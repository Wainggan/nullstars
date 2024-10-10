
var _bgm = game_level_get_music(camera.x, camera.y);
var _bgm_asset = -1;
var _bgm_name = "";

if array_contains(game_level_get_flags(camera.x, camera.y), "hub") {
	_bgm = "hub";
}

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
		_bgm_name = global.data_music[$ _asset].name;
		break;
}

if keyboard_check_pressed(ord("T")) play = !play

if !play
	_bgm_asset = -1;

if _bgm_asset != bgm_asset {
	bgm_from = bgm_asset;
	bgm_asset = _bgm_asset;
	bgm_anim_state = 1;
	bgm_name = _bgm_name
	
	if bgm_from != -1 {
		audio_sound_gain(bgm, 0, 10000)
	} else {
		bgm = audio_play_sound(bgm_asset, 0, true, 0);
		audio_sound_gain(bgm, 1, 10000);
		bgm_anim_state = 2;
		
		//instance_create_layer(0, 0, "Meta", obj_musicname, { name: bgm_name })
	}
}

if bgm_anim_state == 1 {
	if audio_sound_get_gain(bgm) == 0 {
		audio_stop_sound(bgm)
		bgm = -1;
		if bgm_asset != -1 {
			bgm = audio_play_sound(bgm_asset, 0, true, 0);
			audio_sound_gain(bgm, 1, 10000)
			bgm_anim_state = 2;
			
			//instance_create_layer(0, 0, "Meta", obj_musicname, { name: bgm_name })
		}
	}
}

if bgm_anim_state == 2 {
	if audio_sound_get_gain(bgm) == 1 {
		bgm_anim_state = 0;
	}
}

