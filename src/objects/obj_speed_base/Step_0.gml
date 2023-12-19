
var _last = false;

with obj_player {
	if riding(other) {
		with other {
			if dir == 0
				solid_sim(other.dir * 5, 0, obj_player)
			else
				solid_sim(dir * 5, 0, obj_player)
				
			if last == false
				instance_create_layer(x, y, "Instances", obj_effects_rectpop, {
					width: sprite_width, height: sprite_height,
					spd: 0.08, color: #ffcea1
				})
		}
		_last = true
	}
}

with obj_box {
	if riding(other) {
		with other {
			var _vel = 0;
			if dir == 0 
				_vel = sign(other.x_vel);
			else
				_vel = dir;
			//solid_sim(_vel, 0);
			other.x_vel = _vel * 5
				
			if last == false
				instance_create_layer(x, y, "Instances", obj_effects_rectpop, {
					width: sprite_width, height: sprite_height,
					spd: 0.08, color: #ffcea1
				})
		}
		_last = true
	}
}

last = _last
