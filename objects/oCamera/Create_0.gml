/// @description Camera Instance Creation

z = 16; 

yaw = 0;
pitch = 0;
view = -1;

aspect = 0;

viewWidth = 0;
viewHeight = 0;

zNear = 0;
zFar = 0;

fov = 0;

enabled = true;

gmCamera = /*#cast*/ -1; ///@is {camera}

numOfLights = 0;
activeLightPositions = [];
activeLightColours = [];
activeLightStrengths = [];
lightingEnabled = false;

cameraShader = undefined; ///@is {TBShader?}
cameraShaderMandatory = false; 

targetSurface = undefined;
targetSurfaceNoBG = false;

renderLayerMode = TB_RenderLayerModes.Ignore;
renderLayers = 0;

cameraMatrix = matrix_build_identity();
projectionMatrix = matrix_build_identity();
projectionMode = TB_CameraModes.Perspective;

_dead = false;

function make_main() {
	global.MAIN_CAMERA = id;
	}