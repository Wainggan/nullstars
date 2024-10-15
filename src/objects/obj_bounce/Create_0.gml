
event_inherited()

glue_child_setup();
glue_child_set_move(function (_x, _y) {
	x = _x;
	y = _y;
});

boxable = [obj_ball, obj_box] // @todo: need to fix
