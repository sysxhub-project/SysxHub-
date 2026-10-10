
-- ============================================
-- SYSX HUB | FREEMIUM v1.2
-- Draggable Logo + Futuristic GUI
-- Roblox Studio LocalScript
-- ============================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- CONFIG
local HUB_NAME = "sysxhub"
local HUB_VERSION = "FREEMIUM | v1.2"

local a = "rbxassetid://107550524464972"

local C = {
    Dark = Color3.fromRGB(3, 7, 18),
    Panel = Color3.fromRGB(8, 17, 35),
    Card = Color3.fromRGB(12, 27, 51),
    Blue = Color3.fromRGB(0, 90, 230),
    Cyan = Color3.fromRGB(0, 200, 255),
    White = Color3.fromRGB(230, 242, 255),
    Muted = Color3.fromRGB(140, 163, 192),
    Green = Color3.fromRGB(50, 230, 150),
}

-- CLEAN OLD GUI
local old = PlayerGui:FindFirstChild(HUB_NAME)
if old then
    old:Destroy()
end

-- HELPER
local function Create(class, props, parent)
    local obj = Instance.new(class)

    for key, value in pairs(props or {}) do
        obj[key] = value
    end

    obj.Parent = parent
    return obj
end

local function Corner(obj, radius)
    Create("UICorner", {
        CornerRadius = UDim.new(0, radius)
    }, obj)
end

local function Stroke(obj, color, thickness)
    return Create("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = 0.1
    }, obj)
end

-- SCREEN GUI
local GUI = Create("ScreenGui", {
    Name = HUB_NAME,
    ResetOnSpawn = false,
    IgnoreGuiInset = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, PlayerGui)

-- ============================================
-- FLOATING LOGO
-- ============================================

local Logo = Create("ImageButton", {
    Name = "FloatingLogo",
    Size = UDim2.fromOffset(62, 62),
    Position = UDim2.new(0, 24, 0.4, 0),
    BackgroundColor3 = C.Dark,
    Image = a,
    ScaleType = Enum.ScaleType.Fit,
    AutoButtonColor = false,
    ZIndex = 10
}, GUI)

Corner(Logo, 17)
Stroke(Logo, C.Cyan, 2)

Create("UIGradient", {
    Color = ColorSequence.new(
        Color3.fromRGB(10, 40, 85),
        C.Dark
    ),
    Rotation = 45
}, Logo)

-- DRAG SUPPORT: MOUSE + TOUCH
local dragging = false
local dragStart
local startPos
local dragInput
local moved = false
local activeInput

Logo.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        moved = false
        activeInput = input
        dragStart = input.Position
        startPos = Logo.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                activeInput = nil
            end
        end)
    end
end)

Logo.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input == dragInput
        or (activeInput
        and activeInput.UserInputType == Enum.UserInputType.Touch
        and input == activeInput) then

        local delta = input.Position - dragStart

        if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then
            moved = true
        end

        Logo.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ============================================
-- MAIN WINDOW
-- ============================================

local Main = Create("Frame", {
    Name = "MainWindow",
    Size = UDim2.fromOffset(360, 300),
    Position = UDim2.new(0.5, -180, 0.5, -150),
    BackgroundColor3 = C.Dark,
    BorderSizePixel = 0,
    Visible = true,
    ClipsDescendants = true
}, GUI)

Corner(Main, 15)
Stroke(Main, C.Blue, 2)

Create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(11, 27, 54)),
        ColorSequenceKeypoint.new(1, C.Dark)
    }),
    Rotation = 35
}, Main)

-- HEADER
local Header = Create("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 72),
    BackgroundColor3 = C.Panel,
    BorderSizePixel = 0
}, Main)

Corner(Header, 14)

Create("Frame", {
    Position = UDim2.new(0, 0, 1, -10),
    Size = UDim2.new(1, 0, 0, 10),
    BackgroundColor3 = C.Panel,
    BorderSizePixel = 0
}, Header)

-- HUB LOGO
local HubIcon = Create("ImageLabel", {
    Name = "HubLogo",
    Size = UDim2.fromOffset(46, 46),
    Position = UDim2.fromOffset(12, 13),
    BackgroundTransparency = 1,
    Image = a,
    ScaleType = Enum.ScaleType.Fit
}, Header)

-- TITLE
Create("TextLabel", {
    Position = UDim2.fromOffset(66, 13),
    Size = UDim2.new(1, -115, 0, 26),
    BackgroundTransparency = 1,
    Text = HUB_NAME,
    TextColor3 = C.White,
    TextSize = 21,
    Font = Enum.Font.GothamBlack,
    TextXAlignment = Enum.TextXAlignment.Left
}, Header)

