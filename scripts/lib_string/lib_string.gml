if(!script_exists(asset_get_index("lib_library"))) {
	show_error("lib_library is missing!!",true);
	exit;
	}

library_declare("lib_string")

/// @function	sprintf(text, [replacements,...])
/// @param {string}	text				the base string to replace %s occurances in
/// @param {string} [replacements]		any number of following replacements
function sprintf(_text) {
	if(_text == undefined) {return "";} //nothing provided
	if(argument_count == 1) {return string(_text);} 
	
	var outstring = string(_text);
	var i = 1;
	while(string_count("%s",outstring) != 0 && i < argument_count) {
		var pos = string_pos("%s",outstring);
		outstring = string_delete(outstring,pos,2);
		outstring = string_insert(string(argument[i]),outstring,pos);
		i++;
		}	
	return outstring;
}

/// @function printf(text, [replacements,...])
/// @description	shortcut for show_debug_message(sprintf(args));
function printf(_text) {
	var args = array_create(argument_count)
	for(var i = 0; i < argument_count; i++) {args[i] = argument[i]}
	var out = script_execute_ext(sprintf,args)
	show_debug_message(out)
	}

/// @function string_eat(text, [separator])
/// @param {string}	text			the string to eat
/// @param {string}	[separator]		the character to use as the separator, " " by default
/// @description	gives a substring of the given string, from the start of the 
///					string up to the first instance of the split character (default is " ")
function string_eat(_text) {
	var split = (argument_count > 1) ? argument[1] : " ";
	var sepPoint = string_pos(split,_text);
	if sepPoint == 0 {return _text}
	else {return string_copy(_text,1,sepPoint-1)};
	}
	
/// @function string_advance(text, [separator])
/// @param {string}	text			the string to advance
/// @param {string}	[separator]		the character to use as the separator, " " by default
/// @description	opposite of string_eat, gives a substring starting at the first
///					instance of the split character (default is " ") until the end of the string
function string_advance(_text) {
	var split = (argument_count > 1) ? argument[1] : " ";
	var sepPoint = string_pos(split,_text);
	if sepPoint == 0 {return ""}
	else {return string_copy(_text,sepPoint+1,string_length(_text)+1-sepPoint);}
	}

/// @function string_split(text, [separator])
/// @param {string} text			the string to separate
/// @param {string}	[separator]		the character to use as the separator, " " by default
/// @description	breaks up a string into an array of substrings based on the split character (default is " ")
function string_split(_text) {
	var split = (argument_count > 1) ? argument[1] : " ";
	var out = [];
	var i = 0;
	while(_text != "") {
		out[i] = string_eat(_text,split);
		_text = string_advance(_text,split);
		i++
		}
	return out;
	}
	
/// @function string_pad_left(text, width)
/// @param {string}	text			the string to pad
/// @param {real}	length			the desired length of the string
/// @description	pads the given string with spaces from the left until it
///					matches the desired length
function string_pad_left(_text,_width) {
	while(string_length(_text) < _width) {
		_text = " " + _text;
		}
	return _text;
	}
	
/// @function string_pad_right(text, width)
/// @param {string}	text			the string to pad
/// @param {real}	length			the desired length of the string
/// @description	pads the given string with spaces from the right until it
///					matches the desired length
function string_pad_right(_text,_width) {
	while(string_length(_text) < _width) {
		_text = _text + " ";
		}
	return _text;
	}
	
