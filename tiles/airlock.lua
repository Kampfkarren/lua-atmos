local Tile = require("tiles.tile")

local Airlock = Tile.new(0)
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
        
        local spread = self.Volume / #tiles
        
        for _,tile in pairs(tiles) do
            tile.tile.Volume = tile.tile.Volume + spread
        end
        
        self.Volume = 0
    end
end

local Class = {}

function Class.new(volume)
    return setmetatable({
        Volume = volume
    }, {
        __index = Airlock
    })
end

return Class

