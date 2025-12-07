-- SimulacaoUI_LocalScript.lua
-- Atenção: este script é APENAS uma simulação cliente-side.
-- NÃO realiza nenhuma ação sobre outros jogadores nem tenta "roubar" ou afetar servidores.
-- Use isto para aprender e para criar uma UI/efeito de roleplay seguro.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Configurações
local WINDOW_SIZE = UDim2.new(0, 420, 0, 260)
local ANIM_TIME = 0.5
local LOAD_SECONDS = 30 -- tempo total da "busca"

-- Cores (aproximações)
local BG_COLOR = Color3.fromRGB(84, 104, 120) -- cinza azulado
local STROKE_COLOR = Color3.fromRGB(64, 154, 140) -- verde água
local BUTTON_GREEN = Color3.fromRGB(220, 245, 235) -- verde claro meio branco
local BUTTON_TEXT_COLOR = Color3.fromRGB(255,255,255)

-- Helper: cria objetos com propriedades
local function new(className, props)
	local obj = Instance.new(className)
	for k,v in pairs(props or {}) do
		if k == "Parent" then
			obj.Parent = v
		else
			obj[k] = v
		end
	end
	return obj
end

-- Limpa UI anterior similar
for _, child in ipairs(playerGui:GetChildren()) do
	if child.Name == "SimulacaoUI_ScreenGui" then
		child:Destroy()
	end
end

local screenGui = new("ScreenGui", {Parent = playerGui, Name = "SimulacaoUI_ScreenGui", ResetOnSpawn = false})

-- Painel central pequeno
local panel = new("Frame", {
	Parent = screenGui,
	Name = "Panel",
	Size = WINDOW_SIZE,
	Position = UDim2.new(0.5, -WINDOW_SIZE.X.Offset/2, 0.25, 0),
	AnchorPoint = Vector2.new(0,0),
	BackgroundColor3 = BG_COLOR,
	BorderSizePixel = 0,
	Active = true,
})
local uistroke = new("UIStroke", {
	Parent = panel,
	Color = STROKE_COLOR,
	Thickness = 3,
})

local corner = new("UICorner", {Parent = panel, CornerRadius = UDim.new(0,10)})

-- Greeting text
local greeting = new("TextLabel", {
	Parent = panel,
	Name = "Greeting",
	Size = UDim2.new(1, -20, 0, 50),
	Position = UDim2.new(0, 10, 0, 10),
	BackgroundTransparency = 1,
	Text = "Olá, " .. (player.DisplayName ~= "" and player.DisplayName or player.Name),
	TextColor3 = Color3.fromRGB(255,255,255),
	Font = Enum.Font.SourceSansBold,
	TextSize = 24,
	TextXAlignment = Enum.TextXAlignment.Center,
})

-- Button "Puxar jogadores (simulado)"
local puxarBtn = new("TextButton", {
	Parent = panel,
	Name = "PuxarBtn",
	Size = UDim2.new(0.6, 0, 0, 48),
	Position = UDim2.new(0.5, -0.6*WINDOW_SIZE.X.Offset/2, 0, 120),
	BackgroundColor3 = BUTTON_GREEN,
	TextColor3 = BUTTON_TEXT_COLOR,
	Font = Enum.Font.SourceSansBold,
	TextSize = 20,
	Text = "Puxar jogadores (simulado)",
	AutoButtonColor = true,
})
local btnCorner = new("UICorner", {Parent = puxarBtn, CornerRadius = UDim.new(0,8)})

-- Função para animar o painel para fullscreen
local originalVolume = SoundService.Volume

local function expandToFullScreen()
	-- esconde botões/itens primeiro via tween de transparencia
	for _, child in ipairs(panel:GetChildren()) do
		if child:IsA("GuiObject") and child ~= panel then
			local t = TweenService:Create(child, TweenInfo.new(0.25), {BackgroundTransparency = 1, TextTransparency = 1, ImageTransparency = 1})
			pcall(function() t:Play() end)
		end
	end

	wait(ANIM_TIME)

	-- Tween para fullscreen
	local tween = TweenService:Create(panel, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.new(1,0,1,0),
		Position = UDim2.new(0,0,0,0),
	})
	tween:Play()
	tween.Completed:Wait()

	-- reduzir volume local do cliente (simulado)
	pcall(function() SoundService.Volume = 0 end)
end

-- Tela cheia: conteúdo
local fullContainer = new("Frame", {
	Parent = panel,
	Name = "FullContainer",
	Size = UDim2.new(1,0,1,0),
	Position = UDim2.new(0,0,0,0),
	BackgroundTransparency = 1,
	ZIndex = 2,
})

