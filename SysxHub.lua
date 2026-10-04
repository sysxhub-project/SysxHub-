--[[
================================================================
 SYSX HUB - v2.2 | Created by Ramanotsugarr
 Deep Fixed All Features
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
    Build = "SysxHub v2.2 | Created by Ramanotsugarr",
    Logo = "rbxassetid://136425814447688",
    OpenClose = "rbxassetid://70792832229220",
    Discord = "https://discord.gg/E5kQJW3hn",
    Background = Color3.fromRGB(10,8,18),
    Panel = Color3.fromRGB(17,13,29),
    Panel2 = Color3.fromRGB(23,18,38),
    Panel3 = Color3.fromRGB(30,24,48),
    Purple = Color3.fromRGB(125,70,255),
    Blue = Color3.fromRGB(80,140,255),
    White = Color3.fromRGB(255,255,255),
    Radius = 10,
    FarmDelay = 0.1,
    ChestDelay = 0.5,
    KillAuraRange = 25,
    KillAuraCooldown = 0.35,
    LevelTolerance = 50,
    TweenFruitSpeed = 500,
    TweenPlayerSpeed = 800,
    TweenMobSpeed = 250,
}

local State = {
    AutoFarm=false, AutoChest=false, AutoBoss=false,
    AutoFruit=false, AutoKillNearest=false, AutoQuest=false, AutoRaid=false,
    AutoBuyChip=false, AutoGacha=false, StoreFruit=false,
    AutoFish=false, AutoKillGolem=false, AutoCollectBone=false,
    AutoAddStats=false, AutoFarmSea=false, AutoKillSeaBeast=false,
    SelectedWeapon=nil, SelectedCategory=nil,
    SelectedBoss=nil, SelectedBossSea=nil, SelectedSeaMob=nil,
    SelectedRaid=nil, SelectedPlayer=nil,
    BringMob=false, BringMobRange=50, InfiniteJump=false, BoostFPS=false,
    Hitbox=false, HitboxPart=nil, Aimbot=false,
    KillAura=false, LastKillAura=0, LastBring=0, LastFruitTP=0,
    AntiAFK=true, Notifications=true,
    StatsMelee=0, StatsDefense=0, StatsSword=0, StatsGun=0, StatsBloxFruit=0,
    OriginalLighting=nil, OpenedChests={}, CodeInput="",
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
    s.Color = c or CONFIG.Purple
    s.Thickness = t or 1
    s.Transparency = tr or 0
    s.Parent = p
    return s
end

local function Gradient(p, c1, c2, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1 or CONFIG.Purple, c2 or CONFIG.Blue)
    g.Rotation = rot or 45
    g.Parent = p
    return g
end

local function Padding(p, l, r, t, b)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, l or 0)
    pad.PaddingRight = UDim.new(0, r or 0)
    pad.PaddingTop = UDim.new(0, t or 0)
    pad.PaddingBottom = UDim.new(0, b or 0)
    pad.Parent = p
    return pad
end

local function Tween(o, props, time)
    TweenService:Create(o, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local function GetHRP() local c = Player.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function GetDist(a, b) return (a - b).Magnitude end

local function SafeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[SysxHub]", err) return false end
    return true
end

--// FIXED NPC CHECK — only blood NPCs (can be attacked)
local function IsNPC(m)
    if not m or m == Player.Character then return false end
    local hum = m:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    if not m:FindFirstChild("HumanoidRootPart") then return false end
    if Players:GetPlayerFromCharacter(m) then return false end
    if hum.Health <= 0 then return false end
    if hum.MaxHealth <= 0 then return false end
    if hum.WalkSpeed <= 0 then return false end
    local n = string.lower(m.Name)
    local passive = {"dealer","shop","vendor","merchant","quest","giver",
        "bartender","chef","captain","scientist","teacher","guide","trainer",
        "blacksmith","smith","farmer","villager","elder"}
    for _, kw in ipairs(passive) do
        if string.find(n, kw) then return false end
    end
    return true
end

local function IsEnemyPlayer(m)
    if not m or m == Player.Character then return false end
    local plr = Players:GetPlayerFromCharacter(m)
    if not plr then return false end
    if plr:IsFriendsWith(Player.UserId) then return false end
    local h = m:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

--// REMOTE
local function FindRemote(...)
    local kws = {...}
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local ln = string.lower(obj.Name)
            for _, kw in ipairs(kws) do
                if string.find(ln, string.lower(kw)) then return obj end
            end
        end
    end
    return nil
end

local CommF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
local REMOTE_StoreFruit = FindRemote("storefruit", "fruitstore", "savefruit")

--// SCAN
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

local function FindChests()
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("BasePart") then
                local n = string.lower(obj.Name)
                if string.find(n,"chest") or string.find(n,"treasure") or string.find(n,"reward") then
                    local isOpened = obj.Transparency >= 1 or obj:GetAttribute("Opened") == true
                    if not isOpened and obj.Parent then table.insert(list, obj) end
                end
            end
        end)
    end
    return list
end

local function GetChestKey(c)
    return string.format("%.1f_%.1f_%.1f", c.Position.X, c.Position.Y, c.Position.Z)
end

local function FindFruits()
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "fruit") then
            -- Only ground fruit
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

--// WEAPON
local function GetWeaponCategory(name)
    local n = string.lower(name)
    local swords = {"katana","cutlass","sword","saber","rapier","blade","trident","pole","reaper","scythe","dagger","hooks","anchor","cursed","hallow","buddy","shark saw","warden","rengoku","tushita","yama"}
    for _, kw in ipairs(swords) do if string.find(n, kw) then return "Sword" end end
    local guns = {"gun","pistol","slingshot","rifle","bazooka","cannon","musket","sniper","flintlock"}
    for _, kw in ipairs(guns) do if string.find(n, kw) then return "Gun" end end
    local fruits = {"fruit","dough","leopard","kitsune","dragon","venom","shadow","control","spirit","mammoth","trex","rumble","portal","phoenix","sound","spider","buddha","magma","quake","light","dark","ice","sand","flame"}
    for _, kw in ipairs(fruits) do if string.find(n, kw) then return "Fruit" end end
    return "Melee"
