--[[
================================================================
    SYSX HUB v2.4 — Blox Fruits
    Structure: 14 Tabs
    Home&Status, Farm, Pvp[combat], Quest&Item, Stats, Sea,
    Fishing, Race, Fruit&raid, Shop, Teleport, Visual,
    SETTINGS, MISC
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
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService   = game:GetService("TeleportService")
local Lighting          = game:GetService("Lighting")
local HttpService       = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local GuiService        = game:GetService("GuiService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Remotes   = RS:WaitForChild("Remotes", 10)
local CommF_    = Remotes:WaitForChild("CommF_", 10)
local Modules   = RS:FindFirstChild("Modules")
local Net       = Modules and Modules:FindFirstChild("Net")

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
local function Dist(a, b)
    if not a or not b then return math.huge end
    return (a - b).Magnitude
end

--================================================================
-- STATE
--================================================================
local State = {
    -- Farm
    AutoFarm=false, AutoFarmNearest=false, AutoFarmMastery=false,
    AutoFarmMaterial=false, AutoFarmBones=false, AutoFarmWoodPlanks=false,
    AutoCollectChest=false, AutoTreasureChest=false, AutoCollectDrops=false,
    AutoFarmerDrops=false, AutoAttackBoss=false, AutoAttackAllBoss=false,
    AutoTyrant=false, AutoCitizenQuest=false, AutoDarkFragment=false,
    AutoSweetChalice=false, SelectedWeapon="Melee", SelectedMaterial=nil,
    SelectedBoss=nil, FastAttack=true, BringMob=true, BringRange=300,
    BringCount=2, AutoHaki=true, AutoKen=false,

    -- Pvp
    AutoAimbot=false, SelectedPlayer=nil, TeleportPlayer=false,
    AutoDodgeSkill=false, MethodAimbot="Target nearest Player",

    -- Quest & Item
    AutoSaber=false, AutoYama=false, AutoTushita=false, AutoSharkAnchor=false,
    AutoPole=false, AutoFoxLamp=false, AutoDarkDagger=false, AutoCanvander=false,
    AutoBuddySword=false, AutoHallowScythe=false, AutoCDK=false,
    AutoAcidumRifle=false, AutoVenomBow=false, AutoSoulGuitar=false,
    AutoDragonStorm=false, AutoRengoku=false, AutoInsictV2=false,
    AutoRainbowSaviour=false, AutoDarkBladeV2=false, AutoDarkBladeV3=false,
    AutoBartilo=false, AutoSecondSea=false, AutoThirdSea=false, AutoDojo=false,
    AutoCakePrince=false, AutoDoughKing=false, AutoEliteHunter=false,
    AutoSoulReaper=false, AutoKillRipIndra=false, AutoFactory=false,
    AutoPiratesSea=false, AutoDragonHunter=false, AutoCollectBerry=false,

    -- Stats
    AutoStatPoint=false, PointsPerClick=1,
    StatMelee=false, StatDefense=false, StatSword=false, StatGun=false, StatFruit=false,

    -- Sea
    SelectedBoat=nil, DangerLevel="6", CombatWeapon="Random",
    SpeedBoat=200, SpeedTweenBoat=350, SpeedFlyBoat=3,
    AutoFarmSea=false, AttackSeaBeasts=false, DodgeSeaBeasts=false,
    AttackTerrorshark=false, DodgeTerrorshark=false, AttackGhostShip=false,
    AttackPiranha=false, AttackShark=false, AttackFishCrew=false,
    ProtectBoat=false, AutoRepairShip=false, AutoDodgeRoughSea=false,
    NoClipRock=false, NoFog=false,
    AutoSummonKitsune=false, TweenKitsune=false, AutoCollectEmber=false,
    AutoSummonSoulEmber=false, AutoTradeEmber=false, ValuesEmber=10,
    TweenFrozenDimension=false, AutoFindLevi=false, AutoAttackLevi=false,
    AutoAttackLeviSeg=false, AutoAttackLeviTail=false, UseFruitLevi=false,
    UseSkullGuitarLevi=false, AutoChangeDragonstorm=false, AutoFireHeart=false,
    AttackMultiSegments=false, ValueDamageMultiSeg=30000, TweenBoatFrozen=false,
    AutoBuyBoatBH=false, SelectOwnerBH=nil, UseBoatBH=false, MultiFindLevi=false,
    SelectOwnerMulti=nil, AutoStartLevi=false, AutoBuySpy=false, AutoDestroyIDK=false,
    AutoSummonMirage=false, TweenMirage=false, AutoFindMirage=false, WillBack10km=false,
    AutoSummonPre=false, TweenPre=false, AutoFindPre=false, AutoEventPre=false,
    FullyEventPre=false, AutoCollectBone=false, AutoCollectEgg=false,
    AutoToothNecklace=false, AutoTerrorJaw=false, AutoMonsterMagnet=false,
    AutoSharkAnchorCraft=false, AutoCraftVolcanic=false,
    FlyBoat=false, DriveBoatTiki=false, DriveBoatHydra=false,
    TeleportBoatRough=false, TweenUntilEvent=false,

    -- Fishing
    AutoEquipRod=false, AutoFishing=false, AutoSellFish=false, AutoSellCorruptedFish=false,
    SelectedBait="Basic Bait",

    -- Race
    AutoRaceV2=false, AutoRaceV3=false, AutoTrial=false, AutoKillAfterTrialRace=false,
    AutoTrialDraco=false, FullyTrialDraco=false,
    AutoBuyGearV4=false, AutoChooseGears=false, SelectedGearV4="Omega",
    AutoGetCyborg=false, AutoGetGhoul=false, AutoRaceDraco=false,

    -- Fruit & Raid
    AutoStoreFruit=false, AutoBuyFruit=false, AutoBuySniper=false,
    AutoBuySniperMirage=false, AutoFindFruit=false, AutoGetSpawnerFruit=false,
    AutoRandomFruit=false, AutoDropFruit=false, AutoEatFruit=false,
    AutoRaid=false, AutoBuyChip=false, AutoAwakenFruit=false,
    SelectedRaid="Flame", SelectedChip="Flame",

    -- Shop
    AutoBuyMelee={}, AutoFullyMelees=false,

    -- Teleport
    SelectedIsland=nil,

    -- Visual
    ESPPlayer=false, ESPChest=false, ESPBerry=false, ESPFlower=false,
    ESPDevilFruit=false, ESPIsland=false, ESPMirage=false, ESPKitsune=false,
    RemoveDamage=false, RemoveNotifications=false, BoostFPS=false, BlackScreen=false,
    WhiteScreen=false,

    -- SETTINGS
    WebhookURL="", WebhookReport=true, NotiProfile=false,
    PingDiscord=false, FPScap=60,

    -- MISC
    AutoHop1h=false, HopWhenIdle=false, WalkSpeed=16, JumpPower=50,
    InfiniteJump=false, Fly=false, WalkOnWater=false, NoClip=false,
    AntiAFK=true, AutoResetChar=false, FastAttackMisc=true,
    AntiFlag=false, AntiKick=true, KickRecovery=true, AutoExpRedeem=false,
}

getgenv().FarmDistance    = 20
getgenv().FarmSpeed       = 200
getgenv().CustomWalkSpeed = 100
getgenv().CustomJumpPower = 50

--================================================================
-- ANTI AFK
--================================================================
player.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

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
-- ATTACK SYSTEM
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

function SendKey(key, hold)
    hold = hold or 0.05
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(hold)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
    end)
end

--================================================================
-- TELEPORT SYSTEM
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
    return State.AutoFarm or State.AutoFarmNearest or State.AutoCollectChest
        or State.AutoFarmMaterial or State.AutoFarmBones or State.AutoFarmSea
        or State.AutoAttackBoss or State.AutoCakePrince or State.AutoDoughKing
        or State.AutoEliteHunter or State.AutoSoulReaper or State.AutoFactory
        or State.AutoPiratesSea or State.AutoFindFruit or State.AutoTyrant
        or State.AutoCitizenQuest or State.AutoDragonHunter or State.AutoEventPre
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
-- CHEST SYSTEM
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
-- AUTHENTIC KAITUN 3TN FUNCTIONS
--================================================================
_G.FastAttack = 0
task.spawn(function()
    while task.wait(0.01) do
        if _G.FastAttack == os.time() then pcall(AttackNoCoolDown) end
    end
end)

function SendKaitunAttack()
    _G.FastAttack = os.time()
end

-- Combat Controller (Kaitun style)
CombatController = {
    GRAB = true, GRAB_DISTANCE = 350,
    MAX_ATTACK_DURATION = 2, MAX_ATTACK_DURATION_2 = 60,
    CurrentIndex = 1, LastFound = os.time()
}

function CombatController.Grab(mobName)
    pcall(sethiddenproperty, player, 'SimulationRadius', math.huge)
    if not CombatController.GRAB then return end
    if GrabDebounce == os.time() then return end
    GrabDebounce = os.time()

    local sum, count = Vector3.zero, 0
    local list = {}

    for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
        if enemy.Name == mobName then
            local hum = enemy:FindFirstChild('Humanoid')
            local hrp = enemy:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                if isnetworkowner and isnetworkowner(enemy.PrimaryPart or hrp) then
                    count = count + 1
                    enemy:SetAttribute("OldPosition", enemy:GetAttribute('OldPosition') or hrp.Position)
                    sum = sum + hrp.Position
                    table.insert(list, enemy)
                end
            end
        end
    end

    if count == 0 then return end
    local center = CFrame.new(sum / count)

    for _, m in ipairs(list) do
        local mr = m:FindFirstChild("HumanoidRootPart")
        if mr then
            local bv = mr:FindFirstChild('FarmingVelocity')
            if not bv then
                bv = Instance.new('BodyVelocity')
                bv.Name = 'FarmingVelocity'
                bv.MaxForce = Vector3.new(4000, 4000, 4000)
                bv.Parent = mr
            end
            bv.Velocity = Vector3.zero
            m:SetAttribute('IsGrabbed', true)
            mr.CFrame = center
        end
    end
end

function GetMonAsSortedRange()
    local list = {}
    for _, m in ipairs(Workspace.Enemies:GetChildren()) do
        if m:FindFirstChild('Humanoid') and m:FindFirstChild("HumanoidRootPart") and m.Humanoid.Health > 0 then
            table.insert(list, m)
        end
    end
    local hrp = GetHRP()
    if hrp then
        local pos = hrp.Position
        table.sort(list, function(a, b)
            return (a.HumanoidRootPart.Position - pos).Magnitude < (b.HumanoidRootPart.Position - pos).Magnitude
        end)
    end
    return list
end

local function CircleDirection(baseCFrame)
    local angle = (tick() * 200) % 360
    local offset = Vector3.new(math.cos(math.rad(angle)) * 40, 0, math.sin(math.rad(angle)) * 40)
    return CFrame.new(baseCFrame.Position + offset)
end

function CombatController.Attack(mobNames)
    mobNames = type(mobNames) == "string" and {mobNames} or (mobNames or {})
    for _, name in ipairs(mobNames) do
        local mon = FindEnemy({tostring(name)}, 99999)
        if mon then
            CombatController.LastFound = os.time()
            local hum = mon:FindFirstChild('Humanoid')
            local hrp = mon:FindFirstChild('HumanoidRootPart')
            if hum and hrp then
                while task.wait() do
                    if not mon.Parent or not hum.Parent or hum.Health <= 0 then break end
                    if not AnyFarm() then break end

                    local targetCF = hrp.CFrame + Vector3.new(0, 35, 0)
                    FarmTeleport(targetCF, getgenv().FarmSpeed, 20)

                    if Dist(hrp.Position, GetHRP() and GetHRP().Position) < 150 then
                        CombatController.Grab(mon.Name)
                        AutoHaki()
                        EquipWeapon(State.SelectedWeapon)
                        AttackNoCoolDown()
                    end
                end
            end
        else
            -- Mob not found, tween to spawn
            local spawnPart = FindSpawnPart(name, true)
            if spawnPart then
                FarmTeleport(spawnPart.CFrame + Vector3.new(0, 35, 35), getgenv().FarmSpeed, 25)
            end
        end
    end
end

--================================================================
-- Aimbot System
--================================================================
local AimPos = nil
local AimTarget = nil

function LockAimPositionTo(cf)
    AimPos = cf
end

task.spawn(function()
    if not getrawmetatable then return end
    local MT = getrawmetatable(game)
    local OldNameCall = MT.__namecall
    pcall(setreadonly, MT, false)
    MT.__namecall = newcclosure(function(self, ...)
        local Method = getnamecallmethod()
        local Args = {...}
        if Method == 'FireServer' and self.Name == 'RemoteEvent' and AimPos and tostring(AimPos.X) ~= "nan" then
            if #Args == 1 and typeof(Args[1]) == "Vector3" then
                Args[1] = AimPos.Position
            end
            if #Args == 1 and typeof(Args[1]) == "CFrame" then
                Args[1] = AimPos
            end
        end
        return OldNameCall(self, table.unpack(Args))
    end)
    pcall(setreadonly, MT, true)
end)

local function AimbotTarget()
    if State.MethodAimbot == "Select Player" then
        local p = Players:FindFirstChild(State.SelectedPlayer or "")
        return p and p.Character
    else
        local hrp = GetHRP(); if not hrp then return nil end
        local closest, best = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local trp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if trp and hum and hum.Health > 0 then
                    local d = (trp.Position - hrp.Position).Magnitude
                    if d < best and d <= 2000 then closest = p.Character; best = d end
                end
            end
        end
        return closest
    end
end

task.spawn(function()
    while task.wait(0.1) do
        if State.AutoAimbot then
            pcall(function()
                local char = AimbotTarget()
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        AimTarget = char
                        AimPos = CFrame.new(hrp.Position)
                    end
                end
            end)
        else
            AimPos = nil
            AimTarget = nil
        end
    end
end)

--================================================================
-- RACE HANDLERS (Kaitun style)
--================================================================
function CheckMoon()
    local lig = Lighting
    local phase = lig:GetAttribute("MoonPhase")
    if phase then
        if phase == 5 then return "Full Moon"
        elseif phase == 4 then return "Next Night"
        else return "Bad Moon" end
    end
    local sky = lig:FindFirstChildOfClass("Sky")
    local m = sky and sky.MoonTextureId:match("%d+$")
    if m == "9709149431" then return "Full Moon"
    elseif m == "9709149052" then return "Next Night"
    else return "Bad Moon" end
end

function GetCurrentSea()
    local map = Lighting:GetAttribute("MAP")
    if map == "Sea1" then return 1 end
    if map == "Sea2" then return 2 end
    if map == "Sea3" then return 3 end
    if World1 then return 1 end
    if World2 then return 2 end
    if World3 then return 3 end
    return 0
end

function BuyMelee(meleeId, npcName)
    local has = false
    for _, x in ipairs(player.Backpack:GetChildren()) do
        if x:IsA("Tool") and (x.Name == meleeId or x.ToolTip == "Melee") then has = true end
    end
    for _, x in ipairs(player.Character:GetChildren()) do
        if x:IsA("Tool") and (x.Name == meleeId or x.ToolTip == "Melee") then has = true end
    end
    if has then return true end

    if npcName then
        local npc = Workspace:FindFirstChild("NPCs", true) and Workspace.NPCs:FindFirstChild(npcName)
        if npc then
            local npcRoot = npc:FindFirstChild("HumanoidRootPart")
            if npcRoot then
                if player:DistanceFromCharacter(npcRoot.Position) > 8 then
                    FarmTeleport(npcRoot.CFrame * CFrame.new(0, 3, 5), getgenv().FarmSpeed, 20)
                    return false
                end
            end
        end
    end

    pcall(function() CommF_:InvokeServer("Buy" .. meleeId) end)
    task.wait(0.5)
    return false
end

-- Race V2
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoRaceV2 then
            pcall(function()
                if GetCurrentSea() ~= 2 then
                    CommF_:InvokeServer("TravelDressrosa")
                    return
                end
                local res = CommF_:InvokeServer("Alchemist", "1")
                if res == 0 then
                    local pos = CFrame.new(-2779.83521, 72.9661407, -3574.02002)
                    if Dist(GetHRP().Position, pos.Position) > 5 then
                        FarmTeleport(pos, getgenv().FarmSpeed, 15)
                    else
                        CommF_:InvokeServer("Alchemist", "2")
                    end
                elseif res == 1 then
                    -- Collect flowers
                    local hrp = GetHRP()
                    for i = 1, 2 do
                        local flower = Workspace:FindFirstChild("Flower" .. i)
                        if flower and flower.Transparency == 0 then
                            if Dist(hrp.Position, flower.Position) > 5 then
                                FarmTeleport(flower.CFrame, getgenv().FarmSpeed, 15)
                                return
                            end
                        end
                    end
                    local fl3 = Workspace:FindFirstChild("Flower3")
                    if fl3 and fl3.Transparency == 0 then
                        FarmTeleport(fl3.CFrame, getgenv().FarmSpeed, 15)
                    else
                        local swan = FindEnemy({"Swan Pirate"}, 5000)
                        if swan then CombatController.Attack({"Swan Pirate"}) end
                    end
                elseif res == 2 then
                    CommF_:InvokeServer("Alchemist", "3")
                    Notify("Race V2 done!")
                    State.AutoRaceV2 = false
                end
            end)
        end
    end
end)

-- Race V3
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoRaceV3 then
            pcall(function()
                if GetCurrentSea() ~= 2 then
                    CommF_:InvokeServer("TravelDressrosa")
                    return
                end
                local res = CommF_:InvokeServer("Wenlocktoad", "1")
                if res == 0 then
                    CommF_:InvokeServer("Wenlocktoad", "2")
                elseif res == 2 then
                    CommF_:InvokeServer("Wenlocktoad", "3")
                    Notify("Race V3 done!")
                    State.AutoRaceV3 = false
                elseif res == 1 then
                    Notify("Race V3 in progress (farm 2M Beli)")
                end
            end)
        end
    end
end)

