-- Полный сброс старых потоков при перезапуске
if _G.CoinFarmLoop then _G.CoinFarmLoop = false end
if _G.FarmConnection then _G.FarmConnection:Disconnect() end
task.wait(0.1)

-- Настройки чита
_G.CoinFarmLoop = false -- Изначально выключен, включение на кнопку P
local MIN_DIST_TO_MURDER = 35 -- Дистанция, ближе которой к Мардеру подлетать нельзя
local BASE_SPEED = 30
local MAX_SPEED = 75
local ACCELERATION = 3.5

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local currentSpeed = BASE_SPEED

local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- 1. Сквозь стены (Noclip) работает только когда автофарм активен
_G.FarmConnection = RunService.Stepped:Connect(function()
    if _G.CoinFarmLoop and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- 2. Функция поиска текущего Мардера на карте
local function getMurdererPosition()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            -- Проверяем наличие ножа в руках или в рюкзаке
            if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                local mRoot = p.Character:FindFirstChild("HumanoidRootPart")
                if mRoot then return mRoot.Position end
            end
        end
    end
    return nil
end

-- 3. Основной супер-быстрый цикл полета
task.spawn(function()
    while true do
        RunService.Heartbeat:Wait() -- Частота обновления каждый кадр (без задержек)
        
        if _G.CoinFarmLoop then
            local root = getHRP()
            if root then
                local closestCoin = nil
                local shortestDistance = math.huge
                local murderPos = getMurdererPosition()
                
                -- Быстро ищем все монеты на карте
                local container = Workspace:FindFirstChild("CoinContainer", true)
                local targets = container and container:GetChildren() or Workspace:GetDescendants()
                
                for _, obj in pairs(targets) do
                    local isCoin = (obj.Name == "Coin_Server") or (obj.Name:find("Coin") and obj:IsA("BasePart") and obj.Transparency < 1)
                    
                    if isCoin and obj.Parent then
                        local distToCoin = (obj.Position - root.Position).Magnitude
                        
                        -- Проверка безопасности: не стоит ли рядом Мардер?
                        local isSafe = true
                        if murderPos then
                            local distToMurder = (obj.Position - murderPos).Magnitude
                            if distToMurder < MIN_DIST_TO_MURDER then
                                isSafe = false -- Монета слишком опасная, игнорируем
                            end
                        end
                        
                        if isSafe and distToCoin < shortestDistance then
                            shortestDistance = distToCoin
                            closestCoin = obj
                        end
                    end
                end
                
                -- Полет к выбранной безопасной монете
                if closestCoin and closestCoin.Parent then
                    local targetPos = closestCoin.Position
                    local direction = (targetPos - root.Position).Unit
                    
                    -- Моментальный пересчет скорости без тормозов на полпути
                    if currentSpeed < MAX_SPEED then
                        currentSpeed = currentSpeed + ACCELERATION
                    end
                    
                    root.Velocity = direction * currentSpeed
                    
                    -- Мгновенное телепортирование в микро-радиусе для подбора
                    if (targetPos - root.Position).Magnitude < 4 then
                        root.CFrame = CFrame.new(targetPos)
                    end
                else
                    -- Если безопасных монет нет или все собрали — зависаем в воздухе
                    root.Velocity = Vector3.new(0, 0, 0)
                    currentSpeed = BASE_SPEED
                end
            end
        end
    end
end)

-- 4. Отслеживание нажатия кнопки для включения/выключения
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.P then
        _G.CoinFarmLoop = not _G.CoinFarmLoop
        if _G.CoinFarmLoop then
            print("🟢 АВТОФАРМ ВКЛЮЧЕН (Кнопка P)")
            currentSpeed = BASE_SPEED
        else
            print("🔴 АВТОФАРМ ВЫКЛЮЧЕН (Кнопка P)")
            local root = getHRP()
            if root then root.Velocity = Vector3.new(0, 0, 0) end
        end
    end
end)

print("⌨️ Скрипт загружен! Нажми английскую клавишу [ P ] для включения или выключения автофарма.")
