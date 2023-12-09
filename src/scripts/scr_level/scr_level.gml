
function game_level_get(_x, _y) {
	for (var i = 0; i < array_length(level.levels); i++) {
		var _lvl = level.levels[i];
		if point_in_rectangle(
				_x, _y, 
				_lvl.x, _lvl.y,
				_lvl.x + _lvl.width,
				_lvl.y + _lvl.height) {
			return _lvl;
		}
	}
	return undefined;
}

function game_level_get_biome(_x, _y) {
	var _lvl = game_level_get(_x, _y);
	if _lvl == undefined return "";
	return _lvl.fields.biome;
}
