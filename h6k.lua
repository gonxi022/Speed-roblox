-- 🌲 H2K MOD MENU - 99 NIGHTS IN THE FOREST
-- Mod completo con Kill Aura, Speed, Infinite Jump, Auto Scrap, Bring Items
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

-- Services y Referencias
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ItemsFolder = Workspace:WaitForChild("Items")

-- Estados del mod
local ModState = {
    killAura = false,
    speed = false,
    infiniteJump = false,
    instaChests = false,
    autoScrap = false,
    bringScrap = false,
    bringMeds = false,
    isOpen = false,
    minimized = false
}

local Connections = {}
local originalWalkSpeed = Humanoid.WalkSpeed
local originalJumpPower = Humanoid.JumpPower

-- Herramientas y sus IDs de daño
local toolsDamageIDs = {
    ["Old Axe"] = "1_8982038982",
    ["Good Axe"] = "112_8982038982", 
    ["Strong Axe"] = "116_8982038982",
    ["Chainsaw"] = "647_8992824875",
    ["Spear"] = "196_8999010016"
}

-- Items específicos para cada botón
local scrapItems = {
    "UFO Junk", "UFO Component", "Old Car Engine", "Broken Fan", 
    "Old Microwave", "Bolt", "Sheet Metal", "Old Radio", "Tyre",
    "Washing Machine", "Broken Microwave"
}

local medicalItems = {
    "MedKit", "Bandage"
}

-- Posición del campamento
local campPosition = Vector3.new(0, 8, 0)

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

-- Sistema Kill Aura mejorado
local function startKillAura()
    if Connections.killAuraLoop then return end
    
    Connections.killAuraLoop = RunService.Heartbeat:Connect(function()
        if not ModState.killAura then return end
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local tool, damageID = getToolWithDamageID()
        if not tool or not damageID then return end
        
        equipTool(tool)
        
        for _, mob in pairs(Workspace.Characters:GetChildren()) do
            if mob:IsA("Model") and mob ~= character then
                local part = mob:FindFirstChildWhichIsA("BasePart")
                if part and (part.Position - hrp.Position).Magnitude <= 50 then
                    pcall(function()
                        RemoteEvents.ToolDamageObject:InvokeServer(
                            mob, tool, damageID, CFrame.new(part.Position)
                        )
                    end)
                end
            end
        end
        
        wait(0.1)
    end)
end

local function stopKillAura()
    if Connections.killAuraLoop then
        Connections.killAuraLoop:Disconnect()
        Connections.killAuraLoop = nil
    end
end

local function toggleKillAura()
    ModState.killAura = not ModState.killAura
    if ModState.killAura then
        startKillAura()
    else
        stopKillAura()
    end
end

-- Función de Speed
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

-- Función de Infinite Jump
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

-- Función de Insta Open Chests
local function toggleInstaChests()
    ModState.instaChests = not ModState.instaChests
    if ModState.instaChests then
        Connections.chestConnection = Workspace.DescendantAdded:Connect(function(descendant)
            if ModState.instaChests and descendant:IsA("ClickDetector") then
                local parent = descendant.Parent
                if parent and (parent.Name:lower():find("chest") or parent.Name:lower():find("cofre")) then
                    wait(0.1)
                    pcall(function()
                        fireclickdetector(descendant)
                    end)
                end
            end
        end)
    else
        if Connections.chestConnection then
            Connections.chestConnection:Disconnect()
            Connections.chestConnection = nil
        end
    end
end

-- Sistema Auto Scrap mejorado (sin moverse visualmente)
local function startAutoScrap()
    if Connections.scrapLoop then return end
    
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
end

local function stopAutoScrap()
    if Connections.scrapLoop then
        Connections.scrapLoop:Disconnect()
        Connections.scrapLoop = nil
    end
end

local function toggleAutoScrap()
    ModState.autoScrap = not ModState.autoScrap
    if ModState.autoScrap then
        startAutoScrap()
    else
        stopAutoScrap()
    end
