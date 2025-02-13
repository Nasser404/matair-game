/// @description Insérez la description ici

draw_text(50, 50, my_string)
draw_set_color(c_black);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(fnt_vkeyboard);
var _xoff = x;
var _yoff = y;
var _sprites = [spr_small_key, spr_small_key, spr_small_key, spr_small_key, spr_small_key, spr_big_key];
var _text = "1234567890AZERTYUIOPQSDFGHJKLMWXCVBN"

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

var _char = 0;
for(var i = 0; i < 6; i++) {
    var _x = _xoff;
    var _y = _yoff + i*32;
    for (var j = 0; j<6;j++) {
        var _sprite = _sprites[j];
        draw_sprite(_sprite, 0, _x, _y);
        var _w = sprite_get_width(_sprite);
        var _h = sprite_get_height(_sprite);
        
        
        var _key = string_char_at(_text, _char+1);
        
        if (mouse_check_button_pressed(mb_left)) {
            if (point_in_rectangle(_mx, _my, _x, _y, _x+_w, _y+_h)) {
                if (!hidden) my_string+=_key;
            }
        }
        
        draw_text(_x+_w/2, _y +_h/2, _key)
        _x+= _w+ 8;
        _char++;
    }
    
    _sprites = array_reverse(_sprites);    
}
_y+=32;
_x = _xoff+4;


_sprites = [spr_back_key, spr_validate_key, spr_space_key, spr_delete_key];
for (var i = 0; i <4; i++) {
    
    var _sprite = _sprites[i];
    draw_sprite(_sprite, 0, _x, _y);
    var _w = sprite_get_width(_sprite);
    var _h = sprite_get_height(_sprite);
    
    if (mouse_check_button_pressed(mb_left)) {
            if (point_in_rectangle(_mx, _my, _x, _y, _x+_w, _y+_h)) {
                if (!hidden) {
                    clicked??=i;
                    
                }
            }
        }

      _x+= _w+ 8;
    
}