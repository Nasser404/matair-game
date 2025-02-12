/// @description CHECK SELECTED
if (keyboard_check_pressed(ord("P"))) board.chance_view();
if (keyboard_check_pressed(ord("V"))) show_message(board.get_board_string());
    

var _x = device_mouse_x_to_gui(0);
var _y = device_mouse_y_to_gui(0);

if (mouse_check_button_pressed(mb_left)) {
    //show_message($"gui : {_x}, {_y}\nreal: {mouse_x}, {mouse_y}")
    board.clicked(_x, _y);
}
if (os_browser != browser_not_a_browser) {
    if (browser_height != window_get_height()) || (browser_width != window_get_width()) {
        window_set_size(browser_width, browser_height);
    
    }
}
if (keyboard_check_pressed(vk_f1)) instance_create_depth(0, 0, 0, obj_server);
if (keyboard_check_pressed(vk_f2)) instance_create_depth(0, 0, 0, obj_client);
