Sound = {
  sndAmbience,
  sndPlayerHit,
  sndEnemyHit,
  sndBounce,
  sndWinPoint,
  sndLosePoint,
}

function Sound:init()
  self.sndAmbience = love.audio.newSource("assets/audio/ambience.mp3", "static")
  self.sndPlayerHit = love.audio.newSource("assets/audio/paddle.wav", "static")
  self.sndEnemyHit = love.audio.newSource("assets/audio/paddle.wav", "static")
  self.sndBounce = love.audio.newSource("assets/audio/bounce.wav", "static")
  self.sndWinPoint = love.audio.newSource("assets/audio/winpoint.wav", "static")
  self.sndLosePoint = love.audio.newSource("assets/audio/losepoint.wav", "static")
  self.sndAmbience:setLooping(true)
  self.sndAmbience:setVolume(0.5)
  self.sndPlayerHit:setVolume(0.7)
  self.sndEnemyHit:setVolume(0.7)
  self.sndEnemyHit:setPitch(1.2)
  self.sndBounce:setVolume(0.5)
  self.sndBounce:setPitch(0.7)
  self.sndWinPoint:setVolume(0.7)
  self.sndLosePoint:setVolume(0.7)
end

function Sound:play(snd)
  snd:stop()
  snd:play()
end

return Sound