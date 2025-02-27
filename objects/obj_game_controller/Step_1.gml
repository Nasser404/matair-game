/// @description Resize browser canvas
if (os_browser != browser_not_a_browser) {
    if (browser_height != window_get_height()) || (browser_width != window_get_width()) {
        window_set_size(browser_width, browser_height);
    
    }
}