/// @description Draw board, info, chat

if (global.game_board != undefined) {
    
    
    //////////////////////// GAME BOARD & INFO ///////////////////
    global.game_board.draw();
    global.game_board.draw_info();
    ////////////////////////////////////////////////////
    
    //////////////////// NUMBER OF VIEWER ////////////////////
    if (global.game_info != undefined) {
        var _viewers_number = global.game_info[$ "number_of_viewer"] ?? 0
        if (_viewers_number>0) {
            
            draw_set_font(fnt_small_info);
            draw_set_color(c_white);
            draw_set_halign(fa_left);
            draw_set_valign(fa_middle);
            draw_sprite(spr_viewer_number, 0, 96, 24);
            draw_text(96, 24, _viewers_number)
        }
    }
    /////////////////////////////////////////////////////////////
    
    
    ///////////////////////// CHAT BUTTON ////////////////////
    var _x = 8;
    var _y = 8;
    
    if (sprite_clicked(_x, _y, spr_chat_button)) and (global.current_pop_message == undefined) {
        if (!global.chat_up)
            {
                global.chat_up = true
                global.new_message_indicator = false;
                chat_cliked_buffer = 2;
            }
    }
    draw_sprite(spr_chat_button, global.new_message_indicator, _x, _y);
    
    ///////////////////////////////////////////////////////////

} else global.chat_up = false;


////////////////////////////////////////////// CHAT (DRAW BOX TO TYPE MSG, DRAW ALL MSG) ///////////////////////////////
if (global.chat_up) {
    
    chat_cliked_buffer = max(0, chat_cliked_buffer-1);
    global.new_message_indicator = false;
     
    ////////////////////// DARK BACKGROUND //////////////////////////
    draw_set_color(c_black);
    draw_set_alpha(0.7);
    draw_rectangle(0, 0, 270, 480, false);
    draw_set_alpha(1);
    
    ///////////////////////////////////////////////
    
    
    //////////////////////////////////////////////////////// CHAT HISTORY /////////////////////////////////////////////////////////////////
    draw_set_font(fnt_small_info);
    draw_set_color(c_black);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    var _msg = global.game_chat ?? [];
    
    var _msg_x = 10;
    var _msg_y = 42;
    var _sep = _msg_y;
   
    var _draw_msg = array_reverse(_msg)
    for (var i = 0, n = array_length(_draw_msg); i  < min(17, n); i++) {
       
        var _name = $"{_draw_msg[i][0]} : "
        var _message = _draw_msg[i][1]
        var _client_type = _draw_msg[i][2]
        
        var _string_w = string_width(_name)
        
        
        draw_set_color(_client_type == CLIENT_TYPE.PLAYER ? c_yellow: c_aqua)
        
        
        draw_text(_msg_x, _sep, _name);
        draw_set_color(c_white)
        
        var _message_line_break = string_wordwrap_width(_message, 200, "\n", true);
        var _string_h = string_height(_message_line_break)
        draw_text(_msg_x + _string_w + 4, _sep, _message_line_break);
        _sep+=_string_h+4;
    }
    
    

    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////

    

    ///////////////////////////// CHAT BOX BOX WHERE YOU WRITE MESSAGE)  /////////////////////////////////////////////////////////////
    draw_set_color(c_white)
    var _x1 = 10;
    var _y1 = 10;
    var _x2 = 260;
    var _y2 = 32;
    
    var _w = _x2-_x1;
    var _h = _y2-_y1;
    
    ///////////////////////////////////////////////////////////////////////////////////////
    var _text = (!global.vk.hidden) ? global.vk.get_draw_string() :global.chat_message; // GET CHAT BOX TEXT IN ADVANCE (WE NEED TO CALCULATE HEIGHT)
    var _text_line_break = string_wordwrap_width(_text, _w-15, "\n", true);
    //////////////////////////////////////////////////////////////////////////////////////////////
    
    var _s_h = max(0, string_height(_text_line_break) - 18);
    
    draw_roundrect_ext(_x1, _y1, _x2, _y2 + _s_h, 10, 10, false); // DRAW BOX
    
    if (zone_clicked(_x1, _y1, _w, _h+_s_h) and chat_cliked_buffer <=0) and (global.current_pop_message == undefined) {
        
        global.vk.set_validation_script(
        function() {
            if(global.chat_message!=""){
                var _game_id = global.game_info[$ "game_id"];
                var _name =( global.client_type == CLIENT_TYPE.VIEWER) ? $"viewer({temp_id})" : global.name;
                
                var _censored_string =  CENSOR_TEXT ? string_scunthorpe(global.chat_message) : global.chat_message;
                player_send_packet({"type" : MESSAGE_TYPE.GAME_CHAT, "message" : [_name, _censored_string, global.client_type], "game_id" : _game_id})
                global.chat_message = "";
                
            } 
        });
        
        var _max_char = 70;
        global.vk.write_on("chat_message", _max_char); //
    }
    //////////////////////////////////////////////////////////////////////////////////////////
    
    ///////////////////////////////////// DRAW TEXT OF CHAT BOX (CURRENT CHAT MESSAGE) ////////////////////////////////////////////////*
    
    
    draw_set_font(fnt_small_info);
    draw_set_color(c_black);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    if (global.chat_message == "") and (global.vk.hidden) { // IF NO MESSAGE ON CHAT BOX AND VIRTUAL KEYBOARD NOT OPEN display dummy text INSTEAD
        draw_set_color(c_gray);
        draw_set_alpha(0.8);
        _text_line_break = "TAP HERE TO WRITE"
    }
    
    var _tx = _x1 + 6;
    var _ty = _y1 + 3;
   
    draw_text(_tx, _ty,_text_line_break)

    draw_set_alpha(1)    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
  

}