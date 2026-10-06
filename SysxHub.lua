--[[
================================================================
    SYSX HUB | FREEMIUM v2.1
    Flow: Player → NPC (Bring Mob) → Attack → Die
    Tabs: 14
================================================================
]]

--================================================================
-- SERVICES
--================================================================
local Players           = game:GetService("Players")
local RS                = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")
local VirtualUser       = game:GetService("VirtualUser")
local TeleportService   = game:GetService("TeleportService")
local Lighting          = game:GetService("Lighting")
local HttpService       = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local StarterGui        = game:GetService("StarterGui")
local GuiService        = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Remotes = RS:WaitForChild("Remotes", 10)
local CommF_ = Remotes:WaitForChild("CommF_", 10)
local Modules = RS:FindFirstChild("Modules")
local Net = Modules and Modules:FindFirstChild("Net")

repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")

local placeId = game.PlaceId
local World1 = (placeId == 2753915549 or placeId == 85211729168715)
local World2 = (placeId == 4442272183 or placeId == 79091703265657)
local World3 = (placeId == 7449423635 or placeId == 100117331123089)

local DISCORD_INVITE = "https://discord.gg/xWa9NpFRr"

--================================================================
-- THEME
--================================================================
local BLUE_PALETTE = {
    Color3.fromRGB(135, 206, 250),
    Color3.fromRGB(100, 149, 237),
    Color3.fromRGB(80, 130, 220),
    Color3.fromRGB(40, 90, 180),
    Color3.fromRGB(120, 180, 240),
}

local THEME = {
    BG_Main = Color3.fromRGB(8, 12, 24),
    BG_Secondary = Color3.fromRGB(16, 22, 40),
    BG_Tertiary = Color3.fromRGB(24, 32, 56),
    BG_Hover = Color3.fromRGB(32, 44, 76),
    BG_Active = Color3.fromRGB(44, 60, 100),
    Accent_Bright = Color3.fromRGB(180, 220, 255),
    Text_Primary = Color3.fromRGB(230, 238, 248),
    Text_Secondary = Color3.fromRGB(150, 165, 190),
    Text_Muted = Color3.fromRGB(105, 118, 145),
    Border = Color3.fromRGB(40, 55, 90),
    Static_Blue = Color3.fromRGB(60, 130, 220),
    Static_BlueSoft = Color3.fromRGB(180, 220, 255),
    Toggle_On = Color3.fromRGB(30, 100, 180),
    Toggle_Off = Color3.fromRGB(55, 60, 80),
    Toggle_DotOn = Color3.fromRGB(255, 255, 255),
    Toggle_DotOff = Color3.fromRGB(180, 185, 200),
}

local ACCENT_REGISTRY = {}
local function RegisterAccent(s)
    if s and s:IsA("UIStroke") then table.insert(ACCENT_REGISTRY, s) end
end

--================================================================
-- HELPERS
--================================================================
local function Create(cls, props)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do pcall(function() o[k] = v end) end
    return o
end
local function Corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 10); c.Parent = p
end
local function Stroke(p, c, t, tr)
    local s = Instance.new("UIStroke")
    s.Color = c or THEME.Border; s.Thickness = t or 1; s.Transparency = tr or 0.55
    s.Parent = p; return s
end
local function TW(o, props, t)
    TweenService:Create(o, TweenInfo.new(t or 0.25, Enum.EasingStyle.Quart), props):Play()
end
local function GetHRP()
    local c = player.Character
    return c and c:FindFirstChild("HumanoidRootPart") or nil
end
local function IsAlive()
    local c = player.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0 and c:FindFirstChild("HumanoidRootPart") ~= nil
end

--================================================================
-- STATE
--================================================================
local State = {
    AutoFarm=false, AutoFarmNearest=false, AutoChest=false,
    AutoFarmMaterial=false, AutoFarmBones=false, AutoBoss=false,
    SelectedBoss=nil, SelectedMaterial=nil, SelectedWeapon="Melee",
    FastAttack=true, BringMob=true, BringRange=300, BringCount=2,
    AutoFarmSea=false, AutoStoreFruit=false, AutoBuyFruit=false, AutoFindFruit=false,
    AutoRaid=false, AutoAwaken=false, AutoCakePrince=false, AutoDoughKing=false,
    AutoEliteHunter=false, AutoSoulReaper=false, AutoFactory=false, AutoPiratesSea=false,
    AutoTyrant=false, AutoCitizen=false, AutoDragonHunter=false,
    AutoKitsuneSummon=false, AutoKitsuneEmber=false, AutoKitsuneTrade=false,
    AutoMirageSummon=false, AutoMirageTween=false,
    AutoPrehistoricSummon=false, AutoPrehistoricTween=false,
    AutoFrozenTween=false, AutoFindLevi=false, AutoAttackLevi=false,
    AutoV2=false, AutoV3=false, AutoTrial=false, AutoKillAfterTrial=false,
    AutoVolcano=false, AutoCraftMagnet=false,
    AutoMasteryType="Mastery Sword", AutoMastery600=false,
    Aimbot=false, SelectedPlayer=nil, TeleportPlayer=false,
    ESPPlayer=false, ESPFruit=false, ESPChest=false, ESPIsland=false, ESPBoss=false,
    ESPObjects={},
    AntiAFK=true, Noclip=false,
    AutoStats=false, StatMelee=0, StatDefense=0, StatSword=0, StatGun=0, StatFruit=0,
    PointsPerClick=5, BoostFPS=false, WalkWater=false,
    AutoFishing=false, AutoSellFish=false, AutoEquipRod=false,
    AutoShark=false, AutoPiranha=false, AutoTerrorshark=false,
    AutoFishCrew=false, AutoSeaBeast=false, ProtectBoat=false,
    RemoveDamage=false, RemoveNotifications=false, AutoKen=false,
    AutoHaki=true,
    WebhookFruit=false, WebhookMirage=false, WebhookLevi=false, WebhookPre=false,
    WebhookURL="",
    AutoSniper=false, AutoSniperMirage=false,
    AutoDropFruit=false, AutoEatFruit=false,
    SelectedGear="Omega",
    AutoBuyGear=false, AutoChooseGear=false,
}

getgenv().FarmDistance    = 20
getgenv().FarmSpeed       = 200
getgenv().TweenSpeed      = 200
getgenv().CustomWalkSpeed = 100
getgenv().EnableWalkSpeed = false
getgenv().CustomJumpPower = 50
getgenv().EnableJumpPower = false
getgenv().InfiniteJump    = false

--================================================================
-- BRING MOB SYSTEM
--================================================================
local TableMobSpawn = {}
local NameCache = {}

task.spawn(function()
    for _, obj in pairs(getnilinstances and getnilinstances() or {}) do
        if obj:IsA("Part") and obj:GetAttribute("DisplayName") then
            local dn = obj:GetAttribute("DisplayName")
            if string.find(dn, "Lv.") then table.insert(TableMobSpawn, obj) end
        end
    end
    local wo = Workspace:FindFirstChild("_WorldOrigin")
    local es = wo and wo:FindFirstChild("EnemySpawns")
    if es then
        for _, obj in pairs(es:GetChildren()) do
            if obj:IsA("Part") and obj:GetAttribute("DisplayName") then
                local dn = obj:GetAttribute("DisplayName")
                if string.find(dn, "Lv.") and not table.find(TableMobSpawn, obj) then
                    table.insert(TableMobSpawn, obj)
                end
            end
        end
    end
end)

local function CleanName(n)
    if string.find(n, "Lv.") then return (n:gsub(" %pLv. %d+%p", "")) end
    return n
end

local function FindSpawnPart(name, any)
    local clean = CleanName(name)
    for _, sp in pairs(TableMobSpawn) do
        if sp:IsA("Part") then
            local sc = CleanName(sp.Name)
            if sc == name or sc == clean or sp.Name == name then
                if any or not sp:FindFirstChild("Ignored") then return sp end
            end
        end
    end
    return nil
end

function FindEnemy(names, maxRange)
    local hrp = GetHRP(); if not hrp then return nil end
    local enemies = Workspace:FindFirstChild("Enemies"); if not enemies then return nil end

    local lookup = {}
    if type(names) == "table" then
        for _, n in ipairs(names) do lookup[n] = true end
    else lookup[names] = true end

    local maxSq = maxRange and (maxRange * maxRange) or math.huge
    local pos = hrp.Position
    local best, bestD = nil, maxSq

    for _, e in ipairs(enemies:GetChildren()) do
        local h = e:FindFirstChild("Humanoid")
        if h and h.Health > 0 then
            local clean = NameCache[e.Name] or e.Name:match("^(.-)%s*%[") or e.Name
            NameCache[e.Name] = clean
            if lookup[clean] or lookup[e.Name] then
                local trp = e:FindFirstChild("HumanoidRootPart")
                if trp then
                    local d = (trp.Position - pos).Magnitude
                    if d < bestD then best, bestD = e, d end
                end
            end
        end
    end
    return best
end

