
if array_length(path) > 1 {
	var _last_x = path[0].x;
	var _last_y = path[0].y;
	for (var i = 1; i < array_length(path); i++) {
		draw_line_sprite(
			_last_x + TILESIZE / 2, _last_y + TILESIZE / 2,
			path[i].x + TILESIZE / 2, path[i].y + TILESIZE / 2,
			2, #77ffff, 1
		);
		_last_x = path[i].x;
		_last_y = path[i].y;
	}
	
	draw_circle_sprite(
		path[0].x + TILESIZE / 2,
		path[0].y + TILESIZE / 2,
		8, #77ffff, 1
	);
	draw_circle_sprite(
		path[array_length(path) - 1].x + TILESIZE / 2,
		path[array_length(path) - 1].y + TILESIZE / 2,
		8, #77ffff, 1
	);
}
