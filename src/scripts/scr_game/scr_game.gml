
function Game() constructor {
	
	checkpoint = new GameHandleCheckpoints();
	gate = new GameHandleGates();
	
	
	static unpack = function() {
		checkpoint.unpack();
		
		with obj_player {
			var _checkpoint = game_checkpoint_ref();
			x = _checkpoint.x;
			y = _checkpoint.y;
		}

	}
	static pack = function() {
		checkpoint.pack();
	}
	
}

function GameHandleCheckpoints() constructor {
	list = {};
	current = "intro-0";
	
	static unpack = function() {
		current = global.data.location;
		
		var _names = variable_struct_get_names(global.data.checkpoints);
		for (var i = 0; i < array_length(_names); i++) {
			var _index = _names[i];
			
			list[$ _index].collected = global.data.checkpoints[$ _index].collected;
			list[$ _index].deaths = global.data.checkpoints[$ _index].deaths;
			
		}
	}
	static pack = function() {
		global.data.location = current;
		
		var _names = variable_struct_get_names(list);
		for (var i = 0; i < array_length(_names); i++) {
			var _index = _names[i];
			
			if list[$ _index].collected {
				if global.data.checkpoints[$ _index] == undefined {
					global.data.checkpoints[$ _index] = {};
				}
				global.data.checkpoints[$ _index].collected = true;
				global.data.checkpoints[$ _index].deaths = list[$ _index].deaths;
			}
		}
		
	}
	
	static add = function(_object) {
		if list[$ _object.index] != undefined {
			log(Log.error, $"checkpoint: {_object.index} already exists!");
		}
		list[$ _object.index] = {
			object: _object,
			collected: false,
			deaths: 0,
		};
	}
	static get = function() {
		return current;
	}
	static ref = function(_index) {
		return list[$ _index].object;
	}
	static data = function(_index) {
		return list[$ _index];
	}
	static set = function(_index) {
		current = _index;
	}
	
}
function GameHandleGates() constructor {
	list = {};
	
	static unpack = function() {
		
	}
}

global.game = new Game();


