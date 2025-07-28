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
    -- Crear ventana emergente con los remotes
    local copyGui = Instance.new("ScreenGui")
    copyGui.Name = "RemoteCopyGUI"
    copyGui.Parent = player.PlayerGui
    
    local copyFrame = Instance.new("Frame")
    copyFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
    copyFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    copyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    copyFrame.BorderSizePixel = 0
    copyFrame.Parent = copyGui
    
    local copyCorner = Instance.new("UICorner")
    copyCorner.CornerRadius = UDim.new(0, 15)
    copyCorner.Parent = copyFrame
    
    -- Título
    local copyTitle = Instance.new("TextLabel")
    copyTitle.Size = UDim2.new(1, 0, 0, 40)
    copyTitle.Position = UDim2.new(0, 0, 0, 0)
    copyTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    copyTitle.Text = "📋 Remotes Capturados - Clicker League"
    copyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyTitle.TextSize = 14
    copyTitle.Font = Enum.Font.SourceSansBold
    copyTitle.Parent = copyFrame
    
    local copyTitleCorner = Instance.new("UICorner")
    copyTitleCorner.CornerRadius = UDim.new(0, 15)
    copyTitleCorner.Parent = copyTitle
    
    -- Botón cerrar
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = copyFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeButton
    
    -- Área de texto
    local textFrame = Instance.new("ScrollingFrame")
    textFrame.Size = UDim2.new(1, -10, 1, -90)
    textFrame.Position = UDim2.new(0, 5, 0, 45)
    textFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    textFrame.BorderSizePixel = 0
    textFrame.ScrollBarThickness = 8
    textFrame.Parent = copyFrame
    
    local textCorner = Instance.new("UICorner")
    textCorner.CornerRadius = UDim.new(0, 10)
    textCorner.Parent = textFrame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 1, 0)
    textLabel.Position = UDim2.new(0, 5, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 10
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.Parent = textFrame
    
    -- Generar texto
    local copyText = "-- REMOTES PARA CLICKER LEAGUE --\n\n"
    copyText = copyText .. "-- Copia este código en KRNL para hacer auto-farm:\n\n"
    copyText = copyText .. "local ReplicatedStorage = game:GetService('ReplicatedStorage')\n"
    copyText = copyText .. "local Players = game:GetService('Players')\n"
    copyText = copyText .. "local player = Players.LocalPlayer\n\n"
    
    local uniqueRemotes = {}
    for _, remote in pairs(capturedRemotes) do
        if not uniqueRemotes[remote.name] then
            uniqueRemotes[remote.name] = remote
            copyText = copyText .. "-- " .. remote.name .. " (" .. remote.type .. ")\n"
            copyText = copyText .. "-- Args capturados: " .. (remote.args or "None") .. "\n"
            copyText = copyText .. "local " .. remote.name .. " = ReplicatedStorage:FindFirstChild('" .. remote.name .. "')\n"
            copyText = copyText .. "if " .. remote.name .. " then\n"
            
            if string.find(string.lower(remote.name), "click") then
                copyText = copyText .. "    -- Auto clicker infinito\n"
                copyText = copyText .. "    while true do\n"
                copyText = copyText .. "        " .. remote.name .. ":FireServer()\n"
                copyText = copyText .. "        wait(0.01) -- Súper rápido\n"
                copyText = copyText .. "    end\n"
            elseif string.find(string.lower(remote.name), "buy") or string.find(string.lower(remote.name), "purchase") then
                copyText = copyText .. "    -- Comprar automático\n"
                copyText = copyText .. "    " .. remote.name .. ":FireServer('upgrade_name', 999)\n"
            elseif string.find(string.lower(remote.name), "money") or string.find(string.lower(remote.name), "cash") then
                copyText = copyText .. "    -- Dupear dinero\n"
                copyText = copyText .. "    " .. remote.name .. ":FireServer(999999999)\n"
            else
                copyText = copyText .. "    -- Uso genérico\n"
                copyText = copyText .. "    " .. remote.name .. ":FireServer(" .. (remote.args or "") .. ")\n"
            end
            
            copyText = copyText .. "end\n\n"
        end
    end
    
    if #capturedRemotes == 0 then
        copyText = "⚠️ No se capturaron remotes aún.\n\n"
        copyText = copyText .. "🎯 Para capturar remotes:\n"
        copyText = copyText .. "1. Presiona START en el Remote Spy\n"
        copyText = copyText .. "2. Haz clicks en el juego\n"
        copyText = copyText .. "3. Compra upgrades\n"
        copyText = copyText .. "4. Presiona COPY de nuevo\n"
    end
    
    textLabel.Text = copyText
    
    -- Botón para generar auto-farm
    local farmButton = Instance.new("TextButton")
    farmButton.Size = UDim2.new(0.3, 0, 0, 35)
    farmButton.Position = UDim2.new(0.05, 0, 1, -40)
    farmButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    farmButton.Text = "🚀 Auto-Farm"
    farmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    farmButton.TextSize = 12
    farmButton.Font = Enum.Font.SourceSansBold
    farmButton.Parent = copyFrame
    
    local farmCorner = Instance.new("UICorner")
    farmCorner.CornerRadius = UDim.new(0, 8)
    farmCorner.Parent = farmButton
    
    -- Eventos
    closeButton.MouseButton1Click:Connect(function()
        copyGui:Destroy()
    end)
    closeButton.TouchTap:Connect(function()
        copyGui:Destroy()
    end)
    
    farmButton.MouseButton1Click:Connect(function()
        -- Ejecutar auto-farm basado en remotes capturados
        for _, remote in pairs(capturedRemotes) do
            if string.find(string.lower(remote.name), "click") then
                spawn(function()
                    local clickRemote = ReplicatedStorage:FindFirstChild(remote.name)
                    if clickRemote then
                        while true do
                            clickRemote:FireServer()
                            wait(0.01)
                        end
                    end
                end)
                break
            end
        end
        status.Text = "🚀 Auto-farm iniciado!"
    end)
    farmButton.TouchTap:Connect(function()
        -- Mismo código para touch
        for _, remote in pairs(capturedRemotes) do
            if string.find(string.lower(remote.name), "click") then
                spawn(function()
                    local clickRemote = ReplicatedStorage:FindFirstChild(remote.name)
                    if clickRemote then
                        while true do
                            clickRemote:FireServer()
                            wait(0.01)
                        end
                    end
                end)
                break
            end
        end
        status.Text = "🚀 Auto-farm iniciado!"
    end)
    
    status.Text = "📋 Ventana de remotes abierta!"
    
    -- También imprimir en consola para KRNL
    print("=== REMOTES CAPTURADOS ===")
    print(copyText)
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