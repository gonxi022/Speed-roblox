-- REMOTE SPY PARA KRNL ANDROID
-- Detecta y muestra todos los RemoteEvents/RemoteFunctions

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Variables globales
local capturedRemotes = {}
local isLogging = false
local logCount = 0

-- Crear GUI principal
local gui = Instance.new("ScreenGui")
gui.Name = "RemoteSpyGUI"
gui.Parent = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

-- Frame principal
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 450)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

-- Esquinas redondeadas
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = mainFrame

-- Borde brillante
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 255, 255)
stroke.Thickness = 2
stroke.Parent = mainFrame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.Text = "🕵️ Remote Spy - KRNL Android"
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 15)
titleCorner.Parent = title

-- Info del juego
local gameInfo = Instance.new("TextLabel")
gameInfo.Size = UDim2.new(1, 0, 0, 25)
gameInfo.Position = UDim2.new(0, 0, 0, 45)
gameInfo.BackgroundTransparency = 1
gameInfo.Text = "🎮 " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
gameInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
gameInfo.TextSize = 12
gameInfo.Font = Enum.Font.SourceSans
gameInfo.TextTruncate = Enum.TextTruncate.AtEnd
gameInfo.Parent = mainFrame

-- Status
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 20)
status.Position = UDim2.new(0, 0, 0, 70)
status.BackgroundTransparency = 1
status.Text = "📡 Estado: Listo para espiar"
status.TextColor3 = Color3.fromRGB(255, 200, 100)
status.TextSize = 11
status.Font = Enum.Font.SourceSans
status.Parent = mainFrame

-- Botones de control
local buttonFrame = Instance.new("Frame")
buttonFrame.Size = UDim2.new(1, 0, 0, 40)
buttonFrame.Position = UDim2.new(0, 0, 0, 95)
buttonFrame.BackgroundTransparency = 1
buttonFrame.Parent = mainFrame

-- Botón Start/Stop
local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0.3, -5, 1, 0)
startButton.Position = UDim2.new(0, 5, 0, 0)
startButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
startButton.Text = "▶️ START"
startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
startButton.TextSize = 12
startButton.Font = Enum.Font.SourceSansBold
startButton.Parent = buttonFrame

-- Botón Clear
local clearButton = Instance.new("TextButton")
clearButton.Size = UDim2.new(0.3, -5, 1, 0)
clearButton.Position = UDim2.new(0.35, 0, 0, 0)
clearButton.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
clearButton.Text = "🗑️ CLEAR"
clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
clearButton.TextSize = 12
clearButton.Font = Enum.Font.SourceSansBold
clearButton.Parent = buttonFrame

-- Botón Copy
local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(0.3, -5, 1, 0)
copyButton.Position = UDim2.new(0.7, 5, 0, 0)
copyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
copyButton.Text = "📋 COPY"
copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
copyButton.TextSize = 12
copyButton.Font = Enum.Font.SourceSansBold
copyButton.Parent = buttonFrame

-- Agregar esquinas a botones
for _, button in pairs({startButton, clearButton, copyButton}) do
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
end

-- Área de log principal
local logFrame = Instance.new("ScrollingFrame")
logFrame.Size = UDim2.new(1, -10, 0, 300)
logFrame.Position = UDim2.new(0, 5, 0, 140)
logFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
logFrame.BorderSizePixel = 0
logFrame.ScrollBarThickness = 8
logFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
logFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
logFrame.Parent = mainFrame

local logCorner = Instance.new("UICorner")
logCorner.CornerRadius = UDim.new(0, 10)
logCorner.Parent = logFrame

-- Layout para logs
local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 2)
listLayout.Parent = logFrame

