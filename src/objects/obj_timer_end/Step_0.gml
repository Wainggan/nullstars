
var _cond = place_meeting(x, y, obj_player) && !lastTouch;

if game_timer_running() && self.id != level_get_instance(game.timer_target) {
	_cond = false;
}

if _cond {
	var _pop = false;
	
	if game_timer_running() {
		game_timer_stop();
		
		instance_create_layer(x + sprite_width / 2, y + sprite_height / 2, layer, obj_effects_spritepop, {
			sprite: spr_timer_pop,
			index: 1,
			spd: 0.02
		})
		
		_pop = true;
	}

	if global.onoff == false {
		global.onoff = true;
		_pop = true;
	}
	
	if _pop {
		game_set_pause(4)
	
		instance_create_layer(x, y, layer, obj_effects_rectpop, {
			width: sprite_width,
			height: sprite_height,
			pad: 16,
			spd: 0.04
		})
	}
	
}

lastTouch = place_meeting(x, y, obj_player);

