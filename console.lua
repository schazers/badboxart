Console = {
    redBarSecondsUntilOff = 0.0,
    yellowLightsSecondsUntilOff = 0.0,
}

function Console:init()
    -- init the grid contents?
end

function Console:draw()
    if self.redBarSecondsUntilOff > 0 then
        love.graphics.setColor(1.0, 0.4, 0.4, 1.0)
        love.graphics.polygon("fill", 192, 546, 200, 546, 211, 554, 203, 554)
    end
end

function Console:update(dt)
    self.redBarSecondsUntilOff = self.redBarSecondsUntilOff - dt
end

function Console:doPlayerJustHitEffect()
    self.redBarSecondsUntilOff = 0.3
end

return Console