-- LocalScript (colocar em StarterGui)
-- Versão atualizada: texto do botão agora é TOTALMENTE BRANCO (sem stroke/transparência),
-- removeu sombra fake e mantém painel arrastável.
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerName = (player.DisplayName and player.DisplayName ~= "") and player.DisplayName or player.Name

-- Cria ScreenGui e parent para PlayerGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WelcomeGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main frame (painel preto com contorno azul)
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 420, 0, 220)
frame.Position = UDim2.new(0.5, 0, 0.4, 0)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(10,10,10) -- preto suave
frame.BorderSizePixel = 0
frame.ZIndex = 2
frame.Parent = screenGui
frame.Active = true -- necessário para receber Input events para arrastar

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = frame

-- Contorno azul usando UIStroke
local stroke = Instance.new("UIStroke")
stroke.Thickness = 6
stroke.Color = Color3.fromRGB(0, 140, 255) -- azul chamativo
stroke.Transparency = 0
stroke.Parent = frame

-- Título: "OLÁ, USERNAME"
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Parent = frame
title.AnchorPoint = Vector2.new(0.5, 0.5)
title.Position = UDim2.new(0.5, 0, 0.33, 0)
title.Size = UDim2.new(0.9, 0, 0.28, 0)
title.BackgroundTransparency = 1
title.Text = "OLÁ, " .. string.upper(playerName)
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextStrokeTransparency = 0.75
title.TextWrapped = true
title.ZIndex = 3

-- Subtexto opcional (estilístico)
local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.Parent = frame
subtitle.AnchorPoint = Vector2.new(0.5, 0)
subtitle.Position = UDim2.new(0.5, 0, 0.48, 0)
subtitle.Size = UDim2.new(0.85, 0, 0.12, 0)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Bem-vindo(a)! Pronto para começar?"
subtitle.TextColor3 = Color3.fromRGB(200,200,200)
subtitle.TextScaled = true
subtitle.Font = Enum.Font.Gotham
subtitle.TextTransparency = 0.1
subtitle.ZIndex = 3

-- Botão verde chamativo "COMEÇAR TESTE"
local button = Instance.new("TextButton")
button.Name = "StartButton"
button.Parent = frame
button.AnchorPoint = Vector2.new(0.5, 0)
button.Position = UDim2.new(0.5, 0, 0.68, 0)
button.Size = UDim2.new(0.6, 0, 0, 54)
button.BackgroundColor3 = Color3.fromRGB(255,255,255) -- verde base
button.Text = "SIM"
button.Font = Enum.Font.GothamSemibold
button.TextSize = 20
-- Garantir que o texto do botão fique totalmente branco e sem efeitos:
button.TextColor3 = Color3.fromRGB(255,255,255)
button.TextTransparency = 0
button.TextStrokeTransparency = 1
button.TextStrokeColor3 = Color3.fromRGB(255,255,255)
button.TextScaled = true
button.AutoButtonColor = false
button.ZIndex = 3

local btnCorner = Instance.new("UICorner", button)
btnCorner.CornerRadius = UDim.new(0,12)

-- Gradiente para ficar mais chamativo
local btnGradient = Instance.new("UIGradient", button)
btnGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(38,200,92)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(13,160,60))
}
btnGradient.Rotation = 90

-- Delineamento sutil do botão (mantido no fundo, não afeta o texto)
local btnStroke = Instance.new("UIStroke", button)
btnStroke.Thickness = 2
btnStroke.Color = Color3.fromRGB(255,255,255)
btnStroke.Transparency = 0.6

-- Efeitos de hover e clique usando TweenService
local hoverTweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local clickTweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local hoverTween = TweenService:Create(button, hoverTweenInfo, {Size = UDim2.new(0.62,0,0,56)})
local unhoverTween = TweenService:Create(button, hoverTweenInfo, {Size = UDim2.new(0.6,0,0,54)})
local clickTween = TweenService:Create(button, clickTweenInfo, {Position = UDim2.new(0.5,0,0.685,0)})

button.MouseEnter:Connect(function()
	hoverTween:Play()
end)
button.MouseLeave:Connect(function()
	unhoverTween:Play()
end)
button.MouseButton1Down:Connect(function()
	clickTween:Play()
end)
button.MouseButton1Up:Connect(function()
	-- animação de clique rápido e ação
	unhoverTween:Play()
	local flash = TweenService:Create(button, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.15})
	flash:Play()
	flash.Completed:Wait()
	local restore = TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
	restore:Play()
	print("Botão 'COMEÇAR TESTE' clicado por:", playerName)
	-- Aqui você pode disparar RemoteEvent para o servidor, abrir outra GUI, etc.
end)

-- Aparecer com uma pequena animação (sobe e fica)
frame.Position = UDim2.new(0.5, 0, 0.6, 0)
local introTween = TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.4, 0)})
introTween:Play()

-- Funcionalidade de arrastar o painel (drag)
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position

		-- finaliza arrasto quando o input terminar
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)
