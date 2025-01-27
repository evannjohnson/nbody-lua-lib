-- nbody: nbody sim
-- v0.1 @evannjohnson
-- implementation follows https://github.com/DeadlockCode/n-body
vec2 = include("lib/vec2")

function init()
    -- initialization
end

function key(n, z)
    -- key actions: n = number, z = state
end

function enc(n, d)
    -- encoder actions: n = number, d = delta
end

function redraw()
end

function cleanup()
    -- deinitialization
end

Body = {}
Body.prototype = {
    pos = vec2{0, 0},
    vel = vec2{0, 0},
    acc = vec2{0, 0},
    mass = 1
}

Body.mt = {}
Body.mt.__index = function (table, key)
    return Body.prototype[key]
end

function Body.new (o)
    o = o or {}
    setmetatable(o, Body.mt)
    return o
end

function Body:update(dt)
    self.pos = self.pos + self.vel * dt
    self.vel = self.vel + self.acc * dt
    self.acc = vec2{0, 0}
end

