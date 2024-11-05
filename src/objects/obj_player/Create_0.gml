
// if the player dies, their uid system is broken
// oops
if instance_number(obj_player) > 1 {
	instance_destroy();
	exit;
}

event_inherited();


// behaviour

defs = {
	
	move_speed: 2,
	move_accel: 0.5,
	move_slowdown: 0.08,
	move_slowdown_air: 0.04,
	
	boost_limit_x: 9,
	boost_limit_y: 3,
	
	jump_vel: -4.8,
	jump_move_boost: 0.2,
	terminal_vel: global.defs.terminal_vel,
	terminal_vel_fast: 6,
	
	jump_short_vel: -3,
	
	gravity: 0.45,
	gravity_hold: 0.23,
	gravity_peak: 0.12,
	gravity_peak_thresh: 0.36,
	gravity_term: 0.12,
	
	gravity_damp: 0.6,
	
	wall_distance: 4,
	
	climb_speed: 2,
	climb_accel: 1,
	climb_slide: 0.1,
	climb_leave: 8,
	
	dash_timer: 6,
	dash_total: 1,
	
	buffer: 12,
	grace: 4,
	
	anim_dive_time: 20,
	anim_jab_time: 20,
	anim_longjump_time: 30,
	
	
};

anim = new AnimController()
.add("idle", new AnimLevel([0]))
.add("walk", new AnimLevel([3, 1, 4, 2], 12))
.add("jump", new AnimLevel([5]))
.add("fall", new AnimLevel([6]))
.add("dive", new AnimLevel([7]))
.add("jab", new AnimLevel([11]))
.add("longjump", new AnimLevel([8]))
.add("swim", new AnimLevel([13, 14], 1 / 60))
.add("swimming", new AnimLevel([15, 16], 1 / 60))
.add("swimbullet", new AnimLevel([18]))
.add("ledge", new AnimLevel([20]))
.add("crouch", new AnimLevel([22]))
.add("flip", new AnimLevel([24, 25], 1 / 14, 0))
.add("run", new AnimLevel([29, 29, 27, 27, 27, 28, 28], 1/12))
.add("runjump", new AnimLevel([27]))
.add("runfall", new AnimLevel([30]))
.add("land", new AnimLevel([29]))

.meta_default({
	x: -2, y: -16,
	eye_x: 2, eye_y: -29,
	front: false
})
.meta_items([1, 2], {
	y: -15
})
.meta_items([5, 6], {
	y: -17
})
.meta_items([7], {
	x: -4, y: -21,
	front: true
})
.meta_items([8], {
	x: -8, y: -16
})
.meta_items([11], {
	x: 3, y: -11
})
.meta_items([13], {
	x: -4, y: -17
})
.meta_items([14], {
	x: -5, y: -15
})
.meta_items([15], {
	x: -4, y: -16
})
.meta_items([16], {
	x: -4, y: -17
})
.meta_items([18, 19], {
	x: 0, y: -16
})
.meta_items([20], {
	x: -4, y: -17
})
.meta_items([22], {
	x: -5, y: -6
})
.meta_items([23], {
	x: -2, y: -17
})
.meta_items([24, 25], {
	x: -2, y: -15
})
.meta_items([27], {
	x: -5, y: -13
})
.meta_items([28], {
	x: -8, y: -16
})
.meta_items([29], {
	x: -8, y: -16
})
.meta_items([30], {
	x: -3, y: -15
})


event = new Event()
.add("ground", function(){
	anim_longjump_timer = 0;
	anim_flip_timer = 0;
	anim_runjump_timer = 0;
})
.add("ledge", function(){
	anim_longjump_timer = 0;
	anim_flip_timer = 0;
})
.add("jump", function(){
	anim_dive_timer = 0;
	anim_jab_timer = 0;
	anim_flip_timer = 0;
	anim_runjump_timer = 0;
})
.add("fall", function(){
	anim_runjump = 0;
})
.add("jumpdash", function(){
	anim_longjump_timer = defs.anim_longjump_time;
})
.add("jumpbounce", function(){
	anim_flip_timer = 30//defs.anim_longjump_time;
})
.add("dive", function(){
	anim_runjump_timer = 0;
	if y_vel > 0
		anim_dive_timer = defs.anim_dive_time;
	else
		anim_jab_timer = defs.anim_jab_time;
})


// properties

scale_x = 0;
scale_y = 0;

x_last = xstart;
y_last = ystart;

x_delta = 0;
y_delta = 0;

dir = 1;

grace = 0;
grace_y = y;
grace_solid = noone;
buffer = 0;
buffer_dash = 0;

grace_vel = 0
grace_vel_timer = 0

gravity_hold = false;

key_hold = 0;
key_hold_timer = 0;

crouched = false;

momentum_grace = 0;
momentum_grace_amount = 0;

climb_away = 0;

dash_dir_x = 0;
dash_dir_x_vel = 0;
dash_dir_y = 0;
dash_dir_y_vel = 0;
dash_timer = 0;
dash_grace = 0;
dash_recover = 0;
dash_kick_buffer = 0;
dash_start_x_vel = x_vel;
dash_start_y_vel = y_vel;

dash_left = 0;

holding = noone;
hold_cooldown = 0;
hold_throw_x = 0;
hold_throw_y = 0;

swim_dir = 0;
swim_spd = 0;
swim_bullet_check = false;
swim_bullet = false;

