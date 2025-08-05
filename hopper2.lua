-- Steal A Fish Server Hopper para Android/KRNL - VERSIÓN CORREGIDA
-- Optimizado para pantalla táctil

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local gameId = game.PlaceId

-- Variables globales
local isScanning = false
local serverList = {}
local mainGui = nil

-- Función para crear la GUI con correcciones visuales
local function createGUI()
    -- Eliminar GUI anterior si existe
    local existingGui = PlayerGui:FindFirstChild("StealFishHopper")
    if existingGui then
        existingGui:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StealFishHopper"
    screenGui.Parent = PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Marco principal (CORREGIDO: tamaño y posición mejorados)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 380, 0, 520)
    mainFrame.Position = UDim2.new(0.5, -190, 0.5, -260)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 120)
    mainFrame.Parent = screenGui
    mainFrame.ZIndex = 10
    
    -- Esquinas redondeadas
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame
    
    -- CORREGIDO: Título con mejor contraste y tamaño
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title" 
    titleLabel.Size = UDim2.new(1, -10, 0, 60)
    titleLabel.Position = UDim2.new(0, 5, 0, 5)
    titleLabel.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = "🐟 STEAL A FISH SERVER HOPPER"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.TextScaled = false
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextStrokeTransparency = 0.8
    titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    titleLabel.Parent = mainFrame
    titleLabel.ZIndex = 11
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleLabel
    
    -- CORREGIDO: Botón de escaneo más visible
    local scanButton = Instance.new("TextButton")
    scanButton.Name = "ScanButton"
    scanButton.Size = UDim2.new(0, 350, 0, 50)
    scanButton.Position = UDim2.new(0, 15, 0, 80)
    scanButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    scanButton.BorderSizePixel = 2
    scanButton.BorderColor3 = Color3.fromRGB(30, 120, 30)
    scanButton.Text = "🔍 ESCANEAR SERVIDORES"
    scanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    scanButton.TextSize = 20
    scanButton.TextScaled = false
    scanButton.Font = Enum.Font.SourceSansBold
    scanButton.TextStrokeTransparency = 0.8
    scanButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    scanButton.Parent = mainFrame
    scanButton.ZIndex = 11
    
    local scanCorner = Instance.new("UICorner")
    scanCorner.CornerRadius = UDim.new(0, 8)
    scanCorner.Parent = scanButton
    
    -- CORREGIDO: Lista de servidores con mejor visibilidad
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ServerList"
    scrollFrame.Size = UDim2.new(0, 350, 0, 320)
    scrollFrame.Position = UDim2.new(0, 15, 0, 145)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    scrollFrame.BorderSizePixel = 2
    scrollFrame.BorderColor3 = Color3.fromRGB(80, 80, 90)
    scrollFrame.ScrollBarThickness = 12
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 130)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = mainFrame
    scrollFrame.ZIndex = 11
    
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 8)
    scrollCorner.Parent = scrollFrame
    
    -- Layout para la lista
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = scrollFrame
    
    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, 5)
    listPadding.PaddingBottom = UDim.new(0, 5)
    listPadding.PaddingLeft = UDim.new(0, 5)
    listPadding.PaddingRight = UDim.new(0, 5)
    listPadding.Parent = scrollFrame
    
    -- CORREGIDO: Estado del escaneo más visible
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(0, 350, 0, 30)
    statusLabel.Position = UDim2.new(0, 15, 0, 475)
    statusLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    statusLabel.BorderSizePixel = 1
    statusLabel.BorderColor3 = Color3.fromRGB(100, 100, 120)
    statusLabel.Text = "✅ LISTO PARA ESCANEAR"
    statusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    statusLabel.TextSize = 16
    statusLabel.Font = Enum.Font.SourceSansBold
    statusLabel.TextStrokeTransparency = 0.8
    statusLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    statusLabel.Parent = mainFrame
    statusLabel.ZIndex = 11
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 6)
    statusCorner.Parent = statusLabel
    
    -- CORREGIDO: Botón cerrar más visible
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 35, 0, 35)
    closeButton.Position = UDim2.new(1, -45, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    closeButton.BorderSizePixel = 2
    closeButton.BorderColor3 = Color3.fromRGB(150, 30, 30)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextStrokeTransparency = 0.8
    closeButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    closeButton.Parent = mainFrame
    closeButton.ZIndex = 12
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 17)
    closeCorner.Parent = closeButton
    
    -- Sistema de arrastrar mejorado
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    local function updateInput(input)
        if dragging and dragStart then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
    
    titleLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    titleLabel.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                updateInput(input)
            end
        end
    end)
    
    titleLabel.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Eventos de botones
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    scanButton.MouseButton1Click:Connect(function()
        if not isScanning then
            startServerScan(scanButton, statusLabel, scrollFrame)
        end
    end)
    
    return screenGui, scrollFrame, statusLabel, scanButton
