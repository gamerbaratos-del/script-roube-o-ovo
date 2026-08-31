-- Script para controlar válvulas no Roblox

local valveParts = workspace.Vaulas:GetChildren() -- Supondo que as válvulas estejam no grupo "Vaulas"
local openPosition = Vector3.new(0, 0, 0) -- Posição aberta
local closedPosition = Vector3.new(0, -5, 0) -- Posição fechada, ajusta conforme necessário
local isOpen = true

local function toggleValves()
    for _, valve in ipairs(valveParts) do
        if isOpen then
            -- Fechar válvula
            valve.Position = closedPosition
        else
            -- Abrir válvula
            valve.Position = openPosition
        end
    end
    isOpen = not isOpen
end

while true do
    toggleValves()
    wait(2) -- Tempo entre as trocas, ajusta conforme necessário
end
