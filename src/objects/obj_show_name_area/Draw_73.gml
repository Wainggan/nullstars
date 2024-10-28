
var _cam = game_camera_get()

var _pos_x = _cam.x + _cam.w / 2,
	_pos_y = _cam.y + _cam.h / 2 + 120;

draw_set_halign(fa_middle);
draw_set_font(ft_timer);
draw_set_alpha(anim)

draw_text_ext_transformed(_pos_x, _pos_y, $"area {number}", -1, -1, 2, 2, 0);

draw_set_halign(fa_left);
draw_set_alpha(1)

