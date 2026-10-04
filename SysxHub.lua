--[[
================================================================
 SYSX HUB | Freemium Version | v0.1
 Created by Ramanotsugarr
 Logo + Banner + 14 Tabs + Race V4 Trial Complete Chain
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
    Build = "SysxHub | Freemium Version | v0.1",
    Discord = "https://discord.gg/E5kQJW3hn",
    TweenMobSpeed = 400,
    IslandTweenSpeed = 300,
    FruitTweenSpeed = 200,
}

local State = {
    AutoFarm=false, AutoFarmNearest=false, AutoChest=false, AutoBoss=false,
    AutoKillNearest=false, AutoFish=false, AutoAddStats=false,
    HakiActivated=false, Hitbox=false, HitboxPart=nil,
    SelectedWeapon=nil, SelectedCategory=nil,
    SelectedBoss=nil, FirstRunChest=true, UncheckedChests={},
    MirageTweenEnabled=false,
    FindKitsune=false, FindPrehistoric=false, FindFrozenDim=false,
    FindMirage=false, AutoDriveTiki=false,
    KitsuneLevel=0, BoatSpeed=500, BoatHeight=5,
    AutoFarmSea=false, AutoBuyBoat=false,
    AutoKillGolem=false, AutoCollectBone=false, AutoCollectDinoEgg=false,
    SelectedSeaMob="Sea Beast", SelectedBoat="Dinghy",
    AutoRaceV2=false, AutoRaceV3=false,
    Aimbot=false, SelectedPlayer=nil,
    -- TRIAL V4
    AutoTrialV4=false, AutoTrialOnly=false, AutoTrainV4=false,
    AutoPullLever=false, AutoFragment=false,
    TrainCount=0, TrainTarget=0, TrainStage=1,
    -- 
    BringMob=false, BringMobRange=50,
    InfiniteJump=false, BoostFPS=false,
    WalkWater=false, AntiAFK=true, Notifications=true,
    StatsMelee=0, StatsSword=0, StatsGun=0, StatsBloxFruit=0,
    ESPPlayer=false, ESPIsland=false, ESPFruit=false, ESPBlueGear=false,
    ESPChest=false, ESPFlower=false, ESPObjects={},
    OriginalLighting=nil, SelectedRaid=nil, SelectedIsland="Starter Island",
    SelectedMelee=nil, SelectedSword=nil, SelectedGun=nil, SelectedAbility=nil,
    FruitTweenEnabled=false, FruitStoreEnabled=true,
    AutoGacha=false, AutoRaid=false, EliteProgress=0,
    LastBring=0,
}

local CommF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
local function Invoke(...)
    if not CommF then return nil end
    local ok, res = pcall(function(...) return CommF:InvokeServer(...) end, ...)
    if not ok then return nil end
    return res
end

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

local old = PlayerGui:FindFirstChild("SysxHub")
if old then old:Destroy() end

local PASSIVE = {"dealer","shop","vendor","merchant","quest","giver","bartender","chef","captain","scientist","teacher","guide","trainer","banker","blacksmith","smith","farmer","villager","elder"}
local function IsNPC(m)
    if not m or m == Player.Character then return false end
    local hum = m:FindFirstChildOfClass("Humanoid")
    if not hum or not m:FindFirstChild("HumanoidRootPart") then return false end
    if Players:GetPlayerFromCharacter(m) then return false end
    if hum.Health <= 0 or hum.MaxHealth <= 0 or hum.WalkSpeed <= 0 then return false end
    local n = string.lower(m.Name)
    for _, kw in ipairs(PASSIVE) do if string.find(n, kw) then return false end end
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
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Tool") or obj:IsA("Model") then
            if string.find(obj.Name, "Fruit") then
                local part = obj:IsA("Tool") and obj:FindFirstChildWhichIsA("BasePart") 
                    or (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true))
                if part then table.insert(list, {model=obj, part=part}) end
            end
        end
    end
    return list
end
local function GetHeldFruit()
    local char = Player.Character
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.Name:find("Fruit") then return tool end
        end
    end
    return nil
end

local MaxSpeed = 300
local function getCharacter()
    if not Player.Character then Player.CharacterAdded:Wait() end
    Player.Character:WaitForChild("HumanoidRootPart")
    return Player.Character
end
local function toggleNoclip(toggle)
    local char = getCharacter()
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("BasePart") then v.CanCollide = not toggle end
    end
end
local function DistanceFromPlrSort(list)
    local root = getCharacter().HumanoidRootPart
    table.sort(list, function(a, b) return (root.Position - a.Position).Magnitude < (root.Position - b.Position).Magnitude end)
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

local function EquipWeapon()
    local char = Player.Character
    if not char then return nil end
    if State.SelectedWeapon then
        local held = char:FindFirstChild(State.SelectedWeapon)
        if held and held:IsA("Tool") then return held end
        for _, c in ipairs(Player.Backpack:GetChildren()) do
            if c:IsA("Tool") and c.Name == State.SelectedWeapon then
                c.Parent = char task.wait(0.05) return c
            end
        end
    end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then return tool end
    for _, c in ipairs(Player.Backpack:GetChildren()) do
        if c:IsA("Tool") then c.Parent = char task.wait(0.05) return c end
    end
    return nil
end

local function AutoAttackNPC(target, duration)
    if not target or not target.Parent then return false end
    local hum = target:FindFirstChildOfClass("Humanoid")
    local trp = target:FindFirstChild("HumanoidRootPart")
    if not hum or not trp or hum.Health <= 0 then return false end
    duration = duration or 5
    local startTime = tick()
    while tick() - startTime < duration do
        if not target.Parent or hum.Health <= 0 then break end
        local hrp = GetHRP()
        if not hrp then break end
        local dist = GetDist(hrp.Position, trp.Position)
        if dist > 10 then
            hrp.CFrame = CFrame.new(trp.Position + Vector3.new(0, 0, -3), trp.Position)
            task.wait(0.05)
        end
        if State.HitboxPart and State.HitboxPart.Parent then
            State.HitboxPart.CFrame = CFrame.new(trp.Position)
        end
        local tool = EquipWeapon()
        if tool then pcall(function() tool:Activate() end) end
        task.wait(0.08)
    end
    return true
end

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
        if hrp and hrp.Parent then
            hrp.CFrame = startCF:Lerp(targetCF, alpha)
        end
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
    local duration = math.max(dist / CONFIG.IslandTweenSpeed, 0.2)
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
    if hrp and hrp.Parent then
        hrp.CFrame = targetCF
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    if hum then hum.AutoRotate = oldAuto end
    return true
end

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

local WalkWaterConnection = nil
local function getWaterHeight(root)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { Player.Character }
    params.IgnoreWater = false
    local result = workspace:Raycast(root.Position + Vector3.new(0, 20, 0), Vector3.new(0, -80, 0), params)
    if result and result.Instance then
        local mat = result.Material
        local name = string.lower(result.Instance.Name)
        if mat == Enum.Material.Water or string.find(name, "water") or string.find(name, "ocean") or string.find(name, "sea") then
            return result.Position.Y
        end
    end
    if root.Position.Y < 5 then return 0 end
    return nil
end
local function EnableWalkWater()
    if WalkWaterConnection then WalkWaterConnection:Disconnect() end
    WalkWaterConnection = RunService.RenderStepped:Connect(function()
        if not State.WalkWater then return end
        local hrp = GetHRP()
        if not hrp then return end
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local wy = getWaterHeight(hrp)
        if wy then
            local targetY = wy + 3.5
            local currentY = hrp.Position.Y
            if currentY < targetY + 5 and currentY > wy - 10 then
                hrp.CFrame = CFrame.new(hrp.Position.X, targetY, hrp.Position.Z) * CFrame.Angles(0, math.rad(hrp.Orientation.Y), 0)
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
                if hum:GetState() == Enum.HumanoidStateType.Swimming then
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end
            end
        end
    end)
end
local function DisableWalkWater()
    if WalkWaterConnection then WalkWaterConnection:Disconnect() WalkWaterConnection = nil end
end

local function ActivateHakiOnce()
    if State.HakiActivated then return end
    local char = Player.Character
    if char and char:FindFirstChild("HasBuso") then
        State.HakiActivated = true
        return
    end
    if CommF then
        pcall(function() CommF:InvokeServer("Buso") end)
        task.wait(0.3)
    end
    State.HakiActivated = true
end

-- FASTATTACK + CLICKATTACK
task.spawn(function()
    for _, v in pairs(getreg()) do
        if typeof(v) == "function" then
            local ok, env = pcall(function() return getfenv(v).script end)
            if ok and env == Player.PlayerScripts:FindFirstChild("CombatFramework") then
                local ok2, upvals = pcall(function() return debug.getupvalues(v) end)
                if ok2 then
                    for _, upval in pairs(upvals) do
                        if typeof(upval) == "table" then
                            task.spawn(function()
                                RunService.RenderStepped:Connect(function()
                                    if State.AutoFarm or State.AutoFarmNearest or State.AutoKillNearest 
                                    or State.AutoTrialV4 or State.AutoTrainV4 then
                                        pcall(function()
                                            upval.activeController.timeToNextAttack = -(math.huge^math.huge^math.huge)
                                            upval.activeController.attacking = false
                                            upval.activeController.increment = 4
                                            upval.activeController.blocking = false
                                            upval.activeController.hitboxMagnitude = 150
                                            upval.activeController.humanoid.AutoRotate = true
                                            upval.activeController.focusStart = 0
                                            upval.activeController.currentAttackTrack = 0
                                        end)
                                    end
                                end)
                            end)
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    RunService.RenderStepped:Connect(function()
        if State.AutoFarm or State.AutoFarmNearest or State.AutoKillNearest
        or State.AutoTrialV4 or State.AutoTrainV4 then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(0,1,0,1))
            end)
        end
    end)
end)

