--[[
================================================================
 SYSX HUB - v1.0.2 | Created by Ramanotsugarr
 Single File
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
    Version = "v1.0.2",
    Build = "SysxHub v1.0.2 | Created by Ramanotsugarr",
    Logo = "rbxassetid://136425814447688",
    OpenClose = "rbxassetid://70792832229220",
    Discord = "https://discord.gg/E5kQJW3hn",
    Background = Color3.fromRGB(10, 8, 18),
    Panel = Color3.fromRGB(17, 13, 29),
    Panel2 = Color3.fromRGB(23, 18, 38),
    Panel3 = Color3.fromRGB(30, 24, 48),
    Purple = Color3.fromRGB(125, 70, 255),
    Blue = Color3.fromRGB(80, 140, 255),
    White = Color3.fromRGB(255, 255, 255),
    Radius = 10,
    MaxLevel = 2800,
    AttackRange = 25,
    FarmDelay = 0.1,
    RandomFruitCooldown = 7200,
    RaidMinLevel = 1500,
    ChestDelay = 0.5,
    ChestWaitCooldown = 5,
    KillAuraRange = 25,
    KillAuraCooldown = 0.35,
}

local State = {
    AutoFarm = false, AutoChest = false, AutoBoss = false,
    AutoMaterial = false, AutoFruit = false, AutoKillNearest = false,
    SelectedWeapon = nil, SelectedCategory = nil,
    SelectedBoss = nil, SelectedBossSea = nil,
    SelectedSeaMob = nil, AutoFarmSea = false, AutoKillSeaBeast = false,
    AutoDrive = false, DeleteRocks = false,
    HeightBoat = 0, SpeedBoat = 0, LockMoon = false, AzureEmberCount = 0,
    AutoKillGolem = false, AutoCollectBone = false, AutoTrade = false,
    AutoCDK = false, AutoDarkDagger = false, AutoSoulGuitar = false,
    AutoYama = false, AutoTushita = false, AutoBuddySword = false,
    AutoKillIndra = false, AutoSpawnDoughKing = false,
    SelectedSecretLocation = nil, SelectedSecretQuest = nil,
    AutoRaid = false, AutoBuyChip = false,
    RandomFruit = false, StoreFruit = false, LastRandomFruit = 0,
    SelectedRaid = nil,
    AutoFishing = false, AutoCatch = false,
    KillAura = false, LastKillAura = 0, Hitbox = false,
    HitboxPart = nil, Aimbot = false,
    SelectedPlayer = nil, SpectateTarget = nil, Spectating = false,
    AutoAddStats = false,
    StatsMelee = 0, StatsDefense = 0, StatsSword = 0, StatsGun = 0, StatsBloxFruit = 0,
    AntiAFK = true, BringMob = false, LastBring = 0, BringMobRange = 50,
    InfiniteJump = false, BoostFPS = false, OriginalLighting = nil,
    JobIDInput = "", CodeInput = "",
    Notifications = true, CurrentIsland = nil,
    OpenedChests = {}, SearchInput = "",
}

local old = PlayerGui:FindFirstChild("SysxHub")
if old then old:Destroy() end

--// HELPERS
local function Create(cls, props)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do pcall(function() o[k] = v end) end
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

local function IsAlive(m)
    local h = m and m:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function IsNPC(m)
    if not m or m == Player.Character then return false end
    if not m:FindFirstChildOfClass("Humanoid") then return false end
    if not m:FindFirstChild("HumanoidRootPart") then return false end
    if Players:GetPlayerFromCharacter(m) then return false end
    return IsAlive(m)
end

local function IsEnemyPlayer(m)
    if not m or m == Player.Character then return false end
    local plr = Players:GetPlayerFromCharacter(m)
    if not plr then return false end
    if plr:IsFriendsWith(Player.UserId) then return false end
    return IsAlive(m)
end

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

local REMOTE_RandomFruit = FindRemote("randomfruit", "gacha", "zioles", "rollfruit")
local REMOTE_BuyChip = FindRemote("buychip", "purchasechip", "raidchip", "microchip")
local REMOTE_StoreFruit = FindRemote("storefruit", "fruitstore", "savefruit")
local REMOTE_Redeem = FindRemote("redeem", "promocode", "code")

--// GUI
local Gui = Create("ScreenGui", {
    Name = "SysxHub", Parent = PlayerGui, ResetOnSpawn = false,
    IgnoreGuiInset = true, DisplayOrder = 999999,
    ZIndexBehavior = Enum.ZIndexBehavior.Global,
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
    Name = "OpenButton", Parent = Gui, BackgroundColor3 = CONFIG.Panel,
    Size = UDim2.fromOffset(64, 64),
    Position = UDim2.new(0, 18, 0.5, -32), Image = CONFIG.OpenClose,
    AutoButtonColor = false, Visible = true, ZIndex = 100,
})
Corner(OpenButton, 16)
Stroke(OpenButton, CONFIG.Purple, 2, 0.15)
Gradient(OpenButton, CONFIG.Purple, CONFIG.Blue, 45)

Create("TextLabel", {
    Name = "Fallback", Parent = OpenButton, BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1), Text = "S", TextColor3 = CONFIG.White,
    TextSize = 24, Font = Enum.Font.GothamBold, ZIndex = 101,
})

local Main = Create("Frame", {
    Name = "Main", Parent = Gui, AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0, 760, 0, 480),
    BackgroundColor3 = CONFIG.Background, BorderSizePixel = 0,
    Visible = true, ZIndex = 10,
})
Corner(Main, 14)
Stroke(Main, CONFIG.Purple, 1, 0.45)

local MC = Instance.new("UISizeConstraint")
MC.MaxSize = Vector2.new(850, 560)
MC.MinSize = Vector2.new(310, 360)
MC.Parent = Main

local TopBar = Create("Frame", {
    Name = "TopBar", Parent = Main, BackgroundColor3 = CONFIG.Panel,
    Size = UDim2.new(1, 0, 0, 64), BorderSizePixel = 0, ZIndex = 20,
})
Corner(TopBar, 14)
Gradient(TopBar, CONFIG.Panel, CONFIG.Panel2, 0)

Create("ImageLabel", {
    Name = "Logo", Parent = TopBar, BackgroundTransparency = 1,
    Size = UDim2.fromOffset(48, 48), Position = UDim2.new(0, 10, 0.5, -24),
    Image = CONFIG.Logo, ScaleType = Enum.ScaleType.Fit, ZIndex = 21,
})

Create("TextLabel", {
    Name = "Title", Parent = TopBar, BackgroundTransparency = 1,
    Position = UDim2.new(0, 66, 0, 8), Size = UDim2.new(0, 250, 0, 25),
    Text = "SysxHub", TextColor3 = CONFIG.White, TextSize = 20,
    Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 21,
})

Create("TextLabel", {
    Name = "Subtitle", Parent = TopBar, BackgroundTransparency = 1,
    Position = UDim2.new(0, 67, 0, 33), Size = UDim2.new(0, 400, 0, 18),
    Text = CONFIG.Build, TextColor3 = CONFIG.White,
    TextSize = 11, Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 21,
})

local CloseButton = Create("TextButton", {
    Name = "Close", Parent = TopBar, BackgroundColor3 = CONFIG.Panel2,
    Size = UDim2.fromOffset(38, 38), Position = UDim2.new(1, -50, 0.5, -19),
    Text = "X", TextColor3 = CONFIG.White, TextSize = 20,
    Font = Enum.Font.GothamBold, AutoButtonColor = false, ZIndex = 25,
})
Corner(CloseButton, 10)
Stroke(CloseButton, CONFIG.Purple, 1, 0.5)

local Sidebar = Create("Frame", {
    Name = "Sidebar", Parent = Main, BackgroundColor3 = CONFIG.Panel,
    Position = UDim2.new(0, 0, 0, 64), Size = UDim2.new(0, 155, 1, -64),
    BorderSizePixel = 0, ZIndex = 15,
})
Corner(Sidebar, 14)

local TabList = Create("ScrollingFrame", {
    Name = "Tabs", Parent = Sidebar, BackgroundTransparency = 1,
    Position = UDim2.new(0, 8, 0, 10), Size = UDim2.new(1, -16, 1, -20),
    CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 2, ScrollBarImageColor3 = CONFIG.Purple,
    BorderSizePixel = 0, ZIndex = 16,
})

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 5)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabList

local Content = Create("Frame", {
    Name = "Content", Parent = Main, BackgroundTransparency = 1,
    Position = UDim2.new(0, 155, 0, 64), Size = UDim2.new(1, -155, 1, -64),
    BorderSizePixel = 0, ZIndex = 11,
})

local Notification = Create("TextLabel", {
    Name = "Notification", Parent = Gui, AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -20), Size = UDim2.fromOffset(340, 44),
    BackgroundColor3 = CONFIG.Panel, BackgroundTransparency = 0.05,
    Text = "", TextColor3 = CONFIG.White, TextSize = 13,
    Font = Enum.Font.GothamMedium, Visible = false, ZIndex = 500,
})
Corner(Notification, 10)
Stroke(Notification, CONFIG.Purple, 1, 0.35)

