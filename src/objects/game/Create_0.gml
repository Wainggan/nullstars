
global.onoff = 1;

timer = 0;
timer_active = false;
timer_target = undefined;

checkpoint_list = {};
checkpoint = "area-split-cont";

instance_create_layer(0, 0, layer, input);
instance_create_layer(0, 0, layer, camera);
instance_create_layer(0, 0, layer, render);
instance_create_layer(0, 0, layer, music);

room_goto(rm_game);

show_debug_overlay(true);

dbg_view("config", false, 40, 40, 300, 300)

var _names = struct_get_names(global.config);
for (var i = 0; i < array_length(_names); i++) {
	dbg_checkbox(ref_create(global.config, _names[i]), _names[i])
}


