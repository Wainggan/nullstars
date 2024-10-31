
function game_background_get(_name) {
	
	switch _name {
		case "none":
			return new Background()
		case "glow":
			return new Background_Shader(shd_back_glow)
		case "boxes":
			return new Background_Shader(shd_back_boxes)
		case "judge":
			return new Background_Shader(shd_back_judge)
		case "space":
			return new Background_Shader(shd_back_space)
		case "soup":
			return new Background_Shader(shd_back_soup)
		case "blackhole":
			return new Background_Shader(shd_back_blackhole)
		case "clouds":
			return new Background_Clouds()
		case "city":
			return new Background_City()
	}
	
	return new Background()
	
}


function Background() constructor {
	
	static draw = function(_surface) {
		
		var _cam = game_camera_get()
		
		draw_sprite_ext(
			spr_pixel, 0, 
			0, 0, 
			_cam.w, _cam.h, 
			0, #000209, 1
		);
		
	}
	
}

function Background_Shader(_shd) : Background() constructor {
	
	shader = _shd
	
	static draw = function(_surface) {
		
		var _cam = game_camera_get()
		
		shader_set(shader);

		shader_set_uniform_f(shader_get_uniform(shader, "u_offset"), _cam.x / 4, _cam.y / 4);
		shader_set_uniform_f(shader_get_uniform(shader, "u_resolution"), _cam.w, _cam.h);
		shader_set_uniform_f(shader_get_uniform(shader, "u_time"), global.time / 60);

		draw_sprite_ext(
			spr_pixel, 0, 
			0, 0, 
			_cam.w, _cam.h, 
			0, c_white, 1
		);
		
		shader_reset()
		
	}
	
}

function Background_Clouds() : Background() constructor {
	
	static draw = function () {
		
		var _cam = game_camera_get()
		
		draw_sprite_ext(spr_pixel, 0, 0, 0, WIDTH, HEIGHT, 0, #1e1830, 1)
		
		var _dir = global.time / 60 * 3
		var _amount = 8
		var _len = 400
		var _x = WIDTH / 2, _y = -32
		var _col = merge_color(#ff1144, #4411ff, wave(0, 1, 24))
		
		draw_circle_outline(_x, _y, _len, 2, _col, 1)
		
		for (var i = 0; i < _amount; i++) {
			var _d = (_dir + i * 90 / _amount) % 90
			_d = power(_d / 3, 1.4)
			draw_line_sprite(
				_x, _y, 
				_x + lengthdir_x(_len, 270 - _d),
				_y + lengthdir_y(_len, 270 - _d),
				2, _col, 1
			)
			draw_line_sprite(
				_x, _y, 
				_x + lengthdir_x(_len, 270 + _d),
				_y + lengthdir_y(_len, 270 + _d),
				2, _col, 1
			)
		}
		
		draw_line_sprite(_x, _y, _x, _y + _len, 2, _col, 1)
		
		draw_sprite_tiled(spr_background_star, 1, -_cam.x / 12, global.time / 60 * 2 - _cam.y / 12)
		
		draw_sprite_tiled(spr_background_clouds, 0, -_cam.x / 24, 0)
		
		draw_sprite_tiled(spr_background_star, 0, -_cam.x / 8, -_cam.y / 8)
		
		draw_sprite_tiled(spr_background_clouds, 1, wave(-36, 36, 64) - _cam.x / 4, -_cam.y / 4)
		
	}
	
}

function Background_City() : Background() constructor {
	
	static draw = function (_surface) {
		
		var _cam = game_camera_get()
		
		draw_sprite_ext(spr_pixel, 0, 0, 0, WIDTH, HEIGHT, 0, #242234, 1);
		
		// this is a bad idea
		gpu_set_scissor(WIDTH / 2 - 128 + wave(-16, 16, 16), 0, 256, HEIGHT);
		draw_sprite_tiled(spr_background_city0_lines, clamp(floor(power(wave(0, 1, 7), 4) * 5), 0, 4), -_cam.x * 1.1, global.time / 60 * 2);
		gpu_set_scissor(0, 0, WIDTH, HEIGHT);
		
		draw_sprite_tiled(spr_background_star, 1, -_cam.x / 32, global.time / 60 * 4 - _cam.y / 12)
		draw_sprite_tiled(spr_background_star, 0, -_cam.x / 24, -_cam.y / 8)
		
		draw_sprite_tiled(spr_background_city0, 0, 0, 0);
		
		draw_sprite_tiled(spr_background_city0, 1, wave(-36, 36, 64) -_cam.x / 28, -_cam.y / 48);
		draw_sprite_tiled(spr_background_city0, 2, wave(-20, 20, 48) -_cam.x / 20, -_cam.y / 40);
		
		draw_sprite_tiled(spr_background_city0, 3, -_cam.x / 14, 0);
		
		draw_sprite_tiled(spr_background_city0, 4, -_cam.x / 8, 0);	
		
		draw_sprite_tiled(spr_background_city0, 5, -_cam.x / 4, 0);
		
	}
	
}


