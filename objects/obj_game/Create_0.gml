/// @description Insérez la description ici
//cursor_sprite = spr_cursor;
//window_set_cursor(cr_none);

display_set_gui_size(camera_get_view_width(view_camera[0]), camera_get_view_height(view_camera[0]));
audio_channel_num(1);
depth = 0;

global.name = "l";
global.orb_code = "ml45";

global.vk = new  virtual_keyboard();
window_set_color(#302E2B)

global.client = undefined;
global.playing_orb = undefined;