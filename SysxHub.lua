--[[
================================================================
 SYSX HUB | Freemium Version | v0.1 | Created by Ramanotsugarr
 Full Feature + Fixed Farm Level + ESP Distance|Name
================================================================
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

local CONFIG = {
    Name = "SysxHub",
    Build = "SysxHub v0.1 | Freemium | Created by Ramanotsugarr",
    Logo = "rbxassetid://78595907369123",
    OpenClose = "rbxassetid://70792832229220",
    Discord = "https://discord.gg/E5kQJW3hn",
    Background = Color3.fromRGB(10,8,18),
    Panel = Color3.fromRGB(17,13,29),
    Panel2 = Color3.fromRGB(23,18,38),
    Blue = Color3.fromRGB(0,150,255),
    Blue2 = Color3.fromRGB(80,180,255),
    White = Color3.fromRGB(255,255,255),
    Radius = 8,
    TweenMobSpeed = 300,
}

local State = {
    AutoFarm=false, AutoChest=false, AutoBoss=false,
    AutoFruit=false, AutoKillNearest=false, AutoRaid=false,
    AutoGacha=false, StoreFruit=false, AutoFish=false, AutoAddStats=false,
    AutoRaceV2=false, AutoRaceV3=false, CousinBuy=false,
    AutoFarmSea=false, AutoKillSeaBeast=false,
    AutoBuyBoat=false, AutoRemoveRock=false,
    FindMirage=false, FindKitsune=false, KitsuneLevel=35,
    FindPrehistoric=false, AutoKillGolem=false,
    AutoCollectBone=false, AutoCollectDinoEgg=false,
    FindFrozenDim=false, AutoHitLeviathan=false,
    AutoShootHeart=false, AutoDriveTiki=false,
    BoatSpeed=100, BoatHeight=5,
    SelectedWeapon=nil, SelectedCategory=nil,
    SelectedBoss=nil, SelectedRaid=nil, SelectedPlayer=nil,
    SelectedIsland="Starter Island", SelectedMelee=nil, SelectedSword=nil,
    SelectedGun=nil, SelectedAbility=nil, SelectedItem=nil,
    SelectedSeaMob="Sea Beast",
    BringMob=false, BringMobRange=50, InfiniteJump=false, BoostFPS=false,
    Hitbox=false, HitboxPart=nil, Aimbot=false,
    LastBring=0, AntiAFK=true, Notifications=true,
    StatsMelee=0, StatsSword=0, StatsGun=0, StatsBloxFruit=0,
    OriginalLighting=nil, FirstRunChest=true, UncheckedChests={},
    ESPPlayer=false, ESPIsland=false, ESPFruit=false, ESPBlueGear=false,
    ESPChest=false, ESPFlower=false, ESPObjects={},
}

local old = PlayerGui:FindFirstChild("SysxHub")
if old then old:Destroy() end

--// HELPERS
local function Create(cls, props)
    local o = Instance.new(cls)
    for k,v in pairs(props or {}) do pcall(function() o[k]=v end) end
    return o
end
local function Corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or CONFIG.Radius)
    c.Parent = p
    return c
end
local function Stroke(p, c, t, tr)
    local s = Instance.new("UIStroke")
    s.Color = c or CONFIG.Blue
    s.Thickness = t or 1.5
    s.Transparency = tr or 0
    s.Parent = p
    return s
end
local function Gradient(p, c1, c2, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1 or CONFIG.Blue, c2 or CONFIG.Blue2)
    g.Rotation = rot or 45
    g.Parent = p
    return g
end
local function Tween(o, props, time)
    TweenService:Create(o, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end
local function GetHRP()
    local c = Player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function GetDist(a, b) return (a - b).Magnitude end
local function SafeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[SysxHub]", err) return false end
    return true
end

--// REMOTE
local CommF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
local function Invoke(...)
    if not CommF then return nil end
    local ok, res = pcall(function(...) return CommF:InvokeServer(...) end, ...)
    if not ok then return nil end
    return res
end

--// NPC FILTER
local PASSIVE = {"dealer","shop","vendor","merchant","quest","giver","bartender","chef","captain","scientist","teacher","guide","trainer","banker","blacksmith","smith","farmer","villager","elder"}

local function IsNPC(m)
    if not m or m == Player.Character then return false end
    local hum = m:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    if not m:FindFirstChild("HumanoidRootPart") then return false end
    if Players:GetPlayerFromCharacter(m) then return false end
    if hum.Health <= 0 or hum.MaxHealth <= 0 then return false end
    if hum.WalkSpeed <= 0 then return false end
    local n = string.lower(m.Name)
    for _, kw in ipairs(PASSIVE) do
        if string.find(n, kw) then return false end
    end
    return true
end

local function ScanEnemies()
    local list = {}
    for _, obj in ipairs(workspace:GetChildren()) do
        if IsNPC(obj) then table.insert(list, obj) end
    end
    return list
end

local function FindBoss(name)
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name == name and obj:FindFirstChildOfClass("Humanoid") then return obj end
    end
    return nil
end

local function FindMobByName(mobs)
    for _, name in ipairs(mobs) do
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj.Name == name then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 then return obj end
            end
        end
    end
    return nil
end

local function FindFruits()
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "fruit") then
            if obj.Parent == workspace or (obj.Parent and obj.Parent.Name == "Map") then
                table.insert(list, obj)
            end
        end
    end
    return list
end

local function GetHeldFruit()
    local char = Player.Character
    if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and string.find(string.lower(tool.Name), "fruit") then
            return tool
        end
    end
    return nil
end

--// FARM CHEST
local MaxSpeed = 300
local function getCharacter()
    if not Player.Character then Player.CharacterAdded:Wait() end
    Player.Character:WaitForChild("HumanoidRootPart")
    return Player.Character
end
local function toggleNoclip(toggle)
    for _, v in pairs(getCharacter():GetChildren()) do
        if v:IsA("BasePart") then v.CanCollide = not toggle end
    end
end
local function DistanceFromPlrSort(list)
    local root = getCharacter().HumanoidRootPart
    table.sort(list, function(a, b)
        return (root.Position - a.Position).Magnitude < (root.Position - b.Position).Magnitude
    end)
end
local function getChestsSorted()
    if State.FirstRunChest then
        State.FirstRunChest = false
        State.UncheckedChests = {}
        for _, obj in ipairs(game:GetDescendants()) do
            if obj.Name:find("Chest") and obj.ClassName == "Part" then
                table.insert(State.UncheckedChests, obj)
            end
        end
    end
    local chests = {}
    for _, chest in ipairs(State.UncheckedChests) do
        if chest:FindFirstChild("TouchInterest") then table.insert(chests, chest) end
    end
    DistanceFromPlrSort(chests)
    return chests
end
local function TeleportNoclip(goal, speed)
    speed = speed or MaxSpeed
    toggleNoclip(true)
    local root = getCharacter().HumanoidRootPart
    local mag = (root.Position - goal.Position).Magnitude
    while not (mag < 1) do
        if not State.AutoChest then break end
        local dir = (goal.Position - root.Position).unit
        root.CFrame = root.CFrame + dir * (speed * task.wait())
        mag = (root.Position - goal.Position).Magnitude
    end
    toggleNoclip(false)
end

--// WEAPON
local function EquipWeapon()
    local char = Player.Character
    if not char then return nil end
    if State.SelectedWeapon then
        local held = char:FindFirstChild(State.SelectedWeapon)
        if held and held:IsA("Tool") then return held end
        for _, c in ipairs(Player.Backpack:GetChildren()) do
            if c:IsA("Tool") and c.Name == State.SelectedWeapon then c.Parent = char return c end
        end
    end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then return tool end
    for _, c in ipairs(Player.Backpack:GetChildren()) do
        if c:IsA("Tool") then c.Parent = char return c end
    end
    return nil
end

--// TWEEN
local function TweenToPosition(targetPos, speed)
    local hrp = GetHRP()
    if not hrp then return end
    speed = speed or 150
    local startCF = hrp.CFrame
    local targetCF = CFrame.new(targetPos)
    local distance = (startCF.Position - targetCF.Position).Magnitude
    if distance < 1 then return end
    local duration = distance / speed
    local elapsed = 0
    local conn
    conn = RunService.Heartbeat:Connect(function(dt)
        elapsed += dt
        local alpha = math.clamp(elapsed / duration, 0, 1)
        hrp.CFrame = startCF:Lerp(targetCF, alpha)
        if alpha >= 1 then conn:Disconnect() end
    end)
    task.wait(duration + 0.05)
end

--// ESP
local function CreateESP(target, text, color)
    if not target or not target:IsA("BasePart") then return end
    if State.ESPObjects[target] then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "SysxESP"
    bb.Size = UDim2.new(0, 140, 0, 30)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = target
    local label = Instance.new("TextLabel")
    label.Name = "ESPLabel"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or CONFIG.White
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = bb
    State.ESPObjects[target] = bb
end
local function ClearAllESP()
    for target, bb in pairs(State.ESPObjects) do
        pcall(function() bb:Destroy() end)
    end
    State.ESPObjects = {}
end

--// SMOOTH AIMBOT
local AimbotConnection = nil
local function GetClosestPlayerHead()
    local closest, dist = nil, math.huge
    local camPos = Camera.CFrame.Position
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local d = (head.Position - camPos).Magnitude
                if d < dist and d < 500 then closest, dist = head, d end
            end
        end
    end
    return closest
end
local function StartAimbot()
    if AimbotConnection then AimbotConnection:Disconnect() end
    AimbotConnection = RunService.RenderStepped:Connect(function(dt)
        if not State.Aimbot then return end
        local tgt = GetClosestPlayerHead()
        if not tgt then return end
        local curCF = Camera.CFrame
        local tgtCF = CFrame.new(curCF.Position, tgt.Position)
        Camera.CFrame = curCF:Lerp(tgtCF, math.clamp(dt * 10, 0, 1))
    end)
end
local function StopAimbot()
    if AimbotConnection then AimbotConnection:Disconnect() AimbotConnection = nil end
end

--// LEVEL DATA
local LEVEL_DATA = {
    {min=1,   max=10,  quest="BanditQuest1",     questNum=1, mobs={"Bandit","Trainee"}},
    {min=10,  max=30,  quest="JungleQuest",      questNum=1, mobs={"Monkey","Gorilla"}},
    {min=30,  max=60,  quest="BuggyQuest1",      questNum=1, mobs={"Pirate","Brute"}},
    {min=60,  max=90,  quest="DesertQuest",      questNum=1, mobs={"Desert Bandit","Desert Officer"}},
    {min=90,  max=120, quest="SnowQuest",        questNum=1, mobs={"Snow Bandit","Snowman"}},
    {min=120, max=150, quest="MarineQuest2",     questNum=1, mobs={"Chief Petty Officer"}},
    {min=150, max=190, quest="SkyQuest",         questNum=1, mobs={"Sky Bandit","Dark Master"}},
    {min=190, max=250, quest="PrisonQuest",      questNum=1, mobs={"Prisoner","Dangerous Prisoner"}},
    {min=250, max=300, quest="ColosseumQuest",   questNum=1, mobs={"Toga Warrior","Gladiator"}},
    {min=300, max=375, quest="MagmaQuest",       questNum=1, mobs={"Military Soldier","Military Spy"}},
    {min=375, max=450, quest="FishmanQuest",     questNum=1, mobs={"Fishman Warrior","Fishman Commando"}},
    {min=450, max=625, quest="SkyExp1Quest",     questNum=1, mobs={"God's Guard","Shandia","Royal Squad","Royal Soldier"}},
    {min=625, max=700, quest="FountainQuest",    questNum=1, mobs={"Pirate Millionaire","Pistol Billionaire"}},
    {min=700, max=875, quest="Area1Quest",       questNum=1, mobs={"Raider","Mercenary","Swan Pirate"}},
    {min=875, max=950, quest="Area2Quest",       questNum=1, mobs={"Marine Soldier","Marine Commando"}},
    {min=950, max=1000,quest="GraveyardQuest",   questNum=1, mobs={"Zombie","Vampire"}},
    {min=1000,max=1100,quest="SnowMountainQuest",questNum=1, mobs={"Snow Trooper","Winter Warrior"}},
    {min=1100,max=1250,quest="PunkHazardQuest",  questNum=1, mobs={"Lab Subordinate","Horned Riot","Magma Ninja","Lava Pirate"}},
    {min=1250,max=1350,quest="CursedShipQuest",  questNum=1, mobs={"Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer"}},
    {min=1350,max=1425,quest="IceCastleQuest",   questNum=1, mobs={"Arctic Warrior","Snow Lurker"}},
    {min=1425,max=1500,quest="ForgottenQuest",   questNum=1, mobs={"Sea Soldier","Water Tiger"}},
    {min=1500,max=1575,quest="PortQuest",        questNum=1, mobs={"Pirate Millionaire","Pistol Billionaire"}},
    {min=1575,max=1700,quest="HydraQuest",       questNum=1, mobs={"Dragon Crew Warrior","Dragon Crew Archer"}},
    {min=1700,max=1775,quest="GreatTreeQuest",   questNum=1, mobs={"Marine Commodore","Marine Rear Admiral"}},
    {min=1775,max=1975,quest="ForestQuest",      questNum=1, mobs={"Fishman Raider","Fishman Captain","Forest Pirate","Mythological Pirate","Jungle Pirate"}},
    {min=1975,max=2075,quest="HauntedQuest",     questNum=1, mobs={"Reborn Skeleton","Living Zombie","Demonic Soul","Possessed Mummy"}},
    {min=2075,max=2450,quest="CakeQuest",        questNum=1, mobs={"Cake Guard","Cake Baking","Cocoa Warrior","Chocolate Bar Battler","Candy Pirate"}},
    {min=2450,max=2600,quest="TikiQuest",        questNum=1, mobs={"Isle Outlaw","Island Boy","Sun-kissed Warrior","Isle Champion","Serpent Hunter"}},
    {min=2600,max=2800,quest="SubmergedQuest",   questNum=1, mobs={"Reef Bandit","Coral Pirate","Sea Chanter","Ocean Prophet"}},
}

local function GetLevel()
    local ls = Player:FindFirstChild("leaderstats")
    local lv = ls and ls:FindFirstChild("Level")
    return lv and lv.Value or 1
end
local function GetLevelData(level)
    for _, data in ipairs(LEVEL_DATA) do
        if level >= data.min and level < data.max then return data end
    end
    return LEVEL_DATA[#LEVEL_DATA]
end

--// GUI
local Gui = Create("ScreenGui", {
    Name="SysxHub", Parent=PlayerGui, ResetOnSpawn=false,
    IgnoreGuiInset=true, DisplayOrder=999999,
    ZIndexBehavior=Enum.ZIndexBehavior.Global,
})

local Notification = Create("TextLabel", {
    Parent=Gui, AnchorPoint=Vector2.new(0.5,1),
    Position=UDim2.new(0.5,0,1,-20), Size=UDim2.fromOffset(340,44),
    BackgroundColor3=CONFIG.Panel, BackgroundTransparency=0.05,
    Text="", TextColor3=CONFIG.White, TextSize=13,
    Font=Enum.Font.GothamMedium, Visible=false, ZIndex=500,
})
Corner(Notification, 10)
Stroke(Notification, CONFIG.Blue, 1.5, 0.3)

local NT = 0
function Notify(text)
    if not State.Notifications then return end
    NT += 1
    local tk = NT
    Notification.Text = tostring(text)
    Notification.Visible = true
    Notification.TextTransparency = 1
    Notification.BackgroundTransparency = 1
    Tween(Notification, {TextTransparency=0, BackgroundTransparency=0.05}, 0.2)
    task.delay(2.5, function()
        if tk ~= NT then return end
        Tween(Notification, {TextTransparency=1, BackgroundTransparency=1}, 0.2)
        task.wait(0.2)
        if tk == NT then Notification.Visible = false end
    end)
end

local UIScale = Instance.new("UIScale")
UIScale.Scale = 1
UIScale.Parent = Gui
local function UpdateScale()
    if not Camera then return end
    local vp = Camera.ViewportSize
    if vp.X <= 500 then UIScale.Scale = math.clamp(vp.X/420, 0.82, 1)
    elseif vp.X <= 800 then UIScale.Scale = 0.9
    else UIScale.Scale = 1 end
end
UpdateScale()
if Camera then Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale) end

local OpenButton = Create("ImageButton", {
    Parent=Gui, BackgroundColor3=CONFIG.Panel,
    Size=UDim2.fromOffset(64,64), Position=UDim2.new(0,18,0.5,-32),
    Image=CONFIG.OpenClose, ImageColor3=CONFIG.White,
    AutoButtonColor=false, Visible=true, ZIndex=100,
})
Corner(OpenButton, 16)
Stroke(OpenButton, CONFIG.Blue, 2.5, 0.1)
Gradient(OpenButton, CONFIG.Blue, CONFIG.Blue2, 45)

local Main = Create("Frame", {
    Parent=Gui, AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.5,0.5), Size=UDim2.new(0,760,0,480),
    BackgroundColor3=CONFIG.Background, BorderSizePixel=0, Visible=true, ZIndex=10,
})
Corner(Main, 14)
Stroke(Main, CONFIG.Blue, 2, 0.2)

