--// =========================================================
--// SYSX HUB - UI SAFE BUILD
--// Mobile Responsive / Dark Purple
--// =========================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
if not Player then
	warn("[SysxHub] LocalPlayer tidak ditemukan. Pastikan ini LocalScript.")
	return
end

local PlayerGui = Player:WaitForChild("PlayerGui")

--============================================================
-- CONFIG
--============================================================

local CONFIG = {
	Name = "SysxHub",

	Logo = "rbxassetid://136425814447688",
	OpenClose = "rbxassetid://70792832229220",

	Discord = "https://discord.gg/E5kQJW3hn",

	Background = Color3.fromRGB(10, 8, 18),
	Panel = Color3.fromRGB(17, 13, 29),
	Panel2 = Color3.fromRGB(23, 18, 38),

	Purple = Color3.fromRGB(125, 70, 255),
	Purple2 = Color3.fromRGB(155, 100, 255),

	Text = Color3.fromRGB(245, 242, 255),
	SubText = Color3.fromRGB(165, 158, 185),

	Radius = 10,
}

--============================================================
-- CLEAN OLD UI
--============================================================

local old = PlayerGui:FindFirstChild("SysxHub")
if old then
	old:Destroy()
end

--============================================================
-- HELPERS
--============================================================

local function Create(className, props)
	local obj = Instance.new(className)

	for property, value in pairs(props or {}) do
		pcall(function()
			obj[property] = value
		end)
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

local function Padding(parent, left, right, top, bottom)
	local p = Instance.new("UIPadding")
	p.PaddingLeft = UDim.new(0, left or 0)
	p.PaddingRight = UDim.new(0, right or 0)
	p.PaddingTop = UDim.new(0, top or 0)
	p.PaddingBottom = UDim.new(0, bottom or 0)
	p.Parent = parent
	return p
end

local function Tween(obj, properties, time)
	TweenService:Create(
		obj,
		TweenInfo.new(time or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		properties
	):Play()
end

--============================================================
-- SCREEN GUI
--============================================================

local Gui = Create("ScreenGui", {
	Name = "SysxHub",
	Parent = PlayerGui,

	ResetOnSpawn = false,
	IgnoreGuiInset = true,

	DisplayOrder = 999999,
	ZIndexBehavior = Enum.ZIndexBehavior.Global,
})

--============================================================
-- SCALE
--============================================================

local UIScale = Instance.new("UIScale")
UIScale.Scale = 1
UIScale.Parent = Gui

local function UpdateScale()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	local viewport = camera.ViewportSize

	if viewport.X <= 500 then
		UIScale.Scale = math.clamp(viewport.X / 420, 0.82, 1)
	elseif viewport.X <= 800 then
		UIScale.Scale = 0.9
	else
		UIScale.Scale = 1
	end
end

UpdateScale()

if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)
end

--============================================================
-- OPEN BUTTON
--============================================================

local OpenButton = Create("ImageButton", {
	Name = "OpenButton",

	Parent = Gui,

	BackgroundColor3 = CONFIG.Panel,
	BackgroundTransparency = 0.05,

	Size = UDim2.fromOffset(54, 54),

	Position = UDim2.new(0, 18, 0.5, -27),

	Image = CONFIG.OpenClose,
	ImageTransparency = 0,

	AutoButtonColor = false,

	Visible = true,

	ZIndex = 100,
})

Corner(OpenButton, 14)
Stroke(OpenButton, CONFIG.Purple, 1, 0.25)

local OpenFallback = Create("TextLabel", {
	Name = "Fallback",

	Parent = OpenButton,

	BackgroundTransparency = 1,

	Size = UDim2.fromScale(1, 1),

	Text = "S",
	TextColor3 = CONFIG.Text,

	TextSize = 24,
	Font = Enum.Font.GothamBold,

	ZIndex = 101,
})

--============================================================
-- MAIN
--============================================================

