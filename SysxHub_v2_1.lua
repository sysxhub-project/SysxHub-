--[[
    SysxHub v2.1 | UI Refactor / Diagnostic Build
    Discord : https://discord.gg/E5kQJW3hn

    NOTE:
    - UI/state systems are implemented/refactored.
    - Game-dependent automation is intentionally not claimed as verified.
    - Remote calls should be verified against the current game before enabling automation.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui", 20)

if not PlayerGui then
    warn("[SysxHub] PlayerGui tidak ditemukan.")
    return
end

-- =========================================================
-- CONFIG
-- =========================================================

local BRAND = {
    Name = "SysxHub",
    Version = "2.1",
    Discord = "https://discord.gg/E5kQJW3hn",
    LogoAsset = "rbxassetid://136425814447688",
}

local THEME = {
    Bg = Color3.fromRGB(12, 7, 20),
    Bg2 = Color3.fromRGB(20, 11, 31),
    Panel = Color3.fromRGB(28, 15, 42),
    Panel2 = Color3.fromRGB(39, 21, 57),
    Purple = Color3.fromRGB(125, 58, 190),
    Purple2 = Color3.fromRGB(163, 88, 230),
    Pink = Color3.fromRGB(211, 91, 198),
    Text = Color3.fromRGB(245, 240, 250),
    Muted = Color3.fromRGB(174, 160, 190),
    Stroke = Color3.fromRGB(79, 45, 101),
    Success = Color3.fromRGB(95, 210, 140),
    Warning = Color3.fromRGB(235, 190, 75),
    Error = Color3.fromRGB(225, 80, 105),
}

local CONFIG = {
    Width = 680,
    Height = 500,
    Sidebar = 160,
    Header = 56,
    MinWidth = 360,
    MinHeight = 260,
}

local State = {
    Tool = "Melee",
    Sea = 1,
    Boss = nil,
    Material = nil,
    SeaMob = nil,
    Player = nil,
    Chip = nil,
    Quest = nil,
    Island = nil,
    FarmRange = 500,
    ChestRange = 300,
    Toggles = {},
    StatValues = {
        Melee = 0,
        Sword = 0,
        Gun = 0,
        Defense = 0,
        ["Blox Fruit"] = 0,
    },
}

-- =========================================================
-- CLEAN OLD UI
-- =========================================================

pcall(function()
    for _, child in ipairs(PlayerGui:GetChildren()) do
        if child.Name == "SysxHub" or child.Name:match("^SysxHub_") then
            child:Destroy()
        end
    end
end)

-- =========================================================
-- UTILS
-- =========================================================

local U = {}

function U.new(className, props, parent)
    local obj = Instance.new(className)
    for key, value in pairs(props or {}) do
        pcall(function()
            obj[key] = value
        end)
    end
    if parent then
        obj.Parent = parent
    end
    return obj
end

function U.corner(obj, radius)
    return U.new("UICorner", {
        CornerRadius = UDim.new(0, radius or 8)
    }, obj)
end

function U.stroke(obj, color, thickness)
    return U.new("UIStroke", {
        Color = color or THEME.Stroke,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, obj)
end

function U.padding(obj, amount)
    local p = U.new("UIPadding", {}, obj)
    local u = UDim.new(0, amount or 8)
    p.PaddingTop = u
    p.PaddingBottom = u
    p.PaddingLeft = u
    p.PaddingRight = u
    return p
end

function U.gradient(obj, a, b, rotation)
    return U.new("UIGradient", {
        Color = ColorSequence.new(a, b),
        Rotation = rotation or 90
    }, obj)
end

function U.tween(obj, duration, props)
    local tween = TweenService:Create(
        obj,
        TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        props
    )
    tween:Play()
    return tween
end

function U.safe(callback)
    local ok, result = pcall(callback)
    if not ok then
        warn("[SysxHub] " .. tostring(result))
    end
    return ok, result
end

-- =========================================================
-- GUI ROOT
-- =========================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "SysxHub"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.DisplayOrder = 999
Gui.Enabled = true

local attached, attachError = pcall(function()
    Gui.Parent = PlayerGui
end)

if not attached or not Gui.Parent then
    warn("[SysxHub] GUI gagal attach:", attachError)
    return
end

print("[SysxHub] GUI attached:", Gui:GetFullName())

-- =========================================================
-- NOTIFICATIONS
-- =========================================================

local NotificationHolder = U.new("Frame", {
    Name = "Notifications",
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 300, 1, -80),
    Position = UDim2.new(1, -312, 0, 70),
    ZIndex = 100,
}, Gui)

U.new("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, NotificationHolder)

local Notifications = {}

local function notificationColor(kind)
    if kind == "SUCCESS" then return THEME.Success end
    if kind == "WARNING" then return THEME.Warning end
    if kind == "ERROR" then return THEME.Error end
    return THEME.Purple2
end

function Notifications.Push(kind, title, message, duration)
    duration = duration or 3

    local color = notificationColor(kind)

    local card = U.new("Frame", {
        BackgroundColor3 = THEME.Panel,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        ZIndex = 101,
    }, NotificationHolder)

    U.corner(card, 8)
    U.stroke(card, color)

    U.new("Frame", {
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 4, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        ZIndex = 102,
    }, card)

    U.new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = tostring(title),
        TextColor3 = THEME.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -24, 0, 17),
        Position = UDim2.new(0, 14, 0, 6),
        ZIndex = 102,
    }, card)

    U.new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = tostring(message),
        TextColor3 = THEME.Muted,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -24, 0, 18),
        Position = UDim2.new(0, 14, 0, 23),
        ZIndex = 102,
    }, card)

    U.tween(card, 0.25, {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 0
    })

    task.delay(duration, function()
        if not card.Parent then return end
        local tw = U.tween(card, 0.2, {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1
        })
        tw.Completed:Connect(function()
            if card then card:Destroy() end
        end)
    end)