local TopBar = Create("Frame", {
    Parent=Main, BackgroundColor3=CONFIG.Panel,
    Size=UDim2.new(1,0,0,64), BorderSizePixel=0, ZIndex=20,
})
Corner(TopBar, 14)
Gradient(TopBar, CONFIG.Panel, CONFIG.Panel2, 0)

local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 48, 0, 48)
Logo.Position = UDim2.new(0, 10, 0.5, -24)
Logo.BackgroundTransparency = 1
Logo.Image = CONFIG.Logo
Logo.ImageColor3 = CONFIG.White
Logo.ScaleType = Enum.ScaleType.Fit
Logo.Parent = TopBar
Logo.ZIndex = 21

Create("TextLabel", {Parent=TopBar, BackgroundTransparency=1, Position=UDim2.new(0,66,0,8), Size=UDim2.new(0,300,0,25), Text="SysxHub", TextColor3=CONFIG.White, TextSize=20, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=21})
Create("TextLabel", {Parent=TopBar, BackgroundTransparency=1, Position=UDim2.new(0,67,0,33), Size=UDim2.new(0,400,0,18), Text=CONFIG.Build, TextColor3=CONFIG.White, TextSize=11, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=21})

-- Close Button pakai Logo
local CloseButton = Create("ImageButton", {
    Parent=TopBar, BackgroundColor3=CONFIG.Panel2,
    Size=UDim2.fromOffset(38,38), Position=UDim2.new(1,-50,0.5,-19),
    Image=CONFIG.Logo, ImageColor3=CONFIG.White,
    AutoButtonColor=false, ZIndex=25,
})
Corner(CloseButton, 10)
Stroke(CloseButton, CONFIG.Blue, 1.5, 0.3)

