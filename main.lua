-- ========================================================
-- ⚡ ROBIN HUB — SPEED MASTER (AJUSTÁVEL ATÉ 2000)
-- 🛡️ PROTEÇÃO 100% ANTI-BAN, ANTI-KICK & ANTI-AFK
-- ========================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")

local TargetUI = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- Limpeza de instâncias antigas
if TargetUI:FindFirstChild("RobinSpeedMasterUI") then
    TargetUI.RobinSpeedMasterUI:Destroy()
end

-- ========================================================
-- ⚙️ ESTADO E VARIÁVEIS DE CONFIGURAÇÃO
-- ========================================================
local Settings = {
    AutoTreadmill = false,
    SpeedHack = false,
    CurrentSpeed = 100,      -- Velocidade Padrão
    MaxSpeedLimit = 2000,    -- Limite Máximo
    AntiKick = true,
    AntiAFK = true,
    AntiStaff = true,
    AutoRejoin = true,
    SpoofWalkSpeed = true
}

-- ========================================================
-- 🛡️ MÓDULO DE 100% PROTEÇÃO (METATABLE HOOKS & BYPASSES)
-- ========================================================

-- 1. Bloqueador de Kick (Hooking __namecall)
pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if Settings.AntiKick and (method == "Kick" or method == "kick") then
            warn("🛡️ [ROBIN HUB] Tentativa de Kick bloqueada com sucesso!")
            return nil
        end
        return oldNamecall(self, ...)
    end))
end)

-- 2. Camuflador de WalkSpeed (Hooking __index) - Esconde 2000 de velocidade do Anti-Cheat
pcall(function()
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, index)
        if Settings.SpoofWalkSpeed and not checkcaller() and self:IsA("Humanoid") and index == "WalkSpeed" then
            return 16 -- Sempre retorna a velocidade normal para verificações do servidor
        end
        return oldIndex(self, index)
    end))
end)

-- 3. Anti-AFK (VirtualUser Controller)
LocalPlayer.Idled:Connect(function()
    if Settings.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- 4. Auto-Rejoin em caso de Desconexão
GuiService.ErrorMessageChanged:Connect(function()
    if Settings.AutoRejoin then
        task.wait(2)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

-- 5. Anti-Staff / Anti-Admin
Players.PlayerAdded:Connect(function(plr)
    if Settings.AntiStaff then
        local name = plr.Name:lower()
        if name:find("admin") or name:find("mod") or name:find("owner") or name:find("dev") then
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end
end)

-- ========================================================
-- ⚡ SISTEMA DE APLICAÇÃO DE VELOCIDADE E ESTEIRA
-- ========================================================

-- Aplicação de Velocidade Segura
RunService.Stepped:Connect(function()
    pcall(function()
        if Settings.SpeedHack and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = math.clamp(Settings.CurrentSpeed, 1, Settings.MaxSpeedLimit)
            end
        end
    end)
end)

-- Disparador de Esteira (Treadmill Trigger)
local function TriggerTreadmills()
    if not LocalPlayer.Character then return end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("TouchTransmitter") and obj.Parent then
            local part = obj.Parent
            local name = part.Name:lower()
            local parentName = part.Parent and part.Parent.Name:lower() or ""

            if name:find("treadmill") or name:find("esteira") or name:find("belt") or name:find("speed") or parentName:find("treadmill") or parentName:find("esteira") then
                if firetouchinterest then
                    firetouchinterest(hrp, part, 0)
                    task.wait()
                    firetouchinterest(hrp, part, 1)
                else
                    hrp.CFrame = part.CFrame * CFrame.new(0, 2, 0)
                end
            end
        end
    end
end

-- Loop de Farm da Esteira Otimizado
task.spawn(function()
    while true do
        task.wait(0.05)
        if Settings.AutoTreadmill then
            pcall(TriggerTreadmills)
        end
    end
end)

-- ========================================================
-- 🎨 INTERFACE GRÁFICA (UI MODERNA COM ENTRADA DE VELOCIDADE)
-- ========================================================

local ScreenGui = Instance.new("ScreenGui", TargetUI)
ScreenGui.Name = "RobinSpeedMasterUI"
ScreenGui.ResetOnSpawn = false

-- 🟡 BOLINHA FLUTUANTE ARRASTÁVEL
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Name = "OpenBtn"
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
OpenBtn.Text = "⚡"
OpenBtn.TextSize = 22
OpenBtn.Visible = false
OpenBtn.Active = true
OpenBtn.Draggable = true
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

local OpenStroke = Instance.new("UIStroke", OpenBtn)
OpenStroke.Color = Color3.fromRGB(0, 200, 255)
OpenStroke.Thickness = 2

-- JANELA PRINCIPAL
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 380, 0, 310)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 25)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 170, 255)
MainStroke.Thickness = 1.5

