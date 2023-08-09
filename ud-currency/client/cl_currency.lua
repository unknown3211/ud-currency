local playerCash = 0
local isUIOpen = false

RegisterNetEvent('currency:setCash')
AddEventHandler('currency:setCash', function(cash)
    playerCash = cash
    --print("Your cash: $" .. playerCash)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000)  -- Wait 10 seconds after player joins, then requests their cash amount
        TriggerServerEvent('currency:getCash')
    end
end)

RegisterNetEvent('currency:showCashStatus')
AddEventHandler('currency:showCashStatus', function()
    if not isUIOpen then
        isUIOpen = true
        SendNUIMessage({
            action = "openUI"
        })
        TriggerServerEvent('currency:requestCashStatus')
    end
end)

RegisterNetEvent('currency:receiveCashStatus')
AddEventHandler('currency:receiveCashStatus', function(cash)
    SendNUIMessage({
        action = "updateCash",
        cash = cash
    })
    
    Citizen.Wait(5000) -- Shows for 5 seconds
    
    SendNUIMessage({
        action = "closeUI"
    })
    isUIOpen = false
end)

Citizen.CreateThread(function()
    SetNuiFocus(false, false)
end)