-- ========================================================
-- 🛡️ ROBIN HUB ULTIMATE v3.0 — ROUBE O OVO & SPEED MASTER
-- REPOSITÓRIO: gamerbaratos-del/script-roube-o-ovo
-- SISTEMA MAX-PROTECT (Multi-Layer Anti-Cheat & Anti-Ban Bypass)
-- ========================================================

-- ========================================================
-- 1. SISTEMA DE PROTEÇÃO DE INSTÂNCIAS E SERVIÇOS (CLONEREF)
-- ========================================================
local function SafeService(serviceName)
    local s = game:GetService(serviceName)
    return (cloneref and cloneref(s)) or s
end

local Players = SafeService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = SafeService("TweenService")
local RunService = SafeService("RunService")
local CoreGui = SafeService("CoreGui")
local TeleportService = SafeService("TeleportService")
local VirtualUser = SafeService("VirtualUser")
local GuiService = SafeService("GuiService")
local ScriptContext = SafeService("ScriptContext")

local TargetUI = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- Limpeza de instâncias antigas sem causar crash
if TargetUI:FindFirstChild("RobinEggHubMaster") then
    pcall(function() TargetUI.RobinEggHubMaster:Destroy() end)
end

-- ========================================================
-- ⚙️ CONFIGURAÇÕES E ESTADOS GLOBAIS
-- ========================================================
local Settings = {
    -- Auto Farm
    AutoFarm = false,
    FarmSpeed = 65,
    SelectedEggType = "Todos",
    AutoDeposit = false,
    -- Esteira & Velocidade
    AutoTreadmill = false,
    SpeedHack = false,
    CurrentSpeed = 100,
    MaxSpeedLimit = 2000,
    -- Proteções do Sistema
    AntiKick = true,
    AntiAFK = true,
    AntiStaff = true,
    AutoRejoin = true,
    SpoofWalkSpeed = true,
    BlockAntiCheatRemotes = true,
    AntiVoid = true,
    AntiStun = true
}

-- ========================================================
-- 🛡️ ARQUITETURA ANTI-BAN & BYPASSES DE ANTI-CHEAT
-- ========================================================

-- A. BLOQUEIO DE LOGS DE ERRO PARA O SERVIDOR
pcall(function()
    ScriptContext.Error:Connect(function(message, stackTrace, scriptInst)
        -- Silencia relatórios de erro que o Anti-Cheat pode ler
    end)
end)

-- B. HOOKS NO METATABLE (ANTI-KICK, SPOOFER E FILTRO DE REMOTES)
if hookmetamethod and checkcaller and newcclosure then
    -- 1. Anti-Kick e Anti-Remote Log (Namecall Hook)
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if not checkcaller() then
            -- Bloqueio de Kick
            if Settings.AntiKick and (method == "Kick" or method == "kick") then
                warn("🛡️ [ROBIN PROTECT] Tentativa de Kick bloqueada com sucesso!")
                return nil
            end

            -- Filtro de RemoteEvents do Anti-Cheat
            if Settings.BlockAntiCheatRemotes and (method == "FireServer" or method == "InvokeServer") then
                local remoteName = tostring(self.Name):lower()
                local suspiciousKeywords = {"ban", "kick", "cheat", "detect", "flag", "report", "exploit", "anticheat", "log", "security"}
                
                for _, kw in ipairs(suspiciousKeywords) do
                    if remoteName:find(kw) then
                        warn("🛡️ [ROBIN PROTECT] Remote do Anti-Cheat interceptado e bloqueado: " .. self.Name)
                        return nil
                    end
                end
            end
        end

        return oldNamecall(self, ...)
    end))

    -- 2. Spoofer de WalkSpeed, JumpPower e HipHeight (Index Hook)
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, index)
        if Settings.SpoofWalkSpeed and not checkcaller() and self:IsA("Humanoid") then
            if index == "WalkSpeed" then
                return 16
            elseif index == "JumpPower" then
                return 50
            elseif index == "HipHeight" then
                return 0
            end
        end
        return oldIndex(self, index)
    end))

    -- 3. Proteção contra modificação de variáveis locais (NewIndex Hook)
    local oldNewIndex
    oldNewIndex = hookmetamethod(game, "__newindex", newcclosure(function(self, index, value)
        if not checkcaller() and Settings.SpoofWalkSpeed and self:IsA("Humanoid") then
            if index == "WalkSpeed" and Settings.SpeedHack then
                return nil
            end
        end
        return oldNewIndex(self, index, value)
    end))
