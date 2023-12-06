
function YarnPoint() constructor {
	
	x = 0;
	y = 0;
	
	x_move = 0;
	y_move = 0;
	
	direction = 0;
	weight = 1;
	length = 10;
	
	damp = 1;
	leeway = 0;
	
}

function Yarn() constructor {
	
	points = []
	
	static add = function(_p) {
		array_push(points, _p)
	}
	
	static position = function(_x, _y) {
		if array_length(points) == 0 return;
		points[0].x = _x;
		points[0].y = _y;
	}
	
	static shift = function(_offX, _offY) {
		for (var i = 0; i < array_length(points); i++) {
			points[i].x += _offX;
			points[i].y += _offY;
		}
	}
	
	static update = function(_delta = 1, _callback = undefined) {
		if array_length(points) == 0 return;
	
		var _last_x = points[0].x;
		var _last_y = points[0].y;
		var _last_dir = undefined;
	
		for (var i = 1; i < array_length(points); i++) {
			var _p = points[i];
			
			var _target_x = _p.x;
			var _target_y = _p.y;
			
			_p.direction = point_direction(_p.x, _p.y, _last_x, _last_y);
			
			if _last_dir != undefined {
				var _diff = angle_difference(_p.direction, _last_dir);
				_diff *= _p.damp;
				_p.direction = _last_dir + _diff;
			}
			
			if _callback _callback(_p, i, points)
			
			_target_x -= lengthdir_x(_p.weight, _p.direction);
			_target_y -= lengthdir_y(_p.weight, _p.direction);
			
			_target_x += _p.x_move;
			_target_y += _p.y_move;
			
			var _angle_snap = point_direction(_target_x, _target_y, _last_x, _last_y);
			
			var _new_x = _last_x - lengthdir_x(_p.length, _angle_snap);
			var _new_y = _last_y - lengthdir_y(_p.length, _angle_snap);
			
			_p.x = lerp(_new_x, _target_x, _p.leeway);
			_p.y = lerp(_new_y, _target_y, _p.leeway);
			
			_last_x = _p.x;
			_last_y = _p.y;
			_last_dir = _p.direction;
		}
	}
	
	static loop = function(_callback) {
		
		for (var i = 0; i < array_length(points); i++) {
			var _p = points[i];
			if _callback _callback(_p, i, points)
		}
		
	}
	
	static loop_reverse = function(_callback) {
		
		for (var i = array_length(points) - 1; i >= 0; i--) {
			var _p = points[i];
			if _callback _callback(_p, i, points)
		}
		
	}
	
}

function yarn_create(_length, _callback) {
	var _yarn = new Yarn()
	for (var i = 0; i < _length; i++) { // 10
		var _p = new YarnPoint();
		
		if _callback _callback(_p, i)
		
		_yarn.add(_p)
	}
	return _yarn
}



