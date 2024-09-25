check()
update()

var _cam = game_camera_get()

with obj_Exists {
	var _lvl = game_level_get_safe_rect(bbox_left, bbox_top, bbox_right, bbox_bottom)
	if (_lvl == undefined || !_lvl.loaded) && outside(_cam)
		instance_destroy();
}

with obj_spike_bubble {
	if (game.frame + parity) % GAME_BUBBLE_PARITY > 0 continue;
	var _lvl = game_level_get_safe(x, y)
	if (_lvl == undefined || !_lvl.loaded)
	&& (x - 64 < _cam.x || _cam.x + _cam.w < x + 64
	|| y - 64 < _cam.y || _cam.y + _cam.h < y + 64) {
		instance_destroy()
	}
}
