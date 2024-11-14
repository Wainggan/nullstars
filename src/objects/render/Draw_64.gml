
var _cam = game_camera_get();

// holy shit please fucking kill me
// ??????????
var _x = 0;
var _y = 0;
if instance_exists(obj_player) {
	_x = obj_player.x + 16;
	_y = obj_player.y - 100;
}
for (var i = 0; i < array_length(obj_menu.system.stack); i++) {
	// I feel like I had my entire bloodline implicitly cursed after writing this
	//if i < array_length(obj_menu.system.stack) {
	obj_menu.system.stack[i].draw(_x - _cam.x, _y - _cam.y, 1);
	//}
	//else if obj_menu.cache[i] != undefined {
		//obj_menu.cache[i].draw(_x - _cam_x, _y - _cam_y, obj_menu.anims[i]);
	//}
	_x += 24;
}


var _x = 20,
	_y = _cam.h - 16;

draw_set_font(ft_sign);
draw_set_color(c_white);

for (var i = array_length(global.logger.messages) - 1; i >= 0; i--) {
	draw_text_ext_transformed(
		_x, _y, 
		global.logger.messages[i], 
		-1, -1, 
		1, 1, 
		0
	);
	_y -= 16;
}
