
if gif_state == 2 && global.time % 3 == 0 {
	gif_add_surface(gif_id, application_surface, 1/60*3 * 10, 0, 0, 1);
}