-- FARM CONFIG
local FarmConfig = {
    {1,9,"Starter Island","BanditQuest1",1,"Bandit"},
    {10,14,"Jungle","JungleQuest",1,"Monkey"},
    {15,29,"Jungle","JungleQuest",2,"Gorilla"},
    {30,59,"Pirate Village","BuggyQuest1",1,"Pirate"},
    {60,74,"Pirate Village","BuggyQuest1",2,"Brute"},
    {75,89,"Desert","DesertQuest",1,"Desert Bandit"},
    {90,99,"Frozen Village","SnowQuest",1,"Snow Bandit"},
    {100,104,"Frozen Village","SnowQuest",2,"Snowman"},
    {105,119,"Frozen Village","SnowQuest",3,"Yeti"},
    {120,129,"Marine Fortress","MarineQuest2",1,"Chief Petty Officer"},
    {130,149,"Marine Fortress","MarineQuest2",2,"Vice Admiral"},
    {150,174,"Skylands","SkyQuest",1,"Sky Bandit"},
    {175,189,"Skylands","SkyQuest",2,"Dark Master"},
    {190,209,"Prison","PrisonQuest",1,"Prisoner"},
    {210,224,"Prison","PrisonQuest",2,"Dangerous Prisoner"},
    {225,249,"Prison","PrisonQuest",3,"Head Jailer"},
    {250,299,"Colosseum","ColosseumQuest",1,"Gladiator"},
    {300,374,"Magma Village","MagmaQuest",1,"Military Soldier"},
    {375,399,"Magma Village","MagmaQuest",2,"Military Spy"},
    {400,449,"Underwater City","FishmanQuest",1,"Fishman Warrior"},
    {450,499,"Fountain City","FountainQuest",1,"Galley Pirate"},
    {500,599,"Kingdom of Rose","Area1Quest",1,"Raider"},
    {600,699,"Green Zone","Area2Quest",1,"Marine Lieutenant"},
    {700,774,"Graveyard","GraveyardQuest",1,"Zombie"},
    {775,874,"Snow Mountain","SnowMountainQuest",1,"Snow Trooper"},
    {875,999,"Hot and Cold","PunkHazardQuest",1,"Lab Subordinate"},
    {1000,1124,"Cursed Ship","CursedShipQuest",1,"Ship Deckhand"},
    {1125,1249,"Ice Castle","IceCastleQuest",1,"Arctic Warrior"},
    {1250,1374,"Forgotten Island","ForgottenQuest",1,"Sea Soldier"},
    {1500,1574,"Port Town","PortQuest",1,"Pirate Millionaire"},
    {1575,1649,"Hydra Island","HydraQuest",1,"Dragon Crew Warrior"},
    {1650,1699,"Great Tree","GreatTreeQuest",1,"Marine Commodore"},
    {1700,1899,"Floating Turtle","ForestQuest",1,"Forest Pirate"},
    {1900,1999,"Haunted Castle","HauntedQuest",1,"Reborn Skeleton"},
    {2000,2099,"Sea of Treats","CakeQuest",1,"Candy Rebel"},
    {2100,2199,"Chocolate Land","CakeQuest",5,"Chocolate Bar Battler"},
    {2200,2299,"Cake Land","CakeQuest",9,"Candy Pirate"},
    {2300,2399,"Tiki Outpost","TikiQuest",1,"Isle Champion"},
    {2400,2499,"Tiki Outpost","TikiQuest",3,"Island Boy"},
    {2500,2599,"Tiki Outpost","TikiQuest",5,"Tiki Chief"},
    {2600,2699,"Tiki Outpost","TikiQuest",7,"Tiki Chief"},
    {2700,2749,"Final Island","SubmergedQuest",1,"Final Warrior"},
    {2750,2800,"Final Island","SubmergedQuest",3,"Final Boss"},
}

local IslandCoords = {
    ["Starter Island"]=Vector3.new(1077,15,1450),["Jungle"]=Vector3.new(-1620,30,200),
    ["Pirate Village"]=Vector3.new(-1100,15,3800),["Desert"]=Vector3.new(980,15,4200),
    ["Frozen Village"]=Vector3.new(-70,20,-2500),["Marine Fortress"]=Vector3.new(-5100,20,4050),
    ["Skylands"]=Vector3.new(-4650,850,-3220),["Prison"]=Vector3.new(4850,15,650),
    ["Colosseum"]=Vector3.new(-1800,50,-3000),["Magma Village"]=Vector3.new(-5200,20,-300),
    ["Underwater City"]=Vector3.new(6000,-150,3000),["Fountain City"]=Vector3.new(5600,60,-5000),
    ["Kingdom of Rose"]=Vector3.new(-800,20,1800),["Green Zone"]=Vector3.new(-2500,30,100),
    ["Graveyard"]=Vector3.new(6500,60,4500),["Snow Mountain"]=Vector3.new(400,30,-5300),
    ["Hot and Cold"]=Vector3.new(-5500,30,-4000),["Cursed Ship"]=Vector3.new(923,100,32000),
    ["Ice Castle"]=Vector3.new(5000,60,-6500),["Forgotten Island"]=Vector3.new(-3050,100,-7500),
    ["Port Town"]=Vector3.new(-290,20,6000),["Hydra Island"]=Vector3.new(5800,30,-2000),
    ["Great Tree"]=Vector3.new(2700,60,3000),["Floating Turtle"]=Vector3.new(-1600,60,3500),
    ["Haunted Castle"]=Vector3.new(-9500,100,5800),["Sea of Treats"]=Vector3.new(-700,100,-11000),
    ["Chocolate Land"]=Vector3.new(-700,100,-11000),["Cake Land"]=Vector3.new(-700,100,-11000),
    ["Tiki Outpost"]=Vector3.new(-1000,60,6000),["Final Island"]=Vector3.new(0,100,0),
}

local BossDataBySea = {
    Sea1 = {"Gorilla King","Bobby","Yeti","Mob Leader","Vice Admiral","Saber Expert","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg"},
    Sea2 = {"Diamond","Jeremy","Fajita","Don Swan","Darkbeard","Smoke Admiral","Cursed Captain","Awakened Ice Admiral","Tide Keeper"},
    Sea3 = {"Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate","Longma","Cake Queen"},
}

local SeaIslands = {
    Sea1={"Starter Island","Jungle","Pirate Village","Desert","Frozen Village","Marine Fortress","Skylands","Prison","Colosseum","Magma Village","Underwater City","Fountain City"},
    Sea2={"Kingdom of Rose","Green Zone","Graveyard","Snow Mountain","Hot and Cold","Cursed Ship","Ice Castle","Forgotten Island"},
    Sea3={"Port Town","Hydra Island","Great Tree","Floating Turtle","Castle on the Sea","Haunted Castle"},
}

local BoatDataBySea = {
    Sea1 = {"Dinghy","Sloop","Boat","Fishing Boat"},
    Sea2 = {"Guardian","Speed Boat","Miracle"},
    Sea3 = {"Sentinel","Beast Hunter","Shark Boat","Bizarre Boat"},
}

local RaidDataBySea = {
    Sea1 = {"Flame","Ice","Sand","Dark","Light"},
    Sea2 = {"Magma","Quake","Buddha","Love","Spider","Sound","Phoenix","Portal","Rumble","Pain","Blizzard","Gravity"},
    Sea3 = {"Venom","Control","Spirit","Dragon","Leopard","Kitsune","Dough","Mammoth","T-Rex"},
}

local function GetLevel()
    local ls = Player:FindFirstChild("leaderstats")
    local lv = ls and ls:FindFirstChild("Level")
    return lv and lv.Value or 1
end
local function GetCurrentSea()
    local level = GetLevel()
    if level >= 1500 then return "Sea3"
    elseif level >= 700 then return "Sea2"
    else return "Sea1" end
end
local function GetFarmData(level)
    for _, data in ipairs(FarmConfig) do
        if level >= data[1] and level <= data[2] then
            return {Min=data[1], Max=data[2], Island=data[3], Quest=data[4], QuestNum=data[5], NPC=data[6]}
        end
    end
    return nil
end
local function GetNearestEnemy(radius)
    local hrp = GetHRP()
    if not hrp then return nil end
    radius = radius or 500
    local nearest, nd = nil, radius
    for _, obj in ipairs(workspace:GetChildren()) do
        if IsNPC(obj) then
            local trp = obj:FindFirstChild("HumanoidRootPart")
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if trp and hum and hum.Health > 0 then
                local d = GetDist(trp.Position, hrp.Position)
                if d < nd then nearest = obj nd = d end
            end
        end
    end
    return nearest
end
local function GetBoat()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildWhichIsA("VehicleSeat", true) then
            local owner = obj:FindFirstChild("Owner") or obj:GetAttribute("Owner")
            if owner then
                if (owner.Value == Player) or (owner == Player.UserId) or (owner == Player.Name) then
                    return obj
                end
            end
        end
    end
    return nil
end

-- FRAGMENTS GETTER
local function GetFragments()
    local ls = Player:FindFirstChild("leaderstats")
    if ls then
        local f = ls:FindFirstChild("Fragments") or ls:FindFirstChild("Fragment")
        if f then return f.Value or 0 end
    end
    local data = Player:FindFirstChild("Data")
    if data then
        local f = data:FindFirstChild("Fragments") or data:FindFirstChild("Fragment")
        if f then return f.Value or 0 end
    end
    local attr = Player:GetAttribute("Fragments")
    if attr then return attr end
    return 0
end

--// GUI
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

local function Log(text) print("[SysxHub] "..tostring(text)) end

--// QUEST CHAIN
local QuestChain = { Running = false, ActiveType = nil }
local function StopChain() QuestChain.Running = false QuestChain.ActiveType = nil end
local function StartChain(t)
    if QuestChain.Running then Log("Chain busy") return false end
    QuestChain.Running = true QuestChain.ActiveType = t
    return true
end

local function RunAutoSaber()
    Log("Auto Saber: Starting...")
    while QuestChain.Running and QuestChain.ActiveType == "Saber" do
        local prog = Invoke("ProQuestProgress")
        if type(prog) ~= "table" then task.wait(1)
        else
            if not prog.UsedTorch then
                Invoke("ProQuestProgress", "GetTorch") task.wait(2)
                Invoke("ProQuestProgress", "DestroyTorch") task.wait(1)
            elseif not prog.UsedCup then
                Invoke("ProQuestProgress", "GetCup") task.wait(1)
                local char = Player.Character
                local cup = char and (char:FindFirstChild("Cup") or Player.Backpack:FindFirstChild("Cup"))
                if cup then
                    if cup.Parent ~= char then cup.Parent = char end
                    task.wait(0.5)
                    Invoke("ProQuestProgress", "FillCup", cup)
                end
                task.wait(1)
            elseif not prog.KilledMob then
                Invoke("ProQuestProgress", "SickMan") task.wait(1)
                Invoke("ProQuestProgress", "RichSon") task.wait(1)
            else
                Notify("⚔️ Saber Complete!") StopChain() break
            end
        end
        task.wait(0.5)
    end
end

local function RunAutoCDK()
    Log("Auto CDK: Starting...")
    while QuestChain.Running and QuestChain.ActiveType == "CDK" do
        if GetLevel() < 2200 then Log("CDK need Lv 2200+") StopChain() break end
        Invoke("ProQuestProgress", "CDK") task.wait(0.5)
        Invoke("CDKQuest", "OpenDoor") task.wait(0.5)
        Invoke("CDKQuest", "Progress") task.wait(0.5)
        Invoke("CDKQuest", "BoatQuest") task.wait(3)
    end
end

local function RunAutoTushita()
    Log("Auto Tushita: Starting...")
    while QuestChain.Running and QuestChain.ActiveType == "Tushita" do
        Invoke("ProQuestProgress", "Tushita") task.wait(3)
    end
end

local function RunAutoSoulGuitar()
    Log("Auto Soul Guitar: Starting...")
    while QuestChain.Running and QuestChain.ActiveType == "SoulGuitar" do
        Invoke("ProQuestProgress", "SoulGuitar") task.wait(3)
    end
