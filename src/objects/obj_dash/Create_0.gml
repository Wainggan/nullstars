
event_inherited()

defs = {
	recover_time: 100,
	spin_speed: 12,
}

recover_timer = 0;
dir = 0;
dir_dir = 1;

anim_hit = 0;


state = new State()

state_base = state.add()
.set("step", function(){
	state.child()
	
	dir += 1;
	dir += recover_timer / defs.recover_time * defs.spin_speed
	
	anim_hit = approach(anim_hit, 0, 0.1)
})

state_active = state_base.add()
.set("step", function(){})

state_recover = state_base.add()
.set("enter", function(){
	recover_timer = defs.recover_time;
	anim_hit = 1;
	dir_dir = -dir_dir;
	
	activate()
	send()
})
.set("step", function(){
	recover_timer -= 1;
	if recover_timer <= 0 state.change(state_active)
})


state.change(state_active)