ledge_keybuffer = 0;
ledge_stick = 0;

spike_buffer = 0;

anim_dive_timer = 0;
anim_jab_timer = 0;
anim_longjump_timer = 0;
anim_flip_timer = 0;
anim_runjump_timer = 0;

cam_ground_x = x;
cam_ground_y = y;

depth -= 10;
mask_index = spr_debug_player;

tail_length = 12;
tail = yarn_create(tail_length, function(_p, i){
	//_p.len = min(power(max(i - 4, 0) , 1.12) + 4, 8)
	_p.length = 4;
	
	_p.x = x
	_p.y = y + i * 6
		
	_p.size = max(parabola_mid(3, 7, 6, i) + 3, 6)
	_p.round = floor(clamp(i / (tail_length / 3), 1, 1))
})

tail_draw = function(_p, j) {
	var _c = merge_color(c_white, _tip, clamp(j - 3, 0, tail_length) / tail_length);
	_c = multiply_color(_c, _blend);
	draw_sprite_ext(
		spr_player_tail, 0, 
		round_ext(_p.x, _p.round), round_ext(_p.y, _p.round), 
		//round_ext(_p.x, 0), round_ext(_p.y, 0), 
		_p.size / 16, _p.size / 16, 
		0, _c, 1
	);
}

update_tail = function(_p, i, _points){
	var _len = array_length(_points)
	var _scale_nor = (i / _len);
	var _scale_inv = (_len - i) / _len;
	
	if holding {
		_p.damp = 0.8
		_p.weight = 6;
		
		var _t1 = floor(_len * 0.5)
		var _t2 = floor(_len * 0.75)
		
		_p.direction = (90 + 80 * -dir)
		if i > _t1 {
			_p.direction += (i - _t1) * -30 * dir;
			if i > _t2 {
				_p.direction += (i - _t2) * 60 * dir;
			}
		} else {
			
		}
		
		
	} else {
		_p.damp = 0.8
		_p.weight = 2 + _scale_inv;
		
		var _d = sin(global.time / 60 - i * 0.6)
		_p.x_move = -dir * (power(_scale_inv, 6) * 6 + 0.1)
		_p.y_move = _d * (_scale_inv * 0.2 + 0.1) + 0.3 * _scale_inv
		
	}
}

light = instance_create_layer(x, y, "Lights", obj_light, {
	color: #ffffff,
	size: 60,
	intensity: 0.5
});

checkWall = function(_dir, _dist = defs.wall_distance){
	return actor_collision(x + _dir * _dist, y);
}

checkDeath_point = function(_x, _y, _xv = 0, _yv = 0) {
	
	_xv = round(_xv);
	_yv = round(_yv);
	
	static _size = 5;
	
	for (var i = 0; i < array_length(level.loaded); i++) {
		
		var _tm = level.loaded[i].tiles_spike;
		var _tile = tilemap_get_at_pixel(_tm, _x, _y);
		
		if _tile == 0 continue;
		
		switch _tile {
			case 1:
				if !point_in_rectangle(_x % TILESIZE, _y % TILESIZE, 0, 0, _size, 16)
					break;
				if _xv > 0 break;
				return true;
			case 2:
				if !point_in_rectangle(_x % TILESIZE, _y % TILESIZE, 0, 16 - _size, 16, 16)
					break;
				if _yv < 0 break;
				return true;
			case 3:
				if !point_in_rectangle(_x % TILESIZE, _y % TILESIZE, 16 - _size, 0, 16, 16)
					break;
				if _xv < 0 break;
				return true;
			case 4:
				if !point_in_rectangle(_x % TILESIZE, _y % TILESIZE, 0, 0, 16, _size)
					break;
				if _yv > 0 break;
				return true;
		}
		
	}
	
	return false;
	
}

checkDeath = function(_x, _y){
	
	var _inst = instance_place(_x, _y, obj_spike);
	with _inst {
		if object_index == obj_spike_up && other.y_vel >= 0 return true;
		if object_index == obj_spike_down && other.y_vel <= 0 return true;
		if object_index == obj_spike_left && other.x_vel >= 0 return true;
		if object_index == obj_spike_right && other.x_vel <= 0 return true;
		return true;
	}
	
	var _lx = x, _ly = y;
	
	x = _x;
	y = _y;
	
	var _out = false 
		|| checkDeath_point(bbox_left, bbox_top, x_vel, y_vel)
		|| checkDeath_point(bbox_right - 1, bbox_top, x_vel, y_vel)
		|| checkDeath_point(bbox_left, bbox_bottom - 1, x_vel, y_vel)
		|| checkDeath_point(bbox_right - 1, bbox_bottom - 1, x_vel, y_vel)
	
	x = _lx;
	y = _ly;
	
	return _out;
	
	
}

hold_begin = function(_inst){
	holding = _inst;
	anim_holding = 0;
			
	holding.state.change(holding.state_held)
			
	state.change(state_free);
}
hold_end = function(){
	if !holding return;
	holding.state.change(holding.state_free);
	holding = noone;
}

#region jump