local Sidebar = Create("Frame", {
    Parent=Main, BackgroundColor3=CONFIG.Panel,
    Position=UDim2.new(0,0,0,64), Size=UDim2.new(0,155,1,-64),
    BorderSizePixel=0, ZIndex=15,
})
Corner(Sidebar, 14)

local TabList = Create("ScrollingFrame", {
    Parent=Sidebar, BackgroundTransparency=1,
    Position=UDim2.new(0,8,0,10), Size=UDim2.new(1,-16,1,-20),
    CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ScrollBarThickness=2, ScrollBarImageColor3=CONFIG.Blue, BorderSizePixel=0, ZIndex=16,
})
local TL = Instance.new("UIListLayout")
TL.Padding = UDim.new(0,5)
TL.SortOrder = Enum.SortOrder.LayoutOrder
TL.Parent = TabList

local Content = Create("Frame", {
    Parent=Main, BackgroundTransparency=1,
    Position=UDim2.new(0,155,0,64), Size=UDim2.new(1,-155,1,-64),
    BorderSizePixel=0, ZIndex=11,
})

local Pages, Tabs = {}, {}

local function CreatePage(name)
    local P = Create("ScrollingFrame", {
        Name=name, Parent=Content, BackgroundTransparency=1,
        Position=UDim2.new(0,10,0,10), Size=UDim2.new(1,-20,1,-20),
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollBarThickness=3, ScrollBarImageColor3=CONFIG.Blue,
        BorderSizePixel=0, Visible=false, ZIndex=12,
    })
    local L = Instance.new("UIListLayout")
    L.Padding = UDim.new(0,6)
    L.SortOrder = Enum.SortOrder.LayoutOrder
    L.Parent = P
    Pages[name] = P
    return P
end

local function CreateToggle(parent, text, default, cb)
    local S2 = default or false
    local B = Create("TextButton", {
        Parent=parent, BackgroundColor3=CONFIG.Panel,
        Size=UDim2.new(1,0,0,42), Text="",
        AutoButtonColor=false, BorderSizePixel=0, ZIndex=13,
    })
    Corner(B, 8)
    Stroke(B, CONFIG.Blue, 1.2, 0.4)
    Create("TextLabel", {Parent=B, BackgroundTransparency=1, Position=UDim2.new(0,12,0,0), Size=UDim2.new(1,-70,1,0), Text=text, TextColor3=CONFIG.White, TextSize=13, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14})
    local Ind = Create("Frame", {Parent=B, BackgroundColor3=Color3.fromRGB(55,50,65), Size=UDim2.fromOffset(38,20), Position=UDim2.new(1,-52,0.5,-10), ZIndex=14})
    Corner(Ind, 20)
    local Dot = Create("Frame", {Parent=Ind, BackgroundColor3=Color3.fromRGB(190,185,200), Size=UDim2.fromOffset(14,14), Position=UDim2.new(0,3,0.5,-7), ZIndex=15})
    Corner(Dot, 20)
    local function Update()
        if S2 then
            Ind.BackgroundColor3 = CONFIG.Blue
            Dot.BackgroundColor3 = CONFIG.White
            Tween(Dot, {Position=UDim2.new(1,-17,0.5,-7)}, 0.15)
        else
            Ind.BackgroundColor3 = Color3.fromRGB(55,50,65)
            Dot.BackgroundColor3 = Color3.fromRGB(190,185,200)
            Tween(Dot, {Position=UDim2.new(0,3,0.5,-7)}, 0.15)
        end
    end
    B.Activated:Connect(function()
        S2 = not S2
        Update()
        if cb then pcall(cb, S2) end
    end)
    Update()
    return B
end

