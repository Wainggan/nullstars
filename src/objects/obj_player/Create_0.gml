
event_inherited();


// behaviour

defs = {
	
	move_speed: 2,
	move_accel: 1,
	move_slowdown: 0.1,
	
	boost_limit_x: 9,
	boost_limit_y: 3,
	
	jump_vel: -4,
	jump_move_boost: 0.2,
	terminal_vel: 4,
	
	jump_short_vel: -3,
	
	gravity: 0.45,
	gravity_hold: 0.2,
	gravity_peak: 0.1,
	gravity_peak_thresh: 0.36,
	
	gravity_damp: 0.8,
	
	wall_distance: 4,
	
	climb_speed: 2,
	climb_accel: 1,
	climb_slide: 0.1,
	climb_leave: 8,
	
	dash_timer: 6,
	dash_total: 1,
	
	buffer: 12,
	grace: 4,
	
};

input = {
	left: false,
	right: false,
	up: false,
	down: false,
	jump: false,
	jump_pressed: false,
	jump_released: false,
	dash: false,
	dash_pressed: false,
	dash_released: false,
};


// properties

scale_x = 0;
scale_y = 0;

dir = 0;

grace = 0;
grace_y = y;
grace_solid = noone;
buffer = 0;

gravity_hold = 0;

key_hold = 0;
key_hold_timer = 0;

climb_away = 0;

dash_dir_x = 0;
dash_dir_x_vel = 0;
dash_dir_y = 0;
dash_dir_y_vel = 0;
dash_timer = 0;
dash_grace = 0;
dash_recover = 0;

dash_left = 0;

cam_ground_x = x;
cam_ground_y = y;


checkWall = function(_dir){
	return actor_collision(x + _dir * defs.wall_distance, y);
}

jump = function(){
	
	buffer = 0
	grace = 0;
	gravity_hold = 0;
	//actor_move_y(grace_y - y)
	
	dash_left = defs.dash_total;

	y_vel = defs.jump_vel;
	x_vel += (defs.jump_move_boost + defs.move_accel) * sign(x_vel);
	
	if x_lift == 0 && y_lift == 0 {
		with grace_solid {
			other.x_lift = x_lift;
			other.y_lift = y_lift;
		}
	}
	x_vel += x_lift;
	y_vel += y_lift;
	
	scale_x = 0.8;
	scale_y = 1.2;
	
	state.change(state_free);
	
}

jumpdash = function(){
	
	var _kh = input.right - input.left;
	var _kv = input.down - input.up;
	
	grace = 0;
	dash_grace = 0;
	buffer = 0;
	gravity_hold = 0;
			
	if dash_dir_y == 0 {
		
		if _kh != dash_dir_x {
			y_vel = -5.4;
			x_vel = dash_dir_x_vel * 0.4
			x_vel = max(abs(x_vel), defs.move_speed) * sign(x_vel);
		} else {
			y_vel = defs.jump_vel;
			x_vel = dash_dir_x_vel * 0.8
			x_vel = max(abs(x_vel), defs.move_speed) * sign(x_vel);
		}
		
	} else {
		y_vel = -3
		x_vel = abs(dash_dir_x_vel) * 0.7 * sign(_kh == 0 ? sign(x_vel) : _kh)
		x_vel += (_kh == 0 ? dir : _kh) * 4
	}
	
	x_vel += x_lift;
	y_vel += y_lift;
	
	state.change(state_free);
	
}

wallbounce = function(_dir){
	
	buffer = 0
	grace = 0;
	dash_grace = 0;
	gravity_hold = 0;
	
	y_vel = -3
	
	x_vel = 2 * _dir
	x_vel += _dir * 4
	key_hold = sign(x_vel);
	key_hold_timer = 5
	
	x_vel += x_lift;
	y_vel += y_lift;
	
	state.change(state_free);
	
}

walljump = jump;

// state machine

state = new State();

