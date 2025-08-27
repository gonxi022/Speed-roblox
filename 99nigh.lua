-- 99 Nights in the Forest H2K Mod Menu - CORREGIDO
-- Optimizado para KRNL Android - By H2K

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variables globales
local ModState = {
    isOpen = false,
    noclip = false,
    infiniteJump = false,
    killAura = false,
    autoWood = false,
    autoScrap = false,
    autoMedical = false,
    killAuraRange = 20
}

local Connections = {}
local gui = nil

-- Función para limpiar GUIs anteriores
pcall(function()
    if PlayerGui:FindFirstChild("H2K_99Nights") then
        PlayerGui:FindFirstChild("H2K_99Nights"):Destroy()
    end
end)

-- Función para encontrar campfire (lugar de entrega)
local function findCampfire()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("campfire") or obj.Name:lower():find("fire") then
            if obj:IsA("Part") or obj:IsA("MeshPart") then
                return obj
            end
        end
    end
    
    -- Si no encuentra campfire, usar el spawn del jugador
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return LocalPlayer.Character.HumanoidRootPart
    end
    
    return nil
end

-- Función mejorada para encontrar objetos específicos
local function findItemsAdvanced(itemType)
    local items = {}
    local itemNames = {}
    
    if itemType == "Wood" then
        -- Solo troncos, no árboles
        itemNames = {
            "Log", "WoodLog", "TreeLog", "FallenLog", "CutLog", 
            "Timber", "Branch", "WoodPiece", "LogPile"
        }
    elseif itemType == "Scrap" then
        -- Metales y chatarra específicos
        itemNames = {
            "Scrap", "MetalScrap", "IronScrap", "SteelScrap",
            "Can", "Bolt", "Nut", "Pipe", "Wire", "Metal",
            "Iron", "Steel", "Copper", "Aluminum", "Tin"
        }
    elseif itemType == "Medical" then
        -- Medikit y vendas
        itemNames = {
            "Medkit", "MedKit", "FirstAidKit", "FirstAid",
            "Bandage", "Bandages", "HealthPack", "Medicine",
            "Healing", "Antiseptic", "Pills"
        }
    end
    
    -- Buscar en Workspace, excluyendo árboles vivos
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
            -- Excluir árboles que aún están de pie
            local isLivingTree = obj.Name:lower():find("tree") and 
                                 not obj.Name:lower():find("log") and
                                 obj.Size.Y > 10 -- Árboles suelen ser altos
            
            if not isLivingTree then
                for _, name in pairs(itemNames) do
                    if obj.Name:lower():find(name:lower()) then
                        -- Verificar que sea recolectable
                        if obj:FindFirstChild("ProximityPrompt") or 
                           obj:FindFirstChild("ClickDetector") or 
                           (obj.CanCollide and obj.Parent ~= LocalPlayer.Character) then
                            table.insert(items, obj)
                            break
                        end
                    end
                end
            end
        end
    end
    
    return items
end

-- Función mejorada de bring con TP individual
local function bringItemsOneByOne(itemType)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then 
        return 0 
    end
    
    local rootPart = character.HumanoidRootPart
    local campfire = findCampfire()
    local items = findItemsAdvanced(itemType)
    local broughtCount = 0
    
    if not campfire then
        print("No se encontró campfire, llevando items al jugador")
        campfire = rootPart
    end
    
    -- Procesar items uno por uno
    for _, item in pairs(items) do
        if item and item.Parent then
            spawn(function()
                pcall(function()
                    -- TP al item
                    local originalPos = rootPart.CFrame
                    rootPart.CFrame = item.CFrame + Vector3.new(0, 3, 0)
                    wait(0.1)
                    
                    -- Interactuar con ProximityPrompt si existe
                    local prompt = item:FindFirstChild("ProximityPrompt")
                    if prompt then
                        prompt:InputHoldEnd()
                        wait(0.1)
                    end
                    
                    -- Mover item al campfire
                    if item.Parent then
                        item.Anchored = false
                        item.CanCollide = false
                        item.CFrame = campfire.CFrame + Vector3.new(
                            math.random(-3, 3), 2, math.random(-3, 3)
                        )
                        
                        -- Métodos adicionales de transporte
                        if item:FindFirstChild("BodyPosition") then
                            item.BodyPosition.Position = campfire.Position
                        end
                        
                        if item:FindFirstChild("BodyVelocity") then
                            item.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                        end
                    end
                    
                    -- Regresar al campfire
                    wait(0.2)
                    rootPart.CFrame = campfire.CFrame + Vector3.new(0, 3, 0)
                    
                    broughtCount = broughtCount + 1
                    print("Item " .. itemType .. " #" .. broughtCount .. " llevado al campfire")
                end)
            end)
            wait(0.3) -- Pausa entre items para evitar lag
        end
    end
    
    return broughtCount
