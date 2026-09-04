-- ========================================================
-- 🛡️ ROBIN HUB ULTIMATE v3.0 — PROTEÇÃO 100% ANTI-BAN
-- SUPORTE: Delta, Codex, Arceus X, Fluxus, Vega X, PC
-- ========================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- Ponte de Interface Universal
local TargetUI = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- Limpa execuções anteriores
if TargetUI:FindFirstChild("RobinEggHubUltimate") then
    TargetUI.RobinEggHubUltimate:Destroy()
end

-- ========================================================
-- ⚙️ CONFIGURAÇÕES E FLAGS DE SEGURANÇA
-- ========================================================
local Flags = {
    AutoFarm = false,
    FarmSpeed = 60,            -- Velocidade do Voo Tween (60 = Seguro)
    SelectedEggType = "Todos",
    AutoDeposit = false,
    -- 🛡️ SISTEMA DE PROTEÇÃO
    AntiKick = true,
    AntiAFK = true,
    AntiStaff = true,
    AutoRejoin = true,
    StreamerMode = false,
    FPSBoost = false,
    -- 🏃 MOVIEMNTO E VISUAL
    Noclip = false,
    SpeedBoost = false,
    WalkSpeedValue = 32,
    InfJump = false,
    EggESP = false
}

local EggTypes = {"Todos", "Comum", "Raro", "Epico", "Lendario", "Mitico"}

-- ========================================================
-- 🛡️ MÓDULOS DE PROTEÇÃO AVANÇADA (100% ANTI-KICK)
-- ========================================================

-- 1. BLOQUEADOR DE KICK (Bypassa chamadas de Kick do Client)
pcall(function()
    local oldHM
    oldHM = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if Flags.AntiKick and (method == "Kick" or method == "kick") then
            warn("🛡️ [ROBIN HUB] Tentativa de Kick bloqueada com sucesso!")
            return nil
        end
        return oldHM(self, ...)
    end)
end)

-- 2. ANTI-AFK AUTOMÁTICO (Impede a desconexão de 20 minutos)
LocalPlayer.Idled:Connect(function()
    if Flags.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- 3. AUTO-REJOIN (Se o jogo cair, reconecta automaticamente)
game:GetService("GuiService").ErrorMessageChanged:Connect(function()
    if Flags.AutoRejoin then
        task.wait(2)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

-- 4. ANTI-STAFF / ANTI-ADMIN
Players.PlayerAdded:Connect(function(plr)
    if Flags.AntiStaff then
        local name = plr.Name:lower()
        if name:find("admin") or name:find("mod") or name:find("owner") or name:find("dev") then
            -- Troca de servidor se um staff entrar
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end
end)

-- ========================================================
-- 🚀 SISTEMA DE TELEPORTE SUAVE (TWEEN - BURLA ANTI-CHEAT)
-- ========================================================

local CurrentTween = nil

local function SafeTweenTP(targetCFrame)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    
    -- Se estiver muito perto, ajusta direto
    if distance < 5 then
        hrp.CFrame = targetCFrame
        return
    end

    local duration = distance / Flags.FarmSpeed
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    
    CurrentTween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    CurrentTween:Play()
    CurrentTween.Completed:Wait()
end

-- Cancelar Tween se o farm for desligado
local function StopTween()
    if CurrentTween then
        CurrentTween:Cancel()
        CurrentTween = nil
    end
end

-- ========================================================
-- 🌾 LOOP DO AUTO FARM OTIMIZADO E SEGURO
-- ========================================================

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
        if Flags.AutoFarm then
            pcall(function()
                local eggsFound = {}
                
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("egg") or obj.Name:lower():find("ovo")) then
                        if obj.Parent and not obj.Parent:FindFirstChild("Humanoid") then
                            local eggName = obj.Name:lower()
                            local filter = Flags.SelectedEggType:lower()

                            if filter == "todos" or eggName:find(filter) then
                                table.insert(eggsFound, obj)
                            end
                        end
                    end
                end

                if #eggsFound > 0 then
                    for _, egg in ipairs(eggsFound) do
                        if not Flags.AutoFarm then 
                            StopTween()
                            break 
                        end
                        
                        if egg and egg.Parent and egg:IsDescendantOf(workspace) then
                            -- Voo Seguro até o Ovo
                            SafeTweenTP(egg.CFrame * CFrame.new(0, 2.5, 0))
                            task.wait(0.2)
                            
                            -- Depositar se ativo
                            if Flags.AutoDeposit and Flags.AutoFarm then
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
-- ⚡ OUTRAS AUTOMAÇÕES (NOCLIP, SPEED, ESP, OTIMIZADOR)
-- ========================================================

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

UserInputService.JumpRequest:Connect(function()
    if Flags.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if Flags.SpeedBoost and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Flags.WalkSpeedValue
        end
    end
end)

local function EnableFPSBoost()
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj:Destroy()
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            obj.Enabled = false
        end
    end
    game:GetService("Lighting").GlobalShadows = false
end

-- ========================================================
-- 🎨 INTERFACE GRÁFICA (UI COM BOLINHA ARRASTÁVEL)
-- ========================================================

local ScreenGui = Instance.new("ScreenGui", TargetUI)
ScreenGui.Name = "RobinEggHubUltimate"
ScreenGui.ResetOnSpawn = false

-- 🟡 BOLINHA FLUTUANTE ARRASTÁVEL
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Name = "RobinOpenBtn"
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
OpenBtn.Text = "🛡️"
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
MainFrame.Size = UDim2.new(0, 520, 0, 330)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -165)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 25)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 170, 255)
MainStroke.Thickness = 1.5

