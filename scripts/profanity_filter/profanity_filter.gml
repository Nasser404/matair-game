// ----------------- HELPER FUNCTIONS -----------------

/// @function array_join(_array, _separator)
function array_join(_array, _separator) 
{
    var _string = "";
    var _len = array_length(_array);
    if (_len == 0) return "";
    _string = _array[0];
    for (var i = 1; i < _len; i++) {
        _string += _separator + _array[i];
    }
    return _string;
}

/// @function sanitize_word(_word)
function sanitize_word(_word) 
{
    static _accents = [
        "À", "Â", "Ä", "Æ", "Ç", "É", "È", "Ê", "Ë", "Î", "Ï", 
        "Ô", "Œ", "Ù", "Û", "Ü", "Ÿ"
    ];
    static _replacements = [
        "A", "A", "A", "AE", "C", "E", "E", "E", "E", "I", "I", 
        "O", "OE", "U", "U", "U", "Y"
    ];
    
    var _clean_word = string_upper(_word);
    for (var i = 0; i < array_length(_accents); i++) {
        _clean_word = string_replace_all(_clean_word, _accents[i], _replacements[i]);
    }

    var _final_word = "";
    var _allowed_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    for (var i = 1; i <= string_length(_clean_word); i++) {
        var _char = string_char_at(_clean_word, i);
        if (string_pos(_char, _allowed_chars) > 0) {
            _final_word += _char;
        }
    }
    return _final_word;
}


// ----------------- INITIALISATION -----------------

/// @function profanity_init()
function profanity_init() 
{
    global.profanity_list = []; // Liste des mots censurés
    var _filename = "censor.txt"; 

    if (file_exists(_filename)) {
        var _buffer = buffer_load(_filename);
        var _text = buffer_read(_buffer, buffer_text);
        buffer_delete(_buffer);

        _text = string_replace_all(_text, "\r", ""); // Nettoie les retours Windows
        var _lines = string_split(_text, "\n");

        for (var i = 0; i < array_length(_lines); i++) {
            var _raw = _lines[i];
            var _clean = sanitize_word(_raw);
            if (_clean != "") {
                array_push(global.profanity_list, _clean);
            }
        }

        show_debug_message("Profanity filter initialized with " + string(array_length(global.profanity_list)) + " words.");
    } else {
        show_debug_message("WARNING: censor.txt not found.");
    }
}


// ----------------- FILTRAGE -----------------

/// @function censor_string(_input)
function censor_string(_input)
{
    var _clean_input = sanitize_word(_input); // Nettoyage complet (majuscules + accents + alpha-num)
    var _censored_output = _input;

    for (var i = 0; i < array_length(global.profanity_list); i++) {
        var _badword = global.profanity_list[i];
        var _len = string_length(_badword);
        var _pos = string_pos(_badword, _clean_input); // première occurrence

        while (_pos > 0) {
            // Construction du masque de censure
            var _mask = string_repeat("*", _len);

            // Remplace la partie correspondante dans la version censurée
            _censored_output = string_delete(_censored_output, _pos, _len);
            _censored_output = string_insert(_mask, _censored_output, _pos);

            // Pour éviter boucle infinie, on remplace le mot trouvé par des * dans _clean_input aussi
            _clean_input = string_delete(_clean_input, _pos, _len);
            _clean_input = string_insert(_mask, _clean_input, _pos);

            // Rechercher la prochaine occurrence après remplacement
            _pos = string_pos(_badword, _clean_input);
        }
    }

    return _censored_output;
}

