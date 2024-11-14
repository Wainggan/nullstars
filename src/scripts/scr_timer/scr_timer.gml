
function game_timer_start(_length, _start = undefined, _target = undefined) {
	if !game.timer_active {
		game.timer = 0;
		game.timer_length = _length;
		game.timer_start = _start;
		game.timer_target = _target;
		game.timer_active = true;
		
		with obj_Entity {
			reset();
		}
		global.onoff = true;
		
		instance_create_layer(0, 0, "Instances", obj_timer_render)
	}
}

function game_timer_get() {
	return game.timer;
}

function game_timer_stop() {
	game.timer = 0;
	game.timer_active = false;
}

function game_timer_running() {
	return game.timer_active;
}

function game_timer_update() {
	if game.timer_active {
		game.timer += 1;
		if game.timer_length - game.timer <= 0 {
			game_timer_stop()
			//game_player_kill()
		}
	}
}
