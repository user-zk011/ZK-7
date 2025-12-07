-- FakePull_Improved_LocalScript.lua
-- Cole este LocalScript em StarterPlayerScripts ou StarterGui.
-- Todo comportamento é local (client-side) e não faz chamadas ao servidor.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configs visuais / de tempo
local WINDOW_W = 460
local WINDOW_H = 280
local EXPAND_TIME = 0.55
local LOAD_SECONDS = 30 -- duração do "progresso" (segundos)
local PANEL_COLOR = Color3.fromRGB(10,10,10)         -- painel quase preto
local STROKE_BLUE = Color3.fromRGB(0,122,255)        -- azul vivo
local BUTTON_GREEN = Color3.fromRGB(40,200,120)
local BUTTON_RED = Color3.fromRGB(220,60,60)
local TEXT_COLOR = Color3.fromRGB(245,245,245)

local originalVolume = SoundService.Volume

local function new(className, props)
	local obj = Instance.new(className)
	if props then
		for k,v in pairs(props) do
			if k == "Parent" then obj.Parent = v else obj[k] = v end
		end
	end
	return obj
end

-- remove GUI antigo
for _,c in ipairs(playerGui:GetChildren()) do
	if c.Name == "FakePullGUI" then pcall(function() c:Destroy() end) end
end

local screenGui = new("ScreenGui", {
	Parent = playerGui,
	Name = "FakePullGUI",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

-- Full-screen overlay que bloqueia interações atrás (sempre por cima quando visível)
local overlay = new("Frame", {
	Parent = screenGui,
	Name = "ModalOverlay",
	Size = UDim2.new(1,0,1,0),
	Position = UDim2.new(0,0,0,0),
	BackgroundColor3 = PANEL_COLOR,
	BackgroundTransparency = 0.0,
	ZIndex = 900,
	Visible = false,
	Active = true,
})
new("UICorner", {Parent = overlay, CornerRadius = UDim.new(0,0)})

-- Painel "flutuante" inicial (draggable)
local panel = new("Frame", {
	Parent = screenGui,
	Name = "Panel",
	Size = UDim2.new(0, WINDOW_W, 0, WINDOW_H),
	Position = UDim2.new(0.5, -WINDOW_W/2, 0.5, -WINDOW_H/2),
	BackgroundColor3 = PANEL_COLOR,
	BorderSizePixel = 0,
	AnchorPoint = Vector2.new(0.5,0.5),
	ZIndex = 850,
	Active = true,
})
new("UICorner", {Parent = panel, CornerRadius = UDim.new(0,14)})
new("UIStroke", {Parent = panel, Color = STROKE_BLUE, Thickness = 3, Transparency = 0})

-- Drop shadow frame (subtle)
local shadow = new("Frame", {
	Parent = screenGui,
	Name = "PanelShadow",
	Size = panel.Size,
	Position = panel.Position,
	BackgroundColor3 = Color3.fromRGB(0,0,0),
	BackgroundTransparency = 0.8,
	ZIndex = 840,
})
new("UICorner", {Parent = shadow, CornerRadius = UDim.new(0,16)})

-- Content container para centralização
local content = new("Frame", {
	Parent = panel,
	Size = UDim2.new(1, -36, 1, -36),
	Position = UDim2.new(0, 18, 0, 18),
	BackgroundTransparency = 1,
})
local uiLayout = new("UIListLayout", {
	Parent = content,
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0,10),
})

-- Greeting - centralizado e bonito
local greeting = new("TextLabel", {
	Parent = content,
	Size = UDim2.new(1, 0, 0, 36),
	BackgroundTransparency = 1,
	Text = "Olá, " .. (player.DisplayName ~= "" and player.DisplayName or player.Name),
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.GothamBold,
	TextSize = 22,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Center,
	ZIndex = 860,
})

-- Subtitulo pequeno
local subtitle = new("TextLabel", {
	Parent = content,
	Size = UDim2.new(1, 0, 0, 18),
	BackgroundTransparency = 1,
	Text = "Clique em 'Puxar jogadores' para simular",
	TextColor3 = Color3.fromRGB(180,180,190),
	Font = Enum.Font.Gotham,
	TextSize = 14,
	TextXAlignment = Enum.TextXAlignment.Center,
	ZIndex = 860,
})

-- Botões container
local btnContainer = new("Frame", {
	Parent = content,
	Size = UDim2.new(1, 0, 0, 64),
	BackgroundTransparency = 1,
})
local btnLayout = new("UIListLayout", {
	Parent = btnContainer,
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0,16),
})

