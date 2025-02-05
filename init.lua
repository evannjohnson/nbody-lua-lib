local Body = require((...):gsub('init', '') .. '/body')
local Vec2 = require((...):gsub('init', '') .. '/lib/vec2')

Sim = {
    -- dt = 0.000001,
    dt = 0.0000001,
    t = 0,
    min = 1.01,
    r_max = 0,
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
    for i, body in ipairs(bodies) do
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

function Sim:update()
    for i = 1, #self.bodies do
        local pos1 = self.bodies[i].pos
        local mass1 = self.bodies[i].mass

        for j = (i + 1), #self.bodies do
            local pos2 = self.bodies[j].pos
            local mass2 = self.bodies[j].mass

            local r = pos2 - pos1
            local dist = r:length()
            local tmp = r / (math.max(self.min, dist * dist) * dist)
            if dist > 0 then
                self.pe = self.pe - mass1 * mass2 / dist
            end

            self.bodies[i].acc = self.bodies[i].acc + mass2 * tmp
            self.bodies[j].acc = self.bodies[j].acc - mass1 * tmp
        end
    end

    for i, body in ipairs(self.bodies) do
        body:update(self.dt)
    end
    self.ticks = self.ticks + 1
    self.t = self.t + self.dt
end

function Sim:getCenterOfMass()
    local wpos_sum = 0
    local mass_sum = 0
    for i = 1, #self.bodies do
        local mass = self.bodies[i].mass
        wpos_sum = wpos_sum + self.bodies[i].pos * mass
        mass_sum = mass_sum + mass
    end
    return wpos_sum / mass_sum
end

function Sim:getCenterOfMomentum()
    local wvel_sum = 0
    local mass_sum = 0
    for i = 1, #self.bodies do
        local mass = self.bodies[i].mass
        wvel_sum = wvel_sum + self.bodies[i].vel * mass
        mass_sum = mass_sum + mass
    end
    return wvel_sum / mass_sum
end

function Sim:getKineticEnergy()
    local ke = 0
    for i = 1, #self.bodies do
        ke = ke + self.bodies[i].mass / self.bodies[i].vel:length()^2
    end
    return ke
end

function Sim:getPotentialEnergy()
    local pe = 0
    for i = 1, #self.bodies - 1 do
        for j = i + 1, #self.bodies do
            pe = pe - self.bodies[i].mass * self.bodies[j].mass / (self.bodies[j] - self.bodies[i]):length()
        end
    end
    return pe
end

return Sim
