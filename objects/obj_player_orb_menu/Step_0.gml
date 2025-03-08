/// @description Handle clicks
refresh_cooldown = max(0, refresh_cooldown-1);

if ((!global.vk.is_closed()) or (global.current_pop_message != undefined)) clicked = undefined;
    
var _my_orb_id;
switch (clicked) {
    
    case -1 : // REFRESH BUTTON
        player_send_packet({"type" : MESSAGE_TYPE.ORB_LIST});// NETWORKING //
        clicked = undefined;
        refresh_cooldown = 3 *60;
    break;
    
    case noone : // BACK BUTTON
        if (global.chat_up) global.chat_up = false;
        else {
             if (menu_page == 0) or (global.client == undefined) room_goto(rm_menu); 
             else menu_page = 0;
        }
        clicked = undefined;
    break;
    
 
    
    case 0 : // CONTINUE BUTTON
        _my_orb_id = global.orb_data[$ "id"];
        player_send_packet({"type" : MESSAGE_TYPE.ORB_CONTINUE_GAME, "id" : _my_orb_id});// NETWORKING //
        clicked = undefined;
    break;
    
    case 1 : // NEW GAME BUTTON 
        menu_page = 1;
        player_send_packet({"type" : MESSAGE_TYPE.ORB_LIST});// NETWORKING //
        clicked = undefined;
    break;
    
    case 2 : // END GAME BUTTON
        _my_orb_id = global.orb_data[$ "id"];
        player_send_packet({"type" : MESSAGE_TYPE.ORB_END_GAME, "id" : _my_orb_id});// NETWORKING //
        room_goto(rm_menu);
        clicked = undefined;
    break;
    
    
    
    
    default: // SELECTED ORB IN NEW GAME
        var _clicked = clicked-3;
        clicked = undefined;
        _my_orb_id = global.orb_data[$ "id"];
        var _opponent_orb_id = global.orb_list[_clicked][$ "id"];
    
        player_send_packet({"type" : MESSAGE_TYPE.ORB_NEW_GAME, "id1" : _my_orb_id, "id2" : _opponent_orb_id});// NETWORKING //
    break;
    
    case undefined : break;
}
if (global.orb_list != undefined) {
    var _n = array_length(global.orb_list )-1;
    var _total_pages = (_n) div max_list_index
    
    if (list_index > _n) list_index = _total_pages*4;
    if (list_index < 0) list_index = 0;
}
