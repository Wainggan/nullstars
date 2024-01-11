anim = approach(anim, 0, 0.002);
if anim <= 0
	instance_destroy()

image_yscale = height * tween(Tween.Ease, anim);
image_alpha = min(1, anim * 2);