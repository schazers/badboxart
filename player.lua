local clamp = require "math.clamp"

Player = {
  x = 0,
  y = 0,
  z = 0,
  dx = 0,
  dy = 0,
  prevX = 0,
  prevY = 0,
  size = 0.2,
}

function Player:reset()
  self.x = 0
  self.y = 0
end

function Player:draw(screenWidth, screenHeight)
  love.graphics.setColor(1,1,1,0.5)
  love.graphics.rectangle("fill", ((self.x + 1) / 2.0) * screenWidth - (self.size/2.0) * screenWidth,
                                  ((self.y + 1) / 2.0) * screenHeight - (self.size/2.0) * screenHeight, 
                                  screenWidth * self.size, 
                                  screenHeight * self.size,
                                  self.size * screenWidth * 0.1,
                                  self.size * screenHeight * 0.1,
                                  20)
end

function Player:getWidth()
  return self.size
end

function Player:getHeight()
  return self.size
end

function Player:getAABB()
  return { x = self.x - self.size/2.0, y = self.y - self.size/2.0, w = self.size, h = self.size }
end

function Player:getX() return self.x end
function Player:getY() return self.y end
function Player:getZ() return self.z end

function Player:setCenterPos(centerX, centerY)
  self.prevX = self.x
  self.prevY = self.y
  self.x = clamp(centerX, -1.0 + self.size, 1.0 - self.size)
  self.y = clamp(centerY, -1.0 + self.size, 1.0 - self.size)
end

function Player:getMotionDelta() return { dx = self.dx, dy = self.dy } end

function Player:update(dt)
  -- TODO: slew paddle motion towards 0 slowly so there's a grace period for them to put spin.
  -- otherwise they'll have to time it perfectly on the frame of the hit to get spin
  self.dx = self.x - self.prevX
  self.dy = self.y - self.prevY
end

function Player:triggerLostPoint()
  -- TODO: anything?
end

return Player
