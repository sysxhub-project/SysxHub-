--[[
================================================================================
  SysxHub | Dark Purple Premium | FULL SINGLE FILE
  Version 1.3.0
  Discord: https://discord.gg/E5kQJW3hn
  Toggle Asset: rbxassetid://70792832229220
--------------------------------------------------------------------------------
  Struktur Farm: Quest | Level | Nearest
  16 Material resmi + Island DB terpusat per Sea
  Combat state machine: AutoHaki → AutoKen → AutoAttack
  Server authoritative
================================================================================
]]

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 01 — SERVICES
-- ═══════════════════════════════════════════════════════════════════════════
local Players  = game:GetService("Players")
local RS       = game:GetService("ReplicatedStorage")
local UIS      = game:GetService("UserInputService")
local RunSvc   = game:GetService("RunService")
local TweenSvc = game:GetService("TweenService")
local TS       = game:GetService("TeleportService")
local Player   = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 02 — BRANDING & THEME
-- ═══════════════════════════════════════════════════════════════════════════
local Brand = {
	Name        = "SysxHub",
	Discord     = "https://discord.gg/E5kQJW3hn",
	ToggleAsset = "rbxassetid://70792832229220",
	Version     = "1.3.0",
}

local T = {
	Background    = Color3.fromRGB(18, 10, 27),
	BackgroundSec = Color3.fromRGB(25, 14, 37),
	Panel         = Color3.fromRGB(31, 17, 45),
	PanelSec      = Color3.fromRGB(39, 21, 56),
	Primary       = Color3.fromRGB(105, 45, 160),
	PrimaryDark   = Color3.fromRGB(72, 28, 112),
	PrimaryLight  = Color3.fromRGB(145, 75, 205),
	Text          = Color3.fromRGB(245, 240, 250),
	SecondaryText = Color3.fromRGB(175, 160, 190),
	Stroke        = Color3.fromRGB(75, 42, 95),
	Success       = Color3.fromRGB(100, 210, 140),
	Warning       = Color3.fromRGB(230, 190, 80),
	Error         = Color3.fromRGB(220, 80, 100),
}

local UI_CFG = {
	WindowSize = Vector2.new(660, 480),
	SidebarW   = 158,
	TopBarH    = 36,
	CornerR    = 10,
	ScaleOpts  = {0.75, 0.85, 1.0, 1.10, 1.25},
	Tabs = {
		"Discord","Farm","Chest","Boss","Material","Sea",
		"Quests / Items","Fruit / Raid","Fishing","Status",
		"PvP","Stats","Misc",
	},
}

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 03 — UTIL HELPERS
-- ═══════════════════════════════════════════════════════════════════════════
local U = {}

function U.mk(cls, props, parent)
	local o = Instance.new(cls)
	for k,v in pairs(props or {}) do o[k] = v end
	if parent then o.Parent = parent end
	return o
end
function U.corner(o, r) return U.mk("UICorner",{CornerRadius=UDim.new(0,r or UI_CFG.CornerR)},o) end
function U.stroke(o,c,t)
	return U.mk("UIStroke",{Color=c or T.Stroke,Thickness=t or 1,
		ApplyStrokeMode=Enum.ApplyStrokeMode.Border},o)
end
function U.pad(o,p)
	local pd = U.mk("UIPadding",{},o)
	local u = UDim.new(0,p or 8)
	pd.PaddingTop,pd.PaddingBottom,pd.PaddingLeft,pd.PaddingRight = u,u,u,u
	return pd
end
function U.grad(o,c1,c2,rot)
	return U.mk("UIGradient",{Color=ColorSequence.new(c1,c2),Rotation=rot or 90},o)
end
function U.tween(o,ti,target) local tw = TweenSvc:Create(o,ti,target); tw:Play(); return tw end
function U.try(fn, onErr)
	local ok, err = pcall(fn)
	if not ok and onErr then onErr(err) end
	return ok, err
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 04 — CENTRAL DATABASE
-- ═══════════════════════════════════════════════════════════════════════════
local DATA = {}

DATA.Tools      = {"Melee","Sword","Gun","Blox Fruit"}
DATA.ChipList   = {"Flame Chip","Ice Chip","Quake Chip","Light Chip"}
DATA.RedeemCodes= {"WELCOME","RELEASE","THANKS","SYSXHUB","UPDATE1","UPDATE2"}

DATA.ServerRemotes = {
	"Farm","Chest","Boss","Material","Sea","Quest","Raid",
	"Fishing","PvP","Stats","Combat","Misc","Discord","Status","Fruit",
}

-- MATERIAL DATABASE — 16 material resmi
-- Format: [MaterialName] = { npc, island, sea, dropType, reqLevel, respawn }
DATA.MaterialDB = {
	["Bones"]                = { npc="Skeleton",         island="Jungle",           sea=1, dropType="Common",    reqLevel=5,    respawn="Instant" },
	["Ectoplasm"]            = { npc="Ghost",            island="Graveyard",        sea=2, dropType="Uncommon",  reqLevel=200,  respawn="20s"  },
	["Gunpowder"]            = { npc="Pirate",           island="Pirate Village",   sea=1, dropType="Common",    reqLevel=10,   respawn="10s"  },
	["Scrap Metal"]          = { npc="Dock Worker",      island="Port Town",        sea=3, dropType="Common",    reqLevel=700,  respawn="15s"  },
	["Leather"]              = { npc="Bandit",           island="Starter Island",   sea=1, dropType="Common",    reqLevel=1,    respawn="Instant" },
	["Magma Ore"]            = { npc="Magma Beast",      island="Magma Village",    sea=1, dropType="Rare",      reqLevel=90,   respawn="2m"   },
	["Fish Tail"]            = { npc="Sea Serpent",      island="Underwater City",  sea=1, dropType="Uncommon",  reqLevel=110,  respawn="30s"  },
	["Mystic Droplet"]       = { npc="Fountain Spirit",  island="Fountain City",    sea=1, dropType="Rare",      reqLevel=130,  respawn="1m"   },
	["Vampire Fang"]         = { npc="Haunted Knight",   island="Haunted Castle",   sea=3, dropType="Epic",      reqLevel=1200, respawn="3m"   },
	["Radioactive Material"] = { npc="Mutant Beast",     island="Green Zone",       sea=2, dropType="Epic",      reqLevel=175,  respawn="3m"   },
	["Shark Tooth"]          = { npc="Shark",            island="Underwater City",  sea=1, dropType="Uncommon",  reqLevel=110,  respawn="45s"  },
	["Conjured Cocoa"]       = { npc="Candy Monster",    island="Sea of Treats",    sea=3, dropType="Rare",      reqLevel=1400, respawn="2m"   },
	["Demonic Wisp"]         = { npc="Dark Knight",      island="Dark Arena",       sea=2, dropType="Epic",      reqLevel=250,  respawn="3m"   },
	["Dragon Scale"]         = { npc="Hydra Head",       island="Hydra Island",     sea=3, dropType="Legendary", reqLevel=800,  respawn="5m"   },
	["Electric Wing"]        = { npc="Sky Warrior",      island="Skylands",         sea=1, dropType="Rare",      reqLevel=40,   respawn="2m"   },
	["Mutant Tooth"]         = { npc="Mutant Beast",     island="Forgotten Island", sea=2, dropType="Legendary", reqLevel=500,  respawn="5m"   },
}

