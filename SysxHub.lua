--[[
================================================================
 SYSX HUB | Freemium Version | v0.1 | Created by Ramanotsugarr
 Clean UI + Full CommF_ + Auto Haki Integration
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
    LevelTolerance = 50,
    TweenMobSpeed = 250,
}

local State = {
    AutoFarm=false, AutoChest=false, AutoBoss=false,
    AutoFruit=false, AutoKillNearest=false, AutoRaid=false,
    AutoGacha=false, StoreFruit=false, AutoFish=false, AutoAddStats=false,
    AutoRaceV2=false, AutoRaceV3=false, CousinBuy=false,
    AutoFarmSea=false, AutoKillSeaBeast=false,
    SelectedWeapon=nil, SelectedCategory=nil,
    SelectedBoss=nil, SelectedRaid=nil, SelectedPlayer=nil,
    SelectedIsland="Starter Island", SelectedMelee=nil, SelectedSword=nil,
    SelectedGun=nil, SelectedAbility=nil, SelectedItem=nil,
    BringMob=false, BringMobRange=50, InfiniteJump=false, BoostFPS=false,
    Hitbox=false, HitboxPart=nil, Aimbot=false,
    LastBring=0, AntiAFK=true, Notifications=true,
    StatsMelee=0, StatsSword=0, StatsGun=0, StatsBloxFruit=0,
    OriginalLighting=nil,
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

--// FARM CHEST (Adaptasi dari kode user)
local MaxSpeed = 300

local function getCharacter()
    if not Player.Character then
        Player.CharacterAdded:Wait()
    end
    Player.Character:WaitForChild("HumanoidRootPart")
    return Player.Character
end

local function toggleNoclip(toggle)
    for _, v in pairs(getCharacter():GetChildren()) do
        if v:IsA("BasePart") then
            v.CanCollide = not toggle
        end
    end
end

local function DistanceFromPlrSort(list)
    local root = getCharacter().HumanoidRootPart
    table.sort(list, function(a, b)
        local pos = root.Position
        return (pos - a.Position).Magnitude < (pos - b.Position).Magnitude
    end)
end

local UncheckedChests = {}
local FirstRunChest = true

local function getChestsSorted()
    if FirstRunChest then
        FirstRunChest = false
        for _, obj in ipairs(game:GetDescendants()) do
            if obj.Name:find("Chest") and obj.ClassName == "Part" then
                table.insert(UncheckedChests, obj)
            end
        end
    end
    local chests = {}
    for _, chest in ipairs(UncheckedChests) do
        if chest:FindFirstChild("TouchInterest") then
            table.insert(chests, chest)
        end
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

--// SMOOTH AIMBOT
local AimbotConnection = nil
local AimbotTarget = nil

local function GetClosestPlayerHead()
    local closest, dist = nil, math.huge
    local camPos = Camera.CFrame.Position
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local d = (head.Position - camPos).Magnitude
                if d < dist and d < 500 then
                    closest, dist = head, d
                end
            end
        end
    end
    return closest
end

local function StartAimbot()
    if AimbotConnection then AimbotConnection:Disconnect() end
    AimbotConnection = RunService.RenderStepped:Connect(function(dt)
        if not State.Aimbot then return end
        AimbotTarget = GetClosestPlayerHead()
        if not AimbotTarget then return end
        local currentCF = Camera.CFrame
        local targetCF = CFrame.new(currentCF.Position, AimbotTarget.Position)
        Camera.CFrame = currentCF:Lerp(targetCF, math.clamp(dt * 10, 0, 1))
    end)
end

local function StopAimbot()
    if AimbotConnection then
        AimbotConnection:Disconnect()
        AimbotConnection = nil
    end
    AimbotTarget = nil
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
CreateToggle(DiscordPage, "Copy Discord Link", false, function(s)
    if s then
        if setclipboard then setclipboard(CONFIG.Discord) Notify("Copied") end
    end
end)

--// FARM
CreateToggle(FarmPage, "Cek Bones", false, function(s)
    if s then
        local res = Invoke("Bones", "Check")
        Notify("Bones: "..tostring(res))
    end
end)
CreateToggle(FarmPage, "Random Bones", false, function(s)
    if s then Invoke("Bones", "Buy", 1, 1) Notify("Random Bones") end
end)
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
CreateDropdown(FarmPage, "Select Weapon", {"Melee","Sword","Gun","Fruit"}, function(opt)
    State.SelectedCategory = opt
end)
CreateDropdown(FarmPage, "Select Boss", {
    "Gorilla King","Bobby","Yeti","Mob Leader","Vice Admiral","Saber Expert",
    "Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper",
    "Thunder God","Cyborg","Diamond","Jeremy","Fajita","Don Swan","Darkbeard",
    "Smoke Admiral","Cursed Captain","Awakened Ice Admiral","Tide Keeper",
    "Stone","Island Empress","Kilo Admiral","Captain Elephant",
    "Beautiful Pirate","Longma","Cake Queen",
}, function(opt) State.SelectedBoss = opt Notify("Boss: "..opt) end)
CreateToggle(FarmPage, "Auto Farm Boss", false, function(s)
    State.AutoBoss = s
    Notify("Auto Farm Boss: "..(s and "ON" or "OFF"))
end)
CreateToggle(FarmPage, "Farm Chest", false, function(s)
    State.AutoChest = s
    if s then FirstRunChest = true UncheckedChests = {} end
    Notify("Farm Chest: "..(s and "ON" or "OFF"))
end)

--// SEA
CreateToggle(SeaPage, "Auto Farm Sea", false, function(s) State.AutoFarmSea = s Notify("Auto Farm Sea: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Auto Kill Sea Beast", false, function(s) State.AutoKillSeaBeast = s Notify("Auto Kill Sea Beast: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Buy Boat", false, function(s) if s then Invoke("BuyBoat", "Dinghy") Notify("Boat bought") end end)
CreateToggle(SeaPage, "Travel Main (Sea 1)", false, function(s) if s then Invoke("TravelMain") Notify("Sea 1") end end)
CreateToggle(SeaPage, "Travel Dressrosa (Sea 2)", false, function(s) if s then Invoke("TravelDressrosa") Notify("Sea 2") end end)
CreateToggle(SeaPage, "Travel Zou (Sea 3)", false, function(s) if s then Invoke("TravelZou") Notify("Sea 3") end end)

--// QUEST / ITEMS
CreateToggle(QuestItemsPage, "Auto Sea 2", false, function(s) if s then Invoke("TravelDressrosa") Notify("Auto Sea 2") end end)
CreateToggle(QuestItemsPage, "Auto Sea 3", false, function(s) if s then Invoke("TravelZou") Notify("Auto Sea 3") end end)
CreateToggle(QuestItemsPage, "Auto Saber", false, function(s)
    if s then Invoke("BuyItem", "Saber") Notify("Auto Saber") end
end)
CreateToggle(QuestItemsPage, "Auto Quest", false, function(s) State.AutoQuest = s Notify("Auto Quest: "..(s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto CDK", false, function(s) if s then Invoke("ProQuestProgress", "CDK") Notify("CDK") end end)
CreateToggle(QuestItemsPage, "Auto Dark Dagger", false, function(s)
    if s then
        local hasChalice = Player.Backpack:FindFirstChild("God's Chalice")
            or (Player.Character and Player.Character:FindFirstChild("God's Chalice"))
        if hasChalice then Invoke("PlaceChalice") Notify("Summoning Indra")
        else Notify("Need God's Chalice!") end
    end
end)
CreateToggle(QuestItemsPage, "Auto Soul Guitar", false, function(s) if s then Invoke("ProQuestProgress", "SoulGuitar") Notify("Soul Guitar") end end)
CreateToggle(QuestItemsPage, "Auto Yama", false, function(s) if s then Invoke("StartQuest", "EliteHunter", 1) Notify("Elite Hunter") end end)
CreateToggle(QuestItemsPage, "Auto Tushita", false, function(s) if s then Invoke("ProQuestProgress", "Tushita") Notify("Tushita") end end)
CreateToggle(QuestItemsPage, "Auto Buddy Sword", false, function(s)
    if s then
        local boss = FindBoss("Cake Queen")
        if boss then TweenToMob(boss, 300) Notify("Farming Cake Queen") else Notify("Cake Queen not spawned") end
    end
end)
CreateToggle(QuestItemsPage, "Auto Spawn Dough King", false, function(s)
    if s then
        local hasSweet = Player.Backpack:FindFirstChild("Sweet Chalice")
            or (Player.Character and Player.Character:FindFirstChild("Sweet Chalice"))
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
CreateToggle(FruitRaidPage, "Bones Check", false, function(s) if s then local res = Invoke("Bones", "Check") Notify("Bones: "..tostring(res)) end end)
CreateToggle(FruitRaidPage, "Bones Surprise", false, function(s) if s then Invoke("Bones", "Buy", 1, 1) Notify("Surprise") end end)
CreateToggle(FruitRaidPage, "Bones Stat Refund", false, function(s) if s then Invoke("Bones", "Buy", 1, 2) Notify("Stat Refund") end end)
CreateToggle(FruitRaidPage, "Bones Race Reroll", false, function(s) if s then Invoke("Bones", "Buy", 1, 3) Notify("Race Reroll") end end)
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
CreateToggle(PvPPage, "Hitbox", false, function(s) State.Hitbox = s Notify("Hitbox: "..(s and "ON" or "OFF")) end)

--// TRIALS
CreateToggle(TrialsPage, "Great Tree Highest", false, function(s) if s then TweenToPosition(Vector3.new(2700,500,3000),500) end end)
CreateToggle(TrialsPage, "Tween RaceDoor", false, function(s) if s then TweenToPosition(Vector3.new(2830,90,3100),500) end end)
CreateToggle(TrialsPage, "Tween Ancient Clock", false, function(s) if s then TweenToPosition(Vector3.new(-5020,80,-3020),500) end end)
CreateDropdown(TrialsPage, "Select Method", {"Bone","Cake"}, function(opt) State.TrialMethod = opt Notify("Method: "..opt) end)
CreateToggle(TrialsPage, "Race V4 Check", false, function(s) if s then Invoke("RaceV4Progress", "Check") Notify("Race V4 Check") end end)
CreateToggle(TrialsPage, "Race V4 Begin", false, function(s) if s then Invoke("RaceV4Progress", "Begin") Notify("Race V4 Begin") end end)
CreateToggle(TrialsPage, "Race V4 Continue", false, function(s) if s then Invoke("RaceV4Progress", "Continue") Notify("Race V4 Continue") end end)
CreateToggle(TrialsPage, "Train Progress", false, function(s) if s then Invoke("RaceV4Progress", "Continue") Notify("Train Progress") end end)
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
CreateToggle(TeleportPage, "Travel Main", false, function(s) if s then Invoke("TravelMain") end end)
CreateToggle(TeleportPage, "Travel Dressrosa", false, function(s) if s then Invoke("TravelDressrosa") end end)
CreateToggle(TeleportPage, "Travel Zou", false, function(s) if s then Invoke("TravelZou") end end)
CreateToggle(TeleportPage, "Set Spawn", false, function(s) if s then Invoke("SetSpawnPoint") end end)

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
        local map = {
            ["Black Leg"]="BuyBlackLeg",["Electro"]="BuyElectro",
            ["Fishman Karate"]="BuyFishmanKarate",["Sharkman Karate"]="BuySharkmanKarate",
            ["Dragon Talon"]="BuyDragonTalon",["Electric Claw"]="BuyElectricClaw",
            ["Death Step"]="BuyDeathStep",["Superhuman"]="BuySuperhuman",["Godhuman"]="BuyGodhuman",
        }
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
CreateToggle(MiscPage, "Redeem All Codes", false, function(s)
    if s then
        local codes = {"KITT_RESET","SUB2GAMERROBOT_RESET1","SUB2GAMERROBOT_EXP1","SUB2OFFICIALNOOBIE","AXIORE","BLUXXY","JCWK","KITTGAMING","MAGICBUS","STARCODEHEO","STRAWHATMAINE","TANTAIGAMING","THEGREATACE","ENYU_IS_PRO"}
        for _, code in ipairs(codes) do Invoke("Redeem", code) Notify("Redeeming: "..code) task.wait(1) end
    end
end)
CreateToggle(MiscPage, "Rejoin Server", false, function(s) if s then TeleportService:Teleport(game.PlaceId, Player) end end)
CreateToggle(MiscPage, "Join Marine", false, function(s) if s then Invoke("SetTeam", "Marines") Notify("Joined Marines") end end)
CreateToggle(MiscPage, "Join Pirate", false, function(s) if s then Invoke("SetTeam", "Pirates") Notify("Joined Pirates") end end)

--// LOOPS
task.spawn(function()
    while task.wait(0.1) do
        if State.AutoFarm then
            SafeCall(function()
                local ls = Player:FindFirstChild("leaderstats")
                local lv = ls and ls:FindFirstChild("Level")
                local level = lv and lv.Value or 1
                local mobs = FindMobByLevel(level, CONFIG.LevelTolerance)
                if #mobs > 0 then
                    local target = mobs[1].model
                    local trp = target:FindFirstChild("HumanoidRootPart")
                    local hum = target:FindFirstChildOfClass("Humanoid")
                    if trp and hum and hum.Health > 0 then
                        TweenToPosition(trp.Position + Vector3.new(0, 3, 0), CONFIG.TweenMobSpeed)
                        local tool = EquipWeapon()
                        if tool then
                            local timeout = 0
                            while target.Parent and hum.Health > 0 and State.AutoFarm and timeout < 100 do
                                local hrp = GetHRP()
                                if hrp and GetDist(hrp.Position, trp.Position) > 30 then
                                    TweenToPosition(trp.Position + Vector3.new(0, 3, 0), CONFIG.TweenMobSpeed)
                                end
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

task.spawn(function()
    while task.wait(0.3) do
        if State.AutoChest then
            SafeCall(function()
                local chests = getChestsSorted()
                if #chests > 0 then TeleportNoclip(chests[1].CFrame)
                else Notify("Chest habis, tunggu respawn") task.wait(5) FirstRunChest = true UncheckedChests = {} end
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
                        while boss.Parent and boss:FindFirstChildOfClass("Humanoid") and boss.Humanoid.Health > 0 and State.AutoBoss do
                            tool:Activate() task.wait(0.1)
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
            SafeCall(function()
                local held = GetHeldFruit()
                if held then Invoke("StoreFruit", held.Name, held) Notify("Stored: "..held.Name) end
            end)
        end
    end
end)

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

task.spawn(function()
    while task.wait(1) do
        if State.CousinBuy then SafeCall(function() Invoke("Cousin", "Buy") end) end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if State.Hitbox then
            local hrp = GetHRP()
            if hrp then
                if not State.HitboxPart or not State.HitboxPart.Parent then
                    local hb = Instance.new("Part")
                    hb.Name = "SysxHitbox" hb.Size = Vector3.new(10,10,10)
                    hb.Transparency = 1 hb.CanCollide = false hb.CanTouch = true
                    hb.Anchored = true hb.Massless = true hb.Parent = workspace
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
    while task.wait(0.1) do
        if State.BringMob then
            local now = os.clock()
            if now - State.LastBring >= 0.3 then
                local hrp = GetHRP()
                if hrp then
                    local targetPos = hrp.Position + hrp.CFrame.LookVector * 6
                    for _, model in ipairs(workspace:GetChildren()) do
                        if IsNPC(model) then
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
            for _, obj in ipairs(FindFruits()) do CreateESP(obj, obj.Name, Color3.fromRGB(255,200,80)) end
        end
        if State.ESPChest then
            for _, obj in ipairs(getChestsSorted()) do CreateESP(obj, "Chest", Color3.fromRGB(255,215,0)) end
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
