-- H2K 99 NIGHTS FOREST SCRIPT - CORREGIDO SOLO MOBS HOSTILES
-- Sin errores visuales, 100% funcional para Android KRNL
-- BY H2K

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Limpiar GUIs anteriores
for _, gui in pairs(PlayerGui:GetChildren()) do
    if gui.Name:find("H2K") then
        gui:Destroy()
    end
end

-- Estado del script
local State = {
    speed = false,
    jump = false,
    killAura = false,
    isMinimized = false,
    auraRange = 75,
    speedValue = 65
}

local connections = {}
local lastTapTime = 0

-- Función mejorada para encontrar campfire/base
local function findCampfire()
    local campfireNames = {"campfire", "fire", "base", "camp"}
    
    -- Buscar campfire en Workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            for _, campName in pairs(campfireNames) do
                if name:find(campName) then
                    return obj
                end
            end
        end
    end
    
    -- Si no encuentra campfire, buscar SpawnLocation
    local spawnLocation = Workspace:FindFirstChild("SpawnLocation")
    if spawnLocation then
        return spawnLocation
    end
    
    -- Como último recurso, usar posición inicial del jugador
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local part = Instance.new("Part")
        part.Name = "TempCamp"
        part.Size = Vector3.new(1, 1, 1)
        part.Position = Vector3.new(0, 50, 0) -- Posición central elevada
        part.Anchored = true
        part.Transparency = 1
        part.CanCollide = false
        part.Parent = Workspace
        return part
    end
    
    return nil
end

-- Función CORREGIDA para detectar SOLO animales hostiles y NPCs enemigos
local function isHostileEntity(obj)
    if not obj or not obj.Parent then return false end
    
    -- NUNCA atacar a jugadores reales
    if Players:GetPlayerFromCharacter(obj) then
        return false
    end
    
    local name = obj.Name:lower()
    local parentName = obj.Parent.Name:lower()
    
    -- Lista específica de mobs hostiles de 99 Nights
    local hostileEntities = {
        -- Animales hostiles principales
        "wolf", "alphawolf", "alpha_wolf", "alpha wolf",
        "bear", "alphabear", "alpha_bear", "alpha bear",
        "rabbit", "bunny", "deer", "boar", "pig",
        
        -- Enemigos específicos del juego
        "cultist", "cultists", "enemy", "hostile",
        "bandit", "raider", "monster", "creature",
        
        -- Variaciones de nombres
        "mob", "npc_hostile", "hostile_npc"
    }
    
    -- Verificar si es un mob hostil
    for _, entity in pairs(hostileEntities) do
        if name:find(entity) or parentName:find(entity) then
            return true
        end
    end
    
    -- Verificar si es un NPC con Humanoid PERO NO un jugador
    if obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
        -- Excluir NPCs amistosos específicos
        local friendlyNPCs = {"trader", "shop", "merchant", "bird", "watcher", "vendor"}
        
        local isFriendly = false
        for _, friendly in pairs(friendlyNPCs) do
            if name:find(friendly) or parentName:find(friendly) then
                isFriendly = true
                break
            end
        end
        
        -- Solo atacar si NO es amistoso Y no es un jugador
        if not isFriendly then
            return true
        end
    end
    
    return false
end

-- Funciones principales
local function toggleSpeed()
    State.speed = not State.speed
    
    if State.speed then
        connections.speed = RunService.Heartbeat:Connect(function()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.WalkSpeed = State.speedValue
            end
        end)
    else
        if connections.speed then
            connections.speed:Disconnect()
            connections.speed = nil
        end
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = 16
        end
    end
end

