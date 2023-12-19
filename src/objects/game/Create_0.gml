
global.onoff = 1;

timer = 0;
timer_active = false;
timer_target = undefined;

checkpoint_list = [];
checkpoint = 0;

instance_create_layer(0, 0, layer, input);
instance_create_layer(0, 0, layer, camera);
instance_create_layer(0, 0, layer, render);
instance_create_layer(0, 0, layer, music);

room_goto(rm_game);

//show_debug_overlay(true, true);
