-- FakePullSimulation_LocalScript.lua
-- AVISO: ESTE SCRIPT É TOTALMENTE FAKE / CLIENT-SIDE. 
-- Ele NÃO faz nada no servidor, NÃO puxa jogadores nem realiza requisições.
-- Use apenas para gravação de vídeo ou demonstração. Nunca publique isto como funcional.
-- Cole este LocalScript em StarterPlayerScripts ou em StarterGui como LocalScript.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configurações
local WINDOW_W = 440
local WINDOW_H = 260
local EXPAND_TIME = 0.6
local LOAD_SECONDS = 30 -- tempo que a barra leva para "procurar"
local BG_COLOR = Color3.fromRGB(84, 104, 120)       -- cinza azulado
local STROKE_COLOR = Color3.fromRGB(64, 154, 140)   -- verde água (stroke)
local BUTTON_GREEN = Color3.fromRGB(220, 245, 235)  -- botão verde claro meio branco
local BUTTON_GREEN_TEXT = Color3.fromRGB(255,255,255)
local BUTTON_RED = Color3.fromRGB(200,80,80)

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

local screenGui = new("ScreenGui", {Parent = playerGui, Name = "FakePullGUI", ResetOnSpawn = false})
local panel = new("Frame", {
	Parent = screenGui,
	Name = "Panel",
	Size = UDim2.new(0, WINDOW_W, 0, WINDOW_H),
	Position = UDim2.new(0.5, -WINDOW_W/2, 0.18, 0),
	BackgroundColor3 = BG_COLOR,
	BorderSizePixel = 0,
})
new("UICorner", {Parent = panel, CornerRadius = UDim.new(0,12)})
new("UIStroke", {Parent = panel, Color = STROKE_COLOR, Thickness = 3})

-- Greeting
local greeting = new("TextLabel", {
	Parent = panel,
	Size = UDim2.new(1, -30, 0, 48),
	Position = UDim2.new(0, 15, 0, 12),
	BackgroundTransparency = 1,
	Text = "Olá, " .. (player.DisplayName ~= "" and player.DisplayName or player.Name),
	TextColor3 = Color3.new(1,1,1),
	Font = Enum.Font.SourceSansBold,
	TextSize = 22,
	TextXAlignment = Enum.TextXAlignment.Center,
})
-- Small subtitle
new("TextLabel", {
	Parent = panel,
	Size = UDim2.new(1, -30, 0, 18),
	Position = UDim2.new(0, 15, 0, 58),
	BackgroundTransparency = 1,
	Text = "Simulação local — não afeta outros jogadores.",
	TextColor3 = Color3.fromRGB(200,200,200),
	Font = Enum.Font.SourceSans,
	TextSize = 14,
	TextXAlignment = Enum.TextXAlignment.Center,
})

-- Botão principal "Puxar jogadores"
local puxarBtn = new("TextButton", {
	Parent = panel,
	Name = "PuxarBtn",
	Size = UDim2.new(0, 260, 0, 48),
	Position = UDim2.new(0.5, -130, 0, 110),
	BackgroundColor3 = BUTTON_GREEN,
	Text = "Puxar jogadores",
	TextColor3 = BUTTON_GREEN_TEXT,
	Font = Enum.Font.SourceSansBold,
	TextSize = 20,
	AutoButtonColor = true,
})
new("UICorner", {Parent = puxarBtn, CornerRadius = UDim.new(0,10)})

-- Fullscreen container (invisível até a expansão)
local fullContainer = new("Frame", {
	Parent = panel,
	Name = "FullContainer",
	Size = UDim2.new(1,0,1,0),
	Position = UDim2.new(0,0,0,0),
	BackgroundTransparency = 1,
	ZIndex = 2,
	Visible = false,
})

-- When first button clicked: expand panel and show input for server link
local function expandToFullScreen()
	-- fade children out a bit for transition
	for _,child in ipairs(panel:GetChildren()) do
		if child:IsA("GuiObject") and child ~= panel then
			pcall(function() TweenService:Create(child, TweenInfo.new(0.2), {TextTransparency = 0.6, BackgroundTransparency = math.clamp(child.BackgroundTransparency + 0.3, 0, 1)}):Play() end)
		end
	end
	wait(0.25)
	-- expand panel to full screen
	local tween = TweenService:Create(panel, TweenInfo.new(EXPAND_TIME, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.new(1,0,1,0),
		Position = UDim2.new(0,0,0,0),
	})
	tween:Play()
	tween.Completed:Wait()
	-- show full container content
	fullContainer.Visible = true
end

-- Fullscreen UI elements
local bigTitle = new("TextLabel", {
	Parent = fullContainer,
	Size = UDim2.new(1,0,0,96),
	Position = UDim2.new(0,0,0,20),
	BackgroundTransparency = 1,
	Text = "Cole o link do servidor privado que deseja (simulado)",
	TextColor3 = Color3.new(1,1,1),
	Font = Enum.Font.SourceSansBold,
	TextSize = 26,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Center,
})

