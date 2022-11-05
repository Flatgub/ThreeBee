//allows LOGGER_VERBOSE to be set to true from any script, regardless of execution order
if(!variable_global_exists("LOGGER_VERBOSE")) {
	global.LOGGER_VERBOSE = false;
	}

/// @function logger_log(message)
/// @param	{string}	message		the message to log
/// @description		simultaniously prints the message to the debug log and the output stream
function logger_log(_message) {
	debug_log(_message);
	show_debug_message("[LOG]: "+_message);
	}

/// @function logger_log_verbose(message)
/// @param	{string}	message		the message to log
/// @description		simultaniously prints the message to the debug log and the output stream
function logger_log_verbose(_message) {
	if(global.LOGGER_VERBOSE = true) {
		debug_log(_message);
		show_debug_message("[LOG]: "+_message);
		}
	}

/// @function logger_warn(message, alert)
/// @param	{string}	message			the message to log
/// @param	{bool}		[alert=false]	optional, whether or not the debug console should be forced open by this message
function logger_warn(_message) {
	var alert = argument_count > 1 ? argument[1] : false;
	
	if(alert) {debug_alert(_message, CONSOLE_WARNING_COL);}
	else {debug_log(_message, CONSOLE_WARNING_COL);}
	
	show_debug_message("[WARN]: "+_message);
	}

/// @function logger_error(message, alert)
/// @param	{string}	message			the message to log
/// @param	{bool}		[alert=false]	optional, whether or not the debug console should be forced open by this message
function logger_error(_message) {
	var alert = argument_count > 1 ? argument[1] : false;
	
	if(alert) {debug_alert(_message, CONSOLE_ERROR_COL);}
	else {debug_log(_message, CONSOLE_ERROR_COL);}
	
	show_debug_message("[ERROR]: "+_message);
	}