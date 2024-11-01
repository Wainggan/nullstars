
function Menu() constructor {
	
	stack = []
	
	static open = function(_page){
		_page.init();
		array_push(stack, _page);
		return self;
	}
	
	static update = function(){
		
		if array_length(stack) == 0 return;
		
		var _stack = array_last(stack);
		_stack.update(self);
		
	}
	
	static close = function(){
		array_pop(stack)
	}
	
	static stop = function(){
		while array_length(stack)
			close();
	}
	
}


function MenuPage() constructor {
	
	// run once when added to Menu()
	static init = function(){};
	
	// run if input is available to the player
	static update = function(){};
	
	// run every frame on draw
	static draw = function(){};
	
}

function MenuPageList() : MenuPage() constructor {
	
	list = [];
	current = 0;
	
	static init = function() {
		current = 0;
	}
	
	static update = function(_menu) {
		
		var _kh = 
			INPUT.check_stutter("right", 8, 4) -
			INPUT.check_stutter("left", 8, 4);
			
		var _kv = 
			INPUT.check_stutter("down", 8, 5) -
			INPUT.check_stutter("up", 8, 5);
			
		var _click = INPUT.check_pressed("jump");
		var _close = INPUT.check_pressed("dash");
		
		current = mod_euclidean(current + _kv, array_length(list));
		
		if _click || _kh != 0 {
			list[current].input(_click, _kh < 0, _kh > 0);
			return;
		}
		
		if _close {
			_menu.close();
		}
		
	}
	
	static add = function(_item) {
		array_push(list, _item);
		return self;
	}
	
	static draw = function(_x, _y, _anim) {
		
		if _anim == 0 return;
		
		draw_set_font(ft_sign);
		draw_set_color(#cccccc);
		
		draw_sprite_stretched(spr_sign_board, 0, _x, _y, 200, 200 * tween(Tween.Circ, _anim));
		
		if _anim < 1 return;
		
		static _pad_x = 8;
		static _pad_y = 11;
		static _option_pad = 14;
		
		for (var j = 0; j < array_length(list); j++) {
			var _e = list[j]
			if j == current
				draw_text(_x + _pad_x, _y + _pad_y + j * _option_pad, ">");
			_e.draw(_x + _pad_x + 12, _y + _pad_y + j * _option_pad, _x + 200 - _pad_x * 2, j == current);
		}
		
		draw_set_color(c_white);
		
	}
	
}

function MenuPageMap() : MenuPage() constructor {
	
	cam_x = 0;
	cam_y = 0;
	cam_scale = 1 / 24;
	
	static init = function() {
		cam_x = obj_player.x;
		cam_y = obj_player.y;
	}
	
	static update = function(_menu) {
		
		var _kh = INPUT.check("right") - INPUT.check("left");
		var _kv = INPUT.check("down") - INPUT.check("up");
		
		var _click = INPUT.check_pressed("jump");
		var _close = INPUT.check_pressed("dash");
		
		
		var _dir = point_direction(0, 0, _kh, _kv);
	
		if _kh != 0 || _kv != 0 {
			cam_x += lengthdir_x(3 / cam_scale, _dir);
			cam_y += lengthdir_y(3 / cam_scale, _dir);
		}
		
		var _c = noone;
		with obj_checkpoint {
			var _c_dist = point_distance(other.cam_x, other.cam_y, x, y);
			var _c_dir = point_direction(other.cam_x, other.cam_y, x, y);

			if _c_dist < 16 / other.cam_scale {
				other.cam_x = approach(other.cam_x, x, abs(lengthdir_x(1 / other.cam_scale, _c_dir)));
				other.cam_y = approach(other.cam_y, y, abs(lengthdir_y(1 / other.cam_scale, _c_dir)));
				_c = self;
				break;
			}
		}
		
		if _click && _c != noone {
			_menu.stop();
		
			game_camera_set_shake(2, 0.5);
			game_set_pause(2)
		
			game_checkpoint_set(_c.index);
		
			instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_player_death);
			instance_destroy(obj_player);
		
			return;
		}
		
		if _close {
			_menu.close();
			return;
		}
		
	}
	
	static draw = function(_x, _y, _anim) {
		
		if _anim == 0 return;
		
		var _cam = game_camera_get();
		
		var _pos_x = 0 + WIDTH / 2;
		var _pos_y = 0 + HEIGHT / 2;
		var _pos_w = 400 * hermite(_anim);
		var _pos_h = 300 * hermite(_anim);

		var _pos_xoff = _pos_x - _pos_w / 2;
		var _pos_yoff = _pos_y - _pos_h / 2;

		draw_sprite_stretched_ext(spr_map_background, 0, _pos_xoff, _pos_yoff, _pos_w, _pos_h, c_black, 1);
	
		with obj_checkpoint {
			var _c_x = (x - other.cam_x) * (other.cam_scale);
			var _c_y = (y - other.cam_y) * (other.cam_scale);
			var _dist = point_distance(0, 0, _c_x, _c_y);
			var _dir = point_direction(0, 0, _c_x, _c_y);
		
			_c_x += lengthdir_x(power(_dist / 12, 1.5) + WIDTH * 0.5 * hermite(1 - _anim), _dir);
			_c_y += lengthdir_y(power(_dist / 12, 1.5) + HEIGHT * 0.5 * hermite(1 - _anim), _dir);
		
			draw_sprite_ext(
				spr_player_tail, 0, 
				WIDTH / 2 + 0 + _c_x,
				HEIGHT / 2 + 0 + _c_y,
				tween(Tween.Circ, _anim), 
				tween(Tween.Circ, _anim),
				0, c_white, 1,
			);
		}
	
		draw_sprite(spr_debug_marker, 0, 0 + WIDTH / 2, 0 + HEIGHT / 2);
	
	}

}


