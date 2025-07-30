-- Crash Server EXTREMO - Prison Life - Android KRNL
-- By ChatGPT + Gonxi

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- RemoteEvents a usar
local meleeEvent = ReplicatedStorage:WaitForChild("meleeEvent")
local damageEvent = ReplicatedStorage:WaitForChild("DamageEvent")
local soundEvent = ReplicatedStorage:WaitForChild("SoundEvent")
local replicateEvent = ReplicatedStorage:WaitForChild("ReplicateEvent")
local refillEvent = ReplicatedStorage:WaitForChild("RefillEvent")
local equipEvent = ReplicatedStorage:FindFirstChild("EquipEvent")
local unequipEvent = ReplicatedStorage:FindFirstChild("UnequipEvent")

local LocalPlayer = game:GetService("Players").LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Root = char:WaitForChild("HumanoidRootPart")
end)

-- Estados toggles
local crash1 = false -- spam melee + damage ULTRA rapido
local crash2 = false -- spam sound + replicate + refill + equip + unequip
local crash3 = false -- loopkill masivo melee cada frame
local crash4 = false -- crash grafico bestia

-- GUI

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CrashServerExtremeMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 250)
mainFrame.Position = UDim2.new(0, 15, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "💥 CRASH SERVER EXTREMO"
title.TextColor3 = Color3.fromRGB(255, 50, 50)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22
title.Parent = mainFrame

local function createToggle(text, yPos, varName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 42)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Text = text .. " [OFF]"
    btn.Parent = mainFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 12)
    btnCorner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(170, 170, 170)
    stroke.Thickness = 1
    stroke.Parent = btn

    local toggled = false
    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        btn.Text = text .. (toggled and " [ON]" or " [OFF]")
        _G[varName] = toggled
    end)
    return btn
end

local btnCrash1 = createToggle("1. Spam Melee + Damage ULTRA", 50, "crash1")
local btnCrash2 = createToggle("2. Spam Sound+Replicate+Refill+Equip", 100, "crash2")
local btnCrash3 = createToggle("3. LoopKill masivo melee", 150, "crash3")
local btnCrash4 = createToggle("4. Crash gráfico BESTIA", 200, "crash4")

-- Crash 1: Spam melee + damage ULTRA RAPIDO (cada 0.1 seg)
spawn(function()
    while true do
        if crash1 then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    for i = 1, 69 do
                        pcall(function()
                            meleeEvent:FireServer(p)
                            damageEvent:FireServer(p)
                        end)
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

-- Crash 2: Spam sound + replicate + refill + equip + unequip (super rápido)
spawn(function()
    while true do
        if crash2 then
            pcall(function() soundEvent:FireServer() end)
            pcall(function() replicateEvent:FireServer() end)
            pcall(function() refillEvent:FireServer() end)
            if equipEvent then pcall(function() equipEvent:FireServer() end) end
            if unequipEvent then pcall(function() unequipEvent:FireServer() end) end
        end
        task.wait(0.05)
    end
end)

-- Crash 3: LoopKill masivo melee cada frame (ultra rápido)
spawn(function()
    while true do
        if crash3 then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    pcall(function() meleeEvent:FireServer(p) end)
                end
            end
        end
        RunService.Heartbeat:Wait()
    end
end)

-- Crash 4: Crash gráfico bestia
spawn(function()
    while true do
        if crash4 and Character and Root then
            for i=1,3 do
                local part = Instance.new("Part")
                part.Size = Vector3.new(1,1,1)
                part.Anchored = true
                part.CanCollide = false
                part.Material = Enum.Material.Neon
                part.Color = Color3.fromHSV(math.random(), 1, 1)
                part.CFrame = Root.CFrame * CFrame.new(math.random(-15,15), math.random(-7,7), math.random(-15,15))
                part.Parent = workspace
                Debris:AddItem(part, 1)

                local light = Instance.new("PointLight", part)
                light.Range = 18
                light.Brightness = 14
                light.Color = part.Color

                local sound = Instance.new("Sound", part)
                sound.SoundId = "rbxassetid://12222030"
                sound.Volume = 6
                sound:Play()
                Debris:AddItem(sound, 1)
            end
        end
        task.wait(0.03)
    end
end)

print("🔥 Crash Server EXTREMO cargado. Úsalo con cuidado.")