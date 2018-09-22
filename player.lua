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
  timeSinceTouchedBall = 1000,
}

function Player:reset()
  self.x = 0
  self.y = 0
  self.timeSinceTouchedBall = 1000
end

function Player:draw(screenWidth, screenHeight)
  local baseAlpha = 0.38
  local extraAlpha = 0
  local kSecondsOfPaddleFade = 0.22
  if self.timeSinceTouchedBall < kSecondsOfPaddleFade then 
    extraAlpha = (baseAlpha - (baseAlpha * (self.timeSinceTouchedBall / kSecondsOfPaddleFade)))
  end
  local alpha = baseAlpha + extraAlpha

  love.graphics.setColor(1,1,1,alpha)
  love.graphics.rectangle("fill", ((self.x + 1) / 2.0) * screenWidth - (self.size/2.0) * screenWidth,
                                  ((self.y + 1) / 2.0) * screenHeight - (self.size/2.0) * screenHeight, 
                                  screenWidth * self.size, 
                                  screenHeight * self.size,
                                  self.size * screenWidth * 0.1,
                                  self.size * screenHeight * 0.1,
                                  20)
end

function Player:getAABB()
  return { x = self.x - self.size * 2.0, y = self.y - self.size * 2.0, w = self.size * 4.0, h = self.size * 4.0 }
end

function Player:setCenterPos(centerX, centerY)
  self.prevX = self.x
  self.prevY = self.y
  self.x = clamp(centerX, -1.0 + self.size, 1.0 - self.size)
  self.y = clamp(centerY, -1.0 + self.size, 1.0 - self.size)
end

function Player:getMotionDelta() return { dx = self.dx, dy = self.dy } end

function Player:update(dt)
  -- TODO: grace period for spin (after ball leaves paddle, continue applying paddle motion to ball?)
  self.dx = self.x - self.prevX
  self.dy = self.y - self.prevY

  self.timeSinceTouchedBall = self.timeSinceTouchedBall + dt
end

function Player:triggerHitBall()
  self.timeSinceTouchedBall = 0
end

function Player:triggerLostPoint()
  -- TODO: anything?
end

function Player:triggerWonPoint()
  -- TODO: anything?
end

return Player
