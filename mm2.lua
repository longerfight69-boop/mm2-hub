-- [[ MM2 Optimized Clean Menu ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Конфигурация функций
getgenv().Config = {
    AntiAFK = true, AntiCheatBypass = true, RoleScanner = true,
    RadioBypass = false, ESP = false, CoinFarm = false, 
    XPFarm = false, SilentAim = false, GunESP = false, GunTP = false
}

-- Инициализация системных функций (Anti-AFK и Обход ошибок)
if getgenv().Config.AntiAFK then
    LocalPlayer.Idled:Connect(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new(0,0))
    end)
end
if getgenv().Config.AntiCheatBypass then
    game:GetService("ScriptContext").Error:Connect(function() return true end)
end

-- Сканер ролей
local Roles = {Murderer = nil, Sheriff = nil}
task.spawn(function()
    while task.wait(0.5) do
        if not getgenv().Config.RoleScanner then os.exit() end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                if p.Character:FindFirstChild("Knife") or p:FindFirstChild("Backpack"):FindFirstChild("Knife") then Roles.Murderer = p
                elseif p.Character:FindFirstChild("Gun") or p:FindFirstChild("Backpack"):FindFirstChild("Gun") then Roles.Sheriff = p end
            end
        end
    end
end)

-- Создание удобного интерфейса (Мини-окно)
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "MM2_SimpleMenu"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 380, 0, 420)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Можно перетаскивать мышкой

-- Заголовок
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "  MM2 UTILITY CONTROLLER (L-CTRL to Hide)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14

local Container = Instance.new("ScrollingFrame", MainFrame)
Container.Size = UDim2.new(1, -10, 1, -45)
Container.Position = UDim2.new(0, 5, 0, 40)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 550)
Container.ScrollBarThickness = 4

local UIList = Instance.new("UIListLayout", Container)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 4)

-- Функция создания красивой, понятной кнопки-переключателя
local function CreateToggle(name, configKey, categoryName)
    local Btn = Instance.new("TextButton", Container)
    Btn.Size = UDim2.new(1, -5, 0, 32)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Btn.BorderSizePixel = 0
    Btn.Font = Enum.Font.SourceSans
    Btn.TextSize = 16
    
    local function updateText()
        local status = getgenv().Config[configKey] and "[ ON ]" or "[ OFF ]"
        local color = getgenv().Config[configKey] and " #00FF00" or " #FF3333"
        Btn.Text = string.format("  %s: %s %s", categoryName, name, status)
        Btn.TextColor3 = getgenv().Config[configKey] and Color3.fromRGB(150, 255, 150) or Color3.fromRGB(200, 200, 200)
    end
    
    Btn.MouseButton1Click:Connect(function()
        getgenv().Config[configKey] = not getgenv().Config[configKey]
        updateText()
    end)
    updateText()
end

-- Кнопка для моментального убийства (Действие, а не переключатель)
local function CreateAction(name, func, categoryName)
    local Btn = Instance.new("TextButton", Container)
    Btn.Size = UDim2.new(1, -5, 0, 32)
    Btn.BackgroundColor3 = Color3.fromRGB(55, 35, 35)
    Btn.BorderSizePixel = 0
    Btn.Text = string.format("  ⚡ %s: %s", categoryName, name)
    Btn.TextColor3 = Color3.fromRGB(255, 150, 150)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 16
    Btn.MouseButton1Click:Connect(func)
end

-- Наполнение интерфейса кнопками (По вкладкам)
CreateToggle("Bypass Radio Audio", "RadioBypass", "MAIN")
CreateToggle("Player ESP (Colors)", "ESP", "WORLD")
CreateToggle("Coin Autofarm (Underfloor)", "CoinFarm", "WORLD")
CreateToggle("XP Safe AFK", "XPFarm", "WORLD")
CreateToggle("Silent Aim for Sheriff", "SilentAim", "COMBAT")
CreateToggle("Gun Drop ESP", "GunESP", "COMBAT")
CreateToggle("Instant Gun TP & Return", "GunTP", "COMBAT")

-- Функция массового убийства сервера
local function KillServer()
    local knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
    if not knife then return end
    LocalPlayer.Character.Humanoid:EquipTool(knife)
    local origCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
            LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
            task.wait(0.04)
            knife:Activate()
        end
    end
    LocalPlayer.Character.HumanoidRootPart.CFrame = origCFrame
end
CreateAction("KILL ALL SERVER", KillServer, "COMBAT")

-- Бинд на кнопку скрытия меню (Left Control)
game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.LeftControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Логика за кулисами (ESP, Радио, Фамы)
RunService.RenderStepped:Connect(function()
    -- ESP Логика
    if getgenv().Config.ESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("Highlight") then
                local hl = Instance.new("Highlight", p.Character)
                hl.FillColor = (p == Roles.Murderer and Color3.fromRGB(255,0,0)) or (p == Roles.Sheriff and Color3.fromRGB(0,0,255)) or Color3.fromRGB(0,255,0)
                hl.FillTransparency = 0.5
            end
        end
    end
    -- Radio Логика
    if getgenv().Config.RadioBypass then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Sound") and (v.Name == "Radio" or v.Name == "Audio") then v.Volume = 2 v.Muted = false end
        end
    end
end)

-- Потоковые циклы (Фарм Монет и Опыта)
task.spawn(function()
    while task.wait(0.1) do
        if getgenv().Config.CoinFarm and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local c = Workspace:FindFirstChild("CoinContainer", true) or Workspace:FindFirstChild("Normal", true)
            if c then
                for _, coin in ipairs(c:GetDescendants()) do
                    if coin:IsA("TouchTransmitter") and coin.Parent then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = coin.Parent.CFrame * CFrame.new(0, -4.5, 0)
                        task.wait(0.1)
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, coin.Parent, 0)
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, coin.Parent, 1)
                        task.wait(math.random(0,1))
                        break
                    end
                end
            end
        elseif getgenv().Config.XPFarm and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 7000, 0)
            if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.PlatformStand = true end
        end
    end
end)

-- Silent Aim (Шериф)
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Args = {...}
    if getnamecallmethod() == "FireServer" and Self.Name == "ShootGun" and getgenv().Config.SilentAim and Roles.Murderer and Roles.Murderer.Character then
        Args[1] = Roles.Murderer.Character.Head.Position
        return Self.FireServer(Self, unpack(Args))
    end
    return OldNamecall(Self, ...)
end)