end

-- =========================================================
-- MAIN WINDOW
-- =========================================================

local Main = U.new("Frame", {
    Name = "Main",
    BackgroundColor3 = THEME.Bg,
    BorderSizePixel = 0,
    Size = UDim2.fromOffset(CONFIG.Width, CONFIG.Height),
    Position = UDim2.new(0.5, -CONFIG.Width / 2, 0.5, -CONFIG.Height / 2),
    ClipsDescendants = true,
    ZIndex = 10,
}, Gui)

U.corner(Main, 14)
U.stroke(Main, THEME.Stroke)
U.gradient(Main, THEME.Bg, Color3.fromRGB(42, 19, 60), 120)

local UIScale = U.new("UIScale", {Scale = 1}, Main)

-- =========================================================
-- HEADER
-- =========================================================

local Header = U.new("Frame", {
    Name = "Header",
    BackgroundColor3 = THEME.Bg2,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, CONFIG.Header),
    ZIndex = 20,
}, Main)

U.corner(Header, 14)
U.gradient(Header, THEME.Panel2, THEME.Bg2, 0)

local Logo = U.new("ImageLabel", {
    Name = "Logo",
    BackgroundColor3 = THEME.Purple,
    BorderSizePixel = 0,
    Image = BRAND.LogoAsset,
    ScaleType = Enum.ScaleType.Fit,
    Size = UDim2.fromOffset(42, 42),
    Position = UDim2.new(0, 8, 0.5, -21),
    ZIndex = 21,
}, Header)
U.corner(Logo, 10)

local Title = U.new("TextLabel", {
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = BRAND.Name,
    TextColor3 = THEME.Purple2,
    TextSize = 20,
    TextXAlignment = Enum.TextXAlignment.Left,
    Size = UDim2.new(0, 220, 1, 0),
    Position = UDim2.new(0, 60, 0, 0),
    ZIndex = 21,
}, Header)

local function headerButton(text, offset, color)
    local button = U.new("TextButton", {
        BackgroundColor3 = color or THEME.Panel2,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = THEME.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        AutoButtonColor = false,
        Size = UDim2.fromOffset(32, 30),
        Position = UDim2.new(1, offset, 0.5, -15),
        ZIndex = 22,
    }, Header)
    U.corner(button, 6)

    button.MouseEnter:Connect(function()
        U.tween(button, 0.12, {BackgroundColor3 = THEME.Purple})
    end)

    button.MouseLeave:Connect(function()
        U.tween(button, 0.12, {BackgroundColor3 = color or THEME.Panel2})
    end)

    return button
end

local ScaleButton = headerButton("◱", -108)
local MinButton = headerButton("—", -72)
local CloseButton = headerButton("×", -36, THEME.Error)

-- =========================================================
-- SIDEBAR
-- =========================================================

local Sidebar = U.new("Frame", {
    Name = "Sidebar",
    BackgroundColor3 = THEME.Bg2,
    BorderSizePixel = 0,
    Size = UDim2.new(0, CONFIG.Sidebar, 1, -CONFIG.Header),
    Position = UDim2.new(0, 0, 0, CONFIG.Header),
    ZIndex = 15,
}, Main)

U.stroke(Sidebar, THEME.Stroke)

local SideBrand = U.new("Frame", {
    BackgroundColor3 = THEME.Bg,
    BorderSizePixel = 0,
    Size = UDim2.new(1, -12, 0, 78),
    Position = UDim2.new(0, 6, 0, 6),
    ZIndex = 16,
}, Sidebar)
U.corner(SideBrand, 10)

local SideLogo = U.new("ImageLabel", {
    BackgroundTransparency = 1,
    Image = BRAND.LogoAsset,
    ScaleType = Enum.ScaleType.Fit,
    Size = UDim2.fromOffset(48, 48),
    Position = UDim2.new(0.5, -24, 0, 5),
    ZIndex = 17,
}, SideBrand)

U.new("TextLabel", {
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "SYSX HUB",
    TextColor3 = THEME.Text,
    TextSize = 12,
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 53),
    ZIndex = 17,
}, SideBrand)

local TabScroll = U.new("ScrollingFrame", {
    Name = "Tabs",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 1, -92),
    Position = UDim2.new(0, 0, 0, 88),
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = THEME.Purple,
    ZIndex = 16,
}, Sidebar)

