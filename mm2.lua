-- MM2 Personal Utility v3 (Optimized for you)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

getgenv().Config = {
    Noclip = false,
    AutoGun = true,
    SilentAim = true,
    KillAll = false, -- кнопка
    FlingAura = false,
    AntiFling = false,
    CoinFarm = false,
    MurdererESP = true,
    SheriffESP = true
}

-- === GUI (Компактный + Tabs) ===
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.ResetOnSpawn = false
ScreenGui.Name = "MM2_Personal"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 420)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "MM2 Personal v3 | LCTRL - Hide"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16

-- Простые tabs (можно расширить)
local TabFrame = Instance.new("Frame", MainFrame)
TabFrame.Size = UDim2.new(1, -20, 0, 30)
TabFrame.Position = UDim2.new(0, 10, 0, 45)
TabFrame.BackgroundTransparency = 1

local function CreateTabButton(text, pos)
    local btn = Instance.new("TextButton", TabFrame)
    btn.Size = UDim2.new(0.5, -5, 1, 0)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    return btn
end

local CombatTab = CreateTabButton("Combat", UDim2.new(0,0,0,0))
local WorldTab = CreateTabButton("World", UDim2.new(0.5,5,0,0))

local Container = Instance.new("ScrollingFrame", MainFrame)
Container.Size = UDim2.new(1, -20, 1, -100)
Container.Position = UDim2.new(0, 10, 0, 80)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0,0,0,800)
Container.ScrollBarThickness = 6

local UIList = Instance.new("UIListLayout", Container)
UIList.Padding = UDim.new(0, 6)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

local function CreateToggle(name, configKey)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = name .. " [OFF]"
    btn.TextColor3 = Color3.fromRGB(200,200,200)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 15

    btn.MouseButton1Click:Connect(function()
        getgenv().Config[configKey] = not getgenv().Config[configKey]
        local status = getgenv().Config[configKey] and "[ON]" or "[OFF]"
        btn.Text = name .. " " .. status
        btn.TextColor3 = getgenv().Config[configKey] and Color3.fromRGB(0,255,100) or Color3.fromRGB(200,200,200)
    end)
    return btn
end

-- Combat
CreateToggle("Silent Aim (Sheriff → Murderer)", "SilentAim")
CreateToggle("Fling Aura", "FlingAura")
CreateToggle("Anti Fling", "AntiFling")
local KillBtn = Instance.new("TextButton", Container)
KillBtn.Size = UDim2.new(1,0,0,40)
KillBtn.BackgroundColor3 = Color3.fromRGB(80,30,30)
KillBtn.Text = "☠️ KILL ALL (Murderer)"
KillBtn.TextColor3 = Color3.fromRGB(255,100,100)
KillBtn.MouseButton1Click:Connect(function() getgenv().Config.KillAll = true end)

-- World
CreateToggle("Auto Grab Gun + Return", "AutoGun")
CreateToggle("Noclip", "Noclip")
CreateToggle("Coin Farm (Safe)", "CoinFarm")
CreateToggle("Murderer ESP", "MurdererESP")
CreateToggle("Sheriff ESP", "SheriffESP")

UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.LeftControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- === Основные системы ===

local Roles = {Murderer = nil, Sheriff = nil}
local OriginalCFrame = nil

-- Role Scanner (стабильный)
task.spawn(function()
    while task.wait(0.3) do
        Roles.Murderer = nil
        Roles.Sheriff = nil
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local char = p.Character
                local bp = p:FindFirstChild("Backpack")
                if char:FindFirstChild("Knife") or (bp and bp:FindFirstChild("Knife")) then
                    Roles.Murderer = p
                elseif char:FindFirstChild("Gun") or (bp and bp:FindFirstChild("Gun")) then
                    Roles.Sheriff = p
                end
            end
        end
    end
end)

