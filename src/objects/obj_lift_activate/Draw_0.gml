
var _offset_x = sprite_width / 2;
var _offset_y = sprite_height / 2;

var _start_x = start_x + _offset_x;
var _start_y = start_y + _offset_y;

var _end_x = target_x + _offset_x;
var _end_y = target_y + _offset_y;

var _dir = point_direction(_start_x, _start_y, _end_x, _end_y);
var _dist = point_distance(_start_x, _start_y, _end_x, _end_y) / 16 + 1;

draw_sprite_ext(
	spr_debug_timer_start, floor(global.time / 50),
	start_x, start_y, image_xscale, image_yscale,
	0, c_white, 1
);
draw_sprite_ext(
	spr_debug_timer_start, floor(global.time / 50),
	target_x, target_y, image_xscale, image_yscale,
	0, c_white, 1
);

var _color = #333344;
if state.is(state_active) {
	_color = #447755;
} else if state.is(state_retract) {
	_color = #774455;
}

draw_sprite_ext(
	spr_debug_lift_track, 0,
	(_start_x + _end_x) / 2, (_start_y + _end_y) / 2,
	_dist, 1,
	_dir, _color, 1
);
draw_sprite_ext(
	spr_debug_lift_track, 1,
	(_start_x + _end_x) / 2, (_start_y + _end_y) / 2,
	_dist, 1,
	_dir, c_white, 1
);
draw_sprite_ext(
	spr_debug_lift_track, 2 + mod_euclidean(floor(anim_vel), 6),
	(_start_x + _end_x) / 2, (_start_y + _end_y) / 2,
	_dist, 1,
	_dir, c_white, 1
);

