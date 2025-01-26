-- nbody: nbody sim
-- v0.1 @evannjohnson

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
    screen.clear()
    screen.level(15)
    screen.aa(0)
    for i, body in ipairs(bodies) do
        xpos = body.pos[1] / (max_xy * 1.2)
        ypos = body.pos[3] / (max_xy * 1.2) / 2
        screen.circle(xpos * 64 + 64, ypos * 32 + 32, 2)
        screen.stroke()
    end
    screen.update()
end

function cleanup()
    -- deinitialization
end

