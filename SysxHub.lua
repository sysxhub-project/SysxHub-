--========================================================--
--                    SYSXHUB v2.2                        --
--                 UI FIXED / MOBILE SAFE                 --
--========================================================--

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--========================================================--
-- CONFIG
--========================================================--

local CONFIG = {
    Name = "SysxHub",
    Version = "2.2",

    Logo = "rbxassetid://136425814447688",
    OpenClose = "rbxassetid://70792832229220",

    Width = 720,
    Height = 500,

    MobileWidth = 600,
    MobileHeight = 430,

    MinScale = 0.75,
    MaxScale = 1,

    Discord = "https://discord.gg/E5kQJW3hn",
}

--========================================================--
-- THEME
--========================================================--

local THEME = {
    BG = Color3.fromRGB(11, 7, 18),
    BG2 = Color3.fromRGB(18, 11, 29),

    PANEL = Color3.fromRGB(26, 16, 39),
    PANEL2 = Color3.fromRGB(35, 22, 52),

    PURPLE = Color3.fromRGB(137, 69, 220),
    PURPLE2 = Color3.fromRGB(170, 91, 245),

    TEXT = Color3.fromRGB(245, 240, 250),
    MUTED = Color3.fromRGB(165, 153, 180),

    SUCCESS = Color3.fromRGB(75, 210, 125),
    WARNING = Color3.fromRGB(235, 190, 70),
    ERROR = Color3.fromRGB(225, 75, 100),
}

--========================================================--
-- STATE
--========================================================--

local State = {
    Tab = "FARM",
    Scale = 0.90,

    AutoAttack = false,

    Tool = "Melee",
    Boss = "None",
    Material = "None",
    SeaEnemy = "None",
    Fruit = "None",
    Chip = "None",
    Player = "None",

    Toggles = {},
}

--========================================================--
-- SAFE REMOTE
--========================================================--

local CombatRemote

pcall(function()
    local folder = ReplicatedStorage:FindFirstChild("SysxHubRemotes")

    if folder then
        CombatRemote = folder:FindFirstChild("Combat")
    end
end)

local function FireCombat(...)
    if not CombatRemote then
        return false
    end

    local ok = pcall(function()
        CombatRemote:FireServer(...)
    end)

    return ok
end

--========================================================--
-- REMOVE OLD UI
--========================================================--

pcall(function()
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui.Name == "SysxHub"
            or gui.Name:match("^SysxHub_") then

            gui:Destroy()
        end
    end
end)

--========================================================--
-- HELPERS
--========================================================--

local function New(className, properties, parent)

    local object = Instance.new(className)

    for property, value in pairs(properties or {}) do
        pcall(function()
            object[property] = value
        end)
    end

    object.Parent = parent

    return object
end

local function Corner(object, radius)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = object

    return corner
end

local function Stroke(object, color, transparency)

    local stroke = Instance.new("UIStroke")

    stroke.Color =
        color or THEME.PURPLE

    stroke.Transparency =
        transparency or 0

    stroke.Thickness = 1

    stroke.Parent = object

    return stroke
end

local function Tween(object, properties, duration)

    local tween =
        TweenService:Create(
            object,

            TweenInfo.new(
                duration or 0.2,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ),

            properties
        )

    tween:Play()

    return tween
end

--========================================================--
-- SCREEN GUI
--========================================================--

