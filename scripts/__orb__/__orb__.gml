
function orb(_client) : client_type(_client) constructor {
    self.type = "ORB"
    self.orb_code = undefined;
    self.orb_id   = undefined;
    function init() {
        var _data = {
            "type" : MESSAGE_TYPE.ORB_CONNECT,
        }
        send_packet(_data);
        show_debug_message("SENDING ORB CONNECT");
    }
    
    function get_info() {
        var _data = {
            
        }
        
    }
    
    function set_code(_code) { self.orb_code = _code;}
    function set_id(_id) { self.orb_id = _id; }
    function get_code(){return self.orb_code}
    
}