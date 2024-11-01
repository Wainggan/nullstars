
system = new Menu();

page_none = new MenuPageList()
.add(new MenuButton("close", function(){
	system.close()
}))
.add(new MenuSlider("map", 0, 1, 0, 0.1, function(){
	show_debug_message("a")
}))
.add(new MenuRadio("map", ["none", "0.5", "1"], 0, function(){
	show_debug_message("a")
}))
.add(new MenuButton("map", function(){
	system.open(page_map)
}))
.add(new MenuButton("settings", function(){
	system.open(page_settings)
}))
.add(new MenuButton("test3", function(){
	show_debug_message("c")
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
	system.open(page_settings)
}))
.add(new MenuButton("test2", function(){
	show_debug_message("b")
}))
.add(new MenuButton("test3", function(){
	show_debug_message("c")
}))
.add(new MenuButton("test4", function(){
	show_debug_message("d")
}))
