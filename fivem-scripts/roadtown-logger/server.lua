-- ============================================
-- Road Town RP - Admin & txAdmin Logger
-- يرسل سجلات استخدام الأدمن و txAdmin للموقع
-- متوافق مع qb-adminmenu
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
-- QB-ADMINMENU LOGGING (hooks into existing events)
-- ============================================
if Config.LogQBAdmin then

    -- Kill player
    AddEventHandler('qb-admin:server:kill', function(player)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "Kill",
            target = GetTargetName(player),
            details = "قتل اللاعب"
        })
    end)

    -- Revive player
    AddEventHandler('qb-admin:server:revive', function(player)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "Revive",
            target = GetTargetName(player),
            details = "إحياء اللاعب"
        })
    end)

    -- Kick player
    AddEventHandler('qb-admin:server:kick', function(player, reason)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "Kick",
            target = GetTargetName(player),
            details = reason or "بدون سبب"
        })
    end)

    -- Ban player
    AddEventHandler('qb-admin:server:ban', function(player, time, reason)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "Ban",
            target = GetTargetName(player),
            details = "السبب: " .. (reason or "بدون سبب") .. " | المدة: " .. tostring(time) .. " ثانية"
        })
    end)

    -- Spectate player
    AddEventHandler('qb-admin:server:spectate', function(player)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "Spectate",
            target = GetTargetName(player),
            details = "مراقبة اللاعب"
        })
    end)

    -- Freeze player
    AddEventHandler('qb-admin:server:freeze', function(player)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "Freeze",
            target = GetTargetName(player),
            details = "تجميد/فك تجميد اللاعب"
        })
    end)

    -- GoTo player (teleport to)
    AddEventHandler('qb-admin:server:goto', function(player)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "GoTo",
            target = GetTargetName(player),
            details = "انتقل إلى اللاعب"
        })
    end)

    -- Bring player
    AddEventHandler('qb-admin:server:bring', function(player)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "Bring",
            target = GetTargetName(player),
            details = "جلب اللاعب"
        })
    end)

    -- Sit in vehicle
    AddEventHandler('qb-admin:server:intovehicle', function(player)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "IntoVehicle",
            target = GetTargetName(player),
            details = "دخول سيارة اللاعب"
        })
    end)

    -- Open inventory
    AddEventHandler('qb-admin:server:inventory', function(player)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "OpenInventory",
            target = GetTargetName(player),
            details = "فتح مخزون اللاعب"
        })
    end)

    -- Clothing menu
    AddEventHandler('qb-admin:server:cloth', function(player)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "ClothingMenu",
            target = GetTargetName(player),
            details = "فتح قائمة الملابس"
        })
    end)

    -- Set permissions
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

    -- Save car (admincar command)
    AddEventHandler('qb-admin:server:SaveCar', function(mods, vehicle)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "SaveCar",
            target = "-",
            details = "حفظ سيارة: " .. tostring(vehicle and vehicle.model or "unknown")
        })
    end)

    -- Give weapon
    AddEventHandler('qb-admin:giveWeapon', function(weapon)
        local src = source
        SendLog("/api/fivem/admin-log", {
            admin = GetPlayerName(src) .. " (ID: " .. src .. ")",
            action = "GiveWeapon",
            target = "-",
            details = "السلاح: " .. tostring(weapon)
        })
    end)

    -- Open admin menu (admin2 command)
    AddEventHandler('qb-admin:client:openMenu', function()
        -- This is client event, we log from command instead
    end)

    print("^2[RoadTown Logger] QB-Admin logging enabled^0")
end

-- ============================================
-- TXADMIN LOGGING
-- ============================================
if Config.LogTxAdmin then

    AddEventHandler('txAdmin:events:adminAction', function(eventData)
        SendLog("/api/fivem/tx-log", {
            admin = eventData.author or "txAdmin",
            action = eventData.action or "unknown",
            target = eventData.target or "-",
            reason = eventData.reason or "-",
            details = eventData.message or nil
        })
    end)

    AddEventHandler('txAdmin:events:playerKicked', function(eventData)
        SendLog("/api/fivem/tx-log", {
            admin = eventData.author or "txAdmin",
            action = "Kick",
            target = eventData.target or "Unknown",
            reason = eventData.reason or "بدون سبب",
            details = nil
        })
    end)

    AddEventHandler('txAdmin:events:playerBanned', function(eventData)
        SendLog("/api/fivem/tx-log", {
            admin = eventData.author or "txAdmin",
            action = "Ban",
            target = eventData.target or "Unknown",
            reason = eventData.reason or "بدون سبب",
            details = eventData.duration and ("المدة: " .. eventData.duration) or nil
        })
    end)

    AddEventHandler('txAdmin:events:playerWarned', function(eventData)
        SendLog("/api/fivem/tx-log", {
            admin = eventData.author or "txAdmin",
            action = "Warn",
            target = eventData.target or "Unknown",
            reason = eventData.reason or "بدون سبب",
            details = nil
        })
    end)

    AddEventHandler('txAdmin:events:serverShuttingDown', function(eventData)
        SendLog("/api/fivem/tx-log", {
            admin = eventData.author or "txAdmin",
            action = "Server Shutdown",
            target = "-",
            reason = eventData.reason or "إعادة تشغيل",
            details = nil
        })
    end)

    AddEventHandler('txAdmin:events:playerDirectMessage', function(eventData)
        SendLog("/api/fivem/tx-log", {
            admin = eventData.author or "txAdmin",
            action = "DM",
            target = eventData.target or "Unknown",
            reason = "-",
            details = eventData.message or nil
        })
    end)

    print("^2[RoadTown Logger] txAdmin logging enabled^0")
end

print("^5[RoadTown Logger] Resource started - Website: " .. Config.WebsiteURL .. "^0")
