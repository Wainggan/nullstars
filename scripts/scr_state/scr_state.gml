
function StateChild(_parent = undefined, _top) constructor {
	
	__parent = _parent;
	__top = _top;
	
	// stores every event
	__data = {};
		
	static add = function(){
		var _child = new StateChild(self, __top);
		return _child;
	}
	
	static set = function(_name, _func){
		__data[$ _name] = _func;
		return self;
	}
	
	static run = function(_name){
		if __data[$ _name] != undefined
			__data[$ _name]();
	}
	
	// sets up the inheritance stack.
	// when reaches the top of the tree (parent == undefined), 
	// the Stack controller begins running
	static __delegate = function(_name){
		__top.__push(self);
		if __parent != undefined {
			__parent.__delegate(_name);
		} else {
			__top.child(_name);
		}
		__top.__pop();
	}
	
}

function State() constructor {
	
	__stack = [];
	__depth = 0;
	
	__running = false;
	
	// current running event name
	__name = "";
	
	// the currently targeted state
	__current = undefined;
	
	// if currently running, stores the next targeted state
	// current is set to deferchange at end of run()
	__deferchange = undefined;
	
	__time_state = 0;
	__time_total = 0;
	
	
	static add = function(){
		var _child = new StateChild(undefined, self);
		return _child;
	}
	
	static change = function(_child){
		if !__running {
			__change(_child);
			return;
		}
		__deferchange = _child; // only change event at end of run()
	}
	static __change = function(_child){
		run("leave");
		
		__current = _child;
		__time_state = 0;
		
		run("enter");
	}
	
	static child = function(_name = __name){
		if __depth <= 0 return;
		
		var _lastname = __name;
		__name = _name;
		
		__depth--;
		
		if __stack[__depth].__data[$ _name] != undefined
			__stack[__depth].run(_name);
		else
			child(); // move to next child until match found
		
		__depth++;
		
		__name = _lastname;
	}
	
	static run = function(_name = "step"){
		if __current == undefined return;
		__running = true;
		__depth = 0;
		__name = _name;
		__current.__delegate(_name);
		
		__time_state += 1;
		__time_total += 1;
		
		__running = false;
		if __deferchange != undefined {
			var _child = __deferchange;
			__deferchange = undefined;
			__change(_child)
		}
	}
	
	static is = function(_child){
		return __current == _child;
	}
	
	static __push = function(_child){
		array_push(__stack, _child);
		__depth++;
	}
	
	static __pop = function(){
		array_pop(__stack);
		__depth--;
	}
	
}


