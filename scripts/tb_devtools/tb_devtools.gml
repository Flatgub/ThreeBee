

function __tb_devtools_imgui_modelviewer() {
	with(oThreeBeeDevTools) {
		var winsizew = 760;
		var winsizeh = window_get_height() - 100;
		imguigml_set_next_window_size(winsizew,winsizeh,EImGui_Cond.Once)
		var _modelViewWindow = imguigml_begin("Model Viewer",showModelViewer, EImGui_WindowFlags.NoCollapse);
		if(_modelViewWindow[0]) {
			
			// SCROLLABLE MODEL SELECTOR LIST
			imguigml_begin_child("modelselector",200,0,devToolsShowChildBorders)
			imguigml_text("All Models")
			imguigml_begin_child("",200,0,devToolsShowChildBorders,EImGui_WindowFlags.HorizontalScrollbar)
			imguigml_push_item_width(winsizeh)
			var ret = imguigml_list_box("",modelViewerSelectedModel,modelList,floor(winsizeh / 20))
			if(ret[0]) {
				update_selected_model(ret[1]);
				}
			imguigml_end_child()
			imguigml_end_child()
			
			imguigml_same_line()
			imguigml_begin_child("modelview",0,0,devToolsShowChildBorders,EImGui_WindowFlags.HorizontalScrollbar)
			
			imguigml_surface(devToolsCamera.targetSurface)
			devToolsCameraPanelIsHovered = imguigml_is_item_hovered()
			
			imguigml_end_child()
			
			showModelViewer = _modelViewWindow[1]
			if(showModelViewer == false) {
				close_model_viewer_window()
				}
			imguigml_end();
			}
		}
	}
	
function __tb_devtools_imgui_armatureviewer() {
	with(oThreeBeeDevTools) {
		var winsizew = 760;
		var winsizeh = window_get_height() - 100;
		imguigml_set_next_window_size(winsizew,winsizeh,EImGui_Cond.Once)
		var _armViewWindow = imguigml_begin("Armature Viewer",showArmatureViewer, EImGui_WindowFlags.NoCollapse);
		if(_armViewWindow[0]) {
			
			// SCROLLABLE ARMATURE SELECTOR LIST
			imguigml_begin_child("armatureselector",200,0,devToolsShowChildBorders)
			imguigml_text("All Armatures")
			imguigml_begin_child("",200,(winsizeh/3)*2,devToolsShowChildBorders,EImGui_WindowFlags.HorizontalScrollbar)
			imguigml_push_item_width(winsizeh)
			var ret = imguigml_list_box("",armatureViewerSelectedArmature,armatureList,24)
			if(ret[0]) {
				update_selected_armature(ret[1]);
				}
			imguigml_end_child()
			
			imguigml_text("Animations")
			imguigml_begin_child("animationBox",200,150,devToolsShowChildBorders,EImGui_WindowFlags.HorizontalScrollbar)
			imguigml_push_item_width(winsizeh)
			var ret = imguigml_list_box("",selectedAnimationIndex,animationList,7)
			if(ret[0]) {
				update_selected_animation(ret[1]);
				}
			imguigml_end_child()
			imguigml_end_child()
			
			//DEV TOOLS CAMERA
			imguigml_same_line()
			imguigml_begin_child("",0,0,devToolsShowChildBorders,EImGui_WindowFlags.HorizontalScrollbar)
			imguigml_begin_child("armatureview",0,devToolsCameraSize,devToolsShowChildBorders,EImGui_WindowFlags.HorizontalScrollbar)
			
			imguigml_surface(devToolsCamera.targetSurface)
			devToolsCameraPanelIsHovered = imguigml_is_item_hovered()
			imguigml_end_child()
			
			//ANIMATION CONTROLS
			imguigml_begin_child("animationcontrols",0,0,devToolsShowChildBorders,EImGui_WindowFlags.HorizontalScrollbar)
			
			#region [ ANIM CONTROL BUTTONS ]
			// JUMP TO START BUTTON
			imguigml_same_line()
			icon = avIconTextureUVs.jump_to_start;
			imguigml_push_id("jumptostart")
			if(imguigml_image_button(avIconTexture,16,16,icon[0],icon[1],icon[2],icon[3])) {
				armatureviewer_jump_to_start_button()
				}
			imguigml_pop_id()
			
			// FRAME REWIND BUTTON
			imguigml_same_line()
			imguigml_push_id("framerewind")
			var icon = avIconTextureUVs.frame_rewind;
			if(imguigml_image_button(avIconTexture,16,16,icon[0],icon[1],icon[2],icon[3])) {
				armatureviewer_frame_rewind_button()
				}
			imguigml_pop_id()
			
			// PLAY/PAUSE BUTTON
			imguigml_same_line()
			if(playingSelectedAnimation) {icon = avIconTextureUVs.pause;}
			else {icon = avIconTextureUVs.play;}
			
			imguigml_push_id("playpause")
			if(imguigml_image_button(avIconTexture,16,16,icon[0],icon[1],icon[2],icon[3])) {
				armatureviewer_play_button()
				}
			imguigml_pop_id()
			
			
			// FRAME ADVANCE BUTTON
			imguigml_same_line()
			imguigml_push_id("frameadvance")
			icon = avIconTextureUVs.frame_advance;
			if(imguigml_image_button(avIconTexture,16,16,icon[0],icon[1],icon[2],icon[3])) {
				armatureviewer_frame_advance_button()
				}
			imguigml_pop_id()
			
			// JUMP TO END BUTTON
			imguigml_same_line()
			icon = avIconTextureUVs.jump_to_end;
			imguigml_push_id("jumptoend")
			if(imguigml_image_button(avIconTexture,16,16,icon[0],icon[1],icon[2],icon[3])) {
				armatureviewer_jump_to_end_button()
				}
			imguigml_pop_id()
			#endregion
			
			imguigml_same_line()
			imguigml_text(string("Frame: {0} / {1}",armatureInst.animationFrame, armatureInst.activeAnimation.length))
			
			var ret =  imguigml_checkbox("Loop Animation",loopingSelectedAnimation)
			if(ret[0]) {armatureviewer_set_loopanim(ret[1])}
			
			ret = imguigml_checkbox("Show Skeleton",showArmatureSkeleton)
			if(ret[0]) {armatureviewer_set_showskeleton(ret[1])}
				
			
				
			imguigml_end_child()
			imguigml_end_child()
			
			showArmatureViewer = _armViewWindow[1]
			if(showArmatureViewer == false) {
				close_armature_viewer_window()
				}
			imguigml_end();
			}
		}
	}