local bigTitle = new("TextLabel", {
	Parent = fullContainer,
	Name = "BigTitle",
	Size = UDim2.new(1,0,0,80),
	Position = UDim2.new(0,0,0,20),
	BackgroundTransparency = 1,
	Text = "",
	TextColor3 = Color3.fromRGB(255,255,255),
	Font = Enum.Font.SourceSansBold,
	TextSize = 28,
	TextYAlignment = Enum.TextYAlignment.Top,
	TextXAlignment = Enum.TextXAlignment.Center,
})

-- Lista simulada de "brainrots"
local listFrame = new("Frame", {
	Parent = fullContainer,
	Name = "ListFrame",
	Size = UDim2.new(0.6, 0, 0.45, 0),
	Position = UDim2.new(0.2, 0, 0.18, 0),
	BackgroundTransparency = 0.4,
	BackgroundColor3 = Color3.fromRGB(20,20,20),
})
new("UICorner", {Parent = listFrame, CornerRadius = UDim.new(0,8)})
local listLayout = new("UIListLayout", {Parent = listFrame, Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder})

-- Simulação de nomes (falsos)
local simulatedNames = {
	"brainrot_azul",
	"brainrot_7",
	"player_simulado01",
	"enemyfax",
	"avatar_fake_a"
}
-- cria labels
local function populateSimulatedList(names)
	for _, v in ipairs(names) do
		local lbl = new("TextLabel", {
			Parent = listFrame,
			Size = UDim2.new(1, -12, 0, 36),
			BackgroundTransparency = 1,
			Text = "• " .. v,
			TextColor3 = Color3.fromRGB(255,255,255),
			Font = Enum.Font.SourceSans,
			TextSize = 20,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
	end
end

-- Buttons Sim / Nao
local btnYes = new("TextButton", {
	Parent = fullContainer,
	Name = "YesBtn",
	Size = UDim2.new(0,140,0,48),
	Position = UDim2.new(0.25, 0, 0.68, 0),
	BackgroundColor3 = Color3.fromRGB(100,200,150),
	Text = "Sim",
	TextColor3 = Color3.fromRGB(255,255,255),
	Font = Enum.Font.SourceSansBold,
	TextSize = 20,
})
new("UICorner", {Parent = btnYes, CornerRadius = UDim.new(0,8)})

local btnNo = new("TextButton", {
	Parent = fullContainer,
	Name = "NoBtn",
	Size = UDim2.new(0,140,0,48),
	Position = UDim2.new(0.6, 0, 0.68, 0),
	BackgroundColor3 = Color3.fromRGB(200,80,80),
	Text = "Não",
	TextColor3 = Color3.fromRGB(255,255,255),
	Font = Enum.Font.SourceSansBold,
	TextSize = 20,
})
new("UICorner", {Parent = btnNo, CornerRadius = UDim.new(0,8)})

-- Area para confirmar servidor (aparece se "Sim")
local confirmFrame = new("Frame", {
	Parent = fullContainer,
	Name = "ConfirmFrame",
	Size = UDim2.new(0.6,0,0,120),
	Position = UDim2.new(0.2,0,0.78,0),
	BackgroundTransparency = 1,
	Visible = false,
})
local confirmTitle = new("TextLabel", {
	Parent = confirmFrame,
	Size = UDim2.new(1,0,0,28),
	Position = UDim2.new(0,0,0,0),
	BackgroundTransparency = 1,
	Text = "Estamos quase lá, você só precisa confirmar seu servidor",
	TextColor3 = Color3.fromRGB(255,255,255),
	Font = Enum.Font.SourceSansBold,
	TextSize = 18,
	TextWrapped = true,
})
local serverBox = new("TextBox", {
	Parent = confirmFrame,
	Size = UDim2.new(1,0,0,36),
	Position = UDim2.new(0,0,0,36),
	BackgroundColor3 = Color3.fromRGB(230,235,240),
	Text = "",
	PlaceholderText = "coloque o link do seu servidor aqui (simulação)",
	TextColor3 = Color3.fromRGB(30,30,30),
	Font = Enum.Font.SourceSans,
	TextSize = 18,
})
new("UICorner", {Parent = serverBox, CornerRadius = UDim.new(0,6)})
local prontoBtn = new("TextButton", {
	Parent = confirmFrame,
	Size = UDim2.new(0.3,0,0,36),
	Position = UDim2.new(0.7,0,0,36),
	BackgroundColor3 = Color3.fromRGB(100,200,150),
	Text = "Pronto!",
	TextColor3 = Color3.fromRGB(255,255,255),
	Font = Enum.Font.SourceSansBold,
	TextSize = 18,
})
new("UICorner", {Parent = prontoBtn, CornerRadius = UDim.new(0,6)})

-- Barra de carregamento (invisível até ativada)
local progressContainer = new("Frame", {
	Parent = fullContainer,
	Name = "ProgressContainer",
	Size = UDim2.new(0.6,0,0,80),
	Position = UDim2.new(0.2,0,0.78,0),
	BackgroundTransparency = 1,
	Visible = false,
})
local procTitle = new("TextLabel", {
	Parent = progressContainer,
	Size = UDim2.new(1,0,0,28),
	Position = UDim2.new(0,0,0,0),
	BackgroundTransparency = 1,
	Text = "Procurando",
	TextColor3 = Color3.fromRGB(255,255,255),
	Font = Enum.Font.SourceSansBold,
	TextSize = 20,
	TextXAlignment = Enum.TextXAlignment.Center,
})
local dotsLabel = new("TextLabel", {
	Parent = progressContainer,
	Size = UDim2.new(1,0,0,28),
	Position = UDim2.new(0,0,0,26),
	BackgroundTransparency = 1,
	Text = "",
	TextColor3 = Color3.fromRGB(255,255,255),
	Font = Enum.Font.SourceSans,
	TextSize = 20,
	TextXAlignment = Enum.TextXAlignment.Center,
})
local barBg = new("Frame", {
	Parent = progressContainer,
	Size = UDim2.new(1,0,0,18),
	Position = UDim2.new(0,0,0,54),
	BackgroundColor3 = Color3.fromRGB(50,50,50),
})
new("UICorner", {Parent = barBg, CornerRadius = UDim.new(0,6)})
local barFill = new("Frame", {
	Parent = barBg,
	Size = UDim2.new(0,0,1,0),
	Position = UDim2.new(0,0,0,0),
	BackgroundColor3 = Color3.fromRGB(120,220,130),
})
new("UICorner", {Parent = barFill, CornerRadius = UDim.new(0,6)})
local percentLabel = new("TextLabel", {
	Parent = progressContainer,
	Size = UDim2.new(1,0,0,20),
	Position = UDim2.new(0,0,0,76),
	BackgroundTransparency = 1,
	Text = "0%",
	TextColor3 = Color3.fromRGB(255,255,255),
	Font = Enum.Font.SourceSansBold,
	TextSize = 16,
	TextXAlignment = Enum.TextXAlignment.Center,
})

-- Area para perfis simulados (após carregar)
local profilesFrame = new("Frame", {
	Parent = fullContainer,
	Name = "Profiles",
	Size = UDim2.new(0.8,0,0.6,0),
	Position = UDim2.new(0.1,0,0.15,0),
	BackgroundTransparency = 1,
	Visible = false,
})
local profilesLayout = new("UIListLayout", {Parent = profilesFrame, Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder})

local function showProfilesSample()
	profilesFrame:ClearAllChildren()
	new("UIListLayout", {Parent = profilesFrame, Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder})
	local sample = {
		{nick = "usuario_azul", info = "puxando esse jogador..."},
		{nick = "fake_brainrot", info = "puxando esse jogador..."},
		{nick = "player_roleplay", info = "puxando esse jogador..."},
	}
	for i, p in ipairs(sample) do
		local row = new("Frame", {
			Parent = profilesFrame,
			Size = UDim2.new(1,0,0,64),
			BackgroundTransparency = 0.4,
			BackgroundColor3 = Color3.fromRGB(12,12,12),
		})
		new("UICorner", {Parent = row, CornerRadius = UDim.new(0,8)})
		local circle = new("Frame", {
			Parent = row,
			Size = UDim2.new(0,64,0,64),
			Position = UDim2.new(0,8,0,0),
			BackgroundColor3 = Color3.fromRGB(80,80,80),
		})
		new("UICorner", {Parent = circle, CornerRadius = UDim.new(1,32)})
		local nameLbl = new("TextLabel", {
			Parent = row,
			Size = UDim2.new(0.7, -16, 1, 0),
			Position = UDim2.new(0,80,0,0),
			BackgroundTransparency = 1,
			Text = p.nick,
			TextColor3 = Color3.fromRGB(255,255,255),
			Font = Enum.Font.SourceSansBold,
			TextSize = 20,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		local infoLbl = new("TextLabel", {
			Parent = row,
			Size = UDim2.new(0.3, -16, 1, 0),
			Position = UDim2.new(0.7,8,0,0),
			BackgroundTransparency = 1,
			Text = p.info,
			TextColor3 = Color3.fromRGB(200,200,200),
			Font = Enum.Font.SourceSans,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Right,
		})
	end
end

-- Botão final de "Roubar agora" (mas será ação simulada / encerra)
local finalBtn = new("TextButton", {
	Parent = fullContainer,
	Name = "FinalBtn",
	Size = UDim2.new(0,180,0,48),
	Position = UDim2.new(0.5, -90, 0.85, 0),
	BackgroundColor3 = Color3.fromRGB(100,200,150),
	Text = "Roubar agora (simulado)",
	TextColor3 = Color3.fromRGB(255,255,255),
	Font = Enum.Font.SourceSansBold,
	TextSize = 20,
	Visible = false,
})
new("UICorner", {Parent = finalBtn, CornerRadius = UDim.new(0,8)})

-- Lógica dos eventos
puxarBtn.MouseButton1Click:Connect(function()
	-- Expande e mostra lista
	expandToFullScreen()
	wait(0.2)
	bigTitle.Text = "Esses são os seus brainrot (simulado):"
	populateSimulatedList(simulatedNames)
	-- mostra botões
	btnYes.Visible = true
	btnNo.Visible = true
	listFrame.Visible = true
end)

btnNo.MouseButton1Click:Connect(function()
	-- fecha a UI e restaura volume
	pcall(function() SoundService.Volume = originalVolume end)
	screenGui:Destroy()
end)

btnYes.MouseButton1Click:Connect(function()
	-- mostra area de confirmacao
	confirmFrame.Visible = true
	btnYes.Visible = false
	btnNo.Visible = false
end)

prontoBtn.MouseButton1Click:Connect(function()
	-- inicia busca com barra de 30s (simulado)
	confirmFrame.Visible = false
	progressContainer.Visible = true
	local start = tick()
	local finished = false

	-- animação dos pontos
	local dotConn
	dotConn = RunService.Heartbeat:Connect(function()
		local elapsed = tick() - start
		local pct = math.clamp(elapsed / LOAD_SECONDS, 0, 1)
		barFill.Size = UDim2.new(pct, 0, 1, 0)
		percentLabel.Text = string.format("%d%%", math.floor(pct*100))
		-- dots anim
		local dots = math.floor(elapsed*2) % 3 + 1
		local dotStr = string.rep(".", dots)
		dotsLabel.Text = dotStr
		if pct >= 1 then
			finished = true
			dotConn:Disconnect()
			-- prossegue apos pequeno delay
			wait(0.3)
			progressContainer.Visible = false
			-- mostra perfis simulados
			showProfilesSample()
			profilesFrame.Visible = true
			finalBtn.Visible = true
		end
	end)
end)

-- contagem "puxando esse jogador..." e mensagem final
local function playPullingSequence()
	-- simula 3..2..1 com textos em cada profile
	for i = 3,1,-1 do
		for _, lbl in ipairs(profilesFrame:GetChildren()) do
			if lbl:IsA("Frame") then
				for _, ch in ipairs(lbl:GetChildren()) do
					if ch:IsA("TextLabel") and ch.Text:find("puxando") then
						ch.Text = "puxando esse jogador... " .. tostring(i)
					end
				end
			end
		end
		wait(1)
	end
	-- após 3 segundos finais
	for _, lbl in ipairs(profilesFrame:GetChildren()) do
		if lbl:IsA("Frame") then
			for _, ch in ipairs(lbl:GetChildren()) do
				if ch:IsA("TextLabel") and ch.Text:find("puxando") then
					ch.Text = "Pronto jogador puxado (simulado)"
				end
			end
		end
	end
end

finalBtn.MouseButton1Click:Connect(function()
	-- inicia a sequencia (simulada)
	finalBtn.Visible = false
	playPullingSequence()
	wait(1)
	-- fecha tudo e restaura audio
	pcall(function() SoundService.Volume = originalVolume end)
	screenGui:Destroy()
end)

-- Inicialmente alguns elementos invisiveis
listFrame.Visible = false
btnYes.Visible = false
btnNo.Visible = false
confirmFrame.Visible = false
progressContainer.Visible = false
profilesFrame.Visible = false
finalBtn.Visible = false

-- Pequena instrução que é apenas cliente
local infoLabel = new("TextLabel", {
	Parent = panel,
	Size = UDim2.new(1, -20, 0, 18),
	Position = UDim2.new(0,10,1,-28),
	BackgroundTransparency = 1,
	Text = "Esta é uma simulação local — não afeta outros jogadores.",
	TextColor3 = Color3.fromRGB(200,200,200),
	Font = Enum.Font.SourceSans,
	TextSize = 14,
	TextXAlignment = Enum.TextXAlignment.Center,
})

-- Fim do script