-- Función para agregar log
local function addLog(remoteName, remoteType, args, color)
    logCount = logCount + 1
    
    local logEntry = Instance.new("Frame")
    logEntry.Size = UDim2.new(1, -10, 0, 60)
    logEntry.BackgroundColor3 = color or Color3.fromRGB(40, 40, 40)
    logEntry.BorderSizePixel = 0
    logEntry.LayoutOrder = logCount
    logEntry.Parent = logFrame
    
    local entryCorner = Instance.new("UICorner")
    entryCorner.CornerRadius = UDim.new(0, 5)
    entryCorner.Parent = logEntry
    
    -- Nombre del remote
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -10, 0, 20)
    nameLabel.Position = UDim2.new(0, 5, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "🔗 " .. remoteName .. " (" .. remoteType .. ")"
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 12
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = logEntry
    
    -- Argumentos
    local argsLabel = Instance.new("TextLabel")
    argsLabel.Size = UDim2.new(1, -10, 0, 35)
    argsLabel.Position = UDim2.new(0, 5, 0, 20)
    argsLabel.BackgroundTransparency = 1
    argsLabel.Text = "📦 Args: " .. (args or "None")
    argsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    argsLabel.TextSize = 10
    argsLabel.Font = Enum.Font.SourceSans
    argsLabel.TextXAlignment = Enum.TextXAlignment.Left
    argsLabel.TextYAlignment = Enum.TextYAlignment.Top
    argsLabel.TextWrapped = true
    argsLabel.Parent = logEntry
    
    -- Auto scroll
    logFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    logFrame.CanvasPosition = Vector2.new(0, logFrame.CanvasSize.Y.Offset)
    
    -- Guardar para copy
    table.insert(capturedRemotes, {
        name = remoteName,
        type = remoteType,
        args = args
    })
end

-- Función para encontrar todos los remotes
local function findAllRemotes()
    local remotes = {}
    
    -- Buscar en ReplicatedStorage
    local function searchInContainer(container, path)
        for _, child in pairs(container:GetChildren()) do
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                remotes[child.Name] = {
                    object = child,
                    type = child.ClassName,
                    path = path .. child.Name
                }
            elseif child:IsA("Folder") or child:IsA("Configuration") then
                searchInContainer(child, path .. child.Name .. "/")
            end
        end
    end
    
    searchInContainer(ReplicatedStorage, "ReplicatedStorage/")
    
    -- También buscar en StarterGui
    if game:GetService("StarterGui") then
        searchInContainer(game:GetService("StarterGui"), "StarterGui/")
    end
    
    return remotes
end

-- Función para hookear remotes
local function hookRemotes()
    local remotes = findAllRemotes()
    
    for name, data in pairs(remotes) do
        local remote = data.object
        local originalConnect = remote.OnClientEvent
        
        if remote:IsA("RemoteEvent") then
            -- Hook RemoteEvent
            local connection
            connection = remote.OnClientEvent:Connect(function(...)
                local args = {...}
                local argsString = ""
                
                for i, arg in pairs(args) do
                    if typeof(arg) == "string" then
                        argsString = argsString .. '"' .. tostring(arg) .. '"'
                    else
                        argsString = argsString .. tostring(arg)
                    end
                    if i < #args then
                        argsString = argsString .. ", "
                    end
                end
                
                addLog(name, "RemoteEvent", argsString, Color3.fromRGB(50, 150, 50))
                status.Text = "📡 Capturado: " .. name
            end)
            
            -- También hook FireServer calls (experimental)
            local originalFireServer = remote.FireServer
            remote.FireServer = function(self, ...)
                local args = {...}
                local argsString = ""
                
                for i, arg in pairs(args) do
                    if typeof(arg) == "string" then
                        argsString = argsString .. '"' .. tostring(arg) .. '"'
                    else
                        argsString = argsString .. tostring(arg)
                    end
                    if i < #args then
                        argsString = argsString .. ", "
                    end
                end
                
                addLog(name .. " (OUT)", "RemoteEvent", argsString, Color3.fromRGB(150, 50, 50))
                status.Text = "📤 Enviado: " .. name
                
                return originalFireServer(self, ...)
            end
        end
    end
    
    addLog("SYSTEM", "INFO", "Hooked " .. #remotes .. " remotes successfully", Color3.fromRGB(100, 100, 255))
end

-- Funciones de botones
local function toggleLogging()
    isLogging = not isLogging
    
    if isLogging then
        startButton.Text = "⏸️ STOP"
        startButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        status.Text = "📡 Espiando remotes activamente..."
        hookRemotes()
    else
        startButton.Text = "▶️ START"
        startButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        status.Text = "📡 Espionaje pausado"
    end
end

local function clearLogs()
    for _, child in pairs(logFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    capturedRemotes = {}
    logCount = 0
    logFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    status.Text = "🗑️ Logs limpiados"
end

local function copyToClipboard()
    local copyText = "-- REMOTES CAPTURADOS --\n"
    copyText = copyText .. "-- Juego: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. "\n\n"
    
    for _, remote in pairs(capturedRemotes) do
        copyText = copyText .. "-- " .. remote.name .. " (" .. remote.type .. ")\n"
        copyText = copyText .. "-- Args: " .. (remote.args or "None") .. "\n\n"
    end
    
    -- Para KRNL Android, mostrar en consola
    print("=== REMOTES CAPTURADOS ===")
    print(copyText)
    
    status.Text = "📋 Copiado a consola! (F9 para ver)"
    
    -- También crear un script ejecutable
    local scriptText = "\n-- SCRIPT GENERADO AUTOMÁTICAMENTE\n"
    scriptText = scriptText .. "local ReplicatedStorage = game:GetService('ReplicatedStorage')\n\n"
    
    local uniqueRemotes = {}
    for _, remote in pairs(capturedRemotes) do
        if not uniqueRemotes[remote.name] then
            uniqueRemotes[remote.name] = remote
            scriptText = scriptText .. "-- Usar " .. remote.name .. ":\n"
            scriptText = scriptText .. "local " .. remote.name .. " = ReplicatedStorage:FindFirstChild('" .. remote.name .. "')\n"
            scriptText = scriptText .. "if " .. remote.name .. " then\n"
            scriptText = scriptText .. "    " .. remote.name .. ":FireServer(" .. (remote.args or "") .. ")\n"
            scriptText = scriptText .. "end\n\n"
        end
    end
    
    print(scriptText)
end

-- Conectar eventos
startButton.MouseButton1Click:Connect(toggleLogging)
startButton.TouchTap:Connect(toggleLogging)

clearButton.MouseButton1Click:Connect(clearLogs)
clearButton.TouchTap:Connect(clearLogs)

copyButton.MouseButton1Click:Connect(copyToClipboard)
copyButton.TouchTap:Connect(copyToClipboard)

-- Inicialización
addLog("SYSTEM", "INFO", "Remote Spy cargado correctamente", Color3.fromRGB(0, 255, 0))
addLog("SYSTEM", "INFO", "Compatible con KRNL Android", Color3.fromRGB(0, 255, 255))
addLog("SYSTEM", "INFO", "Presiona START para comenzar", Color3.fromRGB(255, 255, 0))

print("🕵️ Remote Spy GUI cargado!")
print("📱 Compatible con KRNL Android")
print("🎯 Juego actual:", game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)