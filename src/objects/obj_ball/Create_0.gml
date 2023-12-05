
event_inherited()

frame = function(){
	var _y_accel = 0;
	if abs(y_vel) < 1 {
		_y_accel = 0.3;
	} else {
		_y_accel = 0.2;
	}
	
	y_vel += _y_accel;

	y_vel = min(y_vel, global.defs.terminal_vel)

	if abs(x_vel) > 4 {
		x_vel = approach(x_vel, 4 * sign(x_vel), 0.2)
	}

	actor_move_x(x_vel, function(){
		x_vel = -x_vel * 1;
	});

	actor_move_y(y_vel, function(){
		if abs(y_vel) > 2 {
			y_vel = -y_vel * 0.4;
		}
		else y_vel = 0;
	});
}

depth = -20;

state = new State();

state_base = state.add();

state_free = state_base.add()
.set("step", function(){
	frame()
})

state_held = state_base.add()
.set("enter", function(){
	x_vel = 0;
	y_vel = 0;
	mask_index = spr_none;
})
.set("leave", function(){
	mask_index = sprite_index;
	
	
})
.set("step", function(){
	
})


state.change(state_free)
