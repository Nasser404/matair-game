function game(_game_id, _server) constructor {
    self.board = new chess_board(0, 0, -1, 0, false);
    self.game_unique_id = _game_id;
    self.name    = "";
    self.playing_orbs_id         = [];
    self.connected_clients       = [];
    self.conected_orbs_socket    = [];
    self.conected_players_socket = [];
    self.conected_viewer_socket  = [];
    self.connected_orb_colors    = {}; 
    self.server = _server;
    
    
    
    
    function get_data() {
        var _data = {
            "GAME ID" : self.game_unique_id,
            "NAME"    : self.name,
            
        }
        return _data
    }
    
    function remove_connection(_socket) {
        array_remove_value(self.conected_orbs_socket,    _socket);
        array_remove_value(self.conected_players_socket, _socket);
        array_remove_value(self.conected_viewer_socket,  _socket);
        array_remove_value(self.connected_clients ,  _socket);
    }
    
    function get_playing_orb_id() {
        
        return self.playing_orbs_id;
    }
    
    function get_board_string() {
        return self.board.get_board_string();
    }
    
    ///@desc Connect a client to this game 
    ///@param {struct.server_client} client The client to connect
    function connect_to_client(_client) {
        var _type = _client.get_type();
        var _socket = _client.get_socket();
        
        array_push(connected_clients, _socket);
        
        switch (_type) {
            case "ORB"    :
                array_push(conected_orbs_socket, _socket);
            break;
            case "VIEWER" : 
                array_push(conected_viewer_socket, _socket);    
            break;
            case "PLAYER" : 
                array_push(conected_players_socket, _socket);    
            break;
            
        } 
        
    }
    
    function get_game_id() {
        return self.game_unique_id;
    }
    
    ///@desc Tell to all client connected to this game that it has ended
    function close() { // 
        for (var i =0, n= array_length(connected_clients);i<n;i++) {
            var _socket = connected_clients[i];
            self.server.clients[$ _socket].game_ended();
        }
    }
}