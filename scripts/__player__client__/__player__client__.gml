function player_client() constructor {
    self.client = undefined;
    
    function create() {
        self.client = network_create_socket(network_socket_ws);
        network_connect_raw_async(self.client, SERVER_IP, 29920);
        return self.client;
    }
    
    
    function close() {
        network_destroy(self.client);
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
        show_debug_message($"Data received from server({_socket}) {_ip}:{_port} - {_data}");
        
        var _type = _data[$ "type"];
        
        
        switch (_type) {
            case MESSAGE_TYPE.IDENTIFICATION:
            break;
                
            case MESSAGE_TYPE.PING:
                //show_debug_message($"RECEIVED PONG({_socket})")
            break;
            
            case MESSAGE_TYPE.ORB_CONNECT : 
                self.handle_orb_connect(_socket, _data);
            break;
        }
    }

    
    function packet_received(_network_event) {
        var _type = _network_event[? "type"];
        var _ip,_port, _socket, _data, _buffer;
        switch (_type) {
            case network_type_connect:
                _ip         = _network_event[? "ip"];
                _port       = _network_event[? "port"];
                _socket     = _network_event[? "socket"];
                //self.handle_connect(_ip, _port, _socket);
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
                //self.handle_disconnect(_ip, _port, _socket);
            break;
        }
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
}
}