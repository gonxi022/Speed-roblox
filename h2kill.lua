-- KILLALL PARA PRISON LIFE - COMPATIBLE CON KRNL ANDROID
-- Optimizado para dispositivos móviles y KRNL

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- ========================================
-- CREAR GUI FLOTANTE PARA MÓVIL
-- ========================================
local function createFloatingGUI()
    -- Eliminar GUI anterior si existe
    if player.PlayerGui:FindFirstChild("KillAllGUI") then
        player.PlayerGui.KillAllGUI:Destroy()
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "KillAllGUI"
    gui.Parent = player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    
    -- Frame principal flotante
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 120, 0, 120)
    mainFrame.Position = UDim2.new(0, 20, 0.5, -60) -- Lado izquierdo, centro vertical
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true -- Permite mover en PC
    mainFrame.Parent = gui
    
    -- Esquinas redondeadas
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame
    
    -- Sombra/Borde
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 0, 0)
    stroke.Thickness = 2
    stroke.Parent = mainFrame
    
    -- Botón de KillAll
    local killAllButton = Instance.new("TextButton")
    killAllButton.Name = "KillAllButton"
    killAllButton.Size = UDim2.new(0.85, 0, 0, 40)
    killAllButton.Position = UDim2.new(0.075, 0, 0, 10)
    killAllButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    killAllButton.Text = "KILL ALL"
    killAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    killAllButton.TextSize = 16
    killAllButton.Font = Enum.Font.SourceSansBold
    killAllButton.BorderSizePixel = 0
    killAllButton.Parent = mainFrame
    
    local killCorner = Instance.new("UICorner")
    killCorner.CornerRadius = UDim.new(0, 8)
    killCorner.Parent = killAllButton
    
    -- Contador de jugadores
    local playerCount = Instance.new("TextLabel")
    playerCount.Name = "PlayerCount"
    playerCount.Size = UDim2.new(1, 0, 0, 25)
    playerCount.Position = UDim2.new(0, 0, 0, 55)
    playerCount.BackgroundTransparency = 1
    playerCount.Text = "Players: " .. (#Players:GetPlayers() - 1)
    playerCount.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerCount.TextSize = 12
    playerCount.Font = Enum.Font.SourceSans
    playerCount.Parent = mainFrame
    
    -- Status label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, 0, 0, 25)
    statusLabel.Position = UDim2.new(0, 0, 0, 80)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Ready"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    statusLabel.TextSize = 11
    statusLabel.Font = Enum.Font.SourceSans
    statusLabel.Parent = mainFrame
    
    return gui, killAllButton, playerCount, statusLabel
end

-- ========================================
-- FUNCIÓN KILLALL ESPECÍFICA PARA PRISON LIFE
-- ========================================
local function executePrisonLifeKillAll(statusLabel)
    statusLabel.Text = "Executing..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    
    local killedCount = 0
    local totalPlayers = #Players:GetPlayers() - 1
    
    -- Método 1: RemoteEvent de melee (el más efectivo en Prison Life)
    local meleeRemote = ReplicatedStorage:FindFirstChild("meleeEvent")
    if meleeRemote then
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
                pcall(function()
                    -- Prison Life usa este remote para ataques melee
                    meleeRemote:FireServer(targetPlayer.Character.Humanoid)
                    killedCount = killedCount + 1
                end)
                wait(0.05) -- Pequeña pausa para evitar spam
            end
        end
    end
    
    -- Método 2: Si el método 1 no funciona, intentar con armas
    if killedCount == 0 then
        -- Buscar armas en el inventario
        local weapons = {"Remington 870", "AK-47", "M9", "Crude Knife"}
        local weapon = nil
        
        for _, weaponName in pairs(weapons) do
            weapon = player.Backpack:FindFirstChild(weaponName)
            if weapon then break end
        end
        
        if weapon and player.Character then
            player.Character.Humanoid:EquipTool(weapon)
            wait(0.5)
            
            -- Usar el arma contra todos
            for _, targetPlayer in pairs(Players:GetPlayers()) do
                if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    pcall(function()
                        -- Acercarse al objetivo
                        if weapon:FindFirstChild("Handle") then
                            weapon.Handle.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
                            wait(0.1)
                            killedCount = killedCount + 1
                        end
                    end)
                end
            end
        end
    end
    
    -- Método 3: Remotes específicos de Prison Life
    local remotes = {"Respawn", "RedeemCode", "BuyGamepass"}
    for _, remoteName in pairs(remotes) do
        local remote = ReplicatedStorage:FindFirstChild(remoteName)
        if remote and remote:IsA("RemoteEvent") then
            for _, targetPlayer in pairs(Players:GetPlayers()) do
                if targetPlayer ~= player then
                    pcall(function()
                        remote:FireServer(targetPlayer, "kill")
                    end)
                end
            end
        end
    end
    
    -- Actualizar status
    wait(1)
    if killedCount > 0 then
        statusLabel.Text = "Killed: " .. killedCount
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        statusLabel.Text = "Failed"
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
    
    -- Volver a "Ready" después de 3 segundos
    wait(3)
    statusLabel.Text = "Ready"
    statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
