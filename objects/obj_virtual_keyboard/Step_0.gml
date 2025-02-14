/// @description Insérez la description ici
x = lerp(x, xto, 0.08);
y = lerp(y, yto, 0.08);
my_string = string_copy(my_string, 1, max_string_lenght);
draw_string = my_string + (show_bar ? "|" : ""); 

switch (clicked) {
    case 0 : 
        my_string = "";
        hide();
        clicked = undefined;
    break;
    
    case 1 : 
        
    hide(); 
    clicked = undefined;
    break;
    
    case 3 :
        
    my_string = string_copy(my_string, 1, string_length(my_string)-1);
    clicked = undefined;
    break;
    case 2 :
        my_string+=" ";
    clicked = undefined
    break;
    
}