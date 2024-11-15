ESX = nil

ESX = exports["es_extended"]:getSharedObject()

local oxmysql = exports.oxmysql

-- Funktion für Discord-Logs
local function sendToDiscord(title, message, color)
    local webhook = "DEINE_DISCORD_WEBHOOK_URL" -- Webhook hier einfügen
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({
        username = 'Fahrzeug-Log',
        embeds = {{
            ["color"] = color,
            ["title"] = title,
            ["description"] = message,
            ["footer"] = {["text"] = os.date('%Y-%m-%d %H:%M:%S')}
        }}
    }), { ['Content-Type'] = 'application/json' })
end

-- Befehl: givecar
RegisterCommand('givecar', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() ~= 'admin' then
        xPlayer.showNotification('Du hast keine Berechtigung für diesen Befehl!')
        return
    end

    local targetId = tonumber(args[1])
    local vehicleModel = args[2]
    local vehicleType = args[3] or 'car'

    if not targetId or not vehicleModel then
        xPlayer.showNotification('Ungültige Argumente. Benutze: /givecar [Spieler-ID] [Fahrzeug-Model] [Typ]')
        return
    end

    local targetPlayer = ESX.GetPlayerFromId(targetId)
    if not targetPlayer then
        xPlayer.showNotification('Spieler nicht gefunden!')
        return
    end

    local plate = "CAR" .. math.random(1000, 9999)
    local vehicleData = {
        model = vehicleModel,
        plate = plate
    }

    oxmysql:insert('INSERT INTO owned_vehicles (owner, plate, vehicle, stored, type) VALUES (?, ?, ?, ?, ?)', {
        targetPlayer.identifier,
        plate,
        json.encode(vehicleData),
        1,
        vehicleType
    }, function(insertId)
        if insertId then
            targetPlayer.showNotification('Dir wurde ein Fahrzeug gegeben: ' .. vehicleModel .. ' (Kennzeichen: ' .. plate .. ')')
            xPlayer.showNotification('Fahrzeug erfolgreich hinzugefügt.')
            sendToDiscord('Fahrzeug hinzugefügt', xPlayer.getName() .. ' hat ' .. vehicleModel .. ' (Kennzeichen: ' .. plate .. ') an ' .. targetPlayer.getName() .. ' gegeben.', 3066993)
        else
            xPlayer.showNotification('Fehler beim Hinzufügen des Fahrzeugs.')
        end
    end)
end, false)

-- Befehl: deletecar
RegisterCommand('deletecar', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() ~= 'admin' then
        xPlayer.showNotification('Du hast keine Berechtigung für diesen Befehl!')
        return
    end

    local plate = args[1]
    if not plate then
        xPlayer.showNotification('Ungültige Argumente. Benutze: /deletecar [Kennzeichen]')
        return
    end

    oxmysql:execute('DELETE FROM owned_vehicles WHERE plate = ?', {plate}, function(affectedRows)
        if affectedRows > 0 then
            xPlayer.showNotification('Fahrzeug mit dem Kennzeichen ' .. plate .. ' wurde erfolgreich gelöscht.')
            sendToDiscord('Fahrzeug gelöscht', xPlayer.getName() .. ' hat das Fahrzeug mit Kennzeichen ' .. plate .. ' gelöscht.', 15158332)
        else
            xPlayer.showNotification('Fahrzeug mit dem Kennzeichen ' .. plate .. ' nicht gefunden.')
        end
    end)
end, false)

-- Befehl: listcars
RegisterCommand('listcars', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() ~= 'admin' then
        xPlayer.showNotification('Du hast keine Berechtigung für diesen Befehl!')
        return
    end

    local targetId = tonumber(args[1])
    if not targetId then
        xPlayer.showNotification('Ungültige Argumente. Benutze: /listcars [Spieler-ID]')
        return
    end

    local targetPlayer = ESX.GetPlayerFromId(targetId)
    if not targetPlayer then
        xPlayer.showNotification('Spieler nicht gefunden!')
        return
    end

    oxmysql:fetch('SELECT plate, vehicle FROM owned_vehicles WHERE owner = ?', {targetPlayer.identifier}, function(results)
        if #results > 0 then
            xPlayer.showNotification('Fahrzeuge des Spielers:')
            for _, vehicle in ipairs(results) do
                local vehicleData = json.decode(vehicle.vehicle)
                xPlayer.showNotification('Kennzeichen: ' .. vehicle.plate .. ' | Modell: ' .. vehicleData.model)
            end
        else
            xPlayer.showNotification('Dieser Spieler besitzt keine Fahrzeuge.')
        end
    end)
end, false)

-- Befehl: storecar
RegisterCommand('storecar', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() ~= 'admin' then
        xPlayer.showNotification('Du hast keine Berechtigung für diesen Befehl!')
        return
    end

    local plate = args[1]
    local stored = tonumber(args[2])
    if not plate or not stored then
        xPlayer.showNotification('Ungültige Argumente. Benutze: /storecar [Kennzeichen] [0/1]')
        return
    end

    oxmysql:execute('UPDATE owned_vehicles SET stored = ? WHERE plate = ?', {stored, plate}, function(affectedRows)
        if affectedRows > 0 then
            local status = stored == 1 and 'eingelagert' or 'ausgelagert'
            xPlayer.showNotification('Fahrzeug mit dem Kennzeichen ' .. plate .. ' wurde erfolgreich ' .. status .. '.')
            sendToDiscord('Fahrzeugstatus geändert', xPlayer.getName() .. ' hat den Speicherstatus von Fahrzeug mit Kennzeichen ' .. plate .. ' auf ' .. status .. ' gesetzt.', 3447003)
        else
            xPlayer.showNotification('Fahrzeug mit dem Kennzeichen ' .. plate .. ' nicht gefunden.')
        end
    end)
end, false)

-- Befehlsvorschläge im Chat registrieren
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        TriggerClientEvent('chat:addSuggestion', -1, '/givecar', 'Gibt einem Spieler ein Fahrzeug.', {
            {name = 'Spieler-ID', help = 'Die ID des Zielspielers'},
            {name = 'Fahrzeug-Model', help = 'Der Modellname des Fahrzeugs'},
            {name = 'Typ', help = 'Fahrzeugtyp (z.B. car, boat, plane)'}
        })
        TriggerClientEvent('chat:addSuggestion', -1, '/deletecar', 'Löscht ein Fahrzeug aus der Datenbank.', {
            {name = 'Kennzeichen', help = 'Das Kennzeichen des Fahrzeugs'}
        })
        TriggerClientEvent('chat:addSuggestion', -1, '/listcars', 'Zeigt alle Fahrzeuge eines Spielers.', {
            {name = 'Spieler-ID', help = 'Die ID des Zielspielers'}
        })
        TriggerClientEvent('chat:addSuggestion', -1, '/storecar', 'Ändert den Speicherstatus eines Fahrzeugs.', {
            {name = 'Kennzeichen', help = 'Das Kennzeichen des Fahrzeugs'},
            {name = 'Status', help = '1 = eingelagert, 0 = ausgelagert'}
        })
    end
end)