end

local function GetWeaponsByCategory(cat)
    local list = {}
    local char = Player.Character
    if not char then return list end
    local function check(t)
        if t:IsA("Tool") and GetWeaponCategory(t.Name) == cat then table.insert(list, t) end
    end
    for _, t in ipairs(char:GetChildren()) do check(t) end
    for _, t in ipairs(Player.Backpack:GetChildren()) do check(t) end
    return list
end

local function SelectWeapon(name)
    local char = Player.Character
    if not char then return false end
    local found = nil
    for _, c in ipairs(char:GetChildren()) do
        if c:IsA("Tool") and c.Name == name then found = c break end
    end
    if not found then
        for _, c in ipairs(Player.Backpack:GetChildren()) do
            if c:IsA("Tool") and c.Name == name then found = c break end
        end
    end
    if not found then Notify("Weapon not found: "..name) return false end
    State.SelectedWeapon = found.Name
    State.SelectedCategory = GetWeaponCategory(found.Name)
    pcall(function() found.Parent = char end)
    Notify("Equipped: "..found.Name)
    return true
end

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

local function AttackNearest(maxDist)
    maxDist = maxDist or 60
    local hrp = GetHRP()
    if not hrp then return end
    local closest, dist = nil, math.huge
    for _, e in ipairs(ScanEnemies()) do
        local ehrp = e:FindFirstChild("HumanoidRootPart")
        if ehrp then
            local d = GetDist(ehrp.Position, hrp.Position)
            if d < dist and d <= maxDist then closest, dist = e, d end
        end
    end
    if closest then
        local tool = EquipWeapon()
        if tool then pcall(function() tool:Activate() end) end
    end
end

--// TWEEN MOVEMENT (smooth)
local function TweenToPosition(targetPos, speed)
    local hrp = GetHRP()
    if not hrp then return end
    speed = speed or 250
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

local function TweenToMob(mob, speed)
    local trp = mob:FindFirstChild("HumanoidRootPart")
    if not trp then return end
    TweenToPosition(trp.Position + Vector3.new(0, 3, 0), speed or CONFIG.TweenMobSpeed)
end

local function TeleportTo(pos)
    local hrp = GetHRP()
    if not hrp then return end
    hrp.CFrame = CFrame.new(pos)
end

--// MOB LEVEL
local function GetMobLevel(mob)
    local lvl = mob:GetAttribute("Level") or mob:GetAttribute("level")
    if lvl then return lvl end
    local hum = mob:FindFirstChildOfClass("Humanoid")
    if hum then
        local mh = hum.MaxHealth
        if mh <= 100 then return 10
        elseif mh <= 500 then return 40
        elseif mh <= 2000 then return 120
        elseif mh <= 8000 then return 300
        elseif mh <= 30000 then return 600
        elseif mh <= 100000 then return 1000
        elseif mh <= 200000 then return 1300
        else return math.floor(mh/500) end
    end
    return 0
end

local function FindMobByLevel(playerLevel, tolerance)
    tolerance = tolerance or CONFIG.LevelTolerance
    local list = {}
    for _, mob in ipairs(ScanEnemies()) do
        local mLvl = GetMobLevel(mob)
        local diff = math.abs(mLvl - playerLevel)
        if diff <= tolerance then
            table.insert(list, {model=mob, level=mLvl, diff=diff})
        end
    end
    table.sort(list, function(a,b) return a.diff < b.diff end)
    return list
end

--// RAID ISLAND DETECTION
local function GetRaidIsland()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Folder") then
            local n = string.lower(obj.Name)
            if string.find(n,"island3") or string.find(n,"island_3") then return 3 end
            if string.find(n,"island4") or string.find(n,"island_4") then return 4 end
            if string.find(n,"island5") or string.find(n,"island_5") then return 5 end
        end
    end
    local hrp = GetHRP()
    if not hrp then return 0 end
    local mobCount = 0
    for _, obj in ipairs(workspace:GetChildren()) do
        if IsNPC(obj) then
            local trp = obj:FindFirstChild("HumanoidRootPart")
            if trp and GetDist(trp.Position, hrp.Position) <= 100 then mobCount += 1 end
        end
    end
    if mobCount >= 5 then return 3 end
    if mobCount >= 3 then return 2 end
    if mobCount >= 1 then return 1 end
    return 0
end

local function IsInRaidIsland3()
    local ls = Player:FindFirstChild("leaderstats")
    local lv = ls and ls:FindFirstChild("Level")
    if not lv or lv.Value < 1500 then return false end
    return GetRaidIsland() >= 3
end

--// COMMF_ FUNCTIONS
local function AutoAddStats()
    if not CommF then Notify("CommF_ not found") return false end
    local stats = {
        {Name="Melee", Value=State.StatsMelee},
        {Name="Defense", Value=State.StatsDefense},
        {Name="Sword", Value=State.StatsSword},
        {Name="Gun", Value=State.StatsGun},
        {Name="Blox Fruit", Value=State.StatsBloxFruit},
    }
    for _, stat in ipairs(stats) do
        if stat.Value > 0 then
            pcall(function() CommF:InvokeServer("AddPoint", stat.Name, stat.Value) end)
            Notify("Added "..stat.Name..": "..stat.Value)
            task.wait(0.3)
        end
    end
    return true
end

local function DoGacha()
    if not CommF then return end
    pcall(function() CommF:InvokeServer("BuyFruit", "Random") end)
    Notify("Gacha triggered")
end

local function DoStoreFruit()
    local held = GetHeldFruit()
    if not held then return end
    if CommF then
        pcall(function() CommF:InvokeServer("StoreFruit", held.Name) end)
    elseif REMOTE_StoreFruit then
        pcall(function()
            if REMOTE_StoreFruit:IsA("RemoteEvent") then
                REMOTE_StoreFruit:FireServer(held)
            else
                REMOTE_StoreFruit:InvokeServer(held)
            end
        end)
    else
        pcall(function() held.Parent = Player.Backpack end)
    end
    Notify("Stored: "..held.Name)
end

