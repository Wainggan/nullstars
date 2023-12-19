
var _size = terp(1, 2, Tween.MidSlow, anim);
var _alpha = herp(1, 0, anim);

draw_sprite_ext(
	sprite, index, 
	x, y, _size, _size,
	0, c_white, _alpha
);