local function toggleJump()
    State.jump = not State.jump
    
    if State.jump then
        connections.jump = UserInputService.JumpRequest:Connect(function()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if connections.jump then
            connections.jump:Disconnect()
            connections.jump = nil
        end
    end
end

-- Kill Aura CORREGIDO - Solo mobs hostiles
local function performKillAura()
    if not State.killAura then return end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = character.HumanoidRootPart
    local tool = character:FindFirstChildOfClass("Tool")
    
    -- Buscar SOLO en mobs hostiles, NO en jugadores
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and isHostileEntity(obj) then
            local targetRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChildOfClass("Part")
            local targetHuman = obj:FindFirstChildOfClass("Humanoid")
            
            if targetRoot and targetHuman and targetHuman.Health > 0 then
                local distance = (rootPart.Position - targetRoot.Position).Magnitude
                
                if distance <= State.auraRange then
                    pcall(function()
                        -- VERIFICAR UNA VEZ MÁS que NO sea un jugador
                        if not Players:GetPlayerFromCharacter(obj) then
                            -- Usar herramienta equipada
                            if tool then
                                tool:Activate()
                                
                                for _, remote in pairs(tool:GetDescendants()) do
                                    if remote:IsA("RemoteEvent") then
                                        remote:FireServer(targetRoot)
                                        remote:FireServer(obj)
                                        remote:FireServer(targetHuman, 999)
                                    end
                                end
                            end
                            
                            -- Daño directo a mobs
                            targetHuman:TakeDamage(999)
                            targetHuman.Health = 0
                            
                            -- RemoteEvents del juego para mobs
                            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                                if remote:IsA("RemoteEvent") then
                                    local remoteName = remote.Name:lower()
                                    if remoteName:find("damage") or remoteName:find("hit") or 
                                       remoteName:find("attack") or remoteName:find("combat") or
                                       remoteName:find("mob") or remoteName:find("enemy") then
                                        remote:FireServer(obj, 999)
                                        remote:FireServer(targetRoot, targetHuman, 999)
                                    end
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
end

-- TP to Camp CORREGIDO
local function teleportToCamp()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then 
        print("Error: Character o HumanoidRootPart no encontrado")
        return 
    end
    
    local campfire = findCampfire()
    if campfire then
        -- TP seguro con verificaciones
        pcall(function()
            character.HumanoidRootPart.CFrame = campfire.CFrame + Vector3.new(0, 5, 0)
            print("Teletransportado al campfire exitosamente")
        end)
    else
        -- TP a spawn como backup
        pcall(function()
            character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
            print("Campfire no encontrado, teletransportado al spawn")
        end)
    end
end

local function instaOpenChests()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local parent = obj.Parent
            if parent and (parent.Name:lower():find("chest") or parent.Name:lower():find("box") or parent.Name:lower():find("loot")) then
                obj.HoldDuration = 0
                obj.MaxActivationDistance = 100
                fireproximityprompt(obj, 0)
            end
        end
    end
end

-- Crear GUI sin errores visuales (IGUAL QUE ANTES)
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "H2K_99Nights"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui
    
    -- Frame principal visible
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 320, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(0, 200, 255)
    mainStroke.Thickness = 2
    mainStroke.Parent = mainFrame
    
    -- Header con logo H2K
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    -- Logo H2K visible
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 60, 0, 30)
    logo.Position = UDim2.new(0, 10, 0, 10)
    logo.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    logo.Text = "H2K"
    logo.TextColor3 = Color3.fromRGB(0, 200, 255)
    logo.TextSize = 18
    logo.Font = Enum.Font.GothamBold
    logo.Parent = header
    
    local logoCorner = Instance.new("UICorner")
    logoCorner.CornerRadius = UDim.new(0, 8)
    logoCorner.Parent = logo
    
    -- Título visible
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -140, 1, 0)
    title.Position = UDim2.new(0, 80, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "99 NIGHTS FOREST"
    title.TextColor3 = Color3.fromRGB(0, 0, 0)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = header
    
    -- Botón minimizar visible
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -40, 0, 10)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    minimizeBtn.Text = "-"
    minimizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    minimizeBtn.TextSize = 20
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = header
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 15)
    minimizeCorner.Parent = minimizeBtn
    
    -- Contenido principal
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 1, -70)
    content.Position = UDim2.new(0, 10, 0, 60)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    -- Función para crear botones visibles
    local function createButton(text, pos, size, color, parent)
        local btn = Instance.new("TextButton")
        btn.Size = size
        btn.Position = pos
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 12
        btn.Font = Enum.Font.Gotham
        btn.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn
        
        return btn
    end
    
    -- Botones principales visibles
    local speedBtn = createButton("SPEED x65: OFF", UDim2.new(0, 10, 0, 10), UDim2.new(0, 135, 0, 35), Color3.fromRGB(50, 150, 50), content)
    local jumpBtn = createButton("INF JUMP: OFF", UDim2.new(0, 155, 0, 10), UDim2.new(0, 135, 0, 35), Color3.fromRGB(100, 50, 150), content)
    
    local killAuraBtn = createButton("KILL AURA: OFF", UDim2.new(0, 10, 0, 55), UDim2.new(0, 200, 0, 35), Color3.fromRGB(200, 50, 50), content)
    
    -- Info de rango visible
    local rangeInfo = Instance.new("TextLabel")
    rangeInfo.Size = UDim2.new(0, 80, 0, 25)
    rangeInfo.Position = UDim2.new(0, 220, 0, 60)
    rangeInfo.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    rangeInfo.Text = "Range: 75"
    rangeInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
    rangeInfo.TextSize = 10
    rangeInfo.Font = Enum.Font.Gotham
    rangeInfo.Parent = content
    
    local rangeCorner = Instance.new("UICorner")
    rangeCorner.CornerRadius = UDim.new(0, 6)
    rangeCorner.Parent = rangeInfo
    
    -- Botones de utilidad
    local tpBtn = createButton("TP TO CAMP", UDim2.new(0, 10, 0, 100), UDim2.new(0, 135, 0, 35), Color3.fromRGB(255, 140, 0), content)
    local chestBtn = createButton("INSTA CHESTS", UDim2.new(0, 155, 0, 100), UDim2.new(0, 135, 0, 35), Color3.fromRGB(150, 100, 255), content)
    
    -- Contador de targets visible - ACTUALIZADO
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(1, -20, 0, 30)
    targetLabel.Position = UDim2.new(0, 10, 0, 150)
    targetLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    targetLabel.Text = "Targets: 0 | SOLO MOBS HOSTILES (NO PLAYERS)"
    targetLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    targetLabel.TextSize = 10
    targetLabel.Font = Enum.Font.Gotham
    targetLabel.Parent = content
    
    local targetCorner = Instance.new("UICorner")
    targetCorner.CornerRadius = UDim.new(0, 8)
    targetCorner.Parent = targetLabel
    
    -- Créditos BY H2K visible
    local credits = Instance.new("TextLabel")
    credits.Size = UDim2.new(1, -20, 0, 50)
    credits.Position = UDim2.new(0, 10, 0, 200)
    credits.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    credits.Text = "BY H2K - CORREGIDO\nSOLO ATACA MOBS HOSTILES\nNO MATA JUGADORES"
    credits.TextColor3 = Color3.fromRGB(0, 200, 255)
    credits.TextSize = 10
    credits.Font = Enum.Font.GothamBold
    credits.Parent = content
    
    local creditsCorner = Instance.new("UICorner")
    creditsCorner.CornerRadius = UDim.new(0, 10)
    creditsCorner.Parent = credits
    
    -- Ícono minimizado H2K
    local miniIcon = Instance.new("Frame")
    miniIcon.Name = "MiniIcon"
    miniIcon.Size = UDim2.new(0, 60, 0, 60)
    miniIcon.Position = UDim2.new(0, 30, 0, 150)
    miniIcon.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    miniIcon.BorderSizePixel = 0
    miniIcon.Active = true
    miniIcon.Draggable = true
    miniIcon.Visible = false
    miniIcon.Parent = screenGui
    
    local miniCorner = Instance.new("UICorner")
    miniCorner.CornerRadius = UDim.new(0, 30)
    miniCorner.Parent = miniIcon
    
    local miniStroke = Instance.new("UIStroke")
    miniStroke.Color = Color3.fromRGB(255, 255, 255)
    miniStroke.Thickness = 2
    miniStroke.Parent = miniIcon
    
    local miniText = Instance.new("TextLabel")
    miniText.Size = UDim2.new(1, 0, 1, 0)
    miniText.BackgroundTransparency = 1
    miniText.Text = "H2K"
    miniText.TextColor3 = Color3.fromRGB(0, 0, 0)
    miniText.TextSize = 16
    miniText.Font = Enum.Font.GothamBold
    miniText.Parent = miniIcon
    
    local miniButton = Instance.new("TextButton")
    miniButton.Size = UDim2.new(1, 0, 1, 0)
    miniButton.BackgroundTransparency = 1
    miniButton.Text = ""
    miniButton.Parent = miniIcon
    
    -- EVENTOS FUNCIONALES
    minimizeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        miniIcon.Visible = true
        State.isMinimized = true
    end)
    
    miniButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        miniIcon.Visible = false
        State.isMinimized = false
    end)
    
    speedBtn.MouseButton1Click:Connect(function()
        toggleSpeed()
        speedBtn.Text = "SPEED x65: " .. (State.speed and "ON" or "OFF")
        speedBtn.BackgroundColor3 = State.speed and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(50, 150, 50)
    end)
    
    jumpBtn.MouseButton1Click:Connect(function()
        toggleJump()
        jumpBtn.Text = "INF JUMP: " .. (State.jump and "ON" or "OFF")
        jumpBtn.BackgroundColor3 = State.jump and Color3.fromRGB(150, 0, 255) or Color3.fromRGB(100, 50, 150)
    end)
    
    killAuraBtn.MouseButton1Click:Connect(function()
        State.killAura = not State.killAura
        killAuraBtn.Text = "KILL AURA: " .. (State.killAura and "ON" or "OFF")
        killAuraBtn.BackgroundColor3 = State.killAura and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(200, 50, 50)
    end)
    
    tpBtn.MouseButton1Click:Connect(function()
        teleportToCamp()
    end)
    
    chestBtn.MouseButton1Click:Connect(function()
        instaOpenChests()
    end)
    
    -- Loop contador de targets CORREGIDO
    spawn(function()
        while screenGui.Parent do
            if State.killAura and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local count = 0
                local rootPart = LocalPlayer.Character.HumanoidRootPart
                
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and isHostileEntity(obj) then
                        local targetRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChildOfClass("Part")
                        if targetRoot then
                            local distance = (rootPart.Position - targetRoot.Position).Magnitude
                            if distance <= State.auraRange then
                                count = count + 1
                            end
                        end
                    end
                end
                
                targetLabel.Text = "Targets: " .. count .. " | SOLO MOBS HOSTILES (NO PLAYERS)"
            else
                targetLabel.Text = "Targets: 0 | SOLO MOBS HOSTILES (NO PLAYERS)"
            end
            wait(1)
        end
    end)
    
    return screenGui
