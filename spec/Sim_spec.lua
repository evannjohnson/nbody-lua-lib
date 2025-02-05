local Body   = require("body")
local Sim    = require("init")
local Vec2   = require("lib/vec2")
local assert = require("luassert")
local say    = require("say")

say:set_namespace("en")

local function are_near(state, arguments)
    arguments.nofmt = arguments.nofmt or {}
    arguments.nofmt[3] = true

    local expected = arguments[1]
    local actual = arguments[2]
    local tolerance = arguments[3]

    local near = true

    for i = 1, 2 do
        near = near and (actual[i] >= expected[i] - tolerance and actual[i] <= expected[i] + tolerance)
    end

    return near
end

say:set("assertion.are_near.positive",
    [[Expected values to be near.
Passed in:
%s
Expected +/- %s:
%s]])

say:set("assertion.are_near.negative",
    [[Expected values not to be near.
Passed in:
%s
Expected +/- %s:
not %s]])

assert:register("assertion", "are_near", are_near, "assertion.are_near.positive",
    "assertion.are_near.negative")

describe("sim calculates center of momentum", function()
    it("with 1 body at origin", function()
        local sim = Sim {
            bodies = {
                Body {
                    pos = Vec2 { 0, 0 },
                    vel = Vec2 { 0, 0 }
                }
            }
        }
        assert.are_same({ 0, 0 }, sim:getCenterOfMomentum())
    end)

    it("with 2 unmoving bodies equidistant from the origin", function()
        local sim = Sim {
            bodies = {
                Body {
                    pos = Vec2 { 1, 1 },
                    vel = Vec2 { 0, 0 }
                },
                Body {
                    pos = Vec2 { -1, -1 },
                    vel = Vec2 { 0, 0 }
                }
            }
        }
        assert.are_same({ 0, 0 }, sim:getCenterOfMomentum())
    end)

    it("with 3 unmoving bodies equidistant from the origin", function()
        local sim = Sim:new()
        for i = 1, 3 do
            table.insert(sim.bodies, Body:new_polar(1, i * 2 * math.pi / 3))
        end

        assert.are_same({ 0, 0 }, sim:getCenterOfMomentum())
    end)

    it("with 1 moving body", function()
        local sim = Sim {
            bodies = {
                Body {
                    vel = Vec2 { 1, 1 }
                }
            }
        }

        assert.are_same({ 1, 1 }, sim:getCenterOfMomentum())
    end)
end)

describe("sim calculates center of mass", function()
    it("with 1 body at origin", function()
        local sim = Sim {
            bodies = {
                Body {
                    pos = Vec2 { 0, 0 },
                    vel = Vec2 { 0, 0 }
                }
            }
        }
        assert.are_same({ 0, 0 }, sim:getCenterOfMass())
    end)

    it("with 2 bodies equidistant from the origin", function()
        local sim = Sim {
            bodies = {
                Body {
                    pos = Vec2 { 1, 1 },
                    vel = Vec2 { 0, 0 }
                },
                Body {
                    pos = Vec2 { -1, -1 },
                    vel = Vec2 { 0, 0 }
                }
            }
        }
        assert.are_same({ 0, 0 }, sim:getCenterOfMass())
    end)

    it("with 3 bodies equidistant from the origin", function()
        local sim = Sim:new()
        for i = 1, 3 do
            table.insert(sim.bodies, Body:new_polar(1, i * 2 * math.pi / 3))
        end

        assert.are_near({ 0, 0 }, sim:getCenterOfMass(), 1e-4)
    end)
end)
