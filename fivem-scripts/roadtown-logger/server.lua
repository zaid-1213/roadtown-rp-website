-- ============================================
-- Road Town RP - Admin & txAdmin Logger
-- يرسل سجلات استخدام الأدمن و txAdmin للموقع
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

-- ============================================
-- QB-ADMINMENU LOGGING (hooks into qb-adminmenu events)
-- ============================================
if Config.LogQBAdmin then

    AddEventHandler('qb-admin:server:kill', function(player)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "Kill",
            target = GetTargetName(player),
            details = "قتل اللاعب"
        })
    end)

    AddEventHandler('qb-admin:server:revive', function(player)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "Revive",
            target = GetTargetName(player),
            details = "إحياء اللاعب"
        })
    end)

    AddEventHandler('qb-admin:server:kick', function(player, reason)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "Kick",
            target = GetTargetName(player),
            details = reason or "بدون سبب"
        })
    end)

    AddEventHandler('qb-admin:server:ban', function(player, time, reason)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "Ban",
            target = GetTargetName(player),
            details = "السبب: " .. (reason or "بدون سبب") .. " | المدة: " .. tostring(time) .. " ثانية"
        })
    end)

    AddEventHandler('qb-admin:server:spectate', function(player)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "Spectate",
            target = GetTargetName(player),
            details = "مراقبة اللاعب"
        })
    end)

    AddEventHandler('qb-admin:server:freeze', function(player)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "Freeze",
            target = GetTargetName(player),
            details = "تجميد/فك تجميد اللاعب"
        })
    end)

    AddEventHandler('qb-admin:server:goto', function(player)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "GoTo",
            target = GetTargetName(player),
            details = "انتقل إلى اللاعب"
        })
    end)

    AddEventHandler('qb-admin:server:bring', function(player)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "Bring",
            target = GetTargetName(player),
            details = "جلب اللاعب"
        })
    end)

    AddEventHandler('qb-admin:server:intovehicle', function(player)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "IntoVehicle",
            target = GetTargetName(player),
            details = "دخول سيارة اللاعب"
        })
    end)

    AddEventHandler('qb-admin:server:inventory', function(player)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "OpenInventory",
            target = GetTargetName(player),
            details = "فتح مخزون اللاعب"
        })
    end)

    AddEventHandler('qb-admin:server:cloth', function(player)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "ClothingMenu",
            target = GetTargetName(player),
            details = "فتح قائمة الملابس"
        })
    end)

    AddEventHandler('qb-admin:server:setPermissions', function(targetId, group)
        local src = source
        local rank = (group and group[1] and group[1].rank) or "unknown"
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "SetPermissions",
            target = (GetPlayerName(targetId) or "Unknown") .. " (ID: " .. tostring(targetId) .. ")",
            details = "الرتبة: " .. rank
        })
    end)

    AddEventHandler('qb-admin:server:SaveCar', function(mods, vehicle)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "SaveCar",
            target = "-",
            details = "حفظ سيارة: " .. tostring(vehicle and vehicle.model or "unknown")
        })
    end)

    AddEventHandler('qb-admin:giveWeapon', function(weapon)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "GiveWeapon",
            target = "-",
            details = "السلاح: " .. tostring(weapon)
        })
    end)

    print("^2[RoadTown Logger] QB-Admin logging enabled^0")
end

