--[[
================================================================
 SYSX HUB | Freemium v1.0 | Created by Ramanotsugarr
 Logo + Banner + 14 Tabs + Farm Config Max 2800 + Farm Nearest
================================================================
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

local LOGO_ID = "rbxassetid://136425814447688"
local BANNER_ID = "rbxassetid://78771184763605"
local MAX_LEVEL = 2800

local CONFIG = {
    Name = "SysxHub",
    Build = "SysxHub v1.0 | Created by Ramanotsugarr",
    Discord = "https://discord.gg/E5kQJW3hn",
    TweenMobSpeed = 400,
    IslandTweenSpeed = 200,
    FruitTweenSpeed = 180,
}

local State = {
    AutoFarm=false, AutoFarmNearest=false, AutoChest=false, AutoBoss=false,
    AutoFruit=false, AutoKillNearest=false, AutoRaid=false,
    AutoGacha=false, StoreFruit=false, AutoFish=false, AutoAddStats=false,
    AutoRaceV2=false, AutoRaceV3=false,
    AutoCastleRaid=false, AutoFactoryRaid=false,
    AutoEliteHunter=false, EliteProgress=0, KilledElites={},
    CastleRaidActive=false, FactoryRaidActive=false,
    AutoFarmSea=false, AutoKillSeaBeast=false,
    AutoBuyBoat=false, AutoRemoveRock=false,
    FindMirage=false, FindKitsune=false, KitsuneLevel=35,
    FindPrehistoric=false, AutoKillGolem=false,
    AutoCollectBone=false, AutoCollectDinoEgg=false,
    FindFrozenDim=false, AutoHitLeviathan=false,
    AutoShootHeart=false, AutoDriveTiki=false,
    BoatSpeed=100, BoatHeight=5,
    SelectedBoat="Dinghy", SelectedSeaMob="Sea Beast",
    SeaEventActive=false, SeaEventMob="Sea Beast",
    SelectedWeapon=nil, SelectedCategory=nil,
    SelectedBoss=nil, SelectedRaid=nil, SelectedPlayer=nil,
    SelectedIsland="Starter Island", SelectedMelee=nil, SelectedSword=nil,
    SelectedGun=nil, SelectedAbility=nil,
    FruitTweenEnabled=false, FruitStoreEnabled=true,
    BringMob=false, BringMobRange=50, InfiniteJump=false, BoostFPS=false,
    Hitbox=false, HitboxPart=nil, Aimbot=false, WalkWater=false,
    LastBring=0, AntiAFK=true, Notifications=true,
    StatsMelee=0, StatsSword=0, StatsGun=0, StatsBloxFruit=0,
    OriginalLighting=nil, FirstRunChest=true, UncheckedChests={},
    ESPPlayer=false, ESPIsland=false, ESPFruit=false, ESPBlueGear=false,
    ESPChest=false, ESPFlower=false, ESPObjects={},
}

local old = PlayerGui:FindFirstChild("SysxHub")
if old then old:Destroy() end

--// HELPERS
local function Create(cls, props)
    local o = Instance.new(cls)
    for k,v in pairs(props or {}) do pcall(function() o[k]=v end) end
    return o
end
local function Corner(p, r)
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r or 8) c.Parent = p return c
end
local function Stroke(p, c, t, tr)
    local s = Instance.new("UIStroke") s.Color = c or Color3.fromRGB(0,150,255)
    s.Thickness = t or 1.2 s.Transparency = tr or 0.4 s.Parent = p return s
end
local function GetHRP() local c = Player.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function GetDist(a,b) return (a-b).Magnitude end
local function Tween(o, props, time)
    TweenService:Create(o, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

--// REMOTE
local CommF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
local function Invoke(...)
    if not CommF then return nil end
    local ok, res = pcall(function(...) return CommF:InvokeServer(...) end, ...)
    if not ok then return nil end
    return res
end

--// NPC FILTER
local PASSIVE = {"dealer","shop","vendor","merchant","quest","giver","bartender","chef","captain","scientist","teacher","guide","trainer","banker","blacksmith","smith","farmer","villager","elder"}

local function IsNPC(m)
    if not m or m == Player.Character then return false end
    local hum = m:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    if not m:FindFirstChild("HumanoidRootPart") then return false end
    if Players:GetPlayerFromCharacter(m) then return false end
    if hum.Health <= 0 or hum.MaxHealth <= 0 then return false end
    if hum.WalkSpeed <= 0 then return false end
    local n = string.lower(m.Name)
    for _, kw in ipairs(PASSIVE) do
        if string.find(n, kw) then return false end
    end
    return true
end

local function ScanEnemies()
    local list = {}
    for _, obj in ipairs(workspace:GetChildren()) do
        if IsNPC(obj) then table.insert(list, obj) end
    end
    return list
end

local function FindBoss(name)
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name == name and obj:FindFirstChildOfClass("Humanoid") then return obj end
    end
    return nil
end

local function FindFruits()
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "fruit") then
            if obj.Parent == workspace or (obj.Parent and obj.Parent.Name == "Map") then
                table.insert(list, obj)
            end
        end
    end
    return list
end

local function GetHeldFruit()
    local char = Player.Character
    if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and string.find(string.lower(tool.Name), "fruit") then
            return tool
        end
    end
    return nil
end

--// FARM CHEST
local MaxSpeed = 300
local function getCharacter()
    if not Player.Character then Player.CharacterAdded:Wait() end
    Player.Character:WaitForChild("HumanoidRootPart")
    return Player.Character
end
local function toggleNoclip(toggle)
    for _, v in pairs(getCharacter():GetChildren()) do
        if v:IsA("BasePart") then v.CanCollide = not toggle end
    end
end
local function DistanceFromPlrSort(list)
    local root = getCharacter().HumanoidRootPart
    table.sort(list, function(a, b)
        return (root.Position - a.Position).Magnitude < (root.Position - b.Position).Magnitude
    end)
end
local function getChestsSorted()
    if State.FirstRunChest then
        State.FirstRunChest = false
        State.UncheckedChests = {}
        for _, obj in ipairs(game:GetDescendants()) do
            if obj.Name:find("Chest") and obj.ClassName == "Part" then
                table.insert(State.UncheckedChests, obj)
            end
        end
    end
    local chests = {}
    for _, chest in ipairs(State.UncheckedChests) do
        if chest:FindFirstChild("TouchInterest") then table.insert(chests, chest) end
    end
    DistanceFromPlrSort(chests)
    return chests
end
local function TeleportNoclip(goal, speed)
    speed = speed or MaxSpeed
    toggleNoclip(true)
    local root = getCharacter().HumanoidRootPart
    local mag = (root.Position - goal.Position).Magnitude
    while not (mag < 1) do
        if not State.AutoChest then break end
        local dir = (goal.Position - root.Position).unit
        root.CFrame = root.CFrame + dir * (speed * task.wait())
        mag = (root.Position - goal.Position).Magnitude
    end
    toggleNoclip(false)
end

--// WEAPON
local function EquipWeapon()
    local char = Player.Character
    if not char then return nil end
    if State.SelectedWeapon then
        local held = char:FindFirstChild(State.SelectedWeapon)
        if held and held:IsA("Tool") then return held end
        for _, c in ipairs(Player.Backpack:GetChildren()) do
            if c:IsA("Tool") and c.Name == State.SelectedWeapon then c.Parent = char return c end
        end
    end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then return tool end
    for _, c in ipairs(Player.Backpack:GetChildren()) do
        if c:IsA("Tool") then c.Parent = char return c end
    end
    return nil
end

--// TWEEN
local function TweenToPosition(targetPos, speed)
    local hrp = GetHRP()
    if not hrp then return end
    speed = speed or CONFIG.TweenMobSpeed
    local startCF = hrp.CFrame
    local targetCF = CFrame.new(targetPos)
    local distance = (startCF.Position - targetCF.Position).Magnitude
    if distance < 1 then return end
    local duration = distance / speed
    local elapsed = 0
    local conn
    conn = RunService.Heartbeat:Connect(function(dt)
        elapsed += dt
        local alpha = math.clamp(elapsed / duration, 0, 1)
        hrp.CFrame = startCF:Lerp(targetCF, alpha)
        if alpha >= 1 then conn:Disconnect() end
    end)
    task.wait(duration + 0.05)
end

local function TweenToIslandSmooth(targetPos)
    local hrp = GetHRP()
    if not hrp then return false end
    local dist = (hrp.Position - targetPos).Magnitude
    if dist < 5 then return true end
    local lookVec = hrp.CFrame.LookVector
    local targetCF = CFrame.lookAt(targetPos + Vector3.new(0,8,0), targetPos + Vector3.new(0,8,0) + Vector3.new(lookVec.X, 0, lookVec.Z))
    local duration = math.max(dist / CONFIG.IslandTweenSpeed, 0.15)
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    local oldAuto = hum and hum.AutoRotate
    if hum then hum.AutoRotate = false end
    local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = targetCF })
    tween:Play()
    local conn = RunService.Heartbeat:Connect(function()
        if hrp and hrp.Parent then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end)
    tween.Completed:Wait()
    if conn then conn:Disconnect() end
    if hrp then
        hrp.CFrame = targetCF
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    if hum then hum.AutoRotate = oldAuto end
    return true
end

--// ESP
local function CreateESP(target, text, color)
    if not target or not target:IsA("BasePart") then return end
    if State.ESPObjects[target] then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "SysxESP" bb.Size = UDim2.new(0, 140, 0, 30)
    bb.StudsOffset = Vector3.new(0, 3, 0) bb.AlwaysOnTop = true bb.Parent = target
    local label = Instance.new("TextLabel")
    label.Name = "ESPLabel" label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1 label.Text = text
    label.TextColor3 = color or Color3.fromRGB(255,255,255)
    label.TextStrokeTransparency = 0 label.TextStrokeColor3 = Color3.new(0,0,0)
    label.TextScaled = true label.Font = Enum.Font.GothamBold label.Parent = bb
    State.ESPObjects[target] = bb
end
local function ClearAllESP()
    for target, bb in pairs(State.ESPObjects) do pcall(function() bb:Destroy() end) end
    State.ESPObjects = {}
end

--// SMOOTH AIMBOT
local AimbotConnection = nil
local function GetClosestPlayerHead()
    local closest, dist = nil, math.huge
    local camPos = Camera.CFrame.Position
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local d = (head.Position - camPos).Magnitude
                if d < dist and d < 500 then closest, dist = head, d end
            end
        end
    end
    return closest
end
local function StartAimbot()
    if AimbotConnection then AimbotConnection:Disconnect() end
    AimbotConnection = RunService.RenderStepped:Connect(function(dt)
        if not State.Aimbot then return end
        local tgt = GetClosestPlayerHead()
        if not tgt then return end
        local curCF = Camera.CFrame
        local tgtCF = CFrame.new(curCF.Position, tgt.Position)
        Camera.CFrame = curCF:Lerp(tgtCF, math.clamp(dt * 10, 0, 1))
    end)
end
local function StopAimbot()
    if AimbotConnection then AimbotConnection:Disconnect() AimbotConnection = nil end
end

--// WALK ON WATER
local WalkWaterConnection = nil
local function getWaterHeight(root)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { Player.Character }
    local result = workspace:Raycast(root.Position + Vector3.new(0,50,0), Vector3.new(0,-150,0), params)
    if result and result.Instance and result.Instance.Name == "Water" then return result.Position.Y end
    return nil
end
local function EnableWalkWater()
    if WalkWaterConnection then WalkWaterConnection:Disconnect() end
    WalkWaterConnection = RunService.Heartbeat:Connect(function()
        if not State.WalkWater then return end
        local hrp = GetHRP()
        if not hrp then return end
        local wy = getWaterHeight(hrp)
        if wy then
            hrp.CFrame = CFrame.new(hrp.Position.X, wy + 3, hrp.Position.Z) * CFrame.Angles(0, math.rad(hrp.Orientation.Y), 0)
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
        end
    end)
end
local function DisableWalkWater()
    if WalkWaterConnection then WalkWaterConnection:Disconnect() WalkWaterConnection = nil end
end

