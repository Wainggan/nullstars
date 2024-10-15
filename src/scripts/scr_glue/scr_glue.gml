

function glue_parent_setup() {
	static __empty = [];
	glue_children = __empty;
}

function glue_parent_offset() {
	for (var i = 0; i < array_length(glue_children); i++) {
		var _inst = level_get_instance(glue_children[i]);
		_inst.glue_offset_x = _inst.x - x;
		_inst.glue_offset_y = _inst.y - y;
	}
}

function glue_parent_moved(_x, _y) {
	for (var i = 0; i < array_length(glue_children); i++) {
		var _inst = level_get_instance(glue_children[i]);
		show_debug_message("{0} {1}", _inst.glue_offset_x, _inst.glue_offset_y, _x, _y);
		_inst.glue_move(_x + _inst.glue_offset_x, _y + _inst.glue_offset_y);
	}
}


function glue_child_setup() {
	static __none = function(){};
	glue_move = __none;
	glue_parent = undefined;
	glue_offset_x = 0;
	glue_offset_y = 0;
}

function glue_child_set_move(_callback) {
	glue_move = _callback;
}

function glue_child_dependant() {
	return glue_parent != undefined;
}