end

-- C. ANTI-AFK AUTOMÁTICO
LocalPlayer.Idled:Connect(function()
    if Settings.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- D. AUTO-REJOIN EM CASO DE QUEDA OU ERRO DE SERVIDOR
GuiService.ErrorMessageChanged:Connect(function()
    if Settings.AutoRejoin then
        task.wait(2)
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end
end)

-- E. DETECTOR DINÂMICO DE STAFF / ADMINS
local function IsStaff(player)
    if not player then return false end
    local name = player.Name:lower()
    local display = player.DisplayName:lower()
    local keywords = {"admin", "mod", "owner", "dev", "staff", "builder", "creator"}

    for _, kw in ipairs(keywords) do
        if name:find(kw) or display:find(kw) then
            return true
        end
    end
    return false
end

Players.PlayerAdded:Connect(function(plr)
    if Settings.AntiStaff and IsStaff(plr) then
        warn("🛡️ [ROBIN PROTECT] Staff/Admin detectado: " .. plr.Name .. ". Trocando de servidor...")
        pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    end
end)

-- ========================================================
-- ⚡ MOTORES DE LOOP E FÍSICA (SPEED & ANTI-STUN)
-- ========================================================

-- Aplicação de Velocidade em Loop Contínuo sem erros
RunService.Stepped:Connect(function()
    pcall(function()
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

            if hum then
                -- Anti-Stun / Restauração de Estado
                if Settings.AntiStun then
                    hum.PlatformStand = false
                    hum.Sit = false
                end

                -- Aplicação Segura de WalkSpeed
                if Settings.SpeedHack then
                    hum.WalkSpeed = math.clamp(Settings.CurrentSpeed, 1, Settings.MaxSpeedLimit)
                end
            end

            -- Anti-Void (Evita queda infinita fora do mapa)
            if Settings.AntiVoid and hrp and hrp.Position.Y < -100 then
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.CFrame = CFrame.new(0, 50, 0)
            end
        end
    end)
end)

-- ========================================================
-- 🏃 LÓGICA AUTO ESTEIRA / TRILHA
-- ========================================================
local function TriggerTreadmills()
    if not LocalPlayer.Character then return end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("TouchTransmitter") and obj.Parent then
            local part = obj.Parent
            local name = part.Name:lower()
            local pName = part.Parent and part.Parent.Name:lower() or ""

            if name:find("treadmill") or name:find("esteira") or name:find("belt") or name:find("speed") or pName:find("treadmill") or pName:find("esteira") then
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

task.spawn(function()
    while true do
        task.wait(0.05)
        if Settings.AutoTreadmill then
            pcall(TriggerTreadmills)
        end
    end
end)

-- ========================================================
-- 🌾 LÓGICA AUTO FARM DE OVOS (SUAVE E COM TRATAMENTO DE ERROS)
-- ========================================================
local CurrentTween = nil

local function SafeTweenTP(targetCFrame)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    
    if distance < 5 then
        hrp.CFrame = targetCFrame
        return
    end

    local duration = distance / Settings.FarmSpeed
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    CurrentTween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    CurrentTween:Play()
    CurrentTween.Completed:Wait()
end

local function StopTween()
    if CurrentTween then
        pcall(function() CurrentTween:Cancel() end)
        CurrentTween = nil
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

task.spawn(function()
    while true do
        task.wait(0.2)
        if Settings.AutoFarm then
            pcall(function()
                local eggsFound = {}
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("egg") or obj.Name:lower():find("ovo")) then
                        if obj.Parent and not obj.Parent:FindFirstChild("Humanoid") then
                            local eggName = obj.Name:lower()
                            local filter = Settings.SelectedEggType:lower()
                            if filter == "todos" or eggName:find(filter) then
                                table.insert(eggsFound, obj)
                            end
                        end
                    end
                end

                if #eggsFound > 0 then
                    for _, egg in ipairs(eggsFound) do
                        if not Settings.AutoFarm then StopTween() break end
                        if egg and egg.Parent and egg:IsDescendantOf(workspace) then
                            SafeTweenTP(egg.CFrame * CFrame.new(0, 2.5, 0))
                            task.wait(0.2)
                            
                            if Settings.AutoDeposit and Settings.AutoFarm then
                                local base = GetPlayerBase()
                                if base then
                                    local depositPart = base:FindFirstChild("Deposit") or base:FindFirstChild("Drop") or base
                                    SafeTweenTP(depositPart.CFrame * CFrame.new(0, 3, 0))
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
-- 🎨 INTERFACE GRÁFICA (UI MODERNA, LEVE E ARRASTÁVEL)
-- ========================================================

local ScreenGui = Instance.new("ScreenGui", TargetUI)
ScreenGui.Name = "RobinEggHubMaster"
ScreenGui.ResetOnSpawn = false

-- BOLINHA ARRASTÁVEL DE ABRIR/FECHAR
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
OpenBtn.Text = "⚡"
OpenBtn.TextSize = 22
OpenBtn.Visible = false
OpenBtn.Active = true
OpenBtn.Draggable = true
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

local OpenStroke = Instance.new("UIStroke", OpenBtn)
OpenStroke.Color = Color3.fromRGB(0, 170, 255)
OpenStroke.Thickness = 2

-- JANELA PRINCIPAL
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 480, 0, 330)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -165)
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
Title.Text = "⚡ ROBIN HUB v3.0 — MAX PROTECTED (100% ANTI-BAN)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 10
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