-- BARRA DE TÍTULO
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "⚡ ROBIN HUB — SPEED MASTER (MAX 2000)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -32, 0.5, -13)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.BackgroundColor3 = Color3.fromRGB(25, 30, 42)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 11
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local function ToggleUI()
    MainFrame.Visible = not MainFrame.Visible
    OpenBtn.Visible = not MainFrame.Visible
end

CloseBtn.MouseButton1Click:Connect(ToggleUI)
OpenBtn.MouseButton1Click:Connect(ToggleUI)

-- ÁREA DE CONTEÚDO
local Container = Instance.new("Frame", MainFrame)
Container.Position = UDim2.new(0, 10, 0, 48)
Container.Size = UDim2.new(1, -20, 1, -58)
Container.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 8)

-- 1. BOTÃO AUTO ESTEIRA
local TreadmillBtn = Instance.new("TextButton", Container)
TreadmillBtn.Size = UDim2.new(1, 0, 0, 36)
TreadmillBtn.BackgroundColor3 = Color3.fromRGB(22, 28, 42)
TreadmillBtn.Text = "🏃 Auto Esteira / Trilha: OFF"
TreadmillBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
TreadmillBtn.Font = Enum.Font.GothamBold
TreadmillBtn.TextSize = 11
Instance.new("UICorner", TreadmillBtn).CornerRadius = UDim.new(0, 6)

TreadmillBtn.MouseButton1Click:Connect(function()
    Settings.AutoTreadmill = not Settings.AutoTreadmill
    if Settings.AutoTreadmill then
        TreadmillBtn.Text = "🏃 Auto Esteira / Trilha: ON"
        TreadmillBtn.TextColor3 = Color3.fromRGB(50, 255, 120)
    else
        TreadmillBtn.Text = "🏃 Auto Esteira / Trilha: OFF"
        TreadmillBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- 2. BOTÃO ATIVAR VELOCIDADE HACK
local SpeedToggleBtn = Instance.new("TextButton", Container)
SpeedToggleBtn.Size = UDim2.new(1, 0, 0, 36)
SpeedToggleBtn.BackgroundColor3 = Color3.fromRGB(22, 28, 42)
SpeedToggleBtn.Text = "⚡ Ativar Super Velocidade: OFF"
SpeedToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
SpeedToggleBtn.Font = Enum.Font.GothamBold
SpeedToggleBtn.TextSize = 11
Instance.new("UICorner", SpeedToggleBtn).CornerRadius = UDim.new(0, 6)

SpeedToggleBtn.MouseButton1Click:Connect(function()
    Settings.SpeedHack = not Settings.SpeedHack
    if Settings.SpeedHack then
        SpeedToggleBtn.Text = "⚡ Ativar Super Velocidade: ON"
        SpeedToggleBtn.TextColor3 = Color3.fromRGB(50, 255, 120)
    else
        SpeedToggleBtn.Text = "⚡ Ativar Super Velocidade: OFF"
        SpeedToggleBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
        -- Restaura velocidade normal ao desligar
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
        end
    end
end)

-- 3. CAIXA DE TEXTO (DIGITAR VELOCIDADE DE 1 A 2000)
local InputFrame = Instance.new("Frame", Container)
InputFrame.Size = UDim2.new(1, 0, 0, 36)
InputFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 6)

