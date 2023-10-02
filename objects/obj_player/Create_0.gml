
event_inherited();


// behaviour

defs = {
	
	move_speed: 2,
	move_accel: 1,
	
	jump_vel: -4,
	jump_move_boost: 0.5,
	terminal_vel: 4,
	
	gravity: 0.45,
	gravity_hold: 0.2,
	gravity_peak: 0.1,
	gravity_peak_thresh: 0.36,
	
	gravity_damp: 0.8,
	
	wall_distance: 4,
	
	climb_speed: 2,
	climb_accel: 1,
	climb_slide: 0.1,
	
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
};


// properties

scale_x = 0;
scale_y = 0;

dir = 0;

grace = 0;
grace_y = y;
buffer = 0;

climb_away = 0;

// state machine

state = new State();

state_base = state.add()
.set("step", function(){
	
	input.left = keyboard_check(vk_left);
	input.right = keyboard_check(vk_right);
	input.up = keyboard_check(vk_up);
	input.down = keyboard_check(vk_down);

	input.jump = keyboard_check(ord("Z"));
	input.jump_pressed = keyboard_check_pressed(ord("Z"));
	input.jump_released = keyboard_check_released(ord("Z"));
	
	buffer -= 1;
	grace -= 1;

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

	if input.jump_released && y_vel < 0 {
		// release jump damping
		y_vel *= defs.gravity_damp;
	}

	y_vel += _y_accel

	y_vel = min(y_vel, defs.terminal_vel);

	if place_meeting(x, y + 1, obj_wall) {
		grace = defs.grace;
		grace_y = y;
	}

	if grace > 0 {
		if buffer > 0 {
			buffer = 0;
			grace = 0;
			y = grace_y; // may cause clipping. consider using actor_move_y()
		
			y_vel = defs.jump_vel;
			x_vel += (defs.jump_move_boost + defs.move_accel) * sign(x_vel);
			
			scale_x = 0.8;
			scale_y = 1.2;
		}
	}

	// x direction logic

	x_vel = approach(x_vel, _kh * defs.move_speed, defs.move_accel);
	
	dir = _kh;

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
	
	// additional checks
	
	var _wall = place_meeting(x + defs.wall_distance, y, obj_wall) - place_meeting(x - defs.wall_distance, y, obj_wall);
	
	if _wall != 0 {
		if buffer {
			buffer = 0;
			grace = 0;
		
			y_vel = defs.jump_vel;
			scale_x = 0.8;
			scale_y = 1.2;
		}
		if _kh == _wall && y_vel > 1 {
			dir = _wall;
			state.change(state_climb);
		}
	}
	
})

state_climb = state_base.add()
.set("step", function(){
	
	var _kh = input.right - input.left;
	var _kv = input.down - input.up;
	
	// y direction logic
	
	var _y_accel = 0;
	
	if y_vel < -defs.climb_speed { // moving up
		_y_accel = defs.climb_slide;
	} else {
		_y_accel = defs.climb_accel;
	}
	
	y_vel = approach(y_vel, _kv * defs.climb_speed, _y_accel);
	
	x_vel = dir * defs.move_speed;
	
	actor_move_y(y_vel, function(){
		y_vel = 0;
	});

	actor_move_x(x_vel, function(){
		x_vel = 0;
	});
	
	var _wall = place_meeting(x + dir, y, obj_wall);
	
	if !_wall {
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
	if climb_away > 6 {
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

state.change(state_free);
