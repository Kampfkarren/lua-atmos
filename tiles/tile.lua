local Constants = require("constants")
local Gases = require("gases")

local Tile = {}

function Tile:Name()
    return "F"
end

function Tile:HeatCapacity() --J/K
    local heatCapacity = 0
    
    for gas,moles in pairs(self.Gases) do
        heatCapacity = heatCapacity + (Gases[gas].SpecificHeat * moles)
    end
    
    return math.max(Constants.MINIMUM_HEAT_CAPACITY, heatCapacity)
end

--read docs/heat.md
function Tile:SpreadTemperature()
    for _,tile in pairs(self.AdjacentTiles) do
        tile = tile.tile
        
        if tile.Permeable and tile.Temperature < self.Temperature and (self.Temperature - tile.Temperature) > Constants.TEMPERATURE_WORTH_WORRYING then
            local tileCapacity = tile:HeatCapacity()
            local maxSpread = (self.Temperature / 2) * tileCapacity
            
            local spread
            
            --OH GOD I WROTE ALL THIS ON A PIECE OF PAPER AND I STILL DON'T GET IT
            if self:_CanSpread(self.HeatFlux, tile) then
                spread = self.HeatFlux
            elseif self:_CanSpread(self.Temperature / 2, tile) then
                spread = self.Temperature / 2
            else
                local amount = self.Temperature - ((self.Temperature + tile.Temperature) / 2)
                
                if self:_CanSpread(amount, tile) then
                    spread = amount
                else
                    --TODO: THIS HAPPENS ALL THE TIME AND I DONT KNOW WHY!!!
                    return
                end
            end
            
            self.Temperature = self.Temperature - spread
            tile.Temperature = tile.Temperature + spread
        end
    end
end

function Tile:_CanSpread(spread, otherTile)
    local amount = spread / otherTile:HeatCapacity()
    local potential = otherTile.Temperature + (amount * otherTile:HeatCapacity())
    return self.Temperature - spread >= potential
end

function Tile:TotalMoles()
    local totalMoles = 0
    
    for _,moles in pairs(self.Gases) do
        totalMoles = totalMoles + moles
    end
    
    return totalMoles
end

--p = nRT/V, then divided by 100 for kPa
function Tile:Pressure()
    if not self.Permeable then return 0 end
    if not self.Area then return 0 end
    
    local n = self:TotalMoles()
    local V = self.Area.Volume
    --print(self.Temperature, n, (n * Constants.IDEAL_GAS_CONSTANT * self.Temperature) / V)
    return ((n * Constants.IDEAL_GAS_CONSTANT * self.Temperature) / V)
end

local Class = {}

function Class.new()
    return setmetatable({
        Permeable = true;
        AdjacentTiles = {};
        Gases = { --Gases and their mol values
            O2 = 0; --Is there any reason to not have gasses be linked to areas instead of tiles?
        };
        
        --Temperature
        Temperature = 0; --C
        HeatFlux = 35; --C/s
    }, {
        __index = Tile
    })
end

return Class
