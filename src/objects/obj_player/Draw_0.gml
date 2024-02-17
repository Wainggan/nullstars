
var _angle = 0, _sprite = sprite_index;
var _dir = dir;
var _pos_x = x, _pos_y = y;
var _tpos_x = undefined, _tpos_y = undefined;

anim_dive_timer -= 1;
anim_jab_timer -= 1;
anim_longjump_timer -= 1;
anim_flip_timer -= 1;
anim_runjump_timer -= 1;

if state.is(state_swim) {
	
	if swim_bullet {
		anim.set("swimbullet")
		_angle = swim_dir
		_dir = 1
		_pos_x += -lengthdir_x(16, _angle + 90);
		_pos_y += -16 - lengthdir_y(16, _angle + 90);
	} else {
		if swim_spd < 1 {
			anim.extract("swim").speed = 1 / 60
			anim.set("swim")
		}
		else if abs(swim_dir % 360 - 90) < 10 || (abs(swim_dir % 360 - 270) < 10 && false) {
			anim.extract("swim").speed = 1 / round(max(20 - abs(swim_spd) * 2, 8))
			anim.set("swim")
		}
		else {
			anim.extract("swimming").speed = 1 / round(max(20 - abs(swim_spd) * 2, 8))
			anim.set("swimming")
		}
		
		
		_pos_y += wave(-2, 3, 8)
		_tpos_y = _pos_y
	}
	
}
else if state.is(state_ledge) {
	
	anim.set("ledge")
	
}
else if state.is(state_menu) {
	
	anim.set("idle")
	
}
else if state.is(state_dash) || anim_dive_timer || anim_jab_timer  {
	
	if anim_jab_timer anim.set("jab")
	else anim.set("dive")
}
else if state.is(state_free) {
	if crouched && !anim_longjump_timer {
		anim.set("crouch")
	}
	else if actor_collision(x, y + 1) && y_vel >= 0 {
		if abs(x_vel) < 0.8
			anim.set("idle")
		else if abs(x_vel) > defs.move_speed + 2 {
			anim.extract("run").speed = 1 / 3//round(max(3 - abs(x_vel) * 0.25, 2))
			anim.set("run")
		}
		else {
			anim.extract("walk").speed = 1 / round(max(12 - abs(x_vel) * 2, 6))
			anim.set("walk")
		}
	}
	else if anim_longjump_timer {
		anim.set("longjump")
	}
	else if anim_flip_timer && y_vel < 0 {
		anim.set("flip")
	}
	else {
		if y_vel < 0 {
			if anim_runjump_timer > 0
				anim.set("runjump")
			else
				anim.set("jump")
		}
		else {
			if anim_runjump_timer > 0
				anim.set("runfall")
			else
				anim.set("fall")
		}
	}
}



anim.update();

var _meta = anim.meta();

tail.position((_tpos_x ?? x) + _meta.x * dir, (_tpos_y ?? y) + _meta.y);

tail.update(, update_tail)

var _color = dash_left == 0 ? #00ffff : #ff00ff;
var _mult = dash_left == 0 ? #ccbbcc : c_white;

self._tip = _color;
self._blend = _mult;

if !_meta.front
	tail.each_reverse(tail_draw)

draw_sprite_ext(
	_sprite,
	anim.get(), _pos_x, _pos_y,
	scale_x * _dir, scale_y,
	_angle, _mult, image_alpha
);
//draw_sprite_ext(
//	spr_player_eyes,
//	0, x + _meta.eye_x * dir, y + _meta.eye_y,
//	scale_x * dir, scale_y,
//	0, c_white, image_alpha
//);

if _meta.front
	tail.each_reverse(tail_draw)




