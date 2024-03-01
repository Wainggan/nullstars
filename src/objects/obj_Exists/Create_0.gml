
outside = function(_cam = game_camera_get()) {
	static __pad = 64;
	return bbox_right <= _cam.x - __pad 
		|| _cam.x + _cam.w + __pad <= bbox_left
		|| bbox_bottom <= _cam.y - __pad
		|| _cam.y + _cam.h + __pad <= bbox_top;
}