-- Auto Cyborg
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoGetCyborg then
            pcall(function()
                if GetCurrentSea() ~= 2 then
                    CommF_:InvokeServer("TravelDressrosa")
                    return
                end
                local res = CommF_:InvokeServer("CyborgTrainer", "Check")
                if res == 2 then
                    Notify("Cyborg already owned")
                    State.AutoGetCyborg = false
                    return
                end
                if res then
                    CommF_:InvokeServer("CyborgTrainer", "Buy")
                    Notify("Cyborg purchased")
                    State.AutoGetCyborg = false
                end
            end)
        end
    end
end)

-- Auto Ghoul
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoGetGhoul then
            pcall(function()
                if GetCurrentSea() ~= 2 then
                    CommF_:InvokeServer("TravelDressrosa")
                    return
                end
                local res = CommF_:InvokeServer("Ectoplasm", "BuyCheck", 4)
                if res == 2 then
                    Notify("Ghoul already owned")
                    State.AutoGetGhoul = false
                    return
                end
                local e = FindEnemy({"Ship Deckhand","Ship Steward","Ship Officer","Ship Engineer"}, 5000)
                if e then
                    CombatController.Attack({"Ship Deckhand","Ship Steward","Ship Officer","Ship Engineer"})
                else
                    CommF_:InvokeServer("Ectoplasm", "Buy", 4)
                    CommF_:InvokeServer("Ectoplasm", "Change", 4)
                end
            end)
        end
    end
end)

-- Auto Trial V4
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoTrial then
            pcall(function()
                if not IsAlive() then return end
                if Workspace.Map:FindFirstChild("Temple of Time") then
                    local hrp = GetHRP()
                    if Dist(hrp.Position, Vector3.new(28286, 14895, 102)) < 3000 then
                        local race = player.Data.Race.Value
                        local trialNames = {
                            Human = "Trial of Strength",
                            Mink = "Trial of Speed",
                            Fishman = "Trial of Water",
                            Ghoul = "Trial of Carnage",
                            Cyborg = "Trial of the Machine",
                            Skypiea = "Trial of the King",
                        }
                        local trial = trialNames[race]
                        if trial then
                            local loc = Workspace._WorldOrigin.Locations:FindFirstChild(trial)
                            if loc then
                                FarmTeleport(loc.CFrame, 300, 20)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Buy Gear V4
task.spawn(function()
    while task.wait(1) do
        if State.AutoBuyGearV4 then
            pcall(function()
                local ok, res = pcall(function()
                    return CommF_:InvokeServer("UpgradeRace", "Check", 2)
                end)
                if ok and type(res) == "number" then
                    if res == 2 or res == 4 or res == 7 then
                        CommF_:InvokeServer("UpgradeRace", "Buy", 2)
                        Notify("Gear V4 purchased")
                        task.wait(2)
                    end
                end
            end)
        end
    end
end)

-- Auto Choose Gears
task.spawn(function()
    while task.wait(1) do
        if State.AutoChooseGears then
            pcall(function()
                local ge = State.SelectedGearV4 or "Omega"
                local templeGui = playerGui:FindFirstChild("TempleGui")
                if templeGui then
                    for _, btn in ipairs(templeGui:GetDescendants()) do
                        if btn:IsA("TextButton") and btn.Name:find("Gear") then
                            local connections = getconnections and getconnections(btn.Activated) or {}
                            for _, c in ipairs(connections) do
                                pcall(function() c.Function() end)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

--================================================================
-- QUEST HANDLERS (Kaitun-style)
--================================================================

-- Auto Saber
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoSaber then
            pcall(function()
                if not World1 then
                    CommF_:InvokeServer("TravelMain")
                    return
                end
                if player.Data.Level.Value < 200 then return end
                if player.Backpack:FindFirstChild("Saber") or (player.Character and player.Character:FindFirstChild("Saber")) then
                    Notify("Saber obtained")
                    State.AutoSaber = false
                    return
                end

                local progress = CommF_:InvokeServer("ProQuestProgress")
                -- Uses plates, torch, cup, relic, etc
                if progress then
                    if not progress.UsedTorch then
                        CommF_:InvokeServer("ProQuestProgress", "GetTorch")
                        task.wait(1)
                        CommF_:InvokeServer("ProQuestProgress", "DestroyTorch")
                    elseif not progress.UsedCup then
                        CommF_:InvokeServer("ProQuestProgress", "GetCup")
                        task.wait(1)
                        local cup = player.Backpack:FindFirstChild("Cup") or (player.Character and player.Character:FindFirstChild("Cup"))
                        if cup then
                            player.Character.Humanoid:EquipTool(cup)
                            CommF_:InvokeServer("ProQuestProgress", "FillCup", cup)
                        end
                        CommF_:InvokeServer("ProQuestProgress", "SickMan")
                    elseif not progress.TalkedSon then
                        CommF_:InvokeServer("ProQuestProgress", "RichSon")
                    elseif not progress.KilledMob then
                        CombatController.Attack("Mob Leader")
                    elseif not progress.UsedRelic then
                        CommF_:InvokeServer("ProQuestProgress", "RichSon")
                        CommF_:InvokeServer("ProQuestProgress", "PlaceRelic")
                    elseif Workspace.Enemies:FindFirstChild("Saber Expert") then
                        CombatController.Attack("Saber Expert")
                    end
                end
            end)
        end
    end
end)

-- Auto Yama
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoYama then
            pcall(function()
                if not World3 then
                    CommF_:InvokeServer("TravelZou")
                    return
                end
                if player.Backpack:FindFirstChild("Yama") or (player.Character and player.Character:FindFirstChild("Yama")) then
                    Notify("Yama obtained")
                    State.AutoYama = false
                    return
                end
                local progress = CommF_:InvokeServer("EliteHunter", "Progress") or 0
                if progress < 30 then
                    local elite = FindEnemy({"Diablo","Deandre","Urban"}, 99999)
                    if elite then
                        CombatController.Attack({elite.Name})
                    else
                        CommF_:InvokeServer("EliteHunter")
                    end
                else
                    local katana = Workspace.Map:FindFirstChild("Waterfall")
                    katana = katana and katana:FindFirstChild("SealedKatana")
                    if katana and katana:FindFirstChild("Hitbox") then
                        if Dist(GetHRP().Position, katana.Hitbox.Position) > 20 then
                            FarmTeleport(katana.Hitbox.CFrame, getgenv().FarmSpeed, 20)
                        else
                            fireclickdetector(katana.Hitbox.ClickDetector)
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Tushita
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoTushita then
            pcall(function()
                if not World3 then
                    CommF_:InvokeServer("TravelZou")
                    return
                end
                if player.Backpack:FindFirstChild("Tushita") or (player.Character and player.Character:FindFirstChild("Tushita")) then
                    Notify("Tushita obtained")
                    State.AutoTushita = false
                    return
                end
                local prog = CommF_:InvokeServer("TushitaProgress") or {}
                if not prog.OpenedDoor then
                    if Workspace.Enemies:FindFirstChild("rip_indra True Form") then
                        CombatController.Attack("rip_indra True Form")
                    end
                else
                    if Workspace.Enemies:FindFirstChild("Longma") then
                        CombatController.Attack("Longma")
                    end
                end
            end)
        end
    end
end)

-- Auto Shark Anchor
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoSharkAnchor then
            pcall(function()
                if player.Backpack:FindFirstChild("Shark Anchor") or (player.Character and player.Character:FindFirstChild("Shark Anchor")) then
                    Notify("Shark Anchor obtained")
                    State.AutoSharkAnchor = false
                    return
                end
                -- Chain craft
                local function hasItem(name)
                    return player.Backpack:FindFirstChild(name) or (player.Character and player.Character:FindFirstChild(name))
                end
                if not hasItem("Shark Tooth Necklace") then
                    pcall(function() CommF_:InvokeServer("CraftItem", "Check", "ToothNecklace") end)
                    pcall(function() CommF_:InvokeServer("CraftItem", "Craft", "ToothNecklace") end)
                elseif not hasItem("Terror Jaw") then
                    pcall(function() CommF_:InvokeServer("CraftItem", "Check", "TerrorJaw") end)
                    pcall(function() CommF_:InvokeServer("CraftItem", "Craft", "TerrorJaw") end)
                elseif not hasItem("Monster Magnet") then
                    pcall(function() CommF_:InvokeServer("CraftItem", "Check", "SharkAnchor") end)
                    pcall(function() CommF_:InvokeServer("CraftItem", "Craft", "SharkAnchor") end)
                end
            end)
        end
    end
end)

-- Auto CDK
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoCDK then
            pcall(function()
                if not World3 then
                    CommF_:InvokeServer("TravelZou")
                    return
                end
                if player.Backpack:FindFirstChild("Cursed Dual Katana") or (player.Character and player.Character:FindFirstChild("Cursed Dual Katana")) then
                    Notify("CDK obtained")
                    State.AutoCDK = false
                    return
                end
                local hasTushita = player.Backpack:FindFirstChild("Tushita") ~= nil
                local hasYama = player.Backpack:FindFirstChild("Yama") ~= nil
                if not hasTushita then State.AutoTushita = true end
                if not hasYama then State.AutoYama = true end

                -- Full CDK logic can be extended
            end)
        end
    end
end)

