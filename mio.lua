local gui = Instance.new("ScreenGui")
gui.Name = "NoclipGui"
gui.ResetOnSpawn = false 
gui.Parent =
game.Players.LocalPlayer:WaitForChild("PlayerGui")

local boton = Instance.new("TextButton")
boton.Parent = gui
boton.Size = UDim2.new(0, 150, 0, 50)
boton.Position = UDim2.new(0, 20, 0, 100)
boton.Text = "Activar No-Clip"
boton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
boton.TextColor3 = Color3.new(1, 1, 1)
boton.Font = Enum.Font.SourceSans
boton.TextSize = 18

local botonSpeed = 
Instance.new("TextButton")
botonSpeed.Parent = gui
botonSpeed.Size = UDim2.new(0, 150, 0, 50)
botonSpeed.Position = UDim2.new(0, 20, 0, 160)
botonSpeed.Text = "Speed x100"
botonSpeed.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
botonSpeed.Font = Enum.Font.SourceSans
botonSpeed.TextSize = 18
botonSpeed.TextColor3 = Color3.new(1, 1, 1)

local RunService =
game:GetService("RunService")
local noclipActivo = false
local conexionNoclip = nil
local speedActivo = false
boton.MouseButton1Click:Connect(function()
  print("Botón tocado")
  noclipActivo = not noclipActivo
  print("Noclip activado")
  local player = 
  game.Players.LocalPlayer
  local char = player.Character or 
  player.CharacterAdded:Wait()
  if not char then return end
  if noclipActivo then 
    print("Noclip ACTIVADO")
  conexionNoclip =
  RunService.Stepped:Connect(function()
    for _, part in
    pairs(char:GetDescendants()) do
      if part:IsA("BasePart") then
        part.CanCollide =
        false
      end
    end
  end)
  else 
    print("Noclip Desactivado")
    
    if conexionNoclip then
      conexionNoclip:Disconnect()
      conexionNoclip = nil
    end
    
    for _, part in
    pairs(char:GetDescendants()) do
      if part:IsA("BasePart") then
        part.CanCollide = true
      end
    end
  end
end)

botonSpeed.MouseButton1Click:Connect(function()
  local player = 
  game.Players.LocalPlayer
  local char = player.Character or 
  player.CharacterAdded:Wait()
  if not char then return end 
  local humanoide =
  char:FindFirstChildOfClass("Humanoid")
  if not humanoide then return end
  speedActivo = not speedActivo
  if speedActivo then
    print("Velocidad X100 ACTIVADA")
    humanoide.WalkSpeed = 100
    botonSpeed.Text = "Speed X1"
    else
      print("Velocidad Normal")
      humanoide.WalkSpeed = 16
      botonSpeed.Text = "Speed X100"
  end
end)