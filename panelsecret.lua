-- FakePull_Refined_LocalScript.lua
-- Cole este LocalScript em StarterPlayerScripts ou StarterGui.
-- TODO: este script é APENAS uma simulação local (client-side). NÃO faz nada no servidor.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Cores (convertidas dos hex que você forneceu)
local COLOR_PANEL = Color3.fromRGB(1, 10, 13)    -- #010a0d
local COLOR_STROKE = Color3.fromRGB(0, 183, 255) -- #00b7ff
local COLOR_GREEN = Color3.fromRGB(0, 255, 13)   -- #00ff0d
local COLOR_RED   = Color3.fromRGB(255, 0, 0)    -- #ff0000
local TEXT_COLOR  = Color3.fromRGB(240,240,240)

-- Ajustes de tempo / tamanhos
local WINDOW_W = 440
local WINDOW_H = 260
local EXPAND_TIME = 0.5
local LOAD_SECONDS = 30 -- tempo da barra (ajuste se quiser)

-- Guarda volume original e restaura ao fechar
local originalVolume = SoundService.Volume

-- Factory helper
local function new(className, props)
	local obj = Instance.new(className)
	if props then
		for k,v in pairs(props) do
			if k == "Parent" then obj.Parent = v else obj[k] = v end
		end
	end
	return obj
end

-- Remove GUI antiga se existir
for _,child in ipairs(playerGui:GetChildren()) do
	if child.Name == "FakePullGUI" then
		pcall(function() child:Destroy() end)
	end
end

-- ScreenGui principal
local screenGui = new("ScreenGui", {
	Parent = playerGui,
	Name = "FakePullGUI",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

-- Overlay fullscreen (usado ao expandir para bloquear cliques e cobrir tela)
local overlay = new("Frame", {
	Parent = screenGui,
	Name = "Overlay",
	Size = UDim2.new(1,0,1,0),
	Position = UDim2.new(0,0,0,0),
	BackgroundColor3 = Color3.fromRGB(0,0,0),
	BackgroundTransparency = 0.5,
	ZIndex = 1000,
	Visible = false,
	Active = true,
})
new("UICorner", {Parent = overlay, CornerRadius = UDim.new(0,0)})

-- Painel inicial (central, arrastável antes do primeiro clique)
local panel = new("Frame", {
	Parent = screenGui,
	Name = "Panel",
	Size = UDim2.new(0, WINDOW_W, 0, WINDOW_H),
	Position = UDim2.new(0.5, -WINDOW_W/2, 0.5, -WINDOW_H/2),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = COLOR_PANEL,
	BorderSizePixel = 0,
	ZIndex = 1010,
	Active = true,
})
new("UICorner", {Parent = panel, CornerRadius = UDim.new(0,12)})
new("UIStroke", {Parent = panel, Color = COLOR_STROKE, Thickness = 3})

-- Sombra (visual)
local shadow = new("Frame", {
	Parent = screenGui,
	Name = "Shadow",
	Size = panel.Size,
	Position = panel.Position + UDim2.new(0,6,0,6),
	BackgroundColor3 = Color3.fromRGB(0,0,0),
	BackgroundTransparency = 0.75,
	ZIndex = 1005,
})
new("UICorner", {Parent = shadow, CornerRadius = UDim.new(0,12)})

-- Conteúdo interno (centralizado)
local content = new("Frame", {
	Parent = panel,
	Size = UDim2.new(1, -36, 1, -36),
	Position = UDim2.new(0, 18, 0, 18),
	BackgroundTransparency = 1,
})
local layout = new("UIListLayout", {
	Parent = content,
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0,6),
})
layout.SortOrder = Enum.SortOrder.LayoutOrder

local greeting = new("TextLabel", {
	Parent = content,
	Size = UDim2.new(1,0,0,40),
	BackgroundTransparency = 1,
	Text = "Olá, " .. (player.DisplayName ~= "" and player.DisplayName or player.Name),
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.GothamBold,
	TextSize = 22,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Center,
	ZIndex = 1015,
})

local subtitle = new("TextLabel", {
	Parent = content,
	Size = UDim2.new(1,0,0,18),
	BackgroundTransparency = 1,
	Text = "",
	TextColor3 = Color3.fromRGB(190,190,190),
	Font = Enum.Font.Gotham,
	TextSize = 14,
	TextXAlignment = Enum.TextXAlignment.Center,
	ZIndex = 1015,
})

-- Botões
local btnContainer = new("Frame", {
	Parent = content,
	Size = UDim2.new(1,0,0,64),
	BackgroundTransparency = 1,
	ZIndex = 1015,
})
local btnLayout = new("UIListLayout", {
	Parent = btnContainer,
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0,12),
})

