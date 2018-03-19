local textWorld = 
[[
WWWWWWWW
WWW9WFFW
WFFFAFFW
WFFFWFFW
WWFFWFFW
WWWWWWWW
]]

return function(Atmos)
    Atmos.LoadTextWorld(textWorld)
    
    for _=1,10 do
        Atmos.Tick()
    end
    
    print("OPENING AIRLOCK")
    Atmos.Sleep(1)
    
    Atmos.FindFirstOfType("A").tile:Toggle()
    
    while true do
        Atmos.Tick()
    end
end
