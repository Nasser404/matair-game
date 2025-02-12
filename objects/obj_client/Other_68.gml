/// @description Insérez la description ici
var _type = async_load[? "type"];

switch (_type) {
    case network_type_data :
        
    var _ip         = async_load[? "ip"];
    var _port       = async_load[? "port"];
    var _socket     = async_load[? "id"];
    
    show_debug_message($"Data received from server {_ip}:{_port} at {_socket}");
    
    var _data =  async_load[? "buffer"];
    var _msg = buffer_read(_data, buffer_string);
    show_debug_message($"msg : {_msg} received from server !");
    
    
    var _buffer = buffer_create(1024, buffer_fixed, 1);
    buffer_seek(_buffer, buffer_seek_start, 0);
    buffer_write(_buffer, buffer_string, "Pong");
    network_send_raw(_socket, _buffer, 1024);
    buffer_delete(_buffer);
    
    break;
}