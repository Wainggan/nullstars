
if respawn_timer > 0 {
	draw_circle_outline_part(x, y - 20, 32, 6, respawn_timer / 16 / 2, 90, false, c_white, 1);
	draw_circle_outline_part(x, y - 20, 32, 6, respawn_timer / 16 / 2, 90, true, c_white, 1);
}
