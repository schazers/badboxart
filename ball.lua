Sound = require 'sound'

Ball = {
  radius = 0.05,
  x = 0,
  y = 0,
  z = 0,
  vx = 0,
  vy = 0,
  vz = 0,
  ax = 0,
  ay = 0,
  state = "ready"
}

function Ball:reset()
  self.x = 0
  self.y = 0
  self.z = 0
  self.vx = 0
  self.vy = 0
  self.vz = 0
  self.ax = 0
  self.ay = 0
  self.state = "ready"
end

function Ball:draw(screenWidth, screenHeight) 
  love.graphics.setColor(1,1,1,1)
  -- scale ball position and radius based upon z-value for psuedo3D render
  love.graphics.circle("fill", (screenWidth / 2.0) + ((screenWidth / 2.0) * ((0.75 * (1.0 - self.z)) + 0.25) * self.x),
                               (screenHeight / 2.0) + ((screenHeight / 2.0) * ((0.75 * (1.0 - self.z)) + 0.25) * self.y),
                                (self.radius * screenWidth) * (0.75 * (1.0 - self.z) + 0.25), -- radius
                                100)                                                -- cirle segments
end

-- in range [0.0, 1.0], where 0.0 is closest, 1.0 is furthest
function Ball:getZ()
  return self.z
end

function Ball:tryToServe(motionDelta)
  if self.state ~= "ready" then
    return 
  end 

  self.vx = 0.0
  self.vy = 0.0
  
  self:handlePlayerTouch(motionDelta)

  self.state = "playing"
end

function Ball:getState()
  return self.state
end

function Ball:update(dt)
  if self.state == "ready" then
    -- TODO
  elseif self.state == "wonpoint" then
    -- TODO
  elseif self.state == "lostpoint" then
    -- TODO
  elseif self.state == "playing" then
    local newX = self.x + self.vx * dt
    local newY = self.y + self.vy * dt
    local newZ = self.z + self.vz * dt

    -- left/right wall handling
    if newX - self.radius < -1.0 then
      newX = -1.0 + self.radius + 0.01
      self.vx = -self.vx
      Sound:play(Sound.sndBounce)
    elseif newX + self.radius > 1.0 then
      newX = 1.0 - self.radius - 0.01
      self.vx = -self.vx
      Sound:play(Sound.sndBounce)
    end

    -- floor/ceiling handling
    if newY - self.radius < -1.0 then
      newY = -1.0 + self.radius + 0.01
      self.vy = -self.vy
      Sound:play(Sound.sndBounce)
    elseif newY + self.radius > 1.0 then
      newY = 1.0 - self.radius - 0.01
      self.vy = -self.vy
      Sound:play(Sound.sndBounce)
    end

    -- TODO: remove and use paddles for depth-collisions
    -- if newZ < 0.0 then
    --   newZ = 0.0 + 0.01
    --   self.vz = -self.vz
    -- elseif newZ > 1.0 then
    --   newZ = 1.0 - 0.01
    --   self.vz = -self.vz
    -- end
    -- TODO: ^^^ ===========================

    self.x = newX
    self.y = newY
    self.z = newZ

    -- TODO: clamp max x, y velocities so acceleration can't get out of hand
    self.vx = self.vx + self.ax * dt
    self.vy = self.vy + self.ay * dt
  end
end

function Ball:getAABB() 
  return { x = self.x - self.radius, y = self.y - self.radius, w = self.radius * 2, h = self.radius * 2 }
end

function Ball:handlePlayerTouch(motionDelta)
  -- TODO: user Dx, Dy to spin ball
  self.ax = self.ax - motionDelta.dx * 50
  self.ay = self.ay - motionDelta.dy * 50

  print(self.ax)
  print(self.ay)

  local newZ = 0.0 + 0.01
  self.z = newZ
  if self.state == "ready" then
    self.vz = 0.8
  elseif self.state == "playing" then 
    self.vz = -self.vz
  end
end

function Ball:handleEnemyTouch(motionDelta)
  -- TODO: use Dx, Dy to spin ball
  local newZ = 1.0 - 0.01
  self.vz = -self.vz
  self.z = newZ
end

function Ball:triggerLostPoint()
  self.state = "lostpoint"
  -- TODO: let lostpoint animation happen before reset
  self:reset()
end

function Ball:triggerWonPoint()  
  self.state = "wonpoint"
  -- TODO: let wonpoint animation happen before reset
  self:reset()
end

function Ball:getPos() return { x = self.x, y = self.y, z = self.z } end

return Ball