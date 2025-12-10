--== CONFIG ==--
local BORDA_ESPESSURA = 5 -- px

--== CRIA GUI ==--
local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 999999 -- Sempre no topo
gui.Parent = player:WaitForChild("PlayerGui")

-- Fundo expansível
local frame = Instance.new("Frame")
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
frame.Size = UDim2.new(0,0,0,0)
frame.Position = UDim2.new(0.5,0,0.5,0)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.ZIndex = 10
frame.Parent = gui

-- Borda RGB interna (5px para dentro)
local border = Instance.new("Frame")
border.Size = UDim2.new(1, -BORDA_ESPESSURA*2, 1, -BORDA_ESPESSURA*2)
border.Position = UDim2.new(0, BORDA_ESPESSURA, 0, BORDA_ESPESSURA)
border.BackgroundTransparency = 1
border.ZIndex = 11
border.Parent = frame

local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = BORDA_ESPESSURA
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiStroke.Parent = border

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0.2,0)
title.Position = UDim2.new(0,0,0.1,0)
title.BackgroundTransparency = 1
title.Text = "AUTO PULL"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBlack
title.ZIndex = 12
title.Parent = frame

-- Botão COMEÇAR
local botao = Instance.new("TextButton")
botao.Size = UDim2.new(0.4,0,0.15,0)
botao.Position = UDim2.new(0.3,0,0.6,0)
botao.BackgroundColor3 = Color3.fromRGB(20,220,60)
botao.Text = "COMEÇAR"
botao.TextColor3 = Color3.new(1,1,1)
botao.TextScaled = true
botao.Font = Enum.Font.GothamBlack
botao.ZIndex = 12
botao.Parent = frame
Instance.new("UICorner").Parent = botao

-- Animação de expansão
frame:TweenSize(
    UDim2.new(1,0,1,0),
    Enum.EasingDirection.Out,
    Enum.EasingStyle.Quad,
    0.5,
    true
)

-- ANIMAÇÃO RGB
task.spawn(function()
    while true do
        for h = 0, 360 do
            uiStroke.Color = Color3.fromHSV(h/360, 1, 1)
            task.wait(0.02)
        end
    end
end)

-- MUTAR SOM PERSONALIZADO DA EXPERIÊNCIA (SEGURO)
local function muteSounds()
    for _, snd in ipairs(workspace:GetDescendants()) do
        if snd:IsA("Sound") then
            snd.Playing = false
            snd.Volume = 0
        end
    end
end

local function restoreSounds()
    for _, snd in ipairs(workspace:GetDescendants()) do
        if snd:IsA("Sound") then
            snd.Volume = 1
        end
    end
end

-- AÇÃO DO BOTÃO
botao.MouseButton1Click:Connect(function()
    muteSounds()
    print("Início da brincadeira 😎")
end)
