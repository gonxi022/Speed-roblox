-- 🔥 H2K MOD MENU - LIFE SENTENCE
-- Bypass Anti-Ban System | Estético y Funcional
-- Compatible Android Krnl - By H2K

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Estados del mod
local ModSettings = {
    noclip = false,
    speed = false,
    speedValue = 25,
    minimized = false,
    bypass = true -- Siempre activo para evitar bans
}

local Connections = {}
local BodyVelocity = nil
local originalWalkSpeed = Humanoid.WalkSpeed

-- Limpiar GUI anterior
pcall(function()
    if LocalPlayer.PlayerGui:FindFirstChild("H2KLifeSentence") then
        LocalPlayer.PlayerGui:FindFirstChild("H2KLifeSentence"):Destroy()
    end
end)

-- BYPASS ANTI-BAN SYSTEM
local function initializeBypass()
    -- Bypass para detección de CanCollide (Noclip)
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    local oldIndex = mt.__index
    local oldNewindex = mt.__newindex
    
    setreadonly(mt, false)
    
    -- Bypass __namecall para métodos de detección
    mt.__namecall = function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if method == "GetTouchingParts" or method == "ReadVoxels" or method == "GetPartBoundsInBox" then
            return {}
        elseif method == "Raycast" and ModSettings.noclip then
            return nil
        end
        
        return oldNamecall(self, ...)
    end
    
    -- Bypass __newindex para CanCollide
    mt.__newindex = function(self, property, value)
        if property == "CanCollide" and ModSettings.noclip then
            if self.Parent == LocalPlayer.Character then
                value = false
            end
        elseif property == "WalkSpeed" and self == Humanoid and not ModSettings.speed then
            -- Permitir solo cambios del script
            return oldNewindex(self, property, value)
        end
        
        return oldNewindex(self, property, value)
    end
    
    setreadonly(mt, true)
    
    -- Hook de Humanoid para bypass de speed detection
    local HumanoidMT = getrawmetatable(Humanoid)
    local oldHumanoidIndex = HumanoidMT.__index
    setreadonly(HumanoidMT, false)
    
    HumanoidMT.__index = function(self, property)
        if property == "WalkSpeed" and self == Humanoid and ModSettings.speed then
            return originalWalkSpeed -- Reportar velocidad original
        end
        return oldHumanoidIndex(self, property)
    end
    
    setreadonly(HumanoidMT, true)
end

-- Inicializar bypass
initializeBypass()

-- Función de Noclip con bypass
local function toggleNoclip()
    ModSettings.noclip = not ModSettings.noclip
    
    if ModSettings.noclip then
        Connections.noclipConnection = RunService.Stepped:Connect(function()
            local character = LocalPlayer.Character
            if character then
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") and part ~= RootPart then
                        pcall(function()
                            part.CanCollide = false
                        end)
                    end
                end
            end
        end)
    else
        if Connections.noclipConnection then
            Connections.noclipConnection:Disconnect()
            Connections.noclipConnection = nil
        end
        
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") and part ~= RootPart then
                    pcall(function()
                        part.CanCollide = true
                    end)
                end
            end
        end
    end
end

-- Función de Speed con bypass
local function toggleSpeed()
    ModSettings.speed = not ModSettings.speed
    
    if ModSettings.speed then
        -- Speed gradual para evitar detección
        spawn(function()
            local targetSpeed = ModSettings.speedValue
            local currentSpeed = Humanoid.WalkSpeed
            local increment = (targetSpeed - currentSpeed) / 10
            
            for i = 1, 10 do
                if not ModSettings.speed then break end
                currentSpeed = currentSpeed + increment
                Humanoid.WalkSpeed = currentSpeed
                wait(0.1)
            end
            Humanoid.WalkSpeed = targetSpeed
        end)
    else
        -- Restaurar velocidad gradualmente
        spawn(function()
            local targetSpeed = originalWalkSpeed
            local currentSpeed = Humanoid.WalkSpeed
            local increment = (targetSpeed - currentSpeed) / 5
            
            for i = 1, 5 do
                currentSpeed = currentSpeed + increment
                Humanoid.WalkSpeed = currentSpeed
                wait(0.1)
            end
            Humanoid.WalkSpeed = targetSpeed
        end)
    end
end

