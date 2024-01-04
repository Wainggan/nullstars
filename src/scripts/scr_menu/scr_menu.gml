
function Menu() constructor {
	
	stack = []
	
	static open = function(_item){
		_item.current = 0;
		array_push(stack, _item)
		return self;
	}
	
	static update = function(){
		
		var _kh = 
			INPUT.check_stutter("right", 8, 4) -
			INPUT.check_stutter("left", 8, 4)
			
		var _kv = 
			INPUT.check_stutter("down", 8, 5) -
			INPUT.check_stutter("up", 8, 5)
			
		var _click = INPUT.check_pressed("jump") 
		
		if array_length(stack) == 0 return;
		
		var _stack = array_last(stack);
		
		_stack.current = mod_euclidean(_stack.current + _kv, array_length(_stack.list));
		
		if _click || _kh != 0 {
			_stack.list[_stack.current].input(_click, _kh < 0, _kh > 0);
		}
		
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
	
	list = [];
	current = 0;
	
	static add = function(_item) {
		array_push(list, _item)
		return self;
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

