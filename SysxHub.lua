--[[
================================================================
    SYSX HUB | FREEMIUM VERSION | v1.0
    Discord: https://discord.gg/xWa9NpFRr
    UI Style: Clean + Elegant Midnight Luxe
    Total Tabs: 26 | Total Features: 280+
================================================================
]]

--================================================================
-- ASSETS
--================================================================
local a = "rbxassetid://114593995135483" -- LOGO
local b = "rbxassetid://71457853614279"  -- BANNER

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

local DISCORD_INVITE = "https://discord.gg/xWa9NpFRr"

--================================================================
-- THEME
--================================================================
local THEME = {
    BG_Main       = Color3.fromRGB(11, 9, 24),
    BG_Secondary  = Color3.fromRGB(22, 19, 42),
    BG_Tertiary   = Color3.fromRGB(31, 27, 54),
    BG_Hover      = Color3.fromRGB(42, 36, 72),
    BG_Active     = Color3.fromRGB(58, 48, 92),
    Accent_Gold   = Color3.fromRGB(212, 175, 95),
    Accent_Bright = Color3.fromRGB(240, 210, 126),
    Accent_Dim    = Color3.fromRGB(150, 122, 68),
    Text_Primary  = Color3.fromRGB(235, 232, 245),
    Text_Secondary= Color3.fromRGB(157, 148, 184),
    Text_Muted    = Color3.fromRGB(110, 103, 138),
    Border        = Color3.fromRGB(58, 51, 85),
}

--================================================================
-- GUARD
--================================================================
local function IsBloxFruits()
    local pid = game.PlaceId
    if pid == 2753915549 or pid == 4442272183 or pid == 7449423635 then return true end
    if pid == 85211729168715 or pid == 79091703265657 or pid == 100117331123089 then return true end
    local rem = RS:FindFirstChild("Remotes")
    return rem and rem:FindFirstChild("CommF_") ~= nil
end

if not IsBloxFruits() then
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "SysxHub", Text = "Blox Fruits only", Duration = 5,
        })
    end)
    task.wait(2)
    pcall(function() Players.LocalPlayer:Kick("Not Blox Fruits") end)
    return
end

if not game:IsLoaded() then game.Loaded:Wait() end

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")

local placeId = game.PlaceId
World1 = (placeId == 2753915549 or placeId == 85211729168715)
World2 = (placeId == 4442272183 or placeId == 79091703265657)
World3 = (placeId == 7449423635 or placeId == 100117331123089)

local Remotes = RS:WaitForChild("Remotes", 10)
local CommF_  = Remotes:WaitForChild("CommF_", 10)
local Modules = RS:FindFirstChild("Modules")
local Net     = Modules and Modules:FindFirstChild("Net")

--================================================================
-- STATE
--================================================================
local State = {
    AutoFarm=false, AutoFarmNearest=false, AutoChest=false,
    AutoFarmMaterial=false, AutoFarmBones=false, AutoBoss=false,
    SelectedBoss=nil, SelectedMaterial=nil, SelectedWeapon="Melee",
    FastAttack=true, BringMob=true, BringRange=300,
    AutoFarmSea=false, AutoStoreFruit=false, AutoBuyFruit=false, AutoFindFruit=false,
    AutoRaid=false, AutoAwaken=false, AutoCakePrince=false, AutoDoughKing=false,
    AutoEliteHunter=false, AutoSoulReaper=false, AutoFactory=false, AutoPiratesSea=false,
    AutoTyrant=false, AutoCitizen=false, AutoDragonHunter=false,
    AutoKitsuneSummon=false, AutoKitsuneEmber=false, AutoKitsuneTrade=false,
    AutoMirageSummon=false, AutoMirageTween=false,
    AutoPrehistoricSummon=false, AutoPrehistoricTween=false,
    AutoFrozenTween=false, AutoFindLevi=false, AutoAttackLevi=false,
    AutoAttackLeviSeg=false, AutoAttackLeviTail=false,
    AutoV2=false, AutoV3=false, AutoTrial=false, AutoKillAfterTrial=false,
    AutoDracoV2V3=false, AutoDracoTrial=false,
    AutoDungeon=false, AutoCard=false, AutoJoinDungeon=false,
    AutoVolcano=false, AutoGolem=false, AutoCraftMagnet=false,
    AutoSecretQuest=false, AutoMasteryMelee=false, AutoMasterySword=false, AutoMasteryGun=false,
    Aimbot=false, SelectedPlayer=nil, TeleportPlayer=false,
    ESPPlayer=false, ESPFruit=false, ESPChest=false, ESPIsland=false, ESPBoss=false,
    ESPObjects={},
    AntiAFK=true, Noclip=false, HideMob=false,
    AutoStats=false, StatMelee=0, StatDefense=0, StatSword=0, StatGun=0, StatFruit=0,
    PointsPerClick=5, BoostFPS=false, WalkWater=false,
    AutoFishing=false, AutoSellFish=false, AutoEquipRod=false,
    AutoShark=false, AutoPiranha=false, AutoTerrorshark=false,
    AutoFishCrew=false, AutoSeaBeast=false, ProtectBoat=false,
    RemoveDamage=false, RemoveNotifications=false, AutoKen=false,
    AutoHaki=true, StackFarmingEnabled=false,
    AutoSharkTooth=false, AutoTerrorJaw=false, AutoMonsterMagnet=false, AutoSharkAnchor=false,
    AutoUpgradeSword=false, AutoUpgradeGun=false,
    AutoTradeBones=false, AutoBuyLegendSword=false, AutoBuyHakiColor=false,
    AutoRainbowHaki=false, AutoSoulGuitar=false, AutoCDK=false, AutoYama=false,
    AutoTushita=false, AutoTTK=false, AutoSaber=false, AutoYoruMini=false,
    AutoCyborg=false, AutoGhoul=false,
    AutoPullLever=false, AutoBuyGearV4=false, AutoChooseGear=false, AutoFinishTrain=false,
    WebhookFruit=false, WebhookMirage=false, WebhookLevi=false, WebhookPre=false,
}

getgenv().FarmDistance    = 20
getgenv().FarmSpeed       = 200
getgenv().TweenSpeed      = 200
getgenv().CustomWalkSpeed = 100
getgenv().EnableWalkSpeed = false
getgenv().CustomJumpPower = 50
getgenv().EnableJumpPower = false
getgenv().InfiniteJump    = false

local PRIORITY_LIST = {
    {"AutoFarmLevel","Auto Farm Level",1},
    {"AutoFarmNearest","Auto Farm Nearest",2},
    {"AutoFarmMastery","Auto Farm Mastery",3},
    {"AutoCollectChest","Auto Collect Chest",4},
    {"AutoCollectBerry","Auto Collect Berry",5},
    {"AutoFarmMaterial","Auto Farm Material",6},
    {"AutoFarmBones","Auto Farm Bones",7},
    {"AutoAttackBoss","Auto Attack Boss",8},
    {"AutoAttackAllBoss","Auto Attack All Boss",9},
    {"AutoSoulReaper","Auto Soul Reaper",10},
    {"AutoEliteHunter","Auto Elite Hunter",11},
    {"AutoKillTyrant","Auto Kill Tyrant",12},
    {"AutoCitizenQuest","Auto Citizen Quest",13},
    {"AutoDoughKing","Auto Dough King",14},
    {"AutoCakePrince","Auto Cake Prince",15},
}
for _, p in ipairs(PRIORITY_LIST) do
    getgenv()["SX_Prio_"..p[1]] = p[3]
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
    s.Color = c or THEME.Border
    s.Thickness = t or 1
    s.Transparency = tr or 0.55
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

function AutoHaki()
    if not IsAlive() then return end
    if not player.Character:FindFirstChild("HasBuso") then
        pcall(function() CommF_:InvokeServer("Buso") end)
    end
end

