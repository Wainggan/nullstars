
if light == noone && game_level_get_safe(x, y) {
	light = instance_create_layer(x, y - 32, "Lights", obj_light, {
		size: 96,
		intensity: 1
	})
}

if game_checkpoint_get() != index && place_meeting(x, y, obj_player) {
	game_checkpoint_set(index);
	game_render_wave(x, y - 16, 400, 80, 1, spr_wave_sphere);
	game_set_pause(4)
}
