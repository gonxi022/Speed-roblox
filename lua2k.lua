--h2k Script
local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

local speed = Instance.new("TextButton")
speed.Name = "Speed"
speed.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
speed.Size = UDim2.new(0, 150, 0, 50)
speed.Position = UDim2.new(0, 120, 0, 40)
speed.Text = "Speed off"
speed.TextColor3 = Color3.fromRGB(255, 255, 255)
speed.Parent = gui

local speedActive = false

speed.MouseButton1Click:Connect(function()
  speedActive = not speedActive
  if speedActive then
    player.Character.Humanoid.WalkSpeed = 90
    speed.Text = "Speed On"
    speed.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    else
      player.Character.Humanoid.WalkSpeed = 16
      speed.Text = "Speed Off"
      speed.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
  end
end)
  