local Main = Create("Frame", {
	Name = "Main",

	Parent = Gui,

	AnchorPoint = Vector2.new(0.5, 0.5),

	Position = UDim2.fromScale(0.5, 0.5),

	Size = UDim2.new(0, 760, 0, 480),

	BackgroundColor3 = CONFIG.Background,

	BorderSizePixel = 0,

	Visible = true,

	ZIndex = 10,
})

Corner(Main, 14)
Stroke(Main, CONFIG.Purple, 1, 0.45)

-- Mobile constraint
local MainConstraint = Instance.new("UISizeConstraint")
MainConstraint.MaxSize = Vector2.new(850, 560)
MainConstraint.MinSize = Vector2.new(310, 360)
MainConstraint.Parent = Main

--============================================================
-- TOP BAR
--============================================================

local TopBar = Create("Frame", {
	Name = "TopBar",

	Parent = Main,

	BackgroundColor3 = CONFIG.Panel,

	Size = UDim2.new(1, 0, 0, 64),

	BorderSizePixel = 0,

	ZIndex = 20,
})

Corner(TopBar, 14)

local Logo = Create("ImageLabel", {
	Name = "Logo",

	Parent = TopBar,

	BackgroundTransparency = 1,

	Size = UDim2.fromOffset(42, 42),

	Position = UDim2.new(0, 12, 0.5, -21),

	Image = CONFIG.Logo,

	ScaleType = Enum.ScaleType.Fit,

	ZIndex = 21,
})

local Title = Create("TextLabel", {
	Name = "Title",

	Parent = TopBar,

	BackgroundTransparency = 1,

	Position = UDim2.new(0, 62, 0, 9),

	Size = UDim2.new(0, 250, 0, 25),

	Text = "SysxHub",

	TextColor3 = CONFIG.Text,

	TextSize = 20,

	Font = Enum.Font.GothamBold,

	TextXAlignment = Enum.TextXAlignment.Left,

	ZIndex = 21,
})

local Subtitle = Create("TextLabel", {
	Name = "Subtitle",

	Parent = TopBar,

	BackgroundTransparency = 1,

	Position = UDim2.new(0, 63, 0, 33),

	Size = UDim2.new(0, 250, 0, 18),

	Text = "Premium Control Panel",

	TextColor3 = CONFIG.SubText,

	TextSize = 11,

	Font = Enum.Font.Gotham,

	TextXAlignment = Enum.TextXAlignment.Left,

	ZIndex = 21,
})

local CloseButton = Create("TextButton", {
	Name = "Close",

	Parent = TopBar,

	BackgroundColor3 = CONFIG.Panel2,

	Size = UDim2.fromOffset(38, 38),

	Position = UDim2.new(1, -50, 0.5, -19),

	Text = "×",

	TextColor3 = CONFIG.Text,

	TextSize = 24,

	Font = Enum.Font.GothamBold,

	AutoButtonColor = false,

	ZIndex = 25,
})

Corner(CloseButton, 10)

--============================================================
-- SIDEBAR
--============================================================

local Sidebar = Create("Frame", {
	Name = "Sidebar",

	Parent = Main,

	BackgroundColor3 = CONFIG.Panel,

	Position = UDim2.new(0, 0, 0, 64),

	Size = UDim2.new(0, 155, 1, -64),

	BorderSizePixel = 0,

	ZIndex = 15,
})

Corner(Sidebar, 14)

local TabList = Create("ScrollingFrame", {
	Name = "Tabs",

	Parent = Sidebar,

	BackgroundTransparency = 1,

	Position = UDim2.new(0, 8, 0, 10),

	Size = UDim2.new(1, -16, 1, -20),

	CanvasSize = UDim2.new(0, 0, 0, 0),

	AutomaticCanvasSize = Enum.AutomaticSize.Y,

	ScrollBarThickness = 2,

	ScrollBarImageColor3 = CONFIG.Purple,

	BorderSizePixel = 0,

	ZIndex = 16,
})

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 5)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabList

--============================================================
-- CONTENT
--============================================================

