--[[
================================================================
 SYSX HUB - FREEMIUM VERSION | v1.3 | Created by Ramanotsugarr
 Single File - Full Code
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

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

local CONFIG = {
    Name = "SysxHub",
    Build = "Freemium Version | v1.3 | Created by Ramanotsugarr",
    Credit = "Ramanotsugarr",
    Logo = "rbxassetid://136425814447688",
    OpenClose = "rbxassetid://70792832229220",
    Discord = "https://discord.gg/E5kQJW3hn",
    Background = Color3.fromRGB(10, 8, 18),
    Panel = Color3.fromRGB(17, 13, 29),
    Panel2 = Color3.fromRGB(23, 18, 38),
    Panel3 = Color3.fromRGB(30, 24, 48),
    Purple = Color3.fromRGB(125, 70, 255),
    Blue = Color3.fromRGB(80, 140, 255),
    Text = Color3.fromRGB(245, 242, 255),
    SubText = Color3.fromRGB(165, 158, 185),
    Success = Color3.fromRGB(80, 220, 120),
    Warning = Color3.fromRGB(255, 200, 80),
    Danger = Color3.fromRGB(255, 80, 90),
    Radius = 10,
    MaxLevel = 2800,
    AttackRange = 55,
    FarmDelay = 0.12,
    RandomFruitCooldown = 7200,
    RaidMinLevel = 1500,
    ChestDelay = 0.8,
}

local State = {
    AutoFarm=false, AutoChest=false, AutoBoss=false, AutoMaterial=false,
    AutoAttack=false, AutoQuest=false, AutoFruit=false, AutoRaid=false,
    AutoFishing=false, AutoCatch=false, AutoSell=false, AutoIsland=false,
    AutoSword=false, AutoKOKO=false, AutoSecret=false,
    AutoKillNearest=false, AutoCDK=false, AutoDarkDagger=false,
    AutoSoulGuitar=false, AutoYama=false, AutoTushita=false,
    AutoBuddySword=false, AutoKillIndra=false, AutoSpawnDoughKing=false,
    FruitSniper=false, PvPMode=false, ESPPlayers=false, Aimbot=false,
    KillAura=false, Hitbox=false, BringMob=false,
    UIAnimation=true, Notifications=true, AntiAFK=true,
    CurrentIsland=nil, CurrentSword=nil, CurrentBoss=nil, CurrentRaid=nil,
    KillCount=0, StartTime=os.time(), SelectedSword=nil,
    RandomFruit=false, StoreFruit=false, LastRandomFruit=0,
    AutoBuyChip=false, StoreChip=false, LastBuyChip=0,
    AutoFragment=false,
    LastAttack=0, LastKillAura=0, LastBring=0,
    HitboxPart=nil,
    OpenedChests = {},
}

local old = PlayerGui:FindFirstChild("SysxHub")
if old then old:Destroy() end

local function Create(className, props)
    local obj = Instance.new(className)
    for property, value in pairs(props or {}) do
        pcall(function() obj[property] = value end)
    end
    return obj
end

local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or CONFIG.Radius)
    c.Parent = parent
    return c
end

local function Stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or CONFIG.Purple
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end

local function Gradient(parent, c1, c2, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1 or CONFIG.Purple, c2 or CONFIG.Blue)
    g.Rotation = rotation or 45
    g.Parent = parent
    return g
end

local function Padding(parent, l, r, t, b)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.Parent = parent
    return p
end

local function Tween(obj, properties, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties):Play()
end

local function GetCharacter() return Player.Character end
local function GetHRP() local c = Player.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function GetDistance(a, b) return (a - b).Magnitude end

local function SafeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[SysxHub Error]", err) return false, err end
    return true
end

local function IsAlive(model)
    local hum = model and model:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function IsNPC(model)
    if not model or model == Player.Character then return false end
    if not model:FindFirstChildOfClass("Humanoid") then return false end
    if not model:FindFirstChild("HumanoidRootPart") then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    return IsAlive(model)
end

local function IsEnemyPlayer(model)
    if not model or model == Player.Character then return false end
    local plr = Players:GetPlayerFromCharacter(model)
    if not plr then return false end
    if plr:IsFriendsWith(Player.UserId) then return false end
    return IsAlive(model)
end

--// REMOTE AUTO DETECT
local function FindRemote(...)
    local keywords = {...}
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local lname = string.lower(obj.Name)
            for _, kw in ipairs(keywords) do
                if string.find(lname, string.lower(kw)) then
                    return obj
                end
            end
        end
    end
    return nil
end

local function FindRemoteExact(name)
    for _, obj in ipairs(game:GetDescendants()) do
        if obj.Name == name and (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
            return obj
        end
    end
    return nil
end

local REMOTE_RandomFruit = FindRemoteExact("RandomFruit") or FindRemote("randomfruit","gacha","zioles","rollfruit","fruitgacha")
local REMOTE_BuyChip = FindRemoteExact("BuyChip") or FindRemote("buychip","purchasechip","raidchip","microchip")
local REMOTE_StoreFruit = FindRemoteExact("StoreFruit") or FindRemote("storefruit","fruitstore","savefruit")

--// GUI BASE
local Gui = Create("ScreenGui", {
    Name="SysxHub", Parent=PlayerGui, ResetOnSpawn=false,
    IgnoreGuiInset=true, DisplayOrder=999999,
    ZIndexBehavior=Enum.ZIndexBehavior.Global,
})

local UIScale = Instance.new("UIScale")
UIScale.Scale = 1
UIScale.Parent = Gui

local function UpdateScale()
    if not Camera then return end
    local vp = Camera.ViewportSize
    if vp.X <= 500 then UIScale.Scale = math.clamp(vp.X / 420, 0.82, 1)
    elseif vp.X <= 800 then UIScale.Scale = 0.9
    else UIScale.Scale = 1 end
end
UpdateScale()
if Camera then Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale) end

local OpenButton = Create("ImageButton", {
    Name="OpenButton", Parent=Gui, BackgroundColor3=CONFIG.Panel,
    BackgroundTransparency=0, Size=UDim2.fromOffset(64, 64),
    Position=UDim2.new(0, 18, 0.5, -32), Image=CONFIG.OpenClose,
    AutoButtonColor=false, Visible=true, ZIndex=100,
})
Corner(OpenButton, 16)
Stroke(OpenButton, CONFIG.Purple, 2, 0.15)
Gradient(OpenButton, CONFIG.Purple, CONFIG.Blue, 45)

local Main = Create("Frame", {
    Name="Main", Parent=Gui, AnchorPoint=Vector2.new(0.5, 0.5),
    Position=UDim2.fromScale(0.5, 0.5), Size=UDim2.new(0, 760, 0, 480),
    BackgroundColor3=CONFIG.Background, BorderSizePixel=0,
    Visible=true, ZIndex=10,
})
Corner(Main, 14)
Stroke(Main, CONFIG.Purple, 1, 0.45)

local MainConstraint = Instance.new("UISizeConstraint")
MainConstraint.MaxSize = Vector2.new(850, 560)
MainConstraint.MinSize = Vector2.new(310, 360)
MainConstraint.Parent = Main

local TopBar = Create("Frame", {
    Name="TopBar", Parent=Main, BackgroundColor3=CONFIG.Panel,
    Size=UDim2.new(1, 0, 0, 64), BorderSizePixel=0, ZIndex=20,
})
Corner(TopBar, 14)
Gradient(TopBar, CONFIG.Panel, CONFIG.Panel2, 0)

Create("ImageLabel", {
    Name="Logo", Parent=TopBar, BackgroundTransparency=1,
    Size=UDim2.fromOffset(48, 48), Position=UDim2.new(0, 10, 0.5, -24),
    Image=CONFIG.Logo, ScaleType=Enum.ScaleType.Fit, ZIndex=21,
})

Create("TextLabel", {
    Name="Title", Parent=TopBar, BackgroundTransparency=1,
    Position=UDim2.new(0, 66, 0, 8), Size=UDim2.new(0, 250, 0, 25),
    Text="SysxHub", TextColor3=CONFIG.Text, TextSize=20,
    Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=21,
})

Create("TextLabel", {
    Name="Subtitle", Parent=TopBar, BackgroundTransparency=1,
    Position=UDim2.new(0, 67, 0, 33), Size=UDim2.new(0, 400, 0, 18),
    Text=CONFIG.Build, TextColor3=CONFIG.SubText,
    TextSize=11, Font=Enum.Font.Gotham,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=21,
})

local CloseButton = Create("TextButton", {
    Name="Close", Parent=TopBar, BackgroundColor3=CONFIG.Panel2,
    Size=UDim2.fromOffset(38, 38), Position=UDim2.new(1, -50, 0.5, -19),
    Text="X", TextColor3=CONFIG.Text, TextSize=20,
    Font=Enum.Font.GothamBold, AutoButtonColor=false, ZIndex=25,
})
Corner(CloseButton, 10)
Stroke(CloseButton, CONFIG.Purple, 1, 0.5)

local Sidebar = Create("Frame", {
    Name="Sidebar", Parent=Main, BackgroundColor3=CONFIG.Panel,
    Position=UDim2.new(0, 0, 0, 64), Size=UDim2.new(0, 155, 1, -64),
    BorderSizePixel=0, ZIndex=15,
})
Corner(Sidebar, 14)

local TabList = Create("ScrollingFrame", {
    Name="Tabs", Parent=Sidebar, BackgroundTransparency=1,
    Position=UDim2.new(0, 8, 0, 10), Size=UDim2.new(1, -16, 1, -20),
    CanvasSize=UDim2.new(0, 0, 0, 0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ScrollBarThickness=2, ScrollBarImageColor3=CONFIG.Purple,
    BorderSizePixel=0, ZIndex=16,
})

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 5)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabList

local Content = Create("Frame", {
    Name="Content", Parent=Main, BackgroundTransparency=1,
    Position=UDim2.new(0, 155, 0, 64), Size=UDim2.new(1, -155, 1, -64),
    BorderSizePixel=0, ZIndex=11,
})

local Notification = Create("TextLabel", {
    Name="Notification", Parent=Gui, AnchorPoint=Vector2.new(0.5, 1),
    Position=UDim2.new(0.5, 0, 1, -20), Size=UDim2.fromOffset(340, 44),
    BackgroundColor3=CONFIG.Panel, BackgroundTransparency=0.05,
    Text="", TextColor3=CONFIG.Text, TextSize=13,
    Font=Enum.Font.GothamMedium, Visible=false, ZIndex=500,
})
Corner(Notification, 10)
Stroke(Notification, CONFIG.Purple, 1, 0.35)

local NotifyToken = 0
local function Notify(text)
    if not State.Notifications then return end
    NotifyToken += 1
    local token = NotifyToken
    Notification.Text = tostring(text)
    Notification.Visible = true
    Notification.TextTransparency = 1
    Notification.BackgroundTransparency = 1
    Tween(Notification, {TextTransparency=0, BackgroundTransparency=0.05}, 0.2)
    task.delay(2.5, function()
        if token ~= NotifyToken then return end
        Tween(Notification, {TextTransparency=1, BackgroundTransparency=1}, 0.2)
        task.wait(0.2)
        if token == NotifyToken then Notification.Visible = false end
    end)
end

local Pages = {}
local Tabs = {}

local function CreatePage(name)
    local Page = Create("ScrollingFrame", {
        Name=name, Parent=Content, BackgroundTransparency=1,
        Position=UDim2.new(0, 10, 0, 10), Size=UDim2.new(1, -20, 1, -20),
        CanvasSize=UDim2.new(0, 0, 0, 0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollBarThickness=3, ScrollBarImageColor3=CONFIG.Purple,
        BorderSizePixel=0, Visible=false, ZIndex=12,
    })
    Padding(Page, 8, 8, 8, 8)
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 9)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Page
    Pages[name] = Page
    return Page
end

local function CreateSection(parent, title, description)
    local Section = Create("Frame", {
        Parent=parent, BackgroundColor3=CONFIG.Panel,
        Size=UDim2.new(1, 0, 0, 72), BorderSizePixel=0, ZIndex=13,
    })
    Corner(Section, 10)
    Stroke(Section, CONFIG.Purple, 1, 0.85)
    Create("TextLabel", {
        Parent=Section, BackgroundTransparency=1,
        Position=UDim2.new(0, 14, 0, 10), Size=UDim2.new(1, -28, 0, 23),
        Text=title, TextColor3=CONFIG.Text, TextSize=15,
        Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14,
    })
    Create("TextLabel", {
        Parent=Section, BackgroundTransparency=1,
        Position=UDim2.new(0, 14, 0, 35), Size=UDim2.new(1, -28, 0, 25),
        Text=description or "", TextColor3=CONFIG.SubText, TextSize=11,
        Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14,
    })
    return Section
end

local function CreateButton(parent, text, callback)
    local Button = Create("TextButton", {
        Parent=parent, BackgroundColor3=CONFIG.Panel,
        Size=UDim2.new(1, 0, 0, 48), Text=text,
        TextColor3=CONFIG.Text, TextSize=13,
        Font=Enum.Font.GothamMedium, AutoButtonColor=false,
        BorderSizePixel=0, ZIndex=13,
    })
    Corner(Button, 9)
    Stroke(Button, CONFIG.Purple, 1, 0.7)
    Gradient(Button, CONFIG.Panel, CONFIG.Panel2, 45)
    Button.MouseEnter:Connect(function() Tween(Button, {BackgroundColor3=CONFIG.Panel2}, 0.15) end)
    Button.MouseLeave:Connect(function() Tween(Button, {BackgroundColor3=CONFIG.Panel}, 0.15) end)
    Button.Activated:Connect(function()
        if callback then
            local ok, err = pcall(callback)
            if not ok then warn("[Button Error]", err) Notify("Error: "..tostring(err)) end
        end
    end)
    return Button
end

local function CreateToggle(parent, text, default, callback)
    local S2 = default or false
    local Button = Create("TextButton", {
        Parent=parent, BackgroundColor3=CONFIG.Panel,
        Size=UDim2.new(1, 0, 0, 48), Text="",
        AutoButtonColor=false, BorderSizePixel=0, ZIndex=13,
    })
    Corner(Button, 9)
    Stroke(Button, CONFIG.Purple, 1, 0.7)
    Create("TextLabel", {
        Parent=Button, BackgroundTransparency=1,
        Position=UDim2.new(0, 14, 0, 0), Size=UDim2.new(1, -75, 1, 0),
        Text=text, TextColor3=CONFIG.Text, TextSize=13,
        Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=14,
    })
    local Indicator = Create("Frame", {
        Parent=Button, BackgroundColor3=Color3.fromRGB(55, 50, 65),
        Size=UDim2.fromOffset(42, 22), Position=UDim2.new(1, -56, 0.5, -11), ZIndex=14,
    })
    Corner(Indicator, 20)
    local Dot = Create("Frame", {
        Parent=Indicator, BackgroundColor3=Color3.fromRGB(190, 185, 200),
        Size=UDim2.fromOffset(16, 16), Position=UDim2.new(0, 3, 0.5, -8), ZIndex=15,
    })
    Corner(Dot, 20)
    local function Update()
        if S2 then
            Indicator.BackgroundColor3 = CONFIG.Purple
            Dot.BackgroundColor3 = Color3.new(1, 1, 1)
            Tween(Dot, {Position=UDim2.new(1, -19, 0.5, -8)}, 0.15)
        else
            Indicator.BackgroundColor3 = Color3.fromRGB(55, 50, 65)
            Dot.BackgroundColor3 = Color3.fromRGB(190, 185, 200)
            Tween(Dot, {Position=UDim2.new(0, 3, 0.5, -8)}, 0.15)
        end
    end
    Button.Activated:Connect(function()
        S2 = not S2 Update()
        if callback then
            local ok, err = pcall(callback, S2)
            if not ok then warn("[Toggle Error]", err) Notify("Error: "..tostring(err)) end
        end
    end)
    Update()
    return Button
end

local function CreateInput(parent, placeholder, callback)
    local Box = Create("TextBox", {
        Parent=parent, BackgroundColor3=CONFIG.Panel2,
        Size=UDim2.new(1, 0, 0, 40), Text="",
        PlaceholderText=placeholder or "Search...",
        PlaceholderColor3=CONFIG.SubText,
        TextColor3=CONFIG.Text, TextSize=13,
        Font=Enum.Font.GothamMedium, AutoButtonColor=false,
        BorderSizePixel=0, ZIndex=13,
        TextXAlignment=Enum.TextXAlignment.Left,
        ClearTextOnFocus=false,
    })
    Corner(Box, 9)
    Stroke(Box, CONFIG.Purple, 1, 0.7)
    Padding(Box, 12, 12, 0, 0)
    Box.Focused:Connect(function() Tween(Box, {BackgroundColor3=CONFIG.Panel3}, 0.15) end)
    Box.FocusLost:Connect(function()
        Tween(Box, {BackgroundColor3=CONFIG.Panel2}, 0.15)
        if callback then
            local ok, err = pcall(callback, Box.Text)
            if not ok then warn("[Input Error]", err) end
        end
    end)
    return Box
end

local function CreateTab(name, icon, order)
    local Button = Create("TextButton", {
        Parent=TabList, BackgroundColor3=CONFIG.Panel,
        Size=UDim2.new(1, 0, 0, 40), Text="",
        AutoButtonColor=false, BorderSizePixel=0,
        LayoutOrder=order, ZIndex=17,
    })
    Corner(Button, 8)
    local Label = Create("TextLabel", {
        Parent=Button, BackgroundTransparency=1,
        Position=UDim2.new(0, 10, 0, 0), Size=UDim2.new(1, -20, 1, 0),
        Text=name, TextColor3=CONFIG.SubText,
        TextSize=12, Font=Enum.Font.GothamMedium,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=18,
    })
    Tabs[name] = {Button=Button, Label=Label}
    return Button
end

local function ShowTab(name)
    for pageName, page in pairs(Pages) do page.Visible = pageName == name end
    for tabName, data in pairs(Tabs) do
        local active = tabName == name
        if active then
            data.Button.BackgroundColor3 = CONFIG.Purple
            data.Label.TextColor3 = Color3.new(1, 1, 1)
        else
            data.Button.BackgroundColor3 = CONFIG.Panel
            data.Label.TextColor3 = CONFIG.SubText
        end
    end
end

--// DATA ISLANDS
local Sea1Islands = {
    {Name="Starter Island", MinLevel=1, MaxLevel=9},
    {Name="Jungle", MinLevel=10, MaxLevel=14},
    {Name="Pirate Village", MinLevel=15, MaxLevel=29},
    {Name="Desert Island", MinLevel=30, MaxLevel=59},
    {Name="Frozen Village", MinLevel=60, MaxLevel=89},
    {Name="Marine Ford", MinLevel=90, MaxLevel=119},
    {Name="Skylands", MinLevel=120, MaxLevel=149},
    {Name="Colosseum", MinLevel=150, MaxLevel=179},
    {Name="Magma Village", MinLevel=180, MaxLevel=224},
    {Name="Underwater City", MinLevel=225, MaxLevel=269},
    {Name="Baratie Quest", MinLevel=270, MaxLevel=299},
    {Name="Sky Island", MinLevel=300, MaxLevel=329},
    {Name="Fountain City", MinLevel=330, MaxLevel=369},
    {Name="Volcano Island", MinLevel=370, MaxLevel=399},
}
local Sea2Islands = {
    {Name="Kingdom of Rose", MinLevel=700, MaxLevel=799},
    {Name="Green Zone", MinLevel=800, MaxLevel=899},
    {Name="Graveyard", MinLevel=900, MaxLevel=999},
    {Name="Snow Mountain", MinLevel=1000, MaxLevel=1099},
    {Name="Hot and Cold", MinLevel=1100, MaxLevel=1199},
    {Name="Cursed Ship", MinLevel=1200, MaxLevel=1299},
    {Name="Ice Castle", MinLevel=1300, MaxLevel=1399},
    {Name="Forgotten Island", MinLevel=1400, MaxLevel=1499},
}
local Sea3Islands = {
    {Name="Port Town", MinLevel=1500, MaxLevel=1574},
    {Name="Hydra Island", MinLevel=1575, MaxLevel=1699},
    {Name="Great Tree", MinLevel=1700, MaxLevel=1774},
    {Name="Floating Turtle", MinLevel=1775, MaxLevel=1974},
    {Name="Haunted Castle", MinLevel=1975, MaxLevel=2074},
    {Name="Sea of Treats", MinLevel=2075, MaxLevel=2449},
    {Name="Tiki Outpost", MinLevel=2450, MaxLevel=2800},
}
local AllIslands = {Sea1=Sea1Islands, Sea2=Sea2Islands, Sea3=Sea3Islands}

local function GetIslandByLevel(level)
    for sea, islands in pairs(AllIslands) do
        for _, island in ipairs(islands) do
            if level >= island.MinLevel and level <= island.MaxLevel then
                return island.Name, sea
            end
        end
    end
    if level > 2800 then return "Tiki Outpost", "Sea3" end
    return nil, nil
end

--// SECRET QUEST DATA
local SecretQuests = {
    Jungle = {
        {Name="Find Grappling Hook + repair Zipline", Steps={"Cari Grappling Hook", "Repair Zipline"}},
        {Name="Find Monkey tracks + knock Monkey down + return Hat", Steps={"Cari jejak Monkey", "Knock Monkey", "Return Hat"}},
        {Name="Trigger Gorilla King + knock bananas + defeat Gorilla King", Steps={"Trigger Gorilla King", "Knock bananas", "Defeat Gorilla King"}},
    },
    ["Pirate Village"] = {
        {Name="Break all Windmill ropes", Steps={"Cari windmill", "Putus semua tali"}},
        {Name="Wait Tavern enemies + defeat them + talk Bartender", Steps={"Tunggu musuh", "Kalahkan", "Talk Bartender"}},
        {Name="Help Chef + complete his task", Steps={"Bantu Chef", "Selesaikan task"}},
    },
    Desert = {
        {Name="Rescue Hasan under the Pyramid", Steps={"Masuk Pyramid", "Cari Hasan", "Rescue"}},
        {Name="Find and interact with 8 stone monuments", Steps={"Cari 8 monument", "Interact semua"}},
        {Name="Collect Cactus fruits", Steps={"Cari cactus", "Collect fruit"}},
    },
    ["Frozen Village"] = {
        {Name="Find Ability Teacher + complete his task", Steps={"Cari Teacher", "Selesaikan task"}},
        {Name="Build 3 Snowmen", Steps={"Kumpulkan bahan", "Build 3"}},
        {Name="Trigger Yeti + defeat Yeti", Steps={"Trigger Yeti", "Defeat Yeti"}},
    },
    ["Marine Fortress"] = {
        {Name="Find Rope + raise the Flag", Steps={"Cari Rope", "Naikkan Flag"}},
        {Name="Wait for Pirate Raid + defeat invading ships", Steps={"Tunggu Raid", "Defeat ships"}},
        {Name="Trigger Vice Admiral + defeat Vice Admiral", Steps={"Trigger", "Defeat"}},
    },
    ["Lower Skylands"] = {
        {Name="Find Angel Guard + retrieve the Golden Chest", Steps={"Cari Angel Guard", "Ambil Chest"}},
        {Name="Find Lightning Bolt + return to Mad Scientist", Steps={"Cari Bolt", "Return"}},
        {Name="Find the Crumpled Letter + deliver it", Steps={"Cari Letter", "Deliver"}},
    },
    Prison = {
        {Name="Stop 3 Escaped Prisoners", Steps={"Cari 3 prisoner", "Stop"}},
        {Name="Find Cell Block Key + retrieve the Coat", Steps={"Cari Key", "Ambil Coat"}},
        {Name="Activate Lever + defeat Prison Boss", Steps={"Activate Lever", "Defeat Boss"}},
    },
    Colosseum = {
        {Name="Defeat the 3 waves in the Colosseum", Steps={"Wave 1", "Wave 2", "Wave 3"}},
        {Name="Interact with Former Champions statues", Steps={"Cari statues", "Interact"}},
        {Name="Complete the Crowd Favorite 1v1", Steps={"Masuk 1v1", "Menang"}},
    },
    ["Magma Village"] = {
        {Name="Defeat the Evil Slimes", Steps={"Cari Slimes", "Defeat"}},
        {Name="Collect Magma Ore + complete extraction", Steps={"Collect Ore", "Extract"}},
        {Name="Trigger Magma General + defeat Magma General", Steps={"Trigger", "Defeat"}},
    },
    ["Underwater City"] = {
        {Name="Find Bubble Cove + help King Neptune", Steps={"Cari Cove", "Bantu Neptune"}},
        {Name="Activate Crystal Beam + help Water Kung Fu Teacher", Steps={"Activate", "Bantu Teacher"}},
        {Name="Find Black Pearl + defeat Fishman Lord", Steps={"Cari Pearl", "Defeat Lord"}},
    },
    ["Upper Skylands"] = {
        {Name="Find Temple Intel", Steps={"Cari Intel"}},
        {Name="Trigger Sky Warlord + defeat Sky Warlord", Steps={"Trigger", "Defeat"}},
        {Name="Find Yellow Bell + trigger Thunder God", Steps={"Cari Bell", "Trigger"}},
    },
    ["Fountain City"] = {
        {Name="Repair the broken Pipes", Steps={"Cari pipes", "Repair"}},
        {Name="Enter Sewer + defeat Sewer Gang", Steps={"Masuk Sewer", "Defeat Gang"}},
        {Name="Repair Cyborg's wires + defeat Cyborg", Steps={"Repair wires", "Defeat Cyborg"}},
    },
}

--// SWORD DATA
local SwordLocationData = {
    DropSwords = {
        {Name="Shark Saw", Boss="The Saw", Location="Middle Town", Sea=1},
        {Name="Warden's Sword", Boss="Chief Warden", Location="Prison", Sea=1},
        {Name="Trident", Boss="Fishman Lord", Location="Underwater City", Sea=1},
        {Name="Pole", Boss="Thunder God", Location="Upper Skylands", Sea=1},
        {Name="KOKO", Boss="Order", Location="Hot and Cold Lab", Sea=2},
        {Name="Rengoku", Boss=nil, Location="Ice Castle", Sea=2},
        {Name="Dragon Trident", Boss="Tide Keeper", Location="Forgotten Island", Sea=2},
        {Name="Twin Hooks", Boss="Captain Elephant", Location="Floating Turtle", Sea=3, LevelReq=1875},
        {Name="Buddy Sword", Boss="Cake Queen", Location="Sea of Treats", Sea=3},
        {Name="Dark Dagger", Boss="rip_indra", Location="Castle on the Sea", Sea=3},
        {Name="Hallow Scythe", Boss="Soul Reaper", Location="Haunted Castle", Sea=3},
        {Name="Shark Anchor", Boss="Anchor Terrorshark", Location="Sea Event", Sea=3},
    },
    QuestSwords = {
        {Name="Saber", Location="Jungle", Sea=1, LevelReq=200, NPC="Saber Expert"},
        {Name="Yama", Location="Hydra Island", Sea=3, NPC="Elite Hunter"},
        {Name="Tushita", Location="Floating Turtle", Sea=3, LevelReq=2000, NPC="Longma"},
        {Name="Cursed Dual Katana", Location="Floating Turtle", Sea=3, LevelReq=2200},
    }
}

--// RAID DATA
local RaidData = {
    Basic = {
        {Fruit="Flame", Chip="Basic", Price=100000},
        {Fruit="Ice", Chip="Basic", Price=100000},
        {Fruit="Sand", Chip="Basic", Price=100000},
        {Fruit="Dark", Chip="Basic", Price=100000},
        {Fruit="Light", Chip="Basic", Price=100000},
        {Fruit="Magma", Chip="Basic", Price=100000},
        {Fruit="Quake", Chip="Basic", Price=100000},
        {Fruit="Buddha", Chip="Basic", Price=100000},
        {Fruit="Spider", Chip="Basic", Price=100000},
    },
    Advanced = {
        {Fruit="Phoenix", Chip="Advanced", FragPrice=1000},
        {Fruit="Dough", Chip="Advanced", FragPrice=1000},
    },
}

local AllRaids = {}
for tier, list in pairs(RaidData) do
    for _, r in ipairs(list) do
        r.Tier = tier
        table.insert(AllRaids, r)
    end
end

--// HELPERS
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

local function FindKOKO()
    for _, obj in ipairs(workspace:GetChildren()) do
        if (obj.Name == "Koko" or string.lower(obj.Name) == "koko") and obj:FindFirstChildOfClass("Humanoid") then
            return obj
        end
    end
    return nil
end

local function FindChests()
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = string.lower(obj.Name)
            if (string.find(name, "chest") or string.find(name, "treasure") or string.find(name, "reward")) then
                if obj.Transparency < 1 and obj.Parent then
                    table.insert(list, obj)
                end
            end
        end
    end
    return list
end

local function FindMaterials()
    local list = {}
    local kws = {"material","ore","wood","stone","crystal","shard","relic"}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            for _, kw in ipairs(kws) do
                if string.find(string.lower(obj.Name), kw) then
                    table.insert(list, obj) break
                end
            end
        end
    end
    return list
end

local function FindFruits()
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "fruit") then
            table.insert(list, obj)
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