--// ============== FARM CONFIG (MAX 2800) ==============
local FarmConfig = {
    {Min=1,    Max=9,    Island="Starter Island",  Quest="BanditQuest1",    QuestNum=1, NPC="Bandit"},
    {Min=10,   Max=14,   Island="Jungle",          Quest="JungleQuest",     QuestNum=1, NPC="Monkey"},
    {Min=15,   Max=29,   Island="Jungle",          Quest="JungleQuest",     QuestNum=2, NPC="Gorilla"},
    {Min=30,   Max=59,   Island="Pirate Village",  Quest="BuggyQuest1",     QuestNum=1, NPC="Pirate"},
    {Min=60,   Max=74,   Island="Pirate Village",  Quest="BuggyQuest1",     QuestNum=2, NPC="Brute"},
    {Min=75,   Max=89,   Island="Desert",          Quest="DesertQuest",     QuestNum=1, NPC="Desert Bandit"},
    {Min=90,   Max=99,   Island="Frozen Village",  Quest="SnowQuest",       QuestNum=1, NPC="Snow Bandit"},
    {Min=100,  Max=104,  Island="Frozen Village",  Quest="SnowQuest",       QuestNum=2, NPC="Snowman"},
    {Min=105,  Max=119,  Island="Frozen Village",  Quest="SnowQuest",       QuestNum=3, NPC="Yeti"},
    {Min=120,  Max=129,  Island="Marine Fortress", Quest="MarineQuest2",    QuestNum=1, NPC="Chief Petty Officer"},
    {Min=130,  Max=149,  Island="Marine Fortress", Quest="MarineQuest2",    QuestNum=2, NPC="Vice Admiral"},
    {Min=150,  Max=174,  Island="Skylands",        Quest="SkyQuest",        QuestNum=1, NPC="Sky Bandit"},
    {Min=175,  Max=189,  Island="Skylands",        Quest="SkyQuest",        QuestNum=2, NPC="Dark Master"},
    {Min=190,  Max=209,  Island="Prison",          Quest="PrisonQuest",     QuestNum=1, NPC="Prisoner"},
    {Min=210,  Max=224,  Island="Prison",          Quest="PrisonQuest",     QuestNum=2, NPC="Dangerous Prisoner"},
    {Min=225,  Max=249,  Island="Prison",          Quest="PrisonQuest",     QuestNum=3, NPC="Head Jailer"},
    {Min=250,  Max=274,  Island="Colosseum",       Quest="ColosseumQuest",  QuestNum=1, NPC="Gladiator"},
    {Min=275,  Max=299,  Island="Magma Village",   Quest="MagmaQuest",      QuestNum=1, NPC="Military Soldier"},
    {Min=300,  Max=324,  Island="Magma Village",   Quest="MagmaQuest",      QuestNum=2, NPC="Military Spy"},
    {Min=325,  Max=374,  Island="Magma Village",   Quest="MagmaQuest",      QuestNum=3, NPC="Magma Admiral"},
    {Min=375,  Max=399,  Island="Underwater City", Quest="FishmanQuest",    QuestNum=1, NPC="Fishman Warrior"},
    {Min=400,  Max=449,  Island="Underwater City", Quest="FishmanQuest",    QuestNum=2, NPC="Fishman Commando"},
    {Min=450,  Max=474,  Island="Fountain City",   Quest="FountainQuest",   QuestNum=1, NPC="Galley Pirate"},
    {Min=475,  Max=499,  Island="Fountain City",   Quest="FountainQuest",   QuestNum=2, NPC="Galley Captain"},
    {Min=500,  Max=524,  Island="Kingdom of Rose", Quest="Area1Quest",      QuestNum=1, NPC="Raider"},
    {Min=525,  Max=549,  Island="Kingdom of Rose", Quest="Area1Quest",      QuestNum=2, NPC="Mercenary"},
    {Min=550,  Max=624,  Island="Kingdom of Rose", Quest="Area1Quest",      QuestNum=3, NPC="Swan Pirate"},
    {Min=625,  Max=649,  Island="Green Zone",       Quest="Area2Quest",      QuestNum=1, NPC="Marine Lieutenant"},
    {Min=650,  Max=699,  Island="Green Zone",       Quest="Area2Quest",      QuestNum=2, NPC="Marine Rear Admiral"},
    {Min=700,  Max=724,  Island="Graveyard",        Quest="GraveyardQuest",  QuestNum=1, NPC="Zombie"},
    {Min=725,  Max=774,  Island="Graveyard",        Quest="GraveyardQuest",  QuestNum=2, NPC="Vampire"},
    {Min=775,  Max=799,  Island="Snow Mountain",    Quest="SnowMountainQuest",QuestNum=1, NPC="Snow Trooper"},
    {Min=800,  Max=874,  Island="Snow Mountain",    Quest="SnowMountainQuest",QuestNum=2, NPC="Winter Warrior"},
    {Min=875,  Max=899,  Island="Hot and Cold",     Quest="PunkHazardQuest", QuestNum=1, NPC="Lab Subordinate"},
    {Min=900,  Max=949,  Island="Hot and Cold",     Quest="PunkHazardQuest", QuestNum=2, NPC="Horned Warrior"},
    {Min=950,  Max=974,  Island="Hot and Cold",     Quest="PunkHazardQuest", QuestNum=3, NPC="Magma Ninja"},
    {Min=975,  Max=999,  Island="Hot and Cold",     Quest="PunkHazardQuest", QuestNum=4, NPC="Lava Pirate"},
    {Min=1000, Max=1049, Island="Cursed Ship",      Quest="CursedShipQuest", QuestNum=1, NPC="Ship Deckhand"},
    {Min=1050, Max=1099, Island="Cursed Ship",      Quest="CursedShipQuest", QuestNum=2, NPC="Ship Engineer"},
    {Min=1100, Max=1124, Island="Cursed Ship",      Quest="CursedShipQuest", QuestNum=3, NPC="Ship Steward"},
    {Min=1125, Max=1174, Island="Cursed Ship",      Quest="CursedShipQuest", QuestNum=4, NPC="Ship Officer"},
    {Min=1175, Max=1199, Island="Ice Castle",       Quest="IceCastleQuest",  QuestNum=1, NPC="Arctic Warrior"},
    {Min=1200, Max=1249, Island="Ice Castle",       Quest="IceCastleQuest",  QuestNum=2, NPC="Snow Lurker"},
    {Min=1250, Max=1274, Island="Ice Castle",       Quest="IceCastleQuest",  QuestNum=3, NPC="Awakened Ice Admiral"},
    {Min=1275, Max=1299, Island="Forgotten Island", Quest="ForgottenQuest",  QuestNum=1, NPC="Sea Soldier"},
    {Min=1300, Max=1349, Island="Forgotten Island", Quest="ForgottenQuest",  QuestNum=2, NPC="Water Fighter"},
    {Min=1350, Max=1374, Island="Forgotten Island", Quest="ForgottenQuest",  QuestNum=3, NPC="Tide Keeper"},
    {Min=1500, Max=1524, Island="Port Town",        Quest="PortQuest",       QuestNum=1, NPC="Pirate Millionaire"},
    {Min=1525, Max=1574, Island="Port Town",        Quest="PortQuest",       QuestNum=2, NPC="Pistol Billionaire"},
    {Min=1575, Max=1599, Island="Hydra Island",     Quest="HydraQuest",      QuestNum=1, NPC="Dragon Crew Warrior"},
    {Min=1600, Max=1624, Island="Hydra Island",     Quest="HydraQuest",      QuestNum=2, NPC="Dragon Crew Archer"},
    {Min=1625, Max=1649, Island="Great Tree",       Quest="GreatTreeQuest",  QuestNum=1, NPC="Marine Commodore"},
    {Min=1650, Max=1699, Island="Great Tree",       Quest="GreatTreeQuest",  QuestNum=2, NPC="Marine Rear Admiral"},
    {Min=1700, Max=1724, Island="Floating Turtle",  Quest="ForestQuest",     QuestNum=1, NPC="Forest Pirate"},
    {Min=1725, Max=1774, Island="Floating Turtle",  Quest="ForestQuest",     QuestNum=2, NPC="Mythological Pirate"},
    {Min=1775, Max=1799, Island="Floating Turtle",  Quest="ForestQuest",     QuestNum=3, NPC="Jungle Pirate"},
    {Min=1800, Max=1824, Island="Floating Turtle",  Quest="ForestQuest",     QuestNum=4, NPC="Musketeer Pirate"},
    {Min=1825, Max=1849, Island="Floating Turtle",  Quest="ForestQuest",     QuestNum=5, NPC="Fishman Raider"},
    {Min=1850, Max=1874, Island="Floating Turtle",  Quest="ForestQuest",     QuestNum=6, NPC="Fishman Captain"},
    {Min=1875, Max=1899, Island="Floating Turtle",  Quest="ForestQuest",     QuestNum=7, NPC="Forest Pirate"},
    {Min=1900, Max=1924, Island="Haunted Castle",   Quest="HauntedQuest",    QuestNum=1, NPC="Reborn Skeleton"},
    {Min=1925, Max=1949, Island="Haunted Castle",   Quest="HauntedQuest",    QuestNum=2, NPC="Living Zombie"},
    {Min=1950, Max=1974, Island="Haunted Castle",   Quest="HauntedQuest",    QuestNum=3, NPC="Demonic Soul"},
    {Min=1975, Max=1999, Island="Haunted Castle",   Quest="HauntedQuest",    QuestNum=4, NPC="Soul Reaper"},
    {Min=2000, Max=2024, Island="Sea of Treats",    Quest="CakeQuest",       QuestNum=1, NPC="Candy Rebel"},
    {Min=2025, Max=2049, Island="Sea of Treats",    Quest="CakeQuest",       QuestNum=2, NPC="Sweet Thief"},
    {Min=2050, Max=2074, Island="Sea of Treats",    Quest="CakeQuest",       QuestNum=3, NPC="Cookie Crafter"},
    {Min=2075, Max=2099, Island="Sea of Treats",    Quest="CakeQuest",       QuestNum=4, NPC="Cake Guard"},
    {Min=2100, Max=2124, Island="Chocolate Land",   Quest="CakeQuest",       QuestNum=5, NPC="Chocolate Bar Battler"},
    {Min=2125, Max=2149, Island="Chocolate Land",   Quest="CakeQuest",       QuestNum=6, NPC="Cocoa Warrior"},
    {Min=2150, Max=2174, Island="Cake Land",        Quest="CakeQuest",       QuestNum=7, NPC="Sweet Thief"},
    {Min=2175, Max=2199, Island="Cake Land",        Quest="CakeQuest",       QuestNum=8, NPC="Candy Rebel"},
    {Min=2200, Max=2249, Island="Cake Land",        Quest="CakeQuest",       QuestNum=9, NPC="Candy Pirate"},
    {Min=2250, Max=2299, Island="Cake Land",        Quest="CakeQuest",       QuestNum=10, NPC="Snow Demon"},
    {Min=2300, Max=2349, Island="Tiki Outpost",     Quest="TikiQuest",       QuestNum=1, NPC="Isle Champion"},
    {Min=2350, Max=2399, Island="Tiki Outpost",     Quest="TikiQuest",       QuestNum=2, NPC="Isle Outlaw"},
    {Min=2400, Max=2449, Island="Tiki Outpost",     Quest="TikiQuest",       QuestNum=3, NPC="Island Boy"},
    {Min=2450, Max=2499, Island="Tiki Outpost",     Quest="TikiQuest",       QuestNum=4, NPC="Tiki Warrior"},
    {Min=2500, Max=2549, Island="Tiki Outpost",     Quest="TikiQuest",       QuestNum=5, NPC="Tiki Chief"},
    {Min=2550, Max=2599, Island="Tiki Outpost",     Quest="TikiQuest",       QuestNum=6, NPC="Tiki Warrior"},
    {Min=2600, Max=2649, Island="Tiki Outpost",     Quest="TikiQuest",       QuestNum=7, NPC="Tiki Chief"},
    {Min=2650, Max=2699, Island="Final Island",     Quest="SubmergedQuest",  QuestNum=1, NPC="Final Warrior"},
    {Min=2700, Max=2749, Island="Final Island",     Quest="SubmergedQuest",  QuestNum=2, NPC="Final Champion"},
    {Min=2750, Max=2800, Island="Final Island",     Quest="SubmergedQuest",  QuestNum=3, NPC="Final Boss"},
}

