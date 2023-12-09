
var _cam_x = camera_get_view_x(view_camera[0]),
	_cam_y = camera_get_view_y(view_camera[0]),
	_cam_w = camera_get_view_width(view_camera[0]),
	_cam_h = camera_get_view_height(view_camera[0]);

var _pos_x = _cam_x + _cam_w / 2,
	_pos_y = _cam_y + 40;

_pos_y -= herp(1, 0, anim) * 80;

draw_set_halign(fa_middle);
draw_set_font(ft_timer);

var _seconds = floor(time / 60);
_seconds = string(_seconds);
var _milliseconds = floor((time / 60 * 1000) % 1000);
_milliseconds = string(_milliseconds);
while string_length(_milliseconds) < 3 _milliseconds += "0";

var _str = $"{_seconds} . {_milliseconds}";

draw_text_ext_transformed(_pos_x, _pos_y, _str, -1, -1, 2, 2, 0);

draw_set_halign(fa_left);

