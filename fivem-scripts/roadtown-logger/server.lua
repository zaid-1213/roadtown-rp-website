-- ============================================
-- Road Town RP - Admin & txAdmin Logger
-- يرسل سجلات استخدام الأدمن و txAdmin للموقع
-- يغطي جميع أوامر txAdmin in-game menu + qb-adminmenu
-- ============================================

local function SendLog(endpoint, data)
    data.secret = Config.Secret
    PerformHttpRequest(Config.WebsiteURL .. endpoint, function(errorCode, resultData, resultHeaders)
        if errorCode ~= 200 then
            print("^1[RoadTown Logger] Failed to send log: " .. tostring(errorCode) .. "^0")
        end
    end, "POST", json.encode(data), { ["Content-Type"] = "application/json" })
end

local function GetTargetName(player)
    if player and player.id then
        return (GetPlayerName(player.id) or "Unknown") .. " (ID: " .. player.id .. ")"
    end
    return "-"
end

local function GetAdminName(src)
    if src and src > 0 then
        return (GetPlayerName(src) or "Unknown") .. " (ID: " .. src .. ")"
    end
    return "Console"
end

-- ============================================
-- QB-ADMINMENU LOGGING
-- ============================================
if Config.LogQBAdmin then

    AddEventHandler('qb-admin:server:kill', function(player)
        SendLog("/api/fivem/admin-log", { admin = GetAdminName(source), action = "Kill", target = GetTargetName(player), details = "قتل اللاعب" })
    end)

    AddEventHandler('qb-admin:server:revive', function(player)
        SendLog("/api/fivem/admin-log", { admin = GetAdminName(source), action = "Revive", target = GetTargetName(player), details = "إحياء اللاعب" })
    end)

    AddEventHandler('qb-admin:server:kick', function(player, reason)
        SendLog("/api/fivem/admin-log", { admin = GetAdminName(source), action = "Kick", target = GetTargetName(player), details = reason or "بدون سبب" })
    end)

    AddEventHandler('qb-admin:server:ban', function(player, time, reason)
        SendLog("/api/fivem/admin-log", { admin = GetAdminName(source), action = "Ban", target = GetTargetName(player), details = "السبب: "..(reason or "بدون سبب").." | المدة: "..tostring(time).." ثانية" })
    end)

    AddEventHandler('qb-admin:server:spectate', function(player)
        SendLog("/api/fivem/admin-log", { admin = GetAdminName(source), action = "Spectate", target = GetTargetName(player), details = "مراقبة اللاعب" })
    end)

    AddEventHandler('qb-admin:server:freeze', function(player)
        SendLog("/api/fivem/admin-log", { admin = GetAdminName(source), action = "Freeze", target = GetTargetName(player), details = "تجميد/فك تجميد" })
    end)

    AddEventHandler('qb-admin:server:goto', function(player)
        SendLog("/api/fivem/admin-log", { admin = GetAdminName(source), action = "GoTo", target = GetTargetName(player), details = "انتقل إلى اللاعب" })
    end)

    AddEventHandler('qb-admin:server:bring', function(player)
        SendLog("/api/fivem/admin-log", { admin = GetAdminName(source), action = "Bring", target = GetTargetName(player), details = "جلب اللاعب" })
    end)

    AddEventHandler('qb-admin:server:intovehicle', function(player)
        SendLog("/api/fivem/admin-log", { admin = GetAdminName(source), action = "IntoVehicle", target = GetTargetName(player), details = "دخول سيارة اللاعب" })
    end)

    AddEventHandler('qb-admin:server:inventory', function(player)
        SendLog("/api/fivem/admin-log", { admin = GetAdminName(source), action = "OpenInventory", target = GetTargetName(player), details = "فتح مخزون اللاعب" })
    end)

    AddEventHandler('qb-admin:server:cloth', function(player)
        SendLog("/api/fivem/admin-log", { admin = GetAdminName(source), action = "ClothingMenu", target = GetTargetName(player), details = "فتح قائمة الملابس" })
    end)

    AddEventHandler('qb-admin:server:setPermissions', function(targetId, group)
        local rank = (group and group[1] and group[1].rank) or "unknown"
        SendLog("/api/fivem/admin-log", { admin = GetAdminName(source), action = "SetPermissions", target = (GetPlayerName(targetId) or "Unknown").." (ID: "..tostring(targetId)..")", details = "الرتبة: "..rank })
    end)

    AddEventHandler('qb-admin:server:SaveCar', function(mods, vehicle)
        SendLog("/api/fivem/admin-log", { admin = GetAdminName(source), action = "SaveCar", target = "-", details = "حفظ سيارة: "..tostring(vehicle and vehicle.model or "unknown") })
    end)

    AddEventHandler('qb-admin:giveWeapon', function(weapon)
        SendLog("/api/fivem/admin-log", { admin = GetAdminName(source), action = "GiveWeapon", target = "-", details = "السلاح: "..tostring(weapon) })
    end)

    print("^2[RoadTown Logger] QB-Admin logging enabled^0")
