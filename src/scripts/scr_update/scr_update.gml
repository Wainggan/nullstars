
function game_update_windowscale(_scale) {
	window_set_size(WIDTH * _scale, HEIGHT * _scale);
}
function game_update_fullscreen(_enable) {
	if _enable == 0 {
		window_set_fullscreen(false);
		window_center();
	} else if _enable == 1 {
		window_enable_borderless_fullscreen(false);
		window_set_fullscreen(true);
	} else if _enable == 2 {
		window_enable_borderless_fullscreen(true);
		window_set_fullscreen(true);
	}
}
function game_update_overlay(_enable) {
	show_debug_overlay(_enable, true);
}
function game_update_gctime(_set) {
	switch _set {
		case 0:
			gc_target_frame_time(100);
			break;
		case 1:
			gc_target_frame_time(500);
			break;
		case 2:
			gc_target_frame_time(1000);
			break;
	}
}
function game_update_log(_set) {
	global.logger.point = _set;
}
