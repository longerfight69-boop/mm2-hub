-- MM2 Ultimate Hub v8 - Улучшенная
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
    Title = "MM2 Ultimate Hub v8",
    SubTitle = "Улучшено по другим хабам",
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

-- ESP
RunService.RenderStepped:Connect(function()
    if not _G.Settings.ESP then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        local hl = p.Character:FindFirstChild("MM2ESP") or Instance.new("Highlight")
        hl.Name = "MM2ESP"
        hl.FillTransparency = 0.35
        hl.OutlineTransparency = 0
        hl.Parent = p.Character
        if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
            hl.FillColor = Color3.fromRGB(255,0,0)
        elseif p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
            hl.FillColor = Color3.fromRGB(0,100,255)
        else
            hl.FillColor = Color3.fromRGB(0,255,0)
        end
    end
end)

-- Auto Gun
task.spawn(function()
    while task.wait(0.02) do
        if _G.Settings.AutoGun then
            local drop = Workspace:FindFirstChild("GunDrop")
            if drop then
                local root = getRoot()
                if root then root.CFrame = drop.CFrame + Vector3.new(0,3,0) end
            end
        end
    end
end)

-- Fling Aura (стабильнее)
RunService.Stepped:Connect(function()
    local root = getRoot()
    if not root then return end

    if _G.Settings.AntiFling then
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
                if dist < 8 then
                    root.RotVelocity = Vector3.new(0, 750000, 0)
                    root.Velocity = Vector3.new(0, 30, 0)
                end
            end
        end
    end
end)

-- UI
Tabs.Main:AddToggle("Gun", {Title = "Авто GunDrop", Default = false}):OnChanged(function(v) _G.Settings.AutoGun = v end)
Tabs.Main:AddToggle("ESP", {Title = "ESP", Default = false}):OnChanged(function(v) _G.Settings.ESP = v end)
Tabs.Main:AddToggle("AntiFling", {Title = "Анти-Флинг", Default = false}):OnChanged(function(v) _G.Settings.AntiFling = v end)
Tabs.Main:AddToggle("WallJump", {Title = "Wall Jump", Default = false}):OnChanged(function(v) _G.Settings.WallJump = v end)

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

Tabs.Tele:AddButton({Title = "Телепорт к цели", Callback = function()
    if not _G.Settings.SelectedTarget then return end
    local target = Players:FindFirstChild(_G.Settings.SelectedTarget)
    if target and target.Character then
        local root = getRoot()
        local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if root and tRoot then root.CFrame = tRoot.CFrame end
    end
end})

Tabs.Tele:AddToggle("Under", {Title = "Уйти под карту", Default = false}):OnChanged(function(v)
    _G.Settings.UnderMap = v
    task.spawn(function()
        while _G.Settings.UnderMap do
            local root = getRoot()
            if root then root.CFrame = root.CFrame * CFrame.new(0, -1, 0) end
            task.wait(0.2)
        end
    end)
end)

-- Combat
Tabs.Combat:AddToggle("FlingAura", {Title = "Fling Aura", Default = false}):OnChanged(function(v) _G.Settings.FlingAura = v end)

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
            task.wait(0.025)
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
            root.CFrame = CFrame.lookAt(t.Position + Vector3.new(0,4,0), t.Position)
            task.wait(0.06)
            gun:Activate()
            task.wait(0.1)
            gun:Activate() -- двойной для надёжности
            break
        end
    end
    task.wait(0.2)
    root.CFrame = old
end})

-- AutoFarm (плавный)
Tabs.Farm:AddToggle("Farm", {Title = "АвтоФарм (плавный)", Default = false}):OnChanged(function(v)
    _G.Settings.AutoFarm = v
    if v then
        task.spawn(function()
            while _G.Settings.AutoFarm do
                task.wait(0.12)
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name:find("Coin") and obj:IsA("BasePart") then
                        local root = getRoot()
                        if root then
                            local dir = (obj.Position - root.Position).Unit
                            root.Velocity = dir * 55   -- плавно
                        end
                    end
                end
            end
        end)
    end
end)

Fluent:Notify({Title = "v8 Загружен", Content = "Улучшено по другим хабам", Duration = 6})
