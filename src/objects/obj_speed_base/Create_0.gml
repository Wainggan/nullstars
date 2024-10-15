
event_inherited();

glue_child_setup();
glue_child_set_move(function (_target_x, _target_y) {
	solid_move(_target_x - x, _target_y - y);
});

depth = 0;

dir = 0;
