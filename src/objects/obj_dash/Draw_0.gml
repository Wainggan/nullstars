
var _c = state.is(state_active) ? c_white : #aaaaaa;
var _d = round_ext(dir, 9)

var _scale = 1 + anim_hit * 0.5;

draw_sprite_ext(sprite_index, 0, x, y, _scale, _scale, _d, _c, 1)
draw_sprite_ext(sprite_index, 1, x, y, _scale, _scale, -_d, c_white, 1)

