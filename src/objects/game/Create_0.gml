
global.onoff = 1;

checkpoint = undefined;

instance_create_layer(0, 0, layer, camera);
instance_create_layer(0, 0, layer, obj_background);

room_goto(rm_game);
