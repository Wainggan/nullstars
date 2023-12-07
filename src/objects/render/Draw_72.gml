
var _cam_x = camera_get_view_x(view_camera[0]),
	_cam_y = camera_get_view_y(view_camera[0]),
	_cam_w = camera_get_view_width(view_camera[0]),
	_cam_h = camera_get_view_height(view_camera[0]);

draw_clear_alpha(c_black, 0);

if !surface_exists(surf_mask)
	surf_mask = surface_create(_cam_w, _cam_h);

surface_set_target(surf_mask)
draw_clear(c_black)

gpu_set_blendmode(bm_subtract);

for (var i = 0; i < array_length(level.levels); i++) {
	var _lvl = level.levels[i];
	draw_sprite_stretched(spr_pixel, 0, _lvl.x - _cam_x, _lvl.y - _cam_y, _lvl.width, _lvl.height)
}

gpu_set_blendmode(bm_normal)

surface_reset_target()

draw_surface(surf_mask, _cam_x, _cam_y);