local IslandCoords = {
    ["Starter Island"]=Vector3.new(1077,15,1450),["Jungle"]=Vector3.new(-1620,30,200),
    ["Pirate Village"]=Vector3.new(-1100,15,3800),["Desert"]=Vector3.new(980,15,4200),
    ["Frozen Village"]=Vector3.new(-70,20,-2500),["Marine Fortress"]=Vector3.new(-5100,20,4050),
    ["Skylands"]=Vector3.new(-4650,850,-3220),["Prison"]=Vector3.new(4850,15,650),
    ["Colosseum"]=Vector3.new(-1800,50,-3000),["Magma Village"]=Vector3.new(-5200,20,-300),
    ["Underwater City"]=Vector3.new(6000,-150,3000),["Fountain City"]=Vector3.new(5600,60,-5000),
    ["Upper Skylands"]=Vector3.new(-4650,1200,-3220),["Kingdom of Rose"]=Vector3.new(-800,20,1800),
    ["Green Zone"]=Vector3.new(-2500,30,100),["Graveyard"]=Vector3.new(6500,60,4500),
    ["Snow Mountain"]=Vector3.new(400,30,-5300),["Hot and Cold"]=Vector3.new(-5500,30,-4000),
    ["Cursed Ship"]=Vector3.new(923,100,32000),["Ice Castle"]=Vector3.new(5000,60,-6500),
    ["Forgotten Island"]=Vector3.new(-3050,100,-7500),["Port Town"]=Vector3.new(-290,20,6000),
    ["Hydra Island"]=Vector3.new(5800,30,-2000),["Great Tree"]=Vector3.new(2700,60,3000),
    ["Floating Turtle"]=Vector3.new(-1600,60,3500),["Haunted Castle"]=Vector3.new(-9500,100,5800),
    ["Sea of Treats"]=Vector3.new(-700,100,-11000),["Chocolate Land"]=Vector3.new(-700,100,-11000),
    ["Cake Land"]=Vector3.new(-700,100,-11000),["Tiki Outpost"]=Vector3.new(-1000,60,6000),
    ["Final Island"]=Vector3.new(0,100,0),
}

local function GetFarmData(level)
    for _, data in ipairs(FarmConfig) do
        if level >= data.Min and level <= data.Max then return data end
    end
    return nil
end

--// FARM NEAREST LOGIC
local function GetNearestEnemy(maxRadius)
    local hrp = GetHRP()
    if not hrp then return nil end
    maxRadius = maxRadius or 500
    local nearest, nearestDist = nil, maxRadius
    for _, obj in ipairs(workspace:GetChildren()) do
        if IsNPC(obj) then
            local trp = obj:FindFirstChild("HumanoidRootPart")
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if trp and hum and hum.Health > 0 then
                local d = GetDist(trp.Position, hrp.Position)
                if d < nearestDist then nearest = obj nearestDist = d end
            end
        end
    end
    return nearest
end

--// ============== GUI ==============
local Gui = Create("ScreenGui", {
    Name="SysxHub", Parent=PlayerGui, ResetOnSpawn=false,
    IgnoreGuiInset=true, DisplayOrder=999999,
    ZIndexBehavior=Enum.ZIndexBehavior.Global,
})

local Notification = Create("TextLabel", {
    Parent=Gui, AnchorPoint=Vector2.new(0.5,1),
    Position=UDim2.new(0.5,0,1,-20), Size=UDim2.fromOffset(340,44),
    BackgroundColor3=Color3.fromRGB(17,13,29), BackgroundTransparency=0.05,
    Text="", TextColor3=Color3.fromRGB(255,255,255), TextSize=13,
    Font=Enum.Font.GothamMedium, Visible=false, ZIndex=999999,
})
Corner(Notification, 10)
Stroke(Notification, Color3.fromRGB(0,150,255), 1.5, 0.3)

local NT = 0
function Notify(text)
    if not State.Notifications then return end
    NT += 1
    local tk = NT
    Notification.Text = tostring(text)
    Notification.Visible = true
    Notification.TextTransparency = 1
    Notification.BackgroundTransparency = 1
    Tween(Notification, {TextTransparency=0, BackgroundTransparency=0.05}, 0.2)
    task.delay(2.5, function()
        if tk ~= NT then return end
        Tween(Notification, {TextTransparency=1, BackgroundTransparency=1}, 0.2)
        task.wait(0.2)
        if tk == NT then Notification.Visible = false end
    end)
end

local UIScale = Instance.new("UIScale")
UIScale.Scale = 1 UIScale.Parent = Gui
local function UpdateScale()
    if not Camera then return end
    local vp = Camera.ViewportSize
    if vp.X <= 500 then UIScale.Scale = math.clamp(vp.X/420, 0.82, 1)
    elseif vp.X <= 800 then UIScale.Scale = 0.9
    else UIScale.Scale = 1 end
end
UpdateScale()
if Camera then Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale) end

--// OPEN BUTTON
local OpenButton = Create("ImageButton", {
    Name="SysxLogo", Parent=Gui,
    Size=UDim2.fromOffset(62,62), Position=UDim2.new(0,18,0.5,-31),
    BackgroundColor3=Color3.fromRGB(8,14,28),
    BorderSizePixel=0, Image=LOGO_ID, ScaleType=Enum.ScaleType.Fit,
    AutoButtonColor=false, ZIndex=100,
})
Corner(OpenButton, 18)
local OS = Instance.new("UIStroke")
OS.Color = Color3.fromRGB(35,125,255) OS.Thickness = 1.5 OS.Transparency = 0.1 OS.Parent = OpenButton

--// MAIN
local Main = Create("Frame", {
    Name="Main", Parent=Gui,
    Size=UDim2.fromOffset(780,600), Position=UDim2.new(0.5,-390,0.5,-300),
    BackgroundColor3=Color3.fromRGB(6,11,23),
    BorderSizePixel=0, Visible=false, ClipsDescendants=true, ZIndex=10,
})
Corner(Main, 18)
local MS = Instance.new("UIStroke")
MS.Color = Color3.fromRGB(38,100,190) MS.Thickness = 1.2 MS.Transparency = 0.25 MS.Parent = Main

--// HEADER
local Header = Create("Frame", {Name="Header", Parent=Main, Size=UDim2.new(1,0,0,82), BackgroundTransparency=1, ZIndex=20})
Create("ImageLabel", {Name="Logo", Parent=Header, Size=UDim2.fromOffset(55,55), Position=UDim2.fromOffset(14,8), BackgroundTransparency=1, Image=LOGO_ID, ScaleType=Enum.ScaleType.Fit, ZIndex=22})
Create("TextLabel", {Parent=Header, BackgroundTransparency=1, Position=UDim2.fromOffset(78,12), Size=UDim2.fromOffset(320,30), Text="SysxHub", TextColor3=Color3.fromRGB(235,242,255), TextSize=23, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=22})
Create("TextLabel", {Parent=Header, BackgroundTransparency=1, Position=UDim2.fromOffset(79,39), Size=UDim2.fromOffset(320,20), Text="Play Smarter, Not Harder", TextColor3=Color3.fromRGB(120,150,195), TextSize=12, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=22})

local StatusDot = Create("Frame", {Parent=Header, Size=UDim2.fromOffset(10,10), Position=UDim2.new(1,-280,0,26), BackgroundColor3=Color3.fromRGB(0,220,150), BorderSizePixel=0, ZIndex=22})
Corner(StatusDot, 10)
Create("TextLabel", {Parent=Header, BackgroundTransparency=1, Position=UDim2.new(1,-265,0,19), Size=UDim2.fromOffset(90,25), Text="Game Loaded", TextColor3=Color3.fromRGB(210,220,235), TextSize=11, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=22})
Create("TextLabel", {Parent=Header, BackgroundTransparency=1, Position=UDim2.new(1,-165,0,19), Size=UDim2.fromOffset(60,25), Text="v1.0.0", TextColor3=Color3.fromRGB(130,145,175), TextSize=11, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Center, ZIndex=22})

local CloseButton = Create("ImageButton", {
    Parent=Header, Size=UDim2.fromOffset(42,42), Position=UDim2.new(1,-58,0,14),
    BackgroundColor3=Color3.fromRGB(23,18,38), BackgroundTransparency=0.05,
    Image=LOGO_ID, ImageColor3=Color3.fromRGB(255,255,255),
    ScaleType=Enum.ScaleType.Fit, AutoButtonColor=false, ZIndex=25,
})
Corner(CloseButton, 10)
Stroke(CloseButton, Color3.fromRGB(0,150,255), 1.5, 0.25)
Create("Frame", {Parent=Header, Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1), BackgroundColor3=Color3.fromRGB(35,55,85), BackgroundTransparency=0.35, BorderSizePixel=0, ZIndex=22})

--// BANNER
local BannerHolder = Create("Frame", {
    Name="BannerHolder", Parent=Main,
    Size=UDim2.new(1,-32,0,150), Position=UDim2.fromOffset(16,98),
    BackgroundColor3=Color3.fromRGB(10,18,34), BorderSizePixel=0, ClipsDescendants=true, ZIndex=12,
})
Corner(BannerHolder, 14)
Stroke(BannerHolder, Color3.fromRGB(35,95,175), 1, 0.25)
Create("ImageLabel", {Name="Banner", Parent=BannerHolder, Size=UDim2.fromScale(1,1), Position=UDim2.fromScale(0,0), BackgroundTransparency=1, Image=BANNER_ID, ScaleType=Enum.ScaleType.Crop, ZIndex=12})
Create("Frame", {Name="BannerOverlay", Parent=BannerHolder, Size=UDim2.fromScale(1,1), BackgroundColor3=Color3.fromRGB(0,10,25), BackgroundTransparency=0.72, BorderSizePixel=0, ZIndex=13})

--// CONTENT
local Content = Create("Frame", {
    Name="Content", Parent=Main,
    Size=UDim2.new(1,-32,1,-264), Position=UDim2.fromOffset(16,256),
    BackgroundTransparency=1, ZIndex=14, ClipsDescendants=false,
})

local Sidebar = Create("Frame", {
    Parent=Content, BackgroundColor3=Color3.fromRGB(17,13,29),
    Size=UDim2.new(0,140,1,0), BorderSizePixel=0, ZIndex=15,
})
Corner(Sidebar, 10)
Stroke(Sidebar, Color3.fromRGB(0,150,255), 1, 0.4)

local TabList = Create("ScrollingFrame", {
    Parent=Sidebar, BackgroundTransparency=1,
    Position=UDim2.new(0,6,0,6), Size=UDim2.new(1,-12,1,-12),
    CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ScrollBarThickness=2, ScrollBarImageColor3=Color3.fromRGB(0,150,255), BorderSizePixel=0, ZIndex=16,
})
local TL = Instance.new("UIListLayout")
TL.Padding = UDim.new(0,4) TL.SortOrder = Enum.SortOrder.LayoutOrder TL.Parent = TabList

local ContentScroll = Create("ScrollingFrame", {
    Parent=Content, BackgroundTransparency=1,
    Position=UDim2.new(0,148,0,0), Size=UDim2.new(1,-148,1,0),
    CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ScrollBarThickness=3, ScrollBarImageColor3=Color3.fromRGB(0,150,255),
    BorderSizePixel=0, ZIndex=14, ClipsDescendants=false,
})

local Pages, Tabs = {}, {}

local function CreatePage(name)
    local P = Create("ScrollingFrame", {
        Name=name, Parent=ContentScroll, BackgroundTransparency=1,
        Position=UDim2.new(0,4,0,4), Size=UDim2.new(1,-8,1,-8),
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollBarThickness=3, ScrollBarImageColor3=Color3.fromRGB(0,150,255),
        BorderSizePixel=0, Visible=false, ZIndex=12, ClipsDescendants=false,
    })
    local L = Instance.new("UIListLayout")
    L.Padding = UDim.new(0,5) L.SortOrder = Enum.SortOrder.LayoutOrder L.Parent = P
    Pages[name] = P
    return P
end

