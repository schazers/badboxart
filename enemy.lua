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
  size = 0.2,
  img = nil,
  imgEnemy1 = nil,
  imgEnemy2 = nil,
  imgEnemy3 = nil,
  movementSpeed = 0.7,
  lives = 10,
}

function Enemy:init()
  self.imgEnemy1 = love.graphics.newImage("assets/img/mouth.png")
  self.imgEnemy2 = love.graphics.newImage("assets/img/frogface.png")
  self.imgEnemy3 = love.graphics.newImage("assets/img/voidface.png")
  self.img = self.imgEnemy1
end

function Enemy:reset()
  self:setCenterPos(0, 0)
  self.dx = 0
  self.dy = 0
  self.prevX = 0
  self.prevY = 0
end

function Enemy:getAABB()
  return { x = self.x - self.size/2.0, y = self.y - self.size/2.0, w = self.size, h = self.size }
end

function Enemy:draw(screenWidth, screenHeight)
  local hw = screenWidth / 2.0
  local hh = screenHeight / 2.0
  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(self.img, hw - 0.25 * hw + ((self.x + 1) / 2.0) * (0.25 * screenWidth) - (self.size/2.0) * (0.25 * screenWidth),
                               hh - 0.25 * hh + ((self.y + 1) / 2.0) * (0.25 * screenHeight) - (self.size/2.0) * (0.25 * screenHeight),
                               0, -- rotation (radians)
                               0.25, -- scale x
                               0.25)-- scale y
end

function Enemy:setCenterPos(centerX, centerY)
  self.x = clamp(centerX, -1.0 + self.size, 1.0 - self.size)
  self.y = clamp(centerY, -1.0 + self.size, 1.0 - self.size) 
end

function Enemy:update(dt, ballPos, ballState)
  -- TODO: remove most of the spin from the ball?
  -- curveball seems to do this..

  if ballState == "playing" then 
    local dx = ballPos.x - self.x
    local dy = ballPos.y - self.y

    local mag = math.sqrt(dx * dx + dy * dy)

    if mag > 0.01 then 
      local nx = dx / mag
      local ny = dy / mag

      self.x = self.x + (nx * dt * self.movementSpeed)
      self.y = self.y + (ny * dt * self.movementSpeed)
    end
  end

  -- TODO: if ball is moving towards player, enemy should move back towards center

  -- TEST: cheat for now, just be where the ball is:
  --self.x = ballPos.x
  --self.y = ballPos.y
end

function Enemy:getMotionDelta() return { dx = self.dx, dy = self.dy } end

function Enemy:triggerWonPoint(gameStage)
  if gameStage == 1 then
    self.movementSpeed = self.movementSpeed + 0.6
  elseif gameStage == 2 then
    self.movementSpeed = self.movementSpeed + 0.3
  elseif gameStage == 3 then
    self.movementSpeed = self.movementSpeed + 0.3
  end
end

function Enemy:advanceToNextEnemy(newGameStage)
  if newGameStage == 1 then
    self.img = self.imgEnemy1
    self.movementSpeed = 1.0
    self.lives = 6
  elseif newGameStage == 2 then
    self.img = self.imgEnemy2
    self.movementSpeed = 1.9
    self.lives = 8
  elseif newGameStage == 3 then
    self.img = self.imgEnemy3
    self.movementSpeed = 2.3
    self.lives = 10
  end
end

function Enemy:triggerLostPoint()
  self.lives = self.lives - 1
end

return Enemy