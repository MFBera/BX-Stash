QBCore = nil
local coreLoaded = false
local depoKordinat = vector3(-480.55709838867, -11.296117782593, 36.426525115967)
local door = vector3(-482.77124023438, -6.7797741889954, 37.018180847168)
local doorOpenCoord = vector3(-483.55932617188, -5.713996887207, 36.427368164062)
local caseCoord = vector3(-413.2694, -2823.2424, 6.0004)
local doorModel = 961976194
local doorDefaultHeading = 335.097
local openedStashId = nil
local caseDistance = 999
local doorAnimation = false
local PlayerData = {}

Citizen.CreateThread(function()
    while QBCore == nil do
        TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
        Citizen.Wait(200)
    end
    coreLoaded = true
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    firstLogin()
end)

RegisterNetEvent('BX-Stash:yenile')
AddEventHandler('BX-Stash:yenile', function()
    depoAc()
end)

RegisterNetEvent('BX-Stash:client:setDoorAnim')
AddEventHandler('BX-Stash:client:setDoorAnim', function(bool)
    doorAnimation = bool
end)

function firstLogin()
    PlayerData = QBCore.Functions.GetPlayerData()
end

function depoAc()
    QBCore.Functions.TriggerCallback("BX-Stash:depolar", function(data)
        if not PlayerData.citizenid then PlayerData = QBCore.Functions.GetPlayerData() end
        SendNUIMessage({type = "open", data = data, citizenid = PlayerData.citizenid})
        SetNuiFocus(true, true)
    end)
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        SetNuiFocus(false, false)
    end
end)

RegisterNUICallback('kapat', function(data, cb)
    SetNuiFocus(false, false)
end)

RegisterNUICallback('satinal', function(data, cb)
    TriggerServerEvent("BX-Stash:satin-al", data)
end)

RegisterNUICallback('deposat', function(data, cb)
    TriggerServerEvent("BX-Stash:sat")
end)

RegisterNUICallback('ac', function(data, cb)
    openedStashId = "TGN_"..data.citizenid
    if caseDistance < 3 then
        TriggerEvent("inventory:client:SetCurrentStash", openedStashId, QBCore.Key)
        TriggerServerEvent("inventory:server:OpenInventory", "stash", openedStashId, {
            maxweight = 10000000,
            slots = 140,
        })
    else
        doorOpen()
    end
end)

Citizen.CreateThread(function()
	while true do
        local time = 1000
        if coreLoaded then
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            if not doorAnimation then
                local mesafe = #(depoKordinat - coords)
                if mesafe < 3 then
                    time = 1
                    local yazi = ""
                    if mesafe < 1 then
                        yazi = "[E] "
                        if IsControlJustReleased(0, 38) then
                            depoAc()
                        end
                    end
                    QBCore.Functions.DrawText3D(depoKordinat.x, depoKordinat.y, depoKordinat.z+0.55, yazi.."Kiralık Depo")
                end

                local openDistance = #(doorOpenCoord - coords)
                if openDistance < 3 then
                    time = 1
                    local yazi = ""
                    if openDistance < 1 then
                        yazi = "[E] "
                        if IsControlJustReleased(0, 38) then
                            openedStashId = nil
                            doorOpen()
                            Citizen.Wait(1000)
                        end
                    end
                    QBCore.Functions.DrawText3D(doorOpenCoord.x, doorOpenCoord.y, doorOpenCoord.z+0.55, yazi.."Kapıyı Aç")
                end
            end

            caseDistance = #(caseCoord - coords)
            if caseDistance < 3 then
                time = 1
                local yazi = ""
                if caseDistance < 1 then
                    yazi = "[E] "
                    if IsControlJustReleased(0, 38) then
                        if openedStashId then
                            TriggerEvent("inventory:client:SetCurrentStash", openedStashId, QBCore.Key)
                            TriggerServerEvent("inventory:server:OpenInventory", "stash", openedStashId, {
                                maxweight = 10000000,
                                slots = 140,
                            })
                        else
                            depoAc()
                        end
                    end
                end
                QBCore.Functions.DrawText3D(caseCoord.x, caseCoord.y, caseCoord.z+0.55, yazi.."Kiralık Depo")
            end
           
        end
        Citizen.Wait(time)
    end
end)

function doorOpen()
    Citizen.CreateThread(function()
        TriggerServerEvent("BX-Stash:server:setDoorAnim", true)
        local door = GetClosestObjectOfType(door, 3.0, doorModel, false, false, false)
        FreezeEntityPosition(door, true)
        while true do
            local doorHeading = GetEntityHeading(door)
            SetEntityHeading(door, doorHeading-0.1)
            if doorHeading < 175 then break end
            Citizen.Wait(10)
        end
        Citizen.Wait(1000)
        doorClose()
        TriggerServerEvent("BX-Stash:server:setDoorAnim", false)
    end)
end

function doorClose()
    local door = GetClosestObjectOfType(door, 3.0, doorModel, false, false, false)
    FreezeEntityPosition(door, true)
    while true do
        local doorHeading = GetEntityHeading(door)
        SetEntityHeading(door, doorHeading+0.1)
        if doorHeading > doorDefaultHeading then break end
        Citizen.Wait(10)
    end
end