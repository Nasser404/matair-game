/// @description Insérez la description ici

player_send_packet({"type" : MESSAGE_TYPE.DISCONNECT_FROM_SERVER});
global.client.close();

global.client            = undefined;

global.orb_list          = undefined;
global.orb_data          = undefined;

global.game_info         = undefined;
global.game_list         = undefined;

global.in_game          = false;
global.asked_a_move     = false;

global.color            = undefined;
global.game_board       = undefined;