end

-- Función para traer chatarra específica (botón manual)
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

-- Función para traer items médicos específicos (botón manual)
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

-- Crear icono flotante H2K (más pequeño)
local function createFloatingIcon()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "H2KIcon"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")
    
    local iconFrame = Instance.new("Frame")
    iconFrame.Name = "IconFrame"
    iconFrame.Size = UDim2.new(0, 45, 0, 45)
    iconFrame.Position = UDim2.new(1, -60, 0, 10)
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
    
    local iconText = Instance.new("TextLabel")
    iconText.Size = UDim2.new(1, 0, 1, 0)
    iconText.BackgroundTransparency = 1
    iconText.Text = "H2K"
    iconText.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconText.TextSize = 14
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

-- Crear mod menu principal (compacto)
local function createModMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "H2KNightsForest"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")
    
    -- Frame principal más pequeño
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 280, 0, 380)
    mainFrame.Position = UDim2.new(0.5, -140, 0.5, -190)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame
    
    -- Header más pequeño
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 139, 34)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 0))
    }
    headerGradient.Rotation = 45
    headerGradient.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -80, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "H2K - 99 Nights"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 7.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 5)
    closeBtnCorner.Parent = closeBtn
    
    -- Contenido compacto
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -16, 1, -50)
    content.Position = UDim2.new(0, 8, 0, 45)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    -- Kill Aura Toggle
    local killAuraSection = Instance.new("Frame")
    killAuraSection.Size = UDim2.new(1, 0, 0, 40)
    killAuraSection.Position = UDim2.new(0, 0, 0, 0)
    killAuraSection.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
    killAuraSection.BorderSizePixel = 0
    killAuraSection.Parent = content
    
    local killAuraCorner = Instance.new("UICorner")
    killAuraCorner.CornerRadius = UDim.new(0, 6)
    killAuraCorner.Parent = killAuraSection
    
    local killAuraLabel = Instance.new("TextLabel")
    killAuraLabel.Size = UDim2.new(1, -60, 1, 0)
    killAuraLabel.Position = UDim2.new(0, 10, 0, 0)
    killAuraLabel.BackgroundTransparency = 1
    killAuraLabel.Text = "Kill Aura"
    killAuraLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    killAuraLabel.TextSize = 12
    killAuraLabel.Font = Enum.Font.Gotham
    killAuraLabel.TextXAlignment = Enum.TextXAlignment.Left
    killAuraLabel.Parent = killAuraSection
    
    local killAuraToggle = Instance.new("TextButton")
    killAuraToggle.Size = UDim2.new(0, 45, 0, 22)
    killAuraToggle.Position = UDim2.new(1, -50, 0.5, -11)
    killAuraToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    killAuraToggle.Text = "OFF"
    killAuraToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    killAuraToggle.TextSize = 10
    killAuraToggle.Font = Enum.Font.GothamBold
    killAuraToggle.Parent = killAuraSection
    
    local killAuraToggleCorner = Instance.new("UICorner")
    killAuraToggleCorner.CornerRadius = UDim.new(0, 5)
    killAuraToggleCorner.Parent = killAuraToggle
    
    -- Speed Toggle
    local speedSection = Instance.new("Frame")
    speedSection.Size = UDim2.new(1, 0, 0, 40)
    speedSection.Position = UDim2.new(0, 0, 0, 45)
    speedSection.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
    speedSection.BorderSizePixel = 0
    speedSection.Parent = content
    
    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(0, 6)
    speedCorner.Parent = speedSection
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(1, -60, 1, 0)
    speedLabel.Position = UDim2.new(0, 10, 0, 0)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed x65"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.TextSize = 12
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = speedSection
    
    local speedToggle = Instance.new("TextButton")
    speedToggle.Size = UDim2.new(0, 45, 0, 22)
    speedToggle.Position = UDim2.new(1, -50, 0.5, -11)
    speedToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    speedToggle.Text = "OFF"
    speedToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedToggle.TextSize = 10
    speedToggle.Font = Enum.Font.GothamBold
    speedToggle.Parent = speedSection
    
    local speedToggleCorner = Instance.new("UICorner")
    speedToggleCorner.CornerRadius = UDim.new(0, 5)
    speedToggleCorner.Parent = speedToggle
    
    -- Infinite Jump Toggle
    local jumpSection = Instance.new("Frame")
    jumpSection.Size = UDim2.new(1, 0, 0, 40)
    jumpSection.Position = UDim2.new(0, 0, 0, 90)
    jumpSection.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
    jumpSection.BorderSizePixel = 0
    jumpSection.Parent = content
    
    local jumpCorner = Instance.new("UICorner")
    jumpCorner.CornerRadius = UDim.new(0, 6)
    jumpCorner.Parent = jumpSection
    
    local jumpLabel = Instance.new("TextLabel")
    jumpLabel.Size = UDim2.new(1, -60, 1, 0)
    jumpLabel.Position = UDim2.new(0, 10, 0, 0)
    jumpLabel.BackgroundTransparency = 1
    jumpLabel.Text = "Infinite Jump"
    jumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpLabel.TextSize = 12
    jumpLabel.Font = Enum.Font.Gotham
    jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
    jumpLabel.Parent = jumpSection
    
    local jumpToggle = Instance.new("TextButton")
    jumpToggle.Size = UDim2.new(0, 45, 0, 22)
    jumpToggle.Position = UDim2.new(1, -50, 0.5, -11)
    jumpToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    jumpToggle.Text = "OFF"
    jumpToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpToggle.TextSize = 10
    jumpToggle.Font = Enum.Font.GothamBold
    jumpToggle.Parent = jumpSection
    
    local jumpToggleCorner = Instance.new("UICorner")
    jumpToggleCorner.CornerRadius = UDim.new(0, 5)
    jumpToggleCorner.Parent = jumpToggle
    
    -- Insta Chests Toggle
    local chestsSection = Instance.new("Frame")
    chestsSection.Size = UDim2.new(1, 0, 0, 40)
    chestsSection.Position = UDim2.new(0, 0, 0, 135)
    chestsSection.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
    chestsSection.BorderSizePixel = 0
    chestsSection.Parent = content
    
    local chestsCorner = Instance.new("UICorner")
    chestsCorner.CornerRadius = UDim.new(0, 6)
    chestsCorner.Parent = chestsSection
    
    local chestsLabel = Instance.new("TextLabel")
    chestsLabel.Size = UDim2.new(1, -60, 1, 0)
    chestsLabel.Position = UDim2.new(0, 10, 0, 0)
    chestsLabel.BackgroundTransparency = 1
    chestsLabel.Text = "Insta Chests"
    chestsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    chestsLabel.TextSize = 12
    chestsLabel.Font = Enum.Font.Gotham
    chestsLabel.TextXAlignment = Enum.TextXAlignment.Left
    chestsLabel.Parent = chestsSection
    
    local chestsToggle = Instance.new("TextButton")
    chestsToggle.Size = UDim2.new(0, 45, 0, 22)
    chestsToggle.Position = UDim2.new(1, -50, 0.5, -11)
    chestsToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    chestsToggle.Text = "OFF"
    chestsToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    chestsToggle.TextSize = 10
    chestsToggle.Font = Enum.Font.GothamBold
    chestsToggle.Parent = chestsSection
    
    local chestsToggleCorner = Instance.new("UICorner")
    chestsToggleCorner.CornerRadius = UDim.new(0, 5)
    chestsToggleCorner.Parent = chestsToggle
    
    -- Auto Scrap Toggle
    local scrapSection = Instance.new("Frame")
    scrapSection.Size = UDim2.new(1, 0, 0, 40)
    scrapSection.Position = UDim2.new(0, 0, 0, 180)
    scrapSection.BackgroundColor3 = Color3.fromRGB(30, 35, 40)
    scrapSection.BorderSizePixel = 0
    scrapSection.Parent = content
    
    local scrapCorner = Instance.new("UICorner")
    scrapCorner.CornerRadius = UDim.new(0, 6)
    scrapCorner.Parent = scrapSection
    
    local scrapLabel = Instance.new("TextLabel")
    scrapLabel.Size = UDim2.new(1, -60, 1, 0)
    scrapLabel.Position = UDim2.new(0, 10, 0, 0)
    scrapLabel.BackgroundTransparency = 1
    scrapLabel.Text = "Auto Scrap"
    scrapLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    scrapLabel.TextSize = 12
    scrapLabel.Font = Enum.Font.Gotham
    scrapLabel.TextXAlignment = Enum.TextXAlignment.Left
    scrapLabel.Parent = scrapSection
    
    local scrapToggle = Instance.new("TextButton")
    scrapToggle.Size = UDim2.new(0, 45, 0, 22)
    scrapToggle.Position = UDim2.new(1, -50, 0.5, -11)
    scrapToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    scrapToggle.Text = "OFF"
    scrapToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    scrapToggle.TextSize = 10
    scrapToggle.Font = Enum.Font.GothamBold
    scrapToggle.Parent = scrapSection
    
    local scrapToggleCorner = Instance.new("UICorner")
    scrapToggleCorner.CornerRadius = UDim.new(0, 5)
    scrapToggleCorner.Parent = scrapToggle
    
    -- Bring Scrap Button
    local bringScrapBtn = Instance.new("TextButton")
    bringScrapBtn.Size = UDim2.new(0, 130, 0, 30)
    bringScrapBtn.Position = UDim2.new(0, 0, 0, 230)
    bringScrapBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    bringScrapBtn.Text = "Bring All Scrap"
    bringScrapBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    bringScrapBtn.TextSize = 11
    bringScrapBtn.Font = Enum.Font.GothamBold
    bringScrapBtn.Parent = content
    
    local bringScrapCorner = Instance.new("UICorner")
    bringScrapCorner.CornerRadius = UDim.new(0, 6)
    bringScrapCorner.Parent = bringScrapBtn
    
    -- Bring Meds Button
    local bringMedsBtn = Instance.new("TextButton")
    bringMedsBtn.Size = UDim2.new(0, 130, 0, 30)
    bringMedsBtn.Position = UDim2.new(0, 134, 0, 230)
    bringMedsBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    bringMedsBtn.Text = "Bring All Meds"
    bringMedsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    bringMedsBtn.TextSize = 11
    bringMedsBtn.Font = Enum.Font.GothamBold
    bringMedsBtn.Parent = content
    
    local bringMedsCorner = Instance.new("UICorner")
    bringMedsCorner.CornerRadius = UDim.new(0, 6)
    bringMedsCorner.Parent = bringMedsBtn
    
    -- TP to Camp Button
    local campBtn = Instance.new("TextButton")
    campBtn.Size = UDim2.new(1, 0, 0, 30)
    campBtn.Position = UDim2.new(0, 0, 0, 270)
    campBtn.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    campBtn.Text = "Teleport to Camp"
    campBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    campBtn.TextSize = 12
    campBtn.Font = Enum.Font.GothamBold
    campBtn.Parent = content
    
    local campBtnCorner = Instance.new("UICorner")
    campBtnCorner.CornerRadius = UDim.new(0, 6)
    campBtnCorner.Parent = campBtn
    
    return {
        gui = screenGui,
        mainFrame = mainFrame,
        content = content,
        closeBtn = closeBtn,
        killAuraToggle = killAuraToggle,
        speedToggle = speedToggle,
        jumpToggle = jumpToggle,
        chestsToggle = chestsToggle,
        scrapToggle = scrapToggle,
        bringScrapBtn = bringScrapBtn,
        bringMedsBtn = bringMedsBtn,
        campBtn = campBtn
    }
