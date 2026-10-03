--========================================================--
--                    SYSXHUB CLIENT                      --
--========================================================--

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--========================================================--
-- CONFIG
--========================================================--

local CONFIG = {
    Name = "SysxHub",
    Version = "2.2",

    OpenCloseAsset = "rbxassetid://70792832229220",

    Discord = "https://discord.gg/E5kQJW3hn",

    DefaultScale = 0.90,
    MinScale = 0.75,
    MaxScale = 1,

    AutoAttackInterval = 0.12,
}

--========================================================--
-- REMOTE
--========================================================--

local Remotes = ReplicatedStorage:WaitForChild("SysxHubRemotes")
local CombatRemote = Remotes:WaitForChild("Combat")

--========================================================--
-- COLORS
--========================================================--

local C = {
    Background = Color3.fromRGB(12, 9, 20),
    Sidebar = Color3.fromRGB(18, 13, 30),
    Panel = Color3.fromRGB(24, 17, 39),
    Panel2 = Color3.fromRGB(32, 23, 51),

    Purple = Color3.fromRGB(139, 76, 255),
    PurpleDark = Color3.fromRGB(98, 53, 190),

    White = Color3.fromRGB(245, 242, 255),
    Gray = Color3.fromRGB(165, 158, 180),
    DarkGray = Color3.fromRGB(72, 66, 86),

    Green = Color3.fromRGB(70, 215, 125),
    Red = Color3.fromRGB(235, 75, 90),
    Yellow = Color3.fromRGB(245, 195, 75),
}

--========================================================--
-- STATE
--========================================================--

local State = {
    CurrentTab = "FARM",
    Scale = CONFIG.DefaultScale,
    Search = "",

    AutoAttack = false,

    Farm = {},
    Chest = {},
    Boss = {},
    Material = {},
    Sea = {},
    Quest = {},
    FruitRaid = {},
    Fishing = {},
    Status = {},
    PVP = {},
    Stats = {},
    Misc = {},
}

local Connections = {}

--========================================================--
-- HELPERS
--========================================================--

local function New(class, props, parent)
    local obj = Instance.new(class)

    for k, v in pairs(props or {}) do
        obj[k] = v
    end

    obj.Parent = parent
    return obj
end

local function Corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
end

local function Border(obj, color, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or C.Purple
    s.Transparency = transparency or 0
    s.Thickness = 1
    s.Parent = obj
end

local function Tween(obj, props, time)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(
            time or 0.2,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        props
    )

    t:Play()
    return t
end

local function Disconnect(name)
    if Connections[name] then
        Connections[name]:Disconnect()
        Connections[name] = nil
    end
end

--========================================================--
-- REMOVE OLD UI
--========================================================--

local old = PlayerGui:FindFirstChild("SysxHub")

if old then
    old:Destroy()
end

--========================================================--
-- SCREEN GUI
--========================================================--

local Gui = New("ScreenGui", {
    Name = "SysxHub",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

--========================================================--
-- NOTIFICATION
--========================================================--

local NotificationHolder = New("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -310, 0, 15),
    Size = UDim2.fromOffset(295, 400),
}, Gui)

New("UIListLayout", {
    Padding = UDim.new(0, 7),
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
}, NotificationHolder)

local function Notify(title, text, kind)
    local accent = C.Purple

    if kind == "SUCCESS" then
        accent = C.Green
    elseif kind == "WARNING" then
        accent = C.Yellow
    elseif kind == "ERROR" then
        accent = C.Red
    end

    local box = New("Frame", {
        Size = UDim2.fromOffset(285, 65),
        BackgroundColor3 = C.Panel,
    }, NotificationHolder)

    Corner(box, 9)
    Border(box, accent, 0.45)

    New("Frame", {
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 1, 0),
    }, box)

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(13, 7),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = C.White,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, box)

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(13, 28),
        Size = UDim2.new(1, -20, 0, 30),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = C.Gray,
        TextSize = 10,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, box)

    box.Position = UDim2.new(1, 30, 0, 0)

    Tween(box, {
        Position = UDim2.new(0, 0, 0, 0)
    }, 0.2)

    task.delay(3, function()
        if box.Parent then
            Tween(box, {
                Position = UDim2.new(1, 30, 0, 0)
            }, 0.2)

            task.wait(0.25)

            if box then
                box:Destroy()
            end
        end
    end)
end

--========================================================--
-- MAIN
--========================================================--

