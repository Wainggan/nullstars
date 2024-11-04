
function News() constructor {

	observers = [];
	
	static push = function(_data) {
		for (var i = 0; i < array_length(observers); i++) {
			observers[i](_data);
		}
	}

	static subscribe = function(_callback) {
		array_push(observers, _callback);
	}
	
	static unsubscribe = function(_callback) {
		var _index = array_get_index(observers, _callback);
		if _index == -1 {
			return false;
		}
		array_delete(observers, _index, 1);
		return true;
	}

}


