/// @description CHECK SELECTED
if (keyboard_check_pressed(ord("P"))) board.chance_view();
if (keyboard_check_pressed(ord("V"))) show_message(board.get_board_string());
    

var _x = device_mouse_x_to_gui(0);
var _y = device_mouse_y_to_gui(0);

if (mouse_check_button_pressed(mb_left)) {
    //show_message($"gui : {_x}, {_y}\nreal: {mouse_x}, {mouse_y}")
    board.clicked(_x, _y);
}
