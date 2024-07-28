if Config.Framework ~= 'qbcore' then
    ESX = exports['es_extended']:getSharedObject()
else
    QBCore = exports['qb-core']:GetCoreObject()
end

function Notify(source, message, type)
    if Config.Framework == 'esx' then
        TriggerClientEvent('esx:showNotification', source, message)
    else
        TriggerClientEvent('QBCore:Notify', source, message, type)
    end
end

MySQL.ready(function()
    MySQL.Async.execute(
        "CREATE TABLE IF NOT EXISTS `bossmenu_jobsdata` (" ..
        "`id` INT(11) NOT NULL AUTO_INCREMENT, " ..
        "`job` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb3_general_ci', " ..
        "`money` BIGINT(20) NULL DEFAULT NULL, " ..
        "INDEX `id` (`id`) USING BTREE" ..
        ")COLLATE='utf8mb3_general_ci' ENGINE=InnoDB;"
        , {}, function()
            if Config.Framework == 'esx' then
                MySQL.query('SELECT name FROM jobs', {}, function(result)
                    local caller = result
                    for k, v in pairs(caller) do
                        MySQL.Async.fetchAll('SELECT * FROM bossmenu_jobsdata WHERE job = ?', { v.name },
                            function(result)
                                if result[1] == nil then
                                    MySQL.Async.execute(
                                        'INSERT INTO bossmenu_jobsdata (job, money) VALUES (@job, @money)', {
                                            ['@job'] = v.name,
                                            ['@money'] = 0
                                        })
                                end
                            end)
                    end
                end)
            else
                for k, v in pairs(QBCore.Shared.Jobs) do
                    MySQL.Async.fetchAll('SELECT * FROM bossmenu_jobsdata WHERE job = ?', { k }, function(result)
                        if result[1] == nil then
                            MySQL.Async.execute('INSERT INTO bossmenu_jobsdata (job, money) VALUES (@job, @money)', {
                                ['@job'] = k,
                                ['@money'] = 0
                            })
                        end
                    end)
                end
            end
        end)
end)

lib.callback.register('getEsxjobGrades', function(source, job)
    local result = MySQL.query.await('SELECT job_name, grade, label FROM job_grades WHERE job_name = ?', { job })
    local jobs = {}

    for _, row in ipairs(result) do
        if not jobs[row.job_name] then
            jobs[row.job_name] = {
                label = 'Some Label',
                type = 'Some Type',
                defaultDuty = true,
                offDutyPay = false,
                grades = {}
            }
        end
        jobs[row.job_name].grades[tostring(row.grade)] = {
            name = row.label,
            payment = 0
        }
    end
    return jobs[job].grades
end)

lib.callback.register('bossmenu:server:getAccounts', function(source, name)
    local arr = {}
    MySQL.query('SELECT * FROM bossmenu_jobsdata WHERE job = ?', { name }, function(result)
        arr = result[1]
    end)
    Wait(500)
    return arr
end)

lib.callback.register('bossmenu:server:withdraw', function(source, data)
    local job
    if Config.Framework == 'esx' then
        local PlayerData = ESX.GetPlayerFromId(source).job.grade_name
        job = PlayerData == "boss"
    else
        local Player = QBCore.Functions.GetPlayer(source)
        job = Player.PlayerData.job.isboss
    end
    if not job then
        cb(false)
        return
    end
    MySQL.query('SELECT * FROM bossmenu_jobsdata WHERE job = ?', { data.job }, function(result)
        local caller = result[1]
        if tonumber(caller.money) >= tonumber(data.amount) then
            MySQL.Async.execute('UPDATE bossmenu_jobsdata SET money = money - @amount WHERE job = @job', {
                ['@job'] = data.job,
                ['@amount'] = data.amount
            }, function()
                if Config.Framework == 'esx' then
                    local xPlayer = ESX.GetPlayerFromId(source)
                    xPlayer.addMoney(data.amount)
                else
                    Player.Functions.AddMoney('bank', data.amount, 'bossmenu-withdraw')
                end
            end)
            return true
        else
            return false
        end
    end)
    Wait(100)
    return true
end)