state_base = state.add()
.set("step", function(){
	
	input.left = keyboard_check(vk_left);
	input.right = keyboard_check(vk_right);
	input.up = keyboard_check(vk_up);
	input.down = keyboard_check(vk_down);

	input.jump = keyboard_check(ord("X"));
	input.jump_pressed = keyboard_check_pressed(ord("X"));
	input.jump_released = keyboard_check_released(ord("X"));
	
	input.dash = keyboard_check(ord("Z"));
	input.dash_pressed = keyboard_check_pressed(ord("Z"));
	input.dash_released = keyboard_check_released(ord("Z"));
	
	if input.jump_pressed buffer = defs.buffer + 1;
	
	if game_paused() {
		return;
	}
	
	buffer -= 1;
	grace -= 1;
	gravity_hold -= 1;
	key_hold_timer -= 1;
	dash_grace -= 1;
	dash_recover -= 1;

	scale_x = lerp(scale_x, 1, 0.2);
	scale_y = lerp(scale_y, 1, 0.2);
	
	x_lift = clamp(x_lift, -defs.boost_limit_x, defs.boost_limit_x);
	y_lift = clamp(y_lift, -defs.boost_limit_y, 0);
	
	state.child();
	
	// this will almost certainly cause an issue later. 
	// todo: figure out how to reset a_lift when touching tiles
	x_lift = 0;
	y_lift = 0;
	
})

state_free = state_base.add()
.set("step", function(){

	var _kh = input.right - input.left;
	var _kv = input.down - input.up;
	
	// x direction logic
	
	var _kh_move = _kh;
	if key_hold_timer _kh_move = key_hold;
	
	var _x_accel = 0;
	if abs(x_vel) > defs.move_speed && _kh_move == sign(x_vel) {
		_x_accel = defs.move_slowdown;
	} else {
		_x_accel = defs.move_accel;
	}
	
	x_vel = approach(x_vel, _kh_move * defs.move_speed, _x_accel);
	if _kh != 0
		dir = _kh;
	
	// y direction logic
	
	var _y_accel = 0;

	if input.jump {
		if abs(y_vel) < defs.gravity_peak_thresh {
			// peak jump
			_y_accel = defs.gravity_peak;
		} else {
			_y_accel = defs.gravity_hold;
		}
	} else {
		_y_accel = defs.gravity;
	}
	if gravity_hold > 0 {
		_y_accel = defs.gravity_peak;
	}

	if input.jump_released && y_vel < 0 {
		// release jump damping
		y_vel *= defs.gravity_damp;
	}

	y_vel += _y_accel

	y_vel = min(y_vel, defs.terminal_vel);
	
	var _wall = actor_collision(x + defs.wall_distance, y) - actor_collision(x - defs.wall_distance, y);
	
	if actor_collision(x, y + 1) {
		grace = defs.grace;
		grace_y = y;
		
		if dash_recover < 0
			dash_left = defs.dash_total;
	}
	
	
	// hell
	if buffer > 0 {
		
		if grace > 0 {
			if dash_grace > 0 {
				jumpdash()
			} else {
				jump()
			}
		} else {
			
			var _close = actor_collision(x, y + 32)
			if _close && dash_grace > 0 {
				dash_grace = 2;
			}
			if dash_grace > 0 && ((_close && grace > 0) || !_close || dash_dir_y == 0) && !checkWall(sign(x_vel)) {
				jumpdash()
			} else {
				
				if checkWall(1) {
					if dash_grace > 0 {
						wallbounce(-1);
					} else {
						walljump();
					}
				} else if checkWall(-1) {
					if dash_grace > 0 {
						wallbounce(1);
					} else {
						walljump();
					}
				}
				
			}
			
		}
		
	}
	
	if _wall != 0 {
		if !actor_collision(x, y + 1) && _kh == _wall && y_vel > 0 {
			dir = _wall;
			state.change(state_climb);
		}
	}
	

	// move
	
	actor_move_y(y_vel, function(){
		if y_vel > 1.5 {
			scale_x = 1.2;
			scale_y = 0.8;
		}
		y_vel = 0;
	});

	actor_move_x(x_vel, function(){
		x_vel = 0;
	});
	
	if input.dash_pressed && dash_left > 0 {
		game_set_pause(3);
		state.change(state_dashset);
		return;
	}
	
})

