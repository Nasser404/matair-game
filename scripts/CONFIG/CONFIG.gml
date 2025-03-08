#macro LOCAL_TEST false
#macro ORB_CODE_LENGHT 4

ini_open("config.ini");

global.SERVER_IP    = ini_read_string("server_config", "server_ip", "127.0.0.1");
global.SERVER_PORT  = ini_read_real("server_config", "server_port", 29920);

ini_close();
