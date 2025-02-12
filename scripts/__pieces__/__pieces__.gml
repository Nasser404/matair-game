enum piece_type {
    pawn,
    knight,
    rook,
    bishop,
    king,
    queen
}

enum piece_color {
    white,
    black,
}

/**
 * Chess piece constructor
 * @param {string} name Piece name
 * @param {array<real>} pos Piece position
 * @param {Enum.piece_type} type Piece type
 * @param {Enum.piece_color} color Piece color
 * @param {struct} [my_board] Parent board
 */
function piece(_name, _pos, _type, _color, _board) constructor {
    self.name = _name;
    self.pos  = _pos;
    self.type = _type;
    self.color = _color;
    self.moves = []
    self.sprite = self.color == piece_color.white ? spr_white_pieces : spr_black_pieces;
    self.forward = self.color == piece_color.white ? -1: 1;
    self.has_moved = false;
    self.last_pos  = [-1, -1];
    self.special_moves = [];
    self.my_board = _board;
    function get_id() {return [self.color, self.type]}
    
    function get_name() {return self.name}
    function get_pos() {return self.pos}
    function get_last_pos() {return self.last_pos}
    function get_type(){return self.type}
    function get_color(){return self.color}
    function get_moves() { return self.moves}
    function set_pos(_new_pos) {
        update_last_pos();
        self.pos = _new_pos
    
    
    }
    function set_moves(_moves) {self.moves = _moves}
    function update_last_pos() {
        self.last_pos = self.pos
    }
    function set_moved() {self.has_moved = true}
    
 
    /**
    * Function Description
    * @param {array} moves Description
    */
    function add_move(_moves) {
        if !array_equals(self.pos, _moves) array_push(self.moves, wrap_pos(_moves))
    }
    
    function on_team(_pos) {
        if (_pos[1] > 7) or (_pos[1] < 0) return true;
            
        var _grid = self.my_board.get_grid();
        
        if (cell_empty(_pos)) return false;
            
        var w_pos = wrap_pos(_pos)
        return _grid[w_pos[0], w_pos[1]].color == self.color;
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
        var _grid = self.my_board.get_grid();
        return _grid[w_pos[0], w_pos[1]] == noone;
    }
    /**
    * Get the piece in the given grid at the given pos
    * @param {array<array>} grid Grid to check in
    * @param {array<Real>} pos return whether the the cell is empty
    * @returns {struct} 
    */
    function get_piece( _pos) {
        
        if (_pos[1] > 7) or (_pos[1] < 0) return noone;
                    
        if (cell_empty(_pos)) return noone;
            
        var _grid = self.my_board.get_grid();
        var w_pos = wrap_pos(_pos)
        return _grid[w_pos[0], w_pos[1]];
    }
    function get_s() {return self.string}
}


/**
 *  Pawn constructor
 * @param {array<real>} pos  Pawn position
 * @param {enum.piece_color} color  Pawn color
 * @param {struct} [board] Pawn parent board
 */
function pawn(_pos, _color, _board = undefined) : piece("Pawn", _pos, piece_type.pawn, _color, _board) constructor {
    self.pos = _pos;
 
    self.image_index = 0;
    self.en_passant = [-1, -1];
    self.string = "p"
    function check_moves() {
        self.moves = []

        var _x = self.pos[0];
        var _y = self.pos[1];
        // simple forward
        if (cell_empty([_x, _y + forward])) add_move([_x, _y + forward]);
            
        // doubel forward
        if (!has_moved) and (cell_empty([_x, _y + forward])) {
            if cell_empty([_x, _y + 2*forward]) add_move([_x, _y + 2*forward]);
        }
            
        // eat left
        if (!cell_empty([_x + 1, _y + forward])) {
            if (!on_team([_x + 1, _y+ forward])) add_move([_x + 1, _y+ forward]);
        }
            
        // eat right 
        if (!cell_empty([_x - 1, _y + forward])) { 
            if (!on_team([_x - 1, _y+ forward])) add_move([_x - 1, _y+ forward]); 
        } 
        
        // en passant right
        if (!cell_empty( [_x + 1, _y])) {
 
            var _piece = get_piece( [_x + 1, _y]);
            if (_piece.get_color() != self.color) {
                if (_piece.get_type() == piece_type.pawn) {

                    if (_piece.get_pos()[1] == _piece.get_last_pos()[1]+2*_piece.forward) {
                        add_move([_x + 1, _y + forward]);
                        self.en_passant =  wrap_pos([_x + 1, _y + forward]);
                    }
                }
            }
        }
    // en passant left
        if (!cell_empty( [_x - 1, _y])) {
 
            var _piece = get_piece( [_x - 1, _y]);
            if (_piece.get_color() != self.color) {
                if (_piece.get_type() == piece_type.pawn) {

                    if (_piece.get_pos()[1] == _piece.get_last_pos()[1]+2*_piece.forward) 
                    {
                        add_move([_x - 1, _y + forward]); 
                        self.en_passant =  wrap_pos([_x - 1, _y + forward]);
                    }
                }
            }
        }
        
        
        
        
        
        return self.moves;
        
    }
}


