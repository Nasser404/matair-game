
///@param {Id.socket} socket
///@param {struct.game_server} server
function server_client(_socket, _server) constructor {
    self.socket         = _socket;
    self.last_packet    = 0;
    function send_keep_alive() { self.server.send_keep_alive(self.socket);}
    self.keep_alive     = time_source_create(time_source_game, KEEP_ALIVE_INTERVAL, time_source_units_seconds, self.send_keep_alive,[] ,-1);
    time_source_start(self.keep_alive);
    self.server         = _server;
    
    function get_last_packet() {return self.last_packet};
    function get_socket() {return self.socket};
    
    self.is_identified = false;
    self.identity       = undefined;
    self.killed = false;
    function ping_reply() {
        self.last_packet = 0;
    }
    
    function disconnect() {
        time_source_destroy(self.keep_alive);
        if (is_identified) {
            var _connected_game_id = self.identity.get_connected_game_id()
            if (_connected_game_id != undefined) {
                self.server.games[$ _connected_game_id].remove_connection(self.socket);
            }
        }
        self.killed = true;
    }
    
    function add_one_packet() {
        self.last_packet++;
    }
    
    function identify(_identifier) {
        switch (_identifier) {
            case "ORB"      : self.identity = new orb(self); break;
            case "PLAYER"   : self.identity = new player(self); break;
            case "VIEWER"   : self.identity = new viewer(self); break;
        }
        
        self.identity.init();
        self.is_identified= true;
        self.exist = true;
    }
    
    function send_packet(_data) {
        if (self.killed) exit;
            
        self.server.send_packet(self.socket, _data);
    }
    
    ///@desc Return type of client
    ///@return {string}
    function get_type() {
        if !self.is_identified return "NONE"
        else return self.identity.get_type();   
    }
    
    function is_orb() {
        return self.get_type() == "ORB";
    }
    function is_player() {
        return self.get_type() == "PLAYER";
    }
    function is_viewer() {
        return self.get_type() == "VIEWER";
    }
    
    function connect_to_game(_game) { 
        if !self.is_identified return 
            
        self.identity.connect_to_game(_game);
    }
    
    function game_ended() { 
        if !self.is_identified return 
            
        self.identity.disconnect_from_game();
        
    }

    
    
}