local NotifyToken = 0
local function Notify(text)
    if not State.Notifications then return end
    NotifyToken += 1
    local tk = NotifyToken
    Notification.Text = tostring(text)
    Notification.Visible = true
    Notification.TextTransparency = 1
    Notification.BackgroundTransparency = 1
    Tween(Notification, {TextTransparency = 0, BackgroundTransparency = 0.05}, 0.2)
    task.delay(2.5, function()
        if tk ~= NotifyToken then return end
        Tween(Notification, {TextTransparency = 1, BackgroundTransparency = 1}, 0.2)
        task.wait(0.2)
        if tk == NotifyToken then Notification.Visible = false end
    end)
end

local Pages, Tabs = {}, {}

local function CreatePage(name)
    local P = Create("ScrollingFrame", {
        Name = name, Parent = Content, BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 10), Size = UDim2.new(1, -20, 1, -20),
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3, ScrollBarImageColor3 = CONFIG.Purple,
        BorderSizePixel = 0, Visible = false, ZIndex = 12,
    })
    Padding(P, 8, 8, 8, 8)
    local L = Instance.new("UIListLayout")
    L.Padding = UDim.new(0, 9)
    L.SortOrder = Enum.SortOrder.LayoutOrder
    L.Parent = P
    Pages[name] = P
    return P
end

local function CreateSection(parent, title, desc)
    local S = Create("Frame", {
        Parent = parent, BackgroundColor3 = CONFIG.Panel,
        Size = UDim2.new(1, 0, 0, 72), BorderSizePixel = 0, ZIndex = 13,
    })
    Corner(S, 10)
    Stroke(S, CONFIG.Purple, 1, 0.85)
    Create("TextLabel", {
        Parent = S, BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 10), Size = UDim2.new(1, -28, 0, 23),
        Text = title, TextColor3 = CONFIG.White, TextSize = 15,
        Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
    })
    Create("TextLabel", {
        Parent = S, BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 35), Size = UDim2.new(1, -28, 0, 25),
        Text = desc or "", TextColor3 = CONFIG.White, TextSize = 11,
        Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
    })
    return S
end

local function CreateButton(parent, text, cb)
    local B = Create("TextButton", {
        Parent = parent, BackgroundColor3 = CONFIG.Panel,
        Size = UDim2.new(1, 0, 0, 48), Text = text,
        TextColor3 = CONFIG.White, TextSize = 13,
        Font = Enum.Font.GothamMedium, AutoButtonColor = false,
        BorderSizePixel = 0, ZIndex = 13,
    })
    Corner(B, 9)
    Stroke(B, CONFIG.Purple, 1, 0.7)
    Gradient(B, CONFIG.Panel, CONFIG.Panel2, 45)
    B.MouseEnter:Connect(function() Tween(B, {BackgroundColor3 = CONFIG.Panel2}, 0.15) end)
    B.MouseLeave:Connect(function() Tween(B, {BackgroundColor3 = CONFIG.Panel}, 0.15) end)
    B.Activated:Connect(function()
        if cb then
            local ok, err = pcall(cb)
            if not ok then warn("[Btn]", err) Notify("Error: " .. tostring(err)) end
        end
    end)
    return B
end

local function CreateToggle(parent, text, default, cb)
    local S2 = default or false
    local B = Create("TextButton", {
        Parent = parent, BackgroundColor3 = CONFIG.Panel,
        Size = UDim2.new(1, 0, 0, 48), Text = "",
        AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 13,
    })
    Corner(B, 9)
    Stroke(B, CONFIG.Purple, 1, 0.7)
    Create("TextLabel", {
        Parent = B, BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -75, 1, 0),
        Text = text, TextColor3 = CONFIG.White, TextSize = 13,
        Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
    })
    local Indicator = Create("Frame", {
        Parent = B, BackgroundColor3 = Color3.fromRGB(55, 50, 65),
        Size = UDim2.fromOffset(42, 22), Position = UDim2.new(1, -56, 0.5, -11), ZIndex = 14,
    })
    Corner(Indicator, 20)
    local Dot = Create("Frame", {
        Parent = Indicator, BackgroundColor3 = Color3.fromRGB(190, 185, 200),
        Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 3, 0.5, -8), ZIndex = 15,
    })
    Corner(Dot, 20)
    local function Update()
        if S2 then
            Indicator.BackgroundColor3 = CONFIG.Purple
            Dot.BackgroundColor3 = Color3.new(1, 1, 1)
            Tween(Dot, {Position = UDim2.new(1, -19, 0.5, -8)}, 0.15)
        else
            Indicator.BackgroundColor3 = Color3.fromRGB(55, 50, 65)
            Dot.BackgroundColor3 = Color3.fromRGB(190, 185, 200)
            Tween(Dot, {Position = UDim2.new(0, 3, 0.5, -8)}, 0.15)
        end
    end
    B.Activated:Connect(function()
        S2 = not S2
        Update()
        if cb then
            local ok, err = pcall(cb, S2)
            if not ok then warn("[Tg]", err) Notify("Error: " .. tostring(err)) end
        end
    end)
    Update()
    return B
end

local function CreateInput(parent, placeholder, cb)
    local Box = Create("TextBox", {
        Parent = parent, BackgroundColor3 = CONFIG.Panel2,
        Size = UDim2.new(1, 0, 0, 40), Text = "",
        PlaceholderText = placeholder or "Search...",
        PlaceholderColor3 = CONFIG.White,
        TextColor3 = CONFIG.White, TextSize = 13,
        Font = Enum.Font.GothamMedium, AutoButtonColor = false,
        BorderSizePixel = 0, ZIndex = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    })
    Corner(Box, 9)
    Stroke(Box, CONFIG.Purple, 1, 0.7)
    Padding(Box, 12, 12, 0, 0)
    Box:GetPropertyChangedSignal("Text"):Connect(function()
        if cb then pcall(cb, Box.Text) end
    end)
    return Box
end

