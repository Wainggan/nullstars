
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

game_update_overlay(global.settings.debug.overlay);
game_update_gctime(global.settings.debug.gctime);

instance_create_layer(0, 0, layer, obj_show_info, {
	text: $"{date_datetime_string(GM_build_date)} {GM_build_type} - {GM_version}",
	persistent: true,
});


