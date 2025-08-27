-- 🚀 H2K MOD MENU - ANDROID KRNL
-- GUI estético, minimizable y funcional
-- Fly, Noclip, Speed con selector de velocidad

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Variables de estados
local ModStates = {
    fly = false,
    noclip = false,
    speed = false,
    speedValue = 50,
    isMinimized = false
}

local Connections = {}
local BodyVelocity = nil
local originalWalkSpeed = Humanoid.WalkSpeed

-- Limpiar GUI anterior
pcall(function()
    if LocalPlayer.PlayerGui:FindFirstChild("H2KModMenu") then
        LocalPlayer.PlayerGui.H2KModMenu:Destroy()
    end
end)

-- Crear GUI principal
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "H2KModMenu"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer.PlayerGui
    
    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 320, 0, 380)
    mainFrame.Position = UDim2.new(0, 20, 0, 100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    -- Esquinas redondeadas
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame
    
    -- Sombra del frame
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 6, 1, 6)
    shadow.Position = UDim2.new(0, -3, 0, -3)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.7
    shadow.ZIndex = mainFrame.ZIndex - 1
    shadow.Parent = mainFrame
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 15)
    shadowCorner.Parent = shadow
    
    -- Header con gradiente
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 50)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(45, 85, 255)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    -- Gradiente del header
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 85, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 65, 235))
    }
    gradient.Rotation = 45
    gradient.Parent = header
    
    -- Logo H2K
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 60, 1, 0)
    logo.Position = UDim2.new(0, 15, 0, 0)
    logo.BackgroundTransparency = 1
    logo.Text = "H2K"
    logo.TextColor3 = Color3.fromRGB(255, 255, 255)
    logo.TextSize = 24
    logo.Font = Enum.Font.GothamBold
    logo.TextStrokeTransparency = 0
    logo.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    logo.Parent = header
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -150, 1, 0)
    title.Position = UDim2.new(0, 80, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Mod Menu"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.Gotham
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Botón minimizar
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeBtn"
    minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
    minimizeBtn.Position = UDim2.new(1, -45, 0, 7.5)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 195, 0)
    minimizeBtn.Text = "−"
    minimizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    minimizeBtn.TextSize = 20
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = header
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 8)
    minimizeCorner.Parent = minimizeBtn
    
    -- Contenido principal
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -65)
    content.Position = UDim2.new(0, 10, 0, 55)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    -- Sección FLY
    local flySection = Instance.new("Frame")
    flySection.Size = UDim2.new(1, 0, 0, 70)
    flySection.Position = UDim2.new(0, 0, 0, 0)
    flySection.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    flySection.BorderSizePixel = 0
    flySection.Parent = content
    
    local flySectionCorner = Instance.new("UICorner")
    flySectionCorner.CornerRadius = UDim.new(0, 8)
    flySectionCorner.Parent = flySection
    
    local flyLabel = Instance.new("TextLabel")
    flyLabel.Size = UDim2.new(1, -80, 1, 0)
    flyLabel.Position = UDim2.new(0, 15, 0, 0)
    flyLabel.BackgroundTransparency = 1
    flyLabel.Text = "✈️ Fly Mode\nVolar por el mapa"
    flyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    flyLabel.TextSize = 14
    flyLabel.Font = Enum.Font.Gotham
    flyLabel.TextXAlignment = Enum.TextXAlignment.Left
    flyLabel.TextYAlignment = Enum.TextYAlignment.Center
    flyLabel.Parent = flySection
    
    local flyToggle = Instance.new("TextButton")
    flyToggle.Name = "FlyToggle"
    flyToggle.Size = UDim2.new(0, 50, 0, 25)
    flyToggle.Position = UDim2.new(1, -65, 0.5, -12.5)
    flyToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    flyToggle.Text = "OFF"
    flyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    flyToggle.TextSize = 12
    flyToggle.Font = Enum.Font.GothamBold
    flyToggle.Parent = flySection
    
    local flyToggleCorner = Instance.new("UICorner")
    flyToggleCorner.CornerRadius = UDim.new(0, 6)
    flyToggleCorner.Parent = flyToggle
    
    -- Sección NOCLIP
    local noclipSection = Instance.new("Frame")
    noclipSection.Size = UDim2.new(1, 0, 0, 70)
    noclipSection.Position = UDim2.new(0, 0, 0, 80)
    noclipSection.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    noclipSection.BorderSizePixel = 0
    noclipSection.Parent = content
    
    local noclipSectionCorner = Instance.new("UICorner")
    noclipSectionCorner.CornerRadius = UDim.new(0, 8)
    noclipSectionCorner.Parent = noclipSection
    
    local noclipLabel = Instance.new("TextLabel")
    noclipLabel.Size = UDim2.new(1, -80, 1, 0)
    noclipLabel.Position = UDim2.new(0, 15, 0, 0)
    noclipLabel.BackgroundTransparency = 1
    noclipLabel.Text = "👻 Noclip Mode\nAtravesar paredes"
    noclipLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    noclipLabel.TextSize = 14
    noclipLabel.Font = Enum.Font.Gotham
    noclipLabel.TextXAlignment = Enum.TextXAlignment.Left
    noclipLabel.TextYAlignment = Enum.TextYAlignment.Center
    noclipLabel.Parent = noclipSection
    
    local noclipToggle = Instance.new("TextButton")
    noclipToggle.Name = "NoclipToggle"
    noclipToggle.Size = UDim2.new(0, 50, 0, 25)
    noclipToggle.Position = UDim2.new(1, -65, 0.5, -12.5)
    noclipToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    noclipToggle.Text = "OFF"
    noclipToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    noclipToggle.TextSize = 12
    noclipToggle.Font = Enum.Font.GothamBold
    noclipToggle.Parent = noclipSection
    
    local noclipToggleCorner = Instance.new("UICorner")
    noclipToggleCorner.CornerRadius = UDim.new(0, 6)
    noclipToggleCorner.Parent = noclipToggle
    
    -- Sección SPEED
    local speedSection = Instance.new("Frame")
    speedSection.Size = UDim2.new(1, 0, 0, 110)
    speedSection.Position = UDim2.new(0, 0, 0, 160)
    speedSection.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    speedSection.BorderSizePixel = 0
    speedSection.Parent = content
    
    local speedSectionCorner = Instance.new("UICorner")
    speedSectionCorner.CornerRadius = UDim.new(0, 8)
    speedSectionCorner.Parent = speedSection
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, -80, 0, 35)
    speedLabel.Position = UDim2.new(0, 15, 0, 0)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "⚡ Speed Hack"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.TextSize = 14
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.TextYAlignment = Enum.TextYAlignment.Center
    speedLabel.Parent = speedSection
    
    local speedToggle = Instance.new("TextButton")
    speedToggle.Name = "SpeedToggle"
    speedToggle.Size = UDim2.new(0, 50, 0, 25)
    speedToggle.Position = UDim2.new(1, -65, 0, 5)
    speedToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    speedToggle.Text = "OFF"
    speedToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedToggle.TextSize = 12
    speedToggle.Font = Enum.Font.GothamBold
    speedToggle.Parent = speedSection
    
    local speedToggleCorner = Instance.new("UICorner")
    speedToggleCorner.CornerRadius = UDim.new(0, 6)
    speedToggleCorner.Parent = speedToggle
    
    -- Slider de velocidad
    local speedSliderFrame = Instance.new("Frame")
    speedSliderFrame.Size = UDim2.new(1, -30, 0, 30)
    speedSliderFrame.Position = UDim2.new(0, 15, 0, 40)
    speedSliderFrame.BackgroundTransparency = 1
    speedSliderFrame.Parent = speedSection
    
    local speedSliderLabel = Instance.new("TextLabel")
    speedSliderLabel.Size = UDim2.new(1, 0, 0, 15)
    speedSliderLabel.BackgroundTransparency = 1
    speedSliderLabel.Text = "Velocidad: 50"
    speedSliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedSliderLabel.TextSize = 12
    speedSliderLabel.Font = Enum.Font.Gotham
    speedSliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedSliderLabel.Parent = speedSliderFrame
    
    local speedSliderBg = Instance.new("Frame")
    speedSliderBg.Size = UDim2.new(1, 0, 0, 8)
    speedSliderBg.Position = UDim2.new(0, 0, 1, -8)
    speedSliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    speedSliderBg.BorderSizePixel = 0
    speedSliderBg.Parent = speedSliderFrame
    
    local speedSliderBgCorner = Instance.new("UICorner")
    speedSliderBgCorner.CornerRadius = UDim.new(0, 4)
    speedSliderBgCorner.Parent = speedSliderBg
    
    local speedSliderFill = Instance.new("Frame")
    speedSliderFill.Size = UDim2.new(0.25, 0, 1, 0) -- 50/200 = 0.25
    speedSliderFill.BackgroundColor3 = Color3.fromRGB(45, 85, 255)
    speedSliderFill.BorderSizePixel = 0
    speedSliderFill.Parent = speedSliderBg
    
    local speedSliderFillCorner = Instance.new("UICorner")
    speedSliderFillCorner.CornerRadius = UDim.new(0, 4)
    speedSliderFillCorner.Parent = speedSliderFill
    
    local speedSliderButton = Instance.new("TextButton")
    speedSliderButton.Size = UDim2.new(0, 16, 0, 16)
    speedSliderButton.Position = UDim2.new(0.25, -8, 0.5, -8)
    speedSliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    speedSliderButton.Text = ""
    speedSliderButton.Parent = speedSliderBg
    
    local speedSliderButtonCorner = Instance.new("UICorner")
    speedSliderButtonCorner.CornerRadius = UDim.new(1, 0)
    speedSliderButtonCorner.Parent = speedSliderButton
    
    -- Botones de velocidad predefinida
    local speedButtonsFrame = Instance.new("Frame")
    speedButtonsFrame.Size = UDim2.new(1, -30, 0, 25)
    speedButtonsFrame.Position = UDim2.new(0, 15, 0, 78)
    speedButtonsFrame.BackgroundTransparency = 1
    speedButtonsFrame.Parent = speedSection
    
    local speedButtons = {
        {text = "25", value = 25},
        {text = "50", value = 50},
        {text = "100", value = 100},
        {text = "200", value = 200}
    }
    
    for i, buttonData in ipairs(speedButtons) do
        local speedBtn = Instance.new("TextButton")
        speedBtn.Size = UDim2.new(0.23, 0, 1, 0)
        speedBtn.Position = UDim2.new((i-1) * 0.25 + 0.01, 0, 0, 0)
        speedBtn.BackgroundColor3 = Color3.fromRGB(45, 85, 255)
        speedBtn.Text = buttonData.text
        speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        speedBtn.TextSize = 11
        speedBtn.Font = Enum.Font.GothamBold
        speedBtn.Parent = speedButtonsFrame
        
        local speedBtnCorner = Instance.new("UICorner")
        speedBtnCorner.CornerRadius = UDim.new(0, 4)
        speedBtnCorner.Parent = speedBtn
        
        speedBtn.MouseButton1Click:Connect(function()
            ModStates.speedValue = buttonData.value
            speedSliderLabel.Text = "Velocidad: " .. buttonData.value
            local percentage = buttonData.value / 200
            speedSliderFill.Size = UDim2.new(percentage, 0, 1, 0)
            speedSliderButton.Position = UDim2.new(percentage, -8, 0.5, -8)
            
            if ModStates.speed then
                Humanoid.WalkSpeed = buttonData.value
            end
        end)
    end
    
    return {
        screenGui = screenGui,
        mainFrame = mainFrame,
        content = content,
        minimizeBtn = minimizeBtn,
        flyToggle = flyToggle,
        noclipToggle = noclipToggle,
        speedToggle = speedToggle,
        speedSliderButton = speedSliderButton,
        speedSliderFill = speedSliderFill,
        speedSliderLabel = speedSliderLabel,
        header = header
    }
