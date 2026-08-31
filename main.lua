--[[
    ⚡ SPEED PANEL v2.5 - DELTA ROBLOX
    Status: ✅ OTIMIZADO PARA DELTA ROBLOX
    Status: 100% FUNCIONAL
]]--

-- Aguardar o jogo carregar completamente
wait(1)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
if not player then return end

local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Variáveis de Configuração
local speedValue = 16
local godMode = true
local noclipMode = false
local invisMode = false
local freezeMode = false
local autoMode = false
local autoDirection = 1
local savedSpeed = 16
local markTP = false
local markCFrame = nil
local draggingSlider = false

-- Criar GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaSpeedPanel"
screenGui.ResetOnSpawn = false
screenGui.ZIndex = 100
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, 280, 0, 300)
panel.Position = UDim2.new(0.5, -140, 0, 20)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
panel.BorderColor3 = Color3.fromRGB(0, 150, 255)
panel.BorderSizePixel = 3
panel.Draggable = true
panel.Active = true
panel.Parent = screenGui

-- Título
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Text = "⚡ DELTA SPEED v2.5"
title.BorderSizePixel = 0
title.Parent = panel

-- Velocidade
local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Size = UDim2.new(1, 0, 0, 30)
speedLabel.Position = UDim2.new(0, 0, 0, 35)
speedLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
speedLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
speedLabel.TextSize = 18
speedLabel.Font = Enum.Font.GothamBold
speedLabel.Text = "Speed: 16"
speedLabel.BorderSizePixel = 0
speedLabel.Parent = panel

-- Botão God Mode
local godBtn = Instance.new("TextButton")
godBtn.Name = "GodBtn"
godBtn.Size = UDim2.new(1, 0, 0, 22)
godBtn.Position = UDim2.new(0, 0, 0, 65)
godBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
godBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
godBtn.TextSize = 12
godBtn.Font = Enum.Font.Gotham
godBtn.Text = "🛡️ GOD MODE: ON"
godBtn.BorderSizePixel = 0
godBtn.Parent = panel

-- Frame de Proteções
local protFrame = Instance.new("Frame")
protFrame.Size = UDim2.new(1, -10, 0, 22)
protFrame.Position = UDim2.new(0, 5, 0, 88)
protFrame.BackgroundTransparency = 1
protFrame.Parent = panel

local noclipBtn = Instance.new("TextButton")
noclipBtn.Name = "NoclipBtn"
noclipBtn.Size = UDim2.new(0.32, 0, 1, 0)
noclipBtn.BackgroundColor3 = Color3.fromRGB(70, 40, 100)
noclipBtn.TextColor3 = Color3.fromRGB(180, 150, 255)
noclipBtn.TextSize = 10
noclipBtn.Font = Enum.Font.Gotham
noclipBtn.Text = "👻 NOCLIP"
noclipBtn.BorderSizePixel = 1
noclipBtn.Parent = protFrame

local invisBtn = Instance.new("TextButton")
invisBtn.Name = "InvisBtn"
invisBtn.Size = UDim2.new(0.32, 0, 1, 0)
invisBtn.Position = UDim2.new(0.34, 0, 0, 0)
invisBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
invisBtn.TextColor3 = Color3.fromRGB(150, 150, 255)
invisBtn.TextSize = 10
invisBtn.Font = Enum.Font.Gotham
invisBtn.Text = "👁️ INVIS"
invisBtn.BorderSizePixel = 1
invisBtn.Parent = protFrame

local freezeBtn = Instance.new("TextButton")
freezeBtn.Name = "FreezeBtn"
freezeBtn.Size = UDim2.new(0.32, 0, 1, 0)
freezeBtn.Position = UDim2.new(0.68, 0, 0, 0)
freezeBtn.BackgroundColor3 = Color3.fromRGB(100, 70, 40)
freezeBtn.TextColor3 = Color3.fromRGB(255, 150, 100)
freezeBtn.TextSize = 10
freezeBtn.Font = Enum.Font.Gotham
freezeBtn.Text = "❄️ FREEZE"
freezeBtn.BorderSizePixel = 1
freezeBtn.Parent = protFrame

-- Frame de Funções
local funcFrame = Instance.new("Frame")
funcFrame.Size = UDim2.new(1, -10, 0, 22)
funcFrame.Position = UDim2.new(0, 5, 0, 111)
funcFrame.BackgroundTransparency = 1
funcFrame.Parent = panel

local resetBtn = Instance.new("TextButton")
resetBtn.Name = "ResetBtn"
resetBtn.Size = UDim2.new(0.48, 0, 1, 0)
resetBtn.BackgroundColor3 = Color3.fromRGB(100, 70, 70)
resetBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
resetBtn.TextSize = 10
resetBtn.Font = Enum.Font.Gotham
resetBtn.Text = "🔄 RESET"
resetBtn.BorderSizePixel = 1
resetBtn.Parent = funcFrame

