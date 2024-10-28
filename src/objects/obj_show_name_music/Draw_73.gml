
var _cam = game_camera_get()

var _pos_x = _cam.x + 20,
	_pos_y = _cam.y + _cam.h - 30 * hermite(anim)

//draw_set_halign(fa_middle);
draw_set_font(ft_timer);

draw_text_transformed(_pos_x, _pos_y, $"{name}", 1, 1, 0);

//draw_set_halign(fa_left);

