-- MM2 Ultimate Hub v6 - Максимально стабильная
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

local Fluent = loadstring(game:HttpGet("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau", true))()

local Window = Fluent:CreateWindow({
    Title = "MM2 Ultimate Hub v6",
    SubTitle = "Стабильная версия",
    Size = UDim2.fromOffset(580, 500),
})

local Tabs = {
    Main = Window:AddTab({ Title = "Основные", Icon = "sliders" }),
    Combat = Window:AddTab({ Title = "Бой", Icon = "zap" }),
    Tele = Window:AddTab({ Title = "Телепорт", Icon = "move" }),
    Farm = Window:AddTab({ Title = "Фарм", Icon = "coin" })
}

-- Получение root части
local function getRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ==================== ESP ====================
RunService.RenderStepped:Connect(function()
    if not _G.Settings.ESP then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        local hl = p.Character:FindFirstChild("MM2ESP")
        if not hl then
            hl = Instance.new("Highlight")
            hl.Name = "MM2ESP"
            hl.FillTransparency = 0.4
            hl.OutlineTransparency = 0
            hl.Parent = p.Character
        end
        if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
            hl.FillColor = Color3.fromRGB(255,0,0)
        elseif p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
            hl.FillColor = Color3.fromRGB(0,100,255)
        else
            hl.FillColor = Color3.fromRGB(0,255,0)
        end
    end
end)

-- Очистка ESP при выключении
local function clearESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            local hl = p.Character:FindFirstChild("MM2ESP")
            if hl then hl:Destroy() end
        end
    end
end

-- ==================== Auto Gun ====================
task.spawn(function()
    while task.wait(0.03) do
        if _G.Settings.AutoGun then
            local drop = Workspace:FindFirstChild("GunDrop") or Workspace:FindFirstChildWhichIsA("Tool")
            if drop then
                local root = getRoot()
                if root then root.CFrame = drop.CFrame end
            end
        end
    end
end)

-- ==================== Anti Fling & Fling Aura ====================
RunService.Stepped:Connect(function()
    local root = getRoot()
    if not root then return end

    if _G.Settings.AntiFling then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    if _G.Settings.FlingAura and _G.Settings.SelectedTarget then
        local target = Players:FindFirstChild(_G.Settings.SelectedTarget)
        if target and target.Character then
            local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if tRoot and (root.Position - tRoot.Position).Magnitude < 8 then
                root.RotVelocity = Vector3.new(0, 999999, 0)
                root.Velocity = Vector3.new(0, 50, 0)
            end
        end
    end
end)

-- ==================== UI ====================
Tabs.Main:AddToggle("Gun", {Title = "Авто GunDrop", Default = false}):OnChanged(function(v) _G.Settings.AutoGun = v end)
Tabs.Main:AddToggle("ESP", {Title = "ESP", Default = false}):OnChanged(function(v) 
    _G.Settings.ESP = v 
    if not v then clearESP() end
end)
Tabs.Main:AddToggle("AntiFling", {Title = "Анти-Флинг", Default = false}):OnChanged(function(v) _G.Settings.AntiFling = v end)
Tabs.Main:AddToggle("WallJump", {Title = "Wall Jump", Default = false}):OnChanged(function(v) _G.Settings.WallJump = v end)

-- WallJump
task.spawn(function()
    while task.wait(0.01) do
        if not _G.Settings.WallJump then continue end
        local root = getRoot()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if root and hum and hum.FloorMaterial == Enum.Material.Air then
            local ray = Workspace:Raycast(root.Position, root.CFrame.LookVector * 2.2)
            if ray then
                root.Velocity = Vector3.new(root.Velocity.X, 60, root.Velocity.Z) + ray.Normal * 12
            end
        end
    end
end)

-- Телепорт
local dropdown = Tabs.Tele:AddDropdown("Target", {Title = "Выбрать цель", Values = {}, Multi = false})
local function updateDropdown()
    local list = {}
    for _, p in Players:GetPlayers() do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    dropdown:SetValues(list)
end
Players.PlayerAdded:Connect(updateDropdown)
Players.PlayerRemoving:Connect(updateDropdown)
updateDropdown()

dropdown:OnChanged(function(v) _G.Settings.SelectedTarget = v end)

-- Under Map (улучшенный)
Tabs.Tele:AddToggle("Under", {Title = "Уйти под карту", Default = false}):OnChanged(function(v)
    _G.Settings.UnderMap = v
    task.spawn(function()
        while _G.Settings.UnderMap do
            local root = getRoot()
            if root then
                root.CFrame = root.CFrame * CFrame.new(0, -0.8, 0)
                root.Velocity = Vector3.new(0,0,0)
            end
            task.wait(0.15)
        end
    end)
end)

-- Combat
Tabs.Combat:AddToggle("FlingAura", {Title = "Fling Aura (на цель)", Default = false}):OnChanged(function(v) _G.Settings.FlingAura = v end)

Tabs.Combat:AddButton({Title = "Kill All (Мардер)", Callback = function()
    local knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
    local root = getRoot()
    if not knife or not root then return end
    local old = root.CFrame
    knife.Parent = LocalPlayer.Character
    task.wait(0.15)
    for _, p in Players:GetPlayers() do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            root.CFrame = p.Character.HumanoidRootPart.CFrame
            task.wait(0.03)
            knife:Activate()
        end
    end
    root.CFrame = old
end})

Tabs.Combat:AddButton({Title = "Убить Мардера (Шериф)", Callback = function()
    local gun = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
    local root = getRoot()
    if not gun or not root then return end
    local old = root.CFrame
    gun.Parent = LocalPlayer.Character
    task.wait(0.12)
    for _, p in Players:GetPlayers() do
        if p ~= LocalPlayer and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
            local t = p.Character.HumanoidRootPart
            root.CFrame = CFrame.lookAt(t.Position + Vector3.new(0,5,2), t.Position)
            task.wait(0.07)
            gun:Activate()
            break
        end
    end
    task.wait(0.1)
    root.CFrame = old
end})

-- Auto Farm
Tabs.Farm:AddToggle("Farm", {Title = "АвтоФарм Монет", Default = false}):OnChanged(function(v)
    _G.Settings.AutoFarm = v
    if v then
        task.spawn(function()
            while _G.Settings.AutoFarm do
                task.wait(0.2)
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name:find("Coin") and obj:IsA("BasePart") then
                        local root = getRoot()
                        if root then root.CFrame = obj.CFrame end
                    end
                end
            end
        end)
    end
end)

Fluent:Notify({Title = "v6 Загружен", Content = "Основные проблемы исправлены", Duration = 6})
