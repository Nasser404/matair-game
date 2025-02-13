function viewer(_client) : server_client_type(_client) constructor {
    self.type = "VIEWER"
    
    function init() {
        var _games = self.client.server.games;
        var _list  = struct_get_names(_games);
        
        var _game_list = [];
        for (var i =0, n = array_length(_list); i < n; i++) {
            var _game = _games[$ i];
            var _game_info = _game.get_data();
            array_push(_game_list, _info)
        }
        
        var _data = {
                "type" : MESSAGE_TYPE.VIEWER_CONNECT,
                "game list" : _game_list,
            }
        
        send_packet(_data);
    }
    
    function disconnected_from_server() {
        
    }
}