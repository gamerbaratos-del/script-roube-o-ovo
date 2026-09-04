-- ========================================================
-- 🥚 ROBIN HUB ULTIMATE v3.0 — PROFESSIONAL EDITION
-- SUPORTE: Delta, Codex, Arceus X, Fluxus, Vega X, PC
-- ========================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local TargetUI = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- Limpa execuções anteriores
if TargetUI:FindFirstChild("RobinHubUltimate3") then
    TargetUI.RobinHubUltimate3:Destroy()
end

-- ========================================================
-- 🌐 COMPATIBILIDADE E POLYFILLS DE EXECUTORES
-- ========================================================

local queue_on_teleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
local set3drendering = set3drendering or setfpscap or function() end

-- ========================================================
-- ⚙️ CONFIGURAÇÃO GLOBAL E SAVE/LOAD SYSTEM (JSON)
-- ========================================================

local ConfigFile = "RobinHub_Config.json"
local DefaultConfig = {
    AutoFarm = false,
    FarmSpeed = 0.3,
    SelectedEgg = "Todos",
    AutoDeposit = false,
    UseTweenTP = false,
    TweenSpeed = 60,
    
    Noclip = false,
    SpeedBoost = false,
    WalkSpeed = 32,
    InfJump = false,
    EggESP = false,
    
    AntiAFK = true,
    AntiStaff = true,
    StreamerMode = false,
    CpuSaver = false,
    WebhookURL = "",
    
    Stats = {
        EggsCollected = 0,
        StartTime = os.time()
    }
}

local Flags = table.clone(DefaultConfig)

local function SaveSettings()
    if writefile then
        pcall(function()
            writefile(ConfigFile, HttpService:JSONEncode(Flags))
        end)
    end
end

local function LoadSettings()
    if isfile and isfile(ConfigFile) and readfile then
        pcall(function()
            local data = HttpService:JSONDecode(readfile(ConfigFile))
            for k, v in pairs(data) do
                Flags[k] = v
            end
        end)
    end
end

LoadSettings()

-- ========================================================
-- 📢 SISTEMA DE NOTIFICAÇÕES TOAST (UI ALERTS)
-- ========================================================

local NotificationContainer = Instance.new("Frame", TargetUI)
NotificationContainer.Name = "RobinNotifications"
NotificationContainer.Size = UDim2.new(0, 250, 1, 0)
NotificationContainer.Position = UDim2.new(1, -260, 0, 20)
NotificationContainer.BackgroundTransparency = 1

local NotifLayout = Instance.new("UIListLayout", NotificationContainer)
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

local function Notify(title, msg, duration)
    duration = duration or 3
    local Toast = Instance.new("Frame", NotificationContainer)
    Toast.Size = UDim2.new(1, 0, 0, 50)
    Toast.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    Toast.BorderSizePixel = 0
    Instance.new("UICorner", Toast).CornerRadius = UDim.new(0, 8)
    
    local Stroke = Instance.new("UIStroke", Toast)
    Stroke.Color = Color3.fromRGB(255, 170, 0)
    Stroke.Thickness = 1
    
    local TTitle = Instance.new("TextLabel", Toast)
    TTitle.Size = UDim2.new(1, -16, 0, 20)
    TTitle.Position = UDim2.new(0, 8, 0, 4)
    TTitle.Text = title
    TTitle.TextColor3 = Color3.fromRGB(255, 170, 0)
    TTitle.Font = Enum.Font.GothamBold
    TTitle.TextSize = 11
    TTitle.TextXAlignment = Enum.TextXAlignment.Left
    TTitle.BackgroundTransparency = 1
    
    local TMsg = Instance.new("TextLabel", Toast)
    TMsg.Size = UDim2.new(1, -16, 0, 20)
    TMsg.Position = UDim2.new(0, 8, 0, 22)
    TMsg.Text = msg
    TMsg.TextColor3 = Color3.fromRGB(220, 220, 220)
    TMsg.Font = Enum.Font.Gotham
    TMsg.TextSize = 10
    TMsg.TextXAlignment = Enum.TextXAlignment.Left
    TMsg.BackgroundTransparency = 1
    
    task.delay(duration, function()
        if Toast then Toast:Destroy() end
    end)
