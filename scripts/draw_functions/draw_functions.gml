function draw_orb_info(_x, _y, _orb_info = {}) {
    
    /*
    var _data = {
    "id" : orb_id,
    "code" : orb_code,
    "in_game" :  is_in_game(),
    "status"  :  get_status(), 
    "game_id" : connected_game_id,
    "used"   : is_used(),       
    }
        */
    draw_set_color(c_white);
    draw_sprite(spr_orb_info, 0, _x, _y);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(fnt_big_info);
    var _id_x = _x + 45;
    var _id_y = _y +5;
    draw_text(_id_x, _id_y, _orb_info[$ "id"]);
    
    draw_set_font(fnt_small_info);
    var _code_x = _x + 8;
    var _code_y = _y + 42;
    draw_text(_code_x, _code_y, $"Code : {_orb_info[$ "code"]}");
    
    draw_set_halign(fa_right);
    draw_set_color(_orb_info[$ "used"] ? c_red: c_lime);
    var _used_x = _x + 216;
    var _used_y = _y + 50;
    draw_text(_used_x, _used_y, _orb_info[$ "used"] ? "USED" : "NOT USED");
    
    draw_set_color(_orb_info[$ "in_game"] ? c_orange : c_white);
    var _in_game_x  = _x + 216;
    var _in_game_y  = _y + 64;
    draw_text(_in_game_x, _in_game_y, _orb_info[$ "in_game"] ? "IN GAME" : "NOT IN GAME");
    
    draw_set_color(_orb_info[$ "status"]== ORB_STATUS.IDLE ? c_white : c_red);
    var _status_x = _x + 216;
    var _status_y = _y + 2;
    draw_text(_status_x,  _status_y, _orb_info[$ "status"]== ORB_STATUS.IDLE  ? "IDLE" : "BUSY");
}



function draw_simple_orb_info(_x, _y, _orb_info = {}) {
    draw_set_color(c_white);
    draw_sprite(spr_simple_orb_info, 0, _x, _y);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top); 
    draw_set_font(fnt_big_info);
    var _id_x = _x +45;
    var _id_y = _y +13;
    draw_text(_id_x, _id_y, _orb_info[$ "id"]);
    
    
    
} 
function find_orb_option(_orb_data) {
    var _possible_option = {"CONTINUE" : false, "NEW GAME" : false, "END GAME" : false};
    
    
    if (_orb_data[$ "in_game"]) {
        var _game_info = _orb_data[$ "game_info"]
        if (!_orb_data[$ "used"]){
            _possible_option[$ "CONTINUE"] = true;
            
            if (_game_info[$ "white_orb"] == _game_info[$ "black_orb"])_possible_option[$ "END GAME"] = true; 
        }
        
        var _current_day = date_get_day_of_year(date_current_datetime()); // If last move happened on a different day we can end the game
        if (abs(_current_day- _game_info[$ "day_of_last_move"]) >= 1) _possible_option[$ "END GAME"] = true; 
            
        if (keyboard_check(vk_f9)) _possible_option[$ "END GAME"] = true; 
            
        
    
    } else {
        _possible_option[$ "NEW GAME"] = true;
    } 
    
    return _possible_option;
    
    
}

function sprite_clicked(_x, _y, _sprite) {
    
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    
    var _w = sprite_get_width(_sprite);
    var _h = sprite_get_height(_sprite);
    if (point_in_rectangle(_mx, _my, _x, _y, _x+_w, _y+_h)) {
        if (mouse_check_button_pressed(mb_left)) {
            return true;
        }
    }
    
    return false;
    
    
    
    
}
function zone_clicked(_x, _y, _w, _h) {
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    
    if (point_in_rectangle(_mx, _my, _x, _y, _x+_w, _y+_h)) {
        if (mouse_check_button_pressed(mb_left)) {
            return true;
        }
    }
    
    return false;
}
function draw_game_info(_x, _y, _game_info = {}) {
    /*var _game_info = {
    "game_id"           : self.game_unique_id,
    "local_game"        : self.local_game,
    "virtual_game"      : self.virtual_game,
    "status"            : game_ended(),
    "white_player"      : _white_player_name,
    "black_player"      : _black_player_name,
    "white_orb"         : _white_orb_name,
    "black_orb"         : _black_orb_name,
    "number_of_viewer"  : self.get_number_of_viewer(),
    "chat_history"      : self.chat_history
        
    }*/
    draw_set_color(c_white);
    
    var _is_virtal_game = _game_info[$ "virtual_game"] ?? 0;
    draw_sprite(spr_game_info, _is_virtal_game, _x, _y);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    if (_game_info[$ "white_player"] != "") draw_set_color(c_yellow);
    
        
    draw_set_font(fnt_small_info);
    var _player_x = _x + 79;
    var _player_y = _y + 5;
   
    var _key = (_is_virtal_game) ? "player" : "orb"
    draw_text(_player_x, _player_y, _game_info[$ $"white_{_key}"] ?? "");
    
    
    
    
    var _status_x = _x + 8;
    var _status_y = _y +50;
    draw_set_color(c_lime);
    draw_text(_status_x,_status_y, $"ID : {_game_info[$ "game_id"]}");
    
    
    draw_set_color(c_white);
    draw_set_halign(fa_right);
    
    if (_game_info[$ "black_player"] != "") draw_set_color(c_yellow);
    var _opponent_x = _x + 170;
    var _opponent_y = _y + 50;
    draw_text(_opponent_x, _opponent_y, _game_info[$ $"black_{_key}"] ?? "");

    
    
    
}