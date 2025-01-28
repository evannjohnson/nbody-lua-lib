-- nbody: nbody sim
-- v0.1 @evannjohnson
-- implementation follows https://github.com/DeadlockCode/n-body
include("lib/nbody-lib")

function init()
    screen.level(15)
    screen.aa(1)
    screen.line_width(1)
    sim = Simulation:new_rand(3)
    simId = sim:start(60)
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