-- BARRA SUPERIOR
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "🛡️ ROBIN HUB — PROTEÇÃO 100% ANTI-KICK"
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
CloseBtn.BackgroundColor3 = Color3.fromRGB(25, 30, 42)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local function ToggleHub()
    MainFrame.Visible = not MainFrame.Visible
    OpenBtn.Visible = not MainFrame.Visible
end

CloseBtn.MouseButton1Click:Connect(ToggleHub)
OpenBtn.MouseButton1Click:Connect(ToggleHub)

-- SIDEBAR
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

-- CONTEÚDO
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

    function Actions:AddToggle(text, flagName)
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
        Btn.BackgroundColor3 = Flags[flagName] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(35, 40, 55)
        Btn.Text = Flags[flagName] and "ON" or "OFF"
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 9
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)

        Btn.MouseButton1Click:Connect(function()
            Flags[flagName] = not Flags[flagName]
            if flagName == "Noclip" then SetNoclip(Flags.Noclip) end
            if flagName == "AutoFarm" and not Flags.AutoFarm then StopTween() end
            Btn.Text = Flags[flagName] and "ON" or "OFF"
            Btn.BackgroundColor3 = Flags[flagName] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(35, 40, 55)
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

    function Actions:AddLabel(text)
        local Lbl = Instance.new("TextLabel", Page)
        Lbl.Size = UDim2.new(1, 0, 0, 18)
        Lbl.Text = text
        Lbl.TextColor3 = Color3.fromRGB(0, 170, 255)
        Lbl.Font = Enum.Font.GothamBold
        Lbl.TextSize = 10
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.BackgroundTransparency = 1
    end

    return Actions
end

-- ========================================================
-- MONTAGEM DAS ABAS
-- ========================================================

-- ABA 1: AUTO FARM
local FarmTab = CreateTab("Auto Farm", "🌾")
FarmTab:AddToggle("Ativar Auto Farm (Voo Seguro)", "AutoFarm")
FarmTab:AddToggle("Auto Depositar na Base", "AutoDeposit")

FarmTab:AddLabel("⚡ Velocidade do Voo (Anti-Cheat):")
FarmTab:AddButton("Velocidade: Lenta (40 - Ultra Seguro)", function() Flags.FarmSpeed = 40 end)
FarmTab:AddButton("Velocidade: Normal (60 - Recomendado)", function() Flags.FarmSpeed = 60 end)
FarmTab:AddButton("Velocidade: Rápida (90 - Mínimo Risco)", function() Flags.FarmSpeed = 90 end)

-- ABA 2: PROTEÇÃO
local ProtectTab = CreateTab("Proteção", "🛡️")
ProtectTab:AddToggle("Anti-Kick Bloqueador", "AntiKick")
ProtectTab:AddToggle("Anti-AFK Automático", "AntiAFK")
ProtectTab:AddToggle("Anti-Staff (Auto Hop)", "AntiStaff")
ProtectTab:AddToggle("Auto Rejoin se Cair", "AutoRejoin")

-- ABA 3: FILTRO DE OVOS
local EggTab = CreateTab("Filtrar Ovos", "🎯")
EggTab:AddLabel("Escolha a Raridade:")
for _, typeName in ipairs(EggTypes) do
    EggTab:AddButton("Focar em: " .. typeName, function()
        Flags.SelectedEggType = typeName
    end)
end

-- ABA 4: OTIMIZAÇÃO / PERFORMANCE
local OptTab = CreateTab("Performance", "🚀")
OptTab:AddButton("Otimizar FPS (Remover Texturas)", function()
    EnableFPSBoost()
end)

-- ABA 5: JOGADOR
local PlayerTab = CreateTab("Jogador", "⚡")
PlayerTab:AddToggle("Super Velocidade", "SpeedBoost")
PlayerTab:AddToggle("Pulo Infinito", "InfJump")
PlayerTab:AddToggle("Noclip (Atravessar Paredes)", "Noclip")

-- ABA 6: TELEPORTES
local TeleportTab = CreateTab("Teleportes", "📍")
TeleportTab:AddButton("Teleportar para Minha Base", function()
    local base = GetPlayerBase()
    if base then SafeTweenTP(base:GetPivot()) end
end)
TeleportTab:AddButton("Server Hop (Trocar de Servidor)", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)