local function CreateDropdown(parent, title, options, cb)
    local Holder = Create("Frame", {
        Parent = parent, BackgroundColor3 = CONFIG.Panel,
        Size = UDim2.new(1, 0, 0, 48), BorderSizePixel = 0,
        ZIndex = 13, ClipsDescendants = false,
    })
    Corner(Holder, 9)
    Stroke(Holder, CONFIG.Purple, 1, 0.7)

    local Selected = options[1] or "Select"
    local IsOpen = false

    local TitleLbl = Create("TextLabel", {
        Parent = Holder, BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -100, 1, 0),
        Text = title .. ": " .. Selected,
        TextColor3 = CONFIG.White, TextSize = 13,
        Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
    })

    local Arrow = Create("TextLabel", {
        Parent = Holder, BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0, 0), Size = UDim2.new(0, 20, 1, 0),
        Text = "v", TextColor3 = CONFIG.White, TextSize = 12,
        Font = Enum.Font.GothamBold, ZIndex = 14,
    })

    local ListHolder = Create("ScrollingFrame", {
        Parent = Holder, BackgroundColor3 = CONFIG.Panel2,
        Position = UDim2.new(0, 0, 1, 4), Size = UDim2.new(1, 0, 0, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3, ScrollBarImageColor3 = CONFIG.Purple,
        BorderSizePixel = 0, ZIndex = 200, Visible = false,
    })
    Corner(ListHolder, 9)
    Stroke(ListHolder, CONFIG.Purple, 1, 0.5)

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 4)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = ListHolder

    local function RefreshOptions()
        for _, c in ipairs(ListHolder:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for i, opt in ipairs(options) do
            local OptBtn = Create("TextButton", {
                Parent = ListHolder, BackgroundColor3 = CONFIG.Panel,
                Size = UDim2.new(1, -8, 0, 36),
                Position = UDim2.new(0, 4, 0, 4),
                Text = opt, TextColor3 = CONFIG.White, TextSize = 12,
                Font = Enum.Font.GothamMedium, AutoButtonColor = false,
                BorderSizePixel = 0, LayoutOrder = i, ZIndex = 201,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            Corner(OptBtn, 6)
            Padding(OptBtn, 10, 10, 0, 0)
            OptBtn.MouseEnter:Connect(function() Tween(OptBtn, {BackgroundColor3 = CONFIG.Purple}, 0.1) end)
            OptBtn.MouseLeave:Connect(function() Tween(OptBtn, {BackgroundColor3 = CONFIG.Panel}, 0.1) end)
            OptBtn.Activated:Connect(function()
                Selected = opt
                TitleLbl.Text = title .. ": " .. opt
                ListHolder.Visible = false
                ListHolder.Size = UDim2.new(1, 0, 0, 0)
                IsOpen = false
                if cb then pcall(cb, opt) end
            end)
        end
    end

    Holder.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            if IsOpen then
                ListHolder.Visible = false
                ListHolder.Size = UDim2.new(1, 0, 0, 0)
                IsOpen = false
            else
                RefreshOptions()
                local h = math.min(#options * 40 + 8, 200)
                ListHolder.Size = UDim2.new(1, 0, 0, h)
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
        Parent = parent, BackgroundColor3 = CONFIG.Panel,
        Size = UDim2.new(1, 0, 0, 56), BorderSizePixel = 0, ZIndex = 13,
    })
    Corner(Holder, 9)
    Stroke(Holder, CONFIG.Purple, 1, 0.7)

    local TitleLbl = Create("TextLabel", {
        Parent = Holder, BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 6), Size = UDim2.new(1, -80, 0, 18),
        Text = title, TextColor3 = CONFIG.White, TextSize = 13,
        Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
    })

    local ValueLbl = Create("TextLabel", {
        Parent = Holder, BackgroundTransparency = 1,
        Position = UDim2.new(1, -70, 0, 6), Size = UDim2.new(0, 60, 0, 18),
        Text = tostring(val), TextColor3 = CONFIG.White, TextSize = 13,
        Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 14,
    })

    local Bar = Create("Frame", {
        Parent = Holder, BackgroundColor3 = CONFIG.Panel2,
        Position = UDim2.new(0, 14, 0, 34), Size = UDim2.new(1, -28, 0, 10),
        BorderSizePixel = 0, ZIndex = 14,
    })
    Corner(Bar, 5)

    local Fill = Create("Frame", {
        Parent = Bar, BackgroundColor3 = CONFIG.Purple,
        Size = UDim2.new((val - minVal) / (maxVal - minVal), 0, 1, 0),
        BorderSizePixel = 0, ZIndex = 15,
    })
    Corner(Fill, 5)

    local Btn = Create("TextButton", {
        Parent = Holder, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), Text = "",
        AutoButtonColor = false, ZIndex = 16,
    })

    local dragging = false
    local function Update(mouseX)
        local abs = Bar.AbsolutePosition
        local size = Bar.AbsoluteSize
        local rel = math.clamp((mouseX - abs.X) / size.X, 0, 1)
        val = math.floor(minVal + (maxVal - minVal) * rel + 0.5)
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        ValueLbl.Text = tostring(val)
        if cb then pcall(cb, val) end
    end

    Btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            Update(input.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            Update(input.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return Holder
end

local function CreateTab(name, order)
    local B = Create("TextButton", {
        Parent = TabList, BackgroundColor3 = CONFIG.Panel,
        Size = UDim2.new(1, 0, 0, 40), Text = "",
        AutoButtonColor = false, BorderSizePixel = 0,
        LayoutOrder = order, ZIndex = 17,
    })
    Corner(B, 8)
    local L = Create("TextLabel", {
        Parent = B, BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 1, 0),
        Text = name, TextColor3 = CONFIG.White,
        TextSize = 12, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 18,
    })
    Tabs[name] = {Button = B, Label = L}
    return B
end

local function ShowTab(name)
    for pageName, page in pairs(Pages) do page.Visible = pageName == name end
    for tabName, data in pairs(Tabs) do
        if tabName == name then
            data.Button.BackgroundColor3 = CONFIG.Purple
        else
            data.Button.BackgroundColor3 = CONFIG.Panel
        end
        data.Label.TextColor3 = CONFIG.White
    end
end

--// DATA
local AllIslands = {
    Sea1 = {
        {Name = "Starter Island", MinLevel = 1, MaxLevel = 9},
        {Name = "Jungle", MinLevel = 10, MaxLevel = 14},
        {Name = "Pirate Village", MinLevel = 15, MaxLevel = 29},
        {Name = "Desert Island", MinLevel = 30, MaxLevel = 59},
        {Name = "Frozen Village", MinLevel = 60, MaxLevel = 89},
        {Name = "Marine Ford", MinLevel = 90, MaxLevel = 119},
        {Name = "Skylands", MinLevel = 120, MaxLevel = 149},
        {Name = "Colosseum", MinLevel = 150, MaxLevel = 179},
        {Name = "Magma Village", MinLevel = 180, MaxLevel = 224},
        {Name = "Underwater City", MinLevel = 225, MaxLevel = 269},
        {Name = "Baratie Quest", MinLevel = 270, MaxLevel = 299},
        {Name = "Sky Island", MinLevel = 300, MaxLevel = 329},
        {Name = "Fountain City", MinLevel = 330, MaxLevel = 369},
        {Name = "Volcano Island", MinLevel = 370, MaxLevel = 399},
    },
    Sea2 = {
        {Name = "Kingdom of Rose", MinLevel = 700, MaxLevel = 799},
        {Name = "Green Zone", MinLevel = 800, MaxLevel = 899},
        {Name = "Graveyard", MinLevel = 900, MaxLevel = 999},
        {Name = "Snow Mountain", MinLevel = 1000, MaxLevel = 1099},
        {Name = "Hot and Cold", MinLevel = 1100, MaxLevel = 1199},
        {Name = "Cursed Ship", MinLevel = 1200, MaxLevel = 1299},
        {Name = "Ice Castle", MinLevel = 1300, MaxLevel = 1399},
        {Name = "Forgotten Island", MinLevel = 1400, MaxLevel = 1499},
    },
    Sea3 = {
        {Name = "Port Town", MinLevel = 1500, MaxLevel = 1574},
        {Name = "Hydra Island", MinLevel = 1575, MaxLevel = 1699},
        {Name = "Great Tree", MinLevel = 1700, MaxLevel = 1774},
        {Name = "Floating Turtle", MinLevel = 1775, MaxLevel = 1974},
        {Name = "Haunted Castle", MinLevel = 1975, MaxLevel = 2074},
        {Name = "Sea of Treats", MinLevel = 2075, MaxLevel = 2449},
        {Name = "Tiki Outpost", MinLevel = 2450, MaxLevel = 2800},
    },
}

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

local BossData = {
    Sea1 = {
        {Name = "Gorilla King", Level = 25, Location = "Jungle"},
        {Name = "Bobby (Chef)", Level = 55, Location = "Pirate Village"},
        {Name = "The Saw", Level = 100, Location = "Middle Town"},
        {Name = "Yeti", Level = 110, Location = "Frozen Village"},
        {Name = "Mob Leader", Level = 120, Location = "Pirate Starter Area"},
        {Name = "Vice Admiral", Level = 130, Location = "Marine Fortress"},
        {Name = "Saber Expert", Level = 200, Location = "Jungle Cave"},
        {Name = "Warden", Level = 220, Location = "Prison"},
        {Name = "Chief Warden", Level = 230, Location = "Prison"},
        {Name = "Swan", Level = 240, Location = "Prison"},
        {Name = "Magma Admiral", Level = 350, Location = "Magma Village"},
        {Name = "Fishman Lord", Level = 425, Location = "Underwater City"},
        {Name = "Wysper", Level = 500, Location = "Upper Skylands"},
        {Name = "Thunder God", Level = 575, Location = "Upper Skylands"},
        {Name = "Cyborg", Level = 675, Location = "Fountain City"},
        {Name = "Ice Admiral", Level = 700, Location = "Frozen Cave"},
    },
    Sea2 = {
        {Name = "Diamond", Level = 750, Location = "Kingdom of Rose"},
        {Name = "Jeremy", Level = 850, Location = "Kingdom of Rose"},
        {Name = "Orbitus", Level = 925, Location = "Green Zone"},
        {Name = "Don Swan", Level = 1000, Location = "Swan Mansion"},
        {Name = "Darkbeard", Level = 1000, Location = "Dark Arena", Raid = true},
        {Name = "Smoke Admiral", Level = 1150, Location = "Hot and Cold"},
        {Name = "Order", Level = 1250, Location = "Hot and Cold", Raid = true},
        {Name = "Cursed Captain", Level = 1325, Location = "Cursed Ship"},
        {Name = "Awakened Ice Admiral", Level = 1400, Location = "Ice Castle"},
        {Name = "Tide Keeper", Level = 1475, Location = "Forgotten Island"},
    },
    Sea3 = {
        {Name = "Stone", Level = 1550, Location = "Port Town"},
        {Name = "Island Empress", Level = 1675, Location = "Hydra Island"},
        {Name = "Kilo Admiral", Level = 1750, Location = "Great Tree"},
        {Name = "Captain Elephant", Level = 1875, Location = "Floating Turtle"},
        {Name = "Beautiful Pirate", Level = 1950, Location = "Floating Turtle"},
        {Name = "Longma", Level = 2000, Location = "Floating Turtle"},
        {Name = "Soul Reaper", Level = 2100, Location = "Haunted Castle", Raid = true},
        {Name = "Cake Queen", Level = 2175, Location = "Ice Cream Land"},
        {Name = "Cake Prince", Level = 2300, Location = "Sea of Treats", Raid = true},
        {Name = "Dough King", Level = 2300, Location = "Sea of Treats", Raid = true},
        {Name = "Tyrant of the Skies", Level = 2600, Location = "Tiki Outpost"},
        {Name = "rip_indra", Level = 5000, Location = "Castle on the Sea", Raid = true},
    },
}

local SecretQuests = {
    Jungle = {
        {Name = "Find Grappling Hook + repair Zipline", Steps = {"Cari Grappling Hook", "Repair Zipline"}},
        {Name = "Find Monkey tracks + knock Monkey down + return Hat", Steps = {"Cari jejak Monkey", "Knock Monkey", "Return Hat"}},
        {Name = "Trigger Gorilla King + knock bananas + defeat Gorilla King", Steps = {"Trigger Gorilla King", "Knock bananas", "Defeat Gorilla King"}},
    },
    ["Pirate Village"] = {
        {Name = "Break all Windmill ropes", Steps = {"Cari windmill", "Putus semua tali"}},
        {Name = "Wait Tavern enemies + defeat them + talk Bartender", Steps = {"Tunggu musuh", "Kalahkan", "Talk Bartender"}},
        {Name = "Help Chef + complete his task", Steps = {"Bantu Chef", "Selesaikan task"}},
    },
    Desert = {
        {Name = "Rescue Hasan under the Pyramid", Steps = {"Masuk Pyramid", "Cari Hasan", "Rescue"}},
        {Name = "Find and interact with 8 stone monuments", Steps = {"Cari 8 monument", "Interact semua"}},
        {Name = "Collect Cactus fruits", Steps = {"Cari cactus", "Collect fruit"}},
    },
    ["Frozen Village"] = {
        {Name = "Find Ability Teacher + complete his task", Steps = {"Cari Teacher", "Selesaikan task"}},
        {Name = "Build 3 Snowmen", Steps = {"Kumpulkan bahan", "Build 3"}},
        {Name = "Trigger Yeti + defeat Yeti", Steps = {"Trigger Yeti", "Defeat Yeti"}},
    },
    ["Marine Fortress"] = {
        {Name = "Find Rope + raise the Flag", Steps = {"Cari Rope", "Naikkan Flag"}},
        {Name = "Wait for Pirate Raid + defeat invading ships", Steps = {"Tunggu Raid", "Defeat ships"}},
        {Name = "Trigger Vice Admiral + defeat Vice Admiral", Steps = {"Trigger", "Defeat"}},
    },
    ["Lower Skylands"] = {
        {Name = "Find Angel Guard + retrieve the Golden Chest", Steps = {"Cari Angel Guard", "Ambil Chest"}},
        {Name = "Find Lightning Bolt + return to Mad Scientist", Steps = {"Cari Bolt", "Return"}},
        {Name = "Find the Crumpled Letter + deliver it", Steps = {"Cari Letter", "Deliver"}},
    },
    Prison = {
        {Name = "Stop 3 Escaped Prisoners", Steps = {"Cari 3 prisoner", "Stop"}},
        {Name = "Find Cell Block Key + retrieve the Coat", Steps = {"Cari Key", "Ambil Coat"}},
        {Name = "Activate Lever + defeat Prison Boss", Steps = {"Activate Lever", "Defeat Boss"}},
    },
    Colosseum = {
        {Name = "Defeat the 3 waves in the Colosseum", Steps = {"Wave 1", "Wave 2", "Wave 3"}},
        {Name = "Interact with Former Champions statues", Steps = {"Cari statues", "Interact"}},
        {Name = "Complete the Crowd Favorite 1v1", Steps = {"Masuk 1v1", "Menang"}},
    },
    ["Magma Village"] = {
        {Name = "Defeat the Evil Slimes", Steps = {"Cari Slimes", "Defeat"}},
        {Name = "Collect Magma Ore + complete extraction", Steps = {"Collect Ore", "Extract"}},
        {Name = "Trigger Magma General + defeat Magma General", Steps = {"Trigger", "Defeat"}},
    },
    ["Underwater City"] = {
        {Name = "Find Bubble Cove + help King Neptune", Steps = {"Cari Cove", "Bantu Neptune"}},
        {Name = "Activate Crystal Beam + help Water Kung Fu Teacher", Steps = {"Activate", "Bantu Teacher"}},
        {Name = "Find Black Pearl + defeat Fishman Lord", Steps = {"Cari Pearl", "Defeat Lord"}},
    },
    ["Upper Skylands"] = {
        {Name = "Find Temple Intel", Steps = {"Cari Intel"}},
        {Name = "Trigger Sky Warlord + defeat Sky Warlord", Steps = {"Trigger", "Defeat"}},
        {Name = "Find Yellow Bell + trigger Thunder God", Steps = {"Cari Bell", "Trigger"}},
    },
    ["Fountain City"] = {
        {Name = "Repair the broken Pipes", Steps = {"Cari pipes", "Repair"}},
        {Name = "Enter Sewer + defeat Sewer Gang", Steps = {"Masuk Sewer", "Defeat Gang"}},
        {Name = "Repair Cyborg's wires + defeat Cyborg", Steps = {"Repair wires", "Defeat Cyborg"}},
    },
}

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
                local name = string.lower(obj.Name)
                if string.find(name, "chest") or string.find(name, "treasure") or string.find(name, "reward") then
                    local isOpened = obj.Transparency >= 1 or obj:GetAttribute("Opened") == true
                    if not isOpened and obj.Parent then
                        table.insert(list, obj)
                    end
                end
            end
        end)
    end
    return list
