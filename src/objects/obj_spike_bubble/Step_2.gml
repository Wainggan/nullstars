if (global.time + parity) % GAME_BUBBLE_PARITY > 0 exit;
var _dist_size = 0
if instance_exists(obj_player) {
	var _dist = distance_to_point(obj_player.x, obj_player.y - 16);
	_dist_size = clamp(1 - (_dist) / 256, 0, 1) * 1.5;
}
size = lerp(size, _dist_size, 0.15)