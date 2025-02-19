function viewer(_client) : server_client_type(_client) constructor {
    self.type = CLIENT_TYPE.VIEWER
    
    function connected_to_server() {
        send_game_list();
    }
    
    
    function send_game_list() {
        var _games = self.client.server.games;
        var _game_list  = struct_get_names(_games);
        
        var _game_info_list = [];
        for (var i =0, n = array_length(_game_list); i < n; i++) {
            
            var _game_id = _game_list[i]
            var _game = _games[$ _game_id];
    
            var _game_info = _game.get_info();
            array_push(_game_info_list, _game_info)
        }
        
        var _data = {
                "type" : MESSAGE_TYPE.VIEWER_CONNECT,
                "game_info_list" : _game_info_list,
            }
        
        send_packet(_data);
    }
        
    function disconnected_from_server() {
        
    }
}