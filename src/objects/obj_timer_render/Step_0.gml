
if state == 0 {
	anim = approach(anim, 1, 0.1);
	if !game_timer_running() {
		state = 1;
	} else {
		time = game.timer;
	}
} else {
	anim_end = approach(anim_end, 1, 1 / 120);
	
	if instance_number(object_index) > 1 anim_end = 1;
	
	if anim_end >= 1 {
		anim = approach(anim, 0, 0.02);
		if anim <= 0 instance_destroy();
	}
	
}

