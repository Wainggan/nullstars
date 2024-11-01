
/*
var _x = x;
var _y = y;

for (var i = 0; i < array_length(menu.menu.stack); i++) {
	menu.menu.stack[i].draw(_x, _y, 1);
	_x += 24;
}


/*
var _cam = game_camera_get()

var _menu_x = x + 32;
var _menu_y = y - 96;

var _menu_pad_x = 8;
var _menu_pad_y = 11;
var _menu_option_pad = 14;

while array_length(anim_menu_open) < array_length(menu.stack)
	array_push(anim_menu_open, 0)

show_debug_message(anim_menu_open)

draw_set_font(ft_sign)
draw_set_color(#cccccc)

for (var i = 0; i < array_length(anim_menu_open); i++) {
	
	anim_menu_open[i] = approach(anim_menu_open[i], i < array_length(menu.stack) ? 1 : 0, 0.1)
	
	if anim_menu_open[i] <= 0 {
		_menu_x += 24;
		continue;
	}
	
	draw_sprite_stretched(spr_sign_board, 0, _menu_x, _menu_y, 200, 200 * tween(Tween.Circ, anim_menu_open[i]));
	
	if anim_menu_open[i] < 1 || i >= array_length(menu.stack) {
		_menu_x += 24;
		continue;
	}
	
	var _stack = menu.stack[i]
	
	for (var j = 0; j < array_length(_stack.list); j++) {
		var _e = _stack.list[j]
		if j == _stack.current
			draw_text(_menu_x + _menu_pad_x, _menu_y + _menu_pad_y + j * _menu_option_pad, ">")
		_e.draw(_menu_x + _menu_pad_x + 12, _menu_y + _menu_pad_y + j * _menu_option_pad, _menu_x + 200 - _menu_pad_x * 2, j == _stack.current)
	}
	_menu_x += 24;
	
}
	
draw_set_color(c_white)

anim_menu_map_open = approach(anim_menu_map_open, state.is(state_map) ? 1 : 0, 0.1)

var _pos_x = _cam.x + WIDTH / 2;
var _pos_y = _cam.y + HEIGHT / 2;
var _pos_w = 400 * hermite(anim_menu_map_open)
var _pos_h = 300 * hermite(anim_menu_map_open)

var _pos_xoff = _pos_x - _pos_w / 2;
var _pos_yoff = _pos_y - _pos_h / 2;

if anim_menu_map_open > 0 {
	draw_sprite_stretched_ext(spr_map_background, 0, _pos_xoff, _pos_yoff, _pos_w, _pos_h, c_black, 1)
	
	with obj_checkpoint {
		var _c_x = (x - other.menu_map_cam_x) * (other.menu_map_cam_scale);
		var _c_y = (y - other.menu_map_cam_y) * (other.menu_map_cam_scale);
		var _dist = point_distance(0, 0, _c_x, _c_y);
		var _dir = point_direction(0, 0, _c_x, _c_y)
		
		_c_x += lengthdir_x(power(_dist / 12, 1.5) + WIDTH * 0.5 * hermite(1 - other.anim_menu_map_open), _dir);
		_c_y += lengthdir_y(power(_dist / 12, 1.5) + HEIGHT * 0.5 * hermite(1 - other.anim_menu_map_open), _dir);
		
		draw_sprite_ext(
			spr_player_tail, 0, 
			WIDTH / 2 + _cam.x + _c_x, 
			HEIGHT / 2 + _cam.y + _c_y,
			tween(Tween.Circ, other.anim_menu_map_open), 
			tween(Tween.Circ, other.anim_menu_map_open),
			0, c_white, 1
		);
	}
	
	draw_sprite(spr_debug_marker, 0, _cam.x + WIDTH / 2, _cam.y + HEIGHT / 2)
	
}


