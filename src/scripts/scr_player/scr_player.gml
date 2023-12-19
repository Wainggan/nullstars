
function game_player_kill() {
	game_set_pause(10);
	game_camera_set_shake(6, 0.5)
	
	global.onoff = 1;
	
	game_timer_stop()
	instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_player_death);
	instance_destroy(obj_player);
	
	with obj_Entity {
		reset();
	}
	
}
