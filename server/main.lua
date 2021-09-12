local ESX
local whitelisted = {}

local function whitelist(identifier, cb)
    if whitelisted[identifier] then
        return
    end
    MySQL.Async.insert("INSERT INTO whitelist (identifier) VALUES(@identifier)", {
        ["identifier"] = identifier
    }, function()
        whitelisted[identifier] = true
        if cb ~= nil then cb() end
    end)
end

local function unwhitelist(identifier, cb)
    if not whitelisted[identifier] then
        return
    end
    MySQL.Async.insert("DELETE FROM whitelist WHERE identifier = @identifier", {
        ["identifier"] = identifier
    }, function()
        whitelisted[identifier] = nil
        if cb ~= nil then cb() end
    end)
end

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local player = source
    local identifiers = GetPlayerIdentifiers(player)
    deferrals.defer()
    Wait(0)
    deferrals.update("🚀 • Nous vérifions votre steamID")
    Wait(Config.Wait.steamId)

    local steamID
    for _, v in pairs(identifiers) do
        if string.find(v, "steam") then
            steamID = v
            break
        end
    end
    if not steamID then
        deferrals.done("Nous n'avons pas trouvé votre steamID, veuillez vérifier que steam est lancé")
    end
    deferrals.update("💡 • Nous vérifions votre présence dans la whitelist...")
    Wait(Config.Wait.whitelist)
    if not whitelisted[steamID] then
        deferrals.done("⛔ • Vous n'êtes pas dans la whitelist")
        return
    end
    deferrals.update("✅ • Vous êtes bien whitelisté... Bienvenue")
    Wait(Config.Wait.connecting)
    deferrals.done()
end)

MySQL.ready(function()
    MySQL.Async.fetchAll("SELECT identifier FROM whitelist", {}, function(result)
        for k, v in pairs(result) do
            whitelisted[v.identifier] = true
        end
    end)
end)

TriggerEvent("esx:getSharedObject", function(obj)
    ESX = obj
end)

RegisterCommand("unwhitelist", function(_src, args)
    if #args ~= 1 then return end
    local identifier = args[1]
    if _src == 0 then
        unwhitelist(identifier, function()
            print("Joueur retiré de la whitelist")
        end)
        return
    end
    local xPlayer = ESX.GetPlayerFromId(_src)
    local group = xPlayer.getGroup()
    if group ~= "superadmin" then return end
    if not whitelisted[identifier] then
        TriggerClientEvent("esx:showNotification", _src, "~r~Le joueur n'est pas whitelisté")
        return
    end
    unwhitelist(identifier, function()
        TriggerClientEvent("esx:showNotification", _src, "~g~Le joueur a bien été retiré de la whitelist")
    end)
end)

RegisterCommand("whitelist", function(_src, args)
    if #args ~= 1 then return end
    local identifier = args[1]
    if _src == 0 then
        whitelist(identifier, function()
            print("Joueur ajouté à la whitelist")
        end)
        return
    end
    local xPlayer = ESX.GetPlayerFromId(_src)
    local group = xPlayer.getGroup()
    if group ~= "superadmin" then return end
    if whitelisted[identifier] then
        TriggerClientEvent("esx:showNotification", _src, "~r~Le joueur est déjà whitelisté")
        return
    end
    whitelist(identifier, function()
        TriggerClientEvent("esx:showNotification", _src, "~g~Le joueur a été ajouté à la whitelist")
    end)
end)