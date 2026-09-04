-- ========================================================
-- 🥚 ROBIN HUB ULTIMATE v2.0 — ESPECIAL: ROUBEM UM OVO
-- SUPORTE: Delta, Codex, Arceus X, Fluxus, Vega X, PC
-- ========================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Ponte de Interface Universal
local TargetUI = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- Limpa execuções anteriores
if TargetUI:FindFirstChild("RobinEggHubUltimate") then
    TargetUI.RobinEggHubUltimate:Destroy()
end

-- ========================================================
-- ESTADO DAS CONFIGURAÇÕES (FLAGS)
-- ========================================================
local Flags = {
    AutoFarm = false,
    FarmDelay = 0.3,          -- Velocidade do Farm (em segundos)
    SelectedEggType = "Todos", -- Filtro de Ovo
    AutoDeposit = false,
    Noclip = false,
    SpeedBoost = false,
    WalkSpeedValue = 32,
    InfJump = false,
    EggESP = false
}

-- Lista de Tipos/Raridades de Ovos no jogo
local EggTypes = {"Todos", "Comum", "Raro", "Epico", "Lendario", "Mitico"}

-- ========================================================
-- LÓGICA E FUNÇÕES DO PERSONAGEM / FARM
-- ========================================================

-- Teleporte Seguro
local function TeleportTo(cframe)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        hrp.CFrame = cframe
    end
end

-- Encontrar a Base do Jogador
local function GetPlayerBase()
    local folder = workspace:FindFirstChild("Bases") or workspace:FindFirstChild("Plots")
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

-- Sistema de Noclip Seguro
local NoclipConn
local function SetNoclip(state)
    Flags.Noclip = state
    if state then
        if not NoclipConn then
            NoclipConn = RunService.Stepped:Connect(function()
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
        if NoclipConn then
            NoclipConn:Disconnect()
            NoclipConn = nil
        end
    end
end

-- Pulo Infinito
UserInputService.JumpRequest:Connect(function()
    if Flags.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Loop de Velocidade do Jogador
task.spawn(function()
    while task.wait(0.2) do
        if Flags.SpeedBoost and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Flags.WalkSpeedValue
        end
    end
end)

-- LOOP DO AUTO FARM (OTIMIZADO E SEM BUGS)
task.spawn(function()
    while true do
        task.wait(Flags.FarmDelay)
        if Flags.AutoFarm then
            pcall(function()
                local eggsFound = {}
                
                -- Escaneia os ovos no mapa
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("egg") or obj.Name:lower():find("ovo")) then
                        if obj.Parent and not obj.Parent:FindFirstChild("Humanoid") then
                            local eggName = obj.Name:lower()
                            local filter = Flags.SelectedEggType:lower()

                            -- Aplica o Filtro de Escolha do Ovo
                            if filter == "todos" or eggName:find(filter) then
                                table.insert(eggsFound, obj)
                            end
                        end
                    end
                end

                -- Teleporta para o ovo encontrado
                if #eggsFound > 0 then
                    for _, egg in ipairs(eggsFound) do
                        if not Flags.AutoFarm then break end
                        if egg and egg.Parent then
                            TeleportTo(egg.CFrame * CFrame.new(0, 2, 0))
                            task.wait(Flags.FarmDelay)
                            
                            -- Se o Auto Depositar estiver ativo, leva até a base
                            if Flags.AutoDeposit then
                                local base = GetPlayerBase()
                                if base then
                                    local depositPart = base:FindFirstChild("Deposit") or base:FindFirstChild("Drop") or base:FindFirstChild("Chest") or base
                                    TeleportTo(depositPart.CFrame * CFrame.new(0, 3, 0))
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

-- Loop de ESP (Destacar Ovos)
local function UpdateESP()
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
                if obj:FindFirstChild("EggHighlight") then
                    obj.EggHighlight:Destroy()
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(2) do
        if Flags.EggESP then UpdateESP() end
    end
end)

-- ========================================================
-- CRIAÇÃO DA INTERFACE GRÁFICA (UI)
-- ========================================================

local ScreenGui = Instance.new("ScreenGui", TargetUI)
ScreenGui.Name = "RobinEggHubUltimate"
ScreenGui.ResetOnSpawn = false

-- 🟡 BOLINHA FLUTUANTE ARRASTÁVEL (MINIMIZAR/ABRIR)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Name = "RobinOpenBtn"
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
OpenBtn.Text = "🥚"
OpenBtn.TextSize = 22
OpenBtn.Visible = false
OpenBtn.Active = true
OpenBtn.Draggable = true
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

local OpenStroke = Instance.new("UIStroke", OpenBtn)
OpenStroke.Color = Color3.fromRGB(255, 170, 0)
OpenStroke.Thickness = 2

-- JANELA PRINCIPAL
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 500, 0, 320)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 29)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(255, 170, 0)
MainStroke.Thickness = 1.5

