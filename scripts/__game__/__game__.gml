function game(_game_id, _server, _local_game = false, _virtual_game = false) constructor {
    self.board          = new chess_board(0, 0, -1, false, false);
    
    self.game_unique_id = _game_id;
    self.server         = _server;
    self.local_game     = _local_game;
    self.virtual_game   = _virtual_game;
    
    self.conected_orbs_socket    = []; // MUST HAVE TWO FOR A GAME TO EXIST
    self.connected_clients       = [];
    self.conected_players_socket = [];
    self.conected_viewer_socket  = [];
    
    self.connected_orb_colors    = {}; 
    self.day_of_last_move        = date_get_day_of_year(date_current_datetime());
    
    function get_data() {
        var _data = {
            "GAME ID" : self.game_unique_id,
            "NAME"    : self.name,
            
        }
        return _data 
    }
    
    function get_game_id() { return self.game_unique_id;}
    
    function get_day_of_last_move() { return self.day_of_last_move };
    
    function get_board_string() { return self.board.get_board_string(); }
    
    function is_local_game() { return self.local_game == true };
    
    function is_virtual_game() { return self.virtual_game == true };
    
    
    function remove_connection(_socket) {
        array_remove_value(self.conected_orbs_socket,    _socket);
        array_remove_value(self.conected_players_socket, _socket);
        array_remove_value(self.conected_viewer_socket,  _socket);
        array_remove_value(self.connected_clients ,  _socket);
    }
    

    ///@desc Connect a client to this game 
    ///@param {ID.socket} client_socket The client to connect
    function connect_client(_client_socket) {
        
        var _client = _server.clients[$ _client_socket];
        var _type = _client.get_type();
        
        array_push(connected_clients, _client_socket);
        
        switch (_type) {
            case CLIENT_TYPE.ORB    :
                array_push(conected_orbs_socket, _client_socket);
            break;
            case CLIENT_TYPE.VIEWER : 
                array_push(conected_viewer_socket, _client_socket);    
            break;
            case CLIENT_TYPE.PLAYER : 
                array_push(conected_players_socket, _client_socket);    
            break;
            
        } 
        
    }
    
    function disconnect_client(_client_socket) {
        if (array_contains(conected_orbs_socket, _client_socket)) server.close_game(self.game_unique_id); // IF ORB DISCONNECT FROM GAME CLOSE THE GAME
            
        remove_connection(_client_socket);
    }

    ///@desc Tell to all client connected to this game that it has ended
    function close() { // 
        for (var i =0, n= array_length(connected_clients);i<n;i++) {
            var _socket = connected_clients[i];
            self.server.clients[$ _socket].disconnect_from_game(); // TELL ALL CLIENT CONNECTED TO GAME TO DISCONNECT
        }
    }
}