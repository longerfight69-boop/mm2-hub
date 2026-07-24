-- MM2 Hub v3 - Fixed Version
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

_G.AutoGun = false
_G.ESP = false
_G.AntiFling = false
_G.FlingAura = false
_G.UnderMap = false
_G.WallJump = false
_G.AutoFarm = false
_G.SelectedTarget = nil

local Fluent = loadstring(game:HttpGet("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau", true))()

local Window = Fluent:CreateWindow({Title = "MM2 Hub v3", SubTitle = "Fixed", Size = UDim2.fromOffset(560, 480)})

local Tabs = {
    Main = Window:AddTab({ Title = "Основные", Icon = "sliders" }),
    Combat = Window:AddTab({ Title = "Бой", Icon = "zap" }),
    Tele = Window:AddTab({ Title = "Телепорт", Icon = "move" }),
    Farm = Window:AddTab({ Title = "Фарм", Icon = "coin" })
}

-- ESP
RunService.RenderStepped:Connect(function()
    if not _G.ESP then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer or not p.Character then continue end
        local hl = p.Character:FindFirstChild("ESP") or Instance.new("Highlight")
        hl.Name = "ESP"
        hl.FillTransparency = 0.5
        hl.Parent = p.Character
        if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then hl.FillColor = Color3.fromRGB(255,0,0)
        elseif p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then hl.FillColor = Color3.fromRGB(0,0,255)
        else hl.FillColor = Color3.fromRGB(0,255,0) end
    end
end)

-- Anti Fling (без сильного лагa)
RunService.Stepped:Connect(function()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if _G.AntiFling then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
                v.Velocity = Vector3.new(0,0,0)
            end
        end
    end
    if _G.FlingAura and _G.SelectedTarget then
        local target = Players:FindFirstChild(_G.SelectedTarget)
        if target and target.Character then
            local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if tRoot and (root.Position - tRoot.Position).Magnitude < 8 then
                root.RotVelocity = Vector3.new(0, 999999, 0)
            end
        end
    end
end)

-- Auto Farm (простой сбор монет)
Tabs.Farm:AddToggle("Farm", {Title = "АвтоФарм Монет", Default = false}):OnChanged(function(v)
    _G.AutoFarm = v
    if v then
        task.spawn(function()
            while _G.AutoFarm do
                task.wait(0.3)
                for _, coin in pairs(Workspace:GetChildren()) do
                    if coin.Name == "Coin" or coin.Name:find("Coin") then
                        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if root and coin:FindFirstChild("Coin") then
                            root.CFrame = coin.Coin.CFrame
                        end
                    end
                end
            end
        end)
    end
end)

-- Основное
Tabs.Main:AddToggle("Gun", {Title = "Авто Gun", Default = false}):OnChanged(function(v) _G.AutoGun = v end)
Tabs.Main:AddToggle("ESP", {Title = "ESP", Default = false}):OnChanged(function(v) _G.ESP = v end)
Tabs.Main:AddToggle("Anti", {Title = "Анти-Флинг", Default = false}):OnChanged(function(v) _G.AntiFling = v end)
Tabs.Main:AddToggle("WJ", {Title = "Wall Jump", Default = false}):OnChanged(function(v) _G.WallJump = v end)

-- Телепорт
local dd = Tabs.Tele:AddDropdown("Target", {Title = "Цель", Values = {}, Multi = false})
local function upd() 
    local l = {} 
    for _,p in Players:GetPlayers() do if p~=LocalPlayer then table.insert(l,p.Name) end end 
    dd:SetValues(l) 
end
Players.PlayerAdded:Connect(upd)
Players.PlayerRemoving:Connect(upd)
upd()

dd:OnChanged(function(v) _G.SelectedTarget = v end)

Tabs.Tele:AddToggle("Under", {Title = "Под карту (фикс)", Default = false}):OnChanged(function(v)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame = root.CFrame * CFrame.new(0, v and -20 or 20, 0) end
end)

-- Combat
Tabs.Combat:AddToggle("Aura", {Title = "Fling Aura (на цель)", Default = false}):OnChanged(function(v) _G.FlingAura = v end)

Tabs.Combat:AddButton({Title = "Kill All (Мардер)", Callback = function()
    local k = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
    local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not k or not r then return end
    local old = r.CFrame
    k.Parent = LocalPlayer.Character
    task.wait(0.1)
    for _,p in Players:GetPlayers() do
        if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            r.CFrame = p.Character.HumanoidRootPart.CFrame
            task.wait(0.02)
            k:Activate()
        end
    end
    r.CFrame = old
end})

Tabs.Combat:AddButton({Title = "Убить Мардера (Шериф)", Callback = function()
    local g = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
    local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not g or not r then return end
    local old = r.CFrame
    g.Parent = LocalPlayer.Character
    task.wait(0.1)
    for _,p in Players:GetPlayers() do
        if p~=LocalPlayer and (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) then
            local t = p.Character.HumanoidRootPart
            r.CFrame = CFrame.lookAt(t.Position + Vector3.new(0,5,0), t.Position)
            task.wait(0.06)
            g:Activate()
            break
        end
    end
    task.wait(0.1)
    r.CFrame = old
end})

Fluent:Notify({Title="v3 Загружен", Content="Попробуй заново", Duration=6})
