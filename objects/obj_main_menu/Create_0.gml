/// @description Insérez la description ici
menu_page       = 0;

clicked         = undefined;
current_writing = undefined;
can_play        = false;


function main_menu() {
    // TITLE
    var _title_x = 134;
    var _title_y = 81;
    var _title_scale = 1 + 0.03 * sin(current_time/1000 * 1.7);
    var _title_rot = 0 +  1 * sin(5000 + current_time/1000 * 2);
    draw_sprite_ext(spr_game_title, 0, _title_x, _title_y,_title_scale, _title_scale, _title_rot, c_white, 1);
    
    
    // BUTTONS
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
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(fnt_small_info);
    
    //// DRAW GAME AND SERVER VERSION
    var _color = c_white;
    if (global.server_ver != "") {
        if (global.server_ver != GAME_VER) _color = c_red;
        else _color = c_lime;
    }
    draw_set_color(_color);
    
    draw_text(8, 448, $"v {GAME_VER}");
    if (global.server_ver != "") draw_text(8, 434, $"server {global.server_ver}");
    draw_set_color(c_white);    
}

function player_join_menu() {
    
    draw_set_valign(fa_top);
    draw_set_halign(fa_left);
    draw_set_font(fnt_game);
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    
    var _sprites = [spr_name, spr_orb_code];
    var _texts   = [global.name, global.orb_code];
    var _x = 48;
    var _y = 72;
    for (var i = 0; i <2;i++) {
        var _sprite = _sprites[i]
            
        var _w = sprite_get_width(_sprite);
        var _h = sprite_get_height(_sprite);
        if (point_in_rectangle(_mx, _my, _x, _y, _x+_w, _y+_h)) {
            if (mouse_check_button_pressed(mb_left)) {
                
                clicked ??=4+i;
            }
            
        }
        
        draw_sprite(_sprite, 0, _x, _y);
        
        var _draw_text = (current_writing == i) ? (global.vk.hidden ? _texts[i]  :global.vk.get_draw_string() ) : _texts[i]
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle)
        draw_text(_x+_w/2, _y+_h/2-8, _draw_text);
        _y+=_h+32;
    }
    
    /// PLAY AND BACK BUTTON
    _sprites = [spr_back_menu, spr_mini_play];
    _x = 16;
    _y = 336;
    for (var i = 0; i <2;i++) {
        var _sprite = _sprites[i]
            
        var _w = sprite_get_width(_sprite);
        var _h = sprite_get_height(_sprite);
        if (point_in_rectangle(_mx, _my, _x, _y, _x+_w, _y+_h)) {
            if (mouse_check_button_pressed(mb_left)) {
                
                clicked ??=6+i;
            }
            
        }
        draw_sprite(_sprite, can_play, _x, _y);
        _x+=_w+32;
    }
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_lime);
    if (can_play) {
        var _is_virtual_game = (string_copy(global.orb_code, 1,2) == "VG");
        if (_is_virtual_game) draw_text(135, 280, "VIRTUAL GAME");
    }
    
}

menu_pages = [main_menu, player_join_menu];

deselect_text = function() {
    current_writing = undefined;
   
}


global.vk.set_close_script(deselect_text);