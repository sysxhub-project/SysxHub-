--[[
================================================================
 SYSX HUB | Freemium Version | v0.2 | Created by Ramanotsugarr
 Blue Outline + Logo + White Text + Full CommF_ Chain
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
    Build = "SysxHub v0.2 | Freemium | Created by Ramanotsugarr",
    Logo = "rbxassetid://78595907369123",
    OpenClose = "rbxassetid://70792832229220",
    Discord = "https://discord.gg/E5kQJW3hn",
    Background = Color3.fromRGB(10,8,18),
    Panel = Color3.fromRGB(17,13,29),
    Panel2 = Color3.fromRGB(23,18,38),
    Blue = Color3.fromRGB(0,150,255),
    Blue2 = Color3.fromRGB(80,180,255),
    White = Color3.fromRGB(255,255,255),
    Radius = 10,
    FarmDelay = 0.1,
    ChestDelay = 0.5,
    KillAuraRange = 25,
    KillAuraCooldown = 0.35,
    LevelTolerance = 50,
    TweenFruitSpeed = 500,
    TweenPlayerSpeed = 150,
    TweenMobSpeed = 250,
    AttackRange = 30,
}

local State = {
    AutoFarm=false, AutoChest=false, AutoBoss=false,
    AutoFruit=false, AutoKillNearest=false, AutoRaid=false, AutoBuyChip=false,
    AutoGacha=false, StoreFruit=false, AutoFish=false, AutoAddStats=false,
    AutoRaceV2=false, AutoRaceV3=false, CousinBuy=false,
    AutoFarmSea=false, AutoKillSeaBeast=false, AutoQuest=false,
    AutoTrial=false, AutoPullLever=false, KillPlayerTrial=false,
    TrialMethod="Bone",
    SelectedWeapon=nil, SelectedCategory=nil,
    SelectedBoss=nil, SelectedBossSea=nil, SelectedRaid=nil, SelectedPlayer=nil,
    SelectedIsland="Starter Island", SelectedMelee=nil, SelectedSword=nil,
    SelectedGun=nil, SelectedAbility=nil, SelectedFruitLoad=nil,
    BringMob=false, BringMobRange=50, InfiniteJump=false, BoostFPS=false,
    Hitbox=false, HitboxPart=nil, Aimbot=false,
    KillAura=false, LastKillAura=0, LastBring=0, LastFruitTP=0,
    AntiAFK=true, Notifications=true,
    StatsMelee=0, StatsSword=0, StatsGun=0, StatsBloxFruit=0,
    OriginalLighting=nil, OpenedChests={},
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

--// NPC FILTER
local PASSIVE = {"dealer","shop","vendor","merchant","quest","giver","bartender","chef","captain","scientist","teacher","guide","trainer","banker","blacksmith","smith","farmer","villager","elder"}

local function IsAlive(m)
    local h = m and m:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

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

local function IsEnemyPlayer(m)
    if not m or m == Player.Character then return false end
    local plr = Players:GetPlayerFromCharacter(m)
    if not plr then return false end
    if plr:IsFriendsWith(Player.UserId) then return false end
    return IsAlive(m)
end

--// REMOTE
local CommF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")

local function Invoke(...)
    if not CommF then return nil end
    local ok, res = pcall(function(...) return CommF:InvokeServer(...) end, ...)
    if not ok then return nil end
    return res
end

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
        if obj:IsA("BasePart") then
            local n = string.lower(obj.Name)
            if string.find(n,"chest") or string.find(n,"treasure") or string.find(n,"reward") then
                local isOpened = obj.Transparency >= 1 or obj:GetAttribute("Opened") == true
                if not isOpened and obj.Parent then table.insert(list, obj) end
            end
        end
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

local function TweenToMob(mob, speed)
    local trp = mob and mob:FindFirstChild("HumanoidRootPart")
    if not trp then return end
    TweenToPosition(trp.Position + Vector3.new(0, 3, 0), speed or CONFIG.TweenMobSpeed)
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

local function AttackNearest(maxDist)
    maxDist = maxDist or CONFIG.AttackRange
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

--// RAID
local function GetRaidIsland()
    local hrp = GetHRP()
    if not hrp then return 0 end
    local c = 0
    for _, obj in ipairs(workspace:GetChildren()) do
        if IsNPC(obj) then
            local trp = obj:FindFirstChild("HumanoidRootPart")
            if trp and GetDist(trp.Position, hrp.Position) <= 100 then c += 1 end
        end
    end
    if c >= 5 then return 3 end
    if c >= 3 then return 2 end
    if c >= 1 then return 1 end
    return 0
end

--// COMMF_ ACTIONS
local function AutoAddStats()
    local stats = {
        {Name="Melee", Value=State.StatsMelee},
        {Name="Sword", Value=State.StatsSword},
        {Name="Gun", Value=State.StatsGun},
        {Name="Blox Fruit", Value=State.StatsBloxFruit},
    }
    for _, stat in ipairs(stats) do
        if stat.Value > 0 then
            Invoke("AddPoint", stat.Name, stat.Value)
            Notify("Added "..stat.Name..": "..stat.Value)
            task.wait(0.3)
        end
    end
end

local function DoStoreFruit()
    local held = GetHeldFruit()
    if not held then return end
    Invoke("StoreFruit", held.Name, held)
    Notify("Stored: "..held.Name)
end

local function DoAutoRaid()
    if not State.SelectedRaid then return end
    Invoke("RaidsNpc", "Select", State.SelectedRaid)
    task.wait(0.5)
    pcall(function()
        fireclickdetector(workspace.Map.CircleIsland.RaidSummon.Button.Main.ClickDetector)
    end)
    Notify("Raid: "..State.SelectedRaid)
end

local function GetQuestChain(q)
    if q == "CDK" then Invoke("ProQuestProgress", "CDK") Notify("CDK Started")
    elseif q == "DarkDagger" or q == "Indra" then
        local hasChalice = Player.Backpack:FindFirstChild("God's Chalice")
            or (Player.Character and Player.Character:FindFirstChild("God's Chalice"))
        if not hasChalice then Notify("Need God's Chalice!") return end
        Invoke("PlaceChalice") Notify("Summoning Indra")
    elseif q == "SoulGuitar" then Invoke("ProQuestProgress", "SoulGuitar") Notify("Soul Guitar Started")
    elseif q == "Yama" then Invoke("StartQuest", "EliteHunter", 1) Notify("Elite Hunter Started")
    elseif q == "Tushita" then Invoke("ProQuestProgress", "Tushita") Notify("Tushita Started")
    elseif q == "BuddySword" then
        local boss = FindBoss("Cake Queen")
        if boss then TweenToMob(boss, 300) Notify("Farming Cake Queen")
        else Notify("Cake Queen not spawned") end
    elseif q == "DoughKing" then
        local hasSweet = Player.Backpack:FindFirstChild("Sweet Chalice")
            or (Player.Character and Player.Character:FindFirstChild("Sweet Chalice"))
        if not hasSweet then Notify("Need Sweet Chalice!") return end
        Invoke("DoughKing") Notify("Summoning Dough King")
    end
end

local RedeemCodes = {
    "KITT_RESET","SUB2GAMERROBOT_RESET1","SUB2GAMERROBOT_EXP1",
    "SUB2OFFICIALNOOBIE","AXIORE","BLUXXY","JCWK","KITTGAMING",
    "MAGICBUS","STARCODEHEO","STRAWHATMAINE","TANTAIGAMING",
    "THEGREATACE","ENYU_IS_PRO",
}

local function RedeemAllCodes()
    for _, code in ipairs(RedeemCodes) do
        Invoke("Redeem", code)
        Notify("Redeeming: "..code)
        task.wait(1)
    end
end

--// ESP
local function CreateESP(target, text, color)
    if not target or not target:IsA("BasePart") then return end
    if State.ESPObjects[target] then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "SysxESP"
    bb.Size = UDim2.new(0, 100, 0, 40)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = target
    local label = Instance.new("TextLabel")
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
Logo.Name = "Logo"
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

local CloseButton = Create("TextButton", {
    Parent=TopBar, BackgroundColor3=CONFIG.Panel2,
    Size=UDim2.fromOffset(38,38), Position=UDim2.new(1,-50,0.5,-19),
    Text="X", TextColor3=CONFIG.White, TextSize=20,
    Font=Enum.Font.GothamBold, AutoButtonColor=false, ZIndex=25,
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
    Stroke(S, CONFIG.Blue, 1.5, 0.3)
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
    Stroke(B, CONFIG.Blue, 1.5, 0.3)
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
    Stroke(B, CONFIG.Blue, 1.5, 0.3)
    Create("TextLabel", {Parent=B, BackgroundTransparency=1, Position=UDim2.new(0,14,0,0), Size=UDim2.new(1,-75,1,0), Text=text, TextColor3=CONFIG.White, TextSize=13, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14})
    local Ind = Create("Frame", {Parent=B, BackgroundColor3=Color3.fromRGB(55,50,65), Size=UDim2.fromOffset(42,22), Position=UDim2.new(1,-56,0.5,-11), ZIndex=14})
    Corner(Ind, 20)
    local Dot = Create("Frame", {Parent=Ind, BackgroundColor3=Color3.fromRGB(190,185,200), Size=UDim2.fromOffset(16,16), Position=UDim2.new(0,3,0.5,-8), ZIndex=15})
    Corner(Dot, 20)
    local function Update()
        if S2 then
            Ind.BackgroundColor3 = CONFIG.Blue
            Dot.BackgroundColor3 = CONFIG.White
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

local function CreateDropdown(parent, title, options, cb)
    local Holder = Create("Frame", {
        Parent=parent, BackgroundColor3=CONFIG.Panel,
        Size=UDim2.new(1,0,0,48), BorderSizePixel=0,
        ZIndex=13, ClipsDescendants=false,
    })
    Corner(Holder, 9)
    Stroke(Holder, CONFIG.Blue, 1.5, 0.3)
    local Selected = options[1] or "Select"
    local IsOpen = false
    local TitleLbl = Create("TextLabel", {Parent=Holder, BackgroundTransparency=1, Position=UDim2.new(0,14,0,0), Size=UDim2.new(1,-100,1,0), Text=title..": "..Selected, TextColor3=CONFIG.White, TextSize=13, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14})
    Create("TextLabel", {Parent=Holder, BackgroundTransparency=1, Position=UDim2.new(1,-30,0,0), Size=UDim2.new(0,20,1,0), Text="v", TextColor3=CONFIG.White, TextSize=12, Font=Enum.Font.GothamBold, ZIndex=14})
    local ListHolder = Create("ScrollingFrame", {
        Parent=Holder, BackgroundColor3=CONFIG.Panel2,
        Position=UDim2.new(0,0,1,4), Size=UDim2.new(1,0,0,0),
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollBarThickness=3, ScrollBarImageColor3=CONFIG.Blue, BorderSizePixel=0, ZIndex=200, Visible=false,
    })
    Corner(ListHolder, 9)
    Stroke(ListHolder, CONFIG.Blue, 1.5, 0.3)
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
            OB.MouseEnter:Connect(function() Tween(OB, {BackgroundColor3=CONFIG.Blue}, 0.1) end)
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
    Stroke(Holder, CONFIG.Blue, 1.5, 0.3)
    Create("TextLabel", {Parent=Holder, BackgroundTransparency=1, Position=UDim2.new(0,14,0,6), Size=UDim2.new(1,-80,0,18), Text=title, TextColor3=CONFIG.White, TextSize=13, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14})
    local ValueLbl = Create("TextLabel", {Parent=Holder, BackgroundTransparency=1, Position=UDim2.new(1,-70,0,6), Size=UDim2.new(0,60,0,18), Text=tostring(val), TextColor3=CONFIG.White, TextSize=13, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Right, ZIndex=14})
    local Bar = Create("Frame", {Parent=Holder, BackgroundColor3=CONFIG.Panel2, Position=UDim2.new(0,14,0,34), Size=UDim2.new(1,-28,0,10), BorderSizePixel=0, ZIndex=14})
    Corner(Bar, 5)
    local Fill = Create("Frame", {Parent=Bar, BackgroundColor3=CONFIG.Blue, Size=UDim2.new((val-minVal)/(maxVal-minVal),0,1,0), BorderSizePixel=0, ZIndex=15})
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
            d.Button.BackgroundColor3 = CONFIG.Blue
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
local TrialsPage = CreatePage("Trials")
local SetingPage = CreatePage("Seting")
local TeleportPage = CreatePage("Teleport")
local StatsPage = CreatePage("Stats")
local ShopPage = CreatePage("Shop")
local MiscPage = CreatePage("Misc")

--// DISCORD
CreateSection(DiscordPage, "DISCORD INFO", "Join community")
Create("TextLabel", {Parent=DiscordPage, BackgroundColor3=CONFIG.Panel, Size=UDim2.new(1,0,0,80), Text="Discord:\n"..CONFIG.Discord, TextColor3=CONFIG.White, TextSize=13, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, BorderSizePixel=0, ZIndex=13})
CreateButton(DiscordPage, "Copy Discord Link", function()
    if setclipboard then setclipboard(CONFIG.Discord) Notify("Copied") end
end)

--// FARM
CreateSection(FarmPage, "FARM", "Auto farm + auto Haki")
CreateToggle(FarmPage, "Auto Farm Level", false, function(s)
    State.AutoFarm = s
    Notify("Auto Farm: "..(s and "ON" or "OFF"))
    if s then
        task.spawn(function()
            while State.AutoFarm do
                pcall(function() Invoke("Buso") end)
                task.wait(2)
            end
        end)
    end
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

CreateSection(FarmPage, "WEAPON", "Select weapon")
CreateDropdown(FarmPage, "Select Tool", {"Melee","Sword","Gun","Fruit"}, function(opt)
    State.SelectedCategory = opt
end)

CreateSection(FarmPage, "BOSS", "Select boss")
CreateDropdown(FarmPage, "Select Sea", {"Sea1","Sea2","Sea3"}, function(opt) end)
CreateToggle(FarmPage, "Auto Farm Boss", false, function(s) State.AutoBoss = s Notify("Auto Farm Boss: "..(s and "ON" or "OFF")) end)

CreateSection(FarmPage, "CHEST", "Auto chest")
CreateToggle(FarmPage, "Farm Chest", false, function(s)
    State.AutoChest = s
    if s then State.OpenedChests = {} end
    Notify("Farm Chest: "..(s and "ON" or "OFF"))
end)

CreateSection(FarmPage, "BONE", "Random Bone")
CreateButton(FarmPage, "Random Bone", function()
    Invoke("Bones", "Buy", 1, 1)
    Notify("Random Bone bought")
end)

CreateSection(FarmPage, "BUSO STAGE", "Change Buso")
CreateButton(FarmPage, "Change Buso Stage", function()
    Invoke("ChangeBusoStage", 0)
    Notify("Buso Stage changed")
end)

--// SEA
CreateSection(SeaPage, "SEA TRAVEL", "Pindah sea")
CreateButton(SeaPage, "Travel Main (Sea 1)", function() Invoke("TravelMain") Notify("Travel Main") end)
CreateButton(SeaPage, "Travel Dressrosa (Sea 2)", function() Invoke("TravelDressrosa") Notify("Travel Dressrosa") end)
CreateButton(SeaPage, "Travel Zou (Sea 3)", function() Invoke("TravelZou") Notify("Travel Zou") end)

CreateSection(SeaPage, "SEA FARM", "Auto sea")
CreateToggle(SeaPage, "Auto Farm Sea", false, function(s) State.AutoFarmSea = s Notify("Auto Farm Sea: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Auto Kill Sea Beast", false, function(s) State.AutoKillSeaBeast = s Notify("Auto Kill Sea Beast: "..(s and "ON" or "OFF")) end)

--// QUEST / ITEMS
CreateSection(QuestItemsPage, "AUTO QUEST", "Basic auto quest")
CreateToggle(QuestItemsPage, "Auto Quest", false, function(s) State.AutoQuest = s Notify("Auto Quest: "..(s and "ON" or "OFF")) end)

CreateSection(QuestItemsPage, "COMMF_ CHAIN", "Auto quest items")
CreateButton(QuestItemsPage, "Auto CDK (Lv 2200+)", function() GetQuestChain("CDK") end)
CreateButton(QuestItemsPage, "Auto Dark Dagger (God's Chalice)", function() GetQuestChain("DarkDagger") end)
CreateButton(QuestItemsPage, "Auto Soul Guitar (Lv 2300+)", function() GetQuestChain("SoulGuitar") end)
CreateButton(QuestItemsPage, "Auto Yama (30 Elite Hunter)", function() GetQuestChain("Yama") end)
CreateButton(QuestItemsPage, "Auto Tushita (Lv 2000+)", function() GetQuestChain("Tushita") end)
CreateButton(QuestItemsPage, "Auto Buddy Sword (Kill Cake Queen)", function() GetQuestChain("BuddySword") end)
CreateButton(QuestItemsPage, "Auto Kill Indra (God's Chalice)", function() GetQuestChain("Indra") end)
CreateButton(QuestItemsPage, "Auto Spawn Dough King (Sweet Chalice)", function() GetQuestChain("DoughKing") end)

CreateSection(QuestItemsPage, "COMMF_ EXTRA", "Quest tambahan")
CreateButton(QuestItemsPage, "Abandon Quest", function() Invoke("AbandonQuest") Notify("Quest abandoned") end)
CreateButton(QuestItemsPage, "Torch Puzzle (Get)", function() Invoke("ProQuestProgress", "GetTorch") Notify("Torch Get") end)
CreateButton(QuestItemsPage, "Torch Puzzle (Destroy)", function() Invoke("ProQuestProgress", "DestroyTorch") Notify("Torch Destroy") end)
CreateButton(QuestItemsPage, "Cup Puzzle (Get)", function() Invoke("ProQuestProgress", "GetCup") Notify("Cup Get") end)
CreateButton(QuestItemsPage, "Cup Puzzle (Fill)", function() Invoke("ProQuestProgress", "FillCup") Notify("Cup Fill") end)
CreateButton(QuestItemsPage, "SickMan Quest", function() Invoke("ProQuestProgress", "SickMan") Notify("SickMan") end)
CreateButton(QuestItemsPage, "RichSon Quest", function() Invoke("ProQuestProgress", "RichSon") Notify("RichSon") end)
CreateButton(QuestItemsPage, "CDK Open Door", function() Invoke("CDKQuest", "OpenDoor") Notify("CDK OpenDoor") end)
CreateButton(QuestItemsPage, "CDK Progress", function() Invoke("CDKQuest", "Progress") Notify("CDK Progress") end)
CreateButton(QuestItemsPage, "CDK Boat Quest", function() Invoke("CDKQuest", "BoatQuest") Notify("CDK BoatQuest") end)
CreateButton(QuestItemsPage, "Wenlocktoad Step 1", function() Invoke("Wenlocktoad", "1") Notify("Wenlocktoad 1") end)
CreateButton(QuestItemsPage, "Wenlocktoad Step 2", function() Invoke("Wenlocktoad", "2") Notify("Wenlocktoad 2") end)
CreateButton(QuestItemsPage, "Alchemist Step 1", function() Invoke("Alchemist", "1") Notify("Alchemist 1") end)
CreateButton(QuestItemsPage, "Alchemist Step 2", function() Invoke("Alchemist", "2") Notify("Alchemist 2") end)

CreateSection(QuestItemsPage, "SECRET QUEST", "Object interaction")
CreateButton(QuestItemsPage, "Auto Temple Door", function() Invoke("CheckTempleDoor") Notify("Temple Door checked") end)
CreateButton(QuestItemsPage, "Auto Bartilo Quest", function() Invoke("BartiloQuestProgress") Notify("Bartilo checked") end)
CreateButton(QuestItemsPage, "Auto Guitar Puzzle", function() Invoke("GuitarPuzzleProgress", "Check") Notify("Guitar checked") end)

CreateSection(QuestItemsPage, "RACE", "Auto Race V2 & V3")
CreateToggle(QuestItemsPage, "Auto Race V2", false, function(s) State.AutoRaceV2 = s Notify("Auto Race V2: "..(s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Race V3", false, function(s) State.AutoRaceV3 = s Notify("Auto Race V3: "..(s and "ON" or "OFF")) end)

CreateSection(QuestItemsPage, "EVENT", "Event NPC")
CreateButton(QuestItemsPage, "Auto Blackbeard Reward", function() Invoke("BlackbeardReward", "DragonClaw", "1") Notify("Blackbeard") end)
CreateButton(QuestItemsPage, "Auto Horned Man Bet", function() Invoke("HornedMan", "Bet") Notify("Horned Man") end)
CreateButton(QuestItemsPage, "Auto Talk Trevor", function() Invoke("TalkTrevor", "1") Notify("Trevor") end)

--// FRUIT / RAID
CreateSection(FruitRaidPage, "FRUIT", "Auto fruit")
CreateToggle(FruitRaidPage, "Collect Fruit", false, function(s) State.AutoFruit = s Notify("Collect Fruit: "..(s and "ON" or "OFF")) end)
CreateToggle(FruitRaidPage, "Random Fruit", false, function(s) State.AutoGacha = s Notify("Random Fruit: "..(s and "ON" or "OFF")) end)
CreateToggle(FruitRaidPage, "Store Fruit", false, function(s) State.StoreFruit = s Notify("Store Fruit: "..(s and "ON" or "OFF")) end)

CreateSection(FruitRaidPage, "BONES", "Bones exchange")
CreateButton(FruitRaidPage, "Bones Check", function()
    local res = Invoke("Bones", "Check")
    Notify("Bones: "..tostring(res))
end)
CreateButton(FruitRaidPage, "Bones Surprise", function() Invoke("Bones", "Buy", 1, 1) Notify("Surprise bought") end)
CreateButton(FruitRaidPage, "Bones Stat Refund", function() Invoke("Bones", "Buy", 1, 2) Notify("Stat Refund") end)
CreateButton(FruitRaidPage, "Bones Race Reroll", function() Invoke("Bones", "Buy", 1, 3) Notify("Race Reroll") end)

CreateSection(FruitRaidPage, "LOAD FRUIT", "Load fruit from inventory")
CreateDropdown(FruitRaidPage, "Select Fruit to Load", {
    "Rocket","Spin","Chop","Spring","Bomb","Smoke","Spike","Flame","Falcon",
    "Ice","Sand","Dark","Diamond","Light","Rubber","Barrier","Magma","Door",
    "Quake","Human","Buddha","Love","Spider","Sound","Phoenix","Portal",
    "Rumble","Pain","Blizzard","Gravity","Mammoth","T-Rex","Dough","Shadow",
    "Venom","Control","Spirit","Dragon","Leopard","Kitsune",
}, function(opt) State.SelectedFruitLoad = opt Notify("Fruit: "..opt) end)
CreateButton(FruitRaidPage, "Load Fruit", function()
    if State.SelectedFruitLoad then
        Invoke("LoadFruit", State.SelectedFruitLoad)
        Notify("Loaded: "..State.SelectedFruitLoad)
    else
        Notify("Select fruit first")
    end
end)

CreateSection(FruitRaidPage, "RAID", "Auto raid")
CreateDropdown(FruitRaidPage, "Select Raid", {"Flame","Ice","Sand","Dark","Light","Magma","Quake","Buddha","Spider","Phoenix","Dough"}, function(opt) State.SelectedRaid = opt Notify("Raid: "..opt) end)
CreateToggle(FruitRaidPage, "Auto Raid", false, function(s) State.AutoRaid = s Notify("Auto Raid: "..(s and "ON" or "OFF")) end)
CreateToggle(FruitRaidPage, "Npc Select", false, function(s) State.AutoBuyChip = s Notify("Npc Select: "..(s and "ON" or "OFF")) end)

CreateSection(FruitRaidPage, "COUSIN", "Random fruit buy")
CreateToggle(FruitRaidPage, "Cousin Buy", false, function(s) State.CousinBuy = s Notify("Cousin Buy: "..(s and "ON" or "OFF")) end)

--// FISHING
CreateSection(FishingPage, "FISHING", "Auto fishing")
CreateToggle(FishingPage, "Auto Fishing", false, function(s) State.AutoFish = s Notify("Auto Fishing: "..(s and "ON" or "OFF")) end)

--// STATUS
CreateSection(StatusPage, "STATUS", "Player info")
local StatusLabel = Create("TextLabel", {
    Parent=StatusPage, BackgroundColor3=CONFIG.Panel,
    Size=UDim2.new(1,0,0,200), Text="Loading...",
    TextColor3=CONFIG.White, TextSize=12, Font=Enum.Font.GothamMedium,
    TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
    BorderSizePixel=0, ZIndex=13,
})
Corner(StatusLabel, 9)
Padding(StatusLabel, 14,14,7,7)

task.spawn(function()
    while task.wait(1) do
        local ls = Player:FindFirstChild("leaderstats")
        local lv = ls and ls:FindFirstChild("Level")
        if lv then
            StatusLabel.Text = string.format("Level: %d\nSea: %s\nRaid Island: %d", lv.Value, lv.Value >= 1500 and "Sea3" or (lv.Value >= 700 and "Sea2" or "Sea1"), GetRaidIsland())
        end
    end
end)

CreateButton(StatusPage, "Get Inventory", function() Invoke("getInventory") Notify("Inventory fetched") end)
CreateButton(StatusPage, "Get Inventory Weapons", function() Invoke("getInventoryWeapons") Notify("Weapons fetched") end)
CreateButton(StatusPage, "Get Titles", function() Invoke("getTitles") Notify("Titles fetched") end)
CreateButton(StatusPage, "Get Unlockables", function() Invoke("GetUnlockables") Notify("Unlockables fetched") end)

--// PVP
CreateSection(PvPPage, "PLAYER CONTROL", "Teleport + spectate")
CreateDropdown(PvPPage, "Select Player", (function()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then table.insert(list, plr.Name) end
    end
    if #list == 0 then list = {"No players"} end
    return list
end)(), function(opt) State.SelectedPlayer = opt Notify("Player: "..opt) end)

CreateButton(PvPPage, "Teleport Player", function()
    if not State.SelectedPlayer then Notify("Select player first") return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name == State.SelectedPlayer and plr.Character then
            local trp = plr.Character:FindFirstChild("HumanoidRootPart")
            if trp then TweenToPosition(trp.Position + Vector3.new(0, 3, 5), CONFIG.TweenPlayerSpeed) end
        end
    end
end)

CreateButton(PvPPage, "Spectate Player", function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name == State.SelectedPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then Camera.CameraSubject = hum Camera.CameraType = Enum.CameraType.Custom end
        end
    end
end)

CreateButton(PvPPage, "Stop Spectate", function()
    local char = Player.Character
    if char then local hum = char:FindFirstChildOfClass("Humanoid") if hum then Camera.CameraSubject = hum end end
end)

CreateSection(PvPPage, "COMBAT", "PvP features")
CreateToggle(PvPPage, "Aimbot", false, function(s) State.Aimbot = s Notify("Aimbot: "..(s and "ON" or "OFF")) end)
CreateToggle(PvPPage, "Hitbox", false, function(s) State.Hitbox = s Notify("Hitbox: "..(s and "ON" or "OFF")) end)

local KillAuraLabel = Create("TextLabel", {Parent=PvPPage, BackgroundColor3=CONFIG.Panel, Size=UDim2.new(1,0,0,40), Text="Kill Aura: Standby", TextColor3=CONFIG.White, TextSize=13, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, BorderSizePixel=0, ZIndex=13})
Corner(KillAuraLabel, 9)
Padding(KillAuraLabel, 14,14,7,7)

--// TRIALS
CreateSection(TrialsPage, "TELEPORT TRIAL", "Tween ke trial")
CreateButton(TrialsPage, "Great Tree Highest", function() TweenToPosition(Vector3.new(2700, 500, 3000), 500) Notify("Great Tree Highest") end)
CreateButton(TrialsPage, "Tween RaceDoor", function() TweenToPosition(Vector3.new(2830, 90, 3100), 500) Notify("RaceDoor") end)
CreateButton(TrialsPage, "Tween Ancient Clock", function() TweenToPosition(Vector3.new(-5020, 80, -3020), 500) Notify("Ancient Clock") end)

CreateSection(TrialsPage, "TRIAL SETUP", "Method trial")
CreateDropdown(TrialsPage, "Select Method", {"Bone","Cake"}, function(opt) State.TrialMethod = opt Notify("Method: "..opt) end)

CreateSection(TrialsPage, "RACE V4", "Race V4 Progress")
CreateButton(TrialsPage, "Race V4 Check", function() Invoke("RaceV4Progress", "Check") Notify("Race V4 Check") end)
CreateButton(TrialsPage, "Race V4 Begin", function() Invoke("RaceV4Progress", "Begin") Notify("Race V4 Begin") end)
CreateButton(TrialsPage, "Race V4 Continue", function() Invoke("RaceV4Progress", "Continue") Notify("Race V4 Continue") end)
CreateButton(TrialsPage, "Finish Trial", function() Invoke("RaceV4Progress", "Finish") Notify("Finish Trial") end)

CreateSection(TrialsPage, "AUTO TRIAL", "Auto trial")
CreateToggle(TrialsPage, "Auto Trial", false, function(s) State.AutoTrial = s Notify("Auto Trial: "..(s and "ON" or "OFF")) end)
CreateToggle(TrialsPage, "Auto Pull Lever", false, function(s) State.AutoPullLever = s Notify("Auto Pull Lever: "..(s and "ON" or "OFF")) end)
CreateToggle(TrialsPage, "Kill Player Trial", false, function(s) State.KillPlayerTrial = s Notify("Kill Player: "..(s and "ON" or "OFF")) end)

--// SETING (ESP)
CreateSection(SetingPage, "ESP / WALLHACK", "Highlight objects")
CreateToggle(SetingPage, "ESP Player", false, function(s) State.ESPPlayer = s Notify("ESP Player: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Island", false, function(s) State.ESPIsland = s Notify("ESP Island: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Fruit", false, function(s) State.ESPFruit = s Notify("ESP Fruit: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Blue Gear", false, function(s) State.ESPBlueGear = s Notify("ESP Blue Gear: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Chest", false, function(s) State.ESPChest = s Notify("ESP Chest: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Flower", false, function(s) State.ESPFlower = s Notify("ESP Flower: "..(s and "ON" or "OFF")) end)

--// TELEPORT
CreateSection(TeleportPage, "TELEPORT", "Tween ke island")
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

CreateButton(TeleportPage, "Tween ke Island", function()
    local pos = IslandCoords[State.SelectedIsland]
    if pos then TweenToPosition(pos + Vector3.new(0,3,0), 500) Notify("Tween: "..State.SelectedIsland) end
end)

CreateSection(TeleportPage, "TRAVEL", "Pindah sea")
CreateButton(TeleportPage, "Travel Main (Sea 1)", function() Invoke("TravelMain") Notify("Travel Main") end)
CreateButton(TeleportPage, "Travel Dressrosa (Sea 2)", function() Invoke("TravelDressrosa") Notify("Travel Dressrosa") end)
CreateButton(TeleportPage, "Travel Zou (Sea 3)", function() Invoke("TravelZou") Notify("Travel Zou") end)

CreateSection(TeleportPage, "TEAM / BOAT", "Team and boat")
CreateButton(TeleportPage, "Set Team Pirates", function() Invoke("SetTeam", "Pirates") Notify("Pirates") end)
CreateButton(TeleportPage, "Set Team Marines", function() Invoke("SetTeam", "Marines") Notify("Marines") end)
CreateButton(TeleportPage, "Buy Boat", function() Invoke("BuyBoat", "Dinghy") Notify("Boat bought") end)
CreateButton(TeleportPage, "Set Spawn", function() Invoke("SetSpawnPoint") Notify("Spawn set") end)

--// STATS
CreateSection(StatsPage, "AUTO ADD STATS", "Distribute stats")
CreateToggle(StatsPage, "Auto Add Stats", false, function(s) State.AutoAddStats = s Notify("Auto Add Stats: "..(s and "ON" or "OFF")) end)
CreateSlider(StatsPage, "Melee", 0, 100, 0, function(v) State.StatsMelee = v end)
CreateSlider(StatsPage, "Sword", 0, 100, 0, function(v) State.StatsSword = v end)
CreateSlider(StatsPage, "Gun", 0, 100, 0, function(v) State.StatsGun = v end)
CreateSlider(StatsPage, "Fruit", 0, 100, 0, function(v) State.StatsBloxFruit = v end)
CreateButton(StatsPage, "Apply Stats Now", function() AutoAddStats() Notify("Stats applied") end)

--// SHOP
CreateSection(ShopPage, "SHOP MELEE", "Buy Fighting Style")
CreateDropdown(ShopPage, "Select Melee", {
    "Black Leg","Electro","Fishman Karate","Sharkman Karate",
    "Dragon Talon","Electric Claw","Death Step","Superhuman","Godhuman",
}, function(opt) State.SelectedMelee = opt Notify("Melee: "..opt) end)

CreateButton(ShopPage, "Buy Selected Melee", function()
    local map = {
        ["Black Leg"]="BuyBlackLeg",["Electro"]="BuyElectro",
        ["Fishman Karate"]="BuyFishmanKarate",["Sharkman Karate"]="BuySharkmanKarate",
        ["Dragon Talon"]="BuyDragonTalon",["Electric Claw"]="BuyElectricClaw",
        ["Death Step"]="BuyDeathStep",["Superhuman"]="BuySuperhuman",["Godhuman"]="BuyGodhuman",
    }
    local fn = map[State.SelectedMelee]
    if fn then Invoke(fn) Notify("Bought: "..State.SelectedMelee) else Notify("Select melee first") end
end)

CreateSection(ShopPage, "SHOP SWORD", "Buy Sword")
CreateDropdown(ShopPage, "Select Sword", {
    "Katana","Cutlass","Iron Mace","Dual Katana","Triple Katana","Pipe","Small Sword",
    "Dual-Headed Blade","Soul Cane","Saber","Rengoku","Shisui","Yama","Tushita",
    "Cursed Dual Katana","Dark Dagger","Buddy Sword","Hallow Scythe","Spikey Trident","Trident",
}, function(opt) State.SelectedSword = opt Notify("Sword: "..opt) end)
CreateButton(ShopPage, "Buy Selected Sword", function()
    if State.SelectedSword then Invoke("BuyItem", State.SelectedSword) Notify("Bought: "..State.SelectedSword) else Notify("Select sword first") end
end)

CreateSection(ShopPage, "SHOP GUN", "Buy Gun")
CreateDropdown(ShopPage, "Select Gun", {
    "Slingshot","Flintlock","Refined Flintlock","Musket","Refined Musket",
    "Cannon","Bazooka","Sniper","Kabucha","Acidum Rifle","Bizarre Rifle","Serpent Bow",
}, function(opt) State.SelectedGun = opt Notify("Gun: "..opt) end)
CreateButton(ShopPage, "Buy Selected Gun", function()
    if State.SelectedGun then Invoke("BuyItem", State.SelectedGun) Notify("Bought: "..State.SelectedGun) else Notify("Select gun first") end
end)

CreateSection(ShopPage, "SHOP ABILITIES", "Buy Haki")
CreateDropdown(ShopPage, "Select Abilities", {"Ken","Buso","Geppo"}, function(opt) State.SelectedAbility = opt Notify("Ability: "..opt) end)
CreateButton(ShopPage, "Buy Selected Ability", function()
    if State.SelectedAbility == "Ken" then Invoke("KenTalk", "Buy") Notify("Ken bought")
    elseif State.SelectedAbility == "Buso" then Invoke("BuyHaki", "Buso") Notify("Buso bought")
    elseif State.SelectedAbility == "Geppo" then Invoke("BuyHaki", "Geppo") Notify("Geppo bought")
    else Notify("Select ability first") end
end)
CreateButton(ShopPage, "Buy Soru", function() Invoke("BuyHaki", "Soru") Notify("Soru bought") end)

--// MISC
CreateSection(MiscPage, "ANTI AFK", "Prevent kick")
CreateToggle(MiscPage, "Anti AFK", true, function(s) State.AntiAFK = s Notify("Anti AFK: "..(s and "ON" or "OFF")) end)

CreateSection(MiscPage, "MOVEMENT", "Movement")
CreateToggle(MiscPage, "Bring Mob", false, function(s) State.BringMob = s Notify("Bring Mob: "..(s and "ON" or "OFF")) end)
CreateSlider(MiscPage, "Bring Mob Range", 0, 100, 50, function(v) State.BringMobRange = v end)
CreateToggle(MiscPage, "Infinite Jump", false, function(s) State.InfiniteJump = s Notify("Infinite Jump: "..(s and "ON" or "OFF")) end)

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

CreateSection(MiscPage, "REDEEM CODE", "Redeem codes")
CreateButton(MiscPage, "Redeem All Codes", function() RedeemAllCodes() end)

CreateSection(MiscPage, "SERVER", "Server options")
CreateButton(MiscPage, "Rejoin Server", function() TeleportService:Teleport(game.PlaceId, Player) end)

--// LOOPS
task.spawn(function()
    while task.wait(CONFIG.FarmDelay) do
        if State.AutoFarm then
            SafeCall(function()
                local ls = Player:FindFirstChild("leaderstats")
                local lv = ls and ls:FindFirstChild("Level")
                local level = lv and lv.Value or 1
                local mobs = FindMobByLevel(level, CONFIG.LevelTolerance)
                if #mobs > 0 then
                    local target = mobs[1].model
                    TweenToMob(target, CONFIG.TweenMobSpeed)
                    local tool = EquipWeapon()
                    if tool then
                        while target.Parent and target:FindFirstChildOfClass("Humanoid")
                            and target.Humanoid.Health > 0 and State.AutoFarm do
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
                if not nearest then State.OpenedChests = {} task.wait(5) return end
                TweenToPosition(nearest.Position + Vector3.new(0, 3, 0), 400)
                State.OpenedChests[GetChestKey(nearest)] = true
                task.wait(0.6)
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if State.AutoBoss and State.SelectedBoss then
            SafeCall(function()
                local boss = FindBoss(State.SelectedBoss)
                if boss then
                    TweenToMob(boss, 300)
                    local tool = EquipWeapon()
                    if tool then
                        while boss.Parent and boss:FindFirstChildOfClass("Humanoid")
                            and boss.Humanoid.Health > 0 and State.AutoBoss do
                            tool:Activate()
                            task.wait(0.1)
                        end
                    end
                end
            end)
        end
    end
end)

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

task.spawn(function()
    while task.wait(60) do
        if State.AutoGacha then
            SafeCall(function() if not GetHeldFruit() then Invoke("BuyFruit", "Random") end end)
        end
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        if State.StoreFruit then
            SafeCall(function() if GetHeldFruit() then DoStoreFruit() end end)
        end
    end
end)

task.spawn(function()
    while task.wait(10) do
        if State.AutoRaid then SafeCall(DoAutoRaid) end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if State.AutoAddStats then SafeCall(AutoAddStats) end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if State.CousinBuy then
            SafeCall(function() Invoke("Cousin", "Buy") end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
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

task.spawn(function()
    while task.wait(0.5) do
        if State.ESPPlayer then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= Player and plr.Character then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then CreateESP(hrp, plr.Name, Color3.fromRGB(255,80,80)) end
                end
            end
        end
        if State.ESPFruit then
            for _, obj in ipairs(FindFruits()) do
                CreateESP(obj, obj.Name, Color3.fromRGB(255,200,80))
            end
        end
        if State.ESPChest then
            for _, obj in ipairs(FindChests()) do
                CreateESP(obj, "Chest", Color3.fromRGB(255,215,0))
            end
        end
        if not State.ESPPlayer and not State.ESPFruit and not State.ESPChest then
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
print("        SYSX HUB v0.2 FREEMIUM")
print("        "..CONFIG.Build)
print("================================")

Notify("SysxHub v0.2 loaded")
return true
