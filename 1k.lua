-- 🌲 H2K MOD MENU - 99 NIGHTS IN THE FOREST
-- Kill Aura, Speed x65, Infinite Jump, NoClip, Bring Items
-- Compatible Android Krnl - By H2K

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Estados del mod
local ModState = {
    killAura = false,
    speed = false,
    infiniteJump = false,
    noClip = false,
    autoScrap = false,
    isOpen = false
}

local Connections = {}
local originalWalkSpeed = Humanoid.WalkSpeed

-- Referencias del juego
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ItemsFolder = Workspace:WaitForChild("Items")
local CharactersFolder = Workspace:WaitForChild("Characters")

-- Items específicos
local scrapItems = {
    "UFO Junk", "UFO Component", "Old Car Engine", "Broken Fan", 
    "Old Microwave", "Bolt", "Sheet Metal", "Old Radio", "Tyre",
    "Washing Machine", "Broken Microwave", "Car Battery", "Generator"
}

local medicalItems = {
    "MedKit", "Bandage", "Pills"
}

-- Herramientas con sus IDs
local toolsDamageIDs = {
    ["Old Axe"] = "1_8982038982",
    ["Good Axe"] = "112_8982038982", 
    ["Strong Axe"] = "116_8982038982",
    ["Chainsaw"] = "647_8992824875",
    ["Spear"] = "196_8999010016",
    ["Knife"] = "324_8999010016"
}

-- Limpiar GUI anterior
pcall(function()
    if LocalPlayer.PlayerGui:FindFirstChild("H2KNightsForest") then
        LocalPlayer.PlayerGui:FindFirstChild("H2KNightsForest"):Destroy()
    end
    if game:GetService("CoreGui"):FindFirstChild("H2KIcon") then
        game:GetService("CoreGui"):FindFirstChild("H2KIcon"):Destroy()
    end
end)

-- Función para obtener herramienta equipable
local function getToolWithDamageID()
    for toolName, damageID in pairs(toolsDamageIDs) do
        local tool = LocalPlayer.Inventory:FindFirstChild(toolName)
        if tool then
            return tool, damageID
        end
    end
    return nil, nil
end

-- Función para equipar herramienta
local function equipTool(tool)
    if tool then
        pcall(function()
            RemoteEvents.EquipItemHandle:FireServer("FireAllClients", tool)
        end)
    end
end

-- Kill Aura Function con radio de 80 studs
local function toggleKillAura()
    ModState.killAura = not ModState.killAura
    
    if ModState.killAura then
        Connections.killAuraLoop = RunService.Heartbeat:Connect(function()
            if not ModState.killAura then return end
            
            local character = LocalPlayer.Character
            if not character then return end
            
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local tool, damageID = getToolWithDamageID()
            if not tool or not damageID then return end
            
            equipTool(tool)
            
            -- Atacar enemigos en radio de 80 studs
            for _, mob in pairs(CharactersFolder:GetChildren()) do
                if mob:IsA("Model") and mob ~= character then
                    -- Solo atacar animales y cultistas
                    if mob.Name:lower():find("cultist") or 
                       mob.Name:lower():find("bear") or 
                       mob.Name:lower():find("wolf") or
                       mob.Name:lower():find("deer") or
                       mob.Name:lower():find("rabbit") then
                        
                        local part = mob.PrimaryPart or mob:FindFirstChildWhichIsA("BasePart")
                        if part then
                            local distance = (part.Position - hrp.Position).Magnitude
                            if distance <= 80 then
                                pcall(function()
                                    RemoteEvents.ToolDamageObject:InvokeServer(
                                        mob, tool, damageID, CFrame.new(part.Position)
                                    )
                                end)
                            end
                        end
                    end
                end
            end
            
            wait(0.1)
        end)
    else
        if Connections.killAuraLoop then
            Connections.killAuraLoop:Disconnect()
            Connections.killAuraLoop = nil
        end
    end
end