end

Notify("Robin Hub v3.0", "Carregado com sucesso!", 4)

-- ========================================================
-- 🛡️ SEGURANÇA, ANTI-AFK E ANTI-STAFF
-- ========================================================

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if Flags.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Anti-Staff Detector
local function CheckForStaff(player)
    if not Flags.AntiStaff then return end
    if player:GetRankInGroup(1) >= 200 or player.Name:lower():find("admin") or player.Name:lower():find("mod") then
        Notify("⚠️ ALERTA DE STAFF", "Staff detectado: " .. player.Name .. ". Desconectando...", 5)
        task.wait(1)
        LocalPlayer:Kick("[Robin Hub Anti-Staff] Um administrador entrou no servidor.")
    end
end

Players.PlayerAdded:Connect(CheckForStaff)
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CheckForStaff(p) end
end

-- Streamer Mode (Ocultar Nome)
local function GetDisplayName()
    if Flags.StreamerMode then
        return "Jogador Anônimo [Robin Hub]"
    end
    return LocalPlayer.DisplayName
end

-- Auto-Reload no Teleporte (Queue on Teleport)
if queue_on_teleport then
    queue_on_teleport([[
        loadstring(game:HttpGet("https://raw.githubusercontent.com/script/robinhub.lua"))()
    ]])
end

-- ========================================================
-- 🚀 SISTEMA DE TELEPORTE E AUTO FARM
-- ========================================================

local function TeleportTo(cframe)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    
    if Flags.UseTweenTP then
        local distance = (hrp.Position - cframe.Position).Magnitude
        local duration = distance / math.max(Flags.TweenSpeed, 10)
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = cframe})
        tween:Play()
        tween.Completed:Wait()
    else
        hrp.CFrame = cframe
    end
end

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

