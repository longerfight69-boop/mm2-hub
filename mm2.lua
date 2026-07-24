-- MM2 Ultimate Hub v7 (Fixed & Optimized)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

_G.Settings = {
    AutoGun = false,
    ESP = false,
    AntiFling = false,
    FlingAura = false,
    UnderMap = false,
    WallJump = false,
    AutoFarm = false,
    SelectedTarget = nil
}

-- Загрузка Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com", true))()

local Window = Fluent:CreateWindow({
    Title = "MM2 Ultimate Hub v7",
    SubTitle = "Исправленная версия",
    Size = UDim2.fromOffset(580, 520),
})

local Tabs = {
    Main = Window:AddTab({ Title = "Основные", Icon = "sliders" }),
    Combat = Window:AddTab({ Title = "Бой", Icon = "zap" }),
    Tele = Window:AddTab({ Title = "Телепорт", Icon = "move" }),
    Farm = Window:AddTab({ Title = "Фарм", Icon = "coin" })
}

local function getRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ==================== СЕРВИСЫ И ЦИКЛЫ ====================

-- ESP На Игроков
RunService.RenderStepped:Connect(function()
    if not _G.Settings.ESP then 
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("MM2ESP") then
                p.Character.MM2ESP:Destroy()
            end
        end
        return 
    end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        local hl = p.Character:FindFirstChild("MM2ESP") or Instance.new("Highlight")
        hl.Name = "MM2ESP"
        hl.FillTransparency = 0.4
        hl.OutlineTransparency = 0
        hl.Parent = p.Character
        
        if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
            hl.FillColor = Color3.fromRGB(255, 0, 0) -- Мардер (Красный)
        elseif p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
            hl.FillColor = Color3.fromRGB(0, 100, 255) -- Шериф (Синий)
        else
            hl.FillColor = Color3.fromRGB(0, 255, 0) -- Мирный (Зеленый)
        end
    end
end)

-- Авто-подбор пистолета (Auto Gun)
task.spawn(function()
    while task.wait(0.1) do
        if _G.Settings.AutoGun then
            local drop = Workspace:FindFirstChild("GunDrop")
            local root = getRoot()
            if drop and root then 
                root.CFrame = drop.CFrame 
            end
        end
    end
end)

-- Анти-Флинг и Флинг Аура
RunService.Stepped:Connect(function()
    local root = getRoot()
    if not root then return end
    
    if _G.Settings.AntiFling and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    if _G.Settings.FlingAura and _G.Settings.SelectedTarget then
        local target = Players:FindFirstChild(_G.Settings.SelectedTarget)
        if target and target.Character then
            local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if tRoot then
                local dist = (root.Position - tRoot.Position).Magnitude
                if dist < 9 then
                    root.RotVelocity = Vector3.new(0, 600000, 0)
                    root.Velocity = Vector3.new(root.Velocity.X * 0.5, 35, root.Velocity.Z * 0.5)
                end
            end
        end
    end
end)

-- ==================== НАСТРОЙКА ИНТЕРФЕЙСА ====================

-- Вкладка: Основные
Tabs.Main:AddToggle("Gun", {Title = "Авто GunDrop", Default = false}):OnChanged(function(v) _G.Settings.AutoGun = v end)
Tabs.Main:AddToggle("ESP", {Title = "ESP игроков", Default = false}):OnChanged(function(v) _G.Settings.ESP = v end)
Tabs.Main:AddToggle("AntiFling", {Title = "Анти-Флинг", Default = false}):OnChanged(function(v) _G.Settings.AntiFling = v end)

-- Вкладка: Телепорт
local dropdown = Tabs.Tele:AddDropdown("Target", {Title = "Выбрать цель", Values = {}, Multi = false})

local function updateDropdown()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    dropdown:SetValues(list)
end
Players.PlayerAdded:Connect(updateDropdown)
Players.PlayerRemoving:Connect(updateDropdown)
updateDropdown()

dropdown:OnChanged(function(v) _G.Settings.SelectedTarget = v end)

Tabs.Tele:AddButton({Title = "Телепорт к выбранному", Callback = function()
    if not _G.Settings.SelectedTarget then return end
    local target = Players:FindFirstChild(_G.Settings.SelectedTarget)
    local root = getRoot()
    if target and target.Character and root then
        local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if tRoot then root.CFrame = tRoot.CFrame + Vector3.new(0, 3, 0) end
    end
end})

-- Вкладка: Бой
Tabs.Combat:AddToggle("FlingAura", {Title = "Fling Aura на цель", Default = false}):OnChanged(function(v) _G.Settings.FlingAura = v end)

Tabs.Combat:AddButton({Title = "Kill All (За Мардера)", Callback = function()
    local knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
    local root = getRoot()
    if not knife or not root then return end
    
    local oldCFrame = root.CFrame
    knife.Parent = LocalPlayer.Character
    task.wait(0.2)
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            root.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, 1, 0)
            task.wait(0.1) -- увеличен таймаут для точности хита
            knife:Activate()
            task.wait(0.05)
        end
    end
    root.CFrame = oldCFrame
end})

Tabs.Combat:AddButton({Title = "Убить Мардера (За Шерифа)", Callback = function()
    local gun = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
    local root = getRoot()
    if not gun or not root then return end
    
    local oldCFrame = root.CFrame
    gun.Parent = LocalPlayer.Character
    task.wait(0.2)
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
            local t = p.Character.HumanoidRootPart
            root.CFrame = CFrame.lookAt(t.Position + Vector3.new(0, 5, 2), t.Position)
            task.wait(0.15)
            gun:Activate()
            break
        end
    end
    task.wait(0.2)
    root.CFrame = oldCFrame
end})

-- Вкладка: Фарм (Умный Плавный Автофарм)
Tabs.Farm:AddToggle("Farm", {Title = "АвтоФарм монет", Default = false}):OnChanged(function(v)
    _G.Settings.AutoFarm = v
    if v then
        task.spawn(function()
            while _G.Settings.AutoFarm do
                task.wait(0.05)
                local root = getRoot()
                if not root then continue end
                
                -- Ищем ближайшую монету
                local closestCoin = nil
                local shortestDist = math.huge
                
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name:find("Coin") and obj:IsA("BasePart") then
                        local dist = (obj.Position - root.Position).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            closestCoin = obj
                        end
                    end
                end
                
                -- Плавный полет к ней
                if closestCoin then
                    local direction = (closestCoin.Position - root.Position).Unit
                    root.Velocity = direction * 75
                else
                    root.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end)
    end
end)

Fluent:Notify({Title = "v7 Загружен", Content = "Скрипт полностью исправлен!", Duration = 5})
