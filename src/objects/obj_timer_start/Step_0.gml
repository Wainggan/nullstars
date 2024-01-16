
var _checkable = false;
if instance_exists(obj_player) {
	if dir == "right" || dir == "left" {
		if obj_player.bbox_bottom > bbox_top 
		&& obj_player.bbox_top < bbox_bottom
			_checkable = true;
	}
	if dir == "up" || dir == "down" {
		if obj_player.bbox_left > bbox_right 
		&& obj_player.bbox_right < bbox_left
			_checkable = true;
	}
}

if !_checkable {
	last_check = false;
}

var _check = false;
if instance_exists(obj_player) {
	if dir == "right" {
		_check = bbox_left <= obj_player.bbox_left;
	}
	if dir == "left" {
		_check = bbox_right >= obj_player.bbox_right;
	}
	if dir == "bottom" {
		_check = bbox_top <= obj_player.bbox_top;
	}
	if dir == "top" {
		_check = bbox_bottom >= obj_player.bbox_bottom;
	}
}

var _start = !last_check && _check && _checkable;
var _end = last_check && !_check && _checkable;

last_check = _check;
last_able = _checkable;

if !game_timer_running() && _start {
	game_timer_start(time * 60, self, ref);
	
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

if game_timer_running() && game.timer_start == self && _end {
	game_timer_stop()
	
	game_set_pause(4)
	
	instance_create_layer(x + sprite_width / 2, y + sprite_height / 2, layer, obj_effects_spritepop, {
		sprite: spr_timer_pop,
		index: 1,
		spd: 0.02
	})
	instance_create_layer(x, y, layer, obj_effects_rectpop, {
		width: sprite_width,
		height: sprite_height,
		pad: 16,
		spd: 0.04
	})
}
