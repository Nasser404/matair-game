// UPDATE TO VERSION NUMBER MUST HAPPEN EVERY TIME THE NETWORKING CODE IS UPDATED
#macro GAME_VER "1.2" 

#macro LOCAL_TEST false
#macro ORB_CODE_LENGHT 4

/// NEED TO BE THE SAME IN THE SERVO 
#macro ENABLE_EN_PASSANT false
#macro ENABLE_CASTLE false // BUGGED

#macro CENSOR_TEXT true
ini_open("config.ini");

global.SERVER_IP    = ini_read_string("server_config", "server_ip", "127.0.0.1");
global.SERVER_PORT  = ini_read_real("server_config", "server_port", 29920);

ini_close();