lib.callback.register('bossmenu:server:deposit', function(source, data)
    local job
    if Config.Framework == 'esx' then
        local PlayerData = ESX.GetPlayerFromId(source).job.grade_name
        job = PlayerData == "boss"
    else
        local Player = QBCore.Functions.GetPlayer(source)
        job = Player.PlayerData.job.isboss
    end
    if job then
        if Config.Framework == 'qbcore' then
            if Player.Functions.RemoveMoney('bank', data.amount, 'bossmenu-deposit') then
                local variable = MySQL.single.await("SELECT money FROM bossmenu_jobsdata WHERE job = ?", { data.job })
                local bossmoney = variable.money + data.amount
                MySQL.update('UPDATE bossmenu_jobsdata SET money = ? WHERE job = ?', { bossmoney, data.job })
                return true
            end
        else
            ESX.GetPlayerFromId(source).removeAccountMoney('bank', data.amount)
            local variable = MySQL.query.await("SELECT money FROM bossmenu_jobsdata WHERE job = ?", { data.job })
            local bossmoney = variable[1].money + data.amount
            MySQL.Async.execute('UPDATE bossmenu_jobsdata SET money = ? WHERE job = ?', { bossmoney, data.job })
            return true
        end
    else
        return false
    end
    Wait(100)
    return true
end)

lib.callback.register('bossmenu:server:GetEmployees', function(source, jobname)
    local src = source
    local job
    if Config.Framework == 'esx' then
        local PlayerData = ESX.GetPlayerFromId(src).job.grade_name
        job = PlayerData == "boss"
    else
        local Player = QBCore.Functions.GetPlayer(src)
        job = Player.PlayerData.job.isboss
    end
    if not job then
        ExploitBan(src, 'GetEmployees Exploiting')
        return false
    end

    local employees = {}
    if Config.Framework == 'qbcore' then
        local players = MySQL.query.await("SELECT * FROM `players` WHERE `job` LIKE '%" .. jobname .. "%'", {})
        if players[1] ~= nil then
            for _, value in pairs(players) do
                local Target = QBCore.Functions.GetPlayerByCitizenId(value.citizenid) or
                    QBCore.Functions.GetOfflinePlayerByCitizenId(value.citizenid)

                if Target and Target.PlayerData.job.name == jobname then
                    local isOnline = Target.PlayerData.source
                    employees[#employees + 1] = {
                        empSource = Target.PlayerData.citizenid,
                        grade = Target.PlayerData.job.grade,
                        isboss = Target.PlayerData.job.isboss,
                        name = Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname,
                        online = isOnline and true or false,
                    }
                end
            end
            table.sort(employees, function(a, b)
                return a.grade.level > b.grade.level
            end)
        end
    else
        local players = MySQL.query.await("SELECT * FROM `users` WHERE `job` LIKE '%" .. jobname .. "%'", {})
        if players[1] ~= nil then
            for _, value in pairs(players) do
                local Target = ESX.GetPlayerFromIdentifier(value.identifier)
                if Target and Target.job.name == jobname then
                    employees[#employees + 1] = {
                        empSource = Target.identifier,
                        grade = {
                            level = Target.job.grade,
                            name = Target.job.grade_name,
                        },
                        isboss = Target.job.grade_name == 'boss',
                        name = Target.getName(),
                        online = true,
                    }
                end
            end
            table.sort(employees, function(a, b)
                return a.grade.level > b.grade.level
            end)
        end
    end
    Wait(100)
    return employees
end)

RegisterNetEvent('bossmenu:server:stash', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local playerJob = Player.PlayerData.job
    if not playerJob.isboss then return end
    local playerPed = GetPlayerPed(src)
    local stashName = playerJob.name .. '-stash'
    exports['qb-inventory']:OpenInventory(src, stashName, {
        maxweight = 4000000,
        slots = 25,
    })
end)

-- Grade Change
lib.callback.register('bossmenu:updatePlayer2', function(source, data)
    local src = source
    if Config.Framework == 'qbcore' then
        local Player = QBCore.Functions.GetPlayer(src)
        local Employee = QBCore.Functions.GetPlayerByCitizenId(data.cid) or
            QBCore.Functions.GetOfflinePlayerByCitizenId(data.cid)

        if not Player.PlayerData.job.isboss then
            ExploitBan(src, 'GradeUpdate Exploiting')
            return false
        end
        if data.grade > Player.PlayerData.job.grade.level then
            Notify(src, 'You cannot promote to this rank!', 'error')
            return false
        end

        if Employee then
            if Employee.Functions.SetJob(Player.PlayerData.job.name, data.grade) then
                Notify(src, 'Sucessfully promoted!', 'success')
                Employee.Functions.Save()

                if Employee.PlayerData.source then -- Player is online
                    Notify(Employee.PlayerData.source, 'You have been promoted.', 'success')
                end
            else
                Notify(src, 'Promotion grade does not exist.', 'error')
            end
        end
    else
        local Player = ESX.GetPlayerFromId(src)
        local Employee = ESX.GetPlayerFromIdentifier(data.cid)

        if not Player.job.grade_name == 'boss' then
            ExploitBan(src, 'GradeUpdate Exploiting')
            return false
        end
        if data.grade > Player.job.grade then
            Notify(src, 'You cannot promote to this rank!', 'error')
            return false
        end

        if Employee then
            if Employee.setJob(Player.job.name, data.grade) then
                Notify(src, 'Sucessfully promoted!', 'success')
                Employee.save()

                if Employee.source then -- Player is online
                    Notify(Employee.source, 'You have been promoted.', 'success')
                end
            else
                Notify(src, 'Promotion grade does not exist.', 'error')
            end
        end
    end
    Wait(100)
    return true
end)

