function virtual_keyboard() constructor  {
    self.x = 8;
    self.y = 540;
    
    self.xto = self.x;
    self.yto = self.y;
    
    self.hidden = true;
    self.closed = true;
    function hide() {
        self.xto = 8;
        self.yto = 540;
        self.hidden = true;
        if (close_script!=undefined) close_script(); 
            
        if (self.binded_var!=undefined) variable_global_set(binded_var, current_string);
    }
    
    function show() {
        self.xto = 8;
        self.yto = 256;
        self.hidden = false;
        self.closed = false;
    }
    function set_close_script(_script) {self.close_script = _script};
    function set_validation_script(_script) {self.validate_script = _script};
    
    self.current_string     = "";
    self.draw_string        = "";
    self.clicked            = undefined;
    self.max_string_lenght  = 8;
    self.binded_var         = undefined;
    self.show_bar = false;
    self.bar_timer = function() {show_bar = !show_bar};
    self.show_bar_timer = time_source_create(time_source_game, 45, time_source_units_frames, bar_timer, [], -1);
    time_source_start(self.show_bar_timer)
    
    
    validate_script = undefined;
    close_script    = undefined;
    
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
        self.draw_string = self.current_string+ (show_bar ? "|" : ""); 
        
        switch (clicked) {
            case 0 : // QUIT
                hide();
                clicked = undefined;
            break;
            
            case 1 : // VALIDATE
                hide(); 
                clicked = undefined;
                if (validate_script!=undefined) validate_script();
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
        
        
    }
    function draw() {
        //draw_text(50, 50, draw_string)
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
        
        draw_set_alpha(0.7)
        draw_rectangle(_xoff-32, _yoff-16, _xoff+room_width+32, _yoff+540, false);
        draw_set_alpha(1);
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
                        if (!hidden) current_string+=_key;
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
        
        
    }
    
    
}