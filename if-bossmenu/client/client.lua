if Config.Framework ~= 'qbcore' then
    ESX = exports['es_extended']:getSharedObject()
else
    QBCore = exports['qb-core']:GetCoreObject()
end

local names = {}
local function toggleNuiFrame(shouldShow)
    SetNuiFocus(shouldShow, shouldShow)
    SendReactMessage('setVisible', shouldShow)
end

if Config.UseCommand then
    RegisterCommand('bossmenu', function()
        if Config.Framework == 'qbcore' then
            if not QBCore.Functions.GetPlayerData().job.isboss then
                QBCore.Functions.Notify('You are not the boss of this company', 'error')
                return
            end
        else
            if not ESX.PlayerData.job.grade_name == 'boss' then
                ESX.ShowNotification('You are not the boss of this company')
                return
            end
        end
        local arr = {}
        if Config.Framework == 'esx' then
            arr = {
                type = 'none',
                name = ESX.PlayerData.job.name,
                isboss = ESX.PlayerData.job.grade_name == 'boss' and true or false,
                label = ESX.PlayerData.job.label,
                onduty = ESX.PlayerData.job.onduty and true or false,
                grade = {
                    level = ESX.PlayerData.job.grade,
                    name = ESX.PlayerData.job.name,
                    payment = 0,
                    isboss = ESX.PlayerData.job.grade_name == 'boss' and true or false,
                },
            }
        end
        local returnValue = lib.callback.await('bossmenu:server:getAccounts', 500,
            Config.Framework == 'qbcore' and QBCore.Functions.GetPlayerData().job.name or ESX.PlayerData.job.name)
        SendReactMessage('SendPlayerData', Config.Framework == 'esx' and arr or QBCore.Functions.GetPlayerData().job)
        SendReactMessage('SetAccountData', returnValue)
        toggleNuiFrame(true)
    end)
