/// @description Insérez la description ici

if (!global.vk.is_closed()) clicked = undefined;
switch (clicked) {
    case 0 : 
        
    //room_goto(rm_game);
    menu_page = 1;
    clicked = undefined;
    break;
        
    case 1 : 
    room_goto(rm_spectate);    
    break;
        
    case 2 : 
        url_open("https://en.wikipedia.org/wiki/Cylinder_chess"); 
        clicked = undefined;
    break;
        
    case 3 : 
        url_open("https://hackaday.io/projects/hacker/1361079"); 
        clicked = undefined;    
    break;
    
    
    case 4 : 
        
    current_writing = 0;
    global.vk.write_on("name", 12)
    clicked = undefined
        
    break;
        
    
    case 5 : 
        
    current_writing = 1; 
    global.vk.write_on("orb_code", 4)
    clicked = undefined
    
    
    break;
    case 6 :
        menu_page = 0;
        clicked = undefined;
    break;
    
    
    case 7 :
        
    room_goto(rm_game);
    break;
    default : clicked = undefined; break;
}


