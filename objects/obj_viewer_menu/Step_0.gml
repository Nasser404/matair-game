/// @description handle clicks
refresh_cooldown = max(0, refresh_cooldown-1);

if ((!global.vk.is_closed()) or (global.current_pop_message != undefined)) clicked = undefined;
switch (clicked) {
    
    case -2 : // REFRESH BUTTON 
        player_send_packet({"type" : MESSAGE_TYPE.GAME_LIST})// NETWORKING //
        refresh_cooldown = 5 * 60; 
        clicked = undefined;
    break;
    
    
    case -1 : // BACK BUTTON
        if (global.chat_up) global.chat_up = false;
        else room_goto(rm_menu);
        clicked = undefined;
    break;
    
    case undefined :
        break;
    default: // CLICKED ON A GAME
        var _selected_game = global.game_list[clicked];
        var _game_id       = _selected_game[$"game_id"];
        player_send_packet({"type" : MESSAGE_TYPE.VIEWER_CONNECT, "game_id" : _game_id}); // NETWORKING //
        clicked = undefined;
    break;
}


if (keyboard_check_pressed(vk_down)) list_index+=max_list_index;
if (keyboard_check_pressed(vk_up)) list_index-=max_list_index;
    
if (global.game_list != undefined) {
    var _n = array_length(global.game_list)-1;
    var _total_pages = (_n) div max_list_index
    
    if (list_index > _n) list_index = _total_pages*4;
    if (list_index < 0) list_index = 0;
}