end

-- Kill Aura mejorado con herramientas
local function performKillAura()
    if not ModState.killAura then return end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart
    local tool = character:FindFirstChildOfClass("Tool")
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = player.Character:FindFirstChild("Humanoid")
            
            if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                local distance = (rootPart.Position - targetRoot.Position).Magnitude
                
                if distance <= ModState.killAuraRange then
                    pcall(function()
                        -- Usar herramienta equipada (hacha, lanza, etc.)
                        if tool and tool:FindFirstChild("Handle") then
                            -- Buscar RemoteEvent de la herramienta
                            for _, obj in pairs(tool:GetDescendants()) do
                                if obj:IsA("RemoteEvent") then
                                    if obj.Name:lower():find("swing") or 
                                       obj.Name:lower():find("hit") or
                                       obj.Name:lower():find("attack") or
                                       obj.Name:lower():find("damage") then
                                        obj:FireServer(targetRoot.Position, targetRoot)
                                        obj:FireServer(targetHumanoid, 100)
                                        obj:FireServer(player.Character)
                                    end
                                end
                            end
                            
                            -- Activar herramienta
                            if tool:FindFirstChild("Activated") then
                                tool:Activate()
                            end
                        end
                        
                        -- Métodos de daño directo
                        targetHumanoid.Health = math.max(0, targetHumanoid.Health - 25)
                        targetHumanoid:TakeDamage(50)
                        
                        -- Buscar RemoteEvents del juego
                        for _, obj in pairs(game.ReplicatedStorage:GetDescendants()) do
                            if obj:IsA("RemoteEvent") then
                                local name = obj.Name:lower()
                                if name:find("damage") or name:find("hit") or 
                                   name:find("attack") or name:find("kill") or
                                   name:find("swing") or name:find("combat") then
                                    obj:FireServer(player.Character, 100)
                                    obj:FireServer(targetHumanoid, 100)
                                    obj:FireServer(targetRoot.Position)
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
end

-- Auto loops para bring continuo
local function autoWoodLoop()
    spawn(function()
        while ModState.autoWood do
            bringItemsOneByOne("Wood")
            wait(5) -- Pausa entre ciclos
        end
    end)
end

local function autoScrapLoop()
    spawn(function()
        while ModState.autoScrap do
            bringItemsOneByOne("Scrap")
            wait(5)
        end
    end)
end

local function autoMedicalLoop()
    spawn(function()
        while ModState.autoMedical do
            bringItemsOneByOne("Medical")
            wait(5)
        end
    end)
end

-- Función Noclip
local function toggleNoclip()
    ModState.noclip = not ModState.noclip
    
    if ModState.noclip then
        Connections.noclipConnection = RunService.Stepped:Connect(function()
            local character = LocalPlayer.Character
            if character then
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = false
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
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Función Infinite Jump
local function toggleInfiniteJump()
    ModState.infiniteJump = not ModState.infiniteJump
    
    if ModState.infiniteJump then
        Connections.infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if Connections.infiniteJumpConnection then
            Connections.infiniteJumpConnection:Disconnect()
            Connections.infiniteJumpConnection = nil
        end
    end
end

-- Crear icono H2K
local function createIcon()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "H2K_99Nights"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = PlayerGui
    
    local iconFrame = Instance.new("Frame")
    iconFrame.Name = "IconFrame"
    iconFrame.Size = UDim2.new(0, 70, 0, 70)
    iconFrame.Position = UDim2.new(0, 20, 0, 80)
    iconFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = screenGui
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 35)
    iconCorner.Parent = iconFrame
    
    local iconStroke = Instance.new("UIStroke")
    iconStroke.Color = Color3.fromRGB(0, 255, 127)
    iconStroke.Thickness = 3
    iconStroke.Parent = iconFrame
    
    local iconGradient = Instance.new("UIGradient")
    iconGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 15, 25))
    }
    iconGradient.Rotation = 45
    iconGradient.Parent = iconFrame
    
    local iconText = Instance.new("TextLabel")
    iconText.Size = UDim2.new(1, 0, 1, 0)
    iconText.BackgroundTransparency = 1
    iconText.Text = "H2K"
    iconText.TextColor3 = Color3.fromRGB(0, 255, 127)
    iconText.TextScaled = true
    iconText.Font = Enum.Font.GothamBold
    iconText.TextStrokeTransparency = 0
    iconText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    iconText.Parent = iconFrame
    
    local iconButton = Instance.new("TextButton")
    iconButton.Size = UDim2.new(1, 0, 1, 0)
    iconButton.BackgroundTransparency = 1
    iconButton.Text = ""
    iconButton.Active = true
    iconButton.Draggable = true
    iconButton.Parent = iconFrame
    
    -- Efecto de respiración
    spawn(function()
        while iconFrame.Parent do
            TweenService:Create(iconStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), 
                {Thickness = 5}):Play()
            wait(1.5)
        end
    end)
    
    return screenGui, iconButton