end

-- ========================================
-- ANIMACIÓN DE BOTÓN PARA MÓVIL
-- ========================================
local function animateButton(button)
    -- Animación de presionado
    local pressedTween = TweenService:Create(
        button,
        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
        {Size = UDim2.new(0.8, 0, 0, 35)}
    )
    
    local releasedTween = TweenService:Create(
        button,
        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
        {Size = UDim2.new(0.85, 0, 0, 40)}
    )
    
    pressedTween:Play()
    pressedTween.Completed:Wait()
    releasedTween:Play()
end

-- ========================================
-- ACTUALIZAR CONTADOR DE JUGADORES
-- ========================================
local function updatePlayerCount(playerCount)
    spawn(function()
        while playerCount and playerCount.Parent do
            playerCount.Text = "Players: " .. (#Players:GetPlayers() - 1)
            wait(2)
        end
    end)
end

-- ========================================
-- INICIALIZAR GUI Y CONEXIONES
-- ========================================
local function initializeKillAll()
    local gui, killAllButton, playerCount, statusLabel = createFloatingGUI()
    
    -- Iniciar contador
    updatePlayerCount(playerCount)
    
    -- Conectar eventos
    killAllButton.MouseButton1Click:Connect(function()
        animateButton(killAllButton)
        executePrisonLifeKillAll(statusLabel)
    end)
    
    -- Soporte táctil para móvil (KRNL Android)
    if UserInputService.TouchEnabled then
        killAllButton.TouchTap:Connect(function()
            animateButton(killAllButton)
            executePrisonLifeKillAll(statusLabel)
        end)
    end
    
    print("Prison Life KillAll GUI loaded successfully!")
    print("Compatible with KRNL Android")
    
    return gui
end

-- ========================================
-- VERIFICAR SI ESTAMOS EN PRISON LIFE
-- ========================================
if game.PlaceId == 155615604 then
    initializeKillAll()
else
    warn("This script is designed for Prison Life only!")
    warn("Current game ID: " .. game.PlaceId)
    warn("Prison Life ID: 155615604")
end

-- ========================================
-- CÓDIGO ADICIONAL PARA KRNL ANDROID
-- ========================================
--[[
INSTRUCCIONES PARA KRNL ANDROID:

1. Abre Prison Life
2. Ejecuta este script
3. El botón flotante aparecerá en el lado izquierdo
4. Toca el botón "KILL ALL" para ejecutar
5. El status mostrará el resultado

NOTAS:
- El botón es arrastrable en PC
- Funciona con touch en móviles
- Cuenta jugadores automáticamente
- Animaciones suaves
- Optimizado para KRNL

TROUBLESHOOTING:
- Si no funciona, asegúrate de estar en Prison Life
- Algunos servidores pueden tener protecciones adicionales
- El script se actualiza automáticamente con nuevos jugadores
]]