-- ISLAND DATABASE (terpusat)
DATA.SeaData = {
	[1] = {
		{ name="Starter Island", reqLevel=1,
		  npcs={"Bandit","Trader"},
		  quests={"Kill 10 Bandits"},
		  materials={"Leather"},
		  bosses={"Bandit Leader"} },
		{ name="Jungle", reqLevel=5,
		  npcs={"Skeleton","Monkey"},
		  quests={"Kill 25 Skeletons"},
		  materials={"Bones"},
		  bosses={} },
		{ name="Pirate Village", reqLevel=10,
		  npcs={"Pirate","Pirate Captain"},
		  quests={"Kill 25 Pirates"},
		  materials={"Gunpowder"},
		  bosses={"Pirate King"} },
		{ name="Desert", reqLevel=15,
		  npcs={"Desert Bandit","Scorpion"},
		  quests={"Kill 50 Desert Bandits"},
		  materials={},
		  bosses={} },
		{ name="Frozen Village", reqLevel=25,
		  npcs={"Frozen Soldier","Yeti"},
		  quests={"Collect 20 Frozen Shards"},
		  materials={},
		  bosses={"Frozen Giant"} },
		{ name="Marine Fortress", reqLevel=35,
		  npcs={"Marine Captain","Vice Admiral"},
		  quests={"Kill 50 Marines"},
		  materials={},
		  bosses={"Vice Admiral"} },
		{ name="Skylands", reqLevel=40,
		  npcs={"Sky Warrior","Sky Lord"},
		  quests={"Kill 25 Sky Warriors"},
		  materials={"Electric Wing"},
		  bosses={"Sky God"} },
		{ name="Prison", reqLevel=60,
		  npcs={"Prison Guard","Warden"},
		  quests={"Kill 50 Prison Guards"},
		  materials={},
		  bosses={"Warden Chief"} },
		{ name="Colosseum", reqLevel=75,
		  npcs={"Gladiator","Champion"},
		  quests={"Kill 50 Gladiators"},
		  materials={},
		  bosses={"Colosseum Champion"} },
		{ name="Magma Village", reqLevel=90,
		  npcs={"Magma Beast","Fire Elemental"},
		  quests={"Kill 50 Magma Beasts"},
		  materials={"Magma Ore"},
		  bosses={"Magma Lord"} },
		{ name="Underwater City", reqLevel=110,
		  npcs={"Sea Serpent","Merman","Shark"},
		  quests={"Kill 50 Sea Serpents"},
		  materials={"Fish Tail","Shark Tooth"},
		  bosses={"Sea Emperor"} },
		{ name="Fountain City", reqLevel=130,
		  npcs={"Fountain Spirit","Guardian"},
		  quests={"Kill 50 Fountain Spirits"},
		  materials={"Mystic Droplet"},
		  bosses={"Fountain Guardian"} },
	},
	[2] = {
		{ name="Kingdom of Rose", reqLevel=150,
		  npcs={"Rose Guard","Knight"},
		  quests={"Kill 50 Rose Guards"},
		  materials={},
		  bosses={"Rose King"} },
		{ name="Green Zone", reqLevel=175,
		  npcs={"Jungle Beast","Mutant Beast"},
		  quests={"Kill 50 Mutant Beasts"},
		  materials={"Radioactive Material"},
		  bosses={} },
		{ name="Graveyard", reqLevel=200,
		  npcs={"Zombie","Ghost"},
		  quests={"Kill 50 Zombies"},
		  materials={"Ectoplasm"},
		  bosses={"Undead King"} },
		{ name="Dark Arena", reqLevel=250,
		  npcs={"Dark Knight","Shadow"},
		  quests={"Kill 50 Dark Knights"},
		  materials={"Demonic Wisp"},
		  bosses={"Dark Champion"} },
		{ name="Snow Mountain", reqLevel=300,
		  npcs={"Snow Golem","Ice Wolf"},
		  quests={"Kill 50 Snow Golems"},
		  materials={},
		  bosses={"Snow Titan"} },
		{ name="Hot and Cold", reqLevel=350,
		  npcs={"Hot-Cold Spirit","Twin Beast"},
		  quests={"Kill 50 Twin Beasts"},
		  materials={},
		  bosses={"Twin Lord"} },
		{ name="Cursed Ship", reqLevel=400,
		  npcs={"Ghost Pirate","Cursed Sailor"},
		  quests={"Kill 50 Ghost Pirates"},
		  materials={},
		  bosses={"Cursed Captain"} },
		{ name="Ice Castle", reqLevel=450,
		  npcs={"Ice King","Frost Giant"},
		  quests={"Kill 50 Ice Guards"},
		  materials={},
		  bosses={"Ice King"} },
		{ name="Forgotten Island", reqLevel=500,
		  npcs={"Forgotten Knight","Forgotten Mage","Mutant Beast"},
		  quests={"Kill 50 Forgotten Knights"},
		  materials={"Mutant Tooth"},
		  bosses={"Forgotten Lord"} },
		{ name="Usoap's Island", reqLevel=550,
		  npcs={"Usoap","Usoap Guard"},
		  quests={"Collect 20 Usoap's Bags"},
		  materials={},
		  bosses={"Usoap Boss"} },
		{ name="Café", reqLevel=575,
		  npcs={"Barista","Customer"},
		  quests={"Collect 20 Coffee Beans"},
		  materials={},
		  bosses={} },
		{ name="Don Swan's Mansion", reqLevel=600,
		  npcs={"Don Swan Servant","Bodyguard"},
		  quests={"Kill 50 Don Swan Servants"},
		  materials={},
		  bosses={"Don Swan"} },
	},
	[3] = {
		{ name="Port Town", reqLevel=700,
		  npcs={"Dock Worker","Merchant"},
		  quests={"Kill 50 Dock Workers"},
		  materials={"Scrap Metal"},
		  bosses={} },
		{ name="Hydra Island", reqLevel=800,
		  npcs={"Hydra Head","Hydra Body"},
		  quests={"Kill 50 Hydra Heads"},
		  materials={"Dragon Scale"},
		  bosses={"Hydra"} },
		{ name="Great Tree", reqLevel=900,
		  npcs={"Tree Guardian","Forest Spirit"},
		  quests={"Kill 50 Tree Guardians"},
		  materials={},
		  bosses={"Tree Elder"} },
		{ name="Floating Turtle", reqLevel=1000,
		  npcs={"Floating Turtle","Turtle Guard"},
		  quests={"Kill 50 Floating Turtles"},
		  materials={},
		  bosses={"Turtle King"} },
		{ name="Haunted Castle", reqLevel=1200,
		  npcs={"Haunted Knight","Ghost"},
		  quests={"Kill 50 Haunted Knights"},
		  materials={"Vampire Fang"},
		  bosses={"Haunted King"} },
		{ name="Sea of Treats", reqLevel=1400,
		  npcs={"Candy Monster","Sweet Guard"},
		  quests={"Kill 50 Candy Monsters"},
		  materials={"Conjured Cocoa"},
		  bosses={"Candy King"} },
		{ name="Castle on the Sea", reqLevel=1600,
		  npcs={"Castle Guard","Royal Knight"},
		  quests={"Kill 50 Castle Guards"},
		  materials={},
		  bosses={"Sea Castle Lord"} },
		{ name="Beautiful Pirate Domain", reqLevel=1800,
		  npcs={"Beautiful Pirate","Pirate Elite"},
		  quests={"Kill 50 Elite Pirates"},
		  materials={},
		  bosses={"Beautiful Pirate"} },
		{ name="Tiki Outpost", reqLevel=2000,
		  npcs={"Tiki Warrior","Tiki Chief"},
		  quests={"Kill 50 Tiki Warriors"},
		  materials={},
		  bosses={"Tiki Chief"} },
	},
}

-- Helper queries
local function getMaterialInfo(name) return DATA.MaterialDB[name] end
local function getIslandInfo(sea, name)
	for _, isl in ipairs(DATA.SeaData[sea] or {}) do
		if isl.name == name then return isl end
	end
	return nil
end
local function getMaterialsForSea(sea)
	local list = {}
	for mat, info in pairs(DATA.MaterialDB) do
		if info.sea == sea then table.insert(list, mat) end
	end
	table.sort(list); return list
end
local function getMaterialsForIsland(sea, island)
	local list = {}
	for mat, info in pairs(DATA.MaterialDB) do
		if info.sea == sea and info.island == island then table.insert(list, mat) end
	end
	table.sort(list); return list
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 05 — NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════
local Notif = {}
local notifHolder

function Notif.Init(parent)
	notifHolder = U.mk("Frame",{
		Name="NotifHolder", BackgroundTransparency=1,
		Size=UDim2.new(0,300,1,-60),
		Position=UDim2.new(1,-312,0,44),
	},parent)
	U.mk("UIListLayout",{
		Padding=UDim.new(0,6),
		SortOrder=Enum.SortOrder.LayoutOrder,
		VerticalAlignment=Enum.VerticalAlignment.Top,
	},notifHolder)
end

local function notifColor(kind)
	if kind=="SUCCESS" then return T.Success end
	if kind=="WARNING" then return T.Warning end
	if kind=="ERROR"   then return T.Error end
	return T.PrimaryLight
end

