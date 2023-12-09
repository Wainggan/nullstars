
//draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);

anim_dive_timer -= 1;
anim_jab_timer -= 1;
anim_longjump_timer -= 1;

if state.is(state_dash) || anim_dive_timer || anim_jab_timer {
	
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

tail.position(x + _meta.x * dir, y + _meta.y);

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
		_p.x_move = -dir * (_scale_inv * 0.4 + 0.3)
		_p.y_move = _d * (_scale_inv * 0.2 + 0.1) + 0.3 * _scale_inv
		
	}
})


var _color = dash_left == 0 ? #00ffff : #ff00ff;
var _mult = dash_left == 0 ? #ccbbcc : c_white;

if !_meta.front
	draw_tail(_color, _mult);

draw_sprite_ext(
	sprite_index,
	anim.get(), x, y,
	scale_x * dir, scale_y,
	0, _mult, image_alpha
);
//draw_sprite_ext(
//	spr_player_eyes,
//	0, x + _meta.eye_x * dir, y + _meta.eye_y,
//	scale_x * dir, scale_y,
//	0, c_white, image_alpha
//);

if _meta.front
	draw_tail(_color, _mult);



