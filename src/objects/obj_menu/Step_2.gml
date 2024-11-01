
// make sure cache arrays are same length
while array_length(cache) < array_length(system.stack) {
	array_push(anims, 0);
	array_push(cache, undefined);
}

// animate anims, remove cache items if animation complete
for (var i = 0; i < array_length(anims); i++) {
	if i < array_length(system.stack) {
		anims[i] = approach(anims[i], 1, 0.1);
	} else if cache[i] != undefined {
		anims[i] = approach(anims[i], 0, 0.1);
		if anims[i] == 0 {
			cache[i] = undefined;
		}
	}
}

// this looks *horrible*
// basically the idea is. if the stack lost an item, add it to the cache to be animated
// if the stack gained the item, clear the entire cache
// at least it works (<- coping)

var _change = array_length(system.stack) - stack_last_length;
var _item = stack_last_item;
stack_last_length = array_length(system.stack);
if stack_last_length > 0
	stack_last_item = system.stack[stack_last_length - 1];
else
	stack_last_item = undefined;

if _change == 1 {
	for (var i = 0; i < array_length(cache); i++) cache[i] = undefined;
} else if _change == -1 {
	cache[stack_last_length] = _item;
}

