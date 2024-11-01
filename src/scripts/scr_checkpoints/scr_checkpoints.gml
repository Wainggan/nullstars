
function game_checkpoint_set(_index) {
	game.checkpoint = _index;
	global.data.location = _index;
	if !array_contains(global.data.checkpoints, _index) {
		array_push(global.data.checkpoints, _index);
	}
	game_file_save();
}

function game_checkpoint_add(_object) {
	if game.checkpoint_list[$ _object.index] != undefined {
		throw $"checkpoint: {_object.index} already exists";
	}
	game.checkpoint_list[$ _object.index] = _object
}

function game_checkpoint_get() {
	return game.checkpoint;
}

function game_checkpoint_ref() {
	return game.checkpoint_list[$ game.checkpoint]
}
