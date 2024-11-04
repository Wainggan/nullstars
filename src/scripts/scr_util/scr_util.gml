
/// @func approach(a, b, amount)
/// @param {real} _a
/// @param {real} _b
/// @param {real} _amount
/// @returns {real}
function approach(_a, _b, _amount) {
	if (_a < _b)
	    return min(_a + _amount, _b); 
	else
	    return max(_a - _amount, _b);
}

function floor_ext(_value, _round) {
	if _round <= 0 return _value;
	return floor(_value / _round) * _round;
}
function ceil_ext(_value, _round) {
	if _round <= 0 return _value;
	return ceil(_value / _round) * _round;
}
function round_ext(_value, _round) {
	if _round <= 0 return _value;
	return round(_value / _round) * _round;
}

function mod_euclidean(_value, _by) {
	return _value - abs(_by) * floor(_value / abs(_by))
}

function map(_value, _start_low, _start_high, _target_low, _target_high) {
    return (((_value - _start_low) / (_start_high - _start_low)) * (_target_high - _target_low)) + _target_low;
}

function wave(_from, _to, _duration, _offset = 0, _time = global.time / 60) {
	var _a4 = (_from - _to) * 0.5;
	return _to + _a4 + sin(((_time + _duration) / _duration + _offset) * (pi*2)) * _a4;
}


function wrap(_value, _min, _max) {
	_value = floor(_value);
	var _low = floor(min(_min, _max));
	var _high = floor(max(_min, _max));
	var _range = _high - _low + 1;

	return (((floor(_value) - _low) % _range) + _range) % _range + _low;
}


function chance(_percent) {
	return _percent > random(1);
}

function parabola(_p1, _p2, _height, _off) {
  return -(_height / power((_p1 - _p2) / 2, 2)) * (_off - _p1) * (_off - _p2)
}
function parabola_mid(_center, _size, _height, _off) {
  return parabola(_center - _size, _center + _size, _height, _off)
}
function parabola_mid_edge(_center, _p, _height, _off) {
  return parabola(_center - (_p - _center), _p, _height, _off)
}

function hermite(_t) {
    return _t * _t * (3.0 - 2.0 * _t);
}
function herp(_a, _b, _t) {
	return lerp(_a, _b, hermite(_t));
}

function struct_assign(_target, _assign) {
	var _names = struct_get_names(_assign);
	for (var i = 0; i < array_length(_names); i++) {
		_target[$ _names[i]] = _assign[$ _names[i]]
	}
	return _target;
}

function array_from_list(_list) {
	var _array = array_create(ds_list_size(_list));
	for (var i = 0; i < ds_list_size(_list); i++) {
		_array[i] = _list[| i];
	}
	return _array;
}

function instance_place_array(_x, _y, _obj, _ordered) {
	var _list = ds_list_create();
	instance_place_list(_x, _y, _obj, _list, _ordered);
	var _array = array_from_list(_list);
	ds_list_destroy(_list);
	return _array;
}

function multiply_color(_c1, _c2) {
	return _c1 * _c2 / #ffffff;
}

// for the one time i need this
function hex_to_dec(_hex) {
    var _dec = 0;
 
    static _dig = "0123456789ABCDEF";
    var _len = string_length(_hex);
    for (var i = 1; i <= _len; i += 1) {
        _dec = _dec << 4 | (string_pos(string_char_at(_hex, i), _dig) - 1);
    }
 
    return _dec;
}

function variable_ref_create(_inst, _name) {
	with { _inst, _name } return function() {
		if (argument_count > 0) {
			variable_instance_set(_inst, _name, argument[0]);
		} else return variable_instance_get(_inst, _name);
	}
}

function array_ref_create(_array, _index) {
	with { _array, _index } return function() {
		if (argument_count > 0) {
			_array[_index] = argument[0];
		} else return _array[_index];
	}
}