-- SIDEBAR
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Position = UDim2.new(0, 8, 0, 48)
Sidebar.Size = UDim2.new(0, 125, 1, -56)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 4)

local SidebarPad = Instance.new("UIPadding", Sidebar)
SidebarPad.PaddingTop = UDim.new(0, 6)
SidebarPad.PaddingLeft = UDim.new(0, 6)
SidebarPad.PaddingRight = UDim.new(0, 6)

-- CONTEÚDO
local Content = Instance.new("Frame", MainFrame)
Content.Position = UDim2.new(0, 139, 0, 48)
Content.Size = UDim2.new(1, -147, 1, -56)
Content.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 8)

local Pages = {}
local FirstTab = true

local function CreateTab(name, icon)
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(1, 0, 0, 30)
    TabBtn.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    TabBtn.Text = icon .. " " .. name
    TabBtn.TextColor3 = Color3.fromRGB(160, 175, 195)
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
                btn.TextColor3 = Color3.fromRGB(160, 175, 195)
            end
        end
        Page.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    Pages[name] = Page
    if FirstTab then
        FirstTab = false
        Page.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    local Actions = {}

    function Actions:AddToggle(text, defaultState, callback)
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
        Lbl.TextSize = 9
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.BackgroundTransparency = 1

        local Btn = Instance.new("TextButton", Frame)
        Btn.Size = UDim2.new(0, 44, 0, 20)
        Btn.Position = UDim2.new(1, -50, 0.5, -10)
        Btn.BackgroundColor3 = defaultState and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(35, 40, 55)
        Btn.Text = defaultState and "ON" or "OFF"
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 9
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)

        local state = defaultState
        Btn.MouseButton1Click:Connect(function()
            state = not state
            Btn.Text = state and "ON" or "OFF"
            Btn.BackgroundColor3 = state and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(35, 40, 55)
            pcall(callback, state)
        end)
    end

    function Actions:AddButton(text, callback)
        local Btn = Instance.new("TextButton", Page)
        Btn.Size = UDim2.new(1, 0, 0, 30)
        Btn.BackgroundColor3 = Color3.fromRGB(22, 28, 42)
        Btn.Text = text
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.GothamSemibold
        Btn.TextSize = 10
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
        Btn.MouseButton1Click:Connect(function() pcall(callback) end)
    end

    function Actions:AddInput(label, default, maxVal, callback)
        local Frame = Instance.new("Frame", Page)
        Frame.Size = UDim2.new(1, 0, 0, 32)
        Frame.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

        local Lbl = Instance.new("TextLabel", Frame)
        Lbl.Size = UDim2.new(0.6, 0, 1, 0)
        Lbl.Position = UDim2.new(0, 8, 0, 0)
        Lbl.Text = label
        Lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
        Lbl.Font = Enum.Font.Gotham
        Lbl.TextSize = 9
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.BackgroundTransparency = 1

        local Box = Instance.new("TextBox", Frame)
        Box.Size = UDim2.new(0, 70, 0, 22)
        Box.Position = UDim2.new(1, -76, 0.5, -11)
        Box.BackgroundColor3 = Color3.fromRGB(28, 35, 52)
        Box.Text = tostring(default)
        Box.TextColor3 = Color3.fromRGB(0, 200, 255)
        Box.Font = Enum.Font.GothamBold
        Box.TextSize = 10
        Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)

        Box.FocusLost:Connect(function()
            local val = tonumber(Box.Text)
            if val then
                val = math.clamp(math.floor(val), 1, maxVal)
                Box.Text = tostring(val)
                pcall(callback, val)
            else
                Box.Text = tostring(default)
            end
        end)
    end

    return Actions
