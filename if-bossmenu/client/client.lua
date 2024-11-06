local selectedFramework = Config.Framework:lower()
if selectedFramework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
elseif selectedFramework == 'qb' or selectedFramework == 'qbcore' then
    QBCore = exports['qb-core']:GetCoreObject()
else
    print('[ERROR] INVALID SELECTED FRAMEWORK! PLS, CHECK config.lua FILE!')
    return
end

local names = {}
local function toggleNuiFrame(shouldShow)
    SetNuiFocus(shouldShow, shouldShow)
    SendReactMessage('setVisible', shouldShow)
end

if not Config.MenuInteraction or Config.MenuInteraction.type == 'command' or Config.MenuInteraction.type == '' then
    local commandName = Config.MenuInteraction.commandName or 'bossmenu'
    RegisterCommand(commandName, function()
        if QBCore then
            if not QBCore.Functions.GetPlayerData().job.isboss then
                QBCore.Functions.Notify('You are not the boss of this company', 'error')
                return
            end
        else
            if not ESX.GetPlayerData().job.grade_name == 'boss' then
                ESX.ShowNotification('You are not the boss of this company')
                return
            end
        end
        local arr = {}
        if ESX then
            local playerData = ESX.GetPlayerData()
            arr = {
                type = 'none',
                name = playerData.job.name,
                isboss = playerData.job.grade_name == 'boss' and true or false,
                label = playerData.job.label,
                onduty = playerData.job.onduty and true or false,
                grade = {
                    level = playerData.job.grade,
                    name = playerData.job.name,
                    payment = 0,
                    isboss = playerData.job.grade_name == 'boss' and true or false,
                },
            }
        end
        local returnValue = lib.callback.await('bossmenu:server:getAccounts', 500,
            QBCore and QBCore.Functions.GetPlayerData().job.name or ESX.GetPlayerData().job.name)
        SendReactMessage('SendPlayerData', ESX and arr or QBCore.Functions.GetPlayerData().job)
        SendReactMessage('SetAccountData', returnValue)
        toggleNuiFrame(true)
    end)