end

-- CORREGIDO: Función para analizar servidor actual mejorada
local function analyzeCurrentServer()
    local serverData = {
        serverId = game.JobId or "Unknown",
        players = #Players:GetPlayers(),
        maxMoney = 0,
        totalFish = 0,
        topPlayer = "Ninguno",
        quality = "Bajo"
    }
    
    -- Analizar jugadores en el servidor
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            -- Buscar leaderstats
            local leaderstats = player:FindFirstChild("leaderstats")
            if leaderstats then
                local money = leaderstats:FindFirstChild("Money") or leaderstats:FindFirstChild("Cash") or leaderstats:FindFirstChild("Coins")
                if money and tonumber(money.Value) then
                    local playerMoney = tonumber(money.Value)
                    if playerMoney > serverData.maxMoney then
                        serverData.maxMoney = playerMoney
                        serverData.topPlayer = player.Name
                    end
                end
            end
            
            -- Contar herramientas/peces en backpack
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                for _, tool in pairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        serverData.totalFish = serverData.totalFish + 1
                    end
                end
            end
            
            -- Contar herramientas equipadas
            if player.Character then
                for _, tool in pairs(player.Character:GetChildren()) do
                    if tool:IsA("Tool") then
                        serverData.totalFish = serverData.totalFish + 1
                    end
                end
            end
        end
    end
    
    -- Calcular puntuación y calidad
    local moneyScore = serverData.maxMoney / 1000
    local fishScore = serverData.totalFish * 5
    local playerScore = serverData.players * 2
    
    serverData.score = math.floor(moneyScore + fishScore + playerScore)
    
    if serverData.score >= 100 then
        serverData.quality = "Excelente"
    elseif serverData.score >= 50 then
        serverData.quality = "Bueno"  
    elseif serverData.score >= 20 then
        serverData.quality = "Regular"
    else
        serverData.quality = "Bajo"
    end
    
    return serverData
end