lib.callback.register('bossmenu:updatePlayer', function(source, data)
    local src = source
    if Config.Framework == 'qbcore' then
        local Player = QBCore.Functions.GetPlayer(src)
        local Employee = QBCore.Functions.GetPlayerByCitizenId(data.cid) or
            QBCore.Functions.GetOfflinePlayerByCitizenId(data.cid)

        if not Player.PlayerData.job.isboss then
            ExploitBan(src, 'GradeUpdate Exploiting')
            return false
        end
        if data.grade < Player.PlayerData.job.grade.level then
            Notify(src, 'You cannot promote to this rank!', 'error')
            return false
        end

        if Employee then
            if Employee.Functions.SetJob(Player.PlayerData.job.name, data.grade) then
                Notify(src, 'Sucessfully promoted!', 'success')
                Employee.Functions.Save()

                if Employee.PlayerData.source then -- Player is online
                    Notify(Employee.PlayerData.source, 'You have been promoted.', 'success')
                end
            else
                Notify(src, 'Promotion grade does not exist.', 'error')
            end
        end
    else
        local Player = ESX.GetPlayerFromId(src)
        local Employee = ESX.GetPlayerFromIdentifier(data.cid)

        if not Player.job.grade_name == 'boss' then
            ExploitBan(src, 'GradeUpdate Exploiting')
            return false
        end
        if data.grade < Player.job.grade then
            Notify(src, 'You cannot promote to this rank!', 'error')
            return false
        end

        if Employee then
            if Employee.setJob(Player.job.name, data.grade) then
                Notify(src, 'Sucessfully promoted!', 'success')
                Employee.save()

                if Employee.source then -- Player is online
                    Notify(Employee.source, 'You have been promoted.', 'success')
                end
            else
                Notify(src, 'Promotion grade does not exist.', 'error')
            end
        end
    end
    return true
end)

-- Fire Employee
lib.callback.register('bossmenu:server:FireEmployee', function(source, target)
    local src = source
    if Config.Framework == 'qbcore' then
        local Player = QBCore.Functions.GetPlayer(src)
        local Employee = QBCore.Functions.GetPlayerByCitizenId(target) or
            QBCore.Functions.GetOfflinePlayerByCitizenId(target)

        if not Player.PlayerData.job.isboss then
            ExploitBan(src, 'FireEmployee Exploiting')
            return false
        end

        if Employee then
            if target == Player.PlayerData.citizenid then
                Notify(src, 'You can\'t fire yourself', 'error')
                return false
            elseif Employee.PlayerData.job.grade.level > Player.PlayerData.job.grade.level then
                Notify(src, 'You cannot fire this citizen!', 'error')
                return false
            end
            if Employee.Functions.SetJob('unemployed', '0') then
                Employee.Functions.Save()
                Notify(src, 'Employee fired!', 'success')
                TriggerEvent('qb-log:server:CreateLog', 'bossmenu', 'Job Fire', 'red',
                    Player.PlayerData.charinfo.firstname ..
                    ' ' ..
                    Player.PlayerData.charinfo.lastname ..
                    ' successfully fired ' ..
                    Employee.PlayerData.charinfo.firstname ..
                    ' ' .. Employee.PlayerData.charinfo.lastname .. ' (' .. Player.PlayerData.job.name .. ')', false)

                if Employee.PlayerData.source then -- Player is online
                    Notify(Employee.PlayerData.source, 'You have been fired! Good luck.', 'error')
                end
            else
                Notify(src, 'Error..', 'error')
                return false
            end
        end
    else
        local Player = ESX.GetPlayerFromId(src)
        local Employee = ESX.GetPlayerFromIdentifier(target)

        if not Player.job.grade_name == 'boss' then
            ExploitBan(src, 'FireEmployee Exploiting')
            return false
        end

        if Employee then
            if target == Player.identifier then
                Notify(src, 'You can\'t fire yourself', 'error')
                return false
            elseif Employee.job.grade > Player.job.grade then
                Notify(src, 'You cannot fire this citizen!', 'error')
                return false
            end
            if Employee.setJob('unemployed', 0) then
                Employee.save()
                Notify(src, 'Employee fired!', 'success')

                if Employee.source then -- Player is online
                    Notify(Employee.source, 'You have been fired! Good luck.', 'error')
                end
            else
                Notify(src, 'Error..', 'error')
                return false
            end
        end
    end
    Wait(100)
    return true
end)