U.new("UIListLayout", {
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, TabScroll)
U.padding(TabScroll, 6)

-- =========================================================
-- CONTENT
-- =========================================================

local Content = U.new("Frame", {
    Name = "Content",
    BackgroundColor3 = THEME.Bg,
    BorderSizePixel = 0,
    Size = UDim2.new(1, -CONFIG.Sidebar, 1, -CONFIG.Header),
    Position = UDim2.new(0, CONFIG.Sidebar, 0, CONFIG.Header),
    ZIndex = 14,
}, Main)

local Search = U.new("TextBox", {
    Name = "Search",
    BackgroundColor3 = THEME.Bg2,
    BorderSizePixel = 0,
    ClearTextOnFocus = false,
    PlaceholderText = "Search Feature...",
    PlaceholderColor3 = THEME.Muted,
    TextColor3 = THEME.Text,
    Font = Enum.Font.Gotham,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = "",
    Size = UDim2.new(1, -24, 0, 34),
    Position = UDim2.new(0, 12, 0, 10),
    ZIndex = 18,
}, Content)
U.corner(Search, 6)
U.stroke(Search)
U.padding(Search, 8)

local ContentScroll = U.new("ScrollingFrame", {
    Name = "FeatureList",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(1, -16, 1, -60),
    Position = UDim2.new(0, 8, 0, 54),
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = THEME.Purple,
    ZIndex = 15,
}, Content)

U.new("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, ContentScroll)
U.padding(ContentScroll, 8)

-- =========================================================
-- UI BUILDER
-- =========================================================

local Connections = {}

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(Connections, connection)
    return connection
end

local function clearConnections()
    for _, connection in ipairs(Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(Connections)
end

local function clearContent()
    clearConnections()
    for _, child in ipairs(ContentScroll:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end
end

local function section(text, order)
    local label = U.new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "▸ " .. text,
        TextColor3 = THEME.Purple2,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -8, 0, 22),
        LayoutOrder = order or 0,
    }, ContentScroll)
    return label
end

local function button(text, callback, order)
    local b = U.new("TextButton", {
        BackgroundColor3 = THEME.Panel,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = THEME.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        AutoButtonColor = false,
        Size = UDim2.new(1, -8, 0, 36),
        LayoutOrder = order or 0,
    }, ContentScroll)

    U.corner(b, 8)
    U.stroke(b)

    connect(b.MouseEnter, function()
        U.tween(b, 0.12, {BackgroundColor3 = THEME.Panel2})
    end)

    connect(b.MouseLeave, function()
        U.tween(b, 0.12, {BackgroundColor3 = THEME.Panel})
    end)

    connect(b.MouseButton1Click, function()
        if callback then
            U.safe(callback)
        end
    end)

    return b
end

local function toggle(text, key, default, callback, order)
    local row = U.new("Frame", {
        BackgroundColor3 = THEME.Panel,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -8, 0, 38),
        LayoutOrder = order or 0,
    }, ContentScroll)

    U.corner(row, 10)
    U.stroke(row)

    U.new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = text,
        TextColor3 = THEME.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
    }, row)

    local value = State.Toggles[key]
    if value == nil then
        value = default or false
        State.Toggles[key] = value
    end

    local track = U.new("Frame", {
        BackgroundColor3 = value and THEME.Purple2 or THEME.Panel2,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(46, 22),
        Position = UDim2.new(1, -58, 0.5, -11),
    }, row)
    U.corner(track, 11)

    local knob = U.new("Frame", {
        BackgroundColor3 = THEME.Text,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(18, 18),
        Position = value
            and UDim2.new(1, -20, 0.5, -9)
            or UDim2.new(0, 2, 0.5, -9),
    }, track)
    U.corner(knob, 9)

    local hit = U.new("TextButton", {
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.fromScale(1, 1),
    }, row)

    connect(hit.MouseButton1Click, function()
        value = not value
        State.Toggles[key] = value

        U.tween(track, 0.16, {
            BackgroundColor3 = value and THEME.Purple2 or THEME.Panel2
        })

        U.tween(knob, 0.16, {
            Position = value
                and UDim2.new(1, -20, 0.5, -9)
                or UDim2.new(0, 2, 0.5, -9)
        })

        if callback then
            U.safe(function()
                callback(value)
            end)
        end
    end)

    return row
end

