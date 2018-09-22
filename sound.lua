Sound = {
  sndPlayerHit,
  sndEnemyHit,
  sndBounce,
}

function Sound:init()
  self.sndPlayerHit = love.audio.newSource("assets/audio/paddle.wav", "static")
  self.sndEnemyHit = love.audio.newSource("assets/audio/paddle.wav", "static")
  self.sndBounce = love.audio.newSource("assets/audio/bounce.wav", "static")
  self.sndPlayerHit:setVolume(0.7)
  self.sndEnemyHit:setVolume(0.7)
  self.sndEnemyHit:setPitch(1.2)
  self.sndBounce:setVolume(0.5)
  self.sndBounce:setPitch(0.7)
end

function Sound:play(snd)
  snd:stop()
  snd:play()
end

return Sound