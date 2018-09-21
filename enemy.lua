local clamp = require "math.clamp"
Ball = require 'ball'

Enemy = {
  x = 0,
  y = 0,
  z = 1.0,
  dx = 0,
  dy = 0,
  prevX = 0,
  prevY = 0,
  size = 0.2
}

function Enemy:reset()
  self.x = 0
  self.y = 0
end

function Enemy:getAABB()
  return { x = self.x - self.size/2.0, y = self.y - self.size/2.0, w = self.size, h = self.size }
end

function Enemy:draw(screenWidth, screenHeight)
  local hw = screenWidth / 2.0
  local hh = screenHeight / 2.0
  love.graphics.setColor(1,1,1,0.5)
  love.graphics.rectangle("fill", hw - 0.25 * hw + ((self.x + 1) / 2.0) * (0.25 * screenWidth) - (self.size/2.0) * (0.25 * screenWidth),
                                  hh - 0.25 * hh + ((self.y + 1) / 2.0) * (0.25 * screenHeight) - (self.size/2.0) * (0.25 * screenHeight),
                                  0.25 * screenWidth * self.size,
                                  0.25 * screenHeight * self.size,
                                  0.25 * self.size * screenWidth * 0.1,
                                  0.25 * self.size * screenHeight * 0.1,
                                  20)
end

function Enemy:setCenterPos(centerX, centerY)
  self.x = clamp(centerX, -1.0 + self.size, 1.0 - self.size)
  self.y = clamp(centerY, -1.0 + self.size, 1.0 - self.size) 
end

function Enemy:update(dt, ballPos)
  -- TODO: move at this particular enemy's speed towards the ball each frame
  -- compute and set Dx, Dy to spin the ball

  -- TEST: cheat for now, just be where the ball is:
  local ballPos = Ball:getPos()
  self.x = ballPos.x
  self.y = ballPos.y
end

function Enemy:getMotionDelta() return { dx = self.dx, dy = self.dy } end

function Enemy:triggerWonPoint()
  -- TODO
end

function Enemy:triggerLostPoint()
  -- TODO
end

return Enemy