local function dropdown(label, options, callback, order, stateKey)
    local row = U.new("Frame", {
        BackgroundColor3 = THEME.Panel,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -8, 0, 38),
        LayoutOrder = order or 0,
        ClipsDescendants = true,
    }, ContentScroll)

    U.corner(row, 8)
    U.stroke(row)

    local current = stateKey and State[stateKey] or nil
    if current == nil or current == "" then
        current = options[1] or "-"
    end

    local header = U.new("TextButton", {
        BackgroundTransparency = 1,
        Text = "  " .. label .. ": " .. tostring(current),
        TextColor3 = THEME.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        Size = UDim2.new(1, 0, 0, 38),
    }, row)

    local list = U.new("Frame", {
        BackgroundColor3 = THEME.Bg2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -16, 0, 0),
        Position = UDim2.new(0, 8, 0, 40),
        ClipsDescendants = true,
    }, row)
    U.corner(list, 6)

    U.new("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, list)

    local opened = false

    for index, option in ipairs(options) do
        local item = U.new("TextButton", {
            BackgroundColor3 = THEME.Panel,
            BorderSizePixel = 0,
            Text = "  " .. tostring(option),
            TextColor3 = THEME.Text,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            Size = UDim2.new(1, -8, 0, 28),
            LayoutOrder = index,
        }, list)

        U.corner(item, 4)

        connect(item.MouseEnter, function()
            U.tween(item, 0.1, {BackgroundColor3 = THEME.Panel2})
        end)

        connect(item.MouseLeave, function()
            U.tween(item, 0.1, {BackgroundColor3 = THEME.Panel})
        end)

        connect(item.MouseButton1Click, function()
            header.Text = "  " .. label .. ": " .. tostring(option)
            if stateKey then
                State[stateKey] = option
            end

            opened = false

            U.tween(row, 0.18, {
                Size = UDim2.new(1, -8, 0, 38)
            })

            U.tween(list, 0.18, {
                Size = UDim2.new(1, -16, 0, 0)
            })

            if callback then
                U.safe(function()
                    callback(option)
                end)
            end
        end)
    end

    connect(header.MouseButton1Click, function()
        opened = not opened
        local height = math.min(#options * 30 + 8, 180)

        U.tween(row, 0.18, {
            Size = UDim2.new(1, -8, 0, opened and (46 + height) or 38)
        })

        U.tween(list, 0.18, {
            Size = UDim2.new(1, -16, 0, opened and height or 0)
        })
    end)

    return row
end

local function slider(label, minValue, maxValue, defaultValue, callback, order, stateKey)
    local row = U.new("Frame", {
        BackgroundColor3 = THEME.Panel,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -8, 0, 50),
        LayoutOrder = order or 0,
    }, ContentScroll)

    U.corner(row, 8)
    U.stroke(row)

    U.new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = label,
        TextColor3 = THEME.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -90, 0, 18),
        Position = UDim2.new(0, 12, 0, 4),
    }, row)

    local value = stateKey and State[stateKey] or defaultValue
    value = tonumber(value) or defaultValue

    local valueLabel = U.new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = string.format("%.0f", value),
        TextColor3 = THEME.Purple2,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
        Size = UDim2.new(0, 66, 0, 18),
        Position = UDim2.new(1, -78, 0, 4),
    }, row)

    local bar = U.new("Frame", {
        BackgroundColor3 = THEME.Bg2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -24, 0, 8),
        Position = UDim2.new(0, 12, 0, 32),
    }, row)
    U.corner(bar, 4)

    local ratio = math.clamp((value - minValue) / math.max(maxValue - minValue, 1), 0, 1)

    local fill = U.new("Frame", {
        BackgroundColor3 = THEME.Purple2,
        BorderSizePixel = 0,
        Size = UDim2.new(ratio, 0, 1, 0),
    }, bar)
    U.corner(fill, 4)

    local knob = U.new("Frame", {
        BackgroundColor3 = THEME.Text,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(ratio, -7, 0.5, -7),
    }, bar)
    U.corner(knob, 7)

    local dragging = false

    local function setValue(x)
        if bar.AbsoluteSize.X <= 0 then return end

        local r = math.clamp(
            (x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,
            0,
            1
        )

        local newValue = minValue + (maxValue - minValue) * r
        newValue = math.floor(newValue + 0.5)

        fill.Size = UDim2.new(r, 0, 1, 0)
        knob.Position = UDim2.new(r, -7, 0.5, -7)
        valueLabel.Text = tostring(newValue)

        if stateKey then
            State[stateKey] = newValue
        end

        if callback then
            U.safe(function()
                callback(newValue)
            end)
        end
    end

    connect(bar.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setValue(input.Position.X)
        end
    end)

    connect(UserInputService.InputChanged, function(input)
        if not dragging then return end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            setValue(input.Position.X)
        end
    end)

    connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return row
end

-- =========================================================
-- DATA
-- =========================================================

local Data = {}

Data.Tools = {"Melee", "Sword", "Gun", "Blox Fruit"}

Data.Chips = {
    "Flame Chip", "Ice Chip", "Quake Chip", "Light Chip",
    "Dark Chip", "Magma Chip", "Rumble Chip", "Human Chip", "Bird Chip"
}

Data.Bosses = {
    "Gorilla King", "Bobby", "The Saw", "Yeti", "Vice Admiral",
    "Saber Expert", "Warden", "Chief Warden", "Swan", "Magma Admiral",
    "Fishman Lord", "Wysper", "Thunder God", "Cyborg", "Don Swan",
    "Darkbeard", "Order", "Cursed Captain", "Awakened Ice Admiral",
    "Stone", "Hydra Leader", "Kilo Admiral", "Captain Elephant",
    "Beautiful Pirate", "Longma", "Cursed Skeleton", "Island Empress",
    "Cake Queen"
}

Data.Materials = {
    "Bones", "Ectoplasm", "Gunpowder", "Scrap Metal", "Leather",
    "Magma Ore", "Fish Tail", "Mystic Droplet", "Vampire Fang",
    "Radioactive Material", "Shark Tooth", "Conjured Cocoa",
    "Demonic Wisp", "Dragon Scale", "Electric Wing", "Mutant Tooth"
}

Data.SeaMobs = {
    [1] = {"Sea Beast", "Pirate Ship", "Piranha", "Shark", "FishCrew Member"},
    [2] = {"Cursed Ship", "Big Sea Beast", "Ghost Pirate Ship", "Sea Monster"},
    [3] = {"Terror Shark", "Sea Emperor", "Leviathan", "Kraken"},
}

Data.Islands = {
    "All Islands", "Starter Island", "Jungle", "Pirate Village", "Desert",
    "Frozen Village", "Marine Fortress", "Lower Skylands", "Prison",
    "Colosseum", "Magma Village", "Underwater City", "Upper Skylands",
    "Fountain City"
}

Data.Quests = {
    {"Starter Island", "The Finale"},
    {"Jungle", "Perbaiki Zipline"},
    {"Jungle", "Kalahkan Monyet Pencuri"},
    {"Jungle", "Jatuhkan Pisang"},
    {"Pirate Village", "Bebaskan Kincir Angin"},
    {"Pirate Village", "Usir 3 Tavern Pirates"},
    {"Pirate Village", "Masak Stew"},
    {"Desert", "Selamatkan Hasan"},
    {"Desert", "Bersihkan 8 Rune/Pilar"},
    {"Desert", "Kumpulkan 10 Cactus Petals"},
    {"Frozen Village", "Bebaskan Ability Teacher"},
    {"Frozen Village", "Buat Snowman"},
    {"Frozen Village", "Hancurkan 3 Bongkahan Es Hijau"},
    {"Marine Fortress", "Pasang Bendera"},
    {"Marine Fortress", "Pertahankan Benteng"},
    {"Marine Fortress", "Hancurkan Bangunan"},
    {"Lower Skylands", "Cari Lightning Bolt"},
    {"Lower Skylands", "Usir Penyusup"},
    {"Lower Skylands", "Pukul Secret Cloud"},
    {"Prison", "Bantu 3 Tahanan Kabur"},
    {"Prison", "Ambil Kunci & Pink Coat"},
    {"Prison", "Atur Tuas"},
    {"Colosseum", "Selesaikan 3 Wave"},
    {"Colosseum", "Aktifkan 4 Patung"},
    {"Colosseum", "Hancurkan 18 Target 90s"},
    {"Magma Village", "Hadapi Gelombang Magma"},
    {"Magma Village", "Hancurkan Magma Drill"},
    {"Magma Village", "Hancurkan 5 Mini Lava Geyser"},
    {"Underwater City", "Naiki Bubble"},
    {"Underwater City", "Atur Crystal"},
    {"Underwater City", "Cari Black Pearl"},
    {"Upper Skylands", "Ambil Relic"},
    {"Upper Skylands", "Serang Awan Petir"},
    {"Upper Skylands", "Bunyikan Bell 6 Kali"},
    {"Fountain City", "Perbaiki Pipa Fountain"},
    {"Fountain City", "Kalahkan Megalo Brute"},
    {"Fountain City", "Perbaiki Kabel Junkyard"},
}

-- =========================================================
-- TABS
-- =========================================================

local Tabs = {}
local TabButtons = {}
local CurrentTab = nil

local function registerTab(name, builder)
    Tabs[name] = builder
end

local function showTab(name)
    if not Tabs[name] then return end

    CurrentTab = name
    clearContent()

    U.safe(function()
        Tabs[name]()
    end)

    for tabName, tabButton in pairs(TabButtons) do
        local selected = tabName == name
        U.tween(tabButton, 0.12, {
            BackgroundColor3 = selected and THEME.Purple or THEME.Bg2,
            TextColor3 = selected and THEME.Text or THEME.Muted,
        })
    end

    ContentScroll.CanvasPosition = Vector2.new(0, 0)
end

-- =========================================================
-- TAB BUILDERS
-- =========================================================

registerTab("Discord", function()
    section("Community", 1)

    button("Copy Discord Link", function()
        if setclipboard then
            pcall(setclipboard, BRAND.Discord)
            Notifications.Push("SUCCESS", "Discord", "Link copied.", 2)
        else
            Notifications.Push("WARNING", "Discord", BRAND.Discord, 3)
        end
    end, 2)

    section("Information", 10)
    button("SysxHub v" .. BRAND.Version, function() end, 11)
    button("UI Refactor / Diagnostic Build", function() end, 12)
end)

registerTab("Farm", function()
    section("Farm Config", 1)

    dropdown("Select Tool", Data.Tools, function(value)
        State.Tool = value
    end, 2, "Tool")

    slider("UI Scale", 50, 150, math.floor(UIScale.Scale * 100), function(value)
        UIScale.Scale = value / 100
    end, 3)

    slider("Farm Range", 100, 1000, State.FarmRange, function(value)
        State.FarmRange = value
    end, 4)

    section("Automation", 10)

    toggle("Auto Farm Level", "FarmLevel", false, function(on)
        Notifications.Push("WARNING", "Farm Level", on and
            "UI state ON; game logic not verified." or "OFF", 2)
    end, 11)

    toggle("Auto Farm Nearest", "FarmNearest", false, function(on)
        Notifications.Push("WARNING", "Farm Nearest", on and
            "UI state ON; game logic not verified." or "OFF", 2)
    end, 12)

    toggle("Auto Factory", "Factory", false, function(on)
        Notifications.Push("WARNING", "Factory", on and
            "UI state ON; game logic not verified." or "OFF", 2)
    end, 13)

    toggle("Auto Farm Ectoplasm", "Ectoplasm", false, function(on)
        Notifications.Push("WARNING", "Ectoplasm", on and
            "UI state ON; game logic not verified." or "OFF", 2)
    end, 14)

    section("Chest", 20)

    toggle("Auto Chest", "Chest", false, function(on)
        Notifications.Push("WARNING", "Chest", on and
            "UI state ON; game logic not verified." or "OFF", 2)
    end, 21)

    slider("Chest Range", 50, 500, State.ChestRange, function(value)
        State.ChestRange = value
    end, 22)

    section("Combat", 30)

    toggle("Auto Haki", "Haki", false, function(on)
        Notifications.Push("WARNING", "Haki", on and
            "Remote/game behavior not verified." or "OFF", 2)
    end, 31)

    toggle("Auto Ken", "Ken", false, function(on)
        Notifications.Push("WARNING", "Ken", on and
            "Remote/game behavior not verified." or "OFF", 2)
    end, 32)

    toggle("Auto Attack", "AutoAttack", false, function(on)
        Notifications.Push("WARNING", "Auto Attack", on and
            "Combat implementation not verified." or "OFF", 2)
    end, 33)
end)

registerTab("Boss", function()
    section("Boss", 1)

    dropdown("Select Boss", Data.Bosses, function(value)
        State.Boss = value
        Notifications.Push("INFO", "Boss", value, 2)
    end, 2, "Boss")

    section("Boss Combat", 10)

    toggle("Auto Kill Selected Boss", "BossKill", false, function(on)
        Notifications.Push("WARNING", "Boss Kill", on and
            "Targeting logic not verified." or "OFF", 2)
    end, 11)
end)

registerTab("Material", function()
    section("Material", 1)

    dropdown("Select Material", Data.Materials, function(value)
        State.Material = value
        Notifications.Push("INFO", "Material", value, 2)
    end, 2, "Material")

    section("Automation", 10)

    toggle("Auto Farm Material", "MaterialFarm", false, function(on)
        Notifications.Push("WARNING", "Material Farm", on and
            "Material targeting not verified." or "OFF", 2)
    end, 11)
end)

registerTab("Sea", function()
    section("Sea Config", 1)

    dropdown("Select Sea", {"Sea 1", "Sea 2", "Sea 3"}, function(value)
        State.Sea = tonumber(value:match("%d+")) or 1
        State.SeaMob = nil
        Notifications.Push("INFO", "Sea", value, 2)
        task.defer(function()
            if CurrentTab == "Sea" then
                showTab("Sea")
            end
        end)
    end, 2, "Sea")

    local mobs = Data.SeaMobs[tonumber(State.Sea) or 1] or {}
    local mobOptions = {"Select Sea Mob"}
    for _, mob in ipairs(mobs) do
        table.insert(mobOptions, mob)
    end

    dropdown("Enemies", mobOptions, function(value)
        if value ~= "Select Sea Mob" then
            State.SeaMob = value
            Notifications.Push("INFO", "Sea Mob", value, 2)
        end
    end, 3, "SeaMob")

    section("Sea Farm", 10)

    toggle("Auto Farm Sea", "SeaFarm", false, function(on)
        Notifications.Push("WARNING", "Sea Farm", on and
            "Sea target logic not verified." or "OFF", 2)
    end, 11)
end)

registerTab("Quests / Items", function()
    section("Secret Quest", 1)

    dropdown("Select Island", Data.Islands, function(value)
        State.Island = value == "All Islands" and nil or value
        State.Quest = nil

        task.defer(function()
            if CurrentTab == "Quests / Items" then
                showTab("Quests / Items")
            end
        end)
    end, 2, "Island")

    local questOptions = {"Select Quest"}

    for _, quest in ipairs(Data.Quests) do
        local island = quest[1]
        local name = quest[2]

        if not State.Island or State.Island == island then
            table.insert(questOptions, name .. " @" .. island)
        end
    end

    dropdown("Select Quest", questOptions, function(value)
        if value ~= "Select Quest" then
            State.Quest = value
            Notifications.Push("INFO", "Quest", value, 2)
        end
    end, 3, "Quest")

    button("Start Selected Quest", function()
        if not State.Quest then
            Notifications.Push("WARNING", "Quest", "Pilih quest dulu.", 2)
            return
        end

        Notifications.Push(
            "WARNING",
            "Quest",
            "Quest selected. Game-specific execution belum diverifikasi.",
            3
        )
    end, 4)

    section("Special Boss", 10)

    button("Kill Cake Prince", function()
        Notifications.Push("WARNING", "Cake Prince",
            "Execution belum diverifikasi.", 2)
    end, 11)

    button("Spawn / Kill Dough King", function()
        Notifications.Push("WARNING", "Dough King",
            "Execution belum diverifikasi.", 2)
    end, 12)

    button("Kill Soul Reaper", function()
        Notifications.Push("WARNING", "Soul Reaper",
            "Execution belum diverifikasi.", 2)
    end, 13)

    button("Spawn / Kill rip_indra", function()
        Notifications.Push("WARNING", "rip_indra",
            "Execution belum diverifikasi.", 2)
    end, 14)
end)

registerTab("Fruit / Raid", function()
    section("Raid", 1)

    dropdown("Select Chip", Data.Chips, function(value)
        State.Chip = value
    end, 2, "Chip")

    button("Start Raid", function()
        Notifications.Push("WARNING", "Raid",
            "Remote Raid belum diverifikasi.", 2)
    end, 3)

    section("Fruit", 10)

    button("Random Fruit", function()
        Notifications.Push("WARNING", "Random Fruit",
            "Remote purchase belum diverifikasi.", 2)
    end, 11)

    toggle("Auto Store Fruit", "StoreFruit", false, function(on)
        Notifications.Push("WARNING", "Store Fruit", on and
            "Storage logic belum diverifikasi." or "OFF", 2)
    end, 12)

    toggle("Tween Fruit → Spawn", "TweenFruit", false, function(on)
        Notifications.Push("WARNING", "Tween Fruit", on and
            "Fruit interaction belum diverifikasi." or "OFF", 2)
    end, 13)
end)

registerTab("Fishing", function()
    section("Fishing", 1)

    toggle("Auto Fish", "AutoFish", false, function(on)
        Notifications.Push("WARNING", "Auto Fish", on and
            "Fishing mechanics belum diverifikasi." or "OFF", 2)
    end, 2)

    toggle("Auto Cast", "AutoCast", false, function(on)
        Notifications.Push("WARNING", "Auto Cast", on and
            "Fishing mechanics belum diverifikasi." or "OFF", 2)
    end, 3)
end)

registerTab("Status", function()
    section("Runtime Status", 1)

    local status = U.new("TextLabel", {
        BackgroundColor3 = THEME.Panel,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        Text = "Status: Initializing...",
        TextColor3 = THEME.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -8, 0, 38),
        LayoutOrder = 2,
    }, ContentScroll)

    U.corner(status, 8)
    U.stroke(status)
    U.padding(status, 10)

    task.spawn(function()
        while status.Parent do
            status.Text = "Status: UI OK  |  Time: " .. os.date("%H:%M:%S")
            task.wait(1)
        end
    end)
end)

