
event_inherited();


// behaviour

defs = {
	
	move_speed: 2,
	move_accel: 1,
	move_slowdown: 0.1,
	
	jump_vel: -4,
	jump_move_boost: 0.4,
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
buffer = 0;

gravity_hold = 0;

climb_away = 0;

dash_dir_x = 0;
dash_dir_y = 0;
dash_timer = 0;
dash_jump_grace = 0;


f_dashjump = function(){
	var _kh = input.right - input.left;
	var _kv = input.down - input.up;
	
	grace = 0;
	buffer = 0;
	gravity_hold = 0;
			
	if dash_dir_y == 0 {
		if _kh != dash_dir_x {
			y_vel = -5.4;
			x_vel *= 0.4
			x_vel = max(abs(x_vel), defs.move_speed) * sign(x_vel);
		} else {
			y_vel = defs.jump_vel;
			x_vel *= 0.8
			x_vel = max(abs(x_vel), defs.move_speed) * sign(x_vel);
		}
	} else {
		y_vel = -3;
		x_vel *= 0.7
		x_vel += (_kh == 0 ? dash_dir_x : _kh) * 4
	}
}

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
	
	buffer -= 1;
	grace -= 1;
	gravity_hold -= 1;
	dash_jump_grace -= 1;

	if input.jump_pressed buffer = defs.buffer;

	scale_x = lerp(scale_x, 1, 0.2);
	scale_y = lerp(scale_y, 1, 0.2);
	
	state.child();
	
})

state_free = state_base.add()
.set("step", function(){

	var _kh = input.right - input.left;
	var _kv = input.down - input.up;
	
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
	
	var _wall = place_meeting(x + defs.wall_distance, y, obj_wall) - place_meeting(x - defs.wall_distance, y, obj_wall);
	
	if place_meeting(x, y + 1, obj_wall) || _wall != 0 {
		grace = defs.grace;
		grace_y = y;
	}
	
	if grace > 0 {
		
		if buffer > 0 {
			
			if dash_jump_grace <= 0 {
				buffer = 0
				grace = 0;
				gravity_hold = 0;
				actor_move_y(grace_y - y)
			
				y_vel = defs.jump_vel;
				x_vel += (defs.jump_move_boost + defs.move_accel) * sign(x_vel);
			
				scale_x = 0.8;
				scale_y = 1.2;
			} else {
				f_dashjump()
			}
		
		}
		
	}
	
	if _wall != 0 {
		if !place_meeting(x, y + 1, obj_wall) && _kh == _wall && y_vel > 0 {
			dir = _wall;
			state.change(state_climb);
		}
	}
	
	// x direction logic
	
	var _x_accel = 0;
	if abs(x_vel) > defs.move_speed && _kh == sign(x_vel) {
		_x_accel = defs.move_slowdown;
	} else {
		_x_accel = defs.move_accel;
	}
	
	x_vel = approach(x_vel, _kh * defs.move_speed, _x_accel);
	if _kh != 0
		dir = _kh;
	
	
	if input.dash_pressed {
		if _kh == 0
			dash_dir_x = dir;
		else
			dash_dir_x = _kh;
		
		dash_dir_y = _kv == 1 ? 1 : 0;
		
		state.change(state_dash)
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
	
	
})

state_climb = state_base.add()
.set("step", function(){
	
	var _kh = input.right - input.left;
	var _kv = input.down - input.up;
	
	// y direction logic
	
	y_vel = approach(y_vel, _kv * defs.climb_speed, defs.climb_accel);
	
	x_vel = dir * defs.move_speed;
	
	actor_move_y(y_vel, function(){
		y_vel = 0;
	});

	actor_move_x(x_vel, function(){
		x_vel = 0;
	});
	
	var _wall = place_meeting(x + dir, y, obj_wall);
	
	if !_wall {
		grace = 0;
		state.change(state_free);
	} else {
		grace = defs.grace
		grace_y = y;
	}
	
	if _kh != 0 && _kh != dir {
		climb_away += 1;
	} else {
		climb_away = 0;
	}
	if climb_away > defs.climb_leave {
		state.change(state_free)
	}
	
	if buffer >= 0 {
		buffer = 0;
		grace = 0;
		
		y_vel = defs.jump_vel;
		x_vel = (defs.jump_move_boost + defs.move_speed) * sign(_kh);
		
		scale_x = 0.8;
		scale_y = 1.2;
		
		state.change(state_free)
	}
	
})

state_dash = state_base.add()
.set("enter", function(){
	dash_timer = 6;
	x_vel *= 0.5;
	y_vel = 0;
	var _dir = point_direction(0, 0, dash_dir_x, dash_dir_y);
	x_vel += lengthdir_x(7, _dir);
	y_vel += lengthdir_y(6, _dir);
})
.set("step", function(){
	
	var _kh = input.right - input.left;
	var _kv = input.down - input.up;
	
	if place_meeting(x, y + 1, obj_wall) {
		grace = defs.grace;
	}
	
	var _jumped = false;
	
	if grace > 0 {
		if buffer > 0 {
			f_dashjump()
			
			_jumped = true;
			state.change(state_free);
		}
	}
	
	actor_move_y(y_vel, function(){
		y_vel = 0;
	});

	actor_move_x(x_vel, function(){
		x_vel = 0;
	});
	
	dash_timer -= 1;
	if dash_timer <= 0 && !_jumped {
		grace = 0;
		gravity_hold = 8
		dash_jump_grace = 6;
		
		if dash_dir_y == 0
			x_vel = clamp(x_vel * 0.5, -4, 4);
		else
			x_vel *= 0.8;
		x_vel = max(abs(x_vel), defs.move_speed) * sign(x_vel);
		state.change(state_free);
	}
	
})

state.change(state_free);
