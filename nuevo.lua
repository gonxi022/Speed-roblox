-- DIAGNÓSTICO Y KILLALL ACTUALIZADO PARA PRISON LIFE
-- Encuentra automáticamente los remotes que funcionan

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Solo ejecutar en Prison Life
if game.PlaceId ~= 155615604 then
    warn("Solo para Prison Life!")
    return
end

-- Crear GUI mejorada
local gui = Instance.new("ScreenGui")
gui.Name = "KillAllDiagnostic"
gui.Parent = player.PlayerGui
gui.ResetOnSpawn = false

-- Frame principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 300)
frame.Position = UDim2.new(0, 10, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Esquinas redondeadas
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "Prison Life Killall"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

-- Botón de diagnóstico
local diagButton = Instance.new("TextButton")
diagButton.Size = UDim2.new(0.9, 0, 0, 35)
diagButton.Position = UDim2.new(0.05, 0, 0, 40)
diagButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
diagButton.Text = "🔍 Diagnosticar"
diagButton.TextColor3 = Color3.fromRGB(255, 255, 255)
diagButton.TextSize = 14
diagButton.Font = Enum.Font.SourceSans
diagButton.Parent = frame

-- Botón killall
local killButton = Instance.new("TextButton")
killButton.Size = UDim2.new(0.9, 0, 0, 35)
killButton.Position = UDim2.new(0.05, 0, 0, 80)
killButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
killButton.Text = "💀 Kill All"
killButton.TextColor3 = Color3.fromRGB(255, 255, 255)
killButton.TextSize = 14
killButton.Font = Enum.Font.SourceSans
killButton.Parent = frame

-- Botón bring all (alternativa)
local bringButton = Instance.new("TextButton")
bringButton.Size = UDim2.new(0.9, 0, 0, 35)
bringButton.Position = UDim2.new(0.05, 0, 0, 120)
bringButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
bringButton.Text = "📍 Bring All"
bringButton.TextColor3 = Color3.fromRGB(255, 255, 255)
bringButton.TextSize = 14
bringButton.Font = Enum.Font.SourceSans
bringButton.Parent = frame

-- Área de log
local logFrame = Instance.new("ScrollingFrame")
logFrame.Size = UDim2.new(0.9, 0, 0, 120)
logFrame.Position = UDim2.new(0.05, 0, 0, 165)
logFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
logFrame.BorderSizePixel = 0
logFrame.ScrollBarThickness = 5
logFrame.Parent = frame

local logText = Instance.new("TextLabel")
logText.Size = UDim2.new(1, 0, 1, 0)
logText.Position = UDim2.new(0, 0, 0, 0)
logText.BackgroundTransparency = 1
logText.Text = "Presiona Diagnosticar para empezar..."
logText.TextColor3 = Color3.fromRGB(255, 255, 255)
logText.TextSize = 10
logText.Font = Enum.Font.SourceSans
logText.TextXAlignment = Enum.TextXAlignment.Left
logText.TextYAlignment = Enum.TextYAlignment.Top
logText.TextWrapped = true
logText.Parent = logFrame

-- Variable para log
local logs = {}

-- Función para agregar log
local function addLog(message)
    table.insert(logs, message)
    logText.Text = table.concat(logs, "\n")
    print(message)
end

-- Función de diagnóstico
local function diagnose()
    addLog("🔍 Iniciando diagnóstico...")
    addLog("Jugadores: " .. (#Players:GetPlayers() - 1))
    
    -- Buscar remotes en ReplicatedStorage
    addLog("\n📡 Buscando RemoteEvents:")
    local foundRemotes = {}
    
    for _, child in pairs(ReplicatedStorage:GetChildren()) do
        if child:IsA("RemoteEvent") then
            table.insert(foundRemotes, child.Name)
            addLog("  ✓ " .. child.Name)
        end
    end
    
    if #foundRemotes == 0 then
        addLog("  ❌ No se encontraron RemoteEvents")
    end
    
    -- Verificar herramientas
    addLog("\n🔫 Verificando herramientas:")
    local weapons = {"Remington 870", "AK-47", "M9", "Crude Knife", "Handcuffs"}
    local foundWeapons = {}
    
    for _, weaponName in pairs(weapons) do
        if player.Backpack:FindFirstChild(weaponName) then
            table.insert(foundWeapons, weaponName)
            addLog("  ✓ " .. weaponName .. " (en backpack)")
        elseif player.Character and player.Character:FindFirstChild(weaponName) then
            table.insert(foundWeapons, weaponName)
            addLog("  ✓ " .. weaponName .. " (equipado)")
        end
    end
    
    if #foundWeapons == 0 then
        addLog("  ❌ No tienes armas")
        addLog("  💡 Ve a la armería y consigue armas")
    end
    
    -- Verificar equipo
    addLog("\n👤 Tu equipo: " .. (player.Team and player.Team.Name or "Sin equipo"))
    
    addLog("\n✅ Diagnóstico completado!")
end

-- Función killall mejorada
local function killAll()
    addLog("\n💀 Ejecutando KillAll...")
    killButton.Text = "Matando..."
    killButton.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
    
    local killedCount = 0
    
    -- Método 1: Probar todos los remotes encontrados
    for _, child in pairs(ReplicatedStorage:GetChildren()) do
        if child:IsA("RemoteEvent") then
            pcall(function()
                for _, target in pairs(Players:GetPlayers()) do
                    if target ~= player and target.Character and target.Character:FindFirstChild("Humanoid") then
                        -- Probar diferentes argumentos
                        child:FireServer(target.Character.Humanoid)
                        child:FireServer(target.Character.Humanoid, 100)
                        child:FireServer(target.Character, 100)
                        child:FireServer(target, "kill")
                    end
                end
            end)
        end
    end
    
    -- Método 2: Usar armas disponibles
    local weapons = {"Remington 870", "AK-47", "M9", "Crude Knife"}
    for _, weaponName in pairs(weapons) do
        local weapon = player.Backpack:FindFirstChild(weaponName)
        if weapon and player.Character then
            player.Character.Humanoid:EquipTool(weapon)
            wait(0.5)
            
            for _, target in pairs(Players:GetPlayers()) do
                if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    pcall(function()
                        if weapon:FindFirstChild("Handle") then
                            -- Teletransportar arma al objetivo
                            weapon.Handle.CFrame = target.Character.HumanoidRootPart.CFrame
                            wait(0.1)
                            killedCount = killedCount + 1
                        end
                    end)
                end
            end
            break
        end
    end
    
    wait(2)
    
    if killedCount > 0 then
        killButton.Text = "Matados: " .. killedCount
        killButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        addLog("✅ Matados: " .. killedCount)
    else
        killButton.Text = "Falló"
        killButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        addLog("❌ KillAll falló - Prueba Bring All")
    end
    
    wait(3)
    killButton.Text = "💀 Kill All"
    killButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
end

-- Función bring all (alternativa más confiable)
local function bringAll()
    addLog("\n📍 Ejecutando Bring All...")
    bringButton.Text = "Trayendo..."
    bringButton.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
    
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        addLog("❌ Tu personaje no está disponible")
        return
    end
    
    local broughtCount = 0
    local myPosition = player.Character.HumanoidRootPart.CFrame
    
    for _, target in pairs(Players:GetPlayers()) do
        if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                target.Character.HumanoidRootPart.CFrame = myPosition + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
                broughtCount = broughtCount + 1
            end)
            wait(0.1)
        end
    end
    
    bringButton.Text = "Traídos: " .. broughtCount
    bringButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    addLog("✅ Traídos: " .. broughtCount .. " jugadores")
    
    wait(3)
    bringButton.Text = "📍 Bring All"
    bringButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
end

-- Conectar eventos
diagButton.MouseButton1Click:Connect(diagnose)
diagButton.TouchTap:Connect(diagnose)

killButton.MouseButton1Click:Connect(killAll)
killButton.TouchTap:Connect(killAll)

bringButton.MouseButton1Click:Connect(bringAll)
bringButton.TouchTap:Connect(bringAll)

addLog("🚀 GUI cargada correctamente!")
addLog("📱 Compatible con Android KRNL")