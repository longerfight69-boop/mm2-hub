-- MM2 Ultimate Hub - Full Version (Optimized for Vega X)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

_G.AutoGunPickup = false
_G.AntiFling = false
_G.ESPEnabled = false
_G.FlingAura = false
_G.UnderMap = false
_G.WallJumpEnabled = false
_G.RadioBypass = false
_G.SelectedTarget = nil

local Fluent = loadstring(game:HttpGet("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau", true))()

local Window = Fluent:CreateWindow({
    Title = "MM2 Ultimate Custom Hub",
    SubTitle = "Optimized for Vega X",
    Size = UDim2.fromOffset(560, 460),
})

local Tabs = {
    Main = Window:AddTab({ Title = "Основные", Icon = "sliders" }),
    Combat = Window:AddTab({ Title = "Бой", Icon = "zap" }),
    Teleport = Window:AddTab({ Title = "Телепорты", Icon = "move" })
}

-- ESP
RunService.RenderStepped:Connect(function()
    if not _G.ESPEnabled then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        local hl = p.Character:FindFirstChild("MM2_ESP")
        if not hl then
            hl = Instance.new("Highlight")
            hl.Name = "MM2_ESP"
            hl.FillTransparency = 0.4
            hl.OutlineTransparency = 0
            hl.Parent = p.Character
        end
        if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
            hl.FillColor = Color3.fromRGB(255,0,0)
        elseif p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
            hl.FillColor = Color3.fromRGB(0,0,255)
        else
            hl.FillColor = Color3.fromRGB(0,255,0)
        end
    end
end)

-- Anti-Fling + Fling Aura
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not (_G.AntiFling or _G.FlingAura)
            if _G.AntiFling and not _G.FlingAura then
                part.Velocity = Vector3.zero
                part.RotVelocity = Vector3.zero
            end
        end
    end

    if _G.FlingAura and root then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if (root.Position - p.Character.HumanoidRootPart.Position).Magnitude < 7 then
                    root.RotVelocity = Vector3.new(0, 999999, 0)
                    root.Velocity = Vector3.new(root.Velocity.X, 40, root.Velocity.Z)
                    break
                end
            end
        end
    end
end)

-- Основные функции (UI)
Tabs.Main:AddToggle("Gun", {Title = "Авто-подбор пистолета", Default = false}):OnChanged(function(v)
    _G.AutoGunPickup = v
    if v then task.spawn(function()
        while _G.AutoGunPickup do task.wait(0.05)
            local drop = Workspace:FindFirstChild("GunDrop")
            if drop then
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then root.CFrame = drop.CFrame end
            end
        end
    end) end
end)

Tabs.Main:AddToggle("ESP", {Title = "Валлхак (ESP)", Default = false}):OnChanged(function(v) _G.ESPEnabled = v end)
Tabs.Main:AddToggle("AntiFling", {Title = "Анти-Флинг", Default = false}):OnChanged(function(v) _G.AntiFling = v end)
Tabs.Main:AddToggle("WallJump", {Title = "Wall Jump", Default = false}):OnChanged(function(v) _G.WallJumpEnabled = v end)

-- Телепорты
local PlayerDropdown = Tabs.Teleport:AddDropdown("Dropdown", {Title = "Выбрать игрока", Values = {}, Multi = false})
local function updateDropdown()
    local names = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    PlayerDropdown:SetValues(names)
end
Players.PlayerAdded:Connect(updateDropdown)
Players.PlayerRemoving:Connect(updateDropdown)
updateDropdown()

PlayerDropdown:OnChanged(function(val)
    _G.SelectedTarget = val
    local target = Players:FindFirstChild(val)
    if target and target.Character then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root and target.Character:FindFirstChild("HumanoidRootPart") then
            root.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end
end)

Tabs.Teleport:AddToggle("Under", {Title = "Уйти под карту", Default = false}):OnChanged(function(v)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        if v then root.CFrame = root.CFrame * CFrame.new(0,-32,0)
        else root.CFrame = root.CFrame * CFrame.new(0,32,0) end
    end
end)

-- Бой
Tabs.Combat:AddToggle("Aura", {Title = "Fling Aura", Default = false}):OnChanged(function(v) _G.FlingAura = v end)

Tabs.Combat:AddButton({Title = "Kill All (Мардер)", Callback = function()
    -- (код кнопки Kill All из предыдущего сообщения)
    local knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not knife or not root then return end
    local old = root.CFrame
    knife.Parent = LocalPlayer.Character
    task.wait(0.1)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            root.CFrame = p.Character.HumanoidRootPart.CFrame
            task.wait(0.03)
            knife:Activate()
        end
    end
    root.CFrame = old
end})

Tabs.Combat:AddButton({Title = "Убить Мардера (Шериф)", Callback = function()
    -- (код кнопки Kill Murderer)
    local gun = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not gun or not root then return end
    local old = root.CFrame
    gun.Parent = LocalPlayer.Character
    task.wait(0.1)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
            local t = p.Character.HumanoidRootPart
            root.CFrame = CFrame.lookAt(t.Position + Vector3.new(0,3,2), t.Position)
            task.wait(0.05)
            gun:Activate()
            break
        end
    end
    root.CFrame = old
end})

Fluent:Notify({Title = "Загружено!", Content = "Полный хаб готов", Duration = 5})
