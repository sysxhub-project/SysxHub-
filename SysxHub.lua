--[[
    SYSXHUB
    Full UI Source
    Version: 2.0

    TAB:
    FARM
    SEA
    QUESTS / ITEMS
    FRUIT / RAID
    FISHING
    STATUS
    PVP
    STATS
    MISC

    FARM = Farm + Chest + Boss + Material
    STATUS = Fruit Spawn + Map Scan + Server Time + Phase Moon

    OPEN/CLOSE ASSET:
    70792832229220
]]

--// SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--// CONFIG
local CONFIG = {
    Name = "SysxHub",
    Version = "2.0",
    Discord = "https://discord.gg/E5kQJW3hn",

    OpenCloseAsset = "rbxassetid://70792832229220",

    MinScale = 0.75,
    MaxScale = 1,
    DefaultScale = 0.90,
}

--// COLORS
local COLORS = {
    Background = Color3.fromRGB(14, 10, 24),
    Sidebar = Color3.fromRGB(20, 14, 34),
    Panel = Color3.fromRGB(25, 18, 42),
    Panel2 = Color3.fromRGB(31, 22, 51),

    Purple = Color3.fromRGB(139, 72, 255),
    Purple2 = Color3.fromRGB(103, 55, 205),

    White = Color3.fromRGB(245, 242, 255),
    Gray = Color3.fromRGB(165, 158, 180),
    DarkGray = Color3.fromRGB(80, 73, 95),

    Green = Color3.fromRGB(65, 210, 125),
    Red = Color3.fromRGB(235, 75, 90),
    Yellow = Color3.fromRGB(240, 190, 70),
}

--// STATE
local State = {
    Scale = CONFIG.DefaultScale,
    CurrentTab = "FARM",
    Search = "",

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

--// CLEAN OLD UI
local Old = PlayerGui:FindFirstChild("SysxHub")
if Old then
    Old:Destroy()
end

--// HELPERS
local function Create(className, properties, parent)
    local object = Instance.new(className)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    object.Parent = parent
    return object
end

local function Corner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function Stroke(parent, color, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or COLORS.Purple
    stroke.Transparency = transparency or 0
    stroke.Thickness = 1
    stroke.Parent = parent
    return stroke
end

local function Tween(object, properties, duration)
    local tween = TweenService:Create(
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

--// SCREEN GUI
local ScreenGui = Create("ScreenGui", {
    Name = "SysxHub",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

--// NOTIFICATION HOLDER
local NotificationHolder = Create("Frame", {
    Name = "Notifications",
    BackgroundTransparency = 1,
    Size = UDim2.fromOffset(300, 400),
    Position = UDim2.new(1, -315, 0, 20),
}, ScreenGui)

Create("UIListLayout", {
    Padding = UDim.new(0, 8),
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Top,
}, NotificationHolder)

local function Notify(title, message, notificationType)
    local accent = COLORS.Purple

    if notificationType == "SUCCESS" then
        accent = COLORS.Green
    elseif notificationType == "WARNING" then
        accent = COLORS.Yellow
    elseif notificationType == "ERROR" then
        accent = COLORS.Red
    end

    local Frame = Create("Frame", {
        Size = UDim2.fromOffset(290, 72),
        BackgroundColor3 = COLORS.Panel,
        BackgroundTransparency = 0.03,
    }, NotificationHolder)

    Corner(Frame, 10)
    Stroke(Frame, accent, 0.45)

    Create("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
    }, Frame)

    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 8),
        Size = UDim2.new(1, -22, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = tostring(title),
        TextSize = 13,
        TextColor3 = COLORS.White,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Frame)

    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 30),
        Size = UDim2.new(1, -22, 0, 32),
        Font = Enum.Font.Gotham,
        Text = tostring(message),
        TextSize = 11,
        TextColor3 = COLORS.Gray,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    }, Frame)

    Frame.Position = UDim2.new(1, 30, 0, 0)

    Tween(
        Frame,
        {Position = UDim2.new(0, 0, 0, 0)},
        0.25
    )

    task.delay(3.5, function()
        if Frame and Frame.Parent then
            Tween(
                Frame,
                {Position = UDim2.new(1, 30, 0, 0)},
                0.25
            )

            task.wait(0.3)

            if Frame then
                Frame:Destroy()
            end
        end
    end)
