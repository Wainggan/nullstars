
function game_camera_set_target(_target) {
	camera.target = _target;
}

function game_camera_get() {
	static __cam = {
		x: 0, y: 0, w: 0, h: 0
	}
	__cam.x = camera_get_view_x(view_camera[0])
	__cam.y = camera_get_view_y(view_camera[0])
	__cam.w = camera_get_view_width(view_camera[0])
	__cam.h = camera_get_view_height(view_camera[0])
	return __cam
}

function game_camera_set_shake(_shake, _damp) {
	camera.shake_time = max(camera.shake_time, _shake);
	camera.shake_damp = _damp;
}
