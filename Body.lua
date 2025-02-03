Vec2 = require("lib/vec2")

Body = {
    pos = Vec2 { 0, 0 },
    vel = Vec2 { 0, 0 },
    acc = Vec2 { 0, 0 },
    mass = 1
}
Body.__index = Body

function Body:new(o)
    o = o or {}
    setmetatable(o, self)
    return o
end

local function rand_disc()
    local theta = math.random() * 2 * math.pi
    return Vec2 { math.cos(theta), math.sin(theta) } * math.random()
end

function Body:new_rand()
    return Body:new {
        pos = rand_disc(),
        vel = rand_disc()
    }
end

function Body:update(dt)
    self.pos = self.pos + self.vel * dt
    self.vel = self.vel + self.acc * dt
    self.acc = Vec2 { 0, 0 }
end

return Body
