instance_create_depth(0, 0, depth-10, imgui);
imguigml_add_font_from_ttf("pixel04b24.ttf", 12.0);

#macro DEVTOOLS_DEVCAMERA_VIEWID 7
#macro DEVTOOLS_DEVCAMERA_RENDERLAYER 256

devToolsShowChildBorders = false;

showDevTools = true;
showModelViewer = false;
showArmatureViewer = false;

devToolsCameraPanelIsHovered = false;

#region [ SHARED ]
devToolsCameraSize = 500; //width and height of the dev tools camera
devToolsCamera = undefined; //camera reserved for dev tool windows
devToolsGrid = undefined; //gridfloor used in dev tool visualisations

/// @function create_dev_tools_camera()
/// @description start up the dev tools visualizer camera.
///				 only one of these can exist at a time to minimise how many GMCameras we have to use
create_dev_tools_camera = function() {
	devToolsCamera = define_camera_perspective(DEVTOOLS_DEVCAMERA_VIEWID,devToolsCameraSize,devToolsCameraSize,70,0.1,1000,true,global.DEFAULT_BASIC_SHADER)
	camera_use_surface(devToolsCamera, true)
	devToolsCamera.renderLayerMode = TB_RenderLayerModes.ExludeOthers
	devToolsCamera.renderLayers = DEVTOOLS_DEVCAMERA_RENDERLAYER
	
	reset_dev_tools_camera();
	}

/// @function destroy_dev_tools_camera()
/// @description clean up and destroy the dev tools camera
destroy_dev_tools_camera = function() {
	delete_camera(devToolsCamera)
	devToolsCamera = undefined;
	}
	
/// @function update_dev_tools_camera()
/// @description update the position and rotation of the dev tools camera (orbital pan)
update_dev_tools_camera = function() {
	//face towards center
	devToolsCamera.yaw = angle_wrap(dtcAngle + 180);
	devToolsCamera.pitch = clamp(-dtcPitch,-89,89);
	
	var realdist = lengthdir_x(dtcZoom, dtcPitch);
	
	devToolsCamera.x = dtcCenterX + lengthdir_x(realdist, dtcAngle);
	devToolsCamera.y = dtcCenterY + lengthdir_y(realdist, dtcAngle);
	devToolsCamera.z = dtcCenterZ -lengthdir_y(dtcZoom, dtcPitch);
	}

/// @function reset_dev_tools_camera()
/// @description reset the dev tools camera to the default position and rotation
reset_dev_tools_camera = function() {
	dtcCenterX = 0;
	dtcCenterY = 0;
	dtcCenterZ = 0;
	dtcZoom = 64;
	dtcPitch = 45;
	dtcAngle = 135;
	update_dev_tools_camera();
	}

/// @function show_dev_tools_grid()
/// @description create the gridfloor visible through the dev tools camera
show_dev_tools_grid = function() {
	devToolsGrid = instance_create_layer(0,0,"Instances",oGridFloor)
	devToolsGrid.gridFloor.renderLayers = DEVTOOLS_DEVCAMERA_RENDERLAYER
	}

/// @function hide_dev_tools_grid()
/// @description destroy the dev tools grid
hide_dev_tools_grid = function() {
	instance_destroy(devToolsGrid)
	devToolsGrid = undefined;
	}

/// @function close_tool_windows()
/// @description closes any open dev tool windows
close_tool_windows = function() {
	if(showModelViewer) {close_model_viewer_window()}
	if(showArmatureViewer) {close_armature_viewer_window()}
	}

#endregion

#region [ MODEL VIEWER ]
viewedModel = undefined;
modelViewerSelectedModel = 0;
modelList = [];

/// opens the model viewer window (get model list + create camera + create model)
open_model_viewer_window = function() {
	showModelViewer = true;
	refresh_model_list();
	
	create_dev_tools_camera();
	
	viewedModel = new ModelRenderComponent(id, global.DEFAULT_MODEL, false, false)
	viewedModel.renderLayers = DEVTOOLS_DEVCAMERA_RENDERLAYER
	
	show_dev_tools_grid();
	}
	
/// closes the model viewer window (free the camera + free the model)
close_model_viewer_window = function() {
	showModelViewer = false;
	destroy_dev_tools_camera()
	
	viewedModel.cleanup();	
	viewedModel = undefined;
	
	hide_dev_tools_grid()
	}

/// @function refresh_model_list()
/// @description	update the list of models shown in the model viewer
refresh_model_list = function() {
	modelList = ds_map_keys_to_array(global.LOADED_MODELS)
	array_sort(modelList,false)
	}

update_selected_model = function(newSelection) {
	modelViewerSelectedModel = newSelection;
	var model = global.LOADED_MODELS[? modelList[modelViewerSelectedModel]];
	viewedModel.renderModel = model
	viewedModel.renderTexture = model.texture
	if(model.texture == global.DEFAULT_TEXTURE) {
		viewedModel.renderTexture = sprite_get_texture(texWhite,0)
		}
	//texture = global.DEFAULT_TEXTURE
	}
#endregion

#region [ ARMATURE VIEWER ]
armatureViewerSelectedArmature = 0;
armatureList = [];
selectedArmature = undefined;
animationList = []
selectedAnimationIndex = 0;
selectedAnimation = undefined;
playingSelectedAnimation = false;
loopingSelectedAnimation = false;
animationSpeed = 1

