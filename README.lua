# GZIN.lua--[[
    GZIN HUB - Auto Farm para Sea 2 (Blox Fruits)
    Versão: 1.0
    Criado por: GZIN
    Descrição: Script de auto farm com interface moderna e minimalista.
]]

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Variáveis do jogador
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Estado do Auto Farm
local autoFarmActive = false
local currentEnemy = "Nenhum"
local currentMission = "Nenhuma"
local missionStatus = "Desativado"

-- Constantes do Sea 2 (ajuste conforme necessário)
local SEA2_QUESTS = {
    {levelMin = 700, levelMax = 874, npcName = "Swan", npcPos = Vector3.new(-567, 60, 452), enemyName = "Pirate", enemyPos = Vector3.new(-600, 60, 400)},
    {levelMin = 875, levelMax = 949, npcName = "Captain", npcPos = Vector3.new(-500, 60, 300), enemyName = "Marine", enemyPos = Vector3.new(-520, 60, 280)},
    {levelMin = 950, levelMax = 1049, npcName = "Bartilo", npcPos = Vector3.new(-400, 60, 200), enemyName = "Swan Pirate", enemyPos = Vector3.new(-420, 60, 180)},
    {levelMin = 1050, levelMax = 1149, npcName = "Don Swan", npcPos = Vector3.new(-350, 60, 150), enemyName = "Don Swan's Crew", enemyPos = Vector3.new(-370, 60, 130)},
    {levelMin = 1150, levelMax = 1249, npcName = "Wysper", npcPos = Vector3.new(-250, 60, 50), enemyName = "Wysper's Soldiers", enemyPos = Vector3.new(-270, 60, 30)},
    {levelMin = 1250, levelMax = 1349, npcName = "Zoro", npcPos = Vector3.new(-150, 60, -50), enemyName = "Zoro's Followers", enemyPos = Vector3.new(-170, 60, -70)},
    -- Adicione mais missões conforme necessário
}

-- =================== GUI ===================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GZIN_HUB"
screenGui.Parent = player.PlayerGui

-- Frame principal
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 350)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Draggable = false -- Será gerenciado manualmente
mainFrame.Parent = screenGui

-- Arredondamento e sombra
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local shadow = Instance.new("UIStroke")
shadow.Color = Color3.fromRGB(80, 60, 200)
shadow.Thickness = 1.5
shadow.Transparency = 0.5
shadow.Parent = mainFrame

-- Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "GZIN HUB"
titleLabel.TextColor3 = Color3.fromRGB(180, 140, 255)
titleLabel.TextSize = 22
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

-- Botão minimizar
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -40, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextSize = 20
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = minimizeBtn

-- Variável para estado minimizado
local isMinimized = false

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 400, 0, 50) or UDim2.new(0, 400, 0, 350)
    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize})
    tween:Play()
    minimizeBtn.Text = isMinimized and "+" or "−"
end)

-- Conteúdo (fica dentro de um frame para esconder quando minimizado)
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -50)
contentFrame.Position = UDim2.new(0, 0, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Toggle Auto Farm
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 120, 0, 40)
toggleBtn.Position = UDim2.new(0.5, -60, 0, 10)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
toggleBtn.Text = "LIGAR"
toggleBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
toggleBtn.TextSize = 16
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = contentFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 60)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Desativado"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = contentFrame

-- Inimigo atual
local enemyLabel = Instance.new("TextLabel")
enemyLabel.Size = UDim2.new(1, -20, 0, 30)
enemyLabel.Position = UDim2.new(0, 10, 0, 90)
enemyLabel.BackgroundTransparency = 1
enemyLabel.Text = "Inimigo: Nenhum"
enemyLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
enemyLabel.TextSize = 14
enemyLabel.Font = Enum.Font.Gotham
enemyLabel.TextXAlignment = Enum.TextXAlignment.Left
enemyLabel.Parent = contentFrame

-- Missão atual
local missionLabel = Instance.new("TextLabel")
missionLabel.Size = UDim2.new(1, -20, 0, 30)
missionLabel.Position = UDim2.new(0, 10, 0, 120)
missionLabel.BackgroundTransparency = 1
missionLabel.Text = "Missão: Nenhuma"
missionLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
missionLabel.TextSize = 14
missionLabel.Font = Enum.Font.Gotham
missionLabel.TextXAlignment = Enum.TextXAlignment.Left
missionLabel.Parent = contentFrame

-- =================== DRAG ===================
local dragging = false
local dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- =================== AUTO FARM LOGIC ===================

-- Função para obter a melhor missão baseada no nível
local function getBestQuest(level)
    local best = nil
    for _, quest in ipairs(SEA2_QUESTS) do
        if level >= quest.levelMin and level <= quest.levelMax then
            if not best or quest.levelMin > best.levelMin then
                best = quest
            end
        end
    end
    return best
