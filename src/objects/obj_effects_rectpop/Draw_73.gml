
var _a = lerp(0, 1, anim) * pad;

draw_set_alpha(herp(1, 0, anim));

draw_roundrect(
	x - _a, y - _a,
	x + width + _a,
	y + height + _a,
	true
);

draw_set_alpha(1)
