-- ignore non-simple+convex polygons for now (can love.math.triangulate if desired)
  -- example of concave polygon that we might want:
  -- {58, 417, 82, 409, 82, 452, 76, 454, 76, 419, 58, 424}

Wallquads = {
    spawnRate = 0.1,
    justHitDur = 0.0,
    color = { r = 125.0/255.0, g = 90.0/255.0, b = 115.0/255.0 }
}

local wallquadverts = {
    -- left wall
    {85, 289, 89, 289, 89, 304, 85, 304},
    {60, 381, 75, 378, 75, 398, 60, 402},
    {59, 435, 66, 433, 66, 458, 59, 460},
    {40, 523, 62, 511, 62, 517, 40, 529},
    {64, 178, 72, 181, 72, 187, 64, 185},
    {5, 33, 31, 52, 31, 65, 5, 48},
    {0, 84, 5, 86, 5, 131, 0, 130},

    -- right wall
    {777, 140, 790, 135, 790, 148, 777, 153},
    {736, 301, 739, 301, 739, 345, 736, 345},
    {783, 300, 799, 300, 799, 310, 783, 309},
    {783, 312, 799, 313, 799, 320, 783, 319},
    {760, 338, 766, 338, 766, 360, 760, 359},
    {773, 364, 784, 366, 784, 380, 773, 378},
    {773, 381, 784, 383, 784, 407, 773, 404},
    {755, 388, 758, 389, 758, 393, 755, 392},
    {744, 436, 751, 438, 751, 456, 744, 453},
    {788, 469, 800, 474, 800, 487, 788, 482},
    {762, 511, 784, 523, 784, 528, 762, 517},
    {756, 526, 798, 552, 798, 566, 756, 538},
}

local wallquads = {}

function createWallquad(verts)
    return {
        quad = verts,
        lifetime = 1.0
    }
end

function Wallquads:init()
    for k,verts in pairs(wallquadverts) do
        wallquad = createWallquad(verts)
        wallquads[#wallquads + 1] = wallquad
    end
end

function Wallquads:draw()
    love.graphics.setColor(self.color.r, self.color.g, self.color.b, 1.0)

    for k,wallquad in pairs(wallquads) do
        if wallquad.lifetime > 0.0 then
            love.graphics.polygon("fill", wallquad.quad)
        end
    end
end

function Wallquads:spawnLifetime(base, variance)
    return base + (math.random() * variance)
end

function Wallquads:update(dt)

    self.spawnRate = 0.01

    self.color = { r = 125.0/255.0, g = 90.0/255.0, b = 115.0/255.0 }

    local lifetimeBase = 0.7
    local lifetimeVariance = 2.5

    if self.justHitDur > 0.0 then
        lifetimeBase = 0.04
        lifetimeVariance = 0.04
        self.spawnRate = 0.6
        self.color.r = self.color.r * 1.25
        self.color.g = self.color.g * 1.25
        self.color.b = self.color.b * 1.25
    end

    for k,wallquad in pairs(wallquads) do

        if wallquad.lifetime > 0.0 then 
            wallquad.lifetime = wallquad.lifetime - dt
        elseif math.random() < self.spawnRate then 
            -- spawn new ones
            wallquad.lifetime = self:spawnLifetime(lifetimeBase, lifetimeVariance)
        end
    end

    self.justHitDur = self.justHitDur - dt
end

function Wallquads:doJustHitEffect()
    self.justHitDur = 0.14
end

return Wallquads