
/// preferred way to check for entity collision
function entity_at(_x, _y, _type) {
	static __list = ds_list_create();
	ds_list_clear(__list);
	
	instance_place_list(_x, _y, _type, __list, false);
	
	for (var i = 0; i < ds_list_size(__list); i++) {
		var _o = __list[| i];
		if _o.collidable {
			return _o;
		}
	}
	
	return noone;
}

