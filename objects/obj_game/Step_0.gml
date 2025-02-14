/// @description Insérez la description ici
if (os_browser != browser_not_a_browser) {
    if (browser_height != window_get_height()) || (browser_width != window_get_width()) {
        window_set_size(browser_width, browser_height);
    
    }
}

if keyboard_check_pressed(ord("R")) game_restart();
    
global.vk.step();
