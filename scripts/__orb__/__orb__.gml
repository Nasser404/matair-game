
enum ORB_STATUS {
    IDLE,
    OCCUPIED,
}
function orb(_client) : server_client_type(_client) constructor {
    self.type = CLIENT_TYPE.ORB
    
    self.orb_code                = undefined;
    self.orb_id                  = undefined;
    
    self.players_on_orb_sockets    = [];
    
    self.main_players_sockets      = [];
    
    self.status                    = ORB_STATUS.OCCUPIED;                    
    ///@desc ORB CONNECT TO SERVER
    function connected_to_server() {
        var _data = {
            "type" : MESSAGE_TYPE.ORB_CONNECT,
        }
        send_packet(_data);
        show_debug_message("SENDING ORB CONNECT");
        /// SEND REAL ORB TO CONNECT (SEND HIS INFORMATION FOR FIRST CONNECTION)
    }
    
     ///@desc ORB DISCONNECT TO SERVER
    function disconnected_from_server() {
        // Disconnect all player on orb
        for (var i = 0, n = array_length(players_on_orb_sockets); i < n; i++) { 
            disconnect_from_server(players_on_orb_sockets[i], DISCONNECT_REASONS.ORB_DISCONNECTED);
        }
        struct_remove(client.server.orbs, self.orb_id);
    }
    
    ///////////////////////////////////// GETTERS ///////////////////////////////////
    function get_id() {return self.orb_id};
    
    function get_data() {
        var _data = {
        "id" : orb_id,
        "code" : orb_code,
        "in_game" :  is_in_game(),
        "status"  :  get_status(), 
        "game_id" : connected_game_id ?? "",
        "used"   : is_used(),    
        "game_info" : get_game_info(), 
        }
        return _data
    }
    
    function get_simple_data() {
        var _data = {
        "id" : orb_id,
        "code" : orb_code,
        "in_game" :  is_in_game(),
        "status"  : get_status(),    
        }
        
        return _data
        
    }
    function get_game_info() {
        var _game = get_game();
        return (_game==undefined) ? {} : _game.get_info();
    }
    
    function get_code(){return self.orb_code;}
    function get_status() {return self.status}
    ////////////////////////////////////////////////////////////////////////////////
    
    //////////////////////////////////////// SETTERS ////////////////////////////////////
    function set_code(_code) { self.orb_code = _code;}
    function set_id(_id) { 
        self.orb_id = _id; 
        self.name   = _id;
    }
    function get_main_player_socket(_n = 0) {
        if (array_length(main_players_sockets) < _n+1) return undefined
        else return main_players_sockets[_n];
    }
    function set_status(_status) {
        self.status = _status;
        var _data = {"type" : MESSAGE_TYPE.ORB_DATA, "orb_data" : get_data()}; 
        
        send_packet_all(_data)
    }
    /////////////////////////////////////////////////////////////////////////////////////   
     
    function new_game_possible() {
        //show_message($"used : {is_used()}\nstatus : {get_status()}\nin game : {is_in_game()}")
        return !is_used() and get_status() == ORB_STATUS.IDLE and !is_in_game();
    }
    function is_used() {
        var _game = get_game();
        var _local_game = false
        if (_game != undefined) _local_game = _game.is_local_game();
         
        if (_local_game) return array_length(main_players_sockets) < 2;
        else return array_length(main_players_sockets) > 0;    
    }
    ///////////////////////////////////////////////////////////////////////////////////////
    
    
    function reset() {
        self.connected_player_socket = [];
        var _data = {"type" : MESSAGE_TYPE.ORB_RESET} 
        send_packet(_data);
    }
    
    function add_main_player(_socket) {
        array_push(main_players_sockets, _socket)
    }
    
    function send_packet_all(_data) {
        for (var i = 0, n = array_length(players_on_orb_sockets); i <n;i++) {
            var _socket = players_on_orb_sockets[i];
            var _player = get_client(_socket);
            _player.send_packet(_data);
        }
    }
    function connect_player(_socket) {
        array_push(players_on_orb_sockets, _socket);
        
        var _player = get_client(_socket);
        _player.set_connected_orb_id(self.orb_id);
        
        var _data = {"type" : MESSAGE_TYPE.ORB_DATA, "orb_data" : get_data()};
        _player.send_packet(_data);
    }
    function remove_player(_socket) {
        array_remove_value(main_players_sockets, _socket);
        array_remove_value(players_on_orb_sockets, _socket);
    }
}