function rook(_pos, _color,_board = undefined) : piece("Rook", _pos, piece_type.rook, _color, _board) constructor {

    self.image_index = 3;
    self.pos = _pos;
    self.string = "r"
    function check_moves() {
        self.moves = []
        var _x = self.pos[0];
        var _y = self.pos[1];
        var i;
        
        // right
        i = 1;
        while( cell_empty( [_x+i, _y])) {
            add_move([_x+i, _y]);
            i+=1;
        }
        if (!on_team( [_x+i, _y])) add_move([_x+i, _y]);
            
        // left
        i = -1;
        while( cell_empty( [_x+i, _y])) {
            add_move([_x+i, _y]);
            i-=1;
        }
        if (!on_team( [_x+i, _y])) add_move([_x+i, _y]);
        
        //up
        i = forward;
        while( cell_empty( [_x, _y+i])) {
            add_move([_x, _y+i]);
            i+=forward;
        }
        if (!on_team( [_x, _y+i])) add_move([_x, _y+i]);
            
        //down
        i = -forward;
        while( cell_empty( [_x, _y+i])) {
            add_move([_x, _y+i]);
            i-=forward;
        }
        if (!on_team( [_x, _y+i])) add_move([_x, _y+i]);
        return self.moves;
    }
}

function knight(_pos, _color,_board = undefined) : piece("Knight", _pos, piece_type.knight, _color, _board) constructor {
    self.image_index = 1;
    self.color = _color
    self.pos = _pos;

    self.string = "n"
    function check_moves() {
        self.moves = []
        var _x = pos[0];
        var _y = pos[1];
        var _possible_moves = [
            [_x + 2, _y + forward], [_x - 2, _y + forward],
            [_x + 2, _y - forward], [_x - 2, _y - forward],
            [_x + 1, _y + 2 * forward], [_x - 1, _y + 2 * forward],
            [_x + 1, _y - 2 * forward], [_x - 1, _y - 2 * forward],
        ] 
        for (var i = 0; i < 8; i++) {
            if (!on_team( _possible_moves[i])) add_move(_possible_moves[i]);
        }
        return self.moves;
    }
}

function bishop(_pos, _color,_board = undefined) : piece("Bishop", _pos, piece_type.bishop, _color, _board) constructor {
    self.image_index = 2; 
    self.color = _color;
    self.pos = _pos;
    self.string = "b"
    function check_moves() {
        self.moves = []
        var _x = pos[0];
        var _y = pos[1];
        var i,j;
        // Diag right up
        i = 1;
        j = forward;

        while(cell_empty( [_x+i, _y+j])) {
            add_move([_x+i, _y+j]);
            i+=1;
            j+=forward
        }
        if (!on_team( [_x+i, _y+j])) add_move([_x+i, _y+j]);
        
        // Diag left up
        i = -1;
        j = forward;

        while(cell_empty( [_x+i, _y+j])) {
            add_move([_x+i, _y+j]);
            i-=1;
            j+=forward
        }
        if (!on_team( [_x+i, _y+j])) add_move([_x+i, _y+j]);
            
        //Diag right down
        i = 1;
        j = -forward;

        while(cell_empty( [_x+i, _y+j])) {
            add_move([_x+i, _y+j]);
            i+=1;
            j-=forward
        }
        if (!on_team( [_x+i, _y+j])) add_move([_x+i, _y+j]);
     
        // Diah left down
        i = -1;
        j = -forward;

        while(cell_empty( [_x+i, _y+j])) {
            add_move([_x+i, _y+j]);
            i-=1;
            j-=forward
        }
        if (!on_team( [_x+i, _y+j])) add_move([_x+i, _y+j]);
              
        
        return self.moves;         
    }
}

