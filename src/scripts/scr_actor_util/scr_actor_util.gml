
function actor_scan(_x, _y, _dir, _cap = 30) {
	static __return = {};
	
	var _check_x = _x;
	var _check_y = _y;
	var _check = _cap;
	
	while _check > 0 {
		if actor_collision(_check_x, _check_y) {
			if _check_x == _x && _check_y == _y break;
			
			var _check_2 = max(sprite_width, sprite_height);
			while actor_collision(_check_x, _check_y) && _check_2 > 0 {
				_check_x -= lengthdir_x(1, _dir);
				_check_y -= lengthdir_y(1, _dir);
				_check_2--;
			}
	
			break;
		}
		_check_x += lengthdir_x(sprite_width, _dir);
		_check_y += lengthdir_y(sprite_height, _dir);
		_check--;
	}
	
	__return.x = _check_x;
	__return.y = _check_y;
	
	return __return;
}

function actor_check(_x, _y, _dir, _target, _cap = undefined) {
	var _ = actor_scan(_x, _y, _dir, _cap);
	
	var _x1 = min(_x, _.x) + 1;
	var _y1 = min(_y, _.y) + 1;
	var _x2 = max(_x + sprite_width, _.x + sprite_width) - 1;
	var _y2 = max(_y + sprite_height, _.y + sprite_height) - 1;

	with _target {
		if rectangle_in_rectangle(
			bbox_left, bbox_top,
			bbox_right, bbox_bottom,
			_x1, _y1, _x2, _y2
		) return true;
	}
	
	return false;
}

function actor_stretch(_x1, _y1, _x2, _y2, _inst = self) {
	with _inst {
		x = _x1;
		y = _y1;
		image_xscale = abs(_x2 - _x1) / sprite_get_width(sprite_index);
		image_yscale = abs(_y2 - _y1) / sprite_get_height(sprite_index);
	}
}
