local isOpen = false
local currentHallIndex = 1
local currentHallCoords = vector3(0, 0, 0)

function OpenUI(data)
    if isOpen then 
        print('^1[Cityhall NUI]^7 UI already open')
        return 
    end
    isOpen = true
    print('^2[Cityhall NUI]^7 Setting NUI focus and opening UI')
    local jsonData = json.encode({ action = 'open', data = data })
    print('^2[Cityhall NUI]^7 JSON length: ' .. #jsonData)
    print('^2[Cityhall NUI]^7 Data structure - Licenses: ' .. (data.licenses and #data.licenses or 0) .. ', Jobs: ' .. (data.jobs and #data.jobs or 0))
    SetNuiFocus(true, true)
    SendNuiMessage(jsonData)
    print('^2[Cityhall NUI]^7 NUI message sent')
end

function CloseUI()
    if not isOpen then return end
    isOpen = false
    print('^2[Cityhall NUI]^7 Closing UI')
    SetNuiFocus(false, false)
    SendNuiMessage(json.encode({ action = 'close' }))
end

-- Handle ESC key to close
CreateThread(function()
    while true do
        Wait(0)
        if isOpen and IsControlJustReleased(0, 322) then -- ESC key
            CloseUI()
        end
    end
end)

RegisterNuiCallback('close', function(_, cb)
    print('^2[Cityhall NUI]^7 Close callback triggered')
    CloseUI()
    cb({ success = true })
end)

RegisterNuiCallback('purchaseLicense', function(data, cb)
    TriggerServerEvent('cityhall:server:purchaseLicense', data.license, currentHallIndex, currentHallCoords)
    cb({ success = true })
end)

RegisterNuiCallback('applyJob', function(data, cb)
    TriggerServerEvent('cityhall:server:applyJob', data.job, currentHallIndex, currentHallCoords)
    cb({ success = true })
end)

RegisterNetEvent('cityhall:client:notification', function(type, title, message)
    TriggerEvent('chat:addMessage', {
        args = {title, message},
        color = {255, 0, 0}
    })
end)

-- Store hall index and coordinates when opening UI
RegisterNetEvent('cityhall:client:setHallData', function(hallIndex, hallCoords)
    currentHallIndex = hallIndex
    currentHallCoords = hallCoords
end)
