/// @description DRAW ALL GAME LIST
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _x,_y;

draw_set_font(fnt_game);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
////////////////////////////////////////// BACK BUTTON/////////////////////////

_x = 16;
_y = 432;

var _w = sprite_get_width(spr_back_menu);
var _h = sprite_get_height(spr_back_menu);
if (point_in_rectangle(_mx, _my, _x, _y, _x+_w, _y+_h)) {
    if (mouse_check_button_pressed(mb_left)) {
        clicked ??= -1;
    }
}
draw_sprite(spr_mini_back, 0, _x, _y);
///////////////////////////////////////////////////////////////////


if (global.game_board == undefined) draw_sprite(spr_spectate_banner, 0, 0, 32); //////// SPECTATE BANNER
    

if (global.game_list == undefined) { /// IF NOT CONENCTED TO SERVER
    
    if (global.client!= undefined) { /////////// WAS DISCONNECTED FROM/UNABLE TO CONNECT TO SERVER
        draw_set_color(c_yellow);
        draw_text(135, 240, "WAITING FOR SERVER");
    } else {
        draw_set_color(c_red);
        draw_text(135, 240, "UNABLE TO CONNECT\nTRY AGAIN");
    }
} else { // IS IS CONNECTED TO SERT
    
    if (global.game_board != undefined) { // IF GAME BOARD BEING DRAWN DISPLAY SPECTATOR LABEL AND EXIT CODE
        draw_sprite(spr_spectating_indicator, 0,88, 432)
        exit; //DONT DRAW GAME LIST (CODE BELOW)
    } 
       
    
    var _current_page = list_index div max_list_index;
    _x            = 32;
    _y            = 96;
    
    var _game_list = array_filter(global.game_list, function(_ele, _ind) {return _ele[$ "status"] == 0})
    
    for (var i = list_index, n = array_length(_game_list); i < min(list_index + max_list_index, n); i++) {
        var _w = sprite_get_width(spr_game_info);
        var _h = sprite_get_height(spr_game_info);
        if (point_in_rectangle(_mx, _my, _x, _y, _x+_w, _y+_h)) {
            if (mouse_check_button_pressed(mb_left)) {
                
                clicked ??=i;
            }
            
        }
        draw_game_info(_x, _y, _game_list[i]);
        _y+=_h+8;
        
        
    }
    
    draw_set_halign(fa_right);
    draw_set_valign(fa_bottom);
    draw_set_font(fnt_game);
    var _total_pages = (array_length(_game_list)-1) div max_list_index

    draw_set_color(c_white);
    draw_text(265, 475, $"{_current_page} OUT OF {_total_pages}") /////// DRAW TOTAL PAGES
    
    
    ///////////////////////// REFRESH BUTTON ////////////////////
    if (refresh_cooldown <= 0) {
        _x = 216;
        _y = 16;
        
        _w = sprite_get_width(spr_refresh);
        _h = sprite_get_height(spr_refresh);
        if (point_in_rectangle(_mx, _my, _x, _y, _x+_w, _y+_h)) {
            if (mouse_check_button_pressed(mb_left)) {
                clicked ??= -2;
            }
        }
        draw_sprite(spr_refresh, 0, _x, _y);
    }
    //////////////////////////////////////////////////////
    
}






