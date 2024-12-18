
var _cam_x = camera_get_view_x(view_camera[0]),
	_cam_y = camera_get_view_y(view_camera[0]),
	_cam_w = camera_get_view_width(view_camera[0]),
	_cam_h = camera_get_view_height(view_camera[0]);

var _lvl_onscreen = game_level_onscreen();

/*
note:
pretty much every normal object's draw event ran before this event.
in the application surface, there is the background tiles with these objects layered on top.
*/

// steal surface
surface_set_target(surf_layer_0);
draw_surface(application_surface, 0, 0);
surface_reset_target();

// clear application surface
draw_clear_alpha(c_black, 0);


// set up god rays
if !surface_exists(surf_background_rays) {
	surf_background_rays = surface_create(WIDTH, HEIGHT);
}
if config.light_ray {
	surface_set_target(surf_background_rays);
	draw_surface(surf_background_lights, 0, 0);
	draw_sprite_ext(spr_pixel, 0, 0, 0, WIDTH, HEIGHT, 0, c_white, 0.4);
	draw_surface_ext(surf_layer_0, 0, 0, 1, 1, 0, c_black, 1);
	draw_surface_ext(surf_tiles, 0, 0, 1, 1, 0, c_black, 1);
	draw_surface_ext(surf_tiles, 0, 0 - 16, 1, 1, 0, c_black, 1);
	surface_reset_target();
}


// -- background lights --

// mask out light layer with whatever is on the application surface
surface_set_target(surf_background_lights);
draw_surface_ext(surf_layer_0, 0, 0, 1, 1, 0, c_black, 1);
draw_surface(surf_bubbles, 0, 0);
surface_reset_target();

surface_set_target(surf_layer_1);
draw_clear_alpha(c_black, 0);

// matrix_set doesn't seem to work with part_system_drawit ...
camera_apply(view_camera[0])

if global.config.graphics_atmosphere_particles
	part_system_drawit(particles_ambient);

surface_reset_target();

// blur surf_background_lights
if global.config.graphics_lights_rimblur && global.settings.graphic.lights >= 1 {

	var _u_kernel = shader_get_uniform(shd_blur, "u_kernel")
	var _u_sigma = shader_get_uniform(shd_blur, "u_sigma")
	var _u_direction = shader_get_uniform(shd_blur, "u_direction")
	var _u_texel = shader_get_uniform(shd_blur, "u_texel")

	shader_set(shd_blur);

	shader_set_uniform_f(_u_kernel, background_lights_kernel);
	shader_set_uniform_f(_u_sigma, background_lights_sigma);
	shader_set_uniform_f(_u_texel, 1 / _cam_w, 1 / _cam_h);

	shader_set_uniform_f(_u_direction, 0, 1);

	surface_set_target(surf_ping);
	draw_surface(surf_background_lights, 0, 0);
	surface_reset_target();

	shader_set_uniform_f(_u_direction, 1, 0);

	surface_set_target(surf_background_lights);
	draw_surface(surf_ping, 0, 0);
	surface_reset_target();
	
	shader_reset()

} else {
	
}


// lights

