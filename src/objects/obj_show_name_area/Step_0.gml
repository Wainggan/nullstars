
if state == 0 {
	anim = approach(anim, 1, 1 / 180)
	if anim == 1 state = 1
} else if state == 1 {
	pause -= 1
	if pause <= 0 state = 2;
} else {
	anim = approach(anim, 0, 1 / 180)
	if anim == 0 instance_destroy()
}
