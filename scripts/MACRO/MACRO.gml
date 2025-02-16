#macro IS_SERVER false  
#macro SERVER:IS_SERVER true
#macro CLIENT:IS_SERVER false



#macro SERVER_IP "88.187.38.210"
#macro SERVER_PORT 29920
#macro MAX_CLIENT 32
#macro KEEP_ALIVE_INTERVAL 3
#macro MAX_NO_KEEP_ALIVE_REPLY 4
#macro UNIQUE_ID_LIST_SIZE 65535

#macro DEBUG true
#macro ORB_CODE_LENGHT 4

enum MESSAGE_TYPE {
    IDENTIFICATION,
    PING,
    GAME_INFO,
    RESET,
    GAME_DISCONNECT,
    ORB_CONNECT,
    PLAYER_CONNECT,
    VIEWER_CONNECT,
    PONG,
    NEW_ORB_CODE,
    SERVER_DISCONNECT,
    PLAYER_OPTION,
    ORB_LIST,
    GAME_LIST
};

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


function nigga() constructor {
    self.big = [1, 2, 3];
}