function Notif.Push(kind,title,msg,dur)
	if not notifHolder then return end
	dur = dur or 3
	local card = U.mk("Frame",{
		BackgroundColor3=T.Panel,BorderSizePixel=0,
		Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,
	},notifHolder)
	U.corner(card,8); U.stroke(card,notifColor(kind))
	local accent = U.mk("Frame",{
		BackgroundColor3=notifColor(kind),BorderSizePixel=0,
		Size=UDim2.new(0,4,1,-8),Position=UDim2.new(0,4,0,4),
	},card)
	U.corner(accent,3)
	U.mk("TextLabel",{
		BackgroundTransparency=1,Font=Enum.Font.GothamBold,
		Text=title,TextColor3=T.Text,TextSize=13,
		TextXAlignment=Enum.TextXAlignment.Left,
		Size=UDim2.new(1,-20,0,16),Position=UDim2.new(0,14,0,6),
	},card)
	U.mk("TextLabel",{
		BackgroundTransparency=1,Font=Enum.Font.Gotham,
		Text=msg,TextColor3=T.SecondaryText,TextSize=12,
		TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,
		Size=UDim2.new(1,-20,0,16),Position=UDim2.new(0,14,0,22),
	},card)
	U.tween(card, TweenInfo.new(0.28,Enum.EasingStyle.Quart),
		{Size=UDim2.new(1,0,0,46),BackgroundTransparency=0})
	task.delay(dur,function()
		if not card.Parent then return end
		local tw = U.tween(card, TweenInfo.new(0.22),
			{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1})
		tw.Completed:Connect(function() card:Destroy() end)
	end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 06 — COMBAT CONTROLLER (STATE MACHINE)
-- ═══════════════════════════════════════════════════════════════════════════
local Combat = {}
Combat.__index = Combat
Combat.State = {
	IDLE="IDLE", QUEST_ACTIVE="QUEST_ACTIVE", TARGET_SEARCH="TARGET_SEARCH",
	TARGET_FOUND="TARGET_FOUND", COMBAT="COMBAT", TARGET_DEAD="TARGET_DEAD",
	QUEST_COMPLETE="QUEST_COMPLETE",
}

function Combat.new(remote)
	local self = setmetatable({},Combat)
	self.Remote   = remote
	self._state   = Combat.State.IDLE
	self._running = false
	self._toggles = {AutoHaki=false, AutoKen=false, AutoAttack=false}
	return self
end
function Combat:SetToggles(t)
	for k,v in pairs(t) do if self._toggles[k]~=nil then self._toggles[k]=v end end
end
function Combat:GetState() return self._state end
function Combat:_fire(action, data)
	if self.Remote and self.Remote:IsA("RemoteEvent") then
		self.Remote:FireServer(action, data or {})
	end
end
function Combat:_tick()
	if not self._running then return end
	self._state = Combat.State.TARGET_SEARCH
	if self._toggles.AutoHaki then self:_fire("AutoHaki",{enable=true}) end
	task.wait(0.15)
	if self._toggles.AutoKen then self:_fire("AutoKen",{enable=true}) end
	task.wait(0.15)
	self:_fire("RequestTargets",{})
	self._state = Combat.State.TARGET_FOUND
	while self._running do
		self._state = Combat.State.COMBAT
		if self._toggles.AutoAttack then self:_fire("Attack",{}) end
		task.wait(0.35)
	end
	self._state = Combat.State.QUEST_COMPLETE
	self:_fire("Stop",{})
	self._state = Combat.State.IDLE
end
function Combat:Start()
	if self._running then return end
	self._running = true
	task.spawn(function() self:_tick() end)
end
function Combat:Stop()
	self._running = false
	self._state = Combat.State.IDLE
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 07 — FEATURE CONTROLLER
-- ═══════════════════════════════════════════════════════════════════════════
local Feature = {}
Feature.__index = Feature

function Feature.new(remotes, combat, notif)
	local self = setmetatable({},Feature)
	self.Remotes = remotes
	self.Combat  = combat
	self.Notif   = notif
	self._active = {}
	return self
end
function Feature:_remote(name)
	local r = self.Remotes and self.Remotes:FindFirstChild(name)
	if r and r:IsA("RemoteEvent") then return r end
	Notif.Push("WARNING","Remote Missing",tostring(name),2)
	return nil
end
function Feature:Fire(name, action, data)
	local r = self:_remote(name)
	if r then r:FireServer(action, data or {}) end
end
function Feature:Toggle(key, on, remoteName, action)
	if self._active[key]==on then return end
	self._active[key]=on
	action = action or (on and "start" or "stop")
	local ok,err = pcall(function()
		self:Fire(remoteName or key, action, {enable=on})
	end)
	if not ok then
		Notif.Push("ERROR","Feature Error",tostring(err),3)
		self._active[key]=false
		return
	end
	if key:match("Farm") or key:match("Boss") or key:match("Kill") then
		if on then self.Combat:Start() else self.Combat:Stop() end
	end
end
function Feature:IsActive(k) return self._active[k]==true end

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 08 — REMOTES RESOLUTION
-- ═══════════════════════════════════════════════════════════════════════════
local SysxFolder = RS:FindFirstChild("SysxHub")
if not SysxFolder then SysxFolder = U.mk("Folder",{Name="SysxHub"},RS) end
local Remotes = SysxFolder:FindFirstChild("Remotes")
if not Remotes then
	Remotes = U.mk("Folder",{Name="Remotes"},SysxFolder)
	for _, n in ipairs(DATA.ServerRemotes) do
		if not Remotes:FindFirstChild(n) then
			U.mk("RemoteEvent",{Name=n},Remotes)
		end
	end
end

local CombatObj = Combat.new(Remotes:FindFirstChild("Combat"))
local F = Feature.new(Remotes, CombatObj, Notif)

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 09 — SCREEN GUI + OPEN BUTTON
-- ═══════════════════════════════════════════════════════════════════════════
local gui = U.mk("ScreenGui",{
	Name="SysxHub", ResetOnSpawn=false, IgnoreGuiInset=true,
	ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
}, Player:WaitForChild("PlayerGui"))

Notif.Init(gui)

local openBtn = U.mk("ImageButton",{
	Name="OpenButton", Image=Brand.ToggleAsset,
	BackgroundTransparency=1,
	Size=UDim2.fromOffset(58,58),
	Position=UDim2.new(0,20,0.5,-29),
	AnchorPoint=Vector2.new(0,0),
},gui)
U.corner(openBtn,29)

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 10 — MAIN WINDOW
-- ═══════════════════════════════════════════════════════════════════════════
local Main = U.mk("Frame",{
	Name="MainWindow",
	BackgroundColor3=T.Background, BorderSizePixel=0,
	Size=UDim2.fromOffset(UI_CFG.WindowSize.X, UI_CFG.WindowSize.Y),
	Position=UDim2.new(0.5,-UI_CFG.WindowSize.X/2, 0.5,-UI_CFG.WindowSize.Y/2),
},gui)
U.corner(Main,12); U.stroke(Main,T.Stroke); Main.ClipsDescendants = true

local uiScale = U.mk("UIScale",{Scale=1},Main)

-- TOPBAR
local TopBar = U.mk("Frame",{
	Name="TopBar", BackgroundColor3=T.BackgroundSec,
	BorderSizePixel=0, Size=UDim2.new(1,0,0,UI_CFG.TopBarH),
},Main)
U.corner(TopBar,12); U.stroke(TopBar,T.Stroke); U.grad(TopBar,T.PrimaryDark,T.BackgroundSec,0)
U.mk("TextLabel",{
	BackgroundTransparency=1,Font=Enum.Font.GothamBold,
	Text="◆ "..Brand.Name, TextColor3=T.PrimaryLight, TextSize=15,
	TextXAlignment=Enum.TextXAlignment.Left,
	Size=UDim2.new(0,200,1,0), Position=UDim2.new(0,12,0,0),
},TopBar)

local function topBtn(txt, xoff, col)
	local b = U.mk("TextButton",{
		BackgroundColor3=col or T.PanelSec, BorderSizePixel=0,
		Text=txt, TextColor3=T.Text, Font=Enum.Font.GothamBold,
		TextSize=14, AutoButtonColor=false,
		Size=UDim2.fromOffset(26,24),
		Position=UDim2.new(1,xoff,0.5,-12),
	},TopBar)
	U.corner(b,6)
	b.MouseEnter:Connect(function() U.tween(b,TweenInfo.new(0.15),{BackgroundColor3=T.Primary}) end)
	b.MouseLeave:Connect(function() U.tween(b,TweenInfo.new(0.15),{BackgroundColor3=col or T.PanelSec}) end)
	return b
end
local scaleBtn = topBtn("◱",-90)
local minBtn   = topBtn("—",-62)
local closeBtn = topBtn("✕",-34,T.Error)

-- SIDEBAR
local Sidebar = U.mk("Frame",{
	Name="Sidebar", BackgroundColor3=T.BackgroundSec,
	BorderSizePixel=0,
	Size=UDim2.new(0,UI_CFG.SidebarW,1,-UI_CFG.TopBarH),
	Position=UDim2.new(0,0,0,UI_CFG.TopBarH),
},Main)
U.stroke(Sidebar,T.Stroke)
local SidebarScroll = U.mk("ScrollingFrame",{
	BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0),
	CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
	ScrollBarThickness=4, ScrollBarImageColor3=T.Primary,
},Sidebar)
U.mk("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},SidebarScroll)
U.pad(SidebarScroll,6)

-- CONTENT
local Content = U.mk("Frame",{
	Name="Content", BackgroundColor3=T.Background, BorderSizePixel=0,
	Size=UDim2.new(1,-UI_CFG.SidebarW,1,-UI_CFG.TopBarH),
	Position=UDim2.new(0,UI_CFG.SidebarW,0,UI_CFG.TopBarH),
},Main)
local SearchBar = U.mk("TextBox",{
	BackgroundColor3=T.BackgroundSec, BorderSizePixel=0,
	ClearTextOnFocus=false, PlaceholderText="Search Feature...",
	PlaceholderColor3=T.SecondaryText, TextColor3=T.Text,
	Font=Enum.Font.Gotham, TextSize=13,
	TextXAlignment=Enum.TextXAlignment.Left, Text="",
	Size=UDim2.new(1,-24,0,32),
	Position=UDim2.new(0,12,0,10),
},Content)
U.corner(SearchBar,6); U.stroke(SearchBar); U.pad(SearchBar,8)
local ContentScroll = U.mk("ScrollingFrame",{
	BackgroundTransparency=1, BorderSizePixel=0,
	Size=UDim2.new(1,-16,1,-58),
	Position=UDim2.new(0,8,0,52),
	CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
	ScrollBarThickness=4, ScrollBarImageColor3=T.Primary,
},Content)
U.mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},ContentScroll)
U.pad(ContentScroll,8)

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 11 — COMPONENT BUILDERS
-- ═══════════════════════════════════════════════════════════════════════════
local currentTab = nil
local registry = {}
local function clearContent()
	for _,c in ipairs(ContentScroll:GetChildren()) do
		if c:IsA("GuiObject") then c:Destroy() end
	end
	registry = {}