-- Auto Soul Guitar
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoSoulGuitar then
            pcall(function()
                if not World3 then
                    CommF_:InvokeServer("TravelZou")
                    return
                end
                if player.Backpack:FindFirstChild("Skull Guitar") or (player.Character and player.Character:FindFirstChild("Skull Guitar")) then
                    Notify("Soul Guitar obtained")
                    State.AutoSoulGuitar = false
                    return
                end
                local prog = CommF_:InvokeServer("GuitarPuzzleProgress", "Check")
                if not prog then
                    CommF_:InvokeServer("gravestoneEvent", 2)
                    CommF_:InvokeServer("gravestoneEvent", 2, true)
                    return
                end
                if not prog.Swamp then
                    CombatController.Attack({"Living Zombie"})
                elseif not prog.Gravestones then
                    CommF_:InvokeServer("GuitarPuzzleProgress", "Ghost")
                elseif not prog.Ghost then
                    CommF_:InvokeServer("GuitarPuzzleProgress", "Ghost")
                elseif not prog.Trophies then
                    -- Puzzle Trophies
                    local tablet = Workspace.Map["Haunted Castle"].Tablet
                    if tablet then
                        for _, seg in ipairs({"Segment6","Segment2","Segment8","Segment9","Segment5"}) do
                            local part = tablet[seg]
                            if part and part.Line.Rotation.Z ~= 0 then
                                fireclickdetector(part.ClickDetector)
                            end
                        end
                    end
                elseif not prog.Pipes then
                    for k, col in pairs({Part1="Really black", Part2="Really black", Part3="Dusty Rose", Part4="Storm blue", Part5="Really black"}) do
                        pcall(function()
                            local p = Workspace.Map["Haunted Castle"]["Lab Puzzle"].ColorFloor.Model[k]
                            if p and p.BrickColor.Name ~= col then
                                fireclickdetector(p.ClickDetector)
                            end
                        end)
                    end
                else
                    CommF_:InvokeServer("soulGuitarBuy")
                end
            end)
        end
    end
end)

-- Auto Bartilo
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoBartilo then
            pcall(function()
                if not World2 then
                    CommF_:InvokeServer("TravelDressrosa")
                    return
                end
                if player.Backpack:FindFirstChild("Warrior Helmet") then
                    Notify("Bartilo done")
                    State.AutoBartilo = false
                    return
                end
                local progress = CommF_:InvokeServer("BartiloQuestProgress")
                if progress and not progress.KilledBandits then
                    if not (playerGui.Main.Quest and playerGui.Main.Quest.Visible) then
                        CommF_:InvokeServer("StartQuest", "BartiloQuest", 1)
                    else
                        CombatController.Attack("Swan Pirate")
                    end
                elseif progress and not progress.KilledSpring then
                    CombatController.Attack("Jeremy")
                elseif progress and not progress.DidPlates then
                    local hrp = GetHRP()
                    if Dist(hrp.Position, Vector3.new(-1836, 44, 1656)) > 20 then
                        FarmTeleport(CFrame.new(-1836, 44, 1656), getgenv().FarmSpeed, 20)
                    end
                end
            end)
        end
    end
end)

-- Auto Second Sea Puzzle
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoSecondSea then
            pcall(function()
                if not World1 then
                    State.AutoSecondSea = false
                    return
                end
                if player.Data.Level.Value < 700 then return end
                local prog = CommF_:InvokeServer("DressrosaQuestProgress")
                if prog then
                    if not prog.TalkedDetective then
                        CommF_:InvokeServer("DressrosaQuestProgress", "Detective")
                        CommF_:InvokeServer("DressrosaQuestProgress", "UseKey")
                    elseif not prog.KilledIceBoss then
                        CombatController.Attack("Ice Admiral")
                    else
                        CommF_:InvokeServer("TravelDressrosa")
                        State.AutoSecondSea = false
                        Notify("Second Sea unlocked")
                    end
                end
            end)
        end
    end
end)

-- Auto Third Sea Puzzle
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoThirdSea then
            pcall(function()
                if not World2 then
                    State.AutoThirdSea = false
                    return
                end
                if player.Data.Level.Value < 1500 then return end
                local prog = CommF_:InvokeServer("ZQuestProgress", "Check")
                if prog == 1 then
                    CommF_:InvokeServer("TravelZou")
                    State.AutoThirdSea = false
                    Notify("Third Sea unlocked")
                end
            end)
        end
    end
end)

-- Auto Dojo Quest
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoDojo then
            pcall(function()
                local res = CommF_:InvokeServer("DojoQuest", "Check")
                if res and res.Belt then
                    local belt = res.Belt
                    if belt then
                        CombatController.Attack({"Reborn Skeleton"})
                    end
                end
            end)
        end
    end
end)

-- Auto Cake Prince
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoCakePrince then
            pcall(function()
                if not World3 then
                    CommF_:InvokeServer("TravelZou")
                    return
                end
                if Workspace.Enemies:FindFirstChild("Cake Prince") then
                    CombatController.Attack("Cake Prince")
                elseif Workspace.Enemies:FindFirstChild("Dough King") then
                    CombatController.Attack("Dough King")
                else
                    CommF_:InvokeServer("CakePrinceSpawner", true)
                    CommF_:InvokeServer("CakePrinceSpawner")
                    CombatController.Attack({"Baking Staff","Head Baker","Cake Guard","Cookie Crafter"})
                end
            end)
        end
    end
end)

-- Auto Dough King
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoDoughKing then
            pcall(function()
                if not World3 then
                    CommF_:InvokeServer("TravelZou")
                    return
                end
                if Workspace.Enemies:FindFirstChild("Dough King") then
                    CombatController.Attack("Dough King")
                    return
                end
                local hasChalice = player.Backpack:FindFirstChild("God's Chalice") or (player.Character and player.Character:FindFirstChild("God's Chalice"))
                if hasChalice then
                    local res = CommF_:InvokeServer("SweetChaliceNpc")
                    if res == "Where are the items?" then
                        CombatController.Attack({"Cocoa Warrior","Chocolate Bar Battler"})
                    end
                end
            end)
        end
    end
end)

-- Auto Elite Hunter
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoEliteHunter then
            pcall(function()
                if not World3 then
                    CommF_:InvokeServer("TravelZou")
                    return
                end
                local elite = FindEnemy({"Diablo","Deandre","Urban"}, 99999)
                if elite then
                    CombatController.Attack({elite.Name})
                else
                    CommF_:InvokeServer("EliteHunter")
                end
            end)
        end
    end
end)

-- Auto Soul Reaper
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoSoulReaper then
            pcall(function()
                if not World3 then
                    CommF_:InvokeServer("TravelZou")
                    return
                end
                if Workspace.Enemies:FindFirstChild("Soul Reaper") then
                    CombatController.Attack("Soul Reaper")
                    return
                end
                local hasHallow = player.Backpack:FindFirstChild("Hallow Essence") or (player.Character and player.Character:FindFirstChild("Hallow Essence"))
                if hasHallow then
                    local summoner = Workspace.Map["Haunted Castle"].Summoner.Detection
                    if summoner then
                        if Dist(GetHRP().Position, summoner.Position) > 8 then
                            FarmTeleport(summoner.CFrame, getgenv().FarmSpeed, 20)
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Kill Rip Indra
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoKillRipIndra then
            pcall(function()
                if not World3 then
                    CommF_:InvokeServer("TravelZou")
                    return
                end
                local rip = FindEnemy({"rip_indra True Form"}, 99999)
                if rip then
                    CombatController.Attack("rip_indra True Form")
                end
            end)
        end
    end
end)

-- Auto Factory
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoFactory then
            pcall(function()
                if not World2 then
                    CommF_:InvokeServer("TravelDressrosa")
                    return
                end
                local core = FindEnemy({"Core"}, 99999)
                if core then
                    CombatController.Attack("Core")
                else
                    FarmTeleport(CFrame.new(502.73, 143.07, -379.07), getgenv().FarmSpeed, 30)
                end
            end)
        end
    end
end)

-- Auto Pirates Sea
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoPiratesSea then
            pcall(function()
                if not World3 then
                    CommF_:InvokeServer("TravelZou")
                    return
                end
                local e = FindEnemy({"Pirate Grand Brigade", "Pirate Millionaire"}, 2000)
                if e then
                    CombatController.Attack({e.Name})
                else
                    FarmTeleport(CFrame.new(-5556, 314, -2988), getgenv().FarmSpeed, 30)
                end
            end)
        end
    end
end)

-- Auto Dragon Hunter
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoDragonHunter then
            pcall(function()
                if not World3 then
                    CommF_:InvokeServer("TravelZou")
                    return
                end
                local e = FindEnemy({"Hydra Enforcer","Venomous Assailant"}, 5000)
                if e then
                    CombatController.Attack({e.Name})
                else
                    local em = Workspace:FindFirstChild("EmberTemplate")
                    if em and em:FindFirstChild("Part") then
                        FarmTeleport(em.Part.CFrame, getgenv().FarmSpeed, 20)
                    end
                end
            end)
        end
    end
end)

