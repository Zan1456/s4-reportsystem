ESX = nil

PlayerData = nil

CACHE_IMG = nil

Citizen.CreateThread(function()
   while ESX == nil do
      TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
      Citizen.Wait(0)
   end

   PlayerData = ESX.GetPlayerData()

   SendNUIMessage({ action = "config", config = Config  })

   Citizen.Wait(2000)

   SendNUIMessage({ action = "config", config = Config  })
 
end)

RegisterCommand(Config.ReportCommand, function(source, args)
   id = 0
   CACHE_IMG = nil
   if args[1] then id = args[1] end
   SendNUIMessage({ action = "report", id = id  })
   SetNuiFocus(1, 1)
   SetNuiFocusKeepInput(0)
 
   exports['screenshot-basic']:requestScreenshotUpload(Config.Webhook, 'files[]', function(data)
      resp = json.decode(data)
      SendNUIMessage({ action = "updateIMG", img = resp.attachments[1].proxy_url  })
      CACHE_IMG = resp.attachments[1].proxy_url
   end)

end)

RegisterNUICallback("save", function(data, cb)
   data.img = CACHE_IMG
   TriggerServerEvent("s4-report:newReport", data)
end)


RegisterNUICallback("close", function(data, cb)
   SetNuiFocus(0, 0)
   SetNuiFocusKeepInput(0)
end)

RegisterNUICallback("prop", function(data, cb)
   print("s4-report:updateReportExtends", data.unique, data.prop, data.value)
   TriggerServerEvent("s4-report:updateReportExtends", data.unique, data.prop, data.value)
end)

RegisterNetEvent("s4-report:notif")
AddEventHandler("s4-report:notif", function(data)
   SendNUIMessage({ action = "showNotif", data = data  })
end)

RegisterNUICallback("reqReports", function(data, cb)
   TriggerServerEvent("s4-report:reqReports")
end)


RegisterNUICallback("repPoint", function(data, cb)
   TriggerServerEvent("s4-report:repPoint", data.identifier, data.point)
end)

RegisterNUICallback("ban", function(data, cb)
   TriggerServerEvent("s4-report:banPlayer", data.id, data.identifier)
end)

RegisterNUICallback("getRepPoint", function(data, cb)
   ESX.TriggerServerCallback('s4-report:getRepPoint', function(x)
      cb(x)
   end, data.identifier)
end)

RegisterNetEvent("s4-report:showReports")
AddEventHandler("s4-report:showReports", function(data)
   for k,v in pairs(data) do
      v.extends = json.decode(v.extends)
   end
   SendNUIMessage({ action = "showReports", data = data  })
   SetNuiFocus(1, 1)
end)