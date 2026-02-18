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
-- TXADMIN LOGGING
-- Uses REAL txAdmin internal events from source code
-- ============================================
if Config.LogTxAdmin then

    -- ===== MASTER HOOK: txsv:logger:menuEvent =====
    -- ALL txAdmin in-game menu actions pass through this event
    -- This captures: Noclip, God Mode, Spawn Vehicle, Freeze, Spectate,
    -- Vehicle Repair/Boost/Delete, Drunk, Fire, Wild Attack, etc.
    local menuActionLabels = {
        ['playerModeChanged'] = 'Player Mode',  -- noclip/godmode/superjump/none
        ['spawnVehicle'] = 'Spawn Vehicle',
        ['vehicleRepair'] = 'Fix Vehicle',
        ['vehicleBoost'] = 'Max Vehicle Mods',
        ['deleteVehicle'] = 'Delete Vehicle',
        ['freezePlayer'] = 'Freeze Player',
        ['spectatePlayer'] = 'Spectate Player',
        ['drunkEffect'] = 'Make Player Drunk',
        ['setOnFire'] = 'Set On Fire',
        ['wildAttack'] = 'Wild Attack',
        ['healPlayer'] = 'Heal Player',
        ['healAll'] = 'Heal All',
        ['tpToPlayer'] = 'Teleport to Player',
        ['tpToCoords'] = 'Teleport to Coords',
        ['tpToWaypoint'] = 'Teleport to Marker',
        ['tpBack'] = 'Teleport Back',
        ['summonPlayer'] = 'Bring Player',
        ['clearArea'] = 'Clear Area',
        ['announceMessage'] = 'Announcement',
    }

    local modeLabels = {
        ['noclip'] = 'Noclip',
        ['godmode'] = 'God Mode',
        ['superjump'] = 'Super Jump',
        ['none'] = 'Normal Mode',
    }

    AddEventHandler('txsv:logger:menuEvent', function(src, action, allowed, ...)
        local args = {...}
        local label = menuActionLabels[action] or action
        local targetName = "-"
        local details = nil

        -- Handle player mode changes (noclip/godmode)
        if action == 'playerModeChanged' then
            local mode = args[1] or "unknown"
            label = modeLabels[mode] or mode
            details = "الوضع: " .. mode
        -- Handle spawn vehicle
        elseif action == 'spawnVehicle' then
            local model = args[1] or "unknown"
            details = "الموديل: " .. tostring(model)
        -- Handle actions with target player
        elseif action == 'freezePlayer' or action == 'spectatePlayer' or action == 'drunkEffect'
            or action == 'setOnFire' or action == 'wildAttack' or action == 'tpToPlayer'
            or action == 'summonPlayer' or action == 'healPlayer' then
            local targetId = args[1]
            if targetId then
                targetName = (GetPlayerName(tonumber(targetId)) or "Unknown") .. " (ID: " .. tostring(targetId) .. ")"
            end
        end

        -- Only log allowed actions (or log denied too if you want)
        if allowed then
            SendLog("/api/fivem/tx-log", {
                admin = GetAdminName(src),
                action = label,
                target = targetName,
                reason = "-",
                details = details
            })
        end
    end)

    -- ===== REAL txAdmin server events (txsv:req:*) =====
    -- These are the actual RegisterNetEvent names from txAdmin source code

    -- Player Mode (Noclip / God Mode / Super Jump)
    AddEventHandler('txsv:req:changePlayerMode', function(mode, nearbyPlayers)
        local src = source
        local label = modeLabels[mode] or mode or "Unknown Mode"
        SendLog("/api/fivem/tx-log", {
            admin = GetAdminName(src),
            action = label,
            target = "-",
            reason = "-",
            details = "الوضع: " .. tostring(mode)
        })
    end)

    -- Spawn Vehicle (FiveM)
    AddEventHandler('txsv:req:vehicle:spawn:fivem', function(model, modelType)
        local src = source
        SendLog("/api/fivem/tx-log", {
            admin = GetAdminName(src),
            action = "Spawn Vehicle",
            target = "-",
            reason = "-",
            details = "الموديل: " .. tostring(model) .. " | النوع: " .. tostring(modelType)
        })
    end)

    -- Fix Vehicle
    AddEventHandler('txsv:req:vehicle:fix', function()
        SendLog("/api/fivem/tx-log", { admin = GetAdminName(source), action = "Fix Vehicle", target = "-", reason = "-", details = nil })
    end)

    -- Boost Vehicle (Max Mods)
    AddEventHandler('txsv:req:vehicle:boost', function()
        SendLog("/api/fivem/tx-log", { admin = GetAdminName(source), action = "Max Vehicle Mods", target = "-", reason = "-", details = nil })
    end)

    -- Delete Vehicle
    AddEventHandler('txsv:req:vehicle:delete', function(vehNetId)
        SendLog("/api/fivem/tx-log", { admin = GetAdminName(source), action = "Delete Vehicle", target = "-", reason = "-", details = "NetID: " .. tostring(vehNetId) })
    end)

    -- Freeze Player
    AddEventHandler('txsv:req:freezePlayer', function(targetId)
        local targetName = targetId and ((GetPlayerName(tonumber(targetId)) or "Unknown") .. " (ID: " .. tostring(targetId) .. ")") or "-"
        SendLog("/api/fivem/tx-log", { admin = GetAdminName(source), action = "Freeze Player", target = targetName, reason = "-", details = nil })
    end)

    -- Spectate Player
    AddEventHandler('txsv:req:spectate:start', function(targetId)
        local targetName = targetId and ((GetPlayerName(tonumber(targetId)) or "Unknown") .. " (ID: " .. tostring(targetId) .. ")") or "-"
        SendLog("/api/fivem/tx-log", { admin = GetAdminName(source), action = "Spectate Player", target = targetName, reason = "-", details = nil })
    end)

    -- Troll: Make Drunk
    AddEventHandler('txsv:req:troll:setDrunk', function(id)
        local targetName = id and ((GetPlayerName(tonumber(id)) or "Unknown") .. " (ID: " .. tostring(id) .. ")") or "-"
        SendLog("/api/fivem/tx-log", { admin = GetAdminName(source), action = "Make Player Drunk", target = targetName, reason = "-", details = nil })
    end)

    -- Troll: Set On Fire
    AddEventHandler('txsv:req:troll:setOnFire', function(id)
        local targetName = id and ((GetPlayerName(tonumber(id)) or "Unknown") .. " (ID: " .. tostring(id) .. ")") or "-"
        SendLog("/api/fivem/tx-log", { admin = GetAdminName(source), action = "Set On Fire", target = targetName, reason = "-", details = nil })
    end)

    -- Troll: Wild Attack
    AddEventHandler('txsv:req:troll:wildAttack', function(id)
        local targetName = id and ((GetPlayerName(tonumber(id)) or "Unknown") .. " (ID: " .. tostring(id) .. ")") or "-"
        SendLog("/api/fivem/tx-log", { admin = GetAdminName(source), action = "Wild Attack", target = targetName, reason = "-", details = nil })
    end)

    -- ===== OFFICIAL TXADMIN BROADCAST EVENTS =====

    AddEventHandler('txAdmin:events:playerKicked', function(eventData)
        local targetName = "-"
        if eventData.target and eventData.target ~= -1 then
            targetName = (GetPlayerName(eventData.target) or "Unknown") .. " (ID: " .. eventData.target .. ")"
        elseif eventData.target == -1 then
            targetName = "الكل"
        end
        SendLog("/api/fivem/tx-log", { admin = eventData.author or "txAdmin", action = "Kick Player", target = targetName, reason = eventData.reason or "بدون سبب", details = nil })
    end)

    AddEventHandler('txAdmin:events:playerBanned', function(eventData)
        local targetName = eventData.targetName or "Unknown"
        if eventData.targetNetId then targetName = targetName .. " (ID: " .. eventData.targetNetId .. ")" end
        local duration = eventData.durationTranslated or (eventData.expiration == false and "دائم" or "")
        SendLog("/api/fivem/tx-log", { admin = eventData.author or "txAdmin", action = "Ban Player", target = targetName, reason = eventData.reason or "بدون سبب", details = duration ~= "" and ("المدة: " .. duration) or nil })
    end)

    AddEventHandler('txAdmin:events:playerWarned', function(eventData)
        local targetName = eventData.targetName or "Unknown"
        if eventData.targetNetId then targetName = targetName .. " (ID: " .. eventData.targetNetId .. ")" end
        SendLog("/api/fivem/tx-log", { admin = eventData.author or "txAdmin", action = "Warn Player", target = targetName, reason = eventData.reason or "بدون سبب", details = nil })
    end)

    AddEventHandler('txAdmin:events:playerHealed', function(eventData)
        local targetName = eventData.target == -1 and "الكل (السيرفر كامل)" or (eventData.target and ((GetPlayerName(eventData.target) or "Unknown") .. " (ID: " .. eventData.target .. ")") or "-")
        SendLog("/api/fivem/tx-log", { admin = eventData.author or "txAdmin", action = "Heal/Revive", target = targetName, reason = "-", details = nil })
    end)

    AddEventHandler('txAdmin:events:playerDirectMessage', function(eventData)
        local targetName = eventData.target and ((GetPlayerName(eventData.target) or "Unknown") .. " (ID: " .. eventData.target .. ")") or "-"
        SendLog("/api/fivem/tx-log", { admin = eventData.author or "txAdmin", action = "Direct Message", target = targetName, reason = "-", details = eventData.message or nil })
    end)

    AddEventHandler('txAdmin:events:serverShuttingDown', function(eventData)
        SendLog("/api/fivem/tx-log", { admin = eventData.author or "txAdmin", action = "Server Shutdown", target = "-", reason = eventData.reason or "إعادة تشغيل", details = nil })
    end)

    AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
        SendLog("/api/fivem/tx-log", { admin = "txAdmin (Auto)", action = "Scheduled Restart", target = "-", reason = "إعادة تشغيل مجدولة", details = eventData.secondsRemaining and ("متبقي: " .. eventData.secondsRemaining .. " ثانية") or nil })
    end)

    AddEventHandler('txAdmin:events:announcement', function(eventData)
        SendLog("/api/fivem/tx-log", { admin = eventData.author or "txAdmin", action = "Announcement", target = "-", reason = "-", details = eventData.message or nil })
    end)

    AddEventHandler('txAdmin:events:consoleCommand', function(eventData)
        SendLog("/api/fivem/tx-log", { admin = eventData.author or "txAdmin", action = "Console Command", target = "-", reason = "-", details = eventData.command or nil })
    end)

    AddEventHandler('txAdmin:events:actionRevoked', function(eventData)
        SendLog("/api/fivem/tx-log", { admin = eventData.revokedBy or "txAdmin", action = "Revoke " .. (eventData.actionType or "Action"), target = eventData.playerName or "-", reason = eventData.actionReason or "-", details = "بواسطة: " .. (eventData.actionAuthor or "Unknown") })
    end)

    print("^2[RoadTown Logger] txAdmin logging enabled (menu + broadcast events)^0")
end

print("^5[RoadTown Logger] Resource started - Website: " .. Config.WebsiteURL .. "^0")