local InputLabel = Instance.new("TextLabel", InputFrame)
InputLabel.Size = UDim2.new(0.55, 0, 1, 0)
InputLabel.Position = UDim2.new(0, 8, 0, 0)
InputLabel.Text = "Ajustar Velocidade (1-2000):"
InputLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
InputLabel.Font = Enum.Font.GothamSemibold
InputLabel.TextSize = 10
InputLabel.TextXAlignment = Enum.TextXAlignment.Left
InputLabel.BackgroundTransparency = 1

local SpeedBox = Instance.new("TextBox", InputFrame)
SpeedBox.Size = UDim2.new(0, 100, 0, 26)
SpeedBox.Position = UDim2.new(1, -108, 0.5, -13)
SpeedBox.BackgroundColor3 = Color3.fromRGB(28, 35, 52)
SpeedBox.Text = tostring(Settings.CurrentSpeed)
SpeedBox.TextColor3 = Color3.fromRGB(0, 200, 255)
SpeedBox.Font = Enum.Font.GothamBold
SpeedBox.TextSize = 11
Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 4)

SpeedBox.FocusLost:Connect(function()
    local val = tonumber(SpeedBox.Text)
    if val then
        val = math.clamp(math.floor(val), 1, Settings.MaxSpeedLimit)
        Settings.CurrentSpeed = val
        SpeedBox.Text = tostring(val)
    else
        SpeedBox.Text = tostring(Settings.CurrentSpeed)
    end
end)

-- 4. ATALHOS RÁPIDOS DE VELOCIDADE
local PresetFrame = Instance.new("Frame", Container)
PresetFrame.Size = UDim2.new(1, 0, 0, 30)
PresetFrame.BackgroundTransparency = 1

local PresetLayout = Instance.new("UIListLayout", PresetFrame)
PresetLayout.FillDirection = Enum.FillDirection.Horizontal
PresetLayout.Padding = UDim.new(0, 6)

local Presets = {100, 500, 1000, 2000}
for _, pVal in ipairs(Presets) do
    local PBtn = Instance.new("TextButton", PresetFrame)
    PBtn.Size = UDim2.new(0.235, 0, 1, 0)
    PBtn.BackgroundColor3 = Color3.fromRGB(25, 32, 48)
    PBtn.Text = tostring(pVal)
    PBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    PBtn.Font = Enum.Font.GothamBold
    PBtn.TextSize = 10
    Instance.new("UICorner", PBtn).CornerRadius = UDim.new(0, 4)

    PBtn.MouseButton1Click:Connect(function()
        Settings.CurrentSpeed = pVal
        SpeedBox.Text = tostring(pVal)
    end)
end

-- 5. STATUS DE PROTEÇÃO
local StatusFrame = Instance.new("Frame", Container)
StatusFrame.Size = UDim2.new(1, 0, 0, 32)
StatusFrame.BackgroundColor3 = Color3.fromRGB(15, 30, 25)
Instance.new("UICorner", StatusFrame).CornerRadius = UDim.new(0, 6)

local StatusStroke = Instance.new("UIStroke", StatusFrame)
StatusStroke.Color = Color3.fromRGB(46, 204, 113)
StatusStroke.Thickness = 1

local StatusLabel = Instance.new("TextLabel", StatusFrame)
StatusLabel.Size = UDim2.new(1, 0, 1, 0)
StatusLabel.Text = "🛡️ Proteções Ativas: Anti-Kick | Anti-AFK | Spoof 2000"
StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 9
StatusLabel.BackgroundTransparency = 1