-- Crear GUI principal
local function createModMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "H2KLifeSentence"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer.PlayerGui
    
    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 280, 0, 320)
    mainFrame.Position = UDim2.new(0, 20, 0, 80)
    mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    -- Esquinas redondeadas
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = mainFrame
    
    -- Sombra
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.8
    shadow.ZIndex = mainFrame.ZIndex - 1
    shadow.Parent = mainFrame
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 20)
    shadowCorner.Parent = shadow
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 15)
    headerCorner.Parent = header
    
    -- Gradiente header
    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 50, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 30, 30))
    }
    headerGradient.Rotation = 45
    headerGradient.Parent = header
    
    -- Logo H2K
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 50, 1, 0)
    logo.Position = UDim2.new(0, 15, 0, 0)
    logo.BackgroundTransparency = 1
    logo.Text = "H2K"
    logo.TextColor3 = Color3.fromRGB(255, 255, 255)
    logo.TextSize = 20
    logo.Font = Enum.Font.GothamBold
    logo.TextStrokeTransparency = 0
    logo.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    logo.Parent = header
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -120, 1, 0)
    title.Position = UDim2.new(0, 70, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Life Sentence"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.Gotham
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Botón minimizar
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeBtn"
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -40, 0, 7.5)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    minimizeBtn.TextSize = 18
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = header
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 6)
    minimizeCorner.Parent = minimizeBtn
    
    -- Contenido
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -16, 1, -55)
    content.Position = UDim2.new(0, 8, 0, 50)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    -- Sección Noclip
    local noclipSection = Instance.new("Frame")
    noclipSection.Size = UDim2.new(1, 0, 0, 60)
    noclipSection.Position = UDim2.new(0, 0, 0, 0)
    noclipSection.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    noclipSection.BorderSizePixel = 0
    noclipSection.Parent = content
    
    local noclipCorner = Instance.new("UICorner")
    noclipCorner.CornerRadius = UDim.new(0, 8)
    noclipCorner.Parent = noclipSection
    
    local noclipLabel = Instance.new("TextLabel")
    noclipLabel.Size = UDim2.new(1, -70, 1, 0)
    noclipLabel.Position = UDim2.new(0, 12, 0, 0)
    noclipLabel.BackgroundTransparency = 1
    noclipLabel.Text = "👻 Noclip\nAtravesar paredes"
    noclipLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    noclipLabel.TextSize = 13
    noclipLabel.Font = Enum.Font.Gotham
    noclipLabel.TextXAlignment = Enum.TextXAlignment.Left
    noclipLabel.TextYAlignment = Enum.TextYAlignment.Center
    noclipLabel.Parent = noclipSection
    
    local noclipToggle = Instance.new("TextButton")
    noclipToggle.Name = "NoclipToggle"
    noclipToggle.Size = UDim2.new(0, 50, 0, 25)
    noclipToggle.Position = UDim2.new(1, -60, 0.5, -12.5)
    noclipToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    noclipToggle.Text = "OFF"
    noclipToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    noclipToggle.TextSize = 11
    noclipToggle.Font = Enum.Font.GothamBold
    noclipToggle.Parent = noclipSection
    
    local noclipToggleCorner = Instance.new("UICorner")
    noclipToggleCorner.CornerRadius = UDim.new(0, 6)
    noclipToggleCorner.Parent = noclipToggle
    
    -- Sección Speed
    local speedSection = Instance.new("Frame")
    speedSection.Size = UDim2.new(1, 0, 0, 100)
    speedSection.Position = UDim2.new(0, 0, 0, 70)
    speedSection.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    speedSection.BorderSizePixel = 0
    speedSection.Parent = content
    
    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(0, 8)
    speedCorner.Parent = speedSection
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, -70, 0, 30)
    speedLabel.Position = UDim2.new(0, 12, 0, 5)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "⚡ Speed Hack"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.TextSize = 13
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.TextYAlignment = Enum.TextYAlignment.Center
    speedLabel.Parent = speedSection
    
    local speedToggle = Instance.new("TextButton")
    speedToggle.Name = "SpeedToggle"
    speedToggle.Size = UDim2.new(0, 50, 0, 25)
    speedToggle.Position = UDim2.new(1, -60, 0, 7.5)
    speedToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    speedToggle.Text = "OFF"
    speedToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedToggle.TextSize = 11
    speedToggle.Font = Enum.Font.GothamBold
    speedToggle.Parent = speedSection
    
    local speedToggleCorner = Instance.new("UICorner")
    speedToggleCorner.CornerRadius = UDim.new(0, 6)
    speedToggleCorner.Parent = speedToggle
    
    -- Slider de velocidad
    local speedSliderFrame = Instance.new("Frame")
    speedSliderFrame.Size = UDim2.new(1, -24, 0, 35)
    speedSliderFrame.Position = UDim2.new(0, 12, 0, 40)
    speedSliderFrame.BackgroundTransparency = 1
    speedSliderFrame.Parent = speedSection
    
    local speedValueLabel = Instance.new("TextLabel")
    speedValueLabel.Size = UDim2.new(1, 0, 0, 15)
    speedValueLabel.BackgroundTransparency = 1
    speedValueLabel.Text = "Velocidad: 25"
    speedValueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedValueLabel.TextSize = 11
    speedValueLabel.Font = Enum.Font.Gotham
    speedValueLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedValueLabel.Parent = speedSliderFrame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 6)
    sliderBg.Position = UDim2.new(0, 0, 1, -6)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = speedSliderFrame
    
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(0, 3)
    sliderBgCorner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(0.25, 0, 1, 0) -- 25/100 = 0.25
    sliderFill.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(0, 3)
    sliderFillCorner.Parent = sliderFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 14, 0, 14)
    sliderButton.Position = UDim2.new(0.25, -7, 0.5, -7)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.Text = ""
    sliderButton.Parent = sliderBg
    
    local sliderButtonCorner = Instance.new("UICorner")
    sliderButtonCorner.CornerRadius = UDim.new(1, 0)
    sliderButtonCorner.Parent = sliderButton
    
    -- Botones de velocidad
    local speedButtonsFrame = Instance.new("Frame")
    speedButtonsFrame.Size = UDim2.new(1, -24, 0, 20)
    speedButtonsFrame.Position = UDim2.new(0, 12, 0, 78)
    speedButtonsFrame.BackgroundTransparency = 1
    speedButtonsFrame.Parent = speedSection
    
    local speedButtons = {
        {text = "16", value = 16},
        {text = "25", value = 25},
        {text = "50", value = 50},
        {text = "100", value = 100}
    }
    
    for i, btnData in ipairs(speedButtons) do
        local speedBtn = Instance.new("TextButton")
        speedBtn.Size = UDim2.new(0.23, 0, 1, 0)
        speedBtn.Position = UDim2.new((i-1) * 0.25 + 0.01, 0, 0, 0)
        speedBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        speedBtn.Text = btnData.text
        speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        speedBtn.TextSize = 10
        speedBtn.Font = Enum.Font.GothamBold
        speedBtn.Parent = speedButtonsFrame
        
        local speedBtnCorner = Instance.new("UICorner")
        speedBtnCorner.CornerRadius = UDim.new(0, 4)
        speedBtnCorner.Parent = speedBtn
        
        speedBtn.MouseButton1Click:Connect(function()
            ModSettings.speedValue = btnData.value
            speedValueLabel.Text = "Velocidad: " .. btnData.value
            local percentage = btnData.value / 100
            sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
            sliderButton.Position = UDim2.new(percentage, -7, 0.5, -7)
            
            if ModSettings.speed then
                Humanoid.WalkSpeed = btnData.value
            end
        end)
    end
    
    -- Bypass Status
    local bypassSection = Instance.new("Frame")
    bypassSection.Size = UDim2.new(1, 0, 0, 40)
    bypassSection.Position = UDim2.new(0, 0, 0, 180)
    bypassSection.BackgroundColor3 = Color3.fromRGB(25, 60, 25)
    bypassSection.BorderSizePixel = 0
    bypassSection.Parent = content
    
    local bypassCorner = Instance.new("UICorner")
    bypassCorner.CornerRadius = UDim.new(0, 8)
    bypassCorner.Parent = bypassSection
    
    local bypassLabel = Instance.new("TextLabel")
    bypassLabel.Size = UDim2.new(1, -20, 1, 0)
    bypassLabel.Position = UDim2.new(0, 10, 0, 0)
    bypassLabel.BackgroundTransparency = 1
    bypassLabel.Text = "🛡️ Bypass Anti-Ban: ACTIVO"
    bypassLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    bypassLabel.TextSize = 12
    bypassLabel.Font = Enum.Font.GothamBold
    bypassLabel.TextXAlignment = Enum.TextXAlignment.Left
    bypassLabel.Parent = bypassSection
    
    -- Créditos
    local creditsFrame = Instance.new("Frame")
    creditsFrame.Size = UDim2.new(1, 0, 0, 25)
    creditsFrame.Position = UDim2.new(0, 0, 1, -25)
    creditsFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    creditsFrame.BorderSizePixel = 0
    creditsFrame.Parent = content
    
    local creditsCorner = Instance.new("UICorner")
    creditsCorner.CornerRadius = UDim.new(0, 8)
    creditsCorner.Parent = creditsFrame
    
    local creditsLabel = Instance.new("TextLabel")
    creditsLabel.Size = UDim2.new(1, 0, 1, 0)
    creditsLabel.BackgroundTransparency = 1
    creditsLabel.Text = "by H2K"
    creditsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    creditsLabel.TextSize = 11
    creditsLabel.Font = Enum.Font.GothamBold
    creditsLabel.Parent = creditsFrame
    
    return {
        screenGui = screenGui,
        mainFrame = mainFrame,
        content = content,
        minimizeBtn = minimizeBtn,
        noclipToggle = noclipToggle,
        speedToggle = speedToggle,
        sliderButton = sliderButton,
        sliderFill = sliderFill,
        speedValueLabel = speedValueLabel,
        header = header
    }
