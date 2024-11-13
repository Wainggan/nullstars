
if game_paused() exit;

age += 1;
if age >= life {
	instance_destroy();
	exit;
}

scale = tween(Tween.Circ, age / life) * size;
alpha = (1 - tween(Tween.Ease, age / life)) * strength;

