function player_send_packet(_data) {
    if (global.client!=undefined) {
        global.client.send_packet(global.client.client, _data);
    }
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
          
        if (_game_info[$ "status"] == GAME_STATUS.ended) _possible_option[$ "END GAME"] = true;
         if (_orb_data[$ "status"] == ORB_STATUS.OCCUPIED) _possible_option[$ "END GAME"] = false; // CANT CLOSE GAME IF ORB IS PHYSYCALLY MOVING 
    
    } else {
        if (_orb_data[$ "status"] == ORB_STATUS.IDLE) _possible_option[$ "NEW GAME"] = true;
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