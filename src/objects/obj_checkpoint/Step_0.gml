
if game_checkpoint_get() != index && place_meeting(x, y, obj_player) {
	game_checkpoint_set(index);
	game_set_pause(4)
}

if game_checkpoint_get() == index {
	collected = true;
}