-- Speed x65 Function
local function toggleSpeed()
    ModState.speed = not ModState.speed
    
    if ModState.speed then
        Humanoid.WalkSpeed = 65
        Connections.speedConnection = Humanoid.Changed:Connect(function(property)
            if property == "WalkSpeed" and ModState.speed then
                Humanoid.WalkSpeed = 65
            end
        end)
    else
        if Connections.speedConnection then
            Connections.speedConnection:Disconnect()
            Connections.speedConnection = nil
        end
        Humanoid.WalkSpeed = originalWalkSpeed
    end
end

-- Infinite Jump Function
local function toggleInfiniteJump()
    ModState.infiniteJump = not ModState.infiniteJump
    
    if ModState.infiniteJump then
        Connections.jumpConnection = UserInputService.JumpRequest:Connect(function()
            if ModState.infiniteJump and Humanoid then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if Connections.jumpConnection then
            Connections.jumpConnection:Disconnect()
            Connections.jumpConnection = nil
        end
    end
end

-- NoClip Function
local function toggleNoClip()
    ModState.noClip = not ModState.noClip
    
    if ModState.noClip then
        Connections.noClipLoop = RunService.Stepped:Connect(function()
            if ModState.noClip then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if Connections.noClipLoop then
            Connections.noClipLoop:Disconnect()
            Connections.noClipLoop = nil
        end
        
        -- Restaurar colisión
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

-- Auto Scrap Function
local function toggleAutoScrap()
    ModState.autoScrap = not ModState.autoScrap
    
    if ModState.autoScrap then
        Connections.scrapLoop = RunService.Heartbeat:Connect(function()
            if not ModState.autoScrap then return end
            
            local character = LocalPlayer.Character
            if not character then return end
            
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            for _, item in pairs(ItemsFolder:GetChildren()) do
                if table.find(scrapItems, item.Name) then
                    local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                    if part then
                        pcall(function()
                            RemoteEvents.RequestStartDraggingItem:FireServer(item)
                            task.wait(0.05)
                            item:SetPrimaryPartCFrame(hrp.CFrame + Vector3.new(math.random(-3,3), 2, math.random(-3,3)))
                            task.wait(0.05)
                            RemoteEvents.StopDraggingItem:FireServer(item)
                        end)
                        break
                    end
                end
            end
            
            task.wait(1)
        end)
    else
        if Connections.scrapLoop then
            Connections.scrapLoop:Disconnect()
            Connections.scrapLoop = nil
        end
    end
end

-- Bring All Scrap Function
local function bringAllScrap()
    local character = LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local stackOffsetY = 2
    local count = 0
    
    for _, item in pairs(ItemsFolder:GetChildren()) do
        if table.find(scrapItems, item.Name) then
            local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
            if part then
                pcall(function()
                    RemoteEvents.RequestStartDraggingItem:FireServer(item)
                    task.wait(0.05)
                    local offset = Vector3.new(math.random(-3,3), count * stackOffsetY + 2, math.random(-3,3))
                    item:SetPrimaryPartCFrame(hrp.CFrame + offset)
                    task.wait(0.05)
                    RemoteEvents.StopDraggingItem:FireServer(item)
                    count = count + 1
                end)
            end
        end
    end
end

-- Bring All Meds Function
local function bringAllMeds()
    local character = LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local stackOffsetY = 2
    local count = 0
    
    for _, item in pairs(ItemsFolder:GetChildren()) do
        if table.find(medicalItems, item.Name) then
            local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
            if part then
                pcall(function()
                    RemoteEvents.RequestStartDraggingItem:FireServer(item)
                    task.wait(0.05)
                    local offset = Vector3.new(math.random(-3,3), count * stackOffsetY + 2, math.random(-3,3))
                    item:SetPrimaryPartCFrame(hrp.CFrame + offset)
                    task.wait(0.05)
                    RemoteEvents.StopDraggingItem:FireServer(item)
                    count = count + 1
                end)
            end
        end
    end
end

-- Crear icono flotante H2K
local function createFloatingIcon()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "H2KIcon"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")
    
    local iconFrame = Instance.new("Frame")
    iconFrame.Size = UDim2.new(0, 50, 0, 50)
    iconFrame.Position = UDim2.new(1, -70, 0, 20)
    iconFrame.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = screenGui
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(1, 0)
    iconCorner.Parent = iconFrame
    
    local iconGradient = Instance.new("UIGradient")
    iconGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 139, 34)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 0))
    }
    iconGradient.Rotation = 45
    iconGradient.Parent = iconFrame
    
    local iconShadow = Instance.new("Frame")
    iconShadow.Size = UDim2.new(1, 6, 1, 6)
    iconShadow.Position = UDim2.new(0, -3, 0, -3)
    iconShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    iconShadow.BackgroundTransparency = 0.7
    iconShadow.ZIndex = iconFrame.ZIndex - 1
    iconShadow.Parent = iconFrame
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(1, 0)
    shadowCorner.Parent = iconShadow
    
    local iconText = Instance.new("TextLabel")
    iconText.Size = UDim2.new(1, 0, 1, 0)
    iconText.BackgroundTransparency = 1
    iconText.Text = "H2K"
    iconText.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconText.TextSize = 16
    iconText.Font = Enum.Font.GothamBold
    iconText.TextStrokeTransparency = 0
    iconText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    iconText.Parent = iconFrame
    
    local iconButton = Instance.new("TextButton")
    iconButton.Size = UDim2.new(1, 0, 1, 0)
    iconButton.BackgroundTransparency = 1
    iconButton.Text = ""
    iconButton.Parent = iconFrame
    
    return {
        gui = screenGui,
        frame = iconFrame,
        button = iconButton
    }
