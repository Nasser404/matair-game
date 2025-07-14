function virtual_keyboard() constructor  {
    
    
    self.show_pos = {
        x : 7,
        y :  312,
    }
    
    self.hide_pos = {
        x : 7,
        y : 540,
    }
    
    self.x = hide_pos.x;
    self.y = hide_pos.y;
    
    self.xto = self.x;
    self.yto = self.y;
    
    self.hidden = true;
    self.closed = true;

    self.current_string     = "";
    self.draw_string        = "";
    self.clicked            = undefined;
    self.max_string_lenght  = 8;
    self.binded_var         = undefined;
    self.show_bar = false;
    self.bar_timer = function() {show_bar = !show_bar};
    self.show_bar_timer = time_source_create(time_source_game, 45, time_source_units_frames, bar_timer, [], -1);
    time_source_start(self.show_bar_timer)
    
    self.keyboard_del_cooldown = 10;
    validate_script = undefined;
    close_script    = undefined;
    validate = false;
    
    function hide() {
        self.xto = hide_pos.x;
        self.yto = hide_pos.y;
        self.hidden = true;
        
            
        if (self.binded_var!=undefined) variable_global_set(binded_var, current_string);
            
        if (close_script!=undefined) close_script(); 
            
        if (validate) {
            if (validate_script!=undefined) validate_script();
            validate = false;
        }
        validate_script = undefined;
        close_script    = undefined;
        self.binded_var = undefined;
        current_string = "";    
    }
    
    function show() {
        self.xto = show_pos.x;
        self.yto = show_pos.y;
        self.hidden = false;
        self.closed = false;
    }
    function set_close_script(_script) {self.close_script = _script};
    function set_validation_script(_script) {self.validate_script = _script};
    
    function bind_to_var(_var_name) {
        self.binded_var = _var_name;
        self.current_string = variable_global_get(_var_name);
    }
    
    function get_draw_string() {
        return self.draw_string;
    }
    function clean() { time_source_destroy(self.show_bar_timer);}
    function is_closed() {return self.closed}
    
    function write_on(_var, _max_string_lenght) {
        self.show()
        self.bind_to_var(_var);
        self.max_string_lenght = _max_string_lenght;
    }
    
    
    function step() {
  
    
        if (hidden) clicked = undefined;
            
        if (point_distance(self.x, self.y, self.xto, self.yto) < 10) {
            
            self.closed = self.hidden;
        }
        self.x = lerp(x, xto, 0.08);
        self.y = lerp(y, yto, 0.08);
        self.current_string = string_copy(self.current_string, 1, max_string_lenght);
        var _current_string_lenght = string_length(current_string);
        self.draw_string = self.current_string+ (show_bar ? (_current_string_lenght < max_string_lenght ? "_" : "") : ""); 
        
        if (global.current_pop_message != undefined)  clicked = undefined;
        switch (clicked) {
            case 0 : // QUIT
                hide();
                clicked = undefined;
            break;
            
            case 1 : // VALIDATE

                validate = true;
                hide(); 
                clicked = undefined;
                
            break;
            
            case 3 : // DELETE
            current_string = string_copy(current_string, 1, string_length(current_string)-1);
            clicked = undefined;
            break;
            
            case 2 : // SPACE
                current_string+=" ";
            clicked = undefined
            break;
            
        }
        
        
        self.keyboard_del_cooldown--;
        
       #region KEYBOARD SUPPORT
        if (!hidden) and (global.current_pop_message == undefined) {    
            if (keyboard_check_pressed(vk_anykey)) {
                if (is_char_alphanum(keyboard_string))  current_string += string_upper(keyboard_string);
                keyboard_string="";
            }
          
            
            if (keyboard_check(vk_backspace)) {
                if (self.keyboard_del_cooldown<=0) {
                    current_string = string_copy(current_string, 1,string_length(current_string)-1);
                    self.keyboard_del_cooldown = 10;
                }
            }
            if keyboard_check_pressed(vk_enter) {
                 if (!hidden) {
                    clicked ??= 1;
                }
            }
            
            
              if keyboard_check_pressed(vk_space) {
                 if (!hidden) {
                    clicked ??= 2;
                }
            }
            
        }
        #endregion
    }
    function draw() {
        
        

        //draw_text(50, 50, draw_string)
        draw_set_color(c_black);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_font(fnt_vkeyboard);
        
        
        var _xoff = x;
        var _yoff = y;
    
        var _text = "1234567890AZERTYUIOPQSDFGHJKLMWXCVBN"
        
        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);
        
        var _x, _y;
        var _char = 0;
        
        draw_set_alpha(0.7)
        draw_roundrect(_xoff-16, _yoff-16, _xoff+room_width, _yoff+540, false)
        draw_set_alpha(1);
        
        
        
        ///////////////////////////////////////////// DRAW KEYBOARD //////////////////////////////////////////////
        
        draw_set_font(fnt_small_info)
        for (var j = 0; j < 4; j++) {
            var _last_row = (j == 3);
            var _n_of_key = _last_row ? 6 : 10;
            for (var i = 0; i < _n_of_key; i++) {
                
                var _w = sprite_get_width(spr_key);
                var _h = sprite_get_height(spr_key);
                
                var _additional_offset = _last_row ? 2 * (4 + _w) : 0;
                var _x = _xoff + i * (4 + _w) + _additional_offset;
                var _y = _yoff + j * (8 + _h);
                //show_message(_x)
                draw_sprite(spr_key, 0, _x, _y);
                
        
                
                var _key = string_char_at(_text, _char+1);
                
                if (mouse_check_button_pressed(mb_left)) {
                    if (point_in_rectangle(_mx, _my, _x, _y, _x+_w, _y+_h)) {
                        if (!hidden) and (global.current_pop_message == undefined) current_string+=_key;
                    }
                }
                draw_text(_x+_w/2, _y +_h/2, _key)
                
                _char++;
            }
        }
        var _sprites       = [spr_back_key,         spr_validate_key,        spr_space_key_new,                spr_delete_key];
        var _positions     = [{x:5, y : _yoff+89}, {x:217, y : _yoff + 120}, {x:65, y : _yoff + 120}, {x:217, y:_yoff+89}];
        
        for (var i = 0; i <4; i++) {
            
            var _sprite = _sprites[i];
           
            var _w = sprite_get_width(_sprite);
            var _h = sprite_get_height(_sprite);
            var _pos = _positions[i];
            var _x = _pos.x;
            var _y = _pos.y;
             draw_sprite(_sprite, 0, _x, _y);
            if (mouse_check_button_pressed(mb_left)) {
                    if (point_in_rectangle(_mx, _my, _x, _y, _x+_w, _y+_h)) {
                        if (!hidden) {
                            clicked??=i;
                            
                        }
                    }
                }
        }
        
        
        /*
        ////////////////////////////////////////////
        var _sprites = [spr_small_key, spr_small_key, spr_small_key, spr_small_key, spr_small_key, spr_big_key];
        for(var i = 0; i < 6; i++) {
            _x = _xoff;
            _y = _yoff + i*32;
            for (var j = 0; j<6;j++) {
                var _sprite = _sprites[j];
                draw_sprite(_sprite, 0, _x, _y);
                var _w = sprite_get_width(_sprite);
                var _h = sprite_get_height(_sprite);
                
                
                var _key = string_char_at(_text, _char+1);
                
                if (mouse_check_button_pressed(mb_left)) {
                    if (point_in_rectangle(_mx, _my, _x, _y, _x+_w, _y+_h)) {
                        if (!hidden) and (global.current_pop_message == undefined) current_string+=_key;
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
        
        
   
        
        
    }*/
    }
    
    
}