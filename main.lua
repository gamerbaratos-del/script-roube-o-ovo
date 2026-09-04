-- ========================================================
-- 🥚 ROBIN HUB v2.0 PRO — ESPECIAL: ROUBEM UM OVO
-- Compatibilidade: Delta, Codex, Arceus X, Fluxus, Vega X, PC
-- ========================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Ponte Universal de GUI (Garante funcionamento em qualquer executor)
local TargetUI = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- Destruir execuções anteriores para não duplicar
if TargetUI:FindFirstChild("RobinEggHubPro") then
    TargetUI.RobinEggHubPro:Destroy()
end

-- ========================================================
-- ESTADO DAS FUNÇÕES (FLAGS & CONFIGS)
-- ========================================================
local Flags = {
    AutoCollectEggs = false,
    AutoStealEggs = false,
    AutoDepositBase = false,
    Noclip = false,
    SpeedBoost = false,
    SpeedValue = 35,
    InfJump = false,
    AntiAFK = true,
    EggESP = false,
    PlayerESP = false,
    FlySpeed = 50
}

-- ========================================================
-- LÓGICA E AUTOMAÇÕES INTERNAS
-- ========================================================

-- Anti-AFK (Evita ser desconectado após 20 min)
LocalPlayer.Idled:Connect(function()
    if Flags.AntiAFK then
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:Button2Down(Vector2.zero, workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.zero, workspace.CurrentCamera.CFrame)
    end
end)

-- Sistema de Noclip
local NoclipConnection
local function SetNoclip(state)
    Flags.Noclip = state
    if state then
        if not NoclipConnection then
            NoclipConnection = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    else
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
    end
end

-- Pulo Infinito
UserInputService.JumpRequest:Connect(function()
    if Flags.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Loop de Velocidade
task.spawn(function()
    while task.wait(0.1) do
        if Flags.SpeedBoost and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Flags.SpeedValue
        end
    end
end)

-- Identificador da Base do Jogador
local function GetPlayerBase()
    local folder = workspace:FindFirstChild("Bases") or workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Tycoons")
    if folder then
        for _, base in ipairs(folder:GetChildren()) do
            if base:FindFirstChild("Owner") and tostring(base.Owner.Value) == LocalPlayer.Name then
                return base
            elseif base.Name:lower():find(LocalPlayer.Name:lower()) then
                return base
            end
        end
    end
    return nil
end

-- Função de Teleporte Seguro
local function TeleportTo(cframe)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = cframe
    end
end

-- Loop 1: Auto Coletar Ovos do Chão
task.spawn(function()
    while task.wait(0.2) do
        if Flags.AutoCollectEggs then
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if not Flags.AutoCollectEggs then break end
                    if obj:IsA("BasePart") and (obj.Name:lower():find("egg") or obj.Name:lower():find("ovo")) then
                        if obj.Parent and not obj.Parent:FindFirstChild("Humanoid") and not obj.Parent:FindFirstChild("Owner") then
                            TeleportTo(obj.CFrame * CFrame.new(0, 2, 0))
                            task.wait(0.15)
                        end
                    end
                end
            end)
        end
    end
end)