local BringState = { target=nil, spot=nil, lastPos=0 }
function BringMob(target)
    if not State.BringMob then return end
    if not target or not target.Parent then return end

    local root = target:FindFirstChild("HumanoidRootPart")
    local hum = target:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health <= 0 then return end

    if BringState.target ~= target then
        BringState.target = target
        local sp = FindSpawnPart(target.Name, true)
        BringState.spot = sp and sp.CFrame or root.CFrame
        local enemies = Workspace:FindFirstChild("Enemies")
        if enemies then
            for _, m in ipairs(enemies:GetChildren()) do
                local ig = m:FindFirstChild("Ignored")
                if ig then ig:Destroy() end
            end
        end
    end

    local hrp = GetHRP(); if not hrp then return end
    if tick() - BringState.lastPos < 0.1 then return end
    BringState.lastPos = tick()

    if sethiddenproperty then
        pcall(function()
            sethiddenproperty(player, "SimulationRadius", math.huge)
            sethiddenproperty(player, "MaxSimulationRadius", math.huge)
        end)
    end

    local spot = BringState.spot; if not spot then return end
    local enemies = Workspace:FindFirstChild("Enemies"); if not enemies then return end

    local gathered = {}
    if not target:FindFirstChild("Ignored") then table.insert(gathered, target) end

    local maxCount = State.BringCount or 2
    local radius = (maxCount > 2) and 350 or 200

    for _, m in ipairs(enemies:GetChildren()) do
        if m ~= target and m.Name == target.Name and not m:FindFirstChild("Ignored") then
            local mh = m:FindFirstChildOfClass("Humanoid")
            local mr = m:FindFirstChild("HumanoidRootPart")
            if mh and mr and mh.Health > 0 then
                local dist = (mr.Position - spot.Position).Magnitude
                if dist <= radius and #gathered < maxCount then
                    table.insert(gathered, m)
                end
            end
        end
    end

    if player:DistanceFromCharacter(root.Position) <= 50 and #gathered >= 2 then
        for _, m in pairs(gathered) do
            local mRoot = m:FindFirstChild("HumanoidRootPart")
            local mHum = m:FindFirstChildOfClass("Humanoid")
            if mRoot and mHum then
                for _, p in ipairs(m:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                end
                if mRoot.Size.X < 30 then
                    mRoot.Size = Vector3.new(50, 50, 50)
                    mRoot.CanCollide = false
                    mRoot.AssemblyLinearVelocity = Vector3.zero
                    mRoot.AssemblyAngularVelocity = Vector3.zero
                end
                mRoot.CFrame = spot * CFrame.new(
                    math.random(-8, 8) / 10, -3, math.random(-8, 8) / 10
                )
                mHum.WalkSpeed = 0
                mHum.AutoRotate = false
                mHum.BreakJointsOnDeath = false
                pcall(function() mHum:ChangeState(Enum.HumanoidStateType.Physics) end)
            end
        end
    end
end

--================================================================
-- ATTACK
--================================================================
function AutoHaki()
    if not IsAlive() then return end
    if not player.Character:FindFirstChild("HasBuso") then
        pcall(function() CommF_:InvokeServer("Buso") end)
    end
end

getgenv().EquipTime = 0
function EquipWeapon(n)
    if tick() - getgenv().EquipTime < 0.3 then return end
    getgenv().EquipTime = tick()
    if not n then return end
    local bp = player:FindFirstChild("Backpack"); if not bp then return end
    local t = bp:FindFirstChild(n)
    if t and t:IsA("Tool") then player.Character.Humanoid:EquipTool(t); return end
    for _, x in ipairs(bp:GetChildren()) do
        if x:IsA("Tool") and x.ToolTip == n then player.Character.Humanoid:EquipTool(x); return end
    end
end

function AttackNoCoolDown()
    local char = player.Character; if not char then return end
    local tool = char:FindFirstChildOfClass("Tool"); if not tool then return end
    local enemies = Workspace:FindFirstChild("Enemies"); if not enemies then return end
    local hrp = GetHRP(); if not hrp then return end

    local myPos = hrp.Position
    local hits, main = {}, nil

    for _, e in ipairs(enemies:GetChildren()) do
        local h = e:FindFirstChild("Humanoid")
        local trp = e:FindFirstChild("HumanoidRootPart")
        if h and trp and h.Health > 0 and (trp.Position - myPos).Magnitude <= 60 then
            local head = e:FindFirstChild("Head") or trp
            table.insert(hits, { e, head })
            main = head
        end
    end

    if not main then return end

    if tool:FindFirstChild("LeftClickRemote") then
        local i = 1
        for _, t in ipairs(hits) do
            pcall(function()
                local r = t[1]:FindFirstChild("HumanoidRootPart")
                if r then tool.LeftClickRemote:FireServer((r.Position - myPos).Unit, i); i = i + 1 end
            end)
        end
    elseif Net then
        local RA = Net:FindFirstChild("RE/RegisterAttack")
        local RH = Net:FindFirstChild("RE/RegisterHit")
        if RA and RH then
            pcall(function()
                RA:FireServer(0.1)
                RH:FireServer(main, hits)
            end)
        end
    end
end

--================================================================
-- TELEPORT
--================================================================
local FarmNoclipConn = nil
local function SetFarmNoclip(on)
    if on then
        if FarmNoclipConn then return end
        FarmNoclipConn = RunService.Stepped:Connect(function()
            pcall(function()
                if player.Character then
                    for _, v in pairs(player.Character:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end
            end)
        end)
    else
        if FarmNoclipConn then FarmNoclipConn:Disconnect() FarmNoclipConn = nil end
    end
end

local function AnyFarm()
    return State.AutoFarm or State.AutoFarmNearest or State.AutoChest
        or State.AutoFarmMaterial or State.AutoFarmBones or State.AutoFarmSea
        or State.AutoBoss or State.AutoCakePrince or State.AutoDoughKing
        or State.AutoEliteHunter or State.AutoSoulReaper or State.AutoFactory
        or State.AutoPiratesSea or State.AutoFindFruit or State.AutoTyrant
        or State.AutoCitizen or State.AutoDragonHunter or State.AutoVolcano
        or State.AutoMastery600
end

function FarmTeleport(goal, speed, customTimeout)
    if not goal or not IsAlive() then return end
    local hrp = GetHRP(); if not hrp then return end
    speed = speed or getgenv().FarmSpeed or 200
    local gp = goal.Position
    local initDist = (hrp.Position - gp).Magnitude
    local timeout = customTimeout or math.max(15, initDist / speed * 3)

    SetFarmNoclip(true)
    local lastTick = tick(); local timeoutStart = tick()

    while true do
        if not AnyFarm() then break end
        if not IsAlive() then break end
        local root = GetHRP(); if not root then break end
        local dist = (root.Position - gp).Magnitude
        if dist < 2 then break end
        if tick() - timeoutStart > timeout then break end

        local dt = tick() - lastTick; lastTick = tick()
        if dt <= 0 then dt = 0.016 end
        if dt > 0.2 then dt = 0.2 end

        local dir = (gp - root.Position).Unit
        local move = math.min(speed * dt, dist)
        root.CFrame = root.CFrame + dir * move
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        RunService.Heartbeat:Wait()
    end

    if IsAlive() then
        local root = GetHRP()
        if root then
            local fd = (root.Position - gp).Magnitude
            if fd > 0.5 and fd < 10 then
                root.CFrame = CFrame.new(gp, root.Position + root.CFrame.LookVector)
            end
        end
    end
    SetFarmNoclip(false)
end

--================================================================
-- CHEST
--================================================================
local ChestCache, ChestCacheDone = {}, false
local function BuildChestCache()
    if ChestCacheDone then return end
    ChestCacheDone = true
    ChestCache = {}
    pcall(function()
        for _, o in ipairs(game:GetDescendants()) do
            if o.Name:find("Chest") and o.ClassName == "Part" then
                table.insert(ChestCache, o)
            end
        end
    end)
end
local function GetSortedChests()
    BuildChestCache()
    local char = player.Character; if not char then return {} end
    local root = char:FindFirstChild("LowerTorso") or char:FindFirstChild("HumanoidRootPart")
    if not root then return {} end
    local active = {}
    for _, c in ipairs(ChestCache) do
        if c and c.Parent and c:FindFirstChild("TouchInterest") then
            table.insert(active, c)
        end
    end
    local rp = root.Position
    table.sort(active, function(a,b) return (rp-a.Position).Magnitude < (rp-b.Position).Magnitude end)
    return active
end

--================================================================
-- ESP
--================================================================
local function CreateESP(part, text, color)
    if not part or not part:IsA("BasePart") then return end
    if State.ESPObjects[part] and State.ESPObjects[part].Parent then
        local l = State.ESPObjects[part]:FindFirstChild("SX_ESP_Label")
        if l then l.Text = text end
        return
    end
    local bb = Instance.new("BillboardGui")
    bb.Name = "SX_ESP_BB"
    bb.Size = UDim2.new(0, 150, 0, 40)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = part
    local l = Instance.new("TextLabel")
    l.Name = "SX_ESP_Label"
    l.Size = UDim2.fromScale(1,1)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color
    l.TextStrokeTransparency = 0
    l.TextStrokeColor3 = Color3.new(0,0,0)
    l.TextScaled = true
    l.Font = Enum.Font.GothamBold
    l.Parent = bb
    State.ESPObjects[part] = bb
end
local function ClearESP()
    for p, bb in pairs(State.ESPObjects) do
        pcall(function() bb:Destroy() end)
        State.ESPObjects[p] = nil
    end
end

--================================================================
-- UI BUILD
--================================================================
local old = playerGui:FindFirstChild("SysxHub")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "SysxHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = playerGui

local Notif = Create("TextLabel", {
    Parent = gui,
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -20),
    Size = UDim2.fromOffset(360, 44),
    BackgroundColor3 = THEME.BG_Secondary,
    BackgroundTransparency = 0.05,
    Text = "", TextColor3 = THEME.Accent_Bright,
    TextSize = 13, Font = Enum.Font.GothamMedium,
    Visible = false, ZIndex = 999999,
})
Corner(Notif, 12)
RegisterAccent(Stroke(Notif, BLUE_PALETTE[1], 1.5, 0.2))

local main = Create("Frame", {
    Parent = gui,
    Size = UDim2.fromOffset(700, 540),
    Position = UDim2.new(0.5, -350, 0.5, -270),
    BackgroundColor3 = THEME.BG_Main,
    BorderSizePixel = 0,
    Visible = true,
    ClipsDescendants = true,
    ZIndex = 10,
})
Corner(main, 18)
RegisterAccent(Stroke(main, BLUE_PALETTE[1], 1.2, 0.45))

local header = Create("Frame", {
    Parent = main,
    Size = UDim2.new(1, 0, 0, 74),
    BackgroundTransparency = 1,
    ZIndex = 20,
})
Create("TextLabel", {
    Parent = header, BackgroundTransparency = 1,
    Position = UDim2.fromOffset(20, 10),
    Size = UDim2.fromOffset(340, 22),
    Text = "SysxHub",
    TextColor3 = THEME.Accent_Bright,
    TextSize = 20, Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 22,
})
Create("TextLabel", {
    Parent = header, BackgroundTransparency = 1,
    Position = UDim2.fromOffset(20, 32),
    Size = UDim2.fromOffset(340, 15),
    Text = "Freemium v2.1  •  Bring Mob System",
    TextColor3 = THEME.Text_Secondary,
    TextSize = 10, Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 22,
})

local close = Create("TextButton", {
    Parent = header,
    Size = UDim2.fromOffset(36, 36),
    Position = UDim2.new(1, -52, 0, 12),
    BackgroundColor3 = THEME.BG_Secondary,
    BackgroundTransparency = 0.1,
    Text = "×",
    TextColor3 = THEME.Accent_Bright,
    TextSize = 22,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false, ZIndex = 25,
})
Corner(close, 10)
RegisterAccent(Stroke(close, BLUE_PALETTE[1], 1.2, 0.35))

Create("Frame", {
    Parent = header,
    Size = UDim2.new(1, -32, 0, 1),
    Position = UDim2.new(0, 16, 1, -2),
    BackgroundColor3 = Color3.fromRGB(60, 90, 150),
    BackgroundTransparency = 0.6,
    BorderSizePixel = 0, ZIndex = 22,
})

local content = Create("Frame", {
    Parent = main,
    Size = UDim2.new(1, -32, 1, -90),
    Position = UDim2.fromOffset(16, 80),
    BackgroundTransparency = 1,
    ZIndex = 14,
})

local sidebar = Create("Frame", {
    Parent = content,
    BackgroundColor3 = THEME.BG_Secondary,
    Size = UDim2.new(0, 145, 1, 0),
    BorderSizePixel = 0, ZIndex = 15,
})
Corner(sidebar, 12)
Stroke(sidebar, THEME.Border, 1, 0.5)

local tabList = Create("ScrollingFrame", {
    Parent = sidebar,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 6, 0, 6),
    Size = UDim2.new(1, -12, 1, -12),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Color3.fromRGB(80, 130, 220),
    BorderSizePixel = 0, ZIndex = 16,
})
local TL = Instance.new("UIListLayout")
TL.Padding = UDim.new(0, 4)
TL.SortOrder = Enum.SortOrder.LayoutOrder
TL.Parent = tabList

