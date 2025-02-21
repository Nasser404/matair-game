/// @description Insérez la description ici
//cursor_sprite = spr_cursor;
//window_set_cursor(cr_none);

display_set_gui_size(camera_get_view_width(view_camera[0]), camera_get_view_height(view_camera[0]));
audio_channel_num(1);
depth = 0;

global.name = "";
global.orb_code = "";

global.vk = new  virtual_keyboard();
window_set_color(#302E2B)

global.client            = undefined;

global.orb_list          = undefined;
global.orb_data          = undefined;

global.game_info         = undefined;
global.game_list         = undefined;

global.in_game          = false;
global.asked_a_move     = false;

global.color            = undefined;
global.game_board       = undefined;
