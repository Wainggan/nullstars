
function game_render_blendmode_set(_mode) {
	shader_set(_mode)
	texture_set_stage(shader_get_sampler_index(_mode, "u_destination"), surface_get_texture(render.surf_app))
}
function game_render_blendmode_reset() {
	shader_reset()
}

function game_render_refresh() {
	var _surf = surface_get_target()
	surface_set_target(render.surf_app)
	draw_clear_alpha(c_black, 0)
	draw_surface(_surf, 0, 0)
	surface_reset_target()
}

function game_render_set_scale(_scale) {
	window_set_size(WIDTH * _scale, HEIGHT * _scale);
}
function game_render_set_fullscreen(_enable) {
	window_set_fullscreen(_enable);
}


function Mode(_init) constructor {
	
	side_0 = _init;
	side_1 = _init;
	progress = 1;
	speed = 1;
	
	static update = function() {
		progress = clamp(progress + speed, 0, 1);
	};
	
	static set = function(_name, _speed = 0.01) {
		
		if _name == side_0 {
			speed = -_speed;
		} else if _name == side_1 {
			speed = _speed;
		} else{
			side_0 = side_1;
			side_1 = _name;
			progress = 0;
			speed = _speed;
		}
		
	};
	
	__return = {
		current: undefined,
		target: undefined,
		progress: undefined,
	};
	
	static get = function() {
		__return.current = side_0;
		__return.target = side_1;
		__return.progress = progress
		return __return;
	};
	
}
