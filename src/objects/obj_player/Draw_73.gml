
var _menu_x = x + 32;
var _menu_y = y - 96;

var _menu_pad_x = 8;
var _menu_pad_y = 11;
var _menu_option_pad = 14;

while array_length(anim_menu_open) < array_length(menu.stack)
	array_push(anim_menu_open, 0)

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
