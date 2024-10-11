
function draw_line_sprite(_x1, _y1, _x2, _y2, _width = 1, _col = draw_get_color(), _alpha = draw_get_alpha()) {
	
	var _dist = point_distance(_x1, _y1, _x2, _y2) // bad idea
	var _dir = point_direction(_x1, _y1, _x2, _y2) // bad idea
	draw_sprite_ext(spr_pixel, 0, _x1, _y1, _dist, _width, _dir, _col, _alpha)
	
}

function draw_circle_sprite_outline(_x, _y, _r, _width = 1, _col = draw_get_color(), _alpha = draw_get_alpha(), _res = 12) {
	
	var _lx = _r
	var _ly = 0
	
	for (var i = 1; i <= _res; i++) {
		
		var _d = 360 / _res * i
		
		var _nx = lengthdir_x(_r, _d)
		var _ny = lengthdir_y(_r, _d)
		
		draw_line_sprite(
			_x + _lx, _y + _ly,
			_x + _nx, _y + _ny,
			_width, _col, _alpha
		)
		
		_lx = _nx
		_ly = _ny
		
	}
	
}

function draw_circle_outline_part(_x, _y, _radius, _thick, _percentage, _start, _anti, _color = draw_get_color(), _alpha = draw_get_alpha()) {

	static __res = 32;
	static __interval = 360 / __res;
	
	_anti = _anti ? -1 : 1
	
	var _hthick = _thick / 2;
    
	draw_primitive_begin(pr_trianglestrip);
    
	for (var i = 0; i < _percentage * __res; i++) {

		var angle = _start + __interval * i * _anti;
		var dir_x = dcos(angle);
		var dir_y = -dsin(angle);
        
		draw_vertex_color(_x + (_radius + _hthick) * dir_x, _y + (_radius + _hthick) * dir_y, _color, _alpha);
        
		draw_vertex_color(_x + (_radius - _hthick) * dir_x, _y + (_radius - _hthick) * dir_y, _color, _alpha);
	}
	
	draw_primitive_end();
}

function draw_circle_outline(_x, _y, _radius, _thick, _color = undefined, _alpha = undefined) {
	draw_circle_outline_part(_x, _y, _radius, _thick, 1, 0, false, _color, _alpha)
}

function draw_circle_sprite(_x, _y, _radius, _color = draw_get_color(), _alpha = draw_get_alpha()) {
	draw_sprite_ext(spr_circle, 0, _x, _y, _radius / 64, _radius / 64, 0, _color, _alpha);
}
