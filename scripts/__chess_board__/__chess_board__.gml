#macro TILE 32

function chess_board(_x, _y, _sprite_index, _view =PIECE_COLOR.WHITE, _verbose = false, _local = false) constructor {
    //// GAMEMAKER ///
    self.x                 = _x;
    self.y                 = _y;
    self.view              = _view;
    self.sprite_index      = _sprite_index;
    self.selected_piece    = undefined;
    self.verbose           = _verbose;
    self.local             = _local;
    /////////////////////////////
    
    self.grid = array_create_ext(8, function() {return array_create(8, undefined);});
    
    
    self.captured_pieces   = {"white" : {"Pawn":0, "Rook":0, "Knight": 0, "Bishop" : 0, "Queen":0, "King":0}, 
                              "black" : {"Pawn":0, "Rook":0, "Knight": 0, "Bishop" : 0, "Queen":0, "King":0}}
    
    self.players_names     = {"white" : "Player1",
                              "black" : "Player2"}
    
    self.playing_orb       = {"white" : "Paris",
                              "black" : "Ivry"}
    
    self.turn           =PIECE_COLOR.WHITE;
    self.number_of_turn = 0;
    self.checked        = undefined;
    self.game_ended     = false;
    self.winner         = undefined;
    self.possible_moves = [[], []];
    self.square_reached = [[], []];
    
    
    self.last_move      = undefined;
    self.orbs_status    = undefined;
    
    function board_view(_value) {
        return (self.view == PIECE_COLOR.WHITE) ? _value : 7 - _value;
    }
    function local_board_view(_color, _value) {
        return (_color == PIECE_COLOR.WHITE) ? _value : 7 - _value;
    }
    
    function init_board() {
        self.selected_piece = undefined;
        
        self.grid = array_create_ext(8, function() {return array_create(8, undefined);})
        
        self.captured_pieces = {"white" : {"Pawn":0, "Rook":0, "Knight": 0, "Bishop" : 0, "Queen":0, "King":0}, 
                                "black" : {"Pawn":0, "Rook":0, "Knight": 0, "Bishop" : 0, "Queen":0, "King":0}}
        
        self.turn           =PIECE_COLOR.WHITE;
        self.number_of_turn = 0;
        self.checked        = undefined;
        self.game_ended     = false;
        self.winner         = undefined;
        self.possible_moves = [[], []];
        self.square_reached = [[], []];
    
        self.last_move      = undefined;
        
        
        //////////// PLACE PIECES /////////////////////
        //Pawn
        for (var i = 0; i < 8 ;i++) {
            add_piece(piece_type.pawn,PIECE_COLOR.BLACK, [i, 1]);
            add_piece(piece_type.pawn,PIECE_COLOR.WHITE, [i, 6]);
        }
        
        //Rook
        add_piece(piece_type.rook,PIECE_COLOR.BLACK, [0, 0]);
        add_piece(piece_type.rook,PIECE_COLOR.BLACK, [7, 0]);
        add_piece(piece_type.rook,PIECE_COLOR.WHITE, [0, 7]);
        add_piece(piece_type.rook,PIECE_COLOR.WHITE, [7, 7]);
        
        // Knight
        add_piece(piece_type.knight,PIECE_COLOR.BLACK, [1, 0]);
        add_piece(piece_type.knight,PIECE_COLOR.BLACK, [6, 0]);
        add_piece(piece_type.knight,PIECE_COLOR.WHITE, [1, 7]);
        add_piece(piece_type.knight,PIECE_COLOR.WHITE, [6, 7]);
        
        // Bishop
        add_piece(piece_type.bishop,PIECE_COLOR.BLACK, [2, 0]);
        add_piece(piece_type.bishop,PIECE_COLOR.BLACK, [5, 0]);
        add_piece(piece_type.bishop,PIECE_COLOR.WHITE, [2, 7]);
        add_piece(piece_type.bishop,PIECE_COLOR.WHITE, [5, 7]);

        // Queen
        add_piece(piece_type.queen,PIECE_COLOR.BLACK, [3, 0]);
        add_piece(piece_type.queen,PIECE_COLOR.WHITE, [3, 7]);
        
        //King
        add_piece(piece_type.king,PIECE_COLOR.BLACK, [4, 0]);
        add_piece(piece_type.king,PIECE_COLOR.WHITE, [4, 7]);
        
        self.init_all_moves(self.turn);
        
        
 
    }
    
    function get_grid() {
        return self.grid;
    }
    
    
    /////////////////////////////////////////// PIECE //////////////////////////////////
    function get_piece(pos) {
        var _w_pos = wrap_pos(pos);
        return self.grid[_w_pos[0], _w_pos[1]];
    }
    
         
    /**
    * Add chess piece to board
    * @param {enum.piece_type} type type of piece
    * @param {enum.PIECE_COLOR} color color of piece
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
    
    function remove_piece(_pos) { 
        delete self.grid[_pos[0], _pos[1]];
        self.grid[_pos[0], _pos[1]] = undefined;
    }
    
    function update_pieces_last_pos(_color) {
        for (var i = 0; i < 8; i++) {
            for (var j = 0; j < 8; j++) {
                var _piece = self.grid[i, j];
                if (_piece == undefined) continue;
                    
                if (_piece.get_color()!=_color) continue;
                    
                _piece.update_last_pos();
            }
        }
        
    }
    function piece_captured(_pos, _temp_move = false) {
        if (!_temp_move) play_sfx(sfx_captured, 1);
        
        var _piece = self.get_piece(_pos);
        
        if (!_temp_move) {
            if (_piece.get_color() == PIECE_COLOR.WHITE) self.captured_pieces[$ "white"][$ _piece.get_name()]+=1;
            else self.captured_pieces[$ "black"][$ _piece.get_name()]+=1;
            if (self.verbose) show_debug_message($"{_piece.get_color() ==PIECE_COLOR.WHITE ? "White" : "Black"} {_piece.get_name()} Captured on {get_chess_pos(_pos)}!");
        }
        remove_piece(_pos);
    }
    
    
    function find_king_pos(_color) {
        for (var i = 0; i < 8; i++) {
            for (var j = 0; j < 8; j++) {
                var _piece = self.grid[i, j];
                
                if (_piece == undefined) or (_piece.get_color() != _color) continue;
                    
                if (_piece.get_type() == piece_type.king) return[i, j];
            }
        }
        return undefined;
        
    }
    
    
    
    function init_all_moves(_color) {
        
        self.square_reached[PIECE_COLOR.WHITE] = self.get_all_attacked_squares(PIECE_COLOR.WHITE);
        self.square_reached[PIECE_COLOR.BLACK] = self.get_all_attacked_squares(PIECE_COLOR.BLACK);
        
        self.possible_moves[_color] = self.get_legal_moves(PIECE_COLOR.WHITE);
    }
    ////////////////////////////////////////// SQUARE ////////////////////////////////////////
    function square_safe(_pos, _color) {
 
        var _possible_enemy_move = self.square_reached[!_color];
        
        // CHECK IF ONE OF POSSIBLE ENEMY MOVE HIT COORDINATES
        for (var i = 0, n = array_length(_possible_enemy_move); i < n; i++) {
            var _enemy_move = _possible_enemy_move[i]
            if (array_equals(_pos, _enemy_move)) return false
        }
        return true
            
    }
    /**
    * Check if square in the given grid at the given pos is empty (!=undefined)
    * @param {array<array>} grid Grid to check in
    * @param {array<Real>} pos Position to check in the grid
    * @returns {bool} return whether the the square is empty
    */
    function square_empty(_pos) {
            if (_pos[1] > 7) or (_pos[1] < 0) return false;
            var w_pos = wrap_pos(_pos)
            return self.grid[w_pos[0], w_pos[1]] == undefined;
        }
    

    
    /**
     * Generates a list of all legal moves for a given color.
     * A move is legal if it is a valid move for the piece and does not leave the player's own king in check.
     * @param {enum.PIECE_COLOR} color color of piece
     * @returns {array<array<int>>}
     */
    function get_legal_moves(_color) {
        var _legal_moves = []
        for (var i = 0; i < 8; i++) {
            for (var j = 0; j < 8; j++) {
                var _piece = self.grid[i, j];
                if (_piece == undefined) or (_piece.get_color()!=_color) continue; 
                    
                // GET ALL POTENTIAL MOVES FOR THIS PIECE
                var _pseudo_legal_moves = _piece.check_moves();
                
                // FILTER OUT MOVES THAT WOULD LEAVE KING IN CHECK
                var _piece_moves = [];
                for (var m = 0, n = array_length(_pseudo_legal_moves); m<n;m++) {
                    var _move = _pseudo_legal_moves[m];
                    
                    if (!is_checked_after_move(_piece.get_pos(), _move, _color)) {
                        array_push(_legal_moves, _move);
                        array_push(_piece_moves, _move);
                    }
                    
                }
                _piece.set_moves(_piece_moves);
               
                
            }
        }
        return _legal_moves;
    }
    /**
    * Generates a list of all squares attacked by a given color.
    * @param {enum.PIECE_COLOR} color color of piece
    */
    function get_all_attacked_squares(_color) {
        var _attacked_squares = []
        for (var i = 0; i < 8; i++) {
            for (var j = 0; j < 8; j++) {
                var _piece = self.grid[i, j];
                
                if (_piece == undefined) or (_piece.get_color() != _color) continue; 
                    
                var _moves =  _piece.check_moves();
                _attacked_squares = array_concat(_attacked_squares,_moves)
            }
        }
        return _attacked_squares
    }
  
    
    ///////////////////////////////// MOVE PIECES ///////////////////////////////////////////
    function move_piece(_from_pos, _to_pos, _real_move = true) {
        
        
        
        var _move_info = {
            "from_pos"  : _from_pos,
            "to_pos"    : _to_pos,
            "captured_piece" : undefined,
            "special_move" : {"type" : SPECIAL_MOVES.NONE, "captured_pawn_pos" : undefined, "rook_from" : undefined, "rook_to" : undefined},
            "was_moved"    : undefined,
        }
        
        var _piece =  self.get_piece(_from_pos);
        if (_piece == undefined) return;
            
        _move_info[$ "was_moved"]  = _piece.has_moved;
        
   
        
        var _captured_piece = self.get_piece(_to_pos);
        
        
        if (_captured_piece!=undefined) {
            _move_info[$ "captured_piece"] = _captured_piece;
            self.piece_captured(_to_pos, !_real_move);
        } else {
                if (_real_move) play_sfx(sfx_moved, 0);
        }
        
        self.grid[_to_pos[0], _to_pos[1]] = _piece;
        remove_piece(_from_pos);
        _piece.set_pos(_to_pos);
        
        // EN PASSANT
        if (_piece.get_type() == piece_type.pawn) and (array_equals(_to_pos, _piece.en_passant)) {
            //if verbose show_message($"{_piece.en_passant} - {_to_pos}")
            var _pawn_affected = [_to_pos[0], _to_pos[1] - _piece.forward]
            _move_info[$ "captured_piece"] = self.get_piece(_pawn_affected);
            piece_captured(_pawn_affected, !_real_move);
            
            _move_info[$ "special_move"][$ "type"]              = SPECIAL_MOVES.EN_PASSANT;
            _move_info[$ "special_move"][$ "captured_pawn_pos"] = _pawn_affected;
        
        }    
        
        // CASTLE
        if (_piece.get_type() == piece_type.king) {
            
            //if verbose show_message($"{_piece.en_passant} - {_to_pos}")
            var _rook_from, _rook_to;
            var _king_pos = _piece.get_pos();
            
            if (array_equals(_to_pos, _piece.right_castle)) {
                _rook_from = [_king_pos[0] + 3, _king_pos[1]];
                _rook_to   = [_king_pos[0] + 1, _king_pos[1]];
                
                move_piece(_rook_from, _rook_to, false);
                if (_real_move) play_sfx(sfx_castle, 1);
                _move_info[$ "special_move"] = {"type": SPECIAL_MOVES.CASTLE, "rook_from": _rook_from, "rook_to": _rook_to} 
                
                
            } 
            if (array_equals(_to_pos, _piece.left_castle)) {
                        _rook_from = [_king_pos[0] - 4, _king_pos[1]];
                        _rook_to  = [_king_pos[0] - 1, _king_pos[1]];
                        
                move_piece(_rook_from, _rook_to, false);
                if (_real_move) play_sfx(sfx_castle, 1);
                _move_info[$ "special_move"] = {"type": SPECIAL_MOVES.CASTLE, "rook_from": _rook_from, "rook_to": _rook_to} 
            }
           
        }   
        // PROMOTION
        if ((_to_pos[1] == 0 or _to_pos[1] == 7)) and (_piece.get_type() == piece_type.pawn) {
            
            add_piece(piece_type.queen, _piece.get_color(), _to_pos)// PROMOTION
            _move_info[$ "special_move"]         = {"type": SPECIAL_MOVES.PROMOTION, "pawn_pos": _to_pos}
            _move_info[$ "promoted_from_pawn"]   = _piece 
            if (_real_move) play_sfx(sfx_promote, 1);
        }
        // NORMAL
        else _piece.set_moved();      
        
        
        selected_piece = undefined;
        if (self.verbose) show_debug_message($"{_piece.get_color() ==PIECE_COLOR.WHITE ? "White" : "Black"} {_piece.get_name()} moves {get_chess_pos(_to_pos)}!")
        if (_real_move) { 
              //if (global.color != self.turn) 
            self.last_move = [_from_pos, _to_pos];
            next_turn();
            
        }
        return _move_info;
    }
    
    
    /// @function unmake_move(_move_info)
    /// @description Reverses a move made on the board using the provided info struct.
    /// @param {struct} _move_info The struct returned by a call to move_piece.
    function unmake_move(_move_info) {
    
        // information from the struct
        var _from_pos                  = _move_info.from_pos;
        var _to_pos                    = _move_info.to_pos;
        var _special_move_type     = _move_info.special_move.type;
        var _captured_piece        = _move_info.captured_piece;
    
        var _moving_piece = self.get_piece(_to_pos);
        
        // reverse promotion 
        if (_special_move_type == SPECIAL_MOVES.PROMOTION) {
            var _original_pawn = _move_info.promoted_from_pawn;
            self.grid[_to_pos[0], _to_pos[1]] = _original_pawn;
            _moving_piece = _original_pawn;
        }
    
        // Move the Piece Back
        self.grid[_from_pos[0], _from_pos[1]] = _moving_piece;
        _moving_piece.set_pos(_from_pos);
        self.grid[_to_pos[0], _to_pos[1]] = undefined;
    
        // Restore has_moved -
        if (!_move_info.was_moved) _moving_piece.set_moved(false); 
        
    
        // Put Back Captured Piece
        if (_captured_piece != undefined) {
            var _capture_pos = _to_pos; 
            
            if (_special_move_type == SPECIAL_MOVES.EN_PASSANT) {
                _capture_pos = _move_info.special_move.captured_pawn_pos;
            }
            
            self.grid[_capture_pos[0], _capture_pos[1]] = _captured_piece;
            
        }
        
        // Undo Castling's rook
        if (_special_move_type == SPECIAL_MOVES.CASTLE) {
            var _rook_from = _move_info.special_move.rook_from;
            var _rook_to = _move_info.special_move.rook_to;
            
            // Get the rook that was moved
            var _rook = self.get_piece(_rook_to);
            
            // Move the rook back 
            self.grid[_rook_from[0], _rook_from[1]] = _rook;
            _rook.set_pos(_rook_from);
            
            self.grid[_rook_to[0], _rook_to[1]] = undefined;
            
            _rook.set_moved(false);
        }
    }
    
   
    //////////////////////////////////// CHECK //////////////////////////////////////////
    function is_checked(_color) {
        var _possible_enemy_move = self.square_reached[!_color];
    
        // FIND KING COORDINATES
        var _king_coord = find_king_pos(_color);
        if (_king_coord==undefined) return false;
        
        // CHECK IF ONE OF POSSIBLE ENEMY MOVE HIT COORDINATES
        for (var i = 0, n = array_length(_possible_enemy_move); i < n; i++) {
            var _enemy_move = _possible_enemy_move[i]
            if (array_equals(_king_coord, _enemy_move)) return true
        }
        return false
        
    }
    
    
    
    /// @function is_checked_after_move(_from_pos, _to_pos, _color)
    /// @description Safely checks if a move would leave the king in check
    function is_checked_after_move(_from_pos, _to_pos, _color) {
        
        var _original_enemy_attacks = self.square_reached[!_color];
    

        var _undo_info = move_piece(_from_pos, _to_pos, false);
    
        self.square_reached[!_color] = self.get_all_attacked_squares(!_color);
        

        var _is_in_check = self.is_checked(_color);
    
       
        unmake_move(_undo_info);
    

        self.square_reached[!_color] = _original_enemy_attacks;
    
        return _is_in_check;
    }
    
 
    function check_move_valid(_from_pos, _to_pos) {
        var _piece = self.get_piece(_from_pos);
        var _moves = _piece.get_moves();
        _moves = remove_illegal_moves(_piece, _moves, _piece.get_color());
        
        for (var i = 0, n = array_length(_moves); i < n; i++) {
            var _possible_move =  _moves[i];
            if (array_equals(_possible_move, _to_pos)) return true;
        }
        return false
    }
   

    
    function next_turn() {
        self.selected_piece = undefined;
        
        
        
        self.number_of_turn++;
        self.turn = !self.turn;
        self.update_pieces_last_pos(self.turn);
        
        self.possible_moves[self.turn] = self.get_legal_moves(self.turn)
        
        self.square_reached[!self.turn] = self.get_all_attacked_squares(!self.turn);
        
        var _is_in_check = self.is_checked(self.turn);
        
        if (_is_in_check) {
            play_sfx(sfx_checked, 2);
            checked = turn;
        } else checked = undefined;
       
        var _moves_left = array_length(possible_moves[self.turn]);
        

        if (_moves_left == 0) && (!game_ended) {    
            self.game_ended = true;
             // VERIFY CHECKMATE / STALEMATE
            
            if (_is_in_check) {
                self.winner = !turn;
                play_sfx(sfx_checkmate, 3);
            } else {
                self.winner = undefined;
                checked = undefined;
            }
            
        }
        
           
}
    

    ///////////////////////////////////////// BOATD DATA STUFF //////////////////////////////
    
    function get_board_data() {
        var _data = {"turn" : self.turn, "captured_pieces" : self.captured_pieces, "number_of_turn" : number_of_turn}
        var _board_data = array_create_ext(8, function() {return array_create(8, "");})
        for (var i = 0; i < 8; i++) {
            for (var j = 0; j < 8; j++) {
                var _piece = self.grid[i, j];
                if (_piece == undefined) continue;
                _board_data[i, j] = _piece.get_data();
                
            }
        }
        _data[$ "board"] = _board_data
        
        return _data;
        
        
    }
    
    function load_board_data(_data) {
        self.grid = array_create_ext(8, function() {return array_create(8, undefined);})
        self.captured_pieces = _data[$ "captured_pieces"];
        self.turn            = _data[$ "turn"]
        self.number_of_turn      = _data[$ "number_of_turn"];
        var _board_data      = _data[$ "board"]
        for (var i = 0; i < 8; i++) {
            for (var j = 0; j < 8; j++) {
                var _piece = _board_data[i, j];
                if (_piece == "") continue; 
                    
                _piece_data = string_split(_piece, ";");
                var _type  = _piece_data[0];
                var _color = _piece_data[1];
                var _have_moved = _piece_data[2];
                self.add_piece(real(_type), real(_color), [i, j])
                self.grid[i, j].set_moved(_have_moved);
            }
        }
    }
    
    function load_info(_info) {
        
        self.players_names = {"white" : _info[$ "white_player"] ?? "?",
                              "black" : _info[$ "black_player"] ?? "?"}
        
        self.playing_orb    =    {"white" : _info[$ "white_orb"] ?? "?",
                                "black" : _info[$ "black_orb"]  ?? "?"}
        self.game_ended     = _info[$ "status"];
        self.winner         = _info[$ "winner"];
        self.orbs_status    = _info[$ "orbs_status"]
        
    }
    
    function get_board_string(){
        var _board_string = ""
        for (var i = 0; i < 8; i++) {
            for (var j = 0; j < 8; j++) {
                var _piece = self.grid[j, i];
                if (_piece == undefined) _board_string+="*"
                else _board_string+=_piece.get_s();    
            }
        }
        return _board_string;
    }
    function get_chess_pos(_pos) {
        var _xname = ["a", "b", "c", "d", "e", "f", "g", "h"];
        
        return $"{_xname[board_view(_pos[0])]}{8 - board_view(_pos[1])}"
    }
    //////// NETWORKING STUFF !!!!!! ///////
    function ask_move_piece(_from_pos, _to_pos) {
        if (local) move_piece(_from_pos, _to_pos);
        else {
            
            if (self.orbs_status != undefined) and ((self.orbs_status[0] != ORB_STATUS.IDLE) or ((self.orbs_status[1] != ORB_STATUS.IDLE))) { // ORB BUSY
                    enqueue_pop_message(POP_MESSAGE_TYPE.SERVER_MESSAGE, "ERROR : ORB ARE BUSY")
                    return; // EXIT (NO NEED TO ASK NETWORK)
            }
            
            if (global.color == turn) && (!global.asked_a_move) {
                
                var _data = {
                    "type" : MESSAGE_TYPE.ASK_MOVE,
                    "game_id" : global.game_info[$ "game_id"],
                    "from" : _from_pos,
                    "to"   : _to_pos,
                    "color": global.color,
                }
                global.asked_a_move = true;
                player_send_packet(_data);// NETWORKING //
            }
        }    
    }
    
     ///////////////////////////////////////////////////////////// BOARD CLICKED ///////////////////////////////////////////////////////
    function clicked(_x, _y) {
        if ((global.color != turn) or global.asked_a_move or game_ended or (global.current_pop_message != undefined)) and (!local) return;
            
    
        var _relative_x = _x - self.x;
        var _relative_y = _y - self.y;
        
        var _out_of_bound = ((_relative_x < 0) or (_relative_x > 8 * TILE-1) or (_relative_y < 0) or (_relative_y> 8 * TILE-1))
        
        if (_out_of_bound) self.selected_piece = undefined;
        else {
            var _clicked_x = board_view(_relative_x div TILE);
            var _clicked_y = board_view(_relative_y div TILE);
            
    
            
            
            
            if (self.selected_piece != undefined)  {
              
                var _moves = selected_piece.get_moves();
                
                for (var i = 0, n = array_length(_moves); i<n;i++) { 
                    var _move = _moves[i];
                    if (array_equals(_move, [_clicked_x, _clicked_y])) {
                        ///////////////////////////////////////////////////////////////
                        if (selected_piece != undefined) {
                            ask_move_piece(selected_piece.get_pos(), _move); 
                            selected_piece = undefined;
                        }
                            
                        /////////////////////////////////////////////////////
                    }
                    
                }
                
            }
                    
            var _piece = self.grid[_clicked_x, _clicked_y];
            if (_piece == undefined) return
            if(_piece.get_color() == turn) self.selected_piece = self.grid[_clicked_x, _clicked_y]; // <------------ SET SELECTED PIECE
            

            
           
                /*
            if (self.selected_piece != undefined) {
                    self.selected_piece.check_moves();
                    var _selected_piece_moves = self.selected_piece.get_moves();

                    _selected_piece_moves = remove_illegal_moves(self.selected_piece, _selected_move, self.selected_piece.get_color())
                
                    self.selected_piece.set_moves(_selected_piece_moves);
                    //self.selected_piece.filter_moves()
            }*/
        }
        
    }
    /////////////////////////////////////////////////////////// DRAW BOARD //////////////////////////////////////
    function draw() { 
            
        
        // DRAW BOARD 
        draw_sprite(self.sprite_index, 4, self.x, self.y);
        // DRAW SELECTED PIECE
        if (selected_piece != undefined) {
            // HIGHLIGHT SELECTED PIECE 
            draw_set_alpha(0.8)
            draw_set_color(#b9ca43);
            var _selected_piece_coord = selected_piece.get_pos()
            var _drawx = self.x + board_view(_selected_piece_coord[0]) * TILE;
            var _drawy = self.y + board_view(_selected_piece_coord[1]) * TILE;
            draw_rectangle( _drawx , _drawy, _drawx +TILE, _drawy+TILE, false);
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
                draw_rectangle(_x, _y, _x+TILE, _y+TILE, false);
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
                
                /// HIGLIGHT LAST MOVE
                if (last_move != undefined) {
                            var _e = 0;
                            repeat(2) {
                                if (array_equals([_i, _j], self.last_move[_e])) {
                                   
                                    draw_set_color(c_lime);
                                    draw_set_alpha(0.3);
                                    draw_rectangle(_piece_x, _piece_y, _piece_x+TILE-1, _piece_y+TILE-1, false)
                                    draw_set_color(c_black);
                                    draw_set_alpha(1);
                                    
                                }
                                _e++;
                            }
                            
                        }
                
                if (_piece == undefined) continue;
       
                // HIGHLIGHT CHECKED KING
                draw_set_color(c_red);
                draw_set_alpha(0.8);
                if (_piece.get_color() == self.checked) and (_piece.get_type() == piece_type.king) draw_rectangle(_piece_x, _piece_y, _piece_x+TILE-1, _piece_y+TILE-1, false)
                draw_set_color(c_black);
                draw_set_alpha(1);
                
                 draw_sprite(_piece.sprite, _piece.image_index, _piece_x, _piece_y)
           }
        }
    }
    
   
    /////////////////////////////////////// DRAW BOARD INFO /////////////////////////////////////////////////////

    function draw_info() {
        
        
        draw_set_color(c_white);
        draw_set_valign(fa_middle)
        draw_set_halign(fa_left);
        draw_set_font(fnt_game);
        var _xoffset = 0;
        var _yoffset = 32;
        var _view_offset = [-_yoffset, 8 * TILE + _yoffset];
        
        var _pieces = ["Pawn", "Knight", "Bishop", "Rook", "Queen", "King"];
        var _name_offset = 38;
        var _piece_captured_offset = 60;
        var _sep = 8;
        
        
        //////////////// BLACK ////////////////
        
        var _bx = self.x + _xoffset;
        var _by = self.y + _view_offset[self.view];
        
        if (self.players_names[$ "black"]!="")  {
            var _orb_name = ""
            if (self.playing_orb[$ "black"] != "") _orb_name = $" - {self.playing_orb[$ "black"]}"
                
            draw_sprite(spr_black_profile, 0, _bx, _by); // PROFILE
            draw_text(_bx+ _name_offset,  _by, $"{self.players_names[$ "black"]}" + _orb_name); // NAME
        } else draw_text(_bx,  _by, "waiting for players"); // NAME
            
        
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
        if (self.orbs_status!=undefined) {
            var _status = self.orbs_status[PIECE_COLOR.BLACK];
            draw_sprite(spr_orb_status, _status, _bx + 210, _by - 16)
        }
        
        //////////////// WHITE  ////////////////
        var _wx = self.x + _xoffset;
        var _wy = self.y + _view_offset[!self.view];
        
        if (self.players_names[$ "white"]!="")  {
            _orb_name = ""
            if (self.playing_orb[$ "white"] != "") _orb_name = $" - {self.playing_orb[$ "white"]}"
            draw_sprite(spr_white_profile, 0, _wx, _wy); // PROFILE
            draw_text(_wx+_name_offset,  _wy,  $"{self.players_names[$ "white"]}" + _orb_name) // NAME
        } else draw_text(_wx,  _wy,  "waiting for players") // NAME
        
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
        if (self.orbs_status!=undefined) {
            var _status = self.orbs_status[PIECE_COLOR.WHITE];
            draw_sprite(spr_orb_status, _status, _wx + 210, _wy - 16)
        }
       
        if (self.game_ended) {
            draw_set_alpha(0.7);
            draw_set_color(c_black);
            draw_rectangle(self.x, self.y, self.x+8*TILE, self.y + 8*TILE, false);
            draw_set_alpha(1);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(c_white);
            if (self.winner == undefined) {
                draw_text(self.x+ (8*TILE)/2, self.y + (8*TILE)/2, "DRAW")
            } else {
                var _col_text = self.winner ==PIECE_COLOR.WHITE ? "white" : "black";
                
                var _winner = (self.playing_orb[$ "white"] != self.playing_orb[$ "black"]) ? self.playing_orb[$ _col_text]  :  self.players_names[$ _col_text];
                draw_text(self.x+ (8*TILE)/2, self.y + (8*TILE)/2, $"{string_upper(_winner)} WINS !")
                
            }
               
            
            
            
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        } else  draw_sprite(spr_turn_indicator, self.turn, 160, 16);
            
    }
    
    
    ///////////////////// OTHER WEIRD FUNC /////////////////////////////
    function play_sfx(_sfx, _priority = 0) {
        audio_play_sound(_sfx, _priority, 0);
    }
    
    function chance_view() {
        self.view = !self.view;
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


