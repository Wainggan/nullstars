
var _cam_x = camera_get_view_x(view_camera[0]),
	_cam_y = camera_get_view_y(view_camera[0]),
	_cam_w = camera_get_view_width(view_camera[0]),
	_cam_h = camera_get_view_height(view_camera[0]);

part_particles_burst(particles_ambient, _cam_x + _cam_w / 2, _cam_y + _cam_h / 2, ps_ambient_dust)

part_system_update(particles_ambient)
