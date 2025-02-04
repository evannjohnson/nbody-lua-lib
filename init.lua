local Body = require((...):gsub('init', '')..'/body')
local Vec2 = require((...):gsub('init', '')..'/lib/vec2')

Sim = {
    -- dt = 0.000001,
    dt = 0.0000001,
    t = 0,
    min = 1.01,
    r_max = 0,
    start_time = nil,
    ticks = 0,
    momentum_center = Vec2 { 0, 0 },
    mass_center = Vec2 { 0, 0 },
    ke = 0,
    pe = 0,
    bodies = {}
}
Sim.__index = Sim

function Sim:new(o)
    o = o or {}
    setmetatable(o, self)
    o.start_time = os.clock()
    return o
end

function Sim:new_rand(n)
    local bodies = {}
    for i = 1,n do
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
    self.ke = 0
    self.pe = 0
    self.r_max = 0
    local wpos_sum = 0
    local wvel_sum = 0
    local mass_sum = 0

    for i = 1, #self.bodies do
        local pos1 = self.bodies[i].pos
        local mass1 = self.bodies[i].mass
        local vel1 = self.bodies[i].vel
        wpos_sum = wpos_sum + pos1 * mass1
        wvel_sum = wvel_sum + vel1 * mass1
        mass_sum = mass_sum + mass1

        self.ke = self.ke + 0.5 * mass1 * (vel1[1]^2 + vel1[2]^2)
        for j = (i + 1), #self.bodies do
            local pos2 = self.bodies[j].pos
            local mass2 = self.bodies[j].mass

            local r = pos2 - pos1
            local dist = r:length()
            local tmp = r / (math.max(self.min, dist*dist) * dist)
            if dist > 0 then
                self.pe = self.pe - mass1 * mass2 / dist
            end

            self.bodies[i].acc = self.bodies[i].acc + mass2 * tmp
            self.bodies[j].acc = self.bodies[j].acc - mass1 * tmp
        end
    end
    self.mass_center = wpos_sum / mass_sum
    self.momentum_center = wvel_sum / mass_sum


    for i, body in ipairs(self.bodies) do
        body:update(self.dt)

        -- local r = body.pos:length()
        -- if r > self.r_max then
        --     self.r_max = r
        -- end
    end
    self.ticks = self.ticks + 1
    self.t = self.t + self.dt
end

return Sim
