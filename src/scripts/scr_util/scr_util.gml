
/// moves `a` to `b` by `amount` without overshooting
/// @arg {real} _a starting value
/// @arg {real} _b ending value
/// @arg {real} _amount positive number to move by
/// @return {real}
/// @pure
function approach(_a, _b, _amount) {
	gml_pragma("forceinline");
	if (_a < _b)
	    return min(_a + _amount, _b); 
	else
	    return max(_a - _amount, _b);
}

/// @pure
function floor_ext(_value, _round) {
	gml_pragma("forceinline");
	if _round <= 0 return _value;
	return floor(_value / _round) * _round;
}
/// @pure
function ceil_ext(_value, _round) {
	gml_pragma("forceinline");
	if _round <= 0 return _value;
	return ceil(_value / _round) * _round;
}
/// @pure
function round_ext(_value, _round) {
	gml_pragma("forceinline");
	if _round <= 0 return _value;
	return round(_value / _round) * _round;
}

/// modulo `value` by `by` such that the result is always positive,
/// using euclidean division: https://en.wikipedia.org/wiki/Modulo
/// @arg {real} _value dividend
/// @arg {real} _by divisor
/// @return {real}
/// @pure
function mod_euclidean(_value, _by) {
	gml_pragma("forceinline");
	return _value - abs(_by) * floor(_value / abs(_by))
}

/// @pure
function map(_value, _start_low, _start_high, _target_low, _target_high) {
    return (((_value - _start_low) / (_start_high - _start_low)) * (_target_high - _target_low)) + _target_low;
}

/// wrapper for `sin()`.
/// sin wave from `from` to `to`, with `duration` long period.
/// @arg {real} _from
/// @arg {real} _to
/// @arg {real} _duration
/// @arg {real} _offset
/// @arg {real} _time
/// @return {real}
/// @pure
function wave(_from, _to, _duration, _offset = 0, _time = global.time / 60) {
	var _a4 = (_from - _to) * 0.5;
	return _to + _a4 + sin(((_time + _duration) / _duration + _offset) * (pi*2)) * _a4;
}

/// @pure
function wrap(_value, _min, _max) {
	_value = floor(_value);
	var _low = floor(min(_min, _max));
	var _high = floor(max(_min, _max));
	var _range = _high - _low + 1;

	return (((floor(_value) - _low) % _range) + _range) % _range + _low;
}

/// @pure
function chance(_percent) {
	gml_pragma("forceinline");
	return _percent > random(1);
}

/// @pure
function parabola(_p1, _p2, _height, _off) {
  return -(_height / power((_p1 - _p2) / 2, 2)) * (_off - _p1) * (_off - _p2)
}
/// @pure
function parabola_mid(_center, _size, _height, _off) {
  return parabola(_center - _size, _center + _size, _height, _off)
}
/// @pure
function parabola_mid_edge(_center, _p, _height, _off) {
  return parabola(_center - (_p - _center), _p, _height, _off)
}

/// smoothstep-style interpolation
/// @arg {real} _t number from 0-1 to remap
/// @return {real}
/// @pure
function hermite(_t) {
	gml_pragma("forceinline");
    return _t * _t * (3.0 - 2.0 * _t);
}
/// smoothstep
/// @pure
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

/// @pure
function multiply_color(_c1, _c2) {
	gml_pragma("forceinline");
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

function array_kick(_array, _index) {
	_array[_index] = _array[array_length(_array) - 1];
	array_pop(_array);
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
