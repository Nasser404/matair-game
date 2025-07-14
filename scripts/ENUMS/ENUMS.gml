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
    
    
    SIZE,
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

enum SPECIAL_MOVES {
    PROMOTION      = 0,
    EN_PASSANT     = 1,         //DISABELED
    CASTLE         = 2,         // DISABELED
    NONE           = 3,     
}
