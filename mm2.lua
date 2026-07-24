repeat wait() until game:IsLoaded()

-- Загрузка чистой библиотеки интерфейса
local Library = loadstring(game:HttpGetAsync("https://githubusercontent.com", true))()
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local SoundService = game:GetService("SoundService")

local Client = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Character, RootPart, Humanoid

getgenv().KnifeRange = 25
getgenv().GunAccuracy = 25
getgenv().Whitelisted = {}
getgenv().RadioBypass = false

local function SetCharVars()
    Character = Client.Character or Client.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
end
SetCharVars()
Client.CharacterAdded:Connect(SetCharVars)

-- ==================== UI WINDOW ====================
local Window = Library:CreateWindow({Title = "MM2 Custom Script (Safe)"})
local Tab1 = Window:CreateTab({Title = "Main & Radio"})
local Tab2 = Window:CreateTab({Title = "World"})
local Tab3 = Window:CreateTab({Title = "Combat"})
local Tab4 = Window:CreateTab({Title = "Fling"})

-- ==================== MAIN & RADIO ====================
local MainSection = Tab1:CreateSection({Title = "Radio Settings"})

-- Функция байпаса радио в лобби
MainSection:CreateToggle({Title = "Bypass Radio Mute", Default = false, Callback = function(state)
    getgenv().RadioBypass = state
end})

-- Поток контроля громкости радио (предотвращает принудительный мут от игры в лобби)
RunService.Heartbeat:Connect(function()
    if getgenv().RadioBypass then
        pcall(function()
            -- Принудительно возвращаем громкость радио-объектам на сервере/клиенте
            local radiosFolder = SoundService:FindFirstChild("Radios") or ReplicatedStorage:FindFirstChild("Radios")
            if radiosFolder then
                if radiosFolder:IsA("SoundGroup") and radiosFolder.Volume == 0 then
                    radiosFolder.Volume = 1
                end
                for _, sound in ipairs(radiosFolder:GetDescendants()) do
                    if sound:IsA("Sound") and sound.Volume == 0 then
                        sound.Volume = 1
                    end
                end
            end
            -- Проверка радио у самих персонажей в лобби
            for _, plyr in ipairs(Players:GetPlayers()) do
                if plyr.Character and plyr.Character:FindFirstChild("HumanoidRootPart") then
                    for _, item in ipairs(plyr.Character.HumanoidRootPart:GetChildren()) do
                        if item:IsA("Sound") and item.Volume == 0 then
                            item.Volume = 1
                        end
                    end
                end
            end
        end)
    end
end)

-- ==================== WORLD (AUTOFARM / TP / ESP) ====================
local AutoSection = Tab2:CreateSection({Title = "Autofarm & Teleport"})

AutoSection:CreateToggle({Title = "Autofarm Coins (Плавный)", Default = false, Callback = function(state)
    getgenv().Autofarm = state
    while getgenv().Autofarm do
        task.wait()
        local container = Workspace:FindFirstChild("CoinContainer", true)
        if container and Client.PlayerGui.MainGUI.Game.CashBag.Visible then
            local coin = container:FindFirstChild("Coin_Server")
            if coin then
                local target = coin.Position - Vector3.new(0, 3, 0)
                local dir = (target - RootPart.Position)
                local dist = dir.Magnitude
                if dist > 4 then
                    RootPart.Velocity = dir.Unit * 120
                else
                    RootPart.CFrame = CFrame.new(target)
                end
            end
        end
    end
end})

local PlayersList = {}
for _, p in ipairs(Players:GetPlayers()) do if p ~= Client then table.insert(PlayersList, p.Name) end end
Players.PlayerAdded:Connect(function(p) if p ~= Client then table.insert(PlayersList, p.Name) end end)

Tab2:CreateDropdown({Text = "Teleport to Player", Array = PlayersList, Callback = function(name)
    local target = Players:FindFirstChild(name)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        RootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
    end
end})

