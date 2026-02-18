-- ============================================
-- Road Town RP - Admin & txAdmin Logger
-- يرسل سجلات استخدام الأدمن و txAdmin للموقع
-- ============================================

-- دالة إرسال السجل للموقع
local function SendLog(endpoint, data)
    data.secret = Config.Secret
    PerformHttpRequest(Config.WebsiteURL .. endpoint, function(errorCode, resultData, resultHeaders)
        if errorCode ~= 200 then
            print("^1[RoadTown Logger] Failed to send log: " .. tostring(errorCode) .. "^0")
        end
    end, "POST", json.encode(data), { ["Content-Type"] = "application/json" })
end

-- ============================================
-- QB-ADMIN COMMANDS LOGGING
-- ============================================
if Config.LogQBAdmin then

    -- /ban
    RegisterNetEvent('qb-admin:server:ban', function(targetId, reason)
        local src = source
        local adminName = GetPlayerName(src) or "Unknown"
        local targetName = targetId and GetPlayerName(tonumber(targetId)) or "Unknown"
        SendLog("/api/fivem/admin-log", {
            admin = adminName .. " (ID: " .. src .. ")",
            action = "Ban",
            target = targetName .. " (ID: " .. tostring(targetId) .. ")",
            details = reason or "بدون سبب"
        })
    end)

    -- /kick
    RegisterNetEvent('qb-admin:server:kick', function(targetId, reason)
        local src = source
        local adminName = GetPlayerName(src) or "Unknown"
        local targetName = targetId and GetPlayerName(tonumber(targetId)) or "Unknown"
        SendLog("/api/fivem/admin-log", {
            admin = adminName .. " (ID: " .. src .. ")",
            action = "Kick",
            target = targetName .. " (ID: " .. tostring(targetId) .. ")",
            details = reason or "بدون سبب"
        })
    end)

    -- /warn
    RegisterNetEvent('qb-admin:server:warn', function(targetId, reason)
        local src = source
        local adminName = GetPlayerName(src) or "Unknown"
        local targetName = targetId and GetPlayerName(tonumber(targetId)) or "Unknown"
        SendLog("/api/fivem/admin-log", {
            admin = adminName .. " (ID: " .. src .. ")",
            action = "Warn",
            target = targetName .. " (ID: " .. tostring(targetId) .. ")",
            details = reason or "بدون سبب"
        })
    end)

    -- /tp (teleport)
    RegisterNetEvent('qb-admin:server:teleport', function(targetId)
        local src = source
        local adminName = GetPlayerName(src) or "Unknown"
        local targetName = targetId and GetPlayerName(tonumber(targetId)) or "Unknown"
        SendLog("/api/fivem/admin-log", {
            admin = adminName .. " (ID: " .. src .. ")",
            action = "Teleport",
            target = targetName .. " (ID: " .. tostring(targetId) .. ")",
            details = "انتقل إلى اللاعب"
        })
    end)

    -- /bring
    RegisterNetEvent('qb-admin:server:bring', function(targetId)
        local src = source
        local adminName = GetPlayerName(src) or "Unknown"
        local targetName = targetId and GetPlayerName(tonumber(targetId)) or "Unknown"
        SendLog("/api/fivem/admin-log", {
            admin = adminName .. " (ID: " .. src .. ")",
            action = "Bring",
            target = targetName .. " (ID: " .. tostring(targetId) .. ")",
            details = "جلب اللاعب"
        })
    end)

    -- /freeze
    RegisterNetEvent('qb-admin:server:freeze', function(targetId)
        local src = source
        local adminName = GetPlayerName(src) or "Unknown"
        local targetName = targetId and GetPlayerName(tonumber(targetId)) or "Unknown"
        SendLog("/api/fivem/admin-log", {
            admin = adminName .. " (ID: " .. src .. ")",
            action = "Freeze",
            target = targetName .. " (ID: " .. tostring(targetId) .. ")",
            details = "تجميد اللاعب"
        })
    end)

    -- /spectate
    RegisterNetEvent('qb-admin:server:spectate', function(targetId)
        local src = source
        local adminName = GetPlayerName(src) or "Unknown"
        local targetName = targetId and GetPlayerName(tonumber(targetId)) or "Unknown"
        SendLog("/api/fivem/admin-log", {
            admin = adminName .. " (ID: " .. src .. ")",
            action = "Spectate",
            target = targetName .. " (ID: " .. tostring(targetId) .. ")",
            details = "مراقبة اللاعب"
        })
    end)

    -- /revive
    RegisterNetEvent('qb-admin:server:revive', function(targetId)
        local src = source
        local adminName = GetPlayerName(src) or "Unknown"
        local targetName = targetId and GetPlayerName(tonumber(targetId)) or "Unknown"
        SendLog("/api/fivem/admin-log", {
            admin = adminName .. " (ID: " .. src .. ")",
            action = "Revive",
            target = targetName and targetName .. " (ID: " .. tostring(targetId) .. ")" or "نفسه",
            details = "إحياء اللاعب"
        })
    end)

    -- /setjob
    RegisterNetEvent('qb-admin:server:setjob', function(targetId, job, grade)
        local src = source
        local adminName = GetPlayerName(src) or "Unknown"
        local targetName = targetId and GetPlayerName(tonumber(targetId)) or "Unknown"
        SendLog("/api/fivem/admin-log", {
            admin = adminName .. " (ID: " .. src .. ")",
            action = "SetJob",
            target = targetName .. " (ID: " .. tostring(targetId) .. ")",
            details = "الوظيفة: " .. tostring(job) .. " | الدرجة: " .. tostring(grade)
        })
    end)

    -- /givemoney
    RegisterNetEvent('qb-admin:server:givemoney', function(targetId, moneyType, amount)
        local src = source
        local adminName = GetPlayerName(src) or "Unknown"
        local targetName = targetId and GetPlayerName(tonumber(targetId)) or "Unknown"
        SendLog("/api/fivem/admin-log", {
            admin = adminName .. " (ID: " .. src .. ")",
            action = "GiveMoney",
            target = targetName .. " (ID: " .. tostring(targetId) .. ")",
            details = "النوع: " .. tostring(moneyType) .. " | المبلغ: $" .. tostring(amount)
        })
    end)

    -- /noclip
    RegisterNetEvent('qb-admin:server:noclip', function()
        local src = source
        local adminName = GetPlayerName(src) or "Unknown"
        SendLog("/api/fivem/admin-log", {
            admin = adminName .. " (ID: " .. src .. ")",
            action = "NoClip",
            target = "-",
            details = "تفعيل/إيقاف NoClip"
        })
    end)

    -- /god (godmode)
    RegisterNetEvent('qb-admin:server:godmode', function()
        local src = source
        local adminName = GetPlayerName(src) or "Unknown"
        SendLog("/api/fivem/admin-log", {
            admin = adminName .. " (ID: " .. src .. ")",
            action = "GodMode",
            target = "-",
            details = "تفعيل/إيقاف وضع الخلود"
        })
    end)

    -- /giveitem
    RegisterNetEvent('qb-admin:server:giveitem', function(targetId, item, amount)
        local src = source
        local adminName = GetPlayerName(src) or "Unknown"
        local targetName = targetId and GetPlayerName(tonumber(targetId)) or "Unknown"
        SendLog("/api/fivem/admin-log", {
            admin = adminName .. " (ID: " .. src .. ")",
            action = "GiveItem",
            target = targetName .. " (ID: " .. tostring(targetId) .. ")",
            details = "العنصر: " .. tostring(item) .. " | الكمية: " .. tostring(amount)
        })
    end)

    -- /car (spawn vehicle)
    RegisterNetEvent('qb-admin:server:spawnvehicle', function(vehicle)
        local src = source
        local adminName = GetPlayerName(src) or "Unknown"
        SendLog("/api/fivem/admin-log", {
            admin = adminName .. " (ID: " .. src .. ")",
            action = "SpawnVehicle",
            target = "-",
            details = "السيارة: " .. tostring(vehicle)
        })
    end)

    print("^2[RoadTown Logger] QB-Admin logging enabled^0")
