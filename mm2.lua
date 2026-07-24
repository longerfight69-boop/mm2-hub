-- Очищаем старые потоки, если скрипт запускается повторно
if _G.CoinFarmLoop then _G.CoinFarmLoop = false end
task.wait(0.2)

_G.CoinFarmLoop = true

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Функция безопасного получения торса персонажа
local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- 1. ДЕЛАЕМ ЧЕЛОВЕКА ПРИЗРАКОМ (Сквозь стены / Noclip)
RunService.Stepped:Connect(function()
    if _G.CoinFarmLoop and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then 
                part.CanCollide = false 
            end
        end
    end
end)

-- Настройки постепенного разгона
local currentSpeed = 20   -- Начальная скорость (чуть быстрее человека)
local maxSpeed = 55       -- Максимальная скорость разгона
local acceleration = 1.5   -- Сила постепенного ускорения

-- 2. ЦИКЛ СБОРА МОНЕТ С РАЗГОНОМ
task.spawn(function()
    print("🚀 Автофарм монет успешно запущен на Delta!")
    
    while _G.CoinFarmLoop do
        task.wait(0.05)
        local root = getHRP()
        
        if root then
            -- Ищем самую ближнюю монетку на карте
            local closestCoin = nil
            local shortestDistance = math.huge
            
            for _, obj in pairs(Workspace:GetDescendants()) do
                -- Проверяем оригинальный CoinContainer из MM2
                if obj.Name:find("Coin") and obj:IsA("BasePart") then
                    local distance = (obj.Position - root.Position).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestCoin = obj
                    end
                end
            end
            
            -- Если монетка найдена — плавно летим к ней
            if closestCoin then
                local targetPos = closestCoin.Position
                local direction = (targetPos - root.Position).Unit
                
                -- Постепенно увеличиваем скорость (разгон)
                if currentSpeed < maxSpeed then
                    currentSpeed = currentSpeed + acceleration
                end
                
                -- Двигаем персонажа с помощью Velocity (физический полет)
                root.Velocity = direction * currentSpeed
                
                -- Если подлетели вплотную, сбрасываем скорость для следующей монеты
                if (targetPos - root.Position).Magnitude < 2 then
                    root.CFrame = CFrame.new(targetPos)
                    currentSpeed = 20
                end
            else
                -- Если монет на карте пока нет — плавно тормозим, а не падаем
                root.Velocity = Vector3.new(0, 0, 0)
                currentSpeed = 20
            end
        end
    end
    print("🛑 Автофарм остановлен.")
end)