local contentScroll = Create("ScrollingFrame", {
    Parent = content,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 155, 0, 0),
    Size = UDim2.new(1, -155, 1, 0),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = Color3.fromRGB(80, 130, 220),
    BorderSizePixel = 0, ZIndex = 14,
})

local Pages, Tabs = {}, {}

local function CreatePage(name)
    local P = Create("ScrollingFrame", {
        Name = name, Parent = contentScroll,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 4, 0, 4),
        Size = UDim2.new(1, -8, 1, -8),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(80, 130, 220),
        BorderSizePixel = 0, Visible = false, ZIndex = 12,
    })
    local L = Instance.new("UIListLayout")
    L.Padding = UDim.new(0, 6)
    L.SortOrder = Enum.SortOrder.LayoutOrder
    L.Parent = P
    Pages[name] = P
    return P
end

local function CreateTab(name, order)
    local B = Create("TextButton", {
        Parent = tabList,
        BackgroundColor3 = THEME.BG_Secondary,
        Size = UDim2.new(1, 0, 0, 30),
        Text = "", AutoButtonColor = false,
        BorderSizePixel = 0, LayoutOrder = order, ZIndex = 17,
    })
    Corner(B, 8)
    local L = Create("TextLabel", {
        Parent = B, BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -14, 1, 0),
        Text = name, TextColor3 = THEME.Text_Secondary,
        TextSize = 10, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 18,
    })
    Tabs[name] = { Button = B, Label = L, Stroke = nil }
    B.MouseEnter:Connect(function()
        if Tabs[name].Label.TextColor3 ~= THEME.Accent_Bright then
            TW(B, {BackgroundColor3 = THEME.BG_Hover}, 0.15)
        end
    end)
    B.MouseLeave:Connect(function()
        if Tabs[name].Label.TextColor3 ~= THEME.Accent_Bright then
            TW(B, {BackgroundColor3 = THEME.BG_Secondary}, 0.15)
        end
    end)
    return B
end

local function ShowTab(name)
    for pn, p in pairs(Pages) do p.Visible = (pn == name) end
    for tn, d in pairs(Tabs) do
        if tn == name then
            d.Button.BackgroundColor3 = THEME.BG_Active
            d.Label.TextColor3 = THEME.Accent_Bright
            if d.Stroke then d.Stroke:Destroy() end
            d.Stroke = Stroke(d.Button, BLUE_PALETTE[1], 1.2, 0.15)
            RegisterAccent(d.Stroke)
        else
            d.Button.BackgroundColor3 = THEME.BG_Secondary
            d.Label.TextColor3 = THEME.Text_Secondary
            if d.Stroke then d.Stroke:Destroy() d.Stroke = nil end
        end
    end
end

--================================================================
-- COMPONENTS
--================================================================
local function CreateToggle(parent, text, default, cb)
    local st = default and true or false
    local B = Create("TextButton", {
        Parent = parent, BackgroundColor3 = THEME.BG_Secondary,
        Size = UDim2.new(1, 0, 0, 38), Text = "",
        AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 100,
    })
    Corner(B, 9)
    RegisterAccent(Stroke(B, BLUE_PALETTE[1], 1, 0.55))

    Create("TextLabel", {
        Parent = B, BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -58, 1, 0),
        Text = text, TextColor3 = THEME.Text_Primary,
        TextSize = 11, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 101,
    })

    local Ind = Create("Frame", {
        Parent = B, BackgroundColor3 = THEME.Toggle_Off,
        Size = UDim2.fromOffset(36, 20),
        Position = UDim2.new(1, -48, 0.5, -10), ZIndex = 101,
    })
    Corner(Ind, 20)
    local Dot = Create("Frame", {
        Parent = Ind, BackgroundColor3 = THEME.Toggle_DotOff,
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(0, 3, 0.5, -7), ZIndex = 102,
    })
    Corner(Dot, 20)

    local function render()
        if st then
            Ind.BackgroundColor3 = THEME.Toggle_On
            Dot.BackgroundColor3 = THEME.Toggle_DotOn
            Dot.Position = UDim2.new(1, -17, 0.5, -7)
        else
            Ind.BackgroundColor3 = THEME.Toggle_Off
            Dot.BackgroundColor3 = THEME.Toggle_DotOff
            Dot.Position = UDim2.new(0, 3, 0.5, -7)
        end
    end

    B.Activated:Connect(function()
        st = not st; render()
        if cb then pcall(cb, st) end
    end)
    render()
    if st and cb then task.defer(function() pcall(cb, true) end) end
    return B
end

local function CreateButton(parent, text, cb)
    local B = Create("TextButton", {
        Parent = parent, BackgroundColor3 = THEME.BG_Secondary,
        Size = UDim2.new(1, 0, 0, 38), Text = text,
        TextColor3 = THEME.Text_Primary, TextSize = 11,
        Font = Enum.Font.GothamMedium, AutoButtonColor = false,
        BorderSizePixel = 0, ZIndex = 100,
    })
    Corner(B, 9)
    RegisterAccent(Stroke(B, BLUE_PALETTE[1], 1.1, 0.55))
    B.MouseEnter:Connect(function() TW(B, {BackgroundColor3 = THEME.BG_Hover}, 0.15) end)
    B.MouseLeave:Connect(function() TW(B, {BackgroundColor3 = THEME.BG_Secondary}, 0.15) end)
    B.Activated:Connect(function()
        TW(B, {BackgroundColor3 = THEME.BG_Active}, 0.08)
        task.delay(0.1, function() TW(B, {BackgroundColor3 = THEME.BG_Secondary}, 0.15) end)
        if cb then pcall(cb) end
    end)
    return B
end

