-- ServerScriptService/AerophobiaMap.server.lua
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local MAP_ROOT = workspace:FindFirstChild("AerophobiaMap")
if not MAP_ROOT then
    MAP_ROOT = Instance.new("Folder")
    MAP_ROOT.Name = "AerophobiaMap"
    MAP_ROOT.Parent = workspace
end

local function makePart(parent, name, size, cframe, color, material)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Color = color
    part.Material = material or Enum.Material.SmoothPlastic
    part.Anchored = true
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent
    return part
end

local function addSpawnPoint(position)
    local spawn = Instance.new("SpawnLocation")
    spawn.Size = Vector3.new(6, 1, 6)
    spawn.Shape = Enum.PartType.Cylinder
    spawn.CFrame = CFrame.new(position)
    spawn.Anchored = true
    spawn.Color = Color3.fromRGB(90, 210, 255)
    spawn.Transparency = 0.2
    spawn.Material = Enum.Material.Neon
    spawn.CanCollide = true
    spawn.Parent = MAP_ROOT
    return spawn
end

local function createIsland(position, size, baseColor)
    local island = Instance.new("Model")
    island.Name = "FloatingIsland"
    island.Parent = MAP_ROOT

    local base = makePart(island, "Base", size, CFrame.new(position), baseColor, Enum.Material.Slate)
    base.Shape = Enum.PartType.Cylinder

    -- ponteira visual para dar sensação de altura
    local top = makePart(island, "Top", Vector3.new(size.X * 0.9, 1, size.Z * 0.9), CFrame.new(position + Vector3.new(0, size.Y * 0.45, 0)), Color3.fromRGB(120, 140, 100), Enum.Material.SmoothPlastic)

    -- alguns detalhes
    for i = 1, 4 do
        local deco = makePart(
            island,
            "Rock_" .. i,
            Vector3.new(2, math.random(2, 5), 2),
            CFrame.new(
                position + Vector3.new(
                    math.random(-size.X * 0.3, size.X * 0.3),
                    (size.Y * 0.7) + math.random(0, 2),
                    math.random(-size.Z * 0.3, size.Z * 0.3)
                )
            ),
            Color3.fromRGB(70, 80, 70),
            Enum.Material.Slate
        )
        deco.Shape = Enum.PartType.Cylinder
    end

    return island
end

local function createFloatingBridge(startPos, endPos, width)
    local bridge = Instance.new("Model")
    bridge.Name = "Bridge"
    bridge.Parent = MAP_ROOT

    local distance = (endPos - startPos).Magnitude
    local center = (startPos + endPos) / 2
    local direction = (endPos - startPos).Unit
    local length = distance

    local plank = makePart(
        bridge,
        "Plank",
        Vector3.new(width, 1, length),
        CFrame.new(center) * CFrame.Angles(0, math.atan2(direction.X, direction.Z), 0),
        Color3.fromRGB(140, 112, 86),
        Enum.Material.WoodPlanks
    )
    plank.Transparency = 0.05

    return bridge
end

local function createDrone(name, startPosition, patrolPoints)
    local drone = Instance.new("Model")
    drone.Name = name
    drone.Parent = MAP_ROOT

    local core = Instance.new("Part")
    core.Name = "Core"
    core.Size = Vector3.new(2.5, 2.5, 2.5)
    core.Color = Color3.fromRGB(255, 100, 100)
    core.Material = Enum.Material.Neon
    core.Anchored = true
    core.Position = startPosition
    core.Parent = drone

    local eye1 = Instance.new("Part")
    eye1.Name = "Eye1"
    eye1.Size = Vector3.new(0.5, 0.5, 0.5)
    eye1.Color = Color3.fromRGB(255, 255, 255)
    eye1.Material = Enum.Material.Neon
    eye1.Anchored = true
    eye1.Position = startPosition + Vector3.new(0.5, 0.2, 0.8)
    eye1.Parent = drone

    local eye2 = Instance.new("Part")
    eye2.Name = "Eye2"
    eye2.Size = Vector3.new(0.5, 0.5, 0.5)
    eye2.Color = Color3.fromRGB(255, 255, 255)
    eye2.Material = Enum.Material.Neon
    eye2.Anchored = true
    eye2.Position = startPosition + Vector3.new(-0.5, 0.2, 0.8)
    eye2.Parent = drone

    local patrol = patrolPoints
    local currentIndex = 1
    local speed = 20

    local function updateDrone()
        local target = patrol[currentIndex]
        local currentPosition = core.Position
        local delta = target - currentPosition
        local move = delta.Unit * math.min(speed, delta.Magnitude)

        if delta.Magnitude < 1 then
            currentIndex += 1
            if currentIndex > #patrol then
                currentIndex = 1
            end
        else
            core.Position = currentPosition + move
            eye1.Position = core.Position + Vector3.new(0.5, 0.2, 0.8)
            eye2.Position = core.Position + Vector3.new(-0.5, 0.2, 0.8)
        end
    end

    task.spawn(function()
        while true do
            updateDrone()
            task.wait(0.05)
        end
    end)

    return drone