// this isn't particularly efficient but it should do
/// @function string_longest_substring(list, starting_from)
function string_longest_substring(_list) {
	var _startingFrom = (argument_count == 2) ? argument[1] : "";
	var bigstring = "";
	var outstring = "";
	for(var i = 0; i < ds_list_size(_list); i++) {
		bigstring += _list[| i] + "|"
		}
		
	var entries = ds_list_create()
	
	//find all initial entries
	if(_startingFrom != "") {
		var index = 1;
		var bitesize = string_length(_startingFrom);
		while(index > 0) {
			index = string_pos_ext(_startingFrom,bigstring,index);
			var entry = {
				pos: index,
				text: string_copy(bigstring, index, bitesize),
				length: bitesize
				}
			ds_list_add(entries, entry);
			}
		
		}
	else {
		for(var i = 1; i < string_length(bigstring); i++) {
			var substr = string_copy(bigstring,i,2); //eat in two char chunks
			if(string_count("|",substr) != 0) {continue;} //ignore any chunks containing delimiters
			var entry = {
				pos: i,
				text: substr,
				length: 2
				}
			ds_list_add(entries, entry);
			}
		}
	
	var keys = []
	var seen = ds_map_create();
	
	while(true) {
		//extend each entry by 1
		for(var i = ds_list_size(entries)-1; i >= 0; i--) {
			var entry = entries[| i];
			entry.length = entry.length + 1;
			entry.text = string_copy(bigstring, entry.pos, entry.length);
			//reject strings which cross word borders;
			if(string_count("|",entry.text) > 0) {ds_list_delete(entries, i); continue;}
			if(ds_map_exists(seen,entry.text)) {seen[? entry.text] = seen[? entry.text] + 1}
			else {seen[? entry.text] = 1}
			}
		
		//count occurences of each new extended entry
		var keys = ds_map_keys_to_array(seen, keys)
		
		//if we somehow reject every single entry, just bail
		if(array_length(keys) == 0) {
			ds_map_destroy(seen);
			ds_list_destroy(entries);
			return _startingFrom;
			}
		
		var highestseen = 0;
		for(var i = 0; i < array_length(keys); i++) {
			var entrytext = keys[i]
			var occurences = seen[? entrytext];
			if(occurences > highestseen) {highestseen = occurences}
			}
		
		//if each entry had only 1 occurence, then we now have no common substrings
		if(highestseen == 1) {
			//get the first entry from the last round and undo the extention, then return that
			var entry = entries[| 0]
			outstring = string_copy(entry.text, 1, entry.length-1);
			if(string_length(outstring) == 2) {outstring = ""} //too short to count
			ds_map_destroy(seen);
			ds_list_destroy(entries);
			return outstring;
			}
		else {
			//trim out all the substrings with one occurence, and repeat
			for(var i = ds_list_size(entries)-1; i >=0 ; i--) {
				var entry = entries[| i];
				if(seen[? entry.text] == 1) {
					ds_list_delete(entries,i);
					}
				}
			ds_map_clear(seen);
			array_resize(keys,0);
			}
		}
	}

/// @function string_find_matching_length(list, [muststartwith])
/// @description similar to string_longest_substring but simplified to only count strings which are
///		similar from the start
function string_find_matching_length(_list) {
	var longest_match = "";
	var mustcontain = argument_count == 2 ? argument[1] : ""
	
	//if each substring must start with a given substring, remove
	//all nonconforming strings from the set before we begin
	if(mustcontain != "") {
		var newlist = ds_list_create();
		ds_list_copy(newlist, _list);
		for(var i = ds_list_size(newlist)-1; i >= 0; i--) {
			if(!string_starts_with(newlist[| i], mustcontain)) {
				ds_list_delete(newlist, i);
				}
			}
		_list = newlist;
		}
	
	var size = ds_list_size(_list)
	if(size == 0) {return longest_match}
	if(size == 1) {return _list[| 0]}
		
	var shortest = string_length(_list[| 0]);
	for(var i = 1; i < size; i++) {
		shortest = min(shortest, string_length(_list[| 0]));
		}
	
	
	var matchlength = 0;
	var done = false;
	while(!done) {
		for(var i = 0; i < size; i++) {
			if(i == 0) { //each go around, take the new match from the first element
				//dont allow any match to go longer than the shortest known string
				if(matchlength+1 > shortest) {done = true; break;}
				
				longest_match = string_copy(_list[| i],1,matchlength+1)
				matchlength++;
				}
			else { //every other string has to match that or we finish at last round's answer
				if(string_copy(_list[| i], 1, matchlength) != longest_match) {
					longest_match = string_copy(longest_match,1,matchlength-1);
					done = true;
					break;
					}
				}
			}
		}
	
	//cleanup if we had to make a copy
	if(mustcontain != "") {
		ds_list_destroy(_list);
		}
		
	return longest_match;
	}
	
/// @function string_starts_with(str, substr)
function string_starts_with(_string, _substr) {
	if(_substr == "") {return true;}
	var len = string_length(_substr);
	return (string_copy(_string,1,len) == _substr);
	}
	
