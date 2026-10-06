--[[
================================================================
    SYSX HUB | FREEMIUM VERSION | v1.0
    Discord: https://discord.gg/xWa9NpFRr
    Theme: Dynamic Blue Outline | Simple ON/OFF Toggle
    Tabs: 13 | Visual Tab = ESP Only
    Platform: Blox Fruits | Mobile Friendly
================================================================
]]

--================================================================
-- ASSETS
--================================================================
local a = "rbxassetid://114593995135483"
local b = "rbxassetid://71457853614279"

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
-- THEME: DYNAMIC BLUE OUTLINE
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

    -- Static colors (no animation)
    Static_Blue = Color3.fromRGB(60, 130, 220),
    Static_BlueSoft = Color3.fromRGB(180, 220, 255),
    Toggle_On = Color3.fromRGB(30, 100, 180),
    Toggle_Off = Color3.fromRGB(55, 60, 80),
    Toggle_DotOn = Color3.fromRGB(255, 255, 255),
    Toggle_DotOff = Color3.fromRGB(180, 185, 200),
}

-- REGISTRY: hanya UIStroke yang di-animasikan
local ACCENT_REGISTRY = {}
local function RegisterAccent(strokeObj)
    if strokeObj and strokeObj:IsA("UIStroke") then
        table.insert(ACCENT_REGISTRY, strokeObj)
    end
end

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
        StarterGui:SetCore("SendNotification", {Title="SysxHub", Text="Blox Fruits only", Duration=5})
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
local CommF_ = Remotes:WaitForChild("CommF_", 10)
local Modules = RS:FindFirstChild("Modules")
local Net = Modules and Modules:FindFirstChild("Net")

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
    AutoSecretQuest=false,
    AutoMasteryMelee=false, AutoMasterySword=false, AutoMasteryGun=false,
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
    AutoHaki=true,
    AutoSharkTooth=false, AutoTerrorJaw=false, AutoMonsterMagnet=false, AutoSharkAnchor=false,
    AutoRainbowHaki=false, AutoSoulGuitar=false, AutoCDK=false, AutoYama=false,
    AutoTushita=false, AutoTTK=false, AutoSaber=false, AutoYoruMini=false,
    AutoCyborg=false, AutoGhoul=false,
    WebhookFruit=false, WebhookMirage=false, WebhookLevi=false, WebhookPre=false,
    AutoSniper=false, AutoSniperMirage=false, AutoSpawnerFruit=false,
    AutoDropFruit=false, AutoEatFruit=false,
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
-- FIND ENEMY / BRING
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
-- ESP SYSTEM
--================================================================
local function CreateESP(part, text, color)
    if not part or not part:IsA("BasePart") then return end
    if State.ESPObjects[part] and State.ESPObjects[part].Parent then
        local lbl = State.ESPObjects[part]:FindFirstChild("SX_ESP_Label")
        if lbl then lbl.Text = text end
        return
    end
    local bb = Instance.new("BillboardGui")
    bb.Name = "SX_ESP_BB"
    bb.Size = UDim2.new(0, 150, 0, 40)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = part
    local lbl = Instance.new("TextLabel")
    lbl.Name = "SX_ESP_Label"
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.new(0,0,0)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold
    lbl.Parent = bb
    State.ESPObjects[part] = bb
end

local function ClearESP()
    for part, bb in pairs(State.ESPObjects) do
        pcall(function() bb:Destroy() end)
        State.ESPObjects[part] = nil
    end
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

-- Notification
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
local notifStroke = Stroke(Notif, BLUE_PALETTE[1], 1.5, 0.2)
RegisterAccent(notifStroke)

-- Floating Logo
local logo = Create("ImageButton", {
    Parent = gui,
    Size = UDim2.fromOffset(60, 60),
    Position = UDim2.new(0, 18, 0.5, -30),
    BackgroundColor3 = THEME.BG_Secondary,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    Image = a,
    ScaleType = Enum.ScaleType.Fit,
    AutoButtonColor = false,
    ZIndex = 100,
})
Corner(logo, 20)
local logoStroke = Stroke(logo, BLUE_PALETTE[1], 2, 0.1)
RegisterAccent(logoStroke)

-- Main UI
local main = Create("Frame", {
    Parent = gui,
    Size = UDim2.fromOffset(700, 540),
    Position = UDim2.new(0.5, -350, 0.5, -270),
    BackgroundColor3 = THEME.BG_Main,
    BorderSizePixel = 0,
    Visible = false,
    ClipsDescendants = true,
    ZIndex = 10,
})
Corner(main, 18)
local mainStroke = Stroke(main, BLUE_PALETTE[1], 1.2, 0.45)
RegisterAccent(mainStroke)

-- Header
local header = Create("Frame", {
    Parent = main,
    Size = UDim2.new(1, 0, 0, 74),
    BackgroundTransparency = 1,
    ZIndex = 20,
})
Create("ImageLabel", {
    Parent = header, Size = UDim2.fromOffset(50, 50),
    Position = UDim2.fromOffset(14, 10),
    BackgroundTransparency = 1, Image = a,
    ScaleType = Enum.ScaleType.Fit, ZIndex = 22,
})
Create("TextLabel", {
    Parent = header, BackgroundTransparency = 1,
    Position = UDim2.fromOffset(74, 4),
    Size = UDim2.fromOffset(340, 22),
    Text = "SysxHub",
    TextColor3 = THEME.Accent_Bright,
    TextSize = 20, Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 22,
})
Create("TextLabel", {
    Parent = header, BackgroundTransparency = 1,
    Position = UDim2.fromOffset(74, 26),
    Size = UDim2.fromOffset(340, 15),
    Text = "Freemium Version  •  v1.0",
    TextColor3 = THEME.Text_Secondary,
    TextSize = 10, Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 22,
})
local lvlLabel = Create("TextLabel", {
    Parent = header, BackgroundTransparency = 1,
    Position = UDim2.fromOffset(74, 43),
    Size = UDim2.fromOffset(340, 15),
    Text = "Lv: 1  •  Sea 1",
    TextColor3 = THEME.Static_BlueSoft,
    TextSize = 10, Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 22,
})
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

local close = Create("ImageButton", {
    Parent = header,
    Size = UDim2.fromOffset(36, 36),
    Position = UDim2.new(1, -52, 0, 12),
    BackgroundColor3 = THEME.BG_Secondary,
    BackgroundTransparency = 0.1,
    Image = a, ImageColor3 = THEME.Static_BlueSoft,
    ScaleType = Enum.ScaleType.Fit,
    AutoButtonColor = false, ZIndex = 25,
})
Corner(close, 10)
local closeStroke = Stroke(close, BLUE_PALETTE[1], 1.2, 0.35)
RegisterAccent(closeStroke)

Create("Frame", {
    Parent = header,
    Size = UDim2.new(1, -32, 0, 1),
    Position = UDim2.new(0, 16, 1, -2),
    BackgroundColor3 = Color3.fromRGB(60, 90, 150),
    BackgroundTransparency = 0.6,
    BorderSizePixel = 0, ZIndex = 22,
})

-- Banner
local banner = Create("Frame", {
    Parent = main,
    Size = UDim2.new(1, -32, 0, 120),
    Position = UDim2.fromOffset(16, 88),
    BackgroundColor3 = THEME.BG_Secondary,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 12,
})
Corner(banner, 14)
Stroke(banner, THEME.Border, 1, 0.35)
Create("ImageLabel", {
    Parent = banner, Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1, Image = b,
    ScaleType = Enum.ScaleType.Crop, ZIndex = 12,
})
Create("Frame", {
    Parent = banner, Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(5, 8, 18),
    BackgroundTransparency = 0.7,
    BorderSizePixel = 0, ZIndex = 13,
})

-- Content
local content = Create("Frame", {
    Parent = main,
    Size = UDim2.new(1, -32, 1, -240),
    Position = UDim2.fromOffset(16, 224),
    BackgroundTransparency = 1,
    ZIndex = 14,
})

-- Sidebar
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
        Text = name,
        TextColor3 = THEME.Text_Secondary,
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 18,
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
-- TOGGLE (Simple ON/OFF, static indicator)
--================================================================
local function CreateToggle(parent, text, default, cb)
    local state = default and true or false

    local B = Create("TextButton", {
        Parent = parent,
        BackgroundColor3 = THEME.BG_Secondary,
        Size = UDim2.new(1, 0, 0, 38),
        Text = "", AutoButtonColor = false,
        BorderSizePixel = 0, ZIndex = 100,
    })
    Corner(B, 9)
    local btnStroke = Stroke(B, BLUE_PALETTE[1], 1, 0.55)
    RegisterAccent(btnStroke)

    Create("TextLabel", {
        Parent = B, BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -58, 1, 0),
        Text = text,
        TextColor3 = THEME.Text_Primary,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 101,
    })

    local Ind = Create("Frame", {
        Parent = B,
        BackgroundColor3 = THEME.Toggle_Off,
        Size = UDim2.fromOffset(36, 20),
        Position = UDim2.new(1, -48, 0.5, -10),
        ZIndex = 101,
    })
    Corner(Ind, 20)

    local Dot = Create("Frame", {
        Parent = Ind,
        BackgroundColor3 = THEME.Toggle_DotOff,
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(0, 3, 0.5, -7),
        ZIndex = 102,
    })
    Corner(Dot, 20)

    local function render()
        if state then
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
        state = not state
        render()
        if cb then pcall(cb, state) end
    end)

    render()
    if state and cb then
        task.defer(function() pcall(cb, true) end)
    end

    return B