local Content = Create("Frame", {
	Name = "Content",

	Parent = Main,

	BackgroundTransparency = 1,

	Position = UDim2.new(0, 155, 0, 64),

	Size = UDim2.new(1, -155, 1, -64),

	BorderSizePixel = 0,

	ZIndex = 11,
})

--============================================================
-- NOTIFICATION
--============================================================

local Notification = Create("TextLabel", {
	Name = "Notification",

	Parent = Gui,

	AnchorPoint = Vector2.new(0.5, 1),

	Position = UDim2.new(0.5, 0, 1, -20),

	Size = UDim2.fromOffset(300, 42),

	BackgroundColor3 = CONFIG.Panel,

	BackgroundTransparency = 0.05,

	Text = "",

	TextColor3 = CONFIG.Text,

	TextSize = 13,

	Font = Enum.Font.GothamMedium,

	Visible = false,

	ZIndex = 500,
})

Corner(Notification, 10)
Stroke(Notification, CONFIG.Purple, 1, 0.35)

local NotifyToken = 0

local function Notify(text)
	NotifyToken += 1

	local token = NotifyToken

	Notification.Text = tostring(text)
	Notification.Visible = true

	Notification.TextTransparency = 1
	Notification.BackgroundTransparency = 1

	Tween(Notification, {
		TextTransparency = 0,
		BackgroundTransparency = 0.05,
	}, 0.2)

	task.delay(2.2, function()
		if token ~= NotifyToken then
			return
		end

		Tween(Notification, {
			TextTransparency = 1,
			BackgroundTransparency = 1,
		}, 0.2)

		task.wait(0.2)

		if token == NotifyToken then
			Notification.Visible = false
		end
	end)
end

--============================================================
-- PAGE SYSTEM
--============================================================

local Pages = {}
local Tabs = {}

local function ClearContent()
	for _, child in ipairs(Content:GetChildren()) do
		child:Destroy()
	end
end

local function CreatePage(name)
	local Page = Create("ScrollingFrame", {
		Name = name,

		Parent = Content,

		BackgroundTransparency = 1,

		Position = UDim2.new(0, 10, 0, 10),

		Size = UDim2.new(1, -20, 1, -20),

		CanvasSize = UDim2.new(0, 0, 0, 0),

		AutomaticCanvasSize = Enum.AutomaticSize.Y,

		ScrollBarThickness = 3,

		ScrollBarImageColor3 = CONFIG.Purple,

		BorderSizePixel = 0,

		Visible = false,

		ZIndex = 12,
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
		Parent = parent,

		BackgroundColor3 = CONFIG.Panel,

		Size = UDim2.new(1, 0, 0, 72),

		BorderSizePixel = 0,

		ZIndex = 13,
	})

	Corner(Section, 10)

	local T = Create("TextLabel", {
		Parent = Section,

		BackgroundTransparency = 1,

		Position = UDim2.new(0, 14, 0, 10),

		Size = UDim2.new(1, -28, 0, 23),

		Text = title,

		TextColor3 = CONFIG.Text,

		TextSize = 15,

		Font = Enum.Font.GothamBold,

		TextXAlignment = Enum.TextXAlignment.Left,

		ZIndex = 14,
	})

	local D = Create("TextLabel", {
		Parent = Section,

		BackgroundTransparency = 1,

		Position = UDim2.new(0, 14, 0, 35),

		Size = UDim2.new(1, -28, 0, 25),

		Text = description or "",

		TextColor3 = CONFIG.SubText,

		TextSize = 11,

		Font = Enum.Font.Gotham,

		TextXAlignment = Enum.TextXAlignment.Left,

		ZIndex = 14,
	})

	return Section
end