local function CreateDropdown(parent, title, options, cb)
    options = options or {"-"}
    local Hold = Create("Frame", {
        Parent = parent, BackgroundColor3 = THEME.BG_Secondary,
        Size = UDim2.new(1, 0, 0, 38),
        BorderSizePixel = 0, ZIndex = 100,
    })
    Corner(Hold, 9)
    RegisterAccent(Stroke(Hold, BLUE_PALETTE[1], 1.1, 0.55))
    local Sel = options[1] or "-"
    local Lbl = Create("TextLabel", {
        Parent = Hold, BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -32, 1, 0),
        Text = title .. ": " .. Sel,
        TextColor3 = THEME.Text_Primary, TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 101,
    })
    Create("TextLabel", {
        Parent = Hold, BackgroundTransparency = 1,
        Position = UDim2.new(1, -22, 0, 0),
        Size = UDim2.new(0, 16, 1, 0),
        Text = "v", TextColor3 = THEME.Static_BlueSoft,
        TextSize = 11, Font = Enum.Font.GothamBold, ZIndex = 101,
    })
    local click = Create("TextButton", {
        Parent = Hold, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), Text = "",
        AutoButtonColor = false, ZIndex = 110,
    })
    click.Activated:Connect(function()
        local Pop = Create("Frame", {
            Parent = gui,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.fromOffset(300, math.min(#options*38+80, 420)),
            BackgroundColor3 = THEME.BG_Secondary,
            BorderSizePixel = 0, ZIndex = 999990,
        })
        Corner(Pop, 14)
        RegisterAccent(Stroke(Pop, BLUE_PALETTE[1], 1.5, 0.25))
        Create("TextLabel", {
            Parent = Pop, BackgroundTransparency = 1,
            Position = UDim2.fromOffset(18, 10),
            Size = UDim2.new(1, -60, 0, 22),
            Text = title, TextColor3 = THEME.Accent_Bright,
            TextSize = 14, Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 999991,
        })
        local xBtn = Create("TextButton", {
            Parent = Pop, Position = UDim2.new(1, -40, 0, 10),
            Size = UDim2.fromOffset(28, 22), Text = "x",
            TextColor3 = THEME.Text_Muted, TextSize = 14,
            BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
            AutoButtonColor = false, ZIndex = 999992,
        })
        xBtn.Activated:Connect(function() Pop:Destroy() end)
        local LS = Create("ScrollingFrame", {
            Parent = Pop, BackgroundTransparency = 1,
            Position = UDim2.fromOffset(12, 42),
            Size = UDim2.new(1, -24, 1, -54),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Color3.fromRGB(80, 130, 220),
            BorderSizePixel = 0, ZIndex = 999991,
        })
        local LL = Instance.new("UIListLayout")
        LL.Padding = UDim.new(0, 4)
        LL.SortOrder = Enum.SortOrder.LayoutOrder
        LL.Parent = LS
        for i, opt in ipairs(options) do
            local OB = Create("TextButton", {
                Parent = LS, BackgroundColor3 = THEME.BG_Tertiary,
                Size = UDim2.new(1, -8, 0, 34),
                Position = UDim2.new(0, 4, 0, 0),
                Text = opt, TextColor3 = THEME.Text_Primary,
                TextSize = 12, Font = Enum.Font.GothamMedium,
                AutoButtonColor = false, BorderSizePixel = 0,
                LayoutOrder = i, ZIndex = 999992,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            Corner(OB, 7)
            local pad = Instance.new("UIPadding")
            pad.PaddingLeft = UDim.new(0, 12); pad.Parent = OB
            OB.MouseEnter:Connect(function() TW(OB, {BackgroundColor3 = THEME.BG_Hover}, 0.1) end)
            OB.MouseLeave:Connect(function() TW(OB, {BackgroundColor3 = THEME.BG_Tertiary}, 0.1) end)
            OB.Activated:Connect(function()
                Sel = opt
                Lbl.Text = title .. ": " .. opt
                if cb then pcall(cb, opt) end
                Pop:Destroy()
            end)
        end
    end)
    return Hold
end

local function CreateSlider(parent, title, minV, maxV, defV, cb)
    local val = defV or minV
    local Hold = Create("Frame", {
        Parent = parent, BackgroundColor3 = THEME.BG_Secondary,
        Size = UDim2.new(1, 0, 0, 58),
        BorderSizePixel = 0, ZIndex = 100,
    })
    Corner(Hold, 9)
    RegisterAccent(Stroke(Hold, BLUE_PALETTE[1], 1, 0.55))
    Create("TextLabel", {
        Parent = Hold, BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 8),
        Size = UDim2.new(1, -90, 0, 16),
        Text = title, TextColor3 = THEME.Text_Secondary,
        TextSize = 10, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 101,
    })
    local VH = Create("Frame", {
        Parent = Hold, BackgroundColor3 = THEME.BG_Tertiary,
        Position = UDim2.new(1, -74, 0, 6),
        Size = UDim2.fromOffset(60, 20), ZIndex = 101,
    })
    Corner(VH, 6)
    Stroke(VH, THEME.Border, 1, 0.4)
    local VL = Create("TextLabel", {
        Parent = VH, BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = tostring(val), TextColor3 = THEME.Static_BlueSoft,
        TextSize = 11, Font = Enum.Font.GothamBold, ZIndex = 102,
    })
    local TB = Create("Frame", {
        Parent = Hold, BackgroundColor3 = THEME.BG_Tertiary,
        Position = UDim2.new(0, 14, 0, 36),
        Size = UDim2.new(1, -28, 0, 6),
        BorderSizePixel = 0, ZIndex = 101,
    })
    Corner(TB, 4)
    local fr = (val - minV) / (maxV - minV)
    local Fill = Create("Frame", {
        Parent = TB, BackgroundColor3 = THEME.Static_Blue,
        Size = UDim2.new(fr, 0, 1, 0),
        BorderSizePixel = 0, ZIndex = 102,
    })
    Corner(Fill, 4)
    local Knob = Create("Frame", {
        Parent = TB, BackgroundColor3 = Color3.new(1,1,1),
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(fr, -7, 0.5, -7),
        BorderSizePixel = 0, ZIndex = 103,
    })
    Corner(Knob, 20)
    Stroke(Knob, THEME.BG_Main, 1.5, 0)
    local Btn = Create("TextButton", {
        Parent = Hold, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 34),
        Position = UDim2.new(0, 0, 0, 22),
        Text = "", AutoButtonColor = false, ZIndex = 110,
    })
    local drag = false
    local function upd(mx)
        local abs = TB.AbsolutePosition
        local sz = TB.AbsoluteSize
        if sz.X == 0 then return end
        local r = math.clamp((mx - abs.X) / sz.X, 0, 1)
        val = math.floor(minV + (maxV - minV) * r + 0.5)
        Fill.Size = UDim2.new(r, 0, 1, 0)
        Knob.Position = UDim2.new(r, -7, 0.5, -7)
        VL.Text = tostring(val)
        if cb then pcall(cb, val) end
    end
    Btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; upd(i.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            upd(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
    return Hold
end

local function CreateLabel(parent, text, sz)
    local L = Create("TextLabel", {
        Parent = parent, BackgroundColor3 = THEME.BG_Secondary,
        Size = UDim2.new(1, 0, 0, sz or 28),
        Text = text, TextColor3 = THEME.Text_Primary,
        TextSize = 10, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        BorderSizePixel = 0, ZIndex = 100,
    })
    Corner(L, 9)
    RegisterAccent(Stroke(L, BLUE_PALETTE[1], 1, 0.55))
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingTop = UDim.new(0, 6)
    pad.Parent = L
    return L
end

--================================================================
-- NOTIFY
--================================================================
function Notify(text)
    if not Notif or not Notif.Parent then return end
    Notif.__tk = (Notif.__tk or 0) + 1
    local tk = Notif.__tk
    Notif.Text = tostring(text)
    Notif.Visible = true
    Notif.TextTransparency = 1
    Notif.BackgroundTransparency = 1
    TW(Notif, {TextTransparency = 0, BackgroundTransparency = 0.05}, 0.25)
    task.delay(2.5, function()
        if tk ~= Notif.__tk then return end
        TW(Notif, {TextTransparency = 1, BackgroundTransparency = 1}, 0.25)
        task.wait(0.25)
        if tk == Notif.__tk then Notif.Visible = false end
    end)
end

local function TryBuy(cmd, ...)
    local a = {...}
    local ok = pcall(function() return CommF_:InvokeServer(cmd, table.unpack(a)) end)
    Notify(ok and "Purchased: " .. cmd or "Failed: " .. cmd)
end

--================================================================
-- ANIMASI
--================================================================
local ci = 1
task.spawn(function()
    while task.wait(3) do
        ci = (ci % #BLUE_PALETTE) + 1
        local tc = BLUE_PALETTE[ci]
        for _, s in ipairs(ACCENT_REGISTRY) do
            if s and s.Parent then
                pcall(function()
                    TweenService:Create(s,
                        TweenInfo.new(2.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                        {Color = tc}):Play()
                end)
            end
        end
    end
end)

--================================================================
-- TABS
--================================================================
local TabDefs = {
    {"Home"},{"Farm"},{"PvP"},{"Sea"},{"Fishing"},{"Stats"},{"Race"},
    {"Fruit & Raid"},{"Quest & Item"},{"Visual"},{"Teleport"},
    {"Shop"},{"Settings"},{"Misc"}
}
for i, d in ipairs(TabDefs) do
    local b = CreateTab(d[1], i)
    b.Activated:Connect(function() ShowTab(d[1]) end)
end

local HomePage      = CreatePage("Home")
local FarmPage      = CreatePage("Farm")
local PvPPage       = CreatePage("PvP")
local SeaPage       = CreatePage("Sea")
local FishingPage   = CreatePage("Fishing")
local StatsPage     = CreatePage("Stats")
local RacePage      = CreatePage("Race")
local FruitRaidPage = CreatePage("Fruit & Raid")
local QuestItemPage = CreatePage("Quest & Item")
local VisualPage    = CreatePage("Visual")
local TeleportPage  = CreatePage("Teleport")
local ShopPage      = CreatePage("Shop")
local SettingsPage  = CreatePage("Settings")
local MiscPage      = CreatePage("Misc")

--================================================================
-- HOME
--================================================================
CreateLabel(HomePage, "=== SysxHub v2.1 ===", 32)
local homeInfo = CreateLabel(HomePage,
    "Bring Mob System\n\n" ..
    "Flow Farm:\n" ..
    "  1. Cari mob di spawn\n" ..
    "  2. Tween ke lokasi spawn\n" ..
    "  3. Bring mob ke player\n" ..
    "  4. Attack sampai mati\n\n" ..
    "Wajib aktifkan:\n" ..
    "  • Bring Mob (Misc)\n" ..
    "  • Bring Mob Count (Misc)",
    180)
homeInfo.TextSize = 11
homeInfo.TextYAlignment = Enum.TextYAlignment.Top

CreateButton(HomePage, "Join Discord Server", function()
    if setclipboard then setclipboard(DISCORD_INVITE) end
    pcall(function() GuiService:OpenBrowserWindow(DISCORD_INVITE) end)
    Notify("Opening Discord...")
end)

CreateLabel(HomePage, "SysxHub | Freemium v2.1", 34)

--================================================================
-- FARM
--================================================================
CreateLabel(FarmPage, "=== Farm Settings ===", 26)
CreateDropdown(FarmPage, "Select Weapon", {"Melee","Sword","Blox Fruit","Gun"}, function(o) State.SelectedWeapon = o end)

CreateLabel(FarmPage, "=== Auto Farm ===", 26)
CreateToggle(FarmPage, "Auto Farm Level", false, function(s)
    State.AutoFarm = s
    Notify(s and "Auto Farm Level ON" or "Auto Farm Level OFF")
end)
CreateToggle(FarmPage, "Auto Farm Nearest", false, function(s) State.AutoFarmNearest = s end)
CreateToggle(FarmPage, "Auto Collect Chest", false, function(s)
    State.AutoChest = s
    if s then ChestCacheDone = false; ChestCache = {} end
end)
CreateToggle(FarmPage, "Auto Farm Bones", false, function(s) State.AutoFarmBones = s end)

CreateLabel(FarmPage, "=== Material Farm ===", 26)
local MaterialList = World1 and {"Angel Wings","Leather + Scrap Metal","Magma Ore","Fish Tail"}
    or World2 and {"Leather + Scrap Metal","Magma Ore","Mystic Droplet","Radioactive Material","Vampire Fang"}
    or World3 and {"Leather + Scrap Metal","Fish Tail","Gunpowder","Mini Tusk","Conjured Cocoa","Dragon Scale"}
    or {"None"}
CreateDropdown(FarmPage, "Select Material", MaterialList, function(o) State.SelectedMaterial = o end)
CreateToggle(FarmPage, "Auto Farm Material", false, function(s) State.AutoFarmMaterial = s end)

CreateLabel(FarmPage, "=== ⭐ BOSS FARM ===", 26)
local BossList = {"Greybeard","The Saw","Saber Expert","The Gorilla King","Bobby","Yeti","Vice Admiral","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Darkbeard","Cursed Captain","Order","Don Swan","Diamond","Jeremy","Fajita","Smoke Admiral","Awakened Ice Admiral","Tide Keeper","Dough King","Cake Prince","rip_indra True Form","Soul Reaper","Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate","Cake Queen","Longma"}
CreateDropdown(FarmPage, "Select Boss", BossList, function(o) State.SelectedBoss = o end)
local BossStat = CreateLabel(FarmPage, "Boss Status: -", 28)
BossStat.TextSize = 11
CreateToggle(FarmPage, "Kill Select Boss", false, function(s) State.AutoBoss = s end)

--================================================================
-- PVP
--================================================================
CreateLabel(PvPPage, "=== PvP ===", 26)
local pvpPlayers = {"None"}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= player then table.insert(pvpPlayers, p.Name) end
end
CreateDropdown(PvPPage, "Select Player", pvpPlayers, function(o) State.SelectedPlayer = o end)
CreateToggle(PvPPage, "Teleport To Player", false, function(s) State.TeleportPlayer = s end)
CreateToggle(PvPPage, "Auto Aimbot", false, function(s) State.Aimbot = s end)

--================================================================
-- SEA
--================================================================
CreateLabel(SeaPage, "=== Sea Settings ===", 26)
CreateDropdown(SeaPage, "Select Boat", {"PirateBrigade","PirateGrandBrigade","MarineBrigade","MarineGrandBrigade","Beast Hunter"}, function(o) getgenv().SelectedBoat = o end)
CreateToggle(SeaPage, "Auto Farm Sea", false, function(s) State.AutoFarmSea = s end)
CreateToggle(SeaPage, "Protect Boat", false, function(s) State.ProtectBoat = s end)

CreateLabel(SeaPage, "=== Sea Enemies ===", 26)
CreateToggle(SeaPage, "Auto Shark", false, function(s) State.AutoShark = s end)
CreateToggle(SeaPage, "Auto Piranha", false, function(s) State.AutoPiranha = s end)
CreateToggle(SeaPage, "Auto Terrorshark", false, function(s) State.AutoTerrorshark = s end)
CreateToggle(SeaPage, "Auto Fish Crew", false, function(s) State.AutoFishCrew = s end)
CreateToggle(SeaPage, "Auto Sea Beast", false, function(s) State.AutoSeaBeast = s end)

CreateLabel(SeaPage, "=== Find Islands ===", 26)
CreateToggle(SeaPage, "Find Mirage Island", false, function(s) getgenv().FindMirage = s end)
CreateToggle(SeaPage, "Find Prehistoric Island", false, function(s) getgenv().FindPrehistoric = s end)
CreateToggle(SeaPage, "Find Frozen Dimension", false, function(s) getgenv().FindFrozen = s end)
CreateToggle(SeaPage, "Find Kitsune Island", false, function(s) getgenv().FindKitsune = s end)

--================================================================
-- FISHING
--================================================================
CreateLabel(FishingPage, "=== Fishing ===", 26)
CreateToggle(FishingPage, "Auto Equip Rod", false, function(s) State.AutoEquipRod = s end)
CreateToggle(FishingPage, "Auto Fishing", false, function(s) State.AutoFishing = s end)
CreateToggle(FishingPage, "Auto Sell Fish", false, function(s) State.AutoSellFish = s end)

--================================================================
-- STATS
--================================================================
CreateLabel(StatsPage, "=== Auto Stats ===", 26)
CreateSlider(StatsPage, "Points Per Click", 1, 50, 5, function(v) State.PointsPerClick = v end)
CreateToggle(StatsPage, "Auto Melee", false, function(s) State.StatMelee = s and 1 or 0 end)
CreateToggle(StatsPage, "Auto Defense", false, function(s) State.StatDefense = s and 1 or 0 end)
CreateToggle(StatsPage, "Auto Sword", false, function(s) State.StatSword = s and 1 or 0 end)
CreateToggle(StatsPage, "Auto Gun", false, function(s) State.StatGun = s and 1 or 0 end)
CreateToggle(StatsPage, "Auto Blox Fruit", false, function(s) State.StatFruit = s and 1 or 0 end)
CreateToggle(StatsPage, "Enable Auto Stats", false, function(s) State.AutoStats = s end)

CreateLabel(StatsPage, "=== Manual Add ===", 26)
CreateButton(StatsPage, "Add 100 Melee", function() CommF_:InvokeServer("AddPoint", "Melee", 100) Notify("+100 Melee") end)
CreateButton(StatsPage, "Add 100 Defense", function() CommF_:InvokeServer("AddPoint", "Defense", 100) Notify("+100 Defense") end)
CreateButton(StatsPage, "Add 100 Sword", function() CommF_:InvokeServer("AddPoint", "Sword", 100) Notify("+100 Sword") end)
CreateButton(StatsPage, "Add 100 Gun", function() CommF_:InvokeServer("AddPoint", "Gun", 100) Notify("+100 Gun") end)
CreateButton(StatsPage, "Add 100 Blox Fruit", function() CommF_:InvokeServer("AddPoint", "Demon Fruit", 100) Notify("+100 Fruit") end)

CreateLabel(StatsPage, "=== Refund ===", 26)
CreateButton(StatsPage, "Buy Stat Refund", function()
    TryBuy("BlackbeardReward", "Refund", "1")
    task.wait(0.3)
    TryBuy("BlackbeardReward", "Refund", "2")
end)
CreateButton(StatsPage, "Buy Race Reroll", function()
    TryBuy("BlackbeardReward", "Reroll", "1")
    task.wait(0.3)
    TryBuy("BlackbeardReward", "Reroll", "2")
end)

--================================================================
-- RACE
--================================================================
CreateLabel(RacePage, "=== Race V4 ===", 26)
CreateToggle(RacePage, "No Frog", false, function(s)
    if s then
        Lighting.FogEnd = 100000
        for _, d in pairs(Lighting:GetDescendants()) do
            if d:IsA("Atmosphere") then d:Destroy() end
        end
    end
end)
CreateButton(RacePage, "Teleport Temple of Time", function()
    local hrp = GetHRP()
    if hrp then hrp.CFrame = CFrame.new(28286.35, 14895.30, 102.62) end
    local ms = RS:FindFirstChild("MapStash")
    local tot = ms and ms:FindFirstChild("Temple of Time")
    if tot then tot.Parent = Workspace.Map end
    Notify("At Temple of Time")
end)
CreateToggle(RacePage, "Auto Buy Gear V4", false, function(s) State.AutoBuyGear = s end)
CreateDropdown(RacePage, "Select Gear V4", {"Alpha","Omega"}, function(o) State.SelectedGear = o end)
CreateToggle(RacePage, "Auto Choose Gears", false, function(s) State.AutoChooseGear = s end)
CreateToggle(RacePage, "Auto Trial", false, function(s) State.AutoTrial = s end)
CreateToggle(RacePage, "Auto Kill After Trial", false, function(s) State.AutoKillAfterTrial = s end)

CreateLabel(RacePage, "=== Race V2-V3 ===", 26)
CreateToggle(RacePage, "Auto V2", false, function(s) State.AutoV2 = s end)
CreateToggle(RacePage, "Auto V3", false, function(s) State.AutoV3 = s end)
CreateToggle(RacePage, "Auto Get Cyborg", false, function(s) State.AutoCyborg = s end)
CreateToggle(RacePage, "Auto Get Ghoul", false, function(s) State.AutoGhoul = s end)

--================================================================
-- FRUIT & RAID
--================================================================
CreateLabel(FruitRaidPage, "=== Fruit ===", 26)
CreateToggle(FruitRaidPage, "Auto Store Fruit", false, function(s) State.AutoStoreFruit = s end)
CreateToggle(FruitRaidPage, "Auto Buy Random Fruit", false, function(s) State.AutoBuyFruit = s end)
CreateToggle(FruitRaidPage, "Tween to Fruit", false, function(s) State.AutoFindFruit = s end)
CreateToggle(FruitRaidPage, "Auto Drop Fruit", false, function(s) State.AutoDropFruit = s end)
CreateToggle(FruitRaidPage, "Auto Eat Fruit", false, function(s) State.AutoEatFruit = s end)

CreateLabel(FruitRaidPage, "=== Raid ===", 26)
CreateDropdown(FruitRaidPage, "Select Chip",
    {"Flame","Ice","Sand","Dark","Light","Magma","Quake","Buddha","Love","Spider","Sound","Phoenix","Portal","Rumble","Pain","Blizzard","Gravity"},
    function(o) getgenv().SelectedChip = o end)
CreateToggle(FruitRaidPage, "Auto Raid", false, function(s) State.AutoRaid = s end)
CreateToggle(FruitRaidPage, "Auto Awaken Fruit", false, function(s) State.AutoAwaken = s end)

CreateLabel(FruitRaidPage, "=== Sniper ===", 26)
CreateToggle(FruitRaidPage, "Auto Buy Fruits Sniper", false, function(s) State.AutoSniper = s end)
CreateToggle(FruitRaidPage, "Auto Buy Sniper (Mirage)", false, function(s) State.AutoSniperMirage = s end)

--================================================================
-- QUEST & ITEM
--================================================================
CreateLabel(QuestItemPage, "=== Special Boss ===", 26)
CreateToggle(QuestItemPage, "Auto Cake Prince", false, function(s) State.AutoCakePrince = s end)
CreateToggle(QuestItemPage, "Auto Dough King", false, function(s) State.AutoDoughKing = s end)
CreateToggle(QuestItemPage, "Auto Elite Hunter", false, function(s) State.AutoEliteHunter = s end)
CreateToggle(QuestItemPage, "Auto Soul Reaper", false, function(s) State.AutoSoulReaper = s end)
CreateToggle(QuestItemPage, "Auto Kill Tyrant", false, function(s) State.AutoTyrant = s end)
CreateToggle(QuestItemPage, "Auto Citizen Quest", false, function(s) State.AutoCitizen = s end)
CreateToggle(QuestItemPage, "Auto Dragon Hunter", false, function(s) State.AutoDragonHunter = s end)

CreateLabel(QuestItemPage, "=== Mastery 600 ===", 26)
CreateDropdown(QuestItemPage, "Mastery Type",
    {"Mastery Sword","Mastery Gun","Mastery Fruit"},
    function(o) State.AutoMasteryType = o end)
CreateToggle(QuestItemPage, "Auto 600 Mastery", false, function(s) State.AutoMastery600 = s end)

CreateLabel(QuestItemPage, "=== All Sword Quest ===", 26)
local SwordList = {"Saber","Tushita","Yama","Buddy Sword","Shark Anchor","Dark Dagger","Twin Hooks","Canvander","Spikey Trident","True Triple Katana","CDK","Yoru Mini","Soul Guitar"}
CreateDropdown(QuestItemPage, "Select Sword", SwordList, function(o) getgenv().SelectedSword = o end)
CreateToggle(QuestItemPage, "Auto Get Sword", false, function(s) getgenv().AutoGetSword = s end)

CreateLabel(QuestItemPage, "=== All Gun Quest ===", 26)
local GunList = {"Kabucha","Serpent Bow","Acidum Rifle","Bizarre Rifle","Dragonstorm","Skull Guitar","Venom Bow","Dual Flintlock"}
CreateDropdown(QuestItemPage, "Select Gun", GunList, function(o) getgenv().SelectedGun = o end)
CreateToggle(QuestItemPage, "Auto Get Gun", false, function(s) getgenv().AutoGetGun = s end)

CreateLabel(QuestItemPage, "=== Craft Item ===", 26)
local CraftList = {"Shark Tooth Necklace","Terror Jaw","Monster Magnet","Shark Anchor","Volcanic Magnet","Pale Scarf","Dark Coat","Swan Glasses"}
CreateDropdown(QuestItemPage, "Select Item", CraftList, function(o) getgenv().SelectedItem = o end)
CreateToggle(QuestItemPage, "Auto Craft", false, function(s) getgenv().AutoCraft = s end)

--================================================================
-- VISUAL
--================================================================
CreateLabel(VisualPage, "=== ESP ===", 26)
CreateToggle(VisualPage, "ESP Player", false, function(s) State.ESPPlayer = s if not s then ClearESP() end end)
CreateToggle(VisualPage, "ESP Fruit", false, function(s) State.ESPFruit = s if not s then ClearESP() end end)
CreateToggle(VisualPage, "ESP Chest", false, function(s) State.ESPChest = s if not s then ClearESP() end end)
CreateToggle(VisualPage, "ESP Island", false, function(s) State.ESPIsland = s if not s then ClearESP() end end)
CreateToggle(VisualPage, "ESP Boss", false, function(s) State.ESPBoss = s if not s then ClearESP() end end)

--================================================================
-- TELEPORT
--================================================================
CreateLabel(TeleportPage, "=== Sea Travel ===", 26)
CreateButton(TeleportPage, "Travel to Sea 1", function() CommF_:InvokeServer("TravelMain") Notify("Traveling Sea 1") end)
CreateButton(TeleportPage, "Travel to Sea 2", function() CommF_:InvokeServer("TravelDressrosa") Notify("Traveling Sea 2") end)
CreateButton(TeleportPage, "Travel to Sea 3", function() CommF_:InvokeServer("TravelZou") Notify("Traveling Sea 3") end)

CreateLabel(TeleportPage, "=== Island Teleport ===", 26)
CreateDropdown(TeleportPage, "Select Island", {"Sky 2","Sky 3"}, function(o) getgenv().SelectedIsland = o end)
CreateButton(TeleportPage, "Tween To Island", function()
    local isl = {["Sky 2"] = Vector3.new(-4607.82, 872.54, -1667.55), ["Sky 3"] = Vector3.new(-7894.61, 5547.14, -380.29)}
    local sel = getgenv().SelectedIsland
    if sel and isl[sel] then
        CommF_:InvokeServer("requestEntrance", isl[sel])
        Notify("Traveling to " .. sel)
    end
end)

--================================================================
-- SHOP
--================================================================
CreateLabel(ShopPage, "=== Buy Fighting Style (All) ===", 26)
CreateButton(ShopPage, "Buy All Fighting Styles", function()
    local list = {"BuyBlackLeg","BuyElectro","BuyFishmanKarate","BuySuperhuman","BuyDeathStep","BuySharkmanKarate","BuyElectricClaw","BuyDragonTalon","BuyGodhuman","BuySanguineArt"}
    for _, cmd in ipairs(list) do
        pcall(function() CommF_:InvokeServer(cmd) end)
        task.wait(0.5)
    end
    Notify("All Fighting Styles purchased")
end)

CreateLabel(ShopPage, "=== Buy Abilities (All) ===", 26)
CreateButton(ShopPage, "Buy All Abilities", function()
    pcall(function() CommF_:InvokeServer("BuyHaki", "Geppo") end) task.wait(0.3)
    pcall(function() CommF_:InvokeServer("BuyHaki", "Buso") end) task.wait(0.3)
    pcall(function() CommF_:InvokeServer("KenTalk", "Buy") end) task.wait(0.3)
    pcall(function() CommF_:InvokeServer("BuyHaki", "Soru") end)
    Notify("All Abilities purchased")
end)

CreateLabel(ShopPage, "=== Buy Misc Shop ===", 26)
CreateButton(ShopPage, "Buy Stat Refund", function()
    TryBuy("BlackbeardReward", "Refund", "1") task.wait(0.3)
    TryBuy("BlackbeardReward", "Refund", "2")
end)
CreateButton(ShopPage, "Buy Race Reroll", function()
    TryBuy("BlackbeardReward", "Reroll", "1") task.wait(0.3)
    TryBuy("BlackbeardReward", "Reroll", "2")
end)
CreateButton(ShopPage, "Buy Race Ghoul", function()
    TryBuy("Ectoplasm", "BuyCheck", 4) task.wait(0.3)
    TryBuy("Ectoplasm", "Change", 4)
end)
CreateButton(ShopPage, "Buy Race Cyborg", function() TryBuy("CyborgTrainer", "Buy") end)
CreateButton(ShopPage, "Buy Dual Flintlock", function() TryBuy("BuyItem", "Dual Flintlock") end)
CreateButton(ShopPage, "Buy Legendary Swords", function()
    TryBuy("LegendarySwordDealer", "1") task.wait(0.3)
    TryBuy("LegendarySwordDealer", "2") task.wait(0.3)
    TryBuy("LegendarySwordDealer", "3")
end)
CreateButton(ShopPage, "Buy True Triple Katana", function()
    TryBuy("MysteriousMan", "1") task.wait(0.3)
    TryBuy("MysteriousMan", "2")
end)

--================================================================
-- SETTINGS
--================================================================
CreateLabel(SettingsPage, "=== Local ===", 26)
CreateToggle(SettingsPage, "Anti AFK", true, function(s) State.AntiAFK = s end)
CreateToggle(SettingsPage, "No Clip", false, function(s) State.Noclip = s end)
CreateToggle(SettingsPage, "Auto Ken", false, function(s) State.AutoKen = s end)
CreateToggle(SettingsPage, "Auto Haki", true, function(s) State.AutoHaki = s end)

CreateLabel(SettingsPage, "=== Remove ===", 26)
CreateToggle(SettingsPage, "Remove Damage Numbers", false, function(s) State.RemoveDamage = s end)
CreateToggle(SettingsPage, "Remove Notifications", false, function(s) State.RemoveNotifications = s end)

CreateLabel(SettingsPage, "=== Webhook ===", 26)
local WebhookBox = Create("TextBox", {
    Parent = SettingsPage,
    BackgroundColor3 = THEME.BG_Secondary,
    Size = UDim2.new(1, 0, 0, 38),
    Text = "",
    PlaceholderText = "Paste Discord Webhook URL...",
    TextColor3 = THEME.Text_Primary,
    PlaceholderColor3 = THEME.Text_Muted,
    TextSize = 11,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
    BorderSizePixel = 0, ZIndex = 100,
})
Corner(WebhookBox, 9)
RegisterAccent(Stroke(WebhookBox, BLUE_PALETTE[1], 1, 0.55))
local padW = Instance.new("UIPadding")
padW.PaddingLeft = UDim.new(0, 12); padW.Parent = WebhookBox
WebhookBox.FocusLost:Connect(function()
    if WebhookBox.Text ~= "" and WebhookBox.Text:find("discord.com/api/webhooks") then
        State.WebhookURL = WebhookBox.Text
        Notify("Webhook URL saved")
    else
        Notify("Invalid Webhook URL")
    end
end)

CreateToggle(SettingsPage, "Webhook Store Fruit", false, function(s) State.WebhookFruit = s end)
CreateToggle(SettingsPage, "Webhook Find Mirage", false, function(s) State.WebhookMirage = s end)
CreateToggle(SettingsPage, "Webhook Find Leviathan", false, function(s) State.WebhookLevi = s end)
CreateToggle(SettingsPage, "Webhook Find Prehistoric", false, function(s) State.WebhookPre = s end)

--================================================================
-- MISC
--================================================================
CreateLabel(MiscPage, "=== ⭐ BRING MOB SYSTEM ===", 26)
CreateToggle(MiscPage, "Bring Mob", true, function(s)
    State.BringMob = s
    Notify(s and "Bring Mob ON" or "Bring Mob OFF")
end)
CreateSlider(MiscPage, "Bring Mob Range", 50, 1000, 300, function(v) State.BringRange = v end)
CreateSlider(MiscPage, "Bring Mob Count", 1, 10, 2, function(v) State.BringCount = v end)

CreateLabel(MiscPage, "=== ⭐ FARM SETTINGS ===", 26)
CreateSlider(MiscPage, "Farm Distance", 5, 50, 20, function(v) getgenv().FarmDistance = v end)
CreateSlider(MiscPage, "Farm Speed", 50, 500, 200, function(v) getgenv().FarmSpeed = v end)

CreateLabel(MiscPage, "=== Combat ===", 26)
CreateToggle(MiscPage, "Fast Attack", true, function(s) State.FastAttack = s end)
CreateSlider(MiscPage, "Tween Speed", 50, 500, 200, function(v) getgenv().TweenSpeed = v end)
CreateToggle(MiscPage, "Change WalkSpeed", false, function(s) getgenv().EnableWalkSpeed = s end)
CreateSlider(MiscPage, "WalkSpeed Value", 16, 300, 100, function(v)
    getgenv().CustomWalkSpeed = v
    if getgenv().EnableWalkSpeed then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
end)
CreateToggle(MiscPage, "Change JumpPower", false, function(s) getgenv().EnableJumpPower = s end)
CreateSlider(MiscPage, "JumpPower Value", 50, 500, 100, function(v)
    getgenv().CustomJumpPower = v
    if getgenv().EnableJumpPower then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v end
    end
end)
CreateToggle(MiscPage, "Infinite Jump", false, function(s) getgenv().InfiniteJump = s end)
CreateToggle(MiscPage, "Walk On Water", false, function(s)
    State.WalkWater = s
    local water = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("WaterBase-Plane")
    if water then water.Size = s and Vector3.new(1000,113,1000) or Vector3.new(1000,80,1000) end
end)

CreateLabel(MiscPage, "=== Performance ===", 26)
CreateToggle(MiscPage, "Boost FPS", false, function(s)
    State.BoostFPS = s
    if s then
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.Brightness = 0
            Lighting.FogEnd = 1e10
            Lighting.Outlines = false
        end)
    else
        pcall(function()
            Lighting.GlobalShadows = true
            Lighting.Brightness = 2
            Lighting.FogEnd = 100000
            Lighting.Outlines = true
        end)
    end
end)
CreateSlider(MiscPage, "FPS Cap", 15, 240, 60, function(v)
    pcall(function() if setfpscap then setfpscap(v) end end)
end)
CreateToggle(MiscPage, "White Screen", false, function(s)
    pcall(function() RunService:Set3dRenderingEnabled(not s) end)
end)
CreateToggle(MiscPage, "Black Screen", false, function(s)
    local bs = playerGui:FindFirstChild("SX_BlackScreen")
    if s then
        if not bs then
            bs = Instance.new("ScreenGui")
            bs.Name = "SX_BlackScreen"
            bs.Parent = playerGui
            bs.IgnoreGuiInset = true
            bs.DisplayOrder = 999998
            local f = Instance.new("Frame")
            f.Size = UDim2.fromScale(1,1)
            f.BackgroundColor3 = Color3.new(0,0,0)
            f.BorderSizePixel = 0
            f.Parent = bs
        end
    elseif bs then bs:Destroy() end
end)

CreateLabel(MiscPage, "=== Server ===", 26)
CreateButton(MiscPage, "Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId, player)
end)
CreateButton(MiscPage, "Server Hop", function()
    Notify("Hopping...")
    pcall(function()
        local data = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, v in pairs(data.data) do
            if v.id ~= game.JobId and v.playing < v.maxPlayers then
                pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, player) end)
                return
            end
        end
    end)
end)

CreateLabel(MiscPage, "=== Team ===", 26)
CreateButton(MiscPage, "Join Pirates", function() CommF_:InvokeServer("SetTeam", "Pirates") Notify("Joined Pirates") end)
CreateButton(MiscPage, "Join Marines", function() CommF_:InvokeServer("SetTeam", "Marines") Notify("Joined Marines") end)

CreateLabel(MiscPage, "=== Codes ===", 26)
CreateButton(MiscPage, "Redeem All Codes", function()
    local codes = {"KITT_RESET","SUB2GAMEROBOT_RESET1","SUB2GAMERROBOT_EXP1","SUB2OFFICIALNOOBIE","AXIORE","BLUXXY","JCWK","KITTGAMING","MAGICBUS","STARCODEHEO","STRAWHATMAINE","TANTAIGAMING","THEGREATACE","ENYU_IS_PRO","FUDD10","FUDD10_V2","BIGNEWS","CHANDLER","SECRET_ADMIN","ADMIN_MELEE"}
    for _, c in ipairs(codes) do
        pcall(function() Remotes.Redeem:InvokeServer(c) end)
        task.wait(0.5)
    end
    Notify("All codes redeemed")
end)

--================================================================
-- MAIN LOOPS
--================================================================

task.spawn(function()
    while task.wait(0.05) do
        if State.FastAttack and IsAlive() then pcall(AttackNoCoolDown) end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        pcall(function() if State.AutoHaki then AutoHaki() end end)
    end
end)

-- AUTO FARM LEVEL
task.spawn(function()
    while task.wait(0.4) do
        if State.AutoFarm then
            pcall(function()
                local hrp = GetHRP(); if not hrp then return end
                local char = player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then return end

                local questMob = nil
                local qf = playerGui:FindFirstChild("TrackedQuestFrame")

                if qf then
                    local inner = qf:FindFirstChild("Frame")
                    if inner and inner.Visible then
                        local lbl = inner:FindFirstChild("QuestTitle")
                            or inner:FindFirstChild("Title")
                            or inner:FindFirstChild("TaskTitle")

                        if lbl and lbl.Text then
                            questMob = lbl.Text:match("Defeat%s+%d+%s+([%w%s]+)")
                                    or lbl.Text:match("Defeat%s+([^%[]+)")
                                    or lbl.Text:match("^([^%[]+)%s*%[")
                                    or lbl.Text:match("^([^%[]+)")

                            if questMob then
                                questMob = questMob
                                    :gsub("%s+$","")
                                    :gsub("%(.*%)","")
                                    :gsub("%s+$","")
                                    :gsub("s$","")
                            end
                        end
                    end
                end

                if not questMob then
                    local lvl = player.Data.Level.Value
                    local Quests = require(RS.Quests)
                    for qName, quests in pairs(Quests) do
                        for id, q in pairs(quests) do
                            if q.LevelReq == lvl then
                                CommF_:InvokeServer("StartQuest", qName, id)
                                return
                            end
                        end
                    end
                    return
                end

                local enemy = FindEnemy({questMob}, 99999)

                if enemy then
                    local trp = enemy:FindFirstChild("HumanoidRootPart")
                    if trp then
                        AutoHaki()
                        EquipWeapon(State.SelectedWeapon)
                        local d = (trp.Position - hrp.Position).Magnitude

                        if d > 25 then
                            FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), getgenv().FarmSpeed, 20)
                        else
                            if State.BringMob then BringMob(enemy) end
                            trp.CanCollide = false
                            if trp.Size.X < 30 then trp.Size = Vector3.new(60,60,60) end
                            if enemy:FindFirstChild("Humanoid") then enemy.Humanoid.WalkSpeed = 0 end
                            AttackNoCoolDown()
                        end
                    end
                else
                    local sp = FindSpawnPart(questMob, true)
                    if sp then
                        FarmTeleport(sp.CFrame * CFrame.new(0, 60, 0), getgenv().FarmSpeed, 25)
                    else
                        if not _G.__LastSpawnWarn or tick() - _G.__LastSpawnWarn > 5 then
                            _G.__LastSpawnWarn = tick()
                            Notify("Spawn not found: " .. questMob)
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Farm Nearest
task.spawn(function()
    while task.wait(0.35) do
        if State.AutoFarmNearest then
            pcall(function()
                local hrp = GetHRP(); if not hrp then return end
                local enemies = Workspace:FindFirstChild("Enemies"); if not enemies then return end
                local best, bestD = nil, math.huge
                for _, e in ipairs(enemies:GetChildren()) do
                    local h = e:FindFirstChild("Humanoid")
                    local trp = e:FindFirstChild("HumanoidRootPart")
                    if h and trp and h.Health > 0 then
                        local d = (trp.Position - hrp.Position).Magnitude
                        if d < bestD and d < 2000 then best = e; bestD = d end
                    end
                end
                if best then
                    local trp = best:FindFirstChild("HumanoidRootPart")
                    if trp then
                        AutoHaki(); EquipWeapon(State.SelectedWeapon)
                        local d = (trp.Position - hrp.Position).Magnitude
                        if d > 25 then FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), getgenv().FarmSpeed, 20) end
                        if State.BringMob then BringMob(best) end
                        trp.CanCollide = false
                        if trp.Size.X < 30 then trp.Size = Vector3.new(60,60,60) end
                        if best:FindFirstChild("Humanoid") then best.Humanoid.WalkSpeed = 0 end
                        AttackNoCoolDown()
                    end
                end
            end)
        end
    end
end)

-- Auto Chest
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoChest then
            pcall(function()
                local hrp = GetHRP(); if not hrp then return end
                local chests = GetSortedChests()
                if #chests > 0 then
                    local t = chests[1]
                    FarmTeleport(t.CFrame + Vector3.new(0, 2, 0), getgenv().FarmSpeed, 20)
                    pcall(function()
                        firetouchinterest(hrp, t, 0)
                        task.wait(0.05)
                        firetouchinterest(hrp, t, 1)
                    end)
                end
            end)
        end
    end
end)

