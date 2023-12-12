
//draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);

var _angle = 0, _sprite = sprite_index;
var _dir = dir;
var _pos_x = x, _pos_y = y;
var _tpos_x = undefined, _tpos_y = undefined;

anim_dive_timer -= 1;
anim_jab_timer -= 1;
anim_longjump_timer -= 1;

if state.is(state_swim) {
	
	if swim_bullet {
		anim.set("swimbullet")
		_angle = swim_dir
		_dir = 1
		_pos_x += -lengthdir_x(16, _angle + 90);
		_pos_y += -16 - lengthdir_y(16, _angle + 90);
	} else {
		if swim_spd < 1 {
			anim.set("swim")
		} else {
			anim.extract("swimming").speed = 1 / round(max(20 - abs(swim_spd) * 2, 8))
			anim.set("swimming")
		}
		
		
		_pos_y += wave(-2, 3, 8)
		_tpos_y = _pos_y
	}
	
}
else if state.is(state_dash) || anim_dive_timer || anim_jab_timer {
	
	if anim_jab_timer anim.set("jab")
	else anim.set("dive")
}
else if state.is(state_free) {
	if actor_collision(x, y + 1) {
		if abs(x_vel) < 0.8
			anim.set("idle")
		else {
			anim.extract("walk").speed = 1 / round(max(12 - abs(x_vel) * 2, 6))
			anim.set("walk")
		}
	} else {
		if anim_longjump_timer {
			anim.set("longjump")
		} else {
			if y_vel < 0
				anim.set("jump")
			else
				anim.set("fall")
		}
	}
}



anim.update();

var _meta = anim.meta();

tail.position((_tpos_x ?? x) + _meta.x * dir, (_tpos_y ?? y) + _meta.y);

tail.update(,function(_p, i, _points){
	var _len = array_length(_points)
	var _scale_inv = (_len - i) / _len;
	
	if holding {
		_p.damp = 0.8
		_p.weight = 6;
		
		var _t1 = floor(_len * 0.5)
		var _t2 = floor(_len * 0.75)
		
		_p.direction = (90 + 80 * -dir)
		if i > _t1 {
			_p.direction += (i - _t1) * -30 * dir;
			if i > _t2 {
				_p.direction += (i - _t2) * 60 * dir;
			}
		} else {
			
		}
		
		
	} else {
		_p.damp = 0.8
		_p.weight = 1;
		
		var _d = sin(current_time / 1000 - i * 0.6)
		_p.x_move = -dir * (_scale_inv * 0.7 + 0.2)
		_p.y_move = _d * (_scale_inv * 0.2 + 0.1) + 0.3 * _scale_inv
		
	}
})


var _color = dash_left == 0 ? #00ffff : #ff00ff;
var _mult = dash_left == 0 ? #ccbbcc : c_white;

if !_meta.front
	draw_tail(_color, _mult);

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
	draw_tail(_color, _mult);


// draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true)