-- Loop 2: Auto Roubar Ovos de Outras Bases
task.spawn(function()
    while task.wait(0.3) do
        if Flags.AutoStealEggs then
            pcall(function()
                local myBase = GetPlayerBase()
                local folder = workspace:FindFirstChild("Bases") or workspace:FindFirstChild("Plots")
                if folder then
                    for _, base in ipairs(folder:GetChildren()) do
                        if not Flags.AutoStealEggs then break end
                        if base ~= myBase then
                            for _, obj in ipairs(base:GetDescendants()) do
                                if obj:IsA("BasePart") and (obj.Name:lower():find("egg") or obj.Name:lower():find("ovo")) then
                                    TeleportTo(obj.CFrame * CFrame.new(0, 2, 0))
                                    task.wait(0.2)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Loop 3: Auto Depositar na Minha Base
task.spawn(function()
    while task.wait(0.8) do
        if Flags.AutoDepositBase then
            pcall(function()
                local base = GetPlayerBase()
                if base then
                    local depositPart = base:FindFirstChild("Deposit") or base:FindFirstChild("Drop") or base:FindFirstChild("Chest") or base:FindFirstChild("Base") or base:FindFirstChild("Basket")
                    if depositPart then
                        TeleportTo(depositPart.CFrame * CFrame.new(0, 3, 0))
                    end
                end
            end)
        end
    end
end)

-- Sistema de ESP (Ovos e Jogadores)
local function UpdateESP()
    -- ESP Ovos
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("egg") or obj.Name:lower():find("ovo")) then
            if Flags.EggESP then
                if not obj:FindFirstChild("EggHighlight") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "EggHighlight"
                    hl.FillColor = Color3.fromRGB(255, 215, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.Parent = obj
                end
            else
                if obj:FindFirstChild("EggHighlight") then obj.EggHighlight:Destroy() end
            end
        end
    end

    -- ESP Jogadores
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if Flags.PlayerESP then
                if not player.Character:FindFirstChild("PlayerHighlight") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "PlayerHighlight"
                    hl.FillColor = Color3.fromRGB(255, 50, 50)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.Parent = player.Character
                end
            else
                if player.Character:FindFirstChild("PlayerHighlight") then
                    player.Character.PlayerHighlight:Destroy()
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(2) do
        if Flags.EggESP or Flags.PlayerESP then UpdateESP() end
    end
end)

-- ========================================================
-- INTERFACE GRÁFICA (UI MODERNA)
-- ========================================================

local ScreenGui = Instance.new("ScreenGui", TargetUI)
ScreenGui.Name = "RobinEggHubPro"
ScreenGui.ResetOnSpawn = false

-- Painel Principal
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 500, 0, 320)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 26)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(255, 170, 0)
MainStroke.Thickness = 1.5

-- 🟡 BOTÃO FLUTUANTE ARRASTÁVEL (MINIMIZAR/ABRIR)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Name = "RobinFloatingButton"
OpenBtn.Size = UDim2.new(0, 48, 0, 48)
OpenBtn.Position = UDim2.new(0.02, 0, 0.45, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 17, 26)
OpenBtn.Text = "🥚"
OpenBtn.TextSize = 22
OpenBtn.Visible = false
OpenBtn.Active = true
OpenBtn.Draggable = true -- Permite arrastar para qualquer lugar na tela do celular

local OpenCorner = Instance.new("UICorner", OpenBtn)
OpenCorner.CornerRadius = UDim.new(1, 0) -- Círculo Perfeito

local OpenStroke = Instance.new("UIStroke", OpenBtn)
OpenStroke.Color = Color3.fromRGB(255, 170, 0)
OpenStroke.Thickness = 2

-- TopBar
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "🥚 ROBIN HUB v2.0  |  Roubem um Ovo"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -32, 0.5, -13)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.BackgroundColor3 = Color3.fromRGB(28, 33, 46)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- Lógica de Alternar entre Painel e Bolinha
local function ToggleHub()
    MainFrame.Visible = not MainFrame.Visible
    OpenBtn.Visible = not MainFrame.Visible
end

CloseBtn.MouseButton1Click:Connect(ToggleHub)
OpenBtn.MouseButton1Click:Connect(ToggleHub)

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Position = UDim2.new(0, 8, 0, 48)
Sidebar.Size = UDim2.new(0, 130, 1, -56)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 4)
local SidebarPadding = Instance.new("UIPadding", Sidebar)
SidebarPadding.PaddingTop = UDim.new(0, 6)
SidebarPadding.PaddingLeft = UDim.new(0, 6)
SidebarPadding.PaddingRight = UDim.new(0, 6)

-- Content Container
local Content = Instance.new("Frame", MainFrame)
Content.Position = UDim2.new(0, 144, 0, 48)
Content.Size = UDim2.new(1, -152, 1, -56)
Content.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 8)

local Pages = {}
local FirstTab = true

