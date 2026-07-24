local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

getgenv().Config = {
    AntiAFK = true, AntiCheatBypass = true, RoleScanner = true,
    RadioBypass = false, ESP = false, CoinFarm = false, 
    XPFarm = false, SilentAim = false, GunTP = false,
    Noclip = false, FlingAura = false
}

if getgenv().Config.AntiAFK then
    LocalPlayer.Idled:Connect(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new(0,0))
    end)
end
if getgenv().Config.AntiCheatBypass then
    game:GetService("ScriptContext").Error:Connect(function() return true end)
end

local Roles = {Murderer = nil, Sheriff = nil}
local PlayerList = {}
local TargetIndex = 1

local function UpdatePlayerList()
    PlayerList = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(PlayerList, p) end
    end
end

task.spawn(function()
    while task.wait(0.5) do
        UpdatePlayerList()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                if p.Character:FindFirstChild("Knife") or p:FindFirstChild("Backpack"):FindFirstChild("Knife") then Roles.Murderer = p
                elseif p.Character:FindFirstChild("Gun") or p:FindFirstChild("Backpack"):FindFirstChild("Gun") then Roles.Sheriff = p end
            end
        end
    end
end)

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "MM2_AdvancedMenu"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 390, 0, 460)
MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "  MM2 UTILITY V2 (L-CTRL to Hide)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16

local Container = Instance.new("ScrollingFrame", MainFrame)
Container.Size = UDim2.new(1, -10, 1, -55)
Container.Position = UDim2.new(0, 5, 0, 50)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 600)
Container.ScrollBarThickness = 4

local UIList = Instance.new("UIListLayout", Container)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 5)

local function CreateToggle(name, configKey, category)
    local Btn = Instance.new("TextButton", Container)
    Btn.Size = UDim2.new(1, -5, 0, 34)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Btn.BorderSizePixel = 0
    Btn.Font = Enum.Font.SourceSans
    Btn.TextSize = 15
    
    local function updateText()
        local status = getgenv().Config[configKey] and "[ ON ]" or "[ OFF ]"
        Btn.Text = string.format("  [%s] %s %s", category, name, status)
        Btn.TextColor3 = getgenv().Config[configKey] and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(220, 220, 220)
    end
    
    Btn.MouseButton1Click:Connect(function()
        getgenv().Config[configKey] = not getgenv().Config[configKey]
        updateText()
    end)
    updateText()
end

CreateToggle("Bypass Radio Audio", "RadioBypass", "MAIN")
CreateToggle("Player ESP", "ESP", "WORLD")
CreateToggle("Smooth Coin Farm (Anti-Ban)", "CoinFarm", "WORLD")
CreateToggle("Noclip (Walk Through Walls)", "Noclip", "WORLD")
CreateToggle("XP Safe Flying", "XPFarm", "WORLD")
CreateToggle("Active Fling Aura", "FlingAura", "COMBAT")
CreateToggle("Silent Aim (Sheriff)", "SilentAim", "COMBAT")
CreateToggle("Instant Gun Pick & Return", "GunTP", "COMBAT")

local TargetFrame = Instance.new("Frame", Container)
TargetFrame.Size = UDim2.new(1, -5, 0, 40)
TargetFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TargetFrame.BorderSizePixel = 0

local PrevBtn = Instance.new("TextButton", TargetFrame)
PrevBtn.Size = UDim2.new(0, 40, 1, 0)
PrevBtn.Text = "<"
PrevBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PrevBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local NextBtn = Instance.new("TextButton", TargetFrame)
NextBtn.Size = UDim2.new(0, 40, 1, 0)
NextBtn.Position = UDim2.new(1, -40, 0, 0)
NextBtn.Text = ">"
NextBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
NextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local TargetLabel = Instance.new("TextLabel", TargetFrame)
TargetLabel.Size = UDim2.new(1, -80, 1, 0)
TargetLabel.Position = UDim2.new(0, 40, 0, 0)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text = "Target: None"
TargetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetLabel.Font = Enum.Font.SourceSansBold

local function UpdateTargetLabel()
    if #PlayerList > 0 then
        if TargetIndex > #PlayerList then TargetIndex = 1 end
        if TargetIndex < 1 then TargetIndex = #PlayerList end
        TargetLabel.Text = "Target: " .. PlayerList[TargetIndex].Name
    else
        TargetLabel.Text = "Target: No Players"
    end
end

PrevBtn.MouseButton1Click:Connect(function() TargetIndex = TargetIndex - 1 UpdateTargetLabel() end)
NextBtn.MouseButton1Click:Connect(function() TargetIndex = TargetIndex + 1 UpdateTargetLabel() end)

local TpBtn = Instance.new("TextButton", Container)
TpBtn.Size = UDim2.new(1, -5, 0, 36)
TpBtn.BackgroundColor3 = Color3.fromRGB(45, 65, 45)
TpBtn.Text = "⚡ TELEPORT TO TARGET"
TpBtn.TextColor3 = Color3.fromRGB(150, 255, 150)
TpBtn.Font = Enum.Font.SourceSansBold
TpBtn.TextSize = 15

