
event_inherited()

/*
 * object representing anything impassable by
 * any obj_Actor. walls, moving platforms.
 * 
 * see `scr_solid`
 */

// fractional part of x/y
x_rem = 0;
y_rem = 0;

// updated to related speed when solid_move_#() is called
lift_x = 0;
lift_y = 0;