-- Auto Collect Berry
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoCollectBerry then
            pcall(function()
                local hrp = GetHRP()
                for _, d in pairs(Workspace.Map:GetDescendants()) do
                    if d.Name == "Berries" then
                        for i = 1, 8 do
                            if d:GetAttribute("_BerryCFrame" .. i) then
                                local cf = d:GetAttribute("_BerryCFrame" .. i)
                                if typeof(cf) == "CFrame" then
                                    if Dist(hrp.Position, cf.Position) > 5 then
                                        FarmTeleport(cf, getgenv().FarmSpeed, 15)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

--================================================================
-- SEA HANDLERS
--================================================================

-- Auto Farm Sea (Sea Events)
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoFarmSea then
            pcall(function()
                local targets = {}
                if State.AttackShark then table.insert(targets, "Shark") end
                if State.AttackPiranha then table.insert(targets, "Piranha") end
                if State.AttackTerrorshark then table.insert(targets, "Terrorshark") end
                if State.AttackFishCrew then table.insert(targets, "Fish Crew Member") end
                if State.AttackSeaBeasts then table.insert(targets, "SeaBeast1") end

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

-- Auto Repair Ship
task.spawn(function()
    while task.wait(1) do
        if State.AutoRepairShip then
            pcall(function()
                local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Sit then
                    local bar = playerGui.Main.BottomHUDList.ShipHealthBar
                    if bar and bar.Visible then
                        local parts = string.split(string.gsub(bar.TextLabel.Text, "Ship ", ""), "/")
                        local cur = tonumber(parts[1]) or 0
                        local max = tonumber(parts[2]) or 100
                        if cur < max then
                            local hammer = player.Character:FindFirstChild("_RepairHammer")
                            if hammer then
                                if not hammer:GetAttribute("Repairing") then
                                    hammer.M1Down:FireServer("Default")
                                end
                            else
                                CommF_:InvokeServer("requestHammer")
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- No Fog
task.spawn(function()
    while task.wait(1) do
        if State.NoFog then
            pcall(function()
                Lighting.FogEnd = 100000
            end)
        end
    end
end)

-- Auto Dodge Rough Sea
task.spawn(function()
    while task.wait(1) do
        if State.AutoDodgeRoughSea then
            pcall(function()
                local rain = Lighting:FindFirstChild("RainCorrection")
                if rain and rain.Enabled then
                    local hrp = GetHRP()
                    if hrp then
                        hrp.CFrame = hrp.CFrame * CFrame.new(0, 500, 0)
                    end
                end
            end)
        end
    end
end)

-- No Clip Rock (boat parts)
task.spawn(function()
    while task.wait(0.5) do
        if State.NoClipRock then
            pcall(function()
                local boats = Workspace:FindFirstChild("Boats")
                if boats then
                    for _, d in ipairs(boats:GetDescendants()) do
                        if d:IsA("BasePart") then d.CanCollide = false end
                    end
                end
            end)
        end
    end
end)

-- Auto Summon Kitsune Island
task.spawn(function()
    while task.wait(1) do
        if State.AutoSummonKitsune then
            pcall(function()
                if not Workspace.Map:FindFirstChild("KitsuneIsland") then
                    local boat = nil
                    for _, b in ipairs(Workspace.Boats:GetChildren()) do
                        local o = b:FindFirstChild("Owner")
                        if o and tostring(o.Value) == player.Name then boat = b end
                    end
                    if not boat then
                        CommF_:InvokeServer("BuyBoat", "PirateBrigade")
                    else
                        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                        local seat = boat:FindFirstChild("VehicleSeat")
                        if seat then
                            if not hum.Sit then
                                FarmTeleport(seat.CFrame, getgenv().FarmSpeed, 10)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Trade Azure Ember
task.spawn(function()
    while task.wait(2) do
        if State.AutoTradeEmber then
            pcall(function()
                local rf = Net and Net:FindFirstChild("RF/KitsuneStatuePray")
                if rf then rf:InvokeServer() end
            end)
        end
    end
end)

-- Auto Find Leviathan
task.spawn(function()
    while task.wait(1) do
        if State.AutoFindLevi then
            pcall(function()
                if not Workspace._WorldOrigin.Locations:FindFirstChild("Frozen Dimension") then
                    local boat = nil
                    for _, b in ipairs(Workspace.Boats:GetChildren()) do
                        local o = b:FindFirstChild("Owner")
                        if o and tostring(o.Value) == player.Name then boat = b end
                    end
                    if not boat then
                        CommF_:InvokeServer("BuyBoat", "Beast Hunter")
                    else
                        local seat = boat:FindFirstChild("VehicleSeat")
                        if seat then
                            seat.CFrame = CFrame.new(-118140.65, 31.78, 172404.87)
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Attack Leviathan
task.spawn(function()
    while task.wait(0.2) do
        if State.AutoAttackLevi then
            pcall(function()
                local levi = Workspace:FindFirstChild("SeaBeasts")
                levi = levi and levi:FindFirstChild("Leviathan")
                if levi then
                    local hum = levi:FindFirstChild("Humanoid")
                    local hrp = levi:FindFirstChild("HumanoidRootPart")
                    if hum and hrp and hum.Health > 0 then
                        FarmTeleport(hrp.CFrame * CFrame.new(0, 900, 100), 350, 20)
                        EquipWeapon(State.SelectedWeapon)
                        AutoHaki()
                        LockAimPositionTo(hrp.CFrame)
                        AttackNoCoolDown()
                    end
                end
            end)
        end
    end
end)

-- Auto Buy Spy
task.spawn(function()
    while task.wait(5) do
        if State.AutoBuySpy then
            pcall(function()
                if GetCurrentSea() == 3 then
                    local res = CommF_:InvokeServer("InfoLeviathan", "1")
                    if res == 2 then
                        CommF_:InvokeServer("InfoLeviathan", "1")
                        CommF_:InvokeServer("InfoLeviathan", "2")
                    end
                end
            end)
        end
    end
end)

-- Auto Destroy IDK
task.spawn(function()
    while task.wait(1) do
        if State.AutoDestroyIDK then
            pcall(function()
                local res = CommF_:InvokeServer("InfoLeviathan", "1")
                if res == 0 then
                    local seaBeast = FindEnemy({"SeaBeast1","Terrorshark"}, 2000)
                    if seaBeast then
                        local trp = seaBeast:FindFirstChild("HumanoidRootPart")
                        if trp then
                            FarmTeleport(trp.CFrame * CFrame.new(0, 55, 0), 350, 20)
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Summon Mirage
task.spawn(function()
    while task.wait(1) do
        if State.AutoSummonMirage then
            pcall(function()
                if not Workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island") then
                    local boat = nil
                    for _, b in ipairs(Workspace.Boats:GetChildren()) do
                        local o = b:FindFirstChild("Owner")
                        if o and tostring(o.Value) == player.Name then boat = b end
                    end
                    if not boat then
                        CommF_:InvokeServer("BuyBoat", "PirateBrigade")
                    else
                        local seat = boat:FindFirstChild("VehicleSeat")
                        if seat then
                            seat.CFrame = seat.CFrame * CFrame.new(0, 5, -500000)
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Find Mirage
task.spawn(function()
    while task.wait(1) do
        if State.AutoFindMirage then
            pcall(function()
                local mirage = Workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island")
                if mirage then
                    if mirage.PrimaryPart then
                        FarmTeleport(mirage.PrimaryPart.CFrame * CFrame.new(0, 100, 0), 350, 30)
                    end
                end
            end)
        end
    end
end)

-- Auto Summon Prehistoric
task.spawn(function()
    while task.wait(1) do
        if State.AutoSummonPre then
            pcall(function()
                if not Workspace.Map:FindFirstChild("PrehistoricIsland") then
                    local boat = nil
                    for _, b in ipairs(Workspace.Boats:GetChildren()) do
                        local o = b:FindFirstChild("Owner")
                        if o and tostring(o.Value) == player.Name then boat = b end
                    end
                    if not boat then
                        CommF_:InvokeServer("BuyBoat", "PirateBrigade")
                    else
                        local seat = boat:FindFirstChild("VehicleSeat")
                        if seat then
                            seat.CFrame = CFrame.new(-118140.65, 31.78, 172404.87)
                        end
                    end
                end
            end)
        end
    end
end)

-- Auto Find Prehistoric
task.spawn(function()
    while task.wait(1) do
        if State.AutoFindPre then
            pcall(function()
                local pre = Workspace.Map:FindFirstChild("PrehistoricIsland")
                if pre then
                    FarmTeleport(pre:GetPivot() * CFrame.new(0, 100, 0), 350, 30)
                end
            end)
        end
    end
end)

-- Auto Event Prehistoric (Attack Golem, Fix Volcano)
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoEventPre then
            pcall(function()
                if not Workspace.Map:FindFirstChild("PrehistoricIsland") then return end
                local golem = FindEnemy({"Lava Golem"}, 99999)
                if golem then
                    CombatController.Attack("Lava Golem")
                end
                -- Delete lava
                local pre = Workspace.Map.PrehistoricIsland
                if pre then
                    for _, d in ipairs(pre:GetDescendants()) do
                        if d.Name == "TouchInterest" and d.Parent.Name ~= "TrialTeleport" then
                            d:Destroy()
                        end
                    end
                end
            end)
        end
    end
end)

--================================================================
-- FISHING SYSTEM
--================================================================
local function DetectRod()
    if not player.Character then return nil end
    local rod = player.Character:FindFirstChild("FishingRodData", true)
    if rod then return rod.Parent end
    for _, c in ipairs(player.Backpack:GetChildren()) do
        if c:FindFirstChild("FishingRodData") then return c end
    end
    return nil
end

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoEquipRod then
            pcall(function()
                local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if not hum then return end
                local current = player.Character:FindFirstChildOfClass("Tool")
                if not (current and current:GetAttribute("InventoryCategory") == "Rod") then
                    for _, c in ipairs(player.Backpack:GetChildren()) do
                        if c:IsA("Tool") and c:GetAttribute("InventoryCategory") == "Rod" then
                            hum:EquipTool(c)
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
        if State.AutoFishing then
            pcall(function()
                local rod = DetectRod()
                if not rod then return end
                local state = rod:GetAttribute("ServerState")
                if state == "Idle" or state == "ReeledIn" then
                    local req = RS:FindFirstChild("FishReplicated")
                    req = req and req:FindFirstChild("FishingRequest")
                    if req then
                        req:InvokeServer("StartCasting")
                        task.wait(0.7)
                        req:InvokeServer("CastLineAtLocation", 
                            (GetHRP().CFrame * CFrame.new(0, 0, -50)).Position, 98, true)
                    end
                elseif state == "Biting" then
                    local req = RS:FindFirstChild("FishReplicated")
                    req = req and req:FindFirstChild("FishingRequest")
                    if req then
                        req:InvokeServer("Catching", true)
                        task.wait(0.25)
                        req:InvokeServer("Catch", 1)
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if State.AutoSellFish then
            pcall(function()
                local jobs = RS:FindFirstChild("JobsReplicated")
                if jobs then jobs:InvokeServer("FishingNPC", "SellFish") end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if State.AutoSellCorruptedFish then
            pcall(function()
                local net = RS.Modules.Net
                local rf = net:FindFirstChild("RF/JobsRemoteFunction")
                if rf then rf:InvokeServer("FishingNPC", "SellCorruptedFish") end
            end)
        end
    end
end)

--================================================================
-- FRUIT & RAID
--================================================================
task.spawn(function()
    while task.wait(2) do
        if State.AutoStoreFruit then
            pcall(function()
                for _, tool in ipairs(player.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and string.find(tool.Name, "Fruit") then
                        CommF_:InvokeServer("StoreFruit", tool:GetAttribute("OriginalName") or tool.Name, tool)
                        task.wait(0.5)
                    end
                end
                for _, tool in ipairs(player.Character:GetChildren()) do
                    if tool:IsA("Tool") and string.find(tool.Name, "Fruit") then
                        CommF_:InvokeServer("StoreFruit", tool:GetAttribute("OriginalName") or tool.Name, tool)
                        task.wait(0.5)
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(5) do
        if State.AutoBuyFruit then
            pcall(function() CommF_:InvokeServer("Cousin", "Buy") end)
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if State.AutoRandomFruit then
            pcall(function() CommF_:InvokeServer("Cousin", "Buy") end)
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if State.AutoFindFruit then
            pcall(function()
                local hrp = GetHRP()
                for _, c in ipairs(Workspace:GetChildren()) do
                    if c:IsA("Tool") and string.find(c.Name, "Fruit") then
                        local h = c:FindFirstChild("Handle")
                        if h then
                            FarmTeleport(h.CFrame, getgenv().FarmSpeed, 15)
                            break
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if State.AutoDropFruit then
            pcall(function()
                for _, t in ipairs(player.Backpack:GetChildren()) do
                    if t:IsA("Tool") and string.find(t.Name, "Fruit") then
                        CommF_:InvokeServer("Drop", t.Name, t)
                        task.wait(0.5)
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if State.AutoEatFruit then
            pcall(function()
                if player.Data.DevilFruit.Value ~= "" then return end
                for _, t in ipairs(player.Backpack:GetChildren()) do
                    if t:IsA("Tool") and string.find(t.Name, "Fruit") then
                        player.Character.Humanoid:EquipTool(t)
                        task.wait(0.3)
                        local eat = t:FindFirstChild("EatRemote")
                        if eat then eat:InvokeServer("Eat") end
                        break
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoAwakenFruit then
            pcall(function()
                CommF_:InvokeServer("Awakener", "Check")
                CommF_:InvokeServer("Awakener", "Awaken")
            end)
        end
    end
end)

-- Auto Raid
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoRaid then
            pcall(function()
                if GetCurrentSea() < 2 then return end
                if player.Data.Level.Value < 1100 then return end

                local mapName = World2 and "CircleIsland" or (World3 and "Boat Castle")
                local map = mapName and Workspace.Map:FindFirstChild(mapName)
                if not map then return end
                local raidSummon = map:FindFirstChild("RaidSummon2")
                if not raidSummon then return end

                local chip = player.Backpack:FindFirstChild("Special Microchip") or (player.Character and player.Character:FindFirstChild("Special Microchip"))
                if chip then
                    local btn = raidSummon.Button:FindFirstChild("Main")
                    if btn then
                        if player:DistanceFromCharacter(btn.Position) > 20 then
                            FarmTeleport(btn.CFrame, getgenv().FarmSpeed, 20)
                        else
                            fireclickdetector(btn.ClickDetector)
                        end
                    end
                elseif State.AutoBuyChip then
                    if player.Data.Fragments.Value >= 100000 then
                        CommF_:InvokeServer("RaidsNpc", "Select", State.SelectedChip or "Flame")
                        task.wait(1)
                        CommF_:InvokeServer("RaidsNpc", "Buy")
                    end
                end
            end)
        end
    end
end)

--================================================================
-- AUTO BUY MELEES (Kaitun-style)
--================================================================
local MeleePrices = {
    ["Black Leg"] = {Price = {Beli = 150000}, Id = "BlackLeg", Npc = "Dark Step Teacher"},
    ["Electro"] = {Price = {Beli = 500000}, Id = "Electro", Npc = "Mad Scientist"},
    ["Fishman Karate"] = {Price = {Beli = 750000}, Id = "FishmanKarate", Npc = "Water Kung-fu Teacher"},
    ["Dragon Claw"] = {Price = {Fragments = 1500}, Id = "DragonClaw", Npc = "Sabi"},
    ["Superhuman"] = {Price = {Beli = 3000000}, Id = "Superhuman", Npc = "Martial Arts Master"},
    ["Death Step"] = {Price = {Beli = 2500000, Fragments = 5000}, Id = "DeathStep", Npc = "Phoeyu, the Reformed"},
    ["Sharkman Karate"] = {Price = {Beli = 2500000, Fragments = 5000}, Id = "SharkmanKarate", Npc = "Sharkman Teacher"},
    ["Electric Claw"] = {Price = {Beli = 2500000, Fragments = 5000}, Id = "ElectricClaw", Npc = "Previous Hero"},
    ["Dragon Talon"] = {Price = {Beli = 2500000, Fragments = 5000}, Id = "DragonTalon", Npc = "Uzoth"},
    ["Godhuman"] = {Price = {Beli = 5000000, Fragments = 5000}, Id = "Godhuman", Npc = "Ancient Monk"},
    ["Sanguine Art"] = {Price = {Beli = 5000000, Fragments = 5000}, Id = "SanguineArt", Npc = "Shafi"},
}

task.spawn(function()
    while task.wait(1) do
        for name, enabled in pairs(State.AutoBuyMelee) do
            if enabled then
                pcall(function()
                    local data = MeleePrices[name]
                    if not data then return end
                    -- Cek sudah punya
                    local has = false
                    for _, x in ipairs(player.Backpack:GetChildren()) do
                        if x:IsA("Tool") and (x.Name == name or x.ToolTip == "Melee") then has = true end
                    end
                    if has then return end

                    -- Cek uang
                    local beli = player.Data.Beli.Value
                    local frags = player.Data.Fragments.Value
                    local needBeli = data.Price.Beli or 0
                    local needFrag = data.Price.Fragments or 0
                    if beli < needBeli or frags < needFrag then return end

                    -- Pergi ke NPC
                    local npc = Workspace.NPCs:FindFirstChild(data.Npc) or Workspace:FindFirstChild(data.Npc, true)
                    if npc then
                        local root = npc:FindFirstChild("HumanoidRootPart")
                        if root then
                            if player:DistanceFromCharacter(root.Position) > 10 then
                                FarmTeleport(root.CFrame * CFrame.new(0, 3, 5), getgenv().FarmSpeed, 20)
                                return
                            end
                        end
                    end

                    -- Beli
                    CommF_:InvokeServer("Buy" .. data.Id)
                    task.wait(1)
                    Notify("Bought: " .. name)
                end)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if State.AutoFullyMelees then
            for name, _ in pairs(MeleePrices) do
                State.AutoBuyMelee[name] = true
            end
        end
    end
end)

--================================================================
-- ESP SYSTEM (Text Hitam + Glow Putih)
--================================================================
local ESPObjects = {}
local function CreateESPBillboard(adornee, text)
    if not adornee or not adornee.Parent then return end
    if ESPObjects[adornee] and ESPObjects[adornee].Parent then
        local lbl = ESPObjects[adornee]:FindFirstChild("ESP_Text")
        if lbl then lbl.Text = text end
        return
    end

    local bb = Instance.new("BillboardGui")
    bb.Name = "SYSX_ESP"
    bb.Size = UDim2.fromOffset(120, 20)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true
    bb.LightInfluence = 0
    bb.MaxDistance = 500
    bb.Adornee = adornee
    bb.Parent = adornee

    -- Glow putih (rounded)
    local glow = Instance.new("Frame")
    glow.Name = "ESP_Glow"
    glow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glow.BackgroundTransparency = 0.4
    glow.Size = UDim2.fromScale(1.1, 1.4)
    glow.Position = UDim2.fromScale(0.5, 0.5)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.BorderSizePixel = 0
    glow.ZIndex = 1
    glow.Parent = bb

    local gc = Instance.new("UICorner")
    gc.CornerRadius = UDim.new(1, 0)
    gc.Parent = glow

    local gs = Instance.new("UIStroke")
    gs.Color = Color3.fromRGB(255, 255, 255)
    gs.Thickness = 1.5
    gs.Transparency = 0.3
    gs.Parent = glow

    -- Text hitam
    local lbl = Instance.new("TextLabel")
    lbl.Name = "ESP_Text"
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.Position = UDim2.fromScale(0.5, 0.5)
    lbl.AnchorPoint = Vector2.new(0.5, 0.5)
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(0, 0, 0)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextStrokeTransparency = 1
    lbl.ZIndex = 2
    lbl.Parent = bb

    ESPObjects[adornee] = bb
end

local function ClearESPKind(kind)
    for k, v in pairs(ESPObjects) do
        if v:GetAttribute("ESP_Kind") == kind then
            pcall(function() v:Destroy() end)
            ESPObjects[k] = nil
        end
    end
end

-- ESP Player
task.spawn(function()
    while task.wait(0.3) do
        if State.ESPPlayer then
            pcall(function()
                local hrp = GetHRP(); if not hrp then return end
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= player and plr.Character then
                        local trp = plr.Character:FindFirstChild("HumanoidRootPart")
                        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                        if trp and hum and hum.Health > 0 then
                            local d = math.floor((trp.Position - hrp.Position).Magnitude)
                            local bb = CreateESPBillboard(trp, plr.Name .. " [" .. d .. "m]")
                            if bb then bb:SetAttribute("ESP_Kind", "Player") end
                        end
                    end
                end
            end)
        else
            ClearESPKind("Player")
        end
    end
end)

-- ESP Chest
task.spawn(function()
    while task.wait(0.3) do
        if State.ESPChest then
            pcall(function()
                local hrp = GetHRP(); if not hrp then return end
                for _, c in ipairs(GetSortedChests()) do
                    local d = math.floor((c.Position - hrp.Position).Magnitude)
                    local bb = CreateESPBillboard(c, "Chest [" .. d .. "m]")
                    if bb then bb:SetAttribute("ESP_Kind", "Chest") end
                end
            end)
        else
            ClearESPKind("Chest")
        end
    end
end)

-- ESP Devil Fruit
task.spawn(function()
    while task.wait(0.3) do
        if State.ESPDevilFruit then
            pcall(function()
                local hrp = GetHRP(); if not hrp then return end
                for _, c in ipairs(Workspace:GetChildren()) do
                    if (c:IsA("Tool") or c:IsA("Model")) and string.find(c.Name, "Fruit") then
                        local h = c:FindFirstChild("Handle") or c.PrimaryPart
                        if h then
                            local d = math.floor((h.Position - hrp.Position).Magnitude)
                            local bb = CreateESPBillboard(h, c.Name .. " [" .. d .. "m]")
                            if bb then bb:SetAttribute("ESP_Kind", "Fruit") end
                        end
                    end
                end
            end)
        else
            ClearESPKind("Fruit")
        end
    end
end)

-- ESP Island
task.spawn(function()
    while task.wait(0.5) do
        if State.ESPIsland then
            pcall(function()
                local hrp = GetHRP(); if not hrp then return end
                local locs = Workspace._WorldOrigin.Locations
                for _, c in ipairs(locs:GetChildren()) do
                    if c:IsA("BasePart") then
                        local d = math.floor((c.Position - hrp.Position).Magnitude)
                        local bb = CreateESPBillboard(c, c.Name .. " [" .. d .. "m]")
                        if bb then bb:SetAttribute("ESP_Kind", "Island") end
                    end
                end
            end)
        else
            ClearESPKind("Island")
        end
    end
end)

-- ESP Mirage
task.spawn(function()
    while task.wait(0.5) do
        if State.ESPMirage then
            pcall(function()
                local hrp = GetHRP(); if not hrp then return end
                local m = Workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island")
                if m and m:IsA("BasePart") then
                    local d = math.floor((m.Position - hrp.Position).Magnitude)
                    local bb = CreateESPBillboard(m, "Mirage [" .. d .. "m]")
                    if bb then bb:SetAttribute("ESP_Kind", "Mirage") end
                end
            end)
        else
            ClearESPKind("Mirage")
        end
    end
end)

-- ESP Kitsune
task.spawn(function()
    while task.wait(0.5) do
        if State.ESPKitsune then
            pcall(function()
                local hrp = GetHRP(); if not hrp then return end
                local k = Workspace._WorldOrigin.Locations:FindFirstChild("Kitsune Island")
                if k and k:IsA("BasePart") then
                    local d = math.floor((k.Position - hrp.Position).Magnitude)
                    local bb = CreateESPBillboard(k, "Kitsune [" .. d .. "m]")
                    if bb then bb:SetAttribute("ESP_Kind", "Kitsune") end
                end
            end)
        else
            ClearESPKind("Kitsune")
        end
    end
end)

--================================================================
-- MISC HANDLERS
--================================================================
task.spawn(function()
    while task.wait(0.5) do
        if State.Fly then
            pcall(function()
                local hrp = GetHRP(); if not hrp then return end
                if not hrp:FindFirstChild("SYSX_Fly") then
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "SYSX_Fly"
                    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    bv.Velocity = Vector3.zero
                    bv.Parent = hrp
                end
            end)
        else
            pcall(function()
                local hrp = GetHRP()
                if hrp and hrp:FindFirstChild("SYSX_Fly") then
                    hrp.SYSX_Fly:Destroy()
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoResetChar and IsAlive() then
            player.Character.Humanoid.Health = 0
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if State.AutoExpRedeem then
            pcall(function()
                local codes = {"KITT_RESET","SUB2GAMEROBOT_RESET1","SUB2GAMERROBOT_EXP1","SUB2OFFICIALNOOBIE","AXIORE","BLUXXY","JCWK","KITTGAMING","MAGICBUS","STARCODEHEO","STRAWHATMAINE","TANTAIGAMING","THEGREATACE","ENYU_IS_PRO","FUDD10","FUDD10_V2","BIGNEWS","CHANDLER","SECRET_ADMIN","ADMIN_MELEE"}
                for _, c in ipairs(codes) do
                    pcall(function() Remotes.Redeem:InvokeServer(c) end)
                    task.wait(0.3)
                end
            end)
        end
    end
end)

-- Anti-Flag
task.spawn(function()
    while task.wait(1800) do
        if State.AntiFlag then
            pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
        end
    end
end)

-- Auto Hop 1h
task.spawn(function()
    while task.wait(3600) do
        if State.AutoHop1h then
            pcall(function()
                local data = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
                for _, v in pairs(data.data) do
                    if v.id ~= game.JobId and v.playing < v.maxPlayers then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, player)
                        return
                    end
                end
            end)
        end
    end
end)

-- Hop When Idle
local lastMoved = tick()
task.spawn(function()
    while task.wait(1) do
        local hrp = GetHRP()
        if hrp then lastMoved = tick() end
        if State.HopWhenIdle and tick() - lastMoved > 300 then
            pcall(function()
                local data = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
                for _, v in pairs(data.data) do
                    if v.id ~= game.JobId and v.playing < v.maxPlayers then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, player)
                        return
                    end
                end
            end)
        end
    end
end)

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
    Text = "Freemium v2.4  •  14 Tabs",
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
-- NOTIFICATION FUNCTION
--================================================================
local function Notify_(text)
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
Notify = Notify_
_G.Notify = Notify

local function TryBuy(cmd, ...)
    local a = {...}
    local ok = pcall(function() return CommF_:InvokeServer(cmd, table.unpack(a)) end)
    Notify(ok and "Purchased: " .. cmd or "Failed: " .. cmd)
end

--================================================================
-- ANIMATION
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
-- TABS CREATION (14)
--================================================================
local TabDefs = {
    {"Home & Status"},{"Farm"},{"Pvp [Combat]"},{"Quest & Item"},{"Stats"},
    {"Sea"},{"Fishing"},{"Race"},{"Fruit & Raid"},{"Shop"},
    {"Teleport"},{"Visual"},{"SETTINGS"},{"MISC"}
}
for i, d in ipairs(TabDefs) do
    local b = CreateTab(d[1], i)
    b.Activated:Connect(function() ShowTab(d[1]) end)
end

local HomePage      = CreatePage("Home & Status")
local FarmPage      = CreatePage("Farm")
local PvpPage       = CreatePage("Pvp [Combat]")
local QuestPage     = CreatePage("Quest & Item")
local StatsPage     = CreatePage("Stats")
local SeaPage       = CreatePage("Sea")
local FishingPage   = CreatePage("Fishing")
local RacePage      = CreatePage("Race")
local FruitRaidPage = CreatePage("Fruit & Raid")
local ShopPage      = CreatePage("Shop")
local TeleportPage  = CreatePage("Teleport")
local VisualPage    = CreatePage("Visual")
local SettingsPage  = CreatePage("SETTINGS")
local MiscPage      = CreatePage("MISC")

--================================================================
-- HOME & STATUS
--================================================================
CreateLabel(HomePage, "=== SYSX HUB v2.4 ===", 32)
CreateLabel(HomePage,
    "14 Tabs | Full Code\n" ..
    "• Home & Status\n" ..
    "• Farm • Pvp [Combat]\n" ..
    "• Quest & Item • Stats\n" ..
    "• Sea • Fishing • Race\n" ..
    "• Fruit & Raid • Shop\n" ..
    "• Teleport • Visual\n" ..
    "• SETTINGS • MISC\n\n" ..
    "All handlers included.\n" ..
    "Bring Mob + Auto Kill + Quest Auto", 200)
CreateButton(HomePage, "Join Discord Server", function()
    if setclipboard then setclipboard(DISCORD_INVITE) end
    pcall(function() GuiService:OpenBrowserWindow(DISCORD_INVITE) end)
    Notify("Discord link copied & opening...")
end)
CreateLabel(HomePage, "Player: " .. player.Name, 30)
CreateLabel(HomePage, "JobId: " .. game.JobId, 30)
CreateLabel(HomePage, "PlaceId: " .. game.PlaceId, 30)

--================================================================
-- FARM
--================================================================
CreateLabel(FarmPage, "=== Level Farming ===", 26)
CreateToggle(FarmPage, "Auto Farm Level", false, function(s)
    State.AutoFarm = s
    Notify(s and "Auto Farm Level ON" or "Auto Farm Level OFF")
end)
CreateToggle(FarmPage, "Auto Farm Nearest", false, function(s) State.AutoFarmNearest = s end)
CreateToggle(FarmPage, "Auto Farm Mastery", false, function(s) State.AutoFarmMastery = s end)

CreateLabel(FarmPage, "=== Collection ===", 26)
CreateToggle(FarmPage, "Auto Collect Chest", false, function(s)
    State.AutoCollectChest = s
    if s then ChestCacheDone = false; ChestCache = {} end
end)
CreateToggle(FarmPage, "Auto Farm Material", false, function(s) State.AutoFarmMaterial = s end)
CreateToggle(FarmPage, "Auto Farm Bones", false, function(s) State.AutoFarmBones = s end)
CreateToggle(FarmPage, "Auto Farm Wood Planks", false, function(s) State.AutoFarmWoodPlanks = s end)
CreateToggle(FarmPage, "Auto Treasure Chest", false, function(s) State.AutoTreasureChest = s end)
CreateToggle(FarmPage, "Auto Collect Drops", false, function(s) State.AutoCollectDrops = s end)
CreateToggle(FarmPage, "Auto Farmer Drops", false, function(s) State.AutoFarmerDrops = s end)

CreateLabel(FarmPage, "=== Boss Farm (Rutin) ===", 26)
CreateToggle(FarmPage, "Auto Attack Boss", false, function(s) State.AutoAttackBoss = s end)
CreateToggle(FarmPage, "Auto Attack All Boss", false, function(s) State.AutoAttackAllBoss = s end)
CreateToggle(FarmPage, "Auto Tyrant of the Skies", false, function(s) State.AutoTyrant = s end)
CreateToggle(FarmPage, "Auto Citizen Quest", false, function(s) State.AutoCitizenQuest = s end)
CreateToggle(FarmPage, "Auto Dark Fragment", false, function(s) State.AutoDarkFragment = s end)
CreateToggle(FarmPage, "Auto Sweet Chalice", false, function(s) State.AutoSweetChalice = s end)

CreateLabel(FarmPage, "=== Farm Config ===", 26)
CreateDropdown(FarmPage, "Select Weapon", {"Melee","Sword","Blox Fruit","Gun"}, function(o) State.SelectedWeapon = o end)
CreateToggle(FarmPage, "Bring Mob", true, function(s) State.BringMob = s end)
CreateSlider(FarmPage, "Bring Mob Radius", 50, 1000, 300, function(v) State.BringRange = v end)
CreateSlider(FarmPage, "Bring Mob Count", 1, 10, 2, function(v) State.BringCount = v end)
CreateSlider(FarmPage, "Farm Speed", 50, 500, 200, function(v) getgenv().FarmSpeed = v end)
CreateToggle(FarmPage, "Auto Haki", true, function(s) State.AutoHaki = s end)
CreateToggle(FarmPage, "Auto Ken", false, function(s) State.AutoKen = s end)

--================================================================
-- PVP [COMBAT]
--================================================================
CreateLabel(PvpPage, "=== PvP Combat ===", 26)
CreateToggle(PvpPage, "Auto Aimbot / Lock Aim", false, function(s) State.AutoAimbot = s end)
CreateToggle(PvpPage, "Auto Dodge Skill", false, function(s) State.AutoDodgeSkill = s end)
CreateToggle(PvpPage, "Teleport Player", false, function(s) State.TeleportPlayer = s end)
local pvpPlayers = {"None"}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= player then table.insert(pvpPlayers, p.Name) end
end
CreateDropdown(PvpPage, "Select Player PVP", pvpPlayers, function(o) State.SelectedPlayer = o end)
CreateDropdown(PvpPage, "Select Method Aimbot", {"Select Player","Target nearest Player"}, function(o) State.MethodAimbot = o end)
CreateButton(PvpPage, "Refresh Player", function()
    Notify("Player list refreshed (rejoin to reload)")
end)

--================================================================
-- QUEST & ITEM
--================================================================
CreateLabel(QuestPage, "=== Sword Quest ===", 26)
CreateToggle(QuestPage, "Auto Saber Quest", false, function(s) State.AutoSaber = s end)
CreateToggle(QuestPage, "Auto Yama Quest", false, function(s) State.AutoYama = s end)
CreateToggle(QuestPage, "Auto Tushita Quest", false, function(s) State.AutoTushita = s end)
CreateToggle(QuestPage, "Auto Shark Anchor Quest", false, function(s) State.AutoSharkAnchor = s end)
CreateToggle(QuestPage, "Auto Pole Quest", false, function(s) State.AutoPole = s end)
CreateToggle(QuestPage, "Auto Fox Lamp Quest", false, function(s) State.AutoFoxLamp = s end)
CreateToggle(QuestPage, "Auto Dark Dagger Quest", false, function(s) State.AutoDarkDagger = s end)
CreateToggle(QuestPage, "Auto Canvander Quest", false, function(s) State.AutoCanvander = s end)
CreateToggle(QuestPage, "Auto Buddy Sword Quest", false, function(s) State.AutoBuddySword = s end)
CreateToggle(QuestPage, "Auto Hallow Scythe Quest", false, function(s) State.AutoHallowScythe = s end)
CreateToggle(QuestPage, "Auto CDK Quest", false, function(s) State.AutoCDK = s end)

CreateLabel(QuestPage, "=== Gun Quest ===", 26)
CreateToggle(QuestPage, "Auto Acidum Rifle Quest", false, function(s) State.AutoAcidumRifle = s end)
CreateToggle(QuestPage, "Auto Venom Bow Quest", false, function(s) State.AutoVenomBow = s end)
CreateToggle(QuestPage, "Auto Soul Guitar Quest", false, function(s) State.AutoSoulGuitar = s end)
CreateToggle(QuestPage, "Auto Dragon Storm Quest", false, function(s) State.AutoDragonStorm = s end)

CreateLabel(QuestPage, "=== Special Item Quest ===", 26)
CreateToggle(QuestPage, "Auto Rengoku Quest", false, function(s) State.AutoRengoku = s end)
CreateToggle(QuestPage, "Auto Insict V2 Quest", false, function(s) State.AutoInsictV2 = s end)
CreateToggle(QuestPage, "Auto Rainbow Saviour Quest", false, function(s) State.AutoRainbowSaviour = s end)
CreateToggle(QuestPage, "Auto Dark Blade V2 Quest", false, function(s) State.AutoDarkBladeV2 = s end)
CreateToggle(QuestPage, "Auto Dark Blade V3 Quest", false, function(s) State.AutoDarkBladeV3 = s end)

CreateLabel(QuestPage, "=== Puzzle Quest ===", 26)
CreateToggle(QuestPage, "Auto Bartilo Quest", false, function(s) State.AutoBartilo = s end)
CreateToggle(QuestPage, "Auto Second Sea Puzzle", false, function(s) State.AutoSecondSea = s end)
CreateToggle(QuestPage, "Auto Third Sea Puzzle", false, function(s) State.AutoThirdSea = s end)
CreateToggle(QuestPage, "Auto Dojo Quest", false, function(s) State.AutoDojo = s end)

CreateLabel(QuestPage, "=== Boss Item Quest ===", 26)
CreateToggle(QuestPage, "Auto Cake Prince", false, function(s) State.AutoCakePrince = s end)
CreateToggle(QuestPage, "Auto Dough King", false, function(s) State.AutoDoughKing = s end)
CreateToggle(QuestPage, "Auto Kill Elite Hunter", false, function(s) State.AutoEliteHunter = s end)
CreateToggle(QuestPage, "Auto Soul Reaper", false, function(s) State.AutoSoulReaper = s end)
CreateToggle(QuestPage, "Auto Kill Rip Indra", false, function(s) State.AutoKillRipIndra = s end)
CreateToggle(QuestPage, "Auto Factory", false, function(s) State.AutoFactory = s end)
CreateToggle(QuestPage, "Auto Pirates Sea", false, function(s) State.AutoPiratesSea = s end)
CreateToggle(QuestPage, "Auto Dragon Hunter Quest", false, function(s) State.AutoDragonHunter = s end)

CreateLabel(QuestPage, "=== Collection Quest ===", 26)
CreateToggle(QuestPage, "Auto Collect Berry", false, function(s) State.AutoCollectBerry = s end)

--================================================================
-- STATS
--================================================================
CreateLabel(StatsPage, "=== Auto Stats ===", 26)
CreateToggle(StatsPage, "Auto Stat Point", false, function(s) State.AutoStatPoint = s end)
CreateSlider(StatsPage, "Points Per Click", 1, 50, 1, function(v) State.PointsPerClick = v end)
CreateToggle(StatsPage, "Auto Melee", false, function(s) State.StatMelee = s end)
CreateToggle(StatsPage, "Auto Defense", false, function(s) State.StatDefense = s end)
CreateToggle(StatsPage, "Auto Sword", false, function(s) State.StatSword = s end)
CreateToggle(StatsPage, "Auto Gun", false, function(s) State.StatGun = s end)
CreateToggle(StatsPage, "Auto Blox Fruit", false, function(s) State.StatFruit = s end)
CreateLabel(StatsPage, "=== Manual Add ===", 26)
CreateButton(StatsPage, "Add 100 Melee", function() CommF_:InvokeServer("AddPoint", "Melee", 100) Notify("+100 Melee") end)
CreateButton(StatsPage, "Add 100 Defense", function() CommF_:InvokeServer("AddPoint", "Defense", 100) Notify("+100 Defense") end)
CreateButton(StatsPage, "Add 100 Sword", function() CommF_:InvokeServer("AddPoint", "Sword", 100) Notify("+100 Sword") end)
CreateButton(StatsPage, "Add 100 Gun", function() CommF_:InvokeServer("AddPoint", "Gun", 100) Notify("+100 Gun") end)
CreateButton(StatsPage, "Add 100 Blox Fruit", function() CommF_:InvokeServer("AddPoint", "Demon Fruit", 100) Notify("+100 Fruit") end)

--================================================================
-- SEA
--================================================================
CreateLabel(SeaPage, "=== Sea Config ===", 26)
CreateDropdown(SeaPage, "Select Boat", {"PirateBrigade","PirateGrandBrigade","Beast Hunter"}, function(o) State.SelectedBoat = o end)
CreateDropdown(SeaPage, "Danger Level", {"1","2","3","4","5","6","infinite"}, function(o) State.DangerLevel = o end)
CreateDropdown(SeaPage, "Combat Weapon", {"Melee","Blox Fruit","Gun","Sword","Random"}, function(o) State.CombatWeapon = o end)

CreateLabel(SeaPage, "=== Sea Event ===", 26)
CreateToggle(SeaPage, "Auto Farm Sea", false, function(s) State.AutoFarmSea = s end)
CreateToggle(SeaPage, "Attack Sea Beasts", false, function(s) State.AttackSeaBeasts = s end)
CreateToggle(SeaPage, "Dodge Sea Beasts Skill", false, function(s) State.DodgeSeaBeasts = s end)
CreateToggle(SeaPage, "Attack Terrorshark", false, function(s) State.AttackTerrorshark = s end)
CreateToggle(SeaPage, "Dodge Terrorshark Skill", false, function(s) State.DodgeTerrorshark = s end)
CreateToggle(SeaPage, "Attack Ghost Ship", false, function(s) State.AttackGhostShip = s end)
CreateToggle(SeaPage, "Attack Piranha", false, function(s) State.AttackPiranha = s end)
CreateToggle(SeaPage, "Attack Shark", false, function(s) State.AttackShark = s end)
CreateToggle(SeaPage, "Attack Fish Crew", false, function(s) State.AttackFishCrew = s end)
CreateToggle(SeaPage, "Protect Boat", false, function(s) State.ProtectBoat = s end)
CreateToggle(SeaPage, "Auto Repair Ur Ship", false, function(s) State.AutoRepairShip = s end)
CreateToggle(SeaPage, "Auto Dodge Rough Sea", false, function(s) State.AutoDodgeRoughSea = s end)
CreateToggle(SeaPage, "No Clip Rock", false, function(s) State.NoClipRock = s end)
CreateToggle(SeaPage, "No Fog", false, function(s) State.NoFog = s end)

CreateLabel(SeaPage, "=== Kitsune Island ===", 26)
CreateToggle(SeaPage, "Auto Summon Kitsune Island", false, function(s) State.AutoSummonKitsune = s end)
CreateToggle(SeaPage, "Tween to Kitsune Island", false, function(s) State.TweenKitsune = s end)
CreateToggle(SeaPage, "Auto Collect Azure Ember", false, function(s) State.AutoCollectEmber = s end)
CreateToggle(SeaPage, "Auto Trade Azure Ember", false, function(s) State.AutoTradeEmber = s end)

CreateLabel(SeaPage, "=== Leviathan / Frozen ===", 26)
CreateToggle(SeaPage, "Tween to Frozen Dimension", false, function(s) State.TweenFrozenDimension = s end)
CreateToggle(SeaPage, "Auto Find Leviathan", false, function(s) State.AutoFindLevi = s end)
CreateToggle(SeaPage, "Auto Attack Leviathan", false, function(s) State.AutoAttackLevi = s end)
CreateToggle(SeaPage, "Auto Attack Levi Segment", false, function(s) State.AutoAttackLeviSeg = s end)
CreateToggle(SeaPage, "Auto Attack Levi Tail", false, function(s) State.AutoAttackLeviTail = s end)
CreateToggle(SeaPage, "Auto Buy Boat Beast Hunter", false, function(s) State.AutoBuyBoatBH = s end)
CreateToggle(SeaPage, "Auto Start Leviathan", false, function(s) State.AutoStartLevi = s end)
CreateToggle(SeaPage, "Auto Buy Spy", false, function(s) State.AutoBuySpy = s end)
CreateToggle(SeaPage, "Auto Destroy IDK", false, function(s) State.AutoDestroyIDK = s end)

CreateLabel(SeaPage, "=== Mirage Island ===", 26)
CreateToggle(SeaPage, "Auto Summon Mirage Island", false, function(s) State.AutoSummonMirage = s end)
CreateToggle(SeaPage, "Tween to Mirage Island", false, function(s) State.TweenMirage = s end)
CreateToggle(SeaPage, "Auto Find Mirage", false, function(s) State.AutoFindMirage = s end)

CreateLabel(SeaPage, "=== Prehistoric Island ===", 26)
CreateToggle(SeaPage, "Auto Summon Prehistoric Island", false, function(s) State.AutoSummonPre = s end)
CreateToggle(SeaPage, "Tween To Prehistoric Island", false, function(s) State.TweenPre = s end)
CreateToggle(SeaPage, "Auto Find Prehistoric Island", false, function(s) State.AutoFindPre = s end)
CreateToggle(SeaPage, "Auto Event Prehistoric Island", false, function(s) State.AutoEventPre = s end)
CreateToggle(SeaPage, "Fully Event Prehistoric Island", false, function(s) State.FullyEventPre = s end)
CreateToggle(SeaPage, "Auto Collect Bone", false, function(s) State.AutoCollectBone = s end)
CreateToggle(SeaPage, "Auto Collect Egg", false, function(s) State.AutoCollectEgg = s end)

CreateLabel(SeaPage, "=== Sea Craft ===", 26)
CreateToggle(SeaPage, "Auto Shark Tooth Necklace", false, function(s) State.AutoToothNecklace = s end)
CreateToggle(SeaPage, "Auto Terror Jaw", false, function(s) State.AutoTerrorJaw = s end)
CreateToggle(SeaPage, "Auto Monster Magnet", false, function(s) State.AutoMonsterMagnet = s end)
CreateToggle(SeaPage, "Auto Shark Anchor Craft", false, function(s) State.AutoSharkAnchorCraft = s end)
CreateToggle(SeaPage, "Auto Crafting Volcanic Magnet", false, function(s) State.AutoCraftVolcanic = s end)

CreateLabel(SeaPage, "=== Boat Setting ===", 26)
CreateToggle(SeaPage, "Fly Boat", false, function(s) State.FlyBoat = s end)
CreateToggle(SeaPage, "Drive Boat To Tiki", false, function(s) State.DriveBoatTiki = s end)
CreateToggle(SeaPage, "Drive Boat To Hydra", false, function(s) State.DriveBoatHydra = s end)
CreateSlider(SeaPage, "Value Speed Boat", 50, 500, 200, function(v) State.SpeedBoat = v end)
CreateSlider(SeaPage, "Value Speed Tween Boat", 50, 2000, 350, function(v) State.SpeedTweenBoat = v end)
CreateSlider(SeaPage, "Value Speed Fly Boat", 0, 10, 3, function(v) State.SpeedFlyBoat = v end)
CreateToggle(SeaPage, "Teleport Boat Other CFrame if Rough Sea", false, function(s) State.TeleportBoatRough = s end)
CreateToggle(SeaPage, "Tween Until Have Sea Event", false, function(s) State.TweenUntilEvent = s end)

--================================================================
-- FISHING
--================================================================
CreateLabel(FishingPage, "=== Fishing ===", 26)
CreateToggle(FishingPage, "Auto Equip Rod", false, function(s) State.AutoEquipRod = s end)
CreateToggle(FishingPage, "Auto Fishing", false, function(s) State.AutoFishing = s end)
CreateToggle(FishingPage, "Auto Sell Fish", false, function(s) State.AutoSellFish = s end)
CreateToggle(FishingPage, "Auto Sell Corrupted Fish", false, function(s) State.AutoSellCorruptedFish = s end)
CreateDropdown(FishingPage, "Select Bait", {"Basic Bait","Good Bait","Excellent Bait"}, function(o) State.SelectedBait = o end)
CreateButton(FishingPage, "Save Position Fishing", function()
    local hrp = GetHRP()
    if not hrp then return end
    getgenv().FishingPosition = hrp.CFrame
    Notify("Fishing position saved")
end)

--================================================================
-- RACE
--================================================================
CreateLabel(RacePage, "=== Race V2/V3 ===", 26)
CreateToggle(RacePage, "Auto Race V2", false, function(s) State.AutoRaceV2 = s end)
CreateToggle(RacePage, "Auto Race V3", false, function(s) State.AutoRaceV3 = s end)
CreateToggle(RacePage, "Auto Get Cyborg", false, function(s) State.AutoGetCyborg = s end)
CreateToggle(RacePage, "Auto Get Ghoul", false, function(s) State.AutoGetGhoul = s end)

CreateLabel(RacePage, "=== Race V4 Trial ===", 26)
CreateToggle(RacePage, "Auto Trial", false, function(s) State.AutoTrial = s end)
CreateToggle(RacePage, "Auto Kill Players After Trial", false, function(s) State.AutoKillAfterTrialRace = s end)
CreateToggle(RacePage, "Auto Trial Draco", false, function(s) State.AutoTrialDraco = s end)
CreateToggle(RacePage, "Fully Trial Draco", false, function(s) State.FullyTrialDraco = s end)
CreateToggle(RacePage, "No Frog", false, function(s)
    if s then
        Lighting.FogEnd = 100000
        for _, d in pairs(Lighting:GetDescendants()) do
            if d:IsA("Atmosphere") then d:Destroy() end
        end
    end
end)

CreateLabel(RacePage, "=== Temple Teleport ===", 26)
CreateButton(RacePage, "Teleport To Temple", function()
    local hrp = GetHRP()
    if hrp then hrp.CFrame = CFrame.new(28286.35, 14895.30, 102.62) end
    local ms = RS:FindFirstChild("MapStash")
    local tot = ms and ms:FindFirstChild("Temple of Time")
    if tot then tot.Parent = Workspace.Map end
    Notify("At Temple of Time")
end)
CreateButton(RacePage, "Pull Lever", function()
    for _, d in pairs(Workspace.Map["Temple of Time"]:GetDescendants()) do
        if d.Name == "ProximityPrompt" then
            pcall(function() fireproximityprompt(d, math.huge) end)
        end
    end
    Notify("Lever pulled")
end)

CreateLabel(RacePage, "=== Gear V4 ===", 26)
CreateToggle(RacePage, "Auto Buy Gear V4", false, function(s) State.AutoBuyGearV4 = s end)
CreateToggle(RacePage, "Auto Choose Gears", false, function(s) State.AutoChooseGears = s end)
CreateDropdown(RacePage, "Select Gear V4", {"Alpha","Omega"}, function(o) State.SelectedGearV4 = o end)
CreateToggle(RacePage, "Auto Race Draco", false, function(s) State.AutoRaceDraco = s end)

--================================================================
-- FRUIT & RAID
--================================================================
CreateLabel(FruitRaidPage, "=== Fruit ===", 26)
CreateToggle(FruitRaidPage, "Auto Store Fruit", false, function(s) State.AutoStoreFruit = s end)
CreateToggle(FruitRaidPage, "Auto Buy Fruit (Cousin)", false, function(s) State.AutoBuyFruit = s end)
CreateToggle(FruitRaidPage, "Auto Buy Fruits Sniper", false, function(s) State.AutoBuySniper = s end)
CreateToggle(FruitRaidPage, "Auto Buy Fruits Sniper (Mirage)", false, function(s) State.AutoBuySniperMirage = s end)
CreateToggle(FruitRaidPage, "Auto Find Fruit", false, function(s) State.AutoFindFruit = s end)
CreateToggle(FruitRaidPage, "Auto Get Spawner Fruit", false, function(s) State.AutoGetSpawnerFruit = s end)
CreateToggle(FruitRaidPage, "Auto Random Fruit", false, function(s) State.AutoRandomFruit = s end)
CreateToggle(FruitRaidPage, "Auto Drop Fruit", false, function(s) State.AutoDropFruit = s end)
CreateToggle(FruitRaidPage, "Auto Eat Fruit", false, function(s) State.AutoEatFruit = s end)

CreateLabel(FruitRaidPage, "=== Raid ===", 26)
CreateToggle(FruitRaidPage, "Auto Raid", false, function(s) State.AutoRaid = s end)
CreateToggle(FruitRaidPage, "Auto Buy Chip", false, function(s) State.AutoBuyChip = s end)
CreateToggle(FruitRaidPage, "Auto Awaken Fruit", false, function(s) State.AutoAwakenFruit = s end)
CreateDropdown(FruitRaidPage, "Select Raid",
    {"Flame","Ice","Sand","Dark","Light","Magma","Quake","Buddha","Love","Spider","Sound","Phoenix","Portal","Rumble","Pain","Blizzard","Gravity"},
    function(o) State.SelectedRaid = o end)
CreateDropdown(FruitRaidPage, "Select Chip",
    {"Flame","Ice","Sand","Dark","Light","Magma","Quake","Buddha"},
    function(o) State.SelectedChip = o end)

--================================================================
-- SHOP
--================================================================
CreateLabel(ShopPage, "=== Fighting Styles (Auto Buy) ===", 26)
local MeleeList = {"Black Leg","Electro","Fishman Karate","Dragon Claw","Superhuman","Death Step","Sharkman Karate","Electric Claw","Dragon Talon","Godhuman","Sanguine Art"}
for _, m in ipairs(MeleeList) do
    CreateToggle(ShopPage, "Auto Buy " .. m, false, function(s)
        State.AutoBuyMelee[m] = s
    end)
end
CreateToggle(ShopPage, "Auto Fully Melees", false, function(s) State.AutoFullyMelees = s end)

CreateLabel(ShopPage, "=== Abilities ===", 26)
CreateButton(ShopPage, "Buy Geppo", function() CommF_:InvokeServer("BuyHaki", "Geppo") Notify("Buy Geppo") end)
CreateButton(ShopPage, "Buy Buso", function() CommF_:InvokeServer("BuyHaki", "Buso") Notify("Buy Buso") end)
CreateButton(ShopPage, "Buy Soru", function() CommF_:InvokeServer("BuyHaki", "Soru") Notify("Buy Soru") end)
CreateButton(ShopPage, "Buy Ken", function() CommF_:InvokeServer("KenTalk", "Buy") Notify("Buy Ken") end)

CreateLabel(ShopPage, "=== Sword ===", 26)
for _, sw in ipairs({"Katana","Cutlass","Dual Katana","Iron Mace","Triple Katana","Pipe","Dual-Headed Blade","Soul Cane","Bisento"}) do
    CreateButton(ShopPage, "Buy " .. sw, function() TryBuy("BuyItem", sw) end)
end

CreateLabel(ShopPage, "=== Gun ===", 26)
for _, gn in ipairs({"Musket","Slingshot","Flintlock","Refined Slingshot","Refined Flintlock","Cannon"}) do
    CreateButton(ShopPage, "Buy " .. gn, function() TryBuy("BuyItem", gn) end)
end
CreateButton(ShopPage, "Buy Kabucha", function()
    TryBuy("BlackbeardReward", "Slingshot", "1")
    task.wait(0.3)
    TryBuy("BlackbeardReward", "Slingshot", "2")
end)

CreateLabel(ShopPage, "=== Accessory ===", 26)
for _, ac in ipairs({"Black Cape","Swordsman Hat","Tomoe Ring"}) do
    CreateButton(ShopPage, "Buy " .. ac, function() TryBuy("BuyItem", ac) end)
end

CreateLabel(ShopPage, "=== Race ===", 26)
CreateButton(ShopPage, "Buy Ghoul Race", function()
    TryBuy("Ectoplasm", "BuyCheck", 4)
    task.wait(0.3)
    TryBuy("Ectoplasm", "Change", 4)
end)
CreateButton(ShopPage, "Buy Cyborg Race", function() TryBuy("CyborgTrainer", "Buy") end)

CreateLabel(ShopPage, "=== Misc ===", 26)
CreateButton(ShopPage, "Buy Stat Refund", function()
    TryBuy("BlackbeardReward", "Refund", "1") task.wait(0.3)
    TryBuy("BlackbeardReward", "Refund", "2")
end)
CreateButton(ShopPage, "Buy Race Reroll", function()
    TryBuy("BlackbeardReward", "Reroll", "1") task.wait(0.3)
    TryBuy("BlackbeardReward", "Reroll", "2")
end)
CreateButton(ShopPage, "Buy Legendary Sword", function()
    TryBuy("LegendarySwordDealer", "1") task.wait(0.3)
    TryBuy("LegendarySwordDealer", "2") task.wait(0.3)
    TryBuy("LegendarySwordDealer", "3")
end)
CreateButton(ShopPage, "Buy True Triple Katana", function()
    TryBuy("MysteriousMan", "1") task.wait(0.3)
    TryBuy("MysteriousMan", "2")
end)

--================================================================
-- TELEPORT
--================================================================
CreateLabel(TeleportPage, "=== Sea Travel ===", 26)
CreateButton(TeleportPage, "Travel to Sea 1", function() CommF_:InvokeServer("TravelMain") Notify("Traveling Sea 1") end)
CreateButton(TeleportPage, "Travel to Sea 2", function() CommF_:InvokeServer("TravelDressrosa") Notify("Traveling Sea 2") end)
CreateButton(TeleportPage, "Travel to Sea 3", function() CommF_:InvokeServer("TravelZou") Notify("Traveling Sea 3") end)

CreateLabel(TeleportPage, "=== Island Teleport ===", 26)
CreateDropdown(TeleportPage, "Select Island", {"Sky 2","Sky 3"}, function(o) State.SelectedIsland = o end)
CreateButton(TeleportPage, "Tween To Island", function()
    local isl = {["Sky 2"] = Vector3.new(-4607.82, 872.54, -1667.55), ["Sky 3"] = Vector3.new(-7894.61, 5547.14, -380.29)}
    local sel = State.SelectedIsland
    if sel and isl[sel] then
        CommF_:InvokeServer("requestEntrance", isl[sel])
        Notify("Traveling to " .. sel)
    end
end)

--================================================================
-- VISUAL
--================================================================
CreateLabel(VisualPage, "=== ESP ===", 26)
CreateToggle(VisualPage, "ESP Player", false, function(s) State.ESPPlayer = s end)
CreateToggle(VisualPage, "ESP Chest", false, function(s) State.ESPChest = s end)
CreateToggle(VisualPage, "ESP Berry", false, function(s) State.ESPBerry = s end)
CreateToggle(VisualPage, "ESP Flower", false, function(s) State.ESPFlower = s end)
CreateToggle(VisualPage, "ESP Devil Fruit", false, function(s) State.ESPDevilFruit = s end)
CreateToggle(VisualPage, "ESP Island", false, function(s) State.ESPIsland = s end)
CreateToggle(VisualPage, "ESP Mirage Island", false, function(s) State.ESPMirage = s end)
CreateToggle(VisualPage, "ESP Kitsune Island", false, function(s) State.ESPKitsune = s end)

CreateLabel(VisualPage, "=== Remove UI ===", 26)
CreateToggle(VisualPage, "Remove Damage", false, function(s) State.RemoveDamage = s end)
CreateToggle(VisualPage, "Remove Notifications", false, function(s) State.RemoveNotifications = s end)
CreateToggle(VisualPage, "Boost FPS", false, function(s) State.BoostFPS = s end)
CreateToggle(VisualPage, "Black Screen", false, function(s) State.BlackScreen = s end)
CreateToggle(VisualPage, "White Screen", false, function(s) State.WhiteScreen = s end)

--================================================================
-- SETTINGS
--================================================================
CreateLabel(SettingsPage, "=== Config ===", 26)
CreateButton(SettingsPage, "Reset Config", function()
    Notify("Config reset (rejoin to apply)")
end)

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
WebhookBox.FocusLost:Connect(function()
    if WebhookBox.Text ~= "" and WebhookBox.Text:find("discord.com/api/webhooks") then
        State.WebhookURL = WebhookBox.Text
        Notify("Webhook URL saved")
    else
        Notify("Invalid Webhook URL")
    end
end)
CreateToggle(SettingsPage, "Webhook Error Report", true, function(s) State.WebhookReport = s end)
CreateToggle(SettingsPage, "Noti Profile", false, function(s) State.NotiProfile = s end)
CreateToggle(SettingsPage, "Ping Discord", false, function(s) State.PingDiscord = s end)
CreateToggle(SettingsPage, "Webhook Tester", false, function(s) State.WebhookTester = s end)

CreateLabel(SettingsPage, "=== Screen ===", 26)
CreateSlider(SettingsPage, "FPS Cap", 15, 240, 60, function(v)
    State.FPScap = v
    pcall(function() if setfpscap then setfpscap(v) end end)
end)
CreateToggle(SettingsPage, "White Screen", false, function(s)
    pcall(function() RunService:Set3dRenderingEnabled(not s) end)
end)
CreateToggle(SettingsPage, "Black Screen", false, function(s)
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

--================================================================
-- MISC
--================================================================
CreateLabel(MiscPage, "=== Server & Hop ===", 26)
CreateToggle(MiscPage, "Auto Hop (after 1h)", false, function(s) State.AutoHop1h = s end)
CreateToggle(MiscPage, "Hop When Idle", false, function(s) State.HopWhenIdle = s end)
CreateButton(MiscPage, "Hop Server", function() Notify("Hopping...") end)
CreateButton(MiscPage, "Low Hop", function() Notify("Low hopping...") end)
CreateButton(MiscPage, "Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId, player)
end)
CreateLabel(MiscPage, "JobId: " .. game.JobId, 30)

CreateLabel(MiscPage, "=== Local Player ===", 26)
CreateSlider(MiscPage, "WalkSpeed", 16, 300, 16, function(v)
    State.WalkSpeed = v
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = v end
end)
CreateSlider(MiscPage, "JumpPower", 50, 500, 50, function(v)
    State.JumpPower = v
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = v end
end)
CreateToggle(MiscPage, "Infinite Jump", false, function(s) State.InfiniteJump = s end)
CreateToggle(MiscPage, "Fly", false, function(s) State.Fly = s end)
CreateToggle(MiscPage, "Walk On Water", false, function(s)
    State.WalkOnWater = s
    local water = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("WaterBase-Plane")
    if water then water.Size = s and Vector3.new(1000,113,1000) or Vector3.new(1000,80,1000) end
end)
CreateToggle(MiscPage, "No Clip", false, function(s) State.NoClip = s end)
CreateToggle(MiscPage, "Anti-AFK", true, function(s) State.AntiAFK = s end)
CreateToggle(MiscPage, "Auto Reset Character", false, function(s) State.AutoResetChar = s end)
CreateToggle(MiscPage, "Fast Attack", true, function(s) State.FastAttackMisc = s end)

CreateLabel(MiscPage, "=== Utility ===", 26)
CreateToggle(MiscPage, "Anti-Flag", false, function(s) State.AntiFlag = s end)
CreateToggle(MiscPage, "Anti-Kick", true, function(s) State.AntiKick = s end)
CreateToggle(MiscPage, "Kick Recovery", true, function(s) State.KickRecovery = s end)
CreateButton(MiscPage, "Join Pirates", function() CommF_:InvokeServer("SetTeam", "Pirates") Notify("Joined Pirates") end)
CreateButton(MiscPage, "Join Marines", function() CommF_:InvokeServer("SetTeam", "Marines") Notify("Joined Marines") end)
CreateToggle(MiscPage, "Auto Exp Redeem", false, function(s) State.AutoExpRedeem = s end)

CreateLabel(MiscPage, "=== Open UI ===", 26)
CreateButton(MiscPage, "Open Fruit Shop", function()
    pcall(function()
        require(RS.Controllers.UI.FruitShop):Open()
    end)
end)
CreateButton(MiscPage, "Open Titles", function()
    local titlesMenu = playerGui:FindFirstChild("TitlesMenu")
    if titlesMenu and titlesMenu:FindFirstChild("Open") then
        titlesMenu.Open:Fire()
    end
end)
CreateButton(MiscPage, "Open Haki Color", function()
    pcall(function()
        playerGui.Main.Colors.Visible = true
    end)
end)

--================================================================
-- MAIN LOOPS
--================================================================

-- Fast Attack Loop
task.spawn(function()
    while task.wait(0.05) do
        if State.FastAttackMisc and IsAlive() then pcall(AttackNoCoolDown) end
    end
end)

-- Auto Haki Loop
task.spawn(function()
    while task.wait(0.5) do
        pcall(function() if State.AutoHaki then AutoHaki() end end)
    end
end)

-- Auto Farm Level Loop (Kaitun-style with quest handling)
task.spawn(function()
    while task.wait(0.25) do
        if State.AutoFarm then
            pcall(function()
                local hrp = GetHRP()
                if not hrp then return end

                local char = player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then return end

                -- Check quest via main quest UI
                local mainGui = playerGui:FindFirstChild("Main")
                local hasQuest = mainGui and mainGui:FindFirstChild("Quest") and mainGui.Quest.Visible
                local questMob = nil
                if hasQuest then
                    local questTitle = mainGui.Quest.Container.QuestTitle.Title.Text or ""
                    local m = questTitle:match("Defeat%s*%d*%s*(.-)%s*%b()")
                    if m then questMob = m:gsub("Military ", "Mil. ") end
                end

                -- Get best quest for level
                if not questMob then
                    local level = player.Data.Level.Value
                    local Quests = require(RS.Quests)
                    local GuideModule = require(RS.GuideModule)
                    local best, lastLvl = nil, 0
                    local ignored = {BartiloQuest=true, Trainees=true, MarineQuest=true, CitizenQuest=true}

                    for npcName, npcData in pairs(GuideModule.Data.NPCList or {}) do
                        local internal = npcData.InternalQuestName
                        if internal and not ignored[internal] and Quests[internal] and npcData.Levels then
                            for id, req in pairs(npcData.Levels) do
                                if Quests[internal][id] and req <= level and req >= lastLvl then
                                    local mob, amt = next(Quests[internal][id].Task)
                                    if amt and amt > 1 then
                                        best = {Id=id, QuestName=internal, Pos=npcData.Position, Mob=mob, Level=req}
                                        lastLvl = req
                                    end
                                end
                            end
                        end
                    end

                    if not best then return end
                    local npcPos = typeof(best.Pos) == "CFrame" and best.Pos.Position or best.Pos
                    if Dist(hrp.Position, npcPos) > 8 then
                        FarmTeleport(CFrame.new(npcPos) * CFrame.new(0, 4, 2), getgenv().FarmSpeed, 25)
                        return
                    end
                    CommF_:InvokeServer("StartQuest", tostring(best.QuestName), best.Id)
                    return
                end

                -- Attack mob
                local enemy = FindEnemy({questMob}, 99999)
                if not enemy then
                    local sp = FindSpawnPart(questMob, true)
                    if sp then FarmTeleport(sp.CFrame * CFrame.new(0, 60, 0), getgenv().FarmSpeed, 25) end
                    return
                end
                CombatController.Attack({questMob})
            end)
        end
    end
end)

-- Auto Farm Nearest
task.spawn(function()
    while task.wait(0.35) do
        if State.AutoFarmNearest then
            pcall(function()
                local list = GetMonAsSortedRange()
                if list[1] then
                    CombatController.Attack({list[1].Name})
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
                CombatController.Attack({"Reborn Skeleton","Living Zombie","Demonic Soul","Posessed Mummy"})
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
                    ["Angel Wings"] = {"Royal Soldier","Royal Squad"},
                    ["Leather + Scrap Metal"] = {"Pirate","Brute"},
                    ["Magma Ore"] = {"Military Soldier","Lava Pirate"},
                    ["Fish Tail"] = {"Fishman Warrior","Fishman Captain"},
                }
                local npcs = mats[State.SelectedMaterial]
                if npcs then
                    CombatController.Attack(npcs)
                end
            end)
        end
    end
end)

-- Auto Kill Boss
task.spawn(function()
    while task.wait(0.4) do
        if State.AutoAttackBoss and State.SelectedBoss then
            pcall(function() CombatController.Attack({State.SelectedBoss}) end)
        end
        if State.AutoAttackAllBoss then
            pcall(function()
                CombatController.Attack({
                    "Greybeard","The Saw","Saber Expert","The Gorilla King","Bobby",
                    "Yeti","Vice Admiral","Warden","Chief Warden","Swan",
                    "Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg"
                })
            end)
        end
        if State.AutoTyrant then
            pcall(function()
                if Workspace.Enemies:FindFirstChild("Tyrant of the Skies") then
                    CombatController.Attack("Tyrant of the Skies")
                end
            end)
        end
        if State.AutoCitizenQuest then
            pcall(function()
                CombatController.Attack({"Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate"})
            end)
        end
        if State.AutoDarkFragment then
            pcall(function()
                if Workspace.Enemies:FindFirstChild("Darkbeard") then
                    CombatController.Attack("Darkbeard")
                end
            end)
        end
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if State.NoClip and player.Character then
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

-- Remove UI
task.spawn(function()
    while task.wait(0.5) do
        if State.RemoveDamage then pcall(function() RS.Assets.GUI.DamageCounter.Enabled = false end) end
        if State.RemoveNotifications then pcall(function() playerGui.Notifications.Enabled = false end) end
    end
end)

-- Auto Stat
task.spawn(function()
    while task.wait(3) do
        if State.AutoStatPoint then
            pcall(function()
                local stats = {{"Melee",State.StatMelee},{"Defense",State.StatDefense},{"Sword",State.StatSword},{"Gun",State.StatGun},{"Demon Fruit",State.StatFruit}}
                for _, s in ipairs(stats) do
                    if s[2] then
                        CommF_:InvokeServer("AddPoint", s[1], State.PointsPerClick)
                        task.wait(0.3)
                    end
                end
            end)
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
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
Notify("SysxHub v2.4 Loaded — 14 Tabs Full ✅")