TpBtn.MouseButton1Click:Connect(function()
    if #PlayerList > 0 and PlayerList[TargetIndex] and PlayerList[TargetIndex].Character then
        local targetRoot = PlayerList[TargetIndex].Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2)
        end
    end
end)

local KillAllBtn = Instance.new("TextButton", Container)
KillAllBtn.Size = UDim2.new(1, -5, 0, 36)
KillAllBtn.BackgroundColor3 = Color3.fromRGB(70, 35, 35)
KillAllBtn.Text = "☠️ KILL ALL SERVER (As Murderer)"
KillAllBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
KillAllBtn.Font = Enum.Font.SourceSansBold
KillAllBtn.TextSize = 15

KillAllBtn.MouseButton1Click:Connect(function()
    local knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
    if not knife then return end
    LocalPlayer.Character.Humanoid:EquipTool(knife)
    local orig = LocalPlayer.Character.HumanoidRootPart.CFrame
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
            LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
            task.wait(0.05)
            knife:Activate()
        end
    end
    LocalPlayer.Character.HumanoidRootPart.CFrame = orig
end)

game:GetService("UserInputService").InputBegan:Connect(function(i, p)
    if not p and i.KeyCode == Enum.KeyCode.LeftControl then MainFrame.Visible = not MainFrame.Visible end
end)

RunService.RenderStepped:Connect(function()
    UpdateTargetLabel()
    if getgenv().Config.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    if getgenv().Config.ESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("Highlight") then
                local hl = Instance.new("Highlight", p.Character)
                hl.FillColor = (p == Roles.Murderer and Color3.fromRGB(255,0,0)) or (p == Roles.Sheriff and Color3.fromRGB(0,0,255)) or Color3.fromRGB(0,255,0)
                hl.FillTransparency = 0.5
            end
        end
    end
    if getgenv().Config.RadioBypass then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Sound") and (v.Name == "Radio" or v.Name == "Audio") then v.Volume = 2 v.Muted = false end
        end
    end
end)

local currentTween = nil
task.spawn(function()
    while task.wait(0.2) do
        if getgenv().Config.CoinFarm and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character.HumanoidRootPart
            local c = Workspace:FindFirstChild("CoinContainer", true) or Workspace:FindFirstChild("Normal", true)
            if c then
                for _, coin in ipairs(c:GetDescendants()) do
                    if coin:IsA("TouchTransmitter") and coin.Parent then
                        local coinPart = coin.Parent
                        local targetCFrame = coinPart.CFrame * CFrame.new(0, -4.5, 0)
                        local distance = (root.Position - targetCFrame.Position).Magnitude
                        local speed = 25
                        local duration = distance / speed
                        
                        local info = TweenInfo.new(duration, Enum.EasingStyle.Linear)
                        currentTween = TweenService:Create(root, info, {CFrame = targetCFrame})
                        currentTween:Play()
                        currentTween.Completed:Wait()
                        
                        firetouchinterest(root, coinPart, 0)
                        firetouchinterest(root, coinPart, 1)
                        task.wait(math.random(0, 1))
                        break
                    end
                end
            end
elseif getgenv().Config.XPFarm
    and LocalPlayer.Character
    and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then

    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 7500, 0)

    if LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = true
    end

elseif currentTween then
    currentTween:Cancel()
end

end
end
end)

task.spawn(function()
    while task.wait() do
        if getgenv().Config.FlingAura
            and LocalPlayer.Character
            and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then

            local root = LocalPlayer.Character.HumanoidRootPart

            local bam = Instance.new("BodyAngularVelocity")
            bam.Name = "FlingForce"
            bam.AngularVelocity = Vector3.new(0, 99999, 0)
            bam.MaxTorque = Vector3.new(0, 99999, 0)
            bam.Parent = root

            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end

            task.wait(0.1)

            if root:FindFirstChild("FlingForce") then
                root.FlingForce:Destroy()
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local drop =
        Workspace:FindFirstChild("GunDrop")
        or Workspace:FindFirstChild("DroppedGun", true)

    if drop
        and drop:IsA("BasePart")
        and getgenv().Config.GunTP
        and LocalPlayer.Character
        and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then

        getgenv().Config.GunTP = false

        local oldPos = LocalPlayer.Character.HumanoidRootPart.CFrame

        LocalPlayer.Character.HumanoidRootPart.CFrame = drop.CFrame

        task.wait(0.2)

        LocalPlayer.Character.HumanoidRootPart.CFrame = oldPos
    end
end)

local OldNamecall

OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Args = {...}

    if getnamecallmethod() == "FireServer"
        and Self.Name == "ShootGun"
        and getgenv().Config.SilentAim
        and Roles.Murderer
        and Roles.Murderer.Character then

        Args = Roles.Murderer.Character.Head.Position
        return Self.FireServer(Self, unpack(Args))
    end

    return OldNamecall(Self, ...)
end)
