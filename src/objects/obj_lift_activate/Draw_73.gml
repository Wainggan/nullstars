
draw_sprite_ext(spr_debug_lift_activate, 0, x, y, image_xscale, image_yscale, 0, c_white, 1);


var _pad = 5;
draw_sprite_stretched_ext(
	spr_debug_lift_activate_rail, 1 + mod_euclidean(floor(anim_vel / 4), 8),
	x + _pad, y + _pad, sprite_width - _pad - _pad, sprite_height - _pad - _pad,
	#444444, 1
);

_pad = 8;
draw_sprite_stretched_ext(
	spr_debug_lift_activate_rail, 1 + mod_euclidean(floor(-anim_vel / 5), 8),
	x + _pad, y + _pad, sprite_width - _pad - _pad, sprite_height - _pad - _pad,
	#444444, 1
);

_pad = 5;
draw_sprite_stretched(
	spr_debug_lift_activate_rail, 0,
	x + _pad, y + _pad, sprite_width - _pad - _pad, sprite_height - _pad - _pad
);
