function player(_client) : server_client_type(_client) constructor {
    self.type                 = CLIENT_TYPE.PLAYER
    self.connected_orb_id     = undefined;
    self.orb_interface        = undefined;
    
    
    function connected_to_server() {
        var _data = {
            "type" : MESSAGE_TYPE.PLAYER_CONNECT,
        }
        send_packet(_data);
    }
    
    function disconnected_from_server() {
        
        var _orb = get_orb();
        if (_orb != undefined) {
            _orb.remove_player(self.get_socket())
        }
    }
    
    
   
    function set_connected_orb_id(_orb_id) {
        self.connected_orb_id = _orb_id;
    }
    
    function get_orb(_orb_id = connected_orb_id) {
        if (_orb_id == undefined) return undefined
        else {
            var _orb_socket = client.server.orbs[$ _orb_id];
            return  client.server.clients[$ _orb_socket].client_type; 
        }
    }
}