getgenv().EquipTime = 0
function EquipWeapon(ToolName)
    if tick() - getgenv().EquipTime < 0.3 then return end
    getgenv().EquipTime = tick()
    if not ToolName then return end
    local bp = player:FindFirstChild("Backpack")
    if not bp then return end
    local tool = bp:FindFirstChild(ToolName)
    if tool and tool:IsA("Tool") then
        player.Character.Humanoid:EquipTool(tool)
        return
    end
    for _, t in ipairs(bp:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip == ToolName then
            player.Character.Humanoid:EquipTool(t)
            return
        end
    end
end

--================================================================
-- FARM TELEPORT
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

local function AnyFarmActive()
    return State.AutoFarm or State.AutoFarmNearest or State.AutoChest
        or State.AutoFarmMaterial or State.AutoFarmBones or State.AutoFarmSea
        or State.AutoBoss or State.AutoCakePrince or State.AutoDoughKing
        or State.AutoEliteHunter or State.AutoSoulReaper or State.AutoFactory
        or State.AutoPiratesSea or State.AutoFindFruit or State.AutoTyrant
        or State.AutoCitizen or State.AutoDragonHunter or State.AutoVolcano
end

function FarmTeleport(goal, speed, customTimeout)
    if not goal or not IsAlive() then return end
    local hrp = GetHRP()
    if not hrp then return end
    speed = speed or getgenv().FarmSpeed or 200
    local goalPos = goal.Position
    local initDist = (hrp.Position - goalPos).Magnitude
    local timeout = customTimeout or math.max(15, initDist / speed * 3)
    SetFarmNoclip(true)
    local lastTick = tick()
    local timeoutStart = tick()
    while true do
        if not AnyFarmActive() then break end
        if not IsAlive() then break end
        local root = GetHRP()
        if not root then break end
        local dist = (root.Position - goalPos).Magnitude
        if dist < 2 then break end
        if tick() - timeoutStart > timeout then break end
        local dt = tick() - lastTick
        lastTick = tick()
        if dt <= 0 then dt = 0.016 end
        if dt > 0.2 then dt = 0.2 end
        local dir = (goalPos - root.Position).Unit
        local moveDist = math.min(speed * dt, dist)
        root.CFrame = root.CFrame + dir * moveDist
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        RunService.Heartbeat:Wait()
    end
    if IsAlive() then
        local root = GetHRP()
        if root then
            local finalDist = (root.Position - goalPos).Magnitude
            if finalDist > 0.5 and finalDist < 10 then
                root.CFrame = CFrame.new(goalPos, root.Position + root.CFrame.LookVector)
            end
        end
    end
    SetFarmNoclip(false)
end
FarmFly = FarmTeleport

--================================================================
-- ATTACK
--================================================================
function AttackNoCoolDown()
    local char = player.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return end
    local hrp = GetHRP()
    if not hrp then return end
    local myPos = hrp.Position
    local hitTargets, mainTarget = {}, nil
    for _, e in ipairs(enemies:GetChildren()) do
        local h = e:FindFirstChild("Humanoid")
        local trp = e:FindFirstChild("HumanoidRootPart")
        if h and trp and h.Health > 0 and (trp.Position - myPos).Magnitude <= 60 then
            local head = e:FindFirstChild("Head") or trp
            table.insert(hitTargets, {e, head})
            mainTarget = head
        end
    end
    if not mainTarget then return end
    if tool:FindFirstChild("LeftClickRemote") then
        local n = 1
        for _, t in ipairs(hitTargets) do
            pcall(function()
                local root = t[1]:FindFirstChild("HumanoidRootPart")
                if root then
                    tool.LeftClickRemote:FireServer((root.Position - myPos).Unit, n)
                    n = n + 1
                end
            end)
        end
    elseif Net then
        local RA = Net:FindFirstChild("RE/RegisterAttack")
        local RH = Net:FindFirstChild("RE/RegisterHit")
        if RA and RH then
            pcall(function()
                RA:FireServer(0.1)
                RH:FireServer(mainTarget, hitTargets)
            end)
        end
    end
end

--================================================================
-- CHEST CACHE
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
    pcall(function()
        for _, c in ipairs(CollectionService:GetTagged("_ChestTagged")) do
            if c:IsA("BasePart") and not table.find(ChestCache, c) then
                table.insert(ChestCache, c)
            end
        end
    end)
end
local function GetSortedChests()
    BuildChestCache()
    local char = player.Character
    if not char then return {} end
    local root = char:FindFirstChild("LowerTorso") or char:FindFirstChild("HumanoidRootPart")
    if not root then return {} end
    local active = {}
    for _, chest in ipairs(ChestCache) do
        if chest and chest.Parent and chest:FindFirstChild("TouchInterest") then
            table.insert(active, chest)
        end
    end
    local rp = root.Position
    table.sort(active, function(x,y) return (rp - x.Position).Magnitude < (rp - y.Position).Magnitude end)
    return active
end

--================================================================
-- FIND ENEMY
--================================================================
local NameCache = {}
function FindEnemy(names, maxRange, typeOverride)
    local hrp = GetHRP()
    if not hrp then return nil end
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    local pos = hrp.Position
    local maxSq = maxRange and (maxRange * maxRange) or math.huge
    local lookup = {}
    for _, n in ipairs(names) do lookup[n] = true end
    local best, bestD = nil, maxSq
    for _, e in ipairs(enemies:GetChildren()) do
        local h = e:FindFirstChild("Humanoid")
        if h and h.Health > 0 then
            local clean = NameCache[e.Name]
            if not clean then
                clean = e.Name:match("^(.-)%s*%[") or e.Name
                NameCache[e.Name] = clean
            end
            if lookup[clean] then
                local target = (typeOverride == "Boat") and e:FindFirstChild("VehicleSeat") or e:FindFirstChild("HumanoidRootPart")
                if target then
                    local d = (target.Position - pos).Magnitude
                    if d < bestD then best = e; bestD = d end
                end
            end
        end
    end
    return best
end

--================================================================
-- BRING MOB
--================================================================
local function BringMobToPlayer(range)
    if not State.BringMob then return end
    range = range or State.BringRange or 300
    local hrp = GetHRP()
    if not hrp then return end
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return end
    local myPos = hrp.Position
    local myCF = hrp.CFrame
    for _, e in ipairs(enemies:GetChildren()) do
        local h = e:FindFirstChildOfClass("Humanoid")
        local trp = e:FindFirstChild("HumanoidRootPart")
        if h and trp and h.Health > 0 then
            local d = (trp.Position - myPos).Magnitude
            if d <= range and d > 1 then
                trp.CFrame = myCF * CFrame.new(math.random(-8,8)/10, -3, math.random(-8,8)/10)
                trp.CanCollide = false
                trp.Size = Vector3.new(50, 50, 50)
                trp.AssemblyLinearVelocity = Vector3.zero
                trp.AssemblyAngularVelocity = Vector3.zero
                h.WalkSpeed = 0
                h.AutoRotate = false
                h.BreakJointsOnDeath = false
                pcall(function() h:ChangeState(Enum.HumanoidStateType.Physics) end)
            end
        end
    end
    if sethiddenproperty then
        pcall(function()
            sethiddenproperty(player, "SimulationRadius", math.huge)
            sethiddenproperty(player, "MaxSimulationRadius", math.huge)
        end)
    end
end

--================================================================
-- QUEST INFO
--================================================================
local SafeRequire = function(m) local ok, r = pcall(require, m) return ok and r or nil end
local QuestsModule = SafeRequire(RS:WaitForChild("Quests", 10))
local GuideModule  = SafeRequire(RS:WaitForChild("GuideModule", 10))

function GetQuestInfo()
    local lvl = player.Data.Level.Value
    local team = tostring(player.Team)
    local questName, questLvl, mobName, npcCFrame, lvlReq, CFrameMon
    if lvl >= 1 and lvl <= 9 then
        if team == "Marines" then
            questName, questLvl, mobName, lvlReq = "MarineQuest", 1, "Trainee", 1
            npcCFrame = CFrame.new(-2709.68, 24.52, 2104.25)
        else
            questName, questLvl, mobName, lvlReq = "BanditQuest1", 1, "Bandit", 1
            npcCFrame = CFrame.new(1059.99, 16.92, 1549.28)
        end
        return {lvlReq, npcCFrame, mobName, questName, questLvl, CFrameMon}
    end
    if lvl >= 210 and lvl <= 249 then
        return {210, CFrame.new(5308.93, 1.65, 475.12), "Dangerous Prisoner", "PrisonerQuest", 2, CFrameMon}
    end
    lvlReq = 0
    if GuideModule and GuideModule.Data and GuideModule.Data.NPCList then
        for k, v in pairs(GuideModule.Data.NPCList) do
            local levels = v.Levels
            for i = 1, #levels do
                local lv = levels[i]
                if lvl >= lv and lv > lvlReq then
                    lvlReq = lv
                    questLvl = (#levels == 3 and i == 3) and 2 or i
                    npcCFrame = k.CFrame
                end
            end
        end
    end
    if QuestsModule then
        for qk, q in pairs(QuestsModule) do
            if qk ~= "CitizenQuest" then
                for qk2, v in pairs(q) do
                    if v.LevelReq == lvlReq then
                        questName = qk
                        questLvl = qk2
                        for mk in pairs(v.Task) do
                            mobName = string.split(mk, " [Lv.")[1]
                        end
                    end
                end
            end
        end
    end
    if questName == "ImpelQuest" then
        questName, questLvl, mobName, lvlReq = "PrisonerQuest", 2, "Dangerous Prisoner", 210
        npcCFrame = CFrame.new(5310.60, 0.35, 474.94)
    elseif questName == "Area2Quest" and questLvl == 2 then
        questLvl, mobName, lvlReq = 1, "Swan Pirate", 775
    end
    if lvl >= 2500 and lvl <= 2524 then mobName = "Sun-kissed Warrior" end
    return {lvlReq, npcCFrame, mobName, questName, questLvl, CFrameMon}
end

--================================================================
-- UI CONSTRUCTORS
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

-- Notif
local Notif = Create("TextLabel", {
    Name = "Notif", Parent = gui,
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -20),
    Size = UDim2.fromOffset(360, 44),
    BackgroundColor3 = THEME.BG_Secondary,
    BackgroundTransparency = 0.08,
    Text = "", TextColor3 = THEME.Accent_Bright,
    TextSize = 13, Font = Enum.Font.GothamMedium,
    Visible = false, ZIndex = 999999,
})
Corner(Notif, 12)
Stroke(Notif, THEME.Accent_Gold, 1.5, 0.3)

-- Logo (draggable)
local logo = Instance.new("ImageButton")
logo.Name = "OpenLogo"
logo.Size = UDim2.new(0, 58, 0, 58)
logo.Position = UDim2.new(0, 18, 0.5, -29)
logo.BackgroundColor3 = THEME.BG_Secondary
logo.BackgroundTransparency = 0.05
logo.BorderSizePixel = 0
logo.Image = a
logo.ScaleType = Enum.ScaleType.Fit
logo.AutoButtonColor = false
logo.ZIndex = 100
logo.Parent = gui
Corner(logo, 18)
local logoStroke = Instance.new("UIStroke")
logoStroke.Color = THEME.Accent_Gold
logoStroke.Thickness = 1.8
logoStroke.Transparency = 0.15
logoStroke.Parent = logo

-- Main UI
local main = Instance.new("Frame")
main.Name = "MainUI"
main.Size = UDim2.new(0, 720, 0, 560)
main.Position = UDim2.new(0.5, -360, 0.5, -280)
main.BackgroundColor3 = THEME.BG_Main
main.BorderSizePixel = 0
main.Visible = false
main.ClipsDescendants = true
main.ZIndex = 10
main.Parent = gui
Corner(main, 18)
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = THEME.Accent_Gold
mainStroke.Thickness = 1.2
mainStroke.Transparency = 0.5
mainStroke.Parent = main

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 74)
header.BackgroundTransparency = 1
header.ZIndex = 20
header.Parent = main

local logoHeader = Instance.new("ImageLabel")
logoHeader.Size = UDim2.fromOffset(50, 50)
logoHeader.Position = UDim2.fromOffset(14, 10)
logoHeader.BackgroundTransparency = 1
logoHeader.Image = a
logoHeader.ScaleType = Enum.ScaleType.Fit
logoHeader.ZIndex = 22
logoHeader.Parent = header

local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(74, 4)
title.Size = UDim2.fromOffset(340, 22)
title.BackgroundTransparency = 1
title.Text = "SysxHub"
title.TextColor3 = THEME.Accent_Bright
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 22
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Position = UDim2.fromOffset(74, 26)
subtitle.Size = UDim2.fromOffset(340, 15)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Freemium Version  •  v1.0"
subtitle.TextColor3 = THEME.Text_Secondary
subtitle.TextSize = 10
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.ZIndex = 22
subtitle.Parent = header

local lvlLabel = Instance.new("TextLabel")
lvlLabel.Position = UDim2.fromOffset(74, 43)
lvlLabel.Size = UDim2.fromOffset(340, 15)
lvlLabel.BackgroundTransparency = 1
lvlLabel.Text = "Lv: 1  •  Sea 1"
lvlLabel.TextColor3 = THEME.Accent_Gold
lvlLabel.TextSize = 10
lvlLabel.Font = Enum.Font.GothamBold
lvlLabel.TextXAlignment = Enum.TextXAlignment.Left
lvlLabel.ZIndex = 22
lvlLabel.Parent = header

task.spawn(function()
    while task.wait(1) do
        if not lvlLabel.Parent then break end
        pcall(function()
            local lv = player.Data and player.Data.Level and player.Data.Level.Value or 1
            local sea = lv >= 1500 and 3 or lv >= 700 and 2 or 1
            lvlLabel.Text = "Lv: " .. lv .. "  •  Sea " .. sea
        end)
    end
end)

-- Close
local close = Instance.new("ImageButton")
close.Size = UDim2.fromOffset(36, 36)
close.Position = UDim2.new(1, -52, 0, 12)
close.BackgroundColor3 = THEME.BG_Secondary
close.BackgroundTransparency = 0.1
close.Image = a
close.ImageColor3 = THEME.Accent_Gold
close.ScaleType = Enum.ScaleType.Fit
close.AutoButtonColor = false
close.ZIndex = 25
close.Parent = header
Corner(close, 10)
Stroke(close, THEME.Accent_Gold, 1.2, 0.4)

Create("Frame", {
    Parent = header,
    Size = UDim2.new(1, -32, 0, 1),
    Position = UDim2.new(0, 16, 1, -2),
    BackgroundColor3 = THEME.Accent_Dim,
    BackgroundTransparency = 0.65,
    BorderSizePixel = 0, ZIndex = 22,
})

