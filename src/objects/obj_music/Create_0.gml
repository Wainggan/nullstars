
bgm = -1;
bgm_asset = -1;
bgm_asset_last = -1;
bgm_asset_next = -1;

bgm_old = {};

play = false;

state = new State();

state_base = state.add()
.set("step", function() {
	
	var _bgm = game_level_get_music(camera.x, camera.y);
	if array_contains(game_level_get_flags(camera.x, camera.y), "hub") {
		_bgm = "hub";
	}
	
	var _bgm_asset = -1;

	switch _bgm {
		case undefined:
			_bgm_asset = bgm_asset;
			break;
		case "none":
			_bgm_asset = -1;
			break;
		default:
			var _asset = global.data_music_refs[$ _bgm];
			_bgm_asset = asset_get_index(_asset);
			// _bgm_name = global.data_music[$ _asset].name;
			break;
	}
	if keyboard_check_pressed(ord("T")) play = !play
	if !play _bgm_asset = -1;
	
	if state.is(state_idle) {
		if _bgm_asset != bgm_asset {
			// really wish this was calico ...
			bgm_asset_next = _bgm_asset;
			state.change(state_switch);
		}
	} else {
		if _bgm_asset == bgm_asset {
			// feels like a bad idea
			state.change(state_idle);
		}
	}
	
	state.child();
	
	bgm_asset_last = _bgm_asset;
	
})

state_idle = state_base.add()

state_switch = state_base.add()
.set("enter", function() {
	if bgm_asset != -1 audio_sound_gain(bgm, 0, 2000);
})
.set("leave", function() {
	if bgm_asset != -1 audio_sound_gain(bgm, 1, 2000);
})
.set("step", function() {
	if bgm_asset == -1 {
		bgm_asset = bgm_asset_next;
		if bgm_asset != -1 {
			bgm = audio_play_sound(bgm_asset, 0, true, 0);
			if bgm_old[$ bgm_asset] != undefined {
				audio_sound_set_track_position(bgm, bgm_old[$ bgm_asset]);
			}
		}
		state.change(state_idle);
	} else if audio_sound_get_gain(bgm) == 0 {
		bgm_old[$ bgm_asset] = audio_sound_get_track_position(bgm);
		audio_stop_sound(bgm);
		bgm_asset = bgm_asset_next;
		if bgm_asset != -1 {
			bgm = audio_play_sound(bgm_asset, 0, true, 0);
			if bgm_old[$ bgm_asset] != undefined {
				audio_sound_set_track_position(bgm, bgm_old[$ bgm_asset]);
			}
		}
		state.change(state_idle);
	}
})

state.change(state_idle);
