
draw_sprite_stretched(spr_speed_base, 0, x, y, sprite_width, sprite_height)
if dir != 0
draw_sprite_stretched(spr_speed_arrows, dir == -1 ? 0 : 1, x + 4, y, sprite_width - 8, sprite_height)
else
draw_sprite_stretched(spr_speed_arrows_lr, 0, x + 4, y, sprite_width - 8, sprite_height)