jump = function(){
	
	buffer = 0
	if grace && grace_target {
		if grace_target.object_index == obj_box {
			grace_target.x_vel = 0
			grace_target.y_vel = 4;
		}
		if grace_target.object_index == obj_ball {
			//grace_target.x_vel = 0;
			grace_target.y_vel = 4;
		}
	}
	grace = 0;
	grace_target = noone;
	gravity_hold = false;
	//actor_move_y(grace_y - y)
	
	dash_left = defs.dash_total;

	y_vel = min(defs.jump_vel, y_vel);
	x_vel += (defs.jump_move_boost + defs.move_accel) * sign(x_vel);
	
	if x_lift == 0 && y_lift == 0 {
		with instance_place(x, y + 1, obj_Solid) {
			other.x_lift = x_lift;
			other.y_lift = y_lift;
		}
	}
	x_lift = clamp(x_lift, -defs.boost_limit_x, defs.boost_limit_x); // temp
	y_lift = clamp(y_lift, -defs.boost_limit_y, 0);
	x_vel += x_lift;
	y_vel += y_lift;
	lifter = noone;
	
	scale_x = 0.8;
	scale_y = 1.2;
	
	ledge_keybuffer = dir
	
	event.call("jump")
	
	if abs(x_vel) > defs.move_speed + 2
		anim_runjump_timer = 120
	
	game_sound_play(sfx_pop_0);
	
	state.change(state_free);
	
}

jumpbounce = function(_dir){
	
	var _kh = INPUT.check("right") - INPUT.check("left");
	
	buffer = 0
	grace = 0;
	grace_target = noone;
	gravity_hold = false;
	//actor_move_y(grace_y - y)
	
	if dash_recover < 0 {
		dash_left = defs.dash_total;
	}
	
	if _kh == _dir {
		y_vel = min(-6.5, y_vel, -min(abs(x_vel) + 1, 8));
		x_vel = -_dir * 2
		key_hold_timer = 9;
	} else {
		y_vel = min(-6.2, y_vel, -min(abs(x_vel) + 1, 9));
		x_vel = -_dir * 4
		key_hold_timer = 5;
	}
	
	key_hold = -_dir;
	
	
	if x_lift == 0 && y_lift == 0 {
		with instance_place(x + _dir * defs.wall_distance, y, obj_Solid) {
			other.x_lift = x_lift;
			other.y_lift = y_lift;
		}
	}
	x_lift = clamp(x_lift, -defs.boost_limit_x, defs.boost_limit_x); // temp
	y_lift = clamp(y_lift, -defs.boost_limit_y, 0);
	x_vel += x_lift;
	y_vel += y_lift;
	lifter = noone;
	
	scale_x = 0.8;
	scale_y = 1.2;
	
	ledge_keybuffer = _dir
	dir = -_dir;
	
	event.call("jump")
	event.call("jumpbounce")
	
	game_sound_play(sfx_pop_2);
	
	state.change(state_free);
	
}

jumpdash = function(){
	
	var _kh = INPUT.check("right") - INPUT.check("left");
	var _kv = INPUT.check("down") - INPUT.check("up");
	
	if grace && grace_target {
		if grace_target.object_index == obj_box {
			dash_left = defs.dash_total;
			grace_target.x_vel += sign(x_vel) * 3
			grace_target.y_vel = 4;
		}
		if grace_target.object_index == obj_ball {
			dash_left = defs.dash_total;
			grace_target.x_vel += sign(x_vel) * 3
			grace_target.y_vel = 4;
		}
	}
	grace = 0;
	grace_target = noone;
	dash_grace = 0;
	buffer = 0;
	buffer_dash = 0;
	gravity_hold = false;
			
	if dash_dir_y == 0 {
		
		if _kh != dash_dir_x {
			y_vel = -5.4;
			x_vel = dash_dir_x_vel * 0.4
			x_vel = max(abs(x_vel), defs.move_speed) * sign(x_vel);
			gravity_hold = true;
		} else {
			y_vel = defs.jump_vel;
			x_vel = dash_dir_x_vel * 0.8
			x_vel = max(abs(x_vel), defs.move_speed) * sign(x_vel);
		}
		
	} else {
		y_vel = -3
		var _test = abs(dash_dir_x_vel) * 0.7 + 4;
		x_vel = max(abs(x_vel), _test);
		x_vel *= sign(_kh == 0 ? sign(x_vel) : _kh)
		
		key_hold = sign(x_vel);
		key_hold_timer = 6;
	}
	
	if x_lift == 0 && y_lift == 0 {
		with instance_place(x, y + 1, obj_Solid) {
			other.x_lift = x_lift;
			other.y_lift = y_lift;
		}
	}
	x_lift = clamp(x_lift, -defs.boost_limit_x, defs.boost_limit_x); // temp
	y_lift = clamp(y_lift, -defs.boost_limit_y, 0);
	x_vel += x_lift;
	y_vel += y_lift;
	
	scale_x = 0.9;
	scale_y = 1.1;
	
	ledge_keybuffer = dir
	
	event.call("jump")
	event.call("jumpdash")
	
	game_sound_play(sfx_pop_2);
	
	state.change(state_free);
	
}

wallbounce = function(_dir){
	
	buffer = 0
	grace = 0;
	dash_grace = 0;
	gravity_hold = false;
	
	dash_left = defs.dash_total
	
	y_vel = -3
	
	x_vel = 2 * _dir
	x_vel += _dir * 4
	key_hold = sign(x_vel);
	key_hold_timer = 5
	dir = _dir
	
	x_vel += x_lift;
	y_vel += y_lift;
	
	event.call("jump")
	
	state.change(state_free);
	
}

