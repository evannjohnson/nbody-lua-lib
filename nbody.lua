-- nbody: nbody sim
-- v0.1 @evannjohnson
-- implementation follows https://github.com/DeadlockCode/n-body

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
    pos = {0, 0},
    vel = {0, 0},
    acc = {0, 0},
    mass = 1
}

Body.mt = {}
Body.mt.__index = function (table, key)
    return Body.prototype[key]
end

function Body:new (o)
    o = o or {}
    setmetatable(o, Body.mt)
    o.pos = pos or o.pos
    o.vel = vel or o.vel
    o.mass = mass or o.mass
    return o
end

