
function actor_scan(_x, _y, _dir, _cap = 30) {
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
	
	return {
		x: _check_x, y: _check_y
	};
}

function actor_stretch(_x1, _y1, _x2, _y2, _inst = self) {
	with _inst {
		x = _x1;
		y = _y1;
		image_xscale = abs(_x2 - _x1) / sprite_width;
		image_yscale = abs(_y2 - _y1) / sprite_height;
	}
}
