
///@param {Id.socket} socket
///@param {struct.game_server} server
function server_client(_socket, _server) constructor {
    self.server         = _server;     // server ref
    self.socket         = _socket;
    self.client_type    = undefined;
    
    /////// SETTING UP TIMEOUT SYSTEM ///////////
    self.last_packet    = 0;
    function send_keep_alive() { self.server.send_keep_alive(self.socket);}
    self.keep_alive     = time_source_create(time_source_game, KEEP_ALIVE_INTERVAL, time_source_units_seconds, self.send_keep_alive,[] ,-1);
    time_source_start(self.keep_alive);
    
    
    function get_last_packet() {return self.last_packet};
    function ping_reply() {self.last_packet = 0;}
    function ping_sent() {self.last_packet++;}
    /////////////////////////////////////////////
    

    function get_socket() {return self.socket};
    
    function identify(_identifier) {
        switch (_identifier) {
            case CLIENT_TYPE.ORB      : self.client_type = new orb(self); break;
            case CLIENT_TYPE.PLAYER   : self.client_type = new player(self); break;
            case CLIENT_TYPE.VIEWER   : self.client_type = new viewer(self); break;
        }
        
        self.client_type.connected_to_server();
    }
    
    ///@desc Wrap of server function, send packet to self socket
    ///@param {struct} data Data to send
    function send_packet(_data) { self.server.send_packet(self.socket, _data);}
    
    ///@desc Return type of client
    ///@return {string}
    function get_type() {
        if (client_type == undefined) return undefined;
        else return self.client_type.get_type();   
    }
    
    function is_orb() { return self.get_type() == CLIENT_TYPE.ORB;}
    function is_player() {return self.get_type() == CLIENT_TYPE.PLAYER;}
    function is_viewer() {return self.get_type() == CLIENT_TYPE.VIEWER;}
    
    
    function connect_to_game(_game_id) { 
        if (self.client_type != undefined) self.client_type.connect_to_game(_game_id);
    }
    
    function disconnect_from_game(_game_id) { 
        if (self.client_type != undefined) self.client_type.disconnect_from_game(_game_id); // Wrapper to disconnect from game
        
    }
    
    ///@desc Code to run when client is disconnected from server
    function disconnected_from_server() { 
        time_source_destroy(self.keep_alive); // destroy keep alive time source 
        
        // If client was identified
        if (self.client_type != undefined) { 
            self.client_type.disconnect_from_game();  // Client disconnect from games
            self.client_type.disconnected_from_server(); // Wrapper to run disconnect from server code
        }
    }
    
    ///@desc Ask server to disconnect given socket
    ///@param {ID.socket} socket
    function disconnect_from_server(_socket, _reason = DISCONNECT_REASONS.NO_REASON) { self.server.disconnect_from_server(_socket, _reason); }
    
}