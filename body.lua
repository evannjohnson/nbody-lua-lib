local Vec2 = require((...):gsub('body', '') .. '/lib/vec2')

local function polar_to_cartesian(r, theta)
    return Vec2 { math.cos(theta), math.sin(theta) } * r
end

local function rand_disc()
    return polar_to_cartesian(math.random(), math.random() * 2 * math.pi)
end

Body = {
    pos = Vec2 { 0, 0 },
    vel = Vec2 { 0, 0 },
    acc = Vec2 { 0, 0 },
    mass = 1
}
Body.__index = Body
setmetatable(Body, {
    __call = function(self, o)
        return self:new(o)
    end
})

function Body:new(o)
    o = o or {}
    setmetatable(o, self)
    return o
end

function Body:new_polar(r, theta, o)
    o = o or {}
    o.pos = polar_to_cartesian(r, theta)
    return Body:new(o)
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
