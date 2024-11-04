
game_file_load();

global.demonstrate = false;

global.time = 0;

global.onoff = 1;

gif_id = -1;
gif_state = 0;

timer = 0;
timer_active = false;
timer_target = undefined;

instance_create_layer(0, 0, layer, obj_input);
instance_create_layer(0, 0, layer, camera);
instance_create_layer(0, 0, layer, render);
instance_create_layer(0, 0, layer, obj_music);
instance_create_layer(0, 0, layer, obj_menu);

room_goto(rm_game);

game_update_overlay(global.settings.debug.overlay);
game_update_gctime(global.settings.debug.gctime);
game_update_log(global.settings.debug.log);

log(Log.user, $"running nullstars! build {date_datetime_string(GM_build_date)} {GM_build_type} - {GM_version}")


