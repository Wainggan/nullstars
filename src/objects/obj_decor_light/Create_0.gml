
event_inherited();

light = instance_create_layer(x, y, layer, obj_light);
with light {
	color = other.color;
	intensity = other.intensity;
	size = other.size;
}

image_blend = color;

