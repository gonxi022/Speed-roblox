-- ✅ KRNL ANDROID SPY AVANZADO CON GUI + MINIMIZAR
-- Pegar esto en la consola de KRNL Android

local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")

-- Crear GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "SpyGui"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0.6, 0, 0.4, 0)
frame.Position = UDim2.new(0.2, 0, 0.05, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 1
frame.Active = true
frame.Draggable = true

local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, 0, 0, 30)
toggle.Text = "🔍 KRNL Android Spy (Tocar para minimizar)"
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggle.Font = Enum.Font.SourceSansBold
toggle.TextSize = 16

local box = Instance.new("TextLabel", frame)
box.Size = UDim2.new(1, -10, 1, -40)
box.Position = UDim2.new(0, 5, 0, 35)
box.TextXAlignment = Enum.TextXAlignment.Left
box.TextYAlignment = Enum.TextYAlignment.Top
box.TextColor3 = Color3.new(0, 1, 0)
box.BackgroundTransparency = 1
box.Font = Enum.Font.Code
box.TextSize = 14
box.TextWrapped = true
box.Text = "Spy iniciado...\n"
box.ClipsDescendants = true

local minimized = false
toggle.MouseButton1Click:Connect(function()
	minimized = not minimized
	box.Visible = not minimized
	toggle.Text = minimized and "🔒 Spy minimizado (tocar para abrir)" or "🔍 KRNL Android Spy (Tocar para minimizar)"
end)

-- Función para loguear
local function log(msg)
	box.Text = box.Text .. "\n" .. msg
	if #box.Text > 10000 then
		box.Text = string.sub(box.Text, -5000) -- Limita tamaño
	end
end

-- 📥 OnClientEvent Remotes
for _, obj in pairs(RS:GetDescendants()) do
	if obj:IsA("RemoteEvent") then
		pcall(function()
			obj.OnClientEvent:Connect(function(...)
				log("📥 Remote: " .. obj.Name)
				local args = {...}
				for i,v in pairs(args) do
					log("  Arg #" .. i .. ": " .. tostring(v) .. " [" .. typeof(v) .. "]")
				end
			end)
		end)
	end
end

-- 🖱️ Clics en botones
for _, obj in pairs(game:GetDescendants()) do
	if obj:IsA("TextButton") or obj:IsA("ImageButton") then
		pcall(function()
			obj.MouseButton1Click:Connect(function()
				log("🖱️ Botón presionado: " .. obj:GetFullName())
			end)
		end)
	end
end

-- 🎮 Inputs del jugador
UIS.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed then
		log("🎮 Input detectado: " .. input.UserInputType.Name)
	end
end)

log("✅ Spy GUI activado. Esperando eventos...")