end

local function GetChestKey(chest)
    local pos = chest.Position
    return string.format("%.1f_%.1f_%.1f", pos.X, pos.Y, pos.Z)
end

local function FindMaterials()
    local list = {}
    local kws = {"material", "ore", "wood", "stone", "crystal", "shard", "relic"}
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

local function GetWeaponCategory(weaponName)
    local name = string.lower(weaponName)
    local swordKws = {"katana","cutlass","sword","saber","rapier","blade","trident","pole","reaper","scythe","dagger","hooks","anchor","cursed","hallow","buddy","shark saw","warden","rengoku","tushita","yama"}
    for _, kw in ipairs(swordKws) do
        if string.find(name, kw) then return "Sword" end
    end
    local gunKws = {"gun","pistol","slingshot","rifle","bazooka","cannon","musket","sniper","flintlock"}
    for _, kw in ipairs(gunKws) do
        if string.find(name, kw) then return "Gun" end
    end
    local fruitKws = {"fruit","dough","leopard","kitsune","dragon","venom","shadow","control","spirit","mammoth","trex","rumble","portal","phoenix","sound","spider","buddha","magma","quake","light","dark","ice","sand","flame"}
    for _, kw in ipairs(fruitKws) do
        if string.find(name, kw) then return "Fruit" end
    end
    return "Melee"
end

local function GetWeaponsByCategory(category)
    local list = {}
    local char = Player.Character
    if not char then return list end
    local function check(t)
        if t:IsA("Tool") and GetWeaponCategory(t.Name) == category then
            table.insert(list, t)
        end
    end
    for _, t in ipairs(char:GetChildren()) do check(t) end
    for _, t in ipairs(Player.Backpack:GetChildren()) do check(t) end
    return list
end

local function SelectWeapon(weaponName)
    local char = Player.Character
    if not char then return false end
    local found = nil
    for _, c in ipairs(char:GetChildren()) do
        if c:IsA("Tool") and c.Name == weaponName then found = c break end
    end
    if not found then
        for _, c in ipairs(Player.Backpack:GetChildren()) do
            if c:IsA("Tool") and c.Name == weaponName then found = c break end
        end
    end
    if not found then Notify("Weapon tidak ada: " .. weaponName) return false end
    State.SelectedWeapon = found.Name
    State.SelectedCategory = GetWeaponCategory(found.Name)
    pcall(function() found.Parent = char end)
    Notify("Equipped [" .. State.SelectedCategory .. "]: " .. found.Name)
    return true
end

local function EquipWeapon()
    local char = Player.Character
    if not char then return nil end
    if State.SelectedWeapon then
        local held = char:FindFirstChild(State.SelectedWeapon)
        if held and held:IsA("Tool") then return held end
        for _, c in ipairs(Player.Backpack:GetChildren()) do
            if c:IsA("Tool") and c.Name == State.SelectedWeapon then
                c.Parent = char return c
            end
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
    maxDist = maxDist or CONFIG.AttackRange
    local hrp = GetHRP()
    if not hrp then return end
    local closest, dist = nil, math.huge
    for _, enemy in ipairs(ScanEnemies()) do
        local ehrp = enemy:FindFirstChild("HumanoidRootPart")
        if ehrp then
            local d = GetDist(ehrp.Position, hrp.Position)
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
        else return math.floor(mh / 500) end
    end
    return 0
end

local function FindMobByLevel(playerLevel, tolerance)
    tolerance = tolerance or 100
    local list = {}
    for _, mob in ipairs(workspace:GetDescendants()) do
        if mob:FindFirstChildOfClass("Humanoid")
            and mob:FindFirstChild("HumanoidRootPart")
            and not Players:GetPlayerFromCharacter(mob)
            and IsAlive(mob) then
            local mLvl = GetMobLevel(mob)
            local diff = math.abs(mLvl - playerLevel)
            if diff <= tolerance then
                table.insert(list, {model = mob, level = mLvl, diff = diff})
            end
        end
    end
    table.sort(list, function(a, b) return a.diff < b.diff end)
    return list
