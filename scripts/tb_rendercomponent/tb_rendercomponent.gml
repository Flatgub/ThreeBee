#macro NO_SHADER -4

/// @function RenderComponent(parent,isStatic,isTransparent)
function RenderComponent(_parent,_static, _transparent) constructor{
	isStatic = _static;
	isTransparent = _transparent;

	renderDepth = 0;
	centerOffsetX = 0;
	centerOffsetY = 0;
	
	parentObject = _parent;

	if isStatic {ds_list_add(global.STATIC_RENDER_REQUESTS,self);}
	else {ds_list_add(global.DYNAMIC_RENDER_REQUESTS,self);}

	renderMode = pr_trianglelist;
	renderTexture = global.DEFAULT_TEXTURE;
	renderMatrix = global.DEFAULT_MATRIX;
	renderBuffer = global.DEFAULT_MODEL;
	customShader = undefined;
	customRenderFunction = undefined;

	dontRender = false;
	colour = c_white;
	alpha = 1;
	z = 0;
	ignoreDepth = false;
	ignoreFlags = false;
	
	/// @function update()
	/// @description transparent objects need to be depth sorted, so this calculates approximate depth
	static update = function() {
		if isTransparent {
			var distX = (parentObject.x+centerOffsetX) - global.CURRENT_CAMERA.x;
			var distY = (parentObject.y+centerOffsetY) - global.CURRENT_CAMERA.y;
			renderDepth = (distX*distX) + (distY*distY);
			} 
		}
	
	static cleanup = function() {
		if isStatic {ds_list_delete(global.STATIC_RENDER_REQUESTS,ds_list_find_index(global.STATIC_RENDER_REQUESTS,self));}
		else {ds_list_delete(global.DYNAMIC_RENDER_REQUESTS,ds_list_find_index(global.DYNAMIC_RENDER_REQUESTS,self));}
		}
	}