-- Botões
local puxarBtn = new("TextButton", {
	Parent = btnContainer,
	Name = "PuxarBtn",
	Size = UDim2.new(0, 240, 0, 48),
	BackgroundColor3 = BUTTON_GREEN,
	Text = "Puxar jogadores",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	ZIndex = 870,
	AutoButtonColor = true,
})
new("UICorner", {Parent = puxarBtn, CornerRadius = UDim.new(0,10)})
new("UIStroke", {Parent = puxarBtn, Color = STROKE_BLUE, Thickness = 1, Transparency = 0.4})

local cancelBtn = new("TextButton", {
	Parent = btnContainer,
	Name = "CancelBtn",
	Size = UDim2.new(0, 120, 0, 48),
	BackgroundColor3 = BUTTON_RED,
	Text = "Fechar",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	ZIndex = 870,
	AutoButtonColor = true,
})
new("UICorner", {Parent = cancelBtn, CornerRadius = UDim.new(0,10)})

-- Fullscreen content (dentro do overlay) - criado dentro de overlay para garantir bloqueio
local fsContainer = new("Frame", {
	Parent = overlay,
	Name = "FullScreenContainer",
	Size = UDim2.new(1,0,1,0),
	Position = UDim2.new(0,0,0,0),
	BackgroundTransparency = 1,
	ZIndex = 905,
	Visible = false,
	Active = true,
})

-- Centro do fullscreen
local fsCenter = new("Frame", {
	Parent = fsContainer,
	Size = UDim2.new(0.8, 0, 0.7, 0),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
})
local fsLayout = new("UIListLayout", {
	Parent = fsCenter,
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0,12),
})

local fsTitle = new("TextLabel", {
	Parent = fsCenter,
	Size = UDim2.new(1,0,0,64),
	BackgroundTransparency = 1,
	Text = "Cole o link do servidor privado que deseja",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.GothamBold,
	TextSize = 24,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Center,
})

local inputBox = new("TextBox", {
	Parent = fsCenter,
	Name = "ServerLinkBox",
	Size = UDim2.new(0.85,0,0,44),
	BackgroundColor3 = Color3.fromRGB(245,245,245),
	Text = "",
	PlaceholderText = "Cole o link do servidor aqui",
	TextColor3 = Color3.fromRGB(20,20,20),
	Font = Enum.Font.Gotham,
	TextSize = 18,
	ClearTextOnFocus = false,
})
new("UICorner", {Parent = inputBox, CornerRadius = UDim.new(0,8)})
new("UIStroke", {Parent = inputBox, Color = Color3.fromRGB(200,200,200), Thickness = 1, Transparency = 0.6})

local puxarServerBtn = new("TextButton", {
	Parent = fsCenter,
	Name = "PuxarServerBtn",
	Size = UDim2.new(0, 200, 0, 46),
	BackgroundColor3 = BUTTON_GREEN,
	Text = "Puxar player",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	AutoButtonColor = true,
})
new("UICorner", {Parent = puxarServerBtn, CornerRadius = UDim.new(0,10)})
new("UIStroke", {Parent = puxarServerBtn, Color = STROKE_BLUE, Thickness = 1, Transparency = 0.4})

-- Progress elements
local progressHolder = new("Frame", {
	Parent = fsCenter,
	Name = "ProgressHolder",
	Size = UDim2.new(0.85,0,0,120),
	BackgroundTransparency = 1,
	Visible = false,
})
local pt = new("TextLabel", {
	Parent = progressHolder,
	Size = UDim2.new(1,0,0,28),
	Position = UDim2.new(0,0,0,0),
	BackgroundTransparency = 1,
	Text = "PROCURANDO PLAYER",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.GothamBold,
	TextSize = 20,
	TextXAlignment = Enum.TextXAlignment.Center,
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
})
local barBg = new("Frame", {
	Parent = progressHolder,
	Size = UDim2.new(1,0,0,18),
	Position = UDim2.new(0,0,0,56),
	BackgroundColor3 = Color3.fromRGB(45,45,45),
})
new("UICorner", {Parent = barBg, CornerRadius = UDim.new(0,8)})
local barFill = new("Frame", {
	Parent = barBg,
	Size = UDim2.new(0,0,1,0),
	BackgroundColor3 = Color3.fromRGB(80,220,140),
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
})

local finishBtn = new("TextButton", {
	Parent = fsCenter,
	Name = "FinishBtn",
	Size = UDim2.new(0,140,0,44),
	BackgroundColor3 = BUTTON_RED,
	Text = "Fechar",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	Visible = false,
})
new("UICorner", {Parent = finishBtn, CornerRadius = UDim.new(0,10)})

