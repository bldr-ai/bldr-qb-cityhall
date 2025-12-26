local QBCore = exports['qb-core']:GetCoreObject()
local availableJobs = {}

-- Initialize available jobs from config
for _, cityhall in ipairs(Config.Cityhalls) do
    for _, job in ipairs(cityhall.jobs) do
        availableJobs[job.id] = {
            ['label'] = job.label,
            ['isManaged'] = job.isManaged or false
        }
    end
end

-- Export: Add a new job to city hall
local function AddCityJob(jobName, jobData)
    if availableJobs[jobName] then return false, 'already added' end
    availableJobs[jobName] = {
        ['label'] = jobData.label,
        ['isManaged'] = jobData.isManaged or false
    }
    return true, 'success'
end

exports('AddCityJob', AddCityJob)

-- License Purchase Event - QBCore Compatible
RegisterNetEvent('cityhall:server:purchaseLicense', function(licenseType, hall, cityhallCoords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Distance validation (prevent exploiting from distance)
    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)
    if #(pedCoords - cityhallCoords) >= 20.0 then
        return TriggerClientEvent('QBCore:Notify', src, 'You are too far away from the City Hall', 'error')
    end
    
    -- Get license config
    local cityhall = Config.Cityhalls[hall]
    if not cityhall then
        return TriggerClientEvent('QBCore:Notify', src, 'Invalid city hall', 'error')
    end
    
    local licenseConfig = cityhall.licenses[licenseType]
    if not licenseConfig then
        return TriggerClientEvent('QBCore:Notify', src, 'Invalid license', 'error')
    end

    local price = licenseConfig.cost
    local playerMoney = Player.PlayerData.money['cash']
    
    -- Check if player has enough money
    if playerMoney < price then
        return TriggerClientEvent('QBCore:Notify', src, ('You don\'t have enough money on you, you need $%s cash'):format(price), 'error')
    end
    
    -- Remove money from player
    if not Player.Functions.RemoveMoney('cash', price, 'cityhall-license') then
        return TriggerClientEvent('QBCore:Notify', src, 'Failed to remove money', 'error')
    end

    -- Create license item info based on license type
    local info = {}
    
    if licenseType == 'id_card' then
        info.citizenid = Player.PlayerData.citizenid
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.gender = Player.PlayerData.charinfo.gender
        info.nationality = Player.PlayerData.charinfo.nationality
        
    elseif licenseType == 'driver_license' then
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.gender = Player.PlayerData.charinfo.gender
        info.type = 'Class A'
        
    elseif licenseType == 'weaponlicense' then
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.expiration = 'lifetime'
    else
        Player.Functions.AddMoney('cash', price, 'cityhall-refund')
        return TriggerClientEvent('QBCore:Notify', src, 'Invalid license type', 'error')
    end

    -- Add item to player inventory
    if not exports['qb-inventory']:AddItem(src, licenseType, 1, false, info, 'cityhall:server:purchaseLicense') then
        Player.Functions.AddMoney('cash', price, 'cityhall-refund')
        return TriggerClientEvent('QBCore:Notify', src, 'Inventory is full', 'error')
    end
    
    TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[licenseType], 'add')
    TriggerClientEvent('QBCore:Notify', src, ('You purchased a %s for $%d'):format(licenseConfig.label, price), 'success')
    
    -- Send email notification via qb-phone
    local citizenid = Player.PlayerData.citizenid
    local firstName = Player.PlayerData.charinfo.firstname
    local lastName = Player.PlayerData.charinfo.lastname
    
    local mailData = {
        sender = 'City Hall',
        subject = licenseConfig.label .. ' - Issued',
        message = 'Hello ' .. firstName .. ' ' .. lastName .. ',<br><br>Your ' .. licenseConfig.label .. ' has been successfully issued.<br><br><strong>License Type:</strong> ' .. licenseConfig.label .. '<br><strong>Cost:</strong> $' .. price .. '<br><strong>Date Issued:</strong> ' .. os.date('%m/%d/%Y') .. '<br><br>This license is now in your inventory and ready to use.<br><br>Best regards,<br>City Hall Services',
        button = {}
    }
    exports['qb-phone']:sendNewMailToOffline(citizenid, mailData)
    
    -- Log the purchase
    TriggerEvent('qb-logs:server:CreateLog', 'cityhall', 'License Purchase', 'green', '**'..GetPlayerName(src)..'** purchased '..licenseConfig.label..' for $'..price)
    print('^2[City Hall]^7 Player ^5'..GetPlayerName(src)..' (^5'..src..'^7) purchased '..licenseConfig.label..' for $'..price)
end)

-- Job Application Event - QBCore Compatible
RegisterNetEvent('cityhall:server:applyJob', function(jobId, hall, cityhallCoords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Distance validation (prevent exploiting from distance)
    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)
    if #(pedCoords - cityhallCoords) >= 20.0 or not availableJobs[jobId] then
        return TriggerClientEvent('QBCore:Notify', src, 'You are too far away from the City Hall', 'error')
    end
    
    -- Get cityhall config
    local cityhall = Config.Cityhalls[hall]
    if not cityhall then
        return TriggerClientEvent('QBCore:Notify', src, 'Invalid city hall', 'error')
    end
    
    -- Validate job exists in QBCore
    local jobConfig = QBCore.Shared.Jobs[jobId]
    if not jobConfig then
        return TriggerClientEvent('QBCore:Notify', src, 'Invalid job', 'error')
    end
    
    -- Set player job with grade 0
    Player.Functions.SetJob(jobId, 0)
    
    TriggerClientEvent('QBCore:Notify', src, ('You have been hired as a %s'):format(jobConfig.label), 'success')
    
    -- Send email notification via qb-phone
    local citizenid = Player.PlayerData.citizenid
    local firstName = Player.PlayerData.charinfo.firstname
    local lastName = Player.PlayerData.charinfo.lastname
    local phoneNumber = Player.PlayerData.charinfo.phone
    
    local mailData = {
        sender = 'City Hall',
        subject = 'Job Application Confirmation',
        message = 'Hello,<br><br>Congratulations! Your job application has been approved.<br><br><strong>Position: ' .. jobConfig.label .. '</strong><br><br>Please report to your supervisor to get started.<br><br>Best regards,<br>City Hall Services',
        button = {}
    }
    exports['qb-phone']:sendNewMailToOffline(citizenid, mailData)
    
    -- Log the job application
    TriggerEvent('qb-logs:server:CreateLog', 'cityhall', 'Job Application', 'green', '**'..GetPlayerName(src)..'** applied for job: '..jobConfig.label)
    print('^2[City Hall]^7 Player ^5'..GetPlayerName(src)..' (^5'..src..'^7) applied for job: ^5'..jobConfig.label)
end)

-- Update core object when QBCore updates
RegisterNetEvent('QBCore:Client:UpdateObject', function()
    QBCore = exports['qb-core']:GetCoreObject()
end)