-- ESP (только важные роли + сброс)
local Highlights = {}
RunService.RenderStepped:Connect(function()
    for _, hl in pairs(Highlights) do hl:Destroy() end
    Highlights = {}

    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local isMurderer = (p == Roles.Murderer)
            local isSheriff = (p == Roles.Sheriff)
            
            if (isMurderer and getgenv().Config.MurdererESP) or (isSheriff and getgenv().Config.SheriffESP) then
                local hl = Instance.new("Highlight")
                hl.FillColor = isMurderer and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,100,255)
                hl.OutlineColor = Color3.fromRGB(255,255,255)
                hl.FillTransparency = 0.4
                hl.OutlineTransparency = 0
                hl.Parent = p.Character
                table.insert(Highlights, hl)
            end
        end
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if getgenv().Config.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Auto Gun Grab (мгновенный + возврат)
RunService.Heartbeat:Connect(function()
    if not getgenv().Config.AutoGun then return end
    local gunDrop = Workspace:FindFirstChild("GunDrop") or Workspace:FindFirstChild("DroppedGun", true)
    if gunDrop and gunDrop:IsA("BasePart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        OriginalCFrame = OriginalCFrame or root.CFrame
        root.CFrame = gunDrop.CFrame
        task.wait(0.08) -- хватание
        root.CFrame = OriginalCFrame
        OriginalCFrame = nil
    end
end)

-- Silent Aim (Sheriff → Murderer)
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Args = {...}
    local method = getnamecallmethod()
    if method == "FireServer" and Self.Name == "ShootGun" and getgenv().Config.SilentAim then
        if Roles.Murderer and Roles.Murderer.Character and Roles.Murderer.Character:FindFirstChild("Head") then
            local head = Roles.Murderer.Character.Head
            Args[1] = head.Position + (head.Velocity * 0.065) -- лёгкий prediction
            return OldNamecall(Self, unpack(Args))
        end
    end
    return OldNamecall(Self, ...)
end)

-- Fling Aura (улучшенный)
task.spawn(function()
    while task.wait(0.1) do
        if getgenv().Config.FlingAura and LocalPlayer.Character then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local bv = root:FindFirstChild("FlingBV") or Instance.new("BodyVelocity")
                bv.Name = "FlingBV"
                bv.MaxForce = Vector3.new(100000, 0, 100000)
                bv.Velocity = Vector3.new(math.random(-50,50), 0, math.random(-50,50))
                bv.Parent = root
            end
        else
            if LocalPlayer.Character then
                local bv = LocalPlayer.Character:FindFirstChild("FlingBV")
                if bv then bv:Destroy() end
            end
        end
    end
end)

-- Anti Fling (по популярным методам)
task.spawn(function()
    while task.wait(0.2) do
        if getgenv().Config.AntiFling and LocalPlayer.Character then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root and root.Velocity.Magnitude > 150 then
                root.Velocity = Vector3.new(0, root.Velocity.Y, 0) -- гасим горизонтальную скорость
                root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
            end
        end
    end
end)

-- Kill All (Murderer)
task.spawn(function()
    while task.wait(0.15) do
        if getgenv().Config.KillAll and LocalPlayer.Character then
            local knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
            if knife then
                LocalPlayer.Character.Humanoid:EquipTool(knife)
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.5)
                            task.wait(0.07)
                            knife:Activate()
                        end
                    end
                end
            end
            getgenv().Config.KillAll = false
        end
    end
end)

-- Coin Farm (плавный + умный)
local CurrentTarget = nil
task.spawn(function()
    while task.wait() do
        if not getgenv().Config.CoinFarm then 
            CurrentTarget = nil
            task.wait(0.5) 
            continue 
        end

        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        local coinsFolder = Workspace:FindFirstChild("CoinContainer") or Workspace:FindFirstChild("Normal")
        if not coinsFolder then continue end

        local closest, dist = nil, math.huge
        for _, coin in ipairs(coinsFolder:GetDescendants()) do
            if coin:IsA("TouchTransmitter") and coin.Parent then
                local part = coin.Parent
                local d = (root.Position - part.Position).Magnitude
                if d < dist then
                    dist = d
                    closest = part
                end
            end
        end

        if closest and dist < 200 then
            CurrentTarget = closest
            local direction = (closest.Position - root.Position).Unit
            root.Velocity = direction * 45 -- чуть быстрее игрока
            firetouchinterest(root, closest, 0)
            firetouchinterest(root, closest, 1)
        end
    end
end)
