-- FakePull_CleanFunctional_LocalScript.lua
-- Cole este LocalScript em StarterPlayerScripts ou StarterGui.
-- Tudo é CLIENT-SIDE: não faz chamadas ao servidor.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CONFIG
local WINDOW_W = 440
local WINDOW_H = 260
local EXPAND_TIME = 0.5
local LOAD_SECONDS = 30 -- tempo de "procura" (mantenha 30 se desejar)
local PANEL_COLOR = Color3.fromRGB(0, 0, 0)        -- painel preto
local STROKE_BLUE = Color3.fromRGB(0, 122, 255)    -- azul vivo no traço
local BUTTON_GREEN = Color3.fromRGB(40, 200, 120)
local BUTTON_RED = Color3.fromRGB(220, 60, 60)
local TEXT_COLOR = Color3.fromRGB(235,235,235)

-- Guardar volume original para restaurar depois
local originalVolume = SoundService.Volume

-- helper para criar instâncias rapidamente
local function new(className, props)
	local obj = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			if k == "Parent" then
				obj.Parent = v
			else
				obj[k] = v
			end
		end
	end
	return obj
end

-- limpa GUI anterior (se houver)
for _, child in ipairs(playerGui:GetChildren()) do
	if child.Name == "FakePullGUI" then
		child:Destroy()
	end
end

-- ScreenGui
local screenGui = new("ScreenGui", {
	Parent = playerGui,
	Name = "FakePullGUI",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

-- overlay full-screen (usado para bloquear input e cobrir tela)
local overlay = new("Frame", {
	Parent = screenGui,
	Name = "Overlay",
	Size = UDim2.new(1,0,1,0),
	Position = UDim2.new(0,0,0,0),
	BackgroundColor3 = PANEL_COLOR,
	BackgroundTransparency = 1, -- começamos transparente até expandir
	Visible = false,
	ZIndex = 100,
	Active = true,
})
new("UICorner", {Parent = overlay, CornerRadius = UDim.new(0,0)})

-- painel inicial (pequeno) - draggable
local panel = new("Frame", {
	Parent = screenGui,
	Name = "Panel",
	Size = UDim2.new(0, WINDOW_W, 0, WINDOW_H),
	Position = UDim2.new(0.5, -WINDOW_W/2, 0.5, -WINDOW_H/2),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(10,10,10),
	BorderSizePixel = 0,
	ZIndex = 105,
	Active = true,
})
new("UICorner", {Parent = panel, CornerRadius = UDim.new(0,12)})
new("UIStroke", {Parent = panel, Color = STROKE_BLUE, Thickness = 3})

-- shadow (pequeno) sob o painel
local shadow = new("Frame", {
	Parent = screenGui,
	Name = "PanelShadow",
	Size = panel.Size,
	Position = panel.Position + UDim2.new(0,6,0,6),
	BackgroundColor3 = Color3.fromRGB(0,0,0),
	BackgroundTransparency = 0.8,
	ZIndex = 104,
})
new("UICorner", {Parent = shadow, CornerRadius = UDim.new(0,14)})

-- content container centralizado
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

-- greeting (centralizado)
local greeting = new("TextLabel", {
	Parent = content,
	Size = UDim2.new(1, 0, 0, 40),
	BackgroundTransparency = 1,
	Text = "Olá, " .. (player.DisplayName ~= "" and player.DisplayName or player.Name),
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.GothamBold,
	TextSize = 22,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Center,
	ZIndex = 106,
})

local subtitle = new("TextLabel", {
	Parent = content,
	Size = UDim2.new(1, 0, 0, 18),
	BackgroundTransparency = 1,
	Text = "",
	TextColor3 = Color3.fromRGB(185,185,185),
	Font = Enum.Font.Gotham,
	TextSize = 14,
	TextXAlignment = Enum.TextXAlignment.Center,
	ZIndex = 106,
})

-- btn container
local btnContainer = new("Frame", {
	Parent = content,
	Size = UDim2.new(1, 0, 0, 64),
	BackgroundTransparency = 1,
	ZIndex = 106,
})
local btnLayout = new("UIListLayout", {
	Parent = btnContainer,
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0,14),
})

-- puxar button (principal)
local puxarBtn = new("TextButton", {
	Parent = btnContainer,
	Name = "PuxarBtn",
	Size = UDim2.new(0, 260, 0, 50),
	BackgroundColor3 = BUTTON_GREEN,
	Text = "Puxar jogadores",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	AutoButtonColor = true,
	ZIndex = 107,
})
new("UICorner", {Parent = puxarBtn, CornerRadius = UDim.new(0,10)})
new("UIStroke", {Parent = puxarBtn, Color = STROKE_BLUE, Thickness = 1, Transparency = 0.35})

-- close button
local closeBtn = new("TextButton", {
	Parent = btnContainer,
	Name = "CloseBtn",
	Size = UDim2.new(0, 120, 0, 50),
	BackgroundColor3 = BUTTON_RED,
	Text = "Fechar",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	AutoButtonColor = true,
	ZIndex = 107,
})
new("UICorner", {Parent = closeBtn, CornerRadius = UDim.new(0,10)})

-- Fullscreen content (dentro do overlay) - garantido bloqueio por overlay estar visível
local full = new("Frame", {
	Parent = overlay,
	Name = "FullContent",
	Size = UDim2.new(1,0,1,0),
	Position = UDim2.new(0,0,0,0),
	BackgroundTransparency = 1,
	ZIndex = 110,
	Visible = false,
	Active = true,
})

-- center frame inside full for UI elements
local center = new("Frame", {
	Parent = full,
	Size = UDim2.new(0.8, 0, 0.7, 0),
	Position = UDim2.new(0.5,0,0.5,0),
	AnchorPoint = Vector2.new(0.5,0.5),
	BackgroundTransparency = 1,
	ZIndex = 111,
})
local centerLayout = new("UIListLayout", {
	Parent = center,
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0,10),
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
	ZIndex = 112,
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
	ZIndex = 112,
})
new("UICorner", {Parent = inputBox, CornerRadius = UDim.new(0,8)})
new("UIStroke", {Parent = inputBox, Color = Color3.fromRGB(200,200,200), Thickness = 1, Transparency = 0.6})

