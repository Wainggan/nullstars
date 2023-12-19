

if anim_open > 0
	draw_sprite_stretched(spr_sign_board, 0, anim_x, anim_y, width, height * tween(Tween.Circ, anim_open));

draw_set_font(ft_sign)
draw_set_color(#ff99ff)

if anim_text > 0
	draw_text_ext(anim_x + pad_x, anim_y + pad_y, string_copy(text, 1, clamp(anim_text, 0, string_length(text))), text_pad, width - pad_x * 2)

draw_set_color(c_white)
