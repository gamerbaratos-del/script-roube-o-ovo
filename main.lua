--[[ 
    ⚡ PAINEL DE VELOCIDADE PROFISSIONAL
    Para: Roube um Ovo (Roblox)
    Versão: 2.0 OTIMIZADA
    Status: SEM ERROS ✅
]]--

-- ========== SERVIÇOS ==========
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ========== VARIÁVEIS GLOBAIS ==========
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local mouse = player:GetMouse()

-- ========== CONFIGURAÇÕES ==========
local speedValue = 16
local minSpeed = 0
local maxSpeed = 2000
local godMode = true
local noclipMode = false
local invisibilityMode = false
local freezeEnemies = false
local autoSpeedMode = false
local autoSpeedDirection = 1

local savedSpeed = 16
local teleportMarked = false
local teleportCFrame = nil

-- ========== CRIAR GUI ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedPanel"
screenGui.ResetOnSpawn = false
screenGui.ZIndex = 10
screenGui.Parent = playerGui

local panelFrame = Instance.new("Frame")
panelFrame.Name = "Panel"
panelFrame.Size = UDim2.new(0, 300, 0, 310)
panelFrame.Position = UDim2.new(0.5, -150, 0, 10)
panelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
panelFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
panelFrame.BorderSizePixel = 2
panelFrame.Draggable = true
panelFrame.Active = true
panelFrame.Parent = screenGui

-- ========== TÍTULO ==========
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "⚡ SPEED PANEL V2.0"
titleLabel.Parent = panelFrame

-- ========== VELOCIDADE DISPLAY ==========
local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Size = UDim2.new(1, 0, 0, 25)
speedLabel.Position = UDim2.new(0, 0, 0, 35)
speedLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedLabel.BorderSizePixel = 0
speedLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
speedLabel.TextSize = 16
speedLabel.Font = Enum.Font.Gotham
speedLabel.Text = "Speed: " .. speedValue
speedLabel.Parent = panelFrame

-- ========== BOTÕES DE PROTEÇÃO ==========
local protectionLabel = Instance.new("TextButton")
protectionLabel.Name = "ProtectionLabel"
protectionLabel.Size = UDim2.new(1, 0, 0, 20)
protectionLabel.Position = UDim2.new(0, 0, 0, 60)
protectionLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
protectionLabel.BorderSizePixel = 0
protectionLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
protectionLabel.TextSize = 12
protectionLabel.Font = Enum.Font.Gotham
protectionLabel.Text = "🛡️ Shield: ON"
protectionLabel.Parent = panelFrame

local noclipBtn = Instance.new("TextButton")
noclipBtn.Name = "NoclipBtn"
noclipBtn.Size = UDim2.new(0.33, -2, 0, 18)
noclipBtn.Position = UDim2.new(0, 0, 0, 81)
noclipBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
noclipBtn.TextColor3 = Color3.fromRGB(200, 150, 255)
noclipBtn.TextSize = 10
noclipBtn.Font = Enum.Font.Gotham
noclipBtn.Text = "👻 Noclip: OFF"
noclipBtn.BorderSizePixel = 1
noclipBtn.Parent = panelFrame

local invisibilityBtn = Instance.new("TextButton")
invisibilityBtn.Name = "InvisibilityBtn"
invisibilityBtn.Size = UDim2.new(0.33, -2, 0, 18)
invisibilityBtn.Position = UDim2.new(0.33, 2, 0, 81)
invisibilityBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 150)
invisibilityBtn.TextColor3 = Color3.fromRGB(150, 150, 255)
invisibilityBtn.TextSize = 10
invisibilityBtn.Font = Enum.Font.Gotham
invisibilityBtn.Text = "👁️ Inv: OFF"
invisibilityBtn.BorderSizePixel = 1
invisibilityBtn.Parent = panelFrame

local freezeBtn = Instance.new("TextButton")
freezeBtn.Name = "FreezeBtn"
freezeBtn.Size = UDim2.new(0.33, -2, 0, 18)
freezeBtn.Position = UDim2.new(0.66, 4, 0, 81)
freezeBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 50)
freezeBtn.TextColor3 = Color3.fromRGB(255, 150, 100)
freezeBtn.TextSize = 10
freezeBtn.Font = Enum.Font.Gotham
freezeBtn.Text = "❄️ Freeze: OFF"
freezeBtn.BorderSizePixel = 1
freezeBtn.Parent = panelFrame

