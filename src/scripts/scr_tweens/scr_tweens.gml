
enum Tween {
	Linear = 0,
	Ease,
	Cubic,
	Quart,
	Expo,
	Circ,
	Back,
	Elastic,
	Bounce,
	FastSlow,
	MidSlow
}

/// @arg {enum.Tween} _index
/// @arg {real} _t
function tween(_index, _t) {
	var _channel = animcurve_get_channel(ac_tweens, _index);
	return animcurve_channel_evaluate(_channel, _t);
}

/// @arg {real} _a
/// @arg {real} _b
/// @arg {enum.Tween} _index
/// @arg {real} _t
function terp(_a, _b, _index, _t) {
	return lerp(_a, _b, tween(_index, _t));
}