end

-- Crear GUI
local gui = createModMenu()

-- Funcionalidad minimizar
local function toggleMinimize()
    ModSettings.minimized = not ModSettings.minimized
    
    local targetSize = ModSettings.minimized and UDim2.new(0, 280, 0, 45) or UDim2.new(0, 280, 0, 320)
    local targetText = ModSettings.minimized and "□" or "−"
    
    local tween = TweenService:Create(gui.mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = targetSize})
    tween:Play()
    
    gui.minimizeBtn.Text = targetText
    gui.content.Visible = not ModSettings.minimized
end

-- Conectar botones
gui.minimizeBtn.MouseButton1Click:Connect(toggleMinimize)

gui.noclipToggle.MouseButton1Click:Connect(function()
    toggleNoclip()
    gui.noclipToggle.Text = ModSettings.noclip and "ON" or "OFF"
    gui.noclipToggle.BackgroundColor3 = ModSettings.noclip and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 80)
end)

gui.speedToggle.MouseButton1Click:Connect(function()
    toggleSpeed()
    gui.speedToggle.Text = ModSettings.speed and "ON" or "OFF"
    gui.speedToggle.BackgroundColor3 = ModSettings.speed and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 80)
end)

-- Slider functionality
local dragging = false
gui.sliderButton.MouseButton1Down:Connect(function()
    dragging = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local sliderBg = gui.sliderButton.Parent
        local relativeX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        
        gui.sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
        gui.sliderButton.Position = UDim2.new(relativeX, -7, 0.5, -7)
        
        ModSettings.speedValue = math.floor(relativeX * 100 + 16)
        gui.speedValueLabel.Text = "Velocidad: " .. ModSettings.speedValue
        
        if ModSettings.speed then
            Humanoid.WalkSpeed = ModSettings.speedValue
        end
    end
end)