// "simple" option
if global.settings.graphic.lights >= 1
if config.light_method {
	
	if !surface_exists(surf_lights_buffer) {
		// big downside: this takes a lot of space.
		/// @todo: change to `surface_r16float`, and use the 3rd pass to color?
		surf_lights_buffer = surface_create(GAME_RENDER_LIGHT_SIZE, GAME_RENDER_LIGHT_SIZE, surface_rgba16float);
	}
	
	// collect relevant lights into list
	
	array_delete(lights_array, 0, array_length(lights_array));
	with obj_light {
		var _size = size * 2 + 16; // surely this won't cause an accident
		if point_in_rectangle(
			x, y,
			_cam_x - _size,
			_cam_y - _size,
			_cam_x + _cam_w + _size,
			_cam_y + _cam_h + _size) {
			array_push(other.lights_array, self);
		}
	}
	
	surface_set_target(surf_lights_buffer);
	draw_clear_alpha(c_black, 1);

	var _u_l_position = shader_get_uniform(shd_light_color_new, "u_position");
	var _u_l_size = shader_get_uniform(shd_light_color_new, "u_size");
	var _u_l_scale = shader_get_uniform(shd_light_color_new, "u_scale");
	var _u_l_intensity = shader_get_uniform(shd_light_color_new, "u_intensity");
	
	var _u_s_position = shader_get_uniform(shd_light_shadow_new, "u_position");
	
	var _size = GAME_RENDER_LIGHT_KERNEL,
		_size_index = GAME_RENDER_LIGHT_SIZE / GAME_RENDER_LIGHT_KERNEL;
	
	// 1st pass: draw all lights into surf_lights_buffer, seperated into groups
	
	shader_set(shd_light_color_new);
	for (var i_light = 0; i_light < array_length(lights_array); i_light++) {
		var _x = i_light % _size_index,
			_y = floor(i_light / _size_index);
		
		with lights_array[i_light] {
			// if other.config.light_method_scissor gpu_set_scissor(_x * _size, _y * _size, _size, _size);
			
			var _size_scale = size div (GAME_RENDER_LIGHT_KERNEL / 2) + 1;
	
			shader_set_uniform_f(_u_l_position, _x * _size + _size / 2, _y * _size + _size / 2);
			shader_set_uniform_f(_u_l_size, size);
			shader_set_uniform_f(_u_l_scale, _size_scale);
			shader_set_uniform_f(_u_l_intensity, intensity);
	
			draw_sprite_stretched_ext(spr_pixel, 0, _x * _size, _y * _size, _size, _size, color, 1);
		}
	}
	
	// "shadows" option
	if global.settings.graphic.lights >= 2 {
		
		// 2nd pass: draw shadows on top of light groups
		
		var _matrix = matrix_build_identity();
		var _matrix_ind = util_matrix_get_alignment();
	
		shader_set(shd_light_shadow_new);
		for (var i_light = 0; i_light < array_length(lights_array); i_light++) {
			var _x = i_light % _size_index,
				_y = floor(i_light / _size_index);
			
			with lights_array[i_light] {
				if other.config.light_method_scissor gpu_set_scissor(_x * _size, _y * _size, _size, _size);
				
				var _x_r = _x * _size + _size / 2,
					_y_r = _y * _size + _size / 2;
				
				var _size_scale = size div (GAME_RENDER_LIGHT_KERNEL / 2) + 1;
				
				shader_set_uniform_f(_u_s_position, x, y);
				
				_matrix[_matrix_ind.x] = -x / _size_scale + _x_r;
				_matrix[_matrix_ind.y] = -y / _size_scale + _y_r;
				_matrix[_matrix_ind.x_scale] = 1 / _size_scale;
				_matrix[_matrix_ind.y_scale] = 1 / _size_scale;
				matrix_set(matrix_world, _matrix);
				
				for (var i_lvl = 0; i_lvl < array_length(_lvl_onscreen); i_lvl++) {
					var _lvl = _lvl_onscreen[i_lvl];
					if _lvl.shadow_vb != -1 {
						vertex_submit(_lvl.shadow_vb, pr_trianglelist, -1);
					}
				}
			}
		}
		matrix_set(matrix_world, matrix_identity);
		
	}
	shader_reset();
	
	surface_reset_target();
	
	
	if !surface_exists(surf_lights) {
		surf_lights = surface_create(_cam_w, _cam_h, surface_rgba16float);
	}
	
	// 3rd "pass": finally draw lights from surf_lights_buffer into surf_lights

	surface_set_target(surf_lights);
	draw_clear_alpha(#777788, 1);
	
	gpu_set_blendmode(bm_add);
	// rim lighting
	draw_surface(surf_background_lights, 0, 0);
	
	// god rays
	if config.light_ray {
		var _ray_x_off = WIDTH / 2;
		var _ray_y_off = -HEIGHT * 2;
		var _ray_s_fac = 1;
		var _ray_a_fac = 1;
		repeat 10 {
			_ray_s_fac *= 1.005;
			_ray_a_fac *= 0.86;
			draw_surface_ext(
				surf_background_rays,
				-_ray_x_off * _ray_s_fac + _ray_x_off,
				-_ray_y_off * _ray_s_fac + _ray_y_off,
				_ray_s_fac, _ray_s_fac,
				0, #bbbbff, 0.07 * _ray_a_fac
			);
		}
	}

	for (var i_light = 0; i_light < array_length(lights_array); i_light++) {
		var _x = i_light % _size_index,
			_y = floor(i_light / _size_index);
		
		var _e = lights_array[i_light];
		
		var _size_scale = _e.size div (GAME_RENDER_LIGHT_KERNEL / 2) + 1;
		
		draw_surface_part_ext(
			surf_lights_buffer,
			_x * _size, _y * _size,
			_size, _size,
			_e.x - _cam_x - _size / 2 * _size_scale,
			_e.y - _cam_y - _size / 2 * _size_scale,
			_size_scale, _size_scale,
			c_white, 1
		);
	}
	
	gpu_set_blendmode(bm_normal);
	surface_reset_target();
	
	if config.light_method_blur {
		
		// shitty implementation
		
		if !surface_exists(surf_ping16) {
			surf_ping16 = surface_create(WIDTH, HEIGHT, surface_rgba16float);
		}
		
		var _u_kernel = shader_get_uniform(shd_blur, "u_kernel")
		var _u_sigma = shader_get_uniform(shd_blur, "u_sigma")
		var _u_direction = shader_get_uniform(shd_blur, "u_direction")
		var _u_texel = shader_get_uniform(shd_blur, "u_texel")
	
		shader_set(shd_blur);
	
		shader_set_uniform_f(_u_kernel, 4);
		shader_set_uniform_f(_u_sigma, 0.3);
		shader_set_uniform_f(_u_texel, 1 / WIDTH, 1 / HEIGHT);
	
		shader_set_uniform_f(_u_direction, 0, 1);
	
		surface_set_target(surf_ping16);
		draw_surface(surf_lights, 0, 0);
		surface_reset_target();
	
		shader_set_uniform_f(_u_direction, 1, 0);
	
		surface_set_target(surf_lights);
		draw_surface(surf_ping16, 0, 0);
		surface_reset_target();
		
		shader_reset()
		
	}
	
	var _u_destination = shader_get_sampler_index(shd_light_compose, "u_destination");
		
	// apply lights
	
	surface_set_target(surf_ping);
		gpu_set_blendmode_ext(bm_one, bm_zero);
		draw_surface(surf_layer_0, 0, 0);
		gpu_set_blendmode(bm_normal);
		
	surface_set_target(surf_layer_0);
		shader_set(shd_light_compose);
		texture_set_stage(_u_destination, surface_get_texture(surf_ping));
		draw_surface_ext(surf_lights, 0, 0, 1, 1, 0, c_white, 1);
		shader_reset();
	
	surface_reset_target();
	surface_reset_target();
	
	surface_set_target(surf_ping);
		gpu_set_blendmode_ext(bm_one, bm_zero);
		draw_surface(surf_layer_1, 0, 0);
		gpu_set_blendmode(bm_normal);
		
	surface_set_target(surf_layer_1);
		shader_set(shd_light_compose);
		texture_set_stage(_u_destination, surface_get_texture(surf_ping));
		draw_surface_ext(surf_lights, 0, 0, 1, 1, 0, c_white, 1);
		shader_reset();
		
	surface_reset_target();
	surface_reset_target();
	
} else {
	
	if !surface_exists(surf_lights) {
		surf_lights = surface_create(_cam_w, _cam_h, surface_rgba16float);
	}

	surface_set_target(surf_lights);
	// ambient lights
	draw_clear_alpha(#777788, 1);

	// background lights

	gpu_set_blendmode(bm_add);

	draw_surface(surf_background_lights, 0, 0);

	gpu_set_blendmode(bm_normal)


	// draw lights
	
	var _u_l_position = shader_get_uniform(shd_light_color, "u_position")
	var _u_l_size = shader_get_uniform(shd_light_color, "u_size")
	var _u_l_intensity = shader_get_uniform(shd_light_color, "u_intensity")
	var _u_l_z = shader_get_uniform(shd_light_color, "u_z")

	var _u_s_position = shader_get_uniform(shd_light_shadow, "u_position")
	var _u_s_z = shader_get_uniform(shd_light_shadow, "u_z")

	gpu_set_ztestenable(true);
	//gpu_set_zwriteenable(true);

	matrix_set(matrix_world, matrix_build(-_cam_x, -_cam_y, 0, 0, 0, 0, 1, 1, 1))
	
	if global.config.graphics_lights_shadow && global.settings.graphic.lights >= 2 {
	
		var _z = 0;
		with obj_light {
	
			var _intensity = intensity;
	
			var _dist_x = min(
				x - _cam_x + size * 2, 
				(_cam_x + _cam_w + size * 2) - x
			);
			var _dist_y = min(
				y - _cam_y + size * 2, 
				(_cam_y + _cam_h + size * 2) - y
			);
			_dist_x = clamp(_dist_x / 60, 0, 1);
			_dist_y = clamp(_dist_y / 60, 0, 1);
			_intensity = herp(0, _intensity, min(_dist_x, _dist_y))
	
			if _intensity < 0.01 continue;
	
			shader_set(shd_light_shadow);
			shader_set_uniform_f(_u_s_position, x, y);
			shader_set_uniform_f(_u_s_z, _z);
	
			for (var i = 0; i < array_length(_lvl_onscreen); i++) {
				if _lvl_onscreen[i].shadow_vb != -1
					vertex_submit(_lvl_onscreen[i].shadow_vb, pr_trianglelist, -1);
			}
	
			shader_set(shd_light_color);
			shader_set_uniform_f(_u_l_position, x - _cam_x, y - _cam_y);
			shader_set_uniform_f(_u_l_size, size);
			shader_set_uniform_f(_u_l_intensity, _intensity);
			shader_set_uniform_f(_u_l_z, _z);
	
			gpu_set_blendmode(bm_add);
			draw_sprite_stretched_ext(spr_pixel, 0, _cam_x, _cam_y, _cam_w, _cam_h, color, 1);
			gpu_set_blendmode(bm_normal);
	
			_z--;
	
		}
	
	} else {
		
		var _z = 0;
		
		shader_set(shd_light_color);
		gpu_set_blendmode(bm_add);
		with obj_light {
	
			var _intensity = intensity;
	
			var _dist_x = min(
				x - _cam_x + size * 2, 
				(_cam_x + _cam_w + size * 2) - x
			);
			var _dist_y = min(
				y - _cam_y + size * 2, 
				(_cam_y + _cam_h + size * 2) - y
			);
			_dist_x = clamp(_dist_x / 60, 0, 1);
			_dist_y = clamp(_dist_y / 60, 0, 1);
			_intensity = herp(0, _intensity, min(_dist_x, _dist_y))
	
			if _intensity < 0.01 continue;
	
			shader_set_uniform_f(_u_l_position, x - _cam_x, y - _cam_y);
			shader_set_uniform_f(_u_l_size, size);
			shader_set_uniform_f(_u_l_intensity, _intensity);
			shader_set_uniform_f(_u_l_z, _z);
	
			draw_sprite_stretched_ext(spr_pixel, 0, _cam_x, _cam_y, _cam_w, _cam_h, color, 1);
			
			_z--;
	
		}
		gpu_set_blendmode(bm_normal);
		
	}

	matrix_set(matrix_world, matrix_identity);

	gpu_set_ztestenable(false);
	//gpu_set_zwriteenable(true);

	shader_reset();

	surface_reset_target();
	
	var _u_destination = shader_get_sampler_index(shd_light_compose, "u_destination");
	
	// apply lights
	
	surface_set_target(surf_ping);
		gpu_set_blendmode_ext(bm_one, bm_zero);
		draw_surface(surf_layer_0, 0, 0);
		gpu_set_blendmode(bm_normal);
		
	surface_set_target(surf_layer_0);
		shader_set(shd_light_compose);
		texture_set_stage(_u_destination, surface_get_texture(surf_ping));
		draw_surface_ext(surf_lights, 0, 0, 1, 1, 0, c_white, 1);
		shader_reset();
		
	surface_reset_target();
	surface_reset_target();
	
	
	surface_set_target(surf_ping);
		gpu_set_blendmode_ext(bm_one, bm_zero);
		draw_surface(surf_layer_1, 0, 0);
		gpu_set_blendmode(bm_normal);
		
	surface_set_target(surf_layer_1);
		shader_set(shd_light_compose);
		texture_set_stage(_u_destination, surface_get_texture(surf_ping));
		draw_surface_ext(surf_lights, 0, 0, 1, 1, 0, c_white, 1);
		shader_reset();
		
	surface_reset_target();
	surface_reset_target();
	
} else {
	
}

// draw bubbles
surface_set_target(surf_layer_0);
draw_surface(surf_bubbles, 0, 0);
surface_reset_target();


// reflections
if global.config.graphics_reflectables && global.settings.graphic.reflections == 1 {

	if !surface_exists(surf_relection)
		surf_relection = surface_create(_cam_w, _cam_h);

	var _u_top = shader_get_uniform(shd_reflect, "u_top")
	var _u_surf = shader_get_sampler_index(shd_reflect, "u_surf")
	var _u_texel = shader_get_uniform(shd_reflect, "u_texel")

	surface_set_target(surf_relection)
	draw_clear_alpha(c_black, 0)

	shader_set(shd_reflect)

	texture_set_stage(_u_surf, surface_get_texture(surf_layer_0))
	shader_set_uniform_f(_u_texel, 1 / _cam_w, 1 / _cam_h);

	with obj_decor_reflectable {
		if !rectangle_in_rectangle(
			_cam_x, _cam_y, _cam_x + _cam_w, _cam_y + _cam_h,
			bbox_left, bbox_top, bbox_right, bbox_bottom
		) continue;
		var _top = (bbox_top - _cam_y) / _cam_h;
		var _tr = floor_ext(_top, 0.01);
		var _tg = floor_ext(frac(_top * 100), 0.01);
		var _tb = floor_ext(frac(_top * 100 * 100), 0.01);
		draw_sprite_stretched_ext(
			sprite_index, 0, 
			x - _cam_x, y - _cam_y, 
			sprite_width, sprite_height,
			make_color_rgb(floor(_tr * 256), floor(_tg * 256), floor(_tb * 256)), image_alpha
		);
	}

	shader_reset()
	surface_reset_target()

}


// water

if !surface_exists(surf_water)
	surf_water = surface_create(WIDTH, HEIGHT);

if !surface_exists(surf_mask)
	surf_mask = surface_create(WIDTH, HEIGHT);

surface_set_target(surf_mask);
draw_clear_alpha(c_black, 0);
var _u_texel = shader_get_uniform(shd_water_shape, "u_texel");
var _u_time = shader_get_uniform(shd_water_shape, "u_time");
var _u_off = shader_get_uniform(shd_water_shape, "u_off");
shader_set(shd_water_shape);
shader_set_uniform_f(_u_time, global.time / 60);
	with obj_water {
		shader_set_uniform_f(_u_texel, 1 / sprite_width, 1 / sprite_height);
		shader_set_uniform_f(_u_off, x / WIDTH, y / HEIGHT);
		draw_surface_ext(
			application_surface, 
			x - _cam_x, y - _cam_y,
			sprite_width / WIDTH, sprite_height / HEIGHT,
			0, c_white, 1
		);
	}
shader_reset();
camera_apply(view_camera[0])
part_system_drawit(particles_water);
surface_reset_target();

surface_set_target(surf_ping);
	draw_surface_ext(surf_background, 0, 0, 1, 1, 0, #8888dd, 1);
	draw_surface(surf_layer_0, 0, 0);
surface_reset_target();

surface_set_target(surf_water);
draw_clear_alpha(c_black, 0);
var _u_back = shader_get_sampler_index(shd_water_color, "u_back");
var _u_time = shader_get_uniform(shd_water_color, "u_time");
var _u_off = shader_get_uniform(shd_water_color, "u_off");
shader_set(shd_water_color);
shader_set_uniform_f(_u_time, global.time / 60);
shader_set_uniform_f(_u_off, _cam_x / WIDTH, _cam_y / HEIGHT);
texture_set_stage(_u_back, surface_get_texture(surf_ping));
	draw_surface(surf_mask, 0, 0);
shader_reset();
surface_reset_target();


// level mask

surface_set_target(surf_mask)
draw_clear(c_black)

gpu_set_blendmode(bm_subtract);

for (var i = 0; i < array_length(_lvl_onscreen); i++) {
	var _lvl = _lvl_onscreen[i];
	draw_sprite_stretched(spr_pixel, 0, _lvl.x - _cam_x, _lvl.y - _cam_y, _lvl.width, _lvl.height)
}

gpu_set_blendmode(bm_normal);

surface_reset_target()


surface_set_target(surf_layer_2);
draw_clear_alpha(c_black, 0);

shader_set(shd_outline)
var _u_texel = shader_get_uniform(shd_outline, "u_texel");
shader_set_uniform_f(_u_texel, 1 / WIDTH, 1 / HEIGHT);
	draw_surface_ext(surf_water, 0, 0, 1, 1, 0, #99bbff, 0.9);
shader_reset();

camera_apply(view_camera[0]);
part_system_drawit(particles_layer);

// camera_apply() bullshit
surface_reset_target();
surface_set_target(surf_layer_2);

draw_surface(surf_mask, 0, 0);

// draw tiles
draw_surface(surf_tiles, 0, 0);

surface_reset_target();


