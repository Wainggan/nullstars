
target = obj_player;

x_sod = new Sod().set_accuracy();
y_sod = new Sod().set_accuracy();

target_x = 0;
target_y = 0;

roomsnap_timer = 0
roomsnap_last = noone;
roomsnap_last_inside = false;
roomsnap_cooldown = 0;

shake_time = 0;
shake_damp = 1;
