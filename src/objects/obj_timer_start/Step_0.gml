
if !game_timer_running() && place_meeting(x, y, obj_player) {
	game_timer_start(time, ref);
	
	game_set_pause(4)
	game_camera_set_shake(3, 0.5)
	
	instance_create_layer(x + sprite_width / 2, y + sprite_height / 2, layer, obj_effects_spritepop, {
		sprite: spr_timer_pop,
		index: 0,
		spd: 0.02
	})
	instance_create_layer(x, y, layer, obj_effects_rectpop, {
		width: sprite_width,
		height: sprite_height,
		pad: 16,
		spd: 0.04
	})
}