end

-- Função para mover o jogador para uma posição
local function moveToPosition(targetPos)
    if not character or not rootPart then return end
    humanoid:MoveTo(targetPos)
    -- Aguardar até chegar perto (com timeout)
    local startTime = tick()
    while (rootPart.Position - targetPos).Magnitude > 5 do
        task.wait(0.1)
        if tick() - startTime > 10 then break end -- timeout
        if not autoFarmActive then break end
    end
end

-- Função para interagir com NPC (simular clique)
local function interactWithNPC(npcName)
    -- Procura o NPC pelo nome (exemplo simples)
    local npc = nil
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == npcName then
            npc = obj
            break
        end
    end
    if npc and npc:FindFirstChild("HumanoidRootPart") then
        moveToPosition(npc.HumanoidRootPart.Position + Vector3.new(0, 0, 3))
        -- Simula clique (ou interação)
        -- Aqui você pode usar VirtualInputManager para simular teclas ou mouse
        -- Por exemplo, para apertar E (interagir):
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.2)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        return true
    end
    return false
end

-- Função para atacar inimigos
local function attackEnemies(enemyName, enemyPos)
    -- Procura inimigos próximos
    local enemies = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == enemyName and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            local dist = (rootPart.Position - obj.HumanoidRootPart.Position).Magnitude
            if dist < 100 then -- raio de busca
                table.insert(enemies, obj)
            end
        end
    end
    if #enemies == 0 then
        -- Se não houver inimigos, mova para a posição de spawn
        moveToPosition(enemyPos)
        return false
    end
    -- Ataca o primeiro inimigo encontrado
    local target = enemies[1]
    local targetPart = target.HumanoidRootPart
    moveToPosition(targetPart.Position + Vector3.new(0, 0, 2))
    -- Simula ataque (por exemplo, apertar tecla de combate)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    -- Verifica se o inimigo está morto
    if target.Humanoid.Health <= 0 then
        return true
    end
    return false
end

-- Loop principal do Auto Farm
local function autoFarmLoop()
    while autoFarmActive do
        task.wait(0.5)
        -- Verifica se o personagem existe
        if not character or not character.Parent then
            character = player.CharacterAdded:Wait()
            humanoid = character:WaitForChild("Humanoid")
            rootPart = character:WaitForChild("HumanoidRootPart")
        end

        -- Obter nível do jogador
        local level = player.Data.Level.Value -- Ajuste conforme a localização real do nível
        if not level then
            statusLabel.Text = "Status: Nível não encontrado"
            continue
        end

        local quest = getBestQuest(level)
        if not quest then
            statusLabel.Text = "Status: Nenhuma missão disponível"
            continue
        end

        -- Atualiza interface
        currentMission = quest.npcName
        missionLabel.Text = "Missão: " .. currentMission
        statusLabel.Text = "Status: Ativado"

        -- Passo 1: Ir ao NPC de missão
        moveToPosition(quest.npcPos)
        -- Interagir para aceitar missão
        if interactWithNPC(quest.npcName) then
            currentEnemy = quest.enemyName
            enemyLabel.Text = "Inimigo: " .. currentEnemy
        end

        -- Passo 2: Ir para área de inimigos e farmar
        local missionCompleted = false
        while autoFarmActive and not missionCompleted do
            -- Verifica se a missão foi concluída (pode ser por contagem de kills ou outro sistema)
            -- Aqui usamos uma verificação simples: se não houver inimigos vivos, assume que completou
            local enemiesAlive = false
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name == quest.enemyName and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                    enemiesAlive = true
                    break
                end
            end
            if not enemiesAlive then
                missionCompleted = true
                break
            end

            -- Atacar
            attackEnemies(quest.enemyName, quest.enemyPos)
            task.wait(0.5)
        end

        -- Se completou, reinicia o ciclo
        if missionCompleted then
            statusLabel.Text = "Status: Missão concluída!"
            task.wait(1)
        end
    end
    -- Quando desativado
    statusLabel.Text = "Status: Desativado"
    enemyLabel.Text = "Inimigo: Nenhum"
    missionLabel.Text = "Missão: Nenhuma"
end

-- Toggle do Auto Farm
toggleBtn.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    toggleBtn.Text = autoFarmActive and "DESLIGAR" or "LIGAR"
    toggleBtn.BackgroundColor3 = autoFarmActive and Color3.fromRGB(90, 40, 120) or Color3.fromRGB(60, 60, 90)
    if autoFarmActive then
        task.spawn(autoFarmLoop)
    end
end)

-- =================== INICIALIZAÇÃO ===================
print("GZIN HUB carregado com sucesso!")
