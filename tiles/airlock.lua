local Tile = require("tiles.tile")

local Airlock = Tile.new()
Airlock.Permeable = false

function Airlock:Name()
    return "A"
end

function Airlock:Toggle()
    self.Permeable = not self.Permeable
    
    if not self.Permeable then
        --airlock closed, distribute volume on door
        local tiles = {}
        
        for _,tile in pairs(self.AdjacentTiles) do
            if tile then
                table.insert(tiles, tile)
            end
        end
        
        for gas,volume in pairs(self.Gases) do
            for _,tile in pairs(tiles) do
                tile.tile.Gases[gas] = tile.tile.Gases[gas] + (volume / #tiles)
            end
            
            self.Gases[gas] = 0
        end
    end
end

local Class = {}

function Class.new()
    return setmetatable({}, {
        __index = Airlock
    })
end

return Class

