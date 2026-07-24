repeat task.wait() until game:IsLoaded()

-- Защита от вылета (Anti-AFK)
pcall(function()
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end)
end)

-- ЗАГРУЗКА СОВРЕМЕННОЙ И РАБОЧЕЙ БИБЛИОТЕКИ ORION
local OrionLib = loadstring(game:HttpGet(('https://githubusercontent.com')))()

local Workspace = game:GetService('Workspace')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService('Players')
local Client = Players.LocalPlayer
local RunService = game:GetService('RunService')
local SoundService = game:GetService("SoundService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")

local Character, RootPart, Humanoid
getgenv().RadioBypass = false
getgenv().KnifeAura = false
getgenv().KnifeRange = 25
getgenv().GunESP = false
getgenv().SheriffAim = false
getgenv().GunAccuracy = 25
getgenv().AllEsp = false
getgenv().MurderEsp = false
getgenv().SheriffEsp = false
getgenv().Autofarm = false
getgenv().AutofarmMethod = "Coins"
getgenv().Whitelisted = {}

local Murderer, Sheriff = nil, nil

local function SetCharVars()
    Character = Client.Character or Client.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
end
SetCharVars()
Client.CharacterAdded:Connect(SetCharVars)

-- Поиск ролей
function GetMurderer()
    for _, v in pairs(Players:GetChildren()) do 
        if v:FindFirstChild("Backpack") and (v.Backpack:FindFirstChild("Knife") or (v.Character and v.Character:FindFirstChild("Knife"))) then
            return v.Name
        end
    end
    return nil
end

function GetSheriff()
    for _, v in pairs(Players:GetChildren()) do 
        if v:FindFirstChild("Backpack") and (v.Backpack:FindFirstChild("Gun") or (v.Character and v.Character:FindFirstChild("Gun"))) then
            return v.Name
        end
    end
    return nil
end

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            Murderer = GetMurderer()
            Sheriff = GetSheriff()
        end)
    end
end)

-- СОЗДАНИЕ ОКНА МЕНЮ
local Window = OrionLib:MakeWindow({Name = "Safe MM2 Custom Pro", HidePremium = false, SaveConfig = false, IntroText = "Loading Safe Script..."})

-- Вкладка 1: Главная и Радио
local Tab1 = Window:MakeTab({Name = "Main & Radio", Icon = "rbxassetid://4483345998", PremiumOnly = false})

Tab1:AddToggle({
    Name = "Bypass Radio Mute (Lobby)",
    Default = false,
    Callback = function(state)
        getgenv().RadioBypass = state
    end
})

-- Поток размучивания Радио в Лобби
RunService.Heartbeat:Connect(function()
    if getgenv().RadioBypass then
        pcall(function()
            local radiosFolder = SoundService:FindFirstChild("Radios") or ReplicatedStorage:FindFirstChild("Radios")
            if radiosFolder then
                if radiosFolder:IsA("SoundGroup") and radiosFolder.Volume == 0 then radiosFolder.Volume = 1 end
                for _, sound in ipairs(radiosFolder:GetDescendants()) do
                    if sound:IsA("Sound") and sound.Volume == 0 then sound.Volume = 1 end
                end
            end
            for _, plyr in ipairs(Players:GetPlayers()) do
                if plyr.Character and plyr.Character:FindFirstChild("HumanoidRootPart") then
                    for _, item in ipairs(plyr.Character.HumanoidRootPart:GetChildren()) do
                        if item:IsA("Sound") and item.Volume == 0 then item.Volume = 1 end
                    end
                end
            end
        end)
    end
end)

Tab1:AddButton({
    Name = "Get All Emotes",
    Callback = function()
        pcall(function()
            local EmoteModule = ReplicatedStorage.Modules.EmoteModule
            local Emotes = Client.PlayerGui.MainGUI.Game:FindFirstChild("Emotes")
            local EmoteList = {"headless","zombie","zen","ninja","floss","dab"}
            require(EmoteModule).GeneratePage(EmoteList, Emotes, 'Free Emotes')
        end)
    end
})

-- Вкладка 2: Визуалы и Фарм
local Tab2 = Window:MakeTab({Name = "World & Farm", Icon = "rbxassetid://4483345998", PremiumOnly = false})

local espFolder = Instance.new("Folder", CoreGui)
espFolder.Name = "SafeESPHolder"

