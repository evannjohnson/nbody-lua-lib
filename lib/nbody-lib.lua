Vec2 = include("lib/vec2")

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

Simulation = {
    -- dt = 0.000001,
    dt = 0.001,
    min = 1.1,
    r_max = 0,
    start_time = nil,
    ticks = 0,
    momentum_center = Vec2 { 0, 0 },
    mass_center = Vec2 { 0, 0 },
    ke = 0,
    pe = 0,
    bodies = {}
}
Simulation.__index = Simulation

function Simulation:new(o)
    o = o or {}
    setmetatable(o, self)
    o.start_time = os.clock()
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
    self.mass_center = wpos_sum / mass_sum
    self.momentum_center = wvel_sum / mass_sum

    for i, body in ipairs(bodies) do
        body.pos = body.pos - self.mass_center
        body.vel = body.vel - self.momentum_center
        body.pos = body.pos / max_dist
    end
    self.mass_center = 0
    self.momentum_center = 0

    return Simulation:new { bodies = bodies }
end

function Simulation:update()
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
end

function Simulation:start(max_tps)
    local id = clock.run(function()
        while true do
            self:update()
            -- print(self.bodies[1].pos.x)
            redraw()
            clock.sleep(1 / max_tps)
        end
    end)
    return id
end

function Simulation:elapsed_time()
    return os.clock() - self.start_time
end

function Simulation:avg_tps()
    return self.ticks / self:elapsed_time()
end

function rand_disc()
    theta = math.random() * 2 * math.pi
    return Vec2 { math.cos(theta), math.sin(theta) } * math.random()
end

