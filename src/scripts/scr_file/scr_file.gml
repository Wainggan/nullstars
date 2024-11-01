
global.version = {
	major: 0,
	minor: 0,
	patch: 0,
};

#macro FILE_DATA "save.star"
#macro FILE_INPUT "input.ini"

#macro FILE_DATA_VERSION 1

global.file = undefined;
global.settings = undefined;
global.data = undefined;

global.file_default = {
	
	"version": { // game version, used for nothing
		"major": 0,
		"minor": 0,
		"patch": 0,
	},
	"json": 0, // json version, used for updating
	
	"data": {
		
		/*
		flags
		*/
		"flags": {},
		
		"location": "intro-0",
		"checkpoints": [],
		
		/*
		stats
		deaths = total amount of deaths
		*/
		"stats": {
			"deaths": 0,
		},
		
		/*
		gates
		"name": {}
			time = best time in ms
		*/
		"gates": {},
	
	},
	/*
	settings
	graphics:
		windowscale:
			0 = 1x
			1 = 2x
			2 = 3x
			3 = 4x
		textscale:
			0 = 1x
			1 = 2x
		fullscreen:
			0 = off
			1 = on
		screenshake:
			0 = none
			1 = 0.5x
			2 = 1x
		lights:
			0 = off
			1 = rimblur + spotlights
			2 = shadows
		reflections:
			0 = off
			1 = on
		backgrounds:
			0 = simplified
			1 = full
	debug:
		gctime:
			0 = 100
			1 = 500
			2 = 1000
		overlay:
			0 = off
			1 = on
		speed: // fps
			0 = 10fps
			1 = 30fps
			2 = 60fps default
	*/
	"settings": {
		"graphic": {
			"windowscale": 0,
			"textscale": 0,
			"fullscreen": 0,
			"screenshake": 2,
			"lights": 2,
			"reflections": 1,
			"backgrounds": 1,
		},
		"sound": {
			"bgm": 8,
			"sfx": 10,
			"mix": 10,
		},
		"debug": {
			"gctime": 2,
			"overlay": 0,
			"speed": 2,
		}
	},
}

function game_file_update(_file) {
	var i = _file.json;
	for (; i < FILE_DATA_VERSION; i++) {
		log(Log.user, $"updating save file from {_file.json} to {i}...");
	}
}

function game_file_load() {
	if !file_exists(FILE_DATA) {
		global.file = json_parse(json_stringify(global.file_default));
	} else {
		var _file = game_json_open(FILE_DATA);
		game_file_update(_file);
		global.file = _file;
		
		// TEMPORARY
		if global.file.json < FILE_DATA_VERSION {
			log(Log.user, $"save file deleted since the format changed ({global.file.json} => {FILE_DATA_VERSION})");
			file_delete(FILE_DATA);
			game_file_load();
			return;
		}
	}
	global.settings = global.file.settings; // alias
	global.data = global.file.data; // alias
}

function game_file_save() {
	game_json_save(FILE_DATA, global.file);
}


function game_json_save(_filename, _tree) {
	log(Log.note, $"saving file {_filename}");
	var _string = json_stringify(_tree);
	var _buffer = buffer_create(string_byte_length(_string)+1, buffer_fixed, 1);
	buffer_write(_buffer, buffer_string, _string);
	buffer_save(_buffer, _filename);
	buffer_delete(_buffer);
}

function game_json_open(_filename) {
	if file_exists(_filename) {
		log(Log.note, $"loading file {_filename}");
		
		var _buffer = buffer_load(_filename);
		var _string = buffer_read(_buffer, buffer_string);
		buffer_delete(_buffer);
		
		var _loadData = json_parse(_string, , true);
		
		return _loadData
		
	} else {
		throw $"file {_filename} does not exist";
	}
}