end

local function TweenToMob(mob, speed)
    local hrp = GetHRP()
    if not hrp then return end
    local targetHRP = mob:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end
    speed = speed or 150
    local startCF = hrp.CFrame
    local targetCF = CFrame.new(targetHRP.Position + Vector3.new(0, 3, 0))
    local distance = (startCF.Position - targetCF.Position).Magnitude
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

local function FindSeaMob(mobName)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == mobName and obj:FindFirstChildOfClass("Humanoid") then
            if obj:FindFirstChild("HumanoidRootPart") then return obj end
        end
    end
    return nil
end

local function FindObjectByKeyword(keyword)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if string.find(string.lower(obj.Name), string.lower(keyword)) then
            if obj:IsA("BasePart") or obj:IsA("Model") then
                return obj
            end
        end
    end
    return nil
end

local function GetPlayerBoat()
    local char = Player.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (string.find(string.lower(obj.Name), "boat")
            or string.find(string.lower(obj.Name), "ship")) then
            if obj.PrimaryPart and GetDist(obj.PrimaryPart.Position, hrp.Position) < 50 then
                return obj
            end
        end
    end
    return nil
end

local function IsInRaidArea()
    local leaderstats = Player:FindFirstChild("leaderstats")
    local LevelValue = leaderstats and leaderstats:FindFirstChild("Level")
    if not LevelValue or LevelValue.Value < CONFIG.RaidMinLevel then return false end
    local hrp = GetHRP()
    if not hrp then return false end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Folder") or obj:IsA("Model") then
            local name = string.lower(obj.Name)
            if string.find(name, "raid") or string.find(name, "room") or string.find(name, "pass") then
                if obj:IsA("BasePart") and GetDist(obj.Position, hrp.Position) <= 500 then return true end
                if obj:IsA("Model") and obj.PrimaryPart and GetDist(obj.PrimaryPart.Position, hrp.Position) <= 500 then return true end
            end
        end
    end
    return false
end

local function GlobalSearch(query)
    if not query or query == "" then return {} end
    local q = string.lower(query)
    local results = {}
    for loc, quests in pairs(SecretQuests) do
        for _, quest in ipairs(quests) do
            if string.find(string.lower(quest.Name), q) then
                table.insert(results, {type = "Quest", location = loc, name = quest.Name})
            end
        end
    end
    for sea, bosses in pairs(BossData) do
        for _, boss in ipairs(bosses) do
            if string.find(string.lower(boss.Name), q) then
                table.insert(results, {type = "Boss", location = boss.Location, name = boss.Name})
            end
        end
    end
    for sea, islands in pairs(AllIslands) do
        for _, island in ipairs(islands) do
            if string.find(string.lower(island.Name), q) then
                table.insert(results, {type = "Island", location = sea, name = island.Name})
            end
        end
    end
    local char = Player.Character
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and string.find(string.lower(tool.Name), q) then
                table.insert(results, {type = "Weapon", location = "Equipped", name = tool.Name})
            end
        end
    end
    for _, tool in ipairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and string.find(string.lower(tool.Name), q) then
            table.insert(results, {type = "Weapon", location = "Backpack", name = tool.Name})
        end
    end
    return results
end

local function AutoAddStats()
    local CommF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
    if not CommF then Notify("Remote CommF_ tidak ditemukan") return false end
    local stats = {
        {Name = "Melee", Value = State.StatsMelee},
        {Name = "Defense", Value = State.StatsDefense},
        {Name = "Sword", Value = State.StatsSword},
        {Name = "Gun", Value = State.StatsGun},
        {Name = "Blox Fruit", Value = State.StatsBloxFruit},
    }
    for _, stat in ipairs(stats) do
        if stat.Value > 0 then
            pcall(function() CommF:InvokeServer("AddPoint", stat.Name, stat.Value) end)
            Notify("Add " .. stat.Name .. ": " .. stat.Value)
            task.wait(0.3)
        end
    end
    return true
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

--// HOLDERS
local WeaponListHolder = Create("Frame", {Parent = FarmPage, BackgroundColor3 = CONFIG.Panel, Size = UDim2.new(1, 0, 0, 200), BorderSizePixel = 0, ZIndex = 13})
Corner(WeaponListHolder, 10)
Stroke(WeaponListHolder, CONFIG.Purple, 1, 0.7)
local WeaponListScroll = Create("ScrollingFrame", {Parent = WeaponListHolder, BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(1, -16, 1, -16), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3, ScrollBarImageColor3 = CONFIG.Purple, BorderSizePixel = 0, ZIndex = 14})
local WL = Instance.new("UIListLayout")
WL.Padding = UDim.new(0, 6)
WL.SortOrder = Enum.SortOrder.LayoutOrder
WL.Parent = WeaponListScroll

local BossListHolder = Create("Frame", {Parent = FarmPage, BackgroundColor3 = CONFIG.Panel, Size = UDim2.new(1, 0, 0, 200), BorderSizePixel = 0, ZIndex = 13})
Corner(BossListHolder, 10)
Stroke(BossListHolder, CONFIG.Purple, 1, 0.7)
local BossListScroll = Create("ScrollingFrame", {Parent = BossListHolder, BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(1, -16, 1, -16), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3, ScrollBarImageColor3 = CONFIG.Purple, BorderSizePixel = 0, ZIndex = 14})
local BL = Instance.new("UIListLayout")
BL.Padding = UDim.new(0, 6)
BL.SortOrder = Enum.SortOrder.LayoutOrder
BL.Parent = BossListScroll

local SecretHolder = Create("Frame", {Parent = QuestItemsPage, BackgroundColor3 = CONFIG.Panel, Size = UDim2.new(1, 0, 0, 250), BorderSizePixel = 0, ZIndex = 13})
Corner(SecretHolder, 10)
Stroke(SecretHolder, CONFIG.Purple, 1, 0.7)
local SecretScroll = Create("ScrollingFrame", {Parent = SecretHolder, BackgroundTransparency = 1, Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(1, -16, 1, -16), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3, ScrollBarImageColor3 = CONFIG.Purple, BorderSizePixel = 0, ZIndex = 14})
local SL = Instance.new("UIListLayout")
SL.Padding = UDim.new(0, 6)
SL.SortOrder = Enum.SortOrder.LayoutOrder
SL.Parent = SecretScroll

--// SHOW FUNCTIONS
function ShowWeaponsInCategory(cat)
    for _, c in ipairs(WeaponListScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local weapons = GetWeaponsByCategory(cat)
    if #weapons == 0 then
        Create("TextLabel", {Parent = WeaponListScroll, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), Text = "Tidak ada weapon " .. cat, TextColor3 = CONFIG.White, TextSize = 12, ZIndex = 15})
        return
    end
    for i, w in ipairs(weapons) do
        local Btn = Create("TextButton", {Parent = WeaponListScroll, BackgroundColor3 = CONFIG.Panel2, Size = UDim2.new(1, 0, 0, 36), Text = "- " .. w.Name, TextColor3 = CONFIG.White, TextSize = 12, Font = Enum.Font.GothamMedium, AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = i, ZIndex = 15, TextXAlignment = Enum.TextXAlignment.Left})
        Corner(Btn, 8)
        Padding(Btn, 12, 12, 0, 0)
        Btn.Activated:Connect(function() SelectWeapon(w.Name) end)
    end
end

