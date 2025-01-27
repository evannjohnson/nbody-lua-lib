-- nbody: nbody sim
-- v0.1 @evannjohnson
-- implementation follows https://github.com/DeadlockCode/n-body
vec2 = include("lib/vec2")

function init()
    sim = Simulation.new_rand(3)
    screen.level(15)
    screen.aa(1)
    screen.line_width(1)
    redraw()
end

function key(n, z)
    -- key actions: n = number, z = state
end

function enc(n, d)
    -- encoder actions: n = number, d = delta
end

function redraw()
    screen.clear()
    screen.stroke()
    for i,body in ipairs(sim.bodies) do
        screen.circle(body.pos[1] * 32 + 63, body.pos[2] * 32 + 31, 2)
        screen.close()
        screen.stroke()
    end
    screen.update()
end

function cleanup()
    -- deinitialization
end

Body = {}
Body.prototype = {
    pos = vec2 { 0, 0 },
    vel = vec2 { 0, 0 },
    acc = vec2 { 0, 0 },
    mass = 1
}

Body.mt = {}
Body.mt.__index = function(table, key)
    return Body.prototype[key]
end

function Body.new(o)
    o = o or {}
    setmetatable(o, Body.mt)
    return o
end

function Body:update(dt)
    self.pos = self.pos + self.vel * dt
    self.vel = self.vel + self.acc * dt
    self.acc = vec2 { 0, 0 }
end

Simulation = {}
Simulation.mt = {}
Simulation.prototype = {
    dt = 0.000001,
    min_dist = 0.0001,
    bodies = {}
}

function Simulation.new(o)
    o = o or {}
    setmetatable(o, Simulation.mt)
    return o
end

function Simulation.new_rand(n)
    bodies = {}
    for i = 1, n do
        table.insert(bodies, Body.new_rand())
    end

    local wpos_sum = 0
    local wvel_sum = 0
    local mass_sum = 0
    local max_dist = 0
    for i,body in ipairs(bodies) do
        wpos_sum = wpos_sum + body.pos * body.mass
        wvel_sum = wvel_sum + body.vel * body.mass
        mass_sum = mass_sum + body.mass
        local dist = body.pos:length()
        if dist > max_dist then
            max_dist = dist
        end
    end
    mass_center = wpos_sum / mass_sum
    momentum_center = wvel_sum / mass_sum

    for i,body in ipairs(bodies) do
        body.pos = body.pos - mass_center
        body.vel = body.vel - momentum_center
        body.pos = body.pos / max_dist
    end

    return Simulation.new{bodies = bodies}
end

function rand_disc()
    theta = math.random() * 2 * math.pi
    return vec2 { math.cos(theta), math.sin(theta) } * math.random()
end

function Body.new_rand()
    return Body.new {
        pos = rand_disc(),
        vel = rand_disc()
    }
end
