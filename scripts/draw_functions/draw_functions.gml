function draw_orb_info(_x, _y, _orb_info = {}) {
    
    /*
        var _orb_info = {
        "id" : "ORB IVRY",
        "code" : "YVLC",
        "in_game" : true,
        "occupied" : true,    
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
    draw_set_color(_orb_info[$ "occupied"] ? c_red: c_lime);
    var _occupied_x = _x + 216;
    var _occupied_y = _y + 50;
    draw_text(_occupied_x, _occupied_y, _orb_info[$ "occupied"] ? "OCCUPIED" : "IDLE");
    
    draw_set_color(_orb_info[$ "in_game"] ? c_orange : c_white);
    var _in_game_x  = _x + 216;
    var _in_game_y  = _y + 64;
    draw_text(_in_game_x, _in_game_y, _orb_info[$ "in_game"] ? "IN GAME" : "NOT IN GAME");
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

function draw_game_info(_x, _y, _game_info = {}) {
    /*var _game_info = {
        "status" : 0,
        "player1"  : "",
        "player2 "",
        
    }*/
    draw_set_color(c_white);
    draw_sprite(spr_game_info, 0, _x, _y);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    draw_set_color(c_yellow)
    draw_set_font(fnt_small_info);
    var _player_x = _x + 79;
    var _player_y = _y + 5;
    draw_text(_player_x, _player_y, _game_info[$ "player1"] ?? "");
    
    
    
        
    
    var _text, _col;
    switch (_game_info[$ "status"])  {
        default: _text = "NO GAME";  _col = c_white; break;
        case 0 : _text = "ON GOING"; _col = c_orange;break;
        case 1 : _text = "GAME END"; _col = c_red;break;
        
    }
    
    draw_set_color(_col);
    var _status_x = _x + 8;
    var _status_y = _y +50;
    draw_text(_status_x,_status_y, _text);
    

    
    draw_set_halign(fa_right);
    
    draw_set_color(c_yellow)
    var _opponent_x = _x + 170;
    var _opponent_y = _y + 50;
    draw_text(_opponent_x, _opponent_y, _game_info[$ "player2"] ?? "");

    
    
    
}