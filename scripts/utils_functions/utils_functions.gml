
///@desc send packet using client socket
///@arg {struct} data
function player_send_packet(_data) {
    if (global.client!=undefined) {
        global.client.send_packet(global.client.client, _data);
    }
}

///@desc Find what client can do depending on his orb data
///@arg {struct} orb_data
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
///@desc return if a sprite at a position (x,y) has been clicked
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
///@desc return if a zone at a position (x,y) and size (w, h]
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
///@desc Remove a value from an array
function array_remove_value(_array, _value) {
    var _index = array_get_index(_array, _value);
    if (_index != -1) array_delete(_array, _index, 1);
}
///@desc Generate a random id made of lower case letter and digits
///@arg {int} len lenght of id
function id_generator(_len=2) {
    var _chars = "abcdefghijklmnopqrstuvwxyz1234567890"
    var _id = ""
    repeat(_len) {
        _id += string_char_at(_chars, irandom_range(1, string_length(_chars)))
        
    }
    return _id;    
}
function is_char_alphanum(_char) {
    var _alphanum = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_";
    return (string_pos(_char, _alphanum) != 0);
}

function string_wordwrap_width(text, max_width, brk, split_words) {
    var pos_space = -1;
    var pos_current = 1;
    var text_current = text;
    var text_output = "";

    if (is_real(brk)) brk = "#";

    while (string_length(text_current) >= pos_current) {
        var segment = string_copy(text_current, 1, pos_current);
        if (string_width(segment) > max_width) {
            // Break at last known space
            if (pos_space != -1) {
                text_output += string_copy(text_current, 1, pos_space) + brk;
                text_current = string_copy(text_current, pos_space + 1, string_length(text_current) - pos_space);
                pos_current = 1;
                pos_space = -1;
            }
            else if (split_words) {
                // Force split mid-word
                text_output += string_copy(text_current, 1, pos_current - 1) + brk;
                text_current = string_copy(text_current, pos_current, string_length(text_current) - (pos_current - 1));
                pos_current = 1;
                pos_space = -1;
            }
        }
        pos_current += 1;
        if (string_char_at(text_current, pos_current) == " ") {
            pos_space = pos_current;
        }
    }

    if (string_length(text_current) > 0) {
        text_output += text_current;
    }

    return text_output;
}
