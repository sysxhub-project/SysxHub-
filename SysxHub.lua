--[[
    SYSXHUB
    UI / STATE / SEA FILTER
    SAFE UI VERSION

    UI STRUCTURE:
    Discord
    Farm
      - Auto Farm Level
      - Auto Quest
      - Auto Kill Nearest
      - Boss
      - Material
    Quest / Items
      - Auto CDK
      - Auto Dark Dagger
      - Auto Soul Guitar
      - Auto Yama
      - Auto Tushita
      - Auto Buddy Sword
      - Auto Kill Indra
      - Auto Spawn Dough King
    Fruit / Raid
    Fishing
    Status
    PvP
    Stats
    Misc

    NOTE:
    Exploit / anti-cheat bypass / remote abuse execution
    tidak dijalankan.
]]

repeat task.wait() until game:IsLoaded()

--------------------------------------------------
-- SERVICES
--------------------------------------------------

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

local Player = Players.LocalPlayer
if not Player then
    return
end

local PlayerGui = Player:WaitForChild("PlayerGui")

--------------------------------------------------
-- REMOVE OLD UI
--------------------------------------------------

pcall(function()
    local old = PlayerGui:FindFirstChild("SysxHub")
    if old then
        old:Destroy()
    end
end)

--------------------------------------------------
-- CONFIG
--------------------------------------------------

local CONFIG = {
    Name = "SysxHub",
    Version = "3.0",
    Discord = "https://discord.gg/E5kQJW3hn",

    Theme = {
        Background = Color3.fromRGB(15, 12, 24),
        Secondary = Color3.fromRGB(24, 19, 38),
        Card = Color3.fromRGB(30, 24, 48),
        Accent = Color3.fromRGB(145, 75, 255),
        AccentDark = Color3.fromRGB(105, 50, 190),
        Text = Color3.fromRGB(245, 240, 255),
        Muted = Color3.fromRGB(165, 155, 185),
        Border = Color3.fromRGB(65, 48, 90)
    }
}

--------------------------------------------------
-- STATE
--------------------------------------------------

local State = {
    CurrentSea = "Unknown",

    AutoFarmLevel = false,
    AutoHaki = false,
    AutoFarmBoss = false,
    AutoFarmMaterial = false,
    AutoQuest = false,
    AutoKill = false,

    AutoCollectFruit = false,
    FruitSniper = false,
    AutoRaid = false,

    AutoFishing = false,
    AntiAFK = false,

    ESP = false,
    Aimbot = false,
    PvPMode = false,

    SelectedBoss = nil,
    SelectedMaterial = nil,

    Items = {
        CDK = false,
        DarkDagger = false,
        SoulGuitar = false,
        Yama = false,
        Tushita = false,
        BuddySword = false,
        KillIndra = false,
        SpawnDoughKing = false
    }
}

--------------------------------------------------
-- SEA DATA
--------------------------------------------------

local SeaData = {

    ["Sea 1"] = {
        Bosses = {
            "The Gorilla King",
            "Bobby",
            "Yeti",
            "Mob Leader",
            "Vice Admiral",
            "Saber Expert",
            "Jungle Pirate",
            "Cyborg",
            "Diamond",
            "Jeremy"
        },

        Materials = {
            "Leather",
            "Scrap Metal",
            "Angel Wings",
            "Gunpowder",
            "Magma Ore",
            "Fish Tail"
        }
    },

    ["Sea 2"] = {
        Bosses = {
            "Don Swan",
            "Smoke Admiral",
            "Cursed Captain",
            "Darkbeard",
            "Order",
            "Diamond",
            "Jeremy"
        },

        Materials = {
            "Radioactive Material",
            "Mystic Droplet",
            "Magma Ore",
            "Fish Tail",
            "Mini Tusk"
        }
    },

    ["Sea 3"] = {
        Bosses = {
            "Stone",
            "Hydra Enforcer",
            "Island Empress",
            "Kilo Admiral",
            "Captain Elephant",
            "Beautiful Pirate",
            "Cake Queen",
            "Longma",
            "Soul Reaper",
            "Cursed Skeleton"
        },

        Materials = {
            "Dragon Scale",
            "Cursed Dual Katana",
            "Vampire Fang",
            "Gunpowder",
            "Scrap Metal"
        }
    }
}

--------------------------------------------------
-- SEA DETECTION
--------------------------------------------------

