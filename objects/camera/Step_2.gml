
if instance_exists(target) {
	target.cam()
}

var _tx = target_x, _ty = target_y;
var _ts = 0.08;

var _weights = collision_circle(target_x, target_y, 16, obj_camera_focus, true, true);

if _weights != noone {
	var _dist = point_distance(target_x, target_y, _weights.x, _weights.y);
	_tx = lerp(_tx, _weights.x, max(0, 1 - power(_dist / _weights.sprite_width * 2, 1.8)));
	_ty = lerp(_ty, _weights.y, max(0, 1 - power(_dist / _weights.sprite_height * 2, 1.8)));
}

_weights = collision_circle(target_x, target_y, 16, obj_camera_room, true, true);

if _weights != noone {
	
	var _cam_w = camera_get_view_width(view_camera[0]),
		_cam_h = camera_get_view_height(view_camera[0])
	
	if _weights.sprite_width <= _cam_w {
		_tx = _weights.x + _weights.sprite_width / 2;
	} else {
		_tx = clamp(_tx, _weights.x + _cam_w / 2, _weights.x + _weights.sprite_width - _cam_w / 2)
	}
	
	if _weights.sprite_height <= _cam_h {
		_ty = _weights.y + _weights.sprite_height / 2;
	} else {
		_ty = clamp(_ty, _weights.y + _cam_h / 2, _weights.y + _weights.sprite_height - _cam_h / 2)
	}
	
}

if roomsnap_last != _weights {
	roomsnap_timer = 1;
}
roomsnap_last = _weights
	
roomsnap_timer = approach(roomsnap_timer, 0, 0.05)
_ts = lerp(_ts, 0, roomsnap_timer)


x = lerp(x, _tx, _ts);
y = lerp(y, _ty, _ts);