-- Auto Farm Bones
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoFarmBones then
            pcall(function()
                local e = FindEnemy({"Reborn Skeleton","Living Zombie","Demonic Soul","Posessed Mummy"}, 5000)
                if e then
                    EquipWeapon(State.SelectedWeapon); AutoHaki()
                    local trp = e:FindFirstChild("HumanoidRootPart")
                    if trp then
                        FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), getgenv().FarmSpeed, 20)
                        if State.BringMob then BringMob(e) end
                        trp.CanCollide = false
                        if e:FindFirstChild("Humanoid") then e.Humanoid.WalkSpeed = 0 end
                        AttackNoCoolDown()
                    end
                end
            end)
        end
    end
end)

-- Auto Farm Material
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoFarmMaterial and State.SelectedMaterial then
            pcall(function()
                local mats = {
                    ["Angel Wings"] = {NPCs={"Royal Soldier","Royal Squad"},Pos=CFrame.new(-7742, 5634, -1564)},
                    ["Leather + Scrap Metal"] = {NPCs={"Pirate","Brute","Scrap Metal"},Pos=CFrame.new(-1257, 54, 4091)},
                    ["Magma Ore"] = {NPCs={"Military Soldier","Lava Pirate"},Pos=CFrame.new(-5408, 11, 8456)},
                    ["Fish Tail"] = {NPCs={"Fishman Warrior","Fishman Captain"},Pos=CFrame.new(60931, 19, 1574)},
                    ["Mystic Droplet"] = {NPCs={"Water Fighter"},Pos=CFrame.new(-3350, 282, -10527)},
                    ["Radioactive Material"] = {NPCs={"Factory Staff"},Pos=CFrame.new(-73, 149, -112)},
                    ["Vampire Fang"] = {NPCs={"Vampire"},Pos=CFrame.new(-6030, 6, -1281)},
                    ["Gunpowder"] = {NPCs={"Pistol Billionaire"},Pos=CFrame.new(-394, 135, 5981)},
                    ["Mini Tusk"] = {NPCs={"Mythological Pirate"},Pos=CFrame.new(-13510, 584, -6986)},
                    ["Conjured Cocoa"] = {NPCs={"Cocoa Warrior","Chocolate Bar Battler"},Pos=CFrame.new(400, 81, -12257)},
                    ["Dragon Scale"] = {NPCs={"Dragon Crew Archer"},Pos=CFrame.new(6689, 378, 331)},
                }
                local data = mats[State.SelectedMaterial]
                if not data then return end
                local e = FindEnemy(data.NPCs, 5000)
                if e then
                    EquipWeapon(State.SelectedWeapon); AutoHaki()
                    local trp = e:FindFirstChild("HumanoidRootPart")
                    if trp then
                        FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), getgenv().FarmSpeed, 20)
                        if State.BringMob then BringMob(e) end
                        trp.CanCollide = false
                        if e:FindFirstChild("Humanoid") then e.Humanoid.WalkSpeed = 0 end
                        AttackNoCoolDown()
                    end
                else
                    FarmTeleport(data.Pos + Vector3.new(0, 30, 0), getgenv().FarmSpeed, 30)
                end
            end)
        end
    end