-- Loop Principal do Auto Farm
task.spawn(function()
    while true do
        task.wait(Flags.FarmSpeed)
        if Flags.AutoFarm then
            pcall(function()
                local eggsFound = {}
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("egg") or obj.Name:lower():find("ovo")) then
                        if obj.Parent and not obj.Parent:FindFirstChild("Humanoid") then
                            local filter = Flags.SelectedEgg:lower()
                            if filter == "todos" or obj.Name:lower():find(filter) then
                                table.insert(eggsFound, obj)
                            end
                        end
                    end
                end

                if #eggsFound > 0 then
                    for _, egg in ipairs(eggsFound) do
                        if not Flags.AutoFarm then break end
                        if egg and egg.Parent then
                            TeleportTo(egg.CFrame * CFrame.new(0, 2, 0))
                            Flags.Stats.EggsCollected = Flags.Stats.EggsCollected + 1
                            task.wait(Flags.FarmSpeed)
                            
                            if Flags.AutoDeposit then
                                local base = GetPlayerBase()
                                if base then
                                    local depositPart = base:FindFirstChild("Deposit") or base:FindFirstChild("Drop") or base
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

-- ========================================================
-- ⚡ RECURSOS DO JOGADOR E OTIMIZAÇÃO DE PERFORMANCE
-- ========================================================

-- Noclip
local NoclipConn
local function SetNoclip(state)
    Flags.Noclip = state
    if state then
        if not NoclipConn then
            NoclipConn = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        end
    elseif NoclipConn then
        NoclipConn:Disconnect()
        NoclipConn = nil
    end
end

-- Pulo Infinito
UserInputService.JumpRequest:Connect(function()
    if Flags.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Velocidade Modificada
task.spawn(function()
    while task.wait(0.2) do
        if Flags.SpeedBoost and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Flags.WalkSpeed
        end
    end
end)

-- Otimizador de FPS / FPS Boost
local function OptimizeGraphics()
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj:Destroy()
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            obj.Enabled = false
        end
    end
    Lighting.GlobalShadows = false
    Notify("Otimização", "Gráficos reduzidos para Máximo FPS!", 3)
end

-- Black Screen / CPU Saver
local BlackScreenFrame
local function SetCpuSaver(state)
    Flags.CpuSaver = state
    if state then
        if not BlackScreenFrame then
            BlackScreenFrame = Instance.new("Frame", TargetUI)
            BlackScreenFrame.Size = UDim2.new(1, 0, 1, 0)
            BlackScreenFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            BlackScreenFrame.ZIndex = 9999
            
            local Lbl = Instance.new("TextLabel", BlackScreenFrame)
            Lbl.Size = UDim2.new(1, 0, 1, 0)
            Lbl.Text = "🌙 MODO ECONOMIA DE BATERIA / CPU ATIVO\n(Robin Hub Rodando em Segundo Plano)"
            Lbl.TextColor3 = Color3.fromRGB(255, 170, 0)
            Lbl.Font = Enum.Font.GothamBold
            Lbl.TextSize = 16
            Lbl.BackgroundTransparency = 1
        end
        BlackScreenFrame.Visible = true
    else
        if BlackScreenFrame then BlackScreenFrame.Visible = false end
    end
end

-- Server Hop (Troca de Servidor)
local function ServerHop()
    Notify("Server Hop", "Procurando novo servidor...", 3)
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local Http = pcall(function()
        local raw = game:HttpGet(Api)
        local decode = HttpService:JSONDecode(raw)
        if decode and decode.data then
            for _, server in ipairs(decode.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                    break
                end
            end
        end
    end)
end

-- ========================================================
-- 🎨 CRIAÇÃO DA INTERFACE GRÁFICA (UI MOBILE-FIRST)
-- ========================================================

local ScreenGui = Instance.new("ScreenGui", TargetUI)
ScreenGui.Name = "RobinHubUltimate3"
ScreenGui.ResetOnSpawn = false

-- 🟡 BOLINHA FLUTUANTE ARRASTÁVEL
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
MainFrame.Size = UDim2.new(0, 520, 0, 340)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(255, 170, 0)
MainStroke.Thickness = 1.5

-- TopBar
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "🥚 ROBIN HUB v3.0 — " .. GetDisplayName()
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -14)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.BackgroundColor3 = Color3.fromRGB(28, 32, 45)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local function ToggleHub()
    MainFrame.Visible = not MainFrame.Visible
    OpenBtn.Visible = not MainFrame.Visible
end

CloseBtn.MouseButton1Click:Connect(ToggleHub)
OpenBtn.MouseButton1Click:Connect(ToggleHub)

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Position = UDim2.new(0, 8, 0, 50)
Sidebar.Size = UDim2.new(0, 140, 1, -58)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 4)
local SidebarPad = Instance.new("UIPadding", Sidebar)
SidebarPad.PaddingTop = UDim.new(0, 6)
SidebarPad.PaddingLeft = UDim.new(0, 6)
SidebarPad.PaddingRight = UDim.new(0, 6)

-- Content Area
local Content = Instance.new("Frame", MainFrame)
Content.Position = UDim2.new(0, 154, 0, 50)
Content.Size = UDim2.new(1, -162, 1, -58)
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

    local Elements = {}

    function Elements:AddToggle(text, flagName, callback)
        local Frame = Instance.new("Frame", Page)
        Frame.Size = UDim2.new(1, 0, 0, 32)
        Frame.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

        local Lbl = Instance.new("TextLabel", Frame)
        Lbl.Size = UDim2.new(0.65, 0, 1, 0)
        Lbl.Position = UDim2.new(0, 8, 0, 0)
        Lbl.Text = text
        Lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
        Lbl.Font = Enum.Font.Gotham
        Lbl.TextSize = 10
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.BackgroundTransparency = 1

        local Btn = Instance.new("TextButton", Frame)
        Btn.Size = UDim2.new(0, 44, 0, 20)
        Btn.Position = UDim2.new(1, -50, 0.5, -10)
        Btn.BackgroundColor3 = Flags[flagName] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(38, 44, 58)
        Btn.Text = Flags[flagName] and "ON" or "OFF"
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 9
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

        Btn.MouseButton1Click:Connect(function()
            Flags[flagName] = not Flags[flagName]
            Btn.Text = Flags[flagName] and "ON" or "OFF"
            Btn.BackgroundColor3 = Flags[flagName] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(38, 44, 58)
            SaveSettings()
            if callback then callback(Flags[flagName]) end
        end)
    end

    function Elements:AddButton(text, callback)
        local Btn = Instance.new("TextButton", Page)
        Btn.Size = UDim2.new(1, 0, 0, 30)
        Btn.BackgroundColor3 = Color3.fromRGB(24, 30, 44)
        Btn.Text = text
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.GothamSemibold
        Btn.TextSize = 10
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
        Btn.MouseButton1Click:Connect(function() pcall(callback) end)
    end

    function Elements:AddLabel(text)
        local Lbl = Instance.new("TextLabel", Page)
        Lbl.Size = UDim2.new(1, 0, 0, 18)
        Lbl.Text = text
        Lbl.TextColor3 = Color3.fromRGB(255, 170, 0)
        Lbl.Font = Enum.Font.GothamBold
        Lbl.TextSize = 10
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.BackgroundTransparency = 1
    end

    return Elements
end

-- ========================================================
-- MONTAGEM DAS ABAS DO PAINEL
-- ========================================================

-- TAB 1: AUTO FARM
local FarmTab = CreateTab("Auto Farm", "🌾")
FarmTab:AddToggle("Ativar Auto Farm", "AutoFarm")
FarmTab:AddToggle("Auto Depositar na Base", "AutoDeposit")
FarmTab:AddToggle("Usar Teleporte Suave (Tween)", "UseTweenTP")

FarmTab:AddLabel("⚡ Velocidade do Farm:")
FarmTab:AddButton("Modo Seguro (0.5s)", function() Flags.FarmSpeed = 0.5 SaveSettings() end)
FarmTab:AddButton("Modo Normal (0.3s)", function() Flags.FarmSpeed = 0.3 SaveSettings() end)
FarmTab:AddButton("Modo Ultra (0.1s)", function() Flags.FarmSpeed = 0.1 SaveSettings() end)

-- TAB 2: FILTRO DE OVOS
local EggTab = CreateTab("Filtro Ovos", "🎯")
EggTab:AddLabel("Escolha a Raridade Alvo:")

local EggList = {"Todos", "Comum", "Raro", "Epico", "Lendario", "Mitico"}
for _, eggType in ipairs(EggList) do
    EggTab:AddButton("Focar: " .. eggType, function()
        Flags.SelectedEgg = eggType
        Notify("Filtro Alterado", "Focado em: " .. eggType, 2)
        SaveSettings()
    end)
end

-- TAB 3: JOGADOR
local PlayerTab = CreateTab("Jogador", "⚡")
PlayerTab:AddToggle("Super Velocidade", "SpeedBoost")
PlayerTab:AddToggle("Pulo Infinito", "InfJump")
PlayerTab:AddToggle("Noclip (Atravessar Paredes)", "Noclip", function(v) SetNoclip(v) end)

-- TAB 4: PERFORMANCE & AFK
local PerfTab = CreateTab("Performance", "🚀")
PerfTab:AddToggle("Anti-AFK (24h)", "AntiAFK")
PerfTab:AddToggle("Economia de Bateria / CPU", "CpuSaver", function(v) SetCpuSaver(v) end)
PerfTab:AddButton("🚀 Impulsione seus FPS (Modo Batata)", OptimizeGraphics)

-- TAB 5: SEGURANÇA & SERVIDOR
local SecTab = CreateTab("Segurança", "🛡️")
SecTab:AddToggle("Anti-Staff (Kick Automático)", "AntiStaff")
SecTab:AddToggle("Modo Anônimo (Streamer)", "StreamerMode")
SecTab:AddButton("🔄 Trocar de Servidor (Server Hop)", ServerHop)
SecTab:AddButton("💾 Salvar Configurações Manualmente", SaveSettings)

-- TAB 6: ESTATÍSTICAS
local StatsTab = CreateTab("Estatísticas", "📊")
StatsTab:AddLabel("Métricas do Farm:")
StatsTab:AddButton("Ver Ovos Coletados", function()
    Notify("Estatísticas", "Total de Ovos Coletados: " .. Flags.Stats.EggsCollected, 4)
end)
StatsTab:AddButton("Resetar Contador", function()
    Flags.Stats.EggsCollected = 0
    Notify("Estatísticas", "Contador resetado com sucesso!", 2)
end)
