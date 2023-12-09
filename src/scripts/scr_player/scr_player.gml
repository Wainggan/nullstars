
function game_player_kill() {
	game_set_pause(10);
	
	global.onoff = 1;
	
	game_timer_stop()
	instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_player_death);
	instance_destroy(obj_player);
}
