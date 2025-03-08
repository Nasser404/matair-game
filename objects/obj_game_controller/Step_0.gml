/// @description Check for import in chess board

global.vk.step();


if (global.in_game) and (global.game_board != undefined) and (!global.chat_up) {
    
    var _x = device_mouse_x_to_gui(0);
    var _y = device_mouse_y_to_gui(0);
    
    
    if (mouse_check_button_pressed(mb_left)) {
        global.game_board.clicked(_x, _y);
    }
}
