function player(_client) : client_type(_client) constructor {
    self.type = "PLAYER"
    self.orb_id = undefined;
    function init() {
        var _data = {
            "type" : MESSAGE_TYPE.PLAYER_CONNECT,
        }
        send_packet(_data);
    }
    
}