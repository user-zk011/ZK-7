-- FakePull_NoWarning_LocalScript.lua
-- COLE ESTE LocalScript EM StarterPlayerScripts OU StarterGui
-- Este script é totalmente client-side: NÃO realiza nenhuma ação no servidor.
-- Ele apenas mostra uma interface local e animações para gravação.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configurações
local WINDOW_W = 440
local WINDOW_H = 260
local EXPAND_TIME = 0.6
local LOAD_SECONDS = 30 -- tempo que a barra leva para "procurar" (segundos)
local PANEL_COLOR = Color3.fromRGB(0,0,0)           -- painel preto
local STROKE_COLOR = Color3.fromRGB(140,200,255)    -- traço azul claro
local BUTTON_GREEN = Color3.fromRGB(100,200,150)    -- botão verde
local BUTTON_RED = Color3.fromRGB(200,80,80)        -- botão vermelho
local TEXT_COLOR = Color3.fromRGB(255,255,255)

-- Helpers
local function new(className, props)
	local obj = Instance.new(className)
	if props then
		for k,v in pairs(props) do
			if k == "Parent" then
				obj.Parent = v
			else
				obj[k] = v
			end
		end
	end
	return obj
end

-- Remove GUI antiga se existir
for _,child in ipairs(playerGui:GetChildren()) do
	if child.Name == "FakePullGUI" then child:Destroy() end
end

