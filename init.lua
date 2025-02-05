local Body = require((...):gsub('init', '') .. '/body')
local Vec2 = require((...):gsub('init', '') .. '/lib/vec2')

Sim = {
    -- dt = 0.000001,
    dt = 0.01,
    t = 0,
    softening = .01,
    r_max = 0,
    integrator = "leapfrog",
    gravEquation = "exponent",
    gravExponent = 2,
    start_time = nil,
    ticks = 0,
    bodies = {}
}
Sim.__index = Sim
setmetatable(Sim, {
    __call = function(self, o)
        return self:new(o)
    end
})

function Sim:new(o)
    o = o or {}
    setmetatable(o, self)
    o.start_time = os.clock()
    return o
end

function Sim:new_rand(n)
    local bodies = {}
    for i = 1, n do
        table.insert(bodies, Body:new_rand())
    end

    local wpos_sum = 0
    local wvel_sum = 0
    local mass_sum = 0
    local max_dist = 0
    for i, body in pairs(bodies) do
        wpos_sum = wpos_sum + body.pos * body.mass
        wvel_sum = wvel_sum + body.vel * body.mass
        mass_sum = mass_sum + body.mass
        local dist = body.pos:length()
        if dist > max_dist then
            max_dist = dist
        end
    end
    self.mass_center = wpos_sum / mass_sum
    self.momentum_center = wvel_sum / mass_sum

    for i, body in ipairs(bodies) do
        body.pos = body.pos - self.mass_center
        body.vel = body.vel - self.momentum_center
        body.pos = body.pos / max_dist
    end
    self.mass_center = 0
    self.momentum_center = 0

    return Sim:new { bodies = bodies }
end

function Sim:new_circular(n)
    local bodies = {}
    for i = 1, n do
        local body = Body:new_polar(1, math.pi * 2 * i / n)
        body.vel = body.pos:clone()
        body.vel:rotate(math.pi / 2)
        body.vel:setLength(.75)
        table.insert(bodies, body)
    end
    return Sim:new { bodies = bodies }
end

function Sim:new_from_state(state)
    return Sim:new(self.startingStates[state])
end

function Sim:update()
    self.integrators[self.integrator](self.bodies, self.dt, self.softening, self.gravityEquations[self.gravEquation],
        self.gravExponent)
    self.ticks = self.ticks + 1
    self.t = self.t + self.dt
end

local function updateAcc(bodies, softening, gravEq, gravExp)
    for i = 1, #bodies do
        bodies[i].acc = Vec2 { 0, 0 }
    end

    for i = 1, #bodies - 1 do
        local pos1 = bodies[i].pos
        local mass1 = bodies[i].mass

        for j = (i + 1), #bodies do
            local pos2 = bodies[j].pos
            local mass2 = bodies[j].mass

            local r = pos2 - pos1
            local dist = r:length()
            -- local force = r / (math.max(softening, dist * dist) * dist)
            local force = gravEq(r, dist, softening, gravExp)

            bodies[i].acc = bodies[i].acc + mass2 * force
            bodies[j].acc = bodies[j].acc - mass1 * force
        end
    end
end

Sim.gravityEquations = {
    exponent = function(r, dist, softening, exp)
        return r / (math.max(softening, dist ^ exp))
    end
}

Sim.integrators = {
    eulerSimple = function(bodies, dt, softening, gravEq, gravExp)
        updateAcc(bodies, softening, gravEq, gravExp)

        for i, body in ipairs(bodies) do
            body:update(dt)
        end
    end,
    eulerSymplectic = function(bodies, dt, softening, gravEq, gravExp)
        updateAcc(bodies, softening, gravEq, gravExp)

        for i, body in ipairs(bodies) do
            body.vel = body.vel + body.acc * dt
            body.pos = body.pos + body.vel * dt
        end
    end,
    leapfrog = function(bodies, dt, softening, gravEq, gravExp)
        for i, body in ipairs(bodies) do
            body.vel = body.vel + body.acc * dt / 2.0
            body.pos = body.pos + body.vel * dt
        end

        updateAcc(bodies, softening, gravEq, gravExp)

        for i, body in ipairs(bodies) do
            body.vel = body.vel + body.acc * dt / 2.0
        end
    end
}

function Sim:getCenterOfMass()
    local wpos_sum = Vec2 { 0, 0 }
    local mass_sum = 0
    for i = 1, #self.bodies do
        local mass = self.bodies[i].mass
        wpos_sum = wpos_sum + self.bodies[i].pos * mass
        mass_sum = mass_sum + mass
    end
    return wpos_sum / mass_sum
end

function Sim:getCenterOfMomentum()
    local wvel_sum = Vec2 { 0, 0 }
    local mass_sum = 0
    for i = 1, #self.bodies do
        local mass = self.bodies[i].mass
        wvel_sum = wvel_sum + self.bodies[i].vel * mass
        mass_sum = mass_sum + mass
    end
    return wvel_sum / mass_sum
end

function Sim:getMaxDistFromOrigin()
    local max = 0
    for i, body in ipairs(self.bodies) do
        local dist = body.pos:length()
        max = math.max(max, dist)
    end
    return max
end

function Sim:getKineticEnergy()
    local ke = 0
    for i = 1, #self.bodies do
        ke = ke + self.bodies[i].mass * self.bodies[i].vel:length() ^ 2 / 2
    end
    return ke
end

function Sim:getPotentialEnergy()
    local pe = 0
    for i = 1, #self.bodies - 1 do
        for j = i + 1, #self.bodies do
            pe = pe - self.bodies[i].mass * self.bodies[j].mass / (self.bodies[j].pos - self.bodies[i].pos):length()
        end
    end
    return pe
end

Sim.startingStates = {
    simpleOrbit = {
        bodies = {
            Body {
                pos = Vec2 { 0, 0 },
                mass = 100
            },
            Body {
                pos = Vec2 { 0, 1 },
                vel = Vec2 { 10, 0 }
            }
        }
    },
    twins = {
        bodies = {
            Body {
                pos = Vec2 { 0, 1 },
                vel = Vec2 { .5, 0 }
            },
            Body {
                pos = Vec2 { 0, -1 },
                vel = Vec2 { -.5, 0 }
            }
        }
    },
    triplets = {
        bodies = {
            Body:new_polar(1, math.pi * 2 / 3),
            Body:new_polar(1, math.pi * 4 / 3),
            Body:new_polar(1, math.pi * 2)
        }
    }
}

return Sim