Create("TextLabel", {
    Position = UDim2.fromOffset(67, 40),
    Size = UDim2.new(1, -115, 0, 16),
    BackgroundTransparency = 1,
    Text = HUB_VERSION,
    TextColor3 = C.Cyan,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, Header)

-- CLOSE BUTTON
local Close = Create("TextButton", {
    Size = UDim2.fromOffset(27, 27),
    Position = UDim2.new(1, -36, 0, 9),
    BackgroundColor3 = Color3.fromRGB(55, 20, 35),
    Text = "×",
    TextColor3 = Color3.fromRGB(255, 110, 130),
    TextSize = 20,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false
}, Header)

Corner(Close, 8)

Close.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

-- PLAYER AVATAR
local Avatar = Create("ImageLabel", {
    Name = "PlayerAvatar",
    Size = UDim2.fromOffset(47, 47),
    Position = UDim2.fromOffset(16, 87),
    BackgroundColor3 = C.Card,
    Image = "",
    ScaleType = Enum.ScaleType.Crop
}, Main)

Corner(Avatar, 24)
Stroke(Avatar, C.Cyan, 2)

task.spawn(function()
    local success, image = pcall(function()
        return Players:GetUserThumbnailAsync(
            Player.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size100x100
        )
    end)

    if success and Avatar.Parent then
        Avatar.Image = image
    end
end)

Create("TextLabel", {
    Position = UDim2.fromOffset(76, 88),
    Size = UDim2.new(1, -90, 0, 23),
    BackgroundTransparency = 1,
    Text = Player.DisplayName,
    TextColor3 = C.White,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, Main)

Create("TextLabel", {
    Position = UDim2.fromOffset(77, 111),
    Size = UDim2.new(1, -90, 0, 17),
    BackgroundTransparency = 1,
    Text = "@" .. Player.Name,
    TextColor3 = C.Cyan,
    TextSize = 11,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left
}, Main)

-- STATUS
local Status = Create("TextLabel", {
    Position = UDim2.fromOffset(16, 150),
    Size = UDim2.new(1, -32, 0, 24),
    BackgroundColor3 = C.Card,
    Text = "●  SYSX HUB ONLINE",
    TextColor3 = C.Green,
    TextSize = 10,
    Font = Enum.Font.GothamBold
}, Main)

Corner(Status, 7)
Stroke(Status, Color3.fromRGB(25, 65, 85), 1)

-- DIVIDER
Create("Frame", {
    Position = UDim2.fromOffset(16, 184),
    Size = UDim2.new(1, -32, 0, 1),
    BackgroundColor3 = C.Blue,
    BorderSizePixel = 0
}, Main)

-- WELCOME TEXT
Create("TextLabel", {
    Position = UDim2.fromOffset(16, 195),
    Size = UDim2.new(1, -32, 0, 25),
    BackgroundTransparency = 1,
    Text = "Welcome to sysxhub",
    TextColor3 = C.White,
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, Main)

Create("TextLabel", {
    Position = UDim2.fromOffset(16, 222),
    Size = UDim2.new(1, -32, 0, 30),
    BackgroundTransparency = 1,
    Text = "Futuristic interface • Freemium edition",
    TextColor3 = C.Muted,
    TextSize = 10,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left
}, Main)

-- ACTION BUTTON
local Action = Create("TextButton", {
    Name = "ActionButton",
    Size = UDim2.new(1, -32, 0, 32),
    Position = UDim2.fromOffset(16, 258),
    BackgroundColor3 = C.Blue,
    Text = "SYSX HUB READY",
    TextColor3 = C.White,
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false
}, Main)

Corner(Action, 8)
Stroke(Action, C.Cyan, 1)

Action.MouseButton1Click:Connect(function()
    Action.Text = "INTERFACE ACTIVE"

    task.delay(1.5, function()
        if Action.Parent then
            Action.Text = "SYSX HUB READY"
        end
    end)
end)

-- LOGO CLICK TO TOGGLE GUI
Logo.Activated:Connect(function()
    if moved then
        moved = false
        return
    end

    Main.Visible = not Main.Visible

    if Main.Visible then
        Main.Size = UDim2.fromOffset(330, 275)

        TweenService:Create(
            Main,
            TweenInfo.new(0.2, Enum.EasingStyle.Back),
            {Size = UDim2.fromOffset(360, 300)}
        ):Play()
    end
end)

print("sysxhub freemium v1.2 loaded")
