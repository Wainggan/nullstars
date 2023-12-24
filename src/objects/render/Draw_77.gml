
var _cam_x = camera_get_view_x(view_camera[0]),
	_cam_y = camera_get_view_y(view_camera[0]),
	_cam_w = camera_get_view_width(view_camera[0]),
	_cam_h = camera_get_view_height(view_camera[0])

var _scale_w = window_get_width() / _cam_w,
	_scale_h = window_get_height() / _cam_h
	
draw_sprite_ext(
	spr_pixel, 0, 
	0, 0, 
	_cam_w, _cam_h, 
	0, #000209, 1
);

draw_surface_ext(surf_background, 0, 0, _scale_w, _scale_h, 0, c_white, 1)

gpu_set_colorwriteenable(true, true, true, false)

draw_surface_ext(application_surface, 0, 0, _scale_w, _scale_h, 0, c_white, 1);

gpu_set_colorwriteenable(true, true, true, true)
