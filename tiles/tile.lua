local Constants = require("constants")
local Gases = require("gases")

local Tile = {}

function Tile:Name()
    return "F"
end

function Tile:Act()
    self:SpreadTemperature()
    
    if self.OnFire then
        if self:IsCombustable() then
            self:FireAct()
        else
            self.OnFire = false
        end
    end
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
            --[[
            Spread is NEVER greater than heat flux.
            To calculate how much heat a tile needs to be at equilibrium...
            ((tileToGiveTemperature + givingTileTemperature)/2) * tileToGiveCapacity
            ]]
            local equilibriumTemperature = ((tile.Temperature + self.Temperature) / 2) * tile:HeatCapacity()
            local spread = math.min(equilibriumTemperature, self:HeatCapacity())
            
            self.Temperature = self.Temperature - spread
            tile.Temperature = tile.Temperature + spread
        end
    end
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

function Tile:IsCombustable()
    return self.Fuel >= Constants.FIRE_FUEL_RATE and self.Gases.O2 >= Constants.FIRE_OXYGEN_RATE
end

function Tile:Spark()
    if self:IsCombustable() then
        self.OnFire = true
    end
end

function Tile:FireAct()
    
end

local Class = {}

function Class.new()
    return setmetatable({
        Permeable = true;
        AdjacentTiles = {};
        Gases = { --Gases and their mol values
            O2 = 0; --Is there any reason to not have gasses be linked to areas instead of tiles?
        };
        Fuel = 0; --Moles of unspecified fuel. Used for fire.
        
        --Temperature
        Temperature = 0; --C
        HeatFlux = 50; --C/s
    }, {
        __index = Tile
    })
end

return Class
