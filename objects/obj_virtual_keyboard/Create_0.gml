/// @description Insérez la description ici
x = 8;
y = 540;

xto = x;
yto = y;


hidden = true;
function hide() {
    xto = 8;
    yto = 540;
    hidden = true;
}

function show() {
    xto = 8;
    yto = 256;
    hidden = false;
}

my_string = "";
max_string_lenght = 8;
function set_max_string_lenght(_lenght) {
    max_string_lenght = _lenght;
}
clicked = undefined;