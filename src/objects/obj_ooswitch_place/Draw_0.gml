
draw_sprite(sprite_index, 1 + global.onoff, x, y)

var _scale = 1 + anim_hit * 0.75
draw_sprite_ext(sprite_index, 0, x, y, _scale, _scale, 0, c_white, 1)

light.color = global.onoff == 0 ? #ffddff : #ddffff;