end

-- Funciones de mod
local function toggleFly()
    ModStates.fly = not ModStates.fly
    
    if ModStates.fly then
        BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.Parent = RootPart
        
        Connections.flyConnection = RunService.Heartbeat:Connect(function()
            if BodyVelocity then
                local camera = workspace.CurrentCamera
                local moveVector = Vector3.new(0, 0, 0)
                
                -- Controles de movimiento
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveVector = moveVector + camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveVector = moveVector - camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveVector = moveVector - camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveVector = moveVector + camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveVector = moveVector + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveVector = moveVector - Vector3.new(0, 1, 0)
                end
                
                BodyVelocity.Velocity = moveVector * 50
            end
        end)
    else
        if BodyVelocity then
            BodyVelocity:Destroy()
            BodyVelocity = nil
        end
        if Connections.flyConnection then
            Connections.flyConnection:Disconnect()
            Connections.flyConnection = nil
        end
    end
end

local function toggleNoclip()
    ModStates.noclip = not ModStates.noclip
    
    if ModStates.noclip then
        Connections.noclipConnection = RunService.Stepped:Connect(function()
            for _, part in pairs(Character:GetChildren()) do
                if part:IsA("BasePart") and part ~= RootPart then
                    part.CanCollide = false
                end
            end
        end)
    else
        if Connections.noclipConnection then
            Connections.noclipConnection:Disconnect()
            Connections.noclipConnection = nil
        end
        
        for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") and part ~= RootPart then
                part.CanCollide = true
            end
        end
    end