local Gui = New("ScreenGui", {
    Name = "SysxHub",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

--========================================================--
-- MAIN
--========================================================--

local isMobile =
    UserInputService.TouchEnabled

local baseWidth =
    isMobile
        and CONFIG.MobileWidth
        or CONFIG.Width

local baseHeight =
    isMobile
        and CONFIG.MobileHeight
        or CONFIG.Height

local Main = New("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),

    Position =
        UDim2.fromScale(0.5, 0.5),

    Size =
        UDim2.fromOffset(
            baseWidth,
            baseHeight
        ),

    BackgroundColor3 =
        THEME.BG,

    BorderSizePixel = 0,

    ClipsDescendants = true,

    Active = true,
}, Gui)

Corner(Main, 14)
Stroke(Main, THEME.PURPLE, 0.55)

local UIScale =
    New("UIScale", {
        Scale = State.Scale
    }, Main)

--========================================================--
-- HEADER
--========================================================--

local Header = New("Frame", {
    Name = "Header",

    Size =
        UDim2.new(1, 0, 0, 58),

    BackgroundColor3 =
        THEME.BG2,

    BorderSizePixel = 0,

    Active = true,
}, Main)

Corner(Header, 14)

local Logo = New("ImageLabel", {
    Name = "Logo",

    BackgroundTransparency = 1,

    Image =
        CONFIG.Logo,

    Size =
        UDim2.fromOffset(42, 42),

    Position =
        UDim2.fromOffset(10, 8),

    ScaleType =
        Enum.ScaleType.Fit,
}, Header)

local Title = New("TextLabel", {
    BackgroundTransparency = 1,

    Text =
        CONFIG.Name,

    Font =
        Enum.Font.GothamBold,

    TextSize = 19,

    TextColor3 =
        THEME.TEXT,

    TextXAlignment =
        Enum.TextXAlignment.Left,

    Position =
        UDim2.fromOffset(61, 7),

    Size =
        UDim2.fromOffset(240, 25),
}, Header)

New("TextLabel", {
    BackgroundTransparency = 1,

    Text =
        "Premium Control Panel  •  v" ..
        CONFIG.Version,

    Font =
        Enum.Font.Gotham,

    TextSize = 9,

    TextColor3 =
        THEME.MUTED,

    TextXAlignment =
        Enum.TextXAlignment.Left,

    Position =
        UDim2.fromOffset(62, 31),

    Size =
        UDim2.fromOffset(250, 18),
}, Header)

--========================================================--
-- HEADER BUTTONS
--========================================================--

local function HeaderButton(
    text,
    offset,
    color
)

    local button =
        New("TextButton", {

            BackgroundColor3 =
                color or THEME.PANEL2,

            BorderSizePixel = 0,

            Text = text,

            TextColor3 =
                THEME.TEXT,

            Font =
                Enum.Font.GothamBold,

            TextSize = 14,

            AutoButtonColor = false,

            Size =
                UDim2.fromOffset(32, 30),

            Position =
                UDim2.new(
                    1,
                    offset,
                    0.5,
                    -15
                ),

        }, Header)

    Corner(button, 7)

    return button
end

local ScaleButton =
    HeaderButton("◱", -108)

local MinButton =
    HeaderButton("—", -72)

local CloseButton =
    HeaderButton(
        "×",
        -36,
        THEME.ERROR
    )

--========================================================--
-- SIDEBAR
--========================================================--

local Sidebar = New("Frame", {

    Name = "Sidebar",

    Position =
        UDim2.fromOffset(
            0,
            58
        ),

    Size =
        UDim2.new(
            0,
            170,
            1,
            -58
        ),

    BackgroundColor3 =
        THEME.BG2,

    BorderSizePixel = 0,

}, Main)

-- BRAND
local SideBrand =
    New("Frame", {

        BackgroundColor3 =
            THEME.BG,

        BorderSizePixel = 0,

        Position =
            UDim2.fromOffset(7, 7),

        Size =
            UDim2.new(
                1,
                -14,
                0,
                70
            ),

    }, Sidebar)

Corner(SideBrand, 9)

New("ImageLabel", {

    BackgroundTransparency = 1,

    Image =
        CONFIG.Logo,

    Size =
        UDim2.fromOffset(42, 42),

    Position =
        UDim2.new(
            0.5,
            -21,
            0,
            4
        ),

    ScaleType =
        Enum.ScaleType.Fit,

}, SideBrand)

New("TextLabel", {

    BackgroundTransparency = 1,

    Text =
        "SYSX HUB",

    Font =
        Enum.Font.GothamBold,

    TextSize = 10,

    TextColor3 =
        THEME.TEXT,

    Position =
        UDim2.new(
            0,
            0,
            0,
            46
        ),

    Size =
        UDim2.new(
            1,
            0,
            0,
            18
        ),

}, SideBrand)

-- TAB SCROLL
local TabScroll =
    New("ScrollingFrame", {

        Name = "Tabs",

        BackgroundTransparency = 1,

        BorderSizePixel = 0,

        Position =
            UDim2.fromOffset(
                6,
                84
            ),

        Size =
            UDim2.new(
                1,
                -12,
                1,
                -90
            ),

        CanvasSize =
            UDim2.new(),

        AutomaticCanvasSize =
            Enum.AutomaticSize.Y,

        ScrollBarThickness = 2,

        ScrollBarImageColor3 =
            THEME.PURPLE,

    }, Sidebar)

New("UIListLayout", {
    Padding =
        UDim.new(0, 5),

    SortOrder =
        Enum.SortOrder.LayoutOrder,
}, TabScroll)

--========================================================--
-- CONTENT
--========================================================--

local Content =
    New("Frame", {

        Name = "Content",

        Position =
            UDim2.fromOffset(
                170,
                58
            ),

        Size =
            UDim2.new(
                1,
                -170,
                1,
                -58
            ),

        BackgroundColor3 =
            THEME.BG,

        BorderSizePixel = 0,

    }, Main)

-- SEARCH
local Search =
    New("TextBox", {

        Name = "Search",

        BackgroundColor3 =
            THEME.BG2,

        BorderSizePixel = 0,

        Position =
            UDim2.fromOffset(
                10,
                10
            ),

        Size =
            UDim2.new(
                1,
                -20,
                0,
                34
            ),

        PlaceholderText =
            "Search Feature...",

        PlaceholderColor3 =
            THEME.MUTED,

        TextColor3 =
            THEME.TEXT,

        Text = "",

        Font =
            Enum.Font.Gotham,

        TextSize = 10,

        ClearTextOnFocus = false,

        TextXAlignment =
            Enum.TextXAlignment.Left,

    }, Content)

Corner(Search, 8)
Stroke(Search, THEME.PANEL2)

local SearchPadding =
    New("UIPadding", {
        PaddingLeft =
            UDim.new(0, 10),

        PaddingRight =
            UDim.new(0, 10),
    }, Search)

-- FEATURE LIST
local FeatureScroll =
    New("ScrollingFrame", {

        Name = "Features",

        BackgroundTransparency = 1,

        BorderSizePixel = 0,

        Position =
            UDim2.fromOffset(
                8,
                52
            ),

        Size =
            UDim2.new(
                1,
                -16,
                1,
                -58
            ),

        CanvasSize =
            UDim2.new(),

        AutomaticCanvasSize =
            Enum.AutomaticSize.Y,

        ScrollBarThickness = 3,

        ScrollBarImageColor3 =
            THEME.PURPLE,

    }, Content)

New("UIListLayout", {

    Padding =
        UDim.new(0, 6),

    SortOrder =
        Enum.SortOrder.LayoutOrder,

}, FeatureScroll)

--========================================================--
-- NOTIFICATIONS
--========================================================--

local NotificationHolder =
    New("Frame", {

        BackgroundTransparency = 1,

        Position =
            UDim2.new(
                1,
                -310,
                0,
                70
            ),

        Size =
            UDim2.fromOffset(
                300,
                400
            ),

        ZIndex = 100,

    }, Gui)

New("UIListLayout", {

    Padding =
        UDim.new(0, 6),

    HorizontalAlignment =
        Enum.HorizontalAlignment.Right,

}, NotificationHolder)

local function Notify(
    kind,
    title,
    message
)

    local color =
        THEME.PURPLE2

    if kind == "SUCCESS" then
        color = THEME.SUCCESS

    elseif kind == "WARNING" then
        color = THEME.WARNING

    elseif kind == "ERROR" then
        color = THEME.ERROR
    end

    local card =
        New("Frame", {

            BackgroundColor3 =
                THEME.PANEL,

            Size =
                UDim2.fromOffset(
                    285,
                    60
                ),

            BackgroundTransparency = 0,

        }, NotificationHolder)

    Corner(card, 9)
    Stroke(card, color)

    New("TextLabel", {

        BackgroundTransparency = 1,

        Text = title,

        Font =
            Enum.Font.GothamBold,

        TextSize = 12,

        TextColor3 =
            THEME.TEXT,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        Position =
            UDim2.fromOffset(
                13,
                7
            ),

        Size =
            UDim2.new(
                1,
                -20,
                0,
                18
            ),

    }, card)

    New("TextLabel", {

        BackgroundTransparency = 1,

        Text = message,

        Font =
            Enum.Font.Gotham,

        TextSize = 10,

        TextColor3 =
            THEME.MUTED,

        TextWrapped = true,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        Position =
            UDim2.fromOffset(
                13,
                27
            ),

        Size =
            UDim2.new(
                1,
                -20,
                0,
                26
            ),

    }, card)

    task.delay(3, function()

        if card.Parent then

            Tween(
                card,
                {
                    BackgroundTransparency = 1
                },
                0.2
            )

            task.wait(0.25)

            if card then
                card:Destroy()
            end
        end
    end)
end

--========================================================--
-- COMPONENTS
--========================================================--

local function ClearFeatures()

    for _, object in ipairs(
        FeatureScroll:GetChildren()
    ) do

        if object:IsA("GuiObject") then
            object:Destroy()
        end

    end
end

local function Section(text)

    local label =
        New("TextLabel", {

            BackgroundTransparency = 1,

            Text =
                "▸ " .. text,

            Font =
                Enum.Font.GothamBold,

            TextSize = 11,

            TextColor3 =
                THEME.PURPLE2,

            TextXAlignment =
                Enum.TextXAlignment.Left,

            Size =
                UDim2.new(
                    1,
                    -8,
                    0,
                    24
                ),

        }, FeatureScroll)

    return label
end

local function Button(
    text,
    callback
)

    local button =
        New("TextButton", {

            BackgroundColor3 =
                THEME.PANEL,

            BorderSizePixel = 0,

            Text = text,

            TextColor3 =
                THEME.TEXT,

            Font =
                Enum.Font.GothamMedium,

            TextSize = 10,

            AutoButtonColor = false,

            Size =
                UDim2.new(
                    1,
                    -8,
                    0,
                    40
                ),

        }, FeatureScroll)

    Corner(button, 8)
    Stroke(button, THEME.PANEL2)

    button.MouseEnter:Connect(function()

        Tween(
            button,
            {
                BackgroundColor3 =
                    THEME.PANEL2
            },
            0.1
        )

    end)

    button.MouseLeave:Connect(function()

        Tween(
            button,
            {
                BackgroundColor3 =
                    THEME.PANEL
            },
            0.1
        )

    end)

    button.MouseButton1Click:Connect(function()

        if callback then
            pcall(callback)
        end

    end)

    return button
end

local function Toggle(
    name,
    key,
    callback
)

    local row =
        New("Frame", {

            BackgroundColor3 =
                THEME.PANEL,

            BorderSizePixel = 0,

            Size =
                UDim2.new(
                    1,
                    -8,
                    0,
                    42
                ),

        }, FeatureScroll)

    Corner(row, 8)
    Stroke(row, THEME.PANEL2)

    New("TextLabel", {

        BackgroundTransparency = 1,

        Text = name,

        Font =
            Enum.Font.GothamMedium,

        TextSize = 10,

        TextColor3 =
            THEME.TEXT,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        Position =
            UDim2.fromOffset(
                12,
                0
            ),

        Size =
            UDim2.new(
                1,
                -80,
                1,
                0
            ),

    }, row)

    local enabled =
        State.Toggles[key] == true

    local switch =
        New("TextButton", {

            BackgroundColor3 =
                enabled
                    and THEME.PURPLE
                    or THEME.BG2,

            BorderSizePixel = 0,

            Text = "",

            AutoButtonColor = false,

            Position =
                UDim2.new(
                    1,
                    -58,
                    0.5,
                    -11
                ),

            Size =
                UDim2.fromOffset(
                    46,
                    22
                ),

        }, row)

    Corner(switch, 11)

    local knob =
        New("Frame", {

            BackgroundColor3 =
                THEME.TEXT,

            BorderSizePixel = 0,

            Position =
                enabled
                    and UDim2.new(
                        1,
                        -20,
                        0.5,
                        -9
                    )
                    or UDim2.new(
                        0,
                        2,
                        0.5,
                        -9
                    ),

            Size =
                UDim2.fromOffset(
                    18,
                    18
                ),

        }, switch)

    Corner(knob, 9)

    switch.MouseButton1Click:Connect(function()

        enabled = not enabled

        State.Toggles[key] =
            enabled

        Tween(
            switch,
            {
                BackgroundColor3 =
                    enabled
                        and THEME.PURPLE
                        or THEME.BG2
            },
            0.15
        )

        Tween(
            knob,
            {
                Position =
                    enabled
                        and UDim2.new(
                            1,
                            -20,
                            0.5,
                            -9
                        )
                        or UDim2.new(
                            0,
                            2,
                            0.5,
                            -9
                        )
            },
            0.15
        )

        if callback then
            pcall(
                callback,
                enabled
            )
        end

    end)

    return row
end

local function Dropdown(
    name,
    options,
    callback
)

    local row =
        New("Frame", {

            BackgroundColor3 =
                THEME.PANEL,

            BorderSizePixel = 0,

            Size =
                UDim2.new(
                    1,
                    -8,
                    0,
                    42
                ),

            ClipsDescendants = true,

        }, FeatureScroll)

    Corner(row, 8)
    Stroke(row, THEME.PANEL2)

    local selected =
        options[1] or "None"

    local main =
        New("TextButton", {

            BackgroundTransparency = 1,

            Text =
                "  " ..
                name ..
                ": " ..
                tostring(selected),

            TextColor3 =
                THEME.TEXT,

            Font =
                Enum.Font.GothamMedium,

            TextSize = 10,

            TextXAlignment =
                Enum.TextXAlignment.Left,

            AutoButtonColor = false,

            Size =
                UDim2.new(
                    1,
                    0,
                    0,
                    42
                ),

        }, row)

    local list =
        New("Frame", {

            BackgroundColor3 =
                THEME.BG2,

            BorderSizePixel = 0,

            Position =
                UDim2.fromOffset(
                    6,
                    44
                ),

            Size =
                UDim2.new(
                    1,
                    -12,
                    0,
                    0
                ),

        }, row)

    Corner(list, 6)

    New("UIListLayout", {

        Padding =
            UDim.new(
                0,
                2
            ),

    }, list)

    local open = false

    for _, option in ipairs(options) do

        local item =
            New("TextButton", {

                BackgroundColor3 =
                    THEME.PANEL,

                BorderSizePixel = 0,

                Text =
                    "  " ..
                    tostring(option),

                TextColor3 =
                    THEME.TEXT,

                Font =
                    Enum.Font.Gotham,

                TextSize = 9,

                TextXAlignment =
                    Enum.TextXAlignment.Left,

                AutoButtonColor = false,

                Size =
                    UDim2.new(
                        1,
                        -8,
                        0,
                        27
                    ),

            }, list)

        Corner(item, 5)

        item.MouseButton1Click:Connect(function()

            selected = option

            main.Text =
                "  " ..
                name ..
                ": " ..
                tostring(option)

            open = false

            row.Size =
                UDim2.new(
                    1,
                    -8,
                    0,
                    42
                )

            list.Size =
                UDim2.new(
                    1,
                    -12,
                    0,
                    0
                )

            if callback then
                pcall(
                    callback,
                    option
                )
            end

        end)
    end

    main.MouseButton1Click:Connect(function()

        open = not open

        local height =
            math.min(
                #options * 29 + 6,
                180
            )

        row.Size =
            UDim2.new(
                1,
                -8,
                0,
                open
                    and 48 + height
                    or 42
            )

        list.Size =
            UDim2.new(
                1,
                -12,
                0,
                open
                    and height
                    or 0
            )

    end)

    return row
end

--========================================================--
-- TAB DATA
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

--========================================================--
-- RENDER
--========================================================--

local RenderTab

RenderTab = function(tab)

    State.Tab = tab

    ClearFeatures()

    if tab == "FARM" then

        Section("FARM")

        Dropdown(
            "Select Tool",
            {
                "Melee",
                "Sword",
                "Gun",
                "Blox Fruit"
            },
            function(value)

                State.Tool = value

            end
        )

        Dropdown(
            "UI Scale",
            {
                "75%",
                "85%",
                "90%",
                "100%"
            },
            function(value)

                local n =
                    tonumber(
                        value:gsub("%%", "")
                    )

                State.Scale =
                    n / 100

                UIScale.Scale =
                    State.Scale

            end
        )

        Toggle(
            "Auto Farm Level",
            "FarmLevel"
        )

        Toggle(
            "Auto Farm Nearest",
            "FarmNearest"
        )

        Toggle(
            "Auto Factory",
            "Factory"
        )

        Toggle(
            "Auto Farm Ectoplasm",
            "Ectoplasm"
        )

        Section("CHEST")

        Toggle(
            "Auto Chest [Tween]",
            "Chest"
        )

        Toggle(
            "Stop When Get Item in Chest",
            "ChestStop"
        )

        Section("BOSS")

        Button(
            "Update Boss List",
            function()

                Notify(
                    "SUCCESS",
                    "Boss",
                    "Boss list updated."
                )

            end
        )

        Dropdown(
            "Select Boss",
            {
                "Boss 1",
                "Boss 2",
                "Boss 3",
                "Boss 4",
                "Boss 5"
            },
            function(value)

                State.Boss =
                    value

            end
        )

        Toggle(
            "Auto Kill Selected Boss",
            "BossKill"
        )

        Toggle(
            "Auto Farm All Bosses",
            "BossAll"
        )

        Toggle(
            "Take Boss Quest",
            "BossQuest"
        )

        Section("MATERIAL")

        Dropdown(
            "Select Material",
            {
                "Bones",
                "Leather",
                "Scrap Metal",
                "Fish Tail",
                "Mystic Droplet",
                "Gunpowder",
                "Demonic Wisp"
            },
            function(value)

                State.Material =
                    value

            end
        )

        Toggle(
            "Auto Farm Material",
            "Material"
        )

        Section("COMBAT")

        Toggle(
            "Auto Haki",
            "Haki"
        )

        Toggle(
            "Auto Ken",
            "Ken"
        )

        Toggle(
            "Auto Attack",
            "AutoAttack",
            function(enabled)

                State.AutoAttack =
                    enabled

                if enabled then

                    FireCombat(
                        "StartAutoAttack",
                        {
                            Range = 12,
                            Width = 8,
                            Height = 8,
                            Interval = 0.12
                        }
                    )

                    Notify(
                        "SUCCESS",
                        "Auto Attack",
                        "Invisible hitbox ON."
                    )

                else

                    FireCombat(
                        "StopAutoAttack"
                    )

                    Notify(
                        "INFO",
                        "Auto Attack",
                        "OFF."
                    )

                end

            end
        )

    elseif tab == "SEA" then

        Section("SEA")

        Dropdown(
            "Enemies",
            {
                "Sea Enemy",
                "Sea Beast",
                "Shark",
                "Terrorshark"
            }
        )

        Toggle(
            "Auto Farm Sea",
            "SeaFarm"
        )

        Toggle(
            "Auto Destroy Boats",
            "DestroyBoats"
        )

        Toggle(
            "Buy Boat for Sea Farm",
            "BuyBoat"
        )

        Toggle(
            "Auto No-Clip Boat",
            "BoatNoClip"
        )

        Toggle(
            "Auto Destroy Rocks",
            "DestroyRocks"
        )

        Section("BOAT SETTINGS")

        Button(
            "Boat Height: 50",
            function() end
        )

        Button(
            "Boat Speed: 100",
            function() end
        )

    elseif tab == "QUESTS / ITEMS" then

        Section("QUEST")

        Dropdown(
            "Island",
            {
                "Starter Island",
                "Desert",
                "Frozen Village",
                "Marine Fortress",
                "Skylands",
                "Fountain City"
            }
        )

        Button(
            "Start Secret Quest",
            function()

                Notify(
                    "INFO",
                    "Secret Quest",
                    "Quest request."
                )

            end
        )

        Toggle(
            "Auto Get Yama",
            "Yama"
        )

        Toggle(
            "Auto Get Tushita",
            "Tushita"
        )

        Toggle(
            "Auto Get Buddy Sword",
            "Buddy"
        )

        Toggle(
            "Auto Get Soul Guitar",
            "SoulGuitar"
        )

        Toggle(
            "Kill Cake Prince",
            "CakePrince"
        )

        Toggle(
            "Auto Spawn & Kill Indra",
            "Indra"
        )

        Toggle(
            "Auto Spawn Dough King",
            "DoughKing"
        )

        Toggle(
            "Auto Get Hallow Scythe",
            "HallowScythe"
        )

    elseif tab == "FRUIT / RAID" then

        Section("RAID")

        Dropdown(
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

        Toggle(
            "Start Raid",
            "Raid"
        )

        Toggle(
            "AutoKillRaid",
            "RaidKill"
        )

        Section("FRUIT")

        Dropdown(
            "Select Fruit",
            {
                "Rocket",
                "Spin",
                "Chop",
                "Flame",
                "Ice",
                "Light",
                "Magma",
                "Dough"
            }
        )

        Toggle(
            "Auto Buy Select Fruit",
            "BuyFruit"
        )

        Toggle(
            "Rolled Fruit",
            "RolledFruit"
        )

        Toggle(
            "Auto Store Fruit",
            "StoreFruit"
        )

    elseif tab == "FISHING" then

        Section("FISHING")

        Toggle(
            "Auto Fish",
            "AutoFish"
        )

        Toggle(
            "Auto Cast",
            "AutoCast"
        )

    elseif tab == "STATUS" then

        Section("STATUS")

        Button(
            "Fruit Spawn: Checking...",
            function()

                Notify(
                    "INFO",
                    "Fruit Spawn",
                    "Status checked."
                )

            end
        )

        Toggle(
            "Check Entire Map",
            "MapCheck"
        )

        local TimeLabel =
            Button(
                "Server Time: " ..
                os.date("%H:%M:%S")
            )

        local MoonLabel =
            Button(
                "Phase Moon: Checking..."
            )

        task.spawn(function()

            while
                TimeLabel.Parent
                and State.Tab == "STATUS"
            do

                TimeLabel.Text =
                    "Server Time: " ..
                    os.date("%H:%M:%S")

                MoonLabel.Text =
                    "Phase Moon: " ..
                    tostring(
                        os.date("%d")
                    )

                task.wait(1)

            end

        end)

    elseif tab == "PVP" then

        Section("PVP")

        Dropdown(
            "Select Player",
            {
                "Player 1",
                "Player 2",
                "Player 3"
            }
        )

        Toggle(
            "Aimbot",
            "Aimbot"
        )

        Toggle(
            "Teleport to Player",
            "TeleportPlayer"
        )

        Toggle(
            "Auto Skill",
            "AutoSkill"
        )

    elseif tab == "STATS" then

        Section("STATS")

        Toggle(
            "Start Add Stats",
            "Stats"
        )

        Button(
            "Melee: 0%",
            function() end
        )

        Button(
            "Sword: 0%",
            function() end
        )

        Button(
            "Gun: 0%",
            function() end
        )

        Button(
            "Defense: 0%",
            function() end
        )

        Button(
            "Blox Fruit: 0%",
            function() end
        )

    elseif tab == "MISC" then

        Section("MISC")

        Button(
            "Job ID: " ..
            tostring(game.JobId)
        )

        Button(
            "Copy Job ID",
            function()

                Notify(
                    "INFO",
                    "Job ID",
                    tostring(game.JobId)
                )

            end
        )

        Button(
            "Join Job ID",
            function()

                Notify(
                    "INFO",
                    "Join Job ID",
                    "Handler belum dikonfigurasi."
                )

            end
        )

        Button(
            "Redeem All Code",
            function()

                Notify(
                    "INFO",
                    "Redeem",
                    "Redeem request."
                )

            end
        )

        Toggle(
            "Anti AFK",
            "AntiAFK"
        )

        Toggle(
            "No Clip",
            "NoClip"
        )

        Toggle(
            "Infinite Jump",
            "InfiniteJump"
        )

        local FPS =
            Button(
                "FPS: calculating..."
            )

        task.spawn(function()

            local frames = 0
            local last =
                os.clock()

            while FPS.Parent do

                frames += 1

                if
                    os.clock() - last >= 1
                then

                    FPS.Text =
                        "FPS: " ..
                        tostring(frames)

                    frames = 0
                    last =
                        os.clock()

                end

                RunService.RenderStepped:Wait()

            end

        end)

    end
end

--========================================================--
-- TAB BUTTONS
--========================================================--

for index, tab in ipairs(Tabs) do

    local button =
        New("TextButton", {

            Name =
                "Tab_" .. tab,

            BackgroundColor3 =
                THEME.BG2,

            BorderSizePixel = 0,

            Text =
                "  " .. tab,

            TextColor3 =
                THEME.MUTED,

            Font =
                Enum.Font.GothamMedium,

            TextSize = 9,

            TextXAlignment =
                Enum.TextXAlignment.Left,

            AutoButtonColor = false,

            Size =
                UDim2.new(
                    1,
                    -4,
                    0,
                    36
                ),

            LayoutOrder =
                index,

        }, TabScroll)

    Corner(button, 7)

    TabButtons[tab] =
        button

    button.MouseButton1Click:Connect(
        function()

            State.Tab =
                tab

            for name, item in
                pairs(TabButtons) do

                Tween(
                    item,
                    {
                        BackgroundColor3 =
                            name == tab
                                and THEME.PURPLE
                                or THEME.BG2,

                        TextColor3 =
                            name == tab
                                and THEME.TEXT
                                or THEME.MUTED,
                    },
                    0.12
                )

            end

            RenderTab(tab)

        end
    )
end

--========================================================--
-- SEARCH
--========================================================--

local SearchIndex = {}

for _, tab in ipairs(Tabs) do
    table.insert(
        SearchIndex,
        {
            tab,
            tab
        }
    )
end

Search:GetPropertyChangedSignal(
    "Text"
):Connect(function()

    local query =
        Search.Text:lower()

    if query == "" then
        return
    end

    local found = false

    for _, item in ipairs(SearchIndex) do

        if
            item[1]:lower():find(
                query,
                1,
                true
            )
            or
            item[2]:lower():find(
                query,
                1,
                true
            )
        then

            found = true

            State.Tab =
                item[1]

            RenderTab(
                item[1]
            )

            break
        end

    end

    if not found then

        Notify(
            "WARNING",
            "Search",
            "Feature not found."
        )

    end
end)

--========================================================--
-- OPEN/CLOSE
--========================================================--

local OpenButton =
    New("ImageButton", {

        Name = "OpenClose",

        BackgroundColor3 =
            THEME.PURPLE,

        BorderSizePixel = 0,

        Image =
            CONFIG.OpenClose,

        ScaleType =
            Enum.ScaleType.Fit,

        Size =
            UDim2.fromOffset(
                58,
                58
            ),

        Position =
            UDim2.new(
                0,
                15,
                0.5,
                -29
            ),

        AutoButtonColor = false,

        ZIndex = 200,

    }, Gui)

Corner(OpenButton, 14)
Stroke(OpenButton, THEME.PURPLE2)

local WindowOpen = true

local function SetWindow(open)

    WindowOpen =
        open

    if open then

        Main.Visible = true

        Tween(
            Main,
            {
                Size =
                    UDim2.fromOffset(
                        baseWidth,
                        baseHeight
                    )
            },
            0.25
        )

    else

        local tween =
            Tween(
                Main,
                {
                    Size =
                        UDim2.fromOffset(
                            0,
                            0
                        )
                },
                0.2
            )

        tween.Completed:Connect(
            function()

                if not WindowOpen then
                    Main.Visible = false
                end

            end
        )

    end
end

OpenButton.MouseButton1Click:Connect(
    function()

        SetWindow(
            not WindowOpen
        )

    end
)

CloseButton.MouseButton1Click:Connect(
    function()

        SetWindow(false)

    end
)

MinButton.MouseButton1Click:Connect(
    function()

        SetWindow(false)

    end
)

--========================================================--
-- SCALE BUTTON
--========================================================--

local ScaleValues = {
    0.75,
    0.85,
    0.90,
    1.00,
}

local ScaleIndex = 3

ScaleButton.MouseButton1Click:Connect(
    function()

        ScaleIndex =
            ScaleIndex + 1

        if ScaleIndex >
            #ScaleValues then

            ScaleIndex = 1

        end

        State.Scale =
            ScaleValues[ScaleIndex]

        UIScale.Scale =
            State.Scale

        Notify(
            "INFO",
            "UI Scale",
            tostring(
                math.floor(
                    State.Scale * 100
                )
            ) .. "%",
        )

    end
)

--========================================================--
-- DRAG
--========================================================--

local function MakeDraggable(
    handle,
    target
)

    local dragging = false
    local startPosition
    local targetPosition

    handle.InputBegan:Connect(
        function(input)

            if
                input.UserInputType ==
                    Enum.UserInputType.MouseButton1

                or

                input.UserInputType ==
                    Enum.UserInputType.Touch
            then

                dragging = true

                startPosition =
                    input.Position

                targetPosition =
                    target.Position

            end

        end
    )

    UserInputService.InputChanged:Connect(
        function(input)

            if not dragging then
                return
            end

            if
                input.UserInputType ==
                    Enum.UserInputType.MouseMovement

                or

                input.UserInputType ==
                    Enum.UserInputType.Touch
            then

                local delta =
                    input.Position -
                    startPosition

                target.Position =
                    UDim2.new(
                        targetPosition.X.Scale,
                        targetPosition.X.Offset +
                            delta.X,

                        targetPosition.Y.Scale,
                        targetPosition.Y.Offset +
                            delta.Y
                    )

            end

        end
    )

    UserInputService.InputEnded:Connect(
        function(input)

            if
                input.UserInputType ==
                    Enum.UserInputType.MouseButton1

                or

                input.UserInputType ==
                    Enum.UserInputType.Touch
            then

                dragging = false

            end

        end
    )
end

MakeDraggable(
    Header,
    Main
)

MakeDraggable(
    OpenButton,
    OpenButton
)

--========================================================--
-- MOBILE
--========================================================--

if isMobile then

    TabScroll.ScrollingEnabled = true
    FeatureScroll.ScrollingEnabled = true

end

--========================================================--
-- INITIAL TAB
--========================================================--

for name, button in
    pairs(TabButtons) do

    if name == "FARM" then

        button.BackgroundColor3 =
            THEME.PURPLE

        button.TextColor3 =
            THEME.TEXT

    end

end

RenderTab("FARM")

Notify(
    "SUCCESS",
    "SysxHub",
    "UI berhasil dimuat."
)

print(
    "[SysxHub] UI loaded successfully"
)