walljump = function(_dir){
	
	buffer = 0
	grace = 0;
	gravity_hold = false;
	//actor_move_y(grace_y - y)
	
	dash_left = defs.dash_total;

	y_vel = defs.jump_vel;
	//x_vel += (defs.jump_move_boost + defs.move_accel) * _dir;
	
	if x_lift == 0 && y_lift == 0 {
		with instance_place(x + _dir * defs.wall_distance, y, obj_Solid) {
			other.x_lift = x_lift;
			other.y_lift = y_lift;
		}
	}
	x_lift = clamp(x_lift, -defs.boost_limit_x, defs.boost_limit_x); // temp
	y_lift = clamp(y_lift, -defs.boost_limit_y, 0);
	x_vel += x_lift;
	y_vel += y_lift;
	
	scale_x = 0.8;
	scale_y = 1.2;
	
	gravity_hold = true;
	
	ledge_keybuffer = dir
	
	event.call("jump")
	
	game_sound_play(sfx_pop_0);
	
	state.change(state_free);
	
};

bounce = function(_dir = 0){
	
	endDash()
	
	state.change(state_free);
	
	grace = 0;
	gravity_hold = false;
	
	dash_left = defs.dash_total;
	
	if _dir == 0 {
	
		dash_grace = 0;
	
		//if INPUT.check("jump")
			y_vel = -8;
		//else
		//	y_vel = -5
	
		scale_x = 0.6;
		scale_y = 1.4;
	
		gravity_hold = true;
	
	} else {
		
		x_vel = _dir * 6.5;
		y_vel = -5;
		
		scale_x = 0.8;
		scale_y = 1.2;
	
		gravity_hold = true;
		
		key_hold = _dir;
		key_hold_timer = 8;
		
	}
	
	
	ledge_keybuffer = dir
	
	event.call("jump")

}

canUncrouch = function(){
	var _last = mask_index;
	mask_index = spr_debug_player;
	var _check = actor_collision(x, y)
	mask_index = _last
	return !_check;
}

#endregion

// state machine

state = new State();

state_base = state.add()
.set("step", function(){
	
	if INPUT.check_pressed("jump") buffer = defs.buffer + 1;
	if INPUT.check_pressed("dash") buffer_dash = defs.buffer + 1;
	
	if place_meeting(x, y, obj_flag_stop) && !state.is(state_stuck) {
		state.change(state_stuck)
	}
	
	if game_paused() {
		return;
	}
	
	buffer -= 1;
	buffer_dash -= 1;
	grace -= 1;
	key_hold_timer -= 1;
	dash_grace -= 1;
	dash_recover -= 1;
	dash_kick_buffer -= 1;
	hold_cooldown -= 1;
	grace_vel_timer -= 1;
	
	if INPUT.check_pressed("jump") || INPUT.check_released("jump") {
		gravity_hold = false;
	}
	
	if !grace {
		grace_target = noone;
	}

	scale_x = lerp(scale_x, 1, 0.2);
	scale_y = lerp(scale_y, 1, 0.2);
	
	x_lift = clamp(x_lift, -defs.boost_limit_x, defs.boost_limit_x);
	y_lift = clamp(y_lift, -defs.boost_limit_y, 0);
	
	state.child();
	
	if crouched {
		mask_index = spr_debug_player_crouch;
	} else {
		mask_index = spr_debug_player;
	}
	
	var _d = 0, _amount = 0;
	var _shifted = false;
	
	if y_vel < 0 && !_shifted {
		_d = 0;
		_amount = 8;
		if actor_collision(x, y + y_vel)
			for (_d = 1; _d < _amount; _d++) {
				if actor_collision(x - _d, y + y_vel) {
				} else break;
			}
		if _d != _amount {
			actor_move_x(-_d)
			_shifted = true;
		}
		
		_d = 0;
		if actor_collision(x, y + y_vel)
			for (_d = 1; _d < _amount; _d++) {
				if actor_collision(x + _d, y + y_vel) {
				} else break;
			}
		if _d != _amount {
			actor_move_x(_d)
			_shifted = true;
		}
	}
	
	static __collide_y = function(){
		if state.is(state_swim) {
			if swim_bullet {
				swim_dir = point_direction(0, 0, x_vel, -y_vel);
			}
		} else {
			if y_vel > 1 {
				game_sound_play(sfx_pop_1);
				scale_x = 1.2;
				scale_y = 0.8;
			}
			y_vel = 0;
		}
	}
	actor_move_y(y_vel, __collide_y);
	
	
	if !_shifted {
		_d = 0;
		_amount = state.is(state_dash) ? 16 : 4;
		if actor_collision(x + x_vel, y)
			for (_d = 1; _d < _amount; _d++) {
				if actor_collision(x + x_vel, y + _d) {
				} else break;
			}
		if _d != _amount {
			actor_move_y(_d)
			_shifted = true;
		}
			
		_d = 0;
		_amount = state.is(state_dash) ? 10 : 2;
		if actor_collision(x + x_vel, y)
			for (_d = 1; _d < _amount; _d++) {
				if actor_collision(x + x_vel, y - _d) {
				} else break;
			}
		if _d != _amount {
			actor_move_y(-_d)
			_shifted = true;
		}
	}

	static __collide_x = function(){
		if state.is(state_swim) {
			if swim_bullet {
				swim_dir = point_direction(0, 0, -x_vel, y_vel);
			}
		} else {
			if abs(x_vel) > 2 {
				grace_vel = x_vel
				grace_vel_timer = 14
			}
			x_vel = 0;
		}
	}
	actor_move_x(x_vel, __collide_x);
	
	static __boxable = [obj_box, obj_ball] // @todo: need to change
	
	if state.is(state_free) || state.is(state_dash) {
		
		if anim_jab_timer && !buffer {		
			var _inst = instance_place(x, y, __boxable);
			if _inst {
				game_set_pause(4)
				
				if dash_dir_y == 0 {
					_inst.x_vel = clamp(abs(_inst.x_vel + sign(x_vel) * 2), 4, 8) * sign(x_vel);
					_inst.y_vel = clamp(_inst.y_vel - 1, -3, -4);
				} else {
					_inst.x_vel = clamp(abs(_inst.x_vel + sign(x_vel) * 1), 3, 6) * sign(x_vel);
					_inst.y_vel = clamp(_inst.y_vel - 1, -5, -7);
				}
				
				anim_jab_timer = 0;
			}
		}
		
		var _inst = instance_place(x, y, obj_dash)
		if dash_left < defs.dash_total && _inst && _inst.state.is(_inst.state_active) {
			game_set_pause(4)
			
			dash_left = defs.dash_total;
			
			_inst.state.change(_inst.state_recover);
		}
		
		var _inst = collision_circle(x, y, 32, __boxable, false, true);
		if _inst && !holding && INPUT.check("grab") && !hold_cooldown {
			game_set_pause(5);
			hold_begin(_inst)
		}
		
	}
	
	if holding {
		anim_holding = approach(anim_holding, 1, 0.1)
		
		var _tp = tail.points[4] //[floor(array_length(tail.points) / 2)];
		var _cx = holding.x;
		var _cy = holding.y + 6;
		var _tx = round(lerp(_cx, _tp.x, anim_holding))
		var _ty = round(lerp(_cy, _tp.y, anim_holding))
		
		with holding {
			x_vel = other.x_vel;
			y_vel = other.y_vel;
			actor_move_x(_tx - _cx)
			actor_move_y(_ty - _cy)
		}
		
	}
	
	if instance_exists(light) {
		light.x = x;
		light.y = y - (crouched ? 8 : 20);
	}
	
	if checkDeath(x, y) {
		game_player_kill()

	}
	
	
	// this will almost certainly cause an issue later. 
	// todo: figure out how to reset a_lift when touching tiles
	x_lift = 0;
	y_lift = 0;
	
	x_delta = x - x_last;
	y_delta = y - y_last;
	
	x_last = x;
	y_last = y;
	
	
	
})