end)

-- Auto Kill Boss
task.spawn(function()
    while task.wait(0.4) do
        if State.AutoBoss and State.SelectedBoss then
            pcall(function()
                local e = FindEnemy({State.SelectedBoss}, 99999)
                local rsB = RS:FindFirstChild(State.SelectedBoss)
                local sp = e ~= nil or (rsB and rsB:FindFirstChild("HumanoidRootPart") ~= nil)
                if BossStat and BossStat.Parent then
                    BossStat.Text = "Boss Status: " .. (sp and "Spawned" or "Not Spawned")
                end
                if e then
                    local trp = e:FindFirstChild("HumanoidRootPart")
                    if trp then
                        AutoHaki(); EquipWeapon(State.SelectedWeapon)
                        FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), getgenv().FarmSpeed, 20)
                        if State.BringMob then BringMob(e) end
                        trp.CanCollide = false
                        if trp.Size.X < 40 then trp.Size = Vector3.new(80,80,80) end
                        if e:FindFirstChild("Humanoid") then e.Humanoid.WalkSpeed = 0 end
                        AttackNoCoolDown()
                    end
                end
            end)
        end
    end
end)

-- Mastery 600
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoMastery600 then
            pcall(function()
                local mt = State.AutoMasteryType
                local wp = "Melee"
                if mt == "Mastery Sword" then wp = "Sword"
                elseif mt == "Mastery Gun" then wp = "Gun"
                elseif mt == "Mastery Fruit" then wp = "Blox Fruit" end
                local e = FindEnemy({"Reborn Skeleton","Living Zombie","Demonic Soul","Posessed Mummy","Bandit"}, 5000)
                if e then
                    EquipWeapon(wp); AutoHaki()
                    local trp = e:FindFirstChild("HumanoidRootPart")
                    if trp then
                        FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), getgenv().FarmSpeed, 20)
                        if State.BringMob then BringMob(e) end
                        trp.CanCollide = false
                        if e:FindFirstChild("Humanoid") then e.Humanoid.WalkSpeed = 0 end
                        AttackNoCoolDown()
                    end
                end
            end)
        end
    end