end

-- ============================================
-- TXADMIN LOGGING
-- ============================================
if Config.LogTxAdmin then

    AddEventHandler('txAdmin:events:adminAction', function(eventData)
        local action = eventData.action or "unknown"
        local adminName = eventData.author or "txAdmin"
        local target = eventData.target or "-"
        local reason = eventData.reason or "-"

        SendLog("/api/fivem/tx-log", {
            admin = adminName,
            action = action,
            target = target,
            reason = reason,
            details = eventData.message or nil
        })
    end)

    -- txAdmin: Player Kicked
    AddEventHandler('txAdmin:events:playerKicked', function(eventData)
        SendLog("/api/fivem/tx-log", {
            admin = eventData.author or "txAdmin",
            action = "Kick",
            target = eventData.target or "Unknown",
            reason = eventData.reason or "بدون سبب",
            details = nil
        })
    end)

    -- txAdmin: Player Banned
    AddEventHandler('txAdmin:events:playerBanned', function(eventData)
        SendLog("/api/fivem/tx-log", {
            admin = eventData.author or "txAdmin",
            action = "Ban",
            target = eventData.target or "Unknown",
            reason = eventData.reason or "بدون سبب",
            details = eventData.duration and ("المدة: " .. eventData.duration) or nil
        })
    end)

    -- txAdmin: Player Warned
    AddEventHandler('txAdmin:events:playerWarned', function(eventData)
        SendLog("/api/fivem/tx-log", {
            admin = eventData.author or "txAdmin",
            action = "Warn",
            target = eventData.target or "Unknown",
            reason = eventData.reason or "بدون سبب",
            details = nil
        })
    end)

    -- txAdmin: Server Restart/Stop
    AddEventHandler('txAdmin:events:serverShuttingDown', function(eventData)
        SendLog("/api/fivem/tx-log", {
            admin = eventData.author or "txAdmin",
            action = "Server Shutdown",
            target = "-",
            reason = eventData.reason or "إعادة تشغيل",
            details = nil
        })
    end)

    -- txAdmin: Direct Message
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