end

-- Crear sistema completo
local icon = createFloatingIcon()
local menu = createModMenu()

-- Función para alternar visibilidad del menu
local function toggleMenu()
    ModState.isOpen = not ModState.isOpen
    menu.mainFrame.Visible = ModState.isOpen
    
    if ModState.isOpen then
        menu.mainFrame.Size = UDim2.new(0, 0, 0, 0)
        menu.mainFrame:TweenSize(
            UDim2.new(0, 280, 0, 380),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Back,
            0.3,
            true
        )
    end
end

-- Función para actualizar UI de toggle
local function updateToggleUI(button, enabled)
    if enabled then
        button.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
        button.Text = "ON"
    else
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        button.Text = "OFF"
    end
end

-- Eventos del icono
icon.button.MouseButton1Click:Connect(function()
    icon.frame:TweenSize(
        UDim2.new(0, 40, 0, 40),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.1,
        true,
        function()
            icon.frame:TweenSize(
                UDim2.new(0, 45, 0, 45),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.1,
                true
            )
        end
    )
    toggleMenu()
end)

-- Eventos del menu principal
menu.closeBtn.MouseButton1Click:Connect(function()
    ModState.isOpen = false
    menu.mainFrame:TweenSize(
        UDim2.new(0, 0, 0, 0),
        Enum.EasingDirection.In,
        Enum.EasingStyle.Back,
        0.2,
        true,
        function()
            menu.mainFrame.Visible = false
        end
    )
end)