lib.callback.register('bossmenu:server:setRank', function(source, target, rank)
    local src = source
    if Config.Framework == 'qbcore' then
        local Player = QBCore.Functions.GetPlayer(src)
        local Target = QBCore.Functions.GetPlayerByCitizenId(target) or
            QBCore.Functions.GetOfflinePlayerByCitizenId(target)

        if not Player.PlayerData.job.isboss then
            ExploitBan(src, 'HireEmployee Exploiting')
            return false
        end

        if Target and Target.Functions.SetJob(Player.PlayerData.job.name, rank) then
            Notify(src,
                'You set ' ..
                (Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname) ..
                ' to rank ' .. Target.PlayerData.job.label, 'success')
            Notify(Target.PlayerData.source, 'You were set to rank ' .. Target.PlayerData.job.label, 'success')
            TriggerEvent('qb-log:server:CreateLog', 'bossmenu', 'Set Rank', 'lightgreen',
                (Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname) ..
                ' successfully set ' ..
                (Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname) ..
                ' to rank ' .. Target.PlayerData.job.label .. ' (' .. Player.PlayerData.job.name .. ')', false)
        end
    else
        local Player = ESX.GetPlayerFromId(src)
        local Target = ESX.GetPlayerFromIdentifier(target)

        if not Player.job.grade_name == 'boss' then
            ExploitBan(src, 'HireEmployee Exploiting')
            return false
        end

        if Target and Target.setJob(Player.job.name, rank) then
            Notify(src, 'You set ' .. (Target.getName()) .. ' to rank ' .. Target.job.grade_label, 'success')
            Notify(Target.source, 'You were set to rank ' .. Target.job.grade_label, 'success')
        end
    end
    return true
end)

-- Recruit Player
RegisterNetEvent('bossmenu:server:HireEmployee', function(recruit)
    local src = source
    if Config.Framework == 'qbcore' then
        local Player = QBCore.Functions.GetPlayer(src)
        local Target = QBCore.Functions.GetPlayerByCitizenId(recruit.citizen) or
            QBCore.Functions.GetOfflinePlayerByCitizenId(recruit.citizen)

        if not Player.PlayerData.job.isboss then
            ExploitBan(src, 'HireEmployee Exploiting')
            return
        end

        if Target and Target.Functions.SetJob(Player.PlayerData.job.name, 0) then
            MySQL.query("DELETE FROM bossmenu_application WHERE id = ?", { recruit.id }, function(result)
                if result then
                    Notify(src, 'Application accepted successfully.', 'success')
                end
            end)
            Notify(src,
                'You hired ' ..
                (Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname) ..
                ' come ' .. Player.PlayerData.job.label .. '', 'success')
            Notify(Target.PlayerData.source, 'You were hired as ' .. Player.PlayerData.job.label .. '', 'success')
            TriggerEvent('qb-log:server:CreateLog', 'bossmenu', 'Recruit', 'lightgreen',
                (Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname) ..
                ' successfully recruited ' ..
                (Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname) ..
                ' (' .. Player.PlayerData.job.name .. ')', false)
        end
    else
        local Player = ESX.GetPlayerFromId(src)
        local Target = ESX.GetPlayerFromIdentifier(recruit.citizen)

        if not Player.job.grade_name == 'boss' then
            ExploitBan(src, 'HireEmployee Exploiting')
            return
        end

        if Target and Target.setJob(Player.job.name, 0) then
            MySQL.Async.execute("DELETE FROM bossmenu_application WHERE id = ?", { recruit.id }, function(result)
                if result then
                    Notify(src, 'Application accepted successfully.', 'success')
                end
            end)
            Notify(src, 'You hired ' .. (Target.getName()) .. ' come ' .. Player.job.label .. '', 'success')
            Notify(Target.source, 'You were hired as ' .. Player.job.label .. '', 'success')
        end
    end
end)

