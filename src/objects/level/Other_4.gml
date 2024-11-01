
with obj_checkpoint {
	if array_contains(global.data.checkpoints, index) {
		collected = true;
	}
}

with obj_player {
	game_checkpoint_set(global.data.location);
	var _checkpoint = game_checkpoint_ref();
	x = _checkpoint.x;
	y = _checkpoint.y;
}
