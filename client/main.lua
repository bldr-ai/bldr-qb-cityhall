-- Config is loaded as shared_script in fxmanifest

local pedsSpawned = false

-- Spawn peds function - QB-Cityhall style
local function spawnPeds()
    if not Config.Peds or not next(Config.Peds) or pedsSpawned then return end
    
    for i = 1, #Config.Peds do
        local current = Config.Peds[i]
        current.model = type(current.model) == 'string' and joaat(current.model) or current.model
        
        RequestModel(current.model)
        while not HasModelLoaded(current.model) do
            Wait(0)
        end
        
        local ped = CreatePed(0, current.model, current.coords.x, current.coords.y, current.coords.z, current.coords.w, false, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStartScenarioInPlace(ped, current.scenario, true, true)
        current.pedHandle = ped
        
        if Config.UseTarget then
            local opts = {}
            if current.cityhall then
                opts = {
                    label = 'Open Cityhall',
                    icon = 'fa-solid fa-city',
                    action = function()
                        TriggerEvent('cityhall:client:openMenu')
                    end
                }
                exports['qb-target']:AddTargetEntity(ped, {
                    options = { opts },
                    distance = 2.5
                })
            end
        end
    end
    pedsSpawned = true
end

-- Create blip helper function
local function createBlip(options)
    if not options.coords or (type(options.coords) ~= 'table' and type(options.coords) ~= 'vector3') then 
        return error(('createBlip() expected coords in a vector3 or table but received %s'):format(type(options.coords)))
    end
    
    local blip = AddBlipForCoord(options.coords.x or options.coords[1], options.coords.y or options.coords[2], options.coords.z or options.coords[3])
    SetBlipSprite(blip, options.sprite or 1)
    SetBlipDisplay(blip, options.display or 4)
    SetBlipScale(blip, options.scale or 1.0)
    SetBlipColour(blip, options.colour or 1)
    SetBlipAsShortRange(blip, options.shortRange or false)
    
    if options.title then
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(options.title)
        EndTextCommandSetBlipName(blip)
    end
    
    return blip
end

-- Setup blips and zones
local function setupBlipsAndZones()
    for _, cityhall in ipairs(Config.Cityhalls) do
        if cityhall.showBlip then
            createBlip({
                coords = cityhall.coords,
                sprite = cityhall.blipData.sprite,
                display = cityhall.blipData.display,
                scale = cityhall.blipData.scale,
                colour = cityhall.blipData.colour,
                title = cityhall.blipData.title,
                shortRange = false
            })
        end
    end
    
    -- Setup zones if not using qb-target
    if not Config.UseTarget then
        -- Zone detection thread
        CreateThread(function()
            local inZone = false
            while true do
                Wait(100)
                local playerCoords = GetEntityCoords(PlayerPedId())
                local nearZone = false
                
                for _, ped in ipairs(Config.Peds) do
                    if ped.cityhall and ped.zoneOptions then
                        local distance = #(playerCoords - ped.coords.xyz)
                        local options = ped.zoneOptions
                        local zoneRadius = math.max(options.length, options.width) / 2
                        
                        if distance < zoneRadius then
                            nearZone = true
                            break
                        end
                    end
                end
                
                if nearZone and not inZone then
                    inZone = true
                    exports['qb-core']:DrawText('[E] Open Cityhall')
                elseif not nearZone and inZone then
                    inZone = false
                    exports['qb-core']:HideText()
                end
            end
        end)
    end
end

-- Initialize on resource start
CreateThread(function()
    spawnPeds()
    setupBlipsAndZones()
end)

-- Handle E key press in zones (non-target)
if not Config.UseTarget then
    CreateThread(function()
        while true do
            Wait(0)
            if IsControlJustReleased(0, 38) then -- E key
                local playerCoords = GetEntityCoords(PlayerPedId())
                
                -- Check if player is in any cityhall zone
                for _, ped in ipairs(Config.Peds) do
                    if ped.cityhall and ped.zoneOptions then
                        local distance = #(playerCoords - ped.coords.xyz)
                        local options = ped.zoneOptions
                        
                        -- Check if within zone bounds
                        if distance < math.max(options.length, options.width) / 2 then
                            TriggerEvent('cityhall:client:openMenu')
                            break
                        end
                    end
                end
            end
        end
    end)
end

RegisterCommand('cityhall', function()
    TriggerEvent('cityhall:client:openMenu')
end, false)

-- Open UI event with hall detection
AddEventHandler('cityhall:client:openMenu', function()
    print('^2[Cityhall]^7 Opening menu...')
    local playerCoords = GetEntityCoords(PlayerPedId())
    
    -- Find nearest cityhall
    local nearestHall = 1
    local minDistance = math.huge
    
    for i, cityhall in ipairs(Config.Cityhalls) do
        local distance = #(playerCoords - cityhall.coords)
        if distance < minDistance then
            minDistance = distance
            nearestHall = i
        end
    end
    
    print('^2[Cityhall]^7 Nearest hall: ' .. nearestHall)
    
    -- Open UI with nearest hall data
    if Config.Cityhalls[nearestHall] then
        local cityhall = Config.Cityhalls[nearestHall]
        local licenses = {}
        
        for licenseId, licenseData in pairs(cityhall.licenses) do
            table.insert(licenses, {
                id = licenseId,
                label = licenseData.label,
                price = licenseData.cost,
                description = licenseData.description or '',
                metadata = licenseData.metadata
            })
        end
        
        print('^2[Cityhall]^7 Opening UI with ' .. #licenses .. ' licenses and ' .. #cityhall.jobs .. ' jobs')
        OpenUI({ licenses = licenses, jobs = cityhall.jobs, hallIndex = nearestHall })
        TriggerEvent('cityhall:client:setHallData', nearestHall, cityhall.coords)
    else
        print('^1[Cityhall]^7 No cityhall found at index ' .. nearestHall)
    end
end)
