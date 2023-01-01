function __tb_devtools_imgui_camerawidget() {
	imguigml_begin_child("devtoolscamera",0,devToolsCameraSize,devToolsShowChildBorders,EImGui_WindowFlags.HorizontalScrollbar)
			
	//draw the devtools camera
	imguigml_surface(devToolsCamera.targetSurface)
			
	//rewind the imgui cursor to the start of the child, so we overlap the camera
	imguigml_set_cursor_pos(0,0)

	//use an invisible button to capture the drag
	imguigml_invisible_button("cameradragzone",devToolsCameraSize,devToolsCameraSize)
	devToolsCameraPanelIsHovered = imguigml_is_item_hovered()
	if(devToolsCameraPanelIsHovered && imguigml_is_mouse_dragging(0)) {
		var delta = imguigml_get_mouse_drag_delta()
		imguigml_reset_mouse_drag_delta()
				
		dtcAngle = angle_wrap(dtcAngle + delta[0]/2)
		dtcPitch = clamp(dtcPitch + delta[1]/2, -85, 85) min(+1,85)
		}

	imguigml_end_child()
	}

function __tb_devtools_imgui_texture_tooltip(_texture) {
	imguigml_begin_tooltip()
	imguigml_image(_texture,128,128)
	imguigml_end_tooltip()
	}

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
			imguigml_same_line()
			if(imguigml_button("Refresh")) {refresh_model_list();}
			imguigml_begin_child("",200,0,devToolsShowChildBorders,EImGui_WindowFlags.HorizontalScrollbar)
			imguigml_push_item_width(winsizeh)
			var ret = imguigml_list_box("",modelViewerSelectedModel,modelList,floor(winsizeh / 20))
			if(ret[0]) {
				update_selected_model(ret[1]);
				}
			imguigml_end_child()
			imguigml_end_child()
			
			imguigml_same_line()
			imguigml_begin_child("",devToolsCameraSize,0,devToolsShowChildBorders,EImGui_WindowFlags.HorizontalScrollbar)
			__tb_devtools_imgui_camerawidget()
			
			imguigml_begin_child("modelinfo",0,0,devToolsShowChildBorders,EImGui_WindowFlags.HorizontalScrollbar)
			imguigml_columns(2)
			imguigml_set_column_width(-1,100)
			
			imguigml_text("File")
			imguigml_next_column()
			imguigml_text(selectedModel.parentFile)
			imguigml_next_column()
			
			imguigml_text("Mesh Groups")
			imguigml_next_column()
			if(imguigml_selectable(array_length(selectedModel.mesh_groups))[0]) {
				show_meshgroup_viewer();
				}
			imguigml_next_column()
			
			imguigml_text("Frozen?")
			imguigml_next_column()
			imguigml_text(selectedModel.frozen ? "Yes" : "No")
			imguigml_next_column()
			
			imguigml_text("Texture")
			imguigml_next_column()
			if(selectedModel.texture == global.DEFAULT_TEXTURE) {imguigml_text_disabled("unassigned")}
			else {imguigml_text(selectedModel.textureName)}
			if(imguigml_is_item_hovered()) {
				__tb_devtools_imgui_texture_tooltip(selectedModel.texture)
				}
			imguigml_next_column()						
			
			
			
			imguigml_end_child()
			imguigml_end_child()
			
			
			
			showModelViewer = _modelViewWindow[1]
			if(showModelViewer == false) {
				close_model_viewer_window()
				}
			imguigml_end();
			}
		}
	}
	
