
anim_dive_timer -= 1;
anim_jab_timer -= 1;
anim_longjump_timer -= 1;
anim_flip_timer -= 1;
anim_runjump_timer -= 1;

if state.is(state_ledge) {
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
	else if onground && y_vel >= 0 {
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

tail.position(x + _meta.x * dir, y + _meta.y);

tail.update(, action_tail_update_point);

var _color = dash_left == 0 ? #00ffff : #ff00ff;
var _mult = dash_left == 0 ? #ddccdd : c_white;

if !_meta.front {
	action_tail_draw(_color, _mult);
}

var _frame = anim.get();

draw_sprite_ext(
	spr_player,
	_frame, x, y,
	scale_x * dir, scale_y,
	0, _mult, 1
);

if _meta.front {
	action_tail_draw(_color, _mult);
}