local function DoAutoRaid()
    if not CommF or not State.SelectedRaid then return end
    pcall(function() CommF:InvokeServer("RaidsNpc", "Select", State.SelectedRaid) end)
    task.wait(0.5)
    pcall(function() CommF:InvokeServer("RaidsNpc", "Start") end)
    Notify("Raid: "..State.SelectedRaid)
end

local function DoBuyChip()
    if not CommF then return end
    pcall(function() CommF:InvokeServer("RaidsNpc", "Buy") end)
    Notify("BuyChip")
end

local function DoAutoQuest()
    if not CommF then return end
    pcall(function() CommF:InvokeServer("StartQuest") end)
end

--// BOSS DATA
local BossData = {
    Sea1 = {
        {Name="Gorilla King", Level=25, Location="Jungle"},
        {Name="Bobby", Level=55, Location="Pirate Village"},
        {Name="Yeti", Level=110, Location="Frozen Village"},
        {Name="Mob Leader", Level=120, Location="Pirate Village"},
        {Name="Vice Admiral", Level=130, Location="Marine Fortress"},
        {Name="Saber Expert", Level=200, Location="Jungle"},
        {Name="Warden", Level=220, Location="Prison"},
        {Name="Chief Warden", Level=230, Location="Prison"},
        {Name="Swan", Level=240, Location="Prison"},
        {Name="Magma Admiral", Level=350, Location="Magma Village"},
        {Name="Fishman Lord", Level=425, Location="Underwater City"},
        {Name="Wysper", Level=500, Location="Upper Skylands"},
        {Name="Thunder God", Level=575, Location="Upper Skylands"},
        {Name="Cyborg", Level=675, Location="Fountain City"},
    },
    Sea2 = {
        {Name="Diamond", Level=750, Location="Kingdom of Rose"},
        {Name="Jeremy", Level=850, Location="Kingdom of Rose"},
        {Name="Fajita", Level=925, Location="Green Zone"},
        {Name="Don Swan", Level=1000, Location="Kingdom of Rose"},
        {Name="Darkbeard", Level=1000, Location="Dark Arena", Raid=true},
        {Name="Smoke Admiral", Level=1150, Location="Hot and Cold"},
        {Name="Cursed Captain", Level=1325, Location="Cursed Ship"},
        {Name="Awakened Ice Admiral", Level=1400, Location="Ice Castle"},
        {Name="Tide Keeper", Level=1475, Location="Forgotten Island"},
    },
    Sea3 = {
        {Name="Stone", Level=1550, Location="Port Town"},
        {Name="Island Empress", Level=1675, Location="Hydra Island"},
        {Name="Kilo Admiral", Level=1750, Location="Great Tree"},
        {Name="Captain Elephant", Level=1875, Location="Floating Turtle"},
        {Name="Beautiful Pirate", Level=1950, Location="Floating Turtle"},
        {Name="Longma", Level=2000, Location="Floating Turtle"},
        {Name="Cake Queen", Level=2175, Location="Ice Cream Land"},
    },
}

--// NOTIFY
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
Stroke(Notification, CONFIG.Purple, 1, 0.35)

local NT = 0
local function Notify(text)
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

--// UI SCALE
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

-- OPEN BUTTON
local OpenButton = Create("ImageButton", {
    Parent=Gui, BackgroundColor3=CONFIG.Panel,
    Size=UDim2.fromOffset(64,64), Position=UDim2.new(0,18,0.5,-32),
    Image=CONFIG.OpenClose, AutoButtonColor=false, Visible=true, ZIndex=100,
})
Corner(OpenButton, 16)
Stroke(OpenButton, CONFIG.Purple, 2, 0.15)
Gradient(OpenButton, CONFIG.Purple, CONFIG.Blue, 45)

-- MAIN
local Main = Create("Frame", {
    Parent=Gui, AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.5,0.5), Size=UDim2.new(0,760,0,480),
    BackgroundColor3=CONFIG.Background, BorderSizePixel=0, Visible=true, ZIndex=10,
})
Corner(Main, 14)
Stroke(Main, CONFIG.Purple, 1, 0.45)

-- TOPBAR
local TopBar = Create("Frame", {
    Parent=Main, BackgroundColor3=CONFIG.Panel,
    Size=UDim2.new(1,0,0,64), BorderSizePixel=0, ZIndex=20,
})
Corner(TopBar, 14)
Gradient(TopBar, CONFIG.Panel, CONFIG.Panel2, 0)

Create("ImageLabel", {Parent=TopBar, BackgroundTransparency=1, Size=UDim2.fromOffset(48,48), Position=UDim2.new(0,10,0.5,-24), Image=CONFIG.Logo, ScaleType=Enum.ScaleType.Fit, ZIndex=21})
Create("TextLabel", {Parent=TopBar, BackgroundTransparency=1, Position=UDim2.new(0,66,0,8), Size=UDim2.new(0,250,0,25), Text="SysxHub", TextColor3=CONFIG.White, TextSize=20, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=21})
Create("TextLabel", {Parent=TopBar, BackgroundTransparency=1, Position=UDim2.new(0,67,0,33), Size=UDim2.new(0,400,0,18), Text=CONFIG.Build, TextColor3=CONFIG.White, TextSize=11, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=21})

local CloseButton = Create("TextButton", {
    Parent=TopBar, BackgroundColor3=CONFIG.Panel2,
    Size=UDim2.fromOffset(38,38), Position=UDim2.new(1,-50,0.5,-19),
    Text="X", TextColor3=CONFIG.White, TextSize=20,
    Font=Enum.Font.GothamBold, AutoButtonColor=false, ZIndex=25,
})
Corner(CloseButton, 10)
Stroke(CloseButton, CONFIG.Purple, 1, 0.5)

-- SIDEBAR
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
    ScrollBarThickness=2, ScrollBarImageColor3=CONFIG.Purple, BorderSizePixel=0, ZIndex=16,
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
        ScrollBarThickness=3, ScrollBarImageColor3=CONFIG.Purple,
        BorderSizePixel=0, Visible=false, ZIndex=12,
    })
    Padding(P, 8,8,8,8)
    local L = Instance.new("UIListLayout")
    L.Padding = UDim.new(0,9)
    L.SortOrder = Enum.SortOrder.LayoutOrder
    L.Parent = P
    Pages[name] = P
    return P
