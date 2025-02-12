
function orb(_client) : server_client_type(_client) constructor {
    self.type = "ORB"
    self.orb_code                = undefined;
    self.orb_id                  = undefined;
    self.connected_player_socket = [];
    self.orb_free                = false;
    
    function get_id() {return self.orb_id}
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
    function get_connect_player_socket(){return self.connected_player_socket}
    
    function connect_player(_player) {
        _player.connect_to_orb(self);
        
        array_push(connected_player_socket,_player.get_socket());
    }
    function disconnect_player(_player) {
        array_remove_value(connected_player_socket, _player_socket);
        
        
    }
    
    function reset() {
        self.connected_player_socket = [];
        self.orb_free = false;
        self.orb_code = undefined;
        var _data = {"type" : MESSAGE_TYPE.RESET} 
        send_packet(_data);
    }
    
}