local saveBtn = Instance.new("TextButton")
saveBtn.Name = "SaveBtn"
saveBtn.Size = UDim2.new(0.48, 0, 1, 0)
saveBtn.Position = UDim2.new(0.52, 0, 0, 0)
saveBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 70)
saveBtn.TextColor3 = Color3.fromRGB(150, 255, 150)
saveBtn.TextSize = 10
saveBtn.Font = Enum.Font.Gotham
saveBtn.Text = "💾 SAVE"
saveBtn.BorderSizePixel = 1
saveBtn.Parent = funcFrame

-- Frame de TP
local tpFrame = Instance.new("Frame")
tpFrame.Size = UDim2.new(1, -10, 0, 22)
tpFrame.Position = UDim2.new(0, 5, 0, 134)
tpFrame.BackgroundTransparency = 1
tpFrame.Parent = panel

local markBtn = Instance.new("TextButton")
markBtn.Name = "MarkBtn"
markBtn.Size = UDim2.new(0.48, 0, 1, 0)
markBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 130)
markBtn.TextColor3 = Color3.fromRGB(150, 200, 255)
markBtn.TextSize = 10
markBtn.Font = Enum.Font.Gotham
markBtn.Text = "📍 MARK"
markBtn.BorderSizePixel = 1
markBtn.Parent = tpFrame

local tpBtn = Instance.new("TextButton")
tpBtn.Name = "TPBtn"
tpBtn.Size = UDim2.new(0.48, 0, 1, 0)
tpBtn.Position = UDim2.new(0.52, 0, 0, 0)
tpBtn.BackgroundColor3 = Color3.fromRGB(100, 70, 130)
tpBtn.TextColor3 = Color3.fromRGB(255, 150, 255)
tpBtn.TextSize = 10
tpBtn.Font = Enum.Font.Gotham
tpBtn.Text = "🚀 TELEPORT"
tpBtn.BorderSizePixel = 1
tpBtn.Parent = tpFrame

-- Auto Speed Button
local autoBtn = Instance.new("TextButton")
autoBtn.Name = "AutoBtn"
autoBtn.Size = UDim2.new(1, 0, 0, 22)
autoBtn.Position = UDim2.new(0, 0, 0, 157)
autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
autoBtn.TextColor3 = Color3.fromRGB(180, 180, 220)
autoBtn.TextSize = 10
autoBtn.Font = Enum.Font.Gotham
autoBtn.Text = "⏱️ AUTO SPEED: OFF"
autoBtn.BorderSizePixel = 0
autoBtn.Parent = panel

-- Frame Slider
local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.new(1, -20, 0, 70)
sliderFrame.Position = UDim2.new(0, 10, 0, 180)
sliderFrame.BackgroundTransparency = 1
sliderFrame.Parent = panel

-- Botão Diminuir
local decreaseBtn = Instance.new("TextButton")
decreaseBtn.Name = "DecreaseBtn"
decreaseBtn.Size = UDim2.new(0, 50, 0, 45)
decreaseBtn.Position = UDim2.new(0, 0, 0.5, -22)
decreaseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
decreaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
decreaseBtn.TextSize = 26
decreaseBtn.Font = Enum.Font.GothamBold
decreaseBtn.Text = "−"
decreaseBtn.BorderSizePixel = 2
decreaseBtn.Parent = sliderFrame

-- Slider
local sliderBg = Instance.new("Frame")
sliderBg.Name = "SliderBg"
sliderBg.Size = UDim2.new(0, 110, 0, 10)
sliderBg.Position = UDim2.new(0, 55, 0.5, -5)
sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
sliderBg.BorderColor3 = Color3.fromRGB(0, 150, 255)
sliderBg.BorderSizePixel = 2
sliderBg.Parent = sliderFrame

local sliderBtn = Instance.new("TextButton")
sliderBtn.Name = "SliderBtn"
sliderBtn.Size = UDim2.new(0, 12, 0, 16)
sliderBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
sliderBtn.BorderColor3 = Color3.fromRGB(0, 150, 80)
sliderBtn.BorderSizePixel = 2
sliderBtn.Text = ""
sliderBtn.Parent = sliderBg

-- Botão Aumentar
local increaseBtn = Instance.new("TextButton")
increaseBtn.Name = "IncreaseBtn"
increaseBtn.Size = UDim2.new(0, 50, 0, 45)
increaseBtn.Position = UDim2.new(1, -50, 0.5, -22)
increaseBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
increaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
increaseBtn.TextSize = 26
increaseBtn.Font = Enum.Font.GothamBold
increaseBtn.Text = "+"
increaseBtn.BorderSizePixel = 2
increaseBtn.Parent = sliderFrame