end

-- Crear mod menu principal
local function createModMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "H2KNightsForest"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 320, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = mainFrame
    
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
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 15)
    headerCorner.Parent = header
    
    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 139, 34)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 0))
    }
    headerGradient.Rotation = 45
    headerGradient.Parent = header
    
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 60, 1, 0)
    logo.Position = UDim2.new(0, 15, 0, 0)
    logo.BackgroundTransparency = 1
    logo.Text = "H2K"
    logo.TextColor3 = Color3.fromRGB(255, 255, 255)
    logo.TextSize = 20
    logo.Font = Enum.Font.GothamBold
    logo.TextStrokeTransparency = 0
    logo.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    logo.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -120, 1, 0)
    title.Position = UDim2.new(0, 80, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "99 Nights Forest"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.Gotham
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 8)
    closeBtnCorner.Parent = closeBtn
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 1, -60)
    content.Position = UDim2.new(0, 10, 0, 55)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    -- Kill Aura Section
    local killAuraSection = Instance.new("Frame")
    killAuraSection.Size = UDim2.new(1, 0, 0, 50)
    killAuraSection.Position = UDim2.new(0, 0, 0, 0)
    killAuraSection.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
    killAuraSection.BorderSizePixel = 0
    killAuraSection.Parent = content
    
    local killAuraCorner = Instance.new("UICorner")
    killAuraCorner.CornerRadius = UDim.new(0, 10)
    killAuraCorner.Parent = killAuraSection
    
    local killAuraLabel = Instance.new("TextLabel")
    killAuraLabel.Size = UDim2.new(1, -70, 1, 0)
    killAuraLabel.Position = UDim2.new(0, 15, 0, 0)
    killAuraLabel.BackgroundTransparency = 1
    killAuraLabel.Text = "Kill Aura (80 studs)\nAtaca animales y cultistas"
    killAuraLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    killAuraLabel.TextSize = 12
    killAuraLabel.Font = Enum.Font.Gotham
    killAuraLabel.TextXAlignment = Enum.TextXAlignment.Left
    killAuraLabel.Parent = killAuraSection
    
    local killAuraToggle = Instance.new("TextButton")
    killAuraToggle.Size = UDim2.new(0, 60, 0, 25)
    killAuraToggle.Position = UDim2.new(1, -65, 0.5, -12.5)
    killAuraToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    killAuraToggle.Text = "OFF"
    killAuraToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    killAuraToggle.TextSize = 11
    killAuraToggle.Font = Enum.Font.GothamBold
    killAuraToggle.Parent = killAuraSection
    
    local killAuraToggleCorner = Instance.new("UICorner")
    killAuraToggleCorner.CornerRadius = UDim.new(0, 6)
    killAuraToggleCorner.Parent = killAuraToggle
    
    -- Speed Section
    local speedSection = Instance.new("Frame")
    speedSection.Size = UDim2.new(1, 0, 0, 50)
    speedSection.Position = UDim2.new(0, 0, 0, 55)
    speedSection.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
    speedSection.BorderSizePixel = 0
    speedSection.Parent = content
    
    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(0, 10)
    speedCorner.Parent = speedSection
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, -70, 1, 0)
    speedLabel.Position = UDim2.new(0, 15, 0, 0)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed x65\nVelocidad aumentada"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.TextSize = 12
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = speedSection
    
    local speedToggle = Instance.new("TextButton")
    speedToggle.Size = UDim2.new(0, 60, 0, 25)
    speedToggle.Position = UDim2.new(1, -65, 0.5, -12.5)
    speedToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    speedToggle.Text = "OFF"
    speedToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedToggle.TextSize = 11
    speedToggle.Font = Enum.Font.GothamBold
    speedToggle.Parent = speedSection
    
    local speedToggleCorner = Instance.new("UICorner")
    speedToggleCorner.CornerRadius = UDim.new(0, 6)
    speedToggleCorner.Parent = speedToggle
    
    -- Infinite Jump Section
    local jumpSection = Instance.new("Frame")
    jumpSection.Size = UDim2.new(1, 0, 0, 50)
    jumpSection.Position = UDim2.new(0, 0, 0, 110)
    jumpSection.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
    jumpSection.BorderSizePixel = 0
    jumpSection.Parent = content
    
    local jumpCorner = Instance.new("UICorner")
    jumpCorner.CornerRadius = UDim.new(0, 10)
    jumpCorner.Parent = jumpSection
    
    local jumpLabel = Instance.new("TextLabel")
    jumpLabel.Size = UDim2.new(1, -70, 1, 0)
    jumpLabel.Position = UDim2.new(0, 15, 0, 0)
    jumpLabel.BackgroundTransparency = 1
    jumpLabel.Text = "Infinite Jump\nSalto infinito"
    jumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpLabel.TextSize = 12
    jumpLabel.Font = Enum.Font.Gotham
    jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
    jumpLabel.Parent = jumpSection
    
    local jumpToggle = Instance.new("TextButton")
    jumpToggle.Size = UDim2.new(0, 60, 0, 25)
    jumpToggle.Position = UDim2.new(1, -65, 0.5, -12.5)
    jumpToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    jumpToggle.Text = "OFF"
    jumpToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpToggle.TextSize = 11
    jumpToggle.Font = Enum.Font.GothamBold
    jumpToggle.Parent = jumpSection
    
    local jumpToggleCorner = Instance.new("UICorner")
    jumpToggleCorner.CornerRadius = UDim.new(0, 6)
    jumpToggleCorner.Parent = jumpToggle
    
    -- NoClip Section
    local noClipSection = Instance.new("Frame")
    noClipSection.Size = UDim2.new(1, 0, 0, 50)
    noClipSection.Position = UDim2.new(0, 0, 0, 165)
    noClipSection.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
    noClipSection.BorderSizePixel = 0
    noClipSection.Parent = content
    
    local noClipCorner = Instance.new("UICorner")
    noClipCorner.CornerRadius = UDim.new(0, 10)
    noClipCorner.Parent = noClipSection
    
    local noClipLabel = Instance.new("TextLabel")
    noClipLabel.Size = UDim2.new(1, -70, 1, 0)
    noClipLabel.Position = UDim2.new(0, 15, 0, 0)
    noClipLabel.BackgroundTransparency = 1
    noClipLabel.Text = "NoClip\nCamina a través de paredes"
    noClipLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    noClipLabel.TextSize = 12
    noClipLabel.Font = Enum.Font.Gotham
    noClipLabel.TextXAlignment = Enum.TextXAlignment.Left
    noClipLabel.Parent = noClipSection
    
    local noClipToggle = Instance.new("TextButton")
    noClipToggle.Size = UDim2.new(0, 60, 0, 25)
    noClipToggle.Position = UDim2.new(1, -65, 0.5, -12.5)
    noClipToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    noClipToggle.Text = "OFF"
    noClipToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    noClipToggle.TextSize = 11
    noClipToggle.Font = Enum.Font.GothamBold
    noClipToggle.Parent = noClipSection
    
    local noClipToggleCorner = Instance.new("UICorner")
    noClipToggleCorner.CornerRadius = UDim.new(0, 6)
    noClipToggleCorner.Parent = noClipToggle
    
    -- Auto Scrap Section
    local autoScrapSection = Instance.new("Frame")
    autoScrapSection.Size = UDim2.new(1, 0, 0, 50)
    autoScrapSection.Position = UDim2.new(0, 0, 0, 220)
    autoScrapSection.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
    autoScrapSection.BorderSizePixel = 0
    autoScrapSection.Parent = content
    
    local autoScrapCorner = Instance.new("UICorner")
    autoScrapCorner.CornerRadius = UDim.new(0, 10)
    autoScrapCorner.Parent = autoScrapSection
    
    local autoScrapLabel = Instance.new("TextLabel")
    autoScrapLabel.Size = UDim2.new(1, -70, 1, 0)
    autoScrapLabel.Position = UDim2.new(0, 15, 0, 0)
    autoScrapLabel.BackgroundTransparency = 1
    autoScrapLabel.Text = "Auto Scrap\nRecolecta chatarra automático"
    autoScrapLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoScrapLabel.TextSize = 12
    autoScrapLabel.Font = Enum.Font.Gotham
    autoScrapLabel.TextXAlignment = Enum.TextXAlignment.Left
    autoScrapLabel.Parent = autoScrapSection
    
    local autoScrapToggle = Instance.new("TextButton")
    autoScrapToggle.Size = UDim2.new(0, 60, 0, 25)
    autoScrapToggle.Position = UDim2.new(1, -65, 0.5, -12.5)
    autoScrapToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    autoScrapToggle.Text = "OFF"
    autoScrapToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    autoScrapToggle.TextSize = 11
    autoScrapToggle.Font = Enum.Font.GothamBold
    autoScrapToggle.Parent = autoScrapSection
    
    local autoScrapToggleCorner = Instance.new("UICorner")
    autoScrapToggleCorner.CornerRadius = UDim.new(0, 6)
    autoScrapToggleCorner.Parent = autoScrapToggle
    
    -- Bring Buttons Section
    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Size = UDim2.new(1, 0, 0, 80)
    buttonsFrame.Position = UDim2.new(0, 0, 0, 275)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Parent = content
    
    local bringScrapBtn = Instance.new("TextButton")
    bringScrapBtn.Size = UDim2.new(1, -5, 0, 35)
    bringScrapBtn.Position = UDim2.new(0, 0, 0, 0)
    bringScrapBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    bringScrapBtn.Text = "🔧 Bring All Scrap"
    bringScrapBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    bringScrapBtn.TextSize = 12
    bringScrapBtn.Font = Enum.Font.GothamBold
    bringScrapBtn.Parent = buttonsFrame
    
    local bringScrapCorner = Instance.new("UICorner")
    bringScrapCorner.CornerRadius = UDim.new(0, 8)
    bringScrapCorner.Parent = bringScrapBtn
    
    local bringMedsBtn = Instance.new("TextButton")
    bringMedsBtn.Size = UDim2.new(1, -5, 0, 35)
    bringMedsBtn.Position = UDim2.new(0, 0, 0, 40)
    bringMedsBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    bringMedsBtn.Text = "🩹 Bring All Meds"
    bringMedsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    bringMedsBtn.TextSize = 12
    bringMedsBtn.Font = Enum.Font.GothamBold
    bringMedsBtn.Parent = buttonsFrame
    
    local bringMedsCorner = Instance.new("UICorner")
    bringMedsCorner.CornerRadius = UDim.new(0, 8)
    bringMedsCorner.Parent = bringMedsBtn
    
    -- Info Footer
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 0, 25)
    infoLabel.Position = UDim2.new(0, 0, 0, 360)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "H2K Mod Menu - Compatible Android Krnl v2.0"
    infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    infoLabel.TextSize = 10
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextXAlignment = Enum.TextXAlignment.Center
    infoLabel.Parent = content
    
    -- Event Connections
    killAuraToggle.MouseButton1Click:Connect(function()
        toggleKillAura()
        if ModState.killAura then
            killAuraToggle.Text = "ON"
            killAuraToggle.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
        else
            killAuraToggle.Text = "OFF"
            killAuraToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        end
    end)
    
    speedToggle.MouseButton1Click:Connect(function()
        toggleSpeed()
        if ModState.speed then
            speedToggle.Text = "ON"
            speedToggle.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
        else
            speedToggle.Text = "OFF"
            speedToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        end
    end)
    
    jumpToggle.MouseButton1Click:Connect(function()
        toggleInfiniteJump()
        if ModState.infiniteJump then
            jumpToggle.Text = "ON"
            jumpToggle.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
        else
            jumpToggle.Text = "OFF"
            jumpToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        end
    end)
    
    noClipToggle.MouseButton1Click:Connect(function()
        toggleNoClip()
        if ModState.noClip then
            noClipToggle.Text = "ON"
            noClipToggle.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
        else
            noClipToggle.Text = "OFF"
            noClipToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        end
    end)
    
    autoScrapToggle.MouseButton1Click:Connect(function()
        toggleAutoScrap()
        if ModState.autoScrap then
            autoScrapToggle.Text = "ON"
            autoScrapToggle.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
        else
            autoScrapToggle.Text = "OFF"
            autoScrapToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        end
    end)
    
    bringScrapBtn.MouseButton1Click:Connect(function()
        bringAllScrap()
        bringScrapBtn.Text = "✅ Scrap Brought!"
        wait(2)
        bringScrapBtn.Text = "🔧 Bring All Scrap"
    end)
    
    bringMedsBtn.MouseButton1Click:Connect(function()
        bringAllMeds()
        bringMedsBtn.Text = "✅ Meds Brought!"
        wait(2)
        bringMedsBtn.Text = "🩹 Bring All Meds"
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        ModState.isOpen = false
        mainFrame.Visible = false
    end)
    
    return {
        gui = screenGui,
        frame = mainFrame,
        toggleVisibility = function()
            ModState.isOpen = not ModState.isOpen
            mainFrame.Visible = ModState.isOpen
        end
    }