-- Barra Superior
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "🥚 ROBIN HUB — ROUBEM UM OVO (ULTIMATE)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -14)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- Função para Alternar entre Hub e Bolinha
local function ToggleHub()
    MainFrame.Visible = not MainFrame.Visible
    OpenBtn.Visible = not MainFrame.Visible
end

CloseBtn.MouseButton1Click:Connect(ToggleHub)
OpenBtn.MouseButton1Click:Connect(ToggleHub)

-- Sidebar (Menu Lateral)
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Position = UDim2.new(0, 8, 0, 50)
Sidebar.Size = UDim2.new(0, 135, 1, -58)
Sidebar.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 4)

local SidebarPad = Instance.new("UIPadding", Sidebar)
SidebarPad.PaddingTop = UDim.new(0, 6)
SidebarPad.PaddingLeft = UDim.new(0, 6)
SidebarPad.PaddingRight = UDim.new(0, 6)

-- Área de Conteúdo
local Content = Instance.new("Frame", MainFrame)
Content.Position = UDim2.new(0, 149, 0, 50)
Content.Size = UDim2.new(1, -157, 1, -58)
Content.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 8)

local Pages = {}
local FirstTab = true

local function CreateTab(name, icon)
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(1, 0, 0, 32)
    TabBtn.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
    TabBtn.Text = icon .. " " .. name
    TabBtn.TextColor3 = Color3.fromRGB(170, 180, 200)
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 11
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("ScrollingFrame", Content)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2

    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 6)

    local PagePad = Instance.new("UIPadding", Page)
    PagePad.PaddingTop = UDim.new(0, 6)
    PagePad.PaddingLeft = UDim.new(0, 6)
    PagePad.PaddingRight = UDim.new(0, 6)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, btn in pairs(Sidebar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
                btn.TextColor3 = Color3.fromRGB(170, 180, 200)
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
        Frame.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
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
        Btn.BackgroundColor3 = Flags[flagName] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(40, 46, 60)
        Btn.Text = Flags[flagName] and "ON" or "OFF"
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 10
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)

        Btn.MouseButton1Click:Connect(function()
            Flags[flagName] = not Flags[flagName]
            if flagName == "Noclip" then SetNoclip(Flags.Noclip) end
            if flagName == "EggESP" then UpdateESP() end
            Btn.Text = Flags[flagName] and "ON" or "OFF"
            Btn.BackgroundColor3 = Flags[flagName] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(40, 46, 60)
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

    function Actions:AddLabel(text)
        local Lbl = Instance.new("TextLabel", Page)
        Lbl.Size = UDim2.new(1, 0, 0, 20)
        Lbl.Text = text
        Lbl.TextColor3 = Color3.fromRGB(255, 170, 0)
        Lbl.Font = Enum.Font.GothamBold
        Lbl.TextSize = 11
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.BackgroundTransparency = 1
    end

    return Actions
end

-- ========================================================
-- MONTAGEM DAS ABAS E SELETORES
-- ========================================================

-- TAB 1: AUTO FARM
local FarmTab = CreateTab("Auto Farm", "🌾")
FarmTab:AddToggle("Ativar Auto Farm de Ovos", "AutoFarm")
FarmTab:AddToggle("Auto Depositar na Base", "AutoDeposit")

FarmTab:AddLabel("⚡ Velocidade do Auto Farm:")
FarmTab:AddButton("Velocidade: Lento (0.5s - Muito Seguro)", function()
    Flags.FarmDelay = 0.5
end)
FarmTab:AddButton("Velocidade: Normal (0.3s - Recomendado)", function()
    Flags.FarmDelay = 0.3
end)
FarmTab:AddButton("Velocidade: Rápido (0.1s - Ultra Farm)", function()
    Flags.FarmDelay = 0.1
end)

-- TAB 2: SELETOR DE OVOS
local EggTab = CreateTab("Filtrar Ovos", "🎯")
EggTab:AddLabel("Escolha qual tipo de Ovo pegar:")

for _, typeName in ipairs(EggTypes) do
    EggTab:AddButton("Focar em: " .. typeName, function()
        Flags.SelectedEggType = typeName
    end)
end

-- TAB 3: JOGADOR
local PlayerTab = CreateTab("Jogador", "⚡")
PlayerTab:AddToggle("Super Velocidade (32)", "SpeedBoost")
PlayerTab:AddToggle("Pulo Infinito", "InfJump")
PlayerTab:AddToggle("Noclip (Atravessar Paredes)", "Noclip")

-- TAB 4: VISUAL
local VisualTab = CreateTab("Visual", "👁️")
VisualTab:AddToggle("ESP Destacar Ovos (Brilho)", "EggESP")

-- TAB 5: TELEPORTES
local TeleportTab = CreateTab("Teleportes", "📍")
TeleportTab:AddButton("Teleportar para o Centro do Mapa", function()
    TeleportTo(CFrame.new(0, 10, 0))
end)
TeleportTab:AddButton("Teleportar para Minha Base", function()
    local base = GetPlayerBase()
    if base then
        TeleportTo(base:GetPivot())
    end
end)