local SeaPlaceIds = {
    [2753915549] = "Sea 1",
    [4442272183] = "Sea 2",
    [7449423635] = "Sea 3"
}

local function getCurrentSea()
    return SeaPlaceIds[game.PlaceId] or "Unknown"
end

local function getSeaData()
    return SeaData[State.CurrentSea]
end

local function getBossList()
    local data = getSeaData()

    if not data then
        return {}
    end

    return data.Bosses or {}
end

local function getMaterialList()
    local data = getSeaData()

    if not data then
        return {}
    end

    return data.Materials or {}
end

State.CurrentSea = getCurrentSea()

--------------------------------------------------
-- SAFE FEATURE HANDLER
--------------------------------------------------

local function SafeFeature(name, callback)
    task.spawn(function()
        local ok, err = pcall(callback)

        if not ok then
            warn("[SysxHub] " .. name .. " error:", err)
        end
    end)
end

--------------------------------------------------
-- GUI
--------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SysxHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

--------------------------------------------------
-- UI HELPERS
--------------------------------------------------

local function corner(object, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = object
    return c
end

local function stroke(object, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = 0.25
    s.Parent = object
    return s
end

local function padding(object, value)
    local p = Instance.new("UIPadding")

    p.PaddingTop = UDim.new(0, value)
    p.PaddingBottom = UDim.new(0, value)
    p.PaddingLeft = UDim.new(0, value)
    p.PaddingRight = UDim.new(0, value)

    p.Parent = object
end

local function makeText(parent, text, size, color, bold)
    local label = Instance.new("TextLabel")

    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or CONFIG.Theme.Text
    label.TextSize = size or 14
    label.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent

    return label
end

local function tween(object, properties, duration)
    local ok = pcall(function()
        TweenService:Create(
            object,
            TweenInfo.new(
                duration or 0.2,
                Enum.EasingStyle.Quart,
                Enum.EasingDirection.Out
            ),
            properties
        ):Play()
    end)

    return ok
end

--------------------------------------------------
-- MAIN
--------------------------------------------------

local Main = Instance.new("Frame")
Main.Name = "Main"

Main.Size = UDim2.new(0, 720, 0, 480)
Main.Position = UDim2.new(0.5, -360, 0.5, -240)

Main.BackgroundColor3 = CONFIG.Theme.Background
Main.BorderSizePixel = 0

Main.Parent = ScreenGui

corner(Main, 14)
stroke(Main, CONFIG.Theme.Border, 1)

--------------------------------------------------
-- HEADER
--------------------------------------------------

local Header = Instance.new("Frame")

Header.Size = UDim2.new(1, 0, 0, 58)
Header.BackgroundColor3 = CONFIG.Theme.Secondary
Header.BorderSizePixel = 0

Header.Parent = Main

corner(Header, 14)

local Title = makeText(
    Header,
    "SysxHub",
    21,
    CONFIG.Theme.Text,
    true
)

Title.Position = UDim2.new(0, 18, 0, 8)
Title.Size = UDim2.new(0, 250, 0, 24)

local Version = makeText(
    Header,
    "v" .. CONFIG.Version,
    11,
    CONFIG.Theme.Muted,
    false
)

Version.Position = UDim2.new(0, 19, 0, 33)
Version.Size = UDim2.new(0, 100, 0, 16)

local SeaLabel = makeText(
    Header,
    "Current Sea: " .. State.CurrentSea,
    12,
    CONFIG.Theme.Muted,
    false
)

SeaLabel.Position = UDim2.new(1, -210, 0, 21)
SeaLabel.Size = UDim2.new(0, 160, 0, 18)
SeaLabel.TextXAlignment = Enum.TextXAlignment.Right

--------------------------------------------------
-- CLOSE
--------------------------------------------------

local Close = Instance.new("TextButton")

Close.Size = UDim2.new(0, 38, 0, 32)
Close.Position = UDim2.new(1, -45, 0, 13)

Close.BackgroundColor3 = CONFIG.Theme.Card
Close.Text = "×"

Close.TextSize = 20
Close.TextColor3 = CONFIG.Theme.Text
Close.Font = Enum.Font.GothamBold

Close.BorderSizePixel = 0
Close.Parent = Main

corner(Close, 8)

--------------------------------------------------
-- SIDEBAR
--------------------------------------------------

local Sidebar = Instance.new("Frame")

Sidebar.Position = UDim2.new(0, 0, 0, 58)
Sidebar.Size = UDim2.new(0, 175, 1, -58)

Sidebar.BackgroundColor3 = CONFIG.Theme.Secondary
Sidebar.BorderSizePixel = 0

Sidebar.Parent = Main

padding(Sidebar, 10)

local SideLayout = Instance.new("UIListLayout")

SideLayout.Padding = UDim.new(0, 6)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder

SideLayout.Parent = Sidebar

--------------------------------------------------
-- CONTENT
--------------------------------------------------

local Content = Instance.new("Frame")

Content.Position = UDim2.new(0, 175, 0, 58)
Content.Size = UDim2.new(1, -175, 1, -58)

Content.BackgroundTransparency = 1
Content.Parent = Main

--------------------------------------------------
-- PAGES
--------------------------------------------------

local Pages = {}
local TabButtons = {}

local function createPage(name)

    local Page = Instance.new("ScrollingFrame")

    Page.Name = name
    Page.Size = UDim2.new(1, 0, 1, 0)

    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0

    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = CONFIG.Theme.Accent

    Page.Visible = false

    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)

    Page.Parent = Content

    padding(Page, 15)

    local layout = Instance.new("UIListLayout")

    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    layout.Parent = Page

    Pages[name] = Page

    return Page
end

local function selectTab(name)

    for tabName, page in pairs(Pages) do
        page.Visible = tabName == name
    end

    for tabName, button in pairs(TabButtons) do

        if tabName == name then

            button.BackgroundColor3 = CONFIG.Theme.Accent
            button.TextColor3 = CONFIG.Theme.Text

        else

            button.BackgroundColor3 = CONFIG.Theme.Card
            button.TextColor3 = CONFIG.Theme.Muted

        end

    end

end

local function createTab(name)

    local Button = Instance.new("TextButton")

    Button.Name = name
    Button.Size = UDim2.new(1, 0, 0, 38)

    Button.BackgroundColor3 = CONFIG.Theme.Card

    Button.Text = name
    Button.TextColor3 = CONFIG.Theme.Muted

    Button.TextSize = 13
    Button.Font = Enum.Font.GothamMedium

    Button.BorderSizePixel = 0

    Button.Parent = Sidebar

    corner(Button, 8)

    local Page = createPage(name)

    Button.MouseButton1Click:Connect(function()
        selectTab(name)
    end)

    TabButtons[name] = Button

    return Page
end

--------------------------------------------------
-- SECTION
--------------------------------------------------

local function createSection(parent, title)

    local Frame = Instance.new("Frame")

    Frame.Size = UDim2.new(1, 0, 0, 36)
    Frame.BackgroundTransparency = 1

    Frame.Parent = parent

    local Label = makeText(
        Frame,
        title,
        15,
        CONFIG.Theme.Accent,
        true
    )

    Label.Size = UDim2.new(1, 0, 1, 0)

    return Frame
end

--------------------------------------------------
-- TOGGLE
--------------------------------------------------

local function createToggle(parent, text, callback)

    local Button = Instance.new("TextButton")

    Button.Size = UDim2.new(1, 0, 0, 44)

    Button.BackgroundColor3 = CONFIG.Theme.Card

    Button.Text = ""
    Button.BorderSizePixel = 0

    Button.Parent = parent

    corner(Button, 8)

    local Label = makeText(
        Button,
        text,
        13,
        CONFIG.Theme.Text,
        false
    )

    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.Size = UDim2.new(1, -80, 1, 0)

    local Status = makeText(
        Button,
        "OFF",
        12,
        CONFIG.Theme.Muted,
        true
    )

    Status.Position = UDim2.new(1, -55, 0, 0)
    Status.Size = UDim2.new(0, 45, 1, 0)

    Status.TextXAlignment = Enum.TextXAlignment.Center

    local enabled = false

    Button.MouseButton1Click:Connect(function()

        enabled = not enabled

        Status.Text = enabled and "ON" or "OFF"

        Status.TextColor3 =
            enabled
            and CONFIG.Theme.Accent
            or CONFIG.Theme.Muted

        SafeFeature(text, function()
            callback(enabled)
        end)

    end)

    return Button
end

--------------------------------------------------
-- INFO
--------------------------------------------------

local function createInfo(parent, title, value)

    local Frame = Instance.new("Frame")

    Frame.Size = UDim2.new(1, 0, 0, 44)

    Frame.BackgroundColor3 = CONFIG.Theme.Card
    Frame.BorderSizePixel = 0

    Frame.Parent = parent

    corner(Frame, 8)

    local A = makeText(
        Frame,
        title,
        13,
        CONFIG.Theme.Text,
        false
    )

    A.Position = UDim2.new(0, 14, 0, 0)
    A.Size = UDim2.new(0.5, 0, 1, 0)

    local B = makeText(
        Frame,
        value,
        12,
        CONFIG.Theme.Muted,
        false
    )

    B.Position = UDim2.new(0.5, 0, 0, 0)
    B.Size = UDim2.new(0.5, -14, 1, 0)

    B.TextXAlignment = Enum.TextXAlignment.Right

    return Frame, B
end

--------------------------------------------------
-- DROPDOWN
--------------------------------------------------

local function createDropdown(parent, title, getOptions, callback)

    local Frame = Instance.new("Frame")

    Frame.Size = UDim2.new(1, 0, 0, 44)

    Frame.BackgroundColor3 = CONFIG.Theme.Card
    Frame.BorderSizePixel = 0

    Frame.ClipsDescendants = true

    Frame.Parent = parent

    corner(Frame, 8)

    local Button = Instance.new("TextButton")

    Button.Size = UDim2.new(1, 0, 0, 44)

    Button.BackgroundTransparency = 1

    Button.Text = ""

    Button.Parent = Frame

    local Label = makeText(
        Frame,
        title,
        13,
        CONFIG.Theme.Text,
        false
    )

    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.Size = UDim2.new(0.45, 0, 0, 44)

    local Selected = makeText(
        Frame,
        "None",
        12,
        CONFIG.Theme.Muted,
        false
    )

    Selected.Position = UDim2.new(0.45, 0, 0, 0)
    Selected.Size = UDim2.new(0.55, -14, 0, 44)

    Selected.TextXAlignment = Enum.TextXAlignment.Right

    local open = false

    local function clearOptions()

        for _, child in ipairs(Frame:GetChildren()) do

            if child:GetAttribute("SysxOption") then
                child:Destroy()
            end

        end

    end

    Button.MouseButton1Click:Connect(function()

        open = not open

        clearOptions()

        if not open then

            Frame.Size = UDim2.new(1, 0, 0, 44)

            return

        end

        local options = {}

        local ok = pcall(function()
            options = getOptions() or {}
        end)

        if not ok then
            options = {}
        end

        local maxOptions = math.min(#options, 8)

        Frame.Size = UDim2.new(
            1,
            0,
            0,
            44 + (maxOptions * 34)
        )

        for i = 1, maxOptions do

            local option = options[i]

            local Option = Instance.new("TextButton")

            Option:SetAttribute("SysxOption", true)

            Option.Size = UDim2.new(1, -20, 0, 30)

            Option.Position = UDim2.new(
                0,
                10,
                0,
                46 + ((i - 1) * 34)
            )

            Option.BackgroundColor3 = CONFIG.Theme.Secondary

            Option.Text = tostring(option)

            Option.TextColor3 = CONFIG.Theme.Text
            Option.TextSize = 11
            Option.Font = Enum.Font.Gotham

            Option.BorderSizePixel = 0

            Option.Parent = Frame

            corner(Option, 6)

            Option.MouseButton1Click:Connect(function()

                Selected.Text = tostring(option)

                SafeFeature(title, function()
                    callback(option)
                end)

                open = false

                clearOptions()

                Frame.Size = UDim2.new(
                    1,
                    0,
                    0,
                    44
                )

            end)

        end

    end)

    return Frame
end

--------------------------------------------------
-- TABS
--------------------------------------------------

local DiscordPage = createTab("Discord")
local FarmPage = createTab("Farm")
local QuestPage = createTab("Quest / Items")
local FruitPage = createTab("Fruit / Raid")
local FishingPage = createTab("Fishing")
local StatusPage = createTab("Status")
local PvPPage = createTab("PvP")
local StatsPage = createTab("Stats")
local MiscPage = createTab("Misc")

--------------------------------------------------
-- DISCORD
--------------------------------------------------

createSection(
    DiscordPage,
    "SysxHub Community"
)

createInfo(
    DiscordPage,
    "Discord",
    CONFIG.Discord
)

local DiscordButton = Instance.new("TextButton")

DiscordButton.Size = UDim2.new(1, 0, 0, 44)

DiscordButton.BackgroundColor3 = CONFIG.Theme.Accent

DiscordButton.Text = "Copy Discord Link"

DiscordButton.TextColor3 = CONFIG.Theme.Text
DiscordButton.TextSize = 13
DiscordButton.Font = Enum.Font.GothamBold

DiscordButton.BorderSizePixel = 0

DiscordButton.Parent = DiscordPage

corner(DiscordButton, 8)

DiscordButton.MouseButton1Click:Connect(function()

    pcall(function()

        if setclipboard then
            setclipboard(CONFIG.Discord)
        end

    end)

end)

--------------------------------------------------
-- FARM
--------------------------------------------------

createSection(
    FarmPage,
    "Level Farming"
)

createToggle(
    FarmPage,
    "Auto Farm Level",
    function(value)

        State.AutoFarmLevel = value

        -- Auto Haki mengikuti Auto Farm Level
        State.AutoHaki = value

    end
)

createToggle(
    FarmPage,
    "Auto Quest",
    function(value)
        State.AutoQuest = value
    end
)

createToggle(
    FarmPage,
    "Auto Kill Nearest",
    function(value)
        State.AutoKill = value
    end
)

--------------------------------------------------
-- BOSS
--------------------------------------------------

createSection(
    FarmPage,
    "Boss"
)

createDropdown(
    FarmPage,
    "Select Boss",
    getBossList,
    function(value)
        State.SelectedBoss = value
    end
)

createToggle(
    FarmPage,
    "Auto Farm Boss",
    function(value)
        State.AutoFarmBoss = value
    end
)

--------------------------------------------------
-- MATERIAL
--------------------------------------------------

createSection(
    FarmPage,
    "Material"
)

createDropdown(
    FarmPage,
    "Select Material",
    getMaterialList,
    function(value)
        State.SelectedMaterial = value
    end
)

createToggle(
    FarmPage,
    "Auto Farm Material",
    function(value)
        State.AutoFarmMaterial = value
    end
)

--------------------------------------------------
-- QUEST / ITEMS
--------------------------------------------------

createSection(
    QuestPage,
    "Weapon Quest"
)

local ItemNames = {

    {
        "Auto CDK",
        "CDK"
    },

    {
        "Auto Dark Dagger",
        "DarkDagger"
    },

    {
        "Auto Soul Guitar",
        "SoulGuitar"
    },

    {
        "Auto Yama",
        "Yama"
    },

    {
        "Auto Tushita",
        "Tushita"
    },

    {
        "Auto Buddy Sword",
        "BuddySword"
    }

}

for _, item in ipairs(ItemNames) do

    createToggle(
        QuestPage,
        item[1],
        function(value)

            State.Items[item[2]] = value

        end
    )

end

createSection(
    QuestPage,
    "Special Quest"
)

createToggle(
    QuestPage,
    "Auto Kill Indra",
    function(value)

        State.Items.KillIndra = value

    end
)

createToggle(
    QuestPage,
    "Auto Spawn Dough King",
    function(value)

        State.Items.SpawnDoughKing = value

    end
)

--------------------------------------------------
-- FRUIT / RAID
--------------------------------------------------

createSection(
    FruitPage,
    "Fruit"
)

createToggle(
    FruitPage,
    "Auto Collect Fruit",
    function(value)

        State.AutoCollectFruit = value

    end
)

createToggle(
    FruitPage,
    "Fruit Sniper",
    function(value)

        State.FruitSniper = value

    end
)

createSection(
    FruitPage,
    "Raid"
)

createToggle(
    FruitPage,
    "Auto Raid",
    function(value)

        State.AutoRaid = value

    end
)

--------------------------------------------------
-- FISHING
--------------------------------------------------

createSection(
    FishingPage,
    "Fishing"
)

createToggle(
    FishingPage,
    "Auto Fishing",
    function(value)

        State.AutoFishing = value

    end
)

createToggle(
    FishingPage,
    "Auto Catch",
    function(value)

        State.AutoFishing = value

    end
)

--------------------------------------------------
-- STATUS
--------------------------------------------------

createSection(
    StatusPage,
    "Current Session"
)

local CurrentSeaInfo, CurrentSeaValue =
    createInfo(
        StatusPage,
        "Current Sea",
        State.CurrentSea
    )

createInfo(
    StatusPage,
    "Place ID",
    tostring(game.PlaceId)
)

local function updateSeaUI()

    State.CurrentSea = getCurrentSea()

    CurrentSeaValue.Text = State.CurrentSea

    SeaLabel.Text =
        "Current Sea: "
        .. State.CurrentSea

end

updateSeaUI()

--------------------------------------------------
-- PVP
--------------------------------------------------

createSection(
    PvPPage,
    "PvP"
)

createToggle(
    PvPPage,
    "PvP Mode",
    function(value)

        State.PvPMode = value

    end
)

createToggle(
    PvPPage,
    "ESP Players",
    function(value)

        State.ESP = value

    end
)

createToggle(
    PvPPage,
    "Aimbot",
    function(value)

        State.Aimbot = value

    end
)

createInfo(
    PvPPage,
    "Current Target",
    "Auto"
)

--------------------------------------------------
-- STATS
--------------------------------------------------

createSection(
    StatsPage,
    "Stats"
)

createInfo(
    StatsPage,
    "Melee",
    "Auto"
)

createInfo(
    StatsPage,
    "Defense",
    "Auto"
)

createInfo(
    StatsPage,
    "Sword",
    "Auto"
)

createInfo(
    StatsPage,
    "Gun",
    "Auto"
)

--------------------------------------------------
-- MISC
--------------------------------------------------

createSection(
    MiscPage,
    "Utilities"
)

createToggle(
    MiscPage,
    "Anti AFK",
    function(value)

        State.AntiAFK = value

    end
)

--------------------------------------------------
-- REJOIN
--------------------------------------------------

local Rejoin = Instance.new("TextButton")

Rejoin.Size = UDim2.new(1, 0, 0, 44)

Rejoin.BackgroundColor3 = CONFIG.Theme.Card

Rejoin.Text = "Rejoin Server"

Rejoin.TextColor3 = CONFIG.Theme.Text
Rejoin.TextSize = 13
Rejoin.Font = Enum.Font.Gotham

Rejoin.BorderSizePixel = 0

Rejoin.Parent = MiscPage

corner(Rejoin, 8)

Rejoin.MouseButton1Click:Connect(function()

    pcall(function()

        TeleportService:Teleport(
            game.PlaceId,
            Player
        )

    end)

end)

--------------------------------------------------
-- DRAGGING
--------------------------------------------------

local dragging = false
local dragStart = nil
local startPosition = nil

Header.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true

        dragStart = input.Position
        startPosition = Main.Position

        input.Changed:Connect(function()

            if input.UserInputState
                == Enum.UserInputState.End then

                dragging = false

            end

        end)

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then

        return
    end

    local delta =
        input.Position - dragStart

    Main.Position = UDim2.new(

        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,

        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y

    )

end)

--------------------------------------------------
-- OPEN / CLOSE
--------------------------------------------------

local OpenButton = Instance.new("TextButton")

OpenButton.Size = UDim2.new(0, 52, 0, 52)

OpenButton.Position =
    UDim2.new(0, 20, 0.5, -26)

OpenButton.BackgroundColor3 =
    CONFIG.Theme.Accent

OpenButton.Text = "S"

OpenButton.TextColor3 =
    CONFIG.Theme.Text

OpenButton.TextSize = 22
OpenButton.Font = Enum.Font.GothamBold

OpenButton.BorderSizePixel = 0

OpenButton.Visible = false

OpenButton.Parent = ScreenGui

corner(OpenButton, 14)

Close.MouseButton1Click:Connect(function()

    Main.Visible = false
    OpenButton.Visible = true

end)

OpenButton.MouseButton1Click:Connect(function()

    Main.Visible = true
    OpenButton.Visible = false

end)

--------------------------------------------------
-- SEA REFRESH
--------------------------------------------------

task.spawn(function()

    local lastSea = State.CurrentSea

    while ScreenGui.Parent do

        task.wait(2)

        local newSea = getCurrentSea()

        if newSea ~= lastSea then

            lastSea = newSea

            State.CurrentSea = newSea

            State.SelectedBoss = nil
            State.SelectedMaterial = nil

            updateSeaUI()

        end

    end

end)

--------------------------------------------------
-- DEFAULT TAB
--------------------------------------------------

selectTab("Farm")

--------------------------------------------------
-- FINAL
--------------------------------------------------

print("--------------------------------")
print("SysxHub " .. CONFIG.Version)
print("UI Loaded Successfully")
print("Current Sea:", State.CurrentSea)
print("--------------------------------")
