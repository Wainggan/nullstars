
if instance_number(obj_player) > 1 {
	instance_destroy();
	exit;
}

event_inherited();

defs = {
	move_speed: 2,
	move_accel: 0.5,
	move_slowdown: 0.08,
	move_slowdown_air: 0.04,
	
	gravity: 0.45,
	gravity_hold: 0.3,
	gravity_peak: 0.12,
	gravity_peak_thresh: 0.36,
	gravity_term: 0.12,
	
	boost_limit_x: 9,
	boost_limit_y: 3,
	
	jump_vel: -4.8,
	jump_damp: 0.6,
	jump_move_boost: 0.2,
	
	terminal_vel: global.defs.terminal_vel,
	terminal_vel_fast: 6,
	
	buffer: 10,
	grace: 10,
};


scale_x = 0;
scale_y = 0;

x_last = x;
y_last = y;

x_delta = 0;
y_delta = 0;

dir = 1;


buffer_jump = 0;
buffer_dash = 0;

nat_crouch = function(_value = undefined) {
	if _value != undefined {
		if _value {
			mask_index = spr_debug_player_crouch;
		} else {
			mask_index = spr_debug_player;
		}
	}
	return mask_index == spr_debug_player_crouch;
};
nat_crouch(false);

get_can_uncrouch = function() {
	if !nat_crouch() return true;
	var _pre = mask_index;
	mask_index = spr_debug_player;
	var _collide = actor_collision(x, y);
	mask_index = _pre;
	return !_collide;
};

onground = false;
onground_last = false;

grace = 0;

vel_keygrace = 0;
vel_grace = 0;
vel_grace_timer = 0;

hold_jump = false;
hold_jump_vel = 0;
hold_jump_timer = 0;


get_lift_x = function() {
	var _out = actor_lift_get_x();
	return clamp(_out, -defs.boost_limit_x, defs.boost_limit_x);
};
get_lift_y = function() {
	var _out = actor_lift_get_y();
	return clamp(_out, -defs.boost_limit_y, 0);
};


action_jump = function() {
	
	var _kh = round(INPUT.check_raw("horizontal"));
	var _kv = round(INPUT.check_raw("vertical"));
	
	buffer_jump = false;
	grace = false;
	
	if _kh != 0 && abs(x_vel) < defs.move_speed {
		x_vel = defs.move_speed * _kh;
	}
	x_vel += (defs.jump_move_boost + defs.move_accel) * _kh;
	y_vel = min(y_vel, defs.jump_vel);
	
	hold_jump = false;
	hold_jump_vel = y_vel;
	hold_jump_timer = 4;
	
	x_vel += get_lift_x();
	y_vel += get_lift_y();
	
	scale_x = 0.8;
	scale_y = 1.2;
	
};

state = new State();

state_base = state.add()
.set("step", function () {
	
	buffer_jump -= 1;
	buffer_dash -= 1;
	if INPUT.check_pressed("jump") buffer_jump = defs.buffer + 1;
	if INPUT.check_pressed("dash") buffer_dash = defs.buffer + 1;
	
	x_delta = x - x_last;
	y_delta = y - y_last;
	
	x_last = x;
	y_last = y;
	
	scale_x = lerp(scale_x, 1, 0.2);
	scale_y = lerp(scale_y, 1, 0.2);
	
	if y_vel >= 0 {
		onground = actor_collision(x, y + 1);
	} else {
		onground = false;
	}
	
	grace -= 1;
	if onground {
		grace = defs.grace;
	}
	
	state.child();
	
	
	static __collide_y = function() {
		y_vel = 0;
	};
	actor_move_y(y_vel, __collide_y);
	
	static __collide_x = function() {
		if vel_grace_timer <= 0 {
			vel_grace_timer = 14;
			vel_grace = x_vel;
		}
		x_vel = 0;
	};
	actor_move_x(x_vel, __collide_x);
	
	actor_lift_update();
	
	onground_last = onground;
	
});


state_free = state_base.add()
.set("step", function () {
	
	var _kh = round(INPUT.check_raw("horizontal"));
	var _kv = round(INPUT.check_raw("vertical"));
	
	var _k_move = _kh;
	if onground && nat_crouch() {
		_k_move = 0;
	}
	
	if vel_grace_timer > 0 {
		vel_grace_timer -= 1;
		if x_vel != 0 && sign(x_vel) == -sign(vel_grace) {
			vel_grace_timer = 0;
		} else if !actor_collision(x + _kh, y) {
			x_vel = vel_grace;
			vel_grace_timer = 0;
		}
	}
	
	var _x_accel = 0;
	if abs(x_vel) > defs.move_speed && _k_move == sign(x_vel) {
		_x_accel = defs.move_slowdown;
		if !onground {
			vel_keygrace = 6;
			_x_accel = defs.move_slowdown_air;
		}
	} else {
		_x_accel = defs.move_accel;
		if nat_crouch() _x_accel = 0.2;
	}
	
	vel_keygrace -= 1;
	if vel_keygrace > 0 && _k_move != sign(x_vel) {
		if onground {
			_x_accel = defs.move_slowdown;
		} else {
			_x_accel = defs.move_slowdown_air;
		}
	}
	
	x_vel = approach(x_vel, _k_move * defs.move_speed, _x_accel);
	
	if _kh != 0 {
		if dir != _kh && onground && nat_crouch() {
			scale_x = 0.8;
			scale_y = 1.2;
		}
		dir = _kh;
	}
	
	var _k_jump = INPUT.check("jump");
	if hold_jump {
		_k_jump = true;
	}
	
	var _y_accel = 0;
	
	if _k_jump {
		if abs(y_vel) < defs.gravity_peak_thresh {
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
		y_vel *= defs.jump_damp;
	}
	
	var _termvel = defs.terminal_vel;
	if _kv == 1 {
		_termvel = defs.terminal_vel_fast;
	}
	
	if INPUT.check("jump") {
		_termvel -= 1;
	}
	
	if hold_jump_timer > 0 {
		hold_jump_timer -= 1;
		if _k_jump {
			y_vel = min(y_vel, hold_jump_vel);
		} else {
			hold_jump = false;
			hold_jump_timer = 0;
		}
	} else {
		hold_jump = false;
	}
	
	if !onground {
		y_vel = approach(y_vel, _termvel, _y_accel);
	}
	
	if nat_crouch() {
		if get_can_uncrouch() {
			if onground && !INPUT.check("down") {
				nat_crouch(false);
				scale_x = 0.8;
				scale_y = 1.2;
			}
			if !onground && y_vel >= 0 && !INPUT.check("down") {
				nat_crouch(false);
				scale_x = 0.8;
				scale_y = 1.2;
			}
		}
	} else {
		if onground && INPUT.check("down") {
			nat_crouch(true);
			scale_x = 1.2;
			scale_y = 0.8;
		}
	}
	
	if buffer_jump > 0 {
		if grace > 0 {
			action_jump();
			if !INPUT.check("jump") {
				y_vel *= defs.jump_damp;
			}
		}
	}
	
});

squish = function(){
	game_player_kill();
};

riding = function(_solid){
	return place_meeting(x, y + 1, _solid) || false && (state.is(state_ledge) && place_meeting(x + dir, y, _solid));
};


state.change(state_free);

