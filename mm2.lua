if _G.CoinFarmLoop then _G.CoinFarmLoop = false end
task.wait(0.2)

_G.CoinFarmLoop = true

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- 1. НАСТОЯЩИЙ NOCLIP (Сквозь любые текстуры без застреваний)
RunService.Stepped:Connect(function()
    if _G.CoinFarmLoop and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then 
                part.CanCollide = false 
            end
        end
    end
end)

local currentSpeed = 25
local maxSpeed = 65
local acceleration = 2.0

-- 2. УМНЫЙ ЦИКЛ СБОРА С ПРОВЕРКОЙ НА ИСЧЕЗНОВЕНИЕ
task.spawn(function()
    print("🚀 Умный автофарм запущен!")
    
    while _G.CoinFarmLoop do
        task.wait(0.03)
        local root = getHRP()
        
        if root then
            local closestCoin = nil
            local shortestDistance = math.huge
            
            -- Ищем контейнер монет MM2
            local container = Workspace:FindFirstChild("CoinContainer", true)
            
            if container then
                -- Перебираем только реальные, живые серверные монеты
                for _, coin in pairs(container:GetChildren()) do
                    if coin.Name == "Coin_Server" and coin:IsA("BasePart") then
                        local distance = (coin.Position - root.Position).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestCoin = coin
                        end
                    end
                end
            end
            
            -- Если в контейнере пусто, ищем обычным перебором (на случай кастомных карт)
            if not closestCoin then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name:find("Coin") and obj:IsA("BasePart") and obj.Parent then
                        -- Проверяем, что монета не прозрачная (её не подобрали)
                        if obj.Transparency < 1 then
                            local distance = (obj.Position - root.Position).Magnitude
                            if distance < shortestDistance then
                                shortestDistance = distance
                                closestCoin = obj
                            end
                        end
                    end
                end
            end
            
            -- Полет к цели
            if closestCoin and closestCoin.Parent then
                local targetPos = closestCoin.Position
                local direction = (targetPos - root.Position).Unit
                
                if currentSpeed < maxSpeed then
                    currentSpeed = currentSpeed + acceleration
                end
                
                root.Velocity = direction * currentSpeed
                
                -- Если подлетели вплотную или монета резко исчезла
                if (targetPos - root.Position).Magnitude < 3.5 then
                    root.CFrame = CFrame.new(targetPos)
                    currentSpeed = 25
                    task.wait(0.02) -- микро-пауза для засчитывания сервером
                end
            else
                -- Если все монеты собрали другие игроки — плавно ждем новые
                root.Velocity = Vector3.new(0, 0, 0)
                currentSpeed = 25
            end
        end
    end
end)
