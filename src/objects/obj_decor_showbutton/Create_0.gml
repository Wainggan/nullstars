
event_inherited()

x_pos = x;
y_pos = y;
index = 0;

switch button {
	case "right":
		index = 1;
		break;
	case "right_up":
		index = 2;
		break;
	case "up":
		index = 3;
		break;
	case "left_up":
		index = 4;
		break;
	case "left":
		index = 5;
		break;
	case "left_down":
		index = 6;
		break;
	case "down":
		index = 7;
		break;
	case "right_down":
		index = 8;
		break;
	case "jump":
		index = 9;
		break;
	case "dash":
		index = 10;
		break;
	case "grab":
		index = 11;
		break;
}

offset = random_range(0, 20000)