/// @context {oThreeBeeDevTools}
function __tb_devtools_imgui_modelviewer_meshgroupviewer() {
	if(showMeshgroupWindow) {
		imguigml_set_next_window_pos(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), EImGui_Cond.Appearing,0,1)
		imguigml_set_next_window_size(332, 300, EImGui_Cond.Appearing)
		var _meshGroupWindow = imguigml_begin("MeshGroups",showMeshgroupWindow, EImGui_WindowFlags.NoCollapse | EImGui_WindowFlags.NoResize)
		if(_meshGroupWindow[0]) {
			var groups = selectedModel.mesh_groups
			
			imguigml_columns(3)
			
			imguigml_text("ID")
			imguigml_set_column_width(-1, 32)
			imguigml_next_column()
			imguigml_set_column_width(-1, 200)
			imguigml_text("Texture")
			imguigml_next_column()
			imguigml_set_column_width(-1, 100)
			imguigml_next_column()
			imguigml_separator()
			
			for(var i = 0; i < array_length(groups); i++) {
				var group = groups[i];
				//column 1, index
				imguigml_text(string(i))
				imguigml_next_column()
				
				//column 2, texture
				if(group.texturename = "") {
					imguigml_text_disabled("default")
					if(imguigml_is_item_hovered()) {
						imguigml_set_tooltip("This group render using the base texture assigned to the model")
						}
					}
				else {
					//TEXTURE doesn't exist
					if(group.texture == undefined) {
						imguigml_text_colored(1,0,0,1,group.texturename)
						if(imguigml_is_item_hovered()) {
							imguigml_begin_tooltip()
							imguigml_text("The assigned texture \"")
							imguigml_same_line(0,0)
							imguigml_text_colored(1.0,1.0,0.4,1.0,group.texturename)
							imguigml_same_line(0,0)
							imguigml_text("\" isn't available.")
							imguigml_text("Either the name is incorrect or the texture isn't loaded.")
							imguigml_end_tooltip()
							}
						}
					//TEXTURE does exist
					else {
						imguigml_text(group.texturename)
						if(imguigml_is_item_hovered()) {
							__tb_devtools_imgui_texture_tooltip(group.texture)
							}
						}
					}
				imguigml_next_column()
				
				//column 3, ???
				imguigml_next_column()
				}
			
		
		
			if(_meshGroupWindow[1] == false || !imguigml_is_window_focused()) {
				close_meshgroup_viewer();
				}
			imguigml_end();
		}
	}
	}
	
function __tb_devtools_imgui_armatureviewer() {
	with(oThreeBeeDevTools) {
		var winsizew = 900;
		var winsizeh = window_get_height() - 100;
		imguigml_set_next_window_size(winsizew,winsizeh,EImGui_Cond.Once)
		var _armViewWindow = imguigml_begin("Armature Viewer",showArmatureViewer, EImGui_WindowFlags.NoCollapse);
		if(_armViewWindow[0]) {
			
			// SCROLLABLE ARMATURE SELECTOR LIST
			imguigml_begin_child("armatureselector",200,0,devToolsShowChildBorders)
			imguigml_text("All Armatures")
			imguigml_same_line()
			if(imguigml_button("Refresh")) {update_armature_list();}
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
			
			#region [ CAMERA AND ANIM CONTROLS ]
			imguigml_same_line()
			imguigml_begin_child("",devToolsCameraSize,0,devToolsShowChildBorders,EImGui_WindowFlags.HorizontalScrollbar)
			__tb_devtools_imgui_camerawidget()
			
			
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
			
			imguigml_text("AnimSpeed:")
			imguigml_same_line()
			imguigml_push_item_width(64)
			var ret = imguigml_input_float("##animspeed",animationSpeed,0,0.1,3)
			if(ret[0]) {armatureviewer_set_animation_speed(ret[1])};
			
			var ret =  imguigml_checkbox("Loop Animation",loopingSelectedAnimation)
			if(ret[0]) {armatureviewer_set_loopanim(ret[1])}
			
			ret = imguigml_checkbox("Show Skeleton",showArmatureSkeleton)
			if(ret[0]) {armatureviewer_set_showskeleton(ret[1])}
				
			imguigml_end_child()
			imguigml_end_child()
			#endregion
			
			
			/// RIGHT SIDE PANEL
			imguigml_same_line()
			imguigml_begin_child("rigmover",0,0,devToolsShowChildBorders,EImGui_WindowFlags.HorizontalScrollbar)
			
			imguigml_text("Position")
			imguigml_push_item_width(imguigml_get_content_region_avail_width())
			var ret = imguigml_drag_float3("##rigpos",armaturePos.x,armaturePos.y,armaturePos.z,0.5)
			if(ret[0]) {update_armature_pos(ret[1],ret[2],ret[3])}
			
			imguigml_text("Rotation")
			imguigml_push_item_width(imguigml_get_content_region_avail_width())
			var ret = imguigml_drag_float3("##rigrot",armatureRot.x,armatureRot.y,armatureRot.z,1.0,-359,359)
			if(ret[0]) {update_armature_rot(ret[1],ret[2],ret[3])}
			
			if(imguigml_button("Reset Pos/Rot")) {
				update_armature_pos(0,0,0)
				update_armature_rot(0,0,0)
				}
				
			imguigml_separator()
			
			imguigml_text(string("Cached Samples: {0}",array_length(armatureInst.activeAnimation.cachedSamples)))
			
			showArmatureViewer = _armViewWindow[1]
			if(showArmatureViewer == false) {
				close_armature_viewer_window()
				}
			imguigml_end();
			}
		}
	}