registerTab("PvP", function()
    section("Target", 1)

    local players = {"None"}
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= Player then
            table.insert(players, other.Name)
        end
    end

    dropdown("Select Player", players, function(value)
        State.Player = value
    end, 2, "Player")

    toggle("Aimbot (Smooth Cam)", "Aimbot", false, function(on)
        Notifications.Push("WARNING", "Aimbot",
            on and "Camera behavior is UI-controlled but targeting is not verified." or "OFF", 2)
    end, 3)

    toggle("Auto Attack Target", "TargetAttack", false, function(on)
        Notifications.Push("WARNING", "Target Attack",
            on and "Combat targeting not verified." or "OFF", 2)
    end, 4)
end)

registerTab("Stats", function()
    section("Stat Allocation", 1)

    toggle("Start Add Stats", "Stats", false, function(on)
        Notifications.Push("WARNING", "Stats",
            on and "Stat remote not verified." or "OFF", 2)
    end, 2)

    for index, stat in ipairs({"Melee", "Sword", "Gun", "Defense", "Blox Fruit"}) do
        slider(stat, 0, 100, State.StatValues[stat], function(value)
            State.StatValues[stat] = value
        end, index + 2)
    end
end)

registerTab("Misc", function()
    section("Server", 1)

    local jobId = U.new("TextLabel", {
        BackgroundColor3 = THEME.Panel,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        Text = "Job ID: " .. tostring(game.JobId),
        TextColor3 = THEME.Text,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -8, 0, 38),
        LayoutOrder = 2,
    }, ContentScroll)
    U.corner(jobId, 8)
    U.stroke(jobId)
    U.padding(jobId, 8)

    button("Copy Job ID", function()
        if setclipboard then
            pcall(setclipboard, game.JobId)
            Notifications.Push("SUCCESS", "Job ID", "Copied.", 2)
        else
            Notifications.Push("WARNING", "Job ID", game.JobId, 3)
        end
    end, 3)

    section("Utility", 10)

    button("Redeem All Code", function()
        Notifications.Push("WARNING", "Redeem",
            "Code remote belum diverifikasi.", 3)
    end, 11)

    toggle("Anti AFK", "AntiAFK", false, function(on)
        Notifications.Push("INFO", "Anti AFK", on and "ON" or "OFF", 2)
    end, 12)

    toggle("No Clip", "NoClip", false, function(on)
        Notifications.Push("WARNING", "No Clip",
            on and "Collision loop belum diaktifkan pada diagnostic build." or "OFF", 2)
    end, 13)

    toggle("Infinite Jump", "InfiniteJump", false, function(on)
        Notifications.Push("WARNING", "Infinite Jump",
            on and "Jump handler belum diverifikasi." or "OFF", 2)
    end, 14)

    toggle("Auto Attack", "MiscAttack", false, function(on)
        Notifications.Push("WARNING", "Auto Attack",
            on and "Combat loop belum diverifikasi." or "OFF", 2)
    end, 15)

    local fps = U.new("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "FPS: -",
        TextColor3 = THEME.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -8, 0, 20),
        LayoutOrder = 16,
    }, ContentScroll)

    task.spawn(function()
        local frames = 0
        local last = os.clock()

        while fps.Parent do
            frames += 1

            if os.clock() - last >= 1 then
                fps.Text = "FPS: " .. tostring(frames)
                frames = 0
                last = os.clock()
            end

            RunService.RenderStepped:Wait()
        end
    end)