-- Hacer arrastrable
local draggingGui = false
local dragStart = nil
local startPos = nil

gui.header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingGui = true
        dragStart = input.Position
        startPos = gui.mainFrame.Position
    end
end)

gui.header.InputChanged:Connect(function(input)
    if draggingGui and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        gui.mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

gui.header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingGui = false
    end
end)

-- Mantener funciones activas después de respawn
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
    originalWalkSpeed = Humanoid.WalkSpeed
    
    -- Reinicializar bypass
    initializeBypass()
    
    wait(1)
    
    -- Reactivar mods si estaban activos
    if ModSettings.noclip then
        toggleNoclip()
        toggleNoclip() -- Toggle twice para reactivar
    end
    
    if ModSettings.speed then
        wait(0.5)
        Humanoid.WalkSpeed = ModSettings.speedValue
    end
end)

-- Limpiar al salir
game:BindToClose(function()
    for _, connection in pairs(Connections) do
        if connection then
            connection:Disconnect()
        end
    end
end)

print("🔥 H2K Life Sentence Mod Menu cargado!")
print("🛡️ Sistema bypass anti-ban activado")
print("📱 Compatible Android Krnl")
print("⚡ Funciones: Noclip, Speed, Bypass")
print("✨ By H2K - Sin riesgo de ban")