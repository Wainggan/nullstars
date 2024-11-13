
var _cam_x = camera_get_view_x(view_camera[0]),
	_cam_y = camera_get_view_y(view_camera[0]),
	_cam_w = camera_get_view_width(view_camera[0]),
	_cam_h = camera_get_view_height(view_camera[0]);

var _lvl_onscreen = game_level_onscreen()

/*
note:
pretty much every normal object's draw event ran before this event.
in the application surface, there is the background tiles with these objects layered on top.
*/

// steal surface
surface_set_target(surf_layer_0);
draw_surface(application_surface, 0, 0);
surface_reset_target();

draw_clear_alpha(c_black, 0);


// -- background lights --

// mask out light layer with whatever is on the application surface
surface_set_target(surf_background_lights);
draw_surface_ext(surf_layer_0, 0, 0, 1, 1, 0, c_black, 1);
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

if global.config.graphics_lights && global.settings.graphic.lights >= 1  {
	
	if !surface_exists(surf_lights) {
		surf_lights = surface_create(_cam_w, _cam_h, surface_rgba16float);
	}

	surface_set_target(surf_lights);
	// ambient lights
	draw_clear_alpha(#777788, 1);

	// background lights

	gpu_set_blendmode(bm_add);

	draw_surface(surf_background_lights, 0, 0);
	draw_surface(surf_bubbles, 0, 0);

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

	matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1))

	gpu_set_ztestenable(false);
	//gpu_set_zwriteenable(true);

	shader_reset();

	surface_reset_target();
	
	// apply lights
	gpu_set_colorwriteenable(true, true, true, false);
	gpu_set_blendmode_ext(bm_dest_color, bm_zero);
	
	surface_set_target(surf_layer_0);
		draw_surface_ext(surf_lights, 0, 0, 1, 1, 0, c_white, 1);
	
	surface_set_target(surf_layer_1);
		draw_surface_ext(surf_lights, 0, 0, 1, 1, 0, c_white, 1);
	
	surface_reset_target();
	surface_reset_target();
	
	gpu_set_blendmode(bm_normal);
	gpu_set_colorwriteenable(true, true, true, true);

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


// draw tile layer

shader_set(shd_tiles);

for (var i = 0; i < array_length(_lvl_onscreen); i++) {
	var _lvl = _lvl_onscreen[i]
	matrix_set(matrix_world, matrix_build(_lvl.x - _cam_x, _lvl.y - _cam_y, 0, 0, 0, 0, 1, 1, 1));
	vertex_submit(_lvl.vb_tiles_below, pr_trianglelist, tileset_get_texture(tl_tiles));
	vertex_submit(_lvl.vb_front, pr_trianglelist, tileset_get_texture(tl_tiles));
}
matrix_set(matrix_world, matrix_build_identity());

shader_reset();

for (var i = 0; i < array_length(_lvl_onscreen); i++) {
	var _lvl = _lvl_onscreen[i]
	draw_tilemap(
		_lvl.tiles_tiles_above, 
		tilemap_get_x(_lvl.tiles_tiles_above) - _cam_x,
		tilemap_get_y(_lvl.tiles_tiles_above) - _cam_y
	);
	draw_tilemap(
		_lvl.tiles_decor, 
		tilemap_get_x(_lvl.tiles_decor) - _cam_x,
		tilemap_get_y(_lvl.tiles_decor) - _cam_y
	);
	draw_tilemap(
		_lvl.tiles_spike, 
		tilemap_get_x(_lvl.tiles_spike) - _cam_x,
		tilemap_get_y(_lvl.tiles_spike) - _cam_y
	);
}

surface_reset_target();