local screenGui = new("ScreenGui", {
	Parent = playerGui,
	Name = "FakePullGUI",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

-- Painel inicial (pequeno)
local panel = new("Frame", {
	Parent = screenGui,
	Name = "Panel",
	Size = UDim2.new(0, WINDOW_W, 0, WINDOW_H),
	Position = UDim2.new(0.5, -WINDOW_W/2, 0.5, -WINDOW_H/2),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = PANEL_COLOR,
	BorderSizePixel = 0,
	ZIndex = 50,
	Active = true, -- captura clique
})
new("UICorner", {Parent = panel, CornerRadius = UDim.new(0,12)})
new("UIStroke", {Parent = panel, Color = STROKE_COLOR, Thickness = 3})

-- Centraliza tudo verticalmente dentro do painel
local contentFrame = new("Frame", {
	Parent = panel,
	Size = UDim2.new(1, -40, 1, -40),
	Position = UDim2.new(0, 20, 0, 20),
	BackgroundTransparency = 1,
})
contentFrame.AnchorPoint = Vector2.new(0,0)

-- Greeting (centralizado)
local greeting = new("TextLabel", {
	Parent = contentFrame,
	Size = UDim2.new(1, 0, 0, 36),
	Position = UDim2.new(0, 0, 0, 10),
	BackgroundTransparency = 1,
	Text = "Olá, " .. (player.DisplayName ~= "" and player.DisplayName or player.Name),
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.SourceSansBold,
	TextSize = 22,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Center,
})
greeting.AnchorPoint = Vector2.new(0.5, 0)
greeting.Position = UDim2.new(0.5, 0, 0, 16)

-- Subtitle centralizado
local subtitle = new("TextLabel", {
	Parent = contentFrame,
	Size = UDim2.new(1, 0, 0, 18),
	Position = UDim2.new(0.5, 0, 0, 56),
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundTransparency = 1,
	Text = "",
	TextColor3 = Color3.fromRGB(200,200,200),
	Font = Enum.Font.SourceSans,
	TextSize = 14,
	TextXAlignment = Enum.TextXAlignment.Center,
})

-- Botão principal (centralizado)
local puxarBtn = new("TextButton", {
	Parent = contentFrame,
	Name = "PuxarBtn",
	Size = UDim2.new(0, 260, 0, 48),
	Position = UDim2.new(0.5, 0, 0.5, 10),
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundColor3 = BUTTON_GREEN,
	Text = "Puxar jogadores",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.SourceSansBold,
	TextSize = 20,
	AutoButtonColor = true,
})
new("UICorner", {Parent = puxarBtn, CornerRadius = UDim.new(0,10)})

-- Fullscreen elements container (invisível até expansão)
local fullContainer = new("Frame", {
	Parent = panel,
	Name = "FullContainer",
	Size = UDim2.new(1,0,1,0),
	Position = UDim2.new(0,0,0,0),
	BackgroundTransparency = 1,
	ZIndex = 55,
	Visible = false,
	Active = true,
})
fullContainer.AnchorPoint = Vector2.new(0,0)

-- Quando expandir, vamos de fato cobrir tudo e bloquear interações com elementos atrás
local originalVolume = SoundService.Volume

local function expandToFullScreen()
	-- hide small panel children (we'll show fullContainer content)
	for _, child in ipairs(contentFrame:GetChildren()) do
		if child ~= puxarBtn then
			child.Visible = false
		end
	end
	-- Tween to fullscreen and ensure opaque black covers entire screen
	local tween = TweenService:Create(panel, TweenInfo.new(EXPAND_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.new(1,0,1,0),
		Position = UDim2.new(0,0,0,0),
		AnchorPoint = Vector2.new(0,0),
	})
	tween:Play()
	tween.Completed:Wait()

	panel.BackgroundTransparency = 0
	panel.Active = true
	panel.ZIndex = 100
	fullContainer.Visible = true

	-- Mute local sounds
	pcall(function() SoundService.Volume = 0 end)
end

-- Fullscreen UI (centralized)
local bigTitle = new("TextLabel", {
	Parent = fullContainer,
	Size = UDim2.new(0.9, 0, 0, 60),
	Position = UDim2.new(0.5, 0, 0.25, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Text = "Cole o link do servidor privado que deseja",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.SourceSansBold,
	TextSize = 24,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Center,
})

local inputBox = new("TextBox", {
	Parent = fullContainer,
	Name = "ServerLinkBox",
	Size = UDim2.new(0.7, 0, 0, 40),
	Position = UDim2.new(0.5, 0, 0.45, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Color3.fromRGB(245,245,245),
	Text = "",
	PlaceholderText = "Cole o link do servidor aqui",
	TextColor3 = Color3.fromRGB(20,20,20),
	Font = Enum.Font.SourceSans,
	TextSize = 18,
	ClearTextOnFocus = false,
})
new("UICorner", {Parent = inputBox, CornerRadius = UDim.new(0,8)})

local puxarServerBtn = new("TextButton", {
	Parent = fullContainer,
	Name = "PuxarServerBtn",
	Size = UDim2.new(0, 160, 0, 42),
	Position = UDim2.new(0.5, 0, 0.58, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = BUTTON_GREEN,
	Text = "Puxar player",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.SourceSansBold,
	TextSize = 20,
})
new("UICorner", {Parent = puxarServerBtn, CornerRadius = UDim.new(0,8)})

-- Progress UI (invisível até ativar)
local progressContainer = new("Frame", {
	Parent = fullContainer,
	Name = "ProgressContainer",
	Size = UDim2.new(0.7,0,0,110),
	Position = UDim2.new(0.5,0,0.5,0),
	AnchorPoint = Vector2.new(0.5,0.5),
	BackgroundTransparency = 1,
	Visible = false,
})
local procTitle = new("TextLabel", {
	Parent = progressContainer,
	Size = UDim2.new(1,0,0,28),
	Position = UDim2.new(0,0,0,0),
	BackgroundTransparency = 1,
	Text = "PROCURANDO PLAYER",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.SourceSansBold,
	TextSize = 20,
	TextXAlignment = Enum.TextXAlignment.Center,
})
local dotsLabel = new("TextLabel", {
	Parent = progressContainer,
	Size = UDim2.new(1,0,0,22),
	Position = UDim2.new(0,0,0,28),
	BackgroundTransparency = 1,
	Text = "",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.SourceSans,
	TextSize = 20,
	TextXAlignment = Enum.TextXAlignment.Center,
})
local barBg = new("Frame", {
	Parent = progressContainer,
	Size = UDim2.new(1,0,0,18),
	Position = UDim2.new(0,0,0,56),
	BackgroundColor3 = Color3.fromRGB(40,40,40),
})
new("UICorner", {Parent = barBg, CornerRadius = UDim.new(0,8)})
local barFill = new("Frame", {
	Parent = barBg,
	Size = UDim2.new(0,0,1,0),
	Position = UDim2.new(0,0,0,0),
	BackgroundColor3 = Color3.fromRGB(120,220,130),
})
new("UICorner", {Parent = barFill, CornerRadius = UDim.new(0,8)})
local percentLabel = new("TextLabel", {
	Parent = progressContainer,
	Size = UDim2.new(1,0,0,22),
	Position = UDim2.new(0,0,0,78),
	BackgroundTransparency = 1,
	Text = "0%",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.SourceSansBold,
	TextSize = 18,
	TextXAlignment = Enum.TextXAlignment.Center,
})

local closeBtn = new("TextButton", {
	Parent = fullContainer,
	Name = "CloseBtn",
	Size = UDim2.new(0,120,0,40),
	Position = UDim2.new(0.5, -60, 0.85, 0),
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundColor3 = BUTTON_RED,
	Text = "Fechar",
	TextColor3 = TEXT_COLOR,
	Font = Enum.Font.SourceSansBold,
	TextSize = 18,
	Visible = false,
})
new("UICorner", {Parent = closeBtn, CornerRadius = UDim.new(0,8)})

-- Utility: hide all clickable children except the one specified
local function hideAllExcept(root, exceptions)
	exceptions = exceptions or {}
	local exceptSet = {}
	for _,v in ipairs(exceptions) do exceptSet[v] = true end
	for _, child in ipairs(root:GetDescendants()) do
		if child:IsA("GuiObject") and child ~= root and not exceptSet[child] then
			pcall(function() child.Visible = false end)
		end
	end
end

-- Quando clicar no botão principal, expandir e mostrar input
puxarBtn.MouseButton1Click:Connect(function()
	-- oculta todo o restante do panel para evitar clique e visual poluído
	hideAllExcept(panel, {puxarBtn})
	expandToFullScreen()

	-- mostra os elementos necessários do fullscreen
	bigTitle.Visible = true
	inputBox.Visible = true
	puxarServerBtn.Visible = true
	progressContainer.Visible = false
	closeBtn.Visible = false
end)

-- Ao clicar em puxar no fullscreen: ocultar demais elementos e começar progresso
puxarServerBtn.MouseButton1Click:Connect(function()
	local text = tostring(inputBox.Text or "")
	if text:match("^%s*$") then
		-- pequeno feedback (shake)
		local origPos = inputBox.Position
		for i=1,6 do
			local x = (i % 2 == 0) and 6 or -6
			TweenService:Create(inputBox, TweenInfo.new(0.04), {Position = UDim2.new(origPos.X.Scale, origPos.X.Offset + x, origPos.Y.Scale, origPos.Y.Offset)}):Play()
			wait(0.04)
		end
		inputBox.Position = origPos
		bigTitle.Text = "Cole um link antes de puxar"
		wait(1.2)
		bigTitle.Text = "Cole o link do servidor privado que deseja"
		return
	end

	-- Oculta tudo exceto o progresso
	hideAllExcept(fullContainer, {progressContainer})
	inputBox.Visible = false
	puxarServerBtn.Visible = false
	bigTitle.Text = "Procurando player..."
	progressContainer.Visible = true

	-- Progress animation (LOAD_SECONDS)
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
			wait(0.2)
			procTitle.Text = "PRONTO"
			dotsLabel.Text = ""
			closeBtn.Visible = true
		end
	end)
end)

closeBtn.MouseButton1Click:Connect(function()
	-- restaura som e remove GUI
	pcall(function() SoundService.Volume = originalVolume end)
	screenGui:Destroy()
end)

-- Inicial: centraliza texto e garante visibilidades
greeting.Text = "Olá, " .. (player.DisplayName ~= "" and player.DisplayName or player.Name)
subtitle.Text = ""
puxarBtn.Visible = true
fullContainer.Visible = false
bigTitle.Visible = false
inputBox.Visible = false
puxarServerBtn.Visible = false
progressContainer.Visible = false
closeBtn.Visible = false

-- Garante que o painel capture todos os cliques quando estiver fullscreen
panel.Active = true
fullContainer.Active = true

-- Fim do script
