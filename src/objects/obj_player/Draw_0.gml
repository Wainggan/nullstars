
draw_sprite_ext(
	nat_crouch() ? spr_debug_player_crouch : spr_debug_player,
	0, x, y,
	scale_x * dir, scale_y,
	0, c_white, image_alpha
);
