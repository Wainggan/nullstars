
function Sod(f = 1, z = 1, r = 0) constructor {
	self.k1 = 0;
	self.k2 = 0;
	self.k3 = 0;
    
	self.value = 0;
	self.value_vel = 0;
	self._lastX = 0;
    
	self.accurate = false;
	self._crit = 0;
	
	self.set_weights(f, z, r);
	
	static set_k = function(k1 = self.k1, k2 = self.k2, k3 = self.k3) {
		self.k1 = k1;
		self.k2 = k2;
		self.k3 = k3;
		self._crit = 
		    self.accurate ? 0.8 * (sqrt(4 * self.k2 + power(self.k1, 2)) - self.k1) : undefined;
		return self;
	}
	
	static set_weights = function(f, z, r) {
		self.k1 = z / (pi * f);
		self.k2 = 1 / power(2 * pi * f, 2);
		self.k3 = (r * z) / (2 * pi * f);
		self._crit = 
			self.accurate ? 0.8 * (sqrt(4 * self.k2 + power(self.k1, 2)) - self.k1) : undefined;
		return self;
	}
	static set_accuracy = function(v = true) {
		self.accurate = v;
		self._crit = 
			self.accurate ? 0.8 * (sqrt(4 * self.k2 + power(self.k1, 2)) - self.k1) : undefined;
		return self;
	}
	static set_value = function(value) {
		self.value = value;
		self._lastX = value;
		self.value_vel = 0;
		return self;
	}
	static get_value = function() {
		return self.value;
	}
	static update = function(x, time = 1, x_vel = undefined) {
		if time <= 0 return self.value;
		
		if (x_vel == undefined) {
		    x_vel = (x - self._lastX) / time;
		    self._lastX = x;
		}
		if (self.accurate) {
		    var iterations = ceil(time / self._crit);
		    time = time / iterations;
		    for (var i = 0; i < iterations; i++) {
			    self.value += self.value_vel * time;
			    var value_accel = 
					(x + self.k3 * x_vel - self.value - self.k1 * self.value_vel) / self.k2 ;
				self.value_vel += time * value_accel;
		    }
		} else {
		    self.value += self.value_vel * time;
		    var newk2 = 
				max(self.k2, 1.1 * (time * time / 4 + time * self.k1 / 2)) ;
			var value_accel = 
				(x + self.k3 * x_vel - self.value - self.k1 * self.value_vel) / newk2 ;
		    self.value_vel += time * value_accel;
		}
		return self.value;
	}
}
