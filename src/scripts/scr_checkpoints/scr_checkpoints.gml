
function game_checkpoint_set(_index) {
	game.checkpoint = _index;
}

function game_checkpoint_add(_object) {
	array_push(game.checkpoint_list, _object)
}

function game_checkpoint_get() {
	return game.checkpoint;
}

function game_checkpoint_ref() {
	array_sort(game.checkpoint_list, function(_a, _b){
		return _a.index - _b.index
	})
	return game.checkpoint_list[game.checkpoint]
}