end

local function RunAutoYama()
    Log("Auto Yama: Starting...")
    while QuestChain.Running and QuestChain.ActiveType == "Yama" do
        Invoke("StartQuest", "EliteHunter", 1)
        local killed = 0
        while killed < 30 and QuestChain.Running do
            local hrp = GetHRP()
            if hrp then
                local nearest, nd = nil, math.huge
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj:FindFirstChildOfClass("Humanoid") then
                        local n = string.lower(obj.Name)
                        if string.find(n, "elitehunter") or string.find(n, "deandre") or string.find(n, "diablo") or string.find(n, "urban") then
                            local trp = obj:FindFirstChild("HumanoidRootPart")
                            local hum = obj:FindFirstChildOfClass("Humanoid")
                            if trp and hum and hum.Health > 0 then
                                local d = GetDist(trp.Position, hrp.Position)
                                if d < 2000 and d < nd then nearest, nd = obj, d end
                            end
                        end
                    end
                end
                if nearest then
                    local trp = nearest:FindFirstChild("HumanoidRootPart")
                    if trp then
                        TweenToPosition(trp.Position + Vector3.new(0,3,0), 400)
                        AutoAttackNPC(nearest, 8)
                        killed += 1
                        State.EliteProgress = killed
                    end
                else
                    TweenToPosition(Vector3.new(2700, 60, 3000), 500)
                    task.wait(2)
                end
            end
            task.wait(0.3)
        end
        if killed >= 30 then Notify("⚔️ Yama Complete!") StopChain() break end
    end
end

local function RunAutoDarkDagger()
    Log("Auto Dark Dagger: Starting...")
    while QuestChain.Running and QuestChain.ActiveType == "DarkDagger" do
        local hasChalice = Player.Backpack:FindFirstChild("God's Chalice") or (Player.Character and Player.Character:FindFirstChild("God's Chalice"))
        if not hasChalice then Log("Need God's Chalice!") StopChain() break end
        Invoke("PlaceChalice") task.wait(2)
        for _, obj in ipairs(workspace:GetChildren()) do
            if string.find(string.lower(obj.Name), "indra") then AutoAttackNPC(obj, 30) end
        end
        Notify("🗡️ Dark Dagger Complete") StopChain() break
    end
end

local function RunAutoBuddySword()
    Log("Auto Buddy Sword: Starting...")
    while QuestChain.Running and QuestChain.ActiveType == "BuddySword" do
        local boss = FindBoss("Cake Queen")
        if boss then
            AutoAttackNPC(boss, 30)
            Notify("⚔️ Cake Queen defeated")
        else
            task.wait(5)
        end
        task.wait(2)
    end
end

local function RunAutoDoughKing()
    Log("Auto Dough King: Starting...")
    while QuestChain.Running and QuestChain.ActiveType == "DoughKing" do
        local hasSweet = Player.Backpack:FindFirstChild("Sweet Chalice") or (Player.Character and Player.Character:FindFirstChild("Sweet Chalice"))
        if not hasSweet then Log("Need Sweet Chalice!") StopChain() break end
        Invoke("DoughKing") task.wait(2)
        for _, obj in ipairs(workspace:GetChildren()) do
            local n = string.lower(obj.Name)
            if string.find(n, "dough") and string.find(n, "king") then AutoAttackNPC(obj, 30) end
        end
        Notify("👑 Dough King Complete!") StopChain() break
    end
end

--// RACE V4 TRIAL HELPER
local TrialV4Locations = {
    Trial1 = Vector3.new(-12440, 550, -7100),  -- Ancient Clock area
    Train1 = Vector3.new(-12440, 550, -7100),
    Trial2 = Vector3.new(-12440, 550, -7100),
    Train2 = Vector3.new(-12440, 550, -7100),
    Trial3 = Vector3.new(-12440, 550, -7100),
    Train3 = Vector3.new(-12440, 550, -7100),
    Trial4 = Vector3.new(-12440, 550, -7100),
    Train4 = Vector3.new(-12440, 550, -7100),
}

local function KillTrialMobs(count, timeout)
    timeout = timeout or 60
    local killed = 0
    local startTime = tick()
    while killed < count and tick() - startTime < timeout do
        local hrp = GetHRP()
        if hrp then
            local nearest, nd = nil, math.huge
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:FindFirstChildOfClass("Humanoid") then
                    local n = string.lower(obj.Name)
                    if string.find(n, "v4") or string.find(n, "fractal") 
                    or string.find(n, "mirror") or string.find(n, "trial")
                    or string.find(n, "train") or string.find(n, "essence") then
                        local trp = obj:FindFirstChild("HumanoidRootPart")
                        local hum = obj:FindFirstChildOfClass("Humanoid")
                        if trp and hum and hum.Health > 0 then
                            local d = GetDist(trp.Position, hrp.Position)
                            if d < 2000 and d < nd then nearest, nd = obj, d end
                        end
                    end
                end
            end
            if nearest then
                local trp = nearest:FindFirstChild("HumanoidRootPart")
                if trp then
                    hrp.CFrame = trp.CFrame * CFrame.new(0, 30, 0)
                    task.wait(0.1)
                end
                AutoAttackNPC(nearest, 3)
                killed += 1
                Log("Train V4: "..killed.."/"..count)
            else
                task.wait(0.5)
            end
        end
        task.wait(0.2)
    end
    return killed
end

local function WaitFragments(amount, timeout)
    timeout = timeout or 120
    local startTime = tick()
    while GetFragments() < amount and tick() - startTime < timeout do
        -- Auto collect fragment
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = string.lower(obj.Name)
                if string.find(n, "fragment") then
                    if obj:FindFirstChild("TouchInterest") then
                        local hrp = GetHRP()
                        if hrp then 
                            TweenToPosition(obj.Position + Vector3.new(0,3,0), 400)
                        end
                    end
                end
            end
        end
        task.wait(1)
    end
    return GetFragments() >= amount
end

--// UIScale
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
Create("TextLabel", {Parent=Header, BackgroundTransparency=1, Position=UDim2.fromOffset(79,39), Size=UDim2.fromOffset(320,20), Text="Freemium Version v0.1", TextColor3=Color3.fromRGB(120,150,195), TextSize=12, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=22})

local StatusDot = Create("Frame", {Parent=Header, Size=UDim2.fromOffset(10,10), Position=UDim2.new(1,-280,0,26), BackgroundColor3=Color3.fromRGB(0,220,150), BorderSizePixel=0, ZIndex=22})
Corner(StatusDot, 10)
Create("TextLabel", {Parent=Header, BackgroundTransparency=1, Position=UDim2.new(1,-265,0,19), Size=UDim2.fromOffset(90,25), Text="Game Loaded", TextColor3=Color3.fromRGB(210,220,235), TextSize=11, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=22})
Create("TextLabel", {Parent=Header, BackgroundTransparency=1, Position=UDim2.new(1,-165,0,19), Size=UDim2.fromOffset(60,25), Text="v0.1", TextColor3=Color3.fromRGB(130,145,175), TextSize=11, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Center, ZIndex=22})

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
    local B = Create("TextButton", {Parent=parent, BackgroundColor3=Color3.fromRGB(17,13,29), Size=UDim2.new(1,0,0,38), Text="", AutoButtonColor=false, BorderSizePixel=0, ZIndex=100})
    Corner(B, 8) Stroke(B, Color3.fromRGB(0,150,255), 1.2, 0.4)
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

local function CreateButton(parent, text, cb)
    local B = Create("TextButton", {
        Parent=parent, BackgroundColor3=Color3.fromRGB(17,13,29),
        Size=UDim2.new(1,0,0,38), Text=text,
        TextColor3=Color3.fromRGB(255,255,255), TextSize=12,
        Font=Enum.Font.GothamMedium, AutoButtonColor=false,
        BorderSizePixel=0, ZIndex=100,
    })
    Corner(B, 8)
    Stroke(B, Color3.fromRGB(0,150,255), 1.2, 0.4)
    B.MouseEnter:Connect(function() TweenService:Create(B, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(0,150,255)}):Play() end)
    B.MouseLeave:Connect(function() TweenService:Create(B, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(17,13,29)}):Play() end)
    B.Activated:Connect(function() if cb then pcall(cb) end end)
    return B
end

