
event_inherited();

/*
 * object representing an active thing in the room, which
 * collides with the scene and other actors.
 * 
 * see `scr_actor`
 */

// speed
x_vel = 0;
y_vel = 0;

// fractional part of x/y
x_rem = 0;
y_rem = 0;

// updated when moved by an obj_Solid
lift_x = 0;
lift_y = 0;
lift_last_x = 0;
lift_last_y = 0;
lift_last_time = 0;

riding = function(_solid) {
	return place_meeting(x, y + 1, _solid);
};
squish = function(){};

