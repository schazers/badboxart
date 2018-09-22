Ball = require 'ball'
Player = require 'player'
Enemy = require 'enemy'
Sound = require 'sound'
local lerp = require "math.lerp"
local clamp = require "math.clamp"

-- offset from top left of game window
gGameOffset = {
  x = 100,
  y = 100
}

gScreenWidth = 624
gScreenHeight = 416
gkBackWallScaleFactor = 0.25

gGameStarted = false

function love.load()
  math.randomseed(os.time())

  -- HiScore:load()

  -- font
  --gTheFont = love.graphics.newFont("8bitwonder.ttf", 18)

  -- images
  --gImgTitleScreen1 = love.graphics.newImage("title_screen_1.png")

  gImgBg = love.graphics.newImage("assets/img/bg.png")

  Enemy:init()
  Sound:init()
end

function startGame()
  -- todo: position ball
  -- todo: give player lives

  Ball:reset()
  Player:reset()

  gGameStarted = true
end

function love.update(dt)
  if not gGameStarted then
    -- TODO
  else
    updateGame(dt)
  end
  
end

function updateGame(dt)
  Player:update(dt)
  Ball:update(dt)
  Enemy:update(dt, Ball:getPos())

  if Ball:getZ() < 0.0 then
    local b = Ball:getAABB()
    local p = Player:getAABB()
    if checkAABBCollision(b.x, b.y, b.w, b.h, p.x, p.y, p.w, p.h) then 
      Ball:handlePlayerTouch(Player:getMotionDelta())
      Sound:play(Sound.sndHit, 1.0)
    else
      Ball:triggerLostPoint()
      Player:triggerLostPoint()
      Enemy:triggerWonPoint()
    end
  end

  if Ball:getZ() > 1.0 then 
    local b = Ball:getAABB()
    local e = Enemy:getAABB()
    if checkAABBCollision(b.x, b.y, b.w, b.h, e.x, e.y, e.w, e.h) then 
      Ball:handleEnemyTouch(Enemy:getMotionDelta())
      Sound:play(Sound.sndHit, 1.2)
    else
      Ball:triggerWonPoint()
      Player:triggerWonPoint()
      Enemy:triggerLostPoint()
    end
  end

  -- TODO: check whether player/enemy won/lost match
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
  local scaledZ = (Ball:getZ())^(3/4)

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

  love.graphics.setColor(0.4, 1.0, 1.0, 1.0)

  love.graphics.line(outlineCorners)
end

function love.draw()
  -- call setFont only inside .draw or it will set Ghost's font
  -- love.graphics.setFont(gTheFont)

  if not gGameStarted then
    -- title screen? hiscore?
  end

  love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
  love.graphics.draw(gImgBg, 0, 0)

  love.graphics.push()
  love.graphics.translate(gGameOffset.x, gGameOffset.y)

  drawWallBallOutline()

  Enemy:draw(gScreenWidth, gScreenHeight)
  Ball:draw(gScreenWidth, gScreenHeight)
  Player:draw(gScreenWidth, gScreenHeight)

  love.graphics.pop()

  drawHUD()
end

function drawHUD()
  -- progress bar
  --love.graphics.setColor(1.0, 0.4, 0.4, 1.0)
  
  -- Text
  --love.graphics.setColor(167.0/255.0, 131.0/255.0, 95.0/255.0, 1.0)
  --love.graphics.print("Trash      "..gTrashCleanedCount, 10, (gGridSize * gSquareW) + (gSquareW / 3) + 10)
end

function love.mousepressed(x, y, button)
  if not gGameStarted then
    startGame()
    return
  end

  if button == 1 then
    Ball:tryToServe(Player:getMotionDelta())
    Sound:play(Sound.sndHit, 1.0)
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
