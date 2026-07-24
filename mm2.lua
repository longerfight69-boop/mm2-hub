-- MM2 Ultimate Hub v2 - Fixed & Improved
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
_G.AutoFarm = false
_G.SelectedTarget = nil

local Fluent = loadstring(game:HttpGet("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau", true))()

local Window = Fluent:CreateWindow({
    Title = "MM2 Ultimate Hub v2",
    SubTitle = "Fixed for Vega X",
    Size = UDim2.fromOffset(570, 480),
})

local Tabs = {
    Main = Window:AddTab({ Title = "Основные", Icon = "sliders" }),
    Combat = Window:AddTab({ Title = "Бой", Icon = "zap" }),
    Teleport = Window:AddTab({ Title = "Телепорты", Icon = "move" }),
    Farm = Window:AddTab({ Title = "Фарм", Icon = "coin" })
}

-- ==================== ESP (исправленный тоггл) ====================
RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        local hl = p.Character:FindFirstChild("MM2_ESP")
        if _G.ESPEnabled then
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
                hl.FillColor = Color3.fromRGB(0,100,255)
            else
                hl.FillColor = Color3.fromRGB(0,255,0)
            end
        elseif hl then
            hl:Destroy()
        end
    end
end)

-- ==================== Anti-Fling + Fling Aura ====================
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if _G.FlingAura then
                part.CanCollide = false
            else
                part.CanCollide = not _G.AntiFling
            end
            if _G.AntiFling and not _G.FlingAura then
                part.Velocity = Vector3.new(0,0,0)
                part.RotVelocity = Vector3.new(0,0,0)
            end
        end
    end

    if _G.FlingAura and root then
        local target = _G.SelectedTarget and Players:FindFirstChild(_G.SelectedTarget)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (root.Position - target.Character.HumanoidRootPart.Position).Magnitude
            if dist < 10 then
                root.RotVelocity = Vector3.new(0, 800000, 0)
                root.Velocity = Vector3.new(0, 50, 0)
            end
        end
    end
end)

-- ==================== UI ====================
Tabs.Main:AddToggle("Gun", {Title = "Авто GunDrop", Default = false}):OnChanged(function(v) _G.AutoGunPickup = v end)
Tabs.Main:AddToggle("ESP", {Title = "Валлхак ESP", Default = false}):OnChanged(function(v) _G.ESPEnabled = v end)
Tabs.Main:AddToggle("AntiFling", {Title = "Анти-Флинг (без сильного замедления)", Default = false}):OnChanged(function(v) _G.AntiFling = v end)
Tabs.Main:AddToggle("WallJump", {Title = "Wall Jump", Default = false}):OnChanged(function(v) _G.WallJumpEnabled = v end)

-- WallJump улучшенный
if _G.WallJumpEnabled then
    task.spawn(function()
        while _G.WallJumpEnabled do
            task.wait()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if root and hum and hum:GetState() == Enum.HumanoidStateType.Freefall then
                local ray = Workspace:Raycast(root.Position, root.CFrame.LookVector * 2.5)
                if ray then
                    root.Velocity = Vector3.new(root.Velocity.X, 60, root.Velocity.Z) + ray.Normal * 12
                    task.wait(0.15)
                end
            end
        end
    end)
end

-- Телепорты
local PlayerDropdown = Tabs.Teleport:AddDropdown("Target", {Title = "Выбрать цель", Values = {}, Multi = false})
local function updateList()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    PlayerDropdown:SetValues(list)
end
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
updateList()

PlayerDropdown:OnChanged(function(v) _G.SelectedTarget = v end)

Tabs.Teleport:AddToggle("Under", {Title = "Уйти под карту (фикс падения)", Default = false}):OnChanged(function(v)
    _G.UnderMap = v
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        if v then
            root.CFrame = root.CFrame * CFrame.new(0, -25, 0)
            root.Velocity = Vector3.new(0,0,0)
        else
            root.CFrame = root.CFrame * CFrame.new(0, 25, 0)
        end
    end
end)

-- Combat
Tabs.Combat:AddToggle("Aura", {Title = "Fling Aura на выбранную цель", Default = false}):OnChanged(function(v) _G.FlingAura = v end)

Tabs.Combat:AddButton({Title = "Kill All (Мардер)", Callback = function()
    -- ... (оставил как было, можешь улучшить позже)
    local knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not knife or not root then return end
    local old = root.CFrame
    knife.Parent = LocalPlayer.Character
    task.wait(0.1)
    for _, p in pairs(Players:GetPlayers()) do
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
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not gun or not root then return end
    local old = root.CFrame
    gun.Parent = LocalPlayer.Character
    task.wait(0.08)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
            local t = p.Character.HumanoidRootPart
            root.CFrame = CFrame.lookAt(t.Position + Vector3.new(0,4,0), t.Position)
            task.wait(0.04)
            gun:Activate()
            task.wait(0.1)
            break
        end
    end
    root.CFrame = old
end})

Fluent:Notify({Title = "v2 Загружен", Content = "Исправления применены", Duration = 5})