lib.addCommand('apply', {
    help = 'Gives an item to a player',
    params = {
        {
            name = 'job',
            type = 'string',
            help = 'Which Job You Want To Apply ?',
        },
        {
            name = 'reason',
            type = 'string',
            help = 'Name of the item to give',
        },
    }
}, function(source, args, raw)
    local src = source
    local Player = Config.Framework == 'qbcore' and QBCore.Functions.GetPlayer(src) or ESX.GetPlayerFromId(src)
    local job = args.job
    local reason = string.sub(raw, string.len(args.job) + string.len(args.reason) + 3)
    reason = string.gsub(reason, "^%s+", "")
    local gender = Config.Framework == 'qbcore' and Player.PlayerData.charinfo.gender or Player.variables.sex
    if gender == 0 or gender == 'm' then
        gender = 'Male'
    else
        gender = 'Female'
    end
    local name = Config.Framework == 'qbcore' and
        Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname or
        Player.variables.firstName .. ' ' .. Player.variables.lastName
    local date = os.date('%d-%m-%Y', os.time())

    local isRealJob = false
    for _, realJob in ipairs(Config.RealJob) do
        if job == realJob then
            isRealJob = true
            break
        end
    end

    if not isRealJob then
        Notify(src, 'The specified job is not valid.', 'error')
        return
    end

    MySQL.query('SELECT 1 FROM bossmenu_application WHERE job = ? AND citizenid = ?',
        { job, Config.Framework == 'qbcore' and Player.PlayerData.citizenid or Player.identifier }, function(result)
            if result[1] then
                Notify(src, 'You have already applied for this job.', 'error')
            else
                MySQL.insert(
                    'INSERT INTO bossmenu_application (job, citizenid, name, gender, date, reason) VALUES (?, ?, ?, ?, ?, ?)',
                    {
                        job,
                        Config.Framework == 'qbcore' and Player.PlayerData.citizenid or Player.identifier,
                        name,
                        gender,
                        date,
                        reason
                    })
                Notify(src, 'Application submitted successfully.', 'success')
            end
        end)
end)

lib.callback.register('bossmenu:server:GetApplication', function(source, job)
    local src = source
    local variable = MySQL.query.await("SELECT * FROM bossmenu_application WHERE job = ?", { job })
    return variable
end)

RegisterNetEvent('bossmenu:server:DeclineJob', function(data)
    local src = source
    MySQL.query("DELETE FROM bossmenu_application WHERE id = ?", { data }, function(result)
        if result then
            Notify(src, 'Application declined successfully.', 'success')
        end
    end)
end)

lib.addCommand('bill', {
    help = 'Bill the person',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Enter the player id',
        },
        {
            name = 'amount',
            type = 'number',
            help = 'Enter the amount',
        },
    }
}, function(source, args, raw)
    local src = source
    local Player = Config.Framework == 'qbcore' and QBCore.Functions.GetPlayer(src) or ESX.GetPlayerFromId(src)
    local Target = Config.Framework == 'qbcore' and QBCore.Functions.GetPlayer(args.target) or
        ESX.GetPlayerFromId(args.target)
    local date = os.date('%d-%m-%Y', os.time())
    local billDate = os.date('%d-%m-%Y', os.time() + (30 * 24 * 60 * 60))
    if not Target then
        Notify(src, 'Player not found.', 'error')
        return
    end
    local isRealJob = false
    for _, realJob in ipairs(Config.RealJob) do
        if Config.Framework == 'qbcore' and Player.PlayerData.job.name or Player.job.name == realJob then
            isRealJob = true
            break
        end
    end
    local amount = args.amount
    if not isRealJob then
        Notify(src, 'You are not allowed to send bills.', 'error')
        return
    end
    if amount <= 0 then
        Notify(src, 'Invalid amount.', 'error')
        return
    end

    if Config.Framework == 'qbcore' then
        MySQL.insert(
            'INSERT INTO bossmenu_bills (job, rcdate, untildate, amount, toname, tocitizenid, fromname, fromcitizenid) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            {
                Player.PlayerData.job.name,
                date,
                billDate,
                amount,
                Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname,
                Target.PlayerData.citizenid,
                Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                Player.PlayerData.citizenid
            })
    else
        MySQL.insert(
            'INSERT INTO bossmenu_bills (job, rcdate, untildate, amount, toname, tocitizenid, fromname, fromcitizenid) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            {
                Player.job.name,
                date,
                billDate,
                amount,
                Target.variables.firstName .. ' ' .. Target.variables.lastName,
                Target.identifier,
                Player.variables.firstName .. ' ' .. Player.variables.lastName,
                Player.identifier
            })
    end
    Notify(src, 'Bill sent successfully.', 'success')
    if Config.Framework == 'qbcore' then
        TriggerClientEvent('QBCore:Notify', Target.PlayerData.source,
            'You have received a bill from ' ..
            Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname .. '', 'success')
    else
        Notify(Target.source, 'You have received a bill.', 'success')
    end