local puxarBtn = new("TextButton", {
	Parent = btnContainer,
	Name = "PuxarBtn",
	Size = UDim2.new(0, 260, 0, 50),
	BackgroundColor3 = COLOR_GREEN,
	Text = "Puxar jogadores",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	AutoButtonColor = true,
	ZIndex = 1020,
})
new("UICorner", {Parent = puxarBtn, CornerRadius = UDim.new(0,10)})
new("UIStroke", {Parent = puxarBtn, Color = COLOR_STROKE, Thickness = 1, Transparency = 0.35})

local closeBtn = new("TextButton", {
	Parent = btnContainer,
	Name = "CloseBtn",
	Size = UDim2.new(0, 120, 0, 50),
	BackgroundColor3 = COLOR_RED,
	Text = "Fechar",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	AutoButtonColor = true,
	ZIndex = 1020,
})
new("UICorner", {Parent = closeBtn, CornerRadius = UDim.new(0,10)})

-- Fullscreen UI (dentro do overlay para garantir bloqueio)
local full = new("Frame", {
	Parent = overlay,
	Name = "FullContent",
	Size = UDim2.new(1,0,1,0),
	Position = UDim2.new(0,0,0,0),
	BackgroundTransparency = 1,
	ZIndex = 1010,
	Visible = false,
	Active = true,
})
local center = new("Frame", {
	Parent = full,
	Size = UDim2.new(0.8,0,0.7,0),
	Position = UDim2.new(0.5,0,0.5,0),
	AnchorPoint = Vector2.new(0.5,0.5),
	BackgroundTransparency = 1,
	ZIndex = 1015,
})
local centerLayout = new("UIListLayout", {
	Parent = center,
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0,12),
})

local fullTitle = new("TextLabel", {
	Parent = center,
	Size = UDim2.new(1,0,0,64),
	BackgroundTransparency = 1,
	Text = "Cole o link do servidor privado que deseja",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.GothamBold,
	TextSize = 24,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Center,
	ZIndex = 1020,
})

local inputBox = new("TextBox", {
	Parent = center,
	Name = "ServerLinkBox",
	Size = UDim2.new(0.85,0,0,44),
	BackgroundColor3 = Color3.fromRGB(245,245,245),
	Text = "",
	PlaceholderText = "Cole o link do servidor aqui",
	TextColor3 = Color3.fromRGB(20,20,20),
	Font = Enum.Font.Gotham,
	TextSize = 18,
	ClearTextOnFocus = false,
	ZIndex = 1020,
})
new("UICorner", {Parent = inputBox, CornerRadius = UDim.new(0,8)})
new("UIStroke", {Parent = inputBox, Color = Color3.fromRGB(200,200,200), Thickness = 1, Transparency = 0.6})

local puxarServerBtn = new("TextButton", {
	Parent = center,
	Name = "PuxarServerBtn",
	Size = UDim2.new(0, 200, 0, 46),
	BackgroundColor3 = COLOR_GREEN,
	Text = "Puxar player",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	AutoButtonColor = true,
	ZIndex = 1020,
})
new("UICorner", {Parent = puxarServerBtn, CornerRadius = UDim.new(0,10)})
new("UIStroke", {Parent = puxarServerBtn, Color = COLOR_STROKE, Thickness = 1, Transparency = 0.35})

