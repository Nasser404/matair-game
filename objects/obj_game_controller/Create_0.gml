/// @description Init
if (instance_number(obj_game_controller)>1) {
    instance_destroy();
    exit;
}
randomize();
window_set_color(#302E2B);
display_set_gui_size(camera_get_view_width(view_camera[0]), camera_get_view_height(view_camera[0]));
audio_channel_num(1);

depth = 0;

global.name     = "";
global.orb_code = "";

global.vk = new  virtual_keyboard();


global.client            = undefined;

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

global.pop_message_queue        = []
global.current_pop_message      = undefined;
chat_cliked_buffer = 0;
temp_id = id_generator() // used for viewer name

pop_message_buffer = 2; // Slight delay between pop message