local function CreateDropdown(parent, title, options, cb)
    local Holder = Create("Frame", {
        Parent=parent, BackgroundColor3=CONFIG.Panel,
        Size=UDim2.new(1,0,0,42), BorderSizePixel=0,
        ZIndex=13, ClipsDescendants=false,
    })
    Corner(Holder, 8)
    Stroke(Holder, CONFIG.Blue, 1.2, 0.4)
    local Selected = options[1] or "Select"
    local IsOpen = false
    local TitleLbl = Create("TextLabel", {Parent=Holder, BackgroundTransparency=1, Position=UDim2.new(0,12,0,0), Size=UDim2.new(1,-40,1,0), Text=title..": "..Selected, TextColor3=CONFIG.White, TextSize=13, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14})
    Create("TextLabel", {Parent=Holder, BackgroundTransparency=1, Position=UDim2.new(1,-25,0,0), Size=UDim2.new(0,20,1,0), Text="v", TextColor3=CONFIG.White, TextSize=12, Font=Enum.Font.GothamBold, ZIndex=14})
    local ListHolder = Create("ScrollingFrame", {
        Parent=Holder, BackgroundColor3=CONFIG.Panel2,
        Position=UDim2.new(0,0,1,4), Size=UDim2.new(1,0,0,0),
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollBarThickness=3, ScrollBarImageColor3=CONFIG.Blue, BorderSizePixel=0, ZIndex=200, Visible=false,
    })
    Corner(ListHolder, 8)
    Stroke(ListHolder, CONFIG.Blue, 1.2, 0.3)
    local LL = Instance.new("UIListLayout")
    LL.Padding = UDim.new(0,4)
    LL.SortOrder = Enum.SortOrder.LayoutOrder
    LL.Parent = ListHolder
    local function Refresh()
        for _, c in ipairs(ListHolder:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for i, opt in ipairs(options) do
            local OB = Create("TextButton", {
                Parent=ListHolder, BackgroundColor3=CONFIG.Panel,
                Size=UDim2.new(1,-8,0,32),
                Position=UDim2.new(0,4,0,4),
                Text=opt, TextColor3=CONFIG.White, TextSize=12,
                Font=Enum.Font.GothamMedium, AutoButtonColor=false,
                BorderSizePixel=0, LayoutOrder=i, ZIndex=201,
                TextXAlignment=Enum.TextXAlignment.Left,
            })
            Corner(OB, 6)
            OB.Activated:Connect(function()
                Selected = opt
                TitleLbl.Text = title..": "..opt
                ListHolder.Visible = false
                ListHolder.Size = UDim2.new(1,0,0,0)
                IsOpen = false
                if cb then pcall(cb, opt) end
            end)
        end
    end
    Holder.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if IsOpen then
                ListHolder.Visible = false
                ListHolder.Size = UDim2.new(1,0,0,0)
                IsOpen = false
            else
                Refresh()
                local h = math.min(#options*36+8, 200)
                ListHolder.Size = UDim2.new(1,0,0,h)
                ListHolder.Visible = true
                IsOpen = true
            end
        end
    end)
    return Holder
end

local function CreateSlider(parent, title, minVal, maxVal, defaultVal, cb)
    local val = defaultVal or minVal
    local Holder = Create("Frame", {
        Parent=parent, BackgroundColor3=CONFIG.Panel,
        Size=UDim2.new(1,0,0,50), BorderSizePixel=0, ZIndex=13,
    })
    Corner(Holder, 8)
    Stroke(Holder, CONFIG.Blue, 1.2, 0.4)
    Create("TextLabel", {Parent=Holder, BackgroundTransparency=1, Position=UDim2.new(0,12,0,5), Size=UDim2.new(1,-80,0,16), Text=title, TextColor3=CONFIG.White, TextSize=12, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14})
    local ValueLbl = Create("TextLabel", {Parent=Holder, BackgroundTransparency=1, Position=UDim2.new(1,-70,0,5), Size=UDim2.new(0,60,0,16), Text=tostring(val), TextColor3=CONFIG.White, TextSize=12, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Right, ZIndex=14})
    local Bar = Create("Frame", {Parent=Holder, BackgroundColor3=CONFIG.Panel2, Position=UDim2.new(0,12,0,30), Size=UDim2.new(1,-24,0,8), BorderSizePixel=0, ZIndex=14})
    Corner(Bar, 4)
    local Fill = Create("Frame", {Parent=Bar, BackgroundColor3=CONFIG.Blue, Size=UDim2.new((val-minVal)/(maxVal-minVal),0,1,0), BorderSizePixel=0, ZIndex=15})
    Corner(Fill, 4)
    local Btn = Create("TextButton", {Parent=Holder, BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Text="", AutoButtonColor=false, ZIndex=16})
    local dragging = false
    local function Update(mouseX)
        local abs = Bar.AbsolutePosition
        local size = Bar.AbsoluteSize
        local rel = math.clamp((mouseX-abs.X)/size.X, 0, 1)
        val = math.floor(minVal + (maxVal-minVal)*rel + 0.5)
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        ValueLbl.Text = tostring(val)
        if cb then pcall(cb, val) end
    end
    Btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            Update(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Update(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return Holder
end

local function CreateLabel(parent, text, size)
    local L = Create("TextLabel", {
        Parent=parent, BackgroundColor3=CONFIG.Panel,
        Size=UDim2.new(1,0,0,size or 38),
        Text=text, TextColor3=CONFIG.White, TextSize=12,
        Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left,
        BorderSizePixel=0, ZIndex=13,
    })
    Corner(L, 8)
    Stroke(L, CONFIG.Blue, 1.2, 0.4)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 12)
    pad.Parent = L
    return L
end

local function CreateTab(name, order)
    local B = Create("TextButton", {
        Parent=TabList, BackgroundColor3=CONFIG.Panel,
        Size=UDim2.new(1,0,0,38), Text="",
        AutoButtonColor=false, BorderSizePixel=0,
        LayoutOrder=order, ZIndex=17,
    })
    Corner(B, 8)
    local L = Create("TextLabel", {Parent=B, BackgroundTransparency=1, Position=UDim2.new(0,10,0,0), Size=UDim2.new(1,-20,1,0), Text=name, TextColor3=CONFIG.White, TextSize=12, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=18})
    Tabs[name] = {Button=B, Label=L}
    return B
end

local function ShowTab(name)
    for pn, p in pairs(Pages) do p.Visible = (pn == name) end
    for tn, d in pairs(Tabs) do
        if tn == name then d.Button.BackgroundColor3 = CONFIG.Blue
        else d.Button.BackgroundColor3 = CONFIG.Panel end
        d.Label.TextColor3 = CONFIG.White
    end
end

--// PAGES
local DiscordPage = CreatePage("Discord")
local FarmPage = CreatePage("Farm")
local SeaPage = CreatePage("Sea")
local QuestItemsPage = CreatePage("Quest / Items")
local FruitRaidPage = CreatePage("Fruit / Raid")
local FishingPage = CreatePage("Fishing")
local StatusPage = CreatePage("Status")
local PvPPage = CreatePage("PvP")
local TrialsPage = CreatePage("Trials")
local SetingPage = CreatePage("Seting")
local TeleportPage = CreatePage("Teleport")
local StatsPage = CreatePage("Stats")
local ShopPage = CreatePage("Shop")
local MiscPage = CreatePage("Misc")

--// DISCORD
CreateToggle(DiscordPage, "Copy Discord Link", false, function(s)
    if s then if setclipboard then setclipboard(CONFIG.Discord) Notify("Copied") end end
end)

--// FARM
CreateDropdown(FarmPage, "Select Weapon", {"Melee","Sword","Gun","Fruit"}, function(opt) State.SelectedCategory = opt end)
CreateToggle(FarmPage, "Auto Farm Level", false, function(s)
    State.AutoFarm = s
    Notify("Auto Farm: "..(s and "ON" or "OFF"))
    if s then
        State.Hitbox = true
        task.spawn(function()
            while State.AutoFarm do
                pcall(function() Invoke("Buso") end)
                task.wait(2)
            end
        end)
    else State.Hitbox = false end
end)
CreateToggle(FarmPage, "Auto Kill Nearest", false, function(s)
    State.AutoKillNearest = s
    Notify("Auto Kill Nearest: "..(s and "ON" or "OFF"))
    if s then
        task.spawn(function()
            while State.AutoKillNearest do
                pcall(function() Invoke("Buso") end)
                task.wait(2)
            end
        end)
    end
end)
CreateToggle(FarmPage, "Farm Chest", false, function(s)
    State.AutoChest = s
    if s then State.FirstRunChest = true State.UncheckedChests = {} end
    Notify("Farm Chest: "..(s and "ON" or "OFF"))
end)
CreateDropdown(FarmPage, "Select Boss", {
    "Gorilla King","Bobby","Yeti","Mob Leader","Vice Admiral","Saber Expert",
    "Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper",
    "Thunder God","Cyborg","Diamond","Jeremy","Fajita","Don Swan","Darkbeard",
    "Smoke Admiral","Cursed Captain","Awakened Ice Admiral","Tide Keeper",
    "Stone","Island Empress","Kilo Admiral","Captain Elephant",
    "Beautiful Pirate","Longma","Cake Queen",
}, function(opt) State.SelectedBoss = opt Notify("Boss: "..opt) end)
CreateToggle(FarmPage, "Auto Farm Boss", false, function(s) State.AutoBoss = s Notify("Auto Farm Boss: "..(s and "ON" or "OFF")) end)
local BonesLabel = CreateLabel(FarmPage, "Bones: -", 38)
task.spawn(function()
    while task.wait(3) do
        local res = Invoke("Bones", "Check")
        if res then BonesLabel.Text = "Bones: "..tostring(res) end
    end
end)
CreateToggle(FarmPage, "Random Bone", false, function(s) if s then Invoke("Bones", "Buy", 1, 1) Notify("Random Bone") end end)

--// SEA
CreateDropdown(SeaPage, "Select Mob", {"Sea Beast","Terrorshark","Shark","Piranha","Fish Crew Member","Fish Crew Warrior"}, function(opt) State.SelectedSeaMob = opt Notify("Sea Mob: "..opt) end)
CreateToggle(SeaPage, "Auto Farm Sea", false, function(s) State.AutoFarmSea = s Notify("Auto Farm Sea: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Start Sea Event", false, function(s)
    if s then
        pcall(function() Invoke("SeaEvent", "Start") end)
        Notify("Sea Event started")
    end
end)
CreateToggle(SeaPage, "Auto Buy New Boat", false, function(s) State.AutoBuyBoat = s Notify("Auto Buy Boat: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Auto Remove Rock", false, function(s) State.AutoRemoveRock = s Notify("Auto Remove Rock: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Find Mirage Island", false, function(s) State.FindMirage = s Notify("Find Mirage: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Tween Mirage", false, function(s)
    if s then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "mirage") then
                TweenToPosition(obj.Position + Vector3.new(0,5,0), 500) Notify("Tween Mirage") break
            end
        end
    end
end)
CreateToggle(SeaPage, "Tween Blue Gear", false, function(s)
    if s then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "bluegear") or string.find(string.lower(obj.Name), "blue_gear")) then
                TweenToPosition(obj.Position + Vector3.new(0,5,0), 500) Notify("Tween Blue Gear") break
            end
        end
    end
end)
CreateToggle(SeaPage, "Tween Fruit Dealer", false, function(s)
    if s then TweenToPosition(Vector3.new(1138, 22, 1480), 500) Notify("Tween Fruit Dealer") end
end)
CreateToggle(SeaPage, "Find Kitsune Island", false, function(s) State.FindKitsune = s Notify("Find Kitsune: "..(s and "ON" or "OFF")) end)
CreateSlider(SeaPage, "Kitsune Level", 0, 300, 35, function(v) State.KitsuneLevel = v Notify("Kitsune Level: "..v) end)
CreateToggle(SeaPage, "Auto Trade Aura", false, function(s)
    if s then pcall(function() Invoke("KitsuneTrade", "Aura") end) Notify("Auto Trade Aura") end
end)
CreateToggle(SeaPage, "Find Prehistoric Island", false, function(s) State.FindPrehistoric = s Notify("Find Prehistoric: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Auto Kill Golem", false, function(s) State.AutoKillGolem = s Notify("Auto Kill Golem: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Auto Collect Bone", false, function(s) State.AutoCollectBone = s Notify("Auto Collect Bone: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Auto Collect Dino Egg", false, function(s) State.AutoCollectDinoEgg = s Notify("Auto Collect Dino Egg: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Find Frozen Dimension", false, function(s) State.FindFrozenDim = s Notify("Find Frozen Dim: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Auto Hit Leviathan", false, function(s) State.AutoHitLeviathan = s Notify("Auto Hit Leviathan: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Auto Shoot Heart", false, function(s) State.AutoShootHeart = s Notify("Auto Shoot Heart: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Auto Drive To Tiki", false, function(s) State.AutoDriveTiki = s Notify("Auto Drive Tiki: "..(s and "ON" or "OFF")) end)
CreateSlider(SeaPage, "Boat Speed", 0, 250, 100, function(v) State.BoatSpeed = v end)
CreateSlider(SeaPage, "Boat Height", 0, 50, 5, function(v) State.BoatHeight = v end)

--// QUEST / ITEMS
CreateToggle(QuestItemsPage, "Auto Sea 2", false, function(s) if s then Invoke("TravelDressrosa") Notify("Auto Sea 2") end end)
CreateToggle(QuestItemsPage, "Auto Sea 3", false, function(s) if s then Invoke("TravelZou") Notify("Auto Sea 3") end end)
CreateToggle(QuestItemsPage, "Auto Saber", false, function(s) if s then Invoke("BuyItem", "Saber") Notify("Auto Saber") end end)
CreateToggle(QuestItemsPage, "Auto CDK", false, function(s) if s then Invoke("ProQuestProgress", "CDK") Notify("CDK") end end)
CreateToggle(QuestItemsPage, "Auto Dark Dagger", false, function(s)
    if s then
        local hasChalice = Player.Backpack:FindFirstChild("God's Chalice") or (Player.Character and Player.Character:FindFirstChild("God's Chalice"))
        if hasChalice then Invoke("PlaceChalice") Notify("Summoning Indra") else Notify("Need God's Chalice!") end
    end
end)
CreateToggle(QuestItemsPage, "Auto Soul Guitar", false, function(s) if s then Invoke("ProQuestProgress", "SoulGuitar") Notify("Soul Guitar") end end)
CreateToggle(QuestItemsPage, "Auto Yama", false, function(s) if s then Invoke("StartQuest", "EliteHunter", 1) Notify("Elite Hunter") end end)
CreateToggle(QuestItemsPage, "Auto Tushita", false, function(s) if s then Invoke("ProQuestProgress", "Tushita") Notify("Tushita") end end)
CreateToggle(QuestItemsPage, "Auto Buddy Sword", false, function(s)
    if s then
        local boss = FindBoss("Cake Queen")
        if boss then TweenToPosition(boss.HumanoidRootPart.Position + Vector3.new(0,3,0), 300) Notify("Farming Cake Queen") else Notify("Cake Queen not spawned") end
    end
end)
CreateToggle(QuestItemsPage, "Auto Spawn Dough King", false, function(s)
    if s then
        local hasSweet = Player.Backpack:FindFirstChild("Sweet Chalice") or (Player.Character and Player.Character:FindFirstChild("Sweet Chalice"))
        if hasSweet then Invoke("DoughKing") Notify("Summoning Dough King") else Notify("Need Sweet Chalice!") end
    end
end)
CreateToggle(QuestItemsPage, "Abandon Quest", false, function(s) if s then Invoke("AbandonQuest") Notify("Abandoned") end end)
CreateToggle(QuestItemsPage, "Torch Puzzle Get", false, function(s) if s then Invoke("ProQuestProgress", "GetTorch") Notify("GetTorch") end end)
CreateToggle(QuestItemsPage, "Torch Puzzle Destroy", false, function(s) if s then Invoke("ProQuestProgress", "DestroyTorch") Notify("DestroyTorch") end end)
CreateToggle(QuestItemsPage, "Cup Puzzle Get", false, function(s) if s then Invoke("ProQuestProgress", "GetCup") Notify("GetCup") end end)
CreateToggle(QuestItemsPage, "Cup Puzzle Fill", false, function(s) if s then Invoke("ProQuestProgress", "FillCup") Notify("FillCup") end end)
CreateToggle(QuestItemsPage, "SickMan Quest", false, function(s) if s then Invoke("ProQuestProgress", "SickMan") Notify("SickMan") end end)
CreateToggle(QuestItemsPage, "RichSon Quest", false, function(s) if s then Invoke("ProQuestProgress", "RichSon") Notify("RichSon") end end)
CreateToggle(QuestItemsPage, "CDK Open Door", false, function(s) if s then Invoke("CDKQuest", "OpenDoor") Notify("CDK Door") end end)
CreateToggle(QuestItemsPage, "CDK Progress", false, function(s) if s then Invoke("CDKQuest", "Progress") Notify("CDK Progress") end end)
CreateToggle(QuestItemsPage, "CDK Boat Quest", false, function(s) if s then Invoke("CDKQuest", "BoatQuest") Notify("CDK Boat") end end)
CreateToggle(QuestItemsPage, "Wenlocktoad 1", false, function(s) if s then Invoke("Wenlocktoad", "1") Notify("Wenlock 1") end end)
CreateToggle(QuestItemsPage, "Wenlocktoad 2", false, function(s) if s then Invoke("Wenlocktoad", "2") Notify("Wenlock 2") end end)
CreateToggle(QuestItemsPage, "Alchemist 1", false, function(s) if s then Invoke("Alchemist", "1") Notify("Alchemist 1") end end)
CreateToggle(QuestItemsPage, "Alchemist 2", false, function(s) if s then Invoke("Alchemist", "2") Notify("Alchemist 2") end end)
CreateToggle(QuestItemsPage, "Auto Temple Door", false, function(s) if s then Invoke("CheckTempleDoor") Notify("Temple Door") end end)
CreateToggle(QuestItemsPage, "Auto Bartilo", false, function(s) if s then Invoke("BartiloQuestProgress") Notify("Bartilo") end end)
CreateToggle(QuestItemsPage, "Auto Guitar Puzzle", false, function(s) if s then Invoke("GuitarPuzzleProgress", "Check") Notify("Guitar") end end)
CreateToggle(QuestItemsPage, "Auto Race V2", false, function(s) State.AutoRaceV2 = s Notify("Race V2: "..(s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Race V3", false, function(s) State.AutoRaceV3 = s Notify("Race V3: "..(s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Blackbeard Reward", false, function(s) if s then Invoke("BlackbeardReward", "DragonClaw", "1") Notify("Blackbeard") end end)
CreateToggle(QuestItemsPage, "Auto Horned Man Bet", false, function(s) if s then Invoke("HornedMan", "Bet") Notify("Horned Man") end end)
CreateToggle(QuestItemsPage, "Auto Talk Trevor", false, function(s) if s then Invoke("TalkTrevor", "1") Notify("Trevor") end end)

--// FRUIT / RAID
CreateToggle(FruitRaidPage, "Collect Fruit", false, function(s) State.AutoFruit = s Notify("Collect Fruit: "..(s and "ON" or "OFF")) end)
CreateToggle(FruitRaidPage, "Random Fruit", false, function(s) State.AutoGacha = s Notify("Random Fruit: "..(s and "ON" or "OFF")) end)
CreateToggle(FruitRaidPage, "Store Fruit", false, function(s) State.StoreFruit = s Notify("Store Fruit: "..(s and "ON" or "OFF")) end)
CreateDropdown(FruitRaidPage, "Select Raid", {"Flame","Ice","Sand","Dark","Light","Magma","Quake","Buddha","Spider","Phoenix","Dough"}, function(opt) State.SelectedRaid = opt Notify("Raid: "..opt) end)
CreateToggle(FruitRaidPage, "Auto Raid", false, function(s) State.AutoRaid = s Notify("Auto Raid: "..(s and "ON" or "OFF")) end)
CreateToggle(FruitRaidPage, "Buy Chip", false, function(s)
    if s then
        pcall(function()
            local npc = workspace:FindFirstChild("Mysterious Scientist")
            if npc then
                local cd = npc:FindFirstChildOfClass("ClickDetector")
                if cd then fireclickdetector(cd) end
            end
        end)
        Notify("Buy Chip")
    end
end)
CreateToggle(FruitRaidPage, "Cousin Buy", false, function(s) State.CousinBuy = s Notify("Cousin Buy: "..(s and "ON" or "OFF")) end)

--// FISHING
CreateToggle(FishingPage, "Auto Fishing", false, function(s) State.AutoFish = s Notify("Auto Fishing: "..(s and "ON" or "OFF")) end)

--// STATUS
local StatusLabel = Create("TextLabel", {
    Parent=StatusPage, BackgroundColor3=CONFIG.Panel,
    Size=UDim2.new(1,0,0,120), Text="Loading...",
    TextColor3=CONFIG.White, TextSize=12, Font=Enum.Font.GothamMedium,
    TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
    BorderSizePixel=0, ZIndex=13,
})
Corner(StatusLabel, 8)
Stroke(StatusLabel, CONFIG.Blue, 1.2, 0.4)
local statusPad = Instance.new("UIPadding")
statusPad.PaddingLeft = UDim.new(0, 12) statusPad.PaddingTop = UDim.new(0, 10)
statusPad.Parent = StatusLabel
task.spawn(function()
    while task.wait(1) do
        local ls = Player:FindFirstChild("leaderstats")
        local lv = ls and ls:FindFirstChild("Level")
        if lv then
            local sea = lv.Value >= 1500 and "Sea3" or (lv.Value >= 700 and "Sea2" or "Sea1")
            StatusLabel.Text = string.format("Level: %d\nSea: %s", lv.Value, sea)
        end
    end
end)
CreateToggle(StatusPage, "Get Inventory", false, function(s) if s then Invoke("getInventory") Notify("Inventory") end end)
CreateToggle(StatusPage, "Get Inventory Weapons", false, function(s) if s then Invoke("getInventoryWeapons") Notify("Weapons") end end)
CreateToggle(StatusPage, "Get Titles", false, function(s) if s then Invoke("getTitles") Notify("Titles") end end)
CreateToggle(StatusPage, "Get Unlockables", false, function(s) if s then Invoke("GetUnlockables") Notify("Unlockables") end end)

--// PVP
CreateDropdown(PvPPage, "Select Player", (function()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then table.insert(list, plr.Name) end
    end
    if #list == 0 then list = {"No players"} end
    return list
end)(), function(opt) State.SelectedPlayer = opt Notify("Player: "..opt) end)
CreateToggle(PvPPage, "Teleport Player", false, function(s)
    if s then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Name == State.SelectedPlayer and plr.Character then
                local trp = plr.Character:FindFirstChild("HumanoidRootPart")
                if trp then TweenToPosition(trp.Position + Vector3.new(0,3,5), 150) end
            end
        end
    end
end)
CreateToggle(PvPPage, "Spectate Player", false, function(s)
    if s then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Name == State.SelectedPlayer and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum then Camera.CameraSubject = hum Camera.CameraType = Enum.CameraType.Custom end
            end
        end
    end
end)
CreateToggle(PvPPage, "Stop Spectate", false, function(s)
    if s then
        local char = Player.Character
        if char then local hum = char:FindFirstChildOfClass("Humanoid") if hum then Camera.CameraSubject = hum end end
    end
end)
CreateToggle(PvPPage, "Aimbot", false, function(s)
    State.Aimbot = s
    if s then StartAimbot() else StopAimbot() end
    Notify("Aimbot: "..(s and "ON" or "OFF"))
end)

--// TRIALS
local TrainProgressLabel = CreateLabel(TrialsPage, "Train Progress: -", 38)
task.spawn(function()
    while task.wait(3) do
        local res = Invoke("RaceV4Progress", "Check")
        if res then TrainProgressLabel.Text = "Train Progress: "..tostring(res) end
    end
end)
CreateToggle(TrialsPage, "Great Tree Highest", false, function(s) if s then TweenToPosition(Vector3.new(2700,500,3000),500) end end)
CreateToggle(TrialsPage, "Tween RaceDoor", false, function(s) if s then TweenToPosition(Vector3.new(2830,90,3100),500) end end)
CreateToggle(TrialsPage, "Tween Ancient Clock", false, function(s) if s then TweenToPosition(Vector3.new(-5020,80,-3020),500) end end)
CreateDropdown(TrialsPage, "Select Method", {"Bone","Cake"}, function(opt) State.TrialMethod = opt Notify("Method: "..opt) end)
CreateToggle(TrialsPage, "Finish Trial", false, function(s) if s then Invoke("RaceV4Progress", "Finish") Notify("Finish Trial") end end)
CreateToggle(TrialsPage, "Auto Trial", false, function(s) State.AutoTrial = s Notify("Auto Trial: "..(s and "ON" or "OFF")) end)
CreateToggle(TrialsPage, "Auto Pull Lever", false, function(s) State.AutoPullLever = s Notify("Auto Pull Lever: "..(s and "ON" or "OFF")) end)
CreateToggle(TrialsPage, "Kill Player Trial", false, function(s) State.KillPlayerTrial = s Notify("Kill Player: "..(s and "ON" or "OFF")) end)

--// SETING (ESP)
CreateToggle(SetingPage, "ESP Player", false, function(s) State.ESPPlayer = s Notify("ESP Player: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Island", false, function(s) State.ESPIsland = s Notify("ESP Island: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Fruit", false, function(s) State.ESPFruit = s Notify("ESP Fruit: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Blue Gear", false, function(s) State.ESPBlueGear = s Notify("ESP Blue Gear: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Chest", false, function(s) State.ESPChest = s Notify("ESP Chest: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Flower", false, function(s) State.ESPFlower = s Notify("ESP Flower: "..(s and "ON" or "OFF")) end)

--// TELEPORT
CreateToggle(TeleportPage, "Check Bones", false, function(s)
    if s then local res = Invoke("Bones", "Check") Notify("Bones: "..tostring(res)) end
end)
local IslandCoords = {
    ["Starter Island"]=Vector3.new(1077,15,1450), ["Jungle"]=Vector3.new(-1620,30,200),
    ["Pirate Village"]=Vector3.new(-1100,15,3800), ["Desert"]=Vector3.new(980,15,4200),
    ["Frozen Village"]=Vector3.new(-70,20,-2500), ["Marine Fortress"]=Vector3.new(-5100,20,4050),
    ["Skylands"]=Vector3.new(-4650,850,-3220), ["Prison"]=Vector3.new(4850,15,650),
    ["Colosseum"]=Vector3.new(-1800,50,-3000), ["Magma Village"]=Vector3.new(-5200,20,-300),
    ["Underwater City"]=Vector3.new(6000,-150,3000), ["Fountain City"]=Vector3.new(5600,60,-5000),
    ["Kingdom of Rose"]=Vector3.new(-800,20,1800), ["Green Zone"]=Vector3.new(-2500,30,100),
    ["Graveyard"]=Vector3.new(6500,60,4500), ["Snow Mountain"]=Vector3.new(400,30,-5300),
    ["Hot and Cold"]=Vector3.new(-5500,30,-4000), ["Cursed Ship"]=Vector3.new(923,100,32000),
    ["Ice Castle"]=Vector3.new(5000,60,-6500), ["Forgotten Island"]=Vector3.new(-3050,100,-7500),
    ["Port Town"]=Vector3.new(-290,20,6000), ["Hydra Island"]=Vector3.new(5800,30,-2000),
    ["Great Tree"]=Vector3.new(2700,60,3000), ["Floating Turtle"]=Vector3.new(-1600,60,3500),
    ["Castle on the Sea"]=Vector3.new(-5000,60,-3000), ["Haunted Castle"]=Vector3.new(-9500,100,5800),
}
local SeaIslands = {
    Sea1 = {"Starter Island","Jungle","Pirate Village","Desert","Frozen Village","Marine Fortress","Skylands","Prison","Colosseum","Magma Village","Underwater City","Fountain City"},
    Sea2 = {"Kingdom of Rose","Green Zone","Graveyard","Snow Mountain","Hot and Cold","Cursed Ship","Ice Castle","Forgotten Island"},
    Sea3 = {"Port Town","Hydra Island","Great Tree","Floating Turtle","Castle on the Sea","Haunted Castle"},
}
CreateDropdown(TeleportPage, "Select Sea", {"Sea1","Sea2","Sea3"}, function(opt) end)
CreateDropdown(TeleportPage, "Select Island", SeaIslands.Sea1, function(opt) State.SelectedIsland = opt Notify("Island: "..opt) end)
CreateToggle(TeleportPage, "Tween ke Island", false, function(s)
    if s then
        local pos = IslandCoords[State.SelectedIsland]
        if pos then TweenToPosition(pos + Vector3.new(0,3,0), 500) Notify("Tween: "..State.SelectedIsland) end
    end
end)
CreateToggle(TeleportPage, "Sea 1", false, function(s) if s then Invoke("TravelMain") Notify("Sea 1") end end)
CreateToggle(TeleportPage, "Sea 2", false, function(s) if s then Invoke("TravelDressrosa") Notify("Sea 2") end end)
CreateToggle(TeleportPage, "Sea 3", false, function(s) if s then Invoke("TravelZou") Notify("Sea 3") end end)

--// STATS
CreateToggle(StatsPage, "Auto Add Stats", false, function(s) State.AutoAddStats = s Notify("Auto Add Stats: "..(s and "ON" or "OFF")) end)
CreateSlider(StatsPage, "Melee", 0, 100, 0, function(v) State.StatsMelee = v end)
CreateSlider(StatsPage, "Sword", 0, 100, 0, function(v) State.StatsSword = v end)
CreateSlider(StatsPage, "Gun", 0, 100, 0, function(v) State.StatsGun = v end)
CreateSlider(StatsPage, "Fruit", 0, 100, 0, function(v) State.StatsBloxFruit = v end)
CreateToggle(StatsPage, "Apply Stats Now", false, function(s)
    if s then
        local stats = {
            {Name="Melee", Value=State.StatsMelee},
            {Name="Sword", Value=State.StatsSword},
            {Name="Gun", Value=State.StatsGun},
            {Name="Blox Fruit", Value=State.StatsBloxFruit},
        }
        for _, st in ipairs(stats) do
            if st.Value > 0 then Invoke("AddPoint", st.Name, st.Value) task.wait(0.3) end
        end
        Notify("Stats applied")
    end
end)

--// SHOP
CreateDropdown(ShopPage, "Select Melee", {"Black Leg","Electro","Fishman Karate","Sharkman Karate","Dragon Talon","Electric Claw","Death Step","Superhuman","Godhuman"}, function(opt) State.SelectedMelee = opt Notify("Melee: "..opt) end)
CreateToggle(ShopPage, "Buy Selected Melee", false, function(s)
    if s then
        local map = {["Black Leg"]="BuyBlackLeg",["Electro"]="BuyElectro",["Fishman Karate"]="BuyFishmanKarate",["Sharkman Karate"]="BuySharkmanKarate",["Dragon Talon"]="BuyDragonTalon",["Electric Claw"]="BuyElectricClaw",["Death Step"]="BuyDeathStep",["Superhuman"]="BuySuperhuman",["Godhuman"]="BuyGodhuman"}
        local fn = map[State.SelectedMelee]
        if fn then Invoke(fn) Notify("Bought: "..State.SelectedMelee) else Notify("Select melee first") end
    end
end)
CreateDropdown(ShopPage, "Select Sword", {"Katana","Cutlass","Iron Mace","Dual Katana","Triple Katana","Pipe","Small Sword","Dual-Headed Blade","Soul Cane","Saber","Rengoku","Shisui","Yama","Tushita","Cursed Dual Katana","Dark Dagger","Buddy Sword","Hallow Scythe","Spikey Trident","Trident"}, function(opt) State.SelectedSword = opt Notify("Sword: "..opt) end)
CreateToggle(ShopPage, "Buy Selected Sword", false, function(s)
    if s and State.SelectedSword then Invoke("BuyItem", State.SelectedSword) Notify("Bought: "..State.SelectedSword)
    elseif s then Notify("Select sword first") end
end)
CreateDropdown(ShopPage, "Select Gun", {"Slingshot","Flintlock","Refined Flintlock","Musket","Refined Musket","Cannon","Bazooka","Sniper","Kabucha","Acidum Rifle","Bizarre Rifle","Serpent Bow"}, function(opt) State.SelectedGun = opt Notify("Gun: "..opt) end)
CreateToggle(ShopPage, "Buy Selected Gun", false, function(s)
    if s and State.SelectedGun then Invoke("BuyItem", State.SelectedGun) Notify("Bought: "..State.SelectedGun)
    elseif s then Notify("Select gun first") end
end)
CreateDropdown(ShopPage, "Select Abilities", {"Ken","Buso","Geppo"}, function(opt) State.SelectedAbility = opt Notify("Ability: "..opt) end)
CreateToggle(ShopPage, "Buy Selected Ability", false, function(s)
    if s then
        if State.SelectedAbility == "Ken" then Invoke("KenTalk", "Buy")
        elseif State.SelectedAbility == "Buso" then Invoke("BuyHaki", "Buso")
        elseif State.SelectedAbility == "Geppo" then Invoke("BuyHaki", "Geppo") end
        Notify("Bought: "..tostring(State.SelectedAbility))
    end
end)
CreateToggle(ShopPage, "Buy Soru", false, function(s) if s then Invoke("BuyHaki", "Soru") Notify("Soru bought") end end)

--// MISC
CreateToggle(MiscPage, "Anti AFK", true, function(s) State.AntiAFK = s Notify("Anti AFK: "..(s and "ON" or "OFF")) end)
CreateToggle(MiscPage, "Bring Mob", false, function(s) State.BringMob = s Notify("Bring Mob: "..(s and "ON" or "OFF")) end)
CreateSlider(MiscPage, "Bring Mob Range", 0, 100, 50, function(v) State.BringMobRange = v end)
CreateToggle(MiscPage, "Infinite Jump", false, function(s) State.InfiniteJump = s Notify("Infinite Jump: "..(s and "ON" or "OFF")) end)
CreateToggle(MiscPage, "Boost FPS", false, function(s)
    State.BoostFPS = s
    if s then
        pcall(function()
            State.OriginalLighting = {GlobalShadows=Lighting.GlobalShadows, Brightness=Lighting.Brightness, Ambient=Lighting.Ambient}
            Lighting.GlobalShadows = false Lighting.Brightness = 0
            Lighting.Ambient = Color3.fromRGB(0,0,0) Lighting.FogEnd = 100 Lighting.Outlines = false
        end)
        Notify("Boost FPS: ON")
    else
        if State.OriginalLighting then
            pcall(function()
                Lighting.GlobalShadows = State.OriginalLighting.GlobalShadows
                Lighting.Brightness = State.OriginalLighting.Brightness
                Lighting.Ambient = State.OriginalLighting.Ambient
            end)
        end
        Notify("Boost FPS: OFF")
    end
end)
CreateToggle(MiscPage, "Redeem All Codes", false, function(s)
    if s then
        local codes = {"KITT_RESET","SUB2GAMERROBOT_RESET1","SUB2GAMERROBOT_EXP1","SUB2OFFICIALNOOBIE","AXIORE","BLUXXY","JCWK","KITTGAMING","MAGICBUS","STARCODEHEO","STRAWHATMAINE","TANTAIGAMING","THEGREATACE","ENYU_IS_PRO"}
        for _, code in ipairs(codes) do Invoke("Redeem", code) Notify("Redeeming: "..code) task.wait(1) end
    end
end)
CreateToggle(MiscPage, "Rejoin Server", false, function(s) if s then TeleportService:Teleport(game.PlaceId, Player) end end)
CreateToggle(MiscPage, "Join Marine", false, function(s) if s then Invoke("SetTeam", "Marines") Notify("Joined Marines") end end)
CreateToggle(MiscPage, "Join Pirate", false, function(s) if s then Invoke("SetTeam", "Pirates") Notify("Joined Pirates") end end)

--// ============== LOOPS ==============

-- AUTO FARM LEVEL
task.spawn(function()
    while task.wait(0.15) do
        if State.AutoFarm then
            SafeCall(function()
                local level = GetLevel()
                local data = GetLevelData(level)
                if not data then return end
                
                if CommF then pcall(function() CommF:InvokeServer("StartQuest", data.quest, data.questNum) end) end
                
                local target = FindMobByName(data.mobs)
                if target then
                    local trp = target:FindFirstChild("HumanoidRootPart")
                    local hum = target:FindFirstChildOfClass("Humanoid")
                    if trp and hum and hum.Health > 0 then
                        local hrp = GetHRP()
                        if not hrp then return end
                        if GetDist(hrp.Position, trp.Position) > 15 then TweenToPosition(trp.Position + Vector3.new(0,3,0), 350) end
                        
                        if not State.HitboxPart or not State.HitboxPart.Parent then
                            local hb = Instance.new("Part")
                            hb.Name = "SysxHitbox" hb.Size = Vector3.new(30,30,30)
                            hb.Transparency = 1 hb.CanCollide = false hb.CanTouch = true
                            hb.Anchored = true hb.Massless = true hb.Parent = workspace
                            State.HitboxPart = hb
                        end
                        State.HitboxPart.CFrame = CFrame.new(trp.Position)
                        
                        local tool = EquipWeapon()
                        if tool then pcall(function() tool:Activate() end) end
                    end
                end
            end)
        else
            if State.HitboxPart then State.HitboxPart:Destroy() State.HitboxPart = nil end
        end
    end
end)

-- AUTO KILL NEAREST
task.spawn(function()
    while task.wait(0.15) do
        if State.AutoKillNearest then
            SafeCall(function()
                local hrp = GetHRP()
                if not hrp then return end
                local closest, dist = nil, math.huge
                for _, mob in ipairs(ScanEnemies()) do
                    local trp = mob:FindFirstChild("HumanoidRootPart")
                    if trp then
                        local d = GetDist(trp.Position, hrp.Position)
                        if d < 100 and d < dist then closest, dist = mob, d end
                    end
                end
                if closest then
                    local trp = closest:FindFirstChild("HumanoidRootPart")
                    local tool = EquipWeapon()
                    if tool then
                        if dist > 15 then TweenToPosition(trp.Position + Vector3.new(0,3,0), 350) end
                        pcall(function() tool:Activate() end)
                    end
                end
            end)
        end
    end
end)

-- FARM CHEST
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoChest then
            SafeCall(function()
                local chests = getChestsSorted()
                if #chests > 0 then TeleportNoclip(chests[1].CFrame)
                else Notify("Chest habis, tunggu respawn") task.wait(5) State.FirstRunChest = true State.UncheckedChests = {} end
            end)
        end
    end
end)

-- AUTO BOSS
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoBoss and State.SelectedBoss then
            SafeCall(function()
                local boss = FindBoss(State.SelectedBoss)
                if boss then
                    local trp = boss:FindFirstChild("HumanoidRootPart")
                    local hum = boss:FindFirstChildOfClass("Humanoid")
                    if trp and hum and hum.Health > 0 then
                        TweenToPosition(trp.Position + Vector3.new(0,3,0), 300)
                        local tool = EquipWeapon()
                        if tool then
                            local timeout = 0
                            while boss.Parent and hum.Health > 0 and State.AutoBoss and timeout < 100 do
                                pcall(function() tool:Activate() end)
                                task.wait(0.15)
                                timeout += 1
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- AUTO FARM SEA / KILL SEA BEAST / EXTRA
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoFarmSea and State.SelectedSeaMob then
            SafeCall(function()
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj.Name == State.SelectedSeaMob then
                        local hum = obj:FindFirstChildOfClass("Humanoid")
                        local trp = obj:FindFirstChild("HumanoidRootPart")
                        if hum and trp and hum.Health > 0 then
                            TweenToPosition(trp.Position + Vector3.new(0,3,0), 400)
                            local tool = EquipWeapon()
                            if tool then pcall(function() tool:Activate() end) end
                            break
                        end
                    end
                end
            end)
        end
        if State.AutoBuyBoat then
            SafeCall(function()
                local hasBoat = false
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj.Name == "Boat" and obj:FindFirstChildOfClass("VehicleSeat") then hasBoat = true break end
                end
                if not hasBoat then Invoke("BuyBoat", "Dinghy") end
            end)
        end
        if State.AutoRemoveRock then
            SafeCall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "rock") then
                        local hrp = GetHRP()
                        if hrp and GetDist(obj.Position, hrp.Position) < 50 then pcall(function() obj:Destroy() end) end
                    end
                end
            end)
        end
        if State.AutoKillGolem then
            SafeCall(function()
                for _, obj in ipairs(workspace:GetChildren()) do
                    if string.find(string.lower(obj.Name), "golem") then
                        local hum = obj:FindFirstChildOfClass("Humanoid")
                        local trp = obj:FindFirstChild("HumanoidRootPart")
                        if hum and trp and hum.Health > 0 then
                            TweenToPosition(trp.Position + Vector3.new(0,3,0), 400)
                            local tool = EquipWeapon()
                            if tool then pcall(function() tool:Activate() end) end
                            break
                        end
                    end
                end
            end)
        end
        if State.AutoCollectBone or State.AutoCollectDinoEgg then
            SafeCall(function()
                local keywords = {}
                if State.AutoCollectBone then table.insert(keywords, "bone") end
                if State.AutoCollectDinoEgg then table.insert(keywords, "dino") table.insert(keywords, "egg") end
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        local n = string.lower(obj.Name)
                        for _, kw in ipairs(keywords) do
                            if string.find(n, kw) and obj:FindFirstChild("TouchInterest") then
                                local hrp = GetHRP()
                                if hrp then TweenToPosition(obj.Position + Vector3.new(0,3,0), 400) end
                                break
                            end
                        end
                    end
                end
            end)
        end
        if State.AutoHitLeviathan then
            SafeCall(function()
                for _, obj in ipairs(workspace:GetChildren()) do
                    if string.find(string.lower(obj.Name), "leviathan") then
                        local trp = obj:FindFirstChild("HumanoidRootPart")
                        if trp then
                            TweenToPosition(trp.Position + Vector3.new(0,3,0), 400)
                            local tool = EquipWeapon()
                            if tool then pcall(function() tool:Activate() end) end
                            break
                        end
                    end
                end
            end)
        end
        if State.AutoShootHeart then
            SafeCall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "heart") then
                        if obj:FindFirstChild("TouchInterest") then
                            local hrp = GetHRP()
                            if hrp then TweenToPosition(obj.Position + Vector3.new(0,3,0), 400) end
                        end
                    end
                end
            end)
        end
        if State.FindMirage then
            SafeCall(function()
                for _, obj in ipairs(workspace:GetChildren()) do
                    if string.find(string.lower(obj.Name), "mirage") then Notify("Mirage found!") State.FindMirage = false break end
                end
            end)
        end
        if State.FindKitsune then
            SafeCall(function()
                for _, obj in ipairs(workspace:GetChildren()) do
                    if string.find(string.lower(obj.Name), "kitsune") then
                        local lvl = obj:GetAttribute("Level") or 0
                        if lvl >= State.KitsuneLevel then Notify("Kitsune found! Lv "..lvl) State.FindKitsune = false break end
                    end
                end
            end)
        end
        if State.FindPrehistoric then
            SafeCall(function()
                for _, obj in ipairs(workspace:GetChildren()) do
                    if string.find(string.lower(obj.Name), "prehistoric") or string.find(string.lower(obj.Name), "dino") then Notify("Prehistoric found!") State.FindPrehistoric = false break end
                end
            end)
        end
        if State.FindFrozenDim then
            SafeCall(function()
                for _, obj in ipairs(workspace:GetChildren()) do
                    if string.find(string.lower(obj.Name), "frozen") or string.find(string.lower(obj.Name), "dimension") then Notify("Frozen Dim found!") State.FindFrozenDim = false break end
                end
            end)
        end
    end
end)

-- AUTO FRUIT
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoFruit then
            SafeCall(function()
                local hrp = GetHRP()
                if not hrp then return end
                local nearest, nd = nil, math.huge
                for _, f in ipairs(FindFruits()) do
                    local d = GetDist(f.Position, hrp.Position)
                    if d < 500 and d < nd then nearest, nd = f, d end
                end
                if nearest then TweenToPosition(nearest.Position + Vector3.new(0, 3, 0), 400) end
            end)
        end
    end
end)

-- AUTO GACHA
task.spawn(function()
    while task.wait(60) do
        if State.AutoGacha then SafeCall(function() if not GetHeldFruit() then Invoke("BuyFruit", "Random") end end) end
    end
end)

-- AUTO STORE FRUIT
task.spawn(function()
    while task.wait(1.5) do
        if State.StoreFruit then
            SafeCall(function()
                local held = GetHeldFruit()
                if held then Invoke("StoreFruit", held.Name, held) Notify("Stored: "..held.Name) end
            end)
        end
    end
end)

-- AUTO RAID
task.spawn(function()
    while task.wait(10) do
        if State.AutoRaid and State.SelectedRaid then
            SafeCall(function()
                Invoke("RaidsNpc", "Select", State.SelectedRaid)
                task.wait(0.5)
                pcall(function() fireclickdetector(workspace.Map.CircleIsland.RaidSummon.Button.Main.ClickDetector) end)
                Notify("Raid: "..State.SelectedRaid)
            end)
        end
    end
end)

-- AUTO ADD STATS
task.spawn(function()
    while task.wait(3) do
        if State.AutoAddStats then
            SafeCall(function()
                local stats = {
                    {Name="Melee", Value=State.StatsMelee},
                    {Name="Sword", Value=State.StatsSword},
                    {Name="Gun", Value=State.StatsGun},
                    {Name="Blox Fruit", Value=State.StatsBloxFruit},
                }
                for _, st in ipairs(stats) do
                    if st.Value > 0 then Invoke("AddPoint", st.Name, st.Value) task.wait(0.3) end
                end
            end)
        end
    end
end)

-- COUSIN BUY
task.spawn(function()
    while task.wait(1) do
        if State.CousinBuy then SafeCall(function() Invoke("Cousin", "Buy") end) end
    end
end)

-- INFINITE JUMP
task.spawn(function()
    while task.wait(0.1) do
        if State.InfiniteJump then
            local char = Player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum:GetState() == Enum.HumanoidStateType.Freefall then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end
    end
end)

-- BRING MOB
task.spawn(function()
    while task.wait(0.1) do
        if State.BringMob or State.AutoFarm then
            local now = os.clock()
            if now - State.LastBring >= 0.3 then
                local hrp = GetHRP()
                if hrp then
                    local targetPos = hrp.Position + hrp.CFrame.LookVector * 6
                    for _, model in ipairs(workspace:GetChildren()) do
                        if IsNPC(model) then
                            local mRoot = model:FindFirstChild("HumanoidRootPart")
                            if mRoot and GetDist(mRoot.Position, hrp.Position) <= (State.BringMobRange or 50) then
                                pcall(function() mRoot.CFrame = CFrame.new(targetPos) end)
                            end
                        end
                    end
                end
                State.LastBring = now
            end
        end
    end
end)

-- ESP LOOP (Distance | Name)
task.spawn(function()
    while task.wait(0.3) do
        local hrp = GetHRP()
        local myPos = hrp and hrp.Position or Vector3.new(0,0,0)
        
        if State.ESPPlayer then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= Player and plr.Character then
                    local trp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if trp then
                        local dist = math.floor((trp.Position - myPos).Magnitude)
                        local text = dist.." | "..plr.Name
                        CreateESP(trp, text, Color3.fromRGB(255,80,80))
                        if State.ESPObjects[trp] then
                            local lbl = State.ESPObjects[trp]:FindFirstChild("ESPLabel")
                            if lbl then lbl.Text = text end
                        end
                    end
                end
            end
        end
        if State.ESPFruit then
            for _, obj in ipairs(FindFruits()) do
                local dist = math.floor((obj.Position - myPos).Magnitude)
                local text = dist.." | "..obj.Name
                CreateESP(obj, text, Color3.fromRGB(255,200,80))
                if State.ESPObjects[obj] then
                    local lbl = State.ESPObjects[obj]:FindFirstChild("ESPLabel")
                    if lbl then lbl.Text = text end
                end
            end
        end
        if State.ESPChest then
            for _, obj in ipairs(getChestsSorted()) do
                local dist = math.floor((obj.Position - myPos).Magnitude)
                local text = dist.." | Chest"
                CreateESP(obj, text, Color3.fromRGB(255,215,0))
                if State.ESPObjects[obj] then
                    local lbl = State.ESPObjects[obj]:FindFirstChild("ESPLabel")
                    if lbl then lbl.Text = text end
                end
            end
        end
        if State.ESPIsland then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = string.lower(obj.Name)
                    if string.find(n,"island") or string.find(n,"portal") or string.find(n,"teleport") then
                        local dist = math.floor((obj.Position - myPos).Magnitude)
                        local text = dist.." | "..obj.Name
                        CreateESP(obj, text, Color3.fromRGB(80,200,255))
                        if State.ESPObjects[obj] then
                            local lbl = State.ESPObjects[obj]:FindFirstChild("ESPLabel")
                            if lbl then lbl.Text = text end
                        end
                    end
                end
            end
        end
        if State.ESPBlueGear then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = string.lower(obj.Name)
                    if string.find(n,"bluegear") or string.find(n,"blue_gear") or string.find(n,"gear") then
                        local dist = math.floor((obj.Position - myPos).Magnitude)
                        local text = dist.." | Blue Gear"
                        CreateESP(obj, text, Color3.fromRGB(0,150,255))
                        if State.ESPObjects[obj] then
                            local lbl = State.ESPObjects[obj]:FindFirstChild("ESPLabel")
                            if lbl then lbl.Text = text end
                        end
                    end
                end
            end
        end
        if State.ESPFlower then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = string.lower(obj.Name)
                    if string.find(n,"flower") or string.find(n,"blossom") or string.find(n,"petal") then
                        local dist = math.floor((obj.Position - myPos).Magnitude)
                        local text = dist.." | "..obj.Name
                        CreateESP(obj, text, Color3.fromRGB(255,100,200))
                        if State.ESPObjects[obj] then
                            local lbl = State.ESPObjects[obj]:FindFirstChild("ESPLabel")
                            if lbl then lbl.Text = text end
                        end
                    end
                end
            end
        end
        if not State.ESPPlayer and not State.ESPIsland and not State.ESPFruit
        and not State.ESPBlueGear and not State.ESPChest and not State.ESPFlower then
            ClearAllESP()
        end
    end
end)

--// TABS
local TabDefs = {
    {"Discord"}, {"Farm"}, {"Sea"}, {"Quest / Items"}, {"Fruit / Raid"},
    {"Fishing"}, {"Status"}, {"PvP"}, {"Trials"}, {"Seting"},
    {"Teleport"}, {"Stats"}, {"Shop"}, {"Misc"},
}
for i, d in ipairs(TabDefs) do
    local btn = CreateTab(d[1], i)
    btn.Activated:Connect(function() ShowTab(d[1]) end)
end

CloseButton.Activated:Connect(function() Main.Visible=false OpenButton.Visible=true end)
OpenButton.Activated:Connect(function() Main.Visible=true OpenButton.Visible=false end)

local dragging, dragStart, startPos = false, nil, nil
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UIS.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - dragStart
    Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end)

Player.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

ShowTab("Farm")

print("================================")
print("        SYSX HUB v0.1 FREEMIUM")
print("        "..CONFIG.Build)
print("================================")

Notify("SysxHub v0.1 loaded")
return true
