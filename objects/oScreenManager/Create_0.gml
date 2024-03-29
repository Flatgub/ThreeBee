/// @description ScreenManager Create

#macro DEBUG_ENABLED true
#macro DEBUG_SHOW_LIGHTS false

recenterRequired = 0;
postFXPanel = undefined;

tb_init()

instance_create_depth(0,0,-10000,oDevConsole);

instance_create_layer(0,0,"Instances",oRenderer);

show_debug_overlay(false)

#macro mouseSensitivityBase 60
#macro mouseSensitivityScale 1

global.OBJA_IMPORT_VERBOSE = false;

global.AMBIENT_LIGHT_COLOUR = [0.25, 0.25, 0.25]

if(DEBUG_ENABLED) {
	instance_create_layer(0,0,"Instances",oThreeBeeDevTools);
	}
	
dev_register_command("tb_toggle_postfx", function(args) {
	if(global.POSTFX_SHADER == undefined) {
		debug_log("No postfx shader is in use.",c_red);
		return;
		}
		
	tb_set_postfx(!global.USE_POSTFX)
	debug_log("postfx " + (global.USE_POSTFX ? "enabled" : "disabled"))
	}, 0, "toggles the postfx pass", "");
	
dev_register_command("tb_guiscale", 
	function (args) {
		try {
			tb_scale_gui_layer(real(args[0]))
			}
		catch (e) {
			debug_log("argument must be 1 or 0!",CONSOLE_ERROR_COL);
			show_debug_message("caught :" + string(e));
			}
		},1, "enables freecam", "[bool]")
