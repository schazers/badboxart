local shake = {}
shake.__index = shake

local new = function (angle, intensity, duration, speed)
	self = {
		angle		= angle,
		intensity	= intensity,
		duration	= duration,
		speed		= speed,
		time		= duration,
		finished	= false,
		x			= math.cos(angle),
		y			= math.sin(angle)
	}
	
	return setmetatable(self, shake)
end

shake.update = function (self, dt)
	if self.time > 0 then
        self.time = self.time - dt
    end
    self.finished = self.time <= 0
end

shake.restart = function (self)
	self.time = 0
end

shake.get = function (self)
	if not self.finished then
		local perc	= math.sqrt(self.time/self.duration)
		local r		= perc * math.sin(self.time * self.speed * perc) * self.intensity
		local dx	= self.x * r
		local dy	= self.y * r

		return dx, dy, self.angle, r
	end
	
	return 0, 0, self.angle, 0
end

return new