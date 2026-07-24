repeat wait() until game:IsLoaded()
local Library = loadstring(game:HttpGetAsync("https://githubusercontent.com", true))()
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Client = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = Client:GetMouse()
local Character, RootPart, Humanoid
getgenv().WS = 16
getgenv().JP = 50
getgenv().FlySpeed = 60
getgenv().KnifeRange = 25
getgenv().GunAccuracy = 25
getgenv().Whitelisted = {}

local function SetCharVars()
 Character = Client.Character or Client.CharacterAdded:Wait()
 Humanoid = Character:WaitForChild("Humanoid")
 RootPart = Character:WaitForChild("HumanoidRootPart")
 Humanoid.WalkSpeed = getgenv().WS
 Humanoid.JumpPower = getgenv().JP
end
SetCharVars()
Client.CharacterAdded:Connect(SetCharVars)

-- ==================== UI ====================
local Window = Library:CreateWindow({Title = "My MM2 Script"})
local Tab1 = Window:CreateTab({Title = "Main"})
local Tab2 = Window:CreateTab({Title = "World"})
local Tab3 = Window:CreateTab({Title = "Combat"})
local Tab4 = Window:CreateTab({Title = "Fling"})

-- ==================== MAIN ====================
local MainSection = Tab1:CreateSection({Title = "Client"})
MainSection:CreateToggle({Title = "CTRL + Click TP", Default = false, Callback = function(s) getgenv().ClickTP = s end})

Mouse.Button1Down:Connect(function()
 if not (UIS:IsKeyDown(Enum.KeyCode.LeftControl) and getgenv().ClickTP) then return end
 if Mouse.Target then RootPart.CFrame = CFrame.new(Mouse.Hit.p + Vector3.new(0,3,0)) end
end)

MainSection:CreateSlider({Title = "WalkSpeed", Min = 16, Max = 200, Default = 16, Callback = function(v) getgenv().WS = v; if Humanoid then Humanoid.WalkSpeed = v end end})
MainSection:CreateSlider({Title = "JumpPower", Min = 50, Max = 200, Default = 50, Callback = function(v) getgenv().JP = v; if Humanoid then Humanoid.JumpPower = v end end})

-- Fly
local flying = false
local bv, bav
MainSection:CreateToggle({Title = "Fly", Default = false, Callback = function(s)
 getgenv().Flying = s
 if s then
 flying = true
 Humanoid.PlatformStand = true
 bv = Instance.new("BodyVelocity", RootPart)
 bav = Instance.new("BodyAngularVelocity", RootPart)
 bv.MaxForce = Vector3.new(1e5,1e5,1e5)
 bav.MaxTorque = Vector3.new(1e5,1e5,1e5)
 else
 flying = false
 if bv then bv:Destroy() end
 if bav then bav:Destroy() end
 Humanoid.PlatformStand = false
 end
end})

MainSection:CreateSlider({Title = "Fly Speed", Min = 20, Max = 150, Default = 60, Callback = function(v) getgenv().FlySpeed = v end})

RunService.Heartbeat:Connect(function(step)
 if flying and RootPart then
 local move = Vector3.new()
 local cf = Camera.CFrame
 if UIS:IsKeyDown(Enum.KeyCode.W) then move += cf.LookVector end
 if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cf.LookVector end
 if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cf.RightVector end
 if UIS:IsKeyDown(Enum.KeyCode.D) then move += cf.RightVector end
 if move.Magnitude > 0 then
 bv.Velocity = move.Unit * getgenv().FlySpeed
 else
 bv.Velocity = Vector3.new()
 end
 end
end)

MainSection:CreateButton({Title = "Godmode", Callback = function()
 pcall(function()
 local hum = Character:FindFirstChild("Humanoid")
 if hum then
 hum.Name = "boop"
 local new = hum:Clone()
 new.Parent = Character
 new.Name = "Humanoid"
 hum:Destroy()
 Camera.CameraSubject = new
 end
 end)
end})

-- ==================== AUTOFARM ПЛАВНЫЙ ====================
local AutoSection = Tab2:CreateSection({Title = "Autofarm"})
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

-- ==================== TELEPORT + ESP ====================
local PlayersList = {}
for _, p in ipairs(Players:GetPlayers()) do if p ~= Client then table.insert(PlayersList, p.Name) end end
Players.PlayerAdded:Connect(function(p) if p ~= Client then table.insert(PlayersList, p.Name) end end)

Tab2:CreateDropdown({Text = "Teleport to Player", Array = PlayersList, Callback = function(name)
 local target = Players:FindFirstChild(name)
 if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
 RootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
 end
end})

-- ESP
local folder = Instance.new("Folder", game.CoreGui)
folder.Name = "ESP Holder"
local function AddBillboard(player)
 -- Сюда можно добавить логику ESP, если потребуется
end
for _,player in pairs(Players:GetPlayers()) do
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

-- Silent Aim
CombatSection:CreateToggle({Title = "Silent Aim (Sheriff)", Default = false, Callback = function(s) getgenv().SheriffAim = s end})
CombatSection:CreateSlider({Title = "Accuracy", Min = 0, Max = 100, Default = 25, Callback = function(v) getgenv().GunAccuracy = v end})

-- Auto Take Gun
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

print("✅ Полный персональный скрипт загружен!")
