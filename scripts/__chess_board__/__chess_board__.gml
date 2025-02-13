#macro TILE 32

function chess_board(_x, _y, _sprite_index, _view = piece_color.white, _verbose = true, _server_board = false) constructor {
    
    self.grid = array_create_ext(8, function() {return array_create(8, noone);})
    
    self.x = _x;
    self.y = _y;
    self.sprite_index = _sprite_index;
    self.turn = piece_color.white;
    self.view = _view;
    self.selected_piece = noone;
    
    self.captured_pieces = {"white" : {"Pawn":0, "Rook":0, "Knight": 0, "Bishop" : 0, "Queen":0, "King":0}, 
                            "black" : {"Pawn":0, "Rook":0, "Knight": 0, "Bishop" : 0, "Queen":0, "King":0}}
    
    self.players_names = {"white" : "Player1",
                          "black" : "Player2"}
    
    self.playing_orb   =    {"white" : "Paris",
                            "black" : "Ivry"}
    self.checked = noone;
    self.verbose = _verbose;
    
    self.is_false_board = false;
    self.is_server_board = _server_board;
    self.game_ended = false;
    self.winner = noone;
    self.possible_moves = [[], []];
    self.square_reached = [[], []];
    
    
    function board_view(_value) {
        return (self.view == piece_color.white) ? _value : 7 - _value;
    }
    function local_board_view(_col, _value) {
        return (_col == piece_color.white) ? _value : 7 - _value;
        
    }
    function get_grid() {
        return self.grid;
    }
    function init_board() {
        self.grid = array_create_ext(8, function() {return array_create(8, noone);})
        self.selected_piece = noone;
        self.turn = piece_color.white;
        self.checked = noone;
        self.game_ended = false;
        self.winner = noone;
        self.possible_moves = [[], []];
        self.square_reached = [[], []];
        
        self.captured_pieces = {"white" : {"Pawn":0, "Rook":0, "Knight": 0, "Bishop" : 0, "Queen":0, "King":0}, 
                                "black" : {"Pawn":0, "Rook":0, "Knight": 0, "Bishop" : 0, "Queen":0, "King":0}}
        //////////// PLACE PIECES /////////////////////
        //Pawn
        for (var i = 0; i < 8 ;i++) {
            add_piece(piece_type.pawn, piece_color.black, [i, 1]);
            add_piece(piece_type.pawn, piece_color.white, [i, 6]);
        }
        
        //Rook
        add_piece(piece_type.rook, piece_color.black, [0, 0]);
        add_piece(piece_type.rook, piece_color.black, [7, 0]);
        add_piece(piece_type.rook, piece_color.white, [0, 7]);
        add_piece(piece_type.rook, piece_color.white, [7, 7]);
        
        // Knight
        add_piece(piece_type.knight, piece_color.black, [1, 0]);
        add_piece(piece_type.knight, piece_color.black, [6, 0]);
        add_piece(piece_type.knight, piece_color.white, [1, 7]);
        add_piece(piece_type.knight, piece_color.white, [6, 7]);
        
        // Bishop
        add_piece(piece_type.bishop, piece_color.black, [2, 0]);
        add_piece(piece_type.bishop, piece_color.black, [5, 0]);
        add_piece(piece_type.bishop, piece_color.white, [2, 7]);
        add_piece(piece_type.bishop, piece_color.white, [5, 7]);

        // Queen
        add_piece(piece_type.queen, piece_color.black, [3, 0]);
        add_piece(piece_type.queen, piece_color.white, [3, 7]);
        
        //King
        add_piece(piece_type.king, piece_color.black, [4, 0]);
        add_piece(piece_type.king, piece_color.white, [4, 7]);
        
                
        calculate_all_moves();
    }
    /**
    * Function Add chess piece to board
    * @param {enum.piece_type} type type of piece
    * @param {enum.piece_color} color color of piece
    * @param {array} coordinate coordinate of piece 
    */
    function add_piece(_type, _color, _pos, _board = self) {
        var _x = _pos[0];
        var _y = _pos[1];
        switch (_type) {
            case piece_type.pawn    : self.grid[_x, _y] = new pawn([_x, _y], _color, self);   break;
            case piece_type.rook    : self.grid[_x, _y] = new rook([_x, _y], _color, self);   break;
            case piece_type.knight  : self.grid[_x, _y] = new knight([_x, _y], _color, self); break;
            case piece_type.bishop  : self.grid[_x, _y] = new bishop([_x, _y], _color, self); break;
            case piece_type.queen   : self.grid[_x, _y] = new queen([_x, _y], _color, self);  break;
            case piece_type.king    : self.grid[_x, _y] = new king([_x, _y], _color, self);   break;
        }
        
    }
    
    function calculate_all_moves() {
        self.square_reached[piece_color.white] = check_square_reached(piece_color.white);
        self.square_reached[piece_color.black] = check_square_reached(piece_color.black);
    }
    
    function calculate_legal_moves(_col) {
        self.possible_moves[_col] = check_possible_moves(_col);

    }
    
    function check_possible_moves(_col) {
        var _possibles_moves = []
        for (var i = 0; i < 8; i++) {
            for (var j = 0; j < 8; j++) {
                
                var _piece = self.grid[i, j];
                if (_piece == noone) continue; 
                    
                var _moves =  _piece.check_moves();
                
                if (!self.is_false_board) _moves = remove_illegal_moves(_piece, _moves, _col)
                if (_piece.get_color() == _col) _possibles_moves = array_concat(_possibles_moves,_moves)
            }
        }
        return _possibles_moves
    }
    
    function check_square_reached(_col) {
        var _possibles_moves = []
        for (var i = 0; i < 8; i++) {
            for (var j = 0; j < 8; j++) {
                
                var _piece = self.grid[i, j];
                if (_piece == noone) continue; 
                    
                if (_piece.get_color() != _col) continue;
                    
                var _moves =  _piece.check_moves();
                _possibles_moves = array_concat(_possibles_moves,_moves)
            }
        }
        return _possibles_moves
    }
    
    
    function get_number_of_possible_moves(_col) {
        return array_length(self.possible_moves[_col]);
    }

    function draw() { 
        if (self.is_server_board) return;
            
        
        // DRAW BOARD 
        draw_sprite(self.sprite_index, 4, self.x, self.y);
        // DRAW SELECTED PIECE
        if (selected_piece != noone) {
            // HIGHLIGHT SELECTED PIECE 
            draw_set_alpha(0.8)
            draw_set_color(#b9ca43);
            var _selected_piece_coord = selected_piece.get_pos()
            var _drawx = self.x + board_view(_selected_piece_coord[0]) * TILE;
            var _drawy = self.y + board_view(_selected_piece_coord[1]) * TILE;
            draw_rectangle( _drawx , _drawy, _drawx +TILE-1, _drawy+TILE-1, false);
            draw_set_alpha(1);
            draw_set_color(c_black);
            
            // DRAW SELECTED PIECE POSSIBLE MOVES
            var _moves = selected_piece.get_moves()
            for (var i = 0, n = array_length(_moves); i<n;i++) {
                var _move = _moves[i];
                //show_message(_move)
                var _x = self.x + TILE * board_view(_move[0]);
                var _y = self.y + TILE * board_view(_move[1]);
                draw_set_color(c_black);
                draw_set_alpha(0.4);
                draw_rectangle(_x, _y, _x+TILE-1, _y+TILE-1, false);
                draw_set_color(c_black);
                draw_set_alpha(1);
                // draw_circle(_x+TILE/2, _y + TILE/2, 3, false);
            }
        }
        // DRAW PIECES
        for (var i = 0; i < 8; i++) { 
            for (var j = 0; j < 8; j++) { 
                
                var _i = board_view(i);
                var _j = board_view(j);
                
                var _piece = self.grid[_i, _j];
                //show_message($"real : {i},{j}\ncurrent:{_i}, {_j}\npiece at coord : {_piece}")
                var _piece_x = self.x + TILE * i
                var _piece_y = self.y + TILE * j
                
                //draw_text(_piece_x+4, _piece_y, get_chess_pos([i, j]))
                
                
                if (_piece == noone) continue;
                    

               
                
                // HIGHLIGHT CHECKED KING
                draw_set_color(c_red);
                draw_set_alpha(0.8);
                if (_piece.get_color() == self.checked) and (_piece.get_type() == piece_type.king) draw_rectangle(_piece_x, _piece_y, _piece_x+TILE-1, _piece_y+TILE-1, false)
                draw_set_color(c_black);
                draw_set_alpha(1);
                
                 draw_sprite(_piece.sprite, _piece.image_index, _piece_x, _piece_y)
           }
        }
            
        
        /// DRAW CAPTURED PIECE
            
 
        
    }
    
    ///////////////////////////////////////////////////////////// BOARD CLICKED ///////////////////////////////////////////////////////
    function clicked(_x, _y) {
        if (self.is_server_board) return;
            
        var _relative_x = _x - self.x;
        var _relative_y = _y - self.y;
        
        var _out_of_bound = ((_relative_x < 0) or (_relative_x > 8 * TILE) or (_relative_y < 0) or (_relative_y> 8 * TILE))
        
        if (_out_of_bound) self.selected_piece = noone;
        else {
            var _clicked_x = board_view(_relative_x div TILE);
            var _clicked_y = board_view(_relative_y div TILE);
            
            if (self.selected_piece != noone)  {
                var _moves = selected_piece.get_moves();
                for (var i = 0, n = array_length(_moves); i<n;i++) { 
                    var _move = _moves[i];
                    if (array_equals(_move, [_clicked_x, _clicked_y])) {
                        ///////////////////////////////////////////////////////////////
                        if (selected_piece != noone) ask_move_piece(selected_piece.get_pos(), _move); 
                            
                        /////////////////////////////////////////////////////
                    }
                    
                }
                
            }
            var _piece = self.grid[_clicked_x, _clicked_y];
            if (_piece == noone) return
                
            
            if(_piece.get_color() == turn) self.selected_piece = self.grid[_clicked_x, _clicked_y];
                
            if (self.selected_piece != noone) {
                    self.selected_piece.check_moves();
                    var _selected_move = self.selected_piece.get_moves();
                    _selected_move = remove_illegal_moves(self.selected_piece, _selected_move, self.selected_piece.get_color())
                
                    self.selected_piece.set_moves(_selected_move);
                    //self.selected_piece.filter_moves()
            }
        }
    }
    ////////////////////////////////////////////////////////////////////////////////////////////
    function chance_view() {
        self.view = !self.view;
        
    }
    
    
    //////// NETWORKING STUFF !!!!!! ///////
    function ask_move_piece(_from, _to) {
        move_piece(_from, _to);
    }
    
    function update_pieces_last_pos(_col) {
        for (var i = 0; i < 8; i++) {
            for (var j = 0; j < 8; j++) {
                var _piece = self.grid[i, j];
                if (_piece == noone) continue;
                    
                if (_piece.get_color()!=_col) continue;
                    
                _piece.update_last_pos();
            }
        }
        
    }
    
    ///////////////////////////////// MOVE PIECES ///////////////////////////////////////////
    function move_piece(_from, _to, _real_move = true) {
        
        var _old_x = _from[0];
        var _old_y = _from[1];
         
        var _new_x = _to[0];
        var _new_y = _to[1];   
        
        if (!cell_empty(_to)) {
            piece_captured(_to);
        } else play_sfx(sfx_moved, 0);
          
        
        
        var _piece =  self.grid[_old_x, _old_y];
        remove_piece(_from);
        
        // EN PASSANT
        if (_piece.get_type() == piece_type.pawn) {
            //if verbose show_message($"{_piece.en_passant} - {_to}")
            if (array_equals(_to, _piece.en_passant)) {
                
                var _pawn_affected = [_to[0], _to[1] - _piece.forward]
                piece_captured(_pawn_affected);
            }
        }    
        // CASTLE
        if (_piece.get_type() == piece_type.king) {
            
            //if verbose show_message($"{_piece.en_passant} - {_to}")
            var _rook_affected, _new_rook_pos;
            var _k_pos = _piece.get_pos();
            
            if (array_equals(_to, _piece.right_castle)) {
                _rook_affected = [_k_pos[0] + 3, _k_pos[1]];
                _new_rook_pos  = [_k_pos[0] + 1, _k_pos[1]];
                
                move_piece(_rook_affected, _new_rook_pos, false);
                play_sfx(sfx_castle, 1);
            } 
            if (array_equals(_to, _piece.left_castle)) {
                        _rook_affected = [_k_pos[0] - 4, _k_pos[1]];
                        _new_rook_pos  = [_k_pos[0] - 1, _k_pos[1]];
                        
                move_piece(_rook_affected, _new_rook_pos, false);
                play_sfx(sfx_castle, 1);
            } 
        }   
          
        if ((_new_y == 0) or (_new_y == 7)) and (_piece.get_type() == piece_type.pawn) {
            
            add_piece(piece_type.queen, _piece.get_color(), _to)// PROMOTION
            play_sfx(sfx_promote, 1);
        }
        else {
            
            self.grid[_new_x , _new_y] = _piece;    
            self.grid[_new_x , _new_y].set_pos(_to);        
            self.grid[_new_x , _new_y].set_moved();        
        } 
        
        selected_piece = noone;
        if (self.verbose) show_debug_message($"{_piece.get_color() == piece_color.white ? "White" : "Black"} {_piece.get_name()} moves {get_chess_pos(_to)}!")
        if (_real_move) next_turn();
    }
    ///////////////////////////////////////////////////////////////////////////////////////

    function remove_piece(_pos) { 
        delete self.grid[_pos[0], _pos[1]];
        self.grid[_pos[0], _pos[1]] = noone;
    }
    
    
    function piece_captured(_pos) {
        play_sfx(sfx_captured, 1);
        var _piece = self.grid[_pos[0], _pos[1]];
        
        if (!self.is_false_board) {
            if (_piece.get_color() == piece_color.white) self.captured_pieces[$ "white"][$ _piece.get_name()]+=1
            else self.captured_pieces[$ "black"][$ _piece.get_name()]+=1
            }
        if (self.verbose) show_debug_message($"{_piece.get_color() == piece_color.white ? "White" : "Black"} {_piece.get_name()} Captured on {get_chess_pos(_pos)}!")
        remove_piece(_pos)
    }
    
    function get_chess_pos(_pos) {
        var _xname = ["a", "b", "c", "d", "e", "f", "g", "h"];
        
        return $"{_xname[board_view(_pos[0])]}{8 - board_view(_pos[1])}"
        
    }
    
    function is_checked(_col) {
        var _possible_enemy_move = self.square_reached[!_col];
    
        // FIND KING COORDINATES
        var _king_coord = [];
        for (var i = 0; i < 8; i++) {
            for (var j = 0; j < 8; j++) {
                var _piece = self.grid[i, j];
                
                if (_piece==noone) continue;
                if (_piece.get_color() != _col) continue;
                if (_piece.get_type() == piece_type.king) _king_coord = [i, j];
            }
        }
        
        
        // CHECK IF ONE OF POSSIBLE ENEMY MOVE HIT COORDINATES
        for (var i = 0, n = array_length(_possible_enemy_move); i < n; i++) {
            var _enemy_move = _possible_enemy_move[i]
            if (array_equals(_king_coord, _enemy_move)) return true
        }
        return false
        
    }
    
    function is_checked_after_move(_from, _to, _col) { // HEAVY !!
        // CREATE A FALSE BOARD MAKE THE POSSIBLE MOVE ON FAKE BOARD AND RETURN IF KING IS STILL CHECKED ON FALSE BOARD
        var _real_board_data = get_board_data();
        var _false_board = new chess_board(self.x, self.y, self.sprite_index, self.view, false);
        _false_board.load_board_data(_real_board_data);
        _false_board.is_false_board = true;
        
        _false_board.move_piece(_from, _to);
        return _false_board.is_checked(_col);
        
    }
    
    function get_board_data() {
        var _data = {"turn" : self.turn, "captured_pieces" : self.captured_pieces}
        var _board_data = array_create_ext(8, function() {return array_create(8, noone);})
        for (var i = 0; i < 8; i++) {
            for (var j = 0; j < 8; j++) {
                var _piece = self.grid[i, j];
                if (_piece == noone) continue;
                _board_data[i, j] = _piece.get_id();
                
            }
        }
        _data[$ "board"] = _board_data
        
        return _data;
        
        
    }
    
    function load_board_data(_data) {
        self.grid = array_create_ext(8, function() {return array_create(8, noone);})
        self.captured_pieces = _data[$ "captured_pieces"];
        self.turn            = _data[$ "turn"]
        var _board_data      = _data[$ "board"]
        for (var i = 0; i < 8; i++) {
            for (var j = 0; j < 8; j++) {
                var _piece_data = _board_data[i, j];
                if (_piece_data == noone) continue;
      
                var _color = _piece_data[0];
                var _type  = _piece_data[1];
                self.add_piece(real(_type), real(_color), [i, j])
            }
        }
    }
    
    function get_board_string(){
        var _board_string = ""
        for (var i = 0; i < 8; i++) {
            for (var j = 0; j < 8; j++) {
                var _piece = self.grid[i, j];
                if (_piece == noone) _board_string+="*"
                else _board_string+=_piece.get_s();    
            }
        }
        return _board_string;
    }
    function check_move_valid(_from, _to) {
        var _piece = self.grid[_from[0], _from[1]]
        var _moves = _piece.get_moves();
        _moves = remove_illegal_moves(_piece, _moves, _piece.get_color());
        
        for (var i = 0, n = array_length(_moves); i < n; i++) {
            var _possible_move =  _moves[i];
            if (array_equals(_possible_move, _to)) return true;
        }
        return false
    }
    function remove_illegal_moves(_piece, _possible_moves, _col) {
        var _clean_moves = []
        var _piece_color = _piece.get_color()
        var _piece_pos   = _piece.get_pos()
        if (_piece_color == _col) {
            
            for (var i = 0, n = array_length(_possible_moves); i < n; i++) {
                var _possible_move =  _possible_moves[i];
                if (is_checked_after_move(_piece_pos, _possible_move,_piece_color)) continue;
                    
                array_push(_clean_moves, _possible_move)
            }
            
        } else _clean_moves = _possible_moves;
        
       
        return _clean_moves
        
    }
    
    function next_turn() {
       
   
        self.turn = !self.turn;
        self.selected_piece = noone;
        
        
        update_pieces_last_pos(turn);
        calculate_all_moves();
       if (!self.is_false_board) calculate_legal_moves(self.turn)
        
        if (is_checked(turn)) {
        
            play_sfx(sfx_checked, 2);
            checked = turn;
            
            // VERIFY CHECKMATE
            if (!self.is_false_board) {
                
                var _number_of_moves = get_number_of_possible_moves(turn);
                if (_number_of_moves <= 0) {
                    self.game_ended = true;
                    self.winner = !turn;
                    play_sfx(sfx_checkmate, 3)
                    //show_message($"{(!turn == piece_color.white) ? "White" : "Black"} Wins !")
                }
            }
           
            
        
        }
        else  {
            if (!self.is_false_board) {
                var _number_of_moves = get_number_of_possible_moves(turn);
                if (_number_of_moves <= 0) { 
                    self.game_ended = true;
                    self.winner = noone;
                 }
             }
        
            checked = noone;
            
        }
    }
    function cell_safe(_pos, _col) {
 
        var _possible_enemy_move = self.square_reached[!_col];
        
        // CHECK IF ONE OF POSSIBLE ENEMY MOVE HIT COORDINATES
        for (var i = 0, n = array_length(_possible_enemy_move); i < n; i++) {
            var _enemy_move = _possible_enemy_move[i]
            if (array_equals(_pos, _enemy_move)) return false
        }
        return true
            
    }
    /**
    * Check if cell in the given grid at the given pos is empty (!=noone)
    * @param {array<array>} grid Grid to check in
    * @param {array<Real>} pos Position to check in the grid
    * @returns {bool} return whether the the cell is empty
    */
    function cell_empty(_pos) {
            if (_pos[1] > 7) or (_pos[1] < 0) return false;
            var w_pos = wrap_pos(_pos)
            return self.grid[w_pos[0], w_pos[1]] == noone;
        }
        
    
    
    function draw_info() {
        
        
        draw_set_color(c_white);
        draw_set_valign(fa_middle)
        draw_set_halign(fa_left);
        var _xoffset = 0;
        var _yoffset = 32;
        var _view_offset = [-_yoffset, 8 * TILE + _yoffset];
        
        var _pieces = ["Pawn", "Knight", "Bishop", "Rook", "Queen", "King"];
        var _name_offset = 38;
        var _piece_captured_offset = 60;
        var _sep = 8;
        
        
        // BLACK
        var _bx = self.x + _xoffset;
        var _by = self.y + _view_offset[self.view];
        
        draw_sprite(spr_black_profile, 0, _bx, _by); // PROFILE
        draw_text(_bx+ _name_offset,  _by, $"{self.players_names[$ "black"]} - {self.playing_orb[$ "black"]}"); // NAME
        
        
        var _n = 0;
        
        for (var i = 0; i < 6; i++) {
            var _name = _pieces[i];
            var _n_captured = self.captured_pieces[$ "white"][$ _name];
            var _cap_x = _bx+_name_offset-6;
            var _cap_y = _by+5;
            repeat(_n_captured) {
                draw_sprite_ext(spr_white_pieces, i, _cap_x + _n * _sep, _cap_y, 0.5, 0.5, 0, c_white, 1);
                _n++;
            }
            
        }
        
        
        // White
        var _wx = self.x + _xoffset;
        var _wy = self.y + _view_offset[!self.view];
        draw_sprite(spr_white_profile, 0, _wx, _wy); // PROFILE
        
        draw_text(_wx+_name_offset,  _wy,  $"{self.players_names[$ "white"]} - {self.playing_orb[$ "white"]}") // NAME
        
        _n = 0;
        for (var i = 0; i < 6; i++) {
            var _name = _pieces[i];
            var _n_captured = self.captured_pieces[$ "black"][$ _name];
            var _cap_x = _wx+_name_offset-6;
            var _cap_y = _wy+5;
            repeat(_n_captured) {
                draw_sprite_ext(spr_black_pieces, i, _cap_x + _n * _sep, _cap_y, 0.5, 0.5, 0, c_white, 1);
                _n++;
            }
            
        }
        
        if (self.game_ended) {
            draw_set_alpha(0.7);
            draw_set_color(c_black);
            draw_rectangle(self.x, self.y, self.x+8*TILE, self.y + 8*TILE, false);
            draw_set_alpha(1);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(c_white);
            if (self.winner == noone) {
                draw_text(self.x+ (8*TILE)/2, self.y + (8*TILE)/2, "DRAW")
            } else {
                var _col_text = self.winner == piece_color.white ? "white" : "black";
                
                var _winner = (self.playing_orb[$ "white"] != self.playing_orb[$ "black"]) ? self.playing_orb[$ _col_text]  :  self.players_names[$ _col_text];
                draw_text(self.x+ (8*TILE)/2, self.y + (8*TILE)/2, $"{string_upper(_winner)} WINS !")
                
            }
               
            
            
            
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
            
    }
    
    function play_sfx(_sfx, _priority = 0) {
 
        if !(self.is_false_board) audio_play_sound(_sfx, _priority, 0);
    }
    

}





/**
 * Wrap a given coordinate horizontally in a 8x8 grid
 * @param {array<Real>} pos The positioon to wrap
 * @returns {array<Real>} New position
 */
function wrap_pos(_pos) {
    var _min = 0
    var _max = 7
    var range = _max - _min + 1; // + 1 is because max bound is inclusive
    return [(((_pos[0] - _min) % range) + range) % range + _min, _pos[1]];
}