end)

-- =========================================================
-- TAB LIST
-- =========================================================

local TabOrder = {
    "Discord",
    "Farm",
    "Boss",
    "Material",
    "Sea",
    "Quests / Items",
    "Fruit / Raid",
    "Fishing",
    "Status",
    "PvP",
    "Stats",
    "Misc",
}

for index, tabName in ipairs(TabOrder) do
    local tabButton = U.new("TextButton", {
        Name = "Tab_" .. tabName,
        BackgroundColor3 = THEME.Bg2,
        BorderSizePixel = 0,
        Text = "  " .. tabName,
        TextColor3 = THEME.Muted,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        Size = UDim2.new(1, -4, 0, 34),
        LayoutOrder = index,
    }, TabScroll)

    U.corner(tabButton, 6)
    TabButtons[tabName] = tabButton

    tabButton.MouseEnter:Connect(function()
        if CurrentTab ~= tabName then
            U.tween(tabButton, 0.1, {BackgroundColor3 = THEME.Panel})
        end
    end)

    tabButton.MouseLeave:Connect(function()
        if CurrentTab ~= tabName then
            U.tween(tabButton, 0.1, {BackgroundColor3 = THEME.Bg2})
        end
    end)

    tabButton.MouseButton1Click:Connect(function()
        showTab(tabName)
    end)
