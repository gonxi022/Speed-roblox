-- KILLALL FUNCIONAL PARA PRISON LIFE 2024
-- Basado en los RemoteEvents actuales encontrados

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Solo ejecutar en Prison Life
if game.PlaceId ~= 155615604 then
    warn("Solo para Prison Life!")
    return
end

-- Crear GUI optimizada
local gui = Instance.new("ScreenGui")
gui.Name = "PrisonLifeKillAll"
gui.Parent = player.PlayerGui
gui.ResetOnSpawn = false

-- Frame principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 220)
frame.Position = UDim2.new(0, 10, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Esquinas redondeadas
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- Borde brillante
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 100, 100)
stroke.Thickness = 2
stroke.Parent = frame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Text = "🏢 Prison Life Hack"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

-- Status del jugador
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 40)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "👤 " .. player.Name .. " | Inmates"
statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.SourceSans
statusLabel.Parent = frame

-- Contador de jugadores
local playerCount = Instance.new("TextLabel")
playerCount.Size = UDim2.new(1, 0, 0, 20)
playerCount.Position = UDim2.new(0, 0, 0, 60)
playerCount.BackgroundTransparency = 1
playerCount.Text = "🎯 Objetivos: " .. (#Players:GetPlayers() - 1)
playerCount.TextColor3 = Color3.fromRGB(255, 255, 255)
playerCount.TextSize = 11
playerCount.Font = Enum.Font.SourceSans
playerCount.Parent = frame

-- Botón KillAll Melee
local meleeButton = Instance.new("TextButton")
meleeButton.Size = UDim2.new(0.9, 0, 0, 35)
meleeButton.Position = UDim2.new(0.05, 0, 0, 85)
meleeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
meleeButton.Text = "⚔️ Melee KillAll"
meleeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
meleeButton.TextSize = 13
meleeButton.Font = Enum.Font.SourceSansBold
meleeButton.Parent = frame

-- Botón KillAll con Armas
local shootButton = Instance.new("TextButton")
shootButton.Size = UDim2.new(0.9, 0, 0, 35)
shootButton.Position = UDim2.new(0.05, 0, 0, 125)
shootButton.BackgroundColor3 = Color3.fromRGB(255, 100, 50)
shootButton.Text = "🔫 Shoot KillAll"
shootButton.TextColor3 = Color3.fromRGB(255, 255, 255)
shootButton.TextSize = 13
shootButton.Font = Enum.Font.SourceSansBold  
shootButton.Parent = frame

-- Botón Bring All
local bringButton = Instance.new("TextButton")
bringButton.Size = UDim2.new(0.9, 0, 0, 35)
bringButton.Position = UDim2.new(0.05, 0, 0, 165)
bringButton.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
bringButton.Text = "📍 Bring All"
bringButton.TextColor3 = Color3.fromRGB(255, 255, 255)
bringButton.TextSize = 13
bringButton.Font = Enum.Font.SourceSansBold
bringButton.Parent = frame

-- Agregar esquinas a botones
for _, button in pairs({meleeButton, shootButton, bringButton}) do
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
end

-- Variables globales
local isExecuting = false

-- Función para actualizar contador
local function updatePlayerCount()
    spawn(function()
        while playerCount and playerCount.Parent do
            playerCount.Text = "🎯 Objetivos: " .. (#Players:GetPlayers() - 1)
            wait(3)
        end
    end)
end

-- Función KillAll con meleeEvent
local function meleeKillAll()
    if isExecuting then return end
    isExecuting = true
    
    meleeButton.Text = "⚔️ Matando..."
    meleeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
    
    local killedCount = 0
    local meleeRemote = ReplicatedStorage:FindFirstChild("meleeEvent")
    
    if meleeRemote then
        print("🗡️ Usando meleeEvent...")
        
        for _, target in pairs(Players:GetPlayers()) do
            if target ~= player and target.Character and target.Character:FindFirstChild("Humanoid") then
                pcall(function()
                    -- Método principal para Prison Life
                    meleeRemote:FireServer(target.Character.Humanoid)
                    killedCount = killedCount + 1
                    print("Atacando a:", target.Name)
                end)
                wait(0.08) -- Timing optimizado
            end
        end
        
        wait(1)
        
        if killedCount > 0 then
            meleeButton.Text = "⚔️ Matados: " .. killedCount
            meleeButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            print("✅ MeleeKillAll completado:", killedCount)
        else
            meleeButton.Text = "⚔️ Falló"
            meleeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            print("❌ MeleeKillAll falló")
        end
    else
        meleeButton.Text = "⚔️ No encontrado"
        meleeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        print("❌ meleeEvent no encontrado")
    end
    
    wait(3)
    meleeButton.Text = "⚔️ Melee KillAll"
    meleeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    isExecuting = false
end

-- Función KillAll con ShootEvent y DamageEvent
local function shootKillAll()
    if isExecuting then return end
    isExecuting = true
    
    shootButton.Text = "🔫 Disparando..."
    shootButton.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
    
    local killedCount = 0
    local shootRemote = ReplicatedStorage:FindFirstChild("ShootEvent")
    local damageRemote = ReplicatedStorage:FindFirstChild("DamageEvent")
    
    -- Verificar si tenemos armas
    local weapons = {"Remington 870", "M9", "AK-47", "Crude Knife"}
    local hasWeapon = false
    
    for _, weaponName in pairs(weapons) do
        if player.Backpack:FindFirstChild(weaponName) or (player.Character and player.Character:FindFirstChild(weaponName)) then
            hasWeapon = true
            break
        end
    end
    
    if hasWeapon then
        print("🔫 Usando armas disponibles...")
        
        -- Método 1: ShootEvent
        if shootRemote then
            for _, target in pairs(Players:GetPlayers()) do
                if target ~= player and target.Character and target.Character:FindFirstChild("Humanoid") then
                    pcall(function()
                        -- Diferentes argumentos para ShootEvent
                        shootRemote:FireServer(target.Character.Humanoid, 100)
                        shootRemote:FireServer(target.Character.Head, Vector3.new(0,0,0), 100)
                        killedCount = killedCount + 1
                    end)
                    wait(0.1)
                end
            end
        end
        
        -- Método 2: DamageEvent  
        if damageRemote then
            for _, target in pairs(Players:GetPlayers()) do
                if target ~= player and target.Character and target.Character:FindFirstChild("Humanoid") then
                    pcall(function()
                        damageRemote:FireServer(target.Character.Humanoid, 100)
                        damageRemote:FireServer(target.Character, 100)
                    end)
                    wait(0.05)
                end
            end
        end
        
        wait(2)
        
        if killedCount > 0 then
            shootButton.Text = "🔫 Matados: " .. killedCount
            shootButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            print("✅ ShootKillAll completado:", killedCount)
        else
            shootButton.Text = "🔫 Falló"
            shootButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            print("❌ ShootKillAll falló")
        end
    else
        shootButton.Text = "🔫 Sin armas"
        shootButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        print("⚠️ Necesitas armas de la armería")
    end
    
    wait(3)
    shootButton.Text = "🔫 Shoot KillAll"
    shootButton.BackgroundColor3 = Color3.fromRGB(255, 100, 50)
    isExecuting = false
end

-- Función Bring All (más confiable)
local function bringAll()
    if isExecuting then return end
    isExecuting = true
    
    bringButton.Text = "📍 Trayendo..."
    bringButton.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
    
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        bringButton.Text = "📍 Sin personaje"
        bringButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        wait(2)
        bringButton.Text = "📍 Bring All"
        bringButton.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
        isExecuting = false
        return
    end
    
    local broughtCount = 0
    local myPosition = player.Character.HumanoidRootPart.CFrame
    
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                -- Traer jugadores cerca tuyo
                target.Character.HumanoidRootPart.CFrame = myPosition + Vector3.new(
                    math.random(-8, 8), 
                    0, 
                    math.random(-8, 8)
                )
                broughtCount = broughtCount + 1
                print("Trayendo a:", target.Name)
            end)
            wait(0.1)
        end
    end
    
    bringButton.Text = "📍 Traídos: " .. broughtCount
    bringButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    print("✅ BringAll completado:", broughtCount)
    
    wait(3)
    bringButton.Text = "📍 Bring All"
    bringButton.BackgroundColor3 = Color3.fromRGB(50, 255, 100)
    isExecuting = false
end

-- Conectar eventos
meleeButton.MouseButton1Click:Connect(meleeKillAll)
meleeButton.TouchTap:Connect(meleeKillAll)

shootButton.MouseButton1Click:Connect(shootKillAll)
shootButton.TouchTap:Connect(shootKillAll)

bringButton.MouseButton1Click:Connect(bringAll)
bringButton.TouchTap:Connect(bringAll)

-- Iniciar contador
updatePlayerCount()

print("🏢 Prison Life KillAll GUI cargada!")
print("📱 Compatible con KRNL Android")
print("⚠️ Consigue armas en la armería para mejor efectividad")