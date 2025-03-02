#macro LOCAL_TEST false

#macro SERVER_IP "88.187.38.210"
#macro SERVER_PORT 29920

#macro ORB_CODE_LENGHT 4

enum MESSAGE_TYPE {
    IDENTIFICATION  = 0 ,           
    
    PING            = 1,
    PONG            = 2,
    
    GAME_DATA       = 3,
    GAME_INFO       = 4,
    GAME_DISCONNECT = 5,
    
    ORB_DATA        = 6,
    ORB_RESET       = 7,
    
    ORB_CONNECT     = 8,
    PLAYER_CONNECT  = 9,
    VIEWER_CONNECT  = 10,

    ORB_LIST        = 11,
    GAME_LIST       = 12,
    
    DISCONNECT_REASON=13,
    
    ASK_MOVE        = 14,
    MOVE            = 15,
    
    ORB_NEW_GAME    = 16,
    ORB_CONTINUE_GAME=17,
    ORB_END_GAME    = 18,
    
    DISCONNECT_FROM_SERVER = 19 , 
    INFORMATION            = 20 ,
    
    GAME_CHAT              = 21,
}
enum CLIENT_TYPE {
    ORB,
    PLAYER,
    VIEWER,
    
}

enum ORB_STATUS {
    IDLE,
    OCCUPIED,
    
    
    
}

enum DISCONNECT_REASONS {
    NO_REASON,
    INVALID_ORB_CODE ,
    TIMEOUT,
    ORB_DISCONNECTED,
    SILENT,
    GAME_NOT_JOINABLE,
    
    
    
    
}


enum INFORMATION_TYPE {
    ORB_NOT_READY     = 0,
    MOVE_NOT_LEGAL    = 1,
    NOT_PLAYER_TURN   = 2,
    NOT_GAME_PLAYER   = 3
}

enum GAME_STATUS {
    on_going = 0,
    ended    = 1
}
function array_remove_value(_array, _value) {
    var _index = array_get_index(_array, _value);
    if (_index != -1) array_delete(_array, _index, 1);
}





function id_generator() {
    var _chars = "abcdefghijklmnopqrstuvwxyz1234567890"
    var _id = ""
    repeat(2) {
        _id += string_char_at(_chars, irandom_range(1, string_length(_chars)))
        
    }
    return _id;    
}