-- Estado
local expanded = false

-- Função utilitária: esconde tudo exceto os especificados (lista de objetos)
local function hideAllExcept(root, exceptions)
	local exceptSet = {}
	for _,v in ipairs(exceptions or {}) do exceptSet[v] = true end
	for _,obj in ipairs(root:GetDescendants()) do
		if obj:IsA("GuiObject") and obj ~= root and not exceptSet[obj] then
			pcall(function() obj.Visible = false end)
		end
	end
end

-- DRAG: torna o painel arrastável antes de expandir
do
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPos = nil

	local function update(input)
		local delta = input.Position - dragStart
		panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		shadow.Position = panel.Position
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

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging and not expanded then
			update(input)
		end
	end)
end

-- Expande para fullscreen: mostra overlay e centraliza fsContainer
local function expandToFullscreen()
	if expanded then return end
	expanded = true

	-- Bring overlay visible to block everything; set panel to full and match overlay color
	overlay.Visible = true
	fsContainer.Visible = true

	-- ensure panel & shadow on top of overlay
	panel.ZIndex = 910
	shadow.ZIndex = 909
	overlay.ZIndex = 900

	-- Tween panel to full screen (overlay already covers entire screen)
	TweenService:Create(panel, TweenInfo.new(EXPAND_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.new(1,0,1,0),
		Position = UDim2.new(0,0,0,0),
		AnchorPoint = Vector2.new(0,0),
	}):Play()
	TweenService:Create(shadow, TweenInfo.new(EXPAND_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.new(1,0,1,0),
		Position = UDim2.new(0,0,0,0),
		AnchorPoint = Vector2.new(0,0),
	}):Play()

	-- Mute local sounds
	pcall(function() SoundService.Volume = 0 end)
end

-- Progress animation
local function startProgressSequence()
	-- hide input area, show progress
	inputBox.Visible = false
	puxarServerBtn.Visible = false
	progressHolder.Visible = true
	fsTitle.Text = "Procurando player..."

	local startTime = tick()
	local conn
	conn = RunService.Heartbeat:Connect(function()
		local elapsed = tick() - startTime
		local pct = math.clamp(elapsed / LOAD_SECONDS, 0, 1)
		barFill.Size = UDim2.new(pct, 0, 1, 0)
		percentLabel.Text = string.format("%d%%", math.floor(pct*100))
		local dots = (math.floor(elapsed * 2) % 3) + 1
		dotsLabel.Text = string.rep(".", dots)
		if pct >= 1 then
			conn:Disconnect()
			wait(0.25)
			pt.Text = "PRONTO"
			dotsLabel.Text = ""
			finishBtn.Visible = true
		end
	end)
end

-- Eventos dos botões
puxarBtn.MouseButton1Click:Connect(function()
	-- pequena animação e expande
	TweenService:Create(puxarBtn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 252, 0, 52)}):Play()
	wait(0.12)
	TweenService:Create(puxarBtn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 240, 0, 48)}):Play()
	-- oculta o resto do pequeno painel para ficar limpo
	hideAllExcept(panel, {puxarBtn})
	wait(0.05)
	expandToFullscreen()
	-- mostrar elementos de fullscreen
	fsContainer.Visible = true
	fsTitle.Visible = true
	inputBox.Visible = true
	puxarServerBtn.Visible = true
	progressHolder.Visible = false
	finishBtn.Visible = false
end)

cancelBtn.MouseButton1Click:Connect(function()
	-- fecha imediatamente (restaura som caso esteja mutado)
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
		fsTitle.Text = "Cole um link antes de puxar"
		wait(1.0)
		fsTitle.Text = "Cole o link do servidor privado que deseja"
		return
	end

	-- Oculta qualquer coisa atrás e inicia a barra
	hideAllExcept(overlay, {fsContainer, progressHolder, barBg, barFill, percentLabel, dotsLabel, pt})
	startProgressSequence()
end)

finishBtn.MouseButton1Click:Connect(function()
	-- restore and close
	pcall(function() SoundService.Volume = originalVolume end)
	screenGui:Destroy()
end)

-- Ajuste inicial: posiciona sombra igual ao painel
shadow.Position = panel.Position
shadow.Size = panel.Size

-- Garante que o overlay capture cliques quando visível
overlay.InputBegan:Connect(function() end)

-- Inicializa visibilidades
fsContainer.Visible = false
progressHolder.Visible = false
finishBtn.Visible = false
