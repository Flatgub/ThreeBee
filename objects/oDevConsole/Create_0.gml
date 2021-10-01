/// @description DevConsole Init

context = __dev_get_context();
context.instance = id; //update the context with out existance;

global.__console_lines = ds_list_create();

commandNames = context.commandNames;
commands = context.commands;

consoleScroll = 0;
global.CONSOLE_OPEN = false;
global.CONSOLE_KEY = 192;

consoleFont = fntConsole;

consoleHeightRatio = 2/3;
consoleHeight = round(global.VIEWPORT_HEIGHT * consoleHeightRatio);
consoleWidth = global.VIEWPORT_WIDTH;


pendingCommand = "";

backspaceTime = 0;
backspaceThresh = 30;
backspace = false;

history = ds_list_create();
historyScroll = -1;
usedHistory = false;

draw_set_font(consoleFont)
fontHeight = string_height("AaYy")-2 //??
FONT_YOFFSET = 2;
barHeight = 2;

global.CONSOLE_COMMAND_QUEUE = ds_queue_create();

consoleSurface = new SurfacePanel(display_get_gui_width(), display_get_gui_height())
	
function matchAsMuchAsPossible(matchfor, matchagainst) {
	var firstletter = string_char_at(matchagainst[| 0],1)
	var allmatch = true;
	for(var i = 0; i <ds_list_size(matchagainst); i++) {
		if(allmatch && string_char_at(matchagainst[| i],1) != firstletter) {
			allmatch = false;
			}
		}
	if(allmatch) {
		matchfor = string_longest_substring(matchagainst)
		}
	return matchfor;
	}
	
	
	
/// @function ds_list_retain_if(list, predicate, [context])
/// @param	{list}		list		the list to iterate over
/// @param	{method}	predicate	a function which takes a single argument and returns a boolean (or two arguments if using context)
/// @param	[struct]	context		an optional struct which contains context variables for the predicate
/// @descrition	executes the predicate function on each element in the list, and removes any 
///		where the predicate returns false
ds_list_retain_if = function(_list, _predicate) {
	var context = argument_count == 3 ? argument[2] : undefined;
	for(var i = ds_list_size(_list)-1; i >= 0; i--) {
		var element = _list[| i];
		if(!_predicate(element, context)) {
			ds_list_delete(_list,i);
			}
		}
	}