function MenuOption() constructor {
	
	static __none = function(){}
	
	callback = __none;
	input = __none;
	
	static draw = function(_x, _y){
		draw_text(_x, _y, "- empty -")
	}
	
}

function MenuButton(_text, _callback = __none) : MenuOption() constructor {
	
	text = _text;
	callback = _callback;
	
	input = function(_click, _left, _right){
		if _click callback(self);
	}
	
	static draw = function(_x1, _y, _x2, _selected){
		var _last = draw_get_color()
		if _selected draw_set_color(c_white);
		draw_text(_x1, _y, text)
		
		if _selected draw_set_color(_last);
	}
	
}

function MenuSlider(_text, _min = 0, _max = 1, _value = 0, _iter = 0.1, _callback = __none) : MenuOption() constructor {
	
	text = _text;
	low = _min;
	high = _max;
	value = _value;
	iter = _iter;
	callback = _callback;
	
	input = function(_click, _left, _right){
		value = clamp(value + (_right - _left) * iter, low, high)
		callback(self, _right - _left);
	}
	
	static draw = function(_x1, _y, _x2, _selected){
		var _last = draw_get_color()
		if _selected draw_set_color(c_white);
		
		draw_text(_x1, _y, text)

		draw_line(_x1 + (_x2 - _x1) / 2, _y, _x2, _y)
		
		var _p = (_x2 - _x1) / 2 + (_x2 - _x1) / 2 * (abs(value - low) / abs(high - low))
		draw_line(_x1 + _p, _y, _x1 + _p, _y + 4)
		
		if _selected draw_set_color(_last);
	}
	
}

function MenuRadio(_text, _options = [], _value = 0, _callback = __none) : MenuOption() constructor {
	
	text = _text;
	options = _options
	value = _value;
	callback = _callback;
	
	input = function(_click, _left, _right){
		value = mod_euclidean(value + (_right - _left), array_length(options))
		callback(self, _right - _left);
	}
	
	static draw = function(_x1, _y, _x2, _selected){
		var _last = draw_get_color()
		if _selected draw_set_color(c_white);
		
		draw_text(_x1, _y, text)
		
		var _off = 0;
		
		draw_set_halign(fa_right)
		for (var i = array_length(options) - 1; i >= 0; i--) {
			
			draw_text(_x2 - _off, _y, options[i]);
			
			if value == i
				draw_line(_x2 - _off - string_width(options[i]) - 3, _y + 10, _x2 - _off, _y + 10)
			
			_off += string_width(options[i]) + 14
			
		}
		draw_set_halign(fa_left)
		
		if _selected draw_set_color(_last);
	}
	
}