-- Eventos de funcionalidades
menu.killAuraToggle.MouseButton1Click:Connect(function()
    toggleKillAura()
    updateToggleUI(menu.killAuraToggle, ModState.killAura)
end)

menu.speedToggle.MouseButton1Click:Connect(function()
    toggleSpeed()
    updateToggleUI(menu.speedToggle, ModState.speed)
end)

menu.jumpToggle.MouseButton1Click:Connect(function()
    toggleInfiniteJump()
    updateToggleUI(menu.jumpToggle, ModState.infiniteJump)
end)

menu.chestsToggle.MouseButton1Click:Connect(function()
    toggleInstaChests()
    updateToggleUI(menu.chestsToggle, ModState.instaChests)
end)

menu.scrapToggle.MouseButton1Click:Connect(function()
    toggleAutoScrap()
    updateToggleUI(menu.scrapToggle, ModState.autoScrap)
end)

-- Eventos de botones específicos
menu.bringScrapBtn.MouseButton1Click:Connect(function()
    bringAllScrap()
    
    -- Feedback visual
    menu.bringScrapBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    menu.bringScrapBtn.Text = "DONE!"
    task.wait(0.5)
    menu.bringScrapBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    menu.bringScrapBtn.Text = "Bring All Scrap"
end)

menu.bringMedsBtn.MouseButton1Click:Connect(function()
    bringAllMeds()
    
    -- Feedback visual
    menu.bringMedsBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    menu.bringMedsBtn.Text = "DONE!"
    task.wait(0.5)
    menu.bringMedsBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    menu.bringMedsBtn.Text = "Bring All Meds"
end)

