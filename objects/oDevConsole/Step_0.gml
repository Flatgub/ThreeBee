/// @description DevConsole Step

consoleHeight = round(display_get_gui_height() * consoleHeightRatio);
var neww = display_get_gui_width()
if(neww != consoleWidth) {consoleSurface.resize(neww, display_get_gui_height())}
consoleWidth = neww;

if (keyboard_check_pressed(192) && !global.CONSOLE_OPEN) {
	global.CONSOLE_OPEN = true;
	//input_field_push("CONSOLE")
	keyboard_string = "";
	}
else if global.CONSOLE_OPEN {
	if keyboard_check_pressed(192) {
		global.CONSOLE_OPEN = false;
		keyboard_string = "";	
		}
			
	if keyboard_string != "" {
		pendingCommand += keyboard_string;
		keyboard_string = "";
		usedHistory = false; //a modification was made;
		}
		
	#region history scroll
	if keyboard_check_pressed(vk_up) && ds_list_size(history) != 0 {
		historyScroll++;
		if historyScroll >= ds_list_size(history) {historyScroll = 0;}
		pendingCommand = history[| historyScroll];
		usedHistory = true;
		}
		
	if keyboard_check_pressed(vk_down) && historyScroll > -1 {
		historyScroll--;
		if historyScroll < 0 {historyScroll = 0;}
		pendingCommand = history[| historyScroll];
		usedHistory = true;
		}
	#endregion
		
	#region backspacing
	if keyboard_check_pressed(vk_backspace) {
		backspace = true;
		}
		
	if keyboard_check(vk_backspace) {
		backspaceTime++;
		if backspaceTime >= backspaceThresh {
			if backspaceTime >= backspaceThresh + (3) {
				backspace = true;
				backspaceTime -= (3)
				}
			}
		}
	else {backspaceTime = 0}
		
	if backspace {
		pendingCommand = string_copy(pendingCommand,1,string_length(pendingCommand)-1);
		backspace = false;
		usedHistory = false; //a modification was made to the string;
		}
	#endregion
	
	#region autocomplete 
	if (keyboard_check_pressed(vk_tab)){
		
		//autocomplete a command when there's no complete command
		if(string_count(" ", pendingCommand) == 0) {
			var results = dev_get_autocomplete(pendingCommand, true);
			switch(ds_list_size(results)) {
				case 0: {debug_log("No suggestions for '" + pendingCommand + "'",CONSOLE_WARNING_COL)};break;
				case 1: pendingCommand = results[| 0];break;
				default: {
					debug_log("Suggestions for '" + pendingCommand + "'",CONSOLE_BLUE_COL);
					for(var i = 0; i <ds_list_size(results); i++) {
						debug_log("  " + results[| i],CONSOLE_GENERIC_COL);						
						}
					if(string_length(pendingCommand) > 2) {
						var match = string_find_matching_length(results, pendingCommand)
						if(match != "") {
							pendingCommand = match;
							}
						//pendingCommand = matchAsMuchAsPossible(pendingCommand, results);
						}
					}
				};
			ds_list_destroy(results);
			}
		else { //try and autocomplete arguments using suggestion helper
			var split = string_split(pendingCommand);
			var commandname = split[0];
			var command = dev_get_command(commandname);
			//if there's a suggestion helper available
			if(!is_undefined(command.suggestionHelper)) {
				var numargs = array_length(split);
				var prevargs;
				var current;
				//if the last character is a space, then the current argument is nothing
				if(string_char_at(pendingCommand,string_length(pendingCommand))==" ") {
					prevargs = array_create(numargs-1); //-1 to avoid including the command itself
					array_copy(prevargs,0,split,1,numargs-1);
					current = "";
					}
				else {//if the current argument is something, trim it out of the prevargs array 
					prevargs = array_create(numargs-2); //-2 to avoid the command and the last arg
					array_copy(prevargs,0,split,1,numargs-2);
					current = split[numargs-1]
					}
				
				var suggestions = command.suggestionHelper(prevargs);
				var originalsuggs = ds_list_size(suggestions);
				var numsuggs = originalsuggs
				//only do autocomplete if we're not already done
				if(ds_list_find_index(suggestions, current) == -1) {					
					var context = {current: current};
					//trim out all suggestions which dont match
					ds_list_retain_if(suggestions, function(_a, context) {return (string_char_at(_a,1) == "<") || (string_starts_with(_a, context.current))}, context);
					delete context;
					numsuggs = ds_list_size(suggestions);
					
					switch(numsuggs) {
						case 0: { //show an error if we filtered out all the suggestions or do nothing
							if(originalsuggs != 0) {
								debug_log(commandname + " has no suggestions for '" + current + "'!",CONSOLE_ERROR_COL)
								}
							else {
								debug_log("command is finished!",CONSOLE_WARNING_COL)
								}
							};break;
						case 1: { //try and substitute or show the only result
							var suggest = suggestions[| 0];
							if(string_char_at(suggest,1) != "<") {
								if(string_starts_with(suggest,current)) {
									//reconstruct the new pendingCommand
									array_insert(prevargs,0,commandname)
									array_push(prevargs,suggest);
									pendingCommand = string_concat(prevargs);
									}
								else {debug_log(commandname + " suggests: " + suggest,CONSOLE_BLUE_COL)}
								}
							else {debug_log(commandname + " suggests: " + suggest,CONSOLE_BLUE_COL)}
							};break;
						default: { //try and match the results 
							
							debug_log(commandname + " suggests: ",CONSOLE_BLUE_COL)
							for(var i = 0; i < numsuggs; i++) {
								debug_log("  " + suggestions[| i],CONSOLE_GENERIC_COL);
								}
							
							//match as much as possible, and if necessary regenerate the current pending command
							var newarg = string_find_matching_length(suggestions, current);
							if(newarg != current && newarg != "") {
								array_insert(prevargs,0,commandname)
								array_push(prevargs,newarg);
								pendingCommand = string_concat(prevargs);
								}
							};break;
						}
					}
				ds_list_destroy(suggestions);
				}
			}
		
	}#endregion
	
	#region submission
	if keyboard_check_pressed(vk_enter) {
		
		ds_list_insert(history,0,pendingCommand);
		debug_log("> "+pendingCommand,CONSOLE_GENERIC_COL);
		
		var commandName = string_eat(pendingCommand," ");
		var args = string_split(string_advance(pendingCommand," ")," ");
		//debug_log("found args " + string(array_length(args)) + ": " + string(args))
		dev_attempt_command_call(commandName,args)
		
		
		//if historyScroll != -1 && usedHistory {historyScroll++} //if you reused a command from the list, stay tracked at that location in history
		//else {historyScroll = -1;}
		
		historyScroll = -1;
		
		
		pendingCommand = "";
		usedHistory = false;
		} #endregion
	
	if keyboard_check_pressed(vk_escape) { //easy escape
		global.CONSOLE_OPEN = false;
		keyboard_string = "";
		}
	}
	


//automatic command execution, one at a time
if(!ds_queue_empty(global.CONSOLE_COMMAND_QUEUE)) {
	pendingCommand = ds_queue_dequeue(global.CONSOLE_COMMAND_QUEUE)
	ds_list_insert(history,0,pendingCommand);
	debug_log("> "+pendingCommand,CONSOLE_GENERIC_COL);
	
	var command = string_eat(pendingCommand," ");
	var args = string_split(string_advance(pendingCommand," ")," ");
	dev_attempt_command_call(command,args)
	
	historyScroll = -1;		
	pendingCommand = "";
	usedHistory = false;
	}