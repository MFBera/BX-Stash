QBCore = nil
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

local depoFiyat = 20000

QBCore.Functions.CreateCallback("BX-Stash:depolar", function(source, cb)
    exports.ghmattimysql:execute("SELECT * FROM BX-Stash", {}, function(result)
        cb(result)
    end)
end)

RegisterServerEvent('BX-Stash:satin-al')
AddEventHandler('BX-Stash:satin-al', function(data)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    if xPlayer.Functions.RemoveMoney('bank', depoFiyat) then
        exports.ghmattimysql:execute("SELECT * FROM BX-Stash WHERE citizenid = @citizenid", {
            ["@citizenid"] = xPlayer.PlayerData.citizenid
        }, function(result)
            if not result[1] then
                exports.ghmattimysql:scalar("INSERT INTO BX-Stash(citizenid, sifre, isim) VALUES (@citizenid, @sifre, @isim)", {
                    ['citizenid'] = xPlayer.PlayerData.citizenid, 
                    ['sifre'] = data.sifre,
                    ['isim'] = data.depoisim,
                }, function()
                    TriggerClientEvent("BX-Stash:yenile", src)
                    TriggerClientEvent("QBCore:Notify", src, "Depo "..depoFiyat.."$ Karşılığında Satın Allındı!", "success")
                end)
            end
        end)
    end
end)

RegisterServerEvent('BX-Stash:sat')
AddEventHandler('BX-Stash:sat', function(data)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    exports.ghmattimysql:execute("SELECT * FROM BX-Stash WHERE citizenid = @citizenid", {
        ["@citizenid"] = xPlayer.PlayerData.citizenid
    }, function(result)
        if result[1] then
            exports.ghmattimysql:scalar("DELETE FROM BX-Stash WHERE citizenid = @citizenid", {
                ['@citizenid'] = xPlayer.PlayerData.citizenid,
            }, function()
                local para = depoFiyat*0.5
                xPlayer.Functions.AddMoney('bank', para)
                TriggerClientEvent("QBCore:Notify", src, "Depo "..para.."$ Karşılığında Satıldı!", "success")
                TriggerClientEvent("BX-Stash:yenile", src)
            end)
        end
    end)
end)

RegisterServerEvent('BX-Stash:server:setDoorAnim')
AddEventHandler('BX-Stash:server:setDoorAnim', function(bool)
    TriggerClientEvent("BX-Stash:client:setDoorAnim", -1, bool)
end)