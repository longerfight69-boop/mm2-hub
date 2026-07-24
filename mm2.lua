-- MM2 Ultimate Hub v7 (Специальная версия для Delta)
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

-- Инициализация Fluent (Исправлено под Delta - без лишних аргументов)
local Fluent = loadstring(game:HttpGet("https://githubusercontent.com"))()

local Window = Fluent:CreateWindow({
    Title = "MM2 Ultimate Hub v7",
    SubTitle = "Delta Edition",
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

-- ==================== ЛОГИКА ЧИТА ====================

-- ESP На игроков
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
            hl.FillColor = Color3.fromRGB(255, 0, 0)
        elseif p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
            hl.FillColor = Color3.fromRGB(0, 100, 255)
        else
            hl.FillColor = Color3.fromRGB(0, 255, 0)
        end
    end
end)

-- Авто-подбор пушки
task.spawn(function()
    while task.wait(0.1) do
        if _G.Settings.AutoGun then
            local drop = Workspace:FindFirstChild("GunDrop")
            local root = getRoot()
            if drop and root then root.CFrame = drop.CFrame end
        end
    end
end)

-- Анти-Флинг
RunService.Stepped:Connect(function()
    local root = getRoot()
    if not root then return end
    if _G.Settings.AntiFling and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- ==================== ИНТЕРФЕЙС ТАБОВ ====================

Tabs.Main:AddToggle("Gun", {Title = "Авто GunDrop", Default = false}):OnChanged(function(v) _G.Settings.AutoGun = v end)
Tabs.Main:AddToggle("ESP", {Title = "ESP игроков", Default = false}):OnChanged(function(v) _G.Settings.ESP = v end)
Tabs.Main:AddToggle("AntiFling", {Title = "Анти-Флинг", Default = false}):OnChanged(function(v) _G.Settings.AntiFling = v end)

-- Телепорты
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

-- Бой
Tabs.Combat:AddButton({Title = "Kill All (За Мардера)", Callback = function()
    local knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
    local root = getRoot()
    if not knife or not root then return end
    
    local oldCFrame = root.CFrame
    knife.Parent = LocalPlayer.Character
    task.wait(0.2)
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            root.CFrame = p.Character.HumanoidRootPart.CFrame
            task.wait(0.1)
            knife:Activate()
        end
    end
    root.CFrame = oldCFrame
end})

-- Фарм монет
Tabs.Farm:AddToggle("Farm", {Title = "АвтоФарм монет", Default = false}):OnChanged(function(v)
    _G.Settings.AutoFarm = v
    if v then
        task.spawn(function()
            while _G.Settings.AutoFarm do
                task.wait(0.1)
                local root = getRoot()
                if not root then continue end
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name:find("Coin") and obj:IsA("BasePart") then
                        local direction = (obj.Position - root.Position).Unit
                        root.Velocity = direction * 60
                        break
                    end
                end
            end
        end)
    end
end)

Fluent:Notify({Title = "Успешно", Content = "Хаб полностью готов для Delta!", Duration = 5})