else
    if Config.UseoxPoly then
        for _, v in ipairs(Config.PolyData) do
            table.insert(names, v.name)
            lib.zones.box({
                coords = v.coords,
                size = { x = v.width, y = v.length, z = 1.0 },
                rotation = v.heading,
                debug = false,
                onEnter = function()
                    lib.showTextUI("Press E to Open Bossmenu")
                end,
                onExit = function()
                    lib.hideTextUI()
                end,
                inside = function()
                    if IsControlJustPressed(0, 38) then
                        if Config.Framework == 'qbcore' then
                            if not QBCore.Functions.GetPlayerData().job.isboss then
                                QBCore.Functions.Notify('You are not the boss of this company', 'error')
                                return
                            end
                        else
                            if not ESX.PlayerData.job.grade_name == 'boss' then
                                ESX.ShowNotification('You are not the boss of this company')
                                return
                            end
                        end
                        local arr = {}
                        if Config.Framework == 'esx' then
                            arr = {
                                type = 'none',
                                name = ESX.PlayerData.job.name,
                                isboss = ESX.PlayerData.job.grade_name == 'boss' and true or false,
                                label = ESX.PlayerData.job.label,
                                onduty = ESX.PlayerData.job.onduty and true or false,
                                grade = {
                                    level = ESX.PlayerData.job.grade,
                                    name = ESX.PlayerData.job.name,
                                    payment = 0,
                                    isboss = ESX.PlayerData.job.grade_name == 'boss' and true or false,
                                },
                            }
                        end
                        local returnValue = lib.callback.await('bossmenu:server:getAccounts', 500,
                            Config.Framework == 'qbcore' and QBCore.Functions.GetPlayerData().job.name or
                            ESX.PlayerData.job.name)
                        SendReactMessage('SendPlayerData',
                            Config.Framework == 'esx' and arr or QBCore.Functions.GetPlayerData().job)
                        SendReactMessage('SetAccountData', returnValue)
                        toggleNuiFrame(true)
                    end
                end
            })
        end
    else
        if Config.UseTarget == 'qb' then
            for _, v in ipairs(Config.PolyData) do
                table.insert(names, v.name)
                exports['qb-target']:AddBoxZone(v.name, vector3(v.coords.x, v.coords.y, v.coords.z), v.width,
                    v.length, {
                        name = v.name,
                        heading = v.heading,
                        debugPoly = false,
                        minZ = v.minZ,
                        maxZ = v.maxZ,
                    }, {
                        options = {
                            {
                                type = "client",
                                icon = "fas fa-user-tie",
                                label = 'Bossmenu',
                                action = function(entity)
                                    local returnValue = lib.callback.await('bossmenu:server:getAccounts', false,
                                        Config.Framework == 'qbcore' and
                                        QBCore.Functions.GetPlayerData().job.name or ESX.PlayerData.job.name)
                                    SendReactMessage('SendPlayerData', QBCore.Functions.GetPlayerData().job)
                                    SendReactMessage('SetAccountData', returnValue)
                                    toggleNuiFrame(true)
                                end,
                                canInteract = function(entity)
                                    if not QBCore.Functions.GetPlayerData().job.isboss then
                                        QBCore.Functions.Notify('You are not the boss of this company', 'error')
                                        return false
                                    else
                                        return true
                                    end
                                end,
                                job = v.job
                            }
                        },
                        distance = 2.5,
                    })
            end
        elseif Config.UseTarget == 'ox' then
            for _, v in ipairs(Config.PolyData) do
                table.insert(names, v.name)
                exports.ox_target:addBoxZone({
                    coords = v.coords,
                    size = { x = v.width, y = v.length, z = 1.0 },
                    rotation = v.heading,
                    options = {
                        {
                            label = 'Bossmenu',
                            icon = 'fas fa-user-tie',
                            distance = 2.5,
                            onSelect = function ()
                                local returnValue = lib.callback.await('bossmenu:server:getAccounts', false,
                                    Config.Framework == 'qbcore' and
                                    QBCore.Functions.GetPlayerData().job.name or ESX.PlayerData.job.name)
                                SendReactMessage('SendPlayerData', QBCore.Functions.GetPlayerData().job)
                                SendReactMessage('SetAccountData', returnValue)
                                toggleNuiFrame(true)
                            end
                        }
                    }
                })
            end
            
        end
    end
end

---Net Events
RegisterNetEvent('bossmenu:client:refreshNuiAccount', function()
    local returnValue = lib.callback.await('bossmenu:server:getAccounts', false, Config.Framework == 'qbcore' and
        QBCore.Functions.GetPlayerData().job.name or ESX.PlayerData.job.name)
    SendReactMessage('SetAccountData', returnValue)
end)

RegisterNetEvent('bossmenu:client:refreshNuiPlayers', function(data)
    local employees = lib.callback.await('bossmenu:server:GetEmployees', 1000, Config.Framework == 'qbcore' and
        QBCore.Functions.GetPlayerData().job.name or ESX.PlayerData.job.name)
    SendReactMessage('SetEmployees', employees)
end)

RegisterNetEvent('bossmenu:client:showBills', function(data)
    local Player = QBCore.Functions.GetPlayerData().money
    SendReactMessage('SetBills', { data = data, pdata = Player })
    toggleNuiFrame(true)
end)
---Nui Callbacks
RegisterNuiCallback('hideFrame', function(_, cb)
    toggleNuiFrame(false)
    cb({})
end)

RegisterNuiCallback('withdraw', function(data, cb)
    print(json.encode(data))
    local returnValue = lib.callback.await('bossmenu:server:withdraw', 500, data)
    if returnValue then
        TriggerEvent('bossmenu:client:refreshNuiAccount')
        cb(true)
    end
end)