local function CreateButton(parent, text, callback)
	local Button = Create("TextButton", {
		Parent = parent,

		BackgroundColor3 = CONFIG.Panel,

		Size = UDim2.new(1, 0, 0, 48),

		Text = text,

		TextColor3 = CONFIG.Text,

		TextSize = 13,

		Font = Enum.Font.GothamMedium,

		AutoButtonColor = false,

		BorderSizePixel = 0,

		ZIndex = 13,
	})

	Corner(Button, 9)

	Button.MouseEnter:Connect(function()
		Tween(Button, {
			BackgroundColor3 = CONFIG.Panel2,
		}, 0.15)
	end)

	Button.MouseLeave:Connect(function()
		Tween(Button, {
			BackgroundColor3 = CONFIG.Panel,
		}, 0.15)
	end)

	Button.Activated:Connect(function()
		if callback then
			local ok, err = pcall(callback)

			if not ok then
				warn("[SysxHub Button Error]", err)
				Notify("Terjadi error pada fitur ini")
			end
		end
	end)

	return Button
end

local function CreateToggle(parent, text, default, callback)
	local State = default or false

	local Button = Create("TextButton", {
		Parent = parent,

		BackgroundColor3 = CONFIG.Panel,

		Size = UDim2.new(1, 0, 0, 48),

		Text = "",

		AutoButtonColor = false,

		BorderSizePixel = 0,

		ZIndex = 13,
	})

	Corner(Button, 9)

	local Label = Create("TextLabel", {
		Parent = Button,

		BackgroundTransparency = 1,

		Position = UDim2.new(0, 14, 0, 0),

		Size = UDim2.new(1, -75, 1, 0),

		Text = text,

		TextColor3 = CONFIG.Text,

		TextSize = 13,

		Font = Enum.Font.GothamMedium,

		TextXAlignment = Enum.TextXAlignment.Left,

		ZIndex = 14,
	})

	local Indicator = Create("Frame", {
		Parent = Button,

		BackgroundColor3 = Color3.fromRGB(55, 50, 65),

		Size = UDim2.fromOffset(42, 22),

		Position = UDim2.new(1, -56, 0.5, -11),

		ZIndex = 14,
	})

	Corner(Indicator, 20)

	local Dot = Create("Frame", {
		Parent = Indicator,

		BackgroundColor3 = Color3.fromRGB(190, 185, 200),

		Size = UDim2.fromOffset(16, 16),

		Position = UDim2.new(0, 3, 0.5, -8),

		ZIndex = 15,
	})

	Corner(Dot, 20)

	local function Update()
		if State then
			Indicator.BackgroundColor3 = CONFIG.Purple
			Dot.BackgroundColor3 = Color3.new(1, 1, 1)

			Tween(Dot, {
				Position = UDim2.new(1, -19, 0.5, -8)
			}, 0.15)
		else
			Indicator.BackgroundColor3 = Color3.fromRGB(55, 50, 65)
			Dot.BackgroundColor3 = Color3.fromRGB(190, 185, 200)

			Tween(Dot, {
				Position = UDim2.new(0, 3, 0.5, -8)
			}, 0.15)
		end
	end

	Button.Activated:Connect(function()
		State = not State
		Update()

		if callback then
			local ok, err = pcall(callback, State)

			if not ok then
				warn("[SysxHub Toggle Error]", err)
				Notify("Error: " .. tostring(err))
			end
		end
	end)

	Update()

	return Button
end

local function CreateTab(name, icon, order)
	local Button = Create("TextButton", {
		Parent = TabList,

		BackgroundColor3 = CONFIG.Panel,

		Size = UDim2.new(1, 0, 0, 40),

		Text = "",

		AutoButtonColor = false,

		BorderSizePixel = 0,

		LayoutOrder = order,

		ZIndex = 17,
	})

	Corner(Button, 8)

	local Label = Create("TextLabel", {
		Parent = Button,

		BackgroundTransparency = 1,

		Position = UDim2.new(0, 10, 0, 0),

		Size = UDim2.new(1, -20, 1, 0),

		Text = icon .. "  " .. name,

		TextColor3 = CONFIG.SubText,

		TextSize = 12,

		Font = Enum.Font.GothamMedium,

		TextXAlignment = Enum.TextXAlignment.Left,

		ZIndex = 18,
	})

	Tabs[name] = {
		Button = Button,
		Label = Label,
	}

	return Button