end

--================================================================
-- BUTTON
--================================================================
local function CreateButton(parent, text, cb)
    local B = Create("TextButton", {
        Parent = parent,
        BackgroundColor3 = THEME.BG_Secondary,
        Size = UDim2.new(1, 0, 0, 38),
        Text = text,
        TextColor3 = THEME.Text_Primary,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = false,
        BorderSizePixel = 0, ZIndex = 100,
    })
    Corner(B, 9)
    local btnStroke = Stroke(B, BLUE_PALETTE[1], 1.1, 0.55)
    RegisterAccent(btnStroke)
    B.MouseEnter:Connect(function() TW(B, {BackgroundColor3 = THEME.BG_Hover}, 0.15) end)
    B.MouseLeave:Connect(function() TW(B, {BackgroundColor3 = THEME.BG_Secondary}, 0.15) end)
    B.Activated:Connect(function()
        TW(B, {BackgroundColor3 = THEME.BG_Active}, 0.08)
        task.delay(0.1, function() TW(B, {BackgroundColor3 = THEME.BG_Secondary}, 0.15) end)
        if cb then pcall(cb) end
    end)
    return B
end

--================================================================
-- DROPDOWN
--================================================================
local function CreateDropdown(parent, title, options, cb)
    options = options or {"-"}
    local Hold = Create("Frame", {
        Parent = parent,
        BackgroundColor3 = THEME.BG_Secondary,
        Size = UDim2.new(1, 0, 0, 38),
        BorderSizePixel = 0, ZIndex = 100,
    })
    Corner(Hold, 9)
    local holdStroke = Stroke(Hold, BLUE_PALETTE[1], 1.1, 0.55)
    RegisterAccent(holdStroke)
    local Sel = options[1] or "-"
    local Lbl = Create("TextLabel", {
        Parent = Hold, BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -32, 1, 0),
        Text = title .. ": " .. Sel,
        TextColor3 = THEME.Text_Primary,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 101,
    })
    Create("TextLabel", {
        Parent = Hold, BackgroundTransparency = 1,
        Position = UDim2.new(1, -22, 0, 0),
        Size = UDim2.new(0, 16, 1, 0),
        Text = "v",
        TextColor3 = THEME.Static_BlueSoft,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        ZIndex = 101,
    })
    local clickBtn = Create("TextButton", {
        Parent = Hold, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "", AutoButtonColor = false, ZIndex = 110,
    })
    clickBtn.Activated:Connect(function()
        local Pop = Create("Frame", {
            Parent = gui,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.fromOffset(300, math.min(#options*38+80, 420)),
            BackgroundColor3 = THEME.BG_Secondary,
            BorderSizePixel = 0, ZIndex = 999990,
        })
        Corner(Pop, 14)
        local popStroke = Stroke(Pop, BLUE_PALETTE[1], 1.5, 0.25)
        RegisterAccent(popStroke)
        Create("TextLabel", {
            Parent = Pop, BackgroundTransparency = 1,
            Position = UDim2.fromOffset(18, 10),
            Size = UDim2.new(1, -60, 0, 22),
            Text = title,
            TextColor3 = THEME.Accent_Bright,
            TextSize = 14, Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 999991,
        })
        local xBtn = Create("TextButton", {
            Parent = Pop,
            Position = UDim2.new(1, -40, 0, 10),
            Size = UDim2.fromOffset(28, 22),
            Text = "x",
            TextColor3 = THEME.Text_Muted,
            TextSize = 14,
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
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
                Parent = LS,
                BackgroundColor3 = THEME.BG_Tertiary,
                Size = UDim2.new(1, -8, 0, 34),
                Position = UDim2.new(0, 4, 0, 0),
                Text = opt,
                TextColor3 = THEME.Text_Primary,
                TextSize = 12,
                Font = Enum.Font.GothamMedium,
                AutoButtonColor = false,
                BorderSizePixel = 0, LayoutOrder = i,
                ZIndex = 999992,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
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

--================================================================
-- SLIDER
--================================================================
local function CreateSlider(parent, title, minV, maxV, defV, cb)
    local val = defV or minV
    local Hold = Create("Frame", {
        Parent = parent,
        BackgroundColor3 = THEME.BG_Secondary,
        Size = UDim2.new(1, 0, 0, 58),
        BorderSizePixel = 0, ZIndex = 100,
    })
    Corner(Hold, 9)
    local holdStroke = Stroke(Hold, BLUE_PALETTE[1], 1, 0.55)
    RegisterAccent(holdStroke)
    Create("TextLabel", {
        Parent = Hold, BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 8),
        Size = UDim2.new(1, -90, 0, 16),
        Text = title,
        TextColor3 = THEME.Text_Secondary,
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 101,
    })
    local ValHolder = Create("Frame", {
        Parent = Hold,
        BackgroundColor3 = THEME.BG_Tertiary,
        Position = UDim2.new(1, -74, 0, 6),
        Size = UDim2.fromOffset(60, 20),
        ZIndex = 101,
    })
    Corner(ValHolder, 6)
    Stroke(ValHolder, THEME.Border, 1, 0.4)
    local ValLbl = Create("TextLabel", {
        Parent = ValHolder, BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = tostring(val),
        TextColor3 = THEME.Static_BlueSoft,
        TextSize = 11,
        Font = Enum.Font.GothamBold, ZIndex = 102,
    })
    local TrackBg = Create("Frame", {
        Parent = Hold,
        BackgroundColor3 = THEME.BG_Tertiary,
        Position = UDim2.new(0, 14, 0, 36),
        Size = UDim2.new(1, -28, 0, 6),
        BorderSizePixel = 0, ZIndex = 101,
    })
    Corner(TrackBg, 4)
    local fillRatio = (val - minV) / (maxV - minV)
    local Fill = Create("Frame", {
        Parent = TrackBg,
        BackgroundColor3 = THEME.Static_Blue,
        Size = UDim2.new(fillRatio, 0, 1, 0),
        BorderSizePixel = 0, ZIndex = 102,
    })
    Corner(Fill, 4)
    local Knob = Create("Frame", {
        Parent = TrackBg,
        BackgroundColor3 = Color3.new(1, 1, 1),
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(fillRatio, -7, 0.5, -7),
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
        end
    end)
    return Hold
end

--================================================================
-- LABEL
--================================================================
local function CreateLabel(parent, text, sz)
    local L = Create("TextLabel", {
        Parent = parent,
        BackgroundColor3 = THEME.BG_Secondary,
        Size = UDim2.new(1, 0, 0, sz or 28),
        Text = text,
        TextColor3 = THEME.Text_Primary,
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        BorderSizePixel = 0, ZIndex = 100,
    })
    Corner(L, 9)
    local lblStroke = Stroke(L, BLUE_PALETTE[1], 1, 0.55)
    RegisterAccent(lblStroke)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingTop = UDim.new(0, 6)
    pad.Parent = L
    return L
end

--================================================================
-- NOTIFY FUNCTION
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
    local args = {...}
    local ok = pcall(function() return CommF_:InvokeServer(cmd, table.unpack(args)) end)
    Notify(ok and "Purchased: " .. cmd or "Failed: " .. cmd)
end

--================================================================
-- DYNAMIC BLUE ANIMATION (OUTLINE ONLY)
--================================================================
local colorIndex = 1
task.spawn(function()
    while task.wait(3) do
        colorIndex = (colorIndex % #BLUE_PALETTE) + 1
        local targetColor = BLUE_PALETTE[colorIndex]
        for _, stroke in ipairs(ACCENT_REGISTRY) do
            if stroke and stroke.Parent then
                pcall(function()
                    TweenService:Create(stroke,
                        TweenInfo.new(2.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                        {Color = targetColor}):Play()
                end)
            end
        end
    end
end)

--================================================================
-- PAGES
--================================================================
local HomePage = CreatePage("Home")
local FarmPage = CreatePage("Farm")
local CombatPage = CreatePage("Combat")
local SeaPage = CreatePage("Sea")
local EventsPage = CreatePage("Events")
local RacePage = CreatePage("Race")
local WeaponsPage = CreatePage("Weapons")
local FruitsPage = CreatePage("Fruits")
local FishingPage = CreatePage("Fishing")
local ShopPage = CreatePage("Shop")
local TeleportPage = CreatePage("Teleport")
local VisualPage = CreatePage("Visual")
local SettingsPage = CreatePage("Settings")

local TabDefs = {{"Home"},{"Farm"},{"Combat"},{"Sea"},{"Events"},{"Race"},{"Weapons"},{"Fruits"},{"Fishing"},{"Shop"},{"Teleport"},{"Visual"},{"Settings"}}
for i, d in ipairs(TabDefs) do
    local btn = CreateTab(d[1], i)
    btn.Activated:Connect(function() ShowTab(d[1]) end)
end

--================================================================
-- TAB: HOME
--================================================================
CreateLabel(HomePage, "=== SysxHub Community ===", 32)
local homeInfo = CreateLabel(HomePage,
    "Welcome to SysxHub!\n\n" ..
    "  Version  :  Freemium v1.0\n" ..
    "  Platform :  Blox Fruits\n" ..
    "  Features :  290+\n\n" ..
    "Join our Discord for updates and free keys.",
    110)
homeInfo.TextSize = 11
homeInfo.TextYAlignment = Enum.TextYAlignment.Top

CreateButton(HomePage, "Join Discord Server", function()
    if setclipboard then setclipboard(DISCORD_INVITE) end
    pcall(function() GuiService:OpenBrowserWindow(DISCORD_INVITE) end)
    Notify("Opening Discord...")
end)

CreateLabel(HomePage, "=== Features ===", 26)
local homeFeat = CreateLabel(HomePage,
    "  -  Full Auto Farm\n" ..
    "  -  Auto Mastery 600\n" ..
    "  -  Race V4 / Draco / Normal\n" ..
    "  -  Auto Leviathan / Kitsune / Mirage\n" ..
    "  -  Events: Volcano, Dungeon\n" ..
    "  -  Weapon Collector\n" ..
    "  -  ESP + Aimbot + PvP\n" ..
    "  -  Webhook Discord Integration",
    160)
homeFeat.TextSize = 11
homeFeat.TextYAlignment = Enum.TextYAlignment.Top

CreateLabel(HomePage, "SysxHub | Freemium Version | v1.0", 34)

--================================================================
-- TAB: FARM
--================================================================
CreateLabel(FarmPage, "=== Farm Settings ===", 26)
CreateDropdown(FarmPage, "Select Weapon", {"Melee","Sword","Blox Fruit","Gun"}, function(o) State.SelectedWeapon = o end)
CreateSlider(FarmPage, "Farm Distance", 5, 50, 20, function(v) getgenv().FarmDistance = v end)
CreateToggle(FarmPage, "Auto Farm Level", false, function(s)
    State.AutoFarm = s
    Notify(s and "Auto Farm Level ON" or "Auto Farm Level OFF")
end)
CreateSlider(FarmPage, "Farm Fly Speed", 50, 300, 200, function(v) getgenv().FarmSpeed = v end)
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

CreateLabel(FarmPage, "=== Special Bosses ===", 26)
CreateToggle(FarmPage, "Auto Cake Prince", false, function(s) State.AutoCakePrince = s end)
CreateToggle(FarmPage, "Auto Dough King", false, function(s) State.AutoDoughKing = s end)
CreateToggle(FarmPage, "Auto Elite Hunter", false, function(s) State.AutoEliteHunter = s end)
CreateToggle(FarmPage, "Auto Soul Reaper", false, function(s) State.AutoSoulReaper = s end)
CreateToggle(FarmPage, "Auto Factory", false, function(s) State.AutoFactory = s end)
CreateToggle(FarmPage, "Auto Pirates Sea", false, function(s) State.AutoPiratesSea = s end)
CreateToggle(FarmPage, "Auto Kill Tyrant", false, function(s) State.AutoTyrant = s end)
CreateToggle(FarmPage, "Auto Citizen Quest", false, function(s) State.AutoCitizen = s end)
CreateToggle(FarmPage, "Auto Dragon Hunter", false, function(s) State.AutoDragonHunter = s end)

CreateLabel(FarmPage, "=== Auto Mastery 600 ===", 26)
local MasteryStatus = CreateLabel(FarmPage, "Status: Idle", 32)
MasteryStatus.TextSize = 11
CreateToggle(FarmPage, "Auto Mastery 600 [Melee]", false, function(s)
    State.AutoMasteryMelee = s
    if s then
        task.spawn(function()
            while State.AutoMasteryMelee do
                pcall(function()
                    MasteryStatus.Text = "Farming Melee Mastery..."
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
CreateToggle(FarmPage, "Auto Mastery 600 [Sword]", false, function(s)
    State.AutoMasterySword = s
    if s then
        task.spawn(function()
            while State.AutoMasterySword do
                pcall(function()
                    MasteryStatus.Text = "Farming Sword Mastery..."
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
CreateToggle(FarmPage, "Auto Mastery 600 [Gun]", false, function(s)
    State.AutoMasteryGun = s
    if s then
        task.spawn(function()
            while State.AutoMasteryGun do
                pcall(function()
                    MasteryStatus.Text = "Farming Gun Mastery..."
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
-- TAB: COMBAT
--================================================================
CreateLabel(CombatPage, "=== Combat Settings ===", 26)
CreateToggle(CombatPage, "Fast Attack", true, function(s) State.FastAttack = s end)
CreateToggle(CombatPage, "Bring Mob", true, function(s) State.BringMob = s end)
CreateSlider(CombatPage, "Bring Mob Range", 50, 1000, 300, function(v) State.BringRange = v end)
CreateSlider(CombatPage, "Tween Speed", 100, 500, 300, function(v) getgenv().TweenSpeed = v end)

CreateLabel(CombatPage, "=== Kill Select Boss ===", 26)
local BossList = {"Greybeard","The Saw","Saber Expert","The Gorilla King","Bobby","Yeti","Vice Admiral","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Darkbeard","Cursed Captain","Order","Don Swan","Diamond","Jeremy","Fajita","Smoke Admiral","Awakened Ice Admiral","Tide Keeper","Dough King","Cake Prince","rip_indra True Form","Soul Reaper","Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate","Cake Queen","Longma"}
CreateDropdown(CombatPage, "Select Boss", BossList, function(o) State.SelectedBoss = o end)
local BossStat = CreateLabel(CombatPage, "Boss Status: -", 28)
BossStat.TextSize = 11
CreateToggle(CombatPage, "Kill Select Boss", false, function(s) State.AutoBoss = s end)

CreateLabel(CombatPage, "=== PvP ===", 26)
local pvpPlayers = {"None"}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= player then table.insert(pvpPlayers, p.Name) end
end
CreateDropdown(CombatPage, "Select Player", pvpPlayers, function(o) State.SelectedPlayer = o end)
CreateToggle(CombatPage, "Teleport To Player", false, function(s) State.TeleportPlayer = s end)
CreateToggle(CombatPage, "Auto Aimbot", false, function(s) State.Aimbot = s end)
CreateToggle(CombatPage, "Auto Aimbot Gun", false, function(s) getgenv().AimbotGun = s end)

CreateLabel(CombatPage, "=== Movement ===", 26)
CreateToggle(CombatPage, "Change WalkSpeed", false, function(s) getgenv().EnableWalkSpeed = s end)
CreateSlider(CombatPage, "WalkSpeed Value", 16, 300, 100, function(v)
    getgenv().CustomWalkSpeed = v
    if getgenv().EnableWalkSpeed then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
end)
CreateToggle(CombatPage, "Change JumpPower", false, function(s) getgenv().EnableJumpPower = s end)
CreateSlider(CombatPage, "JumpPower Value", 50, 500, 100, function(v)
    getgenv().CustomJumpPower = v
    if getgenv().EnableJumpPower then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v end
    end
end)
CreateToggle(CombatPage, "Infinite Jump", false, function(s) getgenv().InfiniteJump = s end)
CreateToggle(CombatPage, "Walk On Water", false, function(s)
    State.WalkWater = s
    local water = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("WaterBase-Plane")
    if water then water.Size = s and Vector3.new(1000,113,1000) or Vector3.new(1000,80,1000) end
end)

--================================================================
-- TAB: SEA
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

CreateLabel(SeaPage, "=== Sea Items ===", 26)
CreateToggle(SeaPage, "Auto Shark Tooth Necklace", false, function(s) State.AutoSharkTooth = s end)
CreateToggle(SeaPage, "Auto Terror Jaw", false, function(s) State.AutoTerrorJaw = s end)
CreateToggle(SeaPage, "Auto Monster Magnet", false, function(s) State.AutoMonsterMagnet = s end)
CreateToggle(SeaPage, "Auto Shark Anchor", false, function(s) State.AutoSharkAnchor = s end)

--================================================================
-- TAB: EVENTS
--================================================================
CreateLabel(EventsPage, "=== Leviathan ===", 26)
local LevStatus = CreateLabel(EventsPage, "Frozen Dimension: Checking...", 28)
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
CreateToggle(EventsPage, "Tween to Frozen Dimension", false, function(s)
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
CreateToggle(EventsPage, "Auto Find Leviathan (Sail)", false, function(s) State.AutoFindLevi = s end)
CreateToggle(EventsPage, "Auto Attack Leviathan", false, function(s)
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
CreateToggle(EventsPage, "Auto Attack Segment", false, function(s)
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
CreateToggle(EventsPage, "Auto Attack Tail", false, function(s)
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

CreateLabel(EventsPage, "=== Kitsune ===", 26)
local KitStatus = CreateLabel(EventsPage, "Island: Checking...", 28)
KitStatus.TextSize = 11
task.spawn(function()
    while task.wait(2) do
        if not KitStatus.Parent then break end
        pcall(function()
            local ex = Workspace.Map:FindFirstChild("KitsuneIsland")
            KitStatus.Text = "Island: " .. (ex and "Spawned" or "Not Spawned")
        end)
    end
end)
CreateToggle(EventsPage, "Auto Summon Kitsune", false, function(s) State.AutoKitsuneSummon = s end)
CreateToggle(EventsPage, "Tween to Kitsune", false, function(s)
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
CreateToggle(EventsPage, "Auto Collect Azure Ember", false, function(s)
    State.AutoKitsuneEmber = s
    if s then
        task.spawn(function()
            while State.AutoKitsuneEmber do
                pcall(function()
                    local ember = Workspace:FindFirstChild("EmberTemplate")
                    if ember and ember:FindFirstChild("Part") then
                        FarmTeleport(ember.Part.CFrame, 200, 30)
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)
CreateToggle(EventsPage, "Auto Trade Azure Ember", false, function(s)
    State.AutoKitsuneTrade = s
    if s then
        task.spawn(function()
            while State.AutoKitsuneTrade do
                pcall(function()
                    local rf = Net and Net:FindFirstChild("RF/KitsuneStatuePray")
                    if rf then rf:InvokeServer() end
                end)
                task.wait(2)
            end
        end)
    end
end)

CreateLabel(EventsPage, "=== Mirage / Prehistoric ===", 26)
local MirStat = CreateLabel(EventsPage, "Mirage: Checking...", 28)
MirStat.TextSize = 11
task.spawn(function()
    while task.wait(2) do
        if not MirStat.Parent then break end
        pcall(function()
            local exists = Workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island")
            MirStat.Text = "Mirage: " .. (exists and "Spawned" or "Not Spawned")
        end)
    end
end)
CreateToggle(EventsPage, "Auto Summon Mirage", false, function(s) State.AutoMirageSummon = s end)
CreateToggle(EventsPage, "Tween to Mirage", false, function(s)
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
CreateToggle(EventsPage, "Auto Summon Prehistoric", false, function(s) State.AutoPrehistoricSummon = s end)
CreateToggle(EventsPage, "Tween to Prehistoric", false, function(s)
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

CreateLabel(EventsPage, "=== Volcano Event ===", 26)
CreateDropdown(EventsPage, "Weapon Kill Golem", {"Melee","Sword","Gun","Blox Fruit"}, function(o) getgenv().GolemWeapon = o end)
CreateDropdown(EventsPage, "Method Kill Golem", {"Click M1","Instant Kill"}, function(o) getgenv().GolemMethod = o end)
CreateToggle(EventsPage, "Auto Craft Volcanic Magnet", false, function(s)
    State.AutoCraftMagnet = s
    if s then
        task.spawn(function()
            while State.AutoCraftMagnet do
                pcall(function()
                    CommF_:InvokeServer("CraftItem", "Check", "VolcanicMagnet")
                    CommF_:InvokeServer("CraftItem", "Craft", "VolcanicMagnet")
                end)
                task.wait(3)
            end
        end)
    end
end)
CreateToggle(EventsPage, "Auto Event Prehistoric", false, function(s)
    State.AutoVolcano = s
    if s then
        task.spawn(function()
            while State.AutoVolcano do
                pcall(function()
                    local pre = Workspace.Map:FindFirstChild("PrehistoricIsland")
                    if pre then
                        local golem = FindEnemy({"Lava Golem"}, 3000)
                        if golem then
                            local trp = golem:FindFirstChild("HumanoidRootPart")
                            if trp then
                                AutoHaki()
                                EquipWeapon(getgenv().GolemWeapon or "Melee")
                                FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), 200, 20)
                                trp.CanCollide = false
                                if golem:FindFirstChild("Humanoid") then golem.Humanoid.WalkSpeed = 0 end
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
CreateToggle(EventsPage, "Auto Collect Bone", false, function(s) getgenv().AutoBone = s end)
CreateToggle(EventsPage, "Fully Event Prehistoric", false, function(s) getgenv().FullyVolcano = s end)

CreateLabel(EventsPage, "=== Dungeon ===", 26)
CreateDropdown(EventsPage, "Dungeon Weapon", {"Melee","Sword","Blox Fruit","Gun"}, function(o) getgenv().DungeonWeapon = o end)
CreateDropdown(EventsPage, "Dungeon Difficulty", {"Normal","Hard","Challenge"}, function(o) getgenv().DungeonDiff = o end)
CreateToggle(EventsPage, "Auto Attack Dungeon", false, function(s)
    State.AutoDungeon = s
    if s then
        task.spawn(function()
            while State.AutoDungeon do
                pcall(function()
                    local enemies = Workspace:FindFirstChild("Enemies")
                    if not enemies then return end
                    for _, e in ipairs(enemies:GetChildren()) do
                        if e.Name ~= "Blank Buddy" and e:FindFirstChild("HumanoidRootPart") then
                            local h = e:FindFirstChild("Humanoid")
                            if h and h.Health > 0 then
                                EquipWeapon(getgenv().DungeonWeapon or "Melee")
                                AutoHaki()
                                local trp = e:FindFirstChild("HumanoidRootPart")
                                FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), 200, 15)
                                trp.CanCollide = false
                                h.WalkSpeed = 0
                                AttackNoCoolDown()
                                break
                            end
                        end
                    end
                end)
                task.wait(0.3)
            end
        end)
    end
end)
CreateToggle(EventsPage, "Auto Pick Card", false, function(s)
    State.AutoCard = s
    if s then
        task.spawn(function()
            while State.AutoCard do
                pcall(function()
                    local pg = player.PlayerGui
                    for _, gui2 in ipairs(pg:GetChildren()) do
                        if gui2.Name:lower():find("dungeon") and gui2.Name:lower():find("card") then
                            for _, desc in ipairs(gui2:GetDescendants()) do
                                if desc:IsA("TextButton") and desc.Visible then
                                    local cons = getconnections and getconnections(desc.Activated)
                                    if cons then
                                        for _, c in ipairs(cons) do pcall(function() c.Function() end) end
                                        return
                                    end
                                end
                            end
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)
CreateToggle(EventsPage, "Auto Join Dungeon", false, function(s)
    State.AutoJoinDungeon = s
    if s then
        task.spawn(function()
            while State.AutoJoinDungeon do
                pcall(function()
                    local pre = player.PlayerGui:FindFirstChild("DungeonQueueSettingsMenu")
                    if pre and pre.Enabled then
                        for _, btn in ipairs(pre:GetDescendants()) do
                            if btn:IsA("TextButton") and btn.Text:lower():find("start") then
                                local cons = getconnections and getconnections(btn.Activated)
                                if cons then for _, c in ipairs(cons) do pcall(function() c.Function() end) end end
                            end
                        end
                    end
                end)
                task.wait(2)
            end
        end)
    end
end)

--================================================================
-- TAB: RACE
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
CreateButton(RacePage, "Teleport Ancient Clock", function()
    FarmTeleport(CFrame.new(29549, 15069, -88), 200, 30)
end)
CreateToggle(RacePage, "Auto Buy Gear V4", false, function(s)
    State.AutoBuyGearV4 = s
    if s then
        task.spawn(function()
            while State.AutoBuyGearV4 do
                pcall(function()
                    local res = CommF_:InvokeServer("UpgradeRace", "Check")
                    if res and (res == 2 or res == 4 or res == 7) then
                        CommF_:InvokeServer("UpgradeRace", "Buy")
                    end
                end)
                task.wait(3)
            end
        end)
    end
end)
CreateToggle(RacePage, "Auto Choose Gears", false, function(s) State.AutoChooseGear = s end)
CreateToggle(RacePage, "Auto Finish Train Quest", false, function(s)
    State.AutoFinishTrain = s
    if s then
        task.spawn(function()
            while State.AutoFinishTrain do
                pcall(function()
                    local enemy = FindEnemy({"Reborn Skeleton","Living Zombie","Demonic Soul","Posessed Mummy"}, 5000)
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
CreateToggle(RacePage, "Auto Pull Lever", false, function(s)
    State.AutoPullLever = s
    if s then
        task.spawn(function()
            while State.AutoPullLever do
                pcall(function()
                    local tot = Workspace.Map:FindFirstChild("Temple of Time")
                    if tot then
                        for _, d in ipairs(tot:GetDescendants()) do
                            if d.Name == "ProximityPrompt" then
                                pcall(function() fireproximityprompt(d, math.huge) end)
                            end
                        end
                    end
                end)
                task.wait(2)
            end
        end)
    end
end)
CreateToggle(RacePage, "Auto Trial", false, function(s) State.AutoTrial = s end)
CreateToggle(RacePage, "Auto Kill After Trial", false, function(s) State.AutoKillAfterTrial = s end)

CreateLabel(RacePage, "=== Race Draco ===", 26)
CreateToggle(RacePage, "Auto Upgrade V2-V3 Draco", false, function(s) State.AutoDracoV2V3 = s end)
CreateToggle(RacePage, "Fully Trial Draco", false, function(s) State.AutoDracoTrial = s end)
CreateToggle(RacePage, "Auto Buy Gear Draco", false, function(s) getgenv().AutoBuyGearDraco = s end)
CreateToggle(RacePage, "Auto Trial Draco", false, function(s) getgenv().AutoTrialDraco = s end)

CreateLabel(RacePage, "=== Race Normal ===", 26)
CreateToggle(RacePage, "Auto V2", false, function(s)
    State.AutoV2 = s
    if s then
        task.spawn(function()
            while State.AutoV2 do
                pcall(function()
                    local res = CommF_:InvokeServer("Alchemist", "1")
                    if res == 0 then
                        FarmTeleport(CFrame.new(-2779.84, 72.97, -3574.02), 200, 30)
                        CommF_:InvokeServer("Alchemist", "2")
                    elseif res == 1 then
                        for _, name in ipairs({"Flower 1","Flower 2","Flower 3"}) do
                            if not player.Backpack:FindFirstChild(name) and not player.Character:FindFirstChild(name) then
                                local obj = Workspace:FindFirstChild(name)
                                if obj then FarmTeleport(obj.CFrame, 200, 20) end
                            end
                        end
                        local z = FindEnemy({"Zombie"}, 5000)
                        if z then
                            EquipWeapon(State.SelectedWeapon); AutoHaki()
                            FarmTeleport(z.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0), 200, 20)
                            z.HumanoidRootPart.CanCollide = false
                            AttackNoCoolDown()
                        end
                    elseif res == 2 then
                        CommF_:InvokeServer("Alchemist", "3")
                    end
                end)
                task.wait(1)
            end
        end)
    end
end)
CreateToggle(RacePage, "Auto V3", false, function(s)
    State.AutoV3 = s
    if s then
        task.spawn(function()
            while State.AutoV3 do
                pcall(function()
                    local res = CommF_:InvokeServer("Wenlocktoad", "1")
                    if res == 0 then CommF_:InvokeServer("Wenlocktoad", "2")
                    elseif res == 2 then CommF_:InvokeServer("Wenlocktoad", "3") end
                end)
                task.wait(1)
            end
        end)
    end
end)
CreateToggle(RacePage, "Auto Get Cyborg", false, function(s) State.AutoCyborg = s end)
CreateToggle(RacePage, "Auto Get Ghoul", false, function(s) State.AutoGhoul = s end)

CreateLabel(RacePage, "=== Trials ===", 26)
CreateButton(RacePage, "Teleport Trial Door", function()
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
CreateButton(RacePage, "Pull Lever", function()
    for _, d in ipairs(Workspace.Map["Temple of Time"]:GetDescendants()) do
        if d.Name == "ProximityPrompt" then
            pcall(function() fireproximityprompt(d, math.huge) end)
        end
    end
    Notify("Lever pulled")
end)

--================================================================
-- TAB: WEAPONS
--================================================================
CreateLabel(WeaponsPage, "=== Sword Collection ===", 26)
CreateDropdown(WeaponsPage, "Select Sword",
    {"Saber","Tushita","Yama","Buddy Sword","Shark Anchor","Dark Dagger","Twin Hooks","Canvander","Spikey Trident"},
    function(o) getgenv().SelectSwordQuest = o end)
getgenv().SelectSwordQuest = "Saber"
CreateToggle(WeaponsPage, "Auto Get Selected Sword", false, function(s)
    getgenv().AutoGetSword = s
    if s then
        task.spawn(function()
            while getgenv().AutoGetSword do
                pcall(function()
                    local sw = getgenv().SelectSwordQuest
                    local targets = {}
                    if sw == "Twin Hooks" then targets = {"Captain Elephant"}
                    elseif sw == "Buddy Sword" then targets = {"Cake Queen"}
                    elseif sw == "Canvander" then targets = {"Beautiful Pirate"}
                    elseif sw == "Dark Dagger" then targets = {"rip_indra True Form","rip_indra"}
                    elseif sw == "Shark Anchor" then targets = {"Terrorshark"}
                    elseif sw == "Yama" then targets = {"Diablo","Deandre","Urban"}
                    elseif sw == "Tushita" then targets = {"Longma"}
                    elseif sw == "Saber" then targets = {"Saber Expert","Mob Leader"}
                    elseif sw == "Spikey Trident" then targets = {"Dough King"}
                    end
                    if #targets > 0 then
                        AutoHaki()
                        local enemy = FindEnemy(targets, 99999)
                        if enemy then
                            local trp = enemy:FindFirstChild("HumanoidRootPart")
                            if trp then
                                EquipWeapon(State.SelectedWeapon)
                                FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), 200, 20)
                                trp.CanCollide = false
                                if enemy:FindFirstChild("Humanoid") then enemy.Humanoid.WalkSpeed = 0 end
                                AttackNoCoolDown()
                            end
                        end
                    end
                end)
                task.wait(0.4)
            end
        end)
    end
end)
CreateToggle(WeaponsPage, "Auto Soul Guitar", false, function(s)
    State.AutoSoulGuitar = s
    if s then
        task.spawn(function()
            while State.AutoSoulGuitar do
                pcall(function()
                    if not Workspace.Map:FindFirstChild("Haunted Castle") then return end
                    if CommF_:InvokeServer("soulGuitarBuy", true) ~= "[You already own this item.]" then
                        local e = FindEnemy({"Soul Reaper"}, 99999)
                        if e then
                            EquipWeapon(State.SelectedWeapon); AutoHaki()
                            FarmTeleport(e.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0), 200, 20)
                            e.HumanoidRootPart.CanCollide = false
                            AttackNoCoolDown()
                        end
                    else
                        Notify("Already own Soul Guitar")
                        State.AutoSoulGuitar = false
                    end
                end)
                task.wait(1)
            end
        end)
    end
end)
CreateToggle(WeaponsPage, "Auto Yama", false, function(s)
    State.AutoYama = s
    if s then
        task.spawn(function()
            while State.AutoYama do
                pcall(function()
                    local prog = CommF_:InvokeServer("EliteHunter", "Progress") or 0
                    if prog >= 30 then
                        local wf = Workspace.Map:FindFirstChild("Waterfall")
                        if wf then
                            local sk = wf:FindFirstChild("SealedKatana")
                            if sk and sk:FindFirstChild("Handle") and sk.Handle:FindFirstChild("ClickDetecter") then
                                FarmTeleport(sk.Handle.CFrame, 200, 20)
                                fireclickdetector(sk.Handle.ClickDetecter)
                            end
                        end
                    else
                        local e = FindEnemy({"Diablo","Deandre","Urban"}, 99999)
                        if e then
                            EquipWeapon(State.SelectedWeapon); AutoHaki()
                            FarmTeleport(e.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0), 200, 20)
                            e.HumanoidRootPart.CanCollide = false
                            AttackNoCoolDown()
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)
CreateToggle(WeaponsPage, "Auto Tushita", false, function(s)
    State.AutoTushita = s
    if s then
        task.spawn(function()
            while State.AutoTushita do
                pcall(function()
                    local e = FindEnemy({"Longma"}, 99999)
                    if e then
                        EquipWeapon(State.SelectedWeapon); AutoHaki()
                        FarmTeleport(e.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0), 200, 20)
                        e.HumanoidRootPart.CanCollide = false
                        AttackNoCoolDown()
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)
CreateToggle(WeaponsPage, "Auto True Triple Katana", false, function(s)
    State.AutoTTK = s
    if s then
        task.spawn(function()
            while State.AutoTTK do
                pcall(function()
                    CommF_:InvokeServer("MysteriousMan", "1")
                    CommF_:InvokeServer("MysteriousMan", "2")
                end)
                task.wait(2)
            end
        end)
    end
end)
CreateToggle(WeaponsPage, "Auto CDK", false, function(s) State.AutoCDK = s end)
CreateToggle(WeaponsPage, "Auto Saber", false, function(s) State.AutoSaber = s end)
CreateToggle(WeaponsPage, "Auto Yoru Mini", false, function(s) State.AutoYoruMini = s end)

CreateLabel(WeaponsPage, "=== Upgrade Weapon ===", 26)
CreateToggle(WeaponsPage, "Auto Upgrade Sword", false, function(s) State.AutoUpgradeSword = s end)
CreateToggle(WeaponsPage, "Auto Upgrade Gun", false, function(s) State.AutoUpgradeGun = s end)

CreateLabel(WeaponsPage, "=== Haki ===", 26)
CreateToggle(WeaponsPage, "Auto Rainbow Haki", false, function(s)
    State.AutoRainbowHaki = s
    if s then
        task.spawn(function()
            while State.AutoRainbowHaki do
                pcall(function()
                    local targets = {
                        {name="Stone", pos=CFrame.new(-1049, 40, 6791)},
                        {name="Island Empress", pos=CFrame.new(5730, 602, 199)},
                        {name="Kilo Admiral", pos=CFrame.new(2889, 424, -7233)},
                        {name="Captain Elephant", pos=CFrame.new(-13393, 319, -8423)},
                        {name="Beautiful Pirate", pos=CFrame.new(5241, 23, 129)},
                    }
                    for _, t in ipairs(targets) do
                        local e = FindEnemy({t.name}, 99999)
                        if e then
                            EquipWeapon(State.SelectedWeapon); AutoHaki()
                            FarmTeleport(e.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0), 200, 20)
                            e.HumanoidRootPart.CanCollide = false
                            AttackNoCoolDown()
                            return
                        end
                    end
                    FarmTeleport(CFrame.new(-11892, 930, -8760), 200, 30)
                    CommF_:InvokeServer("HornedMan", "Bet")
                end)
                task.wait(0.5)
            end
        end)
    end
end)
CreateToggle(WeaponsPage, "Auto Buy Haki Colors", false, function(s)
    State.AutoBuyHakiColor = s
    if s then
        task.spawn(function()
            while State.AutoBuyHakiColor do
                pcall(function()
                    CommF_:InvokeServer("ColorsDealer", "1")
                    CommF_:InvokeServer("ColorsDealer", "2")
                end)
                task.wait(2)
            end
        end)
    end
end)

--================================================================
-- TAB: FRUITS
--================================================================
CreateLabel(FruitsPage, "=== Fruit Management ===", 26)
CreateToggle(FruitsPage, "Auto Store Fruit", false, function(s)
    State.AutoStoreFruit = s
    if s then
        task.spawn(function()
            while State.AutoStoreFruit do
                pcall(function()
                    for _, c in ipairs(player.Character:GetChildren()) do
                        if c:IsA("Tool") and c.Name:find("Fruit") then
                            local key = c.Name:gsub(" Fruit",""):gsub(" ","")
                            if not key:find("%-") then key = key .. "-" .. key end
                            CommF_:InvokeServer("StoreFruit", key, c)
                        end
                    end
                    for _, c in ipairs(player.Backpack:GetChildren()) do
                        if c:IsA("Tool") and c.Name:find("Fruit") then
                            local key = c.Name:gsub(" Fruit",""):gsub(" ","")
                            if not key:find("%-") then key = key .. "-" .. key end
                            CommF_:InvokeServer("StoreFruit", key, c)
                            task.wait(0.3)
                        end
                    end
                end)
                task.wait(1.5)
            end
        end)
    end
end)
CreateToggle(FruitsPage, "Auto Buy Random Fruit", false, function(s)
    State.AutoBuyFruit = s
    if s then
        task.spawn(function()
            while State.AutoBuyFruit do
                pcall(function()
                    CommF_:InvokeServer("Cousin", "Buy")
                end)
                task.wait(2)
            end
        end)
    end
end)
CreateToggle(FruitsPage, "Tween to Fruit", false, function(s)
    State.AutoFindFruit = s
    if s then
        task.spawn(function()
            while State.AutoFindFruit do
                pcall(function()
                    local hrp = GetHRP()
                    if not hrp then return end
                    local best, bestD = nil, math.huge
                    for _, o in ipairs(Workspace:GetChildren()) do
                        if (o:IsA("Tool") or o:IsA("Model")) and o.Name:find("Fruit") then
                            local h = o:FindFirstChild("Handle") or o.PrimaryPart or (o:IsA("Model") and o:FindFirstChildWhichIsA("BasePart", true))
                            if h then
                                local d = (h.Position - hrp.Position).Magnitude
                                if d < bestD then best = h; bestD = d end
                            end
                        end
                    end
                    if best then FarmTeleport(best.CFrame + Vector3.new(0, 3, 0), 200, 30) end
                end)
                task.wait(0.5)
            end
        end)
    end
end)
CreateToggle(FruitsPage, "Auto Drop Fruit", false, function(s)
    State.AutoDropFruit = s
    if s then
        task.spawn(function()
            while State.AutoDropFruit do
                pcall(function()
                    for _, c in ipairs(player.Backpack:GetChildren()) do
                        if c:IsA("Tool") and c.Name:find("Fruit") then
                            local key = c.Name:gsub(" Fruit",""):gsub(" ","")
                            if not key:find("%-") then key = key .. "-" .. key end
                            CommF_:InvokeServer("Drop", key, c)
                            task.wait(0.5)
                        end
                    end
                end)
                task.wait(2)
            end
        end)
    end
end)
CreateToggle(FruitsPage, "Auto Eat Fruit", false, function(s)
    State.AutoEatFruit = s
    if s then
        task.spawn(function()
            while State.AutoEatFruit do
                pcall(function()
                    local eat = player.Character and player.Character:FindFirstChild("EatRemote", true)
                    if eat then eat:InvokeServer() end
                end)
                task.wait(3)
            end
        end)
    end
end)

CreateLabel(FruitsPage, "=== Raid ===", 26)
CreateDropdown(FruitsPage, "Select Chip",
    {"Flame","Ice","Sand","Dark","Light","Magma","Quake","Buddha","Love","Spider","Sound","Phoenix","Portal","Rumble","Pain","Blizzard","Gravity"},
    function(o) getgenv().SelectedChip = o end)
CreateToggle(FruitsPage, "Auto Raid", false, function(s)
    State.AutoRaid = s
    if s then
        task.spawn(function()
            while State.AutoRaid do
                pcall(function()
                    CommF_:InvokeServer("RaidsNpc", "Select", getgenv().SelectedChip or "Flame")
                    local map = Workspace:FindFirstChild("Map")
                    local circle = map and map:FindFirstChild("CircleIsland")
                    if circle and circle:FindFirstChild("RaidSummon2") then
                        local btn = circle.RaidSummon2:FindFirstChild("Button")
                        local mn = btn and btn:FindFirstChild("Main")
                        local cd = mn and mn:FindFirstChild("ClickDetector")
                        if cd then fireclickdetector(cd) end
                    end
                end)
                task.wait(2)
            end
        end)
    end
end)
CreateToggle(FruitsPage, "Auto Awaken Fruit", false, function(s)
    State.AutoAwaken = s
    if s then
        task.spawn(function()
            while State.AutoAwaken do
                pcall(function()
                    CommF_:InvokeServer("Awakener", "Check")
                    CommF_:InvokeServer("Awakener", "Awaken")
                end)
                task.wait(2)
            end
        end)
    end
end)

CreateLabel(FruitsPage, "=== Sniper ===", 26)
CreateToggle(FruitsPage, "Auto Buy Fruits Sniper", false, function(s)
    State.AutoSniper = s
    if s then
        task.spawn(function()
            while State.AutoSniper do
                pcall(function()
                    local fruits = CommF_:InvokeServer("GetFruits")
                    if fruits then
                        for _, f in ipairs(fruits) do
                            if f.Price >= 1000000 then
                                CommF_:InvokeServer("PurchaseRawFruit", f.Name, false)
                            end
                        end
                    end
                end)
                task.wait(3)
            end
        end)
    end
end)
CreateToggle(FruitsPage, "Auto Buy Sniper (Mirage)", false, function(s)
    State.AutoSniperMirage = s
    if s then
        task.spawn(function()
            while State.AutoSniperMirage do
                pcall(function()
                    local fruits = CommF_:InvokeServer("GetFruits")
                    if fruits then
                        for _, f in ipairs(fruits) do
                            if f.Price >= 1000000 then
                                CommF_:InvokeServer("PurchaseRawFruit", f.Name, true)
                            end
                        end
                    end
                end)
                task.wait(3)
            end
        end)
    end
end)

CreateLabel(FruitsPage, "=== Spawner ===", 26)
CreateToggle(FruitsPage, "Auto Get Spawner Fruit", false, function(s)
    State.AutoSpawnerFruit = s
    if s then
        task.spawn(function()
            while State.AutoSpawnerFruit do
                pcall(function()
                    local hrp = GetHRP()
                    if not hrp then return end
                    for _, o in ipairs(Workspace:GetChildren()) do
                        if o:IsA("Tool") and o:FindFirstChild("Handle") and o.Name:find("Fruit") then
                            FarmTeleport(o.Handle.CFrame, 200, 30)
                            task.wait(1.5)
                            break
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    end
end)

--================================================================
-- TAB: FISHING
--================================================================
CreateLabel(FishingPage, "=== Fishing ===", 26)
CreateToggle(FishingPage, "Auto Equip Rod", false, function(s)
    State.AutoEquipRod = s
    if s then
        task.spawn(function()
            while State.AutoEquipRod do
                pcall(function()
                    local tool = player.Character and player.Character:FindFirstChildWhichIsA("Tool")
                    if not tool or tool:GetAttribute("InventoryCategory") ~= "Rod" then
                        for _, t in ipairs(player.Backpack:GetChildren()) do
                            if t:IsA("Tool") and t:GetAttribute("InventoryCategory") == "Rod" then
                                player.Character.Humanoid:EquipTool(t)
                                break
                            end
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    end
end)
CreateToggle(FishingPage, "Auto Fishing", false, function(s)
    State.AutoFishing = s
    if s then
        task.spawn(function()
            while State.AutoFishing do
                pcall(function()
                    local char = player.Character
                    local tool = char and char:FindFirstChildWhichIsA("Tool")
                    if tool and tool:GetAttribute("InventoryCategory") == "Rod" then
                        local state = tool:GetAttribute("State")
                        if state == "ReeledIn" then
                            local FR = RS:FindFirstChild("FishReplicated") and RS.FishReplicated:FindFirstChild("FishingRequest")
                            if FR then FR:InvokeServer("StartCasting") task.wait(0.7) end
                        elseif state == "Biting" then
                            local FR = RS:FindFirstChild("FishReplicated") and RS.FishReplicated:FindFirstChild("FishingRequest")
                            if FR then
                                FR:InvokeServer("Catching", true)
                                task.wait(0.25)
                                FR:InvokeServer("Catch", 1)
                            end
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)
CreateToggle(FishingPage, "Auto Sell Fish", false, function(s)
    State.AutoSellFish = s
    if s then
        task.spawn(function()
            while State.AutoSellFish do
                pcall(function()
                    if Net then
                        local RF = Net:FindFirstChild("RF/JobsRemoteFunction")
                        if RF then RF:InvokeServer("FishingNPC", "SellFish") end
                    end
                end)
                task.wait(2)
            end
        end)
    end
end)
CreateToggle(FishingPage, "Auto Sell Corrupted Fish", false, function(s)
    getgenv().SX_SellCorrupted = s
    if s then
        task.spawn(function()
            while getgenv().SX_SellCorrupted do
                pcall(function()
                    if Net then
                        local RF = Net:FindFirstChild("RF/JobsRemoteFunction")
                        if RF then RF:InvokeServer("FishingNPC", "SellCorruptedFish") end
                    end
                end)
                task.wait(2)
            end
        end)
    end
end)

--================================================================
-- TAB: SHOP
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
    TryBuy("BlackbeardReward", "Refund", "1")
    task.wait(0.3)
    TryBuy("BlackbeardReward", "Refund", "2")
end)
CreateButton(ShopPage, "Buy Race Reroll", function()
    TryBuy("BlackbeardReward", "Reroll", "1")
    task.wait(0.3)
    TryBuy("BlackbeardReward", "Reroll", "2")
end)
CreateButton(ShopPage, "Buy Ghoul Race", function()
    TryBuy("Ectoplasm", "BuyCheck", 4)
    task.wait(0.3)
    TryBuy("Ectoplasm", "Change", 4)
end)
CreateButton(ShopPage, "Buy Cyborg Race", function() TryBuy("CyborgTrainer", "Buy") end)
CreateButton(ShopPage, "Buy Dual Flintlock", function() TryBuy("BuyItem", "Dual Flintlock") end)
CreateButton(ShopPage, "Buy Legendary Swords", function()
    TryBuy("LegendarySwordDealer", "1")
    TryBuy("LegendarySwordDealer", "2")
    TryBuy("LegendarySwordDealer", "3")
end)
CreateButton(ShopPage, "Buy True Triple Katana", function()
    TryBuy("MysteriousMan", "1")
    TryBuy("MysteriousMan", "2")
end)

CreateLabel(ShopPage, "=== Auto Stats ===", 26)
CreateSlider(ShopPage, "Points Per Click", 1, 50, 5, function(v) State.PointsPerClick = v end)
CreateToggle(ShopPage, "Auto Melee", false, function(s) State.StatMelee = s and 1 or 0 end)
CreateToggle(ShopPage, "Auto Defense", false, function(s) State.StatDefense = s and 1 or 0 end)
CreateToggle(ShopPage, "Auto Sword", false, function(s) State.StatSword = s and 1 or 0 end)
CreateToggle(ShopPage, "Auto Gun", false, function(s) State.StatGun = s and 1 or 0 end)
CreateToggle(ShopPage, "Auto Blox Fruit", false, function(s) State.StatFruit = s and 1 or 0 end)
CreateToggle(ShopPage, "Enable Auto Stats", false, function(s) State.AutoStats = s end)

CreateLabel(ShopPage, "=== Team ===", 26)
CreateButton(ShopPage, "Join Pirates", function()
    CommF_:InvokeServer("SetTeam", "Pirates")
    Notify("Joined Pirates")
end)
CreateButton(ShopPage, "Join Marines", function()
    CommF_:InvokeServer("SetTeam", "Marines")
    Notify("Joined Marines")
end)

--================================================================
-- TAB: TELEPORT
--================================================================
CreateLabel(TeleportPage, "=== Sea Travel ===", 26)
CreateButton(TeleportPage, "Travel to Sea 1", function() CommF_:InvokeServer("TravelMain") Notify("Traveling Sea 1") end)
CreateButton(TeleportPage, "Travel to Sea 2", function() CommF_:InvokeServer("TravelDressrosa") Notify("Traveling Sea 2") end)
CreateButton(TeleportPage, "Travel to Sea 3", function() CommF_:InvokeServer("TravelZou") Notify("Traveling Sea 3") end)

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
-- TAB: VISUAL (ESP ONLY)
--================================================================
CreateLabel(VisualPage, "=== ESP Settings ===", 26)
CreateToggle(VisualPage, "ESP Player", false, function(s)
    State.ESPPlayer = s
    if not s then
        ClearESP()
    end
end)
CreateToggle(VisualPage, "ESP Fruit", false, function(s)
    State.ESPFruit = s
    if not s then ClearESP() end
end)
CreateToggle(VisualPage, "ESP Chest", false, function(s)
    State.ESPChest = s
    if not s then ClearESP() end
end)
CreateToggle(VisualPage, "ESP Island", false, function(s)
    State.ESPIsland = s
    if not s then ClearESP() end
end)
CreateToggle(VisualPage, "ESP Boss", false, function(s)
    State.ESPBoss = s
    if not s then ClearESP() end
end)

--================================================================
-- TAB: SETTINGS
--================================================================
CreateLabel(SettingsPage, "=== Local ===", 26)
CreateToggle(SettingsPage, "Anti AFK", true, function(s) State.AntiAFK = s end)
CreateToggle(SettingsPage, "No Clip", false, function(s) State.Noclip = s end)
CreateToggle(SettingsPage, "Hide Mob", false, function(s) State.HideMob = s end)
CreateToggle(SettingsPage, "Auto Ken", false, function(s) State.AutoKen = s end)
CreateToggle(SettingsPage, "Auto Haki", true, function(s) State.AutoHaki = s end)

CreateLabel(SettingsPage, "=== Remove Effects ===", 26)
CreateToggle(SettingsPage, "Remove Damage Numbers", false, function(s) State.RemoveDamage = s end)
CreateToggle(SettingsPage, "Remove Notifications", false, function(s) State.RemoveNotifications = s end)

CreateLabel(SettingsPage, "=== Performance ===", 26)
CreateToggle(SettingsPage, "Boost FPS", false, function(s)
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
CreateSlider(SettingsPage, "FPS Cap", 15, 240, 60, function(v)
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

CreateLabel(SettingsPage, "=== Server ===", 26)
CreateButton(SettingsPage, "Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId, player)
end)
CreateButton(SettingsPage, "Server Hop", function()
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

CreateLabel(SettingsPage, "=== Codes ===", 26)
CreateButton(SettingsPage, "Redeem All Codes", function()
    local codes = {"KITT_RESET","SUB2GAMEROBOT_RESET1","SUB2GAMERROBOT_EXP1","SUB2OFFICIALNOOBIE","AXIORE","BLUXXY","JCWK","KITTGAMING","MAGICBUS","STARCODEHEO","STRAWHATMAINE","TANTAIGAMING","THEGREATACE","ENYU_IS_PRO","FUDD10","FUDD10_V2","BIGNEWS","CHANDLER","SECRET_ADMIN","ADMIN_MELEE"}
    for _, c in ipairs(codes) do
        pcall(function() Remotes.Redeem:InvokeServer(c) end)
        task.wait(0.5)
    end
    Notify("All codes redeemed")
end)

CreateLabel(SettingsPage, "=== Webhook ===", 26)
CreateButton(SettingsPage, "Set Webhook URL (Clipboard)", function()
    local ok, url = pcall(function() return getclipboard() end)
    if ok and url and url:find("discord.com/api/webhooks") then
        getgenv().SX_WebhookURL = url
        Notify("Webhook URL saved")
    else
        Notify("Copy Discord webhook URL first")
    end
end)
CreateToggle(SettingsPage, "Webhook Store Fruit", false, function(s) State.WebhookFruit = s end)
CreateToggle(SettingsPage, "Webhook Find Mirage", false, function(s) State.WebhookMirage = s end)
CreateToggle(SettingsPage, "Webhook Find Leviathan", false, function(s) State.WebhookLevi = s end)
CreateToggle(SettingsPage, "Webhook Find Prehistoric", false, function(s) State.WebhookPre = s end)

CreateLabel(SettingsPage, "=== Config ===", 26)
CreateButton(SettingsPage, "Reset All Settings", function()
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
                local enemy = FindEnemy(data.NPCs, 5000)
                if enemy then
                    EquipWeapon(State.SelectedWeapon); AutoHaki()
                    local trp = enemy:FindFirstChild("HumanoidRootPart")
                    if trp then
                        FarmTeleport(trp.CFrame * CFrame.new(0, 15, 0), 200, 20)
                        trp.CanCollide = false
                        if enemy:FindFirstChild("Humanoid") then enemy.Humanoid.WalkSpeed = 0 end
                        AttackNoCoolDown()
                    end
                else
                    FarmTeleport(data.Pos + Vector3.new(0, 30, 0), 200, 30)
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
                    EquipWeapon(State.SelectedWeapon); AutoHaki()
                    local trp = enemy:FindFirstChild("HumanoidRootPart")
                    if trp then
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
    while task.wait(0.3) do
        if State.AutoCakePrince then
            pcall(function()
                local e = FindEnemy({"Cake Prince","Dough King"}, 99999)
                if e then
                    EquipWeapon(State.SelectedWeapon); AutoHaki()
                    FarmTeleport(e.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0), 200, 20)
                    e.HumanoidRootPart.CanCollide = false
                    AttackNoCoolDown()
                else
                    local mob = FindEnemy({"Baking Staff","Head Baker","Cake Guard","Cookie Crafter"}, 5000)
                    if mob then
                        EquipWeapon(State.SelectedWeapon); AutoHaki()
                        FarmTeleport(mob.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0), 200, 20)
                        mob.HumanoidRootPart.CanCollide = false
                        AttackNoCoolDown()
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
                    FarmTeleport(e.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0), 200, 20)
                    e.HumanoidRootPart.CanCollide = false
                    AttackNoCoolDown()
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
                    FarmTeleport(e.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0), 200, 20)
                    e.HumanoidRootPart.CanCollide = false
                    AttackNoCoolDown()
                else
                    CommF_:InvokeServer("EliteHunter")
                end
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
                    FarmTeleport(e.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0), 200, 20)
                    e.HumanoidRootPart.CanCollide = false
                    AttackNoCoolDown()
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if State.AutoFactory then
            pcall(function()
                local e = FindEnemy({"Core"}, 99999)
                if e then
                    EquipWeapon(State.SelectedWeapon); AutoHaki()
                    FarmTeleport(e.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0), 200, 20)
                    e.HumanoidRootPart.CanCollide = false
                    AttackNoCoolDown()
                else
                    FarmTeleport(CFrame.new(502.7, 143.1, -379.1), 200, 30)
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if State.AutoPiratesSea then
            pcall(function()
                local enemies = Workspace:FindFirstChild("Enemies")
                if not enemies then return end
                for _, e in ipairs(enemies:GetChildren()) do
                    if e.Name ~= "rip_indra True Form" and e.Name ~= "Blank Buddy" and e.PrimaryPart then
                        local h = e:FindFirstChild("Humanoid")
                        if h and h.Health > 0 then
                            if (e.PrimaryPart.Position - Vector3.new(-5556, 314, -2988)).Magnitude < 700 then
                                EquipWeapon(State.SelectedWeapon); AutoHaki()
                                FarmTeleport(e.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0), 200, 20)
                                e.HumanoidRootPart.CanCollide = false
                                AttackNoCoolDown()
                                return
                            end
                        end
                    end
                end
                FarmTeleport(CFrame.new(-5556, 314, -2988), 200, 30)
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
                    FarmTeleport(e.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0), 200, 20)
                    e.HumanoidRootPart.CanCollide = false
                    AttackNoCoolDown()
                else
                    FarmTeleport(CFrame.new(-16557, 202, 508), 200, 30)
                end
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
                    FarmTeleport(e.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0), 200, 20)
                    e.HumanoidRootPart.CanCollide = false
                    AttackNoCoolDown()
                else
                    FarmTeleport(CFrame.new(-11893.7, 929.661, -8760.59), 200, 30)
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
                    FarmTeleport(e.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0), 200, 20)
                    e.HumanoidRootPart.CanCollide = false
                    AttackNoCoolDown()
                else
                    local em = Workspace:FindFirstChild("EmberTemplate")
                    if em and em:FindFirstChild("Part") then
                        FarmTeleport(em.Part.CFrame, 200, 30)
                    else
                        FarmTeleport(CFrame.new(5863.68, 1209.87, 809.94), 200, 30)
                    end
                end
            end)
        end
    end
end)

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
                    local enemy = FindEnemy(targets, 3000)
                    if enemy then
                        local trp = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("VehicleSeat")
                        if trp then
                            EquipWeapon(State.SelectedWeapon); AutoHaki()
                            FarmTeleport(trp.CFrame * CFrame.new(0, 55, 0), 200, 30)
                            if enemy:FindFirstChild("Humanoid") then trp.Size = Vector3.new(60,60,60) end
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
                local boats = Workspace:FindFirstChild("Boats")
                if not boats then return end
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

-- Find Island loop
task.spawn(function()
    while task.wait(1.5) do
        pcall(function()
            if getgenv().FindMirage then
                local loc = Workspace._WorldOrigin.Locations
                local m = loc:FindFirstChild("Mirage Island")
                if m then FarmTeleport(m.CFrame * CFrame.new(0, 100, 0), 200, 30) end
            end
            if getgenv().FindPrehistoric then
                local pre = Workspace.Map:FindFirstChild("PrehistoricIsland")
                if pre then FarmTeleport(pre:GetPivot() * CFrame.new(0, 100, 0), 200, 30) end
            end
            if getgenv().FindFrozen then
                local loc = Workspace._WorldOrigin.Locations
                local f = loc:FindFirstChild("Frozen Dimension")
                if f then FarmTeleport(f.CFrame * CFrame.new(0, 100, 0), 200, 30) end
            end
            if getgenv().FindKitsune then
                local kit = Workspace.Map:FindFirstChild("KitsuneIsland")
                if kit and kit:FindFirstChild("ShrineActive") then
                    local p = kit.ShrineActive:FindFirstChild("NeonShrinePart")
                    if p then FarmTeleport(p.CFrame * CFrame.new(0, 40, 10), 200, 30) end
                end
            end
        end)
    end
end)

-- Sea items crafting
task.spawn(function()
    while task.wait(3) do
        if State.AutoSharkTooth then
            pcall(function()
                CommF_:InvokeServer("CraftItem", "Check", "ToothNecklace")
                CommF_:InvokeServer("CraftItem", "Craft", "ToothNecklace")
            end)
        end
        if State.AutoTerrorJaw then
            pcall(function()
                CommF_:InvokeServer("CraftItem", "Check", "TerrorJaw")
                CommF_:InvokeServer("CraftItem", "Craft", "TerrorJaw")
            end)
        end
        if State.AutoMonsterMagnet then
            pcall(function()
                CommF_:InvokeServer("CraftItem", "Check", "MonsterMagnet")
                CommF_:InvokeServer("CraftItem", "Craft", "MonsterMagnet")
            end)
        end
        if State.AutoSharkAnchor then
            pcall(function()
                CommF_:InvokeServer("CraftItem", "Check", "SharkAnchor")
                CommF_:InvokeServer("CraftItem", "Craft", "SharkAnchor")
            end)
        end
    end
end)

-- ESP loop
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            -- Cleanup invalid
            for part, bb in pairs(State.ESPObjects) do
                if not part.Parent or not bb.Parent then
                    pcall(function() bb:Destroy() end)
                    State.ESPObjects[part] = nil
                end
            end

            local hrp = GetHRP()
            if not hrp then return end
            local myPos = hrp.Position

            if State.ESPPlayer then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= player and plr.Character then
                        local trp = plr.Character:FindFirstChild("HumanoidRootPart")
                        if trp then
                            local d = math.floor((trp.Position - myPos).Magnitude / 3)
                            CreateESP(trp, "[ " .. plr.Name .. " ] [ " .. d .. " ]", Color3.fromRGB(255, 100, 100))
                        end
                    end
                end
            end

            if State.ESPFruit then
                for _, o in ipairs(Workspace:GetChildren()) do
                    if (o:IsA("Tool") or o:IsA("Model")) and o.Name:find("Fruit") then
                        local h = o:FindFirstChild("Handle") or o.PrimaryPart or (o:IsA("Model") and o:FindFirstChildWhichIsA("BasePart", true))
                        if h then
                            local d = math.floor((h.Position - myPos).Magnitude / 3)
                            CreateESP(h, "[ " .. o.Name .. " ] [ " .. d .. " ]", Color3.fromRGB(255, 200, 80))
                        end
                    end
                end
            end

            if State.ESPChest then
                local chests = GetSortedChests()
                for _, c in ipairs(chests) do
                    if c.Parent then
                        local d = math.floor((c.Position - myPos).Magnitude / 3)
                        CreateESP(c, "[ Chest ] [ " .. d .. " ]", Color3.fromRGB(255, 215, 0))
                    end
                end
            end

            if State.ESPIsland then
                local loc = Workspace._WorldOrigin.Locations
                for _, c in ipairs(loc:GetChildren()) do
                    if c:IsA("BasePart") then
                        local d = math.floor((c.Position - myPos).Magnitude / 3)
                        CreateESP(c, "[ " .. c.Name .. " ] [ " .. d .. " ]", Color3.fromRGB(80, 200, 255))
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
                                local d = math.floor((trp.Position - myPos).Magnitude / 3)
                                CreateESP(trp, "[ BOSS " .. e.Name .. " ] [ " .. d .. " ]", Color3.fromRGB(255, 50, 50))
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- Fast Attack
task.spawn(function()
    while task.wait(0.05) do
        if State.FastAttack and IsAlive() then
            pcall(AttackNoCoolDown)
        end
    end
end)

-- Bring Mob
task.spawn(function()
    while task.wait(0.1) do
        if State.BringMob and AnyFarmActive() then
            pcall(BringMobToPlayer, State.BringRange)
        end
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

-- Hide Mob
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

-- Auto Ken
task.spawn(function()
    while task.wait(1) do
        if State.AutoKen then pcall(function() CommF_:InvokeServer("Ken", true) end) end
    end
end)

-- Remove Damage/Notifications
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

-- WalkSpeed/JumpPower
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

-- Anti AFK
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
                    FarmTeleport(p.Character.HumanoidRootPart.CFrame, 200, 30)
                end
            end)
        end
    end
end)

--================================================================
-- DRAG SYSTEM (Mobile-Friendly)
--================================================================
local function MakeDraggable(object, handle, onTap)
    handle = handle or object
    local dragging = false
    local dragStart, startPos
    local moved = false

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragStart = input.Position
            startPos = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if not moved and onTap then
                        task.spawn(onTap)
                    end
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            if math.abs(delta.X) > 8 or math.abs(delta.Y) > 8 then
                moved = true
            end
            object.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--================================================================
-- OPEN / CLOSE
--================================================================
local function OpenUI()
    main.Visible = true
    logo.Visible = false
    main.Size = UDim2.fromOffset(680, 520)
    main.Position = UDim2.new(0.5, -340, 0.5, -260)
    TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quint),
        {Size = UDim2.fromOffset(700, 540), Position = UDim2.new(0.5, -350, 0.5, -270)}):Play()
end

local function CloseUI()
    local tw = TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quint),
        {Size = UDim2.fromOffset(680, 520), Position = UDim2.new(0.5, -340, 0.5, -260)})
    tw:Play()
    tw.Completed:Once(function()
        main.Visible = false
        logo.Visible = true
    end)
end

MakeDraggable(logo, nil, function()
    OpenUI()
end)

MakeDraggable(main, header)

close.Activated:Connect(CloseUI)

--================================================================
-- STARTUP
--================================================================
ShowTab("Farm")
Notify("SysxHub v1.0 Loaded")
