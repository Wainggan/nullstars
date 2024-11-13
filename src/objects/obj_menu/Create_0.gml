
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
	log(Log.warn, "good luck");
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
.add(new MenuButton("performance", function(){
	system.open(page_settings_performance);
}))
.add(new MenuButton("accessibility", function(){
	system.open(page_settings_accessibility);
}))
.add(new MenuButton("sound", function(){
	system.open(page_settings_sound);
}))

page_settings_graphics = new MenuPageList(260)
.add(new MenuButton("back", function(){
	system.close();
}))
.add(new MenuRadio("window scale", 
		["1x", "2x", "3x", "4x"],
		global.settings.graphic.windowscale,
		function(_) {
	global.settings.graphic.windowscale = _;
	game_update_windowscale(_ + 1);
	game_file_save();
}, @"allows you to set the window scale. particularly useful if you have a high density display.
unused if fullscreen is enabled."))
.add(new MenuRadio("fullscreen", 
		["off", "exclusive", "borderless"],
		global.settings.graphic.fullscreen,
		function(_) {
	global.settings.graphic.fullscreen = _;
	game_update_fullscreen(_);
	game_file_save();
}, @"set the fullscreen.
'exclusive' may run faster than 'borderless', though 'borderless' allows you to change windows easier."))
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
}, @"in weaker graphics cards, lights are the primary cause of performance issues.
- 'shadows' enables all lights.
- 'simple' keeps lights, but disables tile shadow casting. this is usually good enough.
- 'none' disables lights entirely."))
.add(new MenuRadio("reflections", 
		["off", "on"],
		global.settings.graphic.reflections,
		function(_) {
	global.settings.graphic.reflections = _;
	game_file_save();
}, @"enables background and puddle reflections.
can save some performance in weaker graphics cards."))
.add(new MenuRadio("bloom", 
		["off", "on"],
		global.settings.graphic.bloom,
		function(_) {
	global.settings.graphic.bloom = _;
	game_file_save();
}, @"enables the bloom post processing layer.
can save some performance in weaker graphics cards."))
.add(new MenuRadio("distortion", 
		["off", "on"],
		global.settings.graphic.distortion,
		function(_) {
	global.settings.graphic.distortion = _;
	game_file_save();
}, @"enables the pixel distortion post processing layer.
can save a tiny bit of performance in weaker graphics cards."))
.add(new MenuRadio("backgrounds", 
		["simplified", "0.5x", "full"],
		global.settings.graphic.backgrounds,
		function(_) {
	global.settings.graphic.backgrounds = _;
	game_file_save();
}, @"in weaker graphics cards. shader based backgrounds can eat performance.
- '0.5x' halves the resolution of shader based backgrounds.
- 'simplified' replaces them with a static picture (+3mb ram)."))
.add(new MenuRadio("text scale", 
		["1x", "2x"],
		global.settings.graphic.textscale,
		function(_) {
	global.settings.graphic.textscale = _;
	game_file_save();
}, @"set the ui text scale to something larger if needed"))

page_settings_performance = new MenuPageList()
.add(new MenuButton("back", function(){
	system.close();
}))
.add(new MenuRadio("reduce saves", 
		["off", "on"],
		0,
		function(_) {
	game_file_save();
}, @"normally, nullstars will save the game whenever you change checkpoint, complete a gate, change a setting, etc.
this setting allows you to disable this, requiring you to manually save using the 'save' button."))
.add(new MenuSlider("room loading threshold",
		16, 256, 16,
		0,
		function(_) {
	game_file_save();
}, @"nullstars splits the map into several 'rooms'. when these are loaded, they can take quite a bit of cpu time.
this setting configures how close to the camera view a room must be to be loaded. the smaller the setting, the closer to the camera the room has to be.
smaller values may cause some stuttering in busy areas."))
.add(new MenuSlider("file loading threshold",
		256, 1024, 64,
		0,
		function(_) {
	game_file_save();
}, @"rooms are stored as seperate files. this saves ram, however, it does mean that if you get close to a completely unloaded room, the file will have to be read from your drive.
that can be quite slow on systems with slower hard drives, and may cause short freezes.
this setting configures how close to the camera view a room must be to be kept in memory."))
.add(new MenuSlider("file loading timer",
		0, 40, 4,
		0,
		function(_) {
	game_file_save();
}, @"this settings will set how long it takes (in seconds) for a room far enough away to be completely unloaded (as set in the previous setting) to be actually unloaded.
longer times can reduce how often a file have to be loaded, though it does take more ram."))

page_settings_accessibility = new MenuPageList()
.add(new MenuButton("back", function(){
	system.close();
}))
.add(new MenuRadio("dashes", 
		["normal", "2x", "infinite"],
		0,
		function(_) {
	game_file_save();
}, undefined))
.add(new MenuRadio("invincibility", 
		["off", "on"],
		0,
		function(_) {
	game_file_save();
}, undefined))
.add(new MenuRadio("gate locks", 
		["off", "on"],
		0,
		function(_) {
	game_file_save();
}, undefined))
.add(new MenuRadio("gate terms", 
		["off", "on"],
		0,
		function(_) {
	game_file_save();
}, undefined))


page_settings_sound = new MenuPageList()
.add(new MenuButton("back", function(){
	system.close();
}))
.add(new MenuSlider("mix", 0, 10, 1, global.settings.sound.mix, function(_) {
	global.settings.sound.mix = _;
	global.game.news_sound.push();
	game_file_save();
}))
.add(new MenuSlider("bgm", 0, 10, 1, global.settings.sound.bgm, function(_) {
	global.settings.sound.bgm = _;
	global.game.news_sound.push();
	game_file_save();
}))
.add(new MenuSlider("sfx", 0, 10, 1, global.settings.sound.sfx, function(_) {
	global.settings.sound.sfx = _;
	global.game.news_sound.push();
	game_file_save();
}))

page_debug = new MenuPageList()
.add(new MenuButton("back", function(){
	system.close();
}))
.add(new MenuButton("clear save data", function(){
	file_delete(FILE_DATA);
	game_end(0);
}, @"immediately delete the save file and close the game."))
.add(new MenuButton("gc", function(){
	var _stats = gc_get_stats();
	var _text = $"{_stats}";
	log(Log.note, _text);
	gc_collect();
}, @"force run the gc."))
.add(new MenuRadio("gc time", 
		["100ns", "500ns", "1000ns"],
		global.settings.debug.gctime,
		function(_) {
	global.settings.debug.gctime = _;
	game_update_gctime(global.settings.debug.gctime);
	game_file_save();
}, @"set the gc's target time. may help with stuttering."))
.add(new MenuRadio("overlay", 
		["off", "on"],
		global.settings.debug.overlay,
		function(_) {
	global.settings.debug.overlay = _;
	game_update_overlay(global.settings.debug.overlay);
	game_file_save();
}, @"enable gamemaker's debug overlay."))
.add(new MenuRadio("log", 
		["note", "warn", "error", "user"],
		global.settings.debug.log,
		function(_) {
	global.settings.debug.log = _;
	log(Log.user, $"log level set to {_}")
	game_update_log(global.settings.debug.log);
	game_file_save();
}))


