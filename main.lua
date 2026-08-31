local speedMultiplier = 1.0 -- velocidade inicial

-- Comando para definir a velocidade desejada
RegisterCommand("speed", function(source, args, rawCommand)
    if #args ~= 1 then
        TriggerEvent('chat:addMessage', { args = { 'Sistema', 'Uso: /speed [valor]' } })
        return
    end

    local valor = tonumber(args[1])
    if valor == nil then
        TriggerEvent('chat:addMessage', { args = { 'Sistema', 'Por favor, insira um valor numérico válido.' } })
        return
    end

    speedMultiplier = valor
    TriggerEvent('chat:addMessage', { args = { 'Sistema', 'Velocidade ajustada para: ' .. valor } })
end)

-- Aplicar o multiplicador de velocidade ao personagem
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            -- Ajusta a velocidade do veículo
            SetEntityMaxSpeed(vehicle, 50.0 * speedMultiplier)
        else
            -- Ajusta a velocidade do personagem (corrida)
            -- Você pode ajustar a velocidade de corrida aqui se desejar
        end
    end
end)