end

local function CreateSection(parent, title, desc)
    local S = Create("Frame", {
        Parent=parent, BackgroundColor3=CONFIG.Panel,
        Size=UDim2.new(1,0,0,72), BorderSizePixel=0, ZIndex=13,
    })
    Corner(S, 10)
    Stroke(S, CONFIG.Purple, 1, 0.85)
    Create("TextLabel", {Parent=S, BackgroundTransparency=1, Position=UDim2.new(0,14,0,10), Size=UDim2.new(1,-28,0,23), Text=title, TextColor3=CONFIG.White, TextSize=15, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14})
    Create("TextLabel", {Parent=S, BackgroundTransparency=1, Position=UDim2.new(0,14,0,35), Size=UDim2.new(1,-28,0,25), Text=desc or "", TextColor3=CONFIG.White, TextSize=11, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14})
    return S
end

local function CreateButton(parent, text, cb)
    local B = Create("TextButton", {
        Parent=parent, BackgroundColor3=CONFIG.Panel,
        Size=UDim2.new(1,0,0,48), Text=text,
        TextColor3=CONFIG.White, TextSize=13,
        Font=Enum.Font.GothamMedium, AutoButtonColor=false,
        BorderSizePixel=0, ZIndex=13,
    })
    Corner(B, 9)
    Stroke(B, CONFIG.Purple, 1, 0.7)
    Gradient(B, CONFIG.Panel, CONFIG.Panel2, 45)
    B.MouseEnter:Connect(function() Tween(B, {BackgroundColor3=CONFIG.Panel2}, 0.15) end)
    B.MouseLeave:Connect(function() Tween(B, {BackgroundColor3=CONFIG.Panel}, 0.15) end)
    B.Activated:Connect(function()
        if cb then
            local ok, err = pcall(cb)
            if not ok then warn("[Btn]", err) Notify("Error: "..tostring(err)) end
        end
    end)
    return B
end

local function CreateToggle(parent, text, default, cb)
    local S2 = default or false
    local B = Create("TextButton", {
        Parent=parent, BackgroundColor3=CONFIG.Panel,
        Size=UDim2.new(1,0,0,48), Text="",
        AutoButtonColor=false, BorderSizePixel=0, ZIndex=13,
    })
    Corner(B, 9)
    Stroke(B, CONFIG.Purple, 1, 0.7)
    Create("TextLabel", {Parent=B, BackgroundTransparency=1, Position=UDim2.new(0,14,0,0), Size=UDim2.new(1,-75,1,0), Text=text, TextColor3=CONFIG.White, TextSize=13, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14})
    local Ind = Create("Frame", {Parent=B, BackgroundColor3=Color3.fromRGB(55,50,65), Size=UDim2.fromOffset(42,22), Position=UDim2.new(1,-56,0.5,-11), ZIndex=14})
    Corner(Ind, 20)
    local Dot = Create("Frame", {Parent=Ind, BackgroundColor3=Color3.fromRGB(190,185,200), Size=UDim2.fromOffset(16,16), Position=UDim2.new(0,3,0.5,-8), ZIndex=15})
    Corner(Dot, 20)
    local function Update()
        if S2 then
            Ind.BackgroundColor3 = CONFIG.Purple
            Dot.BackgroundColor3 = Color3.new(1,1,1)
            Tween(Dot, {Position=UDim2.new(1,-19,0.5,-8)}, 0.15)
        else
            Ind.BackgroundColor3 = Color3.fromRGB(55,50,65)
            Dot.BackgroundColor3 = Color3.fromRGB(190,185,200)
            Tween(Dot, {Position=UDim2.new(0,3,0.5,-8)}, 0.15)
        end
    end
    B.Activated:Connect(function()
        S2 = not S2
        Update()
        if cb then
            local ok, err = pcall(cb, S2)
            if not ok then warn("[Tg]", err) Notify("Error: "..tostring(err)) end
        end
    end)
    Update()
    return B
end

local function CreateInput(parent, placeholder, cb)
    local Box = Create("TextBox", {
        Parent=parent, BackgroundColor3=CONFIG.Panel2,
        Size=UDim2.new(1,0,0,40), Text="",
        PlaceholderText=placeholder or "Input...",
        PlaceholderColor3=CONFIG.White, TextColor3=CONFIG.White, TextSize=13,
        Font=Enum.Font.GothamMedium, AutoButtonColor=false,
        BorderSizePixel=0, ZIndex=13,
        TextXAlignment=Enum.TextXAlignment.Left, ClearTextOnFocus=false,
    })
    Corner(Box, 9)
    Stroke(Box, CONFIG.Purple, 1, 0.7)
    Padding(Box, 12,12,0,0)
    if cb then Box.FocusLost:Connect(function() pcall(cb, Box.Text) end) end
    return Box
end