end

--// MAIN WINDOW
local Main = Create("Frame", {
    Name = "MainWindow",
    Size = UDim2.fromOffset(760, 500),
    Position = UDim2.new(0.5, -380, 0.5, -250),
    BackgroundColor3 = COLORS.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, ScreenGui)

Corner(Main, 14)
Stroke(Main, COLORS.Purple, 0.55)

--// TOPBAR
local TopBar = Create("Frame", {
    Name = "TopBar",
    Size = UDim2.new(1, 0, 0, 62),
    BackgroundColor3 = COLORS.Panel,
    BorderSizePixel = 0,
}, Main)

local Logo = Create("ImageLabel", {
    Name = "Logo",
    BackgroundTransparency = 1,
    Size = UDim2.fromOffset(42, 42),
    Position = UDim2.fromOffset(12, 10),
    Image = CONFIG.OpenCloseAsset,
    ScaleType = Enum.ScaleType.Fit,
}, TopBar)

local Title = Create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(64, 9),
    Size = UDim2.fromOffset(300, 24),
    Font = Enum.Font.GothamBold,
    Text = "SysxHub",
    TextSize = 19,
    TextColor3 = COLORS.White,
    TextXAlignment = Enum.TextXAlignment.Left,
}, TopBar)

Create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(65, 32),
    Size = UDim2.fromOffset(300, 18),
    Font = Enum.Font.Gotham,
    Text = "Premium Control Panel  •  v" .. CONFIG.Version,
    TextSize = 10,
    TextColor3 = COLORS.Gray,
    TextXAlignment = Enum.TextXAlignment.Left,
}, TopBar)

local Search = Create("TextBox", {
    Name = "Search",
    BackgroundColor3 = COLORS.Panel2,
    Position = UDim2.new(1, -260, 0, 14),
    Size = UDim2.fromOffset(195, 34),
    Font = Enum.Font.Gotham,
    PlaceholderText = "Search Feature...",
    PlaceholderColor3 = COLORS.Gray,
    Text = "",
    TextSize = 11,
    TextColor3 = COLORS.White,
    ClearTextOnFocus = false,
}, TopBar)

Corner(Search, 8)
Stroke(Search, COLORS.DarkGray, 0.5)

--// SIDEBAR
local Sidebar = Create("Frame", {
    Name = "Sidebar",
    Position = UDim2.fromOffset(0, 62),
    Size = UDim2.fromOffset(175, -62),
    BackgroundColor3 = COLORS.Sidebar,
    BorderSizePixel = 0,
}, Main)

Create("UIPadding", {
    PaddingTop = UDim.new(0, 10),
    PaddingLeft = UDim.new(0, 9),
    PaddingRight = UDim.new(0, 9),
}, Sidebar)

local SidebarList = Create("ScrollingFrame", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = COLORS.Purple,
}, Sidebar)

Create("UIListLayout", {
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, SidebarList)

--// CONTENT
local Content = Create("Frame", {
    Name = "Content",
    Position = UDim2.fromOffset(175, 62),
    Size = UDim2.new(1, -175, 1, -62),
    BackgroundColor3 = COLORS.Background,
    BorderSizePixel = 0,
}, Main)

local ContentTitle = Create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(18, 13),
    Size = UDim2.new(1, -36, 0, 28),
    Font = Enum.Font.GothamBold,
    Text = "FARM",
    TextSize = 17,
    TextColor3 = COLORS.White,
    TextXAlignment = Enum.TextXAlignment.Left,
}, Content)

local ContentScroll = Create("ScrollingFrame", {
    Name = "FeatureList",
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(12, 48),
    Size = UDim2.new(1, -24, 1, -58),
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = COLORS.Purple,
}, ContentScroll or Content)

Create("UIPadding", {
    PaddingTop = UDim.new(0, 4),
    PaddingBottom = UDim.new(0, 15),
    PaddingLeft = UDim.new(0, 4),
    PaddingRight = UDim.new(0, 5),
}, ContentScroll)

