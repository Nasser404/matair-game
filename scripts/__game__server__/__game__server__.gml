function game_server() constructor {
    self.server = undefined; 
    self.server_created = false;
    
    self.socket_list    = [];         // store Sockets of all clients currently connected
    self.clients        = {};         // struct linkinfg all sockets to their object (constructor) type (player, orb , viewer)
    
    self.players_sockets            = [];      // store Sockets of all players currently connected
    self.orbs_sockets               = [];      // store Sockets of all orbs currently connected
    self.viewers_sockets            = [];      // store Sockets of all viewers currently connected
    self.games = {};                           // store all ongoing games
    
    /// @desc Create server on network.
    /// @return {bool} Return if the server creation on the network was successful
    function create() { 
        // TRY TO CREATE A SERVER ON GIVEN PORT
        self.server = network_create_server_raw(network_socket_ws, SERVER_PORT, MAX_CLIENT); 
        
        if (self.server < 0) { 
            // SERVER FAILED TO BE CREATED
            show_debug_message("Unable to make server");
            self.server_created = false;
            game_end();
        } else {
            // SERVER WAS SUCCESSFULLY CREATED
            show_debug_message($"\n\nServer created : {SERVER_IP}:{SERVER_PORT}\n\n");
            self.server_created = true;
        }
        return server_created;
    }
    
    
    
    
    /// @desc Send keep alive to given socket (used by client class time source)
    /// @param {Id.socket} socket The socket to send to
    function send_keep_alive(_socket) {
        // GET LAST PACKET RECEIVED OF CLIENT
        var _last_packet = clients[$ _socket].get_last_packet();  
        
        if (_last_packet >= MAX_NO_KEEP_ALIVE_REPLY) {    
            // TIMEOUT EVENT           
            disconnect_from_server(_socket);
            show_debug_message("CLIENT TIMEOUT")
        }
        else {
            // SEND PING
            clients[$ _socket].add_one_packet()
            //show_debug_message($"SENDING PING({_socket})");
            var _data = {"type" : MESSAGE_TYPE.PING}
            send_packet(_socket, _data);
        }    
        
    }
    
    ///@desc Disconnect a given socket from the server
    ///@param {Id.socket} socket socket to disconnect
    function disconnect_from_server(_socket) {
        // REMOVE SOCKET FROM EVERY SOCKET LIST AND FROM CLIENTS STRUCT
        clients[$ _socket].disconnect_from_server();
        struct_remove(self.clients, _socket);
        array_remove_value(self.socket_list,     _socket);
        array_remove_value(self.orbs_sockets,    _socket);
        array_remove_value(self.viewers_sockets, _socket);
        array_remove_value(self.players_sockets, _socket);
        
        // KILL CONNECTION WITH SOCKET
        network_destroy(_socket);
    }
    
    /// @desc Send data to given socket over the network
    /// @param {Id.socket} socket Socket to send to
    /// @param {struct} data Data to send
    function send_packet(_socket, _data) {
        var _json_data      = json_stringify(_data);
        
        var _buffer_size    = string_byte_length(_json_data);
        var _buffer         = buffer_create(1024, buffer_fixed, 1);
        
        
        buffer_seek(_buffer, buffer_seek_start, 0);
        buffer_write(_buffer, buffer_string, _json_data);
        
        network_send_raw(_socket, _buffer, 1024);
        
        buffer_delete(_buffer);
    }
    

    
    ///@desc Handle client connection
    function handle_connect(_ip, _port, _socket) {
        show_debug_message($"Client connected({_socket}) {_ip}:{_port}");
        
        array_push(self.socket_list, _socket); // Add socket of connected client to socket list
        
        var _data = {       
            "type" : MESSAGE_TYPE.IDENTIFICATION,
        };
        self.send_packet(_socket, _data);     // Send identification request to client
        clients[$ _socket] = new server_client(_socket, self);
        
    }
    
    
    /// @desc Handle client disconnect
    function handle_disconnect(_ip, _port, _socket) { 
        self.disconnect_from_server(_socket);
        show_debug_message($"Client disconnected({_socket}) {_ip}:{_port}");
    }
    
    
    
    /// @desc Procces Async network event packet received
    /// @param {DSmap} network_event
    function packet_received(_network_event) {
        var _type = _network_event[? "type"];
        var _ip,_port, _socket, _data, _buffer;
        switch (_type) {
            case network_type_connect:
                _ip         = _network_event[? "ip"];
                _port       = _network_event[? "port"];
                _socket     = _network_event[? "socket"];
                self.handle_connect(_ip, _port, _socket);
            break;
            
            case network_type_data :
                _ip         = async_load[? "ip"];
                _port       = async_load[? "port"];
                _socket     = async_load[? "id"];
                _buffer     =  async_load[? "buffer"];
                self.handle_data(_ip, _port, _socket, _buffer);
            break;
            
            case network_type_disconnect :
                _ip         = async_load[? "ip"];
                _port       = async_load[? "port"];
                _socket     = async_load[? "socket"];
                self.handle_disconnect(_ip, _port, _socket);
            break;
        }
        
    }
    
    function close() {
        network_destroy(self.server);
        show_debug_message("\n\nServer closed !\n\n");
    }
    
    ///@param {struct.game} game
    function destroy_game(_game) {
        var _game_id = _game.get_game_id();
        _game.close();
        //HELLO
        struct_remove(self.games, _game_id);
        delete _game;
    } 
        
    /// @desc Handle data received
    /// @param {string} ip 
    /// @param {int} port
    /// @param {Id.socket} socket
    /// @param {string} data
    function handle_data(_ip, _port, _socket, _buffer) {
        var _data, _orb, _client, _orb_code;
 
        var _json_data  = buffer_read(_buffer, buffer_string);
        show_debug_message(_json_data)
        _data       = json_parse(_json_data);
        show_debug_message($"Data received from Client({_socket}) {_ip}:{_port} - {_data}");
        
        var _type = _data[$ "type"];
        
        
        switch (_type) {
            case MESSAGE_TYPE.IDENTIFICATION: 
                var _identifier = _data[$ "identifier"];        // ORB, PLAYER, VIEWER
                show_debug_message($"{_identifier} IDENTIFY")
                switch (_identifier) {
                    
                    case "ORB"      : array_push(self.orbs_sockets,    _socket); break;
                    case "PLAYER"   : array_push(self.players_sockets, _socket); break;
                    case "VIEWER"   : array_push(self.viewers_sockets, _socket); break;
                }
                clients[$ _socket].identify(_identifier);
            
            
            break;
                
            case MESSAGE_TYPE.PONG:
                clients[$ _socket].ping_reply();
                //show_debug_message($"RECEIVED PONG({_socket})")
            break;
            
            case MESSAGE_TYPE.ORB_CONNECT : 
                self.handle_orb_connect(_socket, _data);
            break;
            
            case MESSAGE_TYPE.NEW_ORB_CODE : 
            _orb_code   = _data[$ "orb_code"];
            _client = clients[$ _socket];
            _orb.set_code(_orb_id);
            break
            
            
            case MESSAGE_TYPE.PLAYER_CONNECT :
                self.handle_player_connect(_socket, _data);
            break;
        }

    }
    
 
    
    function handle_player_connect(socket, data) {
        var _player_orb_code    = data[$ "player_orb_code"];
        var _player_name        = data[$ "player_name"];
    
        _client = clients[$ socket];
        var _player = _client.client_type;
    
        var _player_orb = undefined;
    
        // Check if any of the orb code the player given correspond to a connected orb
        for (var i = 0, n = array_length(self.orbs_sockets);i<n;i++) { 
            var _orb_socket = self.orbs_sockets[i];
            var _orb = self.clients[$ _orb_socket];
            var _orb_code = _orb.get_code();
            
            if (_orb_code == _player_orb_code) {
                _player_orb = _orb;
            }
        }
    
        if (_player_orb!=undefined) { // The code given by the player match the code of a connect orb
            
            
            var _possible_action = {"CONTINUE": false, "NEW GAME" : false, "END GAME" : false};
            if (_player_orb.is_in_game()) { // ORB ALREADY IN A GAME 
                
                var _orb_game = self.games[$ _player_orb.get_connected_game_id()]; // GET GAME OF ORB
                
                
            } else { // ORB NOT IN A GAME
                
                _possible_action[$ "NEW GAME"] = true;
                
            }
            
            
        } else { // The code given by the player does not match the code of any of the connect orb
            disconnect_from_server(socket); // Disconnect the player
        }
        
        function handle_orb_connect(_socket, data) {
            var _orb_id     = data[$ "orb_id"];
            var _orb_code   = data[$ "orb_code"];
            var _orb_board  = data[$ "orb_board"];
            
            var _client = clients[$ _socket];
            var _orb = _client.client_type;
            _orb.set_id(_orb_id);
            _orb.set_code(_orb_code);
            
            var _orb_game = undefined;
            
            /// Check if orb connecting is already in a game
            var _games = struct_get_names(self.games);
            for (var i=0, n=array_length(_games); i<n; i++) {
                var _game_id = _games[i];
                var _game = self.games[$ _game_id];
                if (array_contains(_game.get_playing_orb_id(), _orb_id)) {
                    _orb_game = _game;
                    break;
                }
            }
            
            if (_orb_game!=undefined) { // Orb connecting was already in a existing game
                //get game board
                var _game_board = _orb_game.get_board_string();  
                
                if (_orb_board == _game_board) { // Orb board and game board are the samme
                    _orb.connect_to_game(_orb_game); // Connect orb to game
                    
                } else { // Orb board and game board are not the same (should never happend)
                    
                    destroy_game(_orb_game);    // END THE GAME
                    
                }
            } else { // orb connecting was not in a existing game
                _orb.reset(); // tell orb to reset
                
            } 

        }
    }
    
}