-- Banner
local banner = Instance.new("Frame")
banner.Size = UDim2.new(1, -32, 0, 120)
banner.Position = UDim2.fromOffset(16, 88)
banner.BackgroundColor3 = THEME.BG_Secondary
banner.BorderSizePixel = 0
banner.ClipsDescendants = true
banner.ZIndex = 12
banner.Parent = main
Corner(banner, 14)
Stroke(banner, THEME.Border, 1, 0.35)

local bannerImg = Instance.new("ImageLabel")
bannerImg.Size = UDim2.fromScale(1, 1)
bannerImg.BackgroundTransparency = 1
bannerImg.Image = b
bannerImg.ScaleType = Enum.ScaleType.Crop
bannerImg.ZIndex = 12
bannerImg.Parent = banner

local bannerOverlay = Instance.new("Frame")
bannerOverlay.Size = UDim2.fromScale(1, 1)
bannerOverlay.BackgroundColor3 = Color3.fromRGB(5, 3, 15)
bannerOverlay.BackgroundTransparency = 0.68
bannerOverlay.BorderSizePixel = 0
bannerOverlay.ZIndex = 13
bannerOverlay.Parent = banner

-- Content Area
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -32, 1, -240)
content.Position = UDim2.fromOffset(16, 224)
content.BackgroundTransparency = 1
content.ZIndex = 14
content.Parent = main

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.BackgroundColor3 = THEME.BG_Secondary
sidebar.Size = UDim2.new(0, 145, 1, 0)
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 15
sidebar.Parent = content
Corner(sidebar, 12)
Stroke(sidebar, THEME.Border, 1, 0.5)

local tabList = Instance.new("ScrollingFrame")
tabList.BackgroundTransparency = 1
tabList.Position = UDim2.new(0, 6, 0, 6)
tabList.Size = UDim2.new(1, -12, 1, -12)
tabList.CanvasSize = UDim2.new(0, 0, 0, 0)
tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
tabList.ScrollBarThickness = 2
tabList.ScrollBarImageColor3 = THEME.Accent_Gold
tabList.BorderSizePixel = 0
tabList.ZIndex = 16
tabList.Parent = sidebar
local TL = Instance.new("UIListLayout")
TL.Padding = UDim.new(0, 4)
TL.SortOrder = Enum.SortOrder.LayoutOrder
TL.Parent = tabList

local contentScroll = Instance.new("ScrollingFrame")
contentScroll.BackgroundTransparency = 1
contentScroll.Position = UDim2.new(0, 155, 0, 0)
contentScroll.Size = UDim2.new(1, -155, 1, 0)
contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
contentScroll.ScrollBarThickness = 3
contentScroll.ScrollBarImageColor3 = THEME.Accent_Gold
contentScroll.BorderSizePixel = 0
contentScroll.ZIndex = 14
contentScroll.Parent = content

local Pages, Tabs = {}, {}

local function CreatePage(name)
    local P = Instance.new("ScrollingFrame")
    P.Name = name
    P.Parent = contentScroll
    P.BackgroundTransparency = 1
    P.Position = UDim2.new(0, 4, 0, 4)
    P.Size = UDim2.new(1, -8, 1, -8)
    P.CanvasSize = UDim2.new(0, 0, 0, 0)
    P.AutomaticCanvasSize = Enum.AutomaticSize.Y
    P.ScrollBarThickness = 3
    P.ScrollBarImageColor3 = THEME.Accent_Gold
    P.BorderSizePixel = 0
    P.Visible = false
    P.ZIndex = 12
    local L = Instance.new("UIListLayout")
    L.Padding = UDim.new(0, 6)
    L.SortOrder = Enum.SortOrder.LayoutOrder
    L.Parent = P
    Pages[name] = P
    return P
end

local function CreateTab(name, order)
    local B = Instance.new("TextButton")
    B.Parent = tabList
    B.BackgroundColor3 = THEME.BG_Secondary
    B.Size = UDim2.new(1, 0, 0, 28)
    B.Text = ""
    B.AutoButtonColor = false
    B.BorderSizePixel = 0
    B.LayoutOrder = order
    B.ZIndex = 17
    Corner(B, 7)
    local L = Instance.new("TextLabel")
    L.Parent = B
    L.BackgroundTransparency = 1
    L.Position = UDim2.new(0, 10, 0, 0)
    L.Size = UDim2.new(1, -14, 1, 0)
    L.Text = name
    L.TextColor3 = THEME.Text_Secondary
    L.TextSize = 10
    L.Font = Enum.Font.GothamMedium
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.ZIndex = 18
    Tabs[name] = { Button = B, Label = L }
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
            if d.Button:FindFirstChildOfClass("UIStroke") then d.Button:FindFirstChildOfClass("UIStroke"):Destroy() end
            Stroke(d.Button, THEME.Accent_Gold, 1, 0.25)
        else
            d.Button.BackgroundColor3 = THEME.BG_Secondary
            d.Label.TextColor3 = THEME.Text_Secondary
            if d.Button:FindFirstChildOfClass("UIStroke") then d.Button:FindFirstChildOfClass("UIStroke"):Destroy() end
        end
    end
end

-- Element Creators
local function CreateToggle(parent, text, default, cb)
    local state = default or false
    local B = Instance.new("TextButton")
    B.Parent = parent
    B.BackgroundColor3 = THEME.BG_Secondary
    B.Size = UDim2.new(1, 0, 0, 36)
    B.Text = ""
    B.AutoButtonColor = false
    B.BorderSizePixel = 0
    B.ZIndex = 100
    Corner(B, 9)
    Stroke(B, THEME.Border, 1, 0.6)
    local L = Instance.new("TextLabel")
    L.Parent = B
    L.BackgroundTransparency = 1
    L.Position = UDim2.new(0, 12, 0, 0)
    L.Size = UDim2.new(1, -58, 1, 0)
    L.Text = text
    L.TextColor3 = THEME.Text_Primary
    L.TextSize = 11
    L.Font = Enum.Font.GothamMedium
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.ZIndex = 101
    local Ind = Instance.new("Frame")
    Ind.Parent = B
    Ind.BackgroundColor3 = THEME.BG_Tertiary
    Ind.Size = UDim2.fromOffset(34, 18)
    Ind.Position = UDim2.new(1, -46, 0.5, -9)
    Ind.ZIndex = 101
    Corner(Ind, 20)
    Stroke(Ind, THEME.Border, 1, 0.5)
    local Dot = Instance.new("Frame")
    Dot.Parent = Ind
    Dot.BackgroundColor3 = THEME.Text_Muted
    Dot.Size = UDim2.fromOffset(12, 12)
    Dot.Position = UDim2.new(0, 3, 0.5, -6)
    Dot.ZIndex = 102
    Corner(Dot, 20)
    local function upd()
        if state then
            Ind.BackgroundColor3 = THEME.Accent_Gold
            Dot.BackgroundColor3 = THEME.BG_Main
            TW(Dot, {Position = UDim2.new(1, -15, 0.5, -6)}, 0.18)
            if Ind:FindFirstChildOfClass("UIStroke") then Ind:FindFirstChildOfClass("UIStroke"):Destroy() end
            Stroke(Ind, THEME.Accent_Bright, 1, 0)
        else
            Ind.BackgroundColor3 = THEME.BG_Tertiary
            Dot.BackgroundColor3 = THEME.Text_Muted
            TW(Dot, {Position = UDim2.new(0, 3, 0.5, -6)}, 0.18)
            if Ind:FindFirstChildOfClass("UIStroke") then Ind:FindFirstChildOfClass("UIStroke"):Destroy() end
            Stroke(Ind, THEME.Border, 1, 0.5)
        end
    end
    B.Activated:Connect(function()
        state = not state
        upd()
        if cb then pcall(cb, state) end
    end)
    upd()
    if state and cb then task.defer(function() pcall(cb, true) end) end
    return B
end

