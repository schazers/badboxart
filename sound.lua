Sound = {
  sndHit,
  sndBounce,
}

function Sound:init()
  self.sndHit = love.audio.newSource("assets/audio/paddle.wav", "static")
  self.sndBounce = love.audio.newSource("assets/audio/bounce.wav", "static")
  self.sndHit:setVolume(0.7)
  self.sndBounce:setVolume(0.5)
  self.sndBounce:setPitch(0.7)
end

function Sound:play(snd, pitch)
  snd:stop()
  snd:setPitch(pitch)
  snd:play()
end

function Sound:play(snd)
  snd:stop()
  snd:play()
end

return Sound