state_stuck = state_base.add()
.set("step", function(){
	x_vel = approach(x_vel, 0, 0.5);
	y_vel = approach(y_vel, defs.terminal_vel, defs.gravity);
	if actor_collision(x, y + 1) {
		state.change(state_free);
	}
})

state_free = state_base.add()
.set("leave", function(){
	gravity_hold = false;
})
.set("step", function(){

	var _kh = INPUT.check("right") - INPUT.check("left");
	var _kv = INPUT.check("down") - INPUT.check("up");
	
	// x direction logic
	
	var _kh_move = _kh;
	if key_hold_timer _kh_move = key_hold;
	if actor_collision(x, y + 1) && crouched _kh_move = 0;
	
	var _x_accel = 0;
	if abs(x_vel) > defs.move_speed && _kh_move == sign(x_vel) {
		_x_accel = defs.move_slowdown;
		if !actor_collision(x, y + 1) {
			momentum_grace = 6;
			_x_accel = defs.move_slowdown_air
		}
	} else {
		_x_accel = defs.move_accel;
		if crouched _x_accel = 0.2
	}
	momentum_grace -= 1;
	if momentum_grace && _kh_move != sign(x_vel) {
		_x_accel = 0;
	}
	
	x_vel = approach(x_vel, _kh_move * defs.move_speed, _x_accel);
	if _kh_move != 0
		dir = _kh_move;
	if crouched && actor_collision(x, y + 1) && _kh != 0 {
		if dir != _kh {
			scale_x = 0.8;
			scale_y = 1.2;
		}
		dir = _kh;
	}
	
	if sign(x_vel) != 0 && sign(x_vel) == -sign(grace_vel) {
		grace_vel = 0;
		grace_vel_timer = 0;
	}
	
	if abs(grace_vel) > 1 && _kh == sign(grace_vel) && grace_vel_timer > 0 {
		if !actor_collision(x + _kh, y) {
			x_vel = grace_vel
			grace_vel = 0
		}
	} else {
		grace_vel = 0
	}
	
	// y direction logic
	
	var _y_accel = 0;
	
	var _jump = INPUT.check("jump");
	if gravity_hold {
		_jump = true;
	}

	if _jump {
		if INPUT.check("jump") && abs(y_vel) < defs.gravity_peak_thresh {
			// peak jump
			_y_accel = defs.gravity_peak;
		} else {
			_y_accel = defs.gravity_hold;
		}
	} else {
		_y_accel = defs.gravity;
	}
	if y_vel >= defs.terminal_vel {
		_y_accel = defs.gravity_term;
	}

	if INPUT.check_released("jump") && y_vel < 0 {
		// release jump damping
		y_vel *= defs.gravity_damp;
	}

	var _term_vel = defs.terminal_vel
	if _kv == 1 {
		_term_vel = defs.terminal_vel_fast
	}
	
	if INPUT.check("jump") {
		_term_vel -= 1
	}
	
	y_vel = approach(y_vel, _term_vel, _y_accel)
	
	// var _wall = actor_collision(x + defs.wall_distance, y) - actor_collision(x - defs.wall_distance, y);
	
	static __boxable = [obj_box, obj_ball] // @todo: need to change
	
	var _inst = collision_circle(x, y, 14, __boxable, false, true);
	if _inst {
		grace = defs.grace;
		grace_target = _inst;
	}
	if actor_collision(x, y + 1) && y_vel >= -1 {
		grace = defs.grace;
		grace_target = noone;
		grace_y = y;
		
		gravity_hold = false;
		
		if dash_recover < 0
			dash_left = defs.dash_total;
		
		event.call("ground")
	}
	
	if dash_grace <= 0 && actor_collision(x, y + 1) {
		if INPUT.check("down") {
			if INPUT.check_pressed("down") {
				scale_x = 1.2;
				scale_y = 0.8;
			}
			crouched = true;
		} else if canUncrouch() {
			if INPUT.check_released("down") {
				scale_x = 0.8;
				scale_y = 1.2;
			}
			crouched = false;
		}
	}
	if crouched && y_vel >= 0 {
		if !INPUT.check("down") && canUncrouch() {
			crouched = false;
			scale_x = 0.8;
			scale_y = 1.2;
		}
	}
	
	
	// hell
	if buffer > 0 {
		if grace > 0 {
			if dash_grace > 0 || buffer_dash > 0 {
				jumpdash()
			} else {
				jump();
				if !INPUT.check("jump") y_vel *= defs.gravity_damp;
			}
		} else {
			
			var _close = actor_collision(x, y + 32) || checkWall(-1, 12) || checkWall(1, 12)
			if _close && dash_grace > 0 {
				dash_grace = 2;
			}
			if dash_grace > 0 && ((_close && grace > 0) || !_close || dash_dir_y == 0) && !checkWall(sign(x_vel)) {
				jumpdash()
			} else if dash_kick_buffer > 0 {
				if checkWall(1)
					jumpbounce(1)
				else if checkWall(-1)
					jumpbounce(-1)
			} else {
				if checkWall(1) {
					if dash_grace > 0 && _kh != dir {
						wallbounce(-1);
					} else {
						walljump(-1);
					}
				} else if checkWall(-1) {
					if dash_grace > 0 && _kh != dir {
						wallbounce(1);
					} else {
						walljump(1);
					}
				}
				
			}
			
		}
		
	}
	
	if buffer_dash > 0 && dash_left > 0 {
		game_set_pause(3);
		state.change(state_dashset);
		return;
	}
	
	if holding && !INPUT.check("grab") {
		game_set_pause(5);
		state.change(state_throw)
		return;
	}
	
	if place_meeting(x, y, obj_water) {
		state.change(state_swim);
		return;
	}
	
	var _kh_p = INPUT.check_pressed("right") - INPUT.check_pressed("left")
	
	if y_vel <= -1 && _kh != 0 {
		ledge_keybuffer = _kh
	}
	
	if y_vel > -1 {
		if !actor_collision(x, y + 1) && actor_collision(x + _kh, y) && !crouched && !INPUT.check("down") &&
			(_kh_p == dir || ledge_keybuffer == dir || (dash_grace > 0 && dash_dir_y == 0 && _kh == dir)) {
			ledge_keybuffer = 0;
			state.change(state_ledge)
			return;
		}
		if y_vel > 3
			ledge_keybuffer = 0;
	}
	
	if INPUT.check_pressed("up") && !crouched && place_meeting(x, y, obj_checkpoint) {
		state.change(state_menu)
		return;
	}
	
})