end

local function setupLighting()
    Lighting.ClockTime = 20
    Lighting.Brightness = 1.8
    Lighting.Ambient = Color3.fromRGB(80, 90, 110)
    Lighting.OutdoorAmbient = Color3.fromRGB(90, 96, 115)
    Lighting.FogColor = Color3.fromRGB(145, 160, 180)
    Lighting.FogStart = 250
    Lighting.FogEnd = 1200
    Lighting.ExposureCompensation = 0.25
    Lighting.ColorCorrectionEnabled = true
    Lighting.ColorCorrection.TintColor = Color3.fromRGB(180, 180, 190)
    Lighting.ColorCorrection.Contrast = 0.1
    Lighting.ColorCorrection.Saturation = -0.2
end

local function configurePlayer(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(1)
        local root = character:WaitForChild("HumanoidRootPart")
        root.CFrame = CFrame.new(Vector3.new(0, 40, 0))
    end)
end

local function setupFallRespawn()
    local function onCharacterAdded(character)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            task.wait(1)
            local player = Players:GetPlayerFromCharacter(character)
            if player then
                player:LoadCharacter()
            end
        end)

        local root = character:WaitForChild("HumanoidRootPart")
        task.spawn(function()
            while character.Parent do
                if root.Position.Y < -80 then
                    local player = Players:GetPlayerFromCharacter(character)
                    if player then
                        player:LoadCharacter()
                    end
                    break
                end
                task.wait(0.2)
            end
        end)
    end

    for _, player in ipairs(Players:GetPlayers()) do
        configurePlayer(player)
    end

    Players.PlayerAdded:Connect(function(player)
        configurePlayer(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
    end)
end

-- === MAP BUILD ===
setupLighting()

-- Chão do abismo
local voidFloor = makePart(
    MAP_ROOT,
    "VoidFloor",
    Vector3.new(300, 2, 300),
    CFrame.new(0, -60, 0),
    Color3.fromRGB(20, 25, 30),
    Enum.Material.SmoothPlastic
)
voidFloor.Transparency = 0.8

-- Ilhas
local islandPositions = {
    {Vector3.new(0, 25, 0), Vector3.new(26, 6, 26)},
    {Vector3.new(30, 35, 0), Vector3.new(22, 5, 22)},
    {Vector3.new(60, 52, 14), Vector3.new(18, 6, 18)},
    {Vector3.new(90, 70, -16), Vector3.new(20, 5, 20)},
    {Vector3.new(120, 95, 10), Vector3.new(24, 6, 24)},
}

for _, data in ipairs(islandPositions) do
    local pos, size = data[1], data[2]
    createIsland(pos, size, Color3.fromRGB(90, 120, 88))
end

-- Pontes
createFloatingBridge(Vector3.new(0, 25, 0), Vector3.new(30, 35, 0), 6)
createFloatingBridge(Vector3.new(30, 35, 0), Vector3.new(60, 52, 14), 6)
createFloatingBridge(Vector3.new(60, 52, 14), Vector3.new(90, 70, -16), 6)
createFloatingBridge(Vector3.new(90, 70, -16), Vector3.new(120, 95, 10), 6)

-- Spawn points
addSpawnPoint(Vector3.new(0, 35, 0))
addSpawnPoint(Vector3.new(30, 45, 0))
addSpawnPoint(Vector3.new(60, 60, 15))

-- Drone patrolling
local drone = createDrone("Drone_01", Vector3.new(10, 42, 0), {
    Vector3.new(10, 42, 0),
    Vector3.new(40, 50, -10),
    Vector3.new(75, 62, 15),
    Vector3.new(95, 80, -20),
    Vector3.new(120, 100, 8),
})

-- Setup players
for _, player in ipairs(Players:GetPlayers()) do
    local character = player.Character
    if character then
        local root = character:WaitForChild("HumanoidRootPart")
        root.CFrame = CFrame.new(Vector3.new(0, 35, 0))
    end
end

Players.CharacterAutoLoads = false
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        local root = character:WaitForChild("HumanoidRootPart")
        root.CFrame = CFrame.new(Vector3.new(0, 35, 0))
    end)
end)

setupFallRespawn()
