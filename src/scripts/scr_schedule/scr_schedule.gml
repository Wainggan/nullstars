
function Schedule() constructor {
	
	list = [];
	
	static update = function() {
		for (var i = 0; i < array_length(list); i++) {
			var _item = list[i];
			if _item.type == 0 {
				_item.time -= 1;
				if _item.time <= 0 {
					_item.callback();
					array_kick(list, i);
				}
			} else {
				if _item.condition() {
					_item.callback();
					array_kick(list, i);
				}
			}
		}
	}
	
	static add_wait = function(_time, _callback) {
		array_push(list, {
			type: 0,
			time: _time,
			callback: _callback,
		});
		return self;
	}
	static add_condition = function(_condition, _callback) {
		array_push(list, {
			type: 1,
			condition: _condition,
			callback: _callback,
		});
		return self;
	}
	
}