end)

-- Special Boss Loops
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoCakePrince then
            pcall(function()
                local e = FindEnemy({"Cake Prince","Dough King"}, 99999)
                if e then
                    EquipWeapon(State.SelectedWeapon); AutoHaki()
                    local trp = e:FindFirstChild("HumanoidRootPart")
                    if trp then
                        FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), getgenv().FarmSpeed, 20)
                        if State.BringMob then BringMob(e) end
                        trp.CanCollide = false
                        if e:FindFirstChild("Humanoid") then e.Humanoid.WalkSpeed = 0 end
                        AttackNoCoolDown()
                    end
                else
                    local mob = FindEnemy({"Baking Staff","Head Baker","Cake Guard","Cookie Crafter"}, 5000)
                    if mob then
                        EquipWeapon(State.SelectedWeapon); AutoHaki()
                        local trp = mob:FindFirstChild("HumanoidRootPart")
                        if trp then
                            FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), getgenv().FarmSpeed, 20)
                            if State.BringMob then BringMob(mob) end
                            trp.CanCollide = false
                            if mob:FindFirstChild("Humanoid") then mob.Humanoid.WalkSpeed = 0 end
                            AttackNoCoolDown()
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if State.AutoDoughKing then
            pcall(function()
                local e = FindEnemy({"Dough King"}, 99999)
                if e then
                    EquipWeapon(State.SelectedWeapon); AutoHaki()
                    local trp = e:FindFirstChild("HumanoidRootPart")
                    if trp then
                        FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), getgenv().FarmSpeed, 20)
                        if State.BringMob then BringMob(e) end
                        trp.CanCollide = false
                        AttackNoCoolDown()
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if State.AutoEliteHunter then
            pcall(function()
                local e = FindEnemy({"Diablo","Deandre","Urban"}, 99999)
                if e then
                    EquipWeapon(State.SelectedWeapon); AutoHaki()
                    local trp = e:FindFirstChild("HumanoidRootPart")
                    if trp then
                        FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), getgenv().FarmSpeed, 20)
                        if State.BringMob then BringMob(e) end
                        trp.CanCollide = false
                        AttackNoCoolDown()
                    end
                else CommF_:InvokeServer("EliteHunter") end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if State.AutoSoulReaper then
            pcall(function()
                local e = FindEnemy({"Soul Reaper"}, 99999)
                if e then
                    EquipWeapon(State.SelectedWeapon); AutoHaki()
                    local trp = e:FindFirstChild("HumanoidRootPart")
                    if trp then
                        FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), getgenv().FarmSpeed, 20)
                        if State.BringMob then BringMob(e) end
                        trp.CanCollide = false
                        AttackNoCoolDown()
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if State.AutoTyrant then
            pcall(function()
                local e = FindEnemy({"Tyrant of the Skies"}, 99999)
                if e then
                    EquipWeapon(State.SelectedWeapon); AutoHaki()
                    local trp = e:FindFirstChild("HumanoidRootPart")
                    if trp then
                        FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), getgenv().FarmSpeed, 20)
                        if State.BringMob then BringMob(e) end
                        trp.CanCollide = false
                        AttackNoCoolDown()
                    end
                else FarmTeleport(CFrame.new(-16557, 202, 508), getgenv().FarmSpeed, 30) end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if State.AutoCitizen then
            pcall(function()
                local e = FindEnemy({"Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate"}, 99999)
                if e then
                    EquipWeapon(State.SelectedWeapon); AutoHaki()
                    local trp = e:FindFirstChild("HumanoidRootPart")
                    if trp then
                        FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), getgenv().FarmSpeed, 20)
                        if State.BringMob then BringMob(e) end
                        trp.CanCollide = false
                        AttackNoCoolDown()
                    end
                else
                    FarmTeleport(CFrame.new(-11893.7, 929.661, -8760.59), getgenv().FarmSpeed, 30)
                    CommF_:InvokeServer("HornedMan", "Bet")
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if State.AutoDragonHunter then
            pcall(function()
                local e = FindEnemy({"Hydra Enforcer","Venomous Assailant"}, 99999)
                if e then
                    EquipWeapon(State.SelectedWeapon); AutoHaki()
                    local trp = e:FindFirstChild("HumanoidRootPart")
                    if trp then
                        FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), getgenv().FarmSpeed, 20)
                        if State.BringMob then BringMob(e) end
                        trp.CanCollide = false
                        AttackNoCoolDown()
                    end
                else
                    local em = Workspace:FindFirstChild("EmberTemplate")
                    if em and em:FindFirstChild("Part") then
                        FarmTeleport(em.Part.CFrame, getgenv().FarmSpeed, 30)
                    else
                        FarmTeleport(CFrame.new(5863.68, 1209.87, 809.94), getgenv().FarmSpeed, 30)
                    end
                end
            end)
        end
    end
