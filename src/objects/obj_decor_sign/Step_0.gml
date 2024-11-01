
var _touching = place_meeting(x, y, obj_player)

var _off = 0;
if instance_exists(obj_player) {
	_off = clamp(map(obj_player.x - (x + 16), -32, 32, 1, -1), -1, 1);
}

anim_off = lerp(anim_off, _off, 0.05)

if _touching {
	anim_open = approach(anim_open, 1, 0.08);
	if anim_open == 1 {
		anim_text = approach(anim_text, string_length(text), 8);
	}
} else {
	anim_text = approach(anim_text, 0, 12);
	if anim_text <= 0 {
		anim_open = approach(anim_open, 0, 0.08);
	}
}

last = _touching

var _scale = global.settings.graphic.textscale + 1;

var _width = width * _scale;
var _height = height * _scale;

anim_x = floor(x + 16 - _width / 2 + anim_off * 16);
anim_y = floor(y - _height - 16 + abs(anim_off) * 4);

