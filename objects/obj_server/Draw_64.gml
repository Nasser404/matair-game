/// @description Insérez la description ici
draw_text(5, 5, $"Orbs : {server.orbs_sockets}")
draw_text(5, 25, $"Players : {server.players_sockets}")
draw_text(5, 45, $"Viewer : {server.viewers_sockets}")
draw_text(5, 65, $"Games : {struct_get_names(server.games)}")