local function CreateToggle(parent, text, default, cb)
    local S2 = default or false
    local B = Create("TextButton", {
        Parent=parent, BackgroundColor3=Color3.fromRGB(17,13,29),
        Size=UDim2.new(1,0,0,38), Text="", AutoButtonColor=false, BorderSizePixel=0, ZIndex=100,
    })
    Corner(B, 8)
    Stroke(B, Color3.fromRGB(0,150,255), 1.2, 0.4)
    Create("TextLabel", {Parent=B, BackgroundTransparency=1, Position=UDim2.new(0,10,0,0), Size=UDim2.new(1,-60,1,0), Text=text, TextColor3=Color3.fromRGB(255,255,255), TextSize=12, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=101})
    local Ind = Create("Frame", {Parent=B, BackgroundColor3=Color3.fromRGB(55,50,65), Size=UDim2.fromOffset(34,18), Position=UDim2.new(1,-44,0.5,-9), ZIndex=101})
    Corner(Ind, 20)
    local Dot = Create("Frame", {Parent=Ind, BackgroundColor3=Color3.fromRGB(190,185,200), Size=UDim2.fromOffset(12,12), Position=UDim2.new(0,3,0.5,-6), ZIndex=102})
    Corner(Dot, 20)
    local function Update()
        if S2 then
            Ind.BackgroundColor3 = Color3.fromRGB(0,150,255)
            Dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
            Tween(Dot, {Position=UDim2.new(1,-15,0.5,-6)}, 0.15)
        else
            Ind.BackgroundColor3 = Color3.fromRGB(55,50,65)
            Dot.BackgroundColor3 = Color3.fromRGB(190,185,200)
            Tween(Dot, {Position=UDim2.new(0,3,0.5,-6)}, 0.15)
        end
    end
    B.Activated:Connect(function()
        S2 = not S2 Update()
        if cb then pcall(cb, S2) end
    end)
    Update()
    return B
end

local function CreateDropdown(parent, title, options, cb)
    local Holder = Create("Frame", {
        Parent=parent, BackgroundColor3=Color3.fromRGB(17,13,29),
        Size=UDim2.new(1,0,0,38), BorderSizePixel=0, ZIndex=100, ClipsDescendants=false,
    })
    Corner(Holder, 8)
    Stroke(Holder, Color3.fromRGB(0,150,255), 1.2, 0.4)
    local Selected = options[1] or "Select"
    local TitleLbl = Create("TextLabel", {
        Parent=Holder, BackgroundTransparency=1,
        Position=UDim2.new(0,10,0,0), Size=UDim2.new(1,-35,1,0),
        Text=title..": "..Selected, TextColor3=Color3.fromRGB(255,255,255),
        TextSize=12, Font=Enum.Font.GothamMedium,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=101,
    })
    Create("TextLabel", {
        Parent=Holder, BackgroundTransparency=1,
        Position=UDim2.new(1,-22,0,0), Size=UDim2.new(0,18,1,0),
        Text="v", TextColor3=Color3.fromRGB(255,255,255),
        TextSize=11, Font=Enum.Font.GothamBold, ZIndex=101,
    })
    local clickBtn = Create("TextButton", {
        Parent=Holder, BackgroundTransparency=1,
        Size=UDim2.new(1,0,1,0), Text="", AutoButtonColor=false, ZIndex=110,
    })
    clickBtn.Activated:Connect(function()
        local popup = Create("Frame", {
            Parent=Gui, AnchorPoint=Vector2.new(0.5,0.5),
            Position=UDim2.new(0.5,0,0.5,0),
            Size=UDim2.fromOffset(300, math.min(#options*38+80, 400)),
            BackgroundColor3=Color3.fromRGB(10,18,34),
            BorderSizePixel=0, ZIndex=999990,
        })
        Corner(popup, 12)
        local pStroke = Instance.new("UIStroke")
        pStroke.Color = Color3.fromRGB(0,150,255) pStroke.Thickness = 2 pStroke.Parent = popup
        Create("TextLabel", {Parent=popup, BackgroundTransparency=1, Position=UDim2.fromOffset(15,10), Size=UDim2.new(1,-60,0,25), Text=title, TextColor3=Color3.fromRGB(235,242,255), TextSize=15, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=999991})
        local closeBtn = Create("TextButton", {Parent=popup, Position=UDim2.new(1,-40,0,10), Size=UDim2.fromOffset(30,25), Text="×", TextColor3=Color3.fromRGB(255,255,255), TextSize=22, BackgroundTransparency=1, Font=Enum.Font.GothamBold, AutoButtonColor=false, ZIndex=999992})
        closeBtn.Activated:Connect(function() popup:Destroy() end)
        local listScroll = Create("ScrollingFrame", {
            Parent=popup, BackgroundTransparency=1,
            Position=UDim2.fromOffset(10,42), Size=UDim2.new(1,-20,1,-52),
            CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
            ScrollBarThickness=3, ScrollBarImageColor3=Color3.fromRGB(0,150,255),
            BorderSizePixel=0, ZIndex=999991,
        })
        local LL = Instance.new("UIListLayout")
        LL.Padding = UDim.new(0,4) LL.SortOrder = Enum.SortOrder.LayoutOrder LL.Parent = listScroll
        for i, opt in ipairs(options) do
            local OB = Create("TextButton", {
                Parent=listScroll, BackgroundColor3=Color3.fromRGB(17,13,29),
                Size=UDim2.new(1,-8,0,34), Position=UDim2.new(0,4,0,0),
                Text=opt, TextColor3=Color3.fromRGB(255,255,255),
                TextSize=13, Font=Enum.Font.GothamMedium,
                AutoButtonColor=false, BorderSizePixel=0,
                LayoutOrder=i, ZIndex=999992,
                TextXAlignment=Enum.TextXAlignment.Left,
            })
            Corner(OB, 6)
            local pad = Instance.new("UIPadding")
            pad.PaddingLeft = UDim.new(0, 10) pad.Parent = OB
            OB.MouseEnter:Connect(function() TweenService:Create(OB, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(0,150,255)}):Play() end)
            OB.MouseLeave:Connect(function() TweenService:Create(OB, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(17,13,29)}):Play() end)
            OB.Activated:Connect(function()
                Selected = opt
                TitleLbl.Text = title..": "..opt
                if cb then pcall(cb, opt) end
                popup:Destroy()
            end)
        end
    end)
    return Holder
end

