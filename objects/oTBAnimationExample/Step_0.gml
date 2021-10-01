/// @description Animation Example Step

if(global.CONSOLE_OPEN) {exit}


if(armature != undefined) {

	if(armInst.activeAnimation != undefined) {
		if(armInst.animationLoop == false && armInst.animationFinished) {
				armInst.restart_animation()
				}
		
		if(keyboard_check_pressed(ord("P"))) {
			if(armInst.animationLoop == false && armInst.animationFinished) {
				armInst.restart_animation()
				}
			else {
				paused = !paused
				}	
				
			}

		if(keyboard_check_pressed(vk_home)) {armInst.animationFrame = 0};


		if(!paused) {
			armInst.update();
		 }
		else {
			var moved = false;
			if(mouse_wheel_up()) {armInst.animationFrame++;moved=true}
			if(mouse_wheel_down()) {armInst.animationFrame--;moved=true}
			if(keyboard_check(vk_left)) {armInst.animationFrame -= armInst.animationSpeed;moved=true}
			if(keyboard_check(vk_right)) {armInst.animationFrame += armInst.animationSpeed;moved=true}
			if(armInst.animationFrame > armInst.activeAnimation.length) {armInst.animationFrame = 0;moved=true}
			if(armInst.animationFrame < 0) {armInst.animationFrame = armInst.activeAnimation.length;moved=true}			
			armInst.update_animation_sample();
			}
		
			
		
		}
	
	

		
	
}