end

local function secLabel(text, order)
	local l = U.mk("TextLabel",{
		BackgroundTransparency=1,Font=Enum.Font.GothamBold,
		Text="▸ "..text, TextColor3=T.PrimaryLight, TextSize=13,
		TextXAlignment=Enum.TextXAlignment.Left,
		Size=UDim2.new(1,-8,0,22),
	},ContentScroll)
	l.LayoutOrder = order or 0
	table.insert(registry,{currentTab,text,l})
	return l
end

local function makeToggle(text, default, onChange, order)
	local row = U.mk("Frame",{
		BackgroundColor3=T.Panel, BorderSizePixel=0,
		Size=UDim2.new(1,-8,0,36),
	},ContentScroll)
	row.LayoutOrder = order or 0; U.corner(row,8); U.stroke(row)
	U.mk("TextLabel",{
		BackgroundTransparency=1,Font=Enum.Font.GothamMedium,
		Text=text, TextColor3=T.Text, TextSize=13,
		TextXAlignment=Enum.TextXAlignment.Left,
		Size=UDim2.new(1,-80,1,0), Position=UDim2.new(0,12,0,0),
	},row)
	local track = U.mk("Frame",{
		BackgroundColor3=default and T.PrimaryLight or T.PanelSec,
		BorderSizePixel=0,Size=UDim2.fromOffset(46,22),
		Position=UDim2.new(1,-58,0.5,-11),
	},row)
	U.corner(track,11); U.stroke(track)
	local knob = U.mk("Frame",{
		BackgroundColor3=T.Text,BorderSizePixel=0,
		Size=UDim2.fromOffset(18,18),
		Position=default and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9),
	},track)
	U.corner(knob,9)
	local state = default or false
	local btn = U.mk("TextButton",{
		BackgroundTransparency=1, Text="", Size=UDim2.new(1,0,1,0),
	},row)
	btn.MouseButton1Click:Connect(function()
		state = not state
		local ti = TweenInfo.new(0.18,Enum.EasingStyle.Quart)
		U.tween(track,ti,{BackgroundColor3 = state and T.PrimaryLight or T.PanelSec})
		U.tween(knob,ti,{Position = state and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)})
		if onChange then U.try(function() onChange(state) end) end
	end)
	table.insert(registry,{currentTab,text,row})
	return row
end

local function makeButton(text, onClick, order)
	local b = U.mk("TextButton",{
		BackgroundColor3=T.Panel, BorderSizePixel=0,
		Text=text, TextColor3=T.Text, Font=Enum.Font.GothamMedium,
		TextSize=13, AutoButtonColor=false,
		Size=UDim2.new(1,-8,0,34),
	},ContentScroll)
	b.LayoutOrder = order or 0; U.corner(b,8); U.stroke(b)
	b.MouseEnter:Connect(function() U.tween(b,TweenInfo.new(0.15),{BackgroundColor3=T.PanelSec}) end)
	b.MouseLeave:Connect(function() U.tween(b,TweenInfo.new(0.15),{BackgroundColor3=T.Panel}) end)
	b.MouseButton1Click:Connect(function() if onClick then U.try(onClick) end end)
	table.insert(registry,{currentTab,text,b})
	return b
end

local function makeSlider(text, minV, maxV, default, onChange, order)
	local row = U.mk("Frame",{
		BackgroundColor3=T.Panel, BorderSizePixel=0,
		Size=UDim2.new(1,-8,0,48),
	},ContentScroll)
	row.LayoutOrder = order or 0; U.corner(row,8); U.stroke(row)
	U.mk("TextLabel",{
		BackgroundTransparency=1,Font=Enum.Font.GothamMedium,
		Text=text, TextColor3=T.Text, TextSize=13,
		TextXAlignment=Enum.TextXAlignment.Left,
		Size=UDim2.new(1,-80,0,18), Position=UDim2.new(0,12,0,4),
	},row)
	local valLbl = U.mk("TextLabel",{
		BackgroundTransparency=1,Font=Enum.Font.GothamBold,
		Text=string.format("%.2f",default), TextColor3=T.PrimaryLight,
		TextSize=13, TextXAlignment=Enum.TextXAlignment.Right,
		Size=UDim2.new(0,66,0,18), Position=UDim2.new(1,-78,0,4),
	},row)
	local bar = U.mk("Frame",{
		BackgroundColor3=T.BackgroundSec, BorderSizePixel=0,
		Size=UDim2.new(1,-24,0,8),
		Position=UDim2.new(0,12,0,30),
	},row)
	U.corner(bar,4); U.stroke(bar)
	local fill = U.mk("Frame",{
		BackgroundColor3=T.PrimaryLight, BorderSizePixel=0,
		Size=UDim2.new((default-minV)/(maxV-minV),0,1,0),
	},bar)
	U.corner(fill,4)
	local knob = U.mk("Frame",{
		BackgroundColor3=T.Text,BorderSizePixel=0,
		Size=UDim2.fromOffset(14,14),
		Position=UDim2.new((default-minV)/(maxV-minV),-7,0.5,-7),
	},bar)
	U.corner(knob,7)
	local dragging = false
	local function setFromX(x)
		local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		local v = minV + (maxV - minV) * rel
		fill.Size = UDim2.new(rel,0,1,0)
		knob.Position = UDim2.new(rel,-7,0.5,-7)
		valLbl.Text = string.format("%.2f", v)
		if onChange then U.try(function() onChange(v) end) end
	end
	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true; setFromX(input.Position.X)
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then
			setFromX(input.Position.X)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	table.insert(registry,{currentTab,text,row})
	return row
