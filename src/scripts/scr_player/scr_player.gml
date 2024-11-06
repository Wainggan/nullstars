
function game_player_kill() {
	
	var _x = obj_player.x, _y = obj_player.y;
	game_render_particle(_x, _y - 16, ps_player_death_0);
	global.game.schedule.add_wait(2, method({ _x, _y }, function(){
		game_render_particle(_x, _y - 16, ps_player_death_1);
		game_camera_set_shake(8, 1);
		game_set_pause(1);
	}));
	
	game_sound_play(sfx_death);
	game_set_pause(14);
	game_camera_set_shake(4, 0.8);
	
	global.onoff = 1;
	
	game_timer_stop()
	instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_player_death);
	instance_destroy(obj_player);
	
	with obj_Entity {
		reset();
	}
	
}