end

-- Kill Aura loop CORREGIDO
spawn(function()
    while wait(0.1) do
        performKillAura()
    end
end)

-- Inicializar GUI
local gui = createGUI()

-- Controles táctiles Android
UserInputService.TouchTapInWorld:Connect(function(position, processedByUI)
    if not processedByUI then
        local currentTime = tick()
        if currentTime - lastTapTime < 0.5 then
            if gui and gui.Parent then
                if State.isMinimized then
                    gui.MainFrame.Visible = true
                    gui.MiniIcon.Visible = false
                    State.isMinimized = false
                else
                    gui.MainFrame.Visible = false
                    gui.MiniIcon.Visible = true
                    State.isMinimized = true
                end
            end
        end
        lastTapTime = currentTime
    end
end)

-- Hotkeys
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.RightControl then
        if gui and gui.Parent then
            if State.isMinimized then
                gui.MainFrame.Visible = true
                gui.MiniIcon.Visible = false
                State.isMinimized = false
            else
                gui.MainFrame.Visible = false
                gui.MiniIcon.Visible = true
                State.isMinimized = true
            end
        end
    end
end)

print("H2K 99 Nights Forest Script CORREGIDO cargado!")
print("Kill Aura SOLO ataca mobs hostiles - NO JUGADORES")
print("TP to Camp mejorado con múltiples métodos de búsqueda")
print("Toca el ícono H2K para minimizar/abrir GUI")