end

local function ShowTab(name)
	for pageName, page in pairs(Pages) do
		page.Visible = pageName == name
	end

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

--============================================================
-- PAGES
--============================================================

local Farm = CreatePage("FARM")
local Status = CreatePage("STATUS")
local Quests = CreatePage("QUESTS")
local Fruit = CreatePage("FRUIT / RAID")
local Fishing = CreatePage("FISHING")
local PVP = CreatePage("PVP")
local Stats = CreatePage("STATS")
local Misc = CreatePage("MISC")
local Info = CreatePage("INFO")

--============================================================
-- FARM
--============================================================

CreateSection(
	Farm,
	"FARM",
	"Farm, Chest, Boss dan Material dalam satu tab."
)

CreateToggle(
	Farm,
	"Auto Farm",
	false,
	function(state)
		Notify("Auto Farm: " .. (state and "ON" or "OFF"))
	end
)

CreateToggle(
	Farm,
	"Auto Chest",
	false,
	function(state)
		Notify("Auto Chest: " .. (state and "ON" or "OFF"))
	end
)

CreateToggle(
	Farm,
	"Auto Boss",
	false,
	function(state)
		Notify("Auto Boss: " .. (state and "ON" or "OFF"))
	end
)

CreateToggle(
	Farm,
	"Auto Material",
	false,
	function(state)
		Notify("Auto Material: " .. (state and "ON" or "OFF"))
	end
)

CreateToggle(
	Farm,
	"Auto Attack",
	false,
	function(state)
		Notify("Auto Attack: " .. (state and "ON" or "OFF"))
	end
)

CreateSection(
	Farm,
	"COMBAT",
	"Kontrol combat untuk game milik sendiri."
)

CreateButton(
	Farm,
	"Start Farm",
	function()
		Notify("Farm dimulai")
	end
)

CreateButton(
	Farm,
	"Stop All Farm",
	function()
		Notify("Semua farm dihentikan")
	end
)

--============================================================
-- STATUS
--============================================================

CreateSection(
	Status,
	"STATUS",
	"Informasi status player dan dunia."
)

local PhaseMoonLabel = Create("TextLabel", {
	Parent = Status,

	BackgroundColor3 = CONFIG.Panel,

	Size = UDim2.new(1, 0, 0, 52),

	Text = "🌙  Phase Moon\nNormal",

	TextColor3 = CONFIG.Text,

	TextSize = 13,

	Font = Enum.Font.GothamMedium,

	TextXAlignment = Enum.TextXAlignment.Left,

	BorderSizePixel = 0,

	ZIndex = 13,
})

Corner(PhaseMoonLabel, 9)
Padding(PhaseMoonLabel, 14, 14, 7, 7)

CreateButton(Status, "Refresh Status", function()
	Notify("Status diperbarui")
end)

--============================================================
-- QUESTS
--============================================================

CreateSection(
	Quests,
	"QUESTS",
	"Daftar kontrol quest."
)

CreateToggle(
	Quests,
	"Auto Quest",
	false,
	function(state)
		Notify("Auto Quest: " .. (state and "ON" or "OFF"))
	end
)

CreateButton(
	Quests,
	"Refresh Quest",
	function()
		Notify("Quest diperbarui")
	end
)

--============================================================
-- FRUIT / RAID
--============================================================

CreateSection(
	Fruit,
	"FRUIT / RAID",
	"Kontrol fruit dan raid."
)

CreateToggle(
	Fruit,
	"Auto Collect Fruit",
	false,
	function(state)
		Notify("Auto Fruit: " .. (state and "ON" or "OFF"))
	end
)

CreateToggle(
	Fruit,
	"Auto Raid",
	false,
	function(state)
		Notify("Auto Raid: " .. (state and "ON" or "OFF"))
	end
)

--============================================================
-- FISHING
--============================================================

CreateSection(
	Fishing,
	"FISHING",
	"Kontrol sistem fishing."
)

