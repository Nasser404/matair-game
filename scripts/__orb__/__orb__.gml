
enum ORB_INTERFACE {
    PLAYER,
    OPPONENT,
}
function orb(_client) : server_client_type(_client) constructor {
    self.type = "ORB"
    self.orb_code                = undefined;
    self.orb_id                  = undefined;
    self.orb_free                = false;
    self.player_on_orb           = [];
    self.interfaces = [undefined, undefined];
    
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
        "id" : orb_id,
        "code" : orb_code,
        "in_game" : is_in_game(),
        "occupied" :  is_occupied(),
         "game_id" : connected_game_id,   
        }
        
        return _data
        
    }
    
    function is_occupied() {
        
        var _occupied = false;
        var _game = get_game();
        var _local_game = false
        if (_game != noone) _local_game = _game.is_local_game();
        
        if (_local_game) return (!is_interface_free(ORB_INTERFACE.PLAYER)) or (!is_interface_free(ORB_INTERFACE.OPPONENT))
        else return !is_interface_free(ORB_INTERFACE.PLAYER)
        
    }
    function set_code(_code) { self.orb_code = _code;}
    function set_id(_id) { self.orb_id = _id; }
    function get_code(){return self.orb_code;show_message(orb_code)}
    
    function is_interface_free(_interface) {
        return self.interfaces[_interface] == undefined;
    }
    
    function connect_player_to_interface(_interface ,_player) {
        _player.connect_to_orb(self, _interface);
        self.interfaces[_interface] = _player;
    }
    
    function get_connect_player_interface(_interface) {
        return self.interfaces[_interface];
    }
    
    function disconnect_player_of_interface(_interface ,_player) {
        self.interfaces[_interface] = undefined;
        
        
    }
    
    function reset() {
        self.connected_player_socket = [];
        self.orb_free = false;
        var _data = {"type" : MESSAGE_TYPE.RESET} 
        send_packet(_data);
    }
    
    function disconnected_from_server() {
        for (var i = 0, n = array_length(player_on_orb); i < n; i++) {
            disconnect(player_on_orb[i]);
        }
    }
    
    function add_player(_socket) {
        array_push(player_on_orb, _socket)
    }
    function remove_player(_socket) {
        array_remove_value(player_on_orb, _socket)
    }
}