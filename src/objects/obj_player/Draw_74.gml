
var _cam = game_camera_get();

if respawn_timer > 0 {
	var _prog = min(tween(Tween.MidSlow, respawn_timer / 16), 1) / 2;
	draw_circle_outline_part(x - _cam.x, y - _cam.y - 20, 32, 6, _prog, 90, false, c_white, 1, 24);
	draw_circle_outline_part(x - _cam.x, y - _cam.y - 20, 32, 6, _prog, 90, true, c_white, 1, 24);
}

