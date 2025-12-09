-- Criar ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "PainelFull"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Fundo expansível
local frame = Instance.new("Frame")
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
frame.Size = UDim2.new(0,0,0,0)
frame.Position = UDim2.new(0.5,0,0.5,0)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.Parent = gui

-- Borda RGB
local border = Instance.new("UIStroke")
border.Thickness = 6
border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
border.Parent = frame

-- Título AUTO PULL
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0.2,0)
title.Position = UDim2.new(0,0,0.1,0)
title.BackgroundTransparency = 1
title.Text = "AUTO PULL"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBlack
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

-- Animação RGB
task.spawn(function()
    while true do
        for i = 0, 360 do
            border.Color = Color3.fromHSV(i/360,1,1)
            task.wait(0.02)
        end
    end
end)

-- Ação do botão COMEÇAR (versão segura)
botao.MouseButton1Click:Connect(function()
    print("Painel iniciado!")
end)
