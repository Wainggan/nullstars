
global.pause = 0;
global.pause_defer = 0;

function game_get_pause() {
	return global.pause;
}

function game_set_pause(_pause) {
	global.pause_defer = max(_pause, global.pause_defer);
}

function game_paused() {
	return global.pause > 0;
}

function game_pause_update() {
	global.pause = global.pause_defer;
	global.pause -= 1;
	global.pause_defer = global.pause;
}
