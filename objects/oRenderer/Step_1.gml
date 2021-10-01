/// @description Renderer BeginStep

ds_list_clear(depthlist);
global.swaps = 0;



global.CURRENT_CAMERA = global.VIEW_CAMERA_MAP[? 0];

pulse++;
if pulse > 360 {pulse = 0;}