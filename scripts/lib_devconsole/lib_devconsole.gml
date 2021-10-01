#macro CONSOLE_BGCOL_A $080808
#macro CONSOLE_BGCOL_B $101010

#macro CONSOLE_ERROR_COL $0000FF
#macro CONSOLE_WARNING_COL $00AAFF
#macro CONSOLE_GENERIC_COL $FFFFFF
#macro CONSOLE_BLUE_COL $ffff88
#macro CONSOLE_DK_BLUE_COL $ff8888



// the dev context contains information which is necessary between scripts for
// things like command defintion before room start, the first time its referenced
// might not be here, so we need to be able to build it on demand at first request
function __dev_get_context() {
	//return the context if we've already defined it once
	static context = {
		commandNames  : ds_list_create(),	       //list of all known command names
		commands	  : ds_map_create(),	       //map of all command structs
		instance	  : undefined			       //the current instance ID of the devconsole (intially no instance)
		}
	return context;
	}

/// @function debug_log(message,[col])
/// @param	{string}	message		the text to add to the console
/// @param	{colour}	[colour]	the optional colour to show in the editor
/// @description	adds the given message to the developer console;	
function debug_log(_message) {
	var col = argument_count > 1 ? argument[1] : undefined;
	if is_undefined(col) {col = CONSOLE_GENERIC_COL;}
	
	ds_list_add(global.__console_lines, {text : _message, colour : col});
	}	
	
/// @function debug_alert(message,[col])
/// @param	{string}	message		the text to add to the console
/// @param	{colour}	[colour]	the optional colour to show in the editor
/// @description	same as debug_log, but also forces the console open if it wasn't already
function debug_alert(_message) {
	var col = argument_count > 1 ? argument[1] : undefined;
	if is_undefined(col) {col = CONSOLE_GENERIC_COL;}
	
	debug_log(_message,col);
	if(DEBUG_ENABLED) {global.CONSOLE_OPEN = true;}
	
	}

/// @function dev_get_autocomplete(filter, [startswith])
/// @description	returns a list of all known command names which match the filter
/// @param {string}	filter		the substring to filter command names by the
/// @param {bool}	startswith	changes the matchmode from "contains" to "startswith"
function dev_get_autocomplete(_filter) {	
	var startswith = (argument_count == 2) ? argument[1] : false;
	var context = __dev_get_context();
	var results = ds_list_create()
		
	if(startswith) {//accept only strings starting with filter
		for(var i = 0; i < ds_list_size(context.commandNames); i++) {
			var name = context.commandNames[| i];
			if string_starts_with(name,_filter) {
				ds_list_add(results,name) 
				}
			}
		}
	else { //accept any string containing felter
		for(var i = 0; i < ds_list_size(context.commandNames); i++) {
			var name = context.commandNames[| i];
			if string_count(_filter,name) != 0 {
				ds_list_add(results,name) 
				}
			}
		}
	
	return results;
	}
	
/// @function dev_get_command(name)
/// @param	{string}	name		the name of the function to get
function dev_get_command(_name) {
	var context = __dev_get_context();
	if(!ds_map_exists(context.commands,_name)) {
		return undefined;
		}
	return context.commands[? _name];
	}
	
/// @function dev_attempt_command_call(commandName, args)
/// @param {string}	commandName		the name of the command to try and call
/// @param {array}	args			any provided arguments for the command
function dev_attempt_command_call(_commandName, _args) {
	var commandInfo = dev_get_command(_commandName);
	
	if(commandInfo == undefined) {
		debug_log("Unknown Command: " + _commandName, CONSOLE_ERROR_COL);
		return;
		}
		
	//incorrect arg count
	if(array_length(_args) < commandInfo.minArgs) {
		debug_log("USAGE: " + commandInfo.usage,CONSOLE_ERROR_COL)
		return;
	}
	
	//execute command method
	commandInfo.callback(_args);	
	}	
	
// container struct for information on commands
function DevCommand(_name, _callback, _argcount, _blurb, _usage) constructor {
	name = _name;
	callback = _callback;
	minArgs = _argcount;
	blurb = _blurb;
	usage = _name + " " + _usage;
	suggestionHelper = undefined;
	}

//NOTE: this might have to be included in the context
/// @function dev_register_command(name, callback, argcount, blurb, usage)
/// @param	{string}	name		the name of the command
/// @param	{method}	callback	the method to execute when the command is called
/// @param	{real}		argcount	the minimum number of required arguments
/// @param	{string}	blurb		a brief description of the function
/// @param	{string}	usage		the usage pattern for the command (e.g. name needed [ optional | otheroptional ])
function dev_register_command(_name, _callback, _argcount, _blurb, _usage) {
	var command = new DevCommand(_name, _callback, _argcount, _blurb, _usage);
	
	var context = __dev_get_context();
	ds_list_add(context.commandNames,_name);
	ds_map_add(context.commands,_name,command);
	}
// NOTE: command callbacks must take a single argument, the _args array, which contains strings and is at least as long as argcount
	
/// @function dev_register_suggestionhelper(name, callback)
/// @param	{string}	name		the name of the command
/// @param	{method}	callback	the method to execute when trying to calculate 
function dev_register_suggestionhelper(_name, _callback) {
	var context = __dev_get_context();
	if(!ds_map_exists(context.commands, _name)) {throw "tried to register a suggestion helper for command " + _name + " which doesn't exist";}
	var command = context.commands[? _name];
	if(!is_undefined(command.suggestionHelper)) {throw "tried to register a suggestion helper for command " + _name + " which already has one";}
	
	command.suggestionHelper = _callback;
	}
// NOTE: suggestionehelper callbacks take two arguments, 
//			the _prevargs array, which contains all previously completed args (which can be length zero or more)
//		 the suggestionehlper then needs to return a list of potential autocomplete solutions
//		 suggestions starting with < ("such as <integer> or <someArg>") are still shown but wont be tab-completed


var helpFunc = function(_args) {
	var filter = ""
	var context = __dev_get_context()
	
	if(array_length(_args) > 0) {filter = _args[0]}
	
	//select filter list
	var commandlist = (filter == "") ? context.commandNames : dev_get_autocomplete(filter);

	if ds_list_size(commandlist) == 0 {
		debug_log("No results for " + filter,CONSOLE_WARNING_COL);
		return;
		}

	if ds_list_size(commandlist) == 1 {
		var command = dev_get_command(commandlist[| 0]);
		debug_log("Help for '" + command.name + "'",CONSOLE_DK_BLUE_COL);
		var usage = command.usage;
		var blurb = command.blurb;
		debug_log("    " + usage,CONSOLE_BLUE_COL);
		debug_log("    " + blurb,CONSOLE_BLUE_COL);
		return;
		}

	for(var i = 0; i < ds_list_size(commandlist); i++) {
		ds_list_sort(commandlist,false);
		var command = dev_get_command(commandlist[| i]);
		var blurb = command.blurb;
		debug_log("  " + string_pad_right(command.name,22) + " - " + blurb,CONSOLE_BLUE_COL);
		}
	}
dev_register_command("help",helpFunc,0,"Shows a list of all commands and their arguments, with a possible filter","[filter]")