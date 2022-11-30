instance_create_depth(0, 0, depth-10, imgui);
imguigml_add_font_from_ttf("pixel04b24.ttf", 12.0);

#macro DEVTOOLS_MODELVIEW_VIEWID 7
#macro DEVTOOLS_MODELVIEW_RENDERLAYER 256

showDevTools = false;
devToolsShowChildBorders = false;


showModelViewer = false;


refreshModelList = function() {
	modelList = ds_map_keys_to_array(global.LOADED_MODELS)
	}

refreshModelList()

modelViewerSelectedModel = 0;

modelViewerSurfaceSize = 500;
modelViewerCamera = define_camera_perspective(DEVTOOLS_MODELVIEW_VIEWID,modelViewerSurfaceSize,modelViewerSurfaceSize,70,0.1,300,true,global.DEFAULT_BASIC_SHADER)
camera_use_surface(modelViewerCamera, true)
modelViewerCamera.renderLayerMode = TB_RenderLayerModes.ExludeOthers
modelViewerCamera.renderLayers = DEVTOOLS_MODELVIEW_RENDERLAYER
modelViewerCamera.x = -64; 
modelViewerCameraPanelIsHovered = false;

updateModelViewerCamera = function() {
	//face towards center
	modelViewerCamera.yaw = angle_wrap(mvcAngle + 180);
	modelViewerCamera.pitch = clamp(-mvcPitch,-89,89);
	
	var realdist = lengthdir_x(mvcZoom, mvcPitch);
	
	modelViewerCamera.x = mvcCenterX + lengthdir_x(realdist, mvcAngle);
	modelViewerCamera.y = mvcCenterY + lengthdir_y(realdist, mvcAngle);
	modelViewerCamera.z = mvcCenterZ -lengthdir_y(mvcZoom, mvcPitch);
	}

resetModelViewerCamera = function() {
	mvcCenterX = 0;
	mvcCenterY = 0;
	mvcCenterZ = 0;
	mvcZoom = 64;
	mvcPitch = 45;
	mvcAngle = 135;
	updateModelViewerCamera();
	}


updateSelectedModel = function(newSelection) {
	modelViewerSelectedModel = newSelection;
	var model = global.LOADED_MODELS[? modelList[modelViewerSelectedModel]];
	viewedModel.renderModel = model
	viewedModel.renderTexture = model.texture
	//texture = global.DEFAULT_TEXTURE
	}
	
resetModelViewerCamera();

modelViewerGrid = instance_create_layer(0,0,"Instances",oGridFloor)
modelViewerGrid.gridFloor.renderLayers = DEVTOOLS_MODELVIEW_RENDERLAYER

dev_register_command("tb_toggle_devtools", function(args) {
	showDevTools = !showDevTools
	debug_log("devtools " + (showDevTools ? "enabled" : "disabled"))
	}, 0, "toggles the devtools", "");
	

viewedModel = new ModelRenderComponent(id, global.DEFAULT_MODEL, false, false)
viewedModel.renderLayers = DEVTOOLS_MODELVIEW_RENDERLAYER

//rendcomp = new RenderComponent(id, false, false)
//rendcomp.renderTexture = sprite_get_texture(texWhite,0)
//rendcomp.renderLayers = DEVTOOLS_MODELVIEW_RENDERLAYER