else
    if Config.MenuInteraction.type == 'poly' then
        for _, v in ipairs(Config.MenuLocations) do
            table.insert(names, v.name)
            lib.zones.box({
                coords = v.coords,
                size = { x = v.width, y = v.length, z = 1.0 },
                rotation = v.heading,
                debug = false,
                onEnter = function()
                    lib.showTextUI("Press [E] to Open Bossmenu")
                end,
                onExit = function()
                    lib.hideTextUI()
                end,
                inside = function()
                    if IsControlJustPressed(0, 38) then
                        if QBCore then
                            local playerJob = QBCore.Functions.GetPlayerData().job
                            if (v.minGrade and playerJob.grade.level < v.minGrade) or (not v.minGrade and not playerJob.isboss) then
                                QBCore.Functions.Notify('You are not the boss of this company', 'error')
                                return
                            end
                        else
                            local playerJob = ESX.GetPlayerData().job
                            if (v.minGrade and playerJob.grade < v.minGrade) or (not v.minGrade and playerJob.grade_name ~= 'boss') then
                                ESX.ShowNotification('You are not the boss of this company')
                                return
                            end
                        end
                        local arr = {}
                        if ESX then
                            local playerData = ESX.GetPlayerData()
                            arr = {
                                type = 'none',
                                name = playerData.job.name,
                                isboss = playerData.job.grade_name == 'boss' and true or false,
                                label = playerData.job.label,
                                onduty = playerData.job.onduty and true or false,
                                grade = {
                                    level = playerData.job.grade,
                                    name = playerData.job.name,
                                    payment = 0,
                                    isboss = playerData.job.grade_name == 'boss' and true or false,
                                },
                            }
                        end
                        local returnValue = lib.callback.await('bossmenu:server:getAccounts', 500,
                            QBCore and QBCore.Functions.GetPlayerData().job.name or
                            ESX.GetPlayerData().job.name)
                        SendReactMessage('SendPlayerData',
                            ESX and arr or QBCore.Functions.GetPlayerData().job)
                        SendReactMessage('SetAccountData', returnValue)
                        toggleNuiFrame(true)
                    end
                end
            })
        end
    else
        local targetResorceName = Config.MenuInteraction.targetResourceName
        local TARGET_ICON <const> = "fas fa-user-tie"
        if targetResorceName == 'qb' or targetResorceName == 'qb-target' then
            for _, v in ipairs(Config.MenuLocations) do
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
                                icon = TARGET_ICON,
                                label = 'Bossmenu',
                                action = function(entity)
                                    local returnValue = lib.callback.await('bossmenu:server:getAccounts', false,
                                        QBCore.Functions.GetPlayerData().job.name)
                                    SendReactMessage('SendPlayerData', QBCore.Functions.GetPlayerData().job)
                                    SendReactMessage('SetAccountData', returnValue)
                                    toggleNuiFrame(true)
                                end,
                                canInteract = function(entity)
                                    local playerJob = QBCore.Functions.GetPlayerData().job
                                    if (v.minGrade and playerJob.grade.level < v.minGrade) or (not v.minGrade and not playerJob.isboss) then
                                        return false
                                    end
                                    return true
                                end,
                                job = v.job
                            }
                        },
                        distance = 2.5,
                    })
            end
        elseif targetResorceName == 'ox' or targetResorceName == 'ox_target' then
            for _, v in ipairs(Config.MenuLocations) do
                table.insert(names, v.name)
                exports.ox_target:addBoxZone({
                    coords = v.coords,
                    size = { x = v.width, y = v.length, z = 1.0 },
                    rotation = v.heading,
                    options = {
                        {
                            label = 'Bossmenu',
                            icon = TARGET_ICON,
                            distance = 2.5,
                            groups = v.job,
                            canInteract = function()
                                if QBCore then
                                    local playerJob = QBCore.Functions.GetPlayerData().job
                                    if (v.minGrade and playerJob.grade.level < v.minGrade) or (not v.minGrade and not playerJob.isboss) then
                                        return false
                                    end
                                else
                                    local playerJob = ESX.GetPlayerData().job
                                    if (v.minGrade and playerJob.grade < v.minGrade) or (not v.minGrade and playerJob.grade_name ~= 'boss') then
                                        return false
                                    end
                                end
                                return true
                            end,
                            onSelect = function()
                                local returnValue = lib.callback.await('bossmenu:server:getAccounts', false,
                                    QBCore and
                                    QBCore.Functions.GetPlayerData().job.name or ESX.GetPlayerData().job.name)
                                local arr = {}
                                if ESX then
                                    local playerData = ESX.GetPlayerData()
                                    arr = {
                                        type = 'none',
                                        name = playerData.job.name,
                                        isboss = playerData.job.grade_name == 'boss' and true or false,
                                        label = playerData.job.label,
                                        onduty = playerData.job.onduty and true or false,
                                        grade = {
                                            level = playerData.job.grade,
                                            name = playerData.job.name,
                                            payment = 0,
                                            isboss = playerData.job.grade_name == 'boss' and true or false,
                                        },
                                    }
                                end
                                SendReactMessage('SendPlayerData', ESX and arr or QBCore.Functions.GetPlayerData().job)
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
    local returnValue = lib.callback.await('bossmenu:server:getAccounts', false, QBCore and
        QBCore.Functions.GetPlayerData().job.name or ESX.GetPlayerData().job.name)
    SendReactMessage('SetAccountData', returnValue)
end)

RegisterNetEvent('bossmenu:client:refreshNuiPlayers', function(data)
    local employees = lib.callback.await('bossmenu:server:GetEmployees', 1000, QBCore and
        QBCore.Functions.GetPlayerData().job.name or ESX.GetPlayerData().job.name)
    SendReactMessage('SetEmployees', employees)
end)

RegisterNetEvent('bossmenu:client:showBills', function(data)
    local pdata = {
        cash = 0,
        bank = 0,
        crypto = 0
    }
    if ESX then
        for _, account in pairs(ESX.GetPlayerData().accounts) do
            if account.name == "bank" then
                pdata.bank = account.money
            elseif account.name == "money" then
                pdata.cash = account.money
            elseif account.name == "crypto" then
                pdata.crypto = account.money
            end
        end
    elseif QBCore then
        pdata = QBCore.Functions.GetPlayerData().money
    end
    SendReactMessage('SetBills', { data = data, pdata = pdata })
    toggleNuiFrame(true)
end)
---Nui Callbacks
RegisterNuiCallback('hideFrame', function(_, cb)
    toggleNuiFrame(false)
    cb({})
end)

RegisterNuiCallback('withdraw', function(data, cb)
    local returnValue = lib.callback.await('bossmenu:server:withdraw', 500, data)
    if returnValue then
        TriggerEvent('bossmenu:client:refreshNuiAccount')
        cb(true)
    end
end)

RegisterNuiCallback('deposit', function(data, cb)
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
    local joblevel = QBCore and QBCore.Functions.GetPlayerData().job.grade.level or
        ESX.GetPlayerData().job.grade
    local returnValue = lib.callback.await('bossmenu:updatePlayer2', false, { cid = data, grade = joblevel - 1 })
    if returnValue then
        TriggerEvent('bossmenu:client:refreshNuiPlayers')
        cb(true)
    end
end)

RegisterNuiCallback('upGrade', function(data, cb)
    local joblevel = QBCore and QBCore.Functions.GetPlayerData().job.grade.level or
        ESX.GetPlayerData().job.grade
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
    local JobsRank = QBCore and
        QBCore.Shared.Jobs[QBCore.Functions.GetPlayerData().job.name].grades or
        lib.callback.await('getEsxjobGrades', false, ESX.GetPlayerData().job.name)
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
    local returnValue = lib.callback.await('bossmenu:server:GetApplication', false, QBCore and
        QBCore.Functions.GetPlayerData().job.name or ESX.GetPlayerData().job.name)
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
    local pdata = {
        cash = 0,
        bank = 0,
        crypto = 0
    }
    if ESX then
        for _, account in pairs(ESX.GetPlayerData().accounts) do
            if account.name == "bank" then
                pdata.bank = account.money
            elseif account.name == "money" then
                pdata.cash = account.money
            elseif account.name == "crypto" then
                pdata.crypto = account.money
            end
        end
    elseif QBCore then
        pdata = QBCore.Functions.GetPlayerData().money
    end
    Wait(100)
    cb({ data = returnValue, pdata = pdata })
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
            if Config.UseTarget == 'qb' then
                exports['qb-target']:RemoveZone(v)
            end
        end
    end
end)