-- Progress elements
local progressHolder = new("Frame", {
	Parent = center,
	Name = "ProgressHolder",
	Size = UDim2.new(0.85,0,0,120),
	BackgroundTransparency = 1,
	Visible = false,
	ZIndex = 1020,
})
local pTitle = new("TextLabel", {
	Parent = progressHolder,
	Size = UDim2.new(1,0,0,28),
	BackgroundTransparency = 1,
	Text = "PROCURANDO PLAYER",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.GothamBold,
	TextSize = 20,
	TextXAlignment = Enum.TextXAlignment.Center,
	ZIndex = 1020,
})
local dotsLabel = new("TextLabel", {
	Parent = progressHolder,
	Size = UDim2.new(1,0,0,22),
	Position = UDim2.new(0,0,0,28),
	BackgroundTransparency = 1,
	Text = "",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.Gotham,
	TextSize = 18,
	TextXAlignment = Enum.TextXAlignment.Center,
	ZIndex = 1020,
})
local barBg = new("Frame", {
	Parent = progressHolder,
	Size = UDim2.new(1,0,0,18),
	Position = UDim2.new(0,0,0,56),
	BackgroundColor3 = Color3.fromRGB(45,45,45),
	ZIndex = 1020,
})
new("UICorner", {Parent = barBg, CornerRadius = UDim.new(0,8)})
local barFill = new("Frame", {
	Parent = barBg,
	Size = UDim2.new(0,0,1,0),
	BackgroundColor3 = COLOR_GREEN,
	ZIndex = 1025,
})
new("UICorner", {Parent = barFill, CornerRadius = UDim.new(0,8)})
local percentLabel = new("TextLabel", {
	Parent = progressHolder,
	Size = UDim2.new(1,0,0,22),
	Position = UDim2.new(0,0,0,80),
	BackgroundTransparency = 1,
	Text = "0%",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	TextXAlignment = Enum.TextXAlignment.Center,
	ZIndex = 1020,
})

local finishBtn = new("TextButton", {
	Parent = center,
	Name = "FinishBtn",
	Size = UDim2.new(0,140,0,44),
	BackgroundColor3 = COLOR_RED,
	Text = "Fechar",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	Visible = false,
	ZIndex = 1020,
})
new("UICorner", {Parent = finishBtn, CornerRadius = UDim.new(0,10)})

-- Estado
local expanded = false

-- Utility: hide all gui objects under a root except exceptions (uses identity compare)
local function hideAllExcept(root, exceptions)
	local except = {}
	for _,v in ipairs(exceptions or {}) do except[v] = true end
	for _,obj in ipairs(root:GetDescendants()) do
		if obj:IsA("GuiObject") and obj ~= root and not except[obj] then
			pcall(function() obj.Visible = false end)
		end
	end
end

-- Drag logic (allow dragging before expand)
do
	local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

	local function onInputChanged(input)
		if input == dragInput and dragging and not expanded then
			local delta = input.Position - dragStart
			panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			shadow.Position = panel.Position + UDim2.new(0,6,0,6)
		end
	end

	panel.InputBegan:Connect(function(input)
		if expanded then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = panel.Position
			dragInput = input
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(onInputChanged)
end

-- Expand to fullscreen: show overlay, tween panel to full, mute sound
local function expandToFullscreen()
	if expanded then return end
	expanded = true

	overlay.Visible = true
	full.Visible = true

	-- bring to front
	overlay.ZIndex = 1000
	full.ZIndex = 1005
	panel.ZIndex = 1010
	shadow.ZIndex = 1009

	-- tween panel & shadow to fill full screen (fallback to direct set if tween fails)
	local ok, err = pcall(function()
		local info = TweenInfo.new(EXPAND_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		local t1 = TweenService:Create(panel, info, {Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), AnchorPoint = Vector2.new(0,0)})
		local t2 = TweenService:Create(shadow, info, {Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), AnchorPoint = Vector2.new(0,0)})
		t1:Play(); t2:Play()
		t1.Completed:Wait()
	end)
	if not ok then
		panel.Size = UDim2.new(1,0,1,0); panel.Position = UDim2.new(0,0,0,0); panel.AnchorPoint = Vector2.new(0,0)
		shadow.Size = panel.Size; shadow.Position = panel.Position
	end

	-- show center content
	center.Visible = true
	fullTitle.Visible = true
	inputBox.Visible = true
	puxarServerBtn.Visible = true
	progressHolder.Visible = false
	finishBtn.Visible = false

	-- mute local sounds
	pcall(function() SoundService.Volume = 0 end)