local function AddBillboard(player)
    if player == Client then return end
    local billboard = Instance.new("BillboardGui", espFolder)
    billboard.Name = player.Name
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.fromOffset(200, 50)
    billboard.ExtentsOffset = Vector3.new(0, 3, 0)
    billboard.Enabled = false
    
    local textLabel = Instance.new("TextLabel", billboard)
    textLabel.TextSize = 18
    textLabel.Text = player.Name
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.fromScale(1, 1)
    
    task.spawn(function()
        repeat
            task.wait(0.3)
            pcall(function()
                billboard.Adornee = player.Character.Head
                if getgenv().AllEsp then
                    billboard.Enabled = true
                elseif getgenv().MurderEsp and (player.Character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife")) then
                    billboard.Enabled = true
                elseif getgenv().SheriffEsp and (player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun")) then
                    billboard.Enabled = true
                else
                    billboard.Enabled = false
                end

                if player.Character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife") then
                    textLabel.TextColor3 = Color3.new(1, 0, 0)
                elseif player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun") then
                    textLabel.TextColor3 = Color3.new(0, 0, 1)
                else
                    textLabel.TextColor3 = Color3.new(0, 1, 0)
                end
            end)
        until not player.Parent
        billboard:Destroy()
    end)
end

for _, p in pairs(Players:GetPlayers()) do AddBillboard(p) end
Players.PlayerAdded:Connect(AddBillboard)

Tab2:AddToggle({Name = "Player ESP", Default = false, Callback = function(s) getgenv().AllEsp = s end})
Tab2:AddToggle({Name = "Murderer ESP", Default = false, Callback = function(s) getgenv().MurderEsp = s end})
Tab2:AddToggle({Name = "Sheriff ESP", Default = false, Callback = function(s) getgenv().SheriffEsp = s end})

Tab2:AddDropdown({
    Name = "Autofarm Mode",
    Default = "Coins",
    Options = {"XP", "Coins"},
    Callback = function(val) getgenv().AutofarmMethod = val end
})

Tab2:AddToggle({
    Name = "Activate Autofarm",
    Default = false,
    Callback = function(state)
        getgenv().Autofarm = state
        while getgenv().Autofarm do
            task.wait()
            if getgenv().AutofarmMethod == "Coins" then
                local CoinContainer = Workspace:FindFirstChild("CoinContainer", true)
                if CoinContainer and Client.PlayerGui.MainGUI.Game.CashBag.Visible then
                    local coin = CoinContainer:FindFirstChild("Coin_Server")
                    if coin then
                        repeat
                            if not RootPart then break end
                            RootPart.CFrame = CFrame.new(coin.Position - Vector3.new(0, 2.5, 0)) * CFrame.Angles(0, 0, math.rad(180))
                            RunService.Stepped:Wait()
                        until not coin:IsDescendantOf(Workspace) or not getgenv().Autofarm
                        task.wait(1.5)
                    end
                end
            else
                if Client.PlayerGui.MainGUI.Game.CashBag.Visible and RootPart then
                    RootPart.CFrame = CFrame.new(-121.12338256836, 138.27394104004, 38.946128845215)
                end
            end
        end
    end
})

-- Вкладка 3: Бой
local Tab3 = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998", PremiumOnly = false})

Tab3:AddToggle({Name = "Kill Aura (Murderer)", Default = false, Callback = function(s) getgenv().KnifeAura = s end})
Tab3:AddSlider({Name = "Knife Distance", Min = 5, Max = 100, Default = 25, Color = Color3.fromRGB(255,255,255), Increment = 1, ValueName = "studs", Callback = function(v) getgenv().KnifeRange = v end})

local lastAttack = tick()
RunService.Heartbeat:Connect(function()
    if (tick() - lastAttack) < 0.1 or not getgenv().KnifeAura then return end
    pcall(function()
        local Knife = Client.Backpack:FindFirstChild("Knife") or Character:FindFirstChild("Knife")
        if Knife and RootPart then
            for _, v in ipairs(Players:GetPlayers()) do
                if v ~= Client and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    local EnemyRoot = v.Character.HumanoidRootPart
                    if (EnemyRoot.Position - RootPart.Position).Magnitude <= getgenv().KnifeRange then
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

Tab3:AddToggle({Name = "Silent Aim (Sheriff)", Default = false, Callback = function(s) getgenv().SheriffAim = s end})
Tab3:AddToggle({Name = "Gun Drop ESP", Default = false, Callback = function(s) getgenv().GunESP = s end})

-- Подсветка пистолета
local GunHighlight = Instance.new("Highlight", CoreGui)
GunHighlight.FillColor = Color3.fromRGB(248, 241, 174)
GunHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

RunService.RenderStepped:Connect(function()
    pcall(function()
        local gundrop = Workspace:FindFirstChild("GunDrop")
        -- Корректное завершение функции RenderStepped для подсветки пистолета
        GunHighlight.Adornee = gundrop;
        GunHighlight.Enabled = getgenv().GunESP or false;
    end)
end);

-- Кнопка быстрой телепортации к выпавшему пистолету
Tab3:AddBind({
    Name = "Instant Teleport to Gun",
    Default = Enum.KeyCode.Y,
    Hold = false,
    Callback = function()
        local gundrop = Workspace:FindFirstChild("GunDrop")
        if gundrop and RootPart then
            local oldCF = RootPart.CFrame
            repeat
                RootPart.CFrame = gundrop.CFrame
                task.wait()
            until not Workspace:FindFirstChild("GunDrop")
            RootPart.CFrame = oldCF
        end
    end
})

-- Инициализация библиотеки интерфейса Orion
OrionLib:Init()