state_throw = state_base.add()
.set("enter", function(){
	
	var _kh = INPUT.check("right") - INPUT.check("left");
	var _kv = INPUT.check("down") - INPUT.check("up");
	
	key_hold = _kh;
	key_hold_timer = 6;
	
	hold_throw_x = _kh;
	hold_throw_y = _kv;
})
.set("step", function(){
	
	var _kh = INPUT.check("right") - INPUT.check("left");
	var _kv = INPUT.check("down") - INPUT.check("up");
	
	_kh = hold_throw_x;
	_kv = hold_throw_y;
	
	holding.x = x + dir * 4;
	holding.y = y - 12
	
	var _dir = _kh != 0 ? _kh : dir;
	
	if _kh == 0 && _kv == 1 {
		holding.x = x;
		holding.y = y - 4;
		holding.x_vel = 0;
		holding.y_vel = 4;
	} else if _kv == 1 {
		holding.x_vel = _dir * 3 + x_vel / 2;
		holding.y_vel = 4;
	} else if _kh == 0 && _kv == -1 {
		holding.x_vel = 0;
		holding.y_vel = -7;
	} else if _kv == -1 {
		holding.x_vel = _dir * 3 + x_vel / 2;
		holding.y_vel = -5;
	} else {
		holding.x_vel = _dir * 5 + x_vel / 2;
		holding.y_vel = -3;
	}
		
	holding.x_vel = clamp(holding.x_vel, -6, 6)
		
	hold_end()
	
	hold_cooldown = 14;
	grace_target = noone;
	
	state.change(state_free)
})

