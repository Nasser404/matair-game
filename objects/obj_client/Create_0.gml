global.client_type = (room == rm_player) ? CLIENT_TYPE.PLAYER : CLIENT_TYPE.VIEWER;
    

global.client = new player_client();
global.client.create();

