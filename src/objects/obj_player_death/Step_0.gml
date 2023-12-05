
if game_paused() exit;

anim = approach(anim, 1, 0.05);

x = herp(x_start, x_target, anim);
y = herp(y_start, y_target, anim);

if anim >= 1 {
	instance_create_layer(x, y, "Instances", obj_player);
	instance_destroy()
}
