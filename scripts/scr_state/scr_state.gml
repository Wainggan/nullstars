
function State() constructor {
	
	__current = [];
	__depth = 0;
	__name = "";
	current = undefined;
	
	time = 0;
	
	static add = function(){
		var _child = new StateChild(, self);
		return _child;
	}
	
	static change = function(_child){
		run("leave");
		
		current = _child;
		time = 0;
		
		run("enter");
	}
	
	static child = function(_name = __name){
		if __depth <= 0 return;
		
		var _lastname = __name;
		__name = _name;
		
		__depth--;
		
		if __current[__depth].data[$ _name] != undefined
			__current[__depth].run(_name);
		else
			child(); // move to next child until match found
		
		__depth++;
		
		__name = _lastname;
	}
	
	static run = function(_name = "step"){
		if current == undefined return;
		__depth = 0;
		__name = _name;
		current.__delegate(_name);
		
		time += 1;
	}
	
	static __push = function(_child){
		array_push(__current, _child);
		__depth++;
	}
	
	static __pop = function(){
		array_pop(__current);
		__depth--;
	}
	
}

function StateChild(_parent = undefined, _top) constructor {
	static __none = function(){};
	
	parent = _parent;
	top = _top
	
	data = {};
		
	static add = function(){
		var _child = new StateChild(self, top);
		return _child;
	}
	
	static set = function(_name, _func){
		data[$ _name] = _func;
		return self;
	}
	
	static run = function(_name){
		if data[$ _name] != undefined
			data[$ _name]();
	}
		
	static __delegate = function(_name){
		top.__push(self);
		if parent != undefined {
			parent.__delegate(_name);
		} else {
			top.child(_name);
		}
		top.__pop();
	}
}

state = new State();

state_default = state.add()
.set("step", function(){
	show_debug_message("!! default start")
	state.child();
	show_debug_message("!! default end")
})

state_free = state_default.add()
.set("step", function(){
	show_debug_message("!! free start")
	state.child();
	show_debug_message("!! free end")
})

state_tied = state_free.add()
.set("step", function(){
	show_debug_message("!! tie start")
	state.child();
	show_debug_message("!! tie end")
})
.set("fill", function(){
	show_debug_message("!! free fill start")
	state.child();
	show_debug_message("!! free fill end")
})

state.change(state_tied);

state.run();