function queen(_pos, _color,_board = undefined) : piece("Queen", _pos, piece_type.queen, _color, _board) constructor {
    self.image_index = 4;
    self.color = _color;
    self.pos = _pos;
    self.string = "q"
    function check_moves() {
        self.moves = []
        var _x = self.pos[0];
        var _y = self.pos[1];
        var i,j;
        // right
        i = 1;
        while( cell_empty( [_x+i, _y])) {
            add_move([_x+i, _y]);
            i+=1;
        }
        if (!on_team( [_x+i, _y])) add_move([_x+i, _y]);
            
        // left
        i = -1;
        while( cell_empty( [_x+i, _y])) {
            add_move([_x+i, _y]);
            i-=1;
        }
        if (!on_team( [_x+i, _y])) add_move([_x+i, _y]);
        
        //up
        i = forward;
        while( cell_empty( [_x, _y+i])) {
            add_move([_x, _y+i]);
            i+=forward;
        }
        if (!on_team( [_x, _y+i])) add_move([_x, _y+i]);
            
        //down
        i = -forward;
        while( cell_empty( [_x, _y+i])) {
            add_move([_x, _y+i]);
            i-=forward;
        }
        if (!on_team( [_x, _y+i])) add_move([_x, _y+i]);
            
        // Diag right up
        i = 1;
        j = forward;

        while(cell_empty( [_x+i, _y+j])) {
            add_move([_x+i, _y+j]);
            i+=1;
            j+=forward
        }
        if (!on_team( [_x+i, _y+j])) add_move([_x+i, _y+j]);
        
        // Diag left up
        i = -1;
        j = forward;

        while(cell_empty( [_x+i, _y+j])) {
            add_move([_x+i, _y+j]);
            i-=1;
            j+=forward
        }
        if (!on_team( [_x+i, _y+j])) add_move([_x+i, _y+j]);
            
        //Diag right down
        i = 1;
        j = -forward;

        while(cell_empty( [_x+i, _y+j])) {
            add_move([_x+i, _y+j]);
            i+=1;
            j-=forward
        }
        if (!on_team( [_x+i, _y+j])) add_move([_x+i, _y+j]);
    
        // Diah left down
        i = -1;
        j = -forward;

        while(cell_empty( [_x+i, _y+j])) {
            add_move([_x+i, _y+j]);
            i-=1;
            j-=forward
        }
        if (!on_team( [_x+i, _y+j])) add_move([_x+i, _y+j]);
            
        return self.moves;
    }    
}

/**
 * King constructor
 * @param {array<real>} pos King position
 * @param {enum.piece_color} color King color
 * @param {struct} [board] King parent board
 */
function king(_pos, _color,_board = undefined) : piece("King", _pos, piece_type.king, _color, _board) constructor {
    self.image_index = 5;
    self.color = _color;
    self.pos = _pos;
    self.right_castle = [-1, -1];
    self.left_castle = [-1, -1];
    self.string = "k"
    function check_moves() {
        self.right_castle = [-1, -1];
        self.left_castle = [-1, -1];
        
        self.moves = []
        var _x = pos[0];
        var _y = pos[1];
        var _possible_moves = [
        [_x + 1, _y], [_x - 1, _y], [_x, _y+forward], [_x, _y-forward],
        [_x+1, _y+forward], [_x+1, _y-forward], [_x-1, _y +forward], [_x-1, _y-forward],
        ] 
        for (var i = 0; i < 8; i++) {
            if (!on_team( _possible_moves[i])) add_move(_possible_moves[i]);
        }
        
        // Right caste
        var _rook,_line_clear, _line_safe;
        if (!self.has_moved) {
            _rook  = get_piece( [_x + 3, _y]);
            if (_rook != noone) {
                if ((!_rook.has_moved) and (_rook.get_type() == piece_type.rook)) {
                    _line_clear = cell_empty( [_x + 1, _y]) && cell_empty( [_x + 2, _y]);
                    
                    _line_safe  = self.my_board.cell_safe([_x + 1, _y], self.color) && self.my_board.cell_safe([_x + 2, _y], self.color);
                    if (_line_clear) && (_line_safe)  {
                        
                        add_move([_x + 2, _y]);
                        self.right_castle = [_x + 2, _y];
                    }
                    
                }
            }
            
        }
        
        // Left castle
        if (!self.has_moved) {
            _rook  = get_piece( [_x - 4, _y]);
            if (_rook != noone) {
                if ((!_rook.has_moved) and (_rook.get_type() == piece_type.rook)) {
                    _line_clear = cell_empty( [_x - 1, _y]) && cell_empty( [_x - 2, _y])&& cell_empty( [_x - 3, _y]);
                    
                    //show_message("a") 
                    _line_safe  = self.my_board.cell_safe([_x - 1, _y], self.color) && self.my_board.cell_safe([_x - 2, _y], self.color) && self.my_board.cell_safe([_x - 3, _y], self.color);
                    
                    if (_line_clear) && (_line_safe)  {
                        
                        add_move([_x - 2, _y]);
                        self.left_castle = [_x -2, _y];
                    }
                    
                }
            }
            
        }
                
        return self.moves;
    }    
}






