function server_client_type(_client) constructor {
    self.client = _client;
    self.connected_game_id = undefined;
    self.name              = undefined;
    self.color             = undefined;
    
    ///@return {Id.socket} Socket of client
    function get_socket() {return self.client.get_socket();}
    
    ///@return {Enum.CLIENT_TYPE} Type of client
    function get_type() { return self.type;}
    
    ///@return {String} ID of connected games
    function get_connected_game_id() {return self.connected_game_id;}
    
    function set_color(_color) {self.color = _color};
    function get_color(_color) {return self.color};
    
    
    
    function set_name(_name) {self.name =_name};
    function get_name(){return self.name};
    
    function set_connected_game_id(_game_id) {self.connected_game_id = _game_id};
    /// @desc Wrap client function of sending packet to self socket
    ///@param {struct} data Data to send
    function send_packet(_data) { self.client.send_packet(_data); } 

    /// @return {Bool} Client in game
    function is_in_game() {return self.get_connected_game_id() != undefined;}
    
    ///@desc Get reference to a game
    ///@param {String} game_id Id of game to get the reference of
    function get_game(_game_id = connected_game_id) {
        if (_game_id !=undefined) return client.server.games[$ _game_id]; 
        else return undefined;
    }
    
    ///@return {struct.server_client}
    function get_client(_client_socket) {
        if (_client_socket != undefined) return client.server.clients[$ _client_socket].client_type;
        else return undefined;
    }
    
    ///@desc Disconnect client from game it was connected to
    function disconnect_from_game() { // ACTUAL DISCONNECTION FROM GAME INSTRUCTION
        var _game = get_game();
        if (_game!=undefined) _game.disconnect_client(get_socket()); //Tell game to disconnect client from it
        self.connected_game_id  = undefined;
        self.color              = undefined;
         
        var _data = {
            "type" : MESSAGE_TYPE.GAME_DISCONNECT
        }
        send_packet(_data);
    }

    ///@desc Ask server to disconnect given socket
    ///@param {ID.socket} socket
    function disconnect_from_server(_socket, _reason = DISCONNECT_REASONS.NO_REASON) { 
        self.client.disconnect_from_server(_socket, _reason);
    }

}