/// @description Resize browser canvas
if (os_browser != browser_not_a_browser) {
    if (browser_height != window_get_height()) || (browser_width != window_get_width()) {
        window_set_size(browser_width, browser_height);
    
    }
}

// dequeue server message
if (global.current_pop_message == undefined) { 
    pop_message_buffer = max(0, pop_message_buffer-1);
    if ((array_length(global.pop_message_queue)>0) and (pop_message_buffer<=0)) {
        global.current_pop_message = array_shift(global.pop_message_queue);
        pop_message_buffer = 5;
    }
}