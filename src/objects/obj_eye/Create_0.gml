
event_inherited()

pet_wall = instance_create_layer(x, y, layer, obj_blank, {
	image_xscale: sprite_width, image_yscale: sprite_height, visible: false
})
pet_chain = instance_create_layer(x + 8, y + 8, layer, obj_blank, {
	image_xscale: sprite_width / 2, image_yscale: sprite_height / 2, visible: true
})
//pet_spike = instance_create_layer(x, y, layer, obj_blank, {
//	image_xscale: sprite_width, image_yscale: sprite_height, visible: true, collidable: false
//})

scan = undefined;

activate = function(){
	state.change(state_attack)
}
riding = function(){ return false; }

attack_dir = 0;
spd = 0;
accel = 0;

chain_x = y;
chain_y = y;

recover_timer = 0;

state = new State()

state_idle = state.add()
.set("step", function(){
	
	if !instance_exists(obj_player) return;
	
	var _dir = point_direction(x + sprite_width / 2, y + sprite_height / 2, obj_player.x, obj_player.y);	
	_dir = round_ext(_dir, 90);
	
	attack_dir = _dir;
	
	pet_wall.collidable = false;
	pet_chain.collidable = false;
	
	var _activate = false;
	var _coords = actor_scan(x, y, _dir);
	scan = {
		x1: min(x, _coords.x), y1: min(y, _coords.y),
		x2: max(x + sprite_width, _coords.x + sprite_width),
		y2: max(y + sprite_height, _coords.y + sprite_height),
		x: _coords.x, y: _coords.y
	};
	var _activate = rectangle_in_rectangle(
		obj_player.bbox_left, obj_player.bbox_top,
		obj_player.bbox_right, obj_player.bbox_bottom,
		scan.x1, scan.y1, scan.x2, scan.y2
	);

	pet_wall.collidable = true;
	
	if _activate {
		activate();
		send();
		return;
	}
	
})

state_attack = state.add()
.set("enter", function(){
	spd = 1;
	accel = 0;
	spd_timer = 12;
	
	chain_x = x;
	chain_y = y;
})
.set("step", function(){
	
	spd = approach(spd, 10, accel);
	if spd_timer <= 0
		accel += 2;
	spd_timer -= 1;
	
	pet_chain.collidable = false;
	pet_wall.collidable = false;
	
	var _coords = actor_scan(x, y, attack_dir);
	scan = {
		x1: min(x, _coords.x), y1: min(y, _coords.y),
		x2: max(x + sprite_width, _coords.x + sprite_width),
		y2: max(y + sprite_height, _coords.y + sprite_height),
		x: _coords.x, y: _coords.y
	};
	
	var _x_vel = clamp(scan.x - chain_x, -spd, spd);
	var _y_vel = clamp(scan.y - chain_y, -spd, spd);
	
	chain_x += _x_vel
	chain_y += _y_vel
	
	pet_chain.collidable = true;
	pet_wall.collidable = true;
	with pet_chain {
		solid_move(_x_vel, _y_vel);
		actor_stretch(
			min(other.x, other.chain_x) + 8,
			min(other.y, other.chain_y) + 8,
			max(other.x + 32, other.chain_x + 32) - 8,
			max(other.y + 32, other.chain_y + 32) - 8,
		)
	}
	
	
	
	if _x_vel == 0 && _y_vel == 0 {
		game_camera_set_shake(4, 0.5)
		state.change(state_recover)
	}
	
})

state_recover = state.add()
.set("enter", function(){
	recover_timer = 60;
})
.set("step", function(){
	recover_timer -= 1;
	if recover_timer <= 0 {
		state.change(state_retract)
	}
})

state_retract = state.add()
.set("enter", function(){
	spd = 0.1;
	accel = 0;
})
.set("step", function(){
	
	spd = approach(spd, 5, 0.1);
	
	var _x_vel = clamp(x - chain_x, -spd, spd);
	var _y_vel = clamp(y - chain_y, -spd, spd);
	
	chain_x += _x_vel
	chain_y += _y_vel
	
	pet_chain.collidable = true;
	with pet_chain {
		solid_move(_x_vel, _y_vel);
		actor_stretch(
			min(other.x, other.chain_x) + 8,
			min(other.y, other.chain_y) + 8,
			max(other.x + 32, other.chain_x + 32) - 8,
			max(other.y + 32, other.chain_y + 32) - 8,
		)
	}
	
	if _x_vel == 0 && _y_vel == 0 {
		state.change(state_idle)
	}
	
})


state.change(state_idle)