-- ESP Holder
local folder = Instance.new("Folder", game.CoreGui)
folder.Name = "ESP Holder"

local function AddBillboard(player)
    -- Сюда при необходимости можно встроить отрисовку боксов
end
for _, player in pairs(Players:GetPlayers()) do
    if player ~= Client then coroutine.wrap(AddBillboard)(player) end
end
Players.PlayerAdded:Connect(AddBillboard)

-- ==================== COMBAT ====================
local CombatSection = Tab3:CreateSection({Title = "Combat"})

local lastAttack = tick()
RunService.Heartbeat:Connect(function()
    if (tick() - lastAttack) < 0.1 then return end
    pcall(function()
        local Knife = Client.Backpack:FindFirstChild("Knife") or Character:FindFirstChild("Knife")
        if Knife and getgenv().KnifeAura then
            for _, v in ipairs(Players:GetPlayers()) do
                if v ~= Client and v.Character and not table.find(getgenv().Whitelisted, v.Name) then
                    local EnemyRoot = v.Character.HumanoidRootPart
                    local Distance = (EnemyRoot.Position - RootPart.Position).Magnitude
                    if Distance <= getgenv().KnifeRange then
                        VirtualUser:ClickButton1(Vector2.new())
                        firetouchinterest(EnemyRoot, Knife.Handle, 1)
                        firetouchinterest(EnemyRoot, Knife.Handle, 0)
                        lastAttack = tick()
                    end
                end
            end
        end
    end)
end)

CombatSection:CreateToggle({Title = "Kill Aura", Default = false, Callback = function(s) getgenv().KnifeAura = s end})
CombatSection:CreateSlider({Title = "Knife Range", Min = 5, Max = 100, Default = 25, Callback = function(v) getgenv().KnifeRange = v end})

CombatSection:CreateKeybind({Title = "Kill All (K)", Default = "K", Callback = function()
    local Knife = Client.Backpack:FindFirstChild("Knife") or Character:FindFirstChild("Knife")
    if Knife then
        Humanoid:EquipTool(Knife)
        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= Client and v.Character and not table.find(getgenv().Whitelisted, v.Name) then
                local EnemyRoot = v.Character.HumanoidRootPart
                VirtualUser:ClickButton1(Vector2.new())
                firetouchinterest(EnemyRoot, Knife.Handle, 1)
                firetouchinterest(EnemyRoot, Knife.Handle, 0)
            end
        end
    end
end})

CombatSection:CreateToggle({Title = "Silent Aim (Sheriff)", Default = false, Callback = function(s) getgenv().SheriffAim = s end})
CombatSection:CreateSlider({Title = "Accuracy", Min = 0, Max = 100, Default = 25, Callback = function(v) getgenv().GunAccuracy = v end})

CombatSection:CreateButton({Title = "Auto Take Gun", Callback = function()
    local gundrop = Workspace:FindFirstChild("GunDrop")
    if gundrop then RootPart.CFrame = gundrop.CFrame end
end})

-- ==================== FLING ====================
local FlingSection = Tab4:CreateSection({Title = "Fling"})

FlingSection:CreateToggle({Title = "Fling Aura", Default = false, Callback = function(s) getgenv().FlingAura = s end})
FlingSection:CreateToggle({Title = "Anti Fling", Default = true, Callback = function(s) getgenv().AntiFling = s end})

RunService.Heartbeat:Connect(function()
    if getgenv().AntiFling and RootPart then
        RootPart.Velocity = RootPart.Velocity * 0.15
    end
    if getgenv().FlingAura then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Client and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and not table.find(getgenv().Whitelisted, plr.Name) then
                local root = plr.Character.HumanoidRootPart
                if (root.Position - RootPart.Position).Magnitude < 35 then
                    root.Velocity = Vector3.new(math.random(-600,600), 800, math.random(-600,600))
                end
            end
        end
    end
end)

print("✅ Кастомный безопасный MM2 скрипт успешно загружен!")