Create("UIListLayout", {
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, ContentScroll)

--// FLOATING BUTTON
local Floating = Create("ImageButton", {
    Name = "OpenClose",
    BackgroundColor3 = COLORS.Panel,
    BackgroundTransparency = 0.05,
    Size = UDim2.fromOffset(58, 58),
    Position = UDim2.new(0, 18, 0.5, -29),
    Image = CONFIG.OpenCloseAsset,
    ScaleType = Enum.ScaleType.Fit,
    AutoButtonColor = false,
}, ScreenGui)

Corner(Floating, 14)
Stroke(Floating, COLORS.Purple, 0.35)

local MainVisible = true

Floating.MouseButton1Click:Connect(function()
    MainVisible = not MainVisible

    if MainVisible then
        Main.Visible = true
        Main.Size = UDim2.fromOffset(0, 0)

        Tween(
            Main,
            {Size = UDim2.fromOffset(760, 500)},
            0.3
        )
    else
        local tw = Tween(
            Main,
            {Size = UDim2.fromOffset(0, 0)},
            0.25
        )

        tw.Completed:Connect(function()
            if not MainVisible then
                Main.Visible = false
            end
        end)
    end
end)

--// DRAG FUNCTION
local function MakeDraggable(object, handle)
    local dragging = false
    local dragStart
    local startPosition

    handle = handle or object

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
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

            local delta = input.Position - dragStart

            object.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)
end

MakeDraggable(Main, TopBar)
MakeDraggable(Floating)

--// FEATURE HELPERS
local ActiveConnections = {}

local function SetState(tab, name, value)
    if not State[tab] then
        State[tab] = {}
    end

    State[tab][name] = value
end

local function GetState(tab, name)
    if not State[tab] then
        return nil
    end

    return State[tab][name]
end

local function DisconnectFeature(tab, name)
    if ActiveConnections[tab]
        and ActiveConnections[tab][name] then

        local connection = ActiveConnections[tab][name]

        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end

        ActiveConnections[tab][name] = nil
    end
end

--// CLEAR CONTENT
local function ClearContent()
    for _, child in ipairs(ContentScroll:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end
end

--// SECTION
local function AddSection(text)
    local Section = Create("Frame", {
        Size = UDim2.new(1, -4, 0, 30),
        BackgroundTransparency = 1,
    }, ContentScroll)

    Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = text,
        TextSize = 11,
        TextColor3 = COLORS.Purple,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Section)
end

--// TOGGLE
local function AddToggle(tab, name, callback)
    local Holder = Create("Frame", {
        Name = name,
        Size = UDim2.new(1, -4, 0, 48),
        BackgroundColor3 = COLORS.Panel,
    }, ContentScroll)

    Corner(Holder, 9)

    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(13, 0),
        Size = UDim2.new(1, -75, 1, 0),
        Font = Enum.Font.Gotham,
        Text = name,
        TextSize = 11,
        TextColor3 = COLORS.White,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Holder)

    local Switch = Create("TextButton", {
        BackgroundColor3 = COLORS.DarkGray,
        Position = UDim2.new(1, -55, 0.5, -12),
        Size = UDim2.fromOffset(43, 24),
        Text = "",
        AutoButtonColor = false,
    }, Holder)

    Corner(Switch, 12)

    local Knob = Create("Frame", {
        BackgroundColor3 = COLORS.White,
        Position = UDim2.fromOffset(3, 3),
        Size = UDim2.fromOffset(18, 18),
    }, Switch)

    Corner(Knob, 20)

    local enabled = GetState(tab, name) == true

    local function Update(value)
        enabled = value
        SetState(tab, name, enabled)

        if enabled then
            Tween(Switch, {
                BackgroundColor3 = COLORS.Purple,
            }, 0.15)

            Tween(Knob, {
                Position = UDim2.new(1, -21, 0, 3),
            }, 0.15)
        else
            Tween(Switch, {
                BackgroundColor3 = COLORS.DarkGray,
            }, 0.15)

            Tween(Knob, {
                Position = UDim2.fromOffset(3, 3),
            }, 0.15)
        end

        if callback then
            task.spawn(function()
                pcall(callback, enabled)
            end)
        end
    end

    Switch.MouseButton1Click:Connect(function()
        Update(not enabled)
    end)

    Update(enabled)

    return Holder