local function CreateDropdown(parent, title, options, cb)
    local Holder = Create("Frame", {Parent=parent, BackgroundColor3=Color3.fromRGB(17,13,29), Size=UDim2.new(1,0,0,38), BorderSizePixel=0, ZIndex=100, ClipsDescendants=false})
    Corner(Holder, 8) Stroke(Holder, Color3.fromRGB(0,150,255), 1.2, 0.4)
    local Selected = options[1] or "Select"
    local TitleLbl = Create("TextLabel", {Parent=Holder, BackgroundTransparency=1, Position=UDim2.new(0,10,0,0), Size=UDim2.new(1,-35,1,0), Text=title..": "..Selected, TextColor3=Color3.fromRGB(255,255,255), TextSize=12, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=101})
    Create("TextLabel", {Parent=Holder, BackgroundTransparency=1, Position=UDim2.new(1,-22,0,0), Size=UDim2.new(0,18,1,0), Text="v", TextColor3=Color3.fromRGB(255,255,255), TextSize=11, Font=Enum.Font.GothamBold, ZIndex=101})
    local clickBtn = Create("TextButton", {Parent=Holder, BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Text="", AutoButtonColor=false, ZIndex=110})
    clickBtn.Activated:Connect(function()
        local popup = Create("Frame", {Parent=Gui, AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0), Size=UDim2.fromOffset(300, math.min(#options*38+80, 400)), BackgroundColor3=Color3.fromRGB(10,18,34), BorderSizePixel=0, ZIndex=999990})
        Corner(popup, 12)
        local ps = Instance.new("UIStroke") ps.Color = Color3.fromRGB(0,150,255) ps.Thickness = 2 ps.Parent = popup
        Create("TextLabel", {Parent=popup, BackgroundTransparency=1, Position=UDim2.fromOffset(15,10), Size=UDim2.new(1,-60,0,25), Text=title, TextColor3=Color3.fromRGB(235,242,255), TextSize=15, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=999991})
        local closeBtn = Create("TextButton", {Parent=popup, Position=UDim2.new(1,-40,0,10), Size=UDim2.fromOffset(30,25), Text="×", TextColor3=Color3.fromRGB(255,255,255), TextSize=22, BackgroundTransparency=1, Font=Enum.Font.GothamBold, AutoButtonColor=false, ZIndex=999992})
        closeBtn.Activated:Connect(function() popup:Destroy() end)
        local ls = Create("ScrollingFrame", {Parent=popup, BackgroundTransparency=1, Position=UDim2.fromOffset(10,42), Size=UDim2.new(1,-20,1,-52), CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=3, ScrollBarImageColor3=Color3.fromRGB(0,150,255), BorderSizePixel=0, ZIndex=999991})
        local LL = Instance.new("UIListLayout") LL.Padding = UDim.new(0,4) LL.SortOrder = Enum.SortOrder.LayoutOrder LL.Parent = ls
        for i, opt in ipairs(options) do
            local OB = Create("TextButton", {Parent=ls, BackgroundColor3=Color3.fromRGB(17,13,29), Size=UDim2.new(1,-8,0,34), Position=UDim2.new(0,4,0,0), Text=opt, TextColor3=Color3.fromRGB(255,255,255), TextSize=13, Font=Enum.Font.GothamMedium, AutoButtonColor=false, BorderSizePixel=0, LayoutOrder=i, ZIndex=999992, TextXAlignment=Enum.TextXAlignment.Left})
            Corner(OB, 6)
            local pad = Instance.new("UIPadding") pad.PaddingLeft = UDim.new(0, 10) pad.Parent = OB
            OB.MouseEnter:Connect(function() TweenService:Create(OB, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(0,150,255)}):Play() end)
            OB.MouseLeave:Connect(function() TweenService:Create(OB, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(17,13,29)}):Play() end)
            OB.Activated:Connect(function()
                Selected = opt TitleLbl.Text = title..": "..opt
                if cb then pcall(cb, opt) end
                popup:Destroy()
            end)
        end
    end)
    return Holder
end

local function CreateCustomDropdown(parent, title, getOptionsFn, cb)
    local Holder = Create("Frame", {Parent=parent, BackgroundColor3=Color3.fromRGB(17,13,29), Size=UDim2.new(1,0,0,38), BorderSizePixel=0, ZIndex=100, ClipsDescendants=false})
    Corner(Holder, 8) Stroke(Holder, Color3.fromRGB(0,150,255), 1.2, 0.4)
    local Selected = "..."
    local TitleLbl = Create("TextLabel", {Parent=Holder, BackgroundTransparency=1, Position=UDim2.new(0,10,0,0), Size=UDim2.new(1,-35,1,0), Text=title..": Loading...", TextColor3=Color3.fromRGB(255,255,255), TextSize=12, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=101})
    Create("TextLabel", {Parent=Holder, BackgroundTransparency=1, Position=UDim2.new(1,-22,0,0), Size=UDim2.new(0,18,1,0), Text="v", TextColor3=Color3.fromRGB(255,255,255), TextSize=11, Font=Enum.Font.GothamBold, ZIndex=101})
    local clickBtn = Create("TextButton", {Parent=Holder, BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Text="", AutoButtonColor=false, ZIndex=110})
    clickBtn.Activated:Connect(function()
        local sea, options = getOptionsFn()
        if not options or #options == 0 then Notify("No options") return end
        local popup = Create("Frame", {Parent=Gui, AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0), Size=UDim2.fromOffset(300, math.min(#options*38+80, 400)), BackgroundColor3=Color3.fromRGB(10,18,34), BorderSizePixel=0, ZIndex=999990})
        Corner(popup, 12)
        local ps = Instance.new("UIStroke") ps.Color = Color3.fromRGB(0,150,255) ps.Thickness = 2 ps.Parent = popup
        Create("TextLabel", {Parent=popup, BackgroundTransparency=1, Position=UDim2.fromOffset(15,10), Size=UDim2.new(1,-60,0,25), Text=title.." ("..sea..")", TextColor3=Color3.fromRGB(235,242,255), TextSize=15, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=999991})
        local closeBtn = Create("TextButton", {Parent=popup, Position=UDim2.new(1,-40,0,10), Size=UDim2.fromOffset(30,25), Text="×", TextColor3=Color3.fromRGB(255,255,255), TextSize=22, BackgroundTransparency=1, Font=Enum.Font.GothamBold, AutoButtonColor=false, ZIndex=999992})
        closeBtn.Activated:Connect(function() popup:Destroy() end)
        local ls = Create("ScrollingFrame", {Parent=popup, BackgroundTransparency=1, Position=UDim2.fromOffset(10,42), Size=UDim2.new(1,-20,1,-52), CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=3, ScrollBarImageColor3=Color3.fromRGB(0,150,255), BorderSizePixel=0, ZIndex=999991})
        local LL = Instance.new("UIListLayout") LL.Padding = UDim.new(0,4) LL.SortOrder = Enum.SortOrder.LayoutOrder LL.Parent = ls
        for i, opt in ipairs(options) do
            local OB = Create("TextButton", {Parent=ls, BackgroundColor3=Color3.fromRGB(17,13,29), Size=UDim2.new(1,-8,0,34), Position=UDim2.new(0,4,0,0), Text=opt, TextColor3=Color3.fromRGB(255,255,255), TextSize=13, Font=Enum.Font.GothamMedium, AutoButtonColor=false, BorderSizePixel=0, LayoutOrder=i, ZIndex=999992, TextXAlignment=Enum.TextXAlignment.Left})
            Corner(OB, 6)
            local pad = Instance.new("UIPadding") pad.PaddingLeft = UDim.new(0, 10) pad.Parent = OB
            OB.MouseEnter:Connect(function() TweenService:Create(OB, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(0,150,255)}):Play() end)
            OB.MouseLeave:Connect(function() TweenService:Create(OB, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(17,13,29)}):Play() end)
            OB.Activated:Connect(function()
                Selected = opt TitleLbl.Text = title.." ("..sea.."): "..opt
                if cb then pcall(cb, opt) end
                popup:Destroy()
            end)
        end
    end)
    task.spawn(function()
        while task.wait(3) do
            local sea, options = getOptionsFn()
            if TitleLbl then
                if not Selected or Selected == "..." or not table.find(options or {}, Selected) then
                    Selected = (options and options[1]) or "..."
                    if cb then pcall(cb, Selected) end
                end
                TitleLbl.Text = title.." ("..sea.."): "..tostring(Selected)
            end
        end
    end)
    return Holder
end

local function CreateSlider(parent, title, minVal, maxVal, defaultVal, cb)
    local val = defaultVal or minVal
    local Holder = Create("Frame", {Parent=parent, BackgroundColor3=Color3.fromRGB(17,13,29), Size=UDim2.new(1,0,0,46), BorderSizePixel=0, ZIndex=100})
    Corner(Holder, 8) Stroke(Holder, Color3.fromRGB(0,150,255), 1.2, 0.4)
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
    Corner(L, 8) Stroke(L, Color3.fromRGB(0,150,255), 1.2, 0.4)
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
CreateButton(DiscordPage, "📋 Copy Discord Link", function()
    if setclipboard then 
        setclipboard(CONFIG.Discord) 
        Notify("📋 Discord Link Copied") 
    end
end)

--// FARM
CreateDropdown(FarmPage, "Select Weapon", {"Melee","Sword","Gun","Fruit"}, function(opt) State.SelectedCategory = opt end)
CreateToggle(FarmPage, "Auto Farm Level", false, function(s)
    State.AutoFarm = s
    if s then State.Hitbox = true else State.Hitbox = false end
    Log("Auto Farm: "..(s and "ON" or "OFF"))
end)
CreateToggle(FarmPage, "Auto Farm Nearest", false, function(s)
    State.AutoFarmNearest = s
    if s then State.Hitbox = true else State.Hitbox = false end
    Log("Farm Nearest: "..(s and "ON" or "OFF"))
end)
CreateToggle(FarmPage, "Auto Kill Nearest", false, function(s) State.AutoKillNearest = s Log("Kill Nearest: "..(s and "ON" or "OFF")) end)
CreateToggle(FarmPage, "Farm Chest", false, function(s)
    State.AutoChest = s
    if s then State.FirstRunChest = true State.UncheckedChests = {} end
    Log("Farm Chest: "..(s and "ON" or "OFF"))
end)

CreateCustomDropdown(FarmPage, "Select Boss", function()
    local sea = GetCurrentSea()
    return sea, BossDataBySea[sea] or {"Unknown"}
end, function(opt)
    State.SelectedBoss = opt
    Log("Boss: "..opt)
end)
CreateButton(FarmPage, "🔄 Refresh Boss", function() Notify("🔄 Boss refreshed ("..GetCurrentSea()..")") end)
CreateToggle(FarmPage, "Auto Farm Boss", false, function(s) State.AutoBoss = s Log("Auto Boss: "..(s and "ON" or "OFF")) end)

CreateLabel(FarmPage, "Bones System", 34)
CreateToggle(FarmPage, "Random Bone (Surprise)", false, function(s) 
    if s then Invoke("Bones", "Buy", 1, 1) Notify("🦴 Surprise Bought") task.wait(0.5) end 
end)
CreateToggle(FarmPage, "Bone Stat Refund", false, function(s) 
    if s then Invoke("Bones", "Buy", 1, 2) Notify("🦴 Stat Refund") task.wait(0.5) end 
end)
CreateToggle(FarmPage, "Bone Race Reroll", false, function(s) 
    if s then Invoke("Bones", "Buy", 1, 3) Notify("🦴 Race Reroll") task.wait(0.5) end 
end)

--// SEA
CreateDropdown(SeaPage, "Select Mob", {"Sea Beast","Terrorshark","Shark","Piranha","Fish Crew Member","Fish Crew Warrior"}, function(opt) 
    State.SelectedSeaMob = opt 
    Log("Sea Mob: "..opt) 
end)
CreateCustomDropdown(SeaPage, "Select Boat", function()
    local sea = GetCurrentSea()
    return sea, BoatDataBySea[sea] or {"Dinghy"}
end, function(opt)
    State.SelectedBoat = opt
    Log("Boat: "..opt)
end)
CreateToggle(SeaPage, "Auto Farm Sea", false, function(s) State.AutoFarmSea = s Log("Farm Sea: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Find Mirage", false, function(s) State.FindMirage = s Log("Find Mirage: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Tween Mirage", false, function(s) State.MirageTweenEnabled = s Log("Tween Mirage: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Find Kitsune", false, function(s) State.FindKitsune = s Log("Find Kitsune: "..(s and "ON" or "OFF")) end)
CreateSlider(SeaPage, "Kitsune Level", 0, 300, 0, function(v) State.KitsuneLevel = v end)
CreateToggle(SeaPage, "Find Prehistoric", false, function(s) State.FindPrehistoric = s Log("Find Prehistoric: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Find Frozen Dimension", false, function(s) State.FindFrozenDim = s Log("Find Frozen Dim: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Auto Drive Tiki", false, function(s) State.AutoDriveTiki = s Notify("🏝️ Drive Tiki: "..(s and "ON" or "OFF")) end)
CreateSlider(SeaPage, "Boat Speed", 0, 1000, 500, function(v) 
    State.BoatSpeed = v
    pcall(function()
        local boat = GetBoat()
        if boat then
            local seat = boat:FindFirstChildWhichIsA("VehicleSeat", true)
            if seat then
                pcall(function() seat.MaxSpeed = v end)
                pcall(function() seat.Torque = v * 100 end)
            end
        end
    end)
end)
CreateSlider(SeaPage, "Boat Height", 0, 100, 5, function(v) State.BoatHeight = v end)
CreateButton(SeaPage, "🚤 Apply Boat Speed", function()
    local boat = GetBoat()
    if not boat then Notify("❌ Boat not found") return end
    local seat = boat:FindFirstChildWhichIsA("VehicleSeat", true)
    if not seat then Notify("❌ Seat not found") return end
    pcall(function() seat.MaxSpeed = State.BoatSpeed end)
    pcall(function() seat.Torque = State.BoatSpeed * 100 end)
    Notify("🚤 Boat Speed: "..State.BoatSpeed)
end)
CreateButton(SeaPage, "⬆️ Apply Boat Height", function()
    local boat = GetBoat()
    if not boat or not boat.PrimaryPart then Notify("❌ Boat not found") return end
    pcall(function()
        boat.PrimaryPart.CFrame = boat.PrimaryPart.CFrame + Vector3.new(0, State.BoatHeight, 0)
    end)
    Notify("⬆️ Height: "..State.BoatHeight)
end)
CreateToggle(SeaPage, "Auto Buy Boat", false, function(s) State.AutoBuyBoat = s Log("Buy Boat: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Auto Collect Bone", false, function(s) State.AutoCollectBone = s Log("Collect Bone: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Auto Collect Dino Egg", false, function(s) State.AutoCollectDinoEgg = s Log("Collect Egg: "..(s and "ON" or "OFF")) end)
CreateToggle(SeaPage, "Auto Kill Golem", false, function(s) State.AutoKillGolem = s Log("Kill Golem: "..(s and "ON" or "OFF")) end)

--// QUEST / ITEMS
CreateLabel(QuestItemsPage, "Sea Travel", 34)
CreateButton(QuestItemsPage, "🌊 Travel Sea 2", function() Invoke("TravelDressrosa") Notify("🌊 Sea 2") end)
CreateButton(QuestItemsPage, "🌊 Travel Sea 3", function() Invoke("TravelZou") Notify("🌊 Sea 3") end)

CreateLabel(QuestItemsPage, "Quest Chain (All-in-One)", 34)
CreateToggle(QuestItemsPage, "Auto Get Saber", false, function(s)
    if s then if StartChain("Saber") then task.spawn(RunAutoSaber) end else StopChain() end
end)
CreateToggle(QuestItemsPage, "Auto Get CDK", false, function(s)
    if s then if StartChain("CDK") then task.spawn(RunAutoCDK) end else StopChain() end
end)
CreateToggle(QuestItemsPage, "Auto Get Tushita", false, function(s)
    if s then if StartChain("Tushita") then task.spawn(RunAutoTushita) end else StopChain() end
end)
CreateToggle(QuestItemsPage, "Auto Get Soul Guitar", false, function(s)
    if s then if StartChain("SoulGuitar") then task.spawn(RunAutoSoulGuitar) end else StopChain() end
end)
CreateToggle(QuestItemsPage, "Auto Get Yama", false, function(s)
    if s then if StartChain("Yama") then task.spawn(RunAutoYama) end else StopChain() end
end)
CreateToggle(QuestItemsPage, "Auto Get Dark Dagger", false, function(s)
    if s then if StartChain("DarkDagger") then task.spawn(RunAutoDarkDagger) end else StopChain() end
end)
CreateToggle(QuestItemsPage, "Auto Get Buddy Sword", false, function(s)
    if s then if StartChain("BuddySword") then task.spawn(RunAutoBuddySword) end else StopChain() end
end)
CreateToggle(QuestItemsPage, "Auto Get Dough King", false, function(s)
    if s then if StartChain("DoughKing") then task.spawn(RunAutoDoughKing) end else StopChain() end
end)

CreateLabel(QuestItemsPage, "Race", 34)
CreateToggle(QuestItemsPage, "Auto Race V2", false, function(s) State.AutoRaceV2 = s Log("Race V2: "..(s and "ON" or "OFF")) end)
CreateToggle(QuestItemsPage, "Auto Race V3", false, function(s) State.AutoRaceV3 = s Log("Race V3: "..(s and "ON" or "OFF")) end)

CreateLabel(QuestItemsPage, "Event", 34)
CreateToggle(QuestItemsPage, "Auto Blackbeard Reward", false, function(s) 
    if s then Invoke("BlackbeardReward", "DragonClaw", "1") Notify("☠️ Blackbeard") end 
end)
CreateToggle(QuestItemsPage, "Auto Horned Man Bet", false, function(s) 
    if s then Invoke("HornedMan", "Bet") Notify("🎲 Horned") end 
end)
CreateToggle(QuestItemsPage, "Auto Talk Trevor", false, function(s) 
    if s then Invoke("TalkTrevor", "1") Notify("💬 Trevor") end 
end)
CreateButton(QuestItemsPage, "❌ Abandon Quest", function() Invoke("AbandonQuest") Notify("❌ Abandoned") end)

--// FRUIT / RAID
CreateToggle(FruitRaidPage, "Tween Fruit", false, function(s) State.FruitTweenEnabled = s Log("Tween Fruit: "..(s and "ON" or "OFF")) end)
CreateToggle(FruitRaidPage, "Auto Store Fruit", false, function(s) State.FruitStoreEnabled = s Log("Auto Store: "..(s and "ON" or "OFF")) end)
CreateToggle(FruitRaidPage, "Random Fruit (Gacha)", false, function(s) State.AutoGacha = s Log("Gacha: "..(s and "ON" or "OFF")) end)
CreateCustomDropdown(FruitRaidPage, "Select Raid", function()
    local sea = GetCurrentSea()
    return sea, RaidDataBySea[sea] or {"Flame"}
end, function(opt)
    State.SelectedRaid = opt
    Log("Raid: "..opt)
end)
CreateButton(FruitRaidPage, "🔄 Refresh Raid", function() Notify("🔄 Raid refreshed ("..GetCurrentSea()..")") end)
CreateToggle(FruitRaidPage, "Auto Raid", false, function(s) State.AutoRaid = s Log("Auto Raid: "..(s and "ON" or "OFF")) end)

--// FISHING
CreateToggle(FishingPage, "Auto Fishing", false, function(s) State.AutoFish = s Log("Fishing: "..(s and "ON" or "OFF")) end)

--// STATUS
local StatusLabel = CreateLabel(StatusPage, "Loading...", 220)
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
StatusLabel.TextSize = 11

local function GetRace()
    local r = Player:GetAttribute("Race")
    if r then return tostring(r) end
    return "Unknown"
end
local function GetMelee()
    local ls = Player:FindFirstChild("leaderstats")
    if ls then
        local m = ls:FindFirstChild("Melee") or ls:FindFirstChild("MeleePower")
        if m then return tostring(m.Value) end
    end
    return "?"
end
local function GetMoonPhase()
    local l = Lighting:GetAttribute("MoonPhase") or workspace:GetAttribute("MoonPhase")
    if l then return tostring(l) end
    return "?"
end
local function GetFruitSpawn()
    local fruits = {}
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Tool") or obj:IsA("Model") then
            if string.find(obj.Name, "Fruit") then table.insert(fruits, obj.Name) end
        end
    end
    if #fruits == 0 then return "None" end
    return table.concat(fruits, ", ")
end
local function GetSeaEventSpawn(keyword, attribute)
    for _, obj in ipairs(workspace:GetChildren()) do
        if attribute and obj:GetAttribute(attribute) == true then return "Spawned" end
        if keyword and string.find(string.lower(obj.Name), keyword) then return "Spawned" end
    end
    local seaFolder = workspace:FindFirstChild("SeaEvents")
    if seaFolder then
        for _, obj in ipairs(seaFolder:GetDescendants()) do
            if attribute and obj:GetAttribute(attribute) == true then return "Spawned" end
            if keyword and string.find(string.lower(obj.Name), keyword) then return "Spawned" end
        end
    end
    return "Not Spawned"
end

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local level = GetLevel()
            local race = GetRace()
            local melee = GetMelee()
            local eliteProg = State.EliteProgress or 0
            local moon = GetMoonPhase()
            local fruit = GetFruitSpawn()
            local mirage = GetSeaEventSpawn("mirage", "MirageIsland")
            local kitsune = GetSeaEventSpawn("kitsune", "KitsuneIsland")
            local prehistoric = GetSeaEventSpawn("prehistoric", "PrehistoricIsland")
            local frozen = GetSeaEventSpawn("frozen", "FrozenDimension")
            local fragments = GetFragments()
            
            StatusLabel.Text = string.format(
                "━━━ PLAYER ━━━\nRace: %s\nLevel: %d\nMelee: %s\nElite Hunter: %d/3\nFragments: %d\n\n━━━ SERVER ━━━\nMoon Phase: %s\nFruit Spawn: %s\nMirage: %s\nKitsune Island: %s\nPrehistoric: %s\nFrozen Dimension: %s",
                race, level, melee, eliteProg, fragments, moon, fruit, mirage, kitsune, prehistoric, frozen
            )
        end)
    end
end)

--// PVP
CreateDropdown(PvPPage, "Select Player", (function()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do if plr ~= Player then table.insert(list, plr.Name) end end
    if #list == 0 then list = {"No players"} end
    return list
end)(), function(opt) State.SelectedPlayer = opt Log("Player: "..opt) end)
CreateToggle(PvPPage, "Aimbot", false, function(s)
    State.Aimbot = s
    if s then StartAimbot() else StopAimbot() end
    Log("Aimbot: "..(s and "ON" or "OFF"))
end)

--// TRIALS
CreateLabel(TrialsPage, "Race V4 Trial System", 34)
local TrialStatusLabel = CreateLabel(TrialsPage, "RaceV4Progress: -", 34)

task.spawn(function()
    while task.wait(2) do
        local prog = Invoke("RaceV4Progress", "Check")
        if TrialStatusLabel then
            local stageText = "Unknown"
            if prog == 1 then stageText = "Trial 1 - Unlock V4"
            elseif prog == 2 then stageText = "Train 1 - V4 x3 + 1000 Frag"
            elseif prog == 3 then stageText = "Train 2 - V4 x5 + 1500 Frag"
            elseif prog == 4 then stageText = "Train 3 - V4 x4/x5/x10"
            elseif prog == 0 then stageText = "V4 Unlocked / Train 4"
            end
            TrialStatusLabel.Text = "RaceV4Progress: "..tostring(prog).." ("..stageText..")"
        end
    end
end)

CreateToggle(TrialsPage, "Auto Pull Lever", false, function(s)
    State.AutoPullLever = s
    Notify("🔧 Lever: "..(s and "ON" or "OFF"))
    if s then
        task.spawn(function()
            while State.AutoPullLever do
                pcall(function()
                    local hrp = GetHRP()
                    if not hrp then return end
                    local leverPos = Vector3.new(-12440, 550, -7100)
                    if (hrp.Position - leverPos).Magnitude > 20 then TweenToPosition(leverPos, 300) end
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") or obj:IsA("Model") then
                            local n = string.lower(obj.Name)
                            if string.find(n, "lever") then
                                local part = obj:IsA("BasePart") and obj or obj.PrimaryPart
                                if part and (part.Position - leverPos).Magnitude < 100 then
                                    local pp = obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChild("ProximityPrompt", true)
                                    if pp then
                                        pcall(function()
                                            pp:InputHoldBegin() task.wait(0.3) pp:InputHoldEnd()
                                        end)
                                    end
                                    local cd = obj:FindFirstChildOfClass("ClickDetector")
                                    if cd then pcall(function() fireclickdetector(cd) end) end
                                end
                            end
                        end
                    end
                end)
                task.wait(3)
            end
        end)
    end
end)

CreateToggle(TrialsPage, "Auto Trial Only", false, function(s)
    State.AutoTrialOnly = s
    Notify("⚔️ Auto Trial: "..(s and "ON" or "OFF"))
    if s then
        task.spawn(function()
            while State.AutoTrialOnly do
                pcall(function()
                    local prog = Invoke("RaceV4Progress", "Check")
                    if prog == 1 then
                        Invoke("RaceV4Progress", "Begin") task.wait(1)
                    end
                    -- Kill trial mob
                    KillTrialMobs(5, 30)
                    Invoke("RaceV4Progress", "Continue")
                end)
                task.wait(3)
            end
        end)
    end
end)

CreateToggle(TrialsPage, "Auto Train V4", false, function(s)
    State.AutoTrainV4 = s
    Notify("🏋️ Train V4: "..(s and "ON" or "OFF"))
    if s then
        task.spawn(function()
            while State.AutoTrainV4 do
                pcall(function()
                    local prog = Invoke("RaceV4Progress", "Check")
                    -- Tentukan target berdasarkan stage
                    local targetKills = 5
                    local targetFragments = 1000
                    
                    if prog == 2 then 
                        targetKills = 3 targetFragments = 1000 
                    elseif prog == 3 then 
                        targetKills = 5 targetFragments = 1500 
                    elseif prog == 4 then 
                        targetKills = 10 targetFragments = 2500 
                    else 
                        targetKills = 9 targetFragments = 4000 
                    end
                    
                    -- Kill V4 mobs
                    Notify("Killing V4 mobs: "..targetKills)
                    KillTrialMobs(targetKills, 90)
                    
                    -- Collect fragments
                    Notify("Collecting "..targetFragments.." fragments")
                    WaitFragments(targetFragments, 120)
                    
                    Invoke("RaceV4Progress", "Continue")
                    task.wait(2)
                end)
                task.wait(3)
            end
        end)
    end
end)

CreateToggle(TrialsPage, "Auto Trial V4 Complete", false, function(s)
    State.AutoTrialV4 = s
    Notify("🏆 Auto Trial V4: "..(s and "ON" or "OFF"))
    if s then
        task.spawn(function()
            while State.AutoTrialV4 do
                pcall(function()
                    local prog = Invoke("RaceV4Progress", "Check")
                    Log("V4 Progress: "..tostring(prog))
                    
                    if prog == 1 then
                        -- Trial 1
                        Notify("Stage: Trial 1")
                        TweenToPosition(Vector3.new(-12440, 550, -7100), 300)
                        task.wait(1)
                        Invoke("RaceV4Progress", "Begin")
                        task.wait(2)
                        KillTrialMobs(5, 30)
                        Invoke("RaceV4Progress", "Continue")
                        
                    elseif prog == 2 then
                        -- Train 1: V4 x3 + 1000 Fragments
                        Notify("Stage: Train 1 (x3 + 1000 Frag)")
                        KillTrialMobs(3, 60)
                        WaitFragments(1000, 90)
                        Invoke("RaceV4Progress", "Continue")
                        
                    elseif prog == 3 then
                        -- Train 2: V4 x5 + 1500 Fragments
                        Notify("Stage: Train 2 (x5 + 1500 Frag)")
                        KillTrialMobs(5, 90)
                        WaitFragments(1500, 120)
                        Invoke("RaceV4Progress", "Continue")
                        
                    elseif prog == 4 then
                        -- Train 3: V4 x4/x5/x10
                        Notify("Stage: Train 3 (x10)")
                        KillTrialMobs(10, 120)
                        WaitFragments(2500, 150)
                        Invoke("RaceV4Progress", "Continue")
                        
                    else
                        -- Train 4: Final
                        Notify("Stage: Train 4 (Final)")
                        KillTrialMobs(9, 120)
                        WaitFragments(4000, 180)
                        Notify("🏆 Race V4 Complete!")
                        State.AutoTrialV4 = false
                    end
                end)
                task.wait(3)
            end
        end)
    end
end)

CreateToggle(TrialsPage, "Auto Fragment Collect", false, function(s)
    State.AutoFragment = s
    Notify("💎 Fragment: "..(s and "ON" or "OFF"))
    if s then
        task.spawn(function()
            while State.AutoFragment do
                pcall(function()
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            local n = string.lower(obj.Name)
                            if string.find(n, "fragment") then
                                if obj:FindFirstChild("TouchInterest") then
                                    local hrp = GetHRP()
                                    if hrp then TweenToPosition(obj.Position + Vector3.new(0,3,0), 400) end
                                end
                            end
                        end
                    end
                end)
                task.wait(2)
            end
        end)
    end
end)

--// SETING (ESP)
CreateToggle(SetingPage, "ESP Player", false, function(s) State.ESPPlayer = s Log("ESP Player: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Fruit", false, function(s) State.ESPFruit = s Log("ESP Fruit: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Chest", false, function(s) State.ESPChest = s Log("ESP Chest: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Island", false, function(s) State.ESPIsland = s Log("ESP Island: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Blue Gear", false, function(s) State.ESPBlueGear = s Log("ESP Gear: "..(s and "ON" or "OFF")) end)
CreateToggle(SetingPage, "ESP Flower", false, function(s) State.ESPFlower = s Log("ESP Flower: "..(s and "ON" or "OFF")) end)

--// TELEPORT
CreateCustomDropdown(TeleportPage, "Select Island", function()
    local sea = GetCurrentSea()
    return sea, SeaIslands[sea] or {"Starter Island"}
end, function(opt)
    State.SelectedIsland = opt
    Log("Island: "..opt)
end)
CreateButton(TeleportPage, "📍 Tween ke Island", function()
    local pos = IslandCoords[State.SelectedIsland]
    if pos then
        TweenToIslandSmooth(pos + Vector3.new(0,3,0))
        Notify("📍 Tween: "..State.SelectedIsland)
    else
        Notify("❌ Koordinat tidak ditemukan")
    end
end)
CreateButton(TeleportPage, "🌊 Travel Sea 1", function() Invoke("TravelMain") Notify("🌊 Sea 1") end)
CreateButton(TeleportPage, "🌊 Travel Sea 2", function() Invoke("TravelDressrosa") Notify("🌊 Sea 2") end)
CreateButton(TeleportPage, "🌊 Travel Sea 3", function() Invoke("TravelZou") Notify("🌊 Sea 3") end)

--// STATS
CreateToggle(StatsPage, "Auto Add Stats", false, function(s) State.AutoAddStats = s Log("Add Stats: "..(s and "ON" or "OFF")) end)
CreateSlider(StatsPage, "Melee", 0, 100, 0, function(v) State.StatsMelee = v end)
CreateSlider(StatsPage, "Sword", 0, 100, 0, function(v) State.StatsSword = v end)
CreateSlider(StatsPage, "Gun", 0, 100, 0, function(v) State.StatsGun = v end)
CreateSlider(StatsPage, "Fruit", 0, 100, 0, function(v) State.StatsBloxFruit = v end)
CreateButton(StatsPage, "✅ Apply Stats Now", function()
    local stats = {
        {Name="Melee",Value=State.StatsMelee},
        {Name="Sword",Value=State.StatsSword},
        {Name="Gun",Value=State.StatsGun},
        {Name="Blox Fruit",Value=State.StatsBloxFruit}
    }
    for _, st in ipairs(stats) do if st.Value > 0 then Invoke("AddPoint", st.Name, st.Value) task.wait(0.3) end end
    Notify("✅ Stats applied")
end)

--// SHOP
CreateDropdown(ShopPage, "Select Melee", {"Black Leg","Electro","Fishman Karate","Sharkman Karate","Dragon Talon","Electric Claw","Death Step","Superhuman","Godhuman"}, function(opt) State.SelectedMelee = opt Log("Melee: "..opt) end)
CreateButton(ShopPage, "🛒 Buy Selected Melee", function()
    if not State.SelectedMelee then Notify("Select melee first") return end
    local map = {["Black Leg"]="BuyBlackLeg",["Electro"]="BuyElectro",["Fishman Karate"]="BuyFishmanKarate",["Sharkman Karate"]="BuySharkmanKarate",["Dragon Talon"]="BuyDragonTalon",["Electric Claw"]="BuyElectricClaw",["Death Step"]="BuyDeathStep",["Superhuman"]="BuySuperhuman",["Godhuman"]="BuyGodhuman"}
    local fn = map[State.SelectedMelee]
    if fn then Invoke(fn) Notify("🛒 Bought: "..State.SelectedMelee) end
end)
CreateDropdown(ShopPage, "Select Sword", {"Katana","Cutlass","Iron Mace","Dual Katana","Triple Katana","Pipe","Small Sword","Dual-Headed Blade","Soul Cane","Saber","Rengoku","Shisui","Yama","Tushita","Cursed Dual Katana","Dark Dagger","Buddy Sword","Hallow Scythe","Spikey Trident","Trident"}, function(opt) State.SelectedSword = opt Log("Sword: "..opt) end)
CreateButton(ShopPage, "🛒 Buy Selected Sword", function()
    if State.SelectedSword then Invoke("BuyItem", State.SelectedSword) Notify("🛒 "..State.SelectedSword) end
end)
CreateDropdown(ShopPage, "Select Gun", {"Slingshot","Flintlock","Refined Flintlock","Musket","Refined Musket","Cannon","Bazooka","Sniper","Kabucha","Acidum Rifle","Bizarre Rifle","Serpent Bow"}, function(opt) State.SelectedGun = opt Log("Gun: "..opt) end)
CreateButton(ShopPage, "🛒 Buy Selected Gun", function()
    if State.SelectedGun then Invoke("BuyItem", State.SelectedGun) Notify("🛒 "..State.SelectedGun) end
end)
CreateDropdown(ShopPage, "Select Abilities", {"Ken","Buso","Geppo"}, function(opt) State.SelectedAbility = opt Log("Ability: "..opt) end)
CreateButton(ShopPage, "🛒 Buy Selected Ability", function()
    if State.SelectedAbility == "Ken" then Invoke("KenTalk", "Buy")
    elseif State.SelectedAbility == "Buso" then Invoke("BuyHaki", "Buso")
    elseif State.SelectedAbility == "Geppo" then Invoke("BuyHaki", "Geppo") end
    Notify("🛒 "..tostring(State.SelectedAbility))
end)
CreateButton(ShopPage, "🛒 Buy Soru", function() Invoke("BuyHaki", "Soru") Notify("🛒 Soru") end)

--// MISC
CreateToggle(MiscPage, "Anti AFK", true, function(s) State.AntiAFK = s Log("Anti AFK: "..(s and "ON" or "OFF")) end)
CreateToggle(MiscPage, "Bring Mob", false, function(s) State.BringMob = s Notify("🧲 Bring Mob: "..(s and "ON" or "OFF")) end)
CreateSlider(MiscPage, "Bring Mob Range", 0, 100, 50, function(v) State.BringMobRange = v end)
CreateToggle(MiscPage, "Infinite Jump", false, function(s) State.InfiniteJump = s Log("Infinite Jump: "..(s and "ON" or "OFF")) end)
CreateToggle(MiscPage, "Walk On Water", false, function(s)
    State.WalkWater = s
    if s then EnableWalkWater() else DisableWalkWater() end
    Notify("💧 Walk Water: "..(s and "ON" or "OFF"))
end)
CreateToggle(MiscPage, "Boost FPS", false, function(s)
    State.BoostFPS = s
    if s then
        pcall(function()
            State.OriginalLighting = {GlobalShadows=Lighting.GlobalShadows,Brightness=Lighting.Brightness,Ambient=Lighting.Ambient}
            Lighting.GlobalShadows = false Lighting.Brightness = 0
            Lighting.Ambient = Color3.fromRGB(0,0,0) Lighting.FogEnd = 100 Lighting.Outlines = false
        end)
        Notify("⚡ Boost FPS: ON")
    else
        if State.OriginalLighting then
            pcall(function()
                Lighting.GlobalShadows = State.OriginalLighting.GlobalShadows
                Lighting.Brightness = State.OriginalLighting.Brightness
                Lighting.Ambient = State.OriginalLighting.Ambient
            end)
        end
        Notify("⚡ Boost FPS: OFF")
    end
end)
CreateButton(MiscPage, "🌊 Join Marine", function() Invoke("SetTeam", "Marines") Notify("⚓ Marines") end)
CreateButton(MiscPage, "🏴‍☠️ Join Pirate", function() Invoke("SetTeam", "Pirates") Notify("🏴‍☠️ Pirates") end)
CreateButton(MiscPage, "🎁 Redeem All Codes", function()
    local codes = {"KITT_RESET","SUB2GAMERROBOT_RESET1","SUB2GAMERROBOT_EXP1","SUB2OFFICIALNOOBIE","AXIORE","BLUXXY","JCWK","KITTGAMING","MAGICBUS","STARCODEHEO","STRAWHATMAINE","TANTAIGAMING","THEGREATACE","ENYU_IS_PRO"}
    for _, code in ipairs(codes) do Invoke("Redeem", code) task.wait(1) end
    Notify("🎁 All codes redeemed")
end)
CreateButton(MiscPage, "🔄 Rejoin Server", function() TeleportService:Teleport(game.PlaceId, Player) end)

--==================================================
-- LOOPS
--==================================================

-- FARM LEVEL
task.spawn(function()
    while task.wait(0.2) do
        if State.AutoFarm then
            pcall(function()
                ActivateHakiOnce()
                local level = GetLevel()
                if level >= MAX_LEVEL then Log("MAX!") State.AutoFarm = false return end
                local data = GetFarmData(level)
                if not data then return end
                if CommF then pcall(function() CommF:InvokeServer("StartQuest", data.Quest, data.QuestNum) end) end
                local hrp = GetHRP()
                if not hrp then return end
                local nearest, nd = nil, math.huge
                local targetName = data.NPC
                local searchFolders = {}
                local ef = workspace:FindFirstChild("Enemies")
                if ef then table.insert(searchFolders, ef) end
                local nf = workspace:FindFirstChild("NPCs")
                if nf then table.insert(searchFolders, nf) end
                table.insert(searchFolders, workspace)
                for _, folder in ipairs(searchFolders) do
                    if nearest then break end
                    for _, obj in ipairs(folder:GetChildren()) do
                        if obj:FindFirstChildOfClass("Humanoid") then
                            if obj.Name == targetName then
                                local hum = obj:FindFirstChildOfClass("Humanoid")
                                local trp = obj:FindFirstChild("HumanoidRootPart")
                                if hum and trp and hum.Health > 0 then
                                    local d = GetDist(trp.Position, hrp.Position)
                                    if d < nd then nearest = obj nd = d end
                                end
                            end
                        end
                    end
                end
                if nearest then
                    local trp = nearest:FindFirstChild("HumanoidRootPart")
                    if trp then
                        if GetDist(hrp.Position, trp.Position) > 15 then TweenToPosition(trp.Position + Vector3.new(0,3,0), CONFIG.TweenMobSpeed) end
                        if not State.HitboxPart or not State.HitboxPart.Parent then
                            local hb = Instance.new("Part")
                            hb.Name = "SysxHitbox" hb.Size = Vector3.new(30,30,30)
                            hb.Transparency = 1 hb.CanCollide = false hb.CanTouch = true
                            hb.Anchored = true hb.Massless = true hb.Parent = workspace
                            State.HitboxPart = hb
                        end
                        State.HitboxPart.CFrame = CFrame.new(trp.Position)
                        AutoAttackNPC(nearest, 5)
                    end
                else
                    local islandPos = IslandCoords[data.Island]
                    if islandPos and (hrp.Position - islandPos).Magnitude > 500 then TweenToPosition(islandPos + Vector3.new(0,3,0), 500) end
                end
            end)
        else
            if State.HitboxPart then State.HitboxPart:Destroy() State.HitboxPart = nil end
        end
    end
end)

-- FARM NEAREST
task.spawn(function()
    while task.wait(0.15) do
        if State.AutoFarmNearest then
            pcall(function()
                ActivateHakiOnce()
                local level = GetLevel()
                if level >= MAX_LEVEL then Log("MAX!") State.AutoFarmNearest = false return end
                local target = GetNearestEnemy(500)
                if target then
                    local hrp = GetHRP()
                    local trp = target:FindFirstChild("HumanoidRootPart")
                    if hrp and trp then
                        if GetDist(hrp.Position, trp.Position) > 15 then TweenToPosition(trp.Position + Vector3.new(0,3,0), CONFIG.TweenMobSpeed) end
                        if not State.HitboxPart or not State.HitboxPart.Parent then
                            local hb = Instance.new("Part")
                            hb.Name = "SysxHitbox" hb.Size = Vector3.new(30,30,30)
                            hb.Transparency = 1 hb.CanCollide = false hb.CanTouch = true
                            hb.Anchored = true hb.Massless = true hb.Parent = workspace
                            State.HitboxPart = hb
                        end
                        State.HitboxPart.CFrame = CFrame.new(trp.Position)
                        AutoAttackNPC(target, 5)
                    end
                end
            end)
        end
    end
end)

-- KILL NEAREST
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
                if closest then AutoAttackNPC(closest, 3) end
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
                else task.wait(5) State.FirstRunChest = true State.UncheckedChests = {} end
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
                if boss then AutoAttackNPC(boss, 10) end
            end)
        end
    end
end)

-- SEA LOOP
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoFarmSea then
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
        if State.AutoCollectBone then
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "bone") then
                        if obj:FindFirstChild("TouchInterest") then
                            local hrp = GetHRP()
                            if hrp then TweenToPosition(obj.Position + Vector3.new(0,3,0), 400) end
                        end
                    end
                end
            end)
        end
        if State.AutoCollectDinoEgg then
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        local n = string.lower(obj.Name)
                        if (string.find(n, "dino") and string.find(n, "egg")) or string.find(n, "dinosaur") then
                            if obj:FindFirstChild("TouchInterest") then
                                local hrp = GetHRP()
                                if hrp then TweenToPosition(obj.Position + Vector3.new(0,3,0), 400) end
                            end
                        end
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
    end
end)

-- SEA EVENTS
local function ScanSeaEvent(keywords, attributes)
    for _, obj in ipairs(workspace:GetChildren()) do
        local name = string.lower(obj.Name)
        for _, kw in ipairs(keywords) do if string.find(name, kw) then return obj end end
        for _, attr in ipairs(attributes or {}) do if obj:GetAttribute(attr) == true then return obj end end
    end
    local seaFolder = workspace:FindFirstChild("SeaEvents")
    if seaFolder then
        for _, obj in ipairs(seaFolder:GetDescendants()) do
            local name = string.lower(obj.Name)
            for _, kw in ipairs(keywords) do if string.find(name, kw) then return obj end end
            for _, attr in ipairs(attributes or {}) do if obj:GetAttribute(attr) == true then return obj end end
        end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        local name = string.lower(obj.Name)
        for _, kw in ipairs(keywords) do 
            if string.find(name, kw) then
                if obj:IsA("BasePart") or obj:IsA("Model") then return obj end
            end
        end
        for _, attr in ipairs(attributes or {}) do 
            if obj:GetAttribute(attr) == true then
                if obj:IsA("BasePart") or obj:IsA("Model") then return obj end
            end
        end
    end
    return nil
end

local function GetPosition(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart.Position end
        local part = obj:FindFirstChildWhichIsA("BasePart", true)
        if part then return part.Position end
    end
    return nil
end

task.spawn(function()
    while task.wait(2) do
        pcall(function()
            local hrp = GetHRP()
            if not hrp then return end
            
            if State.FindFrozenDim then
                local frozen = ScanSeaEvent({"frozen", "frozendimension", "frozenwatcher", "leviathan"}, {"FrozenDimension", "FrozenDimensionSpawn", "Leviathan"})
                if frozen then
                    local pos = GetPosition(frozen)
                    if pos then
                        Notify("❄️ Frozen Dimension Spawned!")
                        TweenToPosition(pos + Vector3.new(0, 15, 0), 300)
                        task.wait(2)
                        for _, obj in ipairs(workspace:GetDescendants()) do
                            if obj:IsA("BasePart") or obj:IsA("Model") then
                                local n = string.lower(obj.Name)
                                if string.find(n, "watcher") or (string.find(n, "frozen") and string.find(n, "orb")) then
                                    local pp = obj:FindFirstChildOfClass("ProximityPrompt")
                                    if pp then
                                        pcall(function()
                                            pp:InputHoldBegin() task.wait(0.5) pp:InputHoldEnd()
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            if State.FindMirage or State.MirageTweenEnabled then
                local mirage = ScanSeaEvent({"mirage", "mirageisland"}, {"MirageIsland", "Mirage"})
                if mirage then
                    local pos = GetPosition(mirage)
                    if pos and (hrp.Position - pos).Magnitude > 20 then
                        Notify("🏝️ Mirage Spawned!")
                        TweenToPosition(pos + Vector3.new(0, 12, 0), 180)
                    end
                end
            end
            
            if State.FindKitsune then
                local kitsune = ScanSeaEvent({"kitsune", "kitsuneshrine", "kitsuneisland"}, {"KitsuneIsland", "KitsuneShrine"})
                if kitsune then
                    local pos = GetPosition(kitsune)
                    if pos then
                        local lvl = kitsune:GetAttribute("Level") or kitsune:GetAttribute("KitsuneLevel") or 0
                        if tonumber(lvl) >= (State.KitsuneLevel or 0) then
                            Notify("🦊 Kitsune Island Spawned! (Lv "..lvl..")")
                            TweenToPosition(pos + Vector3.new(0, 8, 0), 180)
                            State.FindKitsune = false
                        end
                    end
                end
            end
            
            if State.FindPrehistoric then
                local pre = ScanSeaEvent({"prehistoric", "prehistorichisland", "volcano", "dinoisland"}, {"PrehistoricIsland", "Volcano", "DragonTether"})
                if pre then
                    local pos = GetPosition(pre)
                    if pos then
                        Notify("🦖 Prehistoric Island Spawned!")
                        TweenToPosition(pos + Vector3.new(0, 10, 0), 180)
                        State.FindPrehistoric = false
                    end
                end
            end
        end)
    end
end)

-- AUTO DRIVE TIKI
task.spawn(function()
    while task.wait(2) do
        if State.AutoDriveTiki then
            pcall(function()
                local tiki = ScanSeaEvent({"tiki", "tikioutpost"}, {"TikiIsland"})
                local targetPos = GetPosition(tiki)
                if not targetPos then targetPos = Vector3.new(-1000, 60, 6000) end
                local hrp = GetHRP()
                if not hrp then return end
                local dist = (hrp.Position - targetPos).Magnitude
                if dist > 50 then
                    local boat = GetBoat()
                    if boat and boat.PrimaryPart then
                        local duration = math.max(dist / (State.BoatSpeed or 300), 0.5)
                        local tw = TweenService:Create(boat.PrimaryPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = CFrame.new(targetPos + Vector3.new(0, State.BoatHeight or 5, 0)) })
                        tw:Play()
                        tw.Completed:Wait()
                    else
                        TweenToPosition(targetPos + Vector3.new(0, 5, 0), 500)
                    end
                else
                    Notify("✅ Arrived at Tiki Outpost!")
                    State.AutoDriveTiki = false
                end
            end)
        end
    end
end)

-- FRUIT TWEEN
task.spawn(function()
    while task.wait(0.3) do
        if State.FruitTweenEnabled then
            pcall(function()
                local fruits = FindFruits()
                if #fruits > 0 then
                    local hrp = GetHRP()
                    if hrp then
                        local closest = fruits[1]
                        local cd = GetDist(fruits[1].part.Position, hrp.Position)
                        for _, f in ipairs(fruits) do
                            local d = GetDist(f.part.Position, hrp.Position)
                            if d < cd then closest = f cd = d end
                        end
                        if closest then
                            Notify("🍎 Fruit Spawn: "..closest.model.Name)
                            local dist = GetDist(closest.part.Position, hrp.Position)
                            local dur = math.max(dist / CONFIG.FruitTweenSpeed, 0.1)
                            local tw = TweenService:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), { CFrame = closest.part.CFrame * CFrame.new(0, 5, 0) })
                            tw:Play()
                            tw.Completed:Wait()
                            if State.FruitStoreEnabled then
                                task.wait(0.5)
                                local char = Player.Character
                                if char then
                                    for _, tool in ipairs(char:GetChildren()) do
                                        if tool:IsA("Tool") and tool.Name:find("Fruit") then
                                            local fruitName = tool.Name:gsub(" Fruit", "")
                                            if CommF then 
                                                pcall(function() CommF:InvokeServer("StoreFruit", fruitName, tool) end)
                                                Log("Stored: "..fruitName)
                                            end
                                            break
                                        end
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

-- AUTO STORE FRUIT
task.spawn(function()
    while task.wait(3) do
        if State.FruitStoreEnabled and CommF then
            pcall(function()
                local char = Player.Character
                if char then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") and tool.Name:find("Fruit") then
                            local fruitName = tool.Name:gsub(" Fruit", "")
                            CommF:InvokeServer("StoreFruit", fruitName, tool)
                            Log("Stored from Char: "..fruitName)
                        end
                    end
                end
                for _, tool in ipairs(Player.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name:find("Fruit") then
                        local fruitName = tool.Name:gsub(" Fruit", "")
                        CommF:InvokeServer("StoreFruit", fruitName, tool)
                        Log("Stored from Backpack: "..fruitName)
                        task.wait(0.5)
                    end
                end
            end)
        end
    end
end)

workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Tool") or obj:IsA("Model") then
        task.wait(0.1)
        if obj.Parent == workspace and string.find(obj.Name, "Fruit") then
            Notify("🍎 Fruit Spawn: "..obj.Name)
        end
    end
end)

task.spawn(function()
    while task.wait(60) do
        if State.AutoGacha then 
            pcall(function() if not GetHeldFruit() then Invoke("BuyFruit", "Random") end end) 
        end
    end
end)

task.spawn(function()
    while task.wait(10) do
        if State.AutoRaid and State.SelectedRaid then
            pcall(function()
                Invoke("RaidsNpc", "Select", State.SelectedRaid)
                task.wait(0.5)
                pcall(function() fireclickdetector(workspace.Map.CircleIsland.RaidSummon.Button.Main.ClickDetector) end)
                Log("Raid: "..State.SelectedRaid)
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if State.AutoAddStats then
            pcall(function()
                local stats = {
                    {Name="Melee",Value=State.StatsMelee},
                    {Name="Sword",Value=State.StatsSword},
                    {Name="Gun",Value=State.StatsGun},
                    {Name="Blox Fruit",Value=State.StatsBloxFruit}
                }
                for _, st in ipairs(stats) do if st.Value > 0 then Invoke("AddPoint", st.Name, st.Value) task.wait(0.3) end end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if State.AutoFish then
            pcall(function()
                local char = Player.Character
                if not char then return end
                local tool = char:FindFirstChildOfClass("Tool")
                if tool and string.find(string.lower(tool.Name), "rod") then
                    tool:Activate()
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(5) do
        if State.AutoRaceV2 and CommF then
            pcall(function()
                Invoke("Alchemist", "1")
                task.wait(1)
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        local n = string.lower(obj.Name)
                        if string.find(n, "flower") then
                            local hrp = GetHRP()
                            if hrp then 
                                TweenToPosition(obj.Position + Vector3.new(0,3,0), 300)
                                task.wait(0.5)
                            end
                        end
                    end
                end
                Invoke("Alchemist", "2")
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(5) do
        if State.AutoRaceV3 and CommF then
            pcall(function()
                Invoke("TalkTrevor", "1")
                task.wait(1)
                Invoke("Wenlocktoad", "1")
                task.wait(1)
                local prog = Invoke("Wenlocktoad", "2")
                Log("V3 Progress: "..tostring(prog))
                if prog == 2 or prog == 3 then
                    Invoke("Wenlocktoad", "2")
                    Notify("✅ Race V3 Complete!")
                    State.AutoRaceV3 = false
                end
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
                if hum and hum:GetState() == Enum.HumanoidStateType.Freefall then 
                    hum:ChangeState(Enum.HumanoidStateType.Jumping) 
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.05) do
        if State.BringMob or State.AutoFarm or State.AutoFarmNearest then
            local hrp = GetHRP()
            if hrp then
                local targetPos = hrp.Position + hrp.CFrame.LookVector * 4
                local range = State.BringMobRange or 50
                for _, model in ipairs(workspace:GetChildren()) do
                    if IsNPC(model) then
                        local mRoot = model:FindFirstChild("HumanoidRootPart")
                        local mHum = model:FindFirstChildOfClass("Humanoid")
                        if mRoot and mHum and mHum.Health > 0 then
                            local d = GetDist(mRoot.Position, hrp.Position)
                            if d <= range and d > 3 then
                                mRoot.CFrame = CFrame.new(targetPos)
                                mRoot.AssemblyLinearVelocity = Vector3.zero
                                mRoot.AssemblyAngularVelocity = Vector3.zero
                                pcall(function()
                                    mHum.WalkSpeed = 0
                                    mHum.JumpPower = 0
                                end)
                            end
                        end
                    end
                end
            end
        end
    end
end)

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
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and string.find(obj.Name, "Fruit") then
                    if obj.Parent == workspace or (obj.Parent and obj.Parent.Name == "Map") then
                        local dist = math.floor((obj.Position - myPos).Magnitude)
                        CreateESP(obj, dist.." | "..obj.Name, Color3.fromRGB(255,200,80))
                    end
                end
            end
        end
        if State.ESPChest then
            for _, obj in ipairs(getChestsSorted()) do
                local dist = math.floor((obj.Position - myPos).Magnitude)
                CreateESP(obj, dist.." | Chest", Color3.fromRGB(255,215,0))
            end
        end
        if State.ESPIsland then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = string.lower(obj.Name)
                    if string.find(n,"island") or string.find(n,"portal") then
                        local dist = math.floor((obj.Position - myPos).Magnitude)
                        CreateESP(obj, dist.." | "..obj.Name, Color3.fromRGB(80,200,255))
                    end
                end
            end
        end
        if State.ESPBlueGear then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = string.lower(obj.Name)
                    if string.find(n,"bluegear") or string.find(n,"gear") then
                        local dist = math.floor((obj.Position - myPos).Magnitude)
                        CreateESP(obj, dist.." | Blue Gear", Color3.fromRGB(0,150,255))
                    end
                end
            end
        end
        if State.ESPFlower then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = string.lower(obj.Name)
                    if string.find(n,"flower") or string.find(n,"petal") then
                        local dist = math.floor((obj.Position - myPos).Magnitude)
                        CreateESP(obj, dist.." | "..obj.Name, Color3.fromRGB(255,100,200))
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

-- TABS
local TabDefs = {
    {"Discord"}, {"Farm"}, {"Sea"}, {"Quest / Items"}, {"Fruit / Raid"},
    {"Fishing"}, {"Status"}, {"PvP"}, {"Trials"}, {"Seting"},
    {"Teleport"}, {"Stats"}, {"Shop"}, {"Misc"},
}
for i, d in ipairs(TabDefs) do
    local btn = CreateTab(d[1], i)
    btn.Activated:Connect(function() ShowTab(d[1]) end)
end

-- OPEN/CLOSE
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
print("   SYSX HUB | FREEMIUM v0.1")
print("   "..CONFIG.Build)
print("================================")

Notify("🚀 SysxHub v0.1 loaded")
return true
