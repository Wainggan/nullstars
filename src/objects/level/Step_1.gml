check()

var _cam = game_camera_get()

with obj_Exists {
	var _lvl = game_level_get_safe_rect(bbox_left, bbox_top, bbox_right, bbox_bottom)
	if (_lvl == undefined || !_lvl.loaded) && outside(_cam)
		instance_destroy();
}

with obj_spike_bubble {
	if (global.time + parity) % GAME_BUBBLE_PARITY > 0 continue;
	var _lvl = game_level_get_safe(x, y)
	if (_lvl == undefined || !_lvl.loaded)
	&& rectangle_in_rectangle(
		x - 64, y - 64, x + 64, y + 64,
		_cam.x, _cam.y, _cam.x + _cam.w, _cam.y + _cam.h) {
		instance_destroy()
	}
}

