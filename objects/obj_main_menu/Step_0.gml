/// @description Handle clicks


if (!global.vk.is_closed() and ((clicked != 4) or (clicked != 5)) or (global.current_pop_message!=undefined)) clicked = undefined;
switch (clicked) {
    case 0 : // PLAY BUTTON
    menu_page = 1;
    clicked = undefined;
    layer_set_visible("info", true);
    break;
        
    case 1 : // SPECTATE BUTTON
    room_goto(rm_spectate);    
    break;
        
    case 2 :  // RULE BUTTON
        url_open("https://en.wikipedia.org/wiki/Cylinder_chess"); 
        clicked = undefined;
    break;
        
    case 3 : // CREDIT BUTTON
        url_open("https://hackaday.io/project/202508-matir"); 
        clicked = undefined;    
    break;
    
    
    case 4 : // NAME BOX
        
    current_writing = 0;
    global.vk.write_on("name", 10)
    clicked = undefined
    break;
        
    
    case 5 : // ORB CODE BOX
        
    current_writing = 1; 
    global.vk.write_on("orb_code", ORB_CODE_LENGHT)
    clicked = undefined
    break;
    
    case 6 : /// BACK BUTTON
        menu_page = 0;
        clicked = undefined;
    layer_set_visible("info", false);
    break;
    
    
    case 7 : // PLAY BUTTON (AFTER NAME & ORB CODE)
        
    if (LOCAL_TEST) room_goto(rm_game); // IF LOCAL GAME, SKIP DIRECTLY TO TEST GAME ROOM
    else {
        if (can_play) room_goto(rm_player); 
        clicked = undefined;
    }
    break;
    
    default : clicked = undefined; break;
}


can_play = (string_length(global.orb_code)>=ORB_CODE_LENGHT) && (string_length(global.name)>=1); // CHECK IF NAME AND ORB CODE VALIDATE CONDITION