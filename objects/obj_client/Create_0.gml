client = new player_client();

var _sucess = client.create();

if (_sucess < 0) {
    instance_destroy();
    show_debug_message("Client could not connect to server")
}