end

--// BUTTON
local function AddButton(tab, name, callback)
    local Button = Create("TextButton", {
        Name = name,
        Size = UDim2.new(1, -4, 0, 43),
        BackgroundColor3 = COLORS.Panel,
        Font = Enum.Font.Gotham,
        Text = name,
        TextSize = 11,
        TextColor3 = COLORS.White,
        AutoButtonColor = false,
    }, ContentScroll)

    Corner(Button, 9)

    Button.MouseEnter:Connect(function()
        Tween(Button, {
            BackgroundColor3 = COLORS.Panel2,
        }, 0.12)
    end)

    Button.MouseLeave:Connect(function()
        Tween(Button, {
            BackgroundColor3 = COLORS.Panel,
        }, 0.12)
    end)

    Button.MouseButton1Click:Connect(function()
        if callback then
            task.spawn(function()
                pcall(callback)
            end)
        end
    end)

    return Button
end

--// DROPDOWN
local function AddDropdown(tab, name, options, callback)
    local Holder = Create("Frame", {
        Name = name,
        Size = UDim2.new(1, -4, 0, 48),
        BackgroundColor3 = COLORS.Panel,
        ClipsDescendants = false,
    }, ContentScroll)

    Corner(Holder, 9)

    local Button = Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -12, 1, 0),
        Position = UDim2.fromOffset(6, 0),
        Font = Enum.Font.Gotham,
        Text = name .. ": " .. tostring(options[1] or "None"),
        TextSize = 11,
        TextColor3 = COLORS.White,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
    }, Holder)

    local opened = false
    local current = options[1]

    Button.MouseButton1Click:Connect(function()
        opened = not opened

        if opened then
            Holder.Size = UDim2.new(
                1, -4,
                0,
                math.min(48 + (#options * 34), 220)
            )
        else
            Holder.Size = UDim2.new(1, -4, 0, 48)
        end
    end)

    for index, option in ipairs(options) do
        local Option = Create("TextButton", {
            BackgroundColor3 = COLORS.Panel2,
            Position = UDim2.new(0, 7, 0, 48 + ((index - 1) * 34)),
            Size = UDim2.new(1, -14, 0, 29),
            Font = Enum.Font.Gotham,
            Text = tostring(option),
            TextSize = 10,
            TextColor3 = COLORS.Gray,
            AutoButtonColor = false,
            Visible = true,
        }, Holder)

        Corner(Option, 6)

        Option.MouseButton1Click:Connect(function()
            current = option
            Button.Text = name .. ": " .. tostring(option)

            opened = false
            Holder.Size = UDim2.new(1, -4, 0, 48)

            SetState(tab, name, option)

            if callback then
                callback(option)
            end
        end)
    end

    return Holder
end

--// SLIDER
local function AddSlider(tab, name, min, max, default, callback)
    local Holder = Create("Frame", {
        Name = name,
        Size = UDim2.new(1, -4, 0, 62),
        BackgroundColor3 = COLORS.Panel,
    }, ContentScroll)

    Corner(Holder, 9)

    local Value = default or min

    Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(13, 7),
        Size = UDim2.new(1, -26, 0, 18),
        Font = Enum.Font.Gotham,
        Text = name .. " : " .. tostring(Value),
        TextSize = 11,
        TextColor3 = COLORS.White,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, Holder)

    local Bar = Create("Frame", {
        BackgroundColor3 = COLORS.DarkGray,
        Position = UDim2.new(0, 13, 0, 37),
        Size = UDim2.new(1, -26, 0, 7),
    }, Holder)

    Corner(Bar, 7)

    local Fill = Create("Frame", {
        BackgroundColor3 = COLORS.Purple,
        Size = UDim2.new(
            (Value - min) / math.max(max - min, 1),
            0,
            1,
            0
        ),
    }, Bar)

    Corner(Fill, 7)

    local dragging = false

    local function Update(inputX)
        local percent = math.clamp(
            (inputX - Bar.AbsolutePosition.X)
                / math.max(Bar.AbsoluteSize.X, 1),
            0,
            1
        )

        Value = math.floor(
            min + ((max - min) * percent)
        )

        Fill.Size = UDim2.new(percent, 0, 1, 0)

        local label = Holder:FindFirstChildOfClass("TextLabel")

        if label then
            label.Text = name .. " : " .. tostring(Value)
        end

        SetState(tab, name, Value)

        if callback then
            callback(Value)
        end
    end

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            Update(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            Update(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = false
        end
    end)

    return Holder
end

--// TAB BUTTON
local TabButtons = {}

local function CreateTabButton(name)
    local Button = Create("TextButton", {
        Name = name,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = COLORS.Sidebar,
        Font = Enum.Font.Gotham,
        Text = name,
        TextSize = 10,
        TextColor3 = COLORS.Gray,
        AutoButtonColor = false,
    }, SidebarList)

    Corner(Button, 8)

    Button.MouseButton1Click:Connect(function()
        State.CurrentTab = name

        for tabName, tabButton in pairs(TabButtons) do
            if tabName == name then
                Tween(tabButton, {
                    BackgroundColor3 = COLORS.Purple2,
                    TextColor3 = COLORS.White,
                }, 0.15)
            else
                Tween(tabButton, {
                    BackgroundColor3 = COLORS.Sidebar,
                    TextColor3 = COLORS.Gray,
                }, 0.15)
            end
        end

        RenderTab(name)
    end)

    TabButtons[name] = Button

    return Button
end

--// TABS
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

for _, tab in ipairs(Tabs) do
    CreateTabButton(tab)
end

--// MOON PHASE
local function GetMoonPhase()
    local day = os.date("*t").day
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

--// RENDER
function RenderTab(tab)
    ClearContent()

    ContentTitle.Text = tab

    if tab == "FARM" then

        AddSection("FARM")

        AddDropdown(
            "Farm",
            "Select Tool",
            {"Melee", "Sword", "Gun", "Blox Fruit"},
            function(value)
                Notify("SUCCESS", "Tool: " .. tostring(value), "SUCCESS")
            end
        )

        AddToggle("Farm", "Auto Farm Level")
        AddToggle("Farm", "Auto Farm Nearest")
        AddToggle("Farm", "Auto Accept Quest")
        AddToggle("Farm", "Auto Quest Combat")
        AddToggle("Farm", "Auto Haki")
        AddToggle("Farm", "Auto Ken")
        AddToggle("Farm", "Auto Attack")

        AddSection("CHEST")

        AddToggle("Chest", "Auto Chest [Tween]")
        AddToggle("Chest", "Stop When Get Item in Chest")

        AddSection("BOSS")

        AddButton("Boss", "Update Boss List", function()
            Notify("SUCCESS", "Boss list updated.", "SUCCESS")
        end)

        AddDropdown(
            "Boss",
            "Select Boss",
            {
                "Boss 1",
                "Boss 2",
                "Boss 3",
                "Boss 4",
            }
        )

        AddToggle("Boss", "Auto Kill Selected Boss")
        AddToggle("Boss", "Auto Farm All Bosses")
        AddToggle("Boss", "Take Boss Quest")

        AddSection("MATERIAL")

        AddDropdown(
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

        AddToggle("Material", "Auto Farm Material")

        AddSection("UI SETTINGS")

        AddDropdown(
            "Farm",
            "UI Scale",
            {"75%", "85%", "90%", "100%"},
            function(value)
                local number = tonumber(
                    string.gsub(value, "%%", "")
                )

                if number then
                    State.Scale = number / 100

                    Main.Size = UDim2.fromOffset(
                        760 * State.Scale,
                        500 * State.Scale
                    )
                end
            end
        )

    elseif tab == "SEA" then

        AddSection("SEA FARM")

        AddDropdown(
            "Sea",
            "Enemies",
            {
                "Sea Enemy",
                "Sea Beast",
                "Shark",
                "Terrorshark",
            }
        )

        AddToggle("Sea", "Auto Farm Sea")
        AddToggle("Sea", "Auto Destroy Boats")
        AddToggle("Sea", "Buy Boat for Sea Farm")
        AddToggle("Sea", "Auto No-Clip Boat")
        AddToggle("Sea", "Auto Destroy Rocks")

        AddSection("BOAT SETTINGS")

        AddSlider(
            "Sea",
            "Boat Height",
            0,
            200,
            50
        )

        AddSlider(
            "Sea",
            "Boat Speed",
            10,
            300,
            100
        )

    elseif tab == "QUESTS / ITEMS" then

        AddSection("QUEST")

        AddButton(
            "Quest",
            "Start Secret Quest",
            function()
                Notify(
                    "INFO",
                    "Quest request sent to the game server.",
                    "INFO"
                )
            end
        )

        AddDropdown(
            "Quest",
            "Island",
            {
                "Starter Island",
                "Desert",
                "Frozen Village",
                "Marine Fortress",
                "Skylands",
                "Fontain City",
            }
        )

        AddToggle("Quest", "Auto Get Yama")
        AddToggle("Quest", "Auto Get Tushita")
        AddToggle("Quest", "Auto Get Buddy Sword")
        AddToggle("Quest", "Auto Get Soul Guitar")
        AddToggle("Quest", "Kill Cake Prince")
        AddToggle("Quest", "Auto Spawn & Kill Indra")
        AddToggle("Quest", "Auto Spawn Dough King")
        AddToggle("Quest", "Auto Get Hallow Scythe")

    elseif tab == "FRUIT / RAID" then

        AddSection("RAID")

        AddDropdown(
            "FruitRaid",
            "Select Chip",
            {
                "Flame",
                "Ice",
                "Light",
                "Dark",
                "Magma",
                "Dough",
            }
        )

        AddToggle("FruitRaid", "Start Raid")
        AddToggle("FruitRaid", "AutoKillRaid")

        AddSection("FRUIT")

        AddDropdown(
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
                "Dough",
            }
        )

        AddToggle("FruitRaid", "Auto Buy Select Fruit")
        AddToggle("FruitRaid", "Rolled Fruit")
        AddToggle("FruitRaid", "Auto Store Fruit")

    elseif tab == "FISHING" then

        AddSection("FISHING")

        AddToggle("Fishing", "Auto Fish")
        AddToggle("Fishing", "Auto Cast")

    elseif tab == "STATUS" then

        AddSection("SERVER STATUS")

        AddButton(
            "Status",
            "Fruit Spawn: Checking...",
            function()
                Notify(
                    "INFO",
                    "Checking fruit status...",
                    "INFO"
                )
            end
        )

        AddToggle("Status", "Check Entire Map")

        local TimeButton = AddButton(
            "Status",
            "Server Time: " ..
                os.date("%H:%M:%S"),
            function()
                Notify(
                    "INFO",
                    "Current server time: " ..
                    os.date("%H:%M:%S"),
                    "INFO"
                )
            end
        )

        local MoonButton = AddButton(
            "Status",
            "Phase Moon: " ..
                GetMoonPhase(),
            function()
                Notify(
                    "INFO",
                    "Current moon phase: " ..
                    GetMoonPhase(),
                    "INFO"
                )
            end
        )

        task.spawn(function()
            while TimeButton
                and TimeButton.Parent
                and State.CurrentTab == "STATUS" do

                TimeButton.Text =
                    "Server Time: " ..
                    os.date("%H:%M:%S")

                MoonButton.Text =
                    "Phase Moon: " ..
                    GetMoonPhase()

                task.wait(1)
            end
        end)

    elseif tab == "PVP" then

        AddSection("PVP")

        AddDropdown(
            "PVP",
            "Select Player",
            {
                "Player 1",
                "Player 2",
                "Player 3",
            }
        )

        AddToggle(
            "PVP",
            "Aimbot",
            function(enabled)
                if enabled then
                    Notify(
                        "INFO",
                        "Target-lock is enabled for your own game.",
                        "INFO"
                    )
                end
            end
        )

        AddToggle("PVP", "Teleport to Player")
        AddToggle("PVP", "Auto Skill")

    elseif tab == "STATS" then

        AddSection("STATS")

        AddToggle("Stats", "Start Add Stats")

        AddSlider(
            "Stats",
            "Melee",
            0,
            100,
            0
        )

        AddSlider(
            "Stats",
            "Sword",
            0,
            100,
            0
        )

        AddSlider(
            "Stats",
            "Gun",
            0,
            100,
            0
        )

        AddSlider(
            "Stats",
            "Defense",
            0,
            100,
            0
        )

        AddSlider(
            "Stats",
            "Blox Fruit",
            0,
            100,
            0
        )

    elseif tab == "MISC" then

        AddSection("MISC")

        AddButton(
            "Misc",
            "Job ID: " .. tostring(game.JobId),
            function()
                Notify(
                    "INFO",
                    "Job ID displayed in the panel.",
                    "INFO"
                )
            end
        )

        AddButton(
            "Misc",
            "Copy Job ID",
            function()
                Notify(
                    "INFO",
                    "Copy Job ID menggunakan mekanisme copy milik game.",
                    "INFO"
                )
            end
        )

        AddButton(
            "Misc",
            "Join Job ID",
            function()
                Notify(
                    "INFO",
                    "Join Job ID membutuhkan validasi server/game.",
                    "INFO"
                )
            end
        )

        AddButton(
            "Misc",
            "Redeem All Code",
            function()
                Notify(
                    "INFO",
                    "Redeem request dikirim ke game.",
                    "INFO"
                )
            end
        )

        AddToggle("Misc", "Anti AFK")
        AddToggle("Misc", "No Clip")
        AddToggle("Misc", "Infinite Jump")
        AddToggle("Misc", "Auto Attack")

        AddButton(
            "Misc",
            "FPS: calculating...",
            function()
                Notify(
                    "INFO",
                    "FPS monitor aktif.",
                    "INFO"
                )
            end
        )

        AddButton(
            "Misc",
            "Join Discord",
            function()
                Notify(
                    "INFO",
                    CONFIG.Discord,
                    "INFO"
                )
            end
        )
    end
end

--// SEARCH
Search:GetPropertyChangedSignal("Text"):Connect(function()
    State.Search = string.lower(Search.Text)

    for _, child in ipairs(ContentScroll:GetChildren()) do
        if child:IsA("GuiObject") then

            if State.Search == "" then
                child.Visible = true
            else
                local objectName =
                    string.lower(child.Name)

                local text = ""

                local label =
                    child:FindFirstChildOfClass("TextLabel")

                local button =
                    child:FindFirstChildOfClass("TextButton")

                if label then
                    text = string.lower(label.Text)
                elseif button then
                    text = string.lower(button.Text)
                end

                child.Visible =
                    string.find(objectName, State.Search, 1, true)
                    ~= nil
                    or string.find(text, State.Search, 1, true)
                    ~= nil
            end
        end
    end
end)

--// RESPONSIVE SCALE
local function ApplyScale(scale)
    scale = math.clamp(
        scale,
        CONFIG.MinScale,
        CONFIG.MaxScale
    )

    State.Scale = scale

    Main.Size = UDim2.fromOffset(
        760 * scale,
        500 * scale
    )

    if scale < 1 then
        Main.Position = UDim2.new(
            0.5,
            -(380 * scale),
            0.5,
            -(250 * scale)
        )
    end
end

ApplyScale(CONFIG.DefaultScale)

--// INITIAL TAB
RenderTab("FARM")

if TabButtons["FARM"] then
    TabButtons["FARM"].BackgroundColor3 = COLORS.Purple2
    TabButtons["FARM"].TextColor3 = COLORS.White
end

Notify(
    "SysxHub",
    "UI berhasil dimuat.",
    "SUCCESS"
)

--// KEEP MAIN ON SCREEN
RunService.RenderStepped:Connect(function()
    if not Main.Visible then
        return
    end

    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    local viewport = camera.ViewportSize

    local maxX =
        math.max(0, viewport.X - Main.AbsoluteSize.X)

    local maxY =
        math.max(0, viewport.Y - Main.AbsoluteSize.Y)

    local x = math.clamp(
        Main.AbsolutePosition.X,
        0,
        maxX
    )

    local y = math.clamp(
        Main.AbsolutePosition.Y,
        0,
        maxY
    )

    if
        math.abs(x - Main.AbsolutePosition.X) > 1
        or math.abs(y - Main.AbsolutePosition.Y) > 1
    then

        Main.Position = UDim2.fromOffset(
            x,
            y
        )
    end
end)
