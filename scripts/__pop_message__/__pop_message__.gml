enum POP_MESSAGE_TYPE {
    DISCONNECTED    = 0,
    SERVER_MESSAGE  = 1
}

function pop_message(_type, _message) constructor {
    self.type       = _type;
    self.message    = _message;
    
    
    
    function draw() {
    
        var _x = 135;
        var _y = 240;
        
        var _w = sprite_get_width(spr_pop_message);
        var _h = sprite_get_height(spr_pop_message);
        
        draw_sprite(spr_pop_message, self.type, _x, _y);
        
        
        var _cx = _x - _w/2  + 10;
        var _cy = _y - _h/2  + 10;
        
        var _cw = sprite_get_width(spr_close);
        var _ch = sprite_get_height(spr_close);
        
        draw_sprite(spr_close, 0, _cx, _cy);
        
        
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color((self.type == POP_MESSAGE_TYPE.DISCONNECTED) ? c_yellow : #FFFFFF);
        draw_set_font(fnt_small_info);
        
        var _tx = _x;
        var _ty = _y + 50;
        draw_text(_tx, _ty, self.message);
        
        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);
        
        if (mouse_check_button_pressed(mb_left)) {
            if (point_in_rectangle(_mx, _my, _cx - _cw/2, _cy - _ch/2, _cx + _cw/2, _cy + _ch/2)) {
                global.current_pop_message = undefined;
                if (global.client == undefined) room_goto(rm_menu)
            }
        }
        
    }
    

    
    
}

function enqueue_pop_message(type, message) {
    var _pop_message = new pop_message(type, message);
    array_push(global.pop_message_queue, _pop_message);
}