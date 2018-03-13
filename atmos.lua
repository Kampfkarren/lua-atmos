local w = {"w"}

--[[
local world = {
    {w, w, w, w, w},
    {w, w, w, {"f", 90}, w},
    {w, {"f", 0}, {"f", 0}, {"f", 0}, w},
    {w, {"f", 0}, {"f", 0}, {"f", 0}, w},
    {w, {"f", 0}, {"f", 0}, w, w},
    {w, w, w, w, w}
}]]

local world = {}
local textWorld =
[[
WWWWWWWW
WWW9WFFW
WFFFAFFW
WFFFWFFW
WWFFWFFW
WWWWWWWW
]]

local Tiles = {
    Wall = require("tiles.wall"),
    Floor = require("tiles.floor"),
    Airlock = require("tiles.airlock")
}

local airlock --THIS IS TEMPORARY AND JUST FOR TESTING AREA SPREADING!!!!!

--setup text world
for line in textWorld:gmatch("[^\n]+") do
    local row = {}
    
    for char in line:gmatch(".") do
        if char == "W" then
            table.insert(row, Tiles.Wall.new())
        elseif char == "9" then
            local floor = Tiles.Floor.new()
            floor.Gases.O2 = 90
            floor.Temperature = 400
            table.insert(row, floor)
        elseif char == "F" then
            table.insert(row, Tiles.Floor.new())
        elseif char == "A" then
            airlock = Tiles.Airlock.new()
            table.insert(row, airlock)
        end
    end
    
    table.insert(world, row)
end

for rowNo,row in pairs(world) do
    for colNo,tile in pairs(row) do
        local t = {
            pos = {rowNo, colNo},
            tile = tile
        }
        
        world[rowNo][colNo] = t
    end
end

local visualFormat = "%s:%s:%.2fC "
local gasFormat = "%s,%dmol;"

local function gasList(gases)
    local str = ""
    
    for name,volume in pairs(gases) do
        str = str .. gasFormat:format(name, volume)
    end
    
    return str
end

local function visuals()
    for _,row in pairs(world) do
        local str = ""
        
        for _,tile in pairs(row) do
            str = str .. visualFormat:format(tile.tile:Name(), gasList(tile.tile.Gases), tile.tile.Temperature)
        end
        
        print(str)
    end
end

visuals()

local function getCols(area, pos, down)
    local cols = {}
    
    local start, final, step = pos[1]
    
    if down then
        --from current col onwards (going down)
        final = 1/0 --lol
        step = 1
    else
        --from current col upwards (going up)
        final = 1
        step = -1
    end
    
    for colNo=start,final,step do
        local col = world[colNo]
        
        if col then
            --there's a column
            local tile = col[pos[2]]
            
            if not tile then
                --no tile, space.
                print("no tile")
                return cols, true
            else
                print(tile.tile.Permeable, tile.tile:Name())
                if not tile.tile.Permeable then
                    --wall.
                    return cols, false
                else
                    table.insert(cols, tile.pos)
                end
            end
        else
            print("no column")
            --no column and we're still going, meaning we went into space. breach.
            return cols, true
        end
    end
    
    print("no column (up)")
    return cols, true
end

local function addIfNotExists(area, ele)
    for _,e in pairs(area) do
        if e[1] == ele[1] and e[2] == ele[2] then
            return
        end
    end
    
    table.insert(area, ele)
end

local function checkTile(i, area)
    local breach = false
    local tile = area[i]
    
    print("CHECKING TILE", tile[1], tile[2])
    
    --horizontal
    for _,dir in pairs({1, -1}) do
        print("GOING HORIZONTAL")
        for offset=tile[2],dir/0,dir do --wtf i love lua
            local check = world[tile[1]][offset]
            
            if check then
                if not check.tile.Permeable then
                    --hit a wall
                    print("HIT A WALL HORIZONTALLY AT", check.pos[1], check.pos[2])
                    break
                else
                    print("GOING HORIZONTALLY", check.pos[1], check.pos[2])
                    addIfNotExists(area, check.pos)
                end
            else
                breach = true
                break
            end
        end
    end
    
    --vertical
    for _,down in pairs({true, false}) do
        local tiles,newBreach = getCols(area, tile, down)
        breach = breach or newBreach
        
        for _,tile in pairs(tiles) do
            --we could do this in the getCols function but i don't like it
            addIfNotExists(area, tile)
        end
    end
    
    return breach
end

local function simulate()
    --setup adjacent tiles (can we use this to change everything else? probably)
    for rowNo,row in pairs(world) do
        for colNo,tile in pairs(row) do
            local adjacentTiles = {}
            
            local up = world[rowNo - 1]
            local down = world[rowNo + 1]
            
            adjacentTiles.up = up and up[colNo]
            adjacentTiles.down = down and down[colNo]
            adjacentTiles.left = row[colNo - 1]
            adjacentTiles.right = row[colNo + 1]
            
            tile.tile.AdjacentTiles = adjacentTiles
        end
    end
    
    --make areas
    local areas = {}
    local tiles_checked = {}
    
    for _,row in pairs(world) do
        for _,tile in pairs(row) do
            local posId = table.concat(tile.pos, ":")
            
            if not tiles_checked[posId] then
                tiles_checked[posId] = true
                
                if tile.tile.Permeable then
                    print("NEW AREA", tile.pos[1], tile.pos[2])
                    
                    local areaTiles = {tile.pos}
                    local i = 1
                    local breach = false
                    
                    while i <= #areaTiles do
                        breach = breach or checkTile(i, areaTiles)
                        i = i + 1
                    end
                    
                    print("AREA FINISHED")
                    
                    if breach then
                        print("BREACH!!!")
                    end
                    
                    for _,tile in pairs(areaTiles) do
                        tiles_checked[table.concat(tile, ":")] = true
                    end
                    
                    local area = {}
                    
                    area.breach = breach
                    area.tiles = areaTiles
                    
                    table.insert(areas, area)
                end
            end
        end
    end
    
    print("FINISHED MAKING AREAS: NUMBER OF AREAS", #areas)
    
    --spread volume
    for _,area in pairs(areas) do
        local sums = {
            O2 = 0;
        }
        
        if not area.breach then
            for _,pos in pairs(area.tiles) do
                local tile = world[pos[1]][pos[2]]
                
                for gas,moles in pairs(tile.tile.Gases) do
                    sums[gas] = sums[gas] + moles
                end
            end
        end
        
        for _,pos in pairs(area.tiles) do
            local tile = world[pos[1]][pos[2]]
            
            for gas,moles in pairs(sums) do
                tile.tile.Gases[gas] = moles / #area.tiles
            end
            
            tile.tile:SpreadTemperature()
        end
    end
    
    print("FINISHED GAS SPREADING")
    
    visuals()
end

local clock = os.clock
local function sleep(num)
    local t = clock()
    while clock() - t < num do end
end

for _=1,10 do
    simulate()
    sleep(0.2)
end

print("OPENING AIRLOCK")
sleep(1)

airlock:Toggle()

while true do
    sleep(0.2)
    simulate()
end

--[[
print("OPENING AIRLOCK")
airlock:Toggle()
simulate()

sleep(1)

print("CLOSING AIRLOCK")
airlock:Toggle()
simulate()

while true do
    sleep(1)
    simulate()
end
]]