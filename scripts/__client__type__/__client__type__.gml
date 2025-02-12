function client_type(_client) constructor {
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
        return self.get_connected_game_id() == undefined;
    }
    
    ///@param {struct.game} game
    function connect_to_game(_game) {
        self.connected_game_id = _game.get_game_id();
        _game.connect_to_client(self.client);
    }
    
    function disconnect_from_game() {
        self.connected_game_id = undefined;
        var _data = {
            "type" : MESSAGE_TYPE.GAME_END
        }
        send_packet(_data);
    }
}