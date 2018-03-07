local Tile = {
    Volume = 0;
    Permeable = true;
    AdjacentTiles = {};
}

function Tile:Name()
    return "F"
end

local Class = {}

function Class.new(volume)
    return setmetatable({
        Volume = volume
    }, {
        __index = Tile
    })
end

return Class