state_ledge = state_base.add()
.set("enter", function(){
	ledge_stick = 1;
})
.set("leave", function(){
	ledge_stick = 0;
})
.set("step", function(){
	
	var _kh = INPUT.check("right") - INPUT.check("left");
	var _kv = INPUT.check("down") - INPUT.check("up");
	
	x_vel = dir;
	
	y_vel = 0;
	if !actor_collision(x + dir, y - 22) {
		y_vel = 1
	} else {
		if !actor_collision(x + dir, y - 20) {
			y_vel = -1
		}
	}
	
	event.call("ledge");
	
	dash_left = defs.dash_total
	
	if buffer > 0 {
		walljump(dir);
		return;
	}
	
	if buffer_dash > 0 && dash_left > 0 {
		game_set_pause(3);
		state.change(state_dashset);
		return;
	}
	
	if !actor_collision(x + dir, y) {
		state.change(state_free);
		return;
	}
	if y_delta == 0 && actor_collision(x, y + 1) {
		state.change(state_free);
		return;
	}
	
	if _kh != dir {
		ledge_stick -= 1;
	} else {
		ledge_stick = 4;
	}
	if _kh != dir && ledge_stick <= 0 {
		grace = defs.grace
		state.change(state_free);
		return;
	}
	
})

state_dashset = state_base.add()
.set("step", function(){
	buffer_dash = 0;
	
	var _kh = INPUT.check("right") - INPUT.check("left");
	var _kv = INPUT.check("down") - INPUT.check("up");
	
	if _kh == 0
		dash_dir_x = dir;
	else
		dash_dir_x = _kh;
	
	dash_dir_y = _kv;
	
	if false && _kv == -1 {
		x_vel = max(abs(x_vel), 6, 4 + min(abs(x_vel), 4));
		x_vel *= dash_dir_x
		y_vel = -4;
		
		gravity_hold = 24;
		key_hold_timer = 14;
		key_hold = dash_dir_x;
		
		dash_kick_buffer = 16;
		dash_recover = 8;
		
		dash_left -= 1;
		
		event.call("dive");
		state.change(state_free);
		
		return;
	}
	
	game_sound_play(sfx_dash);
	
	state.change(state_dash);
})

endDash = function(){
	
	if !state.is(state_dash) return;
	
	grace = 0;
	gravity_hold = true
	
	x_vel = max(abs(x_vel), defs.move_speed) * sign(x_vel);
	
	if dash_dir_y == 0 {
		x_vel = lerp(abs(x_vel), abs(dash_start_x_vel), 0.8) * sign(x_vel);
		y_vel = -0.25;
	} else if dash_dir_y == -1  {
		x_vel = lerp(abs(x_vel), abs(dash_start_x_vel), 0.6) * sign(x_vel);
		key_hold_timer = 4;
		key_hold = dash_dir_x;
		
		dash_kick_buffer = 8;
		dash_recover = 3;
	} else {
		x_vel = lerp(abs(x_vel), abs(dash_start_x_vel), 0.2) * sign(x_vel);
		//x_vel *= 0.9;
	}
	
}


state_dash = state_base.add()
.set("enter", function(){
	dash_timer = 6;
	dash_left -= 1;
	
	dash_start_x_vel = x_vel;
	dash_start_y_vel = y_vel;
	
	var _x_vel = x_vel;
	
	if dash_dir_x == sign(x_vel) {
		x_vel *= 0.50;
	} else {
		if dash_dir_y == -1 {
			x_vel = abs(x_vel) * dash_dir_x * 0.75;
		} else {
			x_vel = abs(x_vel) * dash_dir_x * 0.9;
		}
	}
	y_vel = 0;
	var _dir = point_direction(0, 0, dash_dir_x, dash_dir_y);
	dash_dir_x_vel = lengthdir_x(7, _dir);
	dash_dir_y_vel = lengthdir_y(6, _dir);
	x_vel += dash_dir_x_vel;
	y_vel += dash_dir_y_vel;
	
	x_vel = max(abs(x_vel), abs(_x_vel)) * sign(x_vel)
	
	if dash_dir_y == -1 {
		y_vel *= 0.75
	}
	
	dir = sign(x_vel)
	
	dash_recover = dash_timer
	
	event.call("dive")
})
.set("leave", function(){
	
	if dash_dir_y != -1 {
		dash_recover = 2;
		dash_grace = 8;
	} else {
		dash_grace = 4;
	}
	
	if canUncrouch() {
		crouched = false
	}
})
.set("step", function(){
	
	var _kh = INPUT.check("right") - INPUT.check("left");
	var _kv = INPUT.check("down") - INPUT.check("up");
	
	if actor_collision(x, y + 1) {
		grace = defs.grace;
		grace_y = y;
	}
	
	//actor_move_y(y_vel);

	//actor_move_x(x_vel);
	
	if buffer > 0 {
		if grace > 0 {
			if _kh != dir && dash_timer <= 3 {
				jumpdash();
				return;
			} else if _kh == dir {
				jumpdash();
				return;
			}
		} else {
			if checkWall(dir) {
				//if _kh != dir
				//	wallbounce(-dir);
				//else
				if dash_dir_y == -1
					jumpbounce(dir)
				else walljump(-dir);
				return;
			}
			if _kh != dir && dash_timer <= 1 {
				jumpdash();
				return;
			}
		}
	}
	
	dash_timer -= 1;
	if dash_timer <= 0 {
		endDash()
		
		state.change(state_free);
		return;
	}
	
})