end)

lib.addCommand('getbills', {
    help = 'Get the pending bills',
    params = {
        {
            name = 'type',
            type = 'string',
            help = 'Enter the type personal/company',
        }
    }
}, function(source, args, raw)
    local type = args.type
    local src = source
    local Player = Config.Framework == 'qbcore' and QBCore.Functions.GetPlayer(src) or ESX.GetPlayerFromId(src)
    if type == 'personal' then
        MySQL.query('SELECT * FROM bossmenu_bills WHERE tocitizenid = ?',
            { Config.Framework == 'qbcore' and Player.PlayerData.citizenid or Player.identifier },
            function(result)
                if result[1] then
                    TriggerClientEvent('bossmenu:client:showBills', src, result)
                else
                    Notify(src, 'You have no pending bills.', 'error')
                end
            end)
    elseif type == 'company' then
        if Config.Framework == 'esx' then
            if ESX.GetPlayerFromId(src).job.grade_name == 'boss' then
                return
            end
        else
            if not Player.PlayerData.job.isboss then return end
        end
        MySQL.query('SELECT * FROM bossmenu_bills WHERE job = ?', { Player.PlayerData.job.name }, function(result)
            if result[1] then
                TriggerClientEvent('bossmenu:client:showBills', src, result)
            else
                Notify(src, 'You have no pending bills.', 'error')
            end
        end)
    else
        Notify(src, 'Invalid type.', 'error')
    end
end)

lib.callback.register('bossmenu:server:getCompanybills', function(source)
    local src = source
    local Player = Config.Framework == 'qbcore' and QBCore.Functions.GetPlayer(src) or ESX.GetPlayerFromId(src)
    if Config.Framework == 'esx' then
        if ESX.GetPlayerFromId(src).job.grade_name == 'boss' then
            return
        end
    else
        if not Player.PlayerData.job.isboss then return end
    end

    local arr = {}
    MySQL.query('SELECT * FROM bossmenu_bills WHERE job = ?',
        { Config.Framework == 'qbcore' and Player.PlayerData.job.name or Player.job.name }, function(result)
            if result[1] then
                arr = result
            end
        end)
    Wait(500)
    return arr
end)

lib.callback.register('bossmenu:server:payBills', function(source, data)
    local src = source
    if Config.Framework == 'qbcore' then
        local Player = QBCore.Functions.GetPlayerByCitizenId(data.fromcitizenid) or
            QBCore.Functions.GetOfflinePlayerByCitizenId(data.fromcitizenid)

        if Player.Functions.RemoveMoney('bank', data.amount) then
            MySQL.query("SELECT * FROM bossmenu_jobsdata WHERE job = ?", { data.job }, function(result)
                if result[1] then
                    local totalamount = result[1].money + data.amount
                    local Promise = MySQL.update.await("UPDATE bossmenu_jobsdata SET money = ? WHERE job = ?",
                        { totalamount, data.job })
                    if Promise then
                        MySQL.query("DELETE FROM bossmenu_bills WHERE id = ?", { data.id }, function(result)
                            if result then
                                Notify(Player.PlayerData.source, 'Bill Paid', 'success')
                                return true
                            end
                        end)
                    end
                end
            end)
        end
    else
        local Player = ESX.GetPlayerFromIdentifier(data.fromcitizenid)
        if Player then
            Player.addAccountMoney('bank', data.amount)
            MySQL.query("SELECT * FROM bossmenu_jobsdata WHERE job = ?", { data.job }, function(result)
                if result[1] then
                    local totalamount = result[1].money + data.amount
                    MySQL.update("UPDATE bossmenu_jobsdata SET money = ? WHERE job = ?", { totalamount, data.job })
                    MySQL.query("DELETE FROM bossmenu_bills WHERE id = ?", { data.id })
                    Notify(Player.source, 'Bill Paid', 'success')
                    return true
                end
            end)
        end
    end
end)
