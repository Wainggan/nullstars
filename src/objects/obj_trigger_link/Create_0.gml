
event_inherited()

alarm[0] = 1;

activate_inherit = activate;
activate = function(_other) {
	if obj_a && _other.id != obj_a.id obj_a.activate(self);
	if obj_b && _other.id != obj_b.id obj_b.activate(self);
}