local function CreateButton(parent, text, cb)
    local B = Instance.new("TextButton")
    B.Parent = parent
    B.BackgroundColor3 = THEME.BG_Secondary
    B.Size = UDim2.new(1, 0, 0, 36)
    B.Text = text
    B.TextColor3 = THEME.Text_Primary
    B.TextSize = 11
    B.Font = Enum.Font.GothamMedium
    B.AutoButtonColor = false
    B.BorderSizePixel = 0
    B.ZIndex = 100
    Corner(B, 9)
    Stroke(B, THEME.Border, 1.1, 0.55)
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
    local Hold = Instance.new("Frame")
    Hold.Parent = parent
    Hold.BackgroundColor3 = THEME.BG_Secondary
    Hold.Size = UDim2.new(1, 0, 0, 36)
    Hold.BorderSizePixel = 0
    Hold.ZIndex = 100
    Corner(Hold, 9)
    Stroke(Hold, THEME.Border, 1.1, 0.55)
    local Sel = options[1] or "-"
    local Lbl = Instance.new("TextLabel")
    Lbl.Parent = Hold
    Lbl.BackgroundTransparency = 1
    Lbl.Position = UDim2.new(0, 12, 0, 0)
    Lbl.Size = UDim2.new(1, -32, 1, 0)
    Lbl.Text = title .. ": " .. Sel
    Lbl.TextColor3 = THEME.Text_Primary
    Lbl.TextSize = 11
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = 101
    local arrow = Instance.new("TextLabel")
    arrow.Parent = Hold
    arrow.BackgroundTransparency = 1
    arrow.Position = UDim2.new(1, -22, 0, 0)
    arrow.Size = UDim2.new(0, 16, 1, 0)
    arrow.Text = "v"
    arrow.TextColor3 = THEME.Accent_Gold
    arrow.TextSize = 11
    arrow.Font = Enum.Font.GothamBold
    arrow.ZIndex = 101
    local clickBtn = Instance.new("TextButton")
    clickBtn.Parent = Hold
    clickBtn.BackgroundTransparency = 1
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.Text = ""
    clickBtn.AutoButtonColor = false
    clickBtn.ZIndex = 110
    clickBtn.Activated:Connect(function()
        local Pop = Instance.new("Frame")
        Pop.Parent = gui
        Pop.AnchorPoint = Vector2.new(0.5, 0.5)
        Pop.Position = UDim2.new(0.5, 0, 0.5, 0)
        Pop.Size = UDim2.fromOffset(300, math.min(#options*36+80, 400))
        Pop.BackgroundColor3 = THEME.BG_Secondary
        Pop.BorderSizePixel = 0
        Pop.ZIndex = 999990
        Corner(Pop, 14)
        Stroke(Pop, THEME.Accent_Gold, 1.5, 0.3)
        local PT = Instance.new("TextLabel")
        PT.Parent = Pop
        PT.BackgroundTransparency = 1
        PT.Position = UDim2.fromOffset(18, 10)
        PT.Size = UDim2.new(1, -60, 0, 22)
        PT.Text = title
        PT.TextColor3 = THEME.Accent_Bright
        PT.TextSize = 14
        PT.Font = Enum.Font.GothamBold
        PT.TextXAlignment = Enum.TextXAlignment.Left
        PT.ZIndex = 999991
        local xBtn = Instance.new("TextButton")
        xBtn.Parent = Pop
        xBtn.Position = UDim2.new(1, -40, 0, 10)
        xBtn.Size = UDim2.fromOffset(28, 22)
        xBtn.Text = "x"
        xBtn.TextColor3 = THEME.Text_Muted
        xBtn.TextSize = 14
        xBtn.BackgroundTransparency = 1
        xBtn.Font = Enum.Font.GothamBold
        xBtn.AutoButtonColor = false
        xBtn.ZIndex = 999992
        xBtn.Activated:Connect(function() Pop:Destroy() end)
        local LS = Instance.new("ScrollingFrame")
        LS.Parent = Pop
        LS.BackgroundTransparency = 1
        LS.Position = UDim2.fromOffset(12, 42)
        LS.Size = UDim2.new(1, -24, 1, -54)
        LS.CanvasSize = UDim2.new(0, 0, 0, 0)
        LS.AutomaticCanvasSize = Enum.AutomaticSize.Y
        LS.ScrollBarThickness = 3
        LS.ScrollBarImageColor3 = THEME.Accent_Gold
        LS.BorderSizePixel = 0
        LS.ZIndex = 999991
        local LL = Instance.new("UIListLayout")
        LL.Padding = UDim.new(0, 4)
        LL.SortOrder = Enum.SortOrder.LayoutOrder
        LL.Parent = LS
        for i, opt in ipairs(options) do
            local OB = Instance.new("TextButton")
            OB.Parent = LS
            OB.BackgroundColor3 = THEME.BG_Tertiary
            OB.Size = UDim2.new(1, -8, 0, 32)
            OB.Position = UDim2.new(0, 4, 0, 0)
            OB.Text = opt
            OB.TextColor3 = THEME.Text_Primary
            OB.TextSize = 12
            OB.Font = Enum.Font.GothamMedium
            OB.AutoButtonColor = false
            OB.BorderSizePixel = 0
            OB.LayoutOrder = i
            OB.ZIndex = 999992
            OB.TextXAlignment = Enum.TextXAlignment.Left
            Corner(OB, 7)
            local pad = Instance.new("UIPadding")
            pad.PaddingLeft = UDim.new(0, 12)
            pad.Parent = OB
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
    local Hold = Instance.new("Frame")
    Hold.Parent = parent
    Hold.BackgroundColor3 = THEME.BG_Secondary
    Hold.Size = UDim2.new(1, 0, 0, 56)
    Hold.BorderSizePixel = 0
    Hold.ZIndex = 100
    Corner(Hold, 9)
    Stroke(Hold, THEME.Border, 1, 0.55)
    local TLb = Instance.new("TextLabel")
    TLb.Parent = Hold
    TLb.BackgroundTransparency = 1
    TLb.Position = UDim2.new(0, 14, 0, 8)
    TLb.Size = UDim2.new(1, -90, 0, 16)
    TLb.Text = title
    TLb.TextColor3 = THEME.Text_Secondary
    TLb.TextSize = 10
    TLb.Font = Enum.Font.GothamMedium
    TLb.TextXAlignment = Enum.TextXAlignment.Left
    TLb.ZIndex = 101
    local ValHolder = Instance.new("Frame")
    ValHolder.Parent = Hold
    ValHolder.BackgroundColor3 = THEME.BG_Tertiary
    ValHolder.Position = UDim2.new(1, -74, 0, 6)
    ValHolder.Size = UDim2.fromOffset(60, 20)
    ValHolder.ZIndex = 101
    Corner(ValHolder, 6)
    Stroke(ValHolder, THEME.Accent_Dim, 1, 0.4)
    local ValLbl = Instance.new("TextLabel")
    ValLbl.Parent = ValHolder
    ValLbl.BackgroundTransparency = 1
    ValLbl.Size = UDim2.fromScale(1, 1)
    ValLbl.Text = tostring(val)
    ValLbl.TextColor3 = THEME.Accent_Bright
    ValLbl.TextSize = 11
    ValLbl.Font = Enum.Font.GothamBold
    ValLbl.ZIndex = 102
    local TrackBg = Instance.new("Frame")
    TrackBg.Parent = Hold
    TrackBg.BackgroundColor3 = THEME.BG_Tertiary
    TrackBg.Position = UDim2.new(0, 14, 0, 34)
    TrackBg.Size = UDim2.new(1, -28, 0, 6)
    TrackBg.BorderSizePixel = 0
    TrackBg.ZIndex = 101
    Corner(TrackBg, 4)
    local fillRatio = (val - minV) / (maxV - minV)
    local Fill = Instance.new("Frame")
    Fill.Parent = TrackBg
    Fill.BackgroundColor3 = THEME.Accent_Gold
    Fill.Size = UDim2.new(fillRatio, 0, 1, 0)
    Fill.BorderSizePixel = 0
    Fill.ZIndex = 102
    Corner(Fill, 4)
    local Knob = Instance.new("Frame")
    Knob.Parent = TrackBg
    Knob.BackgroundColor3 = THEME.Accent_Bright
    Knob.Size = UDim2.fromOffset(14, 14)
    Knob.Position = UDim2.new(fillRatio, -7, 0.5, -7)
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 103
    Corner(Knob, 20)
    Stroke(Knob, THEME.BG_Main, 1.5, 0)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Hold
    Btn.BackgroundTransparency = 1
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.Position = UDim2.new(0, 0, 0, 22)
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Btn.ZIndex = 110
    local dragging = false
    local function update(mx)
        local abs = TrackBg.AbsolutePosition
        local sz = TrackBg.AbsoluteSize
        if sz.X == 0 then return end
        local rel = math.clamp((mx - abs.X) / sz.X, 0, 1)
        val = math.floor(minV + (maxV - minV) * rel + 0.5)
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        Knob.Position = UDim2.new(rel, -7, 0.5, -7)
        ValLbl.Text = tostring(val)
        if cb then pcall(cb, val) end
    end
    Btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(i.Position.X)
            pcall(function() TW(Knob, {Size = UDim2.fromOffset(18, 18)}, 0.1) end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            pcall(function() TW(Knob, {Size = UDim2.fromOffset(14, 14)}, 0.12) end)
        end
    end)
    return Hold
end

local function CreateLabel(parent, text, sz)
    local L = Instance.new("TextLabel")
    L.Parent = parent
    L.BackgroundColor3 = THEME.BG_Secondary
    L.Size = UDim2.new(1, 0, 0, sz or 28)
    L.Text = text
    L.TextColor3 = THEME.Text_Primary
    L.TextSize = 10
    L.Font = Enum.Font.GothamMedium
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.TextYAlignment = Enum.TextYAlignment.Top
    L.BorderSizePixel = 0
    L.ZIndex = 100
    Corner(L, 9)
    Stroke(L, THEME.Border, 1, 0.55)
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
    TW(Notif, {TextTransparency = 0, BackgroundTransparency = 0.08}, 0.25)
    task.delay(2.5, function()
        if tk ~= Notif.__tk then return end
        TW(Notif, {TextTransparency = 1, BackgroundTransparency = 1}, 0.25)
        task.wait(0.25)
        if tk == Notif.__tk then Notif.Visible = false end
    end)
end

local function TryBuy(cmd, ...)
    local args = {...}
    local ok = pcall(function() return CommF_:InvokeServer(cmd, table.unpack(args)) end)
    Notify(ok and "Purchased: " .. cmd or "Failed: " .. cmd)
end

--================================================================
-- PAGES
--================================================================
local DiscordPage      = CreatePage("Discord")
local FarmPage         = CreatePage("Farm")
local StackFarmPage    = CreatePage("Stack Farming")
local MasteryPage      = CreatePage("Mastery Weapon")
local SeaPage          = CreatePage("Sea")
local LeviathanPage    = CreatePage("Leviathan")
local KitsunePage      = CreatePage("Kitsune")
local MiragePage       = CreatePage("Mirage / Prehist")
local QuestItemsPage   = CreatePage("Quest / Items")
local FruitRaidPage    = CreatePage("Fruit / Raid")
local FishingPage      = CreatePage("Fishing")
local RaceV4Page       = CreatePage("Race V4")
local RaceDracoPage    = CreatePage("Race Draco")
local RaceNormalPage   = CreatePage("Race Normal")
local SecretPage       = CreatePage("Secret Quest")
local DungeonPage      = CreatePage("Dungeon")
local VolcanoPage      = CreatePage("Volcano Event")
local TrialsPage       = CreatePage("Trials")
local PvPPage          = CreatePage("PvP")
local SetingPage       = CreatePage("Seting")
local TeleportPage     = CreatePage("Teleport")
local StatsPage        = CreatePage("Stats")
local ShopPage         = CreatePage("Shop")
local MiscPage         = CreatePage("Misc")
local WebhookPage      = CreatePage("Webhook")
local SettingPage      = CreatePage("Setting")

local TabDefs = {
    {"Discord"}, {"Farm"}, {"Stack Farming"}, {"Mastery Weapon"},
    {"Sea"}, {"Leviathan"}, {"Kitsune"}, {"Mirage / Prehist"},
    {"Quest / Items"}, {"Fruit / Raid"}, {"Fishing"},
    {"Race V4"}, {"Race Draco"}, {"Race Normal"},
    {"Secret Quest"}, {"Dungeon"}, {"Volcano Event"},
    {"Trials"}, {"PvP"}, {"Seting"}, {"Teleport"},
    {"Stats"}, {"Shop"}, {"Misc"}, {"Webhook"}, {"Setting"},
}
for i, d in ipairs(TabDefs) do
    local btn = CreateTab(d[1], i)
    btn.Activated:Connect(function() ShowTab(d[1]) end)
end

--================================================================
-- TAB 1: DISCORD
--================================================================
CreateLabel(DiscordPage, "=== SysxHub Community ===", 32)
local DInfo = CreateLabel(DiscordPage,
    "Welcome to SysxHub!\n\n" ..
    "  Version        :  Freemium v1.0\n" ..
    "  Platform       :  Blox Fruits\n" ..
    "  Total Features :  280+\n" ..
    "  Total Tabs     :  26\n\n" ..
    "Join our Discord for updates and free keys.",
    130)
DInfo.TextSize = 11
DInfo.TextYAlignment = Enum.TextYAlignment.Top

CreateButton(DiscordPage, "Join Discord Server", function()
    if setclipboard then setclipboard(DISCORD_INVITE) end
    pcall(function() GuiService:OpenBrowserWindow(DISCORD_INVITE) end)
    Notify("Opening Discord... Link copied")
end)

CreateLabel(DiscordPage, "=== Features ===", 26)
local DFeat = CreateLabel(DiscordPage,
    "  -  Priority Stack Farming\n" ..
    "  -  Auto Leviathan Hunt\n" ..
    "  -  Race V4 / Draco / Normal\n" ..
    "  -  Secret Quest System\n" ..
    "  -  Auto Dungeon + Card Pick\n" ..
    "  -  Volcano Event Auto\n" ..
    "  -  Kitsune / Mirage / Prehistoric\n" ..
    "  -  ESP + PvP Aimbot\n" ..
    "  -  Discord Webhook Integration\n" ..
    "  -  280+ features total",
    180)
DFeat.TextSize = 11
DFeat.TextYAlignment = Enum.TextYAlignment.Top

CreateLabel(DiscordPage, "SysxHub | Freemium Version | v1.0", 34)

--================================================================
-- TAB 2: FARM
--================================================================
CreateLabel(FarmPage, "=== Farm Settings ===", 26)
CreateDropdown(FarmPage, "Select Weapon", {"Melee","Sword","Blox Fruit","Gun"}, function(o) State.SelectedWeapon = o end)
CreateSlider(FarmPage, "Farm Distance", 5, 50, 20, function(v) getgenv().FarmDistance = v end)
CreateToggle(FarmPage, "Auto Farm Level", false, function(s)
    State.AutoFarm = s
    Notify(s and "Auto Farm Level ON" or "Auto Farm Level OFF")
end)
CreateSlider(FarmPage, "Farm Fly Speed", 50, 300, 200, function(v)
    getgenv().FarmSpeed = v
    Notify("Fly Speed: " .. v)
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

CreateLabel(FarmPage, "=== Special Boss ===", 26)
CreateToggle(FarmPage, "Auto Cake Prince", false, function(s) State.AutoCakePrince = s end)
CreateToggle(FarmPage, "Auto Dough King", false, function(s) State.AutoDoughKing = s end)
CreateToggle(FarmPage, "Auto Elite Hunter", false, function(s) State.AutoEliteHunter = s end)
CreateToggle(FarmPage, "Auto Soul Reaper", false, function(s) State.AutoSoulReaper = s end)
CreateToggle(FarmPage, "Auto Factory", false, function(s) State.AutoFactory = s end)
CreateToggle(FarmPage, "Auto Pirates Sea", false, function(s) State.AutoPiratesSea = s end)

--================================================================
-- TAB 3: STACK FARMING
--================================================================
CreateLabel(StackFarmPage, "=== Priority Stack System ===", 26)
CreateLabel(StackFarmPage, "Only the highest priority feature with available targets will run.", 40).TextSize = 11
CreateToggle(StackFarmPage, "Enable Stack Farming", false, function(s)
    State.StackFarmingEnabled = s
    Notify(s and "Stack Farming ON" or "Stack Farming OFF")
end)
CreateLabel(StackFarmPage, "--- Priority List ---", 22)
local optList = {"1","2","3","4","5","6","7","8","9","10","11","12","13","14","15"}
for _, p in ipairs(PRIORITY_LIST) do
    CreateDropdown(StackFarmPage, "Priority: " .. p[2], optList, function(o)
        getgenv()["SX_Prio_" .. p[1]] = tonumber(o)
    end)
end

--================================================================
-- TAB 4: MASTERY WEAPON
--================================================================
CreateLabel(MasteryPage, "=== Auto Mastery 600 ===", 26)
local MStatus = CreateLabel(MasteryPage, "Status: Idle", 36)
MStatus.TextSize = 11

CreateToggle(MasteryPage, "Auto Mastery 600 [Melee]", false, function(s)
    State.AutoMasteryMelee = s
    if s then
        task.spawn(function()
            while State.AutoMasteryMelee do
                pcall(function()
                    MStatus.Text = "Farming Melee Mastery..."
                    local enemy = FindEnemy({"Reborn Skeleton","Living Zombie","Bandit"}, 5000)
                    if enemy then
                        EquipWeapon("Melee"); AutoHaki()
                        local trp = enemy:FindFirstChild("HumanoidRootPart")
                        if trp then
                            FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), 200, 20)
                            trp.CanCollide = false
                            if enemy:FindFirstChild("Humanoid") then enemy.Humanoid.WalkSpeed = 0 end
                            AttackNoCoolDown()
                        end
                    end
                end)
                task.wait(0.3)
            end
        end)
    end
end)

CreateToggle(MasteryPage, "Auto Mastery 600 [Sword]", false, function(s)
    State.AutoMasterySword = s
    if s then
        task.spawn(function()
            while State.AutoMasterySword do
                pcall(function()
                    MStatus.Text = "Farming Sword Mastery..."
                    local enemy = FindEnemy({"Reborn Skeleton","Living Zombie","Bandit"}, 5000)
                    if enemy then
                        EquipWeapon("Sword"); AutoHaki()
                        local trp = enemy:FindFirstChild("HumanoidRootPart")
                        if trp then
                            FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), 200, 20)
                            trp.CanCollide = false
                            if enemy:FindFirstChild("Humanoid") then enemy.Humanoid.WalkSpeed = 0 end
                            AttackNoCoolDown()
                        end
                    end
                end)
                task.wait(0.3)
            end
        end)
    end
end)

