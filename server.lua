ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent("s4-report:newReport")
AddEventHandler("s4-report:newReport", function(data)

    xPlayer = ESX.GetPlayerFromId(source)
    zPlayer = {}

    if GetPlayerName(tonumber(data.id)) then
        zPlayer = ESX.GetPlayerFromId(tonumber(data.id))
        result = MySQL.Sync.fetchAll("SELECT firstname, lastname FROM `users` WHERE identifier = '"..zPlayer.identifier.."' ")
        name = result[1].firstname .. " " .. result[1].lastname
    else 
        name = Config.NotifLang["Unk"]
        zPlayer.identifier = Config.NotifLang["Unk"]
    end
    
    unique = math.random(1111111111, 9999999999)

    MySQL.Async.execute("INSERT INTO reports (owner, text, pid, rname, identifier, rip, uniqueid, img) VALUES ('"..xPlayer.identifier.."', '"..data.text.."', '"..data.id.."', '"..name.."', '"..zPlayer.identifier.."', '"..xPlayer.source.."', '"..unique.."', '"..data.img.."')")
 
    for _, v in pairs(ESX.GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(v)
        if xPlayer.getGroup() == "admin" then
            TriggerClientEvent("s4-report:notif", xPlayer.source, { data = data, name = name, src = xPlayer.source })
        end
    end


    if Config.EnableRecordScreen == true then 
        TriggerClientEvent("s4-render:addNewTask", tonumber(data.id),"s4-report:updateReport", unique, Config.RecordScreenTime*1000)
    end

    if GetPlayerName(tonumber(data.id)) then
        repres = {}
        repres = MySQL.Sync.fetchAll("SELECT * FROM `reports_players` WHERE identifier = '"..zPlayer.identifier.."' ")
        if #repres == 0 then 
            MySQL.Async.execute("INSERT INTO `reports_players` (identifier) VALUES ('"..zPlayer.identifier.."')")
        end
    end

end)

RegisterNetEvent("s4-report:repPoint")
AddEventHandler("s4-report:repPoint", function(identifier, point)
    repres = {}
    repres = MySQL.Sync.fetchAll("SELECT * FROM `reports_players` WHERE identifier = '"..identifier.."' ")
    if #repres ~= 0 then 
       MySQL.Async.execute("UPDATE `reports_players` SET `points` = '"..tonumber(point).."' WHERE `identifier` = '"..identifier.."' ")
    end
end)

ESX.RegisterServerCallback('s4-report:getRepPoint', function(source, cb, identifier)
    repres = {}
    repres = MySQL.Sync.fetchAll("SELECT * FROM `reports_players` WHERE identifier = '"..identifier.."' ")
    if #repres ~= 0 then 
       cb(tonumber(repres[1].points))
    end
end)

RegisterNetEvent("s4-report:updateReport")
AddEventHandler("s4-report:updateReport", function(data)
    result = {}
    result = MySQL.Sync.fetchAll("SELECT * FROM `reports` WHERE `uniqueid` = '"..data.unique.."' ")
    if #result ~= 0 then 
        extends = json.decode(result[1].extends)
        extends["video_thumbnail"] = data.video_thumbnail
        extends["video_thumbnail_proxy"] = data.video_thumbnail_proxy
        extends["video"] = data.video
        extends["video_proxy"] = data.video_proxy
        MySQL.Async.execute("UPDATE `reports` SET `extends` = '"..json.encode(extends).."' WHERE `uniqueid` = '"..data.unique.."' ")
    end
end)

RegisterNetEvent("s4-report:updateReportExtends")
AddEventHandler("s4-report:updateReportExtends", function(unique, prop, value)
    result = {}
    result = MySQL.Sync.fetchAll("SELECT * FROM `reports` WHERE `uniqueid` = '"..unique.."' ")
    if #result ~= 0 then 
        extends = json.decode(result[1].extends)
        extends = value
        MySQL.Async.execute("UPDATE `reports` SET `extends` = '"..json.encode(extends).."' WHERE `uniqueid` = '"..unique.."' ")
    end
end)


RegisterCommand(Config.ShowReportsCommand, function(source)
   xPlayer = ESX.GetPlayerFromId(source)
   if xPlayer.getGroup() ~= Config.AdminGroup then return end
   result = {}
   result = MySQL.Sync.fetchAll("SELECT * FROM `reports` ORDER BY id DESC")
   if #result ~= 0 then 
      TriggerClientEvent("s4-report:showReports", source, result)
   else
      xPlayer.showNotification(Config.NotifLang["No_reports_found"])
   end
end)

RegisterNetEvent("s4-report:reqReports")
AddEventHandler("s4-report:reqReports", function()
    local source = source
    xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() ~= Config.AdminGroup then return end
    result = {}
    result = MySQL.Sync.fetchAll("SELECT * FROM `reports`")
    if #result ~= 0 then 
       TriggerClientEvent("s4-report:showReports", source, result)
    else
       xPlayer.showNotification(Config.NotifLang["No_reports_found"])
    end
end)


RegisterNetEvent("s4-report:banPlayer")
AddEventHandler("s4-report:banPlayer", function(pid, identifier)
    xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() ~= Config.AdminGroup then return end
    local src = tonumber(pid)
    local identifiers = {}
	for k,v in ipairs(GetPlayerIdentifiers(src))do
        if string.sub(v, 1, string.len("license:")) == "license:" then
            identifiers["license"] = v
        elseif string.sub(v, 1, string.len("steam:")) == "steam:" then
            identifiers["steam"] = v
        elseif string.sub(v, 1, string.len("live:")) == "live:" then
            identifiers["live"] = v
        elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
            identifiers["xbl"]  = v
        elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
            identifiers["discord"] = v
        elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
            identifiers["ip"] = v
        end
    end
    identifiers[Config.DefaultIdentifier] = identifier

    MySQL.Async.fetchAll('INSERT INTO reports_banlist (identifiers) VALUES (@identifiers) ', { ["@identifiers"] = json.encode(identifiers)  }, function(results) end)
    xPlayer.showNotification(Config.NotifLang["User_Banned"])
    DropPlayer(src, Config.NotifLang["Ure_Banned"])
end)

AddEventHandler('playerConnecting', function(name, setCallback, deferrals) 
    local src = source
    local identifiers = {}
	for k,v in ipairs(GetPlayerIdentifiers(src))do
        if string.sub(v, 1, string.len("license:")) == "license:" then
            identifiers["license"] = v
        elseif string.sub(v, 1, string.len("steam:")) == "steam:" then
            identifiers["steam"] = v
        elseif string.sub(v, 1, string.len("live:")) == "live:" then
            identifiers["live"] = v
        elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
            identifiers["xbl"]  = v
        elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
            identifiers["discord"] = v
        elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
            identifiers["ip"] = v
        end
    end

	deferrals.defer()
    deferrals.update(Config.NotifLang["Checking_Ban_List"])

    MySQL.Async.fetchAll('SELECT * FROM reports_banlist', {}, function(results)
        for k,v in pairs(results) do
            x = json.decode(v.identifiers)
            if x["license"] == identifiers["license"] or x["steam"] == identifiers["steam"] or x["live"] == identifiers["live"] or x["xbl"] == identifiers["xbl"] or x["discord"] == identifiers["discord"] or x["ip"] == identifiers["ip"] then
               deferrals.done(Config.NotifLang["Ure_Banned"].." [s4-reportsystem]")
               return  
            end
        end
        deferrals.done()
    end)

end)
