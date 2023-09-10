// SEE TBMeshImportSettings FOR DETAILS
#macro TB_OBJ_LOAD_DEFAULT_FREEZE_ON_LOAD false
#macro TB_OBJ_LOAD_DEFAULT_PRESERVE_BUFFER false

enum TB_CameraModes {
	Perspective,
	Orthographic
	}

enum TB_RenderLayerModes {
	Ignore,			//render all layers
	ExcludeLayers,	//render every layer except those which match
	ExludeOthers	//only render layers which match
	}

#macro RENDER_LAYER_DEFAULT 0