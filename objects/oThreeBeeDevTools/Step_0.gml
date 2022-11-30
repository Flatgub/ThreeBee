if(showDevTools && imguigml_ready()) {
	//header bar
	if(imguigml_begin_main_menu_bar()) {
		
		//FILE
		if(imguigml_begin_menu("File")) {
			if(imguigml_menu_item("Import Model")) {
				var file = get_open_filename("*.obj","");
				if(file != "") {model_load_obj(file, undefined, true)}
				}
				
			if(imguigml_menu_item("Import Armature")) {
				var file = get_open_filename("*.obja","");
				if(file != "") {obja_load(file)}
				}
				
			imguigml_separator()
			if(imguigml_menu_item("Exit")) {game_end();}
			imguigml_end_menu()
			}
			
		//TOOLS
		if(imguigml_begin_menu("Tools")) {
			if(imguigml_menu_item("Model Viewer")) {
				//make sure no other window is using the dev camera
				if(devToolsCamera != undefined) {close_tool_windows()}
				open_model_viewer_window();
				}
				
			if(imguigml_menu_item("Armature Viewer")) {
				//make sure no other window is using the dev camera
				if(devToolsCamera != undefined) {close_tool_windows()}
				open_armature_viewer_window();
				}
			imguigml_end_menu()
			}
		
		imguigml_end_main_menu_bar()
		}
		
		
	if(showModelViewer) {__tb_devtools_imgui_modelviewer()}
	else if(showArmatureViewer) {
		__tb_devtools_imgui_armatureviewer()
		if(playingSelectedAnimation && armatureInst != undefined) {
			armatureInst.update();
			if(armatureInst.animationFinished && !armatureInst.animationLoop) {
				playingSelectedAnimation = false;
				}
			}
		}
	else {devToolsCameraPanelIsHovered = false}
	}
	
if(keyboard_check_pressed(ord("J"))) {
	devToolsShowChildBorders = !devToolsShowChildBorders
	}
	
if(devToolsCameraPanelIsHovered) {
	if(keyboard_check(vk_left)) {dtcAngle = angle_wrap(dtcAngle+1)}
	if(keyboard_check(vk_right)) {dtcAngle = angle_wrap(dtcAngle-1)}
	if(keyboard_check(vk_up)) {dtcPitch = min(dtcPitch+1,85)}
	if(keyboard_check(vk_down)) {dtcPitch = max(dtcPitch-1,-85)}
	if(mouse_wheel_up()) {dtcZoom = max(dtcZoom-2,2)}
	if(mouse_wheel_down()) {dtcZoom += 2}
	
	update_dev_tools_camera()
	}