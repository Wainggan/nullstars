
/*
 * object representing something that can be loaded dynamically
 * by the level loading system (and thus can be automatically 
 * freed using instance_destroy() at any time)
 * 
 * useful for decorative objects that only need to exist and
 * not much else
 */

outside = function(_cam = game_camera_get()) {
	static __pad = 64;
	return bbox_right <= _cam.x - __pad 
		|| _cam.x + _cam.w + __pad <= bbox_left
		|| bbox_bottom <= _cam.y - __pad
		|| _cam.y + _cam.h + __pad <= bbox_top;
}