-- CORREGIDO: Función para crear item de servidor mejorada
local function createServerItem(serverData, parent)
    local serverFrame = Instance.new("Frame")
    serverFrame.Size = UDim2.new(1, -10, 0, 90)
    serverFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
    serverFrame.BorderSizePixel = 2
    serverFrame.BorderColor3 = Color3.fromRGB(90, 90, 110)
    serverFrame.Parent = parent
    serverFrame.ZIndex = 12
    
    local serverCorner = Instance.new("UICorner")
    serverCorner.CornerRadius = UDim.new(0, 8)
    serverCorner.Parent = serverFrame
    
    -- Indicador de calidad con color
    local qualityFrame = Instance.new("Frame")
    qualityFrame.Size = UDim2.new(0, 8, 1, 0)
    qualityFrame.Position = UDim2.new(0, 0, 0, 0)
    qualityFrame.BorderSizePixel = 0
    qualityFrame.Parent = serverFrame
    qualityFrame.ZIndex = 13
    
    local qualityCorner = Instance.new("UICorner")
    qualityCorner.CornerRadius = UDim.new(0, 8)
    qualityCorner.Parent = qualityFrame
    
    -- Color según calidad
    if serverData.quality == "Excelente" then
        qualityFrame.BackgroundColor3 = Color3.fromRGB(50, 220, 50)
    elseif serverData.quality == "Bueno" then
        qualityFrame.BackgroundColor3 = Color3.fromRGB(220, 180, 50)
    elseif serverData.quality == "Regular" then
        qualityFrame.BackgroundColor3 = Color3.fromRGB(220, 120, 50)
    else
        qualityFrame.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    end
    
    -- Info del servidor CORREGIDA
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(0, 220, 1, 0)
    infoLabel.Position = UDim2.new(0, 15, 0, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = string.format("🎯 Puntuación: %d (%s)\n👥 Jugadores: %d | 💰 Dinero Max: $%s\n🐟 Peces Totales: %d | 👑 Top: %s", 
        serverData.score, serverData.quality, serverData.players, 
        serverData.maxMoney >= 1000 and string.format("%.1fK", serverData.maxMoney/1000) or tostring(serverData.maxMoney),
        serverData.totalFish, serverData.topPlayer)
    infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoLabel.TextSize = 14
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Center
    infoLabel.TextStrokeTransparency = 0.8
    infoLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    infoLabel.Parent = serverFrame
    infoLabel.ZIndex = 13
    
    -- Botón unirse CORREGIDO
    local joinButton = Instance.new("TextButton")
    joinButton.Size = UDim2.new(0, 90, 0, 50)
    joinButton.Position = UDim2.new(1, -100, 0.5, -25)
    joinButton.BackgroundColor3 = Color3.fromRGB(20, 150, 220)
    joinButton.BorderSizePixel = 2
    joinButton.BorderColor3 = Color3.fromRGB(10, 100, 180)
    joinButton.Text = "UNIRSE"
    joinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    joinButton.TextSize = 16
    joinButton.Font = Enum.Font.SourceSansBold
    joinButton.TextStrokeTransparency = 0.8
    joinButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    joinButton.Parent = serverFrame
    joinButton.ZIndex = 13
    
    local joinCorner = Instance.new("UICorner")
    joinCorner.CornerRadius = UDim.new(0, 6)
    joinCorner.Parent = joinButton
    
    -- Evento para unirse al servidor
    joinButton.MouseButton1Click:Connect(function()
        joinButton.Text = "UNIENDO..."
        joinButton.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
        
        wait(0.5)
        
        local success, error = pcall(function()
            if serverData.serverId and serverData.serverId ~= "Unknown" and serverData.serverId ~= "" then
                TeleportService:TeleportToPlaceInstance(gameId, serverData.serverId, LocalPlayer)
            else
                TeleportService:Teleport(gameId, LocalPlayer)
            end
        end)
        
        if not success then
            joinButton.Text = "ERROR"
            joinButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
            wait(2)
            joinButton.Text = "UNIRSE"
            joinButton.BackgroundColor3 = Color3.fromRGB(20, 150, 220)
        end
    end)
    
    return serverFrame
end

-- CORREGIDA: Función principal de escaneo
function startServerScan(scanButton, statusLabel, scrollFrame)
    if isScanning then return end
    
    isScanning = true
    scanButton.Text = "⏳ ESCANEANDO..."
    scanButton.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
    statusLabel.Text = "🔍 INICIANDO ESCANEO..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    
    -- Limpiar lista anterior
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    serverList = {}
    local serversScanned = 0
    local maxServers = 12
    
    -- Analizar servidor actual primero
    statusLabel.Text = "📊 ANALIZANDO SERVIDOR ACTUAL..."
    wait(1)
    
    local currentServerData = analyzeCurrentServer()
    if currentServerData.score > 10 then
        table.insert(serverList, currentServerData)
        createServerItem(currentServerData, scrollFrame)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #serverList * 98)
    end
    
    serversScanned = 1
    
    -- Función para escanear siguiente servidor
    local function scanNextServer()
        if serversScanned >= maxServers then
            -- Finalizar escaneo
            isScanning = false
            scanButton.Text = "🔍 ESCANEAR SERVIDORES"
            scanButton.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
            statusLabel.Text = string.format("✅ ESCANEO COMPLETADO - %d SERVIDORES", #serverList)
            statusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
            
            -- Ordenar por puntuación
            table.sort(serverList, function(a, b) return a.score > b.score end)
            
            -- Recrear lista ordenada
            for _, child in pairs(scrollFrame:GetChildren()) do
                if child:IsA("Frame") then
                    child:Destroy()
                end
            end
            
            for i, serverData in ipairs(serverList) do
                if i <= 10 then
                    createServerItem(serverData, scrollFrame)
                end
            end
            
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, math.min(#serverList, 10) * 98)
            return
        end
        
        serversScanned = serversScanned + 1
        statusLabel.Text = string.format("🔄 SERVIDOR %d/%d - SALTANDO...", serversScanned, maxServers)
        
        wait(2)
        
        -- Saltar al siguiente servidor
        TeleportService:Teleport(gameId, LocalPlayer)
    end
    
    -- Esperar un poco y empezar a escanear
    wait(2)
    scanNextServer()
end

-- Crear la GUI
wait(1)
mainGui = createGUI()

-- Mensaje de confirmación
print("✅ STEAL A FISH SERVER HOPPER CARGADO EXITOSAMENTE!")
print("📱 VERSIÓN ANDROID/KRNL OPTIMIZADA")
print("🎮 INTERFAZ CORREGIDA Y FUNCIONAL")
print("🔍 LISTO PARA ESCANEAR SERVIDORES!")

-- Notificación en pantalla
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🐟 Server Hopper";
    Text = "¡Cargado exitosamente! Presiona ESCANEAR para empezar.";
    Duration = 5;
})