-- ============================================
-- TXADMIN LOGGING (official txAdmin events)
-- Events: playerKicked, playerBanned, playerWarned,
-- playerHealed, playerDirectMessage, serverShuttingDown,
-- scheduledRestart, announcement, consoleCommand, actionRevoked
-- ============================================
if Config.LogTxAdmin then

    -- Player Kicked
    AddEventHandler('txAdmin:events:playerKicked', function(eventData)
        local targetName = "-"
        if eventData.target and eventData.target ~= -1 then
            targetName = (GetPlayerName(eventData.target) or "Unknown") .. " (ID: " .. eventData.target .. ")"
        elseif eventData.target == -1 then
            targetName = "الكل"
        end
        SendLog("/api/fivem/tx-log", {
            admin = eventData.author or "txAdmin",
            action = "Kick",
            target = targetName,
            reason = eventData.reason or "بدون سبب",
            details = nil
        })
    end)

    -- Player Banned
    AddEventHandler('txAdmin:events:playerBanned', function(eventData)
        local targetName = eventData.targetName or "Unknown"
        if eventData.targetNetId then
            targetName = targetName .. " (ID: " .. eventData.targetNetId .. ")"
        end
        local duration = ""
        if eventData.durationTranslated then
            duration = "المدة: " .. eventData.durationTranslated
        elseif eventData.expiration == false then
            duration = "دائم"
        end
        SendLog("/api/fivem/tx-log", {
            admin = eventData.author or "txAdmin",
            action = "Ban",
            target = targetName,
            reason = eventData.reason or "بدون سبب",
            details = duration ~= "" and duration or nil
        })
    end)

    -- Player Warned
    AddEventHandler('txAdmin:events:playerWarned', function(eventData)
        local targetName = eventData.targetName or "Unknown"
        if eventData.targetNetId then
            targetName = targetName .. " (ID: " .. eventData.targetNetId .. ")"
        end
        SendLog("/api/fivem/tx-log", {
            admin = eventData.author or "txAdmin",
            action = "Warn",
            target = targetName,
            reason = eventData.reason or "بدون سبب",
            details = nil
        })
    end)

    -- Player Healed
    AddEventHandler('txAdmin:events:playerHealed', function(eventData)
        local targetName = "-"
        if eventData.target == -1 then
            targetName = "الكل (السيرفر كامل)"
        elseif eventData.target then
            targetName = (GetPlayerName(eventData.target) or "Unknown") .. " (ID: " .. eventData.target .. ")"
        end
        SendLog("/api/fivem/tx-log", {
            admin = eventData.author or "txAdmin",
            action = "Heal",
            target = targetName,
            reason = "-",
            details = nil
        })
    end)

    -- Player Direct Message
    AddEventHandler('txAdmin:events:playerDirectMessage', function(eventData)
        local targetName = "-"
        if eventData.target then
            targetName = (GetPlayerName(eventData.target) or "Unknown") .. " (ID: " .. eventData.target .. ")"
        end
        SendLog("/api/fivem/tx-log", {
            admin = eventData.author or "txAdmin",
            action = "DM",
            target = targetName,
            reason = "-",
            details = eventData.message or nil
        })
    end)

    -- Server Shutting Down
    AddEventHandler('txAdmin:events:serverShuttingDown', function(eventData)
        SendLog("/api/fivem/tx-log", {
            admin = eventData.author or "txAdmin",
            action = "Server Shutdown",
            target = "-",
            reason = eventData.reason or "إعادة تشغيل",
            details = nil
        })
    end)

    -- Scheduled Restart
    AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
        SendLog("/api/fivem/tx-log", {
            admin = "txAdmin (Auto)",
            action = "Scheduled Restart",
            target = "-",
            reason = "إعادة تشغيل مجدولة",
            details = eventData.secondsRemaining and ("متبقي: " .. eventData.secondsRemaining .. " ثانية") or nil
        })
    end)

    -- Announcement
    AddEventHandler('txAdmin:events:announcement', function(eventData)
        SendLog("/api/fivem/tx-log", {
            admin = eventData.author or "txAdmin",
            action = "Announcement",
            target = "-",
            reason = "-",
            details = eventData.message or nil
        })
    end)

    -- Console Command
    AddEventHandler('txAdmin:events:consoleCommand', function(eventData)
        SendLog("/api/fivem/tx-log", {
            admin = eventData.author or "txAdmin",
            action = "Console Command",
            target = "-",
            reason = "-",
            details = eventData.command or nil
        })
    end)

    -- Action Revoked (unban/unwarn)
    AddEventHandler('txAdmin:events:actionRevoked', function(eventData)
        SendLog("/api/fivem/tx-log", {
            admin = eventData.revokedBy or "txAdmin",
            action = "Revoke " .. (eventData.actionType or "Action"),
            target = eventData.playerName or "-",
            reason = eventData.actionReason or "-",
            details = "الإجراء الأصلي بواسطة: " .. (eventData.actionAuthor or "Unknown")
        })
    end)

    print("^2[RoadTown Logger] txAdmin logging enabled^0")
end

print("^5[RoadTown Logger] Resource started - Website: " .. Config.WebsiteURL .. "^0")
