
event_inherited()

light = instance_create_layer(x + 16, y + 16, "Lights", obj_light, {
	color: #8855ff,
	intensity: 0.9,
	size: 96
})

anim_open = 0;
anim_text = 0;
anim_off = 0;

last = false;

pad_x = 8;
pad_y = 7;
text_pad = 10;

width = 164;

draw_set_font(ft_sign)
height = string_height_ext(text, text_pad, width - pad_x * 2) + pad_y * 2;

anim_x = x
anim_y = y

image_index = irandom_range(0, sprite_get_number(sprite_index))
	