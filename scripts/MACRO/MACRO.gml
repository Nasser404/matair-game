#macro IS_SERVER false  
#macro SERVER:IS_SERVER true
#macro CLIENT:IS_SERVER false

#macro LOCAL_TEST false

#macro SERVER_IP "88.187.38.210"
#macro SERVER_PORT 29920
#macro MAX_CLIENT 32
#macro KEEP_ALIVE_INTERVAL 3
#macro MAX_NO_KEEP_ALIVE_REPLY 2
#macro UNIQUE_ID_LIST_SIZE 1024

#macro DEBUG true
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

enum DISCONNECT_REASONS {
    NO_REASON,
    INVALID_ORB_CODE ,
    TIMEOUT,
    ORB_DISCONNECTED,
    SILENT,
    GAME_NOT_JOINABLE,
    
    
    
    
}
function array_remove_value(_array, _value) {
    var _index = array_get_index(_array, _value);
    if (_index != -1) array_delete(_array, _index, 1);
}




global.unique_id = []

function generate_unique_id_list() {
    var _list = []
    for (var i = 0; i <= UNIQUE_ID_LIST_SIZE; i++) {
        array_push(_list, i);
    }
    global.unique_id = array_shuffle(_list);
}



function get_unique_id() {
    if (array_length(global.unique_id) == 0) generate_unique_id_list();
    else return array_pop(global.unique_id);    
        
}


function id_generator() {
    var _chars = "abcdefghijklmnopqrstuvwxyz1234567890"
    var _id = ""
    repeat(2) {
        _id += string_char_at(_chars, irandom_range(1, string_length(_chars)))
        
    }
    return _id;    
}



