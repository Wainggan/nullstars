
global.version = {
	major: 0,
	minor: 0,
	patch: 0,
};

#macro FILE_DATA "save.star"
#macro FILE_INPUT "input.ini"

#macro FILE_DATA_VERSION 0

global.file = undefined;
global.settings = undefined;
global.data = undefined;

global.file_default = {
	"version": {
		"major": 0,
		"minor": 0,
		"patch": 0
	},
	"json": 0,
	"data": {
		"flags": {},
		"location": "intro-0",
		"checkpoints": [],
		"stats": {
			"deaths": 0
		},
		"gates": {}
	},
	"settings": {
		"graphic": {
			"screenshake": 1,
			"lights": 2
		},
		"sound": {
			"bgm": 8,
			"sfx": 9,
			"all": 10
		}
	}
}

function game_file_update(_file) {
	var i = _file.json;
	for (; i < FILE_DATA_VERSION; i++) {
		show_debug_message(i);
	}
}

function game_file_load() {
	if !file_exists(FILE_DATA) {
		global.file = json_parse(json_stringify(global.file_default));
		return;
	}
	
	var _file = game_json_open(FILE_DATA);
	game_file_update(_file);
	global.file = _file;
	global.settings = _file.settings; // alias
	global.data = _file.data; // alias
}

function game_file_save() {
	game_json_save(FILE_DATA, global.file);
}


function game_json_save(_filename, _tree) {
	var _string = json_stringify(_tree);
	var _buffer = buffer_create(string_byte_length(_string)+1, buffer_fixed, 1);
	buffer_write(_buffer, buffer_string, _string);
	buffer_save(_buffer, _filename);
	buffer_delete(_buffer);
}

function game_json_open(_filename) {
	if file_exists(_filename) {
		var _buffer = buffer_load(_filename);
		var _string = buffer_read(_buffer, buffer_string);
		buffer_delete(_buffer);
		
		var _loadData = json_parse(_string, , true);
		
		return _loadData
		
	} else {
		throw $"file {_filename} does not exist";
	}
}

