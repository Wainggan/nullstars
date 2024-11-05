
function game_sound_get_bgm() {
	
	return (global.settings.sound.bgm * global.settings.sound.mix) / 100
}
function game_sound_get_sfx() {
	return (global.settings.sound.sfx * global.settings.sound.mix) / 100
}