end

local function toggleSpeed()
    ModStates.speed = not ModStates.speed
    
    if ModStates.speed then
        Humanoid.WalkSpeed = ModStates.speedValue
    else
        Humanoid.WalkSpeed = originalWalkSpeed
    end
end

-- Crear GUI
local gui = createGUI()

-- Funcionalidad minimizar
local function toggleMinimize()
    ModStates.isMinimized = not ModStates.isMinimized
    
    local targetSize = ModStates.isMinimized and UDim2.new(0, 320, 0, 50) or UDim2.new(0, 320, 0, 380)
    local targetText = ModStates.isMinimized and "□" or "−"
    
    local tween = TweenService:Create(gui.mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = targetSize})
    tween:Play()
    
    gui.minimizeBtn.Text = targetText
    gui.content.Visible = not ModStates.isMinimized
end

-- Conectar botones
gui.minimizeBtn.MouseButton1Click:Connect(toggleMinimize)

gui.flyToggle.MouseButton1Click:Connect(function()
    toggleFly()
    gui.flyToggle.Text = ModStates.fly and "ON" or "OFF"
    gui.flyToggle.BackgroundColor3 = ModStates.fly and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 70)
end)

gui.noclipToggle.MouseButton1Click:Connect(function()
    toggleNoclip()
    gui.noclipToggle.Text = ModStates.noclip and "ON" or "OFF"
    gui.noclipToggle.BackgroundColor3 = ModStates.noclip and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 70)
end)

gui.speedToggle.MouseButton1Click:Connect(function()
    toggleSpeed()
    gui.speedToggle.Text = ModStates.speed and "ON" or "OFF"
    gui.speedToggle.BackgroundColor3 = ModStates.speed and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 70)
end)

-- Funcionalidad del slider de velocidad
local dragging = false

gui.speedSliderButton.MouseButton1Down:Connect(function()
    dragging = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local sliderBg = gui.speedSliderButton.Parent
        local relativeX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        
        gui.speedSliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
        gui.speedSliderButton.Position = UDim2.new(relativeX, -8, 0.5, -8)
        
        ModStates.speedValue = math.floor(relativeX * 200 + 1)
        gui.speedSliderLabel.Text = "Velocidad: " .. ModStates.speedValue
        
        if ModStates.speed then
            Humanoid.WalkSpeed = ModStates.speedValue
        end
    end
end)

-- Hacer el GUI arrastrable
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

-- Limpiar al salir del juego
game:BindToClose(function()
    for _, connection in pairs(Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    if BodyVelocity then
        BodyVelocity:Destroy()
    end
end)

print("🚀 H2K Mod Menu cargado exitosamente!")
print("📱 Compatible con Android Krnl")
print("✨ GUI estético y funcional")