CreateToggle(MasteryPage, "Auto Mastery 600 [Gun]", false, function(s)
    State.AutoMasteryGun = s
    if s then
        task.spawn(function()
            while State.AutoMasteryGun do
                pcall(function()
                    MStatus.Text = "Farming Gun Mastery..."
                    local enemy = FindEnemy({"Reborn Skeleton","Living Zombie","Bandit"}, 5000)
                    if enemy then
                        EquipWeapon("Gun"); AutoHaki()
                        local trp = enemy:FindFirstChild("HumanoidRootPart")
                        if trp then
                            FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), 200, 20)
                            trp.CanCollide = false
                            if enemy:FindFirstChild("Humanoid") then enemy.Humanoid.WalkSpeed = 0 end
                            AttackNoCoolDown()
                        end
                    end
                end)
                task.wait(0.3)
            end
        end)
    end
end)

--================================================================
-- TAB 5: SEA
--================================================================
CreateLabel(SeaPage, "=== Sea Settings ===", 26)
CreateDropdown(SeaPage, "Select Boat", {"PirateBrigade","PirateGrandBrigade","MarineBrigade","MarineGrandBrigade","Beast Hunter"}, function(o) getgenv().SelectedBoat = o end)
CreateToggle(SeaPage, "Auto Farm Sea", false, function(s) State.AutoFarmSea = s end)
CreateToggle(SeaPage, "Protect Boat", false, function(s) State.ProtectBoat = s end)

CreateLabel(SeaPage, "=== Attack Options ===", 26)
CreateToggle(SeaPage, "Auto Shark", false, function(s) State.AutoShark = s end)
CreateToggle(SeaPage, "Auto Piranha", false, function(s) State.AutoPiranha = s end)
CreateToggle(SeaPage, "Auto Terrorshark", false, function(s) State.AutoTerrorshark = s end)
CreateToggle(SeaPage, "Auto Fish Crew", false, function(s) State.AutoFishCrew = s end)
CreateToggle(SeaPage, "Auto Sea Beast", false, function(s) State.AutoSeaBeast = s end)

CreateLabel(SeaPage, "=== Find Island ===", 26)
CreateToggle(SeaPage, "Find Mirage Island", false, function(s) getgenv().FindMirage = s end)
CreateToggle(SeaPage, "Find Prehistoric Island", false, function(s) getgenv().FindPrehistoric = s end)
CreateToggle(SeaPage, "Find Frozen Dimension", false, function(s) getgenv().FindFrozen = s end)
CreateToggle(SeaPage, "Find Kitsune Island", false, function(s) getgenv().FindKitsune = s end)

CreateLabel(SeaPage, "=== Sea Items ===", 26)
CreateToggle(SeaPage, "Auto Shark Tooth Necklace", false, function(s) State.AutoSharkTooth = s end)
CreateToggle(SeaPage, "Auto Terror Jaw", false, function(s) State.AutoTerrorJaw = s end)
CreateToggle(SeaPage, "Auto Monster Magnet", false, function(s) State.AutoMonsterMagnet = s end)
CreateToggle(SeaPage, "Auto Shark Anchor", false, function(s) State.AutoSharkAnchor = s end)

--================================================================
-- TAB 6: LEVIATHAN
--================================================================
CreateLabel(LeviathanPage, "=== Leviathan Hunt ===", 26)
local LevStatus = CreateLabel(LeviathanPage, "Frozen Dimension: Checking...", 28)
LevStatus.TextSize = 11
task.spawn(function()
    while task.wait(2) do
        if not LevStatus.Parent then break end
        pcall(function()
            local exists = Workspace._WorldOrigin.Locations:FindFirstChild("Frozen Dimension")
            LevStatus.Text = "Frozen Dimension: " .. (exists and "Spawned" or "Not Spawned")
        end)
    end
end)

CreateToggle(LeviathanPage, "Tween to Frozen Dimension", false, function(s)
    State.AutoFrozenTween = s
    if s then
        task.spawn(function()
            while State.AutoFrozenTween do
                pcall(function()
                    local fd = Workspace._WorldOrigin.Locations:FindFirstChild("Frozen Dimension")
                    if fd then FarmTeleport(fd.CFrame * CFrame.new(2, 20, 2), 200, 30) end
                end)
                task.wait(0.5)
            end
        end)
    end
end)

CreateToggle(LeviathanPage, "Auto Find Leviathan (Sail)", false, function(s) State.AutoFindLevi = s end)
CreateToggle(LeviathanPage, "Auto Attack Leviathan", false, function(s)
    State.AutoAttackLevi = s
    if s then
        task.spawn(function()
            while State.AutoAttackLevi do
                pcall(function()
                    local sb = Workspace:FindFirstChild("SeaBeasts")
                    if not sb then return end
                    for _, v in ipairs(sb:GetChildren()) do
                        if v.Name == "Leviathan" and v:FindFirstChild("HumanoidRootPart") then
                            local hp = v:FindFirstChild("Health")
                            if not hp or hp.Value > 0 then
                                EquipWeapon("Melee"); AutoHaki()
                                FarmTeleport(v.HumanoidRootPart.CFrame * CFrame.new(0, 900, 100), 200, 30)
                                v.HumanoidRootPart.CanCollide = false
                                AttackNoCoolDown()
                            end
                        end
                    end
                end)
                task.wait(0.3)
            end
        end)
    end
end)

CreateToggle(LeviathanPage, "Auto Attack Segment", false, function(s)
    State.AutoAttackLeviSeg = s
    if s then
        task.spawn(function()
            while State.AutoAttackLeviSeg do
                pcall(function()
                    local sb = Workspace:FindFirstChild("SeaBeasts")
                    if not sb then return end
                    for _, v in ipairs(sb:GetChildren()) do
                        if v.Name == "Leviathan Segment" and v:FindFirstChild("HumanoidRootPart") then
                            local hp = v:FindFirstChild("Health")
                            if not hp or hp.Value > 0 then
                                EquipWeapon("Melee"); AutoHaki()
                                FarmTeleport(v.HumanoidRootPart.CFrame * CFrame.new(0, 900, math.random(0,350)), 200, 30)
                                v.HumanoidRootPart.CanCollide = false
                                AttackNoCoolDown()
                            end
                        end
                    end
                end)
                task.wait(0.3)
            end
        end)
    end
end)

CreateToggle(LeviathanPage, "Auto Attack Tail", false, function(s)
    State.AutoAttackLeviTail = s
    if s then
        task.spawn(function()
            while State.AutoAttackLeviTail do
                pcall(function()
                    local sb = Workspace:FindFirstChild("SeaBeasts")
                    if not sb then return end
                    for _, v in ipairs(sb:GetChildren()) do
                        if v.Name == "Leviathan Tail" and v:FindFirstChild("HumanoidRootPart") then
                            local hp = v:FindFirstChild("Health")
                            if not hp or hp.Value > 0 then
                                EquipWeapon("Melee"); AutoHaki()
                                FarmTeleport(v.HumanoidRootPart.CFrame * CFrame.new(0, 900, math.random(0,350)), 200, 30)
                                v.HumanoidRootPart.CanCollide = false
                                AttackNoCoolDown()
                            end
                        end
                    end
                end)
                task.wait(0.3)
            end
        end)
    end
end)