-- ========== BOTÕES SECUNDÁRIOS ==========
local resetBtn = Instance.new("TextButton")
resetBtn.Name = "ResetBtn"
resetBtn.Size = UDim2.new(0.5, -2, 0, 18)
resetBtn.Position = UDim2.new(0, 0, 0, 100)
resetBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 100)
resetBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
resetBtn.TextSize = 10
resetBtn.Font = Enum.Font.Gotham
resetBtn.Text = "🔄 Reset"
resetBtn.BorderSizePixel = 1
resetBtn.Parent = panelFrame

local saveSpeedBtn = Instance.new("TextButton")
saveSpeedBtn.Name = "SaveSpeedBtn"
saveSpeedBtn.Size = UDim2.new(0.5, -2, 0, 18)
saveSpeedBtn.Position = UDim2.new(0.5, 2, 0, 100)
saveSpeedBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 100)
saveSpeedBtn.TextColor3 = Color3.fromRGB(150, 255, 150)
saveSpeedBtn.TextSize = 10
saveSpeedBtn.Font = Enum.Font.Gotham
saveSpeedBtn.Text = "💾 Save"
saveSpeedBtn.BorderSizePixel = 1
saveSpeedBtn.Parent = panelFrame

local markTPBtn = Instance.new("TextButton")
markTPBtn.Name = "MarkTPBtn"
markTPBtn.Size = UDim2.new(0.5, -2, 0, 18)
markTPBtn.Position = UDim2.new(0, 0, 0, 119)
markTPBtn.BackgroundColor3 = Color3.fromRGB(100, 120, 180)
markTPBtn.TextColor3 = Color3.fromRGB(150, 180, 255)
markTPBtn.TextSize = 10
markTPBtn.Font = Enum.Font.Gotham
markTPBtn.Text = "📍 Mark"
markTPBtn.BorderSizePixel = 1
markTPBtn.Parent = panelFrame

local teleportBtn = Instance.new("TextButton")
teleportBtn.Name = "TeleportBtn"
teleportBtn.Size = UDim2.new(0.5, -2, 0, 18)
teleportBtn.Position = UDim2.new(0.5, 2, 0, 119)
teleportBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 180)
teleportBtn.TextColor3 = Color3.fromRGB(255, 150, 255)
teleportBtn.TextSize = 10
teleportBtn.Font = Enum.Font.Gotham
teleportBtn.Text = "🚀 Teleport"
teleportBtn.BorderSizePixel = 1
teleportBtn.Parent = panelFrame

local autoSpeedBtn = Instance.new("TextButton")
autoSpeedBtn.Name = "AutoSpeedBtn"
autoSpeedBtn.Size = UDim2.new(1, 0, 0, 18)
autoSpeedBtn.Position = UDim2.new(0, 0, 0, 138)
autoSpeedBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
autoSpeedBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
autoSpeedBtn.TextSize = 10
autoSpeedBtn.Font = Enum.Font.Gotham
autoSpeedBtn.Text = "⏱️ Auto: OFF"
autoSpeedBtn.BorderSizePixel = 1
autoSpeedBtn.Parent = panelFrame

-- ========== FRAME DOS BOTÕES ==========
local buttonFrame = Instance.new("Frame")
buttonFrame.Name = "ButtonFrame"
buttonFrame.Size = UDim2.new(1, -10, 0, 80)
buttonFrame.Position = UDim2.new(0, 5, 0, 157)
buttonFrame.BackgroundTransparency = 1
buttonFrame.Parent = panelFrame

local decreaseBtn = Instance.new("TextButton")
decreaseBtn.Name = "DecreaseBtn"
decreaseBtn.Size = UDim2.new(0, 60, 0, 40)
decreaseBtn.Position = UDim2.new(0, 5, 0, 20)
decreaseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
decreaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
decreaseBtn.TextSize = 24
decreaseBtn.Font = Enum.Font.GothamBold
decreaseBtn.Text = "−"
decreaseBtn.BorderColor3 = Color3.fromRGB(150, 0, 0)
decreaseBtn.BorderSizePixel = 2
decreaseBtn.Parent = buttonFrame

