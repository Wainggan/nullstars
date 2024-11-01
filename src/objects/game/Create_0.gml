
game_file_load();

global.time = 0;

global.onoff = 1;

timer = 0;
timer_active = false;
timer_target = undefined;

checkpoint_list = {};
checkpoint = "area-split-cont";

instance_create_layer(0, 0, layer, obj_input);
instance_create_layer(0, 0, layer, camera);
instance_create_layer(0, 0, layer, render);
instance_create_layer(0, 0, layer, music);
instance_create_layer(0, 0, layer, obj_menu);

room_goto(rm_game);

show_debug_overlay(true);

dbg_view("config", false, 40, 40, 300, 300)

var _names = struct_get_names(global.config);
array_sort(_names, true)
for (var i = 0; i < array_length(_names); i++) {
	dbg_checkbox(ref_create(global.config, _names[i]), _names[i])
}

gc_target_frame_time(1000)

instance_create_layer(0, 0, layer, obj_show_info, { persistent: true });


