
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

function tween(_index, _t) {
	var _channel = animcurve_get_channel(ac_tweens, _index);
	return animcurve_channel_evaluate(_channel, _t);
}

function terp(_a, _b, _index, _t) {
	return lerp(_a, _b, tween(_index, _t));
}
