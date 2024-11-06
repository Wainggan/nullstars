
function game_sound_play(_asset) {
	var _priority = 20;
	var _gain = 1;
	
	var _data = global.data_sound[$ audio_get_name(_asset)];
	if _data != undefined {
		_priority = _data.priority;
		_gain = _data.gain;
	}
	
	audio_play_sound(
		_asset, _priority, false,
		_gain * (global.settings.sound.sfx * global.settings.sound.mix / 100)
	);
}

global.data_sound = {};

function data_sound_add(_asset = "", _priority = 0, _gain = 1) {
	global.data_sound[$ _asset] = {
		priority: _priority,
		gain: _gain,
	};
}

data_sound_add(nameof(sfx_pop_0), 10, 0.4);
data_sound_add(nameof(sfx_pop_1), 10, 0.4);
data_sound_add(nameof(sfx_pop_2), 8, 0.4);
data_sound_add(nameof(sfx_dash), 10, 0.8);
data_sound_add(nameof(sfx_death), 0, 1);

