
function game_camera_set_target(_target) {
	camera.target = _target;
}

function game_camera_get() {
	return {
		x: camera_get_view_x(view_camera[0]),
		y: camera_get_view_y(view_camera[0]),
		w: camera_get_view_width(view_camera[0]),
		h: camera_get_view_height(view_camera[0])
	};
}
