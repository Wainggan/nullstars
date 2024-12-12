
var _inst = instance_place(x, y, obj_player);
if _inst {
	_inst.event.call("bounce", 0, x, bbox_top);
}

