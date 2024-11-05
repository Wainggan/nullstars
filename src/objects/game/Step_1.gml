
global.time++;

global.logger.update();

if keyboard_check_pressed(ord("8")) global.config.slow = !global.config.slow
if keyboard_check_pressed(ord("0")) global.demonstrate = !global.demonstrate

if keyboard_check_pressed(ord("9")) {
	if gif_state == 0 {
		log(Log.user, "ready to start recording!");
		gif_id = gif_open(WIDTH, HEIGHT);
		gif_state = 1;
	} else if gif_state == 1 {
		log(Log.user, "recording ...");
		gif_state = 2;
	} else if gif_state == 2 {
		var _name = $"{irandom(99999999)}.gif";
		log(Log.user, $"gif saved! ({game_save_id}/{_name})");
		var _status = gif_save(gif_id, _name);
		if _status == -1 {
			log(Log.user, $"recording failed?");
		}
		gif_state = 0;
	}
}

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

