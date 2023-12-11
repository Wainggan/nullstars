
with obj_player {
	if riding(other) {
		with other {
			if dir == 0
				solid_sim(other.dir * 5, 0)
			else
				solid_sim(dir * 5, 0)
				
			if last == false
				instance_create_layer(x, y, "Instances", obj_effects_rectpop, {
					width: sprite_width, height: sprite_height,
					spd: 0.08, color: #ffcea1
				})
		}
		other.last = true
	} else other.last = false;
}

