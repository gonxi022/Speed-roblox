-- ⚠️ Este script detecta la pelota y hace parry automático con botón flotante
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Buscar el RemoteEvent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local parryEvent = ReplicatedStorage:FindFirstChild("ParryAttempt") or ReplicatedStorage:FindFirstChild("RemoteEvent") -- cambia según el nombre

-- Botón flotante para encender/apagar
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local toggle = Instance.new("TextButton")
toggle.Parent = ScreenGui
toggle.Size = UDim2.new(0, 160, 0, 50)
toggle.Position = UDim2.new(0, 10, 0, 200)
toggle.Text = "Auto Parry: OFF"
toggle.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.TextScaled = true
toggle.BorderSizePixel = 0

local auto = false
toggle.MouseButton1Click:Connect(function()
	auto = not auto
	toggle.Text = auto and "Auto Parry: ON" or "Auto Parry: OFF"
	toggle.BackgroundColor3 = auto and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 80)
end)

-- Detectar pelota cerca y bloquear
while true do
	if auto and LocalPlayer.Character and parryEvent then
		local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local ball = workspace:FindFirstChild("Ball")
		if hrp and ball then
			local dist = (ball.Position - hrp.Position).Magnitude
			if dist < 23 then -- distancia ajustable
				parryEvent:FireServer()
			end
		end
	end
	wait(0.03)
end