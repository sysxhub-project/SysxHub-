--[[
================================================================
 SYSX HUB - v1.0 | Created by Ramanotsugarr
 Blue Outline + Logo Asset + White Text + CommF_ Chain
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
    Build = "SysxHub v1.0 | Created by Ramanotsugarr",
    Logo = "rbxassetid://78595907369123",
    OpenClose = "rbxassetid://70792832229220",
    Discord = "https://discord.gg/E5kQJW3hn",
    Background = Color3.fromRGB(10,8,18),
    Panel = Color3.fromRGB(17,13,29),
    Panel2 = Color3.fromRGB(23,18,38),
    Panel3 = Color3.fromRGB(30,24,48),
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
    AutoFarm=false, AutoChest=false, AutoBoss=false, AutoQuest=false,
    AutoFruit=false, AutoKillNearest=false, AutoRaid=false, AutoBuyChip=false,
    AutoGacha=false, StoreFruit=false, AutoFish=false, AutoAddStats=false,
    AutoRaceV2=false, AutoRaceV3=false,
    SelectedWeapon=nil, SelectedCategory=nil,
    SelectedBoss=nil, SelectedBossSea=nil, SelectedRaid=nil,
    SelectedPlayer=nil,
    BringMob=false, BringMobRange=50, InfiniteJump=false, BoostFPS=false,
    Hitbox=false, HitboxPart=nil, Aimbot=false,
    KillAura=false, LastKillAura=0, LastBring=0, LastFruitTP=0,
    AntiAFK=true, Notifications=true,
    StatsMelee=0, StatsDefense=0, StatsSword=0, StatsGun=0, StatsBloxFruit=0,
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

local function FindObjectByKeyword(kw)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if string.find(string.lower(obj.Name), string.lower(kw)) then
            if obj:IsA("BasePart") then return obj end
            if obj:IsA("Model") and obj.PrimaryPart then return obj.PrimaryPart end
        end
    end
    return nil
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

local function IsInRaidIsland3()
    local ls = Player:FindFirstChild("leaderstats")
    local lv = ls and ls:FindFirstChild("Level")
    if not lv or lv.Value < 1500 then return false end
    return GetRaidIsland() >= 3
end

--// COMMF_ ACTIONS
local function AutoAddStats()
    if not CommF then return false end
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
end

local function DoStoreFruit()
    local held = GetHeldFruit()
    if not held then return end
    if CommF then
        pcall(function() CommF:InvokeServer("StoreFruit", held.Name) end)
    elseif REMOTE_StoreFruit then
        pcall(function()
            if REMOTE_StoreFruit:IsA("RemoteEvent") then REMOTE_StoreFruit:FireServer(held)
            else REMOTE_StoreFruit:InvokeServer(held) end
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
    pcall(function()
        fireclickdetector(workspace.Map["Boat Castle"].RaidSummon2.Button.Main.ClickDetector)
    end)
    Notify("Raid: "..State.SelectedRaid)
end

local function DoBuyChip()
    if not CommF or not State.SelectedRaid then return end
    pcall(function() CommF:InvokeServer("RaidsNpc", "Select", State.SelectedRaid) end)
    Notify("BuyChip: "..State.SelectedRaid)
end

--// COMMF_ CHAIN
local function GetQuestChain(questName)
    if not CommF then Notify("CommF_ not found") return false end
    if questName == "CDK" then
        pcall(function() CommF:InvokeServer("ProQuestProgress", "CDK") end)
        Notify("Starting CDK Puzzle (Lv 2200+)")
    elseif questName == "DarkDagger" or questName == "Indra" then
        local hasChalice = Player.Backpack:FindFirstChild("God's Chalice")
            or (Player.Character and Player.Character:FindFirstChild("God's Chalice"))
        if not hasChalice then Notify("Need God's Chalice!") return false end
        pcall(function() CommF:InvokeServer("PlaceChalice") end)
        Notify("rip_indra summoning")
    elseif questName == "SoulGuitar" then
        pcall(function() CommF:InvokeServer("ProQuestProgress", "SoulGuitar") end)
        Notify("Soul Guitar puzzle (Lv 2300+)")
    elseif questName == "Yama" then
        pcall(function() CommF:InvokeServer("StartQuest", "EliteHunter", 1) end)
        Notify("Elite Hunter quest started")
    elseif questName == "Tushita" then
        pcall(function() CommF:InvokeServer("ProQuestProgress", "Tushita") end)
        Notify("Tushita torch puzzle (Lv 2000+)")
    elseif questName == "BuddySword" then
        local boss = FindBoss("Cake Queen")
        if boss then TweenToMob(boss, 300) Notify("Farming Cake Queen")
        else Notify("Cake Queen not spawned (wait 30 min)") end
    elseif questName == "DoughKing" then
        local hasSweet = Player.Backpack:FindFirstChild("Sweet Chalice")
            or (Player.Character and Player.Character:FindFirstChild("Sweet Chalice"))
        if not hasSweet then Notify("Need Sweet Chalice!") return false end
        pcall(function() CommF:InvokeServer("DoughKing") end)
        Notify("Summoning Dough King")
    end
    return true
end

--// REDEEM
local RedeemCodes = {
    "KITT_RESET","SUB2GAMERROBOT_RESET1","SUB2GAMERROBOT_EXP1",
    "SUB2OFFICIALNOOBIE","AXIORE","BLUXXY","JCWK","KITTGAMING",
    "MAGICBUS","STARCODEHEO","STRAWHATMAINE","TANTAIGAMING",
    "THEGREATACE","ENYU_IS_PRO",
}

local function RedeemAllCodes()
    if not CommF then Notify("CommF_ not found") return end
    for _, code in ipairs(RedeemCodes) do
        pcall(function() CommF:InvokeServer("Redeem", code) end)
        Notify("Redeeming: "..code)
        task.wait(1)
    end
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

--// LOGO (Asset ID)
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
local StatsPage = CreatePage("Stats")
local SetingPage = CreatePage("Seting")
local MiscPage = CreatePage("Misc")

--// WEAPON LIST
local WeaponListHolder = Create("Frame", {Parent=FarmPage, BackgroundColor3=CONFIG.Panel, Size=UDim2.new(1,0,0,180), BorderSizePixel=0, ZIndex=13})
Corner(WeaponListHolder, 10)
Stroke(WeaponListHolder, CONFIG.Blue, 1.5, 0.3)
local WeaponListScroll = Create("ScrollingFrame", {Parent=WeaponListHolder, BackgroundTransparency=1, Position=UDim2.new(0,8,0,8), Size=UDim2.new(1,-16,1,-16), CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=3, ScrollBarImageColor3=CONFIG.Blue, BorderSizePixel=0, ZIndex=14})
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

--// BOSS LIST
local BossListHolder = Create("Frame", {Parent=FarmPage, BackgroundColor3=CONFIG.Panel, Size=UDim2.new(1,0,0,200), BorderSizePixel=0, ZIndex=13})
Corner(BossListHolder, 10)
Stroke(BossListHolder, CONFIG.Blue, 1.5, 0.3)
local BossListScroll = Create("ScrollingFrame", {Parent=BossListHolder, BackgroundTransparency=1, Position=UDim2.new(0,8,0,8), Size=UDim2.new(1,-16,1,-16), CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=3, ScrollBarImageColor3=CONFIG.Blue, BorderSizePixel=0, ZIndex=14})
local BL = Instance.new("UIListLayout")
BL.Padding = UDim.new(0,6)
BL.SortOrder = Enum.SortOrder.LayoutOrder
BL.Parent = BossListScroll

local function ShowBossBySea(sea)
    for _, c in ipairs(BossListScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for i, b in ipairs(BossData[sea] or {}) do
        local Btn = Create("TextButton", {Parent=BossListScroll, BackgroundColor3=CONFIG.Panel2, Size=UDim2.new(1,0,0,46), Text="- "..b.Name.." (Lv "..b.Level..")\n  "..b.Location..(b.Raid and " [Raid]" or ""), TextColor3=CONFIG.White, TextSize=11, Font=Enum.Font.GothamMedium, AutoButtonColor=false, BorderSizePixel=0, LayoutOrder=i, ZIndex=15, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top})
        Corner(Btn, 8)
        Padding(Btn, 12,12,6,6)
        Btn.Activated:Connect(function()
            State.SelectedBoss = b.Name
            State.SelectedBossSea = sea
            Notify("Boss: "..b.Name)
        end)
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

CreateSection(FarmPage, "WEAPON", "Select weapon")
CreateDropdown(FarmPage, "Select Tool", {"Melee","Sword","Gun","Fruit"}, function(opt)
    State.SelectedCategory = opt
    ShowWeaponsInCategory(opt)
end)

CreateSection(FarmPage, "BOSS", "Select boss")
CreateDropdown(FarmPage, "Select Sea", {"Sea1","Sea2","Sea3"}, function(opt) ShowBossBySea(opt) end)
CreateToggle(FarmPage, "Auto Farm Boss", false, function(s)
    State.AutoBoss = s
    if s and not State.SelectedBoss then Notify("Select boss first") State.AutoBoss = false
    else Notify("Auto Farm Boss: "..(s and "ON" or "OFF")) end
end)

CreateSection(FarmPage, "CHEST", "Auto farm chest")
CreateToggle(FarmPage, "Farm Chest", false, function(s)
    State.AutoChest = s
    if s then State.OpenedChests = {} end
    Notify("Farm Chest: "..(s and "ON" or "OFF"))
end)

--// SEA
CreateSection(SeaPage, "SEA", "Sea mobs")
CreateToggle(SeaPage, "Auto Farm Sea", false, function(s) Notify("Auto Farm Sea: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Auto Kill Sea Beast", false, function(s) Notify("Auto Kill Sea Beast: "..(s and "ON" or "OFF")) end)

--// QUEST / ITEMS
CreateSection(QuestItemsPage, "AUTO QUEST", "Basic auto quest")
CreateToggle(QuestItemsPage, "Auto Quest", false, function(s) State.AutoQuest=s Notify("Auto Quest: "..(s and "ON" or "OFF")) end)

CreateSection(QuestItemsPage, "COMMF_ CHAIN", "Auto quest items")
CreateButton(QuestItemsPage, "Auto CDK (Lv 2200+)", function() GetQuestChain("CDK") end)
CreateButton(QuestItemsPage, "Auto Dark Dagger (God's Chalice)", function() GetQuestChain("DarkDagger") end)
CreateButton(QuestItemsPage, "Auto Soul Guitar (Lv 2300+)", function() GetQuestChain("SoulGuitar") end)
CreateButton(QuestItemsPage, "Auto Yama (30 Elite Hunter)", function() GetQuestChain("Yama") end)
CreateButton(QuestItemsPage, "Auto Tushita (Lv 2000+)", function() GetQuestChain("Tushita") end)
CreateButton(QuestItemsPage, "Auto Buddy Sword (Kill Cake Queen)", function() GetQuestChain("BuddySword") end)
CreateButton(QuestItemsPage, "Auto Kill Indra (God's Chalice)", function() GetQuestChain("Indra") end)
CreateButton(QuestItemsPage, "Auto Spawn Dough King (Sweet Chalice)", function() GetQuestChain("DoughKing") end)

CreateSection(QuestItemsPage, "RACE", "Auto Race V2 & V3")
CreateToggle(QuestItemsPage, "Auto Race V2", false, function(s) State.AutoRaceV2=s Notify("Auto Race V2: "..(s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Race V3", false, function(s) State.AutoRaceV3=s Notify("Auto Race V3: "..(s and "ON" or "OFF")) end)

--// FRUIT / RAID
CreateSection(FruitRaidPage, "FRUIT", "Auto collect fruit")
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

--// STATUS
CreateSection(StatusPage, "STATUS", "Player info + boss per sea")
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
            local bossText = ""
            for _, b in ipairs(bossList) do
                bossText = bossText .. string.format("\n%s (Lv %d) - %s", b.Name, b.Level, b.Location)
            end
            StatusLabel.Text = string.format("Level: %d\nSea: %s\nRaid Island: %d\n\nBosses %s:%s", lv, sea, GetRaidIsland(), sea, bossText)
        end
    end
end)

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

CreateButton(PvPPage, "Teleport Player (Tween)", function()
    if not State.SelectedPlayer then Notify("Select player first") return end
    local target = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name == State.SelectedPlayer then target = plr break end
    end
    if not target or not target.Character then Notify("Player not found") return end
    local trp = target.Character:FindFirstChild("HumanoidRootPart")
    if not trp then Notify("No HRP") return end
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

--// SETING (ESP)
CreateSection(SetingPage, "ESP / WALLHACK", "Highlight objects")
CreateToggle(SetingPage, "ESP Player", false, function(s) State.ESPPlayer=s Notify("ESP Player: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Island", false, function(s) State.ESPIsland=s Notify("ESP Island: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Fruit", false, function(s) State.ESPFruit=s Notify("ESP Fruit: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Blue Gear", false, function(s) State.ESPBlueGear=s Notify("ESP Blue Gear: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Chest", false, function(s) State.ESPChest=s Notify("ESP Chest: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Flower", false, function(s) State.ESPFlower=s Notify("ESP Flower: "..(s and "ON" or "OFF")) end)

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

CreateSection(MiscPage, "REDEEM CODE", "Redeem all codes")
CreateButton(MiscPage, "Redeem All Codes", function() RedeemAllCodes() end)

CreateSection(MiscPage, "SERVER", "Server options")
CreateButton(MiscPage, "Rejoin Server", function() TeleportService:Teleport(game.PlaceId, Player) end)

--// LOOPS
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

task.spawn(function()
    while task.wait(60) do
        if State.AutoGacha then
            SafeCall(function() if not GetHeldFruit() then DoGacha() end end)
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
    while task.wait(15) do
        if State.AutoBuyChip then SafeCall(DoBuyChip) end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if State.AutoAddStats then SafeCall(AutoAddStats) end
    end
end)

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
        if State.ESPIsland then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = string.lower(obj.Name)
                    if string.find(n,"island") or string.find(n,"portal") or string.find(n,"teleport") then
                        CreateESP(obj, obj.Name, Color3.fromRGB(80,200,255))
                    end
                end
            end
        end
        if State.ESPFruit then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "fruit") then
                    if obj.Parent == workspace or (obj.Parent and obj.Parent.Name == "Map") then
                        CreateESP(obj, obj.Name, Color3.fromRGB(255,200,80))
                    end
                end
            end
        end
        if State.ESPBlueGear then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = string.lower(obj.Name)
                    if string.find(n,"bluegear") or string.find(n,"blue_gear") or string.find(n,"gear") then
                        CreateESP(obj, "Blue Gear", Color3.fromRGB(0,150,255))
                    end
                end
            end
        end
        if State.ESPChest then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = string.lower(obj.Name)
                    if string.find(n,"chest") or string.find(n,"treasure") or string.find(n,"reward") then
                        CreateESP(obj, "Chest", Color3.fromRGB(255,215,0))
                    end
                end
            end
        end
        if State.ESPFlower then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = string.lower(obj.Name)
                    if string.find(n,"flower") or string.find(n,"blossom") or string.find(n,"petal") then
                        CreateESP(obj, obj.Name, Color3.fromRGB(255,100,200))
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
    {"Fishing"}, {"Status"}, {"PvP"}, {"Stats"}, {"Seting"}, {"Misc"},
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
print("        SYSX HUB LOADED v1.0")
print("        "..CONFIG.Build)
print("================================")

Notify("SysxHub v1.0 loaded")
return true
