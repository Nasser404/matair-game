/// @description reset all client var

player_send_packet({"type" : MESSAGE_TYPE.DISCONNECT_FROM_SERVER}); // NETWORKING //
global.client.close();

global.client            = undefined;
global.client_type       = undefined;

global.orb_list          = undefined;
global.orb_data          = undefined;

global.game_info         = undefined;
global.game_list         = undefined;

global.in_game          = false;
global.asked_a_move     = false;

global.color            = undefined;
global.game_board       = undefined;
global.client_type      = undefined;

global.game_chat                = undefined;
global.chat_up                  = false;
global.chat_message             = "";
global.new_message_indicator    = false;