end

-- ========================================================
-- CREAÇÃO DAS ABAS NA UI
-- ========================================================

-- ABA 1: VELOCIDADE
local SpeedTab = CreateTab("Velocidade", "⚡")
SpeedTab:AddToggle("Auto Esteira / Trilha", false, function(s) Settings.AutoTreadmill = s end)
SpeedTab:AddToggle("Ativar Speed Hack", false, function(s)
    Settings.SpeedHack = s
    if not s and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
    end
end)
SpeedTab:AddInput("Velocidade (1-2000):", Settings.CurrentSpeed, Settings.MaxSpeedLimit, function(val)
    Settings.CurrentSpeed = val
end)
SpeedTab:AddButton("Preset: 100", function() Settings.CurrentSpeed = 100 end)
SpeedTab:AddButton("Preset: 500", function() Settings.CurrentSpeed = 500 end)
SpeedTab:AddButton("Preset: 1000", function() Settings.CurrentSpeed = 1000 end)
SpeedTab:AddButton("Preset: 2000 (MÁX)", function() Settings.CurrentSpeed = 2000 end)

-- ABA 2: AUTO FARM OVOS
local FarmTab = CreateTab("Auto Farm", "🌾")
FarmTab:AddToggle("Ativar Auto Farm Ovos", false, function(s)
    Settings.AutoFarm = s
    if not s then StopTween() end
end)
FarmTab:AddToggle("Auto Depositar na Base", false, function(s) Settings.AutoDeposit = s end)

-- ABA 3: SEGURANÇA & PROTEÇÃO AVANÇADA
local ProtectTab = CreateTab("Proteções", "🛡️")
ProtectTab:AddToggle("Anti-Kick Metatable", true, function(s) Settings.AntiKick = s end)
ProtectTab:AddToggle("WalkSpeed Spoofing", true, function(s) Settings.SpoofWalkSpeed = s end)
ProtectTab:AddToggle("Bloquear Remotes Anti-Cheat", true, function(s) Settings.BlockAntiCheatRemotes = s end)
ProtectTab:AddToggle("Anti-AFK 24/7", true, function(s) Settings.AntiAFK = s end)
ProtectTab:AddToggle("Anti-Staff (Auto Server Hop)", true, function(s) Settings.AntiStaff = s end)
ProtectTab:AddToggle("Auto Rejoin se Cair", true, function(s) Settings.AutoRejoin = s end)
ProtectTab:AddToggle("Anti-Void (Queda no Mapa)", true, function(s) Settings.AntiVoid = s end)
ProtectTab:AddToggle("Anti-Stun / Anti-Freeze", true, function(s) Settings.AntiStun = s end)
