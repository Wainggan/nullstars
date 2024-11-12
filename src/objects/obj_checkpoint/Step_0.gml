
if game_checkpoint_get() != index && place_meeting(x, y, obj_player) {
	game_checkpoint_set(index);
	game_render_wave(x, y - 16, 400, 80, spr_wave_sphere);
	game_set_pause(4)
}
