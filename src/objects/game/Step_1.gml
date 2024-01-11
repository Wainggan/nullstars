
if global.config.slow {
	game_set_speed(10, gamespeed_fps)
} else {
	game_set_speed(60, gamespeed_fps)
}

var _k_cp = keyboard_check_pressed(ord("E")) - keyboard_check_pressed(ord("Q"));
if _k_cp != 0 {
	checkpoint += _k_cp;
	if checkpoint >= array_length(checkpoint_list) checkpoint = 0;
	if checkpoint < 0 checkpoint = array_length(checkpoint_list) - 1;

	var _checkpoint = game_checkpoint_ref()
	obj_player.x = _checkpoint.x;
	obj_player.y = _checkpoint.y - 24;
}

game_pause_update();

game_timer_update()

