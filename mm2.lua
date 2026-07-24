-- Полная очистка прошлых запусков перед стартом
if _G.CoinFarmLoop then _G.CoinFarmLoop = false end
if _G.FarmConnection then _G.FarmConnection:Disconnect() end
task.wait(0.15)

-- Включаем скрипт сразу при инжекте (без нажатия кнопок)
_G.CoinFarmLoop = true 

local MIN_DIST_TO_MURDER = 30 -- Безопасное расстояние от убийцы
local BASE_SPEED = 25
local MAX_SPEED = 75
local ACCELERATION = 4.0

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local currentSpeed = BASE_SPEED

local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- 1. Абсолютный Noclip (пролет через текстуры)
_G.FarmConnection = RunService.Stepped:Connect(function()
    if _G.CoinFarmLoop and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- 2. Поиск позиции текущего Мардера
local function getMurdererPosition()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                local mRoot = p.Character:FindFirstChild("HumanoidRootPart")
                if mRoot then return mRoot.Position end
            end
        end
    end
    return nil
end

-- 3. Супер-быстрый цикл полета без задержек (каждый кадр)
task.spawn(function()
    print("🟢 АВТОФАРМ ЗАПУЩЕН НА DELTA!")
    
    while _G.CoinFarmLoop do
        RunService.Heartbeat:Wait()
        local root = getHRP()
        
        if root then
            local closestCoin = nil
            local shortestDistance = math.huge
            local murderPos = getMurdererPosition()
            
            -- Получаем список монет на карте
            local container = Workspace:FindFirstChild("CoinContainer", true)
            local targets = container and container:GetChildren() or Workspace:GetDescendants()
            
            for _, obj in pairs(targets) do
                local isCoin = (obj.Name == "Coin_Server") or (obj.Name:find("Coin") and obj:IsA("BasePart") and obj.Transparency < 1)
                
                if isCoin and obj.Parent then
                    local distToCoin = (obj.Position - root.Position).Magnitude
                    
                    -- Проверка: нет ли рядом Мардера
                    local isSafe = true
                    if murderPos then
                        local distToMurder = (obj.Position - murderPos).Magnitude
                        if distToMurder < MIN_DIST_TO_MURDER then
                            isSafe = false -- Рядом убийца, монету брать нельзя
                        end
                    end
                    
                    if isSafe and distToCoin < shortestDistance then
                        shortestDistance = distToCoin
                        closestCoin = obj
                    end
                end
            end
            
            -- Логика движения к безопасной цели
            if closestCoin and closestCoin.Parent then
                local targetPos = closestCoin.Position
                local direction = (targetPos - root.Position).Unit
                
                -- Постепенное нарастание скорости
                if currentSpeed < MAX_SPEED then
                    currentSpeed = currentSpeed + ACCELERATION
                end
                
                root.Velocity = direction * currentSpeed
                
                -- Микро-телепорт для моментального подбора
                if (targetPos - root.Position).Magnitude < 4 then
                    root.CFrame = CFrame.new(targetPos)
                end
            else
                -- Если монет нет или они все караулятся Мардером — останавливаемся
                root.Velocity = Vector3.new(0, 0, 0)
                currentSpeed = BASE_SPEED
            end
        end
    end
    
    -- Полная остановка при выключении скрипта
    local root = getHRP()
    if root then root.Velocity = Vector3.new(0, 0, 0) end
    print("🔴 АВТОФАРМ ОСТАНОВЛЕН")
end)