state_swim = state_base.add()
.set("enter", function(){
	if !swim_bullet_check {
		swim_dir = point_direction(0, 0, x_vel, y_vel);
		swim_spd = point_distance(0, 0, x_vel, y_vel);
		swim_bullet = false;
		if dash_grace > 0 {
			game_set_pause(3)
			dash_grace = 0;
			swim_bullet = true;
			swim_spd = max(swim_spd + 1, 8);
		
		} else {
			if swim_spd > 5 {
				swim_spd = max(5, swim_spd * 0.8)
			}
		}
	} else {
		swim_bullet_check = false;
	}
	
})
.set("step", function(){
	
	var _push_x = place_meeting(x + 16, y, obj_water) - place_meeting(x - 16, y, obj_water);
	var _push_y = place_meeting(x, y + 24, obj_water) - place_meeting(x, y - 24, obj_water);
	
	var _kh = INPUT.check("right") - INPUT.check("left");
	var _kv = INPUT.check("down") - INPUT.check("up");
	
	var _kh_r = INPUT.check_raw("horizontal");
	var _kv_r = INPUT.check_raw("vertical");

	var _k_dir = point_direction(0, 0, _kh_r, _kv_r)
	
	var _dir_target = _k_dir;
	if _kh == 0 && _kv == 0 _dir_target = swim_dir;
	var _dir_diff = angle_difference(swim_dir, _dir_target)
	
	if _kh != 0 dir = _kh
	
	
	var _spd_target_normal = point_distance(0, 0, _kh_r, _kv_r);
	var _dir_accel;
	
	if canUncrouch() {
		crouched = false
	}
	
	
	if !swim_bullet {
		if _spd_target_normal < 0.1 {
			swim_spd = approach(swim_spd, 0, 0.4)
		} else {
			swim_spd = approach(swim_spd, 4, swim_spd > 4 ? 0.02 : 0.3)
		}
		_dir_accel = 360 - round(360 * clamp(swim_spd / 4, 0, 0.98))
	} else {
		swim_spd = approach(swim_spd, max(swim_spd, 8), 1)
		_dir_accel = 2
	}
	
	swim_dir -= clamp(round(sign(_dir_diff) * _dir_accel), -abs(_dir_diff), abs(_dir_diff));
	
	x_vel = lengthdir_x(swim_spd, swim_dir) + _push_x
	y_vel = lengthdir_y(swim_spd, swim_dir) + _push_y
	
	dash_left = defs.dash_total
	
	if buffer_dash >= 0 {
		game_set_pause(3)
		state.change(state_swimbulletset);
		return;
	}
	
	if !place_meeting(x, y, obj_water) {
		grace = defs.grace;
		gravity_hold = true;
		y_vel += -1;
		
		if swim_bullet {
			x_vel *= 1;
			y_vel *= 1.2;
			swim_bullet = false;
		}
		
		state.change(state_free);
		
		return;
	}
	
	//x_vel = _push_x;
	//y_vel = _push_y;
	

})

state_swimbulletset = state_base.add()
.set("step", function(){
	var _kh = INPUT.check("right") - INPUT.check("left");
	var _kv = INPUT.check("down") - INPUT.check("up");
	
	buffer_dash = 0;
	
	swim_spd = max(swim_spd + 1 * +!swim_bullet, 8);
	
	swim_dir = point_direction(0, 0, _kh, _kv);
	if _kh == 0 && _kv == 0 swim_dir = point_direction(0, 0, dir, 0);
	
	swim_bullet = true;
	swim_bullet_check = true;
	
	state.change(state_swim);
})

state_menu = state_base.add()
.set("enter", function(){
	with obj_menu system.open(page_none);
})
.set("step", function(){
	x_vel = approach(x_vel, 0, defs.move_accel);
	y_vel = approach(y_vel, defs.terminal_vel, defs.gravity);
	
	buffer_dash = 0;
	buffer = 0;
	
	with obj_menu system.update();
	
	if array_length(obj_menu.system.stack) == 0 {
		obj_menu.system.stop();
		state.change(state_free);
		return;
	}
	
	if !place_meeting(x, y, obj_checkpoint) {
		obj_menu.system.stop();
		state.change(state_free);
		return;
	}
	
})


state.change(state_free);

squish = function(){
	game_player_kill()
}

riding = function(_solid){
	return place_meeting(x, y + 1, _solid) || (state.is(state_ledge) && place_meeting(x + dir, y, _solid))
}

cam = function(){
	
	if (state.is(state_free) && actor_collision(x, y + 1)) {
		cam_ground_x = x + dir * 64;
		cam_ground_y = y - 32;
	}
	
	var _dist = point_distance(cam_ground_x, cam_ground_y, x, y);
	
	var _x = x + power(abs(x_vel), 1.4) * sign(x_vel);
	var _y = y - 32;
	
	/*
	if state.is(state_menu) {
		_x += 48 + (array_length(menu.stack) - 1) * 12;
		_y += -4;
	}*/
	
	camera.target_x = lerp(cam_ground_x, _x, 1 - max(0, 1 - power(_dist / 64, 2)) * 0.0);
	camera.target_y = lerp(cam_ground_y, _y, 1 - max(0, 1 - power(_dist / 128, 2)) * 0.8);
	
}

outside = function() { return false; };