end

-- Crear menú principal
local function createMainMenu(parentGui)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainMenu"
    mainFrame.Size = UDim2.new(0, 380, 0, 520)
    mainFrame.Position = UDim2.new(0.5, -190, 0.5, -260)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Active = true
    mainFrame.Parent = parentGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 20)
    mainCorner.Parent = mainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(0, 255, 127)
    mainStroke.Thickness = 2
    mainStroke.Parent = mainFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundColor3 = Color3.fromRGB(0, 20, 10)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 20)
    headerCorner.Parent = header
    
    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 75))
    }
    headerGradient.Rotation = 90
    headerGradient.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -120, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "99 NIGHTS FOREST"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextStrokeTransparency = 0.5
    title.Parent = header
    
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 80, 0, 40)
    logo.Position = UDim2.new(1, -90, 0, 10)
    logo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    logo.Text = "H2K"
    logo.TextColor3 = Color3.fromRGB(0, 0, 0)
    logo.TextScaled = true
    logo.Font = Enum.Font.GothamBold
    logo.Parent = header
    
    local logoCorner = Instance.new("UICorner")
    logoCorner.CornerRadius = UDim.new(0, 8)
    logoCorner.Parent = logo
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 15)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 15)
    closeBtnCorner.Parent = closeBtn
    
    -- Contenido
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -20, 1, -80)
    content.Position = UDim2.new(0, 10, 0, 70)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 8
    content.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 127)
    content.CanvasSize = UDim2.new(0, 0, 0, 700)
    content.Parent = mainFrame
    
    -- Función para crear secciones
    local function createSection(name, yPos, height)
        local section = Instance.new("Frame")
        section.Name = name .. "Section"
        section.Size = UDim2.new(1, 0, 0, height or 80)
        section.Position = UDim2.new(0, 0, 0, yPos)
        section.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
        section.BorderSizePixel = 0
        section.Parent = content
        
        local sectionCorner = Instance.new("UICorner")
        sectionCorner.CornerRadius = UDim.new(0, 12)
        sectionCorner.Parent = section
        
        local sectionStroke = Instance.new("UIStroke")
        sectionStroke.Color = Color3.fromRGB(40, 40, 60)
        sectionStroke.Thickness = 1
        sectionStroke.Parent = section
        
        return section
    end
    
    -- Sección Auto Bring
    local bringSection = createSection("AutoBring", 10, 120)
    
    local bringTitle = Instance.new("TextLabel")
    bringTitle.Size = UDim2.new(1, 0, 0, 25)
    bringTitle.Position = UDim2.new(0, 10, 0, 5)
    bringTitle.BackgroundTransparency = 1
    bringTitle.Text = "AUTO BRING TO CAMPFIRE"
    bringTitle.TextColor3 = Color3.fromRGB(0, 255, 127)
    bringTitle.TextSize = 14
    bringTitle.Font = Enum.Font.GothamBold
    bringTitle.TextXAlignment = Enum.TextXAlignment.Left
    bringTitle.Parent = bringSection
    
    -- Función para crear auto toggles
    local function createAutoToggle(name, text, pos, parent)
        local toggle = Instance.new("TextButton")
        toggle.Name = name
        toggle.Size = UDim2.new(0, 110, 0, 35)
        toggle.Position = pos
        toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        toggle.Text = text .. ": OFF"
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.TextSize = 11
        toggle.Font = Enum.Font.Gotham
        toggle.Parent = parent
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 8)
        toggleCorner.Parent = toggle
        
        return toggle
    end
    
    local autoWoodToggle = createAutoToggle("AutoWoodToggle", "AUTO WOOD", UDim2.new(0, 10, 0, 35), bringSection)
    local autoScrapToggle = createAutoToggle("AutoScrapToggle", "AUTO SCRAP", UDim2.new(0, 130, 0, 35), bringSection)
    local autoMedicalToggle = createAutoToggle("AutoMedicalToggle", "AUTO MEDICAL", UDim2.new(0, 250, 0, 35), bringSection)
    
    -- Botones de bring manual
    local manualWoodBtn = Instance.new("TextButton")
    manualWoodBtn.Size = UDim2.new(0, 110, 0, 30)
    manualWoodBtn.Position = UDim2.new(0, 10, 0, 80)
    manualWoodBtn.BackgroundColor3 = Color3.fromRGB(139, 69, 19)
    manualWoodBtn.Text = "BRING LOGS"
    manualWoodBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    manualWoodBtn.TextSize = 11
    manualWoodBtn.Font = Enum.Font.Gotham
    manualWoodBtn.Parent = bringSection
    
    local manualWoodCorner = Instance.new("UICorner")
    manualWoodCorner.CornerRadius = UDim.new(0, 6)
    manualWoodCorner.Parent = manualWoodBtn
    
    local manualScrapBtn = Instance.new("TextButton")
    manualScrapBtn.Size = UDim2.new(0, 110, 0, 30)
    manualScrapBtn.Position = UDim2.new(0, 130, 0, 80)
    manualScrapBtn.BackgroundColor3 = Color3.fromRGB(128, 128, 128)
    manualScrapBtn.Text = "BRING SCRAP"
    manualScrapBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    manualScrapBtn.TextSize = 11
    manualScrapBtn.Font = Enum.Font.Gotham
    manualScrapBtn.Parent = bringSection
    
    local manualScrapCorner = Instance.new("UICorner")
    manualScrapCorner.CornerRadius = UDim.new(0, 6)
    manualScrapCorner.Parent = manualScrapBtn
    
    local manualMedicalBtn = Instance.new("TextButton")
    manualMedicalBtn.Size = UDim2.new(0, 110, 0, 30)
    manualMedicalBtn.Position = UDim2.new(0, 250, 0, 80)
    manualMedicalBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
    manualMedicalBtn.Text = "BRING MEDS"
    manualMedicalBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    manualMedicalBtn.TextSize = 11
    manualMedicalBtn.Font = Enum.Font.Gotham
    manualMedicalBtn.Parent = bringSection
    
    local manualMedicalCorner = Instance.new("UICorner")
    manualMedicalCorner.CornerRadius = UDim.new(0, 6)
    manualMedicalCorner.Parent = manualMedicalBtn
    
    -- Sección Movement
    local movementSection = createSection("Movement", 140, 90)
    
    local movementTitle = Instance.new("TextLabel")
    movementTitle.Size = UDim2.new(1, 0, 0, 25)
    movementTitle.Position = UDim2.new(0, 10, 0, 5)
    movementTitle.BackgroundTransparency = 1
    movementTitle.Text = "MOVEMENT"
    movementTitle.TextColor3 = Color3.fromRGB(0, 255, 127)
    movementTitle.TextSize = 16
    movementTitle.Font = Enum.Font.GothamBold
    movementTitle.TextXAlignment = Enum.TextXAlignment.Left
    movementTitle.Parent = movementSection
    
    local function createToggle(name, text, pos, parent)
        local toggle = Instance.new("TextButton")
        toggle.Name = name
        toggle.Size = UDim2.new(0, 150, 0, 35)
        toggle.Position = pos
        toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        toggle.Text = text .. ": OFF"
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.TextScaled = true
        toggle.Font = Enum.Font.Gotham
        toggle.Parent = parent
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 8)
        toggleCorner.Parent = toggle
        
        return toggle
    end
    
    local noclipToggle = createToggle("NoclipToggle", "NOCLIP", UDim2.new(0, 10, 0, 35), movementSection)
    local infiniteJumpToggle = createToggle("InfiniteJumpToggle", "INF JUMP", UDim2.new(0, 180, 0, 35), movementSection)
    
    -- Sección Kill Aura
    local killAuraSection = createSection("KillAura", 240, 130)
    
    local killAuraTitle = Instance.new("TextLabel")
    killAuraTitle.Size = UDim2.new(1, 0, 0, 25)
    killAuraTitle.Position = UDim2.new(0, 10, 0, 5)
    killAuraTitle.BackgroundTransparency = 1
    killAuraTitle.Text = "COMBAT AURA (Uses Equipped Tool)"
    killAuraTitle.TextColor3 = Color3.fromRGB(0, 255, 127)
    killAuraTitle.TextSize = 14
    killAuraTitle.Font = Enum.Font.GothamBold
    killAuraTitle.TextXAlignment = Enum.TextXAlignment.Left
    killAuraTitle.Parent = killAuraSection
    
    local killAuraToggle = createToggle("KillAuraToggle", "KILL AURA", UDim2.new(0, 10, 0, 35), killAuraSection)
    
    -- Controles de rango mejorados
    local rangeLabel = Instance.new("TextLabel")
    rangeLabel.Size = UDim2.new(0, 100, 0, 30)
    rangeLabel.Position = UDim2.new(0, 10, 0, 80)
    rangeLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    rangeLabel.Text = "Range: " .. ModState.killAuraRange
    rangeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    rangeLabel.TextScaled = true
    rangeLabel.Font = Enum.Font.Gotham
    rangeLabel.Parent = killAuraSection
    
    local rangeLabelCorner = Instance.new("UICorner")
    rangeLabelCorner.CornerRadius = UDim.new(0, 6)
    rangeLabelCorner.Parent = rangeLabel
    
    local rangeMinus = Instance.new("TextButton")
    rangeMinus.Size = UDim2.new(0, 40rangeMinus.Size = UDim2.new(0, 40, 0, 30)
    rangeMinus.Position = UDim2.new(0, 120, 0, 80)
    rangeMinus.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    rangeMinus.Text = "-"
    rangeMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
    rangeMinus.TextScaled = true
    rangeMinus.Font = Enum.Font.GothamBold
    rangeMinus.Parent = killAuraSection
    
    local rangeMinusCorner = Instance.new("UICorner")
    rangeMinusCorner.CornerRadius = UDim.new(0, 6)
    rangeMinusCorner.Parent = rangeMinus
    
    local rangePlus = Instance.new("TextButton")
    rangePlus.Size = UDim2.new(0, 40, 0, 30)
    rangePlus.Position = UDim2.new(0, 170, 0, 80)
    rangePlus.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    rangePlus.Text = "+"
    rangePlus.TextColor3 = Color3.fromRGB(255, 255, 255)
    rangePlus.TextScaled = true
    rangePlus.Font = Enum.Font.GothamBold
    rangePlus.Parent = killAuraSection
    
    local rangePlusCorner = Instance.new("UICorner")
    rangePlusCorner.CornerRadius = UDim.new(0, 6)
    rangePlusCorner.Parent = rangePlus
    
    local playersInRange = Instance.new("TextLabel")
    playersInRange.Size = UDim2.new(0, 140, 0, 25)
    playersInRange.Position = UDim2.new(0, 220, 0, 85)
    playersInRange.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    playersInRange.Text = "Targets: 0"
    playersInRange.TextColor3 = Color3.fromRGB(255, 215, 0)
    playersInRange.TextSize = 12
    playersInRange.Font = Enum.Font.Gotham
    playersInRange.Parent = killAuraSection
    
    local playersCorner = Instance.new("UICorner")
    playersCorner.CornerRadius = UDim.new(0, 6)
    playersCorner.Parent = playersInRange
    
    -- Event Connections
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        ModState.isOpen = false
    end)
    
    autoWoodToggle.MouseButton1Click:Connect(function()
        ModState.autoWood = not ModState.autoWood
        autoWoodToggle.Text = "AUTO WOOD: " .. (ModState.autoWood and "ON" or "OFF")
        autoWoodToggle.BackgroundColor3 = ModState.autoWood and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(60, 60, 80)
        if ModState.autoWood then autoWoodLoop() end
    end)
    
    autoScrapToggle.MouseButton1Click:Connect(function()
        ModState.autoScrap = not ModState.autoScrap
        autoScrapToggle.Text = "AUTO SCRAP: " .. (ModState.autoScrap and "ON" or "OFF")
        autoScrapToggle.BackgroundColor3 = ModState.autoScrap and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(60, 60, 80)
        if ModState.autoScrap then autoScrapLoop() end
    end)
    
    autoMedicalToggle.MouseButton1Click:Connect(function()
        ModState.autoMedical = not ModState.autoMedical
        autoMedicalToggle.Text = "AUTO MEDICAL: " .. (ModState.autoMedical and "ON" or "OFF")
        autoMedicalToggle.BackgroundColor3 = ModState.autoMedical and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(60, 60, 80)
        if ModState.autoMedical then autoMedicalLoop() end
    end)
    
    manualWoodBtn.MouseButton1Click:Connect(function()
        spawn(function() bringItemsOneByOne("Wood") end)
    end)
    
    manualScrapBtn.MouseButton1Click:Connect(function()
        spawn(function() bringItemsOneByOne("Scrap") end)
    end)
    
    manualMedicalBtn.MouseButton1Click:Connect(function()
        spawn(function() bringItemsOneByOne("Medical") end)
    end)
    
    noclipToggle.MouseButton1Click:Connect(function()
        toggleNoclip()
        noclipToggle.Text = "NOCLIP: " .. (ModState.noclip and "ON" or "OFF")
        noclipToggle.BackgroundColor3 = ModState.noclip and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(60, 60, 80)
    end)
    
    infiniteJumpToggle.MouseButton1Click:Connect(function()
        toggleInfiniteJump()
        infiniteJumpToggle.Text = "INF JUMP: " .. (ModState.infiniteJump and "ON" or "OFF")
        infiniteJumpToggle.BackgroundColor3 = ModState.infiniteJump and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(60, 60, 80)
    end)
    
    killAuraToggle.MouseButton1Click:Connect(function()
        ModState.killAura = not ModState.killAura
        killAuraToggle.Text = "KILL AURA: " .. (ModState.killAura and "ON" or "OFF")
        killAuraToggle.BackgroundColor3 = ModState.killAura and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(60, 60, 80)
    end)
    
    rangeMinus.MouseButton1Click:Connect(function()
        ModState.killAuraRange = math.max(5, ModState.killAuraRange - 5)
        rangeLabel.Text = "Range: " .. ModState.killAuraRange
    end)
    
    rangePlus.MouseButton1Click:Connect(function()
        ModState.killAuraRange = math.min(50, ModState.killAuraRange + 5)
        rangeLabel.Text = "Range: " .. ModState.killAuraRange
    end)
    
    spawn(function()
        while mainFrame.Parent do
            if ModState.killAura then
                local count = 0
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if distance <= ModState.killAuraRange then
                            count = count + 1
                        end
                    end
                end
                playersInRange.Text = "Targets: " .. count
            end
            wait(0.5)
        end
    end)
    
    return mainFrame
end

spawn(function()
    while wait(0.1) do
        if ModState.killAura then
            performKillAura()
        end
    end
end)

local screenGui, iconButton = createIcon()
gui = screenGui
local mainMenu = createMainMenu(screenGui)

iconButton.MouseButton1Click:Connect(function()
    ModState.isOpen = not ModState.isOpen
    mainMenu.Visible = ModState.isOpen
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
        ModState.isOpen = not ModState.isOpen
        mainMenu.Visible = ModState.isOpen
    end
end)