end)

-- Sea Farm
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoFarmSea then
            pcall(function()
                local targets = {}
                if State.AutoShark then table.insert(targets, "Shark") end
                if State.AutoPiranha then table.insert(targets, "Piranha") end
                if State.AutoTerrorshark then table.insert(targets, "Terrorshark") end
                if State.AutoFishCrew then table.insert(targets, "Fish Crew Member") end
                if State.AutoSeaBeast then table.insert(targets, "SeaBeast1") end
                if #targets > 0 then
                    local e = FindEnemy(targets, 3000)
                    if e then
                        local trp = e:FindFirstChild("HumanoidRootPart") or e:FindFirstChild("VehicleSeat")
                        if trp then
                            EquipWeapon(State.SelectedWeapon); AutoHaki()
                            FarmTeleport(trp.CFrame * CFrame.new(0, 55, 0), getgenv().FarmSpeed, 30)
                            if State.BringMob then BringMob(e) end
                            trp.CanCollide = false
                            AttackNoCoolDown()
                        end
                    end
                end
            end)
        end
    end
end)

-- Protect Boat
task.spawn(function()
    while task.wait(0.3) do
        if State.ProtectBoat then
            pcall(function()
                local boats = Workspace:FindFirstChild("Boats"); if not boats then return end
                for _, bp in ipairs(boats:GetChildren()) do
                    local o = bp:FindFirstChild("Owner")
                    if o and tostring(o.Value) == player.Name then
                        local seat = bp:FindFirstChild("VehicleSeat")
                        if seat then
                            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                            if hum and not hum.Sit then
                                local saved = seat.CFrame
                                seat.CFrame = saved + Vector3.new(math.random(75,100), math.random(75,100), math.random(75,100))
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Find Islands
task.spawn(function()
    while task.wait(1.5) do
        pcall(function()
            if getgenv().FindMirage then
                local loc = Workspace._WorldOrigin.Locations
                local m = loc:FindFirstChild("Mirage Island")
                if m then FarmTeleport(m.CFrame * CFrame.new(0, 100, 0), getgenv().FarmSpeed, 30) end
            end
            if getgenv().FindPrehistoric then
                local pre = Workspace.Map:FindFirstChild("PrehistoricIsland")
                if pre then FarmTeleport(pre:GetPivot() * CFrame.new(0, 100, 0), getgenv().FarmSpeed, 30) end
            end
            if getgenv().FindFrozen then
                local loc = Workspace._WorldOrigin.Locations
                local f = loc:FindFirstChild("Frozen Dimension")
                if f then FarmTeleport(f.CFrame * CFrame.new(0, 100, 0), getgenv().FarmSpeed, 30) end
            end
            if getgenv().FindKitsune then
                local kit = Workspace.Map:FindFirstChild("KitsuneIsland")
                if kit and kit:FindFirstChild("ShrineActive") then
                    local p = kit.ShrineActive:FindFirstChild("NeonShrinePart")
                    if p then FarmTeleport(p.CFrame * CFrame.new(0, 40, 10), getgenv().FarmSpeed, 30) end
                end
            end
        end)
    end
end)

-- ESP
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            for part, bb in pairs(State.ESPObjects) do
                if not part.Parent or not bb.Parent then
                    pcall(function() bb:Destroy() end)
                    State.ESPObjects[part] = nil
                end
            end
            local hrp = GetHRP(); if not hrp then return end
            local mp = hrp.Position

            if State.ESPPlayer then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= player and plr.Character then
                        local trp = plr.Character:FindFirstChild("HumanoidRootPart")
                        if trp then
                            local d = math.floor((trp.Position - mp).Magnitude / 3)
                            CreateESP(trp, "[ " .. plr.Name .. " ] [ " .. d .. " ]", Color3.fromRGB(255, 100, 100))
                        end
                    end
                end
            end
            if State.ESPFruit then
                for _, o in ipairs(Workspace:GetChildren()) do
                    if (o:IsA("Tool") or o:IsA("Model")) and o.Name:find("Fruit") then
                        local h = o:FindFirstChild("Handle") or o.PrimaryPart
                        if h then
                            local d = math.floor((h.Position - mp).Magnitude / 3)
                            CreateESP(h, "[ " .. o.Name .. " ] [ " .. d .. " ]", Color3.fromRGB(255, 200, 80))
                        end
                    end
                end
            end
            if State.ESPChest then
                local chests = GetSortedChests()
                for _, c in ipairs(chests) do
                    if c.Parent then
                        local d = math.floor((c.Position - mp).Magnitude / 3)
                        CreateESP(c, "[ Chest ] [ " .. d .. " ]", Color3.fromRGB(255, 215, 0))
                    end
                end
            end
            if State.ESPBoss then
                local enemies = Workspace:FindFirstChild("Enemies")
                if enemies then
                    for _, e in ipairs(enemies:GetChildren()) do
                        local h = e:FindFirstChildOfClass("Humanoid")
                        if h and h.DisplayName and h.DisplayName:find("Boss") then
                            local trp = e:FindFirstChild("HumanoidRootPart")
                            if trp then
                                local d = math.floor((trp.Position - mp).Magnitude / 3)
                                CreateESP(trp, "[ BOSS " .. e.Name .. " ] [ " .. d .. " ]", Color3.fromRGB(255, 50, 50))
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if State.Noclip and player.Character then
        pcall(function()
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end)
    end
end)

-- Auto Ken
task.spawn(function()
    while task.wait(1) do
        if State.AutoKen then pcall(function() CommF_:InvokeServer("Ken", true) end) end
    end
end)

-- Remove Damage/Notif
task.spawn(function()
    while task.wait(0.5) do
        if State.RemoveDamage then pcall(function() RS.Assets.GUI.DamageCounter.Enabled = false end) end
        if State.RemoveNotifications then pcall(function() playerGui.Notifications.Enabled = false end) end
    end
end)

-- Auto Stats
task.spawn(function()
    while task.wait(3) do
        if State.AutoStats then
            pcall(function()
                local s = {{"Melee",State.StatMelee},{"Defense",State.StatDefense},{"Sword",State.StatSword},{"Gun",State.StatGun},{"Demon Fruit",State.StatFruit}}
                for _, x in ipairs(s) do
                    if x[2] == 1 then
                        CommF_:InvokeServer("AddPoint", x[1], State.PointsPerClick)
                        task.wait(0.3)
                    end
                end
            end)
        end
    end
end)

-- WS/JP
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                if getgenv().EnableWalkSpeed and hum.WalkSpeed ~= getgenv().CustomWalkSpeed then
                    hum.WalkSpeed = getgenv().CustomWalkSpeed
                end
                if getgenv().EnableJumpPower and hum.JumpPower ~= getgenv().CustomJumpPower then
                    hum.JumpPower = getgenv().CustomJumpPower
                end
            end
        end)
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if getgenv().InfiniteJump then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Anti AFK (FIXED)
player.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Teleport Player
task.spawn(function()
    while task.wait(0.3) do
        if State.TeleportPlayer and State.SelectedPlayer then
            pcall(function()
                local p = Players:FindFirstChild(State.SelectedPlayer)
                if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    FarmTeleport(p.Character.HumanoidRootPart.CFrame, getgenv().FarmSpeed, 30)
                end
            end)
        end
    end
end)

--================================================================
-- DRAG
--================================================================
local function MakeDraggable(obj, handle)
    handle = handle or obj
    local drag = false
    local ds, sp
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            ds = i.Position
            sp = obj.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not drag then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            local d = i.Position - ds
            obj.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

MakeDraggable(main, header)

close.Activated:Connect(function()
    gui.Enabled = not gui.Enabled
end)

--================================================================
-- STARTUP
--================================================================
ShowTab("Farm")
Notify("SysxHub v2.1 Loaded — Bring Mob System Aktif ✅")