end

-- Start progress sequence (bar fills over LOAD_SECONDS)
local function startProgressSequence()
	-- hide input & show progress
	inputBox.Visible = false
	puxarServerBtn.Visible = false
	progressHolder.Visible = true
	fullTitle.Text = "Procurando player..."

	local startTime = tick()
	local conn
	conn = RunService.Heartbeat:Connect(function()
		local elapsed = tick() - startTime
		local pct = math.clamp(elapsed / LOAD_SECONDS, 0, 1)
		barFill.Size = UDim2.new(pct, 0, 1, 0)
		percentLabel.Text = string.format("%d%%", math.floor(pct * 100))
		local dots = (math.floor(elapsed * 2) % 3) + 1
		dotsLabel.Text = string.rep(".", dots)
		if pct >= 1 then
			conn:Disconnect()
			wait(0.2)
			pTitle.Text = "PRONTO"
			dotsLabel.Text = ""
			finishBtn.Visible = true
		end
	end)
end

-- Button events
puxarBtn.MouseButton1Click:Connect(function()
	-- small visual click feedback
	TweenService:Create(puxarBtn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 272, 0, 54)}):Play()
	wait(0.08)
	TweenService:Create(puxarBtn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 260, 0, 50)}):Play()

	-- tidy up small UI and expand
	subtitle.Visible = false
	hideAllExcept(panel, {puxarBtn, closeBtn})
	wait(0.06)
	expandToFullscreen()
end)

closeBtn.MouseButton1Click:Connect(function()
	pcall(function() SoundService.Volume = originalVolume end)
	screenGui:Destroy()
end)

puxarServerBtn.MouseButton1Click:Connect(function()
	local link = tostring(inputBox.Text or "")
	if link:match("^%s*$") then
		-- shake feedback
		local orig = inputBox.Position
		for i=1,6 do
			local offset = (i % 2 == 0) and 8 or -8
			TweenService:Create(inputBox, TweenInfo.new(0.04), {Position = UDim2.new(orig.X.Scale, orig.X.Offset + offset, orig.Y.Scale, orig.Y.Offset)}):Play()
			wait(0.04)
		end
		inputBox.Position = orig
		fullTitle.Text = "Cole um link antes de puxar"
		wait(1.0)
		fullTitle.Text = "Cole o link do servidor privado que deseja"
		return
	end

	-- hide everything except progress to make the result clean
	hideAllExcept(overlay, {full, center, progressHolder, barBg, barFill, percentLabel, dotsLabel, pTitle})
	startProgressSequence()
end)

finishBtn.MouseButton1Click:Connect(function()
	pcall(function() SoundService.Volume = originalVolume end)
	screenGui:Destroy()
end)

-- Inicializações finais para garantir visibilidades corretas
overlay.Visible = false
full.Visible = false
center.Visible = false
progressHolder.Visible = false
finishBtn.Visible = false
subtitle.Text = ""

-- Posiciona sombra corretamente
shadow.Position = panel.Position + UDim2.new(0,6,0,6)
shadow.Size = panel.Size

-- Ready
