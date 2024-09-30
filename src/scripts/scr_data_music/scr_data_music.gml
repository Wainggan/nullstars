
global.data_music = {};
global.data_music_refs = {};

function data_music_add(_asset = "", _name = "", _ref = "", _artist = "", _description = "") {
	global.data_music[$ _asset] = {
		name: _name,
		description: _description,
		artist: _artist,
	};
	global.data_music_refs[$ _ref] = _asset;
}

data_music_add(nameof(mus_wind), "wind", "wind", "", "");
data_music_add(nameof(mus_questionthestars), "center of the universe", "stars", "parchment", "");
data_music_add(nameof(mus_wind), "years ago", "lava", "parchment", "");

