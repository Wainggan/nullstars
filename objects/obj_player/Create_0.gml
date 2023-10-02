
event_inherited();


// behaviour

defs = {
	
	move_speed: 2,
	move_accel: 1,
	
	jump_vel: -4,
	terminal_vel: 4,
	
	gravity: 0.45,
	gravity_hold: 0.2,
	gravity_peak: 0.1,
	gravity_peak_thresh: 0.36,
	
	gravity_damp: 0.8,
	
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

grace = 0;
grace_y = y;
buffer = 0;


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
			scale_x = 0.8;
			scale_y = 1.2;
		}
	}

	// x direction logic

	x_vel = approach(x_vel, _kh * defs.move_speed, defs.move_accel);

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

state.change(state_free);
