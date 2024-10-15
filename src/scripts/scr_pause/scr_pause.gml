
global.pause = 0;
global.pause_defer = 0;
global.pause_freeze = false;

function game_get_pause() {
	return global.pause;
}

// game_get_pause() and game_pause() only change once game_pause_update() is run
function game_set_pause(_pause) {
	global.pause_defer = max(_pause, global.pause_defer);
}

function game_set_freeze(_pause) {
	global.pause_freeze = _pause;
}

function game_paused() {
	return global.pause_freeze || global.pause > 0;
}

function game_pause_update() {
	global.pause = global.pause_defer;
	global.pause -= 1;
	global.pause_defer = global.pause;
}
