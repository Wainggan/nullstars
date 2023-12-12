
if place_meeting(x, y, obj_player) {
	with obj_player {
		actor_move_x(other.bbox_left - bbox_right)
		bounce(-1)
	}
}
