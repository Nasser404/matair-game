function player_send_packet(_data) {
    if (global.client!=undefined) {
        global.client.send_packet(global.client.client, _data);
    }
}

function player_client() constructor {
    self.client         = -1;
    
    /////// SETTING UP TIMEOUT SYSTEM ///////////
    timeout = function() { instance_destroy(obj_client);}
    timeout_timer = time_source_create(time_source_global, 10, time_source_units_seconds, timeout)
    time_source_start(timeout_timer);
    ///////////////////////////////////////////////
    
    function create() {
        self.client = network_create_socket(network_socket_ws);
        network_connect_raw_async(self.client, SERVER_IP, SERVER_PORT);
    }
    

    function close() {
        time_source_destroy(timeout_timer);
        show_debug_message("closing client");
        network_destroy(self.client);
    }
    
    /// @desc Handle data received
    /// @param {string} ip 
    /// @param {int} port
    /// @param {Id.socket} socket
    /// @param {string} data
    function handle_data(_ip, _port, _socket, _buffer) {
        var _data, _orb, _client, _orb_code;

        var _json_data  = buffer_read(_buffer, buffer_string);
        show_debug_message(_json_data)
        _data       = json_parse(_json_data);
        show_debug_message($"Data received from server({_socket}) {_ip}:{_port} - {_data}");
        
        var _type = _data[$ "type"];
        
        
        switch (_type) {
            case MESSAGE_TYPE.IDENTIFICATION:
                _data = {"type" : MESSAGE_TYPE.IDENTIFICATION};
                if (room = rm_player) _data[$ "identifier"] = CLIENT_TYPE.PLAYER;
                else _data[$ "identifier"] = CLIENT_TYPE.VIEWER;
                send_packet(_socket, _data);
            break;
                
            case MESSAGE_TYPE.PING:
                _data = {"type" : MESSAGE_TYPE.PONG};
                time_source_reset(timeout_timer);
                time_source_start(timeout_timer);
                send_packet(_socket, _data);
                //show_debug_message($"RECEIVED PONG({_socket})")
            break;
            
            case MESSAGE_TYPE.PLAYER_CONNECT: 
                handle_player_connect(_socket, _data);
            break;
            
            case MESSAGE_TYPE.VIEWER_CONNECT :
                handle_viewer_connect(_socket, _data)
            break;
            
            
            case MESSAGE_TYPE.PLAYER_OPTION :
                handle_player_option(_socket, _data);
            
            break;
            
            case MESSAGE_TYPE.ORB_LIST :
                handle_orb_list(_socket, _data);
            break;
            
            
            case MESSAGE_TYPE.GAME_DATA :
                handle_game_data(_socket, _data);
            break;
            
            case MESSAGE_TYPE.MOVE  :
                handle_network_move(_socket, _data);
            break;
            
            case MESSAGE_TYPE.GAME_INFO :
                handle_game_info(_socket, _data);
            break;
            
        }
    }
    function handle_game_info(_socket, _data) {
        var _info                   = _data[$ "info"];
        global.game_info = _info
        if (global.game_board!=undefined) global.game_board.load_info(_info);
    }
    function handle_game_data(_socket, _data){
        
    
        var _info                   = _data[$ "info"];
        var _game_data              = _data[$ "data"]; 
        
        var _server_board_string           = _data[$ "board_string"];
        var _my_assigned_color      = _data[$ "color"];
        var _force_update          = _data[$ "force_update"]
        
        global.game_info = _info;
        if (!global.in_game) {
            global.game_board = new chess_board(7,110, spr_chess_board, _my_assigned_color);
            global.game_board.init_board();
            global.color        = _my_assigned_color;
            global.game_board.load_info(_info);
            global.game_board.load_board_data(_game_data);
            global.game_board.calculate_legal_moves(global.color)
            global.in_game = true;
        } else {
            var _my_board_string = global.game_board.get_board_string();
            if ((_my_board_string != _server_board_string) or _force_update) {
                global.color        = _my_assigned_color;
                global.game_board.load_info(_info);
                global.game_board.load_board_data(_game_data);
                global.game_board.calculate_legal_moves(global.color);
            }
        }
        
   
    }
    
    function handle_network_move(_socket, _data) {
        var _from = _data[$ "from"];
        var _to   = _data[$ "to"];
        if (global.in_game) and (global.game_board != undefined) {
            global.game_board.move_piece(_from, _to);
            global.asked_a_move = false;
        }
        
    }
    
    function handle_orb_list(_socket, _data) {
        global.orb_list = _data[$ "orb_list"];
    }
    
    
    function handle_player_connect(_socket, data) {
        var _data = {
        "type"              : MESSAGE_TYPE.PLAYER_CONNECT,
        "player_name"       : global.name,
        "player_orb_code"   : global.orb_code,        
        }
        send_packet(_socket, _data);
    }
    
    function handle_viewer_connect(_socket, data) {
        global.game_list = data[$ "game_info_list"]
        
        
    }
    
    function handle_player_option(_socket, data) {
        global.play_options = data[$ "options"];
        global.orb_info  = data[$ "orb_info"];
    }
    
    function packet_received(_network_event) {
        var _type = _network_event[? "type"];
        var _ip,_port, _socket, _data, _buffer;
        switch (_type) {
            case network_type_connect:
                _ip         = _network_event[? "ip"];
                _port       = _network_event[? "port"];
                _socket     = _network_event[? "socket"];
                //self.handle_connect(_ip, _port, _socket);
            break;
            
            case network_type_data :
                _ip         = async_load[? "ip"];
                _port       = async_load[? "port"];
                _socket     = async_load[? "id"];
                _buffer     =  async_load[? "buffer"];
                self.handle_data(_ip, _port, _socket, _buffer);
            break;
            
            case network_type_disconnect :
                _ip         = async_load[? "ip"];
                _port       = async_load[? "port"];
                _socket     = async_load[? "socket"];
                //self.handle_disconnect(_ip, _port, _socket);
            break;
        }
    }
    
    
    /// @desc Send data to given socket over the network
    /// @param {Id.socket} socket Socket to send to
    /// @param {struct} data Data to send
    function send_packet(_socket, _data) {
        var _json_data      = json_stringify(_data);
        
        var _buffer_size    = string_byte_length(_json_data);
        var _buffer         = buffer_create(1024, buffer_fixed, 1);
        
        
        buffer_seek(_buffer, buffer_seek_start, 0);
        buffer_write(_buffer, buffer_string, _json_data);
        
        network_send_raw(_socket, _buffer, 1024);
        
        buffer_delete(_buffer);
    }
}