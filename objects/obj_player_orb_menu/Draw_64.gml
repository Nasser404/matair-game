/// @description Insérez la description ici
if (global.game_board == undefined) menu[menu_page]();
    
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);


var _x = 8;
var _y = 432;

var _w = sprite_get_width(spr_back_menu);
var _h = sprite_get_height(spr_back_menu);
if (point_in_rectangle(_mx, _my, _x, _y, _x+_w, _y+_h)) {
    if (mouse_check_button_pressed(mb_left)) {
        clicked ??= noone;
    }
}
draw_sprite(spr_mini_back, 0, _x, _y);