local Main = New("Frame", {
    Name = "MainWindow",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(760, 500),
    BackgroundColor3 = C.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, Gui)

Corner(Main, 14)
Border(Main, C.Purple, 0.55)

--========================================================--
-- TOPBAR
--========================================================--

local TopBar = New("Frame", {
    Size = UDim2.new(1, 0, 0, 62),
    BackgroundColor3 = C.Panel,
    BorderSizePixel = 0,
}, Main)

local Logo = New("ImageLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(10, 9),
    Size = UDim2.fromOffset(44, 44),
    Image = CONFIG.OpenCloseAsset,
    ScaleType = Enum.ScaleType.Fit,
}, TopBar)

New("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(64, 9),
    Size = UDim2.fromOffset(250, 23),
    Font = Enum.Font.GothamBold,
    Text = "SysxHub",
    TextColor3 = C.White,
    TextSize = 18,
    TextXAlignment = Enum.TextXAlignment.Left,
}, TopBar)

New("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(65, 33),
    Size = UDim2.fromOffset(250, 17),
    Font = Enum.Font.Gotham,
    Text = "Premium Control Panel  •  v" .. CONFIG.Version,
    TextColor3 = C.Gray,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
}, TopBar)

local Search = New("TextBox", {
    BackgroundColor3 = C.Panel2,
    Position = UDim2.new(1, -215, 0, 14),
    Size = UDim2.fromOffset(195, 34),
    Font = Enum.Font.Gotham,
    PlaceholderText = "Search Feature...",
    PlaceholderColor3 = C.Gray,
    Text = "",
    TextColor3 = C.White,
    TextSize = 10,
    ClearTextOnFocus = false,
}, TopBar)

Corner(Search, 8)
Border(Search, C.DarkGray, 0.5)

--========================================================--
-- SIDEBAR
--========================================================--

local Sidebar = New("Frame", {
    Position = UDim2.fromOffset(0, 62),
    Size = UDim2.new(0, 175, 1, -62),
    BackgroundColor3 = C.Sidebar,
    BorderSizePixel = 0,
}, Main)

local SidebarScroll = New("ScrollingFrame", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(8, 8),
    Size = UDim2.new(1, -16, 1, -16),
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = C.Purple,
}, Sidebar)

New("UIListLayout", {
    Padding = UDim.new(0, 5),
}, SidebarScroll)

--========================================================--
-- CONTENT
--========================================================--

local Content = New("Frame", {
    Position = UDim2.fromOffset(175, 62),
    Size = UDim2.new(1, -175, 1, -62),
    BackgroundColor3 = C.Background,
    BorderSizePixel = 0,
}, Main)

local ContentTitle = New("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(17, 11),
    Size = UDim2.new(1, -34, 0, 28),
    Font = Enum.Font.GothamBold,
    Text = "FARM",
    TextColor3 = C.White,
    TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left,
}, Content)

local FeatureScroll = New("ScrollingFrame", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(11, 45),
    Size = UDim2.new(1, -22, 1, -53),
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = C.Purple,
}, Content)

New("UIListLayout", {
    Padding = UDim.new(0, 7),
}, FeatureScroll)

--========================================================--
-- FLOATING OPEN/CLOSE
--========================================================--

local Floating = New("ImageButton", {
    BackgroundColor3 = C.Panel,
    Position = UDim2.new(0, 14, 0.5, -29),
    Size = UDim2.fromOffset(58, 58),
    Image = CONFIG.OpenCloseAsset,
    ScaleType = Enum.ScaleType.Fit,
    AutoButtonColor = false,
}, Gui)

Corner(Floating, 14)
Border(Floating, C.Purple, 0.4)

local Visible = true

Floating.MouseButton1Click:Connect(function()
    Visible = not Visible

    if Visible then
        Main.Visible = true
        Main.Size = UDim2.fromOffset(0, 0)

        Tween(Main, {
            Size = UDim2.fromOffset(
                760 * State.Scale,
                500 * State.Scale
            )
        }, 0.25)
    else
        local t = Tween(Main, {
            Size = UDim2.fromOffset(0, 0)
        }, 0.2)

        t.Completed:Connect(function()
            if not Visible then
                Main.Visible = false
            end
        end)
    end
end)

--========================================================--
-- DRAG
--========================================================--

local function Drag(object, handle)
    local dragging = false
    local startInput
    local startPosition

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            startInput = input.Position
            startPosition = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            local delta = input.Position - startInput

            object.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)
