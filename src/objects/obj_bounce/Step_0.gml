
if place_meeting(x, y, obj_player) {
	with obj_player {
		actor_move_y(other.bbox_top - y)
		bounce()
	}
}
