
anim_dive_timer -= 1;
anim_jab_timer -= 1;
anim_longjump_timer -= 1;
anim_flip_timer -= 1;
anim_runjump_timer -= 1;

var _sprite = spr_player;
var _pos_x = x;
var _pos_y = y;
var _tail_x = undefined;
var _tail_y = undefined;
var _angle = 0;
var _dir = dir;

if state.is(state_swim_bullet) {
	_sprite = spr_player_bullet;
	_angle = swim_dir;
	_dir = 1;
	_pos_y -= 16;
	_tail_x = 0;
	_tail_y = 0;
}
else if state.is(state_swim) {
	
	var _swim_spd = point_distance(0, 0, x_vel, y_vel);
	var _swim_dir = point_direction(0, 0, x_vel, y_vel);
	
	if _swim_spd < 1 {
		anim.extract("swim").speed = 1 / 60;
		anim.set("swim");
	}
	else if abs(_swim_dir % 360 - 90) < 10 || (abs(_swim_dir % 360 - 270) < 10 && false) {
		anim.extract("swim").speed = 1 / round(max(20 - abs(_swim_spd) * 2, 8));
		anim.set("swim");
	}
	else {
		anim.extract("swimming").speed = 1 / round(max(20 - abs(_swim_spd) * 2, 8));
		anim.set("swimming");
	}
	
	_pos_y += wave(-2, 3, 8);
	
}
else if state.is(state_ledge) {
	anim.set("ledge");
}
else if state.is(state_menu) {
	anim.set("idle");
}
else if state.is(state_dash) || anim_dive_timer || anim_jab_timer {
	if anim_dive_timer > 0 {
		anim.set("dive");
	} else {
		anim.set("jab");
	}
}
else if state.is(state_free) {
	if nat_crouch() && anim_longjump_timer <= 0 {
		anim.set("crouch");
	}
	else if actor_collision(x, y + 1) && y_vel >= 0 {
		if abs(x_vel) < 0.8 {
			anim.set("idle");
		}
		else if abs(x_vel) > defs.move_speed + 2 {
			anim.extract("run").speed = 1 / 3;
			anim.set("run");
		}
		else {
			anim.extract("walk").speed = 1 / round(max(12 - abs(x_vel) * 2, 6));
			anim.set("walk");
		}
	}
	else if anim_longjump_timer > 0 {
		anim.set("longjump");
	}
	else if anim_flip_timer > 0 && y_vel < 0 {
		anim.set("flip");
	}
	else {
		if y_vel < 0 {
			if anim_runjump_timer > 0 {
				anim.set("runjump");
			} else {
				anim.set("jump");
			}
		}
		else {
			if anim_runjump_timer > 0 {
				anim.set("runfall");
			} else {
				anim.set("fall");
			}
		}
	}
}

anim.update();

var _meta = anim.meta();

tail.position(
	_pos_x + (_tail_x ?? _meta.x * dir),
	_pos_y + (_tail_y ?? _meta.y),
);

tail.update(, action_tail_update_point);

var _color = dash_left == 0 ? #00ffff : #ff00ff;
var _mult = dash_left == 0 ? #ddccdd : c_white;

if !_meta.front {
	action_tail_draw(_color, _mult);
}

var _frame = anim.get();

draw_sprite_ext(
	_sprite,
	_frame, _pos_x, _pos_y,
	scale_x * _dir, scale_y,
	_angle, _mult, 1
);

if _meta.front {
	action_tail_draw(_color, _mult);
}

