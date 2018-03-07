local Tile = require("tiles.tile")

local Wall = Tile.new(0)
Wall.Permeable = false

function Wall:Name()
    return "W"
end

local Class = {}

function Class.new(volume)
    return setmetatable({
        Volume = volume
    }, {
        __index = Wall
    })
end

return Class
