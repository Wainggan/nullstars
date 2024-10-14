
var _cam_x = camera_get_view_x(view_camera[0]),
	_cam_y = camera_get_view_y(view_camera[0]),
	_cam_w = camera_get_view_width(view_camera[0]),
	_cam_h = camera_get_view_height(view_camera[0]);

if !surface_exists(surf_ping)
	surf_ping = surface_create(_cam_w, _cam_h);
	
if !surface_exists(surf_app)
	surf_app = surface_create(_cam_w, _cam_h)

if !surface_exists(surf_compose)
	surf_compose = surface_create(_cam_w, _cam_h);

if !surface_exists(surf_layer_0)
	surf_layer_0 = surface_create(_cam_w, _cam_h);
if !surface_exists(surf_layer_1)
	surf_layer_1 = surface_create(_cam_w, _cam_h);
if !surface_exists(surf_layer_2)
	surf_layer_2 = surface_create(_cam_w, _cam_h);


