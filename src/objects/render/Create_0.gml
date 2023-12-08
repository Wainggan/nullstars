
application_surface_draw_enable(false);

depth = 10;

surf_lights = -1;
surf_mask = -1;
surf_background = -1;

surf_blur_ping = -1;

surf_background_lights = -1;

background_lights_kernel = 8;
background_lights_sigma = 0.8;
background_lights_brightness = 4;

mode = 0;

vertex_format_begin();
vertex_format_add_position_3d();
lights_vf = vertex_format_end();
lights_vb = -1;

setup_lights = function(){
	
	if lights_vb vertex_delete_buffer(lights_vb);
	lights_vb = vertex_create_buffer();
	
	static _Quad = function(_vb, _x1, _y1, _x2, _y2) {
		vertex_position_3d(_vb, _x1, _y1, 0);
		vertex_position_3d(_vb, _x1, _y1, 1);
		vertex_position_3d(_vb, _x2, _y2, 0);
		
		vertex_position_3d(_vb, _x1, _y1, 1);
		vertex_position_3d(_vb, _x2, _y2, 0);
		vertex_position_3d(_vb, _x2, _y2, 1);
	};
	
	vertex_begin(lights_vb, lights_vf);
	
	for (var i = 0; i < /* array_length(level.levels) */1; i++) {
		var _tiles = level.levels[i].tiles;
		var _x_off = level.levels[i].x;
		var _y_off = level.levels[i].y;
		
		for (var _x = 0; _x < tilemap_get_width(_tiles); _x++) {
			for (var _y = 0; _y < tilemap_get_height(_tiles); _y++) {
				
				if tilemap_get(_tiles, _x, _y) == 0 continue;
				
				var _cx = _x_off + _x * TILESIZE;
				var _cy = _y_off + _y * TILESIZE;
				
				//show_debug_message($"{_cx} {_cy}")
				
				_Quad(
					lights_vb, 
					_cx, _cy, _cx + TILESIZE, _cy + TILESIZE
				);
				_Quad(
					lights_vb, 
					_cx + TILESIZE, _cy, _cx, _cy + TILESIZE
				);
				
			}
		}
	}
	
	vertex_end(lights_vb);
	
}
