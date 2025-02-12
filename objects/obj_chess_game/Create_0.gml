/// @description INIT BOARD
board = new chess_board(7,143, spr_chess_board);
board.init_board();

cursor_sprite = spr_cursor;
window_set_cursor(cr_none);

display_set_gui_size(camera_get_view_width(view_camera[0]), camera_get_view_height(view_camera[0]));
audio_channel_num(1);
