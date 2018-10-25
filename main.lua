Ball = require 'ball'
Player = require 'player'
Enemy = require 'enemy'
Sound = require 'sound'
Wallquads = require 'wallquads'

local lerp = require "math.lerp"
local clamp = require "math.clamp"

local newShake = require "shake"

local gCurrShake

-- offset from top left of game window
gGameOffset = {
  x = 100,
  y = 100
}

gScreenWidth = 624
gScreenHeight = 416
gkBackWallScaleFactor = 0.25

gGameStarted = false
gGameOver = false
gGameWon = false

gGameStage = 1
gkTotalNumStages = 3

function love.load()
  math.randomseed(os.time())

  gTheFont = love.graphics.newFont("assets/font/8bitwonder.TTF", 40)
  gImgBg = love.graphics.newImage("assets/img/bg.png")

  Wallquads:init()
  Enemy:init()
  Sound:init()
  Sound:play(Sound.sndAmbience)
end

function startGame()
  Ball:reset()
  Player:reset()
  Enemy:reset()
  gGameStage = 1
  Enemy:advanceToNextEnemy(gGameStage)
  Ball:advanceToStage(gGameStage)
  gGameStarted = true
  gGameOver = false
  gGameWon = false
end

function love.update(dt)
  if not gGameStarted then
    -- TODO: handle game over, game won, title screen updates
    if gCurrShake then
      gCurrShake:update(dt)
    end
  else
    updateGame(dt)
  end
  
end

gk_screenShakeDur = 0.5
gk_screenShakeTimeElapsed = 99999.0 -- sentinel

function updateGame(dt)
  Player:update(dt)
  Ball:update(dt)
  Enemy:update(dt, Ball:getPos(), Ball:getState())
  Wallquads:update(dt)

  if gCurrShake then
    gCurrShake:update(dt)
  end

  if Ball:getState() == "ready" then
    Enemy:reset()
  elseif Ball:getState() == "playing" then
    if Ball:getZ() < 0.0 then
      local b = Ball:getAABB()
      local p = Player:getAABB()
      if checkAABBCollision(b.x, b.y, b.w, b.h, p.x, p.y, p.w, p.h) then
        Ball:handlePlayerTouch(Player:getMotionDelta())
        Player:triggerHitBall()
        Sound:play(Sound.sndPlayerHit)
        Wallquads:doJustHitEffect()
        gCurrShake = newShake(math.random() * math.pi, 0.8, 0.06, 60)
      else
        Ball:triggerLostPoint()
        Player:triggerLostPoint()
        Enemy:triggerWonPoint(gGameStage)
        gCurrShake = newShake(math.random() * math.pi, 5, 2.0, 20)
      end
    end
  
    if Ball:getZ() > 1.0 then 
      local b = Ball:getAABB()
      local e = Enemy:getAABB()
      if checkAABBCollision(b.x, b.y, b.w, b.h, e.x, e.y, e.w, e.h) then 
        Ball:handleEnemyTouch(Enemy:getMotionDelta())
        Sound:play(Sound.sndEnemyHit)
        gCurrShake = newShake(math.random() * math.pi, 3, 0.09, 40)
      else
        Ball:triggerWonPoint()
        Player:triggerWonPoint()
        Enemy:triggerLostPoint()
      end
    end
  end

  if Enemy.lives < 1 then 
    gGameStage = gGameStage + 1
    if gGameStage > gkTotalNumStages then
      gGameStarted = false
      gGameWon = true
    else 
      Enemy:advanceToNextEnemy(gGameStage)
      Ball:advanceToStage(gGameStage)
    end
  elseif Player.lives < 1 then
    gGameOver = true
    gGameStarted = false
  end
end

function checkAABBCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function drawWallBallOutline()
  local frontCorners = {
    0, 0,
    gScreenWidth, 0,
    gScreenWidth, gScreenHeight,
    0, gScreenHeight,
    0, 0
  }

  local hw = gScreenWidth / 2.0
  local hh = gScreenHeight / 2.0

  local backCorners = {
    hw - hw * gkBackWallScaleFactor, hh - hh * gkBackWallScaleFactor,
    hw + hw * gkBackWallScaleFactor, hh - hh * gkBackWallScaleFactor,
    hw + hw * gkBackWallScaleFactor, hh + hh * gkBackWallScaleFactor,
    hw - hw * gkBackWallScaleFactor, hh + hh * gkBackWallScaleFactor,
    hw - hw * gkBackWallScaleFactor, hh - hh * gkBackWallScaleFactor
  }

  local topLeftDiag = { 0,0, hw - hw * gkBackWallScaleFactor, hh - hh * gkBackWallScaleFactor }
  local topRightDiag = { gScreenWidth, 0, hw + hw * gkBackWallScaleFactor, hh - hh * gkBackWallScaleFactor, }
  local botRightDiag = {  gScreenWidth, gScreenHeight, hw + hw * gkBackWallScaleFactor, hh + hh * gkBackWallScaleFactor, }
  local botLeftDiag = { 0, gScreenHeight, hw - hw * gkBackWallScaleFactor, hh + hh * gkBackWallScaleFactor, }

  -- outline on wall at ball's depth location
  local scaledZ = (Ball:getZ())^(2/3)

  local outlineLeft = lerp(0, hw - hw * gkBackWallScaleFactor, scaledZ)
  local outlineTop = lerp(0, hh - hh * gkBackWallScaleFactor, scaledZ)
  local outlineRight = lerp(gScreenWidth, hw + hw * gkBackWallScaleFactor, scaledZ)
  local outlineBottom = lerp(gScreenHeight, hh + hh * gkBackWallScaleFactor, scaledZ)

  local outlineCorners = {
    outlineLeft, outlineTop,
    outlineRight, outlineTop,
    outlineRight, outlineBottom,
    outlineLeft, outlineBottom,
    outlineLeft, outlineTop,
  }

  -- love.graphics.setColor(0.4, 1.0, 0.4, 1.0)

  -- love.graphics.line(frontCorners)
  -- love.graphics.line(backCorners)

  -- love.graphics.line(topLeftDiag)
  -- love.graphics.line(topRightDiag)
  -- love.graphics.line(botRightDiag)
  -- love.graphics.line(botLeftDiag)

  love.graphics.setColor(0.55, 1.0, 0.4, 1.0)

  love.graphics.line(outlineCorners)
end

function love.draw()
  local dx, dy = 0, 0
  if gCurrShake then dx, dy = gCurrShake:get() end

  love.graphics.push()
  love.graphics.translate(dx, dy)

  -- call setFont only inside .draw or it will set Ghost's font
  love.graphics.setFont(gTheFont)

  love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
  love.graphics.draw(gImgBg, 0, 0)

  Wallquads:draw()

  love.graphics.setColor(1.0, 1.0, 1.0, 1.0)

  -- title screen? hiscore?
  if not gGameStarted then
    if gGameOver then
      love.graphics.setColor(0.5, 1.0, 0.4, 1.0)
      love.graphics.print("GAME OVER", 234, 14)
    elseif gGameWon then
      love.graphics.setColor(0.5, 1.0, 0.4, 1.0)
      love.graphics.print("YOU ARE THE BEST", 134, 14)
    else
      love.graphics.setColor(0.5, 1.0, 0.4, 1.0)
      love.graphics.print("ROBO SQUASH", 200, 14)
    end
  else
    love.graphics.push()
    love.graphics.translate(gGameOffset.x, gGameOffset.y)

    drawWallBallOutline()

    Enemy:draw(gScreenWidth, gScreenHeight)
    Ball:draw(gScreenWidth, gScreenHeight)
    Player:draw(gScreenWidth, gScreenHeight)

    love.graphics.pop()

    drawHUD()
  end

  love.graphics.pop()
end

function drawHUD()
  -- Enemy lives
  love.graphics.setColor(1.0, 0.4, 0.4, 1.0)
  local padding = 10 
  local radius = 8
  local livesOffset = { x = gGameOffset.x + radius, y = gGameOffset.y - radius * 2 }

  for i = 1, Enemy.lives do
    love.graphics.circle("fill", livesOffset.x + (i-1) * padding + (i-1) * radius * 2,
                                 livesOffset.y,
                                 radius,  -- radius
                                 50) -- cirle segments
  end


  love.graphics.setColor(0.5, 1.0, 0.4, 1.0)
  for i = 1, Player.lives do
    love.graphics.circle("fill", gGameOffset.x + gScreenWidth - ((i-1) * (padding + radius*2)) - radius,
                                 livesOffset.y,
                                 radius,  -- radius
                                 50) -- cirle segments
  end
end

function love.mousepressed(x, y, button)
  if not gGameStarted then
    startGame()
    return
  end

  if button == 1 then
    Ball:tryToServe(Player:getMotionDelta())
  end
end

function love.mousemoved(x, y, dx, dy, istouch)
  local screenX = clamp(x - gGameOffset.x, 0, gScreenWidth)
  local screenY = clamp(y - gGameOffset.y, 0, gScreenHeight)
  local worldX = (screenX / gScreenWidth) * 2.0 - 1.0
  local worldY = (screenY / gScreenHeight) * 2.0 - 1.0
  Player:setCenterPos(worldX, worldY) 
end

-- For key names, see: https://love2d.org/wiki/KeyConstant
function love.keypressed(key, scancode, isrepeat)
end