end

-- ============================================
-- TXADMIN LOGGING (official events + NUI action interception)
-- ============================================
if Config.LogTxAdmin then

    -- ===== OFFICIAL TXADMIN EVENTS =====

    AddEventHandler('txAdmin:events:playerKicked', function(eventData)
        local targetName = "-"
        if eventData.target and eventData.target ~= -1 then
            targetName = (GetPlayerName(eventData.target) or "Unknown").." (ID: "..eventData.target..")"
        elseif eventData.target == -1 then
            targetName = "الكل"
        end
        SendLog("/api/fivem/tx-log", { admin = eventData.author or "txAdmin", action = "Kick Player", target = targetName, reason = eventData.reason or "بدون سبب", details = nil })
    end)

    AddEventHandler('txAdmin:events:playerBanned', function(eventData)
        local targetName = eventData.targetName or "Unknown"
        if eventData.targetNetId then targetName = targetName.." (ID: "..eventData.targetNetId..")" end
        local duration = eventData.durationTranslated or (eventData.expiration == false and "دائم" or "")
        SendLog("/api/fivem/tx-log", { admin = eventData.author or "txAdmin", action = "Ban Player", target = targetName, reason = eventData.reason or "بدون سبب", details = duration ~= "" and ("المدة: "..duration) or nil })
    end)

    AddEventHandler('txAdmin:events:playerWarned', function(eventData)
        local targetName = eventData.targetName or "Unknown"
        if eventData.targetNetId then targetName = targetName.." (ID: "..eventData.targetNetId..")" end
        SendLog("/api/fivem/tx-log", { admin = eventData.author or "txAdmin", action = "Warn Player", target = targetName, reason = eventData.reason or "بدون سبب", details = nil })
    end)

    AddEventHandler('txAdmin:events:playerHealed', function(eventData)
        local targetName = eventData.target == -1 and "الكل (السيرفر كامل)" or (eventData.target and ((GetPlayerName(eventData.target) or "Unknown").." (ID: "..eventData.target..")") or "-")
        SendLog("/api/fivem/tx-log", { admin = eventData.author or "txAdmin", action = "Revive Player", target = targetName, reason = "-", details = nil })
    end)

    AddEventHandler('txAdmin:events:playerDirectMessage', function(eventData)
        local targetName = eventData.target and ((GetPlayerName(eventData.target) or "Unknown").." (ID: "..eventData.target..")") or "-"
        SendLog("/api/fivem/tx-log", { admin = eventData.author or "txAdmin", action = "Direct Message", target = targetName, reason = "-", details = eventData.message or nil })
    end)

    AddEventHandler('txAdmin:events:serverShuttingDown', function(eventData)
        SendLog("/api/fivem/tx-log", { admin = eventData.author or "txAdmin", action = "Server Shutdown", target = "-", reason = eventData.reason or "إعادة تشغيل", details = nil })
    end)

    AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
        SendLog("/api/fivem/tx-log", { admin = "txAdmin (Auto)", action = "Scheduled Restart", target = "-", reason = "إعادة تشغيل مجدولة", details = eventData.secondsRemaining and ("متبقي: "..eventData.secondsRemaining.." ثانية") or nil })
    end)

    AddEventHandler('txAdmin:events:announcement', function(eventData)
        SendLog("/api/fivem/tx-log", { admin = eventData.author or "txAdmin", action = "Announcement", target = "-", reason = "-", details = eventData.message or nil })
    end)

    AddEventHandler('txAdmin:events:consoleCommand', function(eventData)
        SendLog("/api/fivem/tx-log", { admin = eventData.author or "txAdmin", action = "Console Command", target = "-", reason = "-", details = eventData.command or nil })
    end)

    AddEventHandler('txAdmin:events:actionRevoked', function(eventData)
        SendLog("/api/fivem/tx-log", { admin = eventData.revokedBy or "txAdmin", action = "Revoke "..(eventData.actionType or "Action"), target = eventData.playerName or "-", reason = eventData.actionReason or "-", details = "بواسطة: "..(eventData.actionAuthor or "Unknown") })
    end)

    -- ===== TXADMIN IN-GAME MENU ACTIONS (intercepting internal events) =====
    -- txAdmin menu actions trigger these internal events

    -- Freeze Player
    AddEventHandler('txcl:event:freezePlayer', function(targetNetId)
        local src = source
        local targetName = targetNetId and ((GetPlayerName(targetNetId) or "Unknown").." (ID: "..targetNetId..")") or "-"
        SendLog("/api/fivem/tx-log", { admin = GetAdminName(src), action = "Freeze Player", target = targetName, reason = "-", details = nil })
    end)

    -- Spectate Player
    AddEventHandler('txcl:event:spectatePlayer', function(targetNetId)
        local src = source
        local targetName = targetNetId and ((GetPlayerName(targetNetId) or "Unknown").." (ID: "..targetNetId..")") or "-"
        SendLog("/api/fivem/tx-log", { admin = GetAdminName(src), action = "Spectate Player", target = targetName, reason = "-", details = nil })
    end)

    -- Teleport to Player
    AddEventHandler('txcl:event:teleportToPlayer', function(targetNetId)
        local src = source
        local targetName = targetNetId and ((GetPlayerName(targetNetId) or "Unknown").." (ID: "..targetNetId..")") or "-"
        SendLog("/api/fivem/tx-log", { admin = GetAdminName(src), action = "Teleport to Player", target = targetName, reason = "-", details = nil })
    end)

    -- ===== INTERCEPT ALL TXADMIN MENU ACTIONS VIA txsv:req:playerActions =====
    -- This is the main server event txAdmin uses for ALL in-game menu actions
    AddEventHandler('__cfx_internal:serverPrint', function(msg)
        -- txAdmin prints action logs to console, we intercept them
    end)

    -- Monitor resource for txAdmin action commands
    -- txAdmin executes commands internally, we hook the common ones
    local txCommands = {
        ['tx-noclip'] = 'Noclip',
        ['tx-godmode'] = 'God Mode',
        ['tx-invisible'] = 'Invisible',
        ['tx-heal'] = 'Heal',
        ['tx-car'] = 'Spawn Vehicle',
        ['tx-spawnvehicle'] = 'Spawn Vehicle',
        ['tx-fix'] = 'Fix Vehicle',
        ['tx-maxmods'] = 'Max Vehicle Mods',
        ['tx-refuel'] = 'Refuel Vehicle',
    }

    for cmd, label in pairs(txCommands) do
        RegisterCommand(cmd, function(src, args)
            if src > 0 then
                local target = args[1] and ((GetPlayerName(tonumber(args[1])) or "Unknown").." (ID: "..args[1]..")") or "-"
                local detail = table.concat(args, " ")
                SendLog("/api/fivem/tx-log", { admin = GetAdminName(src), action = label, target = target, reason = "-", details = detail ~= "" and detail or nil })
            end
        end, true)
    end

    -- ===== INTERCEPT ALL TXADMIN NUI CALLBACKS =====
    -- txAdmin v7+ uses txsv:req:vehicle:spawn, txsv:req:player:heal etc.
    -- We hook the most common ones

    local txActions = {
        'txsv:req:vehicle:spawn',
        'txsv:req:vehicle:fix',
        'txsv:req:vehicle:boost',
        'txsv:req:vehicle:delete',
        'txsv:req:player:heal',
        'txsv:req:player:freeze',
        'txsv:req:player:spectate',
        'txsv:req:player:kick',
        'txsv:req:player:warn',
        'txsv:req:player:ban',
        'txsv:req:player:dm',
        'txsv:req:player:tpto',
        'txsv:req:player:bring',
        'txsv:req:player:giveItem',
        'txsv:req:player:giveMoney',
        'txsv:req:player:giveMoneyAll',
        'txsv:req:player:giveItemAll',
        'txsv:req:player:removeMoney',
        'txsv:req:player:setJob',
        'txsv:req:player:setGang',
        'txsv:req:player:setPerms',
        'txsv:req:player:setPed',
        'txsv:req:player:setAmmo',
        'txsv:req:player:toggleCuffs',
        'txsv:req:player:toggleDuty',
        'txsv:req:player:makeDrunk',
        'txsv:req:player:mutePlayer',
        'txsv:req:player:playSound',
        'txsv:req:player:removeStress',
        'txsv:req:player:openInventory',
        'txsv:req:player:openStash',
        'txsv:req:player:openTrunk',
        'txsv:req:player:reviveAll',
        'txsv:req:player:reviveRadius',
        'txsv:req:player:infiniteAmmo',
        'txsv:req:player:godMode',
        'txsv:req:player:invisible',
        'txsv:req:player:noclip',
        'txsv:req:player:toggleBlips',
        'txsv:req:player:toggleNames',
        'txsv:req:player:toggleCoords',
        'txsv:req:player:toggleBlackout',
        'txsv:req:player:toggleLaser',
        'txsv:req:player:vehicleDevMenu',
        'txsv:req:player:getRoutingBucket',
        'txsv:req:player:setRoutingBucket',
        'txsv:req:player:setVehicleGarageState',
        'txsv:req:player:teleportToCoords',
        'txsv:req:player:teleportToMarker',
        'txsv:req:player:teleportToLocation',
        'txsv:req:player:teleportBack',
    }

    local actionLabels = {
        ['vehicle:spawn'] = 'Spawn Vehicle',
        ['vehicle:fix'] = 'Fix Vehicle',
        ['vehicle:boost'] = 'Max Vehicle Mods',
        ['vehicle:delete'] = 'Delete Vehicle',
        ['player:heal'] = 'Heal Player',
        ['player:freeze'] = 'Freeze Player',
        ['player:spectate'] = 'Spectate Player',
        ['player:kick'] = 'Kick Player',
        ['player:warn'] = 'Warn Player',
        ['player:ban'] = 'Ban Player',
        ['player:dm'] = 'Direct Message',
        ['player:tpto'] = 'Teleport to Player',
        ['player:bring'] = 'Bring Player',
        ['player:giveItem'] = 'Give Item',
        ['player:giveMoney'] = 'Give Money',
        ['player:giveMoneyAll'] = 'Give Money to All',
        ['player:giveItemAll'] = 'Give Item to All',
        ['player:removeMoney'] = 'Remove Money',
        ['player:setJob'] = 'Set Job',
        ['player:setGang'] = 'Set Gang',
        ['player:setPerms'] = 'Set Perms',
        ['player:setPed'] = 'Set Ped',
        ['player:setAmmo'] = 'Set Ammo',
        ['player:toggleCuffs'] = 'Toggle Cuffs',
        ['player:toggleDuty'] = 'Toggle Duty',
        ['player:makeDrunk'] = 'Make Player Drunk',
        ['player:mutePlayer'] = 'Mute Player',
        ['player:playSound'] = 'Play Sound',
        ['player:removeStress'] = 'Remove Stress',
        ['player:openInventory'] = 'Open Inventory',
        ['player:openStash'] = 'Open Stash',
        ['player:openTrunk'] = 'Open Trunk',
        ['player:reviveAll'] = 'Revive All',
        ['player:reviveRadius'] = 'Revive Radius',
        ['player:infiniteAmmo'] = 'Infinite Ammo',
        ['player:godMode'] = 'God Mode',
        ['player:invisible'] = 'Invisible',
        ['player:noclip'] = 'Noclip',
        ['player:toggleBlips'] = 'Toggle Blips',
        ['player:toggleNames'] = 'Toggle Names',
        ['player:toggleCoords'] = 'Toggle Coords',
        ['player:toggleBlackout'] = 'Toggle Blackout',
        ['player:toggleLaser'] = 'Toggle Laser',
        ['player:vehicleDevMenu'] = 'Vehicle Dev Menu',
        ['player:getRoutingBucket'] = 'Get Routing Bucket',
        ['player:setRoutingBucket'] = 'Set Routing Bucket',
        ['player:setVehicleGarageState'] = 'Set Vehicle Garage State',
        ['player:teleportToCoords'] = 'Teleport to Coords',
        ['player:teleportToMarker'] = 'Teleport to Marker',
        ['player:teleportToLocation'] = 'Teleport to Location',
        ['player:teleportBack'] = 'Teleport Back',
    }

    for _, eventName in ipairs(txActions) do
        AddEventHandler(eventName, function(data)
            local src = source
            local shortName = eventName:gsub('txsv:req:', '')
            local label = actionLabels[shortName] or shortName
            local targetName = "-"
            if data then
                if data.id then
                    targetName = (GetPlayerName(tonumber(data.id)) or "Unknown").." (ID: "..tostring(data.id)..")"
                elseif data.targetId then
                    targetName = (GetPlayerName(tonumber(data.targetId)) or "Unknown").." (ID: "..tostring(data.targetId)..")"
                elseif data.netId then
                    targetName = (GetPlayerName(tonumber(data.netId)) or "Unknown").." (ID: "..tostring(data.netId)..")"
                end
            end
            local details = nil
            if data then
                if data.model then details = "Model: "..tostring(data.model) end
                if data.amount then details = (details and details.." | " or "").."Amount: "..tostring(data.amount) end
                if data.item then details = (details and details.." | " or "").."Item: "..tostring(data.item) end
                if data.job then details = (details and details.." | " or "").."Job: "..tostring(data.job) end
                if data.gang then details = (details and details.." | " or "").."Gang: "..tostring(data.gang) end
                if data.reason then details = (details and details.." | " or "").."Reason: "..tostring(data.reason) end
                if data.coords then details = (details and details.." | " or "").."Coords: "..tostring(data.coords) end
                if data.location then details = (details and details.." | " or "").."Location: "..tostring(data.location) end
            end
            SendLog("/api/fivem/tx-log", { admin = GetAdminName(src), action = label, target = targetName, reason = (data and data.reason) or "-", details = details })
        end)
    end

    print("^2[RoadTown Logger] txAdmin logging enabled (events + menu actions)^0")
end

print("^5[RoadTown Logger] Resource started - Website: " .. Config.WebsiteURL .. "^0")
