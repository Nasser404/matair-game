function player(_client) : server_client_type(_client) constructor {
    self.type                 = "PLAYER"
    self.orb_id               = undefined;
    self.connected_orb_socket = undefined;
    self.orb                  = undefined;
    function init() {
        var _data = {
            "type" : MESSAGE_TYPE.PLAYER_CONNECT,
        }
        send_packet(_data);
    }
    
    function connect_to_orb(_orb) { 
        self.orb = _orb;
        self.ord_id = _orb.get_id();
        self.connected_orb_socket = _orb.get_socket();
    }

    function disconnect_from_server() {
        
    }
}