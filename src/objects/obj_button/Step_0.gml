
var _touching = place_meeting(x, y, obj_Actor);

if _touching && !touching {
	trigger_run();
	trigger_send();
}

touching = _touching;