--================================================================
-- TAB 7: KITSUNE
--================================================================
CreateLabel(KitsunePage, "=== Kitsune Island ===", 26)
local KitStatus = CreateLabel(KitsunePage, "Island: Checking...", 28)
local KitEmber = CreateLabel(KitsunePage, "Azure Ember: 0", 28)
task.spawn(function()
    while task.wait(2) do
        if not KitStatus.Parent then break end
        pcall(function()
            local ex = Workspace.Map:FindFirstChild("KitsuneIsland")
            KitStatus.Text = "Island: " .. (ex and "Spawned" or "Not Spawned")
        end)
    end
end)

CreateToggle(KitsunePage, "Auto Summon Kitsune Island", false, function(s) State.AutoKitsuneSummon = s end)
CreateToggle(KitsunePage, "Tween to Kitsune Island", false, function(s)
    getgenv().SX_KitTween = s
    if s then
        task.spawn(function()
            while getgenv().SX_KitTween do
                pcall(function()
                    local k = Workspace.Map:FindFirstChild("KitsuneIsland")
                    if k then
                        local s2 = k:FindFirstChild("ShrineActive")
                        if s2 and s2:FindFirstChild("NeonShrinePart") then
                            FarmTeleport(s2.NeonShrinePart.CFrame + Vector3.new(0,0,5), 200, 30)
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)
CreateToggle(KitsunePage, "Auto Collect Azure Ember", false, function(s) State.AutoKitsuneEmber = s end)
CreateToggle(KitsunePage, "Auto Trade Azure Ember", false, function(s) State.AutoKitsuneTrade = s end)

--================================================================
-- TAB 8: MIRAGE / PREHIST
--================================================================
CreateLabel(MiragePage, "=== Mirage Island ===", 26)
local MirStat = CreateLabel(MiragePage, "Mirage: Checking...", 28)
task.spawn(function()
    while task.wait(2) do
        if not MirStat.Parent then break end
        pcall(function()
            local exists = Workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island")
            MirStat.Text = "Mirage: " .. (exists and "Spawned" or "Not Spawned")
        end)
    end
end)

CreateToggle(MiragePage, "Auto Summon Mirage Island", false, function(s) State.AutoMirageSummon = s end)
CreateToggle(MiragePage, "Tween to Mirage Island", false, function(s)
    State.AutoMirageTween = s
    if s then
        task.spawn(function()
            while State.AutoMirageTween do
                pcall(function()
                    local mir = Workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island")
                    if mir and mir.PrimaryPart then
                        FarmTeleport(mir.PrimaryPart.CFrame * CFrame.new(0,500,0), 200, 30)
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)

CreateLabel(MiragePage, "=== Prehistoric Island ===", 26)
local PreStat = CreateLabel(MiragePage, "Prehistoric: Checking...", 28)
task.spawn(function()
    while task.wait(2) do
        if not PreStat.Parent then break end
        pcall(function()
            local exists = Workspace.Map:FindFirstChild("PrehistoricIsland")
            PreStat.Text = "Prehistoric: " .. (exists and "Spawned" or "Not Spawned")
        end)
    end
end)

CreateToggle(MiragePage, "Auto Summon Prehistoric", false, function(s) State.AutoPrehistoricSummon = s end)
CreateToggle(MiragePage, "Tween to Prehistoric", false, function(s)
    State.AutoPrehistoricTween = s
    if s then
        task.spawn(function()
            while State.AutoPrehistoricTween do
                pcall(function()
                    local pre = Workspace.Map:FindFirstChild("PrehistoricIsland")
                    if pre then FarmTeleport(pre:GetPivot() * CFrame.new(2,20,2), 200, 30) end
                end)
                task.wait(0.5)
            end
        end)
    end
end)

--================================================================
-- TAB 9: QUEST / ITEMS
--================================================================
CreateLabel(QuestItemsPage, "=== Sea Travel ===", 26)
CreateButton(QuestItemsPage, "Travel to Sea 1", function() CommF_:InvokeServer("TravelMain"); Notify("Traveling Sea 1") end)
CreateButton(QuestItemsPage, "Travel to Sea 2", function() CommF_:InvokeServer("TravelDressrosa"); Notify("Traveling Sea 2") end)
CreateButton(QuestItemsPage, "Travel to Sea 3", function() CommF_:InvokeServer("TravelZou"); Notify("Traveling Sea 3") end)

CreateLabel(QuestItemsPage, "=== Race Upgrade ===", 26)
CreateToggle(QuestItemsPage, "Auto V2", false, function(s) State.AutoV2 = s end)
CreateToggle(QuestItemsPage, "Auto V3", false, function(s) State.AutoV3 = s end)

CreateLabel(QuestItemsPage, "=== Auto Get Sword ===", 26)
CreateDropdown(QuestItemsPage, "Select Sword",
    {"Saber","Tushita","Yama","Buddy Sword","Shark Anchor","Dark Dagger","Twin Hooks","Canvander","Spikey Trident"},
    function(o) getgenv().SelectSwordQuest = o end)
getgenv().SelectSwordQuest = "Saber"
CreateToggle(QuestItemsPage, "Auto Get Selected Sword", false, function(s) getgenv().AutoGetSword = s end)
CreateToggle(QuestItemsPage, "Auto Get Cyborg Race", false, function(s) State.AutoCyborg = s end)
CreateToggle(QuestItemsPage, "Auto Get Ghoul Race", false, function(s) State.AutoGhoul = s end)
CreateToggle(QuestItemsPage, "Auto Rainbow Haki", false, function(s) State.AutoRainbowHaki = s end)

CreateLabel(QuestItemsPage, "=== Legendary Weapons ===", 26)
CreateToggle(QuestItemsPage, "Auto Soul Guitar", false, function(s) State.AutoSoulGuitar = s end)
CreateToggle(QuestItemsPage, "Auto CDK", false, function(s) State.AutoCDK = s end)
CreateToggle(QuestItemsPage, "Auto Yama", false, function(s) State.AutoYama = s end)
CreateToggle(QuestItemsPage, "Auto Tushita", false, function(s) State.AutoTushita = s end)
CreateToggle(QuestItemsPage, "Auto True Triple Katana", false, function(s) State.AutoTTK = s end)
CreateToggle(QuestItemsPage, "Auto Saber", false, function(s) State.AutoSaber = s end)
CreateToggle(QuestItemsPage, "Auto Yoru Mini", false, function(s) State.AutoYoruMini = s end)

--================================================================
-- TAB 10: FRUIT / RAID
--================================================================
CreateLabel(FruitRaidPage, "=== Fruit Management ===", 26)
CreateToggle(FruitRaidPage, "Auto Store Fruit", false, function(s) State.AutoStoreFruit = s end)
CreateToggle(FruitRaidPage, "Auto Buy Random Fruit", false, function(s) State.AutoBuyFruit = s end)
CreateToggle(FruitRaidPage, "Tween to Fruit", false, function(s) State.AutoFindFruit = s end)

CreateLabel(FruitRaidPage, "=== Raid ===", 26)
CreateDropdown(FruitRaidPage, "Select Chip",
    {"Flame","Ice","Sand","Dark","Light","Magma","Quake","Buddha","Love","Spider","Sound","Phoenix","Portal","Rumble","Pain","Blizzard","Gravity"},
    function(o) getgenv().SelectedChip = o end)
CreateToggle(FruitRaidPage, "Auto Raid", false, function(s) State.AutoRaid = s end)
CreateToggle(FruitRaidPage, "Auto Awaken Fruit", false, function(s) State.AutoAwaken = s end)

--================================================================
-- TAB 11: FISHING
--================================================================
CreateLabel(FishingPage, "=== Fishing ===", 26)
CreateToggle(FishingPage, "Auto Equip Rod", false, function(s) State.AutoEquipRod = s end)
CreateToggle(FishingPage, "Auto Fishing", false, function(s) State.AutoFishing = s end)
CreateToggle(FishingPage, "Auto Sell Fish", false, function(s) State.AutoSellFish = s end)

--================================================================
-- TAB 12: RACE V4
--================================================================
CreateLabel(RaceV4Page, "=== Race V4 ===", 26)
CreateToggle(RaceV4Page, "No Frog", false, function(s)
    if s then
        Lighting.FogEnd = 100000
        for _, d in pairs(Lighting:GetDescendants()) do
            if d:IsA("Atmosphere") then d:Destroy() end
        end
    end
end)
CreateButton(RaceV4Page, "Teleport Temple of Time", function()
    local hrp = GetHRP()
    if hrp then hrp.CFrame = CFrame.new(28286.35, 14895.30, 102.62) end
    local ms = RS:FindFirstChild("MapStash")
    local tot = ms and ms:FindFirstChild("Temple of Time")
    if tot then tot.Parent = Workspace.Map end
    Notify("At Temple of Time")
end)
CreateButton(RaceV4Page, "Teleport Ancient Clock", function() FarmTeleport(CFrame.new(29549, 15069, -88), 200, 30) end)
CreateToggle(RaceV4Page, "Auto Buy Gear", false, function(s) State.AutoBuyGearV4 = s end)
CreateToggle(RaceV4Page, "Auto Choose Gears", false, function(s) State.AutoChooseGear = s end)
CreateToggle(RaceV4Page, "Auto Finish Train Quest", false, function(s) State.AutoFinishTrain = s end)
CreateToggle(RaceV4Page, "Auto Pull Lever", false, function(s) State.AutoPullLever = s end)
CreateToggle(RaceV4Page, "Auto Trial", false, function(s) State.AutoTrial = s end)
CreateToggle(RaceV4Page, "Auto Kill After Trial", false, function(s) State.AutoKillAfterTrial = s end)

--================================================================
-- TAB 13: RACE DRACO
--================================================================
CreateLabel(RaceDracoPage, "=== Race Draco ===", 26)
CreateToggle(RaceDracoPage, "Auto Upgrade V2-V3 Draco", false, function(s) State.AutoDracoV2V3 = s end)
CreateToggle(RaceDracoPage, "Fully Trial Draco", false, function(s) State.AutoDracoTrial = s end)
CreateToggle(RaceDracoPage, "Auto Buy Gear Draco", false, function(s) getgenv().AutoBuyGearDraco = s end)
CreateToggle(RaceDracoPage, "Auto Trial Draco", false, function(s) getgenv().AutoTrialDraco = s end)

--================================================================
-- TAB 14: RACE NORMAL
--================================================================
CreateLabel(RaceNormalPage, "=== Race Normal ===", 26)
CreateToggle(RaceNormalPage, "Auto Upgrade Race V2-V3", false, function(s) getgenv().AutoUpgradeRace = s end)
CreateToggle(RaceNormalPage, "Auto Get Cyborg", false, function(s) State.AutoCyborg = s end)
CreateToggle(RaceNormalPage, "Auto Get Ghoul", false, function(s) State.AutoGhoul = s end)

--================================================================
-- TAB 15: SECRET QUEST
--================================================================
CreateLabel(SecretPage, "=== Secret Quest ===", 26)
local SQProg = CreateLabel(SecretPage, "Progress: 0/39", 28)
local SQStep = CreateLabel(SecretPage, "Current: Idle", 28)
CreateToggle(SecretPage, "Hop Server on Dead Hour", false, function(s) getgenv().SQHop = s end)
CreateToggle(SecretPage, "Auto Secret Quest", false, function(s)
    State.AutoSecretQuest = s
    if s then Notify("Secret Quest activated") end
end)

--================================================================
-- TAB 16: DUNGEON
--================================================================
CreateLabel(DungeonPage, "=== Dungeon ===", 26)
CreateDropdown(DungeonPage, "Select Weapon", {"Melee","Sword","Blox Fruit","Gun"}, function(o) getgenv().DungeonWeapon = o end)
CreateDropdown(DungeonPage, "Select Difficulty", {"Normal","Hard","Challenge"}, function(o) getgenv().DungeonDiff = o end)
CreateToggle(DungeonPage, "Auto Attack Dungeon", false, function(s) State.AutoDungeon = s end)
CreateToggle(DungeonPage, "Auto Pick Card", false, function(s) State.AutoCard = s end)
CreateToggle(DungeonPage, "Auto Join Dungeon", false, function(s) State.AutoJoinDungeon = s end)

--================================================================
-- TAB 17: VOLCANO EVENT
--================================================================
CreateLabel(VolcanoPage, "=== Volcano Event ===", 26)
CreateDropdown(VolcanoPage, "Weapon Kill Golem", {"Melee","Sword","Gun","Blox Fruit"}, function(o) getgenv().GolemWeapon = o end)
CreateDropdown(VolcanoPage, "Method Kill Golem", {"Click M1","Instant Kill"}, function(o) getgenv().GolemMethod = o end)
CreateToggle(VolcanoPage, "Auto Craft Volcanic Magnet", false, function(s) State.AutoCraftMagnet = s end)
CreateToggle(VolcanoPage, "Auto Find Prehistoric", false, function(s) getgenv().FindPrehistoric = s end)
CreateToggle(VolcanoPage, "Auto Event Prehistoric", false, function(s) State.AutoVolcano = s end)
CreateToggle(VolcanoPage, "Auto Collect Bone", false, function(s) getgenv().AutoBone = s end)
CreateToggle(VolcanoPage, "Fully Event Prehistoric", false, function(s) getgenv().FullyVolcano = s end)

--================================================================
-- TAB 18: TRIALS
--================================================================
CreateLabel(TrialsPage, "=== Race V4 Trial ===", 26)
CreateButton(TrialsPage, "Teleport Trial Door", function()
    local race = player.Data.Race.Value
    local poses = {
        Human = CFrame.new(29221.82, 14890.97, -205.99),
        Skypiea = CFrame.new(28960.15, 14919.62, 235.03),
        Fishman = CFrame.new(28231.17, 14890.97, -211.64),
        Cyborg = CFrame.new(28502.68, 14895.97, -423.72),
        Ghoul = CFrame.new(28674.24, 14890.67, 445.43),
        Mink = CFrame.new(29012.34, 14890.97, -380.14),
    }
    if poses[race] then FarmTeleport(poses[race], 200, 30) end
end)
CreateButton(TrialsPage, "Pull Lever", function()
    for _, d in ipairs(Workspace.Map["Temple of Time"]:GetDescendants()) do
        if d.Name == "ProximityPrompt" then
            pcall(function() fireproximityprompt(d, math.huge) end)
        end
    end
    Notify("Lever pulled")
end)
CreateToggle(TrialsPage, "Auto Trial V4", false, function(s) State.AutoTrial = s end)
CreateToggle(TrialsPage, "Auto Kill After Trial", false, function(s) State.AutoKillAfterTrial = s end)

--================================================================
-- TAB 19: PVP
--================================================================
CreateLabel(PvPPage, "=== PvP ===", 26)
local pvpPlayers = {"None"}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= player then table.insert(pvpPlayers, p.Name) end
end
CreateDropdown(PvPPage, "Select Player", pvpPlayers, function(o) State.SelectedPlayer = o end)
CreateToggle(PvPPage, "Teleport To Player", false, function(s) State.TeleportPlayer = s end)
CreateToggle(PvPPage, "Auto Aimbot", false, function(s) State.Aimbot = s end)
CreateSlider(PvPPage, "WalkSpeed Value", 16, 300, 100, function(v)
    getgenv().CustomWalkSpeed = v
    if getgenv().EnableWalkSpeed then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
end)
CreateSlider(PvPPage, "JumpPower Value", 50, 500, 100, function(v)
    getgenv().CustomJumpPower = v
    if getgenv().EnableJumpPower then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v end
    end
end)
CreateToggle(PvPPage, "Change WalkSpeed", false, function(s) getgenv().EnableWalkSpeed = s end)
CreateToggle(PvPPage, "Change JumpPower", false, function(s) getgenv().EnableJumpPower = s end)
CreateToggle(PvPPage, "Infinite Jump", false, function(s) getgenv().InfiniteJump = s end)
CreateToggle(PvPPage, "Walk On Water", false, function(s)
    State.WalkWater = s
    local water = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("WaterBase-Plane")
    if water then water.Size = s and Vector3.new(1000,113,1000) or Vector3.new(1000,80,1000) end
end)

--================================================================
-- TAB 20: SETING
--================================================================
CreateLabel(SetingPage, "=== ESP ===", 26)
CreateToggle(SetingPage, "ESP Player", false, function(s) State.ESPPlayer = s end)
CreateToggle(SetingPage, "ESP Fruit", false, function(s) State.ESPFruit = s end)
CreateToggle(SetingPage, "ESP Chest", false, function(s) State.ESPChest = s end)
CreateToggle(SetingPage, "ESP Island", false, function(s) State.ESPIsland = s end)
CreateToggle(SetingPage, "ESP Boss", false, function(s) State.ESPBoss = s end)

CreateLabel(SetingPage, "=== Kill Select Boss ===", 26)
local BossList = {"Greybeard","The Saw","Saber Expert","The Gorilla King","Bobby","Yeti","Vice Admiral","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Darkbeard","Cursed Captain","Order","Don Swan","Diamond","Jeremy","Fajita","Smoke Admiral","Awakened Ice Admiral","Tide Keeper","Dough King","Cake Prince","rip_indra True Form","Soul Reaper","Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate","Cake Queen","Longma"}
CreateDropdown(SetingPage, "Select Boss", BossList, function(o) State.SelectedBoss = o end)
local BossStat = CreateLabel(SetingPage, "Boss Status: -", 28)
CreateToggle(SetingPage, "Kill Select Boss", false, function(s) State.AutoBoss = s end)
CreateToggle(SetingPage, "Auto Hop If Boss Not Spawn", false, function(s) getgenv().AutoHopBoss = s end)

--================================================================
-- TAB 21: TELEPORT
--================================================================
CreateLabel(TeleportPage, "=== Island Teleport ===", 26)
CreateDropdown(TeleportPage, "Select Island", {"Sky 2","Sky 3"}, function(o) getgenv().SelectedIsland = o end)
CreateButton(TeleportPage, "Tween To Island", function()
    local isl = {
        ["Sky 2"] = Vector3.new(-4607.82, 872.54, -1667.55),
        ["Sky 3"] = Vector3.new(-7894.61, 5547.14, -380.29),
    }
    local sel = getgenv().SelectedIsland
    if sel and isl[sel] then
        CommF_:InvokeServer("requestEntrance", isl[sel])
        Notify("Traveling to " .. sel)
    end
end)

--================================================================
-- TAB 22: STATS
--================================================================
CreateLabel(StatsPage, "=== Auto Allocate Stats ===", 26)
CreateSlider(StatsPage, "Points Per Click", 1, 50, 5, function(v) State.PointsPerClick = v end)
CreateToggle(StatsPage, "Auto Melee", false, function(s) State.StatMelee = s and 1 or 0 end)
CreateToggle(StatsPage, "Auto Defense", false, function(s) State.StatDefense = s and 1 or 0 end)
CreateToggle(StatsPage, "Auto Sword", false, function(s) State.StatSword = s and 1 or 0 end)
CreateToggle(StatsPage, "Auto Gun", false, function(s) State.StatGun = s and 1 or 0 end)
CreateToggle(StatsPage, "Auto Blox Fruit", false, function(s) State.StatFruit = s and 1 or 0 end)
CreateToggle(StatsPage, "Enable Auto Stats", false, function(s) State.AutoStats = s end)

--================================================================
-- TAB 23: SHOP
--================================================================
CreateLabel(ShopPage, "=== Fighting Style ===", 26)
CreateButton(ShopPage, "Buy Black Leg", function() TryBuy("BuyBlackLeg") end)
CreateButton(ShopPage, "Buy Electro", function() TryBuy("BuyElectro") end)
CreateButton(ShopPage, "Buy Fishman Karate", function() TryBuy("BuyFishmanKarate") end)
CreateButton(ShopPage, "Buy Superhuman", function() TryBuy("BuySuperhuman") end)
CreateButton(ShopPage, "Buy Death Step", function() TryBuy("BuyDeathStep") end)
CreateButton(ShopPage, "Buy Sharkman Karate", function() TryBuy("BuySharkmanKarate") end)
CreateButton(ShopPage, "Buy Electric Claw", function() TryBuy("BuyElectricClaw") end)
CreateButton(ShopPage, "Buy Dragon Talon", function() TryBuy("BuyDragonTalon") end)
CreateButton(ShopPage, "Buy God Human", function() TryBuy("BuyGodhuman") end)
CreateButton(ShopPage, "Buy Sanguine Art", function() TryBuy("BuySanguineArt") end)

CreateLabel(ShopPage, "=== Abilities ===", 26)
CreateButton(ShopPage, "Buy Geppo", function() TryBuy("BuyHaki", "Geppo") end)
CreateButton(ShopPage, "Buy Buso", function() TryBuy("BuyHaki", "Buso") end)
CreateButton(ShopPage, "Buy Ken", function() TryBuy("KenTalk", "Buy") end)
CreateButton(ShopPage, "Buy Soru", function() TryBuy("BuyHaki", "Soru") end)

CreateLabel(ShopPage, "=== Misc ===", 26)
CreateButton(ShopPage, "Buy Stat Refund", function()
    TryBuy("BlackbeardReward", "Refund", "1"); task.wait(0.3); TryBuy("BlackbeardReward", "Refund", "2")
end)
CreateButton(ShopPage, "Buy Race Reroll", function()
    TryBuy("BlackbeardReward", "Reroll", "1"); task.wait(0.3); TryBuy("BlackbeardReward", "Reroll", "2")
end)
CreateButton(ShopPage, "Buy Ghoul Race", function()
    TryBuy("Ectoplasm", "BuyCheck", 4); task.wait(0.3); TryBuy("Ectoplasm", "Change", 4)
end)
CreateButton(ShopPage, "Buy Cyborg Race", function() TryBuy("CyborgTrainer", "Buy") end)
CreateButton(ShopPage, "Buy Dual Flintlock", function() TryBuy("BuyItem", "Dual Flintlock") end)
CreateButton(ShopPage, "Buy Legendary Swords", function()
    TryBuy("LegendarySwordDealer", "1"); TryBuy("LegendarySwordDealer", "2"); TryBuy("LegendarySwordDealer", "3")
end)
CreateButton(ShopPage, "Buy True Triple Katana", function()
    TryBuy("MysteriousMan", "1"); TryBuy("MysteriousMan", "2")
end)

--================================================================
-- TAB 24: MISC
--================================================================
CreateLabel(MiscPage, "=== Combat ===", 26)
CreateToggle(MiscPage, "Fast Attack", true, function(s) State.FastAttack = s end)
CreateToggle(MiscPage, "Bring Mob", true, function(s) State.BringMob = s end)
CreateSlider(MiscPage, "Bring Mob Range", 50, 1000, 300, function(v) State.BringRange = v end)
CreateSlider(MiscPage, "Tween Speed", 100, 500, 300, function(v)
    getgenv().TweenSpeed = v
    Notify("Tween Speed: " .. v)
end)

CreateLabel(MiscPage, "=== Local ===", 26)
CreateToggle(MiscPage, "Anti AFK", true, function(s) State.AntiAFK = s end)
CreateToggle(MiscPage, "No Clip", false, function(s) State.Noclip = s end)
CreateToggle(MiscPage, "Hide Mob", false, function(s) State.HideMob = s end)
CreateToggle(MiscPage, "Auto Ken", false, function(s) State.AutoKen = s end)

CreateLabel(MiscPage, "=== Server ===", 26)
CreateButton(MiscPage, "Rejoin Server", function() TeleportService:Teleport(game.PlaceId, player) end)
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
    end
end)
CreateToggle(MiscPage, "Remove Damage Numbers", false, function(s) State.RemoveDamage = s end)
CreateToggle(MiscPage, "Remove Notifications", false, function(s) State.RemoveNotifications = s end)

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
-- TAB 25: WEBHOOK
--================================================================
CreateLabel(WebhookPage, "=== Discord Webhook ===", 26)
CreateLabel(WebhookPage, "Configure your webhook URL. Notifications sent on events.", 40).TextSize = 11
CreateButton(WebhookPage, "Set Webhook URL (Clipboard)", function()
    local url = ""
    pcall(function()
        if getclipboard then url = getclipboard() end
    end)
    if url and url ~= "" then
        getgenv().WebhookURL = url
        Notify("Webhook URL set")
    else
        Notify("Copy URL to clipboard first")
    end
end)
CreateToggle(WebhookPage, "Webhook Store Fruit", false, function(s) State.WebhookFruit = s end)
CreateToggle(WebhookPage, "Webhook Find Mirage", false, function(s) State.WebhookMirage = s end)
CreateToggle(WebhookPage, "Webhook Find Leviathan", false, function(s) State.WebhookLevi = s end)
CreateToggle(WebhookPage, "Webhook Find Prehistoric", false, function(s) State.WebhookPre = s end)

--================================================================
-- TAB 26: SETTING
--================================================================
CreateLabel(SettingPage, "=== Display ===", 26)
CreateToggle(SettingPage, "White Screen", false, function(s)
    pcall(function() RunService:Set3dRenderingEnabled(not s) end)
end)
CreateToggle(SettingPage, "Black Screen", false, function(s)
    local gui = playerGui:FindFirstChild("SX_BlackScreen")
    if s then
        if not gui then
            gui = Instance.new("ScreenGui")
            gui.Name = "SX_BlackScreen"
            gui.Parent = playerGui
            gui.IgnoreGuiInset = true
            gui.DisplayOrder = 999998
            local f = Instance.new("Frame")
            f.Size = UDim2.fromScale(1,1)
            f.BackgroundColor3 = Color3.new(0,0,0)
            f.BorderSizePixel = 0
            f.Parent = gui
        end
    elseif gui then gui:Destroy() end
end)

CreateLabel(SettingPage, "=== Performance ===", 26)
CreateSlider(SettingPage, "FPS Cap", 15, 240, 60, function(v)
    pcall(function() if setfpscap then setfpscap(v) end end)
end)

CreateLabel(SettingPage, "=== Config ===", 26)
CreateButton(SettingPage, "Reset All Settings", function()
    Notify("Config reset. Rejoin to apply.")
end)

--================================================================
-- MAIN LOOPS
--================================================================
task.spawn(function()
    while task.wait(0.5) do
        pcall(function() if State.AutoHaki then AutoHaki() end end)
    end
end)

task.spawn(function()
    while task.wait(0.4) do
        if State.AutoFarm then
            pcall(function()
                local hrp = GetHRP()
                if not hrp then return end
                local char = player.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not hum or hum.Health <= 0 then return end

                local hasQuest = false
                local questMob = nil
                local qf = playerGui:FindFirstChild("TrackedQuestFrame")
                if qf then
                    local inner = qf:FindFirstChild("Frame")
                    if inner and inner.Visible then
                        hasQuest = true
                        local lbl = inner:FindFirstChild("QuestTitle") or inner:FindFirstChild("Title") or inner:FindFirstChild("TaskTitle")
                        if lbl and lbl.Text then
                            questMob = lbl.Text:match("Defeat%s+([^%[]+)") or lbl.Text:match("^([^%[]+)")
                            if questMob then questMob = questMob:gsub("%s+$",""):gsub("%(.*%)",""):gsub("%s+$","") end
                        end
                    end
                end

                if hasQuest and questMob then
                    local enemy = FindEnemy({questMob}, 99999)
                    if enemy then
                        local trp = enemy:FindFirstChild("HumanoidRootPart")
                        if trp then
                            AutoHaki()
                            EquipWeapon(State.SelectedWeapon)
                            local d = (trp.Position - hrp.Position).Magnitude
                            if d > 25 then
                                FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), 200, 20)
                            else
                                trp.CanCollide = false
                                trp.Size = Vector3.new(60,60,60)
                                if enemy:FindFirstChild("Humanoid") then enemy.Humanoid.WalkSpeed = 0 end
                                AttackNoCoolDown()
                            end
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.35) do
        if State.AutoFarmNearest then
            pcall(function()
                local hrp = GetHRP()
                if not hrp then return end
                local enemies = Workspace:FindFirstChild("Enemies")
                if not enemies then return end
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
                        AutoHaki()
                        EquipWeapon(State.SelectedWeapon)
                        local d = (trp.Position - hrp.Position).Magnitude
                        if d > 25 then FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), 200, 20) end
                        trp.CanCollide = false
                        trp.Size = Vector3.new(60,60,60)
                        if best:FindFirstChild("Humanoid") then best.Humanoid.WalkSpeed = 0 end
                        AttackNoCoolDown()
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if State.AutoChest then
            pcall(function()
                local hrp = GetHRP()
                if not hrp then return end
                local chests = GetSortedChests()
                if #chests > 0 then
                    local target = chests[1]
                    FarmTeleport(target.CFrame + Vector3.new(0, 2, 0), 200, 20)
                    pcall(function()
                        firetouchinterest(hrp, target, 0)
                        task.wait(0.05)
                        firetouchinterest(hrp, target, 1)
                    end)
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if State.AutoFarmBones then
            pcall(function()
                local enemy = FindEnemy({"Reborn Skeleton","Living Zombie","Demonic Soul","Posessed Mummy"}, 5000)
                if enemy then
                    local trp = enemy:FindFirstChild("HumanoidRootPart")
                    if trp then
                        AutoHaki()
                        EquipWeapon(State.SelectedWeapon)
                        FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), 200, 20)
                        trp.CanCollide = false
                        if enemy:FindFirstChild("Humanoid") then enemy.Humanoid.WalkSpeed = 0 end
                        AttackNoCoolDown()
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.4) do
        if State.AutoBoss and State.SelectedBoss then
            pcall(function()
                local enemy = FindEnemy({State.SelectedBoss}, 99999)
                local rsBoss = RS:FindFirstChild(State.SelectedBoss)
                local spawned = enemy ~= nil or (rsBoss and rsBoss:FindFirstChild("HumanoidRootPart") ~= nil)
                if BossStat and BossStat.Parent then
                    BossStat.Text = "Boss Status: " .. (spawned and "Spawned" or "Not Spawned")
                end
                if enemy then
                    local trp = enemy:FindFirstChild("HumanoidRootPart")
                    if trp then
                        AutoHaki()
                        EquipWeapon(State.SelectedWeapon)
                        FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), 200, 20)
                        trp.CanCollide = false
                        trp.Size = Vector3.new(80,80,80)
                        if enemy:FindFirstChild("Humanoid") then enemy.Humanoid.WalkSpeed = 0 end
                        AttackNoCoolDown()
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.05) do
        if State.FastAttack and IsAlive() then
            pcall(AttackNoCoolDown)
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if State.BringMob and AnyFarmActive() then
            pcall(BringMobToPlayer, State.BringRange)
        end
    end
