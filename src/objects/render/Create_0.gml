
application_surface_draw_enable(false);

depth = 10;

surf_lights = -1;
surf_mask = -1;
surf_background = -1;

surf_blur_ping = -1;

surf_background_lights = -1;

surf_app = -1;

background_mode = 0;
background_from = 0;
background_anim = 0;

background_lights_kernel = 7;
background_lights_sigma = 0.8;
background_lights_brightness = 4;

particles_ambient = part_system_create_layer("Instances", true)
part_system_automatic_update(particles_ambient, false)
part_system_automatic_draw(particles_ambient, false)

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
	
	for (var i = 0; i < array_length(level.levels); i++) {
		var _tiles = level.levels[i].tiles;
		var _x_off = level.levels[i].x;
		var _y_off = level.levels[i].y;
		
		var _vb = vertex_create_buffer();
		
		var _count = 0;
		
		vertex_begin(_vb, lights_vf);
		
		for (var _x = 0; _x < tilemap_get_width(_tiles); _x++) {
			for (var _y = 0; _y < tilemap_get_height(_tiles); _y++) {
				
				if tilemap_get(_tiles, _x, _y) == 0 continue;
				
				var _cx = _x_off + _x * TILESIZE;
				var _cy = _y_off + _y * TILESIZE;
				var _h = TILESIZE;
				
				while _y < tilemap_get_height(_tiles) && tilemap_get(_tiles, _x, _y + 1) != 0 {
					_h += TILESIZE;
					_y++;
				}
				
				_Quad(
					_vb, 
					_cx, _cy, _cx + TILESIZE, _cy + _h
				);
				_Quad(
					_vb, 
					_cx + TILESIZE, _cy, _cx, _cy + _h
				);
				
				_count++;
				
			}
		}
		
		vertex_end(_vb);
		
		show_debug_message($"{_count} shadow tiles")
		
		level.levels[i].vb = _vb;
	}
	
}
