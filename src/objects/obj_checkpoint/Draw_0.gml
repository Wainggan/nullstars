
var _image = 0;
light.color = #ffffff
light.intensity = 0.4
light.size = 54

if global.game.checkpoint.data(index).collected {
	_image = 2;
	light.color = #ddddff
	light.intensity = 0.6
}
if game_checkpoint_get() == index {
	_image = 1;
	light.color = #ee99ff
	light.intensity = 1
	light.size = 72
}

draw_sprite(sprite_index, _image, x, y)
