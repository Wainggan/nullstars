
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
