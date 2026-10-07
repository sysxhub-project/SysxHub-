--[[
================================================================
    SYSX HUB v1.1 — Blox Fruits
    Structure: 13 Tabs
    Home&Status, Farm, Pvp[Combat], Quest&Item, Stats, Sea,
    Fishing, Race, Fruit&Raid, Shop, Teleport, Visual, MISC
================================================================
]]

--================================================================
-- SERVICES
--================================================================
local Players             = game:GetService("Players")
local RS                  = game:GetService("ReplicatedStorage")
local TweenService        = game:GetService("TweenService")
local UserInputService    = game:GetService("UserInputService")
local RunService          = game:GetService("RunService")
local Workspace           = game:GetService("Workspace")
local VirtualUser         = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService     = game:GetService("TeleportService")
local Lighting            = game:GetService("Lighting")
local HttpService         = game:GetService("HttpService")
local CollectionService   = game:GetService("CollectionService")
local GuiService          = game:GetService("GuiService")

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
-- THEME — Outline Style
--================================================================
local BLUE_PALETTE = {
    Color3.fromRGB(135, 206, 250),
    Color3.fromRGB(100, 149, 237),
    Color3.fromRGB(80, 130, 220),
    Color3.fromRGB(40, 90, 180),
    Color3.fromRGB(120, 180, 240),
}

local THEME = {
    BG_Main         = Color3.fromRGB(8, 12, 24),
    BG_Secondary    = Color3.fromRGB(12, 18, 32),
    BG_Tertiary     = Color3.fromRGB(20, 28, 50),
    BG_Hover        = Color3.fromRGB(28, 38, 66),
    BG_Active       = Color3.fromRGB(40, 56, 96),
    Accent_Bright   = Color3.fromRGB(180, 220, 255),
    Text_Primary    = Color3.fromRGB(230, 238, 248),
    Text_Secondary  = Color3.fromRGB(150, 165, 190),
    Text_Muted      = Color3.fromRGB(105, 118, 145),
    Border          = Color3.fromRGB(50, 70, 120),
    Static_Blue     = Color3.fromRGB(60, 130, 220),
    Static_BlueSoft = Color3.fromRGB(180, 220, 255),
    Toggle_On       = Color3.fromRGB(60, 130, 220),
    Toggle_Off      = Color3.fromRGB(30, 36, 52),
    Toggle_DotOn    = Color3.fromRGB(255, 255, 255),
    Toggle_DotOff   = Color3.fromRGB(140, 145, 160),
    Outline         = Color3.fromRGB(80, 130, 220),
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
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = p
end

local function Stroke(p, c, t, tr)
    local s = Instance.new("UIStroke")
    s.Color = c or THEME.Outline
    s.Thickness = t or 1.5
    s.Transparency = tr or 0.15
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
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

    -- Quest
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
    AutoStatPoint=false, PointsPerClick=1, SelectedStat="Melee",
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

    -- Sea to Sea (baru)
    AutoTravelSea1=false, AutoTravelSea2=false, AutoTravelSea3=false,

    -- Fishing
    AutoEquipRod=false, AutoFishing=false, AutoSellFish=false, AutoSellCorruptedFish=false,
    SelectedBait="Basic Bait",

    -- Race
    AutoRaceV2=false, AutoRaceV3=false, AutoTrial=false, AutoKillAfterTrialRace=false,
    AutoTrialDraco=false, FullyTrialDraco=false,
    AutoBuyGearV4=false, AutoChooseGears=false, SelectedGearV4="Omega",
    AutoGetCyborg=false, AutoGetGhoul=false, AutoRaceDraco=false,

    -- Race V4 (baru)
    AutoPullLeverV4=false, AutoTrialV4=false, AutoFinishTrainV4=false,

    -- Fruit & Raid
    AutoStoreFruit=false, AutoBuyFruit=false, AutoBuySniper=false,
    AutoFindFruit=false, AutoRandomFruit=false, SelectedSniperFruit="Flame",
    AutoRaid=false, AutoBuyChip=false, AutoAwakenFruit=false,
    SelectedRaid="Flame", SelectedChip="Flame",

    -- Shop
    AutoBuyMelee={}, AutoFullyMelees=false, SelectedMelee="Black Leg",

    -- Teleport
    SelectedIsland=nil,

    -- Visual
    ESPPlayer=false, ESPChest=false, ESPBerry=false, ESPFlower=false,
    ESPDevilFruit=false, ESPIsland=false, ESPMirage=false, ESPKitsune=false,
    RemoveDamage=false, RemoveNotifications=false, BoostFPS=false,
    BlackScreen=false, WhiteScreen=false,

    -- MISC
    AutoHop1h=false, HopWhenIdle=false, WalkSpeed=16, JumpPower=50,
    InfiniteJump=false, WalkOnWater=false, NoClip=false,
    AntiAFK=true, AutoResetChar=false, FastAttackMisc=true,
    AntiFlag=false, AntiKick=true, KickRecovery=true, AutoExpRedeem=false,
    WebhookURL="", WebhookReport=true, NotiProfile=false,
    PingDiscord=false, FPScap=60,
}

getgenv().FarmDistance    = 20
getgenv().FarmSpeed       = 200

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
-- MOB SPAWN CACHE
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

--================================================================
-- BRING MOB
--================================================================
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
    local lastTick = tick()
    local timeoutStart = tick()

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
-- CHEST SYSTEM — Source Baru
--================================================================
local ChestData = {
    MaxSpeed = 300,
    Unchecked = {},
    FirstRun = true,
}

local function GetCharacter()
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    player.Character:WaitForChild("HumanoidRootPart")
    return player.Character
end

local function SortChestsByDistance(list)
    local char = GetCharacter()
    local root = char:FindFirstChild("LowerTorso") or char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local rp = root.Position
    table.sort(list, function(a, b)
        return (rp - a.Position).Magnitude < (rp - b.Position).Magnitude
    end)
end

local function BuildChestCache()
    if not ChestData.FirstRun then return end
    ChestData.FirstRun = false
    ChestData.Unchecked = {}
    for _, obj in pairs(game:GetDescendants()) do
        if obj.ClassName == "Part" and obj.Name:find("Chest") then
            table.insert(ChestData.Unchecked, obj)
        end
    end
end

local function GetSortedChests()
    BuildChestCache()
    local chests = {}
    for _, chest in pairs(ChestData.Unchecked) do
        if chest:FindFirstChild("TouchInterest") then
            table.insert(chests, chest)
        end
    end
    SortChestsByDistance(chests)
    return chests
end

