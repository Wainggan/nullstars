
var _cam = game_camera_get()

gpu_set_tex_filter(true)

gpu_set_blendmode_ext_sepalpha(bm_one, bm_zero, bm_zero, bm_one)

game_render_refresh()
game_render_blendmode_set(shd_blend_fog)

if !keyboard_check(vk_space)
draw_sprite_tiled_ext(spr_atmosphere_overlay, 0, -_cam.x * 1.1 - (current_time / 100), -_cam.y * 1.1, 8, 8, c_white, 0.2);

game_render_blendmode_reset()

gpu_set_blendmode(bm_normal)

gpu_set_tex_filter(false)



exit;


gpu_set_blendmode_ext(bm_one, bm_zero)

var _colors = [
	#0000ff,
	#ab49f5,
	#ffaa88
];

var _tex_size = _cam.w

for (var i = 0; i < 3; i++) {
	
	game_render_refresh()
	game_render_blendmode_set(shd_blend_screen)

	var _off_x = wave(-400, 400, 133, 0.7 * i) + wave(-200, 200, 83, 0.4 * i)
	var _off_y = wave(-300, 300, 142, 0.9 * i) + wave(-200, 200, 76, 0.8 * i)

	var _pos_x = (_tex_size / 2) + _cam.x - mod_euclidean(_cam.x * 1.2 + _off_x, _tex_size + 64),
		_pos_y = (_tex_size / 2) + _cam.y - mod_euclidean(_cam.y * 1.2 + _off_y, _tex_size + 64);

	var _size = _tex_size / 64, _color = _colors[i], _transparency = 1;

	draw_sprite_ext(
		spr_atmoshpere, 0, 
		_pos_x, _pos_y,
		_size, _size,
		0, _color, _transparency
	);
	draw_sprite_ext(
		spr_atmoshpere, 0, 
		_pos_x + _cam.w, _pos_y, 
		_size, _size,
		0, _color, _transparency
	);
	draw_sprite_ext(
		spr_atmoshpere, 0, 
		_pos_x, _pos_y + _cam.h, 
		_size, _size,
		0, _color, _transparency
	);
	draw_sprite_ext(
		spr_atmoshpere, 0, 
		_pos_x + _cam.w, _pos_y + _cam.h, 
		_size, _size,
		0, _color, _transparency
	);
	
	game_render_blendmode_reset()
}



gpu_set_blendmode(bm_normal)

gpu_set_tex_filter(false)
