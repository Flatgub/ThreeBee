function logger_log(_message) {
	debug_log(_message);
	show_debug_message("[LOG]: "+_message);
	}
	
function logger_warn(_message) {
	var alert = argument_count > 1 ? argument[1] : false;
	
	if(alert) {debug_alert(_message, CONSOLE_WARNING_COL);}
	else {debug_log(_message, CONSOLE_WARNING_COL);}
	
	show_debug_message("[WARN]: "+_message);
	}
	
function logger_error(_message) {
	var alert = argument_count > 1 ? argument[1] : false;
	
	if(alert) {debug_alert(_message, CONSOLE_ERROR_COL);}
	else {debug_log(_message, CONSOLE_ERROR_COL);}
	
	show_debug_message("[ERROR]: "+_message);
	}