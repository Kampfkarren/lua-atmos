local Tile = require("tiles.tile")

local Wall = Tile.new()
Wall.Permeable = false

function Wall:Name()
    return "W"
end

local Class = {}

function Class.new()
    return setmetatable({}, {
        __index = Wall
    })
end

return Class
