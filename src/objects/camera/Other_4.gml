if instance_exists(target) {
	var _cam = game_camera_get()
	x = target.x - _cam.w / 2
	y = target.y - _cam.h / 2
}