local function GetHeldChip()
    local char = Player.Character
    if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and string.find(string.lower(tool.Name), "chip") then
            return tool
        end
    end
    return nil
end

local function EquipWeapon()
    local char = Player.Character
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then return tool end
    for _, child in ipairs(Player.Backpack:GetChildren()) do
        if child:IsA("Tool") then child.Parent = char return child end
    end
    return nil
end

local function AttackNearest(maxDist)
    maxDist = maxDist or CONFIG.AttackRange
    local hrp = GetHRP()
    if not hrp then return end
    local closest, dist = nil, math.huge
    for _, enemy in ipairs(ScanEnemies()) do
        local ehrp = enemy:FindFirstChild("HumanoidRootPart")
        if ehrp then
            local d = GetDistance(ehrp.Position, hrp.Position)
            if d < dist and d <= maxDist then closest, dist = enemy, d end
        end
    end
    if closest then
        local tool = EquipWeapon()
        if tool then pcall(function() tool:Activate() end) end
    end
end

local function TeleportTo(pos)
    local hrp = GetHRP()
    if not hrp then return end
    hrp.CFrame = CFrame.new(pos)
end

--// LOOPS
task.spawn(function()
    while task.wait(CONFIG.FarmDelay) do
        if State.AutoFarm or State.AutoKillNearest then
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
                if not hrp or #chests == 0 then return end
                local nearest, dist = nil, math.huge
                for _, c in ipairs(chests) do
                    local key = tostring(c.Position)
                    if not State.OpenedChests[key] then
                        local d = GetDistance(c.Position, hrp.Position)
                        if d < dist then nearest, dist = c, d end
                    end
                end
                if nearest then
                    TeleportTo(nearest.Position + Vector3.new(0, 3, 0))
                    State.OpenedChests[tostring(nearest.Position)] = true
                    task.delay(300, function()
                        State.OpenedChests[tostring(nearest.Position)] = nil
                    end)
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if State.AutoBoss and State.CurrentBoss then
            SafeCall(function()
                local boss = FindBoss(State.CurrentBoss)
                if boss then
                    local hrp = boss:FindFirstChild("HumanoidRootPart")
                    if hrp then TeleportTo(hrp.Position + Vector3.new(0, 3, 0)) end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        if State.AutoMaterial then
            SafeCall(function()
                local mats = FindMaterials()
                local hrp = GetHRP()
                if hrp and #mats > 0 then
                    local nearest, dist = nil, math.huge
                    for _, m in ipairs(mats) do
                        local d = GetDistance(m.Position, hrp.Position)
                        if d < dist then nearest, dist = m, d end
                    end
                    if nearest and dist < 300 then
                        TeleportTo(nearest.Position + Vector3.new(0, 3, 0))
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if State.AutoFruit or State.FruitSniper then
            SafeCall(function()
                for _, f in ipairs(FindFruits()) do
                    local hrp = GetHRP()
                    if hrp and GetDistance(f.Position, hrp.Position) < 500 then
                        TeleportTo(f.Position + Vector3.new(0, 3, 0))
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(2.5) do
        if State.AutoFishing or State.AutoCatch then
            SafeCall(function()
                local char = Player.Character
                if not char then return end
                local tool = char:FindFirstChildOfClass("Tool")
                if tool and string.find(string.lower(tool.Name), "rod") then
                    tool:Activate()
                end
            end)
        end
    end
end)

local leaderstats = Player:FindFirstChild("leaderstats")
local LevelValue = leaderstats and leaderstats:FindFirstChild("Level")

local function OnLevelChanged(newLevel)
    if newLevel > CONFIG.MaxLevel then newLevel = CONFIG.MaxLevel end
    local target, sea = GetIslandByLevel(newLevel)
    if target and target ~= State.CurrentIsland then
        State.CurrentIsland = target
        Notify("Auto Island: " .. target .. " (" .. tostring(sea) .. ")")
    end
end

if LevelValue then
    LevelValue.Changed:Connect(OnLevelChanged)
    OnLevelChanged(LevelValue.Value)
end

local function FarmSwordDrop(swordName)
    for _, s in ipairs(SwordLocationData.DropSwords) do
        if s.Name == swordName then
            if s.Boss then
                local target = FindBoss(s.Boss)
                if not target then Notify("Boss tidak ada: "..s.Boss) return false end
                State.CurrentBoss = s.Boss
                State.AutoBoss = true
                Notify("Farming "..swordName)
            end
            return true
        end
    end
    Notify("Sword tidak ada")
    return false
end

local function FarmKOKO()
    local koko = FindKOKO()
    if not koko then Notify("KOKO tidak ditemukan") return false end
    local hrp = koko:FindFirstChild("HumanoidRootPart")
    if hrp then
        TeleportTo(hrp.Position + Vector3.new(0, 3, 0))
        Notify("Interaksi KOKO")
        return true
    end
    return false
end

--// GACHA ZIOLES (Random Fruit)
local function RandomFruitDirect()
    local now = os.time()
    if now - State.LastRandomFruit < CONFIG.RandomFruitCooldown then
        local rem = CONFIG.RandomFruitCooldown - (now - State.LastRandomFruit)
        Notify(string.format("Cooldown: %dh %dm", math.floor(rem/3600), math.floor((rem%3600)/60)))
        return false
    end
    if GetHeldFruit() then
        Notify("Masih pegang fruit")
        return false
    end
    if not REMOTE_RandomFruit then
        Notify("Remote RandomFruit tidak ada")
        return false
    end
    local ok = pcall(function()
        if REMOTE_RandomFruit:IsA("RemoteEvent") then
            REMOTE_RandomFruit:FireServer()
        else
            REMOTE_RandomFruit:InvokeServer()
        end
    end)
    if ok then
        State.LastRandomFruit = now
        Notify("Gacha Fruit dibuka")
        task.wait(1.5)
        if State.StoreFruit then SafeCall(StoreFruit) end
        return true
    end
    Notify("Gagal fire RandomFruit")
    return false
end

function StoreFruit()
    local held = GetHeldFruit()
    if not held then Notify("Tidak ada fruit di tangan") return false end
    local fruitName = held.Name
    if REMOTE_StoreFruit then
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
    Notify("Store Fruit: "..fruitName)
    return true
end

--// BUY CHIP
local function BuyChipDirect()
    if GetHeldChip() then
        Notify("Masih pegang chip")
        return false
    end
    if not REMOTE_BuyChip then
        Notify("Remote BuyChip tidak ada")
        return false
    end
    local ok = pcall(function()
        if REMOTE_BuyChip:IsA("RemoteEvent") then
            REMOTE_BuyChip:FireServer()
        else
            REMOTE_BuyChip:InvokeServer()
        end
    end)
    if ok then
        State.LastBuyChip = os.time()
        Notify("BuyChip fired")
        task.wait(1)
        if State.StoreChip then
            local held = GetHeldChip()
            if held then pcall(function() held.Parent = Player.Backpack end) end
        end
        return true
    end
    return false
end

task.spawn(function()
    while task.wait(60) do
        if State.RandomFruit then SafeCall(RandomFruitDirect) end
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        if State.StoreFruit then
            SafeCall(function()
                if GetHeldFruit() then StoreFruit() end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(15) do
        if State.AutoBuyChip then SafeCall(BuyChipDirect) end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if State.AutoKOKO then SafeCall(FarmKOKO) end
    end
end)

--// KILL AURA
local function IsInRaidArea()
    if not LevelValue or LevelValue.Value < CONFIG.RaidMinLevel then
        return false
    end
    local hrp = GetHRP()
    if not hrp then return false end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Folder") or obj:IsA("Model") then
            local name = string.lower(obj.Name)
            if string.find(name, "raid") or string.find(name, "room") or string.find(name, "pass") then
                if obj:IsA("BasePart") then
                    if GetDistance(obj.Position, hrp.Position) <= 500 then return true end
                elseif obj:IsA("Model") and obj.PrimaryPart then
                    if GetDistance(obj.PrimaryPart.Position, hrp.Position) <= 500 then return true end
                end
            end
        end
    end
    return false
end

task.spawn(function()
    while task.wait(0.1) do
        if State.KillAura then
            if not IsInRaidArea() then
                State.KillAura = false
                Notify("Kill Aura OFF - bukan area raid")
            else
                local now = os.clock()
                if now - State.LastKillAura >= 0.35 then
                    local hrp = GetHRP()
                    if hrp then
                        local found = false
                        for _, obj in ipairs(workspace:GetChildren()) do
                            if IsNPC(obj) or IsEnemyPlayer(obj) then
                                local targetHRP = obj:FindFirstChild("HumanoidRootPart")
                                if targetHRP and GetDistance(targetHRP.Position, hrp.Position) <= 25 then
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
    end
end)

--// HITBOX
task.spawn(function()
    while task.wait(0.05) do
        if State.Hitbox then
            local hrp = GetHRP()
            if hrp then
                if not State.HitboxPart or not State.HitboxPart.Parent then
                    local hb = Instance.new("Part")
                    hb.Name = "SysxHitbox"
                    hb.Size = Vector3.new(10, 10, 10)
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
            if State.HitboxPart then
                State.HitboxPart:Destroy()
                State.HitboxPart = nil
            end
        end
    end
end)

--// BRING MOB
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
                            local mobRoot = model:FindFirstChild("HumanoidRootPart")
                            if mobRoot and GetDistance(mobRoot.Position, hrp.Position) <= 100 then
                                pcall(function() mobRoot.CFrame = CFrame.new(targetPos) end)
                            end
                        end
                    end
                end
                State.LastBring = now
            end
        end
    end
end)

--// PAGES
local DiscordPage = CreatePage("Discord")
local FarmPage = CreatePage("Farm")
local QuestItemsPage = CreatePage("Quest / Items")
local FruitRaidPage = CreatePage("Fruit / Raid")
local FishingPage = CreatePage("Fishing")
local StatusPage = CreatePage("Status")
local PvPPage = CreatePage("PvP")
local StatsPage = CreatePage("Stats")
local MiscPage = CreatePage("Misc")

--// DISCORD
CreateSection(DiscordPage, "DISCORD INFO", "Join community")
local DiscordLabel = Create("TextLabel", {
    Parent=DiscordPage, BackgroundColor3=CONFIG.Panel,
    Size=UDim2.new(1, 0, 0, 80),
    Text="Discord Server:\n"..CONFIG.Discord,
    TextColor3=CONFIG.Text, TextSize=13, Font=Enum.Font.GothamMedium,
    TextXAlignment=Enum.TextXAlignment.Left, BorderSizePixel=0, ZIndex=13,
})
Corner(DiscordLabel, 9)
Padding(DiscordLabel, 14, 14, 7, 7)

CreateButton(DiscordPage, "Copy Discord Link", function()
    if setclipboard then
        setclipboard(CONFIG.Discord)
        Notify("Discord link copied")
    else
        Notify("Clipboard tidak tersedia")
    end
end)

--// FARM
CreateSection(FarmPage, "FARM", "Auto farm level")
CreateToggle(FarmPage, "Auto Farm Level", false, function(s) State.AutoFarm=s Notify("Auto Farm Level: "..(s and "ON" or "OFF")) end)
CreateToggle(FarmPage, "Auto Quest", false, function(s) State.AutoQuest=s Notify("Auto Quest: "..(s and "ON" or "OFF")) end)
CreateToggle(FarmPage, "Auto Kill Nearest", false, function(s) State.AutoKillNearest=s Notify("Auto Kill Nearest: "..(s and "ON" or "OFF")) end)

CreateSection(FarmPage, "BOSS", "Auto farm boss")
CreateButton(FarmPage, "Select Boss", function()
    for _, b in ipairs({"The Saw","Chief Warden","Fishman Lord","Thunder God","Order","Tide Keeper","Captain Elephant","Cake Queen","rip_indra","Soul Reaper","Anchor Terrorshark","Dough King","Longma","Elite Pirate","Kitsune"}) do
        print("[Boss]", b)
    end
    Notify("Boss list di console")
end)
CreateToggle(FarmPage, "Auto Farm Boss", false, function(s) State.AutoBoss=s Notify("Auto Farm Boss: "..(s and "ON" or "OFF")) end)

CreateSection(FarmPage, "MATERIAL", "Auto farm material")
CreateButton(FarmPage, "Select Material", function()
    for _, m in ipairs({"Leather","Cloth","Scrap Metal","Angel Wings","Magma Ore","Fish Tail","Mystic Droplet","Magic Ivy","Radioactive Material","Vampire Fang","Snow Crystal","Cursed Fragment","Dragon Scale","Sea King Hide","Terror Jaw","Void Essence"}) do
        print("[Material]", m)
    end
    Notify("Material list di console")
end)
CreateToggle(FarmPage, "Auto Farm Material", false, function(s) State.AutoMaterial=s Notify("Auto Farm Material: "..(s and "ON" or "OFF")) end)

CreateSection(FarmPage, "CHEST", "Auto farm chest")
CreateToggle(FarmPage, "Farm Chest", false, function(s) State.AutoChest=s Notify("Farm Chest: "..(s and "ON" or "OFF")) end)
CreateButton(FarmPage, "Teleport Chest Terdekat", function()
    local chests = FindChests()
    local hrp = GetHRP()
    if not hrp or #chests == 0 then Notify("Tidak ada chest") return end
    local nearest, dist = nil, math.huge
    for _, c in ipairs(chests) do
        local d = GetDistance(c.Position, hrp.Position)
        if d < dist then nearest, dist = c, d end
    end
    if nearest then
        TeleportTo(nearest.Position + Vector3.new(0, 3, 0))
        Notify("Teleport: "..nearest.Name)
    end
end)

--// QUEST / ITEMS
CreateSection(QuestItemsPage, "QUEST / ITEMS", "Auto farm item langka")
CreateToggle(QuestItemsPage, "Auto CDK", false, function(s) State.AutoCDK=s Notify("Auto CDK: "..(s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Dark Dagger", false, function(s) State.AutoDarkDagger=s Notify("Auto Dark Dagger: "..(s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Soul Guitar", false, function(s) State.AutoSoulGuitar=s Notify("Auto Soul Guitar: "..(s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Yama", false, function(s) State.AutoYama=s Notify("Auto Yama: "..(s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Tushita", false, function(s) State.AutoTushita=s Notify("Auto Tushita: "..(s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Buddy Sword", false, function(s) State.AutoBuddySword=s Notify("Auto Buddy Sword: "..(s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Kill Indra", false, function(s) State.AutoKillIndra=s Notify("Auto Kill Indra: "..(s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Spawn Dough King", false, function(s) State.AutoSpawnDoughKing=s Notify("Auto Spawn Dough King: "..(s and "ON" or "OFF")) end)

CreateSection(QuestItemsPage, "SECRET QUEST", "Cari quest")
CreateInput(QuestItemsPage, "Search quest...", function(text)
    if not text or text == "" then return end
    local found = {}
    for loc, quests in pairs(SecretQuests) do
        for _, q in ipairs(quests) do
            if string.find(string.lower(q.Name), string.lower(text)) then
                table.insert(found, loc.." - "..q.Name)
            end
        end
    end
    if #found > 0 then
        Notify("Found "..#found.." quest")
        for _, f in ipairs(found) do print("[Search]", f) end
    else
        Notify("Tidak ada hasil")
    end
end)

--// FRUIT / RAID
CreateSection(FruitRaidPage, "FRUIT", "Auto collect fruit")
CreateToggle(FruitRaidPage, "Auto Collect Fruit", false, function(s) State.AutoFruit=s Notify("Auto Collect Fruit: "..(s and "ON" or "OFF")) end)
CreateToggle(FruitRaidPage, "Fruit Sniper", false, function(s) State.FruitSniper=s Notify("Fruit Sniper: "..(s and "ON" or "OFF")) end)

CreateSection(FruitRaidPage, "GACHA ZIOLES", "Buka Gacha Box Zioles")
CreateButton(FruitRaidPage, "Gacha Fruit", function() RandomFruitDirect() end)
CreateToggle(FruitRaidPage, "Auto Gacha", false, function(s) State.RandomFruit=s Notify("Auto Gacha: "..(s and "ON" or "OFF")) end)
CreateToggle(FruitRaidPage, "Store Fruit", false, function(s) State.StoreFruit=s Notify("Store Fruit: "..(s and "ON" or "OFF")) end)
CreateButton(FruitRaidPage, "Store Fruit Sekarang", function() StoreFruit() end)

CreateSection(FruitRaidPage, "BUY RAID CHIP", "Mysterious Scientist")
CreateButton(FruitRaidPage, "Buy Raid Chip", function() BuyChipDirect() end)
CreateToggle(FruitRaidPage, "Auto Buy Chip", false, function(s) State.AutoBuyChip=s Notify("Auto Buy Chip: "..(s and "ON" or "OFF")) end)

CreateSection(FruitRaidPage, "RAID", "Auto raid")
CreateToggle(FruitRaidPage, "Auto Raid", false, function(s) State.AutoRaid=s Notify("Auto Raid: "..(s and "ON" or "OFF")) end)

--// FISHING
CreateSection(FishingPage, "FISHING", "Auto fishing")
CreateToggle(FishingPage, "Auto Fishing", false, function(s) State.AutoFishing=s Notify("Auto Fishing: "..(s and "ON" or "OFF")) end)
CreateToggle(FishingPage, "Auto Catch", false, function(s) State.AutoCatch=s Notify("Auto Catch: "..(s and "ON" or "OFF")) end)

--// STATUS
CreateSection(StatusPage, "STATUS", "Info player")
local StatusLabel = Create("TextLabel", {
    Parent=StatusPage, BackgroundColor3=CONFIG.Panel,
    Size=UDim2.new(1, 0, 0, 100),
    Text="Level: -\nIsland: -\nSea: -\nSword: -\nRaid: -",
    TextColor3=CONFIG.Text, TextSize=13, Font=Enum.Font.GothamMedium,
    TextXAlignment=Enum.TextXAlignment.Left, BorderSizePixel=0, ZIndex=13,
})
Corner(StatusLabel, 9)
Padding(StatusLabel, 14, 14, 7, 7)

task.spawn(function()
    while task.wait(1) do
        if LevelValue then
            local lv = LevelValue.Value
            local island, sea = GetIslandByLevel(lv)
            StatusLabel.Text = string.format(
                "Level: %d\nIsland: %s\nSea: %s\nSword: %s\nRaid: %s",
                lv, island or "-", tostring(sea) or "-",
                State.SelectedSword or "-", State.CurrentRaid or "-"
            )
        end
    end
end)

--// PVP
CreateSection(PvPPage, "PVP", "PVP Control")
CreateToggle(PvPPage, "PvP Mode", false, function(s) State.PvPMode=s Notify("PvP Mode: "..(s and "ON" or "OFF")) end)
CreateToggle(PvPPage, "ESP Players", false, function(s) State.ESPPlayers=s Notify("ESP Players: "..(s and "ON" or "OFF")) end)
CreateToggle(PvPPage, "Aimbot", false, function(s) State.Aimbot=s Notify("Aimbot: "..(s and "ON" or "OFF")) end)
CreateToggle(PvPPage, "Kill Aura (Raid Only)", false, function(s)
    if s and not IsInRaidArea() then Notify("Harus di Raid Area (Sea 3)") return end
    State.KillAura = s
    Notify("Kill Aura: "..(s and "ON" or "OFF"))
end)
CreateToggle(PvPPage, "Hitbox", false, function(s) State.Hitbox=s Notify("Hitbox: "..(s and "ON" or "OFF")) end)
CreateToggle(PvPPage, "Bring Mob", false, function(s) State.BringMob=s Notify("Bring Mob: "..(s and "ON" or "OFF")) end)

local CurrentTargetLabel = Create("TextLabel", {
    Parent=PvPPage, BackgroundColor3=CONFIG.Panel,
    Size=UDim2.new(1, 0, 0, 40),
    Text="Current Target: -",
    TextColor3=CONFIG.Text, TextSize=13, Font=Enum.Font.GothamMedium,
    TextXAlignment=Enum.TextXAlignment.Left, BorderSizePixel=0, ZIndex=13,
})
Corner(CurrentTargetLabel, 9)
Padding(CurrentTargetLabel, 14, 14, 7, 7)

task.spawn(function()
    while task.wait(1) do
        local hrp = GetHRP()
        local nearest, dist = nil, math.huge
        if hrp then
            for _, obj in ipairs(workspace:GetChildren()) do
                if IsNPC(obj) or IsEnemyPlayer(obj) then
                    local targetHRP = obj:FindFirstChild("HumanoidRootPart")
                    if targetHRP then
                        local d = GetDistance(targetHRP.Position, hrp.Position)
                        if d < dist then nearest, dist = obj, d end
                    end
                end
            end
        end
        CurrentTargetLabel.Text = "Current Target: "..(nearest and (nearest.Name.." ("..math.floor(dist)..")") or "-")
    end
end)

--// STATS
CreateSection(StatsPage, "STATS", "Player stats")
local StatsInfoLabel = Create("TextLabel", {
    Parent=StatsPage, BackgroundColor3=CONFIG.Panel,
    Size=UDim2.new(1, 0, 0, 80),
    Text="Melee: -\nDefense: -\nSword: -\nGun: -",
    TextColor3=CONFIG.Text, TextSize=13, Font=Enum.Font.GothamMedium,
    TextXAlignment=Enum.TextXAlignment.Left, BorderSizePixel=0, ZIndex=13,
})
Corner(StatsInfoLabel, 9)
Padding(StatsInfoLabel, 14, 14, 7, 7)

task.spawn(function()
    while task.wait(2) do
        local stats = Player:FindFirstChild("leaderstats")
        if stats then
            StatsInfoLabel.Text = string.format(
                "Melee: %s\nDefense: %s\nSword: %s\nGun: %s",
                stats:FindFirstChild("Melee") and stats.Melee.Value or "-",
                stats:FindFirstChild("Defense") and stats.Defense.Value or "-",
                stats:FindFirstChild("Sword") and stats.Sword.Value or "-",
                stats:FindFirstChild("Gun") and stats.Gun.Value or "-"
            )
        end
    end
end)

--// MISC
CreateSection(MiscPage, "MISC", "Additional settings")
CreateToggle(MiscPage, "Anti AFK", true, function(s) State.AntiAFK=s Notify("Anti AFK: "..(s and "ON" or "OFF")) end)
CreateButton(MiscPage, "Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId, Player)
end)

--// TABS
local TabDefinitions = {
    {"Discord"},
    {"Farm"},
    {"Quest / Items"},
    {"Fruit / Raid"},
    {"Fishing"},
    {"Status"},
    {"PvP"},
    {"Stats"},
    {"Misc"},
}

for index, data in ipairs(TabDefinitions) do
    local button = CreateTab(data[1], "", index)
    button.Activated:Connect(function() ShowTab(data[1]) end)
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

local openDragging, openDragStart, openStartPos = false, nil, nil
OpenButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        openDragging = true openDragStart = input.Position openStartPos = OpenButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then openDragging = false end
        end)
    end
end)
UIS.InputChanged:Connect(function(input)
    if not openDragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - openDragStart
    OpenButton.Position = UDim2.new(openStartPos.X.Scale, openStartPos.X.Offset + delta.X, openStartPos.Y.Scale, openStartPos.Y.Offset + delta.Y)
end)

Player.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

ShowTab("Discord")

print("================================")
print("        SYSX HUB LOADED v1.3")
print("        " .. CONFIG.Build)
print("================================")

Notify("SysxHub " .. CONFIG.Build .. " loaded")
return true