local ChestNoclipConn = nil
local function SetChestNoclip(on)
    if on then
        if ChestNoclipConn then return end
        ChestNoclipConn = RunService.Stepped:Connect(function()
            pcall(function()
                if player.Character then
                    for _, v in pairs(player.Character:GetChildren()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end
            end)
        end)
    else
        if ChestNoclipConn then
            ChestNoclipConn:Disconnect()
            ChestNoclipConn = nil
        end
    end
end

local function ChestTeleport(goalCF, speed)
    if not IsAlive() then return end
    speed = speed or ChestData.MaxSpeed

    SetChestNoclip(true)
    local root = GetHRP()
    if not root then SetChestNoclip(false); return end

    local initDist = (root.Position - goalCF.Position).Magnitude
    local timeout = tick() + math.max(15, initDist / speed * 3)

    while true do
        if not State.AutoCollectChest then break end
        if not IsAlive() then break end
        if tick() > timeout then break end

        local root2 = GetHRP()
        if not root2 then break end

        local dist = (root2.Position - goalCF.Position).Magnitude
        if dist < 1 then break end

        local dir = (goalCF.Position - root2.Position).Unit
        local step = speed * RunService.Heartbeat:Wait()
        root2.CFrame = root2.CFrame + dir * step
    end

    if IsAlive() then
        local root3 = GetHRP()
        if root3 and (root3.Position - goalCF.Position).Magnitude < 5 then
            root3.CFrame = goalCF
        end
    end

    SetChestNoclip(false)
end

--================================================================
-- COMBAT CONTROLLER
--================================================================
_G.FastAttack = 0
task.spawn(function()
    while task.wait(0.01) do
        if _G.FastAttack == os.time() then pcall(AttackNoCoolDown) end
    end
end)

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
            local spawnPart = FindSpawnPart(name, true)
            if spawnPart then
                FarmTeleport(spawnPart.CFrame + Vector3.new(0, 35, 35), getgenv().FarmSpeed, 25)
            end
        end
    end
end

--================================================================
-- AIMBOT
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
            if #Args == 1 and typeof(Args[1]) == "Vector3" then Args[1] = AimPos.Position end
            if #Args == 1 and typeof(Args[1]) == "CFrame" then Args[1] = AimPos end
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
-- UTILITY
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

--================================================================
-- RACE HANDLERS
--================================================================
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoRaceV2 then
            pcall(function()
                if GetCurrentSea() ~= 2 then CommF_:InvokeServer("TravelDressrosa"); return end
                local res = CommF_:InvokeServer("Alchemist", "1")
                if res == 0 then
                    local pos = CFrame.new(-2779.83521, 72.9661407, -3574.02002)
                    if Dist(GetHRP().Position, pos.Position) > 5 then
                        FarmTeleport(pos, getgenv().FarmSpeed, 15)
                    else
                        CommF_:InvokeServer("Alchemist", "2")
                    end
                elseif res == 1 then
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
                        CombatController.Attack({"Swan Pirate"})
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

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoRaceV3 then
            pcall(function()
                if GetCurrentSea() ~= 2 then CommF_:InvokeServer("TravelDressrosa"); return end
                local res = CommF_:InvokeServer("Wenlocktoad", "1")
                if res == 0 then CommF_:InvokeServer("Wenlocktoad", "2")
                elseif res == 2 then
                    CommF_:InvokeServer("Wenlocktoad", "3")
                    Notify("Race V3 done!")
                    State.AutoRaceV3 = false
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoGetCyborg then
            pcall(function()
                if GetCurrentSea() ~= 2 then CommF_:InvokeServer("TravelDressrosa"); return end
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

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoGetGhoul then
            pcall(function()
                if GetCurrentSea() ~= 2 then CommF_:InvokeServer("TravelDressrosa"); return end
                local res = CommF_:InvokeServer("Ectoplasm", "BuyCheck", 4)
                if res == 2 then
                    Notify("Ghoul already owned")
                    State.AutoGetGhoul = false
                    return
                end
                CombatController.Attack({"Ship Deckhand","Ship Steward","Ship Officer","Ship Engineer"})
                CommF_:InvokeServer("Ectoplasm", "Buy", 4)
                CommF_:InvokeServer("Ectoplasm", "Change", 4)
            end)
        end
    end
end)

--================================================================
-- QUEST HANDLERS
--================================================================
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoSaber then
            pcall(function()
                if not World1 then CommF_:InvokeServer("TravelMain"); return end
                if player.Data.Level.Value < 200 then return end
                if player.Backpack:FindFirstChild("Saber") or (player.Character and player.Character:FindFirstChild("Saber")) then
                    Notify("Saber obtained")
                    State.AutoSaber = false
                    return
                end
                local progress = CommF_:InvokeServer("ProQuestProgress")
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

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoYama then
            pcall(function()
                if not World3 then CommF_:InvokeServer("TravelZou"); return end
                if player.Backpack:FindFirstChild("Yama") or (player.Character and player.Character:FindFirstChild("Yama")) then
                    Notify("Yama obtained")
                    State.AutoYama = false
                    return
                end
                local progress = CommF_:InvokeServer("EliteHunter", "Progress") or 0
                if progress < 30 then
                    local elite = FindEnemy({"Diablo","Deandre","Urban"}, 99999)
                    if elite then CombatController.Attack({elite.Name})
                    else CommF_:InvokeServer("EliteHunter") end
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

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoTushita then
            pcall(function()
                if not World3 then CommF_:InvokeServer("TravelZou"); return end
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

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoSharkAnchor then
            pcall(function()
                if player.Backpack:FindFirstChild("Shark Anchor") or (player.Character and player.Character:FindFirstChild("Shark Anchor")) then
                    Notify("Shark Anchor obtained")
                    State.AutoSharkAnchor = false
                    return
                end
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

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoSoulGuitar then
            pcall(function()
                if not World3 then CommF_:InvokeServer("TravelZou"); return end
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
                if not prog.Swamp then CombatController.Attack({"Living Zombie"})
                elseif not prog.Gravestones then CommF_:InvokeServer("GuitarPuzzleProgress", "Ghost")
                elseif not prog.Ghost then CommF_:InvokeServer("GuitarPuzzleProgress", "Ghost")
                else CommF_:InvokeServer("soulGuitarBuy") end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoBartilo then
            pcall(function()
                if not World2 then CommF_:InvokeServer("TravelDressrosa"); return end
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

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoSecondSea then
            pcall(function()
                if not World1 then State.AutoSecondSea = false; return end
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

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoThirdSea then
            pcall(function()
                if not World2 then State.AutoThirdSea = false; return end
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

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoCakePrince then
            pcall(function()
                if not World3 then CommF_:InvokeServer("TravelZou"); return end
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

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoDoughKing then
            pcall(function()
                if not World3 then CommF_:InvokeServer("TravelZou"); return end
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

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoEliteHunter then
            pcall(function()
                if not World3 then CommF_:InvokeServer("TravelZou"); return end
                local elite = FindEnemy({"Diablo","Deandre","Urban"}, 99999)
                if elite then CombatController.Attack({elite.Name})
                else CommF_:InvokeServer("EliteHunter") end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoSoulReaper then
            pcall(function()
                if not World3 then CommF_:InvokeServer("TravelZou"); return end
                if Workspace.Enemies:FindFirstChild("Soul Reaper") then
                    CombatController.Attack("Soul Reaper")
                    return
                end
                local hasHallow = player.Backpack:FindFirstChild("Hallow Essence") or (player.Character and player.Character:FindFirstChild("Hallow Essence"))
                if hasHallow then
                    local summoner = Workspace.Map["Haunted Castle"].Summoner.Detection
                    if summoner and Dist(GetHRP().Position, summoner.Position) > 8 then
                        FarmTeleport(summoner.CFrame, getgenv().FarmSpeed, 20)
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoKillRipIndra then
            pcall(function()
                if not World3 then CommF_:InvokeServer("TravelZou"); return end
                local rip = FindEnemy({"rip_indra True Form"}, 99999)
                if rip then CombatController.Attack("rip_indra True Form") end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoFactory then
            pcall(function()
                if not World2 then CommF_:InvokeServer("TravelDressrosa"); return end
                local core = FindEnemy({"Core"}, 99999)
                if core then CombatController.Attack("Core")
                else FarmTeleport(CFrame.new(502.73, 143.07, -379.07), getgenv().FarmSpeed, 30) end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoPiratesSea then
            pcall(function()
                if not World3 then CommF_:InvokeServer("TravelZou"); return end
                local e = FindEnemy({"Pirate Grand Brigade", "Pirate Millionaire"}, 2000)
                if e then CombatController.Attack({e.Name})
                else FarmTeleport(CFrame.new(-5556, 314, -2988), getgenv().FarmSpeed, 30) end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoDragonHunter then
            pcall(function()
                if not World3 then CommF_:InvokeServer("TravelZou"); return end
                local e = FindEnemy({"Hydra Enforcer","Venomous Assailant"}, 5000)
                if e then CombatController.Attack({e.Name})
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
                                if typeof(cf) == "CFrame" and Dist(hrp.Position, cf.Position) > 5 then
                                    FarmTeleport(cf, getgenv().FarmSpeed, 15)
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

task.spawn(function()
    while task.wait(1) do
        if State.NoFog then pcall(function() Lighting.FogEnd = 100000 end) end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if State.AutoDodgeRoughSea then
            pcall(function()
                local rain = Lighting:FindFirstChild("RainCorrection")
                if rain and rain.Enabled then
                    local hrp = GetHRP()
                    if hrp then hrp.CFrame = hrp.CFrame * CFrame.new(0, 500, 0) end
                end
            end)
        end
    end
end)

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
                        if seat and not hum.Sit then FarmTeleport(seat.CFrame, getgenv().FarmSpeed, 10) end
                    end
                end
            end)
        end
    end
end)

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
                        if seat then seat.CFrame = CFrame.new(-118140.65, 31.78, 172404.87) end
                    end
                end
            end)
        end
    end
end)

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
                        if seat then seat.CFrame = seat.CFrame * CFrame.new(0, 5, -500000) end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if State.AutoFindMirage then
            pcall(function()
                local mirage = Workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island")
                if mirage and mirage.PrimaryPart then
                    FarmTeleport(mirage.PrimaryPart.CFrame * CFrame.new(0, 100, 0), 350, 30)
                end
            end)
        end
    end
end)

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
                        if seat then seat.CFrame = CFrame.new(-118140.65, 31.78, 172404.87) end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if State.AutoFindPre then
            pcall(function()
                local pre = Workspace.Map:FindFirstChild("PrehistoricIsland")
                if pre then FarmTeleport(pre:GetPivot() * CFrame.new(0, 100, 0), 350, 30) end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoEventPre then
            pcall(function()
                if not Workspace.Map:FindFirstChild("PrehistoricIsland") then return end
                local golem = FindEnemy({"Lava Golem"}, 99999)
                if golem then CombatController.Attack("Lava Golem") end
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
-- FISHING
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
    while task.wait(3) do
        if State.AutoBuyFruit then
            pcall(function()
                local res = CommF_:InvokeServer("Cousin", "Buy")
                if res then Notify("Bought Random Fruit: " .. tostring(res)) end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(5) do
        if State.AutoRandomFruit then
            pcall(function()
                local res = CommF_:InvokeServer("Cousin", "Buy")
                if res then
                    Notify("Rolled: " .. tostring(res))
                    if State.AutoStoreFruit then
                        task.wait(1)
                        for _, tool in ipairs(player.Backpack:GetChildren()) do
                            if tool:IsA("Tool") and string.find(tool.Name, "Fruit") then
                                CommF_:InvokeServer("StoreFruit",
                                    tool:GetAttribute("OriginalName") or tool.Name, tool)
                                task.wait(0.5)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if State.AutoFindFruit then
            pcall(function()
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
    while task.wait(0.5) do
        if State.AutoAwakenFruit then
            pcall(function()
                CommF_:InvokeServer("Awakener", "Check")
                CommF_:InvokeServer("Awakener", "Awaken")
            end)
        end
    end
end)

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
-- AUTO BUY MELEES
--================================================================
local MeleePrices = {
    ["Black Leg"]       = {Price = {Beli = 150000},                   Id = "BlackLeg",       Npc = "Dark Step Teacher"},
    ["Electro"]         = {Price = {Beli = 500000},                   Id = "Electro",        Npc = "Mad Scientist"},
    ["Fishman Karate"]  = {Price = {Beli = 750000},                   Id = "FishmanKarate",  Npc = "Water Kung-fu Teacher"},
    ["Dragon Claw"]     = {Price = {Fragments = 1500},                Id = "DragonClaw",     Npc = "Sabi"},
    ["Superhuman"]      = {Price = {Beli = 3000000},                  Id = "Superhuman",     Npc = "Martial Arts Master"},
    ["Death Step"]      = {Price = {Beli = 2500000, Fragments = 5000}, Id = "DeathStep",      Npc = "Phoeyu, the Reformed"},
    ["Sharkman Karate"] = {Price = {Beli = 2500000, Fragments = 5000}, Id = "SharkmanKarate", Npc = "Sharkman Teacher"},
    ["Electric Claw"]   = {Price = {Beli = 2500000, Fragments = 5000}, Id = "ElectricClaw",   Npc = "Previous Hero"},
    ["Dragon Talon"]    = {Price = {Beli = 2500000, Fragments = 5000}, Id = "DragonTalon",    Npc = "Uzoth"},
    ["Godhuman"]        = {Price = {Beli = 5000000, Fragments = 5000}, Id = "Godhuman",       Npc = "Ancient Monk"},
    ["Sanguine Art"]    = {Price = {Beli = 5000000, Fragments = 5000}, Id = "SanguineArt",    Npc = "Shafi"},
}

task.spawn(function()
    while task.wait(1) do
        for name, enabled in pairs(State.AutoBuyMelee) do
            if enabled then
                pcall(function()
                    local data = MeleePrices[name]
                    if not data then return end
                    local has = false
                    for _, x in ipairs(player.Backpack:GetChildren()) do
                        if x:IsA("Tool") and (x.Name == name or x.ToolTip == "Melee") then has = true end
                    end
                    if has then return end

                    local beli = player.Data.Beli.Value
                    local frags = player.Data.Fragments.Value
                    local needBeli = data.Price.Beli or 0
                    local needFrag = data.Price.Fragments or 0
                    if beli < needBeli or frags < needFrag then return end

                    local npc = Workspace.NPCs:FindFirstChild(data.Npc) or Workspace:FindFirstChild(data.Npc, true)
                    if npc then
                        local root = npc:FindFirstChild("HumanoidRootPart")
                        if root and player:DistanceFromCharacter(root.Position) > 10 then
                            FarmTeleport(root.CFrame * CFrame.new(0, 3, 5), getgenv().FarmSpeed, 20)
                            return
                        end
                    end

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
-- ESP — Text Hitam + Glow Putih (Neon)
--================================================================
local ESPObjects = {}
local GLOW_LAYERS = 5

local function CreateESPBillboard(adornee, text)
    if not adornee or not adornee.Parent then return end
    if ESPObjects[adornee] and ESPObjects[adornee].Parent then
        local lbl = ESPObjects[adornee]:FindFirstChild("ESP_Text")
        if lbl then lbl.Text = text end
        return ESPObjects[adornee]
    end

    local bb = Instance.new("BillboardGui")
    bb.Name = "SYSX_ESP"
    bb.Size = UDim2.fromOffset(140, 20)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.LightInfluence = 0
    bb.MaxDistance = 1000
    bb.Adornee = adornee
    bb.Parent = adornee

    for i = 1, GLOW_LAYERS do
        local glowLbl = Instance.new("TextLabel")
        glowLbl.Name = "ESP_Glow_" .. i
        glowLbl.BackgroundTransparency = 1
        glowLbl.Size = UDim2.fromScale(1, 1)
        glowLbl.Position = UDim2.fromScale(0.5, 0.5)
        glowLbl.AnchorPoint = Vector2.new(0.5, 0.5)
        glowLbl.Text = text
        glowLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        glowLbl.TextSize = 11
        glowLbl.Font = Enum.Font.GothamBold
        glowLbl.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
        glowLbl.TextStrokeTransparency = 1 - (i * 0.15)
        glowLbl.TextTransparency = 0.5
        glowLbl.ZIndex = 1
        glowLbl.Parent = bb
    end

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
    lbl.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextStrokeTransparency = 0
    lbl.TextTransparency = 0
    lbl.ZIndex = 10
    lbl.Parent = bb

    ESPObjects[adornee] = bb
    return bb
end

local function UpdateESPText(adornee, text)
    local bb = ESPObjects[adornee]
    if not bb then return end
    local main = bb:FindFirstChild("ESP_Text")
    if main then main.Text = text end
    for i = 1, GLOW_LAYERS do
        local g = bb:FindFirstChild("ESP_Glow_" .. i)
        if g then g.Text = text end
    end
end

local function ClearESPKind(kind)
    for k, v in pairs(ESPObjects) do
        if v:GetAttribute("ESP_Kind") == kind then
            pcall(function() v:Destroy() end)
            ESPObjects[k] = nil
        end
    end
end

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
                            local text = plr.Name .. " [" .. d .. "m]"
                            UpdateESPText(trp, text)
                            local bb = CreateESPBillboard(trp, text)
                            if bb then bb:SetAttribute("ESP_Kind", "Player") end
                        end
                    end
                end
            end)
        else ClearESPKind("Player") end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if State.ESPChest then
            pcall(function()
                local hrp = GetHRP(); if not hrp then return end
                for _, c in ipairs(GetSortedChests()) do
                    local d = math.floor((c.Position - hrp.Position).Magnitude)
                    local text = "Chest [" .. d .. "m]"
                    UpdateESPText(c, text)
                    local bb = CreateESPBillboard(c, text)
                    if bb then bb:SetAttribute("ESP_Kind", "Chest") end
                end
            end)
        else ClearESPKind("Chest") end
    end
end)

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
                            local text = c.Name .. " [" .. d .. "m]"
                            UpdateESPText(h, text)
                            local bb = CreateESPBillboard(h, text)
                            if bb then bb:SetAttribute("ESP_Kind", "Fruit") end
                        end
                    end
                end
            end)
        else ClearESPKind("Fruit") end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.ESPIsland then
            pcall(function()
                local hrp = GetHRP(); if not hrp then return end
                local locs = Workspace._WorldOrigin.Locations
                for _, c in ipairs(locs:GetChildren()) do
                    if c:IsA("BasePart") then
                        local d = math.floor((c.Position - hrp.Position).Magnitude)
                        local text = c.Name .. " [" .. d .. "m]"
                        UpdateESPText(c, text)
                        local bb = CreateESPBillboard(c, text)
                        if bb then bb:SetAttribute("ESP_Kind", "Island") end
                    end
                end
            end)
        else ClearESPKind("Island") end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.ESPMirage then
            pcall(function()
                local hrp = GetHRP(); if not hrp then return end
                local m = Workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island")
                if m and m:IsA("BasePart") then
                    local d = math.floor((m.Position - hrp.Position).Magnitude)
                    local text = "Mirage [" .. d .. "m]"
                    UpdateESPText(m, text)
                    local bb = CreateESPBillboard(m, text)
                    if bb then bb:SetAttribute("ESP_Kind", "Mirage") end
                end
            end)
        else ClearESPKind("Mirage") end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.ESPKitsune then
            pcall(function()
                local hrp = GetHRP(); if not hrp then return end
                local k = Workspace._WorldOrigin.Locations:FindFirstChild("Kitsune Island")
                if k and k:IsA("BasePart") then
                    local d = math.floor((k.Position - hrp.Position).Magnitude)
                    local text = "Kitsune [" .. d .. "m]"
                    UpdateESPText(k, text)
                    local bb = CreateESPBillboard(k, text)
                    if bb then bb:SetAttribute("ESP_Kind", "Kitsune") end
                end
            end)
        else ClearESPKind("Kitsune") end
    end
end)

--================================================================
-- MISC HANDLERS
--================================================================
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

task.spawn(function()
    while task.wait(1800) do
        if State.AntiFlag then
            pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
        end
    end
end)

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
-- UI BUILD — Outline Style
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
RegisterAccent(Stroke(Notif, THEME.Outline, 1.5, 0.15))

local main = Create("Frame", {
    Parent = gui,
    Size = UDim2.fromOffset(700, 540),
    Position = UDim2.new(0.5, -350, 0.5, -270),
    BackgroundColor3 = THEME.BG_Main,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    Visible = true,
    ClipsDescendants = true,
    ZIndex = 10,
})
Corner(main, 18)
RegisterAccent(Stroke(main, THEME.Outline, 2, 0.1))

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
    Text = "v1.1  •  13 Tabs",
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
RegisterAccent(Stroke(close, THEME.Outline, 1.5, 0.15))

Create("Frame", {
    Parent = header,
    Size = UDim2.new(1, -32, 0, 1),
    Position = UDim2.new(0, 16, 1, -2),
    BackgroundColor3 = THEME.Outline,
    BackgroundTransparency = 0.4,
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
    BackgroundTransparency = 0.2,
    Size = UDim2.new(0, 145, 1, 0),
    BorderSizePixel = 0, ZIndex = 15,
})
Corner(sidebar, 12)
RegisterAccent(Stroke(sidebar, THEME.Outline, 1.5, 0.2))

local tabList = Create("ScrollingFrame", {
    Parent = sidebar,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 6, 0, 6),
    Size = UDim2.new(1, -12, 1, -12),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = THEME.Outline,
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
    ScrollBarImageColor3 = THEME.Outline,
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
        ScrollBarImageColor3 = THEME.Outline,
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
        BackgroundTransparency = 0.3,
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
            TW(B, {BackgroundColor3 = THEME.BG_Hover, BackgroundTransparency = 0.1}, 0.15)
        end
    end)
    B.MouseLeave:Connect(function()
        if Tabs[name].Label.TextColor3 ~= THEME.Accent_Bright then
            TW(B, {BackgroundColor3 = THEME.BG_Secondary, BackgroundTransparency = 0.3}, 0.15)
        end
    end)
    return B
end

local function ShowTab(name)
    for pn, p in pairs(Pages) do p.Visible = (pn == name) end
    for tn, d in pairs(Tabs) do
        if tn == name then
            d.Button.BackgroundColor3 = THEME.BG_Active
            d.Button.BackgroundTransparency = 0.05
            d.Label.TextColor3 = THEME.Accent_Bright
            if d.Stroke then d.Stroke:Destroy() end
            d.Stroke = Stroke(d.Button, THEME.Outline, 1.5, 0.1)
            RegisterAccent(d.Stroke)
        else
            d.Button.BackgroundColor3 = THEME.BG_Secondary
            d.Button.BackgroundTransparency = 0.3
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
        BackgroundTransparency = 0.15,
        Size = UDim2.new(1, 0, 0, 38), Text = "",
        AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 100,
    })
    Corner(B, 9)
    RegisterAccent(Stroke(B, THEME.Outline, 1.2, 0.25))

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
    Stroke(Ind, THEME.Outline, 1, 0.4)
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
        BackgroundTransparency = 0.15,
        Size = UDim2.new(1, 0, 0, 38), Text = text,
        TextColor3 = THEME.Text_Primary, TextSize = 11,
        Font = Enum.Font.GothamMedium, AutoButtonColor = false,
        BorderSizePixel = 0, ZIndex = 100,
    })
    Corner(B, 9)
    RegisterAccent(Stroke(B, THEME.Outline, 1.2, 0.25))
    B.MouseEnter:Connect(function() TW(B, {BackgroundColor3 = THEME.BG_Hover, BackgroundTransparency = 0.05}, 0.15) end)
    B.MouseLeave:Connect(function() TW(B, {BackgroundColor3 = THEME.BG_Secondary, BackgroundTransparency = 0.15}, 0.15) end)
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
        BackgroundTransparency = 0.15,
        Size = UDim2.new(1, 0, 0, 38),
        BorderSizePixel = 0, ZIndex = 100,
    })
    Corner(Hold, 9)
    RegisterAccent(Stroke(Hold, THEME.Outline, 1.2, 0.25))
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
            BackgroundTransparency = 0.05,
            BorderSizePixel = 0, ZIndex = 999990,
        })
        Corner(Pop, 14)
        RegisterAccent(Stroke(Pop, THEME.Outline, 2, 0.1))
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
            ScrollBarImageColor3 = THEME.Outline,
            BorderSizePixel = 0, ZIndex = 999991,
        })
        local LL = Instance.new("UIListLayout")
        LL.Padding = UDim.new(0, 4)
        LL.SortOrder = Enum.SortOrder.LayoutOrder
        LL.Parent = LS
        for i, opt in ipairs(options) do
            local OB = Create("TextButton", {
                Parent = LS, BackgroundColor3 = THEME.BG_Tertiary,
                BackgroundTransparency = 0.15,
                Size = UDim2.new(1, -8, 0, 34),
                Position = UDim2.new(0, 4, 0, 0),
                Text = opt, TextColor3 = THEME.Text_Primary,
                TextSize = 12, Font = Enum.Font.GothamMedium,
                AutoButtonColor = false, BorderSizePixel = 0,
                LayoutOrder = i, ZIndex = 999992,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            Corner(OB, 7)
            Stroke(OB, THEME.Outline, 1, 0.3)
            local pad = Instance.new("UIPadding")
            pad.PaddingLeft = UDim.new(0, 12); pad.Parent = OB
            OB.MouseEnter:Connect(function() TW(OB, {BackgroundColor3 = THEME.BG_Hover, BackgroundTransparency = 0.05}, 0.1) end)
            OB.MouseLeave:Connect(function() TW(OB, {BackgroundColor3 = THEME.BG_Tertiary, BackgroundTransparency = 0.15}, 0.1) end)
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
        BackgroundTransparency = 0.15,
        Size = UDim2.new(1, 0, 0, 58),
        BorderSizePixel = 0, ZIndex = 100,
    })
    Corner(Hold, 9)
    RegisterAccent(Stroke(Hold, THEME.Outline, 1.2, 0.25))
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
    Stroke(VH, THEME.Outline, 1, 0.3)
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
    Stroke(TB, THEME.Outline, 1, 0.3)
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
    Stroke(Knob, THEME.Outline, 1.5, 0)
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
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, sz or 28),
        Text = text, TextColor3 = THEME.Accent_Bright,
        TextSize = 10, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        BorderSizePixel = 0, ZIndex = 100,
    })
    Corner(L, 9)
    RegisterAccent(Stroke(L, THEME.Outline, 1.2, 0.2))
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 12)
    pad.Parent = L
    return L
end

--================================================================
-- NOTIFICATION
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
-- ACCENT ANIMATION
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
-- TABS (13)
--================================================================
local TabDefs = {
    {"Home & Status"},{"Farm"},{"Pvp [Combat]"},{"Quest & Item"},{"Stats"},
    {"Sea"},{"Fishing"},{"Race"},{"Fruit & Raid"},{"Shop"},
    {"Teleport"},{"Visual"},{"MISC"}
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
local MiscPage      = CreatePage("MISC")

--================================================================
-- HOME & STATUS
--================================================================
CreateLabel(HomePage, "SYSX HUB v1.1", 32)
CreateLabel(HomePage,
    "13 Tabs | All Setting in MISC\n" ..
    "Home & Status • Farm • Pvp [Combat]\n" ..
    "Quest & Item • Stats • Sea • Fishing\n" ..
    "Race • Fruit & Raid • Shop • Teleport\n" ..
    "Visual • MISC", 180)
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
CreateLabel(FarmPage, "Level Farming", 26)
CreateToggle(FarmPage, "Auto Farm Level", false, function(s) State.AutoFarm = s end)
CreateToggle(FarmPage, "Auto Farm Nearest", false, function(s) State.AutoFarmNearest = s end)
CreateToggle(FarmPage, "Auto Farm Mastery", false, function(s) State.AutoFarmMastery = s end)

CreateLabel(FarmPage, "Collection", 26)
CreateToggle(FarmPage, "Auto Collect Chest", false, function(s)
    State.AutoCollectChest = s
    if s then ChestData.FirstRun = true; ChestData.Unchecked = {} end
end)
CreateToggle(FarmPage, "Auto Farm Bones", false, function(s) State.AutoFarmBones = s end)
CreateToggle(FarmPage, "Auto Farm Wood Planks", false, function(s) State.AutoFarmWoodPlanks = s end)
CreateToggle(FarmPage, "Auto Treasure Chest", false, function(s) State.AutoTreasureChest = s end)
CreateToggle(FarmPage, "Auto Collect Drops", false, function(s) State.AutoCollectDrops = s end)
CreateToggle(FarmPage, "Auto Farmer Drops", false, function(s) State.AutoFarmerDrops = s end)

CreateDropdown(FarmPage, "Select Material",
    {"Angel Wings","Leather + Scrap Metal","Magma Ore","Fish Tail"},
    function(o) State.SelectedMaterial = o end)
CreateToggle(FarmPage, "Auto Farm Material", false, function(s) State.AutoFarmMaterial = s end)

CreateLabel(FarmPage, "Boss Farm", 26)
CreateDropdown(FarmPage, "Select Boss",
    {"Darkbeard","Cursed Captain","rip_indra True Form"},
    function(o) State.SelectedBoss = o end)
CreateToggle(FarmPage, "Auto Attack Boss", false, function(s) State.AutoAttackBoss = s end)
CreateToggle(FarmPage, "Auto Attack All Boss", false, function(s) State.AutoAttackAllBoss = s end)
CreateToggle(FarmPage, "Auto Tyrant of the Skies", false, function(s) State.AutoTyrant = s end)
CreateToggle(FarmPage, "Auto Citizen Quest", false, function(s) State.AutoCitizenQuest = s end)
CreateToggle(FarmPage, "Auto Dark Fragment", false, function(s) State.AutoDarkFragment = s end)
CreateToggle(FarmPage, "Auto Sweet Chalice", false, function(s) State.AutoSweetChalice = s end)

CreateLabel(FarmPage, "Farm Config", 26)
CreateDropdown(FarmPage, "Select Weapon",
    {"Melee","Sword","Blox Fruit","Gun"},
    function(o) State.SelectedWeapon = o end)
CreateToggle(FarmPage, "Bring Mob", true, function(s) State.BringMob = s end)
CreateSlider(FarmPage, "Bring Mob Radius", 50, 1000, 300, function(v) State.BringRange = v end)
CreateSlider(FarmPage, "Bring Mob Count", 1, 10, 2, function(v) State.BringCount = v end)
CreateSlider(FarmPage, "Farm Speed", 50, 500, 200, function(v) getgenv().FarmSpeed = v end)
CreateToggle(FarmPage, "Auto Haki", true, function(s) State.AutoHaki = s end)
CreateToggle(FarmPage, "Auto Ken", false, function(s) State.AutoKen = s end)

--================================================================
-- PVP [COMBAT]
--================================================================
CreateLabel(PvpPage, "PvP Combat", 26)
CreateToggle(PvpPage, "Auto Aimbot / Lock Aim", false, function(s) State.AutoAimbot = s end)
CreateToggle(PvpPage, "Auto Dodge Skill", false, function(s) State.AutoDodgeSkill = s end)

local pvpPlayers = {"None"}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= player then table.insert(pvpPlayers, p.Name) end
end
CreateDropdown(PvpPage, "Select Player PVP", pvpPlayers, function(o) State.SelectedPlayer = o end)
CreateToggle(PvpPage, "Teleport Player", false, function(s) State.TeleportPlayer = s end)

CreateDropdown(PvpPage, "Select Method Aimbot",
    {"Select Player","Target nearest Player"},
    function(o) State.MethodAimbot = o end)
CreateButton(PvpPage, "Refresh Player", function() Notify("Rejoin to refresh player list") end)

--================================================================
-- QUEST & ITEM
--================================================================
CreateLabel(QuestPage, "Sword Quest", 26)
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

CreateLabel(QuestPage, "Gun Quest", 26)
CreateToggle(QuestPage, "Auto Acidum Rifle Quest", false, function(s) State.AutoAcidumRifle = s end)
CreateToggle(QuestPage, "Auto Venom Bow Quest", false, function(s) State.AutoVenomBow = s end)
CreateToggle(QuestPage, "Auto Soul Guitar Quest", false, function(s) State.AutoSoulGuitar = s end)
CreateToggle(QuestPage, "Auto Dragon Storm Quest", false, function(s) State.AutoDragonStorm = s end)

CreateLabel(QuestPage, "Special Item Quest", 26)
CreateToggle(QuestPage, "Auto Rengoku Quest", false, function(s) State.AutoRengoku = s end)
CreateToggle(QuestPage, "Auto Insict V2 Quest", false, function(s) State.AutoInsictV2 = s end)
CreateToggle(QuestPage, "Auto Rainbow Saviour Quest", false, function(s) State.AutoRainbowSaviour = s end)
CreateToggle(QuestPage, "Auto Dark Blade V2 Quest", false, function(s) State.AutoDarkBladeV2 = s end)
CreateToggle(QuestPage, "Auto Dark Blade V3 Quest", false, function(s) State.AutoDarkBladeV3 = s end)

CreateLabel(QuestPage, "Puzzle Quest", 26)
CreateToggle(QuestPage, "Auto Bartilo Quest", false, function(s) State.AutoBartilo = s end)
CreateToggle(QuestPage, "Auto Second Sea Puzzle", false, function(s) State.AutoSecondSea = s end)
CreateToggle(QuestPage, "Auto Third Sea Puzzle", false, function(s) State.AutoThirdSea = s end)
CreateToggle(QuestPage, "Auto Dojo Quest", false, function(s) State.AutoDojo = s end)

CreateLabel(QuestPage, "Boss Item Quest", 26)
CreateToggle(QuestPage, "Auto Cake Prince", false, function(s) State.AutoCakePrince = s end)
CreateToggle(QuestPage, "Auto Dough King", false, function(s) State.AutoDoughKing = s end)
CreateToggle(QuestPage, "Auto Kill Elite Hunter", false, function(s) State.AutoEliteHunter = s end)
CreateToggle(QuestPage, "Auto Soul Reaper", false, function(s) State.AutoSoulReaper = s end)
CreateToggle(QuestPage, "Auto Kill Rip Indra", false, function(s) State.AutoKillRipIndra = s end)
CreateToggle(QuestPage, "Auto Factory", false, function(s) State.AutoFactory = s end)
CreateToggle(QuestPage, "Auto Pirates Sea", false, function(s) State.AutoPiratesSea = s end)
CreateToggle(QuestPage, "Auto Dragon Hunter Quest", false, function(s) State.AutoDragonHunter = s end)

CreateLabel(QuestPage, "Collection Quest", 26)
CreateToggle(QuestPage, "Auto Collect Berry", false, function(s) State.AutoCollectBerry = s end)

--================================================================
-- STATS
--================================================================
CreateLabel(StatsPage, "Auto Stats", 26)
CreateDropdown(StatsPage, "Select Stat Priority",
    {"Melee","Defense","Sword","Gun","Blox Fruit"},
    function(o) State.SelectedStat = o end)
CreateToggle(StatsPage, "Auto Stat Point", false, function(s) State.AutoStatPoint = s end)
CreateSlider(StatsPage, "Points Per Click", 1, 50, 1, function(v) State.PointsPerClick = v end)
CreateToggle(StatsPage, "Auto Melee", false, function(s) State.StatMelee = s end)
CreateToggle(StatsPage, "Auto Defense", false, function(s) State.StatDefense = s end)
CreateToggle(StatsPage, "Auto Sword", false, function(s) State.StatSword = s end)
CreateToggle(StatsPage, "Auto Gun", false, function(s) State.StatGun = s end)
CreateToggle(StatsPage, "Auto Blox Fruit", false, function(s) State.StatFruit = s end)

--================================================================
-- SEA
--================================================================
CreateLabel(SeaPage, "Sea Config", 26)
CreateDropdown(SeaPage, "Select Boat",
    {"PirateBrigade","PirateGrandBrigade","Beast Hunter"},
    function(o) State.SelectedBoat = o end)
CreateDropdown(SeaPage, "Danger Level",
    {"1","2","3","4","5","6","infinite"},
    function(o) State.DangerLevel = o end)
CreateDropdown(SeaPage, "Combat Weapon",
    {"Melee","Blox Fruit","Gun","Sword","Random"},
    function(o) State.CombatWeapon = o end)

-- Sea to Sea (baru)
CreateLabel(SeaPage, "Sea to Sea", 26)
CreateToggle(SeaPage, "Auto Travel to Sea 1", false, function(s)
    State.AutoTravelSea1 = s
    if s then
        pcall(function()
            if GetCurrentSea() ~= 1 then
                CommF_:InvokeServer("TravelMain")
                Notify("Traveling to Sea 1")
            else
                Notify("Already in Sea 1")
                State.AutoTravelSea1 = false
            end
        end)
    end
end)
CreateToggle(SeaPage, "Auto Travel to Sea 2", false, function(s)
    State.AutoTravelSea2 = s
    if s then
        pcall(function()
            if GetCurrentSea() ~= 2 then
                CommF_:InvokeServer("TravelDressrosa")
                Notify("Traveling to Sea 2")
            else
                Notify("Already in Sea 2")
                State.AutoTravelSea2 = false
            end
        end)
    end
end)
CreateToggle(SeaPage, "Auto Travel to Sea 3", false, function(s)
    State.AutoTravelSea3 = s
    if s then
        pcall(function()
            if GetCurrentSea() ~= 3 then
                CommF_:InvokeServer("TravelZou")
                Notify("Traveling to Sea 3")
            else
                Notify("Already in Sea 3")
                State.AutoTravelSea3 = false
            end
        end)
    end
end)
CreateButton(SeaPage, "Refresh Sea Detection", function()
    local s = GetCurrentSea()
    Notify("Current Sea: " .. s)
end)

CreateLabel(SeaPage, "Sea Event", 26)
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

CreateLabel(SeaPage, "Kitsune Island", 26)
CreateToggle(SeaPage, "Auto Summon Kitsune Island", false, function(s) State.AutoSummonKitsune = s end)
CreateToggle(SeaPage, "Tween to Kitsune Island", false, function(s) State.TweenKitsune = s end)
CreateToggle(SeaPage, "Auto Collect Azure Ember", false, function(s) State.AutoCollectEmber = s end)
CreateToggle(SeaPage, "Auto Trade Azure Ember", false, function(s) State.AutoTradeEmber = s end)

CreateLabel(SeaPage, "Leviathan / Frozen", 26)
CreateToggle(SeaPage, "Tween to Frozen Dimension", false, function(s) State.TweenFrozenDimension = s end)
CreateToggle(SeaPage, "Auto Find Leviathan", false, function(s) State.AutoFindLevi = s end)
CreateToggle(SeaPage, "Auto Attack Leviathan", false, function(s) State.AutoAttackLevi = s end)
CreateToggle(SeaPage, "Auto Attack Levi Segment", false, function(s) State.AutoAttackLeviSeg = s end)
CreateToggle(SeaPage, "Auto Attack Levi Tail", false, function(s) State.AutoAttackLeviTail = s end)
CreateToggle(SeaPage, "Auto Buy Boat Beast Hunter", false, function(s) State.AutoBuyBoatBH = s end)
CreateToggle(SeaPage, "Auto Start Leviathan", false, function(s) State.AutoStartLevi = s end)
CreateToggle(SeaPage, "Auto Buy Spy", false, function(s) State.AutoBuySpy = s end)
CreateToggle(SeaPage, "Auto Destroy IDK", false, function(s) State.AutoDestroyIDK = s end)

CreateLabel(SeaPage, "Mirage Island", 26)
CreateToggle(SeaPage, "Auto Summon Mirage Island", false, function(s) State.AutoSummonMirage = s end)
CreateToggle(SeaPage, "Tween to Mirage Island", false, function(s) State.TweenMirage = s end)
CreateToggle(SeaPage, "Auto Find Mirage", false, function(s) State.AutoFindMirage = s end)

CreateLabel(SeaPage, "Prehistoric Island", 26)
CreateToggle(SeaPage, "Auto Summon Prehistoric Island", false, function(s) State.AutoSummonPre = s end)
CreateToggle(SeaPage, "Tween To Prehistoric Island", false, function(s) State.TweenPre = s end)
CreateToggle(SeaPage, "Auto Find Prehistoric Island", false, function(s) State.AutoFindPre = s end)
CreateToggle(SeaPage, "Auto Event Prehistoric Island", false, function(s) State.AutoEventPre = s end)
CreateToggle(SeaPage, "Fully Event Prehistoric Island", false, function(s) State.FullyEventPre = s end)
CreateToggle(SeaPage, "Auto Collect Bone", false, function(s) State.AutoCollectBone = s end)
CreateToggle(SeaPage, "Auto Collect Egg", false, function(s) State.AutoCollectEgg = s end)

CreateLabel(SeaPage, "Sea Craft", 26)
CreateToggle(SeaPage, "Auto Shark Tooth Necklace", false, function(s) State.AutoToothNecklace = s end)
CreateToggle(SeaPage, "Auto Terror Jaw", false, function(s) State.AutoTerrorJaw = s end)
CreateToggle(SeaPage, "Auto Monster Magnet", false, function(s) State.AutoMonsterMagnet = s end)
CreateToggle(SeaPage, "Auto Shark Anchor Craft", false, function(s) State.AutoSharkAnchorCraft = s end)
CreateToggle(SeaPage, "Auto Crafting Volcanic Magnet", false, function(s) State.AutoCraftVolcanic = s end)

CreateLabel(SeaPage, "Boat Setting", 26)
CreateToggle(SeaPage, "Fly Boat", false, function(s) State.FlyBoat = s end)
CreateToggle(SeaPage, "Drive Boat To Tiki", false, function(s) State.DriveBoatTiki = s end)
CreateToggle(SeaPage, "Drive Boat To Hydra", false, function(s) State.DriveBoatHydra = s end)
CreateSlider(SeaPage, "Value Speed Boat", 50, 500, 200, function(v) State.SpeedBoat = v end)
CreateSlider(SeaPage, "Value Speed Tween Boat", 50, 2000, 350, function(v) State.SpeedTweenBoat = v end)
CreateSlider(SeaPage, "Value Speed Fly Boat", 0, 10, 3, function(v) State.SpeedFlyBoat = v end)

--================================================================
-- FISHING
--================================================================
CreateLabel(FishingPage, "Fishing", 26)
CreateDropdown(FishingPage, "Select Bait",
    {"Basic Bait","Good Bait","Excellent Bait"},
    function(o) State.SelectedBait = o end)
CreateToggle(FishingPage, "Auto Equip Rod", false, function(s) State.AutoEquipRod = s end)
CreateToggle(FishingPage, "Auto Fishing", false, function(s) State.AutoFishing = s end)
CreateToggle(FishingPage, "Auto Sell Fish", false, function(s) State.AutoSellFish = s end)
CreateToggle(FishingPage, "Auto Sell Corrupted Fish", false, function(s) State.AutoSellCorruptedFish = s end)
CreateButton(FishingPage, "Save Position Fishing", function()
    local hrp = GetHRP()
    if not hrp then return end
    getgenv().FishingPosition = hrp.CFrame
    Notify("Fishing position saved")
end)

--================================================================
-- RACE
--================================================================
CreateLabel(RacePage, "Race V2/V3", 26)
CreateToggle(RacePage, "Auto Race V2", false, function(s) State.AutoRaceV2 = s end)
CreateToggle(RacePage, "Auto Race V3", false, function(s) State.AutoRaceV3 = s end)
CreateToggle(RacePage, "Auto Get Cyborg", false, function(s) State.AutoGetCyborg = s end)
CreateToggle(RacePage, "Auto Get Ghoul", false, function(s) State.AutoGetGhoul = s end)

CreateLabel(RacePage, "Race V4 Trial", 26)
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

-- Race V4 (baru)
CreateLabel(RacePage, "Race V4 Options", 26)
CreateToggle(RacePage, "Auto Pull Lever V4", false, function(s)
    State.AutoPullLeverV4 = s
    if s then
        task.spawn(function()
            while State.AutoPullLeverV4 do
                task.wait(1)
                pcall(function()
                    for _, d in pairs(Workspace.Map["Temple of Time"]:GetDescendants()) do
                        if d.Name == "ProximityPrompt" then
                            pcall(function() fireproximityprompt(d, math.huge) end)
                        end
                    end
                end)
            end
        end)
    end
end)
CreateToggle(RacePage, "Auto Trial V4", false, function(s)
    State.AutoTrialV4 = s
    if s then
        task.spawn(function()
            while State.AutoTrialV4 do
                task.wait(1)
                pcall(function()
                    local hrp = GetHRP()
                    if hrp then
                        hrp.CFrame = CFrame.new(28286.35, 14895.30, 102.62)
                        local ms = RS:FindFirstChild("MapStash")
                        local tot = ms and ms:FindFirstChild("Temple of Time")
                        if tot then tot.Parent = Workspace.Map end
                    end
                end)
            end
        end)
    end
end)
CreateToggle(RacePage, "Auto Finish Train V4", false, function(s)
    State.AutoFinishTrainV4 = s
    if s then
        task.spawn(function()
            while State.AutoFinishTrainV4 do
                task.wait(1)
                pcall(function()
                    local mobs = {"Reborn Skeleton","Living Zombie","Demonic Soul","Posessed Mummy"}
                    local enemy = FindEnemy(mobs, 99999)
                    if enemy then
                        CombatController.Attack({enemy.Name})
                    else
                        local sp = FindSpawnPart(mobs[1], true)
                        if sp then
                            FarmTeleport(sp.CFrame * CFrame.new(0, 60, 0), getgenv().FarmSpeed, 25)
                        end
                    end
                end)
            end
        end)
    end
end)

CreateLabel(RacePage, "Temple Teleport", 26)
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

CreateLabel(RacePage, "Gear V4", 26)
CreateDropdown(RacePage, "Select Gear V4", {"Alpha","Omega"}, function(o) State.SelectedGearV4 = o end)
CreateToggle(RacePage, "Auto Buy Gear V4", false, function(s) State.AutoBuyGearV4 = s end)
CreateToggle(RacePage, "Auto Choose Gears", false, function(s) State.AutoChooseGears = s end)
CreateToggle(RacePage, "Auto Race Draco", false, function(s) State.AutoRaceDraco = s end)

--================================================================
-- FRUIT & RAID
--================================================================
CreateLabel(FruitRaidPage, "Fruit", 26)
CreateToggle(FruitRaidPage, "Auto Store Fruit", false, function(s) State.AutoStoreFruit = s end)
CreateToggle(FruitRaidPage, "Auto Buy Fruit (Cousin)", false, function(s) State.AutoBuyFruit = s end)

CreateDropdown(FruitRaidPage, "Select Sniper Fruit",
    {"Flame","Ice","Quake","Light","Dark"},
    function(o) State.SelectedSniperFruit = o end)
CreateToggle(FruitRaidPage, "Auto Buy Sniper Fruit", false, function(s) State.AutoBuySniper = s end)

CreateToggle(FruitRaidPage, "Auto Find Fruit", false, function(s) State.AutoFindFruit = s end)
CreateToggle(FruitRaidPage, "Auto Random Fruit", false, function(s) State.AutoRandomFruit = s end)

CreateLabel(FruitRaidPage, "Raid", 26)
CreateDropdown(FruitRaidPage, "Select Raid",
    {"Flame","Ice","Sand","Dark","Light","Magma","Quake","Buddha","Love","Spider","Sound","Phoenix","Portal","Rumble","Pain","Blizzard","Gravity"},
    function(o) State.SelectedRaid = o end)
CreateToggle(FruitRaidPage, "Auto Raid", false, function(s) State.AutoRaid = s end)

CreateDropdown(FruitRaidPage, "Select Chip",
    {"Flame","Ice","Sand","Dark","Light","Magma","Quake","Buddha"},
    function(o) State.SelectedChip = o end)
CreateToggle(FruitRaidPage, "Auto Buy Chip", false, function(s) State.AutoBuyChip = s end)
CreateToggle(FruitRaidPage, "Auto Awaken Fruit", false, function(s) State.AutoAwakenFruit = s end)

--================================================================
-- SHOP
--================================================================
CreateLabel(ShopPage, "Fighting Styles", 26)
CreateDropdown(ShopPage, "Select Melee",
    {"Black Leg","Electro","Fishman Karate","Dragon Claw","Superhuman","Death Step","Sharkman Karate","Electric Claw","Dragon Talon","Godhuman","Sanguine Art"},
    function(o) State.SelectedMelee = o end)
CreateToggle(ShopPage, "Auto Buy Melee", false, function(s)
    if State.SelectedMelee then
        State.AutoBuyMelee[State.SelectedMelee] = s
    end
end)
CreateToggle(ShopPage, "Auto Fully Melees", false, function(s) State.AutoFullyMelees = s end)

CreateLabel(ShopPage, "Abilities", 26)
CreateButton(ShopPage, "Buy Geppo", function() CommF_:InvokeServer("BuyHaki", "Geppo") Notify("Buy Geppo") end)
CreateButton(ShopPage, "Buy Buso", function() CommF_:InvokeServer("BuyHaki", "Buso") Notify("Buy Buso") end)
CreateButton(ShopPage, "Buy Soru", function() CommF_:InvokeServer("BuyHaki", "Soru") Notify("Buy Soru") end)
CreateButton(ShopPage, "Buy Ken", function() CommF_:InvokeServer("KenTalk", "Buy") Notify("Buy Ken") end)

CreateLabel(ShopPage, "Sword", 26)
for _, sw in ipairs({"Katana","Cutlass","Dual Katana","Iron Mace","Triple Katana","Pipe","Dual-Headed Blade","Soul Cane","Bisento"}) do
    CreateButton(ShopPage, "Buy " .. sw, function() TryBuy("BuyItem", sw) end)
end

CreateLabel(ShopPage, "Gun", 26)
for _, gn in ipairs({"Musket","Slingshot","Flintlock","Refined Slingshot","Refined Flintlock","Cannon"}) do
    CreateButton(ShopPage, "Buy " .. gn, function() TryBuy("BuyItem", gn) end)
end
CreateButton(ShopPage, "Buy Kabucha", function()
    TryBuy("BlackbeardReward", "Slingshot", "1")
    task.wait(0.3)
    TryBuy("BlackbeardReward", "Slingshot", "2")
end)

CreateLabel(ShopPage, "Accessory", 26)
for _, ac in ipairs({"Black Cape","Swordsman Hat","Tomoe Ring"}) do
    CreateButton(ShopPage, "Buy " .. ac, function() TryBuy("BuyItem", ac) end)
end

CreateLabel(ShopPage, "Race", 26)
CreateButton(ShopPage, "Buy Ghoul Race", function()
    TryBuy("Ectoplasm", "BuyCheck", 4)
    task.wait(0.3)
    TryBuy("Ectoplasm", "Change", 4)
end)
CreateButton(ShopPage, "Buy Cyborg Race", function() TryBuy("CyborgTrainer", "Buy") end)

CreateLabel(ShopPage, "Misc", 26)
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
CreateLabel(TeleportPage, "Sea Travel", 26)
CreateButton(TeleportPage, "Travel to Sea 1", function() CommF_:InvokeServer("TravelMain") Notify("Traveling Sea 1") end)
CreateButton(TeleportPage, "Travel to Sea 2", function() CommF_:InvokeServer("TravelDressrosa") Notify("Traveling Sea 2") end)
CreateButton(TeleportPage, "Travel to Sea 3", function() CommF_:InvokeServer("TravelZou") Notify("Traveling Sea 3") end)

CreateLabel(TeleportPage, "Island Teleport", 26)

local IslandPositions = {
    [1] = {
        ["Start Island"]        = Vector3.new(1071.28, 16.30, 1426.86),
        ["Marine Start"]        = Vector3.new(-2573.33, 6.88, 2046.99),
        ["Middle Town"]         = Vector3.new(-655.82, 7.88, 1436.67),
        ["Jungle"]              = Vector3.new(-1249.77, 11.88, 341.35),
        ["Pirate Village"]      = Vector3.new(-1122.34, 4.78, 3855.91),
        ["Desert"]              = Vector3.new(1094.14, 6.47, 4192.88),
        ["Frozen Village"]      = Vector3.new(1198.00, 27.00, -1211.73),
        ["Marine Fortress"]     = Vector3.new(-4505.37, 20.68, 4260.55),
        ["Colosseum"]           = Vector3.new(-1428.35, 7.38, -3014.37),
        ["Sky 1"]               = Vector3.new(-4970.21, 717.70, -2622.35),
        ["Sky 2"]               = Vector3.new(-4813.02, 903.70, -1912.69),
        ["Sky 3"]               = Vector3.new(-7952.31, 5545.52, -320.70),
        ["Prison"]              = Vector3.new(4854.16, 5.68, 740.19),
        ["Magma Village"]       = Vector3.new(-5231.75, 8.61, 8467.87),
        ["Underwater City"]     = Vector3.new(61163.85, 11.77, 1819.78),
        ["Fountain City"]       = Vector3.new(5132.71, 4.53, 4037.85),
        ["Cyborg House"]        = Vector3.new(6262.72, 71.30, 3998.23),
        ["Shanks Room"]         = Vector3.new(-1442.16, 29.87, -28.35),
        ["Mob Island"]          = Vector3.new(-2850.20, 7.39, 5354.99),
    },
    [2] = {
        ["First Spot"]          = Vector3.new(82.94, 18.07, 2834.98),
        ["Flamingo Mansion"]    = Vector3.new(-390.09, 331.88, 673.46),
        ["Flamingo Room"]       = Vector3.new(2302.19, 15.17, 663.81),
        ["Green Zone"]          = Vector3.new(-2372.14, 72.99, -3166.51),
        ["Cafe"]                = Vector3.new(-385.25, 73.04, 297.38),
        ["Factory"]             = Vector3.new(430.42, 210.01, -432.50),
        ["Colosseum"]           = Vector3.new(-1836.58, 44.58, 1360.30),
        ["Graveyard Island"]    = Vector3.new(-5571.84, 195.18, -795.43),
        ["Graveyard Shore"]     = Vector3.new(-5931.77, 5.19, -1189.69),
        ["Snow Mountain"]       = Vector3.new(1384.68, 453.56, -4990.09),
        ["Hot and Cold"]        = Vector3.new(-6026.96, 14.74, -5071.96),
        ["Magma Side"]          = Vector3.new(-5478.39, 15.97, -5246.91),
        ["Cursed Ship"]         = Vector3.new(902.05, 124.75, 33071.81),
        ["Ice Castle"]          = Vector3.new(5400.40, 28.21, -6236.99),
        ["Forgotten Island"]    = Vector3.new(-3043.31, 238.88, -10191.57),
        ["Usoapp Island"]       = Vector3.new(4748.78, 8.35, 2849.57),
        ["Raid Lab"]            = Vector3.new(-5554.95, 329.07, -5930.31),
        ["Mini Sky"]            = Vector3.new(-260.35, 49325.70, -35259.30),
    },
    [3] = {
        ["Port Town"]           = Vector3.new(-287, 30, 5388),
        ["Hydra Island"]        = Vector3.new(3399.32, 72.41, 1572.99),
        ["Secret Temple"]       = Vector3.new(5247, 7, 1097),
        ["Hydra House"]         = Vector3.new(5245, 602, 251),
        ["Great Tree"]          = Vector3.new(2443, 36, -6573),
        ["Castle on the Sea"]   = Vector3.new(-5500, 314, -2855),
        ["Mansion"]             = Vector3.new(-12548, 337, -7481),
        ["Floating Turtle"]     = Vector3.new(-10016, 332, -8326),
        ["Haunted Castle"]      = Vector3.new(-9509.34, 142.13, 5535.16),
        ["Peanut Island"]       = Vector3.new(-2131, 38, -10106),
        ["Ice Cream Island"]    = Vector3.new(-950, 59, -10907),
        ["Cake Island"]         = Vector3.new(-1762, 38, -11878),
        ["Tiki Outpost"]        = Vector3.new(-16204.08, 9.08, 479.22),
        ["Submerged Island"]    = Vector3.new(11427, -2155, 9730),
        ["Sealed Cavern"]       = Vector3.new(10437.38, -2227.38, 9670.98),
    },
}

local function GetCurrentSeaNum()
    if World1 then return 1 end
    if World2 then return 2 end
    if World3 then return 3 end
    return 1
end

local function GetIslandListForSea(sea)
    local list = {}
    for name, _ in pairs(IslandPositions[sea] or {}) do
        table.insert(list, name)
    end
    table.sort(list)
    return list
end

local CurrentSea = GetCurrentSeaNum()
CreateDropdown(TeleportPage, "Select Island",
    GetIslandListForSea(CurrentSea),
    function(o) State.SelectedIsland = o end)
CreateButton(TeleportPage, "Tween To Island", function()
    local sel = State.SelectedIsland
    if not sel then Notify("Select island first") return end
    local pos = IslandPositions[CurrentSea] and IslandPositions[CurrentSea][sel]
    if pos then
        CommF_:InvokeServer("requestEntrance", pos)
        Notify("Traveling to " .. sel)
    else
        Notify("Island not found in this sea")
    end
end)
CreateButton(TeleportPage, "Refresh Island List", function()
    CurrentSea = GetCurrentSeaNum()
    Notify("Refreshed island list for Sea " .. CurrentSea)
end)

--================================================================
-- VISUAL
--================================================================
CreateLabel(VisualPage, "ESP", 26)
CreateToggle(VisualPage, "ESP Player", false, function(s) State.ESPPlayer = s end)
CreateToggle(VisualPage, "ESP Chest", false, function(s) State.ESPChest = s end)
CreateToggle(VisualPage, "ESP Devil Fruit", false, function(s) State.ESPDevilFruit = s end)
CreateToggle(VisualPage, "ESP Island", false, function(s) State.ESPIsland = s end)
CreateToggle(VisualPage, "ESP Mirage Island", false, function(s) State.ESPMirage = s end)
CreateToggle(VisualPage, "ESP Kitsune Island", false, function(s) State.ESPKitsune = s end)

CreateLabel(VisualPage, "Remove UI", 26)
CreateToggle(VisualPage, "Remove Damage", false, function(s) State.RemoveDamage = s end)
CreateToggle(VisualPage, "Remove Notifications", false, function(s) State.RemoveNotifications = s end)
CreateToggle(VisualPage, "Boost FPS", false, function(s) State.BoostFPS = s end)
CreateToggle(VisualPage, "Black Screen", false, function(s) State.BlackScreen = s end)
CreateToggle(VisualPage, "White Screen", false, function(s) State.WhiteScreen = s end)

--================================================================
-- MISC (All Setting)
--================================================================
CreateLabel(MiscPage, "Server & Hop", 26)
CreateToggle(MiscPage, "Auto Hop (after 1h)", false, function(s) State.AutoHop1h = s end)
CreateToggle(MiscPage, "Hop When Idle", false, function(s) State.HopWhenIdle = s end)
CreateButton(MiscPage, "Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId, player)
end)
CreateLabel(MiscPage, "JobId: " .. game.JobId, 30)

CreateLabel(MiscPage, "Config", 26)
CreateButton(MiscPage, "Reset Config", function()
    Notify("Config reset (rejoin to apply)")
end)

CreateLabel(MiscPage, "Webhook", 26)
local WebhookBox = Create("TextBox", {
    Parent = MiscPage,
    BackgroundColor3 = THEME.BG_Secondary,
    BackgroundTransparency = 0.15,
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
RegisterAccent(Stroke(WebhookBox, THEME.Outline, 1.2, 0.25))
WebhookBox.FocusLost:Connect(function()
    if WebhookBox.Text ~= "" and WebhookBox.Text:find("discord.com/api/webhooks") then
        State.WebhookURL = WebhookBox.Text
        Notify("Webhook URL saved")
    else
        Notify("Invalid Webhook URL")
    end
end)
CreateToggle(MiscPage, "Webhook Error Report", true, function(s) State.WebhookReport = s end)
CreateToggle(MiscPage, "Noti Profile", false, function(s) State.NotiProfile = s end)
CreateToggle(MiscPage, "Ping Discord", false, function(s) State.PingDiscord = s end)

CreateLabel(MiscPage, "Local Player", 26)
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
CreateToggle(MiscPage, "Walk On Water", false, function(s)
    State.WalkOnWater = s
    local water = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("WaterBase-Plane")
    if water then water.Size = s and Vector3.new(1000,113,1000) or Vector3.new(1000,80,1000) end
end)
CreateToggle(MiscPage, "No Clip", false, function(s) State.NoClip = s end)
CreateToggle(MiscPage, "Anti-AFK", true, function(s) State.AntiAFK = s end)
CreateToggle(MiscPage, "Auto Reset Character", false, function(s) State.AutoResetChar = s end)
CreateToggle(MiscPage, "Fast Attack", true, function(s) State.FastAttackMisc = s end)

CreateLabel(MiscPage, "Screen", 26)
CreateSlider(MiscPage, "FPS Cap", 15, 240, 60, function(v)
    State.FPScap = v
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

CreateLabel(MiscPage, "Utility", 26)
CreateToggle(MiscPage, "Anti-Flag", false, function(s) State.AntiFlag = s end)
CreateToggle(MiscPage, "Anti-Kick", true, function(s) State.AntiKick = s end)
CreateToggle(MiscPage, "Kick Recovery", true, function(s) State.KickRecovery = s end)
CreateButton(MiscPage, "Join Pirates", function() CommF_:InvokeServer("SetTeam", "Pirates") Notify("Joined Pirates") end)
CreateButton(MiscPage, "Join Marines", function() CommF_:InvokeServer("SetTeam", "Marines") Notify("Joined Marines") end)
CreateToggle(MiscPage, "Auto Exp Redeem", false, function(s) State.AutoExpRedeem = s end)

CreateLabel(MiscPage, "Open UI", 26)
CreateButton(MiscPage, "Open Fruit Shop", function()
    pcall(function() require(RS.Controllers.UI.FruitShop):Open() end)
end)
CreateButton(MiscPage, "Open Titles", function()
    local titlesMenu = playerGui:FindFirstChild("TitlesMenu")
    if titlesMenu and titlesMenu:FindFirstChild("Open") then
        titlesMenu.Open:Fire()
    end
end)
CreateButton(MiscPage, "Open Haki Color", function()
    pcall(function() playerGui.Main.Colors.Visible = true end)
end)

--================================================================
-- MAIN LOOPS
--================================================================
task.spawn(function()
    while task.wait(0.05) do
        if State.FastAttackMisc and IsAlive() then pcall(AttackNoCoolDown) end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        pcall(function() if State.AutoHaki then AutoHaki() end end)
    end
end)

-- Auto Farm Level (Fixed)
task.spawn(function()
    while task.wait(0.25) do
        if State.AutoFarm then
            pcall(function()
                local hrp = GetHRP()
                if not hrp then return end
                local char = player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then return end

                local hasQuest = false
                local questMob = nil
                local mainGui = playerGui:FindFirstChild("Main")
                if mainGui and mainGui:FindFirstChild("Quest") and mainGui.Quest.Visible then
                    local questTitle = mainGui.Quest.Container.QuestTitle.Title.Text or ""
                    local m = questTitle:match("Defeat%s*%d*%s*(.-)%s*%b()")
                    if m then
                        hasQuest = true
                        questMob = m:gsub("Military ", "Mil. "):gsub("%s+$", "")
                    end
                end

                if hasQuest and questMob and questMob ~= "" then
                    local enemy = FindEnemy({questMob}, 99999)
                    if enemy then
                        CombatController.Attack({questMob})
                    else
                        local sp = FindSpawnPart(questMob, true)
                        if sp then
                            FarmTeleport(sp.CFrame * CFrame.new(0, 60, 0), getgenv().FarmSpeed, 25)
                        end
                    end
                    return
                end

                local level = player.Data.Level.Value
                local okQ, Quests = pcall(function() return require(RS.Quests) end)
                local okG, GuideModule = pcall(function() return require(RS.GuideModule) end)
                if not okQ or not okG then return end

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
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.35) do
        if State.AutoFarmNearest then
            pcall(function()
                local list = GetMonAsSortedRange()
                if list[1] then CombatController.Attack({list[1].Name}) end
            end)
        end
    end
end)

-- Auto Farm Mastery (tambahan fix)
task.spawn(function()
    while task.wait(0.35) do
        if State.AutoFarmMastery then
            pcall(function()
                local list = GetMonAsSortedRange()
                if list[1] then CombatController.Attack({list[1].Name}) end
            end)
        end
    end
end)

-- Auto Collect Chest (pakai source baru)
task.spawn(function()
    while task.wait(0.2) do
        if State.AutoCollectChest then
            pcall(function()
                local chests = GetSortedChests()
                if #chests > 0 then
                    ChestTeleport(chests[1].CFrame)
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if State.AutoFarmBones then
            pcall(function()
                CombatController.Attack({"Reborn Skeleton","Living Zombie","Demonic Soul","Posessed Mummy"})
            end)
        end
    end
end)

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
                if npcs then CombatController.Attack(npcs) end
            end)
        end
    end
end)

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

RunService.Stepped:Connect(function()
    if State.NoClip and player.Character then
        pcall(function()
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(1) do
        if State.AutoKen then pcall(function() CommF_:InvokeServer("Ken", true) end) end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.RemoveDamage then pcall(function() RS.Assets.GUI.DamageCounter.Enabled = false end) end
        if State.RemoveNotifications then pcall(function() playerGui.Notifications.Enabled = false end) end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if State.AutoStatPoint then
            pcall(function()
                local stats = {
                    {"Melee",State.StatMelee},{"Defense",State.StatDefense},
                    {"Sword",State.StatSword},{"Gun",State.StatGun},
                    {"Demon Fruit",State.StatFruit}
                }
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
-- FLOATING BUTTON (Logo)
--================================================================
local floatingButton = Instance.new("ScreenGui")
floatingButton.Name = "SYSX_FloatingButton"
floatingButton.ResetOnSpawn = false
floatingButton.IgnoreGuiInset = true
floatingButton.DisplayOrder = 999998
floatingButton.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
floatingButton.Parent = playerGui

local btnHolder = Instance.new("Frame")
btnHolder.Name = "ButtonHolder"
btnHolder.Size = UDim2.fromOffset(56, 56)
btnHolder.Position = UDim2.new(1, -80, 0, 120)
btnHolder.BackgroundColor3 = THEME.BG_Secondary
btnHolder.BackgroundTransparency = 0.1
btnHolder.BorderSizePixel = 0
btnHolder.Active = true
btnHolder.Parent = floatingButton

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = btnHolder

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = THEME.Outline
btnStroke.Thickness = 1.8
btnStroke.Transparency = 0.15
btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
btnStroke.Parent = btnHolder

local logoText = Instance.new("TextLabel")
logoText.Name = "LogoText"
logoText.Text = "SYSX"
logoText.Size = UDim2.fromScale(1, 1)
logoText.BackgroundTransparency = 1
logoText.TextColor3 = THEME.Accent_Bright
logoText.TextSize = 14
logoText.Font = Enum.Font.GothamBlack
logoText.TextStrokeColor3 = THEME.Outline
logoText.TextStrokeTransparency = 0.3
logoText.Parent = btnHolder

local btnClick = Instance.new("TextButton")
btnClick.Name = "ClickArea"
btnClick.Size = UDim2.fromScale(1, 1)
btnClick.BackgroundTransparency = 1
btnClick.Text = ""
btnClick.AutoButtonColor = false
btnClick.Parent = btnHolder

local uiVisible = true

local function ToggleUI()
    uiVisible = not uiVisible
    gui.Enabled = uiVisible
    local ti = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    if uiVisible then
        TweenService:Create(btnHolder, ti, {BackgroundColor3 = THEME.BG_Secondary}):Play()
        TweenService:Create(btnStroke, ti, {Color = THEME.Outline}):Play()
        TweenService:Create(logoText, ti, {TextColor3 = THEME.Accent_Bright}):Play()
    else
        TweenService:Create(btnHolder, ti, {BackgroundColor3 = THEME.Static_Blue}):Play()
        TweenService:Create(btnStroke, ti, {Color = THEME.Accent_Bright}):Play()
        TweenService:Create(logoText, ti, {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    end
end

btnClick.MouseButton1Click:Connect(ToggleUI)

btnClick.MouseEnter:Connect(function()
    TweenService:Create(btnHolder, TweenInfo.new(0.15), {Size = UDim2.fromOffset(60, 60)}):Play()
    TweenService:Create(btnStroke, TweenInfo.new(0.15), {Transparency = 0}):Play()
end)

btnClick.MouseLeave:Connect(function()
    TweenService:Create(btnHolder, TweenInfo.new(0.15), {Size = UDim2.fromOffset(56, 56)}):Play()
    TweenService:Create(btnStroke, TweenInfo.new(0.15), {Transparency = 0.15}):Play()
end)

local fbDragging = false
local fbStart, fbPos
btnHolder.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        fbDragging = true
        fbStart = input.Position
        fbPos = btnHolder.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if fbDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - fbStart
        btnHolder.Position = UDim2.new(
            fbPos.X.Scale, fbPos.X.Offset + delta.X,
            fbPos.Y.Scale, fbPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        fbDragging = false
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then ToggleUI() end
end)

--================================================================
-- STARTUP
--================================================================
ShowTab("Farm")
Notify("SYSX HUB v1.1 Loaded — New Chest + Fixed Farm Level ✅")