CreateToggle(
	Fishing,
	"Auto Fishing",
	false,
	function(state)
		Notify("Auto Fishing: " .. (state and "ON" or "OFF"))
	end
)

CreateToggle(
	Fishing,
	"Auto Sell",
	false,
	function(state)
		Notify("Auto Sell: " .. (state and "ON" or "OFF"))
	end
)

--============================================================
-- PVP
--============================================================

CreateSection(
	PVP,
	"PVP",
	"Pengaturan PVP untuk game milik sendiri."
)

CreateToggle(
	PVP,
	"Combat Assist",
	false,
	function(state)
		Notify("Combat Assist: " .. (state and "ON" or "OFF"))
	end
)

CreateToggle(
	PVP,
	"Hitbox",
	false,
	function(state)
		Notify("Hitbox: " .. (state and "ON" or "OFF"))
	end
)

--============================================================
-- STATS
--============================================================

CreateSection(
	Stats,
	"STATS",
	"Statistik player."
)

CreateButton(
	Stats,
	"Refresh Stats",
	function()
		Notify("Stats diperbarui")
	end
)

CreateButton(
	Stats,
	"Reset Local Settings",
	function()
		Notify("Settings lokal di-reset")
	end
)

--============================================================
-- MISC
--============================================================

CreateSection(
	Misc,
	"MISC",
	"Pengaturan tambahan SysxHub."
)

CreateToggle(
	Misc,
	"UI Animation",
	true,
	function(state)
		Notify("UI Animation: " .. (state and "ON" or "OFF"))
	end
)

CreateToggle(
	Misc,
	"Notifications",
	true,
	function(state)
		Notify("Notifications: " .. (state and "ON" or "OFF"))
	end
)

CreateButton(
	Misc,
	"Discord",
	function()
		Notify("Discord: discord.gg/E5kQJW3hn")
	end
)

--============================================================
-- INFO
--============================================================

CreateSection(
	Info,
	"SYSX HUB",
	"Premium Control Panel"
)

CreateSection(
	Info,
	"Version",
	"SysxHub UI Safe Build"
)

CreateButton(
	Info,
	"Close UI",
	function()
		Main.Visible = false
		OpenButton.Visible = true
	end
)

--============================================================
-- CREATE TABS
--============================================================

local TabDefinitions = {
	{"FARM", "⚡"},
	{"STATUS", "◈"},
	{"QUESTS", "☰"},
	{"FRUIT / RAID", "◆"},
	{"FISHING", "◇"},
	{"PVP", "⚔"},
	{"STATS", "▣"},
	{"MISC", "⚙"},
	{"INFO", "●"},
}

for index, data in ipairs(TabDefinitions) do
	local name = data[1]
	local icon = data[2]

	local button = CreateTab(name, icon, index)

	button.Activated:Connect(function()
		ShowTab(name)
	end)
end

--============================================================
-- OPEN / CLOSE
--============================================================

local function OpenUI()
	Main.Visible = true
	OpenButton.Visible = false
end

local function CloseUI()
	Main.Visible = false
	OpenButton.Visible = true
end

CloseButton.Activated:Connect(CloseUI)

OpenButton.Activated:Connect(OpenUI)

--============================================================
-- DRAG MAIN
--============================================================

local dragging = false
local dragStart
local startPosition

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = Main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UIS.InputChanged:Connect(function(input)
	if not dragging then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseMovement
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local delta = input.Position - dragStart

	Main.Position = UDim2.new(
		startPosition.X.Scale,
		startPosition.X.Offset + delta.X,
		startPosition.Y.Scale,
		startPosition.Y.Offset + delta.Y
	)
end)

--============================================================
-- DEFAULT TAB
--============================================================

ShowTab("FARM")

--============================================================
-- FINAL
--============================================================

print("================================")
print("        SYSX HUB LOADED")
print("        UI BUILD: SAFE")
print("================================")

Notify("SysxHub berhasil dimuat")
