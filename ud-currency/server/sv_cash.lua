local cashPerMinute = 100

RegisterServerEvent('currency:getCash')
AddEventHandler('currency:getCash', function()
    local source = source
    local identifier = GetPlayerIdentifiers(source)[1]
    
    exports.oxmysql:execute("SELECT cash FROM currency WHERE identifier = @identifier", { ['@identifier'] = identifier }, function(result)
        if result[1] then
            TriggerClientEvent('currency:setCash', source, result[1].cash)
        else
            exports.oxmysql:execute('INSERT INTO currency (identifier, cash) VALUES (@identifier, 500)', {
                ['@identifier'] = identifier
            }, function()
                TriggerClientEvent('currency:setCash', source, 500)
            end)
        end
    end)
end)

RegisterServerEvent("currency:removeCashEvent")
AddEventHandler("currency:removeCashEvent", function(playerId, amount)
    local identifier = GetPlayerIdentifiers(playerId)[1]

    exports.oxmysql:execute("UPDATE currency SET cash = cash - @amount WHERE identifier = @identifier", { ['@amount'] = amount, ['@identifier'] = identifier }, function()
        TriggerClientEvent('currency:getCash', playerId)
    end)
end)

RegisterServerEvent("currency:addCashEvent")
AddEventHandler("currency:addCashEvent", function(playerId, amount)
    local identifier = GetPlayerIdentifiers(playerId)[1]

    exports.oxmysql:execute("UPDATE currency SET cash = cash + @amount WHERE identifier = @identifier", { ['@amount'] = amount, ['@identifier'] = identifier }, function()
        TriggerClientEvent('currency:getCash', playerId)
    end)
end)

RegisterCommand("udremovecash", function(source, args, rawCommand)
    local amount = tonumber(args[1])

    if not amount then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1ERROR', 'You must specify an amount!' } })
        return
    end

    TriggerEvent("currency:removeCashEvent", source, amount)
end, false)

RegisterCommand("udaddcash", function(source, args, rawCommand)
    local amount = tonumber(args[1])

    if not amount then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1ERROR', 'You must specify an amount!' } })
        return
    end

    TriggerEvent("currency:addCashEvent", source, amount)
end, false)

RegisterCommand("printcash", function(source, args, rawCommand)
    local identifier = GetPlayerIdentifiers(source)[1]

    exports.oxmysql:execute("SELECT cash FROM currency WHERE identifier = @identifier", { ['@identifier'] = identifier }, function(result)
        if result[1] then
            TriggerClientEvent('chat:addMessage', source, { args = { '^2Cash', 'Your cash: $' .. result[1].cash } })
        else
            TriggerClientEvent('chat:addMessage', source, { args = { '^1ERROR', 'You have no cash record in the database.' } })
        end
    end)
end, false)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- waits for 1 minute

        local players = GetPlayers()

        for _, playerId in ipairs(players) do
            local identifier = GetPlayerIdentifiers(playerId)[1]

            exports.oxmysql:execute("UPDATE currency SET cash = cash + @amount WHERE identifier = @identifier", { ['@amount'] = cashPerMinute, ['@identifier'] = identifier }, function()
                TriggerClientEvent('currency:getCash', playerId)
            end)
        end
    end
end)

RegisterCommand("cashstatus", function(source, args, rawCommand)
    TriggerClientEvent('currency:showCashStatus', source)
end, false)

RegisterServerEvent('currency:requestCashStatus')
AddEventHandler('currency:requestCashStatus', function()
    local source = source
    local identifier = GetPlayerIdentifiers(source)[1]
    
    exports.oxmysql:execute("SELECT cash FROM currency WHERE identifier = @identifier", { ['@identifier'] = identifier }, function(result)
        if result[1] then
            TriggerClientEvent('currency:receiveCashStatus', source, result[1].cash)
        end
    end)
end)
