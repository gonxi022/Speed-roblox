-- Gem & Checkpoint Storm OP para Legends of Speed
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local tpEnabled = false
local gemCount = 0
local checkpointCount = 0

-- Cache para gemas y checkpoints
local gemsCache = {}
local checkpointsCache = {}

local function updateCaches()
    gemsCache = {}
    checkpointsCache = {}

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local lname = obj.Name:lower()
            if lname:find("gem") then
                table.insert(gemsCache, obj)
            elseif lname:find("checkpoint") or lname:find("step") then
                table.insert(checkpointsCache, obj)
            end
        end
    end
end

local function teleportToPositions(positions)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local coThreads = {}
    for _, posPart in ipairs(positions) do
        local co = coroutine.create(function()
            pcall(function()
                hrp.CFrame = CFrame.new(posPart.Position + Vector3.new(0,2.5,0))
            end)
        end)
        table.insert(coThreads, co)
    end
    for _, co in ipairs(coThreads) do
        coroutine.resume(co)
    end
end

RunService.Heartbeat:Connect(function()
    if tpEnabled then
        pcall(function()
            updateCaches()
            gemCount = #gemsCache
            checkpointCount = #checkpointsCache
            teleportToPositions(gemsCache)
            teleportToPositions(checkpointsCache)
        end)
    end
end)

-- UI interactiva y stats
local function createUI()
    local oldGui = PlayerGui:FindFirstChild("GemCheckUI")
    if oldGui then oldGui:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "GemCheckUI"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 280, 0, 60)
    btn.Position = UDim2.new(0.03, 0, 0.78, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.BorderSizePixel = 0
    btn.BackgroundTransparency = 0.1
    btn.Text = "⚡ GEM & CHECKPOINT OFF"
    btn.Parent = gui

    local statsLabel = Instance.new("TextLabel")
    statsLabel.Size = UDim2.new(0, 280, 0, 40)
    statsLabel.Position = UDim2.new(0.03, 0, 0.72, 0)
    statsLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    statsLabel.BackgroundTransparency = 0.2
    statsLabel.TextColor3 = Color3.new(1,1,1)
    statsLabel.TextScaled = true
    statsLabel.BorderSizePixel = 0
    statsLabel.Text = "Gemas: 0 | Checkpoints: 0"
    statsLabel.Parent = gui

    btn.MouseButton1Click:Connect(function()
        tpEnabled = not tpEnabled
        btn.Text = tpEnabled and "⚡ GEM & CHECKPOINT ON" or "⚡ GEM & CHECKPOINT OFF"
    end)
    btn.TouchTap:Connect(btn.MouseButton1Click)

    coroutine.wrap(function()
        while true do
            if tpEnabled then
                statsLabel.Text = ("Gemas: %d | Checkpoints: %d"):format(gemCount, checkpointCount)
            else
                statsLabel.Text = "Gemas: 0 | Checkpoints: 0"
            end
            task.wait(0.5)
        end
    end)()

    Players.LocalPlayer.CharacterAdded:Connect(function()
        wait(1)
        createUI()
    end)
end

createUI()