-- FUNÇÕES
local function updateSlider()
    local percentage = (speedValue - 0) / (2000 - 0)
    sliderBtn.Position = UDim2.new(percentage, -6, 0.5, -8)
end

local function setSpeed(value)
    speedValue = math.clamp(value, 0, 2000)
    speedLabel.Text = "Speed: " .. math.floor(speedValue)
    if humanoid then
        humanoid.WalkSpeed = speedValue
    end
    updateSlider()
end

-- EVENTOS
godBtn.MouseButton1Click:Connect(function()
    godMode = not godMode
    godBtn.TextColor3 = godMode and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 100, 100)
    godBtn.Text = godMode and "🛡️ GOD MODE: ON" or "🛡️ GOD MODE: OFF"
end)

noclipBtn.MouseButton1Click:Connect(function()
    noclipMode = not noclipMode
    noclipBtn.TextColor3 = noclipMode and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(180, 150, 255)
end)

invisBtn.MouseButton1Click:Connect(function()
    invisMode = not invisMode
    invisBtn.TextColor3 = invisMode and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(150, 150, 255)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = invisMode and 1 or 0
        end
    end
end)

freezeBtn.MouseButton1Click:Connect(function()
    freezeMode = not freezeMode
    freezeBtn.TextColor3 = freezeMode and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 150, 100)
end)

resetBtn.MouseButton1Click:Connect(function()
    setSpeed(16)
end)

saveBtn.MouseButton1Click:Connect(function()
    savedSpeed = speedValue
    saveBtn.Text = "💾 " .. math.floor(savedSpeed)
end)

markBtn.MouseButton1Click:Connect(function()
    if rootPart then
        markCFrame = rootPart.CFrame
        markTP = true
        markBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    end
end)

tpBtn.MouseButton1Click:Connect(function()
    if markTP and markCFrame and rootPart then
        rootPart.CFrame = markCFrame + Vector3.new(0, 3, 0)
    end
end)

autoBtn.MouseButton1Click:Connect(function()
    autoMode = not autoMode
    autoBtn.TextColor3 = autoMode and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(180, 180, 220)
    autoBtn.Text = autoMode and "⏱️ AUTO SPEED: ON" or "⏱️ AUTO SPEED: OFF"
end)

decreaseBtn.MouseButton1Click:Connect(function()
    setSpeed(speedValue - 10)
end)

increaseBtn.MouseButton1Click:Connect(function()
    setSpeed(speedValue + 10)
end)

sliderBtn.MouseButton1Down:Connect(function()
    draggingSlider = true
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
    end
end)

-- LOOP PRINCIPAL
RunService.RenderStepped:Connect(function()
    if not character or not character.Parent then return end
    
    -- Verificar integridade
    if not humanoid or not humanoid.Parent then
        humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
    end
    
    if not rootPart or not rootPart.Parent then
        rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
    end
    
    -- Slider arrastavél
    if draggingSlider then
        local mouse = Players.LocalPlayer:GetMouse()
        local sliderStart = sliderBg.AbsolutePosition.X
        local sliderEnd = sliderStart + sliderBg.AbsoluteSize.X
        local mouseX = math.clamp(mouse.X, sliderStart, sliderEnd)
        local percentage = (mouseX - sliderStart) / sliderBg.AbsoluteSize.X
        setSpeed(percentage * 2000)
    end
    
    -- Velocidade
    if humanoid then
        humanoid.WalkSpeed = speedValue
    end
    
    -- Noclip
    if noclipMode then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Freeze Inimigos
    if freezeMode then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local rp = p.Character:FindFirstChild("HumanoidRootPart")
                if rp then
                    rp.CanCollide = false
                    for _, part in pairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end
    end
    
    -- Auto Speed
    if autoMode then
        local newSpeed = speedValue + (autoDirection * 5)
        if newSpeed >= 2000 then
            autoDirection = -1
        elseif newSpeed <= 0 then
            autoDirection = 1
        end
        setSpeed(newSpeed)
    end
    
    -- God Mode
    if godMode and humanoid then
        humanoid.Health = humanoid.MaxHealth
    end
end)

-- Detectar morte
humanoid.Died:Connect(function()
    wait(0.1)
    player.CharacterAdded:Wait()
    character = player.Character
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    setSpeed(speedValue)
end)

updateSlider()
print("✅ Delta Speed Panel v2.5 CARREGADO!")
print("⚡ Script 100% Funcional para Delta Roblox")
print("🎮 Aproveite!")
