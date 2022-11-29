if(showDevTools && imguigml_ready()) {
	//header bar
	if(imguigml_begin_main_menu_bar()) {
		
		//FILE
		if(imguigml_begin_menu("File")) {
			if(imguigml_menu_item("Exit")) {game_end();}
			imguigml_end_menu()
			}
			
		//TOOLS
		if(imguigml_begin_menu("Tools")) {
			if(imguigml_menu_item("Model Viewer")) {
				showModelViewer = true;
				refreshModelList()
				}
			imguigml_end_menu()
			}
		
		imguigml_end_main_menu_bar()
		}
		
		
	if(showModelViewer) {
		var winsizew = 760;
		var winsizeh = window_get_height() - 100;
		imguigml_set_next_window_size(winsizew,winsizeh,EImGui_Cond.Once)
		var _modelViewWindow = imguigml_begin("Model Viewer",showModelViewer, EImGui_WindowFlags.NoCollapse);
		if(_modelViewWindow[0]) {
			
						
			imguigml_begin_child("modelselector",200,0,devToolsShowChildBorders,EImGui_WindowFlags.HorizontalScrollbar)
			imguigml_text("All Models")
			imguigml_push_item_width(winsizeh)
			var ret = imguigml_list_box("",modelViewerSelectedModel,modelList,floor(winsizeh / 20))
			if(ret[0]) {
				updateSelectedModel(ret[1]);
				}
			imguigml_end_child()
			
			imguigml_same_line()
			imguigml_begin_child("modelview",0,0,devToolsShowChildBorders,EImGui_WindowFlags.HorizontalScrollbar)
			bleb = imguigml_get_content_region_avail_width()
			
			imguigml_surface(modelViewerCamera.targetSurface)
			modelViewerCameraPanelIsHovered = imguigml_is_item_hovered()
			
			imguigml_end_child()
			
			showModelViewer = _modelViewWindow[1]
			imguigml_end();
			}
		
		//if(ImGuiGML.WantCaptureMouse)
		}
		else  {
			modelViewerCameraPanelIsHovered = false
		}
	}
	
if(keyboard_check_pressed(ord("J"))) {
	devToolsShowChildBorders = !devToolsShowChildBorders
	}
	
if(modelViewerCameraPanelIsHovered) {
	if(keyboard_check(vk_left)) {mvcAngle = angle_wrap(mvcAngle+1)}
	if(keyboard_check(vk_right)) {mvcAngle = angle_wrap(mvcAngle-1)}
	if(keyboard_check(vk_up)) {mvcPitch = min(mvcPitch+1,85)}
	if(keyboard_check(vk_down)) {mvcPitch = max(mvcPitch-1,-85)}
	if(mouse_wheel_up()) {mvcZoom = max(mvcZoom-2,2)}
	if(mouse_wheel_down()) {mvcZoom += 2}
	
	updateModelViewerCamera()
	}