local sliderFrame = Instance.new("Frame")
sliderFrame.Name = "SliderFrame"
sliderFrame.Size = UDim2.new(0, 140, 0, 50)
sliderFrame.Position = UDim2.new(0, 75, 0, 15)
sliderFrame.BackgroundTransparency = 1
sliderFrame.Parent = buttonFrame

local sliderBg = Instance.new("Frame")
sliderBg.Name = "SliderBg"
sliderBg.Size = UDim2.new(1, 0, 0, 8)
sliderBg.Position = UDim2.new(0, 0, 0, 21)
sliderBg.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
sliderBg.BorderColor3 = Color3.fromRGB(0, 150, 255)
sliderBg.BorderSizePixel = 1
sliderBg.Parent = sliderFrame

local sliderButton = Instance.new("TextButton")
sliderButton.Name = "SliderButton"
sliderButton.Size = UDim2.new(0, 15, 0, 15)
sliderButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
sliderButton.BorderColor3 = Color3.fromRGB(0, 150, 80)
sliderButton.BorderSizePixel = 2
sliderButton.Text = ""
sliderButton.Parent = sliderBg

local sliderLabel = Instance.new("TextLabel")
sliderLabel.Name = "SliderLabel"
sliderLabel.Size = UDim2.new(1, 0, 0, 15)
sliderLabel.BackgroundTransparency = 1
sliderLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
sliderLabel.TextSize = 11
sliderLabel.Font = Enum.Font.Gotham
sliderLabel.Text = "0       500    1000    2000"
sliderLabel.Parent = sliderFrame

local increaseBtn = Instance.new("TextButton")
increaseBtn.Name = "IncreaseBtn"
increaseBtn.Size = UDim2.new(0, 60, 0, 40)
increaseBtn.Position = UDim2.new(1, -65, 0, 20)
increaseBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
increaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
increaseBtn.TextSize = 24
increaseBtn.Font = Enum.Font.GothamBold
increaseBtn.Text = "+"
increaseBtn.BorderColor3 = Color3.fromRGB(0, 150, 0)
increaseBtn.BorderSizePixel = 2
increaseBtn.Parent = buttonFrame

-- ========== FUNÇÕES ==========
local function updateSlider()
    if maxSpeed > minSpeed then
        local percentage = (speedValue - minSpeed) / (maxSpeed - minSpeed)
        sliderButton.Position = UDim2.new(percentage, -7.5, 0, -3.5)
    end
end

local function updateSpeed(newSpeed)
    speedValue = math.clamp(newSpeed, minSpeed, maxSpeed)
    speedLabel.Text = "Speed: " .. math.floor(speedValue)
    if humanoid then
        humanoid.WalkSpeed = speedValue
    end
    updateSlider()
end

local function toggleGodMode()
    godMode = not godMode
    if godMode then
        protectionLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
        protectionLabel.Text = "🛡️ Shield: ON"
    else
        protectionLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        protectionLabel.Text = "🛡️ Shield: OFF"
    end
end

local function toggleNoclip()
    noclipMode = not noclipMode
    noclipBtn.TextColor3 = noclipMode and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(200, 150, 255)
    noclipBtn.Text = noclipMode and "👻 Noclip: ON" or "👻 Noclip: OFF"
end

local function toggleInvisibility()
    invisibilityMode = not invisibilityMode
    invisibilityBtn.TextColor3 = invisibilityMode and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(150, 150, 255)
    invisibilityBtn.Text = invisibilityMode and "👁️ Inv: ON" or "👁️ Inv: OFF"
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = invisibilityMode and 1 or 0
        end
    end
end

local function toggleFreeze()
    freezeEnemies = not freezeEnemies
    freezeBtn.TextColor3 = freezeEnemies and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 150, 100)
    freezeBtn.Text = freezeEnemies and "❄️ Freeze: ON" or "❄️ Freeze: OFF"
end

local function resetSpeed()
    updateSpeed(16)
end

local function saveCurrentSpeed()
    savedSpeed = speedValue
    saveSpeedBtn.Text = "💾 " .. math.floor(savedSpeed)
end