function ShowBossBySea(sea)
    for _, c in ipairs(BossListScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for i, b in ipairs(BossData[sea] or {}) do
        local Btn = Create("TextButton", {Parent = BossListScroll, BackgroundColor3 = CONFIG.Panel2, Size = UDim2.new(1, 0, 0, 46), Text = "- " .. b.Name .. " (Lv " .. b.Level .. ")\n  " .. b.Location .. (b.Raid and " [Raid]" or ""), TextColor3 = CONFIG.White, TextSize = 11, Font = Enum.Font.GothamMedium, AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = i, ZIndex = 15, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top})
        Corner(Btn, 8)
        Padding(Btn, 12, 12, 6, 6)
        Btn.Activated:Connect(function()
            State.SelectedBoss = b.Name
            State.SelectedBossSea = sea
            Notify("Boss: " .. b.Name)
        end)
    end
end

function ShowSecretLocations()
    for _, c in ipairs(SecretScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local i = 0
    for loc, quests in pairs(SecretQuests) do
        i += 1
        local Btn = Create("TextButton", {Parent = SecretScroll, BackgroundColor3 = CONFIG.Panel2, Size = UDim2.new(1, 0, 0, 38), Text = loc .. " (" .. #quests .. ")", TextColor3 = CONFIG.White, TextSize = 12, Font = Enum.Font.GothamBold, AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = i, ZIndex = 15, TextXAlignment = Enum.TextXAlignment.Left})
        Corner(Btn, 8)
        Padding(Btn, 12, 12, 0, 0)
        Btn.Activated:Connect(function() ShowSecretQuests(loc) end)
    end
end

function ShowSecretQuests(location)
    for _, c in ipairs(SecretScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local Back = Create("TextButton", {Parent = SecretScroll, BackgroundColor3 = CONFIG.Panel2, Size = UDim2.new(1, 0, 0, 36), Text = "< Back", TextColor3 = CONFIG.White, TextSize = 12, Font = Enum.Font.GothamBold, AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = 1, ZIndex = 15, TextXAlignment = Enum.TextXAlignment.Left})
    Corner(Back, 8)
    Padding(Back, 12, 12, 0, 0)
    Back.Activated:Connect(ShowSecretLocations)
    for i, q in ipairs(SecretQuests[location] or {}) do
        local Btn = Create("TextButton", {Parent = SecretScroll, BackgroundColor3 = CONFIG.Panel2, Size = UDim2.new(1, 0, 0, 42), Text = "- " .. q.Name, TextColor3 = CONFIG.White, TextSize = 11, Font = Enum.Font.GothamMedium, AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = i + 1, ZIndex = 15, TextXAlignment = Enum.TextXAlignment.Left})
        Corner(Btn, 8)
        Padding(Btn, 12, 12, 0, 0)
        Btn.Activated:Connect(function()
            State.SelectedSecretLocation = location
            State.SelectedSecretQuest = q
            Notify("Quest: " .. q.Name)
        end)
    end
end

ShowSecretLocations()

--// DISCORD
CreateSection(DiscordPage, "DISCORD INFO", "Join community")
Create("TextLabel", {Parent = DiscordPage, BackgroundColor3 = CONFIG.Panel, Size = UDim2.new(1, 0, 0, 80), Text = "Discord Server:\n" .. CONFIG.Discord, TextColor3 = CONFIG.White, TextSize = 13, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0, ZIndex = 13})
CreateButton(DiscordPage, "Copy Discord Link", function()
    if setclipboard then setclipboard(CONFIG.Discord) Notify("Copied") end
end)

--// FARM
CreateSection(FarmPage, "FARM", "Auto farm level")
CreateToggle(FarmPage, "Auto Farm Level", false, function(s) State.AutoFarm = s Notify("Auto Farm Level: " .. (s and "ON" or "OFF")) end)
CreateToggle(FarmPage, "Auto Kill Nearest", false, function(s) State.AutoKillNearest = s Notify("Auto Kill Nearest: " .. (s and "ON" or "OFF")) end)

CreateSection(FarmPage, "WEAPON", "Pilih kategori lalu weapon")
CreateDropdown(FarmPage, "Select Tool", {"Melee", "Sword", "Gun", "Fruit"}, function(opt)
    State.SelectedCategory = opt
    ShowWeaponsInCategory(opt)
end)

CreateSection(FarmPage, "BOSS", "Pilih boss")
CreateDropdown(FarmPage, "Select Sea", {"Sea1", "Sea2", "Sea3"}, function(opt) ShowBossBySea(opt) end)
CreateToggle(FarmPage, "Auto Farm Boss", false, function(s)
    State.AutoBoss = s
    if s and not State.SelectedBoss then Notify("Pilih boss dulu") State.AutoBoss = false
    else Notify("Auto Farm Boss: " .. (s and "ON" or "OFF")) end
end)

CreateSection(FarmPage, "CHEST", "Auto farm chest")
CreateToggle(FarmPage, "Farm Chest", false, function(s)
    State.AutoChest = s
    if s then State.OpenedChests = {} end
    Notify("Farm Chest: " .. (s and "ON" or "OFF"))
end)

--// SEA
CreateSection(SeaPage, "SEA", "Pilih mob laut")
CreateDropdown(SeaPage, "Select Mobs", {"Piranha", "Shark", "FishCrewMember", "SeaBeast", "Terrorshark"}, function(opt)
    State.SelectedSeaMob = opt
    Notify("Mob: " .. opt)
end)

CreateSection(SeaPage, "AUTO FARM SEA", "Farm mob laut")
CreateToggle(SeaPage, "Auto Farm Sea", false, function(s) State.AutoFarmSea = s Notify("Auto Farm Sea: " .. (s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Auto Kill Sea Beast", false, function(s) State.AutoKillSeaBeast = s Notify("Auto Kill Sea Beast: " .. (s and "ON" or "OFF")) end)

CreateSection(SeaPage, "BOAT", "Kontrol kapal")
CreateToggle(SeaPage, "Auto Drive", false, function(s) State.AutoDrive = s Notify("Auto Drive: " .. (s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Delete Rocks", false, function(s) State.DeleteRocks = s Notify("Delete Rocks: " .. (s and "ON" or "OFF")) end)
CreateSlider(SeaPage, "Height Boat", 0, 100, 0, function(v) State.HeightBoat = v end)
CreateSlider(SeaPage, "Speed Boat", 0, 350, 0, function(v) State.SpeedBoat = v end)

CreateSection(SeaPage, "MIRAGE", "Fitur Mirage")
CreateButton(SeaPage, "Find Mirage", function()
    local m = FindObjectByKeyword("mirage")
    if m and m.PrimaryPart then TeleportTo(m.PrimaryPart.Position + Vector3.new(0, 5, 0)) Notify("Teleport Mirage") else Notify("Mirage tidak ada") end
end)
CreateButton(SeaPage, "Teleport Highest", function()
    local hrp = GetHRP()
    if hrp then hrp.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 500, 0)) Notify("Teleport Highest") end
end)
CreateToggle(SeaPage, "Lock Moon", false, function(s) State.LockMoon = s Notify("Lock Moon: " .. (s and "ON" or "OFF")) end)
CreateButton(SeaPage, "Teleport Bluegear", function()
    local b = FindObjectByKeyword("bluegear")
    if b and b.PrimaryPart then TeleportTo(b.PrimaryPart.Position + Vector3.new(0, 5, 0)) Notify("Teleport Bluegear") else Notify("Bluegear tidak ada") end
end)
CreateButton(SeaPage, "Teleport Bloxfruit Dealer", function()
    local d = FindObjectByKeyword("dealer")
    if d and d.PrimaryPart then TeleportTo(d.PrimaryPart.Position + Vector3.new(0, 5, 0)) Notify("Teleport Dealer") else Notify("Dealer tidak ada") end
end)

CreateSection(SeaPage, "KITSUNE", "Fitur Kitsune")
CreateButton(SeaPage, "Find Kitsune Island", function()
    local k = FindObjectByKeyword("kitsune")
    if k and k.PrimaryPart then TeleportTo(k.PrimaryPart.Position + Vector3.new(0, 5, 0)) Notify("Teleport Kitsune") else Notify("Kitsune tidak ada") end
end)
CreateButton(SeaPage, "Teleport Azure Ember", function()
    local a = FindObjectByKeyword("azure ember")
    if a and a.PrimaryPart then TeleportTo(a.PrimaryPart.Position + Vector3.new(0, 5, 0)) Notify("Teleport Azure Ember") else Notify("Azure Ember tidak ada") end
end)
CreateSlider(SeaPage, "Azure Ember Count", 0, 35, 0, function(v) State.AzureEmberCount = v end)

CreateSection(SeaPage, "PREHISTORIC", "Fitur Prehistoric")
CreateButton(SeaPage, "Find Prehistoric", function()
    local p = FindObjectByKeyword("prehistoric")
    if p and p.PrimaryPart then TeleportTo(p.PrimaryPart.Position + Vector3.new(0, 5, 0)) Notify("Teleport Prehistoric") else Notify("Prehistoric tidak ada") end
end)
CreateToggle(SeaPage, "Auto Kill Golem", false, function(s) State.AutoKillGolem = s Notify("Auto Kill Golem: " .. (s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Auto Collect Bone", false, function(s) State.AutoCollectBone = s Notify("Auto Collect Bone: " .. (s and "ON" or "OFF")) end)

CreateSection(SeaPage, "TRADE", "Auto Trade")
CreateToggle(SeaPage, "Auto Trade", false, function(s) State.AutoTrade = s Notify("Auto Trade: " .. (s and "ON" or "OFF")) end)

--// QUEST / ITEMS
CreateSection(QuestItemsPage, "QUEST / ITEMS", "Auto farm item langka")
CreateToggle(QuestItemsPage, "Auto CDK", false, function(s) State.AutoCDK = s Notify("Auto CDK: " .. (s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Dark Dagger", false, function(s) State.AutoDarkDagger = s Notify("Auto Dark Dagger: " .. (s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Soul Guitar", false, function(s) State.AutoSoulGuitar = s Notify("Auto Soul Guitar: " .. (s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Yama", false, function(s) State.AutoYama = s Notify("Auto Yama: " .. (s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Tushita", false, function(s) State.AutoTushita = s Notify("Auto Tushita: " .. (s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Buddy Sword", false, function(s) State.AutoBuddySword = s Notify("Auto Buddy Sword: " .. (s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Kill Indra", false, function(s) State.AutoKillIndra = s Notify("Auto Kill Indra: " .. (s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Spawn Dough King", false, function(s) State.AutoSpawnDoughKing = s Notify("Auto Spawn Dough King: " .. (s and "ON" or "OFF")) end)

CreateSection(QuestItemsPage, "SEARCH", "Cari quest / boss / island / weapon")
CreateInput(QuestItemsPage, "Search... (quest, boss, island, weapon)", function(text)
    State.SearchInput = text
    if not text or text == "" then
        for _, c in ipairs(SecretScroll:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        ShowSecretLocations()
        return
    end
    local results = GlobalSearch(text)
    for _, c in ipairs(SecretScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    if #results == 0 then
        Create("TextLabel", {Parent = SecretScroll, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), Text = "Tidak ada hasil", TextColor3 = CONFIG.White, TextSize = 12, ZIndex = 15})
        return
    end
    for i, r in ipairs(results) do
        local Btn = Create("TextButton", {Parent = SecretScroll, BackgroundColor3 = CONFIG.Panel2, Size = UDim2.new(1, 0, 0, 42), Text = "[" .. r.type .. "] " .. r.name .. "\n  " .. r.location, TextColor3 = CONFIG.White, TextSize = 11, Font = Enum.Font.GothamMedium, AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = i, ZIndex = 15, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top})
        Corner(Btn, 8)
        Padding(Btn, 12, 12, 6, 6)
        Btn.Activated:Connect(function()
            Notify("Selected: " .. r.name)
            if r.type == "Boss" then State.SelectedBoss = r.name
            elseif r.type == "Quest" then State.SelectedSecretLocation = r.location
            elseif r.type == "Weapon" then SelectWeapon(r.name) end
        end)
    end
end)

CreateSection(QuestItemsPage, "SECRET QUEST", "Pilih quest")
CreateDropdown(QuestItemsPage, "Select Location", 
    {"Jungle", "Pirate Village", "Desert", "Frozen Village", "Marine Fortress",
     "Lower Skylands", "Prison", "Colosseum", "Magma Village", "Underwater City",
     "Upper Skylands", "Fountain City"}, 
function(opt) ShowSecretQuests(opt) end)

CreateButton(QuestItemsPage, "Start Secret Quest", function()
    if not State.SelectedSecretQuest then Notify("Pilih quest dulu") return end
    Notify("Starting: " .. State.SelectedSecretQuest.Name)
end)
CreateButton(QuestItemsPage, "Cancel Secret Quest", function()
    State.SelectedSecretQuest = nil
    Notify("Quest dibatalkan")
end)

--// FRUIT / RAID
CreateSection(FruitRaidPage, "FRUIT", "Auto collect fruit")
CreateToggle(FruitRaidPage, "Auto Collect Fruit", false, function(s) State.AutoFruit = s Notify("Auto Collect Fruit: " .. (s and "ON" or "OFF")) end)

CreateSection(FruitRaidPage, "GACHA ZIOLES", "Auto Gacha Box")
CreateToggle(FruitRaidPage, "Auto Gacha", false, function(s) State.RandomFruit = s Notify("Auto Gacha: " .. (s and "ON" or "OFF")) end)
CreateToggle(FruitRaidPage, "Store Fruit", false, function(s) State.StoreFruit = s Notify("Store Fruit: " .. (s and "ON" or "OFF")) end)

CreateSection(FruitRaidPage, "RAID", "Auto raid")
CreateDropdown(FruitRaidPage, "Select Raid", 
    {"Flame", "Ice", "Sand", "Dark", "Light", "Magma", "Quake", "Buddha", "Spider", "Phoenix", "Dough"},
function(opt) State.SelectedRaid = opt Notify("Raid: " .. opt) end)
CreateToggle(FruitRaidPage, "Auto Raid", false, function(s) State.AutoRaid = s Notify("Auto Raid: " .. (s and "ON" or "OFF")) end)
CreateToggle(FruitRaidPage, "Auto Buy Chip", false, function(s) State.AutoBuyChip = s Notify("Auto Buy Chip: " .. (s and "ON" or "OFF")) end)

--// FISHING
CreateSection(FishingPage, "FISHING", "Auto fishing")
CreateToggle(FishingPage, "Auto Fishing", false, function(s) State.AutoFishing = s Notify("Auto Fishing: " .. (s and "ON" or "OFF")) end)
CreateToggle(FishingPage, "Auto Catch", false, function(s) State.AutoCatch = s Notify("Auto Catch: " .. (s and "ON" or "OFF")) end)

--// STATUS
CreateSection(StatusPage, "STATUS", "Info player")
local StatusLabel = Create("TextLabel", {Parent = StatusPage, BackgroundColor3 = CONFIG.Panel, Size = UDim2.new(1, 0, 0, 100), Text = "Level: -\nIsland: -\nSea: -\nBoss: -", TextColor3 = CONFIG.White, TextSize = 13, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0, ZIndex = 13})
Corner(StatusLabel, 9)
Padding(StatusLabel, 14, 14, 7, 7)

local leaderstats = Player:FindFirstChild("leaderstats")
local LevelValue = leaderstats and leaderstats:FindFirstChild("Level")

task.spawn(function()
    while task.wait(1) do
        if LevelValue then
            local lv = LevelValue.Value
            local island, sea = GetIslandByLevel(lv)
            StatusLabel.Text = string.format("Level: %d\nIsland: %s\nSea: %s\nBoss: %s", lv, island or "-", tostring(sea) or "-", State.SelectedBoss or "-")
        end
    end
end)

--// PVP
CreateSection(PvPPage, "PLAYER CONTROL", "Pilih player untuk teleport / spectate")
CreateDropdown(PvPPage, "Select Player", (function()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then table.insert(list, plr.Name) end
    end
    return list
end)(), function(opt) State.SelectedPlayer = opt Notify("Player: " .. opt) end)

CreateButton(PvPPage, "Teleport Player", function()
    if not State.SelectedPlayer then Notify("Pilih player dulu") return end
    local target = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name == State.SelectedPlayer then target = plr break end
    end
    if not target or not target.Character then Notify("Player tidak ada") return end
    local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end
    local myHRP = GetHRP()
    if not myHRP then return end
    myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, -5)
    Notify("Teleport ke: " .. State.SelectedPlayer)
end)

CreateButton(PvPPage, "Spectate Player", function()
    if not State.SelectedPlayer then Notify("Pilih player dulu") return end
    local target = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name == State.SelectedPlayer then target = plr break end
    end
    if not target or not target.Character then Notify("Player tidak ada") return end
    local targetHum = target.Character:FindFirstChildOfClass("Humanoid")
    if not targetHum then return end
    Camera.CameraSubject = targetHum
    Camera.CameraType = Enum.CameraType.Custom
    State.Spectating = true
    State.SpectateTarget = State.SelectedPlayer
    Notify("Spectating: " .. State.SelectedPlayer)
end)

CreateButton(PvPPage, "Stop Spectate", function()
    local char = Player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then Camera.CameraSubject = hum end
    end
    State.Spectating = false
    State.SpectateTarget = nil
    Notify("Spectate stopped")
end)

CreateSection(PvPPage, "COMBAT", "Fitur PvP")
CreateToggle(PvPPage, "Aimbot", false, function(s) State.Aimbot = s Notify("Aimbot: " .. (s and "ON" or "OFF")) end)
CreateToggle(PvPPage, "Hitbox", false, function(s) State.Hitbox = s Notify("Hitbox: " .. (s and "ON" or "OFF")) end)

local KillAuraLabel = Create("TextLabel", {Parent = PvPPage, BackgroundColor3 = CONFIG.Panel, Size = UDim2.new(1, 0, 0, 40), Text = "Kill Aura: Auto (bawaan)", TextColor3 = CONFIG.White, TextSize = 13, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0, ZIndex = 13})
Corner(KillAuraLabel, 9)
Padding(KillAuraLabel, 14, 14, 7, 7)

task.spawn(function()
    while task.wait(1) do
        if IsInRaidArea() then KillAuraLabel.Text = "Kill Aura: Active (di Raid)"
        else KillAuraLabel.Text = "Kill Aura: Standby (bukan Raid)" end
    end
end)

--// STATS
CreateSection(StatsPage, "AUTO ADD STATS", "Distribute stat point otomatis")
CreateToggle(StatsPage, "Auto Add Stats", false, function(s) State.AutoAddStats = s Notify("Auto Add Stats: " .. (s and "ON" or "OFF")) end)
CreateSlider(StatsPage, "Melee", 0, 100, 0, function(v) State.StatsMelee = v end)
CreateSlider(StatsPage, "Defense", 0, 100, 0, function(v) State.StatsDefense = v end)
CreateSlider(StatsPage, "Sword", 0, 100, 0, function(v) State.StatsSword = v end)
CreateSlider(StatsPage, "Gun", 0, 100, 0, function(v) State.StatsGun = v end)
CreateSlider(StatsPage, "BloxFruit", 0, 100, 0, function(v) State.StatsBloxFruit = v end)
CreateButton(StatsPage, "Apply Stats Sekarang", function() AutoAddStats() end)

--// MISC
CreateSection(MiscPage, "ANTI AFK", "Cegah kick idle")
CreateToggle(MiscPage, "Anti AFK", true, function(s) State.AntiAFK = s Notify("Anti AFK: " .. (s and "ON" or "OFF")) end)

CreateSection(MiscPage, "JOB ID", "Join server by Job ID")
CreateButton(MiscPage, "Copy Job ID", function()
    if setclipboard then setclipboard(tostring(game.JobId)) Notify("Job ID copied") end
end)
CreateInput(MiscPage, "Paste Job ID here...", function(text) State.JobIDInput = text end)
CreateButton(MiscPage, "Join Job", function()
    if not State.JobIDInput or State.JobIDInput == "" then Notify("Isi Job ID dulu") return end
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, State.JobIDInput, Player) end)
end)

CreateSection(MiscPage, "MOVEMENT", "Movement control")
CreateToggle(MiscPage, "Bring Mob", false, function(s) State.BringMob = s Notify("Bring Mob: " .. (s and "ON" or "OFF")) end)
CreateSlider(MiscPage, "Bring Mob Range", 0, 100, 50, function(v) State.BringMobRange = v end)
CreateToggle(MiscPage, "Infinite Jump", false, function(s) State.InfiniteJump = s Notify("Infinite Jump: " .. (s and "ON" or "OFF")) end)

CreateSection(MiscPage, "PERFORMANCE", "Boost FPS")
CreateToggle(MiscPage, "Boost FPS", false, function(s)
    State.BoostFPS = s
    if s then
        pcall(function()
            State.OriginalLighting = {GlobalShadows = Lighting.GlobalShadows, Brightness = Lighting.Brightness, Ambient = Lighting.Ambient}
            Lighting.GlobalShadows = false
            Lighting.Brightness = 0
            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
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
    if not State.CodeInput or State.CodeInput == "" then Notify("Isi code dulu") return end
    if REMOTE_Redeem then
        pcall(function()
            if REMOTE_Redeem:IsA("RemoteEvent") then REMOTE_Redeem:FireServer(State.CodeInput)
            else REMOTE_Redeem:InvokeServer(State.CodeInput) end
        end)
        Notify("Redeem: " .. State.CodeInput)
    else
        Notify("Remote redeem tidak ditemukan")
    end
end)

CreateSection(MiscPage, "SERVER", "Server options")
CreateButton(MiscPage, "Rejoin Server", function() TeleportService:Teleport(game.PlaceId, Player) end)

--// LOOPS
task.spawn(function()
    while task.wait(CONFIG.FarmDelay) do
        if State.AutoFarm then
            SafeCall(function()
                local lv = LevelValue and LevelValue.Value or 1
                local mobs = FindMobByLevel(lv, 100)
                if #mobs > 0 then
                    local target = mobs[1].model
                    TweenToMob(target, 150)
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
                if #chests == 0 then task.wait(CONFIG.ChestWaitCooldown) return end
                local nearest, nearestDist = nil, math.huge
                for _, c in ipairs(chests) do
                    local key = GetChestKey(c)
                    if not State.OpenedChests[key] then
                        local d = GetDist(c.Position, hrp.Position)
                        if d < nearestDist then nearest, nearestDist = c, d end
                    end
                end
                if not nearest then
                    State.OpenedChests = {}
                    task.wait(CONFIG.ChestWaitCooldown)
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
                        local d = GetDist(m.Position, hrp.Position)
                        if d < dist then nearest, dist = m, d end
                    end
                    if nearest and dist < 300 then TeleportTo(nearest.Position + Vector3.new(0, 3, 0)) end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if State.AutoFruit then
            SafeCall(function()
                for _, f in ipairs(FindFruits()) do
                    local hrp = GetHRP()
                    if hrp and GetDist(f.Position, hrp.Position) < 500 then
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
                if tool and string.find(string.lower(tool.Name), "rod") then tool:Activate() end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if State.AutoFarmSea and State.SelectedSeaMob then
            SafeCall(function()
                local mob = FindSeaMob(State.SelectedSeaMob)
                if mob then
                    local hrp = mob:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        TeleportTo(hrp.Position + Vector3.new(0, 3, 0))
                        local tool = EquipWeapon()
                        if tool then tool:Activate() end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        if State.AutoKillSeaBeast then
            SafeCall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    local n = string.lower(obj.Name)
                    if (string.find(n, "seabeast") or string.find(n, "seabest") or string.find(n, "terrorshark"))
                        and obj:FindFirstChildOfClass("Humanoid") then
                        local hrp = obj:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            TeleportTo(hrp.Position + Vector3.new(0, 3, 0))
                            local tool = EquipWeapon()
                            if tool then tool:Activate() end
                            break
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoDrive then
            SafeCall(function()
                local boat = GetPlayerBoat()
                if boat and boat.PrimaryPart then
                    local hrp = GetHRP()
                    if hrp then boat.PrimaryPart.CFrame = CFrame.new(hrp.Position + Vector3.new(0, State.HeightBoat / 10, 0)) end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if State.DeleteRocks then
            SafeCall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "rock") then
                        pcall(function() obj:Destroy() end)
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if State.AutoKillGolem then
            SafeCall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if string.find(string.lower(obj.Name), "golem") and obj:FindFirstChildOfClass("Humanoid") and IsAlive(obj) then
                        local hrp = obj:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            TeleportTo(hrp.Position + Vector3.new(0, 3, 0))
                            local tool = EquipWeapon()
                            if tool then tool:Activate() end
                            break
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        if State.AutoCollectBone then
            SafeCall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "bone") then
                        local hrp = GetHRP()
                        if hrp and GetDist(obj.Position, hrp.Position) < 500 then
                            TeleportTo(obj.Position + Vector3.new(0, 3, 0))
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(60) do
        if State.RandomFruit and REMOTE_RandomFruit then
            SafeCall(function()
                local now = os.time()
                if now - State.LastRandomFruit >= CONFIG.RandomFruitCooldown and not GetHeldFruit() then
                    pcall(function()
                        if REMOTE_RandomFruit:IsA("RemoteEvent") then REMOTE_RandomFruit:FireServer()
                        else REMOTE_RandomFruit:InvokeServer() end
                    end)
                    State.LastRandomFruit = now
                    Notify("Auto Gacha fired")
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        if State.StoreFruit then
            SafeCall(function()
                local held = GetHeldFruit()
                if held then
                    local fruitName = held.Name
                    if REMOTE_StoreFruit then
                        pcall(function()
                            if REMOTE_StoreFruit:IsA("RemoteEvent") then REMOTE_StoreFruit:FireServer(held)
                            else REMOTE_StoreFruit:InvokeServer(held) end
                        end)
                    else
                        pcall(function() held.Parent = Player.Backpack end)
                    end
                    Notify("Store Fruit: " .. fruitName)
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(15) do
        if State.AutoBuyChip and REMOTE_BuyChip and not GetHeldChip() then
            SafeCall(function()
                pcall(function()
                    if REMOTE_BuyChip:IsA("RemoteEvent") then REMOTE_BuyChip:FireServer()
                    else REMOTE_BuyChip:InvokeServer() end
                end)
                Notify("BuyChip")
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if State.AutoAddStats then SafeCall(AutoAddStats) end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        State.KillAura = IsInRaidArea()
        if State.KillAura then
            local now = os.clock()
            if now - State.LastKillAura >= CONFIG.KillAuraCooldown then
                local hrp = GetHRP()
                if hrp then
                    local found = false
                    for _, obj in ipairs(workspace:GetChildren()) do
                        if IsNPC(obj) or IsEnemyPlayer(obj) then
                            local targetHRP = obj:FindFirstChild("HumanoidRootPart")
                            if targetHRP and GetDist(targetHRP.Position, hrp.Position) <= CONFIG.KillAuraRange then
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
                            local mobRoot = model:FindFirstChild("HumanoidRootPart")
                            if mobRoot and GetDist(mobRoot.Position, hrp.Position) <= State.BringMobRange then
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

task.spawn(function()
    while task.wait(0.1) do
        if State.InfiniteJump then
            local char = Player.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
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

--// TABS
local TabDefinitions = {
    {"Discord"}, {"Farm"}, {"Sea"}, {"Quest / Items"}, {"Fruit / Raid"},
    {"Fishing"}, {"Status"}, {"PvP"}, {"Stats"}, {"Misc"},
}

for index, data in ipairs(TabDefinitions) do
    local btn = CreateTab(data[1], index)
    btn.Activated:Connect(function() ShowTab(data[1]) end)
end

CloseButton.Activated:Connect(function() Main.Visible = false OpenButton.Visible = true end)
OpenButton.Activated:Connect(function() Main.Visible = true OpenButton.Visible = false end)

--// DRAG
local dragging, dragStart, startPos = false, nil, nil
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
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
    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - dragStart
    Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end)

--// ANTI AFK
Player.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

ShowTab("Discord")

print("================================")
print("        SYSX HUB LOADED v1.0.2")
print("        " .. CONFIG.Build)
print("================================")

Notify("SysxHub " .. CONFIG.Build .. " loaded")
return true
