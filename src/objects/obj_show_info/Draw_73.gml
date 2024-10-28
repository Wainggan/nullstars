
var _cam = game_camera_get()

var _pos_x = _cam.x + 20,
	_pos_y = _cam.y + _cam.h - 16 * hermite(anim)

// draw_set_halign(fa_middle);
draw_set_font(ft_sign);

draw_text_ext_transformed(
	_pos_x, _pos_y, 
	$"{date_datetime_string(GM_build_date)} {GM_build_type} - {GM_version}", 
	-1, -1, 
	1, 1, 
	0
);

// draw_set_halign(fa_left);

