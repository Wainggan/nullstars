
function game_update_windowscale(_scale) {
	window_set_size(WIDTH * _scale, HEIGHT * _scale);
}
function game_update_fullscreen(_enable) {
	window_set_fullscreen(_enable);
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
