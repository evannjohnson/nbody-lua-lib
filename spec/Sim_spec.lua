local Body = require("body")
local Sim = require("init")
local Vec2 = require("lib/vec2")

describe("sim calculates center of momentum", function()
    it("with 1 body at origin", function()
        local sim = Sim:new{
            bodies = {
                Body{
                    pos = Vec2{0, 0},
                    vel = Vec2{0, 0}
                }
            }
        }
        assert.are_same({0,0}, sim:getCenterOfMomentum())
    end)
end)
