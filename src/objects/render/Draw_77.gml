
var _cam_x = camera_get_view_x(view_camera[0]),
	_cam_y = camera_get_view_y(view_camera[0]),
	_cam_w = camera_get_view_width(view_camera[0]),
	_cam_h = camera_get_view_height(view_camera[0])
	
draw_sprite_ext(
	spr_pixel, 0, 
	0, 0, 
	_cam_w, _cam_h, 
	0, #000209, 1
);

draw_surface(surf_background, 0, 0)

draw_surface(application_surface, 0, 0);
