///@self Game server
function game_server() constructor {
    self.server = undefined; 
    self.server_created = false;
    
    self.socket_list    = [];         // store Sockets of all clients currently connected
    self.clients        = {};         // struct linkinfg all sockets to their object (constructor) type (player, orb , viewer)
    
    self.players_sockets            = [];      // store Sockets of all players currently connected
    self.orbs_sockets               = [];      // store Sockets of all orbs currently connected
    self.viewers_sockets            = [];      // store Sockets of all viewers currently connected
    self.games = {};                           // store all ongoing games
    self.orbs  = {};
    generate_unique_id_list();
    
    /// @desc Create server on network.
    /// @return {bool} Return if the server creation on the network was successful
    function create() { 
        // TRY TO CREATE A SERVER ON GIVEN PORT
        self.server = network_create_server_raw(network_socket_ws, SERVER_PORT, MAX_CLIENT); 
        
        if (self.server < 0) { 
            // SERVER FAILED TO BE CREATED
            show_debug_message("Unable to make server");
            self.server_created = false;
            game_end();
        } else {
            // SERVER WAS SUCCESSFULLY CREATED
            show_debug_message($"\n\nServer created : {SERVER_IP}:{SERVER_PORT}\n\n");
            self.server_created = true;
        }
        return server_created;
    }
    
    function close() {
        network_destroy(self.server);
        show_debug_message("\n\nServer closed !\n\n");
    }
    
    ///@return {struct.game}
    function create_game(_game_id =  get_unique_id(), _local_game = false, _virtual_game = false) {
        self.games[$ _game_id] = new game(_game_id, self, _local_game, _virtual_game);
        return self.games[$ _game_id];
        
        send_game_list();
    }
    
    ///@param {String} game_id
    function close_game(_game_id) {
        var _game = self.games[$ _game_id]
        _game.close();
        struct_remove(self.games, _game_id);
        delete _game;
        
        send_game_list();
    } 
    
    function send_game_list() {
        for (var i =0, n= array_length(self.viewers_sockets);i<n;i++) {
                var _socket = self.viewers_sockets[i]
                var _viewer = self.clients[$ _socket].client_type;
                _viewer.send_game_list();
            }
        
    }
    
   
    /// @desc Send keep alive to given socket (used by client class time source)
    /// @param {Id.socket} socket The socket to send to
    function send_keep_alive(_socket) {
        // GET LAST PACKET RECEIVED OF CLIENT
        var _last_packet = clients[$ _socket].get_last_packet();  
        
        if (_last_packet >= MAX_NO_KEEP_ALIVE_REPLY) {    
            // TIMEOUT EVENT           
            disconnect_from_server(_socket, DISCONNECT_REASONS.TIMEOUT);
            show_debug_message("CLIENT TIMEOUT")
        }
        else {
            // SEND PING
            clients[$ _socket].ping_sent()
            //show_debug_message($"SENDING PING({_socket})");
            var _data = {"type" : MESSAGE_TYPE.PING}
            send_packet(_socket, _data);
        }    
        
    }
    
    ///@desc Disconnect a given socket from the server
    ///@param {Id.socket} socket socket to disconnect
    ///@param {enum.DISCONNECT_REASONS} reason reason of disconnect
    function disconnect_from_server(_socket, _reason = DISCONNECT_REASONS.NO_REASON) {
        // REMOVE SOCKET FROM EVERY SOCKET LIST AND FROM CLIENTS STRUCT
        
        
        if (clients[$ _socket] != undefined) {
            
            if (_reason != DISCONNECT_REASONS.NO_REASON) {
                var _data = {"type" : MESSAGE_TYPE.DISCONNECT_REASON, "reason" : _reason};
                clients[$ _socket].send_packet(_data);
            }
            
            clients[$ _socket].disconnected_from_server();
        }
        struct_remove(self.clients, _socket);
        array_remove_value(self.socket_list,     _socket);
        array_remove_value(self.orbs_sockets,    _socket);
        array_remove_value(self.viewers_sockets, _socket);
        array_remove_value(self.players_sockets, _socket);
        
        show_debug_message($"DISCONNECTED CLIENT {_socket}")
        // KILL CONNECTION WITH SOCKET
        network_destroy(_socket);
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
    
    function send_packet_list(_data, _socket_list) {
        for (var i =0, n= array_length(_socket_list);i<n;i++) {
            var _socket = _socket_list[i];
            send_packet(_socket, _data);
        }
    }
    /// @desc Procces Async network event packet received
    /// @param {DSmap} network_event
    function packet_received(_network_event) {
        var _type = _network_event[? "type"];
        var _ip,_port, _socket, _data, _buffer;
        switch (_type) {
            case network_type_connect:
                _ip         = _network_event[? "ip"];
                _port       = _network_event[? "port"];
                _socket     = _network_event[? "socket"];
                self.handle_connect(_ip, _port, _socket);
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
                self.handle_disconnect(_ip, _port, _socket);
            break;
        }
        
    }
    
    ///@desc Handle client connection
    function handle_connect(_ip, _port, _socket) {
        show_debug_message($"Client connected({_socket}) {_ip}:{_port}");
        
        array_push(self.socket_list, _socket); // Add socket of connected client to socket list
        
        var _data = {       
            "type" : MESSAGE_TYPE.IDENTIFICATION,
        };
        self.send_packet(_socket, _data);     // Send identification request to client
        clients[$ _socket] = new server_client(_socket, self);
        
    }
    
    
    /// @desc Handle client disconnect
    function handle_disconnect(_ip, _port, _socket) { 
        self.disconnect_from_server(_socket);
        show_debug_message($"Client disconnected({_socket}) {_ip}:{_port}");
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
        if (_data[$ "type"] != MESSAGE_TYPE.PONG) show_debug_message($"Data received from Client({_socket}) {_ip}:{_port} - {_data}");
        
        var _type = _data[$ "type"];
        
        
        switch (_type) {
            case MESSAGE_TYPE.IDENTIFICATION: 
                handle_identification(_socket, _data);
            break;
                
            case MESSAGE_TYPE.PONG:
                clients[$ _socket].ping_reply();
                //show_debug_message($"RECEIVED PONG({_socket})")
            break;
            
            case MESSAGE_TYPE.ORB_CONNECT : 
                self.handle_orb_connect(_socket, _data);
            break;
            
            case MESSAGE_TYPE.PLAYER_CONNECT :
                self.handle_player_connect(_socket, _data);
            break;
            
            case MESSAGE_TYPE.ORB_LIST :
                self.handle_orb_list(_socket, _data);
            break;
            
            case MESSAGE_TYPE.ASK_MOVE :
                self.handle_move_asked(_socket, _data);
            break;
            
            case MESSAGE_TYPE.ORB_DATA :
                self.handle_orb_data(_socket, _data);
            break;
            
            case MESSAGE_TYPE.DISCONNECT_FROM_SERVER :
                disconnect_from_server(_socket);
            break;
            
            case MESSAGE_TYPE.ORB_NEW_GAME :
                self.handle_orb_new_game(_socket, _data);
            break;
        }

    }
  
    function handle_orb_new_game(_socket, _data) {
        var _orb1_id = _data[$ "id1"];
        var _orb2_id = _data[$ "id2"];
        
        show_debug_message("NEW GAME ASKED")
        var _local_game = (_orb1_id == _orb2_id);
        
        var _orb1_socket   = orbs[$ _orb1_id] ?? -1;
        var _orb2_socket   = orbs[$ _orb2_id] ?? -1;
        
        var _orb1_client = clients[$ _orb1_socket];
        var _orb2_client = clients[$ _orb2_socket];
        if ((_orb1_client != undefined) and (_orb2_client != undefined)) { // Check if both orb exist
            var _orb1 = _orb1_client.client_type;
            var _orb2 = _orb2_client.client_type;
            
            if (_orb1.new_game_possible()) and (_orb2.new_game_possible()) {
                
                
                
                var _new_game = create_game(get_unique_id(), _local_game, false);
                _new_game.connect_client(_orb1_socket);
                if (!_local_game) _new_game.connect_client(_orb2_socket);
                _new_game.connect_client(_socket);
                
                _orb1.add_main_player(_socket);
                
            }
            
            
        }
        
    }
    
    function handle_orb_data(_socket, _data) {
        var _orb = clients[$ _socket].client_type;
        var _status = _data[$ "status"];
        var _orb_code   = _data[$ "orb_code"];
    
        _orb.set_status(_status);
        _orb.set_code(_orb_code);
        
    }
    function handle_move_asked(_socket, _data) {
        var _game_id = _data[$ "game_id"];
        var _game = games[$ _game_id];
        
        if (_game == undefined) disconnect_from_server(_socket);
        else _game.move_asked(_socket, _data);
        
        
        
    }
    function handle_orb_list(_socket, data) {
        var _orb_list = [];
        for (var i = 0, n = array_length(self.orbs_sockets);i<n;i++) { // GET ORB LIST
            var _orb_socket = self.orbs_sockets[i];
            var _orb = self.clients[$ _orb_socket].client_type;
    
            array_push(_orb_list, _orb.get_simple_data());
        }
        var _data = {"type" : MESSAGE_TYPE.ORB_LIST, "orb_list" : _orb_list}
        send_packet(_socket, _data)
        
    }
    
    function handle_identification(_socket, _data) {
        var _identifier = _data[$ "identifier"];        // ORB, PLAYER, VIEWER
        show_debug_message($"{_identifier} IDENTIFY")
        switch (_identifier) {
            
            case CLIENT_TYPE.ORB      : array_push(self.orbs_sockets,    _socket); break;
            case CLIENT_TYPE.PLAYER   : array_push(self.players_sockets, _socket); break;
            case CLIENT_TYPE.VIEWER   : array_push(self.viewers_sockets, _socket); break;
        }
        clients[$ _socket].identify(_identifier);
    }
    
    function handle_player_connect(socket, data) { 
        var _player_orb_code    = data[$ "player_orb_code"];
        var _player_name        = data[$ "player_name"];
    
        var _client = clients[$ socket];
        var _player = _client.client_type;
        _player.set_name(_player_name);
    
        /////////////////////////// VIRTUAL GAME //////////////////////////////////
        if (string_copy(_player_orb_code, 1, 2) == "VG") { // IF GAME IS VIRTUAL GAME
            var _new_game = self.games[$ _player_orb_code] ?? create_game(_player_orb_code, false, true); 
            if (_new_game.game_joinable()) _new_game.connect_client(socket);
            else disconnect_from_server(socket, DISCONNECT_REASONS.GAME_NOT_JOINABLE)    
            exit;
        }
       ////////////////////////////////////////////////////////////////////////////////////
        
        var _player_orb = undefined;
        // Check if any of the orb code the player given correspond to a connected orb
        for (var i = 0, n = array_length(self.orbs_sockets);i<n;i++) { 
            var _orb_socket = self.orbs_sockets[i];
            var _orb = self.clients[$ _orb_socket].client_type;
            
            var _orb_code = _orb.get_code();
            if (_orb_code == _player_orb_code) {
                _player_orb = _orb; 
                break;
            }
        }
    
        if (_player_orb!=undefined) _player_orb.connect_player(socket); // The code given by the player match the code of a connect orb 
        else disconnect_from_server(socket, DISCONNECT_REASONS.INVALID_ORB_CODE); // The code given by the player does not match the code of any of the connect orb
    }
        
    function handle_orb_connect(_socket, data) {
        var _orb_id     = data[$ "orb_id"];
        var _orb_code   = data[$ "orb_code"];
        var _orb_board  = data[$ "orb_board"];
        
        var _client = clients[$ _socket];
        var _orb = _client.client_type;
        _orb.set_id(_orb_id);
        _orb.set_code(_orb_code);
        
        _orb.reset(); // tell orb to reset
        self.orbs[$ _orb_id] = _socket;
        
    }
    

    

    

}