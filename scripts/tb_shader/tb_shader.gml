function TBShader() constructor {
	shader = undefined;
	
	shader_use = function() {
		logger_warn("shader " + instanceof(self) + " has no shader_use implementation",true)
		}
		
	hasPerComponentUniforms = false;
	
	update_uniforms = function() {
		logger_warn("shader " + instanceof(self) + " has hasPerComponentUniforms set but lacks an update_uniforms implementation",true)
		}
	}