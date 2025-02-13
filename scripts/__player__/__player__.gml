function player(_client) : server_client_type(_client) constructor {
    self.type                 = "PLAYER"
    self.orb_id               = undefined;
    self.connected_orb_socket = undefined;
    self.orb                  = undefined;
    self.orb_interface        = undefined;
    function init() {
        var _data = {
            "type" : MESSAGE_TYPE.PLAYER_CONNECT,
        }
        send_packet(_data);
    }
    
    function connect_to_orb(_orb, _interface) { 
        self.orb = _orb;
        self.ord_id = _orb.get_id();
        self.connected_orb_socket = _orb.get_socket();
        self.orb_interface = _interface;
    }

    function disconnected_from_server() {
        if (self.orb != undefined) {
            self.orb.disconnect_player_of_interface(self.orb_interface, self);
        }
    }
}