/// @function string_concat(array, [separator])
/// @param {array}	array			an array of elemnts
/// @param {string}	[separator]		the character to use as the separator, " " by default
/// @description	essentially the opposite of string_split, used to combine an array of elements
///					back into a single string
function string_concat(_array) {
	var out = "";
	var split = (argument_count > 1) ? argument[1] : " ";
	
	for(var i = 0; i < array_length(_array); i++) {
		out += string(_array[i]);
		if(i < array_length(_array)-1) {
			out += split;
			}
		}
	return out;
	}
	
if(library_present("lib_ui")) {
	
	function string_strip_formatting(_text) {
		var formatmark = chr(UI_TEXT_FORMATTING_MARK)
		var rsidemark = chr(UI_TEXT_FORMATTING_RBRACKET);
	
	
		var ind = string_pos(formatmark,_text); 
		//if(ind > 0) {show_debug_message("string has format marks")}
		//else {show_debug_message("string has no format marks")}
	
		while(ind > 0) {
		
			var right_index = string_pos(rsidemark,_text)+1;
			if(right_index > ind) {
				var len = right_index - ind;
				//var content = string_copy(_text,ind,len);
				//var dbln = sprintf("format mark from %s to %s, length %s, covers %s", ind, right_index, len, content)
				//show_debug_message(dbln)
			
				_text = string_delete(_text,ind,len)
			
				//show_debug_message("text is now '" + _text + "'");
				}
			else {
				//show_debug_message("right_index was " + string(right_index) + " which is less than index " + string(ind));
				break;
				}
		
			ind = string_pos(formatmark,_text); 
			}
	
		return _text;
		}
	
	function string_get_part(_text, _chars, _silent) {
		var formatmark = chr(UI_TEXT_FORMATTING_MARK)
		var rsidemark = chr(UI_TEXT_FORMATTING_RBRACKET);
	
		var product = "";
	
		var charsToEat = _chars;
		var charsEaten = 0;
		var lastEat = 1;
	
		if(!_silent) {show_debug_message("input is: '" + _text + "'")};
	
		//easy out, if there's no format marks, or the first format mark is ahead of where we want to copy, just do a single long copy
		var firstformatmark = string_pos(formatmark,_text);
		if(firstformatmark == 0 || firstformatmark > _chars) {
			product = string_copy(_text,1,_chars);
			}
		else {
			while(charsToEat > charsEaten) {
				var charsneeded = charsToEat - charsEaten;
			
				var distToEnd = charsneeded;
			
				var markstart = string_pos_ext(formatmark,_text,lastEat-1);
			
				var distToMarkStart = markstart - lastEat;
			
			
				if(!_silent) {show_debug_message(sprintf("lastEat: %s, copyLen: %s, nextMark: %s, (%s/%s)",lastEat,distToEnd,distToMarkStart,charsEaten,charsToEat))}
			
				if(markstart == 0) {
					if(!_silent) {show_debug_message("chars remain but there's no format marks left, copy in one go")}
					var tocopy = charsneeded; //copy whats left
				
					product += string_copy(_text,lastEat,tocopy);
					charsEaten += tocopy;
					lastEat += tocopy;
					}
				else if(distToEnd < distToMarkStart) {
					if(!_silent) {show_debug_message("chars remain, formatting marks remain, but we're done before we hit the next one, copy everything we need");}
					var tocopy = charsneeded; //copy whats left
				
					product += string_copy(_text,lastEat,tocopy);
					charsEaten += tocopy;
					lastEat += tocopy;
					}
				else {
					if(!_silent) {show_debug_message("chars remain, a formatting mark exists inbetween where we are and where we want to be, copying up to the cut")}
					var markend = string_pos_ext(rsidemark,_text,lastEat)+1;
					var tocopy = markstart-lastEat;
		
					product += string_copy(_text,lastEat,tocopy);
					product += string_copy(_text,markstart,markend-markstart); //copy the entire formatting block in one go;
					charsEaten += tocopy;
					lastEat = markend;
					}
				
				if(!_silent) {show_debug_message("product is now '" + product + "'");}
				}
		
		
		
			}
		
		return product;
	
		}

}