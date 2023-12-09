
target = [obj_player, obj_box, obj_ball]

hit = false;
hit_buffer = 0;

anim_hit = 0;

light = instance_create_layer(x, y, "Lights", obj_light, {
	size: 64,
	intensity: 0.6
})
