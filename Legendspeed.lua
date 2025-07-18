local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Admins autorizados
local admins = {
    ["gonchii002"] = true,
    ["AdminEjemplo"] = true,
}

if not admins[player.Name] then return end

-- Crear o conseguir los RemoteEvents
local function getOrCreateEvent(name)
    local event = ReplicatedStorage:FindFirstChild(name)
    if not event then
        event = Instance.new("RemoteEvent")
        event.Name = name
        event.Parent = ReplicatedStorage
    end
    return event
end

local killAllEvent = getOrCreateEvent("KillAllEvent")
local kickAllEvent = getOrCreateEvent("KickAllEvent")
local giveSpeedEvent = getOrCreateEvent("GiveSpeedEvent")

-- Crear la GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local function createButton(name, text, color, posY)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 250, 0, 70)
    button.Position = UDim2.new(0, 20, 0, posY)
    button.BackgroundColor3 = color
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 32
    button.AutoButtonColor = true
    button.Parent = screenGui
    button.ClipsDescendants = true
    return button
end

-- Botón 1: Matar a todos
local killAllButton = createButton("KillAllButton", "KILL ALL INSTANT", Color3.fromRGB(220,0,0), 40)
killAllButton.MouseButton1Click:Connect(function()
    killAllEvent:FireServer()
end)

-- Botón 2: Kick a todos
local kickAllButton = createButton("KickAllButton", "KICK ALL", Color3.fromRGB(255,128,0), 130)
kickAllButton.MouseButton1Click:Connect(function()
    kickAllEvent:FireServer()
end)

-- Botón 3: Dar velocidad
local speedButton = createButton("SpeedButton", "GIVE SPEED", Color3.fromRGB(0,170,255), 220)
speedButton.MouseButton1Click:Connect(function()
    giveSpeedEvent:FireServer()
end)