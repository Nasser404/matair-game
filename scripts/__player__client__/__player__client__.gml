function player_client() constructor {
    self.client         = -1;
    
    
    
    
    timeout = function() {
       // room_goto(rm_menu);
        instance_destroy(obj_client);
    }
    
    timeout_timer = time_source_create(time_source_global, 5, time_source_units_seconds, timeout)
    time_source_start(timeout_timer);
    
    function create() {
        
        var _port = 28770;
        while ((self.client <= 0) and _port < 29920) {
            
            self.client = network_create_socket_ext(network_socket_ws, _port);
            _port++;
        }
        
        network_connect_raw_async(self.client, SERVER_IP, SERVER_PORT);
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