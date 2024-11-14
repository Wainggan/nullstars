
var _cam = game_camera_get();

var _scale = global.settings.graphic.textscale + 1;

var _width = width * _scale;
var _height = height * _scale;

if anim_open > 0
	draw_sprite_stretched(
		spr_sign_board, 0,
		anim_x - _cam.x, anim_y - _cam.y,
		_width, _height * tween(Tween.Circ, anim_open),
	);

draw_set_font(ft_sign)
draw_set_color(#ff99ff)

if anim_text > 0
	draw_text_ext_transformed(
		anim_x - _cam.x + pad_x * _scale,
		anim_y - _cam.y + pad_y * _scale,
		string_copy(text, 1, clamp(anim_text, 0, string_length(text))),
		text_pad, (_width - pad_x * 2 * _scale) / _scale,
		_scale, _scale, 0,
	);

draw_set_color(c_white)