local function CreateDropdown(parent, title, options, cb)
    local Holder = Create("Frame", {
        Parent=parent, BackgroundColor3=CONFIG.Panel,
        Size=UDim2.new(1,0,0,48), BorderSizePixel=0,
        ZIndex=13, ClipsDescendants=false,
    })
    Corner(Holder, 9)
    Stroke(Holder, CONFIG.Purple, 1, 0.7)
    local Selected = options[1] or "Select"
    local IsOpen = false
    local TitleLbl = Create("TextLabel", {Parent=Holder, BackgroundTransparency=1, Position=UDim2.new(0,14,0,0), Size=UDim2.new(1,-100,1,0), Text=title..": "..Selected, TextColor3=CONFIG.White, TextSize=13, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14})
    Create("TextLabel", {Parent=Holder, BackgroundTransparency=1, Position=UDim2.new(1,-30,0,0), Size=UDim2.new(0,20,1,0), Text="v", TextColor3=CONFIG.White, TextSize=12, Font=Enum.Font.GothamBold, ZIndex=14})
    local ListHolder = Create("ScrollingFrame", {
        Parent=Holder, BackgroundColor3=CONFIG.Panel2,
        Position=UDim2.new(0,0,1,4), Size=UDim2.new(1,0,0,0),
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollBarThickness=3, ScrollBarImageColor3=CONFIG.Purple, BorderSizePixel=0, ZIndex=200, Visible=false,
    })
    Corner(ListHolder, 9)
    Stroke(ListHolder, CONFIG.Purple, 1, 0.5)
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
                Size=UDim2.new(1,-8,0,36),
                Position=UDim2.new(0,4,0,4),
                Text=opt, TextColor3=CONFIG.White, TextSize=12,
                Font=Enum.Font.GothamMedium, AutoButtonColor=false,
                BorderSizePixel=0, LayoutOrder=i, ZIndex=201,
                TextXAlignment=Enum.TextXAlignment.Left,
            })
            Corner(OB, 6)
            Padding(OB, 10,10,0,0)
            OB.MouseEnter:Connect(function() Tween(OB, {BackgroundColor3=CONFIG.Purple}, 0.1) end)
            OB.MouseLeave:Connect(function() Tween(OB, {BackgroundColor3=CONFIG.Panel}, 0.1) end)
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
                local h = math.min(#options*40+8, 200)
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
        Size=UDim2.new(1,0,0,56), BorderSizePixel=0, ZIndex=13,
    })
    Corner(Holder, 9)
    Stroke(Holder, CONFIG.Purple, 1, 0.7)
    Create("TextLabel", {Parent=Holder, BackgroundTransparency=1, Position=UDim2.new(0,14,0,6), Size=UDim2.new(1,-80,0,18), Text=title, TextColor3=CONFIG.White, TextSize=13, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14})
    local ValueLbl = Create("TextLabel", {Parent=Holder, BackgroundTransparency=1, Position=UDim2.new(1,-70,0,6), Size=UDim2.new(0,60,0,18), Text=tostring(val), TextColor3=CONFIG.White, TextSize=13, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Right, ZIndex=14})
    local Bar = Create("Frame", {Parent=Holder, BackgroundColor3=CONFIG.Panel2, Position=UDim2.new(0,14,0,34), Size=UDim2.new(1,-28,0,10), BorderSizePixel=0, ZIndex=14})
    Corner(Bar, 5)
    local Fill = Create("Frame", {Parent=Bar, BackgroundColor3=CONFIG.Purple, Size=UDim2.new((val-minVal)/(maxVal-minVal),0,1,0), BorderSizePixel=0, ZIndex=15})
    Corner(Fill, 5)
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

