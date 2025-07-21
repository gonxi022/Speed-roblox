-- MM2 Super Mod Menu - ESP, TP Kill, Fly, Noclip
-- Autor: ChatGPT - Android KRNL Compatible

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Estado
local noclip = false
local fly = false
local tpKill = false
local flySpeed = 3
local ESPList = {}

-- Crear UI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "MM2SuperMod"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 320)
frame.Position = UDim2.new(0, 20, 0, 60)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(50,50,50)
title.Text = "🔪 MM2 Super Menu"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

function createBtn(txt, posY)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 240, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Text = txt
    return btn
end

local noclipBtn = createBtn("Noclip: OFF", 40)
local flyBtn = createBtn("Fly: OFF", 80)
local tpBtn = createBtn("TP Kill: OFF", 120)
local toggleESPBtn = createBtn("ESP: ON", 160)

-- FUNCIONES

local function getRole(plr)
    local stats = plr:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Role") then
        return stats.Role.Value
    end
    return nil
end

local function applyESP()
    for _, esp in pairs(ESPList) do esp:Destroy() end
    table.clear(ESPList)

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local role = getRole(plr)
            local color = Color3.fromRGB(255, 255, 255)
            if role == "Murderer" then color = Color3.fromRGB(255, 50, 50)
            elseif role == "Sheriff" or role == "Innocent" then color = Color3.fromRGB(50, 255, 50) end

            local esp = Instance.new("BillboardGui", plr.Character.Head)
            esp.Size = UDim2.new(0, 100, 0, 40)
            esp.AlwaysOnTop = true
            esp.Name = "ESPTag"

            local nameLbl = Instance.new("TextLabel", esp)
            nameLbl.Size = UDim2.new(1, 0, 1, 0)
            nameLbl.Text = plr.Name
            nameLbl.TextColor3 = color
            nameLbl.TextScaled = true
            nameLbl.BackgroundTransparency = 1
            nameLbl.Font = Enum.Font.SourceSansBold

            table.insert(ESPList, esp)
        end
    end
end

local function toggleNoclip(state)
    noclip = state
    noclipBtn.Text = "Noclip: " .. (noclip and "ON" or "OFF")
end

local function toggleFly(state)
    fly = state
    flyBtn.Text = "Fly: " .. (fly and "ON" or "OFF")
end

local function toggleTPKill(state)
    tpKill = state
    tpBtn.Text = "TP Kill: " .. (tpKill and "ON" or "OFF")
end

-- Activar ESP al inicio
applyESP()

-- BOTONES
noclipBtn.MouseButton1Click:Connect(function()
    toggleNoclip(not noclip)
end)

flyBtn.MouseButton1Click:Connect(function()
    toggleFly(not fly)
end)

tpBtn.MouseButton1Click:Connect(function()
    toggleTPKill(not tpKill)
end)

toggleESPBtn.MouseButton1Click:Connect(function()
    applyESP()
end)

-- LOOP: Noclip y Fly
RunService.Stepped:Connect(function()
    if noclip and LocalPlayer.Character then
        for _, p in pairs(LocalPlayer.Character:GetChildren()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end
end)

local flying = false
local BodyGyro, BodyVelocity

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if fly and char and char:FindFirstChild("HumanoidRootPart") then
        if not flying then
            BodyGyro = Instance.new("BodyGyro")
            BodyGyro.P = 9e4
            BodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            BodyGyro.cframe = char.HumanoidRootPart.CFrame
            BodyGyro.Parent = char.HumanoidRootPart

            BodyVelocity = Instance.new("BodyVelocity")
            BodyVelocity.velocity = Vector3.new(0, 0, 0)
            BodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
            BodyVelocity.Parent = char.HumanoidRootPart
            flying = true
        end

        local direction = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction = direction - Vector3.new(0, 1, 0) end

        BodyVelocity.velocity = direction.Unit * flySpeed
        BodyGyro.CFrame = camera.CFrame
    elseif flying then
        flying = false
        if BodyGyro then BodyGyro:Destroy() end
        if BodyVelocity then BodyVelocity:Destroy() end
    end
end)

-- TP Kill on touch
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        plr.CharacterAdded:Connect(function()
            wait(1)
            applyESP()
        end)
    end
end

Players.PlayerAdded:Connect(function(plr)
    wait(1)
    applyESP()
end)

-- TP Kill usando ESP
RunService.RenderStepped:Connect(function()
    if tpKill and getRole(LocalPlayer) == "Murderer" then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = plr.Character.HumanoidRootPart
                LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, 2)
                wait(0.5)
            end
        end
    end
end)