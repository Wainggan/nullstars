
for (var i = 0; i < array_length(children); i++) {
	with level_get_instance(children[i]) {
		glue_parent = other.parent;
	}
}

with level_get_instance(parent) {
	glue_children = other.children;
	glue_parent_offset();
}