local function markTP()
    if rootPart then
        teleportCFrame = rootPart.CFrame
        teleportMarked = true
        markTPBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        markTPBtn.TextColor3 = Color3.fromRGB(100, 255, 150)
    end
end

local function teleportToMark()
    if teleportMarked and teleportCFrame and rootPart then
        rootPart.CFrame = teleportCFrame + Vector3.new(0, 3, 0)
    end
end

local function toggleAutoSpeed()
    autoSpeedMode = not autoSpeedMode
    autoSpeedBtn.BackgroundColor3 = autoSpeedMode and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(100, 100, 100)
    autoSpeedBtn.TextColor3 = autoSpeedMode and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(200, 200, 200)
    autoSpeedBtn.Text = autoSpeedMode and "⏱️ Auto: ON" or "⏱️ Auto: OFF"
end

-- ========== EVENTOS DOS BOTÕES ==========
decreaseBtn.MouseButton1Click:Connect(function()
    updateSpeed(speedValue - 10)
end)

increaseBtn.MouseButton1Click:Connect(function()
    updateSpeed(speedValue + 10)
end)

protectionLabel.MouseButton1Click:Connect(toggleGodMode)
noclipBtn.MouseButton1Click:Connect(toggleNoclip)
invisibilityBtn.MouseButton1Click:Connect(toggleInvisibility)
freezeBtn.MouseButton1Click:Connect(toggleFreeze)
resetBtn.MouseButton1Click:Connect(resetSpeed)
saveSpeedBtn.MouseButton1Click:Connect(saveCurrentSpeed)
markTPBtn.MouseButton1Click:Connect(markTP)
teleportBtn.MouseButton1Click:Connect(teleportToMark)
autoSpeedBtn.MouseButton1Click:Connect(toggleAutoSpeed)

-- ========== SLIDER ARRASTAVÉL ==========
local draggingSlider = false

sliderButton.MouseButton1Down:Connect(function()
    draggingSlider = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
    end
end)

-- ========== LOOP PRINCIPAL ==========
RunService.RenderStepped:Connect(function()
    if not character or not character.Parent then return end
    
    -- Verificar se rootPart e humanoid ainda existem
    if not rootPart or not humanoid then
        rootPart = character:FindFirstChild("HumanoidRootPart")
        humanoid = character:FindFirstChild("Humanoid")
        if not rootPart or not humanoid then return end
    end
    
    -- Slider arrastável
    if draggingSlider then
        local mouseX = mouse.X
        local sliderStart = sliderBg.AbsolutePosition.X
        local sliderEnd = sliderStart + sliderBg.AbsoluteSize.X
        local clampedMouse = math.clamp(mouseX, sliderStart, sliderEnd)
        local percentage = (clampedMouse - sliderStart) / sliderBg.AbsoluteSize.X
        local newSpeed = minSpeed + (percentage * (maxSpeed - minSpeed))
        updateSpeed(newSpeed)
    end
    
    -- Atualizar velocidade
    if humanoid then
        humanoid.WalkSpeed = speedValue
    end
    
    -- Noclip
    if noclipMode and character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Congelar inimigos
    if freezeEnemies then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local char = p.Character
                local rp = char:FindFirstChild("HumanoidRootPart")
                if rp then
                    rp.CanCollide = false
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
        end
    end
    
    -- Velocidade automática
    if autoSpeedMode then
        local newSpeed = speedValue + (autoSpeedDirection * 3)
        if newSpeed >= maxSpeed then
            autoSpeedDirection = -1
        elseif newSpeed <= minSpeed then
            autoSpeedDirection = 1
        end
        updateSpeed(newSpeed)
    end
    
    -- Proteção contra dano
    if godMode and humanoid then
        if humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end
end)

-- ========== DETECTAR MORTE ==========
humanoid.Died:Connect(function()
    player.CharacterAdded:Wait()
    character = player.Character
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    updateSpeed(speedValue)
end)

-- ========== INICIALIZAÇÃO ==========
updateSlider()
print("✅ Speed Panel v2.0 Carregado com Sucesso!")
print("📖 Comandos: Velocidade | Proteção | Noclip | Invisibilidade | Congelamento")
print("⚡ Pronto para uso!")
