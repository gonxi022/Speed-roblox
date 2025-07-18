-- GemStorm Ultra OP Collector para Legends of Speed
-- Multi-Teleport, sin pausas, con UI y stats
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local tpEnabled = false
local cacheGems = {}
local gemCount = 0

-- Actualiza lista de gemas y cachea
local function updateGemCache()
    cacheGems = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("gem") then
            table.insert(cacheGems, obj)
        end
    end
end

-- Teletransporta instantáneo sin pausa, en paralelo usando corutinas
local function multiTeleport()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    gemCount = 0

    local coroutines = {}
    for _, gem in ipairs(cacheGems) do
        local co = coroutine.create(function()
            pcall(function()
                hrp.CFrame = CFrame.new(gem.Position + Vector3.new(0,2.5,0))
                gemCount = gemCount + 1
            end)
        end)
        table.insert(coroutines, co)
    end

    for _, co in ipairs(coroutines) do
        coroutine.resume(co)
    end
end

-- Actualiza contador en UI
local function updateStatsLabel(label)
    while true do
        if tpEnabled then
            label.Text = "Gemas recogidas (estimado): "..gemCount
        else
            label.Text = "Gemas recogidas (estimado): 0"
        end
        task.wait(0.5)
    end
end

-- Loop principal para activar teleports constantemente
RunService.Heartbeat:Connect(function()
    if tpEnabled then
        pcall(function()
            updateGemCache()
            multiTeleport()
        end)
    end
end)

-- UI avanzada con stats y toggle
local function createUI()
    local oldGui = PlayerGui:FindFirstChild("GemStormUI")
    if oldGui then oldGui:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "GemStormUI"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui

    -- Botón toggle
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 280, 0, 60)
    btn.Position = UDim2.new(0.03, 0, 0.78, 0)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.BorderSizePixel = 0
    btn.BackgroundTransparency = 0.1
    btn.Text = "⚡ GEMSTORM OFF"
    btn.Parent = gui

    -- Label stats
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Size = UDim2.new(0, 280, 0, 40)
    statsLabel.Position = UDim2.new(0.03, 0, 0.72, 0)
    statsLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    statsLabel.BackgroundTransparency = 0.2
    statsLabel.TextColor3 = Color3.new(1,1,1)
    statsLabel.TextScaled = true
    statsLabel.BorderSizePixel = 0
    statsLabel.Text = "Gemas recogidas (estimado): 0"
    statsLabel.Parent = gui

    btn.MouseButton1Click:Connect(function()
        tpEnabled = not tpEnabled
        btn.Text = tpEnabled and "⚡ GEMSTORM ON" or "⚡ GEMSTORM OFF"
        if not tpEnabled then
            gemCount = 0
        end
    end)

    btn.TouchTap:Connect(btn.MouseButton1Click)

    Players.LocalPlayer.CharacterAdded:Connect(function()
        wait(1)
        createUI()
    end)

    coroutine.wrap(function()
        updateStatsLabel(statsLabel)
    end)()
end

createUI()