end

-- =========================================================
-- SEARCH
-- =========================================================

local SearchIndex = {
    {"Discord", "Join Discord"},
    {"Discord", "Version"},
    {"Farm", "Select Tool"},
    {"Farm", "UI Scale"},
    {"Farm", "Farm Range"},
    {"Farm", "Auto Farm Level"},
    {"Farm", "Auto Farm Nearest"},
    {"Farm", "Auto Factory"},
    {"Farm", "Auto Farm Ectoplasm"},
    {"Farm", "Auto Chest"},
    {"Farm", "Auto Haki"},
    {"Farm", "Auto Ken"},
    {"Farm", "Auto Attack"},
    {"Boss", "Select Boss"},
    {"Boss", "Auto Kill Selected Boss"},
    {"Material", "Select Material"},
    {"Material", "Auto Farm Material"},
    {"Sea", "Select Sea"},
    {"Sea", "Enemies"},
    {"Sea", "Auto Farm Sea"},
    {"Quests / Items", "Select Island"},
    {"Quests / Items", "Select Quest"},
    {"Quests / Items", "Start Selected Quest"},
    {"Fruit / Raid", "Select Chip"},
    {"Fruit / Raid", "Start Raid"},
    {"Fruit / Raid", "Random Fruit"},
    {"Fruit / Raid", "Auto Store Fruit"},
    {"Fishing", "Auto Fish"},
    {"Fishing", "Auto Cast"},
    {"PvP", "Select Player"},
    {"PvP", "Aimbot"},
    {"PvP", "Auto Attack Target"},
    {"Stats", "Start Add Stats"},
    {"Misc", "Copy Job ID"},
    {"Misc", "Redeem All Code"},
    {"Misc", "Anti AFK"},
    {"Misc", "No Clip"},
    {"Misc", "Infinite Jump"},
}