end

Drag(Main, TopBar)
Drag(Floating, Floating)

--========================================================--
-- UI COMPONENTS
--========================================================--

local function ClearFeatures()
    for _, child in ipairs(FeatureScroll:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end
end

local function Section(text)
    local label = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -5, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = text,
        TextColor3 = C.Purple,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, FeatureScroll)

    return label
end

local function Toggle(tab, name, callback)
    local holder = New("Frame", {
        Name = name,
        Size = UDim2.new(1, -5, 0, 47),
        BackgroundColor3 = C.Panel,
    }, FeatureScroll)

    Corner(holder, 9)

    New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(13, 0),
        Size = UDim2.new(1, -72, 1, 0),
        Font = Enum.Font.Gotham,
        Text = name,
        TextColor3 = C.White,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, holder)

    local button = New("TextButton", {
        BackgroundColor3 = C.DarkGray,
        Position = UDim2.new(1, -55, 0.5, -11),
        Size = UDim2.fromOffset(43, 22),
        Text = "",
        AutoButtonColor = false,
    }, holder)

    Corner(button, 12)

    local knob = New("Frame", {
        BackgroundColor3 = C.White,
        Position = UDim2.fromOffset(3, 3),
        Size = UDim2.fromOffset(16, 16),
    }, button)

    Corner(knob, 20)

    local state = false

    local function Update(value)
        state = value
        State[tab][name] = value

        if value then
            Tween(button, {
                BackgroundColor3 = C.Purple
            }, 0.12)

            Tween(knob, {
                Position = UDim2.new(1, -19, 0, 3)
            }, 0.12)
        else
            Tween(button, {
                BackgroundColor3 = C.DarkGray
            }, 0.12)

            Tween(knob, {
                Position = UDim2.fromOffset(3, 3)
            }, 0.12)
        end

        if callback then
            task.spawn(function()
                pcall(callback, value)
            end)
        end
    end

    button.MouseButton1Click:Connect(function()
        Update(not state)
    end)

    return holder
end

local function Button(name, callback)
    local b = New("TextButton", {
        Name = name,
        Size = UDim2.new(1, -5, 0, 43),
        BackgroundColor3 = C.Panel,
        Font = Enum.Font.Gotham,
        Text = name,
        TextColor3 = C.White,
        TextSize = 10,
        AutoButtonColor = false,
    }, FeatureScroll)

    Corner(b, 9)

    b.MouseEnter:Connect(function()
        Tween(b, {
            BackgroundColor3 = C.Panel2
        }, 0.1)
    end)

    b.MouseLeave:Connect(function()
        Tween(b, {
            BackgroundColor3 = C.Panel
        }, 0.1)
    end)

    b.MouseButton1Click:Connect(function()
        if callback then
            task.spawn(callback)
        end
    end)

    return b
end