end

-- Hacer el GUI draggable
local function makeDraggable(frame)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Character Respawn Handler
local function onCharacterAdded(character)
    Character = character
    Humanoid = character:WaitForChild("Humanoid")
    RootPart = character:WaitForChild("HumanoidRootPart")
    originalWalkSpeed = Humanoid.WalkSpeed
    
    -- Reactivar funciones si estaban activas
    if ModState.speed then
        wait(1)
        Humanoid.WalkSpeed = 65
    end
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- Crear y configurar GUI
local floatingIcon = createFloatingIcon()
local modMenu = createModMenu()

-- Hacer draggable el header
makeDraggable(modMenu.frame.Header)

-- Conectar icono flotante
floatingIcon.button.MouseButton1Click:Connect(function()
    modMenu.toggleVisibility()
end)

-- Cleanup al salir
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        for _, connection in pairs(Connections) do
            if connection then
                connection:Disconnect()
            end
        end
    end
end)

-- Notificación de carga
print("🌲 H2K 99 Nights Forest Mod Menu Cargado!")
print("✅ Kill Aura: Radio 80 studs - Solo animales y cultistas")
print("✅ Speed x65: Velocidad aumentada")  
print("✅ Infinite Jump: Salto infinito")
print("✅ NoClip: Camina a través de paredes")
print("✅ Auto Scrap: Recolecta chatarra automático")
print("✅ Bring Items: Botones para traer items")
print("📱 Compatible con Android Krnl")