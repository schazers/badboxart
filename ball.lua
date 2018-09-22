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
  state = "ready",
  timeSincePointEnded = 0
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
  self.timeSincePointEnded = 0
end

function Ball:draw(screenWidth, screenHeight) 
  if self.state == "playing" or self.state == "ready" then
    love.graphics.setColor(1.0,0.4,0.4,1)
  elseif self.state == "lostpoint" then
    love.graphics.setColor(0.5,0.2,0.2,1)
  elseif self.state == "wonpoint" then
    love.graphics.setColor(0.4,1.0,0.4,1)
  end
  
  -- scale ball position and radius based upon z-value for psuedo3D render
  local scaledZ = self.z^(2/3)
  love.graphics.circle("fill", (screenWidth / 2.0) + ((screenWidth / 2.0) * ((0.75 * (1.0 - scaledZ)) + 0.25) * self.x),
                               (screenHeight / 2.0) + ((screenHeight / 2.0) * ((0.75 * (1.0 - scaledZ)) + 0.25) * self.y),
                                (self.radius * screenWidth) * (0.75 * (1.0 - scaledZ) + 0.25), -- radius
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

  Sound:play(Sound.sndPlayerHit)

  self.state = "playing"
end

function Ball:getState()
  return self.state
end

function Ball:update(dt)
  if self.state == "ready" then
    -- todo? wiggle ball?
  elseif self.state == "wonpoint" or self.state == "lostpoint" then
    self.timeSincePointEnded = self.timeSincePointEnded + dt
    if self.timeSincePointEnded > 1.4 then
      self:reset()
    end
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

    self.x = newX
    self.y = newY
    self.z = newZ

    -- TODO: clamp max x, y velocities so acceleration can't get out of hand?
    self.vx = self.vx + self.ax * dt
    self.vy = self.vy + self.ay * dt
  end
end

function Ball:getAABB() 
  return { x = self.x - self.radius * 2.0, y = self.y - self.radius * 2.0, w = self.radius * 4, h = self.radius * 4 }
end

function Ball:handlePlayerTouch(motionDelta)

  -- simulate friction to slow spin amount
  self.ax = 0.75 * self.ax
  self.ay = 0.75 * self.ay

  -- add spin
  local axDelta = - motionDelta.dx * 50
  local ayDelta = - motionDelta.dy * 50

  -- reverse ball's spin if new spin is in other direction
  if (axDelta < 0 and self.ax > 0) or (axDelta > 0 and self.ax < 0) then
    self.ax = axDelta
  else
    self.ax = self.ax + axDelta
  end

  if (ayDelta < 0 and self.ay > 0) or (ayDelta > 0 and self.ay < 0) then
    self.ay = ayDelta
  else
    self.ay = self.ay + ayDelta
  end

  local newZ = 0.0 + 0.01
  self.z = newZ
  if self.state == "ready" then
    self.vz = 1.0
  elseif self.state == "playing" then 
    self.vz = -self.vz
  end
end

function Ball:handleEnemyTouch(motionDelta)
  -- TODO: use Dx, Dy to spin ball?
  local newZ = 1.0 - 0.01
  self.vz = -self.vz
  self.z = newZ
end

function Ball:triggerLostPoint()
  self.state = "lostpoint"
  self.timeSincePointEnded = 0
  self.z = 0 -- so the ball will render properly before reset
end

function Ball:triggerWonPoint()
  self.state = "wonpoint"
  self.timeSincePointEnded = 0
  self.z = 1.0 
end

function Ball:getPos() return { x = self.x, y = self.y, z = self.z } end

return Ball