local function CreateSlider(parent, title, minVal, maxVal, defaultVal, cb)
    local val = defaultVal or minVal
    local Holder = Create("Frame", {Parent=parent, BackgroundColor3=Color3.fromRGB(17,13,29), Size=UDim2.new(1,0,0,46), BorderSizePixel=0, ZIndex=100})
    Corner(Holder, 8)
    Stroke(Holder, Color3.fromRGB(0,150,255), 1.2, 0.4)
    Create("TextLabel", {Parent=Holder, BackgroundTransparency=1, Position=UDim2.new(0,10,0,5), Size=UDim2.new(1,-70,0,14), Text=title, TextColor3=Color3.fromRGB(255,255,255), TextSize=11, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=101})
    local ValueLbl = Create("TextLabel", {Parent=Holder, BackgroundTransparency=1, Position=UDim2.new(1,-65,0,5), Size=UDim2.new(0,55,0,14), Text=tostring(val), TextColor3=Color3.fromRGB(255,255,255), TextSize=11, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Right, ZIndex=101})
    local Bar = Create("Frame", {Parent=Holder, BackgroundColor3=Color3.fromRGB(23,18,38), Position=UDim2.new(0,10,0,26), Size=UDim2.new(1,-20,0,7), BorderSizePixel=0, ZIndex=101})
    Corner(Bar, 4)
    local Fill = Create("Frame", {Parent=Bar, BackgroundColor3=Color3.fromRGB(0,150,255), Size=UDim2.new((val-minVal)/(maxVal-minVal),0,1,0), BorderSizePixel=0, ZIndex=102})
    Corner(Fill, 4)
    local Btn = Create("TextButton", {Parent=Holder, BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Text="", AutoButtonColor=false, ZIndex=110})
    local dragging = false
    local function Update(mouseX)
        local abs = Bar.AbsolutePosition
        local size = Bar.AbsoluteSize
        local rel = math.clamp((mouseX-abs.X)/size.X, 0, 1)
        val = math.floor(minVal + (maxVal-minVal)*rel + 0.5)
        Fill.Size = UDim2.new(rel, 0, 1, 0) ValueLbl.Text = tostring(val)
        if cb then pcall(cb, val) end
    end
    Btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true Update(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Update(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return Holder
end

local function CreateLabel(parent, text, size)
    local L = Create("TextLabel", {Parent=parent, BackgroundColor3=Color3.fromRGB(17,13,29), Size=UDim2.new(1,0,0,size or 34), Text=text, TextColor3=Color3.fromRGB(255,255,255), TextSize=11, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, BorderSizePixel=0, ZIndex=100})
    Corner(L, 8)
    Stroke(L, Color3.fromRGB(0,150,255), 1.2, 0.4)
    local pad = Instance.new("UIPadding") pad.PaddingLeft = UDim.new(0, 10) pad.Parent = L
    return L
end

local function CreateTab(name, order)
    local B = Create("TextButton", {Parent=TabList, BackgroundColor3=Color3.fromRGB(17,13,29), Size=UDim2.new(1,0,0,32), Text="", AutoButtonColor=false, BorderSizePixel=0, LayoutOrder=order, ZIndex=17})
    Corner(B, 7)
    local L = Create("TextLabel", {Parent=B, BackgroundTransparency=1, Position=UDim2.new(0,8,0,0), Size=UDim2.new(1,-16,1,0), Text=name, TextColor3=Color3.fromRGB(255,255,255), TextSize=11, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=18})
    Tabs[name] = {Button=B, Label=L}
    return B
end

local function ShowTab(name)
    for pn, p in pairs(Pages) do p.Visible = (pn == name) end
    for tn, d in pairs(Tabs) do
        if tn == name then d.Button.BackgroundColor3 = Color3.fromRGB(0,150,255)
        else d.Button.BackgroundColor3 = Color3.fromRGB(17,13,29) end
        d.Label.TextColor3 = Color3.fromRGB(255,255,255)
    end
end

--// PAGES
local DiscordPage = CreatePage("Discord")
local FarmPage = CreatePage("Farm")
local SeaPage = CreatePage("Sea")
local QuestItemsPage = CreatePage("Quest / Items")
local FruitRaidPage = CreatePage("Fruit / Raid")
local FishingPage = CreatePage("Fishing")
local StatusPage = CreatePage("Status")
local PvPPage = CreatePage("PvP")
local TrialsPage = CreatePage("Trials")
local SetingPage = CreatePage("Seting")
local TeleportPage = CreatePage("Teleport")
local StatsPage = CreatePage("Stats")
local ShopPage = CreatePage("Shop")
local MiscPage = CreatePage("Misc")

--// DISCORD
CreateToggle(DiscordPage, "Copy Discord Link", false, function(s)
    if s then if setclipboard then setclipboard(CONFIG.Discord) Notify("Copied") end end
end)

--// FARM
CreateDropdown(FarmPage, "Select Weapon", {"Melee","Sword","Gun","Fruit"}, function(opt) State.SelectedCategory = opt end)
CreateToggle(FarmPage, "Auto Farm Level", false, function(s)
    State.AutoFarm = s
    if s then State.Hitbox = true else State.Hitbox = false end
    Notify("Auto Farm: "..(s and "ON" or "OFF"))
    if s then
        task.spawn(function()
            while State.AutoFarm do
                pcall(function() Invoke("Buso") end)
                task.wait(2)
            end
        end)
    end
end)
CreateToggle(FarmPage, "Auto Farm Nearest", false, function(s)
    State.AutoFarmNearest = s
    if s then State.Hitbox = true else State.Hitbox = false end
    Notify("Farm Nearest: "..(s and "ON" or "OFF"))
    if s then
        task.spawn(function()
            while State.AutoFarmNearest do
                pcall(function() Invoke("Buso") end)
                task.wait(2)
            end
        end)
    end
end)
CreateToggle(FarmPage, "Auto Kill Nearest", false, function(s) State.AutoKillNearest = s Notify("Auto Kill Nearest: "..(s and "ON" or "OFF")) end)
CreateToggle(FarmPage, "Farm Chest", false, function(s)
    State.AutoChest = s
    if s then State.FirstRunChest = true State.UncheckedChests = {} end
    Notify("Farm Chest: "..(s and "ON" or "OFF"))
end)
CreateDropdown(FarmPage, "Select Boss", {"Gorilla King","Bobby","Yeti","Mob Leader","Vice Admiral","Saber Expert","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Diamond","Jeremy","Fajita","Don Swan","Darkbeard","Smoke Admiral","Cursed Captain","Awakened Ice Admiral","Tide Keeper","Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate","Longma","Cake Queen"}, function(opt) State.SelectedBoss = opt Notify("Boss: "..opt) end)
CreateToggle(FarmPage, "Auto Farm Boss", false, function(s) State.AutoBoss = s Notify("Auto Farm Boss: "..(s and "ON" or "OFF")) end)
CreateToggle(FarmPage, "Castle Raid", false, function(s) State.AutoCastleRaid = s Notify("Castle Raid: "..(s and "ON" or "OFF")) end)
CreateToggle(FarmPage, "Factory Raid", false, function(s) State.AutoFactoryRaid = s Notify("Factory Raid: "..(s and "ON" or "OFF")) end)
local BonesLabel = CreateLabel(FarmPage, "Bones: -", 34)
task.spawn(function()
    while task.wait(3) do
        local res = Invoke("Bones", "Check")
        if res then BonesLabel.Text = "Bones: "..tostring(res) end
    end
end)
CreateToggle(FarmPage, "Random Bone", false, function(s) if s then Invoke("Bones", "Buy", 1, 1) Notify("Random Bone") end end)

--// SEA
CreateDropdown(SeaPage, "Select Mob", {"Sea Beast","Terrorshark","Shark","Piranha","Fish Crew Member","Fish Crew Warrior"}, function(opt) State.SelectedSeaMob = opt State.SeaEventMob = opt Notify("Sea Mob: "..opt) end)
CreateDropdown(SeaPage, "Select Boat", {"Dinghy","Bizarre Boat","Speed Boat","Miracle","Sentinel","Guardian","Beast Hunter","Shark Boat"}, function(opt) State.SelectedBoat = opt Notify("Boat: "..opt) end)
CreateToggle(SeaPage, "Auto Farm Sea", false, function(s) State.AutoFarmSea = s Notify("Auto Farm Sea: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Start Sea Event", false, function(s) State.SeaEventActive = s if s then Notify("Sea Event: "..State.SeaEventMob) else Notify("Sea Event stopped") end end)
CreateToggle(SeaPage, "Auto Buy New Boat", false, function(s) State.AutoBuyBoat = s Notify("Auto Buy Boat: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Auto Remove Rock", false, function(s) State.AutoRemoveRock = s Notify("Auto Remove Rock: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Find Mirage Island", false, function(s) State.FindMirage = s Notify("Find Mirage: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Tween Mirage", false, function(s) if s then for _, obj in ipairs(workspace:GetDescendants()) do if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "mirage") then TweenToPosition(obj.Position + Vector3.new(0,5,0), 500) Notify("Tween Mirage") break end end end end)
CreateToggle(SeaPage, "Tween Blue Gear", false, function(s) if s then for _, obj in ipairs(workspace:GetDescendants()) do if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "bluegear") or string.find(string.lower(obj.Name), "blue_gear")) then TweenToPosition(obj.Position + Vector3.new(0,5,0), 500) Notify("Tween Blue Gear") break end end end end)
CreateToggle(SeaPage, "Tween Fruit Dealer", false, function(s) if s then TweenToPosition(Vector3.new(1138, 22, 1480), 500) Notify("Tween Fruit Dealer") end end)
CreateToggle(SeaPage, "Find Kitsune Island", false, function(s) State.FindKitsune = s Notify("Find Kitsune: "..(s and "ON" or "OFF")) end)
CreateSlider(SeaPage, "Kitsune Level", 0, 300, 35, function(v) State.KitsuneLevel = v end)
CreateToggle(SeaPage, "Auto Trade Aura", false, function(s) if s then pcall(function() Invoke("KitsuneTrade", "Aura") end) Notify("Auto Trade Aura") end end)
CreateToggle(SeaPage, "Find Prehistoric Island", false, function(s) State.FindPrehistoric = s Notify("Find Prehistoric: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Auto Kill Golem", false, function(s) State.AutoKillGolem = s Notify("Auto Kill Golem: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Auto Collect Bone", false, function(s) State.AutoCollectBone = s Notify("Auto Collect Bone: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Auto Collect Dino Egg", false, function(s) State.AutoCollectDinoEgg = s Notify("Auto Collect Dino Egg: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Find Frozen Dimension", false, function(s) State.FindFrozenDim = s Notify("Find Frozen Dim: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Auto Hit Leviathan", false, function(s) State.AutoHitLeviathan = s Notify("Auto Hit Leviathan: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Auto Shoot Heart", false, function(s) State.AutoShootHeart = s Notify("Auto Shoot Heart: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Auto Drive To Tiki", false, function(s) State.AutoDriveTiki = s Notify("Auto Drive Tiki: "..(s and "ON" or "OFF")) end)
CreateSlider(SeaPage, "Boat Speed", 0, 250, 100, function(v) State.BoatSpeed = v end)
CreateSlider(SeaPage, "Boat Height", 0, 50, 5, function(v) State.BoatHeight = v end)

--// QUEST / ITEMS
CreateToggle(QuestItemsPage, "Auto Sea 2", false, function(s) if s then Invoke("TravelDressrosa") Notify("Auto Sea 2") end end)
CreateToggle(QuestItemsPage, "Auto Sea 3", false, function(s) if s then Invoke("TravelZou") Notify("Auto Sea 3") end end)
CreateToggle(QuestItemsPage, "Auto Saber", false, function(s) if s then Invoke("BuyItem", "Saber") Notify("Auto Saber") end end)
CreateToggle(QuestItemsPage, "Auto CDK", false, function(s) if s then Invoke("ProQuestProgress", "CDK") Notify("CDK") end end)
CreateToggle(QuestItemsPage, "Auto Dark Dagger", false, function(s)
    if s then
        local hasChalice = Player.Backpack:FindFirstChild("God's Chalice") or (Player.Character and Player.Character:FindFirstChild("God's Chalice"))
        if hasChalice then Invoke("PlaceChalice") Notify("Summoning Indra") else Notify("Need God's Chalice!") end
    end
end)
CreateToggle(QuestItemsPage, "Auto Soul Guitar", false, function(s) if s then Invoke("ProQuestProgress", "SoulGuitar") Notify("Soul Guitar") end end)
CreateToggle(QuestItemsPage, "Auto Yama", false, function(s) if s then Invoke("StartQuest", "EliteHunter", 1) Notify("Elite Hunter") end end)
CreateToggle(QuestItemsPage, "Auto Tushita", false, function(s) if s then Invoke("ProQuestProgress", "Tushita") Notify("Tushita") end end)
CreateToggle(QuestItemsPage, "Auto Buddy Sword", false, function(s)
    if s then
        local boss = FindBoss("Cake Queen")
        if boss then TweenToPosition(boss.HumanoidRootPart.Position + Vector3.new(0,3,0), 300) Notify("Farming Cake Queen") else Notify("Cake Queen not spawned") end
    end
end)
CreateToggle(QuestItemsPage, "Auto Spawn Dough King", false, function(s)
    if s then
        local hasSweet = Player.Backpack:FindFirstChild("Sweet Chalice") or (Player.Character and Player.Character:FindFirstChild("Sweet Chalice"))
        if hasSweet then Invoke("DoughKing") Notify("Summoning Dough King") else Notify("Need Sweet Chalice!") end
    end
end)
CreateToggle(QuestItemsPage, "Auto Elite Hunter", false, function(s)
    State.AutoEliteHunter = s
    if s then State.EliteProgress = 0 State.KilledElites = {} end
    Notify("Auto Elite Hunter: "..(s and "ON" or "OFF"))
end)
local EliteLabel = CreateLabel(QuestItemsPage, "Elite Progress: 0/3", 34)
CreateToggle(QuestItemsPage, "Abandon Quest", false, function(s) if s then Invoke("AbandonQuest") Notify("Abandoned") end end)
CreateToggle(QuestItemsPage, "Torch Puzzle Get", false, function(s) if s then Invoke("ProQuestProgress", "GetTorch") Notify("GetTorch") end end)
CreateToggle(QuestItemsPage, "Torch Puzzle Destroy", false, function(s) if s then Invoke("ProQuestProgress", "DestroyTorch") Notify("DestroyTorch") end end)
CreateToggle(QuestItemsPage, "Cup Puzzle Get", false, function(s) if s then Invoke("ProQuestProgress", "GetCup") Notify("GetCup") end end)
CreateToggle(QuestItemsPage, "Cup Puzzle Fill", false, function(s) if s then Invoke("ProQuestProgress", "FillCup") Notify("FillCup") end end)
CreateToggle(QuestItemsPage, "SickMan Quest", false, function(s) if s then Invoke("ProQuestProgress", "SickMan") Notify("SickMan") end end)
CreateToggle(QuestItemsPage, "RichSon Quest", false, function(s) if s then Invoke("ProQuestProgress", "RichSon") Notify("RichSon") end end)
CreateToggle(QuestItemsPage, "CDK Open Door", false, function(s) if s then Invoke("CDKQuest", "OpenDoor") Notify("CDK Door") end end)
CreateToggle(QuestItemsPage, "CDK Progress", false, function(s) if s then Invoke("CDKQuest", "Progress") Notify("CDK Progress") end end)
CreateToggle(QuestItemsPage, "CDK Boat Quest", false, function(s) if s then Invoke("CDKQuest", "BoatQuest") Notify("CDK Boat") end end)
CreateToggle(QuestItemsPage, "Wenlocktoad 1", false, function(s) if s then Invoke("Wenlocktoad", "1") Notify("Wenlock 1") end end)
CreateToggle(QuestItemsPage, "Wenlocktoad 2", false, function(s) if s then Invoke("Wenlocktoad", "2") Notify("Wenlock 2") end end)
CreateToggle(QuestItemsPage, "Alchemist 1", false, function(s) if s then Invoke("Alchemist", "1") Notify("Alchemist 1") end end)
CreateToggle(QuestItemsPage, "Alchemist 2", false, function(s) if s then Invoke("Alchemist", "2") Notify("Alchemist 2") end end)
CreateToggle(QuestItemsPage, "Auto Temple Door", false, function(s) if s then Invoke("CheckTempleDoor") Notify("Temple Door") end end)
CreateToggle(QuestItemsPage, "Auto Bartilo", false, function(s) if s then Invoke("BartiloQuestProgress") Notify("Bartilo") end end)
CreateToggle(QuestItemsPage, "Auto Guitar Puzzle", false, function(s) if s then Invoke("GuitarPuzzleProgress", "Check") Notify("Guitar") end end)
CreateToggle(QuestItemsPage, "Auto Race V2", false, function(s) State.AutoRaceV2 = s Notify("Race V2: "..(s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Race V3", false, function(s) State.AutoRaceV3 = s Notify("Race V3: "..(s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Blackbeard Reward", false, function(s) if s then Invoke("BlackbeardReward", "DragonClaw", "1") Notify("Blackbeard") end end)
CreateToggle(QuestItemsPage, "Auto Horned Man Bet", false, function(s) if s then Invoke("HornedMan", "Bet") Notify("Horned Man") end end)
CreateToggle(QuestItemsPage, "Auto Talk Trevor", false, function(s) if s then Invoke("TalkTrevor", "1") Notify("Trevor") end end)

--// FRUIT / RAID
CreateToggle(FruitRaidPage, "Tween Fruit", false, function(s) State.FruitTweenEnabled = s Notify("Tween Fruit: "..(s and "ON" or "OFF")) end)
CreateToggle(FruitRaidPage, "Auto Store Fruit", false, function(s) State.FruitStoreEnabled = s Notify("Auto Store: "..(s and "ON" or "OFF")) end)
CreateToggle(FruitRaidPage, "Random Fruit (Gacha)", false, function(s) State.AutoGacha = s Notify("Random Fruit: "..(s and "ON" or "OFF")) end)
CreateDropdown(FruitRaidPage, "Select Raid", {"Flame","Ice","Sand","Dark","Light","Magma","Quake","Buddha","Spider","Phoenix","Dough"}, function(opt) State.SelectedRaid = opt Notify("Raid: "..opt) end)
CreateToggle(FruitRaidPage, "Auto Raid", false, function(s) State.AutoRaid = s Notify("Auto Raid: "..(s and "ON" or "OFF")) end)
CreateToggle(FruitRaidPage, "Buy Chip", false, function(s)
    if s then
        pcall(function()
            local npc = workspace:FindFirstChild("Mysterious Scientist")
            if npc then
                local cd = npc:FindFirstChildOfClass("ClickDetector")
                if cd then fireclickdetector(cd) end
            end
        end)
        Notify("Buy Chip")
    end
end)

--// FISHING
CreateToggle(FishingPage, "Auto Fishing", false, function(s) State.AutoFish = s Notify("Auto Fishing: "..(s and "ON" or "OFF")) end)

--// STATUS
local StatusLabel = CreateLabel(StatusPage, "Loading...", 110)
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
task.spawn(function()
    while task.wait(1) do
        local ls = Player:FindFirstChild("leaderstats")
        local lv = ls and ls:FindFirstChild("Level")
        if lv then
            local sea = lv.Value >= 1500 and "Sea3" or (lv.Value >= 700 and "Sea2" or "Sea1")
            StatusLabel.Text = string.format("Level: %d\nSea: %s", lv.Value, sea)
        end
    end
end)
CreateToggle(StatusPage, "Get Inventory", false, function(s) if s then Invoke("getInventory") Notify("Inventory") end end)
CreateToggle(StatusPage, "Get Inventory Weapons", false, function(s) if s then Invoke("getInventoryWeapons") Notify("Weapons") end end)
CreateToggle(StatusPage, "Get Titles", false, function(s) if s then Invoke("getTitles") Notify("Titles") end end)
CreateToggle(StatusPage, "Get Unlockables", false, function(s) if s then Invoke("GetUnlockables") Notify("Unlockables") end end)

--// PVP
CreateDropdown(PvPPage, "Select Player", (function()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then table.insert(list, plr.Name) end
    end
    if #list == 0 then list = {"No players"} end
    return list
end)(), function(opt) State.SelectedPlayer = opt Notify("Player: "..opt) end)
CreateToggle(PvPPage, "Teleport Player", false, function(s)
    if s then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Name == State.SelectedPlayer and plr.Character then
                local trp = plr.Character:FindFirstChild("HumanoidRootPart")
                if trp then TweenToPosition(trp.Position + Vector3.new(0,3,5), 150) end
            end
        end
    end
end)
CreateToggle(PvPPage, "Spectate Player", false, function(s)
    if s then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Name == State.SelectedPlayer and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hum then Camera.CameraSubject = hum Camera.CameraType = Enum.CameraType.Custom end
            end
        end
    end
end)
CreateToggle(PvPPage, "Stop Spectate", false, function(s)
    if s then
        local char = Player.Character
        if char then local hum = char:FindFirstChildOfClass("Humanoid") if hum then Camera.CameraSubject = hum end end
    end
end)
CreateToggle(PvPPage, "Aimbot", false, function(s)
    State.Aimbot = s
    if s then StartAimbot() else StopAimbot() end
    Notify("Aimbot: "..(s and "ON" or "OFF"))
end)

--// TRIALS
local TrainProgressLabel = CreateLabel(TrialsPage, "Train Progress: -", 34)
task.spawn(function()
    while task.wait(3) do
        local res = Invoke("RaceV4Progress", "Check")
        if res then TrainProgressLabel.Text = "Train Progress: "..tostring(res) end
    end
end)
CreateToggle(TrialsPage, "Great Tree Highest", false, function(s) if s then TweenToPosition(Vector3.new(2700,500,3000),500) end end)
CreateToggle(TrialsPage, "Tween RaceDoor", false, function(s) if s then TweenToPosition(Vector3.new(2830,90,3100),500) end end)
CreateToggle(TrialsPage, "Tween Ancient Clock", false, function(s) if s then TweenToPosition(Vector3.new(-5020,80,-3020),500) end end)
CreateDropdown(TrialsPage, "Select Method", {"Bone","Cake"}, function(opt) State.TrialMethod = opt Notify("Method: "..opt) end)
CreateToggle(TrialsPage, "Finish Trial", false, function(s) if s then Invoke("RaceV4Progress", "Finish") Notify("Finish Trial") end end)
CreateToggle(TrialsPage, "Auto Trial", false, function(s) State.AutoTrial = s Notify("Auto Trial: "..(s and "ON" or "OFF")) end)
CreateToggle(TrialsPage, "Auto Pull Lever", false, function(s) State.AutoPullLever = s Notify("Auto Pull Lever: "..(s and "ON" or "OFF")) end)
CreateToggle(TrialsPage, "Kill Player Trial", false, function(s) State.KillPlayerTrial = s Notify("Kill Player: "..(s and "ON" or "OFF")) end)

--// SETING (ESP)
CreateToggle(SetingPage, "ESP Player", false, function(s) State.ESPPlayer = s Notify("ESP Player: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Island", false, function(s) State.ESPIsland = s Notify("ESP Island: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Fruit", false, function(s) State.ESPFruit = s Notify("ESP Fruit: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Blue Gear", false, function(s) State.ESPBlueGear = s Notify("ESP Blue Gear: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Chest", false, function(s) State.ESPChest = s Notify("ESP Chest: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Flower", false, function(s) State.ESPFlower = s Notify("ESP Flower: "..(s and "ON" or "OFF")) end)

--// TELEPORT
local SeaIslands = {
    Sea1={"Starter Island","Jungle","Pirate Village","Desert","Frozen Village","Marine Fortress","Skylands","Prison","Colosseum","Magma Village","Underwater City","Fountain City"},
    Sea2={"Kingdom of Rose","Green Zone","Graveyard","Snow Mountain","Hot and Cold","Cursed Ship","Ice Castle","Forgotten Island"},
    Sea3={"Port Town","Hydra Island","Great Tree","Floating Turtle","Castle on the Sea","Haunted Castle"},
}
CreateDropdown(TeleportPage, "Select Sea", {"Sea1","Sea2","Sea3"}, function(opt) end)
CreateDropdown(TeleportPage, "Select Island", SeaIslands.Sea1, function(opt) State.SelectedIsland = opt Notify("Island: "..opt) end)
CreateToggle(TeleportPage, "Tween ke Island", false, function(s)
    if s then
        local pos = IslandCoords[State.SelectedIsland]
        if pos then TweenToIslandSmooth(pos + Vector3.new(0,3,0)) Notify("Tween: "..State.SelectedIsland) end
    end
end)
CreateToggle(TeleportPage, "Sea 1", false, function(s) if s then Invoke("TravelMain") Notify("Sea 1") end end)
CreateToggle(TeleportPage, "Sea 2", false, function(s) if s then Invoke("TravelDressrosa") Notify("Sea 2") end end)
CreateToggle(TeleportPage, "Sea 3", false, function(s) if s then Invoke("TravelZou") Notify("Sea 3") end end)

--// STATS
CreateToggle(StatsPage, "Auto Add Stats", false, function(s) State.AutoAddStats = s Notify("Auto Add Stats: "..(s and "ON" or "OFF")) end)
CreateSlider(StatsPage, "Melee", 0, 100, 0, function(v) State.StatsMelee = v end)
CreateSlider(StatsPage, "Sword", 0, 100, 0, function(v) State.StatsSword = v end)
CreateSlider(StatsPage, "Gun", 0, 100, 0, function(v) State.StatsGun = v end)
CreateSlider(StatsPage, "Fruit", 0, 100, 0, function(v) State.StatsBloxFruit = v end)
CreateToggle(StatsPage, "Apply Stats Now", false, function(s)
    if s then
        local stats = {{Name="Melee",Value=State.StatsMelee},{Name="Sword",Value=State.StatsSword},{Name="Gun",Value=State.StatsGun},{Name="Blox Fruit",Value=State.StatsBloxFruit}}
        for _, st in ipairs(stats) do if st.Value > 0 then Invoke("AddPoint", st.Name, st.Value) task.wait(0.3) end end
        Notify("Stats applied")
    end
end)

--// SHOP
CreateDropdown(ShopPage, "Select Melee", {"Black Leg","Electro","Fishman Karate","Sharkman Karate","Dragon Talon","Electric Claw","Death Step","Superhuman","Godhuman"}, function(opt) State.SelectedMelee = opt Notify("Melee: "..opt) end)
CreateToggle(ShopPage, "Buy Selected Melee", false, function(s)
    if s then
        local map = {["Black Leg"]="BuyBlackLeg",["Electro"]="BuyElectro",["Fishman Karate"]="BuyFishmanKarate",["Sharkman Karate"]="BuySharkmanKarate",["Dragon Talon"]="BuyDragonTalon",["Electric Claw"]="BuyElectricClaw",["Death Step"]="BuyDeathStep",["Superhuman"]="BuySuperhuman",["Godhuman"]="BuyGodhuman"}
        local fn = map[State.SelectedMelee]
        if fn then Invoke(fn) Notify("Bought: "..State.SelectedMelee) else Notify("Select melee first") end
    end
end)
CreateDropdown(ShopPage, "Select Sword", {"Katana","Cutlass","Iron Mace","Dual Katana","Triple Katana","Pipe","Small Sword","Dual-Headed Blade","Soul Cane","Saber","Rengoku","Shisui","Yama","Tushita","Cursed Dual Katana","Dark Dagger","Buddy Sword","Hallow Scythe","Spikey Trident","Trident"}, function(opt) State.SelectedSword = opt Notify("Sword: "..opt) end)
CreateToggle(ShopPage, "Buy Selected Sword", false, function(s) if s and State.SelectedSword then Invoke("BuyItem", State.SelectedSword) Notify("Bought: "..State.SelectedSword) elseif s then Notify("Select sword first") end end)
CreateDropdown(ShopPage, "Select Gun", {"Slingshot","Flintlock","Refined Flintlock","Musket","Refined Musket","Cannon","Bazooka","Sniper","Kabucha","Acidum Rifle","Bizarre Rifle","Serpent Bow"}, function(opt) State.SelectedGun = opt Notify("Gun: "..opt) end)
CreateToggle(ShopPage, "Buy Selected Gun", false, function(s) if s and State.SelectedGun then Invoke("BuyItem", State.SelectedGun) Notify("Bought: "..State.SelectedGun) elseif s then Notify("Select gun first") end end)
CreateDropdown(ShopPage, "Select Abilities", {"Ken","Buso","Geppo"}, function(opt) State.SelectedAbility = opt Notify("Ability: "..opt) end)
CreateToggle(ShopPage, "Buy Selected Ability", false, function(s)
    if s then
        if State.SelectedAbility == "Ken" then Invoke("KenTalk", "Buy")
        elseif State.SelectedAbility == "Buso" then Invoke("BuyHaki", "Buso")
        elseif State.SelectedAbility == "Geppo" then Invoke("BuyHaki", "Geppo") end
        Notify("Bought: "..tostring(State.SelectedAbility))
    end
end)
CreateToggle(ShopPage, "Buy Soru", false, function(s) if s then Invoke("BuyHaki", "Soru") Notify("Soru bought") end end)

--// MISC
CreateToggle(MiscPage, "Anti AFK", true, function(s) State.AntiAFK = s Notify("Anti AFK: "..(s and "ON" or "OFF")) end)
CreateToggle(MiscPage, "Bring Mob", false, function(s) State.BringMob = s Notify("Bring Mob: "..(s and "ON" or "OFF")) end)
CreateSlider(MiscPage, "Bring Mob Range", 0, 100, 50, function(v) State.BringMobRange = v end)
CreateToggle(MiscPage, "Infinite Jump", false, function(s) State.InfiniteJump = s Notify("Infinite Jump: "..(s and "ON" or "OFF")) end)
CreateToggle(MiscPage, "Walk On Water", false, function(s)
    State.WalkWater = s
    if s then EnableWalkWater() else DisableWalkWater() end
    Notify("Walk On Water: "..(s and "ON" or "OFF"))
end)
CreateToggle(MiscPage, "Boost FPS", false, function(s)
    State.BoostFPS = s
    if s then
        pcall(function()
            State.OriginalLighting = {GlobalShadows=Lighting.GlobalShadows,Brightness=Lighting.Brightness,Ambient=Lighting.Ambient}
            Lighting.GlobalShadows = false Lighting.Brightness = 0
            Lighting.Ambient = Color3.fromRGB(0,0,0) Lighting.FogEnd = 100 Lighting.Outlines = false
        end)
        Notify("Boost FPS: ON")
    else
        if State.OriginalLighting then
            pcall(function()
                Lighting.GlobalShadows = State.OriginalLighting.GlobalShadows
                Lighting.Brightness = State.OriginalLighting.Brightness
                Lighting.Ambient = State.OriginalLighting.Ambient
            end)
        end
        Notify("Boost FPS: OFF")
    end
end)
CreateToggle(MiscPage, "Redeem All Codes", false, function(s)
    if s then
        local codes = {"KITT_RESET","SUB2GAMERROBOT_RESET1","SUB2GAMERROBOT_EXP1","SUB2OFFICIALNOOBIE","AXIORE","BLUXXY","JCWK","KITTGAMING","MAGICBUS","STARCODEHEO","STRAWHATMAINE","TANTAIGAMING","THEGREATACE","ENYU_IS_PRO"}
        for _, code in ipairs(codes) do Invoke("Redeem", code) Notify("Redeeming: "..code) task.wait(1) end
    end
end)
CreateToggle(MiscPage, "Rejoin Server", false, function(s) if s then TeleportService:Teleport(game.PlaceId, Player) end end)
CreateToggle(MiscPage, "Join Marine", false, function(s) if s then Invoke("SetTeam", "Marines") Notify("Joined Marines") end end)
CreateToggle(MiscPage, "Join Pirate", false, function(s) if s then Invoke("SetTeam", "Pirates") Notify("Joined Pirates") end end)

--==================================================
-- LOOPS
--==================================================

-- AUTO FARM LEVEL (Config-based, Max 2800)
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoFarm then
            pcall(function()
                local ls = Player:FindFirstChild("leaderstats")
                local lv = ls and ls:FindFirstChild("Level")
                local level = lv and lv.Value or 1
                if level >= MAX_LEVEL then Notify("Max Level Reached!") State.AutoFarm = false return end
                
                local data = GetFarmData(level)
                if not data then return end

                local islandPos = IslandCoords[data.Island]
                if islandPos then
                    local hrp = GetHRP()
                    if hrp then
                        local dist = (hrp.Position - islandPos).Magnitude
                        if dist > 400 then TweenToPosition(islandPos + Vector3.new(0,3,0), 500) end
                    end
                end

                if CommF then
                    pcall(function() CommF:InvokeServer("StartQuest", data.Quest, data.QuestNum) end)
                end

                local hrp = GetHRP()
                if not hrp then return end
                local nearest, nd = nil, math.huge
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj.Name == data.NPC then
                        local hum = obj:FindFirstChildOfClass("Humanoid")
                        local trp = obj:FindFirstChild("HumanoidRootPart")
                        if hum and trp and hum.Health > 0 then
                            local d = GetDist(trp.Position, hrp.Position)
                            if d < 800 and d < nd then nearest, nd = obj, d end
                        end
                    end
                end

                if nearest then
                    local trp = nearest:FindFirstChild("HumanoidRootPart")
                    local hum = nearest:FindFirstChildOfClass("Humanoid")
                    if trp and hum and hum.Health > 0 then
                        if GetDist(hrp.Position, trp.Position) > 15 then
                            TweenToPosition(trp.Position + Vector3.new(0,3,0), CONFIG.TweenMobSpeed)
                        end
                        if not State.HitboxPart or not State.HitboxPart.Parent then
                            local hb = Instance.new("Part")
                            hb.Name = "SysxHitbox" hb.Size = Vector3.new(30,30,30)
                            hb.Transparency = 1 hb.CanCollide = false hb.CanTouch = true
                            hb.Anchored = true hb.Massless = true hb.Parent = workspace
                            State.HitboxPart = hb
                        end
                        State.HitboxPart.CFrame = CFrame.new(trp.Position)
                        local tool = EquipWeapon()
                        if tool then pcall(function() tool:Activate() end) end
                    end
                end
            end)
        else
            if State.HitboxPart then State.HitboxPart:Destroy() State.HitboxPart = nil end
        end
    end
end)

-- AUTO FARM NEAREST (Nearest NPC)
task.spawn(function()
    while task.wait(0.15) do
        if State.AutoFarmNearest then
            pcall(function()
                local hrp = GetHRP()
                if not hrp then return end
                
                local ls = Player:FindFirstChild("leaderstats")
                local lv = ls and ls:FindFirstChild("Level")
                local level = lv and lv.Value or 1
                if level >= MAX_LEVEL then Notify("Max Level Reached!") State.AutoFarmNearest = false return end
                
                -- Cari NPC terdekat
                local target = GetNearestEnemy(500)
                if target then
                    local trp = target:FindFirstChild("HumanoidRootPart")
                    local hum = target:FindFirstChildOfClass("Humanoid")
                    if trp and hum and hum.Health > 0 then
                        local dist = GetDist(hrp.Position, trp.Position)
                        if dist > 15 then
                            TweenToPosition(trp.Position + Vector3.new(0,3,0), CONFIG.TweenMobSpeed)
                        end
                        if not State.HitboxPart or not State.HitboxPart.Parent then
                            local hb = Instance.new("Part")
                            hb.Name = "SysxHitbox" hb.Size = Vector3.new(30,30,30)
                            hb.Transparency = 1 hb.CanCollide = false hb.CanTouch = true
                            hb.Anchored = true hb.Massless = true hb.Parent = workspace
                            State.HitboxPart = hb
                        end
                        State.HitboxPart.CFrame = CFrame.new(trp.Position)
                        local tool = EquipWeapon()
                        if tool then pcall(function() tool:Activate() end) end
                    end
                end
            end)
        end
    end
end)

-- AUTO KILL NEAREST
task.spawn(function()
    while task.wait(0.15) do
        if State.AutoKillNearest then
            pcall(function()
                local hrp = GetHRP()
                if not hrp then return end
                local closest, dist = nil, math.huge
                for _, mob in ipairs(ScanEnemies()) do
                    local trp = mob:FindFirstChild("HumanoidRootPart")
                    if trp then
                        local d = GetDist(trp.Position, hrp.Position)
                        if d < 100 and d < dist then closest, dist = mob, d end
                    end
                end
                if closest then
                    local trp = closest:FindFirstChild("HumanoidRootPart")
                    local tool = EquipWeapon()
                    if tool then
                        if dist > 15 then TweenToPosition(trp.Position + Vector3.new(0,3,0), CONFIG.TweenMobSpeed) end
                        pcall(function() tool:Activate() end)
                    end
                end
            end)
        end
    end
end)

-- FARM CHEST
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoChest then
            pcall(function()
                local chests = getChestsSorted()
                if #chests > 0 then TeleportNoclip(chests[1].CFrame)
                else Notify("Chest habis") task.wait(5) State.FirstRunChest = true State.UncheckedChests = {} end
            end)
        end
    end
end)

-- AUTO BOSS
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoBoss and State.SelectedBoss then
            pcall(function()
                local boss = FindBoss(State.SelectedBoss)
                if boss then
                    local trp = boss:FindFirstChild("HumanoidRootPart")
                    local hum = boss:FindFirstChildOfClass("Humanoid")
                    if trp and hum and hum.Health > 0 then
                        TweenToPosition(trp.Position + Vector3.new(0,3,0), 300)
                        local tool = EquipWeapon()
                        if tool then
                            local timeout = 0
                            while boss.Parent and hum.Health > 0 and State.AutoBoss and timeout < 100 do
                                pcall(function() tool:Activate() end)
                                task.wait(0.15)
                                timeout += 1
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- CASTLE RAID
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoCastleRaid then
            pcall(function()
                if not State.CastleRaidActive then
                    Invoke("RaidsNpc", "Select", "Castle")
                    task.wait(1)
                    State.CastleRaidActive = true
                    Notify("Castle Raid started")
                end
                local hrp = GetHRP()
                if not hrp then return end
                local nearest, nd = nil, math.huge
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj:FindFirstChildOfClass("Humanoid") then
                        local n = string.lower(obj.Name)
                        if string.find(n, "castle") or string.find(n, "raid") then
                            local trp = obj:FindFirstChild("HumanoidRootPart")
                            if trp then
                                local d = GetDist(trp.Position, hrp.Position)
                                if d < 500 and d < nd then nearest, nd = obj, d end
                            end
                        end
                    end
                end
                if nearest then
                    local trp = nearest:FindFirstChild("HumanoidRootPart")
                    local tool = EquipWeapon()
                    if tool then
                        TweenToPosition(trp.Position + Vector3.new(0,3,0), 350)
                        pcall(function() tool:Activate() end)
                    end
                end
            end)
        else
            State.CastleRaidActive = false
        end
    end
end)

-- FACTORY RAID
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoFactoryRaid then
            pcall(function()
                if not State.FactoryRaidActive then
                    Invoke("RaidsNpc", "Select", "Factory")
                    task.wait(1)
                    State.FactoryRaidActive = true
                    Notify("Factory Raid started")
                end
                local hrp = GetHRP()
                if not hrp then return end
                local nearest, nd = nil, math.huge
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj:FindFirstChildOfClass("Humanoid") then
                        local n = string.lower(obj.Name)
                        if string.find(n, "factory") or string.find(n, "soldier") then
                            local trp = obj:FindFirstChild("HumanoidRootPart")
                            if trp then
                                local d = GetDist(trp.Position, hrp.Position)
                                if d < 500 and d < nd then nearest, nd = obj, d end
                            end
                        end
                    end
                end
                if nearest then
                    local trp = nearest:FindFirstChild("HumanoidRootPart")
                    local tool = EquipWeapon()
                    if tool then
                        TweenToPosition(trp.Position + Vector3.new(0,3,0), 350)
                        pcall(function() tool:Activate() end)
                    end
                end
            end)
        else
            State.FactoryRaidActive = false
        end
    end
end)

-- AUTO ELITE HUNTER
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoEliteHunter then
            pcall(function()
                local hrp = GetHRP()
                if not hrp then return end
                local nearest, nd = nil, math.huge
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj:FindFirstChildOfClass("Humanoid") then
                        local n = string.lower(obj.Name)
                        if string.find(n, "elitehunter") or string.find(n, "deandre") or string.find(n, "diablo") or string.find(n, "urban") then
                            local trp = obj:FindFirstChild("HumanoidRootPart")
                            local hum = obj:FindFirstChildOfClass("Humanoid")
                            if trp and hum and hum.Health > 0 then
                                local d = GetDist(trp.Position, hrp.Position)
                                if d < 1000 and d < nd then nearest, nd = obj, d end
                            end
                        end
                    end
                end
                if nearest then
                    local trp = nearest:FindFirstChild("HumanoidRootPart")
                    local hum = nearest:FindFirstChildOfClass("Humanoid")
                    if trp and hum and hum.Health > 0 then
                        TweenToPosition(trp.Position + Vector3.new(0,3,0), 400)
                        local tool = EquipWeapon()
                        if tool then
                            local timeout = 0
                            while nearest.Parent and hum.Health > 0 and State.AutoEliteHunter and timeout < 100 do
                                pcall(function() tool:Activate() end)
                                task.wait(0.15)
                                timeout += 1
                            end
                        end
                        if not State.KilledElites[nearest] then
                            State.KilledElites[nearest] = true
                            State.EliteProgress += 1
                            Notify("Elite: "..State.EliteProgress.."/3")
                            if State.EliteProgress >= 3 then Notify("Elite Hunter done!") State.AutoEliteHunter = false end
                        end
                    end
                else
                    TweenToPosition(Vector3.new(2700, 60, 3000), 500)
                    task.wait(2)
                end
            end)
        end
    end
end)

-- SEA / FRUIT / STATS / ETC LOOPS
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoFarmSea and State.SelectedSeaMob then
            pcall(function()
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj.Name == State.SelectedSeaMob then
                        local hum = obj:FindFirstChildOfClass("Humanoid")
                        local trp = obj:FindFirstChild("HumanoidRootPart")
                        if hum and trp and hum.Health > 0 then
                            TweenToPosition(trp.Position + Vector3.new(0,3,0), 400)
                            local tool = EquipWeapon()
                            if tool then pcall(function() tool:Activate() end) end
                            break
                        end
                    end
                end
            end)
        end
        if State.AutoBuyBoat then
            pcall(function()
                local hasBoat = false
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:FindFirstChildOfClass("VehicleSeat") then
                        local owner = obj:FindFirstChild("Owner")
                        if owner and owner.Value == Player then hasBoat = true break end
                    end
                end
                if not hasBoat then Invoke("BuyBoat", State.SelectedBoat or "Dinghy") end
            end)
        end
        if State.AutoRemoveRock then
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "rock") then
                        local hrp = GetHRP()
                        if hrp and GetDist(obj.Position, hrp.Position) < 50 then pcall(function() obj:Destroy() end) end
                    end
                end
            end)
        end
        if State.AutoKillGolem then
            pcall(function()
                for _, obj in ipairs(workspace:GetChildren()) do
                    if string.find(string.lower(obj.Name), "golem") then
                        local hum = obj:FindFirstChildOfClass("Humanoid")
                        local trp = obj:FindFirstChild("HumanoidRootPart")
                        if hum and trp and hum.Health > 0 then
                            TweenToPosition(trp.Position + Vector3.new(0,3,0), 400)
                            local tool = EquipWeapon()
                            if tool then pcall(function() tool:Activate() end) end
                            break
                        end
                    end
                end
            end)
        end
        if State.AutoCollectBone or State.AutoCollectDinoEgg then
            pcall(function()
                local keywords = {}
                if State.AutoCollectBone then table.insert(keywords, "bone") end
                if State.AutoCollectDinoEgg then table.insert(keywords, "dino") table.insert(keywords, "egg") end
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        local n = string.lower(obj.Name)
                        for _, kw in ipairs(keywords) do
                            if string.find(n, kw) and obj:FindFirstChild("TouchInterest") then
                                local hrp = GetHRP()
                                if hrp then TweenToPosition(obj.Position + Vector3.new(0,3,0), 400) end
                                break
                            end
                        end
                    end
                end
            end)
        end
        if State.AutoHitLeviathan then
            pcall(function()
                for _, obj in ipairs(workspace:GetChildren()) do
                    if string.find(string.lower(obj.Name), "leviathan") then
                        local trp = obj:FindFirstChild("HumanoidRootPart")
                        if trp then
                            TweenToPosition(trp.Position + Vector3.new(0,3,0), 400)
                            local tool = EquipWeapon()
                            if tool then pcall(function() tool:Activate() end) end
                            break
                        end
                    end
                end
            end)
        end
        if State.AutoShootHeart then
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "heart") then
                        if obj:FindFirstChild("TouchInterest") then
                            local hrp = GetHRP()
                            if hrp then TweenToPosition(obj.Position + Vector3.new(0,3,0), 400) end
                        end
                    end
                end
            end)
        end
        if State.FindMirage then
            pcall(function()
                for _, obj in ipairs(workspace:GetChildren()) do
                    if string.find(string.lower(obj.Name), "mirage") then Notify("Mirage found!") State.FindMirage = false break end
                end
            end)
        end
        if State.FindKitsune then
            pcall(function()
                for _, obj in ipairs(workspace:GetChildren()) do
                    if string.find(string.lower(obj.Name), "kitsune") then
                        local lvl = obj:GetAttribute("Level") or 0
                        if lvl >= State.KitsuneLevel then Notify("Kitsune found! Lv "..lvl) State.FindKitsune = false break end
                    end
                end
            end)
        end
        if State.FindPrehistoric then
            pcall(function()
                for _, obj in ipairs(workspace:GetChildren()) do
                    if string.find(string.lower(obj.Name), "prehistoric") or string.find(string.lower(obj.Name), "dino") then Notify("Prehistoric found!") State.FindPrehistoric = false break end
                end
            end)
        end
        if State.FindFrozenDim then
            pcall(function()
                for _, obj in ipairs(workspace:GetChildren()) do
                    if string.find(string.lower(obj.Name), "frozen") or string.find(string.lower(obj.Name), "dimension") then Notify("Frozen Dim found!") State.FindFrozenDim = false break end
                end
            end)
        end
        if State.SeaEventActive then
            pcall(function()
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj.Name == State.SeaEventMob then
                        local hum = obj:FindFirstChildOfClass("Humanoid")
                        local trp = obj:FindFirstChild("HumanoidRootPart")
                        if hum and trp and hum.Health > 0 then
                            TweenToPosition(trp.Position + Vector3.new(0,3,0), 400)
                            local tool = EquipWeapon()
                            if tool then pcall(function() tool:Activate() end) end
                            break
                        end
                    end
                end
            end)
        end
    end
end)

-- FRUIT TWEEN
task.spawn(function()
    while task.wait(0.3) do
        if State.FruitTweenEnabled then
            local hrp = GetHRP()
            if hrp then
                local closest, cd = nil, math.huge
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "fruit") then
                        if obj.Parent == workspace or (obj.Parent and obj.Parent.Name == "Map") then
                            local d = GetDist(obj.Position, hrp.Position)
                            if d < 500 and d < cd then closest, cd = obj, d end
                        end
                    end
                end
                if closest then
                    Notify("Fruit Spawn: "..closest.Name)
                    local dist = GetDist(closest.Position, hrp.Position)
                    local dur = math.max(dist / CONFIG.FruitTweenSpeed, 0.1)
                    local tw = TweenService:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), { CFrame = closest.CFrame + Vector3.new(0,3,0) })
                    tw:Play()
                    tw.Completed:Wait()
                    if State.FruitStoreEnabled then
                        local held = GetHeldFruit()
                        if held then Invoke("StoreFruit", held.Name, held) end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(60) do
        if State.AutoGacha then pcall(function() if not GetHeldFruit() then Invoke("BuyFruit", "Random") end end) end
    end
end)

task.spawn(function()
    while task.wait(10) do
        if State.AutoRaid and State.SelectedRaid then
            pcall(function()
                Invoke("RaidsNpc", "Select", State.SelectedRaid)
                task.wait(0.5)
                pcall(function() fireclickdetector(workspace.Map.CircleIsland.RaidSummon.Button.Main.ClickDetector) end)
                Notify("Raid: "..State.SelectedRaid)
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if State.AutoAddStats then
            pcall(function()
                local stats = {{Name="Melee",Value=State.StatsMelee},{Name="Sword",Value=State.StatsSword},{Name="Gun",Value=State.StatsGun},{Name="Blox Fruit",Value=State.StatsBloxFruit}}
                for _, st in ipairs(stats) do if st.Value > 0 then Invoke("AddPoint", st.Name, st.Value) task.wait(0.3) end end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if State.InfiniteJump then
            local char = Player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum:GetState() == Enum.HumanoidStateType.Freefall then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if State.BringMob or State.AutoFarm or State.AutoFarmNearest then
            local now = os.clock()
            if now - State.LastBring >= 0.3 then
                local hrp = GetHRP()
                if hrp then
                    local targetPos = hrp.Position + hrp.CFrame.LookVector * 6
                    for _, model in ipairs(workspace:GetChildren()) do
                        if IsNPC(model) then
                            local mRoot = model:FindFirstChild("HumanoidRootPart")
                            if mRoot and GetDist(mRoot.Position, hrp.Position) <= (State.BringMobRange or 50) then
                                pcall(function() mRoot.CFrame = CFrame.new(targetPos) end)
                            end
                        end
                    end
                end
                State.LastBring = now
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if EliteLabel then EliteLabel.Text = "Elite Progress: "..(State.EliteProgress or 0).."/3" end
    end
end)

-- ESP LOOP
task.spawn(function()
    while task.wait(0.3) do
        local hrp = GetHRP()
        local myPos = hrp and hrp.Position or Vector3.new(0,0,0)
        if State.ESPPlayer then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= Player and plr.Character then
                    local trp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if trp then
                        local dist = math.floor((trp.Position - myPos).Magnitude)
                        local text = dist.." | "..plr.Name
                        CreateESP(trp, text, Color3.fromRGB(255,80,80))
                        if State.ESPObjects[trp] then
                            local lbl = State.ESPObjects[trp]:FindFirstChild("ESPLabel")
                            if lbl then lbl.Text = text end
                        end
                    end
                end
            end
        end
        if State.ESPFruit then
            for _, obj in ipairs(FindFruits()) do
                local dist = math.floor((obj.Position - myPos).Magnitude)
                local text = dist.." | "..obj.Name
                CreateESP(obj, text, Color3.fromRGB(255,200,80))
                if State.ESPObjects[obj] then
                    local lbl = State.ESPObjects[obj]:FindFirstChild("ESPLabel")
                    if lbl then lbl.Text = text end
                end
            end
        end
        if State.ESPChest then
            for _, obj in ipairs(getChestsSorted()) do
                local dist = math.floor((obj.Position - myPos).Magnitude)
                local text = dist.." | Chest"
                CreateESP(obj, text, Color3.fromRGB(255,215,0))
                if State.ESPObjects[obj] then
                    local lbl = State.ESPObjects[obj]:FindFirstChild("ESPLabel")
                    if lbl then lbl.Text = text end
                end
            end
        end
        if State.ESPIsland then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = string.lower(obj.Name)
                    if string.find(n,"island") or string.find(n,"portal") or string.find(n,"teleport") then
                        local dist = math.floor((obj.Position - myPos).Magnitude)
                        local text = dist.." | "..obj.Name
                        CreateESP(obj, text, Color3.fromRGB(80,200,255))
                        if State.ESPObjects[obj] then
                            local lbl = State.ESPObjects[obj]:FindFirstChild("ESPLabel")
                            if lbl then lbl.Text = text end
                        end
                    end
                end
            end
        end
        if State.ESPBlueGear then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = string.lower(obj.Name)
                    if string.find(n,"bluegear") or string.find(n,"blue_gear") or string.find(n,"gear") then
                        local dist = math.floor((obj.Position - myPos).Magnitude)
                        local text = dist.." | Blue Gear"
                        CreateESP(obj, text, Color3.fromRGB(0,150,255))
                        if State.ESPObjects[obj] then
                            local lbl = State.ESPObjects[obj]:FindFirstChild("ESPLabel")
                            if lbl then lbl.Text = text end
                        end
                    end
                end
            end
        end
        if State.ESPFlower then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = string.lower(obj.Name)
                    if string.find(n,"flower") or string.find(n,"blossom") or string.find(n,"petal") then
                        local dist = math.floor((obj.Position - myPos).Magnitude)
                        local text = dist.." | "..obj.Name
                        CreateESP(obj, text, Color3.fromRGB(255,100,200))
                        if State.ESPObjects[obj] then
                            local lbl = State.ESPObjects[obj]:FindFirstChild("ESPLabel")
                            if lbl then lbl.Text = text end
                        end
                    end
                end
            end
        end
        if not State.ESPPlayer and not State.ESPIsland and not State.ESPFruit
        and not State.ESPBlueGear and not State.ESPChest and not State.ESPFlower then
            ClearAllESP()
        end
    end
end)

--// TABS
local TabDefs = {
    {"Discord"}, {"Farm"}, {"Sea"}, {"Quest / Items"}, {"Fruit / Raid"},
    {"Fishing"}, {"Status"}, {"PvP"}, {"Trials"}, {"Seting"},
    {"Teleport"}, {"Stats"}, {"Shop"}, {"Misc"},
}
for i, d in ipairs(TabDefs) do
    local btn = CreateTab(d[1], i)
    btn.Activated:Connect(function() ShowTab(d[1]) end)
end

--// OPEN/CLOSE
local function OpenGUI()
    Main.Visible = true
    Main.Size = UDim2.fromOffset(750, 570)
    Main.Position = UDim2.new(0.5, -375, 0.5, -285)
    TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(780, 600),
        Position = UDim2.new(0.5, -390, 0.5, -300),
    }):Play()
end
local function CloseGUI()
    local tw = TweenService:Create(Main, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Size = UDim2.fromOffset(750, 570),
        Position = UDim2.new(0.5, -375, 0.5, -285),
    })
    tw:Play()
    tw.Completed:Once(function() Main.Visible = false end)
end

local IsDragging, DragStart, StartPosition, HasMoved = false, nil, nil, false
OpenButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsDragging = true HasMoved = false
        DragStart = input.Position
        StartPosition = OpenButton.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if not IsDragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - DragStart
        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then HasMoved = true end
        OpenButton.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsDragging = false
    end
end)

OpenButton.Activated:Connect(function()
    if HasMoved then HasMoved = false return end
    if Main.Visible then CloseGUI() else OpenGUI() end
end)
CloseButton.Activated:Connect(function() CloseGUI() end)

-- DRAG MAIN
local MDragging, MDragStart, MStartPos = false, nil, nil
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        MDragging = true MDragStart = input.Position MStartPos = Main.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then MDragging = false end end)
    end
end)
UIS.InputChanged:Connect(function(input)
    if not MDragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - MDragStart
    Main.Position = UDim2.new(MStartPos.X.Scale, MStartPos.X.Offset + delta.X, MStartPos.Y.Scale, MStartPos.Y.Offset + delta.Y)
end)

OpenButton.MouseEnter:Connect(function()
    TweenService:Create(OpenButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(68,68)}):Play()
end)
OpenButton.MouseLeave:Connect(function()
    TweenService:Create(OpenButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(62,62)}):Play()
end)

Player.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

ShowTab("Farm")
print("================================")
print("        SYSX HUB v1.0 FREEMIUM")
print("        "..CONFIG.Build)
print("================================")

Notify("SysxHub v1.0 loaded")
return true
