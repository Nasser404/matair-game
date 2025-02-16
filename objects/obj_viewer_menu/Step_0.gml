/// @description Insérez la description ici
if (!global.vk.is_closed()) clicked = undefined;
switch (clicked) {
    case -1 : 
    room_goto(rm_menu);
    clicked = undefined;
    break;
    
    case undefined :
        break;
    default:
        show_message(global.game_list[clicked])
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