menu.campBtn.MouseButton1Click:Connect(function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(campPosition)
        
        -- Feedback visual
        menu.campBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        menu.campBtn.Text = "DONE!"
        task.wait(0.3)
        menu.campBtn.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
        menu.campBtn.Text = "Teleport to Camp"
    end
end)

-- Hacer draggable el menu
local dragging = false
local dragStart = nil
local startPos = nil

menu.mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = menu.mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

menu.mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            local delta = input.Position - dragStart
            menu.mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end
end)

-- Auto-actualización del character al respawnear
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    RootPart = newChar:WaitForChild("HumanoidRootPart")
    
    originalWalkSpeed = Humanoid.WalkSpeed
    originalJumpPower = Humanoid.JumpPower
    
    -- Reaplica estados activos
    if ModState.speed then
        Humanoid.WalkSpeed = 65
        if Connections.speedConnection then
            Connections.speedConnection:Disconnect()
        end
        Connections.speedConnection = Humanoid.Changed:Connect(function(property)
            if property == "WalkSpeed" and ModState.speed then
                Humanoid.WalkSpeed = 65
            end
        end)
    end
    
    if ModState.killAura then
        stopKillAura()
        startKillAura()
    end
    
    if ModState.autoScrap then
        stopAutoScrap()
        startAutoScrap()
    end
