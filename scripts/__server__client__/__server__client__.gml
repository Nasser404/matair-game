
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
    self.client_type       = undefined;
    self.killed = false;
    function ping_reply() {
        self.last_packet = 0;
    }
    

    function add_one_packet() {
        self.last_packet++;
    }
    function identify(_identifier) {
        switch (_identifier) {
            case "ORB"      : self.client_type = new orb(self); break;
            case "PLAYER"   : self.client_type = new player(self); break;
            case "VIEWER"   : self.client_type = new viewer(self); break;
        }
        
        self.client_type.init();
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
        else return self.client_type.get_type();   
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
            
        self.client_type.connect_to_game(_game);
    }
    
    function disconnect_from_game() { 
        if (self.is_identified) self.client_type.disconnect_from_game(); // Wrapper to disconnect from game
        
    }
    
    ///@desc disconnect client from server
    function disconnect_from_server() { 
        time_source_destroy(self.keep_alive); // destroy keep alive time source 
        
        client_type.disconnect_from_server();
        if (is_identified) { // If client was identified
            var _connected_game_id = self.client_type.get_connected_game_id(); 
            if (_connected_game_id != undefined) {// Check if the client was connected to a game
                
                // If was connected to a game, tell the game to remove the connection to it
                self.server.games[$ _connected_game_id].remove_connection(self.socket);
                if (client_type.get_type() == "PLAYER") {
                    
                    
                }
            }
        }
        self.killed = true;
    }
    

    
    
}