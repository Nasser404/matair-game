/// @description Insérez la description ici


// TITLE
var _title_x = 134;
var _title_y = 81;
var _title_scale = 1 + 0.03 * sin(current_time/1000 * 1.7);
var _title_rot = 0 +  1 * sin(5000 + current_time/1000 * 2);
draw_sprite_ext(spr_game_title, 0, _title_x, _title_y,_title_scale, _title_scale, _title_rot, c_white, 1);
// BUTTON(
var _button_sprites = [spr_play, spr_spectate, spr_rules, spr_credits];

var _x = 49;
var _y = 128;

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

for (var i = 0; i < 4; i++) {
    var _sprite = _button_sprites[i]

    var _w = sprite_get_width(_sprite);
    var _h = sprite_get_height(_sprite);
    if (point_in_rectangle(_mx, _my, _x, _y, _x+_w, _y+_h)) {
        if (mouse_check_button_pressed(mb_left)) {
            
            clicked ??=i;
        }
        
    }
    draw_sprite(_sprite, 0, _x, _y);
    _y+=_h+16;
}

