
/// @func approach(a, b, amount)
/// @param {Real} _a
/// @param {Real} _b
/// @param {Real} _amount
/// @returns {Real}
function approach(_a, _b, _amount) {
	if (_a < _b)
	    return min(_a + _amount, _b); 
	else
	    return max(_a - _amount, _b);
}

function round_ext(_value,_round) {
	if _round <= 0 return _value;
	return round(_value / _round) * _round;
}

function map(_val, _start1, _end1, _start2, _end2) {
	var _prop = (_val - _start1)/(_end1-_start1);
	return _prop*(_end2-_start2) + _start2;
}

function wave(_from, _to, _duration, _offset = 0, _time = current_time * 0.001) {
	var _a4 = (_from - _to) * 0.5;
	return _to + _a4 + sin(((_time + _duration * _offset) / _duration) * (pi*2)) * _a4;
}

function wrap(_value,_min,_max) {
	var _mod = ( _value - _min ) mod ( _max - _min );
	if ( _mod < 0 ) return _mod + _max; else return _mod + _min;
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
	var _c_r = (color_get_red(_c1) / 255) * (color_get_red(_c2) / 255)
	var _c_g = (color_get_green(_c1) / 255) * (color_get_green(_c2) / 255)
	var _c_b = (color_get_blue(_c1) / 255) * (color_get_blue(_c2) / 255)
	return make_color_rgb(_c_r * 255, _c_g * 255, _c_b * 255);
}