local inputBox = new("TextBox", {
	Parent = fullContainer,
	Name = "ServerLinkBox",
	Size = UDim2.new(0.7, 0, 0, 40),
	Position = UDim2.new(0.15, 0, 0, 140),
	BackgroundColor3 = Color3.fromRGB(245,245,245),
	Text = "",
	PlaceholderText = "Cole o link do servidor privado aqui (simulação)",
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
	Position = UDim2.new(0.5, -80, 0, 200),
	BackgroundColor3 = Color3.fromRGB(100,200,150),
	Text = "Puxar player",
	TextColor3 = Color3.fromRGB(255,255,255),
	Font = Enum.Font.SourceSansBold,
	TextSize = 20,
})
new("UICorner", {Parent = puxarServerBtn, CornerRadius = UDim.new(0,8)})

-- Progress UI (inicialmente invisível)
local progressContainer = new("Frame", {
	Parent = fullContainer,
	Name = "ProgressContainer",
	Size = UDim2.new(0.7,0,0,110),
	Position = UDim2.new(0.15,0,0,140),
	BackgroundTransparency = 1,
	Visible = false,
})
local procTitle = new("TextLabel", {
	Parent = progressContainer,
	Size = UDim2.new(1,0,0,28),
	Position = UDim2.new(0,0,0,0),
	BackgroundTransparency = 1,
	Text = "PROCURANDO PLAYER",
	TextColor3 = Color3.new(1,1,1),
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
	TextColor3 = Color3.new(1,1,1),
	Font = Enum.Font.SourceSans,
	TextSize = 20,
	TextXAlignment = Enum.TextXAlignment.Center,
})
local barBg = new("Frame", {
	Parent = progressContainer,
	Size = UDim2.new(1,0,0,18),
	Position = UDim2.new(0,0,0,56),
	BackgroundColor3 = Color3.fromRGB(50,50,50),
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
	TextColor3 = Color3.new(1,1,1),
	Font = Enum.Font.SourceSansBold,
	TextSize = 18,
	TextXAlignment = Enum.TextXAlignment.Center,
})

-- Close button after finish
local closeBtn = new("TextButton", {
	Parent = fullContainer,
	Name = "CloseBtn",
	Size = UDim2.new(0,120,0,40),
	Position = UDim2.new(0.5, -60, 1, -70),
	BackgroundColor3 = Color3.fromRGB(200,80,80),
	Text = "Fechar",
	TextColor3 = Color3.new(1,1,1),
	Font = Enum.Font.SourceSansBold,
	TextSize = 18,
	Visible = false,
})
new("UICorner", {Parent = closeBtn, CornerRadius = UDim.new(0,8)})

-- Functions for animations and flow
local function showProgressSequence()
	-- Hide input and show progress container
	inputBox.Visible = false
	puxarServerBtn.Visible = false
	progressContainer.Visible = true

	local startTime = tick()
	local conn
	conn = RunService.Heartbeat:Connect(function()
		local elapsed = tick() - startTime
		local pct = math.clamp(elapsed / LOAD_SECONDS, 0, 1)
		barFill.Size = UDim2.new(pct, 0, 1, 0)
		percentLabel.Text = string.format("%d%%", math.floor(pct*100))
		-- dots animation (cyclical)
		local dots = (math.floor(elapsed * 2) % 3) + 1
		dotsLabel.Text = string.rep(".", dots)
		if pct >= 1 then
			conn:Disconnect()
			wait(0.3)
			-- final state: keep progress at 100% and show finish message & close
			procTitle.Text = "PRONTO (simulado)"
			dotsLabel.Text = ""
			closeBtn.Visible = true
		end
	end)
end

-- Button actions
puxarBtn.MouseButton1Click:Connect(function()
	expandToFullScreen()
	-- make sure relevant elements visible
	fullContainer.Visible = true
	bigTitle.Text = "Cole o link do servidor privado que deseja (simulação)"
	inputBox.Visible = true
	puxarServerBtn.Visible = true
	progressContainer.Visible = false
	closeBtn.Visible = false
end)

puxarServerBtn.MouseButton1Click:Connect(function()
	local link = tostring(inputBox.Text or "")
	if link:match("^%s*$") then
		-- feedback simples: shake input and temporary hint
		local origPos = inputBox.Position
		for i=1,6 do
			local x = (i % 2 == 0) and 6 or -6
			TweenService:Create(inputBox, TweenInfo.new(0.04), {Position = UDim2.new(origPos.X.Scale, origPos.X.Offset + x, origPos.Y.Scale, origPos.Y.Offset)}):Play()
			wait(0.04)
		end
		inputBox.Position = origPos
		bigTitle.Text = "Cole um link antes de puxar (simulação)"
		wait(1.2)
		bigTitle.Text = "Cole o link do servidor privado que deseja (simulação)"
		return
	end

	-- Start the fake progress sequence
	showProgressSequence()
end)

closeBtn.MouseButton1Click:Connect(function()
	-- destroy GUI (end of fake flow)
	screenGui:Destroy()
end)

-- Initial visibility states are already set; finished.