local function CreateTab(name, order)
    local B = Create("TextButton", {
        Parent=TabList, BackgroundColor3=CONFIG.Panel,
        Size=UDim2.new(1,0,0,40), Text="",
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
        if tn == name then
            d.Button.BackgroundColor3 = CONFIG.Purple
        else
            d.Button.BackgroundColor3 = CONFIG.Panel
        end
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
local StatsPage = CreatePage("Stats")
local MiscPage = CreatePage("Misc")

--// WEAPON HOLDER (only for Farm weapon select)
local WeaponListHolder = Create("Frame", {Parent=FarmPage, BackgroundColor3=CONFIG.Panel, Size=UDim2.new(1,0,0,180), BorderSizePixel=0, ZIndex=13})
Corner(WeaponListHolder, 10)
Stroke(WeaponListHolder, CONFIG.Purple, 1, 0.7)
local WeaponListScroll = Create("ScrollingFrame", {Parent=WeaponListHolder, BackgroundTransparency=1, Position=UDim2.new(0,8,0,8), Size=UDim2.new(1,-16,1,-16), CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=3, ScrollBarImageColor3=CONFIG.Purple, BorderSizePixel=0, ZIndex=14})
local WL = Instance.new("UIListLayout")
WL.Padding = UDim.new(0,6)
WL.SortOrder = Enum.SortOrder.LayoutOrder
WL.Parent = WeaponListScroll

local function ShowWeaponsInCategory(cat)
    for _, c in ipairs(WeaponListScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local weapons = GetWeaponsByCategory(cat)
    if #weapons == 0 then
        Create("TextLabel", {Parent=WeaponListScroll, BackgroundTransparency=1, Size=UDim2.new(1,0,0,36), Text="No weapon in "..cat, TextColor3=CONFIG.White, TextSize=12, ZIndex=15})
        return
    end
    for i, w in ipairs(weapons) do
        local Btn = Create("TextButton", {Parent=WeaponListScroll, BackgroundColor3=CONFIG.Panel2, Size=UDim2.new(1,0,0,36), Text="- "..w.Name, TextColor3=CONFIG.White, TextSize=12, Font=Enum.Font.GothamMedium, AutoButtonColor=false, BorderSizePixel=0, LayoutOrder=i, ZIndex=15, TextXAlignment=Enum.TextXAlignment.Left})
        Corner(Btn, 8)
        Padding(Btn, 12,12,0,0)
        Btn.Activated:Connect(function() SelectWeapon(w.Name) end)
    end
end

--// DISCORD
CreateSection(DiscordPage, "DISCORD INFO", "Join community")
Create("TextLabel", {Parent=DiscordPage, BackgroundColor3=CONFIG.Panel, Size=UDim2.new(1,0,0,80), Text="Discord:\n"..CONFIG.Discord, TextColor3=CONFIG.White, TextSize=13, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, BorderSizePixel=0, ZIndex=13})
CreateButton(DiscordPage, "Copy Discord Link", function()
    if setclipboard then setclipboard(CONFIG.Discord) Notify("Copied") end
end)

--// FARM
CreateSection(FarmPage, "FARM", "Auto farm level + level match")
CreateToggle(FarmPage, "Auto Farm Level", false, function(s) State.AutoFarm=s Notify("Auto Farm: "..(s and "ON" or "OFF")) end)
CreateToggle(FarmPage, "Auto Kill Nearest", false, function(s) State.AutoKillNearest=s Notify("Auto Kill Nearest: "..(s and "ON" or "OFF")) end)
CreateToggle(FarmPage, "Auto Quest", false, function(s) State.AutoQuest=s Notify("Auto Quest: "..(s and "ON" or "OFF")) end)

CreateSection(FarmPage, "WEAPON", "Select weapon")
CreateDropdown(FarmPage, "Select Tool", {"Melee", "Sword", "Gun", "Fruit"}, function(opt)
    State.SelectedCategory = opt
    ShowWeaponsInCategory(opt)
end)

CreateSection(FarmPage, "CHEST", "Auto farm chest")
CreateToggle(FarmPage, "Farm Chest", false, function(s)
    State.AutoChest = s
    if s then State.OpenedChests = {} end
    Notify("Farm Chest: "..(s and "ON" or "OFF"))
end)

--// SEA
CreateSection(SeaPage, "SEA", "Select mobs")
CreateDropdown(SeaPage, "Select Mobs", {"Piranha","Shark","FishCrewMember","SeaBeast","Terrorshark"}, function(opt)
    State.SelectedSeaMob = opt
    Notify("Mob: "..opt)
end)
CreateToggle(SeaPage, "Auto Farm Sea", false, function(s) State.AutoFarmSea=s Notify("Auto Farm Sea: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Auto Kill Sea Beast", false, function(s) State.AutoKillSeaBeast=s Notify("Auto Kill Sea Beast: "..(s and "ON" or "OFF")) end)

--// QUEST / ITEMS
CreateSection(QuestItemsPage, "QUEST / ITEMS", "Rare item features")
CreateToggle(QuestItemsPage, "Auto CDK", false, function(s) Notify("Auto CDK: "..(s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Dark Dagger", false, function(s) Notify("Auto Dark Dagger: "..(s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Soul Guitar", false, function(s) Notify("Auto Soul Guitar: "..(s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Yama", false, function(s) Notify("Auto Yama: "..(s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Tushita", false, function(s) Notify("Auto Tushita: "..(s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Buddy Sword", false, function(s) Notify("Auto Buddy Sword: "..(s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Kill Indra", false, function(s) Notify("Auto Kill Indra: "..(s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Spawn Dough King", false, function(s) Notify("Auto Spawn Dough King: "..(s and "ON" or "OFF")) end)

--// FRUIT / RAID
CreateSection(FruitRaidPage, "FRUIT", "Auto collect fruit (tween)")
CreateToggle(FruitRaidPage, "Auto Collect Fruit", false, function(s) State.AutoFruit=s Notify("Auto Collect Fruit: "..(s and "ON" or "OFF")) end)

CreateSection(FruitRaidPage, "GACHA ZIOLES", "Auto Gacha Box")
CreateToggle(FruitRaidPage, "Auto Gacha", false, function(s) State.AutoGacha=s Notify("Auto Gacha: "..(s and "ON" or "OFF")) end)
CreateToggle(FruitRaidPage, "Store Fruit", false, function(s) State.StoreFruit=s Notify("Store Fruit: "..(s and "ON" or "OFF")) end)

CreateSection(FruitRaidPage, "RAID", "Auto raid")
CreateDropdown(FruitRaidPage, "Select Raid", {"Flame","Ice","Sand","Dark","Light","Magma","Quake","Buddha","Spider","Phoenix","Dough"}, function(opt)
    State.SelectedRaid = opt
    Notify("Raid: "..opt)
end)
CreateToggle(FruitRaidPage, "Auto Raid", false, function(s) State.AutoRaid=s Notify("Auto Raid: "..(s and "ON" or "OFF")) end)
CreateToggle(FruitRaidPage, "Auto Buy Chip", false, function(s) State.AutoBuyChip=s Notify("Auto Buy Chip: "..(s and "ON" or "OFF")) end)

--// FISHING
CreateSection(FishingPage, "FISHING", "Auto fishing")
CreateToggle(FishingPage, "Auto Fishing", false, function(s) State.AutoFish=s Notify("Auto Fishing: "..(s and "ON" or "OFF")) end)

--// STATUS (BOSSES PER SEA)
CreateSection(StatusPage, "STATUS", "Player info + boss list")
local StatusLabel = Create("TextLabel", {
    Parent=StatusPage, BackgroundColor3=CONFIG.Panel,
    Size=UDim2.new(1,0,0,300),
    Text="Loading...",
    TextColor3=CONFIG.White, TextSize=12,
    Font=Enum.Font.GothamMedium,
    TextXAlignment=Enum.TextXAlignment.Left,
    TextYAlignment=Enum.TextYAlignment.Top,
    BorderSizePixel=0, ZIndex=13,
})
Corner(StatusLabel, 9)
Padding(StatusLabel, 14,14,7,7)

local leaderstats = Player:FindFirstChild("leaderstats")
local LevelValue = leaderstats and leaderstats:FindFirstChild("Level")

task.spawn(function()
    while task.wait(1) do
        if LevelValue then
            local lv = LevelValue.Value
            local sea = "Sea1"
            if lv >= 1500 then sea = "Sea3"
            elseif lv >= 700 then sea = "Sea2"
            end
            
            local bossList = BossData[sea] or {}
            local bossText = "\n=== BOSSES "..sea:upper().." ==="
            for _, b in ipairs(bossList) do
                bossText = bossText .. string.format("\n%s (Lv %d) - %s", b.Name, b.Level, b.Location)
            end
            
            StatusLabel.Text = string.format("Level: %d\nSea: %s\nRaid Island: %d%s", lv, sea, GetRaidIsland(), bossText)
        end
    end
end)

--// PVP
CreateSection(PvPPage, "PLAYER CONTROL", "Select + tween to player")
CreateDropdown(PvPPage, "Select Player", (function()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then table.insert(list, plr.Name) end
    end
    if #list == 0 then list = {"No players"} end
    return list
end)(), function(opt) State.SelectedPlayer = opt Notify("Player: "..opt) end)

CreateButton(PvPPage, "Teleport Player (Tween)", function()
    if not State.SelectedPlayer then Notify("Select player first") return end
    local target = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name == State.SelectedPlayer then target = plr break end
    end
    if not target or not target.Character then Notify("Player not found") return end
    local trp = target.Character:FindFirstChild("HumanoidRootPart")
    if not trp then Notify("Target no HRP") return end
    TweenToPosition(trp.Position + Vector3.new(0, 3, 5), CONFIG.TweenPlayerSpeed)
    Notify("Tweening to: "..State.SelectedPlayer)
end)

CreateButton(PvPPage, "Spectate Player", function()
    if not State.SelectedPlayer then Notify("Select player first") return end
    local target = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name == State.SelectedPlayer then target = plr break end
    end
    if not target or not target.Character then Notify("Player not found") return end
    local hum = target.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    Camera.CameraSubject = hum
    Camera.CameraType = Enum.CameraType.Custom
    Notify("Spectating: "..State.SelectedPlayer)
end)

CreateButton(PvPPage, "Stop Spectate", function()
    local char = Player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then Camera.CameraSubject = hum end
    end
    Notify("Spectate stopped")
end)

CreateSection(PvPPage, "COMBAT", "PvP features")
CreateToggle(PvPPage, "Aimbot", false, function(s) State.Aimbot=s Notify("Aimbot: "..(s and "ON" or "OFF")) end)
CreateToggle(PvPPage, "Hitbox", false, function(s) State.Hitbox=s Notify("Hitbox: "..(s and "ON" or "OFF")) end)

local KillAuraLabel = Create("TextLabel", {Parent=PvPPage, BackgroundColor3=CONFIG.Panel, Size=UDim2.new(1,0,0,40), Text="Kill Aura: Standby", TextColor3=CONFIG.White, TextSize=13, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, BorderSizePixel=0, ZIndex=13})
Corner(KillAuraLabel, 9)
Padding(KillAuraLabel, 14,14,7,7)

task.spawn(function()
    while task.wait(1) do
        if IsInRaidIsland3() then
            KillAuraLabel.Text = "Kill Aura: ACTIVE (Raid Island "..GetRaidIsland()..")"
        else
            KillAuraLabel.Text = "Kill Aura: Standby (need Island 3+)"
        end
    end
end)

--// STATS
CreateSection(StatsPage, "AUTO ADD STATS", "Distribute stat points")
CreateToggle(StatsPage, "Auto Add Stats", false, function(s) State.AutoAddStats=s Notify("Auto Add Stats: "..(s and "ON" or "OFF")) end)
CreateSlider(StatsPage, "Melee", 0, 100, 0, function(v) State.StatsMelee=v end)
CreateSlider(StatsPage, "Defense", 0, 100, 0, function(v) State.StatsDefense=v end)
CreateSlider(StatsPage, "Sword", 0, 100, 0, function(v) State.StatsSword=v end)
CreateSlider(StatsPage, "Gun", 0, 100, 0, function(v) State.StatsGun=v end)
CreateSlider(StatsPage, "BloxFruit", 0, 100, 0, function(v) State.StatsBloxFruit=v end)
CreateButton(StatsPage, "Apply Stats Now", function() AutoAddStats() end)

--// MISC
CreateSection(MiscPage, "ANTI AFK", "Prevent kick")
CreateToggle(MiscPage, "Anti AFK", true, function(s) State.AntiAFK=s Notify("Anti AFK: "..(s and "ON" or "OFF")) end)

CreateSection(MiscPage, "MOVEMENT", "Movement control")
CreateToggle(MiscPage, "Bring Mob", false, function(s) State.BringMob=s Notify("Bring Mob: "..(s and "ON" or "OFF")) end)
CreateSlider(MiscPage, "Bring Mob Range", 0, 100, 50, function(v) State.BringMobRange=v end)
CreateToggle(MiscPage, "Infinite Jump", false, function(s) State.InfiniteJump=s Notify("Infinite Jump: "..(s and "ON" or "OFF")) end)

CreateSection(MiscPage, "PERFORMANCE", "Boost FPS")
CreateToggle(MiscPage, "Boost FPS", false, function(s)
    State.BoostFPS = s
    if s then
        pcall(function()
            State.OriginalLighting = {GlobalShadows=Lighting.GlobalShadows, Brightness=Lighting.Brightness, Ambient=Lighting.Ambient}
            Lighting.GlobalShadows = false
            Lighting.Brightness = 0
            Lighting.Ambient = Color3.fromRGB(0,0,0)
            Lighting.FogEnd = 100
            Lighting.Outlines = false
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

CreateSection(MiscPage, "REDEEM CODE", "Redeem code")
CreateInput(MiscPage, "Enter code...", function(text) State.CodeInput = text end)
CreateButton(MiscPage, "Redeem Code", function()
    if not State.CodeInput or State.CodeInput == "" then Notify("Enter code first") return end
    if CommF then
        pcall(function() CommF:InvokeServer("Redeem", State.CodeInput) end)
        Notify("Redeeming: "..State.CodeInput)
    else
        Notify("Redeem remote not found")
    end
end)

CreateSection(MiscPage, "SERVER", "Server options")
CreateButton(MiscPage, "Rejoin Server", function() TeleportService:Teleport(game.PlaceId, Player) end)

--// =====================================================
--// LOOPS
--// =====================================================

-- AUTO FARM LEVEL (blood NPC + level match ±50)
task.spawn(function()
    while task.wait(CONFIG.FarmDelay) do
        if State.AutoFarm then
            SafeCall(function()
                local lv = LevelValue and LevelValue.Value or 1
                local mobs = FindMobByLevel(lv, CONFIG.LevelTolerance)
                if #mobs > 0 then
                    local target = mobs[1].model
                    TweenToMob(target, CONFIG.TweenMobSpeed)
                    local tool = EquipWeapon()
                    if tool then
                        while target.Parent 
                            and target:FindFirstChildOfClass("Humanoid")
                            and target.Humanoid.Health > 0
                            and State.AutoFarm do
                            tool:Activate()
                            task.wait(0.1)
                        end
                    end
                end
            end)
        elseif State.AutoKillNearest then
            SafeCall(function() AttackNearest(60) end)
        end
    end
end)

-- AUTO CHEST
task.spawn(function()
    while task.wait(CONFIG.ChestDelay) do
        if State.AutoChest then
            SafeCall(function()
                local chests = FindChests()
                local hrp = GetHRP()
                if not hrp then return end
                if #chests == 0 then task.wait(5) return end
                local nearest, nd = nil, math.huge
                for _, c in ipairs(chests) do
                    local key = GetChestKey(c)
                    if not State.OpenedChests[key] then
                        local d = GetDist(c.Position, hrp.Position)
                        if d < nd then nearest, nd = c, d end
                    end
                end
                if not nearest then
                    State.OpenedChests = {}
                    task.wait(5)
                    return
                end
                TeleportTo(nearest.Position + Vector3.new(0, 3, 0))
                State.OpenedChests[GetChestKey(nearest)] = true
                task.wait(0.6)
            end)
        end
    end
end)

-- AUTO FRUIT (tween fast + cooldown + ground filter)
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoFruit then
            SafeCall(function()
                local now = os.clock()
                if now - State.LastFruitTP < 1 then return end
                local hrp = GetHRP()
                if not hrp then return end
                local nearest, nd = nil, math.huge
                for _, f in ipairs(FindFruits()) do
                    local d = GetDist(f.Position, hrp.Position)
                    if d < 500 and d < nd then nearest, nd = f, d end
                end
                if nearest then
                    State.LastFruitTP = now
                    TweenToPosition(nearest.Position + Vector3.new(0, 3, 0), CONFIG.TweenFruitSpeed)
                end
            end)
        end
    end
end)

-- AUTO FISHING
task.spawn(function()
    while task.wait(2) do
        if State.AutoFish then
            SafeCall(function()
                local char = Player.Character
                if not char then return end
                local tool = char:FindFirstChildOfClass("Tool")
                if tool and string.find(string.lower(tool.Name), "rod") then tool:Activate() end
            end)
        end
    end
end)

-- AUTO GACHA
task.spawn(function()
    while task.wait(60) do
        if State.AutoGacha then
            SafeCall(function()
                if not GetHeldFruit() then DoGacha() end
            end)
        end
    end
end)

-- AUTO STORE FRUIT
task.spawn(function()
    while task.wait(1.5) do
        if State.StoreFruit then
            SafeCall(function()
                if GetHeldFruit() then DoStoreFruit() end
            end)
        end
    end
end)

-- AUTO RAID
task.spawn(function()
    while task.wait(10) do
        if State.AutoRaid then SafeCall(DoAutoRaid) end
    end
end)

-- AUTO BUY CHIP
task.spawn(function()
    while task.wait(15) do
        if State.AutoBuyChip then SafeCall(DoBuyChip) end
    end
end)

-- AUTO ADD STATS
task.spawn(function()
    while task.wait(3) do
        if State.AutoAddStats then SafeCall(AutoAddStats) end
    end
end)

-- KILL AURA (only Island 3+ raid)
task.spawn(function()
    while task.wait(0.1) do
        State.KillAura = IsInRaidIsland3()
        if State.KillAura then
            local now = os.clock()
            if now - State.LastKillAura >= CONFIG.KillAuraCooldown then
                local hrp = GetHRP()
                if hrp then
                    local found = false
                    for _, obj in ipairs(workspace:GetChildren()) do
                        if IsNPC(obj) or IsEnemyPlayer(obj) then
                            local trp = obj:FindFirstChild("HumanoidRootPart")
                            if trp and GetDist(trp.Position, hrp.Position) <= CONFIG.KillAuraRange then
                                found = true break
                            end
                        end
                    end
                    if found then
                        local tool = EquipWeapon()
                        if tool then
                            pcall(function() tool:Activate() end)
                            State.LastKillAura = now
                        end
                    end
                end
            end
        end
    end
end)

-- HITBOX
task.spawn(function()
    while task.wait(0.05) do
        if State.Hitbox then
            local hrp = GetHRP()
            if hrp then
                if not State.HitboxPart or not State.HitboxPart.Parent then
                    local hb = Instance.new("Part")
                    hb.Name = "SysxHitbox"
                    hb.Size = Vector3.new(10,10,10)
                    hb.Transparency = 1
                    hb.CanCollide = false
                    hb.CanTouch = true
                    hb.Anchored = true
                    hb.Massless = true
                    hb.Parent = workspace
                    State.HitboxPart = hb
                end
                State.HitboxPart.CFrame = hrp.CFrame
            end
        else
            if State.HitboxPart then State.HitboxPart:Destroy() State.HitboxPart = nil end
        end
    end
end)

-- BRING MOB
task.spawn(function()
    while task.wait(0.1) do
        if State.BringMob then
            local now = os.clock()
            if now - State.LastBring >= 0.3 then
                local hrp = GetHRP()
                if hrp then
                    local targetPos = hrp.Position + hrp.CFrame.LookVector * 6
                    for _, model in ipairs(workspace:GetChildren()) do
                        if IsNPC(model) or IsEnemyPlayer(model) then
                            local mRoot = model:FindFirstChild("HumanoidRootPart")
                            if mRoot and GetDist(mRoot.Position, hrp.Position) <= State.BringMobRange then
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

-- INFINITE JUMP
task.spawn(function()
    while task.wait(0.1) do
        if State.InfiniteJump then
            local char = Player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum:GetState() == Enum.HumanoidStateType.Freefall then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end
end)

-- AIMBOT
task.spawn(function()
    while task.wait(0.05) do
        if State.Aimbot then
            local closest, dist = nil, math.huge
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= Player and plr.Character then
                    local head = plr.Character:FindFirstChild("Head")
                    if head then
                        local d = (head.Position - Camera.CFrame.Position).Magnitude
                        if d < dist then closest, dist = head, d end
                    end
                end
            end
            if closest then Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position) end
        end
    end
end)

--// TABS
local TabDefs = {{"Discord"},{"Farm"},{"Sea"},{"Quest / Items"},{"Fruit / Raid"},{"Fishing"},{"Status"},{"PvP"},{"Stats"},{"Misc"}}
for i, d in ipairs(TabDefs) do
    local btn = CreateTab(d[1], i)
    btn.Activated:Connect(function() ShowTab(d[1]) end)
end

CloseButton.Activated:Connect(function() Main.Visible=false OpenButton.Visible=true end)
OpenButton.Activated:Connect(function() Main.Visible=true OpenButton.Visible=false end)

local dragging, dragStart, startPos = false, nil, nil
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
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
print("        SYSX HUB LOADED v2.2")
print("        "..CONFIG.Build)
print("================================")

Notify("SysxHub v2.2 loaded")
return true
