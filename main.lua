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

gGameWidth = 624
gGameHeight = 416

SCREEN_WIDTH = (gGameOffset.x * 2) + gGameWidth
SCREEN_HEIGHT = gGameOffset.y + gGameHeight + 200

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

  Wallquads:update(dt)
  
end

gk_screenShakeDur = 0.5
gk_screenShakeTimeElapsed = 99999.0 -- sentinel

function updateGame(dt)
  Player:update(dt)
  Ball:update(dt)
  Enemy:update(dt, Ball:getPos(), Ball:getState())

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
        Wallquads:doJustHitEffect()
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
    gGameWidth, 0,
    gGameWidth, gGameHeight,
    0, gGameHeight,
    0, 0
  }

  local hw = gGameWidth / 2.0
  local hh = gGameHeight / 2.0

  local backCorners = {
    hw - hw * gkBackWallScaleFactor, hh - hh * gkBackWallScaleFactor,
    hw + hw * gkBackWallScaleFactor, hh - hh * gkBackWallScaleFactor,
    hw + hw * gkBackWallScaleFactor, hh + hh * gkBackWallScaleFactor,
    hw - hw * gkBackWallScaleFactor, hh + hh * gkBackWallScaleFactor,
    hw - hw * gkBackWallScaleFactor, hh - hh * gkBackWallScaleFactor
  }

  local topLeftDiag = { 0,0, hw - hw * gkBackWallScaleFactor, hh - hh * gkBackWallScaleFactor }
  local topRightDiag = { gGameWidth, 0, hw + hw * gkBackWallScaleFactor, hh - hh * gkBackWallScaleFactor, }
  local botRightDiag = {  gGameWidth, gGameHeight, hw + hw * gkBackWallScaleFactor, hh + hh * gkBackWallScaleFactor, }
  local botLeftDiag = { 0, gGameHeight, hw - hw * gkBackWallScaleFactor, hh + hh * gkBackWallScaleFactor, }

  -- outline on wall at ball's depth location
  local scaledZ = (Ball:getZ())^(2/3)

  local outlineLeft = lerp(0, hw - hw * gkBackWallScaleFactor, scaledZ)
  local outlineTop = lerp(0, hh - hh * gkBackWallScaleFactor, scaledZ)
  local outlineRight = lerp(gGameWidth, hw + hw * gkBackWallScaleFactor, scaledZ)
  local outlineBottom = lerp(gGameHeight, hh + hh * gkBackWallScaleFactor, scaledZ)

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
  love.graphics.push() -- center screen
  gTranslateScreenToCenterDx = 0.5 * (love.graphics.getWidth() - SCREEN_WIDTH)
  gTranslateScreenToCenterDy = 0.5 * (love.graphics.getHeight() - SCREEN_HEIGHT)
  love.graphics.translate(gTranslateScreenToCenterDx, gTranslateScreenToCenterDy)

  local screenShakeDx, screenShakeDy = 0, 0
  if gCurrShake then screenShakeDx, screenShakeDy = gCurrShake:get() end

  love.graphics.push() -- screen shake
  love.graphics.translate(screenShakeDx, screenShakeDy)

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
      love.graphics.print("GAME OVER", 234, 24)
      love.graphics.push()
      love.graphics.translate(gGameOffset.x, gGameOffset.y)
      Ball:draw(gGameWidth, gGameHeight)
      Player:draw(gGameWidth, gGameHeight, screenShakeDx, screenShakeDy)
      love.graphics.pop()
    elseif gGameWon then
      love.graphics.setColor(0.5, 1.0, 0.4, 1.0)
      love.graphics.print("YOU ARE THE BEST", 134, 24)
      love.graphics.push()
      love.graphics.translate(gGameOffset.x, gGameOffset.y)
      Ball:draw(gGameWidth, gGameHeight)
      Player:draw(gGameWidth, gGameHeight, screenShakeDx, screenShakeDy)
      love.graphics.pop()
    else
      love.graphics.setColor(0.5, 1.0, 0.4, 1.0)
      love.graphics.print("ROBOPONG", 256, 24)
    end
  else
    love.graphics.push()
    love.graphics.translate(gGameOffset.x, gGameOffset.y)

    drawWallBallOutline()

    Enemy:draw(gGameWidth, gGameHeight)
    Ball:draw(gGameWidth, gGameHeight)
    Player:draw(gGameWidth, gGameHeight, screenShakeDx, screenShakeDy)

    love.graphics.pop()

    drawHUD()
  end

  love.graphics.pop() -- screen shake
  love.graphics.pop() -- center screen 
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
    love.graphics.circle("fill", gGameOffset.x + gGameWidth - ((i-1) * (padding + radius*2)) - radius,
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
  local screenX = clamp(x - gGameOffset.x - gTranslateScreenToCenterDx, 0, gGameWidth)
  local screenY = clamp(y - gGameOffset.y - gTranslateScreenToCenterDy, 0, gGameHeight)
  local worldX = (screenX / gGameWidth) * 2.0 - 1.0
  local worldY = (screenY / gGameHeight) * 2.0 - 1.0
  Player:setCenterPos(worldX, worldY) 
end

-- For key names, see: https://love2d.org/wiki/KeyConstant
function love.keypressed(key, scancode, isrepeat)
end