showArmatureSkeleton = false;
animationSkeletonRenderer = undefined;

armatureInst = undefined;
armatureRenderer = undefined;

avIconTexture = sprite_get_texture(sprDevToolsButtons,0);
avIconTextureUVs = {}
avIconTextureUVs.play = sprite_get_uvs(sprDevToolsButtons, 0);
avIconTextureUVs.pause = sprite_get_uvs(sprDevToolsButtons, 1);
avIconTextureUVs.frame_advance = sprite_get_uvs(sprDevToolsButtons, 2);
avIconTextureUVs.frame_rewind = sprite_get_uvs(sprDevToolsButtons, 3);
avIconTextureUVs.jump_to_end = sprite_get_uvs(sprDevToolsButtons, 4);
avIconTextureUVs.jump_to_start = sprite_get_uvs(sprDevToolsButtons, 5);


/// @function open_armature_viewer_window()
/// @description	open the armature viewer tool window
open_armature_viewer_window = function() {
	showArmatureViewer = true;
	
	update_armature_list();
	
	create_dev_tools_camera();
	
	update_selected_armature(0);
		
	show_dev_tools_grid();
	}

/// @function close_armature_viewer_window()
/// @description	close the armature viewer tool window
close_armature_viewer_window = function() {
	showArmatureViewer = false;
	destroy_dev_tools_camera()
	
	armatureRenderer.cleanup();
	animationSkeletonRenderer.cleanup();
	
	delete armatureRenderer;
	delete animationSkeletonRenderer;
	delete armatureInst;
	
	hide_dev_tools_grid()
	}
	
/// @function update_armature_list() 
update_armature_list = function() {
	armatureList = ds_map_keys_to_array(global.LOADED_ARMATURES)
	array_sort(armatureList,false)
	}

/// @function update_selected_armature(newSelection) 
update_selected_armature = function(newSelection) {
	// cleanup last armature
	if(armatureInst != undefined) {
		armatureRenderer.cleanup();
		animationSkeletonRenderer.cleanup();
		delete armatureRenderer;
		delete animationSkeletonRenderer;
		delete armatureInst;
		}
	
	armatureViewerSelectedArmature = newSelection;
	selectedArmature = global.LOADED_ARMATURES[? armatureList[armatureViewerSelectedArmature]];
	
	armatureInst = new OBJA_Armature_Instance(selectedArmature)
	armatureRenderer = new OBJA_ArmatureRenderComponent(id, armatureInst)
	armatureRenderer.renderLayers = DEVTOOLS_DEVCAMERA_RENDERLAYER;
	
	animationSkeletonRenderer = new OBJA_SkeletonRenderComponent(id, armatureInst)
	animationSkeletonRenderer.customShader = global.DEFAULT_BASIC_SHADER 
	animationSkeletonRenderer.renderLayers = DEVTOOLS_DEVCAMERA_RENDERLAYER;
	animationSkeletonRenderer.dontRender = !showArmatureSkeleton;
	
	if(selectedArmature != undefined) {
		animationList = selectedArmature.list_all_animations();
		update_selected_animation(0);
		}
	else {
		selectedAnimation = undefined;
		}
	}
	
/// @function update_selected_animation(newSelection) 
update_selected_animation = function(newSelection) {
	selectedAnimationIndex = newSelection;
	var animationName = animationList[selectedAnimationIndex]
	selectedAnimation = selectedArmature.get_animation(animationName);
	armatureInst.set_animation(animationName, loopingSelectedAnimation);
	armatureInst.animationSpeed = animationSpeed;
	}
	
/// @function armatureviewer_play_button
/// playpause button
armatureviewer_play_button = function() {
	if(!playingSelectedAnimation && armatureInst.animationFinished) {
		armatureInst.restart_animation()
		}
		
	playingSelectedAnimation = !playingSelectedAnimation
	}
	
armatureviewer_frame_rewind_button = function() {
	armatureInst.animation_rewind_frame();
	}
	
armatureviewer_frame_advance_button = function() {
	armatureInst.animation_advance_frame();
	}
	
armatureviewer_jump_to_start_button = function() {
	playingSelectedAnimation = false;
	armatureInst.set_animation_frame(0)
	}
	
armatureviewer_jump_to_end_button = function() {
	playingSelectedAnimation = false;
	armatureInst.set_animation_frame(armatureInst.activeAnimation.length)
	}
	
armatureviewer_set_loopanim = function(value) {
	loopingSelectedAnimation = value;
	armatureInst.animationLoop = loopingSelectedAnimation;
	}
	
armatureviewer_set_showskeleton = function(enable) {
	showArmatureSkeleton = enable
	animationSkeletonRenderer.dontRender = !showArmatureSkeleton;
	}

armatureviewer_set_animation_speed = function(value) {
	animationSpeed = value;
	armatureInst.animationSpeed = animationSpeed;
	}
		
#endregion


dev_register_command("tb_toggle_devtools", function(args) {
	showDevTools = !showDevTools
	debug_log("devtools " + (showDevTools ? "enabled" : "disabled"))
	}, 0, "toggles the devtools", "");
	







