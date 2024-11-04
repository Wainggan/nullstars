
function game_checkpoint_set(_index) {
	global.game.checkpoint.set(_index);
	global.game.checkpoint.data(_index).collected = true;
	game_file_save();
}

function game_checkpoint_add(_object) {
	global.game.checkpoint.add(_object);
}

function game_checkpoint_get() {
	return global.game.checkpoint.get();
}

function game_checkpoint_ref() {
	return global.game.checkpoint.ref(global.game.checkpoint.get());
}
