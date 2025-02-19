/// @description Insérez la description ici
clicked     = undefined;
menu_page   = 0;



list_index     = 0
max_list_index = 4;

function player_menu() {
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _x,_y;
    
    draw_set_font(fnt_game);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    if (global.orb_info == undefined) {
        
        if (global.client!= undefined) {
            draw_set_color(c_yellow);
            draw_text(135, 240, "WAITING FOR SERVER");
        } else {
            draw_set_color(c_red);
            draw_text(135, 240, "UNABLE TO CONNECT\nTRY AGAIN");
        }
    } else {
        /// PLAY AND BACK BUTTON
        draw_orb_info(24, 24, global.orb_info);
        draw_game_info(35, 112, global.game_info);
        
        /// PLAY AND BACK BUTTON
        var _sprites = [spr_continue, spr_new_game, spr_end_game];
        var _option = ["CONTINUE", "NEW GAME", "END GAME"]
        _x = 48;
        _y = 192;
        for (var i = 0; i <3;i++) {
            var _sprite = _sprites[i]
            var _can_click = global.play_options[$ _option[i]] ?? false;
            var _w = sprite_get_width(_sprite);
            var _h = sprite_get_height(_sprite);
            if (point_in_rectangle(_mx, _my, _x, _y, _x+_w, _y+_h)) {
                if (mouse_check_button_pressed(mb_left)) {
                    
                    if (_can_click) clicked ??=i;
                }
                
            }
            draw_sprite(_sprite, _can_click, _x, _y);
            _y+=_h+16;
        }
        
        
    }
    
    
}

function new_game_menu() {
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _x,_y;
    
    draw_set_font(fnt_game);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    

    draw_orb_info(24, 16, global.orb_info);
    draw_sprite(spr_versus_banner, 0,0, 104);
    if (global.orb_list != undefined) {
        var _current_page = list_index div max_list_index;
        _x            = 24;
        _y            = 176;
        for (var i = list_index, n = array_length(global.orb_list); i < min(list_index + max_list_index, n); i++) {
            var _w = sprite_get_width(spr_simple_orb_info);
            var _h = sprite_get_height(spr_simple_orb_info);
            if (point_in_rectangle(_mx, _my, _x, _y, _x+_w, _y+_h)) {
                if (mouse_check_button_pressed(mb_left)) {
                    
                    clicked ??=3+i;
                }
                
            }
            
            
            draw_simple_orb_info(_x ,_y, global.orb_list[i]);
            _y+=_h+8;
        }
        
        draw_set_halign(fa_right);
        draw_set_valign(fa_bottom);
        
        var _total_pages = (array_length(global.orb_list)-1) div max_list_index
        draw_set_font(fnt_game);
        draw_set_color(c_white);
        draw_text(265, 475, $"{_current_page} OUT OF {_total_pages}")
    } else {
        
        draw_set_font(fnt_game);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        
        if (global.client!= undefined) {
            draw_set_color(c_yellow);
            draw_text(135, 240, "WAITING FOR SERVER");
        } else {
            draw_set_color(c_red);
            draw_text(135, 240, "UNABLE TO CONNECT\nTRY AGAIN");
        }
    }
    
}


menu = [player_menu, new_game_menu];