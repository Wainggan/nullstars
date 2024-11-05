
if gif_state == 2 && global.time % 3 == 0 {
	gif_add_surface(gif_id, application_surface, 1/60*3 * 10, 0, 0, 1);
}

if keyboard_check_pressed(ord("7")) {
	var _name = $"{irandom(99999999)}.png";
	log(Log.user, $"png saved! ({game_save_id}/{_name})");
	screen_save(_name);
}