local puxarServerBtn = new("TextButton", {
	Parent = center,
	Name = "PuxarServerBtn",
	Size = UDim2.new(0, 200, 0, 46),
	BackgroundColor3 = BUTTON_GREEN,
	Text = "Puxar player",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	AutoButtonColor = true,
	ZIndex = 112,
})
new("UICorner", {Parent = puxarServerBtn, CornerRadius = UDim.new(0,10)})
new("UIStroke", {Parent = puxarServerBtn, Color = STROKE_BLUE, Thickness = 1, Transparency = 0.35})

-- progress area
local progressHolder = new("Frame", {
	Parent = center,
	Name = "ProgressHolder",
	Size = UDim2.new(0.85,0,0,120),
	BackgroundTransparency = 1,
	Visible = false,
	ZIndex = 112,
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
	ZIndex = 112,
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
	ZIndex = 112,
})
local barBg = new("Frame", {
	Parent = progressHolder,
	Size = UDim2.new(1,0,0,18),
	Position = UDim2.new(0,0,0,56),
	BackgroundColor3 = Color3.fromRGB(45,45,45),
	ZIndex = 112,
})
new("UICorner", {Parent = barBg, CornerRadius = UDim.new(0,8)})
local barFill = new("Frame", {
	Parent = barBg,
	Size = UDim2.new(0,0,1,0),
	BackgroundColor3 = Color3.fromRGB(80,220,140),
	ZIndex = 113,
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
	ZIndex = 112,
})

local finishBtn = new("TextButton", {
	Parent = center,
	Name = "FinishBtn",
	Size = UDim2.new(0,140,0,44),
	BackgroundColor3 = BUTTON_RED,
	Text = "Fechar",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	Visible = false,
	ZIndex = 112,
})
new("UICorner", {Parent = finishBtn, CornerRadius = UDim.new(0,10)})

-- estado
local expanded = false

