
var _cam_x = camera_get_view_x(view_camera[0]),
	_cam_y = camera_get_view_y(view_camera[0]),
	_cam_w = camera_get_view_width(view_camera[0]),
	_cam_h = camera_get_view_height(view_camera[0]);

if !surface_exists(surf_blur_ping)
	surf_blur_ping = surface_create(_cam_w, _cam_h);
