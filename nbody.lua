-- nbody: nbody sim
-- v0.1 @evannjohnson
-- implementation follows https://github.com/DeadlockCode/n-body
vec2 = include("lib/vec2")

function init()
    screen.level(15)
    screen.aa(1)
    screen.line_width(1)
    sim = Simulation:new_rand(3)
    simId = sim:start(5)
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
    for i, body in ipairs(sim.bodies) do
        screen.circle(body.pos[1] * 32 + 63, body.pos[2] * 32 + 31, 2)
        screen.close()
        screen.stroke()
    end
    screen.update()
end

function cleanup()
    -- deinitialization
end

Body = {
    pos = vec2 { 0, 0 },
    vel = vec2 { 0, 0 },
    acc = vec2 { 0, 0 },
    mass = 1
}
Body.__index = Body

function Body:new(o)
    o = o or {}
    setmetatable(o, self)
    return o
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
    self.acc = vec2 { 0, 0 }
end

Simulation = {
    dt = 0.000001,
    -- dt = 0.001,
    min = 0.0001,
    bodies = {}
}
Simulation.__index = Simulation

function Simulation:new(o)
    o = o or {}
    setmetatable(o, self)
    return o
end

function Simulation:new_rand(n)
    bodies = {}
    for i = 1, n do
        table.insert(bodies, Body:new_rand())
    end

    local wpos_sum = 0
    local wvel_sum = 0
    local mass_sum = 0
    local max_dist = 0
    for i, body in ipairs(bodies) do
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

    for i, body in ipairs(bodies) do
        body.pos = body.pos - mass_center
        body.vel = body.vel - momentum_center
        body.pos = body.pos / max_dist
    end

    return Simulation:new { bodies = bodies }
end

function Simulation:update()
    for i = 1, #self.bodies do
        local pos1 = self.bodies[i].pos
        local mass1 = self.bodies[i].mass
        for j = (i + 1), #self.bodies do
            local pos2 = self.bodies[j].pos
            local mass2 = self.bodies[j].mass

            local r = pos2 - pos1
            local mag_sq = r:lengthSquared()
            local mag = r:length()
            local tmp = r / (math.max(self.min, mag_sq) * mag)

            self.bodies[i].acc = self.bodies[i].acc + mass2 * tmp
            self.bodies[j].acc = self.bodies[j].acc - mass1 * tmp
        end
    end

    for i, body in ipairs(self.bodies) do
        body:update(self.dt)
    end
end

function Simulation:start(rate)
    id = clock.run(function()
        while true do
            self:update()
            print(self.bodies[1].pos.x)
            redraw()
            clock.sleep(1 / rate)
        end
    end)
    return id
end

function rand_disc()
    theta = math.random() * 2 * math.pi
    return vec2 { math.cos(theta), math.sin(theta) } * math.random()
end
