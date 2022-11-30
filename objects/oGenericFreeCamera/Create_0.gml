/// @description GenericFreeCam Create

z = 16;
x = 0;
y = 0;

horizontalAcceleration = 0.2;
maxHorizontalSpeed = 1;

verticalAcceleration = 0.05;
maxVerticalSpeed = 1;

movementFreedom = true;

xSpeed = 0;
ySpeed = 0;
zSpeed = 0;
subX = 0;
subY = 0;
subZ = 0;

mouseLock = false;

thisCamera = define_camera_perspective(0,global.WINDOW_WIDTH,global.WINDOW_HEIGHT,58,0.1,320,true,new RetroShader_Lit());
audio_listener_bind_to_camera(thisCamera)

thisCamera.lightingEnabled = true;


thisCamera.yaw = 180;
facingDirection = 0;

window_mouse_set(global.SCREEN_CENTER_X,global.SCREEN_CENTER_Y);