local function Dropdown(tab, name, options, callback)
    local holder = New("Frame", {
        Name = name,
        Size = UDim2.new(1, -5, 0, 45),
        BackgroundColor3 = C.Panel,
        ClipsDescendants = true,
    }, FeatureScroll)

    Corner(holder, 9)

    local selected = options[1]

    local main = New("TextButton", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -20, 0, 45),
        Font = Enum.Font.Gotham,
        Text = name .. ": " .. tostring(selected),
        TextColor3 = C.White,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
    }, holder)

    local opened = false

    main.MouseButton1Click:Connect(function()
        opened = not opened

        if opened then
            holder.Size = UDim2.new(
                1, -5,
                0,
                math.min(45 + (#options * 32), 200)
            )
        else
            holder.Size = UDim2.new(1, -5, 0, 45)
        end
    end)

    for i, option in ipairs(options) do
        local optionButton = New("TextButton", {
            BackgroundColor3 = C.Panel2,
            Position = UDim2.new(0, 7, 0, 45 + ((i - 1) * 32)),
            Size = UDim2.new(1, -14, 0, 27),
            Font = Enum.Font.Gotham,
            Text = tostring(option),
            TextColor3 = C.Gray,
            TextSize = 9,
            AutoButtonColor = false,
        }, holder)

        Corner(optionButton, 6)

        optionButton.MouseButton1Click:Connect(function()
            selected = option
            main.Text = name .. ": " .. tostring(option)

            opened = false
            holder.Size = UDim2.new(1, -5, 0, 45)

            State[tab][name] = option

            if callback then
                callback(option)
            end
        end)
    end
end

local function Slider(tab, name, min, max, default, callback)
    local holder = New("Frame", {
        Name = name,
        Size = UDim2.new(1, -5, 0, 62),
        BackgroundColor3 = C.Panel,
    }, FeatureScroll)

    Corner(holder, 9)

    local value = default

    local label = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 7),
        Size = UDim2.new(1, -24, 0, 18),
        Font = Enum.Font.Gotham,
        Text = name .. " : " .. tostring(value),
        TextColor3 = C.White,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, holder)

    local bar = New("Frame", {
        BackgroundColor3 = C.DarkGray,
        Position = UDim2.fromOffset(12, 38),
        Size = UDim2.new(1, -24, 0, 6),
    }, holder)

    Corner(bar, 6)

    local fill = New("Frame", {
        BackgroundColor3 = C.Purple,
        Size = UDim2.new(
            (value - min) / (max - min),
            0,
            1,
            0
        ),
    }, bar)

    Corner(fill, 6)

    local dragging = false

    local function SetValue(x)
        local percent = math.clamp(
            (x - bar.AbsolutePosition.X) /
            math.max(bar.AbsoluteSize.X, 1),
            0,
            1
        )

        value = math.floor(
            min + ((max - min) * percent)
        )

        fill.Size = UDim2.new(percent, 0, 1, 0)
        label.Text = name .. " : " .. tostring(value)

        State[tab][name] = value

        if callback then
            callback(value)
        end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            SetValue(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            SetValue(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = false
        end
    end)
end

--========================================================--
-- TABS
--========================================================--

local Tabs = {
    "FARM",
    "SEA",
    "QUESTS / ITEMS",
    "FRUIT / RAID",
    "FISHING",
    "STATUS",
    "PVP",
    "STATS",
    "MISC",
}

local TabButtons = {}

local RenderTab

for _, tabName in ipairs(Tabs) do
    local b = New("TextButton", {
        Name = tabName,
        Size = UDim2.new(1, 0, 0, 37),
        BackgroundColor3 = C.Sidebar,
        Font = Enum.Font.Gotham,
        Text = tabName,
        TextColor3 = C.Gray,
        TextSize = 9,
        AutoButtonColor = false,
    }, SidebarScroll)

    Corner(b, 8)

    TabButtons[tabName] = b

    b.MouseButton1Click:Connect(function()
        State.CurrentTab = tabName

        for name, button in pairs(TabButtons) do
            if name == tabName then
                Tween(button, {
                    BackgroundColor3 = C.PurpleDark,
                    TextColor3 = C.White
                }, 0.12)
            else
                Tween(button, {
                    BackgroundColor3 = C.Sidebar,
                    TextColor3 = C.Gray
                }, 0.12)
            end
        end

        RenderTab(tabName)
    end)
end

--========================================================--
-- MOON
--========================================================--

local function MoonPhase()
    local day = tonumber(os.date("%d")) or 1

    local phases = {
        "New Moon",
        "Waxing Crescent",
        "First Quarter",
        "Waxing Gibbous",
        "Full Moon",
        "Waning Gibbous",
        "Last Quarter",
        "Waning Crescent",
    }

    return phases[((day - 1) % #phases) + 1]
end

--========================================================--
-- RENDER TAB
--========================================================--

RenderTab = function(tab)
    ClearFeatures()

    ContentTitle.Text = tab

    if tab == "FARM" then

        Section("FARM")

        Dropdown(
            "Farm",
            "Select Tool",
            {
                "Melee",
                "Sword",
                "Gun",
                "Blox Fruit"
            }
        )

        Toggle("Farm", "Auto Farm Level")
        Toggle("Farm", "Auto Farm Nearest")
        Toggle("Farm", "Auto Accept Quest")
        Toggle("Farm", "Auto Quest Combat")
        Toggle("Farm", "Auto Haki")
        Toggle("Farm", "Auto Ken")

        --================================================--
        -- AUTO ATTACK
        --================================================--

        Toggle("Farm", "Auto Attack", function(enabled)

            State.AutoAttack = enabled

            if enabled then

                CombatRemote:FireServer(
                    "StartAutoAttack",
                    {
                        Range = 12,
                        Width = 8,
                        Height = 8,
                        Interval = CONFIG.AutoAttackInterval,
                    }
                )

                Notify(
                    "AUTO ATTACK",
                    "Invisible hitbox enabled.",
                    "SUCCESS"
                )

            else

                CombatRemote:FireServer(
                    "StopAutoAttack"
                )

                Notify(
                    "AUTO ATTACK",
                    "Auto Attack stopped.",
                    "INFO"
                )
            end
        end)

        Section("CHEST")

        Toggle(
            "Chest",
            "Auto Chest [Tween]"
        )

        Toggle(
            "Chest",
            "Stop When Get Item in Chest"
        )

        Section("BOSS")

        Button(
            "Update Boss List",
            function()
                Notify(
                    "BOSS",
                    "Boss list updated.",
                    "SUCCESS"
                )
            end
        )

        Dropdown(
            "Boss",
            "Select Boss",
            {
                "Boss 1",
                "Boss 2",
                "Boss 3",
                "Boss 4",
                "Boss 5",
            }
        )

        Toggle("Boss", "Auto Kill Selected Boss")
        Toggle("Boss", "Auto Farm All Bosses")
        Toggle("Boss", "Take Boss Quest")

        Section("MATERIAL")

        Dropdown(
            "Material",
            "Select Material",
            {
                "Bones",
                "Leather",
                "Scrap Metal",
                "Angel Wings",
                "Fish Tail",
                "Mystic Droplet",
                "Gunpowder",
                "Demonic Wisp",
            }
        )

        Toggle("Material", "Auto Farm Material")

        Section("UI")

        Dropdown(
            "Farm",
            "UI Scale",
            {
                "75%",
                "85%",
                "90%",
                "100%"
            },
            function(value)

                local number =
                    tonumber(
                        string.gsub(value, "%%", "")
                    )

                if number then
                    State.Scale =
                        math.clamp(
                            number / 100,
                            CONFIG.MinScale,
                            CONFIG.MaxScale
                        )

                    Main.Size = UDim2.fromOffset(
                        760 * State.Scale,
                        500 * State.Scale
                    )
                end
            end
        )

    elseif tab == "SEA" then

        Section("SEA")

        Dropdown(
            "Sea",
            "Enemies",
            {
                "Sea Enemy",
                "Sea Beast",
                "Shark",
                "Terrorshark"
            }
        )

        Toggle("Sea", "Auto Farm Sea")
        Toggle("Sea", "Auto Destroy Boats")
        Toggle("Sea", "Buy Boat for Sea Farm")
        Toggle("Sea", "Auto No-Clip Boat")
        Toggle("Sea", "Auto Destroy Rocks")

        Section("BOAT SETTINGS")

        Slider(
            "Sea",
            "Boat Height",
            0,
            200,
            50
        )

        Slider(
            "Sea",
            "Boat Speed",
            10,
            300,
            100
        )

    elseif tab == "QUESTS / ITEMS" then

        Section("QUEST")

        Dropdown(
            "Quest",
            "Island",
            {
                "Starter Island",
                "Desert",
                "Frozen Village",
                "Marine Fortress",
                "Skylands",
                "Fontain City"
            }
        )

        Button(
            "Start Secret Quest",
            function()
                Notify(
                    "QUEST",
                    "Secret Quest requested.",
                    "INFO"
                )
            end
        )

        Toggle("Quest", "Auto Get Yama")
        Toggle("Quest", "Auto Get Tushita")
        Toggle("Quest", "Auto Get Buddy Sword")
        Toggle("Quest", "Auto Get Soul Guitar")
        Toggle("Quest", "Kill Cake Prince")
        Toggle("Quest", "Auto Spawn & Kill Indra")
        Toggle("Quest", "Auto Spawn Dough King")
        Toggle("Quest", "Auto Get Hallow Scythe")

    elseif tab == "FRUIT / RAID" then

        Section("RAID")

        Dropdown(
            "FruitRaid",
            "Select Chip",
            {
                "Flame",
                "Ice",
                "Light",
                "Dark",
                "Magma",
                "Dough"
            }
        )

        Toggle("FruitRaid", "Start Raid")
        Toggle("FruitRaid", "AutoKillRaid")

        Section("FRUIT")

        Dropdown(
            "FruitRaid",
            "Select Fruit",
            {
                "Rocket",
                "Spin",
                "Chop",
                "Spring",
                "Bomb",
                "Smoke",
                "Flame",
                "Ice",
                "Light",
                "Magma",
                "Dough"
            }
        )

        Toggle("FruitRaid", "Auto Buy Select Fruit")
        Toggle("FruitRaid", "Rolled Fruit")
        Toggle("FruitRaid", "Auto Store Fruit")

    elseif tab == "FISHING" then

        Section("FISHING")

        Toggle("Fishing", "Auto Fish")
        Toggle("Fishing", "Auto Cast")

    elseif tab == "STATUS" then

        Section("STATUS")

        Button(
            "Fruit Spawn: Checking...",
            function()
                Notify(
                    "STATUS",
                    "Fruit status requested.",
                    "INFO"
                )
            end
        )

        Toggle(
            "Status",
            "Check Entire Map"
        )

        local timeButton = Button(
            "Server Time: " ..
            os.date("%H:%M:%S")
        )

        local moonButton = Button(
            "Phase Moon: " ..
            MoonPhase(),
            function()
                Notify(
                    "MOON",
                    "Phase: " .. MoonPhase(),
                    "INFO"
                )
            end
        )

        task.spawn(function()

            while
                timeButton.Parent
                and State.CurrentTab == "STATUS"
            do

                timeButton.Text =
                    "Server Time: " ..
                    os.date("%H:%M:%S")

                moonButton.Text =
                    "Phase Moon: " ..
                    MoonPhase()

                task.wait(1)
            end

        end)

    elseif tab == "PVP" then

        Section("PVP")

        Dropdown(
            "PVP",
            "Select Player",
            {
                "Player 1",
                "Player 2",
                "Player 3"
            }
        )

        Toggle("PVP", "Aimbot")
        Toggle("PVP", "Teleport to Player")
        Toggle("PVP", "Auto Skill")

    elseif tab == "STATS" then

        Section("STATS")

        Toggle("Stats", "Start Add Stats")

        Slider("Stats", "Melee", 0, 100, 0)
        Slider("Stats", "Sword", 0, 100, 0)
        Slider("Stats", "Gun", 0, 100, 0)
        Slider("Stats", "Defense", 0, 100, 0)
        Slider("Stats", "Blox Fruit", 0, 100, 0)

    elseif tab == "MISC" then

        Section("MISC")

        Button(
            "Job ID: " .. game.JobId
        )

        Button(
            "Copy Job ID",
            function()
                Notify(
                    "JOB ID",
                    "Job ID: " .. game.JobId,
                    "INFO"
                )
            end
        )

        Button(
            "Join Job ID",
            function()
                Notify(
                    "JOB ID",
                    "Join Job ID membutuhkan handler server.",
                    "INFO"
                )
            end
        )

        Button(
            "Redeem All Code",
            function()
                Notify(
                    "CODE",
                    "Redeem request sent.",
                    "INFO"
                )
            end
        )

        Toggle("Misc", "Anti AFK")
        Toggle("Misc", "No Clip")
        Toggle("Misc", "Infinite Jump")

        Button(
            "Join Discord",
            function()
                Notify(
                    "DISCORD",
                    CONFIG.Discord,
                    "INFO"
                )
            end
        )
    end
end

--========================================================--
-- SEARCH
--========================================================--

Search:GetPropertyChangedSignal("Text"):Connect(function()

    State.Search = string.lower(Search.Text)

    for _, child in ipairs(FeatureScroll:GetChildren()) do

        if child:IsA("GuiObject") then

            if State.Search == "" then
                child.Visible = true
            else

                local text = string.lower(child.Name)

                local label =
                    child:FindFirstChildOfClass("TextLabel")

                local button =
                    child:FindFirstChildOfClass("TextButton")

                if label then
                    text = text .. " " ..
                        string.lower(label.Text)
                end

                if button then
                    text = text .. " " ..
                        string.lower(button.Text)
                end

                child.Visible =
                    string.find(
                        text,
                        State.Search,
                        1,
                        true
                    ) ~= nil
            end
        end
    end
end)

--========================================================--
-- AUTO ATTACK CLEANUP
--========================================================--

Player.CharacterRemoving:Connect(function()
    if State.AutoAttack then
        CombatRemote:FireServer(
            "StopAutoAttack"
        )

        State.AutoAttack = false
    end
end)

--========================================================--
-- INITIAL
--========================================================--

RenderTab("FARM")

TabButtons["FARM"].BackgroundColor3 =
    C.PurpleDark

TabButtons["FARM"].TextColor3 =
    C.White

Notify(
    "SysxHub",
    "SysxHub berhasil dimuat.",
    "SUCCESS"
)