state_climb = state_base.add()
.set("step", function(){
	
	var _kh = input.right - input.left;
	var _kv = input.down - input.up;
	
	// y direction logic
	
	y_vel = approach(y_vel, _kv * defs.climb_speed, defs.climb_accel);
	
	x_vel = dir * defs.move_speed;
	
	dash_left = defs.dash_total;
	
	actor_move_y(y_vel, function(){
		y_vel = 0;
	});

	actor_move_x(x_vel, function(){
		x_vel = 0;
	});
	
	var _wall = actor_collision(x + dir, y);
	
	if input.dash_pressed && dash_left > 0 {
		game_set_pause(3)
		state.change(state_dashset)
		return;
	}
	
	if !_wall {
		grace = 0;
		state.change(state_free);
		return;
	} else {
		grace = defs.grace
		grace_y = y;
	}
	
	if _kh != dir {
		climb_away += 1;
	} else {
		climb_away = 0;
	}
	if climb_away > defs.climb_leave {
		state.change(state_free)
		return;
	}
	
	if buffer > 0 {
		walljump();
		return;
	}
	
})

state_dashset = state_base.add()
.set("step", function(){
	var _kh = input.right - input.left;
	var _kv = input.down - input.up;
	
	if _kh == 0
		dash_dir_x = dir;
	else
		dash_dir_x = _kh;
	
	dash_dir_y = _kv == 1 ? 1 : 0;
	
	state.change(state_dash);
})

state_dash = state_base.add()
.set("enter", function(){
	dash_timer = 6;
	dash_left -= 1;
	
	x_vel *= 0.5;
	y_vel = 0;
	var _dir = point_direction(0, 0, dash_dir_x, dash_dir_y);
	dash_dir_x_vel = lengthdir_x(7, _dir);
	dash_dir_y_vel = lengthdir_y(6, _dir);
	x_vel += dash_dir_x_vel;
	y_vel += dash_dir_y_vel;
	
	dir = sign(x_vel)
})
.set("leave", function(){
	dash_grace = 8;
	dash_recover = 1;
})
.set("step", function(){
	
	var _kh = input.right - input.left;
	var _kv = input.down - input.up;
	
	if actor_collision(x, y + 1) {
		grace = defs.grace;
		grace_y = y;
	}
	
	actor_move_y(y_vel);

	actor_move_x(x_vel);
	
	if buffer > 0 {
		if grace > 0 {
			if _kh == dir {
				jumpdash();
				return;
			}
		} else {
			if checkWall(dir) {
				wallbounce(-dir);
				return;
			}
		}
	}
	
	dash_timer -= 1;
	if dash_timer <= 0 {
		grace = 0;
		gravity_hold = 8
		
		if dash_dir_y == 0
			x_vel = clamp(x_vel * 0.5, -4, 4);
		else
			x_vel *= 0.8;
		x_vel = max(abs(x_vel), defs.move_speed) * sign(x_vel);
		
		state.change(state_free);
		return;
	}
	
})

state.change(state_free);


riding = function(_solid){
	return place_meeting(x, y + 1, _solid) || (state.is(state_climb) && place_meeting(x + dir, y, _solid))
}

cam = function(){
	
	if (state.is(state_free) && actor_collision(x, y + 1)) || state.is(state_climb) {
		cam_ground_x = x + dir * 32;
		cam_ground_y = y;
	}
	
	var _dist = point_distance(cam_ground_x, cam_ground_y, x, y);
	
	camera.target_x = lerp(cam_ground_x, x, 1 - max(0, 1 - power(_dist / 64, 2)) * 0.2);
	camera.target_y = lerp(cam_ground_y, y, 1 - max(0, 1 - power(_dist / 128, 2)) * 0.8);
	
}