-- util: hide all GUIObjects in a parent except listed ones
local function hideAllExcept(parent, keepList)
	local keep = {}
	for _,v in ipairs(keepList or {}) do keep[v] = true end
	for _,obj in ipairs(parent:GetDescendants()) do
		if obj:IsA("GuiObject") and not keep[obj] and obj ~= parent then
			pcall(function() obj.Visible = false end)
		end
	end
end

-- draggable logic (before expand)
do
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPos = nil

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

-- expand: show overlay, animate panel to full screen, mute sound
local function expandToFull()
	if expanded then return end
	expanded = true

	-- show overlay fully (opaque) to hide background and block input
	overlay.BackgroundTransparency = 0
	overlay.Visible = true
	full.Visible = true

	-- move overlay above others
	overlay.ZIndex = 200
	full.ZIndex = 205
	panel.ZIndex = 210
	shadow.ZIndex = 209

	-- tween panel & shadow to fill screen
	local success, err = pcall(function()
		local tweenInfo = TweenInfo.new(EXPAND_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		local t1 = TweenService:Create(panel, tweenInfo, {Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), AnchorPoint = Vector2.new(0,0)})
		local t2 = TweenService:Create(shadow, tweenInfo, {Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), AnchorPoint = Vector2.new(0,0)})
		t1:Play(); t2:Play()
		t1.Completed:Wait()
	end)
	if not success then
		-- fallback: set directly
		panel.Size = UDim2.new(1,0,1,0); panel.Position = UDim2.new(0,0,0,0); panel.AnchorPoint = Vector2.new(0,0)
		shadow.Size = panel.Size; shadow.Position = panel.Position
	end

	-- ensure full UI is visible and inputBox present
	full.Visible = true
	center.Visible = true
	fullTitle.Visible = true
	inputBox.Visible = true
	puxarServerBtn.Visible = true

	-- mute local sound
	pcall(function() SoundService.Volume = 0 end)
end

-- progress sequence
local function startProgress()
	-- hide inputs and show progress holder
	inputBox.Visible = false
	puxarServerBtn.Visible = false
	fullTitle.Text = "Procurando player..."
	progressHolder.Visible = true

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

-- button events
puxarBtn.MouseButton1Click:Connect(function()
	-- small pulse then expand
	TweenService:Create(puxarBtn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 268, 0, 54)}):Play()
	wait(0.12)
	TweenService:Create(puxarBtn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 260, 0, 50)}):Play()

	-- cleanup of small panel visuals: hide subtitle etc to look clean
	subtitle.Visible = false
	hideAllExcept(panel, {puxarBtn, closeBtn})
	wait(0.06)
	expandToFull()
end)

closeBtn.MouseButton1Click:Connect(function()
	-- restore sound and remove gui
	pcall(function() SoundService.Volume = originalVolume end)
	screenGui:Destroy()
end)

puxarServerBtn.MouseButton1Click:Connect(function()
	local link = tostring(inputBox.Text or "")
	if link:match("^%s*$") then
		-- feedback shake
		local orig = inputBox.Position
		for i=1,6 do
			local offset = (i % 2 == 0) and 8 or -8
			TweenService:Create(inputBox, TweenInfo.new(0.04), {Position = UDim2.new(orig.X.Scale, orig.X.Offset + offset, orig.Y.Scale, orig.Y.Offset)}):Play()
			wait(0.04)
		end
		inputBox.Position = orig
		fullTitle.Text = "Cole um link antes de puxar"
		wait(1.1)
		fullTitle.Text = "Cole o link do servidor privado que deseja"
		return
	end

	-- start the fake progress
	hideAllExcept(overlay, {full, center, progressHolder, barBg, barFill, percentLabel, dotsLabel, pTitle})
	startProgress()
end)

finishBtn.MouseButton1Click:Connect(function()
	pcall(function() SoundService.Volume = originalVolume end)
	screenGui:Destroy()
end)

-- initial state: ensure visible states
overlay.Visible = false
full.Visible = false
progressHolder.Visible = false
finishBtn.Visible = false
subtitle.Text = ""

-- position shadow behind panel properly
shadow.Position = panel.Position + UDim2.new(0,6,0,6)
shadow.Size = panel.Size

-- ready