end)

RunService.Stepped:Connect(function()
    if State.Noclip and player.Character then
        pcall(function()
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.HideMob then
            pcall(function()
                local enemies = Workspace:FindFirstChild("Enemies")
                if not enemies then return end
                for _, e in pairs(enemies:GetDescendants()) do
                    if e:IsA("BasePart") and e.Transparency < 1 then e.Transparency = 1 end
                end
            end)
        end
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
        if State.AutoStats then
            pcall(function()
                local stats = {{"Melee",State.StatMelee},{"Defense",State.StatDefense},{"Sword",State.StatSword},{"Gun",State.StatGun},{"Demon Fruit",State.StatFruit}}
                for _, s in ipairs(stats) do
                    if s[2] == 1 then
                        CommF_:InvokeServer("AddPoint", s[1], State.PointsPerClick)
                        task.wait(0.3)
                    end
                end
            end)
        end
    end
end)

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

UserInputService.JumpRequest:Connect(function()
    if getgenv().InfiniteJump then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

player.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if State.TeleportPlayer and State.SelectedPlayer then
            pcall(function()
                local p = Players:FindFirstChild(State.SelectedPlayer)
                if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    FarmTeleport(p.Character.HumanoidRootPart.CFrame, 200, 30)
                end
            end)
        end
    end
end)

--================================================================
-- DRAG FUNCTIONS
--================================================================
local function MakeDraggable(object, handle)
    handle = handle or object
    local dragging = false
    local dragStart
    local startPosition
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
        if dragging then
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
        end
    end)
end

MakeDraggable(logo)
MakeDraggable(main, header)

--================================================================
-- UI OPEN/CLOSE
--================================================================
local function OpenUI()
    main.Visible = true
    main.Size = UDim2.fromOffset(700, 540)
    main.Position = UDim2.new(0.5, -350, 0.5, -270)
    TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quint),
        {Size=UDim2.fromOffset(720,560), Position=UDim2.new(0.5,-360,0.5,-280)}):Play()
end

local function CloseUI()
    local tw = TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quint),
        {Size=UDim2.fromOffset(700,540), Position=UDim2.new(0.5,-350,0.5,-270)})
    tw:Play()
    tw.Completed:Once(function() main.Visible = false end)
end

local logoMoved = false
local logoDragStart = nil
logo.InputBegan:Connect(function()
    logoMoved = false
    logoDragStart = tick()
end)
logo.MouseButton1Click:Connect(function()
    if tick() - (logoDragStart or 0) < 0.2 then
        if main.Visible then CloseUI() else OpenUI() end
    end
end)

close.Activated:Connect(CloseUI)

--================================================================
-- STARTUP
--================================================================
ShowTab("Farm")
Notify("SysxHub v1.0 Loaded")
