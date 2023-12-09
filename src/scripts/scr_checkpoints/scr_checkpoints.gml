
function game_checkpoint_set(_object) {
	game.checkpoint = _object;
}

function game_checkpoint_add(_object) {
	array_push(game.checkpoint_list, _object)
}

function game_checkpoint_get() {
	return game.checkpoint;
}

function game_checkpoint_ref() {
	return game.checkpoint_list[game.checkpoint]
}
