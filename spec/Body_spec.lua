local Body = require("body")
local Vec2 = require("lib/vec2")

describe("body", function()
    it("creates objects correctly", function()
        for i = 1,100 do
            local params = {
                pos = {
                    x = math.random() * (math.random() < 0.5 and 1 or -1),
                    y = math.random() * (math.random() < 0.5 and 1 or -1),
                },
                vel = {
                    x = math.random() * (math.random() < 0.5 and 1 or -1),
                    y = math.random() * (math.random() < 0.5 and 1 or -1),
                },
                acc = {
                    x = math.random() * (math.random() < 0.5 and 1 or -1),
                    y = math.random() * (math.random() < 0.5 and 1 or -1),
                },
                mass = math.random() * (math.random() < 0.5 and 1 or -1),
            }
            local body = Body:new({
                pos = Vec2 { params.pos.x, params.pos.y },
                vel = Vec2 { params.vel.x, params.vel.y },
                acc = Vec2 { params.acc.x, params.acc.y },
                mass = params.mass
            })
            for k, v in pairs(params) do
                if type(v) == "table" then
                    assert.are.same(v.x, body[k].x)
                    assert.are.same(v.y, body[k].y)
                else
                    assert.are.same(v, body[k])
                end
            end
        end
    end)
end)
