
x_pos = x;
y_pos = y;
index = 0;

switch button {
	case "right":
		index = 1;
		break;
	case "up":
		index = 2;
		break;
	case "left":
		index = 3;
		break;
	case "down":
		index = 4;
		break;
	case "jump":
		index = 5;
		break;
	case "dash":
		index = 6;
		break;
	case "grab":
		index = 7;
		break;
}

offset = random_range(0, 20000)
