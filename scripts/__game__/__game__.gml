function game(_game_id, _server, _local_game = false, _virtual_game = false) constructor {
    self.board          = new chess_board(0, 0, -1, false, false);
    self.board.init_board();
    self.game_unique_id = _game_id;
    self.server         = _server;
    self.local_game     = _local_game;
    self.virtual_game   = _virtual_game;
    
    self.conected_orbs_socket    = []; // MUST HAVE TWO FOR A  REAL GAME TO EXIST 0 FOR A VG
    self.connected_clients       = [];
    self.conected_players_socket = [];
    self.connected_viewer_socket  = [];
    
    self.day_of_last_move        = date_get_day_of_year(date_current_datetime());
    
    self.colors                  = [undefined, undefined]; // WHITE, BLACK
    
    self.chat_history            = [];
    
    function get_info() {
        var _white_client =  get_client(self.colors[piece_color.white]);
        var _black_client =  get_client(self.colors[piece_color.black]);
        
        
        if (virtual_game) {
            var _white_player_name = (_white_client == undefined) ? "" : _white_client.get_name();
            var _black_player_name = (_black_client == undefined) ? "" : _black_client.get_name();
            
            var _white_orb_name = "";
            var _black_orb_name = "";
        } else {
            var _white_orb_name = (_white_client == undefined) ? "" : _white_client.get_name();
            var _black_orb_name = (_black_client == undefined) ? "" : _black_client.get_name();
            
            var _white_player_name = "TO DO"
            var _black_player_name = "DONT FORGET" // GET NAME OF PLAYER USING ORB VARIABLE TO GET PLAYER SOCKET
        }
            
        
        var _data = {
            "game_id"           : self.game_unique_id,
            "local_game"        : self.local_game,
            "virtual_game"      : self.virtual_game,
            "status"            : game_ended(),
            "white_player"      : _white_player_name,
            "black_player"      : _black_player_name,
            "white_orb"         : _white_orb_name,
            "black_orb"         : _black_orb_name,
            "number_of_viewer"  : self.get_number_of_viewer(),
            "chat_history"      : self.chat_history,
            "winner"            : self.board.winner,
        }
        return _data;
    }
    
    function get_data() {
        return board.get_board_data();
    }
    function game_ended() {
        return self.board.game_ended;
    }
    
    function get_number_of_viewer() {
        return array_length(connected_viewer_socket)
    }
    function get_number_of_player() {
        return array_length(conected_players_socket);
    }
    
    function game_joinable() {
        return (get_number_of_player() < 2) and (!game_ended());
    }
    function get_game_id() { return self.game_unique_id;}
    
    function get_day_of_last_move() { return self.day_of_last_move };
    
    function get_board_string() { return self.board.get_board_string(); }
    
    function is_local_game() { return self.local_game == true };
    
    function is_virtual_game() { return self.virtual_game == true };
    
    
    ///@return {struct.server_client}
    function get_client(_client_socket) {
        
        
        if (_client_socket == undefined) return undefined;
        else return server.clients[$ _client_socket].client_type;
    }
    
    function remove_connection(_socket) {
        array_remove_value(self.conected_orbs_socket,    _socket);
        array_remove_value(self.conected_players_socket, _socket);
        array_remove_value(self.connected_viewer_socket,  _socket);
        array_remove_value(self.connected_clients ,  _socket);
    }
    

    ///@desc Connect a client to this game 
    ///@param {ID.socket} client_socket The client to connect
    function connect_client(_client_socket) {
        array_push(connected_clients, _client_socket);
        
        var _client = get_client(_client_socket);
        var _type = _client.get_type();
      
        _client.set_connected_game_id(self.game_unique_id);
        
   
        switch (_type) {
            case CLIENT_TYPE.ORB    :
                if (!local_game) and (!virtual_game) give_client_color(_client_socket);
                array_push(conected_orbs_socket, _client_socket);
            break;
            case CLIENT_TYPE.VIEWER : 
                array_push(connected_viewer_socket, _client_socket);
            break;
            case CLIENT_TYPE.PLAYER : 
                if (virtual_game) or (local_game) give_client_color(_client_socket);
                else {
                    var _player_orb = _client.get_orb();
                    var _player_orb_color = _player_orb.get_color();
                    _client.set_color(_player_orb_color);
                }  
                array_push(conected_players_socket, _client_socket); 
            
                   
            break;
        } 
        
        var _data = {"type" : MESSAGE_TYPE.GAME_DATA,
                     "info" : get_info(),
                     "data" : get_data(),
                     "board_string" : get_board_string(),
                     "color" :  _client.get_color(),
                     "force_update" : true};
            
        _client.send_packet(_data);
        
        _data = {
            "type" :MESSAGE_TYPE.GAME_INFO,
            "info":get_info(),
        }
        send_packet_all(_data, [_client_socket]);
        
    }
    
    function send_packet_all(_data, _except = []) {
        for (var i =0, n= array_length(connected_clients);i<n;i++) {
            var _socket = connected_clients[i];
            if !(array_contains(_except, _socket)) {
                
               var _client = get_client(_socket);
               _client.send_packet(_data); // SEND ALL CLIENT INFO
                
            }
        }
    }

    function give_client_color(_client_socket) {
        var _client = get_client(_client_socket);
        
        var _choices =  []
        
        if (self.colors[piece_color.black] == undefined) array_push(_choices, piece_color.black);
        if (self.colors[piece_color.white] == undefined) array_push(_choices, piece_color.white);
            
   
        var _color =  _choices[irandom(array_length(_choices)-1)];
        
        self.colors[_color] = _client_socket;
        _client.set_color(_color);
        //show_message(self.colors)
        
    }
    
    function disconnect_client(_client_socket) { // Function called by client
        if (array_contains(conected_orbs_socket, _client_socket)) server.close_game(self.game_unique_id); // IF ORB DISCONNECT FROM GAME CLOSE THE GAME
            
        var _client         = get_client(_client_socket);
        var _client_color   =_client.get_color();
        if (_client_color!= undefined) self.colors[_client_color] = undefined;
            
        
        remove_connection(_client_socket);
        
        if (get_number_of_player()<2) and (get_number_of_turn() > 4) { // IF A PLAYER QUIT AFTER 4 TURN IT'S COUNTED AS A SURRENDER OTHER PARTI WINS
            
            board.game_ended = true;
            if (colors[piece_color.white] == undefined) board.winner = piece_color.black;
            else board.winner = piece_color.white;
        }
        
        if (get_number_of_player()<=0) {
            server.close_game(self.game_unique_id); // IF NO PLAYER LEFT CLOSE THE GAME
            exit;
        } 
         
        var _data = {
            "type" :MESSAGE_TYPE.GAME_INFO,
            "info":get_info(),
        }
        send_packet_all(_data);
           
        
        
        
  
    }
    
    function get_game_turn() {return board.turn}
    function get_number_of_turn() {return board.n_of_turn};
    function is_move_legal(_from, _to) {return board.check_move_valid(_from, _to)}
    
    function move_asked(_client_socket, _move_data) {
        var _can_fufill_demand = false;
        
        var _color = _move_data[$ "color"];
        var _from = _move_data[$ "from"];
        var _to = _move_data[$ "to"];
        if (array_contains(conected_players_socket,_client_socket)) {
            
            if (get_game_turn() == _color) {
                if (is_move_legal(_from, _to)) {
                    board.move_piece(_from, _to);
                    var _data = {
                        "type" : MESSAGE_TYPE.MOVE,
                        "from" : _from,
                        "to"   : _to
                    }
                    
                    send_packet_all(_data);
                    
                    
                    
                    _can_fufill_demand = true;
                }
                
            }
        }
        
        if (!_can_fufill_demand) {
            var _client = get_client(_client_socket);
            var _data = {"type" : MESSAGE_TYPE.GAME_DATA,
                        "info" : get_info(),
                        "data" : get_data(),
                        "board_string" : get_board_string(),
                        "color" :  _client.get_color(),
                        "force_update" : true};
              
            _client.send_packet(_data);
        }
    }
    
    
    ///@desc Tell to all client connected to this game and that it has been closed
    function close() { // 
        for (var i =0, n= array_length(connected_clients);i<n;i++) {
            var _socket = connected_clients[i];
            var _client = get_client(_socket);
            _client.disconnect_from_game(); // TELL ALL CLIENT CONNECTED TO GAME TO DISCONNECT
        }
    }
}