end)

-- Notificación de carga exitosa
local function showLoadNotification()
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "H2KLoadNotification"
    notificationGui.Parent = game:GetService("CoreGui")
    
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 280, 0, 60)
    notification.Position = UDim2.new(0.5, -140, 0, -80)
    notification.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
    notification.BorderSizePixel = 0
    notification.Parent = notificationGui
    
    local notificationCorner = Instance.new("UICorner")
    notificationCorner.CornerRadius = UDim.new(0, 8)
    notificationCorner.Parent = notification
    
    local notificationText = Instance.new("TextLabel")
    notificationText.Size = UDim2.new(1, -16, 1, 0)
    notificationText.Position = UDim2.new(0, 8, 0, 0)
    notificationText.BackgroundTransparency = 1
    notificationText.Text = "H2K Mod Menu Loaded!\nClick H2K icon to open"
    notificationText.TextColor3 = Color3.fromRGB(255, 255, 255)
    notificationText.TextSize = 12
    notificationText.Font = Enum.Font.GothamBold
    notificationText.TextStrokeTransparency = 0
    notificationText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    notificationText.Parent = notification
    
    -- Animación de entrada
    notification:TweenPosition(
        UDim2.new(0.5, -140, 0, 15),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Back,
        0.5,
        true,
        function()
            task.wait(3)
            notification:TweenPosition(
                UDim2.new(0.5, -140, 0, -80),
                Enum.EasingDirection.In,
                Enum.EasingStyle.Back,
                0.3,
                true,
                function()
                    notificationGui:Destroy()
                end
            )
        end
    )
end

-- Protección anti-detección mejorada
local function antiDetection()
    spawn(function()
        task.wait(1)
        for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
            if gui.Name:find("H2K") then
                gui.Parent = game:GetService("CoreGui")
            end
        end
    end)
    
    spawn(function()
        while task.wait(5) do
            if not game:GetService("CoreGui"):FindFirstChild("H2KIcon") then
                icon = createFloatingIcon()
                menu = createModMenu()
            end
        end
    end)
end

-- Ejecutar protección
spawn(antiDetection)

-- Mostrar notificación de carga
showLoadNotification()

-- Sistema de cleanup mejorado
local function cleanupConnections()
    for name, connection in pairs(Connections) do
        if connection and typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    table.clear(Connections)
end

-- Cleanup al salir del juego
game:BindToClose(function()
    cleanupConnections()
    
    pcall(function()
        if icon and icon.gui then
            icon.gui:Destroy()
        end
        if menu and menu.gui then
            menu.gui:Destroy()
        end
    end)
end)

-- Sistema de reconexión automática para estados activos
spawn(function()
    while task.wait(1) do
        if ModState.killAura and not Connections.killAuraLoop then
            startKillAura()
        end
        
        if ModState.autoScrap and not Connections.scrapLoop then
            startAutoScrap()
        end
        
        if ModState.speed and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.WalkSpeed ~= 65 then
                humanoid.WalkSpeed = 65
            end
        end
    end
end)

-- Mensaje final en consola
print("🌲 H2K Mod Menu for 99 Nights in the Forest - Loaded Successfully!")
print("📱 Optimized for Android Krnl")
print("🎯 Features: Kill Aura, Speed x65, Infinite Jump, Insta Chests, Auto Scrap, Bring Items")
print("💚 Click the H2K icon to start using the mod menu")
print("🔧 Bring All Scrap: " .. table.concat(scrapItems, ", "))
print("🏥 Bring All Meds: " .. table.concat(medicalItems, ", "))