local function CreateTab(name, icon)
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(1, 0, 0, 30)
    TabBtn.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    TabBtn.Text = icon .. " " .. name
    TabBtn.TextColor3 = Color3.fromRGB(160, 170, 190)
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 10
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("ScrollingFrame", Content)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Color3.fromRGB(255, 170, 0)

    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 6)
    local PagePadding = Instance.new("UIPadding", Page)
    PagePadding.PaddingTop = UDim.new(0, 6)
    PagePadding.PaddingLeft = UDim.new(0, 6)
    PagePadding.PaddingRight = UDim.new(0, 6)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, btn in pairs(Sidebar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
                btn.TextColor3 = Color3.fromRGB(160, 170, 190)
            end
        end
        Page.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
        TabBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    end)

    Pages[name] = Page
    if FirstTab then
        FirstTab = false
        Page.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
        TabBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    end

    local Actions = {}

    function Actions:AddToggle(text, flagName)
        local Frame = Instance.new("Frame", Page)
        Frame.Size = UDim2.new(1, 0, 0, 34)
        Frame.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

        local Lbl = Instance.new("TextLabel", Frame)
        Lbl.Size = UDim2.new(0.65, 0, 1, 0)
        Lbl.Position = UDim2.new(0, 8, 0, 0)
        Lbl.Text = text
        Lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
        Lbl.Font = Enum.Font.Gotham
        Lbl.TextSize = 10
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.BackgroundTransparency = 1

        local Btn = Instance.new("TextButton", Frame)
        Btn.Size = UDim2.new(0, 46, 0, 22)
        Btn.Position = UDim2.new(1, -52, 0.5, -11)
        Btn.BackgroundColor3 = Flags[flagName] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(38, 44, 58)
        Btn.Text = Flags[flagName] and "ON" or "OFF"
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 10
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)

        Btn.MouseButton1Click:Connect(function()
            Flags[flagName] = not Flags[flagName]
            if flagName == "Noclip" then SetNoclip(Flags.Noclip) end
            if flagName == "EggESP" or flagName == "PlayerESP" then UpdateESP() end
            Btn.Text = Flags[flagName] and "ON" or "OFF"
            Btn.BackgroundColor3 = Flags[flagName] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(38, 44, 58)
        end)
    end

    function Actions:AddButton(text, callback)
        local Btn = Instance.new("TextButton", Page)
        Btn.Size = UDim2.new(1, 0, 0, 32)
        Btn.BackgroundColor3 = Color3.fromRGB(25, 32, 48)
        Btn.Text = text
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.GothamSemibold
        Btn.TextSize = 10
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
        Btn.MouseButton1Click:Connect(function() pcall(callback) end)
    end

    return Actions
end

-- ========================================================
-- MONTAGEM DAS ABAS E RECURSOS
-- ========================================================

local FarmTab = CreateTab("Auto Farm", "🥚")
FarmTab:AddToggle("Auto Coletar Ovos (Mapa)", "AutoCollectEggs")
FarmTab:AddToggle("Auto Roubar Ovos (Bases)", "AutoStealEggs")
FarmTab:AddToggle("Auto Depositar na Base", "AutoDepositBase")

local PlayerTab = CreateTab("Jogador", "⚡")
PlayerTab:AddToggle("Ativar Super Velocidade", "SpeedBoost")
PlayerTab:AddToggle("Pulo Infinito", "InfJump")
PlayerTab:AddToggle("Noclip (Atravessar)", "Noclip")
PlayerTab:AddToggle("Anti-AFK (Anti Desconexão)", "AntiAFK")

local VisualTab = CreateTab("Visual", "👁️")
VisualTab:AddToggle("ESP Destacar Ovos", "EggESP")
VisualTab:AddToggle("ESP Destacar Jogadores", "PlayerESP")

local TeleportTab = CreateTab("Teleportes", "📍")
TeleportTab:AddButton("Teleportar para o Centro", function()
    TeleportTo(CFrame.new(0, 12, 0))
end)
TeleportTab:AddButton("Teleportar para Minha Base", function()
    local base = GetPlayerBase()
    if base then TeleportTo(base:GetPivot()) end
end)

local ConfigTab = CreateTab("Configs", "⚙️")
ConfigTab:AddButton("Reentrar no Servidor (Rejoin)", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)
ConfigTab:AddButton("Remover Lag (FPS Boost)", function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
    end
end)
ConfigTab:AddButton("Fechar Script Definitivamente", function()
    ScreenGui:Destroy()
end)