end

local function makeDropdown(labelText, options, onSelect, order)
	local holder = U.mk("Frame",{
		BackgroundColor3=T.Panel, BorderSizePixel=0,
		Size=UDim2.new(1,-8,0,36),
	},ContentScroll)
	holder.LayoutOrder = order or 0
	U.corner(holder,8); U.stroke(holder); holder.ClipsDescendants = true
	local header = U.mk("TextButton",{
		BackgroundColor3=T.Panel, BorderSizePixel=0,
		Text="  "..labelText..": "..(options[1] or "-"),
		TextColor3=T.Text, Font=Enum.Font.GothamMedium, TextSize=13,
		TextXAlignment=Enum.TextXAlignment.Left, AutoButtonColor=false,
		Size=UDim2.new(1,0,0,36),
	},holder)
	local listHolder = U.mk("Frame",{
		BackgroundColor3=T.BackgroundSec, BorderSizePixel=0,
		Size=UDim2.new(1,-16,0,0),
		Position=UDim2.new(0,8,0,38),
	},holder)
	U.corner(listHolder,6); listHolder.ClipsDescendants = true
	U.mk("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder},listHolder)
	local opened = false
	for i,opt in ipairs(options) do
		local ib = U.mk("TextButton",{
			BackgroundColor3=T.Panel, BorderSizePixel=0,
			Text="  "..opt, TextColor3=T.Text, Font=Enum.Font.Gotham,
			TextSize=12, TextXAlignment=Enum.TextXAlignment.Left,
			AutoButtonColor=false, Size=UDim2.new(1,-8,0,28),
			LayoutOrder=i,
		},listHolder)
		U.corner(ib,4)
		ib.MouseEnter:Connect(function() U.tween(ib,TweenInfo.new(0.12),{BackgroundColor3=T.PanelSec}) end)
		ib.MouseLeave:Connect(function() U.tween(ib,TweenInfo.new(0.12),{BackgroundColor3=T.Panel}) end)
		ib.MouseButton1Click:Connect(function()
			header.Text = "  "..labelText..": "..opt
			opened = false
			U.tween(holder,TweenInfo.new(0.2),{Size=UDim2.new(1,-8,0,36)})
			U.tween(listHolder,TweenInfo.new(0.2),{Size=UDim2.new(1,-16,0,0)})
			if onSelect then U.try(function() onSelect(opt) end) end
		end)
	end
	header.MouseButton1Click:Connect(function()
		opened = not opened
		local h = math.min(#options * 30 + 8, 180)
		U.tween(holder,TweenInfo.new(0.2),
			{Size=UDim2.new(1,-8,0, opened and 36+h+8 or 36)})
		U.tween(listHolder,TweenInfo.new(0.2),
			{Size=UDim2.new(1,-16,0, opened and h or 0)})
	end)
	UIS.InputBegan:Connect(function(input)
		if not opened then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			opened = false
			U.tween(holder,TweenInfo.new(0.2),{Size=UDim2.new(1,-8,0,36)})
			U.tween(listHolder,TweenInfo.new(0.2),{Size=UDim2.new(1,-16,0,0)})
		end
	end)
	table.insert(registry,{currentTab,labelText,holder})
	return holder
end

local function makeInfoPanel(order, height)
	local holder = U.mk("Frame",{
		BackgroundColor3=T.Panel, BorderSizePixel=0,
		Size=UDim2.new(1,-8,0,height or 100),
	},ContentScroll)
	holder.LayoutOrder = order or 0; U.corner(holder,8); U.stroke(holder)
	return holder
end
local function fillInfo(holder, lines)
	for _,c in ipairs(holder:GetChildren()) do
		if c:IsA("GuiObject") then c:Destroy() end
	end
	U.mk("TextLabel",{
		BackgroundTransparency=1,Font=Enum.Font.Gotham,
		Text=table.concat(lines,"\n"), TextColor3=T.Text, TextSize=12,
		TextXAlignment=Enum.TextXAlignment.Left,
		TextYAlignment=Enum.TextYAlignment.Top, TextWrapped=true,
		Size=UDim2.new(1,-16,1,-16), Position=UDim2.new(0,8,0,8),
	},holder)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 12 — TAB BUILDERS
-- ═══════════════════════════════════════════════════════════════════════════
local tabBuilders = {}

-- ─── DISCORD ──────────────────────────────────────────────────────────────
tabBuilders["Discord"] = function()
	secLabel("Community", 1)
	makeButton("Join Discord — "..Brand.Discord, function()
		if setclipboard then pcall(setclipboard, Brand.Discord) end
		Notif.Push("SUCCESS","Discord",Brand.Discord,3)
	end, 2)
	secLabel("Info", 3)
	makeButton("Version: "..Brand.Version, function() end, 4)
	makeButton("Copy Asset Toggle ID", function()
		if setclipboard then pcall(setclipboard,"70792832229220") end
		Notif.Push("SUCCESS","Asset","Copied",2)
	end, 5)
end

-- ─── FARM (Quest | Level | Nearest) ───────────────────────────────────────
tabBuilders["Farm"] = function()
	secLabel("Farm Config", 1)

	local farmSea = 1
	local farmIsland = nil

	makeDropdown("Sea", {"Sea 1","Sea 2","Sea 3"}, function(v)
		farmSea = tonumber(v:match("%d+")) or 1
		farmIsland = nil
		openTab("Farm")
	end, 2)

	local islandNames = {"All Islands"}
	for _, isl in ipairs(DATA.SeaData[farmSea] or {}) do
		table.insert(islandNames, isl.name)
	end
	makeDropdown("Island", islandNames, function(v)
		farmIsland = (v == "All Islands") and nil or v
		openTab("Farm")
	end, 3)

	-- QUEST dropdown (dari IslandDB)
	secLabel("Quest", 4)
	local questList = {"Select Quest..."}
	for _, isl in ipairs(DATA.SeaData[farmSea] or {}) do
		if (not farmIsland) or isl.name == farmIsland then
			for _, q in ipairs(isl.quests) do
				table.insert(questList, q.." @"..isl.name)
			end
		end
	end
	if #questList == 1 then questList = {"(No quest in this Sea/Island)"} end

	makeDropdown("Quest", questList, function(v)
		if v == "Select Quest..." or v == "(No quest in this Sea/Island)" then return end
		local quest, island = v:match("^(.-) @(.+)$")
		local info = island and getIslandInfo(farmSea, island)
		if info then
			Notif.Push("INFO","Quest Loaded",
				quest.." | "..island.." | Lv."..info.reqLevel, 3)
			F:Fire("Farm","selectQuest",{
				quest=quest, island=island, sea=farmSea, reqLevel=info.reqLevel,
			})
		end
	end, 5)

	-- LEVEL slider
	secLabel("Level", 6)
	makeSlider("Target Level", 1, 3000, 100, function(v)
		F:Fire("Farm","setLevel",{value=math.floor(v)})
	end, 7)

	-- NEAREST toggle
	secLabel("Nearest", 8)
	makeToggle("Auto Farm Nearest", false, function(on)
		F:Toggle("AutoFarmNearest", on, "Farm", on and "start" or "stop")
		Notif.Push(on and "SUCCESS" or "INFO","Nearest",
			on and "Enabled" or "Disabled", 2)
	end, 9)

	-- FARM toggles
	secLabel("Auto Farm", 10)
	local o = 11
	local function farmToggle(n, rn, ac)
		makeToggle(n, false, function(on)
			F:Toggle(n, on, rn, ac)
			Notif.Push(on and "SUCCESS" or "INFO", n, on and "Enabled" or "Disabled", 2)
		end, o); o += 1
	end
	farmToggle("Auto Farm Level","Farm")
	farmToggle("Auto Factory","Farm")
	farmToggle("Auto Farm Ectoplasm","Farm")
	farmToggle("Auto Accept Quest","Quest")

	makeDropdown("Select Tool", DATA.Tools, function(v)
		F:Fire("Farm","setTool",{tool=v})
	end, o); o += 1

	makeSlider("UI Scale", 0.5, 1.5, 1.0, function(v) uiScale.Scale = v end, o); o += 1

	secLabel("Combat Automation", o); o += 1
	local function combatToggle(name)
		makeToggle(name, false, function(on)
			local key = name:gsub("Auto ","")
			CombatObj._toggles[key] = on
			F:Fire("Combat", name, {enable=on})
		end, o); o += 1
	end
	combatToggle("Auto Quest Combat")
	combatToggle("Auto Haki")
	combatToggle("Auto Ken")
	combatToggle("Auto Attack")
end

-- ─── CHEST ────────────────────────────────────────────────────────────────
tabBuilders["Chest"] = function()
	secLabel("Chest", 1)
	makeToggle("Auto Chest [Tween]", false, function(on)
		F:Toggle("AutoChest", on, "Farm", on and "start" or "stop")
		Notif.Push(on and "SUCCESS" or "INFO","Auto Chest",on and "Enabled" or "Disabled",2)
	end, 2)
	makeToggle("Stop When Get Item in Chest", false, function(on)
		F:Fire("Farm","stopWhenItem",{enable=on})
	end, 3)
end

-- ─── BOSS ─────────────────────────────────────────────────────────────────
tabBuilders["Boss"] = function()
	secLabel("Boss Filter", 1)
	local curSea = 1
	makeDropdown("Sea", {"Sea 1","Sea 2","Sea 3"}, function(v)
		curSea = tonumber(v:match("%d+")) or 1
		openTab("Boss")
	end, 2)

	local bossList = {"None"}
	local bossMap = {}
	for _, isl in ipairs(DATA.SeaData[curSea] or {}) do
		for _, boss in ipairs(isl.bosses) do
			table.insert(bossList, boss)
			bossMap[boss] = {Island=isl.name, ReqLevel=isl.reqLevel}
		end
	end
	if #bossList == 1 then table.insert(bossList, "(No boss in this Sea)") end

	makeDropdown("Select Boss", bossList, function(v)
		local info = bossMap[v]
		if info then
			Notif.Push("INFO","Boss Source",
				v.." @ "..info.Island.." (Lv."..info.ReqLevel..")",3)
			F:Fire("Boss","select",{boss=v, sea=curSea, island=info.Island})
		end
	end, 3)

	makeButton("Update Boss List", function()
		F:Fire("Boss","updateList",{sea=curSea})
		Notif.Push("SUCCESS","Boss","Updated for Sea "..curSea,2)
	end, 4)
	makeSlider("UI Scale", 0.5, 1.5, 1.0, function(v) uiScale.Scale = v end, 5)

	secLabel("Boss Combat", 10)
	makeToggle("Auto Kill Selected Boss", false, function(on)
		F:Toggle("AutoKillBoss", on, "Boss", on and "killSelected" or "stop")
	end, 11)
	makeToggle("Auto Farm All Bosses", false, function(on)
		F:Toggle("AutoFarmAllBoss", on, "Boss", on and "farmAll" or "stop")
	end, 12)
	makeToggle("Take Boss Quest", false, function(on)
		F:Toggle("TakeBossQuest", on, "Boss", on and "takeQuest" or "stop")
	end, 13)
end

-- ─── MATERIAL ─────────────────────────────────────────────────────────────
tabBuilders["Material"] = function()
	secLabel("Material Filter", 1)

	local selSea = 1
	local selIsland = nil
	local selMat = nil

	makeDropdown("Select Sea", {"Sea 1","Sea 2","Sea 3"}, function(v)
		selSea = tonumber(v:match("%d+")) or 1
		selIsland = nil
		openTab("Material")
	end, 2)

	local islandNames = {"All Islands"}
	for _, isl in ipairs(DATA.SeaData[selSea] or {}) do
		table.insert(islandNames, isl.name)
	end
	makeDropdown("Select Island", islandNames, function(v)
		selIsland = (v == "All Islands") and nil or v
		openTab("Material")
	end, 3)

	local matNames
	if selIsland then
		matNames = getMaterialsForIsland(selSea, selIsland)
	else
		matNames = getMaterialsForSea(selSea)
	end
	if #matNames == 0 then matNames = {"(No material)"} end
	table.insert(matNames, 1, "Select...")

	makeDropdown("Select Material", matNames, function(v)
		if v == "Select..." or v == "(No material)" then return end
		selMat = v
		local info = getMaterialInfo(v)
		if info then
			Notif.Push("SUCCESS","Material Info",
				v.." | "..info.island.." | NPC: "..info.npc, 4)
			F:Fire("Material","select",{
				material = v, npc = info.npc, island = info.island,
				sea = info.sea, reqLevel = info.reqLevel,
				dropType = info.dropType, respawn = info.respawn,
			})
		end
		openTab("Material")
	end, 4)

	secLabel("Material Source", 10)
	local infoPanel = makeInfoPanel(11, 130)
	if selMat then
		local info = getMaterialInfo(selMat)
		if info then
			fillInfo(infoPanel, {
				"Material     : "..selMat,
				"Source NPC   : "..info.npc,
				"Location     : "..info.island.." (Sea "..info.sea..")",
				"Drop Type    : "..info.dropType,
				"Required Lv  : "..info.reqLevel,
				"Respawn      : "..info.respawn,
			})
		end
	else
		fillInfo(infoPanel, {"Select a material to see the source."})
	end

	secLabel("Auto Farm", 20)
	makeToggle("Auto Farm Material", false, function(on)
		F:Toggle("AutoFarmMaterial", on, "Material", on and "start" or "stop")
		Notif.Push(on and "SUCCESS" or "INFO","Auto Material",
			on and "Enabled" or "Disabled",2)
	end, 21)
	makeToggle("Stop When Obtained", false, function(on)
		F:Fire("Material","stopWhenObtained",{enable=on})
	end, 22)
end

-- ─── SEA ──────────────────────────────────────────────────────────────────
tabBuilders["Sea"] = function()
	secLabel("Sea Explorer", 1)
	local curSea = 1
	makeDropdown("Sea", {"Sea 1","Sea 2","Sea 3"}, function(v)
		curSea = tonumber(v:match("%d+")) or 1
		openTab("Sea")
	end, 2)

	local npcSet = {}
	for _, isl in ipairs(DATA.SeaData[curSea] or {}) do
		for _, n in ipairs(isl.npcs) do npcSet[n] = true end
	end
	local npcList = {}
	for n in pairs(npcSet) do table.insert(npcList, n) end
	table.sort(npcList)
	if #npcList == 0 then npcList = {"(No NPC)"} end

	makeDropdown("Enemies [Select]", npcList, function(v)
		for _, isl in ipairs(DATA.SeaData[curSea] or {}) do
			for _, n in ipairs(isl.npcs) do
				if n == v then
					Notif.Push("INFO","Enemy Source",
						v.." @ "..isl.name.." (Lv."..isl.reqLevel..")",3)
					F:Fire("Sea","selectEnemy",{enemy=v, sea=curSea, island=isl.name})
					return
				end
			end
		end
	end, 3)

	secLabel("Sea Farm", 10)
	makeToggle("Auto Farm Sea", false, function(on)
		F:Toggle("AutoFarmSea", on, "Sea", on and "farm" or "stop")
	end, 11)
	makeToggle("Auto Destroy Boats", false, function(on)
		F:Toggle("AutoDestroyBoats", on, "Sea", on and "start" or "stop")
	end, 12)
	makeToggle("Buy Boat for Sea Farm", false, function(on)
		F:Toggle("BuyBoat", on, "Sea", on and "start" or "stop")
	end, 13)
	makeToggle("Auto No-Clip Boat", false, function(on)
		F:Toggle("NoClipBoat", on, "Sea", on and "start" or "stop")
	end, 14)
	makeToggle("Auto Destroy Rocks", false, function(on)
		F:Toggle("AutoDestroyRocks", on, "Sea", on and "start" or "stop")
	end, 15)
	makeSlider("Boat Height", 0, 100, 10, function(v)
		F:Fire("Sea","boatHeight",{value=v})
	end, 16)
	makeSlider("Boat Speed", 0, 200, 50, function(v)
		F:Fire("Sea","boatSpeed",{value=v})
	end, 17)
end

-- ─── QUESTS / ITEMS (tanpa Quest dropdown generik) ────────────────────────
tabBuilders["Quests / Items"] = function()
	secLabel("Island Explorer", 1)

	local curSea = 1
	makeDropdown("Sea", {"Sea 1","Sea 2","Sea 3"}, function(v)
		curSea = tonumber(v:match("%d+")) or 1
		openTab("Quests / Items")
	end, 2)

	local islandNames = {}
	for _, isl in ipairs(DATA.SeaData[curSea] or {}) do
		table.insert(islandNames, isl.name)
	end
	if #islandNames == 0 then islandNames = {"(None)"} end

	local islandInfo = makeInfoPanel(4, 150)
	fillInfo(islandInfo, {"Select an island to see info."})

	makeDropdown("Island", islandNames, function(v)
		local isl = getIslandInfo(curSea, v)
		if isl then
			fillInfo(islandInfo, {
				"Sea           : "..curSea,
				"Island        : "..isl.name,
				"Required Lv   : "..isl.reqLevel,
				"NPC           : "..table.concat(isl.npcs, ", "),
				"Quest         : "..table.concat(isl.quests, ", "),
				"Material      : "..((#isl.materials>0) and table.concat(isl.materials, ", ") or "-"),
				"Boss          : "..((#isl.bosses > 0) and table.concat(isl.bosses, ", ") or "-"),
			})
			F:Fire("Quest","island",{island=v, sea=curSea})
		end
	end, 3)

	-- Search island
	local searchIsland = U.mk("TextBox",{
		BackgroundColor3=T.BackgroundSec,BorderSizePixel=0,
		ClearTextOnFocus=false,PlaceholderText="Search island...",
		PlaceholderColor3=T.SecondaryText,TextColor3=T.Text,
		Font=Enum.Font.Gotham,TextSize=12,Text="",
		Size=UDim2.new(1,-8,0,28),
	},ContentScroll)
	U.corner(searchIsland,6); U.stroke(searchIsland); U.pad(searchIsland,6)
	searchIsland.LayoutOrder = 5

	searchIsland:GetPropertyChangedSignal("Text"):Connect(function()
		local kw = string.lower(searchIsland.Text)
		if #kw < 2 then return end
		local matches = {}
		for sea, islands in pairs(DATA.SeaData) do
			for _, isl in ipairs(islands) do
				if string.find(string.lower(isl.name), kw, 1, true) then
					table.insert(matches, "S"..sea..":"..isl.name)
				end
			end
		end
		if #matches > 0 then
			Notif.Push("INFO","Search", table.concat(matches, " | "), 4)
		else
			Notif.Push("WARNING","Search","No island found",2)
		end
	end)

	secLabel("Secret Quest", 10)
	makeButton("Start Secret Quest", function()
		F:Fire("Quest","startSecret",{})
	end, 11)

	secLabel("Weapon Grind", 20)
	local o = 21
	local function itemBtn(n, a)
		makeButton(n, function()
			F:Fire("Quest", a, {enable=true})
			Notif.Push("INFO",n,"Started",2)
		end, o); o += 1
	end
	itemBtn("Auto Get Yama","getYama")
	itemBtn("Auto Get Tushita","getTushita")
	itemBtn("Auto Get Buddy Sword","getBuddySword")
	itemBtn("Auto Get Soul Guitar","getSoulGuitar")
	itemBtn("Kill Cake Prince","killCakePrince")
	itemBtn("Auto Spawn & Kill Indra","spawnIndra")
	itemBtn("Auto Spawn Dough King","spawnDoughKing")
	itemBtn("Auto Get Hallow Scythe","getHallowScythe")
end

-- ─── FRUIT / RAID (tanpa Fruit dropdown generik) ──────────────────────────
tabBuilders["Fruit / Raid"] = function()
	secLabel("Raid", 1)
	makeDropdown("Select Chip", DATA.ChipList, function(v)
		F:Fire("Raid","selectChip",{chip=v})
	end, 2)
	makeButton("Start Raid", function() F:Fire("Raid","start",{}) end, 3)
	makeToggle("AutoKillRaid", false, function(on)
		F:Toggle("AutoKillRaid", on, "Raid", on and "start" or "stop")
	end, 4)

	secLabel("Fruit Roll & Store", 10)
	makeButton("Rolled Fruit", function() F:Fire("Raid","rolled",{}) end, 11)
	makeToggle("Auto Store Fruit", false, function(on)
		F:Toggle("AutoStoreFruit", on, "Raid", on and "store" or "stop")
	end, 12)
end

-- ─── FISHING ──────────────────────────────────────────────────────────────
tabBuilders["Fishing"] = function()
	secLabel("Fishing", 1)
	makeToggle("Auto Fish", false, function(on)
		F:Toggle("AutoFish", on, "Fishing", on and "start" or "stop")
	end, 2)
	makeToggle("Auto Cast", false, function(on)
		F:Toggle("AutoCast", on, "Fishing", on and "start" or "stop")
	end, 3)
end

-- ─── STATUS ───────────────────────────────────────────────────────────────
tabBuilders["Status"] = function()
	secLabel("Server Status", 1)
	local fruitLbl = U.mk("TextLabel",{
		BackgroundTransparency=1,Font=Enum.Font.Gotham,
		Text="Fruit Spawn: -", TextColor3=T.Text, TextSize=13,
		TextXAlignment=Enum.TextXAlignment.Left,
		Size=UDim2.new(1,-8,0,20),
	},ContentScroll); fruitLbl.LayoutOrder = 2
	local mapLbl = U.mk("TextLabel",{
		BackgroundTransparency=1,Font=Enum.Font.Gotham,
		Text="Map Check: -", TextColor3=T.Text, TextSize=13,
		TextXAlignment=Enum.TextXAlignment.Left,
		Size=UDim2.new(1,-8,0,20),
	},ContentScroll); mapLbl.LayoutOrder = 3
	local timeLbl = U.mk("TextLabel",{
		BackgroundTransparency=1,Font=Enum.Font.Gotham,
		Text="Server Time: -", TextColor3=T.Text, TextSize=13,
		TextXAlignment=Enum.TextXAlignment.Left,
		Size=UDim2.new(1,-8,0,20),
	},ContentScroll); timeLbl.LayoutOrder = 4

	makeButton("Check Entire Map", function()
		F:Fire("Misc","checkMap",{})
		Notif.Push("INFO","Map","Checking map...",2)
	end, 5)

	local stRemote = Remotes:FindFirstChild("Misc")
	if stRemote then
		stRemote.OnClientEvent:Connect(function(kind,data)
			if kind=="fruitStatus" then
				fruitLbl.Text = "Fruit Spawn: "..(data and "Yes" or "No")
			elseif kind=="mapStatus" then
				mapLbl.Text = "Map Check: "..tostring(data)
			end
		end)
	end

	task.spawn(function()
		while true do
			timeLbl.Text = "Server Time: "..os.date("%H:%M:%S")
			task.wait(1)
		end
	end)
end

-- ─── PVP ──────────────────────────────────────────────────────────────────
tabBuilders["PvP"] = function()
	secLabel("PvP", 1)
	local playerNames = {"None"}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Player then table.insert(playerNames, p.Name) end
	end
	makeDropdown("Select Player", playerNames, function(v)
		F:Fire("PvP","select",{player=v})
	end, 2)
	makeToggle("Aimbot", false, function(on)
		F:Toggle("Aimbot", on, "PvP", on and "start" or "stop")
	end, 3)
	makeButton("Teleport to Player", function()
		F:Fire("PvP","teleport",{})
	end, 4)
	makeToggle("Auto Skill", false, function(on)
		F:Toggle("AutoSkill", on, "PvP", on and "start" or "stop")
	end, 5)
end

-- ─── STATS ────────────────────────────────────────────────────────────────
tabBuilders["Stats"] = function()
	secLabel("Stat Allocation", 1)
	makeToggle("Start Add Stats", false, function(on)
		F:Toggle("AddStats", on, "Stats", on and "start" or "stop")
	end, 2)
	makeSlider("Melee",      0, 100, 0, function(v) F:Fire("Stats","melee",{value=v}) end, 3)
	makeSlider("Sword",      0, 100, 0, function(v) F:Fire("Stats","sword",{value=v}) end, 4)
	makeSlider("Gun",        0, 100, 0, function(v) F:Fire("Stats","gun",{value=v}) end, 5)
	makeSlider("Defense",    0, 100, 0, function(v) F:Fire("Stats","defense",{value=v}) end, 6)
	makeSlider("Blox Fruit %",0, 100, 0, function(v) F:Fire("Stats","fruit",{value=v}) end, 7)
end

-- ─── MISC ─────────────────────────────────────────────────────────────────
tabBuilders["Misc"] = function()
	secLabel("Server", 1)
	U.mk("TextLabel",{
		BackgroundTransparency=1,Font=Enum.Font.Gotham,
		Text="Job ID: "..game.JobId, TextColor3=T.Text, TextSize=12,
		TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true,
		Size=UDim2.new(1,-8,0,32),
	},ContentScroll).LayoutOrder = 2

	makeButton("Copy Job ID", function()
		if setclipboard then pcall(setclipboard,game.JobId) end
		Notif.Push("SUCCESS","Job ID","Copied",2)
	end, 3)

	local jobBox = U.mk("TextBox",{
		BackgroundColor3=T.BackgroundSec, BorderSizePixel=0,
		ClearTextOnFocus=false, PlaceholderText="Enter Job ID",
		PlaceholderColor3=T.SecondaryText, TextColor3=T.Text,
		Font=Enum.Font.Gotham, TextSize=12, Text="",
		Size=UDim2.new(1,-8,0,30),
	},ContentScroll)
	U.corner(jobBox,6); U.stroke(jobBox); jobBox.LayoutOrder = 4

	makeButton("Join Job ID", function()
		local id = jobBox.Text
		if id and #id >= 8 then
			pcall(function() TS:TeleportToPlaceInstance(game.PlaceId, id, Player) end)
			Notif.Push("INFO","Job ID","Joining "..id,2)
		else
			Notif.Push("WARNING","Job ID","Invalid Job ID",2)
		end
	end, 5)

	secLabel("Utility", 10)
	makeButton("Redeem All Code", function()
		for _, code in ipairs(DATA.RedeemCodes) do
			F:Fire("Misc","redeem",{code=code})
			task.wait(0.6)
		end
		Notif.Push("SUCCESS","Redeem","Sent "..#DATA.RedeemCodes.." codes",3)
	end, 11)
	makeToggle("Anti AFK", false, function(on)
		F:Toggle("AntiAFK", on, "Misc", on and "start" or "stop")
	end, 12)
	makeToggle("No Clip", false, function(on)
		F:Toggle("NoClip", on, "Misc", on and "start" or "stop")
	end, 13)
	makeToggle("Infinite Jump", false, function(on)
		F:Toggle("InfJump", on, "Misc", on and "start" or "stop")
	end, 14)
	makeToggle("Auto Attack", false, function(on)
		F:Toggle("AutoAttackMisc", on, "Combat", on and "start" or "stop")
		CombatObj:SetToggles({AutoAttack = on})
	end, 15)

	local fpsLbl = U.mk("TextLabel",{
		BackgroundTransparency=1,Font=Enum.Font.Gotham,
		Text="FPS: -", TextColor3=T.Text, TextSize=13,
		TextXAlignment=Enum.TextXAlignment.Left,
		Size=UDim2.new(1,-8,0,20),
	},ContentScroll); fpsLbl.LayoutOrder = 16

	local frames, last = 0, tick()
	RunSvc.RenderStepped:Connect(function()
		frames += 1
		if tick() - last >= 1 then
			fpsLbl.Text = "FPS: "..frames
			frames = 0; last = tick()
		end
	end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 13 — SIDEBAR + TAB NAVIGATION
-- ═══════════════════════════════════════════════════════════════════════════
local function openTab(name)
	currentTab = name
	clearContent()
	if tabBuilders[name] then
		U.try(tabBuilders[name], function(e)
			Notif.Push("ERROR","Tab",tostring(e),3)
		end)
	else
		U.mk("TextLabel",{
			BackgroundTransparency=1,Font=Enum.Font.Gotham,
			Text="Coming soon...", TextColor3=T.SecondaryText, TextSize=13,
			Size=UDim2.new(1,-8,0,20),
		},ContentScroll)
	end
	for _, b in ipairs(SidebarScroll:GetChildren()) do
		if b:IsA("TextButton") then
			local active = (b.Name == "Tab_"..name)
			U.tween(b,TweenInfo.new(0.15),{
				BackgroundColor3 = active and T.Primary or T.BackgroundSec,
				TextColor3 = active and T.Text or T.SecondaryText,
			})
		end
	end
end

for i, tabName in ipairs(UI_CFG.Tabs) do
	local b = U.mk("TextButton",{
		Name="Tab_"..tabName, BackgroundColor3=T.BackgroundSec,
		BorderSizePixel=0, Text="  "..tabName,
		TextColor3=T.SecondaryText, Font=Enum.Font.GothamMedium,
		TextSize=13, TextXAlignment=Enum.TextXAlignment.Left,
		AutoButtonColor=false, Size=UDim2.new(1,-4,0,32),
	},SidebarScroll)
	b.LayoutOrder = i; U.corner(b,6)
	b.MouseEnter:Connect(function()
		if currentTab ~= tabName then
			U.tween(b,TweenInfo.new(0.12),{BackgroundColor3=T.Panel})
		end
	end)
	b.MouseLeave:Connect(function()
		if currentTab ~= tabName then
			U.tween(b,TweenInfo.new(0.12),{BackgroundColor3=T.BackgroundSec})
		end
	end)
	b.MouseButton1Click:Connect(function() openTab(tabName) end)
end

openTab("Discord")

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 14 — SEARCH SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════
SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
	local q = string.lower(SearchBar.Text)
	if q == "" then
		if currentTab then openTab(currentTab) end
		return
	end
	local results = {}
	for _, entry in ipairs(registry) do
		local tn = entry[1] and string.lower(entry[1]) or ""
		local fn = entry[2] and string.lower(entry[2]) or ""
		if string.find(tn,q,1,true) or string.find(fn,q,1,true) then
			table.insert(results, entry)
		end
	end
	for _, c in ipairs(ContentScroll:GetChildren()) do
		if c:IsA("GuiObject") then c.Visible = false end
	end
	if #results == 0 then
		local lbl = U.mk("TextLabel",{
			BackgroundTransparency=1,Font=Enum.Font.GothamBold,
			Text="Feature not found", TextColor3=T.Error, TextSize=13,
			Size=UDim2.new(1,-8,0,24),
		},ContentScroll)
		lbl.Visible = true
		return
	end
	for _, entry in ipairs(results) do
		local obj = entry[3]
		if obj and obj.Parent then obj.Visible = true end
	end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 15 — WINDOW / OPEN BUTTON CONTROLS
-- ═══════════════════════════════════════════════════════════════════════════
local isOpen = true
local function setWindow(open)
	isOpen = open
	local target = open
		and UDim2.fromOffset(UI_CFG.WindowSize.X, UI_CFG.WindowSize.Y)
		or  UDim2.fromOffset(0,0)
	U.tween(Main, TweenInfo.new(0.28,Enum.EasingStyle.Quart), {Size=target})
end
openBtn.MouseButton1Click:Connect(function()
	if isOpen then setWindow(false) else setWindow(true) end
end)
closeBtn.MouseButton1Click:Connect(function() setWindow(false) end)
minBtn.MouseButton1Click:Connect(function() setWindow(false) end)

local scaleIdx = 3
scaleBtn.MouseButton1Click:Connect(function()
	scaleIdx = scaleIdx % #UI_CFG.ScaleOpts + 1
	uiScale.Scale = UI_CFG.ScaleOpts[scaleIdx]
	Notif.Push("INFO","UI Scale",
		tostring(math.floor(UI_CFG.ScaleOpts[scaleIdx]*100)).."%",1.5)
end)

-- Drag MainWindow
do
	local dragging, dragStart, startPos
	TopBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Main.Position
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
			local d = input.Position - dragStart
			Main.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- Drag OpenButton
do
	local dragging, dragStart, startPos
	openBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = openBtn.Position
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
			local d = input.Position - dragStart
			openBtn.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 16 — MOBILE GESTURE
-- ═══════════════════════════════════════════════════════════════════════════
if UIS.TouchEnabled then
	SidebarScroll.ScrollingDirection = Enum.ScrollingDirection.Y
	ContentScroll.ScrollingDirection = Enum.ScrollingDirection.Y
end

-- ═══════════════════════════════════════════════════════════════════════════
-- SECTION 17 — CLEANUP
-- ═══════════════════════════════════════════════════════════════════════════
Player.CharacterRemoving:Connect(function()
	CombatObj:Stop()
end)

Notif.Push("SUCCESS","SysxHub","Loaded v"..Brand.Version,3)