local SearchOverlay

Search:GetPropertyChangedSignal("Text"):Connect(function()
    local query = Search.Text:lower()

    if SearchOverlay then
        SearchOverlay:Destroy()
        SearchOverlay = nil
    end

    if query == "" then
        return
    end

    SearchOverlay = U.new("Frame", {
        BackgroundColor3 = THEME.Bg2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -16, 1, -60),
        Position = UDim2.new(0, 8, 0, 54),
        ZIndex = 50,
    }, Content)

    U.corner(SearchOverlay, 8)
    U.stroke(SearchOverlay, THEME.Purple)

    local layout = U.new("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, SearchOverlay)

    U.padding(SearchOverlay, 8)

    local found = 0

    for _, item in ipairs(SearchIndex) do
        local tabName = item[1]
        local featureName = item[2]

        if featureName:lower():find(query, 1, true)
            or tabName:lower():find(query, 1, true) then

            found += 1

            local result = U.new("TextButton", {
                BackgroundColor3 = THEME.Panel,
                BorderSizePixel = 0,
                Text = "  ▸ [" .. tabName .. "]  " .. featureName,
                TextColor3 = THEME.Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                Size = UDim2.new(1, -8, 0, 32),
                LayoutOrder = found,
                ZIndex = 51,
            }, SearchOverlay)

            U.corner(result, 6)

            result.MouseButton1Click:Connect(function()
                Search.Text = ""
                showTab(tabName)
            end)
        end
    end

    if found == 0 then
        U.new("TextLabel", {
            BackgroundTransparency = 1,
            Text = 'Not found: "' .. Search.Text .. '"',
            TextColor3 = THEME.Error,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            Size = UDim2.new(1, -8, 0, 30),
            ZIndex = 51,
        }, SearchOverlay)
    end
end)

-- =========================================================
-- OPEN / CLOSE
-- =========================================================

local OpenButton = U.new("ImageButton", {
    Name = "OpenButton",
    BackgroundColor3 = THEME.Purple,
    BorderSizePixel = 0,
    Image = BRAND.LogoAsset,
    ScaleType = Enum.ScaleType.Fit,
    Size = UDim2.fromOffset(72, 72),
    Position = UDim2.new(0, 18, 0.5, -36),
    AutoButtonColor = false,
    ZIndex = 200,
}, Gui)

U.corner(OpenButton, 36)
U.stroke(OpenButton, THEME.Purple2, 2)

local windowOpen = true

local function setWindow(open)
    windowOpen = open

    if open then
        Main.Visible = true
        U.tween(Main, 0.25, {
            Size = UDim2.fromOffset(CONFIG.Width, CONFIG.Height)
        })
    else
        local tw = U.tween(Main, 0.22, {
            Size = UDim2.fromOffset(0, 0)
        })

        tw.Completed:Connect(function()
            if not windowOpen then
                Main.Visible = false
            end
        end)
    end
end

OpenButton.MouseButton1Click:Connect(function()
    setWindow(not windowOpen)
end)

CloseButton.MouseButton1Click:Connect(function()
    setWindow(false)
end)

MinButton.MouseButton1Click:Connect(function()
    setWindow(false)
end)

local scaleSteps = {0.75, 0.85, 1, 1.1, 1.25}
local scaleIndex = 3

ScaleButton.MouseButton1Click:Connect(function()
    scaleIndex = (scaleIndex % #scaleSteps) + 1
    UIScale.Scale = scaleSteps[scaleIndex]
    Notifications.Push(
        "INFO",
        "UI Scale",
        tostring(math.floor(scaleSteps[scaleIndex] * 100)) .. "%",
        1.5
    )
end)

-- =========================================================
-- DRAG SUPPORT
-- =========================================================

local function makeDraggable(handle, target)
    local dragging = false
    local startPosition
    local startTargetPosition

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            startPosition = input.Position
            startTargetPosition = target.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            local delta = input.Position - startPosition

            target.Position = UDim2.new(
                startTargetPosition.X.Scale,
                startTargetPosition.X.Offset + delta.X,
                startTargetPosition.Y.Scale,
                startTargetPosition.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

makeDraggable(Header, Main)
makeDraggable(OpenButton, OpenButton)

-- =========================================================
-- MOBILE SAFE SETTINGS
-- =========================================================

if UserInputService.TouchEnabled then
    TabScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    ContentScroll.ScrollingDirection = Enum.ScrollingDirection.Y

    -- Start slightly smaller on small screens.
    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize

    if viewport and viewport.X < 700 then
        UIScale.Scale = 0.8
    end
end

-- =========================================================
-- SAFE CHARACTER RESET
-- =========================================================

Player.CharacterRemoving:Connect(function()
    -- Reset UI state only. No assumptions about game remotes.
    State.Toggles.AutoAttack = false
    State.Toggles.Chest = false
    State.Toggles.FarmLevel = false
    State.Toggles.FarmNearest = false
    State.Toggles.Aimbot = false
end)

-- =========================================================
-- INITIALIZE
-- =========================================================

showTab("Discord")

Notifications.Push(
    "SUCCESS",
    BRAND.Name,
    "UI loaded successfully. Game-dependent features require verification.",
    4
)

print("[SysxHub] UI loaded successfully | v" .. BRAND.Version)
