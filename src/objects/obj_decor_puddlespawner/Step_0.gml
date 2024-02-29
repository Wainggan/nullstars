
var _cam = game_camera_get()
var _pad = WIDTH;

schedule += 30;
while schedule > 1 {
	schedule--;
	
	var _x = irandom_range(_cam.x - _pad, _cam.x + _cam.w + _pad), 
		_y = irandom_range(_cam.y - _pad, _cam.y + _cam.h + _pad);
	var _level = game_level_get_safe(_x, _y);
	
	if !_level || !_level.loaded continue;
	
	if tilemap_get_at_pixel(_level.tiles, _x, _y) != 0 continue;
	
	for (var i = 1; i < TILESIZE; i++) {
		if tilemap_get_at_pixel(_level.tiles, _x, _y + i) != 0 {
			var _tx = floor((_x - _level.x) / TILESIZE), _ty = floor((_y - _level.y + i) / TILESIZE)
			
			var _space_l = 0;
			for (var j = 1; j < 4; j++) {
				if !tilemap_get(_level.tiles, _tx - j, _ty) break;
				_space_l++;
			}
			
			var _space_r = 0;
			for (var j = 1; j < 4; j++) {
				if !tilemap_get(_level.tiles, _tx + j, _ty) break;
				_space_r++;
			}
			
			var _space = min(_space_l, _space_r);
			_space = max(_space, 1);
			
			if _space != 1 _space = _space * 2 - 1;
			
			var _ox = _tx * TILESIZE + _level.x;
			var _oy = _ty * TILESIZE + _level.y;
			
			with instance_create_layer(
				_ox, _oy + 1,
				"Instances", obj_decor_puddle, {
					image_xscale: _space,
				}
			) {
				x = x - sprite_width / 2 - TILESIZE / 2;
				height = random_range(0.7, 1.5)
				if random(1) < 0.6 && place_meeting(x, y, obj_decor_puddle) instance_destroy() // @todo: stupid
			}
			
			break;
		}
	}
	
}

timer -= 1;
if timer <= 0 instance_destroy();