RegisterNuiCallback('deposit', function(data, cb)
    print(json.encode(data))
    local returnValue = lib.callback.await('bossmenu:server:deposit', 500, data)
    if returnValue then
        TriggerEvent('bossmenu:client:refreshNuiAccount')
        cb(true)
    end
end)

RegisterNuiCallback('get:timestamps', function(data, cb)
    TriggerEvent('bossmenu:client:refreshNuiPlayers')
    cb(true)
end)

RegisterNuiCallback('downGrade', function(data, cb)
    local joblevel = Config.Framework == 'qbcore' and QBCore.Functions.GetPlayerData().job.grade.level or
        ESX.PlayerData.job.grade
    local returnValue = lib.callback.await('bossmenu:updatePlayer2', false, { cid = data, grade = joblevel - 1 })
    if returnValue then
        TriggerEvent('bossmenu:client:refreshNuiPlayers')
        cb(true)
    end
end)

RegisterNuiCallback('upGrade', function(data, cb)
    local joblevel = Config.Framework == 'qbcore' and QBCore.Functions.GetPlayerData().job.grade.level or
        ESX.PlayerData.job.grade
    local returnValue = lib.callback.await('bossmenu:updatePlayer', false, { cid = data, grade = joblevel + 1 })
    if returnValue then
        TriggerEvent('bossmenu:client:refreshNuiPlayers')
        cb(true)
    end
end)

RegisterNuiCallback('fireEmployee', function(data, cb)
    local returnValue = lib.callback.await('bossmenu:server:FireEmployee', false, data)
    if returnValue then
        TriggerEvent('bossmenu:client:refreshNuiPlayers')
        cb(true)
    end
end)

RegisterNuiCallback('GetCurrentJobranks', function(data, cb)
    local JobsRank = Config.Framework == 'qbcore' and
        QBCore.Shared.Jobs[QBCore.Functions.GetPlayerData().job.name].grades or
        lib.callback.await('getEsxjobGrades', false, ESX.PlayerData.job.name)
    print(json.encode(JobsRank, { indent = true }))
    cb(JobsRank)
end)

RegisterNuiCallback('OpenBossInventory', function(data, cb)
    TriggerServerEvent('bossmenu:server:stash')
    toggleNuiFrame(false)
    cb(true)
end)

RegisterNuiCallback('SetRank', function(data, cb)
    local returnValue = lib.callback.await('bossmenu:server:setRank', false, data.source, data.rank)
    if returnValue then
        TriggerEvent('bossmenu:client:refreshNuiPlayers')
        cb(true)
    end
end)

RegisterNuiCallback('getApplicationOfjob', function(_, cb)
    local returnValue = lib.callback.await('bossmenu:server:GetApplication', false, Config.Framework == 'qbcore' and
        QBCore.Functions.GetPlayerData().job.name or ESX.PlayerData.job.name)
    if returnValue then
        cb(returnValue)
    end
end)

RegisterNuiCallback('DeclineJob', function(data, cb)
    TriggerServerEvent('bossmenu:server:DeclineJob', data)
    cb(true)
end)

RegisterNuiCallback('Acceptemployee', function(data, cb)
    TriggerServerEvent('bossmenu:server:HireEmployee', data)
    cb(true)
end)

RegisterNuiCallback('OpenBossOutfits', function(data, cb)
    TriggerEvent('illenium-appearance:client:OutfitManagementMenu', { type = 'Job' })
    cb(true)
end)

RegisterNuiCallback('GetBills', function(data, cb)
    local returnValue = lib.callback.await('bossmenu:server:getCompanybills', 500)
    local Player = QBCore.Functions.GetPlayerData().money
    Wait(100)
    cb({ data = returnValue, pdata = Player })
end)

RegisterNuiCallback('PayBill', function(data, cb)
    local returnValue = lib.callback.await('bossmenu:server:payBills', false, data)
    if returnValue then
        cb(returnValue)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, v in pairs(names) do
            exports['qb-target']:RemoveZone(v)
        end
    end
end)
