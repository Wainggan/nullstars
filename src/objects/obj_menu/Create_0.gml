
anims = [];
cache = [];
stack_last_length = 0;
stack_last_item = undefined;

system = new Menu();

page_none = new MenuPageList()
.add(new MenuButton("close", function(){
	system.close()
}))
.add(new MenuButton("map", function(){
	system.open(page_map)
}))
.add(new MenuButton("settings", function(){
	system.open(page_settings)
}))
.add(new MenuButton("debug", function(){
	system.open(page_debug);
}))
.add(new MenuButton("exit", function(){
	game_end()
}))

page_map = new MenuPageMap()

page_settings = new MenuPageList()
.add(new MenuButton("back", function(){
	system.close();
}))
.add(new MenuButton("graphics", function(){
	system.open(page_settings_graphics);
}))
.add(new MenuButton("sound", function(){
	system.open(page_settings_sound);
}))

page_settings_graphics = new MenuPageList()
.add(new MenuButton("back", function(){
	system.close();
}))
.add(new MenuRadio("window scale", 
		["1x", "2x", "3x", "4x"],
		global.settings.graphic.windowscale,
		function(_) {
	global.settings.graphic.windowscale = _;
	game_render_set_scale(_ + 1);
	game_file_save();
}))
.add(new MenuRadio("fullscreen", 
		["off", "on"],
		global.settings.graphic.fullscreen,
		function(_) {
	global.settings.graphic.fullscreen = _;
	game_render_set_fullscreen(_);
	game_file_save();
}))
.add(new MenuRadio("screen shake", 
		["none", "0.5x", "1x"],
		global.settings.graphic.screenshake,
		function(_) {
	global.settings.graphic.screenshake = _;
	game_file_save();
}))
.add(new MenuRadio("lights", 
		["none", "simple", "shadows"],
		global.settings.graphic.lights,
		function(_) {
	global.settings.graphic.lights = _;
	game_file_save();
}))
.add(new MenuRadio("reflections", 
		["off", "on"],
		global.settings.graphic.reflections,
		function(_) {
	global.settings.graphic.reflections = _;
	game_file_save();
}))
.add(new MenuRadio("backgrounds", 
		["simplified", "full"],
		global.settings.graphic.backgrounds,
		function(_) {
	global.settings.graphic.backgrounds = _;
	game_file_save();
}))
.add(new MenuRadio("text scale", 
		["1x", "2x"],
		global.settings.graphic.textscale,
		function(_) {
	global.settings.graphic.textscale = _;
	game_file_save();
}))

page_settings_sound = new MenuPageList()
.add(new MenuButton("back", function(){
	system.close();
}))
.add(new MenuSlider("mix", 0, 10, 1, global.settings.sound.mix, function(_) {
	global.settings.sound.mix = _;
	game_file_save();
}))
.add(new MenuSlider("bgm", 0, 10, 1, global.settings.sound.bgm, function(_) {
	global.settings.sound.bgm = _;
	game_file_save();
}))
.add(new MenuSlider("sfx", 0, 10, 1, global.settings.sound.sfx, function(_) {
	global.settings.sound.sfx = _;
	game_file_save();
}))

page_debug = new MenuPageList()
.add(new MenuButton("back", function(){
	system.close();
}))
.add(new MenuButton("clear save data", function(){
	file_delete(FILE_DATA);
	game_end(0);
}))
.add(new MenuButton("gc", function(){
	var _stats = gc_get_stats();
	var _text = $"{_stats}";
	instance_create_layer(0, 0, layer, obj_show_info, {
		text: _text,
		persistent: true,
	});
	show_debug_message(_text);
	gc_collect();
}))


