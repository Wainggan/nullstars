
var _cam_x = camera_get_view_x(view_camera[0]),
	_cam_y = camera_get_view_y(view_camera[0]),
	_cam_w = camera_get_view_width(view_camera[0]),
	_cam_h = camera_get_view_height(view_camera[0]);

var _biome = game_level_get_biome(camera.x, camera.y);
var _amparts = -1;
switch _biome {
	case "dust":
		_amparts = ps_ambient_dust;
		break;
	case "rain":
		_amparts = ps_ambient_rain;
		break;
}

if _amparts != -1
	part_particles_burst(
		particles_ambient, 
		_cam_x + _cam_w / 2, 
		_cam_y + _cam_h / 2, 
		_amparts
	)

part_system_update(particles_ambient)
