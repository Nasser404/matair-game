/// @description Insérez la description ici

switch (clicked) {
    case 0 : 
        
    room_goto(rm_game);
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
    
}

