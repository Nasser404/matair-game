function server_client_type(_client) constructor {
    self.client = _client;
    self.connected_game_id = undefined;
    
    function send_packet(_data) {
        self.client.send_packet(_data);
    } 
    function get_type() {
        return self.type;
    }
    
    function get_connected_game_id() {
        return self.connected_game_id;
    }
    
    function is_in_game() {

        return self.get_connected_game_id() != undefined;
    }
    
    ///@return {Id.socket}
    function get_socket() {return self.client.get_socket();}
    
    ///@param {struct.game} game
    function connect_to_game(_game) {
        self.connected_game_id = _game.get_game_id();
        _game.connect_to_client(self.client);
        
        var _data = {"type" : MESSAGE_TYPE.GAME_INFO,
                     "info" : _game.get_data()}
                
        send_packet(_data);
    }
    function get_game() {
        if (connected_game_id!=undefined) return _client.server[$ connected_game_id];
            else return noone;
    }
    function disconnect_from_game() { // ACTUAL DISCONNECTION FROM GAME INSTRUCTION
        self.connected_game_id = undefined; 
        var _data = {
            "type" : MESSAGE_TYPE.GAME_DISCONNECT
        }
        send_packet(_data);
    }
    function ask_disconnect() {
        self.client.ask_disconnect();
    }
    
    function disconnect(_socket) {
        self.client.disconnect(_socket);
    }

}