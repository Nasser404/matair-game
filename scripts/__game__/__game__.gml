function game(_game_id, _server, _local_game = false, _virtual_game = false) constructor {
    self.board          = new chess_board(0, 0, -1, false, false);
    
    self.game_unique_id = _game_id;
    self.server         = _server;
    self.local_game     = _local_game;
    self.virtual_game   = _virtual_game;
    
    self.conected_orbs_socket    = []; // MUST HAVE TWO FOR A  REAL GAME TO EXIST 0 FOR A VG
    self.connected_clients       = [];
    self.conected_players_socket = [];
    self.conected_viewer_socket  = [];
    
    self.day_of_last_move        = date_get_day_of_year(date_current_datetime());
    
    self.colors                  = [undefined, undefined]; // WHITE, BLACK

    function get_info() {
        var _p1 =  get_client(self.colors[piece_color.white]);
        var _p2 =  get_client(self.colors[piece_color.black]);
        
        var _n1 = (_p1 == undefined) ? "----" : _p1.get_name();
        var _n2 = (_p2 == undefined) ? "----" : _p2.get_name();
        var _data = {
            "status" : game_ended(),
            "player1" : _n1,
            "player2" : _n2,
        }
        return _data 
    }
    
    
    function game_ended() {
        return self.board.game_ended;
    }
    
    
    function get_game_id() { return self.game_unique_id;}
    
    function get_day_of_last_move() { return self.day_of_last_move };
    
    function get_board_string() { return self.board.get_board_string(); }
    
    function is_local_game() { return self.local_game == true };
    
    function is_virtual_game() { return self.virtual_game == true };
    ///@return {struct.server_client}
    function get_client(_client_socket) {
        if (_client_socket == undefined) return undefined;
        else return server.clients[$ _client_socket];
    }
    
    function remove_connection(_socket) {
        array_remove_value(self.conected_orbs_socket,    _socket);
        array_remove_value(self.conected_players_socket, _socket);
        array_remove_value(self.conected_viewer_socket,  _socket);
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
                array_push(conected_viewer_socket, _client_socket);
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
                     "data" : get_data()};
            
        _client.send_packet(_data);
    }
    

    function give_client_color(_client_socket) {
        var _client = get_client(_client_socket);
        
        var _choices =  []
        if (self.colors[piece_color.black] == undefined) array_push(_choices, piece_color.black);
        if (self.colors[piece_color.white] == undefined) array_push(_choices, piece_color.white);
        var _color =  _choices[irandom(array_length(_choices)) - 1];
        
        self.colors[_color] = _client_socket;
        _client.set_color(_color);
        
    }
    
    function disconnect_client(_client_socket) { // Function called by client
        if (array_contains(conected_orbs_socket, _client_socket)) server.close_game(self.game_unique_id); // IF ORB DISCONNECT FROM GAME CLOSE THE GAME
            
        var _client         = get_client(_client_socket);
        var _client_color   =_client.get_color();
        if (_client_color!= undefined) self.colors[_client_color] = undefined;
            
        remove_connection(_client_socket);
        
  
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