
var _touching = place_meeting(x, y, obj_Actor);

if _touching && !touching {
	activate();
	send();
}

touching = _touching;

