

instance_create_layer(obj_player.x, obj_player.y, "Lights", obj_light, {
	color: choose(#ff00ff, #00ffff),
	size: random_range(30, 50),
	intensity: random_range(1, 2)
});