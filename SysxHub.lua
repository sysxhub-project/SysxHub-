--[[
================================================================
 SYSX HUB | Freemium v0.1 (FINAL BUILD)
 + Game Lock (Blox Fruits Only)
 + Farm DB (Level 1-2800)
 + Factory Raid + Castle Raid
 + Material Config (Sea 1/2/3)
 + Farm Factory / Raid Castle / Bone / Material (Auto Sea)
 + Auto Sea Detection
 + Kitsune -> Azure
 + Emoji -> Text Icon
================================================================
]]

--============================================================
-- GAME LOCK
--============================================================
local RS = game:GetService("ReplicatedStorage")
local MPS = game:GetService("MarketplaceService")
local PlayersLock = game:GetService("Players")

local function IsBloxFruits()
    if game.PlaceId == 2753915549 then return true end
    if game.PlaceId == 4442272183 then return true end
    local remotes = RS:FindFirstChild("Remotes")
    if remotes and remotes:FindFirstChild("CommF_") then return true end
    local ok, info = pcall(function() return MPS:GetProductInfo(game.PlaceId) end)
    if ok and info and info.Name
        and string.find(string.lower(info.Name), "blox fruit") then
        return true
    end
    return false
end

if not IsBloxFruits() then
    local msg = "You're have kicked by Sysx Because this script only for BloxFruit"
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "SysxHub", Text = msg, Duration = 10,
        })
    end)
    task.wait(2)
    pcall(function() PlayersLock.LocalPlayer:Kick(msg) end)
    return warn("[SysxHub] "..msg)
end

--============================================================
-- SERVICES
--============================================================
local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")
local VirtualUser       = game:GetService("VirtualUser")
local TeleportService   = game:GetService("TeleportService")
local Lighting          = game:GetService("Lighting")

local Player    = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera    = Workspace.CurrentCamera

local LOGO_ID   = "rbxassetid://136425814447688"
local BANNER_ID = "rbxassetid://78771184763605"
local MAX_LEVEL = 2800

local CONFIG = {
    Build            = "SysxHub | Freemium Version | v0.1",
    Discord          = "https://discord.gg/E5kQJW3hn",
    TweenMobSpeed    = 400,
    IslandTweenSpeed = 300,
    FruitTweenSpeed  = 220,
    DangerTarget     = 6,
}

local State = {
    AutoFarm=false, AutoFarmNearest=false, AutoChest=false,
    AutoFarmFactory=false, AutoFarmRaidCastle=false,
    AutoFarmBone=false, AutoFarmMaterial=false,
    SelectedMaterial=nil,
    AutoBoss=false, AutoFish=false, AutoAddStats=false,
    SelectedWeapon=nil, SelectedCategory=nil, SelectedBoss=nil,
    FirstRunChest=true, UncheckedChests={},
    AutoFarmSea=false, AutoBuyBoat=false, AutoCollectBone=false,
    AutoCollectDinoEgg=false, AutoKillGolem=false,
    SelectedSeaMob="Sea Beast", SelectedBoat="Dinghy",
    BoatSpeed=500, BoatHeight=5,
    FindAzure=false, AzureLevel=0,
    FindPrehistoric=false, FindFrozenDim=false, FindMirage=false,
    MirageTweenEnabled=false, AutoDriveTiki=false,
    SeaEventAutoSail=false, _dangerLevel=0,
    FruitTweenEnabled=false, FruitStoreEnabled=true,
    AutoGacha=false, _fruitActive=nil,
    AutoRaid=false, SelectedRaid=nil,
    AutoRaceV2=false, AutoRaceV3=false,
    AutoTrialV4=false, AutoTrialOnly=false, AutoTrainV4=false,
    AutoPullLever=false, AutoFragment=false, EliteProgress=0,
    HakiActivated=false, HitboxPart=nil,
    Aimbot=false, SelectedPlayer=nil,
    BringMob=false, BringMobRange=50,
    InfiniteJump=false, BoostFPS=false, WalkWater=false,
    AntiAFK=true, Notifications=true,
    StatsMelee=0, StatsSword=0, StatsGun=0, StatsBloxFruit=0,
    ESPPlayer=false, ESPIsland=false, ESPFruit=false, ESPBlueGear=false,
    ESPChest=false, ESPFlower=false, ESPObjects={},
    SelectedMelee=nil, SelectedSword=nil, SelectedGun=nil,
    SelectedAbility=nil, SelectedIsland="Starter Island",
    OriginalLighting=nil,
}

--============================================================
-- HELPER
--============================================================
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
local function GetHRP()
    local c = Player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function GetDist(a,b) return (a-b).Magnitude end
local function Tween(o, props, time)
    TweenService:Create(o, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

--============================================================
-- REMOTE
--============================================================
local CommF = RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("CommF_")

local function Invoke(...)
    if not CommF then return nil end
    local ok, res = pcall(function(...) return CommF:InvokeServer(...) end, ...)
    if not ok then return nil end
    return res
end
local function InvokeAny(args)
    if not CommF then return nil end
    local names = args[1]
    if type(names) == "string" then names = {names} end
    local rest = {}
    for i = 2, #args do rest[#rest+1] = args[i] end
    for _, name in ipairs(names) do
        local ok, res = pcall(function()
            return CommF:InvokeServer(name, table.unpack(rest))
        end)
        if ok then return res end
    end
    return nil
end

--============================================================
-- NPC DETECTION
--============================================================
local PASSIVE = {
    "dealer","shop","vendor","merchant","quest","giver","bartender","chef",
    "captain","scientist","teacher","guide","trainer","banker","blacksmith",
    "smith","farmer","villager","elder"
}
local function IsNPC(m)
    if not m or m == Player.Character then return false end
    local hum = m:FindFirstChildOfClass("Humanoid")
    if not hum or not m:FindFirstChild("HumanoidRootPart") then return false end
    if Players:GetPlayerFromCharacter(m) then return false end
    if hum.Health <= 0 or hum.MaxHealth <= 0 or hum.WalkSpeed <= 0 then return false end
    local n = string.lower(m.Name)
    for _, kw in ipairs(PASSIVE) do
        if string.find(n, kw) then return false end
    end
    return true
end
local function FindBoss(name)
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name == name and obj:FindFirstChildOfClass("Humanoid") then
            return obj
        end
    end
    return nil
end
local function FindFruits()
    local list = {}
    for _, obj in ipairs(workspace:GetChildren()) do
        if (obj:IsA("Tool") or obj:IsA("Model")) and string.find(obj.Name, "Fruit") then
            local part = obj:IsA("Tool")
                and obj:FindFirstChildWhichIsA("BasePart")
                or (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true))
            if part then table.insert(list, {model=obj, part=part}) end
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

--============================================================
-- TWEEN
--============================================================
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
    local targetCF = CFrame.lookAt(
        targetPos + Vector3.new(0,8,0),
        targetPos + Vector3.new(0,8,0) + Vector3.new(lookVec.X, 0, lookVec.Z)
    )
    local duration = math.max(dist / CONFIG.IslandTweenSpeed, 0.2)
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    local oldAuto = hum and hum.AutoRotate
    if hum then hum.AutoRotate = false end
    local tw = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = targetCF })
    tw:Play()
    local conn = RunService.Heartbeat:Connect(function()
        if hrp and hrp.Parent then
            hrp.AssemblyLinearVelocity  = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end)
    tw.Completed:Wait()
    if conn then conn:Disconnect() end
    if hrp and hrp.Parent then
        hrp.CFrame = targetCF
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    if hum then hum.AutoRotate = oldAuto end
    return true
end

--============================================================
-- WEAPON & HITBOX
--============================================================
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
local function EnsureHitbox()
    if State.HitboxPart and State.HitboxPart.Parent then return State.HitboxPart end
    local hb = Instance.new("Part")
    hb.Name = "SysxHitbox" hb.Size = Vector3.new(30,30,30)
    hb.Transparency = 1 hb.CanCollide = false hb.CanTouch = true
    hb.Anchored = true hb.Massless = true hb.Parent = workspace
    State.HitboxPart = hb
    return hb
end
local function DestroyHitbox()
    if State.HitboxPart then
        pcall(function() State.HitboxPart:Destroy() end)
        State.HitboxPart = nil
    end
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
        if GetDist(hrp.Position, trp.Position) > 10 then
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

--============================================================
-- ESP / AIMBOT
--============================================================
local function CreateESP(target, text, color)
    if not target or not target:IsA("BasePart") then return end
    if State.ESPObjects[target] then
        local lbl = State.ESPObjects[target]:FindFirstChild("ESPLabel")
        if lbl then lbl.Text = text end
        return
    end
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
    for _, bb in pairs(State.ESPObjects) do pcall(function() bb:Destroy() end) end
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

--============================================================
-- WALK WATER
--============================================================
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
        if mat == Enum.Material.Water
            or string.find(name, "water")
            or string.find(name, "ocean")
            or string.find(name, "sea") then
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
                hrp.CFrame = CFrame.new(hrp.Position.X, targetY, hrp.Position.Z)
                    * CFrame.Angles(0, math.rad(hrp.Orientation.Y), 0)
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

--============================================================
-- HAKI
--============================================================
local function ActivateHakiOnce()
    if State.HakiActivated then return end
    local char = Player.Character
    if char and char:FindFirstChild("HasBuso") then
        State.HakiActivated = true
        return
    end
    if CommF then pcall(function() CommF:InvokeServer("Buso") end) task.wait(0.3) end
    State.HakiActivated = true
end

--============================================================
-- FAST ATTACK
--============================================================
task.spawn(function()
    for _, v in pairs(getreg()) do
        if typeof(v) == "function" then
            local ok, env = pcall(function() return getfenv(v).script end)
            if ok and env == Player.PlayerScripts:FindFirstChild("CombatFramework") then
                local ok2, upvals = pcall(function() return debug.getupvalues(v) end)
                if ok2 then
                    for _, upval in pairs(upvals) do
                        if typeof(upval) == "table" then
                            RunService.RenderStepped:Connect(function()
                                if State.AutoFarm or State.AutoFarmNearest
                                    or State.AutoFarmFactory or State.AutoFarmRaidCastle
                                    or State.AutoFarmBone or State.AutoFarmMaterial
                                    or State.AutoTrialV4 or State.AutoTrainV4 then
                                    pcall(function()
                                        upval.activeController.timeToNextAttack = -(math.huge^math.huge^math.huge)
                                        upval.activeController.attacking        = false
                                        upval.activeController.increment        = 4
                                        upval.activeController.blocking         = false
                                        upval.activeController.hitboxMagnitude  = 150
                                        upval.activeController.humanoid.AutoRotate = true
                                        upval.activeController.focusStart       = 0
                                        upval.activeController.currentAttackTrack = 0
                                    end)
                                end
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
        if State.AutoFarm or State.AutoFarmNearest
            or State.AutoFarmFactory or State.AutoFarmRaidCastle
            or State.AutoFarmBone or State.AutoFarmMaterial
            or State.AutoTrialV4 or State.AutoTrainV4 then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(0,1,0,1))
            end)
        end
    end)
end)

--============================================================
-- FARM DB
--============================================================
local FarmConfig = {
    {Min=1,   Max=9,   Sea=1, Island="Starter Island", Quest="Bandit Quest", Mob="Bandit"},
    {Min=10,  Max=14,  Sea=1, Island="Jungle", Quest="Monkey Quest", Mob="Monkey"},
    {Min=15,  Max=29,  Sea=1, Island="Jungle", Quest="Gorilla Quest", Mob="Gorilla"},
    {Min=30,  Max=39,  Sea=1, Island="Pirate Village", Quest="Pirate Quest", Mob="Pirate"},
    {Min=40,  Max=59,  Sea=1, Island="Pirate Village", Quest="Brute Quest", Mob="Brute"},
    {Min=60,  Max=74,  Sea=1, Island="Desert", Quest="Desert Bandit Quest", Mob="Desert Bandit"},
    {Min=75,  Max=89,  Sea=1, Island="Desert", Quest="Desert Officer Quest", Mob="Desert Officer"},
    {Min=90,  Max=99,  Sea=1, Island="Frozen Village", Quest="Snow Bandit Quest", Mob="Snow Bandit"},
    {Min=100, Max=104, Sea=1, Island="Frozen Village", Quest="Snowman Quest", Mob="Snowman"},
    {Min=105, Max=119, Sea=1, Island="Frozen Village", Quest="Yeti Quest", Mob="Yeti"},
    {Min=120, Max=129, Sea=1, Island="Marine Fortress", Quest="Chief Petty Officer Quest", Mob="Chief Petty Officer"},
    {Min=130, Max=149, Sea=1, Island="Marine Fortress", Quest="Vice Admiral Quest", Mob="Vice Admiral"},
    {Min=150, Max=174, Sea=1, Island="Skylands", Quest="Sky Bandit Quest", Mob="Sky Bandit"},
    {Min=175, Max=189, Sea=1, Island="Skylands", Quest="Dark Master Quest", Mob="Dark Master"},
    {Min=190, Max=209, Sea=1, Island="Prison", Quest="Prisoner Quest", Mob="Prisoner"},
    {Min=210, Max=224, Sea=1, Island="Prison", Quest="Dangerous Prisoner Quest", Mob="Dangerous Prisoner"},
    {Min=225, Max=249, Sea=1, Island="Prison", Quest="Chief Warden Quest", Mob="Chief Warden"},
    {Min=250, Max=274, Sea=1, Island="Colosseum", Quest="Toga Warrior Quest", Mob="Toga Warrior"},
    {Min=275, Max=299, Sea=1, Island="Colosseum", Quest="Gladiator Quest", Mob="Gladiator"},
    {Min=300, Max=324, Sea=1, Island="Magma Village", Quest="Military Soldier Quest", Mob="Military Soldier"},
    {Min=325, Max=374, Sea=1, Island="Magma Village", Quest="Military Spy Quest", Mob="Military Spy"},
    {Min=375, Max=399, Sea=1, Island="Magma Village", Quest="Military Spy Quest", Mob="Military Spy"},
    {Min=400, Max=449, Sea=1, Island="Underwater City", Quest="Fishman Warrior Quest", Mob="Fishman Warrior"},
    {Min=450, Max=474, Sea=1, Island="Underwater City", Quest="Fishman Commando Quest", Mob="Fishman Commando"},
    {Min=475, Max=524, Sea=1, Island="Fountain City", Quest="Galley Pirate Quest", Mob="Galley Pirate"},
    {Min=525, Max=599, Sea=1, Island="Fountain City", Quest="Galley Captain Quest", Mob="Galley Captain"},
    {Min=700, Max=724, Sea=2, Island="Kingdom of Rose", Quest="Raider Quest", Mob="Raider"},
    {Min=725, Max=774, Sea=2, Island="Kingdom of Rose", Quest="Mercenary Quest", Mob="Mercenary"},
    {Min=775, Max=799, Sea=2, Island="Kingdom of Rose", Quest="Swan Pirate Quest", Mob="Swan Pirate"},
    {Min=800, Max=874, Sea=2, Island="Kingdom of Rose", Quest="Factory Staff Quest", Mob="Factory Staff"},
    {Min=875, Max=899, Sea=2, Island="Green Zone", Quest="Marine Lieutenant Quest", Mob="Marine Lieutenant"},
    {Min=900, Max=949, Sea=2, Island="Green Zone", Quest="Marine Captain Quest", Mob="Marine Captain"},
    {Min=950, Max=974, Sea=2, Island="Graveyard", Quest="Zombie Quest", Mob="Zombie"},
    {Min=975, Max=999, Sea=2, Island="Graveyard", Quest="Vampire Quest", Mob="Vampire"},
    {Min=1000, Max=1049, Sea=2, Island="Snow Mountain", Quest="Snow Trooper Quest", Mob="Snow Trooper"},
    {Min=1050, Max=1099, Sea=2, Island="Snow Mountain", Quest="Winter Warrior Quest", Mob="Winter Warrior"},
    {Min=1100, Max=1124, Sea=2, Island="Hot and Cold", Quest="Lab Subordinate Quest", Mob="Lab Subordinate"},
    {Min=1125, Max=1174, Sea=2, Island="Hot and Cold", Quest="Horned Warrior Quest", Mob="Horned Warrior"},
    {Min=1175, Max=1199, Sea=2, Island="Hot and Cold", Quest="Magma Ninja Quest", Mob="Magma Ninja"},
    {Min=1200, Max=1249, Sea=2, Island="Hot and Cold", Quest="Lava Pirate Quest", Mob="Lava Pirate"},
    {Min=1250, Max=1274, Sea=2, Island="Cursed Ship", Quest="Ship Deckhand Quest", Mob="Ship Deckhand"},
    {Min=1275, Max=1299, Sea=2, Island="Cursed Ship", Quest="Ship Engineer Quest", Mob="Ship Engineer"},
    {Min=1300, Max=1324, Sea=2, Island="Cursed Ship", Quest="Ship Steward Quest", Mob="Ship Steward"},
    {Min=1325, Max=1349, Sea=2, Island="Cursed Ship", Quest="Ship Officer Quest", Mob="Ship Officer"},
    {Min=1350, Max=1374, Sea=2, Island="Ice Castle", Quest="Arctic Warrior Quest", Mob="Arctic Warrior"},
    {Min=1375, Max=1424, Sea=2, Island="Ice Castle", Quest="Snow Lurker Quest", Mob="Snow Lurker"},
    {Min=1425, Max=1474, Sea=2, Island="Forgotten Island", Quest="Sea Soldier Quest", Mob="Sea Soldier"},
    {Min=1475, Max=1499, Sea=2, Island="Forgotten Island", Quest="Water Fighter Quest", Mob="Water Fighter"},
    {Min=1500, Max=1524, Sea=3, Island="Port Town", Quest="Pirate Millionaire Quest", Mob="Pirate Millionaire"},
    {Min=1525, Max=1574, Sea=3, Island="Port Town", Quest="Pistol Billionaire Quest", Mob="Pistol Billionaire"},
    {Min=1575, Max=1599, Sea=3, Island="Hydra Island", Quest="Dragon Crew Warrior Quest", Mob="Dragon Crew Warrior"},
    {Min=1600, Max=1624, Sea=3, Island="Hydra Island", Quest="Dragon Crew Archer Quest", Mob="Dragon Crew Archer"},
    {Min=1625, Max=1649, Sea=3, Island="Great Tree", Quest="Marine Commodore Quest", Mob="Marine Commodore"},
    {Min=1650, Max=1699, Sea=3, Island="Great Tree", Quest="Marine Rear Admiral Quest", Mob="Marine Rear Admiral"},
    {Min=1700, Max=1724, Sea=3, Island="Floating Turtle", Quest="Fishman Raider Quest", Mob="Fishman Raider"},
    {Min=1725, Max=1774, Sea=3, Island="Floating Turtle", Quest="Fishman Captain Quest", Mob="Fishman Captain"},
    {Min=1775, Max=1799, Sea=3, Island="Floating Turtle", Quest="Forest Pirate Quest", Mob="Forest Pirate"},
    {Min=1800, Max=1824, Sea=3, Island="Floating Turtle", Quest="Mythological Pirate Quest", Mob="Mythological Pirate"},
    {Min=1825, Max=1849, Sea=3, Island="Haunted Castle", Quest="Reborn Skeleton Quest", Mob="Reborn Skeleton"},
    {Min=1850, Max=1899, Sea=3, Island="Haunted Castle", Quest="Living Zombie Quest", Mob="Living Zombie"},
    {Min=1900, Max=1924, Sea=3, Island="Haunted Castle", Quest="Demonic Soul Quest", Mob="Demonic Soul"},
    {Min=1925, Max=1974, Sea=3, Island="Haunted Castle", Quest="Soul Reaper Quest", Mob="Soul Reaper"},
    {Min=1975, Max=1999, Sea=3, Island="Sea of Treats", Quest="Candy Rebel Quest", Mob="Candy Rebel"},
    {Min=2000, Max=2024, Sea=3, Island="Sea of Treats", Quest="Sweet Thief Quest", Mob="Sweet Thief"},
    {Min=2025, Max=2049, Sea=3, Island="Sea of Treats", Quest="Sweet Thief Quest", Mob="Sweet Thief"},
    {Min=2050, Max=2074, Sea=3, Island="Sea of Treats", Quest="Candy Pirate Quest", Mob="Candy Pirate"},
    {Min=2075, Max=2099, Sea=3, Island="Sea of Treats", Quest="Snow Demon Quest", Mob="Snow Demon"},
    {Min=2100, Max=2124, Sea=3, Island="Chocolate Island", Quest="Cocoa Warrior Quest", Mob="Cocoa Warrior"},
    {Min=2125, Max=2149, Sea=3, Island="Chocolate Island", Quest="Chocolate Bar Battler Quest", Mob="Chocolate Bar Battler"},
    {Min=2150, Max=2174, Sea=3, Island="Chocolate Island", Quest="Sweet Thief Quest", Mob="Sweet Thief"},
    {Min=2175, Max=2200, Sea=3, Island="Cake Land", Quest="Cake Guard Quest", Mob="Cake Guard"},
    {Min=2200, Max=2224, Sea=3, Island="Cake Land", Quest="Baking Staff Quest", Mob="Baking Staff"},
    {Min=2225, Max=2250, Sea=3, Island="Cake Land", Quest="Head Baker Quest", Mob="Head Baker"},
    {Min=2250, Max=2274, Sea=3, Island="Cake Land", Quest="Cake Queen Quest", Mob="Cake Queen"},
    {Min=2275, Max=2299, Sea=3, Island="Ice Cream Island", Quest="Ice Cream Chef Quest", Mob="Ice Cream Chef"},
    {Min=2300, Max=2324, Sea=3, Island="Ice Cream Island", Quest="Ice Cream Commander Quest", Mob="Ice Cream Commander"},
    {Min=2325, Max=2349, Sea=3, Island="Peanut Island", Quest="Peanut Scout Quest", Mob="Peanut Scout"},
    {Min=2350, Max=2374, Sea=3, Island="Peanut Island", Quest="Peanut President Quest", Mob="Peanut President"},
    {Min=2375, Max=2399, Sea=3, Island="Cake Island", Quest="Cookie Crafter Quest", Mob="Cookie Crafter"},
    {Min=2400, Max=2424, Sea=3, Island="Cake Island", Quest="Cake Guard Quest", Mob="Cake Guard"},
    {Min=2425, Max=2449, Sea=3, Island="Cake Island", Quest="Baking Staff Quest", Mob="Baking Staff"},
    {Min=2450, Max=2474, Sea=3, Island="Cake Island", Quest="Head Baker Quest", Mob="Head Baker"},
    {Min=2475, Max=2499, Sea=3, Island="Tiki Outpost", Quest="Isle Champion Quest", Mob="Isle Champion"},
    {Min=2500, Max=2524, Sea=3, Island="Tiki Outpost", Quest="Kitsune Guard Quest", Mob="Kitsune Guard"},
    {Min=2525, Max=2549, Sea=3, Island="Tiki Outpost", Quest="Isle Outlaw Quest", Mob="Isle Outlaw"},
    {Min=2550, Max=2574, Sea=3, Island="Tiki Outpost", Quest="Island Empress Quest", Mob="Island Empress"},
    {Min=2575, Max=2599, Sea=3, Island="Tiki Outpost", Quest="Sun-kissed Warrior Quest", Mob="Sun-kissed Warrior"},
    {Min=2600, Max=2624, Sea=3, Island="Tiki Outpost", Quest="Sun-kissed Warrior Quest", Mob="Sun-kissed Warrior"},
    {Min=2625, Max=2649, Sea=3, Island="Tiki Outpost", Quest="Isle Champion Quest", Mob="Isle Champion"},
    {Min=2650, Max=2674, Sea=3, Island="Tiki Outpost", Quest="Isle Outlaw Quest", Mob="Isle Outlaw"},
    {Min=2675, Max=2699, Sea=3, Island="Tiki Outpost", Quest="Island Empress Quest", Mob="Island Empress"},
    {Min=2700, Max=2724, Sea=3, Island="Tiki Outpost", Quest="Kitsune Guard Quest", Mob="Kitsune Guard"},
    {Min=2725, Max=2749, Sea=3, Island="Tiki Outpost", Quest="Isle Champion Quest", Mob="Isle Champion"},
    {Min=2750, Max=2774, Sea=3, Island="Tiki Outpost", Quest="Isle Outlaw Quest", Mob="Isle Outlaw"},
    {Min=2775, Max=2800, Sea=3, Island="Tiki Outpost", Quest="Island Empress Quest", Mob="Island Empress"},
}

--============================================================
-- CASTLE RAID
--============================================================
local CastleRaid = {
    Name = "Castle Raid", Sea = 3, Island = "Castle on the Sea",
    Mobs = {
        "Galley Pirate","Galley Captain","Raider","Mercenary","Vampire",
        "Zombie","Snow Trooper","Winter Warrior","Lab Subordinate",
        "Horned Warrior","Magma Ninja","Lava Pirate","Ship Deckhand",
        "Ship Engineer","Ship Steward","Ship Officer","Arctic Warrior",
        "Snow Lurker","Sea Soldier",
    },
    MobLookup = {},
}
for _, mobName in ipairs(CastleRaid.Mobs) do CastleRaid.MobLookup[mobName] = true end
function CastleRaid:IsRaidMob(npc)
    if not npc then return false end
    return self.MobLookup[npc.Name] == true
end

--============================================================
-- FACTORY RAID
--============================================================
local FactoryRaid = {
    Name = "Factory Raid", Sea = 2, Island = "Kingdom of Rose",
    Target = "Factory",
    Mobs = { "Factory Staff" },
    MobLookup = {},
}
for _, mobName in ipairs(FactoryRaid.Mobs) do FactoryRaid.MobLookup[mobName] = true end
function FactoryRaid:IsRaidMob(npc)
    if not npc then return false end
    return self.MobLookup[npc.Name] == true
end

--============================================================
-- MATERIAL DB
--============================================================
local MaterialConfig = {
    {Name="Leather", Sea=1, Location="Pirate Village", NPC={"Pirate","Brute"}},
    {Name="Scrap Metal", Sea=1, Location="Pirate Village", NPC={"Pirate","Brute"}},
    {Name="Magma Ore", Sea=1, Location="Magma Village", NPC={"Military Soldier","Military Spy"}},
    {Name="Angel Wings", Sea=1, Location="Skylands", NPC={"God's Guard","Shanda"}},
    {Name="Fish Tail", Sea=1, Location="Underwater City", NPC={"Fishman Warrior","Fishman Commando"}},
    {Name="Radioactive Material", Sea=2, Location="Hot and Cold", NPC={"Factory Staff"}},
    {Name="Vampire Fang", Sea=2, Location="Graveyard", NPC={"Vampire"}},
    {Name="Ectoplasm", Sea=2, Location="Cursed Ship", NPC={"Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer"}},
    {Name="Mystic Droplet", Sea=2, Location="Forgotten Island", NPC={"Sea Soldier","Water Fighter"}},
    {Name="Mini Tusk", Sea=3, Location="Floating Turtle", NPC={"Mythological Pirate"}},
    {Name="Conjured Cocoa", Sea=3, Location="Sea of Treats", NPC={"Cocoa Warrior","Chocolate Bar Battler"}},
    {Name="Gunpowder", Sea=3, Location="Port Town", NPC={"Pistol Billionaire"}},
    {Name="Bones", Sea=3, Location="Haunted Castle", NPC={"Reborn Skeleton","Living Zombie","Demonic Soul","Possessed Mummy"}},
    {Name="Dragon Scale", Sea=3, Location="Hydra Island", NPC={"Dragon Crew Warrior","Dragon Crew Archer"}},
}
local MaterialByName = {}
for _, data in ipairs(MaterialConfig) do MaterialByName[data.Name] = data end
local function GetMaterialsBySea(sea)
    local result = {}
    for _, data in ipairs(MaterialConfig) do
        if data.Sea == sea then table.insert(result, data) end
    end
    table.sort(result, function(a,b) return a.Name < b.Name end)
    return result
end
local function GetMaterialNamesBySea(sea)
    local result = {}
    for _, data in ipairs(GetMaterialsBySea(sea)) do
        table.insert(result, data.Name)
    end
    return result
end
local function GetMaterialData(name, sea)
    local data = MaterialByName[name]
    if not data then return nil end
    if sea and data.Sea ~= sea then return nil end
    return data
end

--============================================================
-- MAP DATA
--============================================================
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
    ["Castle on the Sea"]=Vector3.new(-5500,30,-4000),["Haunted Castle"]=Vector3.new(-9500,100,5800),
    ["Sea of Treats"]=Vector3.new(-700,100,-11000),["Chocolate Island"]=Vector3.new(-700,100,-11000),
    ["Cake Land"]=Vector3.new(-700,100,-11000),["Ice Cream Island"]=Vector3.new(-700,100,-11000),
    ["Peanut Island"]=Vector3.new(-700,100,-11000),["Cake Island"]=Vector3.new(-700,100,-11000),
    ["Tiki Outpost"]=Vector3.new(-1000,60,6000),["Final Island"]=Vector3.new(0,100,0),
}
local BossDataBySea = {
    Sea1={"Gorilla King","Bobby","Yeti","Mob Leader","Vice Admiral","Saber Expert",
          "Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper",
          "Thunder God","Cyborg"},
    Sea2={"Diamond","Jeremy","Fajita","Don Swan","Darkbeard","Smoke Admiral",
          "Cursed Captain","Awakened Ice Admiral","Tide Keeper"},
    Sea3={"Stone","Island Empress","Kilo Admiral","Captain Elephant",
          "Beautiful Pirate","Longma","Cake Queen"},
}
local SeaIslands = {
    Sea1={"Starter Island","Jungle","Pirate Village","Desert","Frozen Village",
          "Marine Fortress","Skylands","Prison","Colosseum","Magma Village",
          "Underwater City","Fountain City"},
    Sea2={"Kingdom of Rose","Green Zone","Graveyard","Snow Mountain",
          "Hot and Cold","Cursed Ship","Ice Castle","Forgotten Island"},
    Sea3={"Port Town","Hydra Island","Great Tree","Floating Turtle",
          "Castle on the Sea","Haunted Castle","Sea of Treats","Tiki Outpost"},
}
local BoatDataBySea = {
    Sea1={"Dinghy","Sloop","Boat","Fishing Boat"},
    Sea2={"Guardian","Speed Boat","Miracle"},
    Sea3={"Sentinel","Beast Hunter","Shark Boat","Bizarre Boat"},
}
local RaidDataBySea = {
    Sea1={"Flame","Ice","Sand","Dark","Light"},
    Sea2={"Magma","Quake","Buddha","Love","Spider","Sound",
          "Phoenix","Portal","Rumble","Pain","Blizzard","Gravity"},
    Sea3={"Venom","Control","Spirit","Dragon","Leopard","Kitsune",
          "Dough","Mammoth","T-Rex"},
}
local MeleeList = {"Black Leg","Electro","Fishman Karate","Sharkman Karate",
    "Dragon Talon","Electric Claw","Death Step","Superhuman","Godhuman"}
local SwordList = {"Katana","Cutlass","Iron Mace","Dual Katana","Triple Katana","Pipe",
    "Small Sword","Dual-Headed Blade","Soul Cane","Saber","Rengoku",
    "Shisui","Yama","Tushita","Cursed Dual Katana","Dark Dagger",
    "Buddy Sword","Hallow Scythe","Spikey Trident","Trident"}
local GunList = {"Slingshot","Flintlock","Refined Flintlock","Musket","Refined Musket",
    "Cannon","Bazooka","Sniper","Kabucha","Acidum Rifle","Bizarre Rifle","Serpent Bow"}
local AbilityList = {"Ken","Buso","Geppo","Soru"}

--============================================================
-- LEVEL / SEA
--============================================================
local function GetLevel()
    local ls = Player:FindFirstChild("leaderstats")
    local lv = ls and ls:FindFirstChild("Level")
    return lv and lv.Value or 1
end
local function GetFarmData(level)
    level = tonumber(level) or 1
    for _, data in ipairs(FarmConfig) do
        if level >= data.Min and level <= data.Max then return data end
    end
    if level < 1 then return FarmConfig[1] end
    return FarmConfig[#FarmConfig]
end
local function GetSeaNumber()
    local data = GetFarmData(GetLevel())
    if data and data.Sea then return data.Sea end
    local level = GetLevel()
    if level >= 1500 then return 3
    elseif level >= 700 then return 2
    else return 1 end
end
local function GetCurrentSea()
    local s = GetSeaNumber()
    if s == 1 then return "Sea1"
    elseif s == 2 then return "Sea2"
    else return "Sea3" end
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

-- BOSS LIVE
local BossSpawnCache = {}
local BossScanCooldown = 0
local function ScanBosses()
    if tick() - BossScanCooldown < 2 then return BossSpawnCache end
    BossScanCooldown = tick()
    BossSpawnCache = {}
    for _, obj in ipairs(workspace:GetChildren()) do
        local hum = obj:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 and hum.MaxHealth >= 500 then
            if not Players:GetPlayerFromCharacter(obj) then
                local n = string.lower(obj.Name)
                local skip = false
                for _, kw in ipairs(PASSIVE) do
                    if string.find(n, kw) then skip = true break end
                end
                if not skip then BossSpawnCache[obj.Name] = obj end
            end
        end
    end
    return BossSpawnCache
end
local function GetBossListForSea(sea)
    local baseList = BossDataBySea[sea] or {}
    local spawned = ScanBosses()
    local live, offline = {}, {}
    for _, name in ipairs(baseList) do
        if spawned[name] then table.insert(live, name.." [LIVE]")
        else table.insert(offline, name) end
    end
    local result = {}
    for _, n in ipairs(live) do table.insert(result, n) end
    for _, n in ipairs(offline) do table.insert(result, n) end
    for name, _ in pairs(spawned) do
        local found = false
        for _, n in ipairs(baseList) do if n == name then found = true break end end
        if not found then table.insert(result, name.." [LIVE]") end
    end
    return result, #live
end

--============================================================
-- FRAGMENTS / CHEST
--============================================================
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
    return Player:GetAttribute("Fragments") or 0
end
local function DistanceFromPlrSort(list)
    local root = GetHRP()
    if not root then return end
    table.sort(list, function(a, b)
        return (root.Position - a.Position).Magnitude < (root.Position - b.Position).Magnitude
    end)
end
local function GetChestsSorted()
    if State.FirstRunChest then
        State.FirstRunChest = false
        State.UncheckedChests = {}
        for _, obj in ipairs(game:GetDescendants()) do
            if obj.ClassName == "Part" and obj.Name:find("Chest") then
                table.insert(State.UncheckedChests, obj)
            end
        end
    end
    local chests = {}
    for _, chest in ipairs(State.UncheckedChests) do
        if chest.Parent and chest:FindFirstChild("TouchInterest") then
            table.insert(chests, chest)
        end
    end
    DistanceFromPlrSort(chests)
    return chests
end

--============================================================
-- SEA EVENT SCANNER
--============================================================
local function ScanSeaEventBroad(keywords, attributeNames)
    for _, obj in ipairs(workspace:GetChildren()) do
        local name = string.lower(obj.Name)
        for _, kw in ipairs(keywords) do if string.find(name, kw) then return obj end end
        for _, attr in ipairs(attributeNames or {}) do
            local v = obj:GetAttribute(attr)
            if v == true or (type(v) == "number" and v > 0) then return obj end
        end
    end
    local sf = workspace:FindFirstChild("SeaEvents")
    if sf then
        for _, obj in ipairs(sf:GetDescendants()) do
            local name = string.lower(obj.Name)
            for _, kw in ipairs(keywords) do if string.find(name, kw) then return obj end end
            for _, attr in ipairs(attributeNames or {}) do
                local v = obj:GetAttribute(attr)
                if v == true or (type(v) == "number" and v > 0) then return obj end
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
local function GetDangerLevel()
    local lv = Player:GetAttribute("DangerLevel")
    if type(lv) == "number" then return lv end
    local ls = Player:FindFirstChild("leaderstats")
    if ls then
        local d = ls:FindFirstChild("Danger") or ls:FindFirstChild("DangerLevel")
        if d then return tonumber(d.Value) or 0 end
    end
    local rs = RS:GetAttribute("DangerLevel")
    if type(rs) == "number" then return rs end
    local hrp = GetHRP()
    if hrp then
        local tikiPos = Vector3.new(-1000, 60, 6000)
        local dist = (hrp.Position - tikiPos).Magnitude
        if dist < 500 then return 0
        elseif dist < 1500 then return 1
        elseif dist < 2500 then return 2
        elseif dist < 4000 then return 3
        elseif dist < 6000 then return 4
        elseif dist < 8000 then return 5
        else return 6 end
    end
    return 0
end

--============================================================
-- AUTO SAIL
--============================================================
local function EnsureOnBoat()
    local char = Player.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    if hum.SeatPart then
        local seat = hum.SeatPart
        local boat = seat:FindFirstAncestorWhichIsA("Model")
        if boat and boat:FindFirstChildWhichIsA("VehicleSeat", true) then return boat end
    end
    local boat = GetBoat()
    if not boat then return nil end
    local seat = boat:FindFirstChildWhichIsA("VehicleSeat", true)
    if not seat then return nil end
    local hrp = GetHRP()
    if hrp then
        hrp.CFrame = seat.CFrame * CFrame.new(0, 3, 0)
        task.wait(0.3)
        hum.Sit = true
        task.wait(0.3)
    end
    return boat
end
local function DriveBoatForward(boat)
    if not boat then return end
    local seat = boat:FindFirstChildWhichIsA("VehicleSeat", true)
    if not seat then return end
    pcall(function() seat.Throttle = 1 end)
    pcall(function() seat.Steer = 0 end)
end
local function AutoSailToDanger(targetDanger)
    targetDanger = targetDanger or CONFIG.DangerTarget
    local boat = EnsureOnBoat()
    if not boat then return false end
    local tikiPos = Vector3.new(-1000, 60, 6000)
    local startTime = tick()
    local timeout = 90
    while tick() - startTime < timeout do
        if not State.SeaEventAutoSail and not State.FindMirage
            and not State.FindAzure and not State.FindPrehistoric
            and not State.FindFrozenDim then return false end
        local hrp = GetHRP()
        if hrp then
            DriveBoatForward(boat)
            local danger = GetDangerLevel()
            State._dangerLevel = danger
            if danger >= targetDanger then
                pcall(function()
                    local seat = boat:FindFirstChildWhichIsA("VehicleSeat", true)
                    if seat then seat.Throttle = 0 end
                end)
                return true
            end
            local boatPos = boat.PrimaryPart and boat.PrimaryPart.Position or hrp.Position
            if (boatPos - tikiPos).Magnitude < 300 then
                pcall(function()
                    local seat = boat:FindFirstChildWhichIsA("VehicleSeat", true)
                    if seat then seat.Steer = 1 end
                end)
            end
        end
        task.wait(0.5)
    end
    return false
end

--============================================================
-- QUEST CHAIN
--============================================================
local QuestChain = { Running = false, ActiveType = nil }
local function StopChain() QuestChain.Running = false QuestChain.ActiveType = nil end
local function StartChain(t)
    if QuestChain.Running then return false end
    QuestChain.Running = true QuestChain.ActiveType = t
    return true
end

--============================================================
-- TRIAL V4
--============================================================
local function CheckV4Progress()
    local prog = InvokeAny({"RaceV4Progress","RaceV4","V4Progress"}, "Check")
    if type(prog) == "number" then return prog end
    return 0
end
local function V4Begin() InvokeAny({"RaceV4Progress","RaceV4","V4Progress"}, "Begin") end
local function V4Continue() InvokeAny({"RaceV4Progress","RaceV4","V4Progress"}, "Continue") end

local function KillTrialMobs(count, timeout)
    timeout = timeout or 60
    local killed = 0
    local startTime = tick()
    while killed < count and tick() - startTime < timeout do
        if not (State.AutoTrialV4 or State.AutoTrialOnly or State.AutoTrainV4) then break end
        local hrp = GetHRP()
        if hrp then
            local nearest, nd = nil, math.huge
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:FindFirstChildOfClass("Humanoid") then
                    local n = string.lower(obj.Name)
                    if string.find(n, "v4") or string.find(n, "fractal")
                        or string.find(n, "mirror") or string.find(n, "trial")
                        or string.find(n, "train") or string.find(n, "essence")
                        or string.find(n, "dojo") or string.find(n, "shadow") then
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
                if trp then hrp.CFrame = trp.CFrame * CFrame.new(0, 30, 0) task.wait(0.1) end
                AutoAttackNPC(nearest, 3)
                killed += 1
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
        if not (State.AutoTrialV4 or State.AutoTrainV4) then break end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "fragment")
                and obj:FindFirstChild("TouchInterest") then
                local hrp = GetHRP()
                if hrp then TweenToPosition(obj.Position + Vector3.new(0,3,0), 400) end
            end
        end
        task.wait(1)
    end
    return GetFragments() >= amount
end

--============================================================
-- NOTIF
--============================================================
local Gui
local function Notify(text)
    if not State.Notifications then return end
    if not Gui then return end
    local n = Gui:FindFirstChild("__notif")
    if not n then return end
    n.__tk = (n.__tk or 0) + 1
    local tk = n.__tk
    n.Text = tostring(text)
    n.Visible = true
    n.TextTransparency = 1
    n.BackgroundTransparency = 1
    Tween(n, {TextTransparency=0, BackgroundTransparency=0.05}, 0.2)
    task.delay(2.5, function()
        if tk ~= n.__tk then return end
        Tween(n, {TextTransparency=1, BackgroundTransparency=1}, 0.2)
        task.wait(0.2)
        if tk == n.__tk then n.Visible = false end
    end)
end

--============================================================
-- GUI BUILD
--============================================================
local old = PlayerGui:FindFirstChild("SysxHub")
if old then old:Destroy() end

Gui = Create("ScreenGui", {
    Name = "SysxHub", Parent = PlayerGui, ResetOnSpawn = false,
    IgnoreGuiInset = true, DisplayOrder = 999999,
    ZIndexBehavior = Enum.ZIndexBehavior.Global,
})

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

local Notification = Create("TextLabel", {
    Name = "__notif", Parent = Gui,
    AnchorPoint = Vector2.new(0.5,1),
    Position = UDim2.new(0.5,0,1,-20), Size = UDim2.fromOffset(340,44),
    BackgroundColor3 = Color3.fromRGB(17,13,29), BackgroundTransparency = 0.05,
    Text = "", TextColor3 = Color3.fromRGB(255,255,255), TextSize = 13,
    Font = Enum.Font.GothamMedium, Visible = false, ZIndex = 999999,
})
Corner(Notification, 10)
Stroke(Notification, Color3.fromRGB(0,150,255), 1.5, 0.3)

local LogoButton = Create("ImageButton", {
    Name = "SysxLogo", Parent = Gui,
    Size = UDim2.fromOffset(62,62), Position = UDim2.new(0,18,0.5,-31),
    BackgroundColor3 = Color3.fromRGB(8,14,28),
    BorderSizePixel = 0, Image = LOGO_ID, ScaleType = Enum.ScaleType.Fit,
    AutoButtonColor = false, ZIndex = 100,
})
Corner(LogoButton, 18)
local OS = Instance.new("UIStroke")
OS.Color = Color3.fromRGB(35,125,255) OS.Thickness = 1.5 OS.Transparency = 0.1 OS.Parent = LogoButton

local Main = Create("Frame", {
    Name = "Main", Parent = Gui,
    Size = UDim2.fromOffset(780,600), Position = UDim2.new(0.5,-390,0.5,-300),
    BackgroundColor3 = Color3.fromRGB(6,11,23),
    BorderSizePixel = 0, Visible = false, ClipsDescendants = true, ZIndex = 10,
})
Corner(Main, 18)
local MS = Instance.new("UIStroke")
MS.Color = Color3.fromRGB(38,100,190) MS.Thickness = 1.2 MS.Transparency = 0.25 MS.Parent = Main

local Header = Create("Frame", {
    Name = "Header", Parent = Main, Size = UDim2.new(1,0,0,82),
    BackgroundTransparency = 1, ZIndex = 20,
})
Create("ImageLabel", {
    Name = "Logo", Parent = Header, Size = UDim2.fromOffset(55,55),
    Position = UDim2.fromOffset(14,8), BackgroundTransparency = 1,
    Image = LOGO_ID, ScaleType = Enum.ScaleType.Fit, ZIndex = 22,
})
Create("TextLabel", {
    Parent = Header, BackgroundTransparency = 1,
    Position = UDim2.fromOffset(78,8), Size = UDim2.fromOffset(240,26),
    Text = "SysxHub", TextColor3 = Color3.fromRGB(235,242,255), TextSize = 22,
    Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 22,
})
local HeaderLevel = Create("TextLabel", {
    Parent = Header, BackgroundTransparency = 1,
    Position = UDim2.fromOffset(78,34), Size = UDim2.fromOffset(240,20),
    Text = "Lv: 1 | Sea 1", TextColor3 = Color3.fromRGB(120,200,255), TextSize = 12,
    Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 22,
})
task.spawn(function()
    while task.wait(1) do
        if not HeaderLevel.Parent then break end
        pcall(function()
            local lvl = GetLevel()
            local s = GetSeaNumber()
            HeaderLevel.Text = "Lv: "..lvl.." | Sea "..s
        end)
    end
end)

local CloseButton = Create("ImageButton", {
    Parent = Header, Size = UDim2.fromOffset(42,42),
    Position = UDim2.new(1,-58,0,14),
    BackgroundColor3 = Color3.fromRGB(23,18,38), BackgroundTransparency = 0.05,
    Image = LOGO_ID, ImageColor3 = Color3.fromRGB(255,255,255),
    ScaleType = Enum.ScaleType.Fit, AutoButtonColor = false, ZIndex = 25,
})
Corner(CloseButton, 10)
Stroke(CloseButton, Color3.fromRGB(0,150,255), 1.5, 0.25)
Create("Frame", {
    Parent = Header, Size = UDim2.new(1,0,0,1),
    Position = UDim2.new(0,0,1,-1),
    BackgroundColor3 = Color3.fromRGB(35,55,85),
    BackgroundTransparency = 0.35, BorderSizePixel = 0, ZIndex = 22,
})

local BannerHolder = Create("Frame", {
    Name = "BannerHolder", Parent = Main,
    Size = UDim2.new(1,-32,0,150), Position = UDim2.fromOffset(16,98),
    BackgroundColor3 = Color3.fromRGB(10,18,34),
    BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 12,
})
Corner(BannerHolder, 14)
Stroke(BannerHolder, Color3.fromRGB(35,95,175), 1, 0.25)
Create("ImageLabel", {
    Name = "Banner", Parent = BannerHolder,
    Size = UDim2.fromScale(1,1), Position = UDim2.fromScale(0,0),
    BackgroundTransparency = 1, Image = BANNER_ID,
    ScaleType = Enum.ScaleType.Crop, ZIndex = 12,
})
Create("Frame", {
    Name = "BannerOverlay", Parent = BannerHolder,
    Size = UDim2.fromScale(1,1),
    BackgroundColor3 = Color3.fromRGB(0,10,25),
    BackgroundTransparency = 0.72, BorderSizePixel = 0, ZIndex = 13,
})
local Content = Create("Frame", {
    Name = "Content", Parent = Main,
    Size = UDim2.new(1,-32,1,-264), Position = UDim2.fromOffset(16,256),
    BackgroundTransparency = 1, ZIndex = 14, ClipsDescendants = false,
})
local Sidebar = Create("Frame", {
    Parent = Content, BackgroundColor3 = Color3.fromRGB(17,13,29),
    Size = UDim2.new(0,140,1,0), BorderSizePixel = 0, ZIndex = 15,
})
Corner(Sidebar, 10)
Stroke(Sidebar, Color3.fromRGB(0,150,255), 1, 0.4)
local TabList = Create("ScrollingFrame", {
    Parent = Sidebar, BackgroundTransparency = 1,
    Position = UDim2.new(0,6,0,6), Size = UDim2.new(1,-12,1,-12),
    CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(0,150,255),
    BorderSizePixel = 0, ZIndex = 16,
})
local TL = Instance.new("UIListLayout")
TL.Padding = UDim.new(0,4) TL.SortOrder = Enum.SortOrder.LayoutOrder TL.Parent = TabList
local ContentScroll = Create("ScrollingFrame", {
    Parent = Content, BackgroundTransparency = 1,
    Position = UDim2.new(0,148,0,0), Size = UDim2.new(1,-148,1,0),
    CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(0,150,255),
    BorderSizePixel = 0, ZIndex = 14, ClipsDescendants = false,
})
local Pages, Tabs = {}, {}
local function CreatePage(name)
    local P = Create("ScrollingFrame", {
        Name = name, Parent = ContentScroll, BackgroundTransparency = 1,
        Position = UDim2.new(0,4,0,4), Size = UDim2.new(1,-8,1,-8),
        CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(0,150,255),
        BorderSizePixel = 0, Visible = false, ZIndex = 12, ClipsDescendants = false,
    })
    local L = Instance.new("UIListLayout")
    L.Padding = UDim.new(0,5) L.SortOrder = Enum.SortOrder.LayoutOrder L.Parent = P
    Pages[name] = P
    return P
end
local function CreateToggle(parent, text, default, cb)
    local S2 = default or false
    local B = Create("TextButton", {
        Parent = parent, BackgroundColor3 = Color3.fromRGB(17,13,29),
        Size = UDim2.new(1,0,0,38), Text = "", AutoButtonColor = false,
        BorderSizePixel = 0, ZIndex = 100,
    })
    Corner(B, 8) Stroke(B, Color3.fromRGB(0,150,255), 1.2, 0.4)
    Create("TextLabel", {
        Parent = B, BackgroundTransparency = 1,
        Position = UDim2.new(0,10,0,0), Size = UDim2.new(1,-60,1,0),
        Text = text, TextColor3 = Color3.fromRGB(255,255,255), TextSize = 12,
        Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 101,
    })
    local Ind = Create("Frame", {
        Parent = B, BackgroundColor3 = Color3.fromRGB(55,50,65),
        Size = UDim2.fromOffset(34,18), Position = UDim2.new(1,-44,0.5,-9), ZIndex = 101,
    })
    Corner(Ind, 20)
    local Dot = Create("Frame", {
        Parent = Ind, BackgroundColor3 = Color3.fromRGB(190,185,200),
        Size = UDim2.fromOffset(12,12), Position = UDim2.new(0,3,0.5,-6), ZIndex = 102,
    })
    Corner(Dot, 20)
    local function Update()
        if S2 then
            Ind.BackgroundColor3 = Color3.fromRGB(0,150,255)
            Dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
            Tween(Dot, {Position = UDim2.new(1,-15,0.5,-6)}, 0.15)
        else
            Ind.BackgroundColor3 = Color3.fromRGB(55,50,65)
            Dot.BackgroundColor3 = Color3.fromRGB(190,185,200)
            Tween(Dot, {Position = UDim2.new(0,3,0.5,-6)}, 0.15)
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
        Parent = parent, BackgroundColor3 = Color3.fromRGB(17,13,29),
        Size = UDim2.new(1,0,0,38), Text = text,
        TextColor3 = Color3.fromRGB(255,255,255), TextSize = 12,
        Font = Enum.Font.GothamMedium, AutoButtonColor = false,
        BorderSizePixel = 0, ZIndex = 100,
    })
    Corner(B, 8)
    Stroke(B, Color3.fromRGB(0,150,255), 1.2, 0.4)
    B.MouseEnter:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0,150,255)}):Play()
    end)
    B.MouseLeave:Connect(function()
        TweenService:Create(B, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(17,13,29)}):Play()
    end)
    B.Activated:Connect(function() if cb then pcall(cb) end end)
    return B
end
local function CreateDropdown(parent, title, options, cb)
    local Holder = Create("Frame", {
        Parent = parent, BackgroundColor3 = Color3.fromRGB(17,13,29),
        Size = UDim2.new(1,0,0,38), BorderSizePixel = 0, ZIndex = 100,
        ClipsDescendants = false,
    })
    Corner(Holder, 8) Stroke(Holder, Color3.fromRGB(0,150,255), 1.2, 0.4)
    local Selected = options[1] or "Select"
    local TitleLbl = Create("TextLabel", {
        Parent = Holder, BackgroundTransparency = 1,
        Position = UDim2.new(0,10,0,0), Size = UDim2.new(1,-35,1,0),
        Text = title..": "..Selected, TextColor3 = Color3.fromRGB(255,255,255),
        TextSize = 12, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 101,
    })
    Create("TextLabel", {
        Parent = Holder, BackgroundTransparency = 1,
        Position = UDim2.new(1,-22,0,0), Size = UDim2.new(0,18,1,0),
        Text = "v", TextColor3 = Color3.fromRGB(255,255,255), TextSize = 11,
        Font = Enum.Font.GothamBold, ZIndex = 101,
    })
    local clickBtn = Create("TextButton", {
        Parent = Holder, BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0), Text = "", AutoButtonColor = false, ZIndex = 110,
    })
    clickBtn.Activated:Connect(function()
        local popup = Create("Frame", {
            Parent = Gui, AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.new(0.5,0,0.5,0),
            Size = UDim2.fromOffset(300, math.min(#options*38+80, 400)),
            BackgroundColor3 = Color3.fromRGB(10,18,34),
            BorderSizePixel = 0, ZIndex = 999990,
        })
        Corner(popup, 12)
        local ps = Instance.new("UIStroke")
        ps.Color = Color3.fromRGB(0,150,255) ps.Thickness = 2 ps.Parent = popup
        Create("TextLabel", {
            Parent = popup, BackgroundTransparency = 1,
            Position = UDim2.fromOffset(15,10), Size = UDim2.new(1,-60,0,25),
            Text = title, TextColor3 = Color3.fromRGB(235,242,255),
            TextSize = 15, Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 999991,
        })
        local closeBtn = Create("TextButton", {
            Parent = popup, Position = UDim2.new(1,-40,0,10),
            Size = UDim2.fromOffset(30,25), Text = "x",
            TextColor3 = Color3.fromRGB(255,255,255), TextSize = 22,
            BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
            AutoButtonColor = false, ZIndex = 999992,
        })
        closeBtn.Activated:Connect(function() popup:Destroy() end)
        local ls = Create("ScrollingFrame", {
            Parent = popup, BackgroundTransparency = 1,
            Position = UDim2.fromOffset(10,42), Size = UDim2.new(1,-20,1,-52),
            CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(0,150,255),
            BorderSizePixel = 0, ZIndex = 999991,
        })
        local LL = Instance.new("UIListLayout")
        LL.Padding = UDim.new(0,4) LL.SortOrder = Enum.SortOrder.LayoutOrder LL.Parent = ls
        for i, opt in ipairs(options) do
            local OB = Create("TextButton", {
                Parent = ls, BackgroundColor3 = Color3.fromRGB(17,13,29),
                Size = UDim2.new(1,-8,0,34), Position = UDim2.new(0,4,0,0),
                Text = opt, TextColor3 = Color3.fromRGB(255,255,255),
                TextSize = 13, Font = Enum.Font.GothamMedium,
                AutoButtonColor = false, BorderSizePixel = 0,
                LayoutOrder = i, ZIndex = 999992,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            Corner(OB, 6)
            local pad = Instance.new("UIPadding") pad.PaddingLeft = UDim.new(0, 10) pad.Parent = OB
            OB.MouseEnter:Connect(function()
                TweenService:Create(OB, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0,150,255)}):Play()
            end)
            OB.MouseLeave:Connect(function()
                TweenService:Create(OB, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(17,13,29)}):Play()
            end)
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
    local Holder = Create("Frame", {
        Parent = parent, BackgroundColor3 = Color3.fromRGB(17,13,29),
        Size = UDim2.new(1,0,0,38), BorderSizePixel = 0, ZIndex = 100,
        ClipsDescendants = false,
    })
    Corner(Holder, 8) Stroke(Holder, Color3.fromRGB(0,150,255), 1.2, 0.4)
    local Selected = nil
    local TitleLbl = Create("TextLabel", {
        Parent = Holder, BackgroundTransparency = 1,
        Position = UDim2.new(0,10,0,0), Size = UDim2.new(1,-35,1,0),
        Text = title..": Loading...", TextColor3 = Color3.fromRGB(255,255,255),
        TextSize = 12, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 101,
    })
    Create("TextLabel", {
        Parent = Holder, BackgroundTransparency = 1,
        Position = UDim2.new(1,-22,0,0), Size = UDim2.new(0,18,1,0),
        Text = "v", TextColor3 = Color3.fromRGB(255,255,255), TextSize = 11,
        Font = Enum.Font.GothamBold, ZIndex = 101,
    })
    local clickBtn = Create("TextButton", {
        Parent = Holder, BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0), Text = "", AutoButtonColor = false, ZIndex = 110,
    })
    clickBtn.Activated:Connect(function()
        local sea, options = getOptionsFn()
        if type(sea) ~= "string" then sea = tostring(sea) end
        if type(options) ~= "table" or #options == 0 then
            Notify("[!] No options") return
        end
        local popup = Create("Frame", {
            Parent = Gui, AnchorPoint = Vector2.new(0.5,0.5),
            Position = UDim2.new(0.5,0,0.5,0),
            Size = UDim2.fromOffset(300, math.min(#options*38+80, 400)),
            BackgroundColor3 = Color3.fromRGB(10,18,34),
            BorderSizePixel = 0, ZIndex = 999990,
        })
        Corner(popup, 12)
        local ps = Instance.new("UIStroke")
        ps.Color = Color3.fromRGB(0,150,255) ps.Thickness = 2 ps.Parent = popup
        Create("TextLabel", {
            Parent = popup, BackgroundTransparency = 1,
            Position = UDim2.fromOffset(15,10), Size = UDim2.new(1,-60,0,25),
            Text = title.." ("..sea..")", TextColor3 = Color3.fromRGB(235,242,255),
            TextSize = 15, Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 999991,
        })
        local closeBtn = Create("TextButton", {
            Parent = popup, Position = UDim2.new(1,-40,0,10),
            Size = UDim2.fromOffset(30,25), Text = "x",
            TextColor3 = Color3.fromRGB(255,255,255), TextSize = 22,
            BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
            AutoButtonColor = false, ZIndex = 999992,
        })
        closeBtn.Activated:Connect(function() popup:Destroy() end)
        local ls = Create("ScrollingFrame", {
            Parent = popup, BackgroundTransparency = 1,
            Position = UDim2.fromOffset(10,42), Size = UDim2.new(1,-20,1,-52),
            CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3, ScrollBarImageColor3 = Color3.fromRGB(0,150,255),
            BorderSizePixel = 0, ZIndex = 999991,
        })
        local LL = Instance.new("UIListLayout")
        LL.Padding = UDim.new(0,4) LL.SortOrder = Enum.SortOrder.LayoutOrder LL.Parent = ls
        for i, opt in ipairs(options) do
            local OB = Create("TextButton", {
                Parent = ls, BackgroundColor3 = Color3.fromRGB(17,13,29),
                Size = UDim2.new(1,-8,0,34), Position = UDim2.new(0,4,0,0),
                Text = opt, TextColor3 = Color3.fromRGB(255,255,255),
                TextSize = 13, Font = Enum.Font.GothamMedium,
                AutoButtonColor = false, BorderSizePixel = 0,
                LayoutOrder = i, ZIndex = 999992,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            Corner(OB, 6)
            local pad = Instance.new("UIPadding") pad.PaddingLeft = UDim.new(0, 10) pad.Parent = OB
            OB.MouseEnter:Connect(function()
                TweenService:Create(OB, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0,150,255)}):Play()
            end)
            OB.MouseLeave:Connect(function()
                TweenService:Create(OB, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(17,13,29)}):Play()
            end)
            OB.Activated:Connect(function()
                Selected = opt
                TitleLbl.Text = title.." ("..sea.."): "..opt
                if cb then pcall(cb, opt) end
                popup:Destroy()
            end)
        end
    end)
    task.spawn(function()
        while task.wait(2) do
            if not TitleLbl.Parent then break end
            local sea, options = getOptionsFn()
            if type(sea) ~= "string" then sea = tostring(sea) end
            options = options or {}
            if not Selected or not table.find(options, Selected) then
                Selected = options[1]
                if cb and Selected then pcall(cb, Selected) end
            end
            TitleLbl.Text = title.." ("..sea.."): "..tostring(Selected or "-")
        end
    end)
    return Holder
end
local function CreateSlider(parent, title, minVal, maxVal, defaultVal, cb)
    local val = defaultVal or minVal
    local Holder = Create("Frame", {
        Parent = parent, BackgroundColor3 = Color3.fromRGB(17,13,29),
        Size = UDim2.new(1,0,0,46), BorderSizePixel = 0, ZIndex = 100,
    })
    Corner(Holder, 8) Stroke(Holder, Color3.fromRGB(0,150,255), 1.2, 0.4)
    Create("TextLabel", {
        Parent = Holder, BackgroundTransparency = 1,
        Position = UDim2.new(0,10,0,5), Size = UDim2.new(1,-70,0,14),
        Text = title, TextColor3 = Color3.fromRGB(255,255,255),
        TextSize = 11, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 101,
    })
    local ValueLbl = Create("TextLabel", {
        Parent = Holder, BackgroundTransparency = 1,
        Position = UDim2.new(1,-65,0,5), Size = UDim2.new(0,55,0,14),
        Text = tostring(val), TextColor3 = Color3.fromRGB(255,255,255),
        TextSize = 11, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 101,
    })
    local Bar = Create("Frame", {
        Parent = Holder, BackgroundColor3 = Color3.fromRGB(23,18,38),
        Position = UDim2.new(0,10,0,26), Size = UDim2.new(1,-20,0,7),
        BorderSizePixel = 0, ZIndex = 101,
    })
    Corner(Bar, 4)
    local Fill = Create("Frame", {
        Parent = Bar, BackgroundColor3 = Color3.fromRGB(0,150,255),
        Size = UDim2.new((val-minVal)/(maxVal-minVal),0,1,0),
        BorderSizePixel = 0, ZIndex = 102,
    })
    Corner(Fill, 4)
    local Btn = Create("TextButton", {
        Parent = Holder, BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0), Text = "", AutoButtonColor = false, ZIndex = 110,
    })
    local dragging = false
    local function Update(mouseX)
        local abs = Bar.AbsolutePosition
        local size = Bar.AbsoluteSize
        if size.X == 0 then return end
        local rel = math.clamp((mouseX-abs.X)/size.X, 0, 1)
        val = math.floor(minVal + (maxVal-minVal)*rel + 0.5)
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        ValueLbl.Text = tostring(val)
        if cb then pcall(cb, val) end
    end
    Btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true Update(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            Update(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return Holder
end
local function CreateLabel(parent, text, size)
    local L = Create("TextLabel", {
        Parent = parent, BackgroundColor3 = Color3.fromRGB(17,13,29),
        Size = UDim2.new(1,0,0,size or 34), Text = text,
        TextColor3 = Color3.fromRGB(255,255,255), TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        BorderSizePixel = 0, ZIndex = 100,
    })
    Corner(L, 8) Stroke(L, Color3.fromRGB(0,150,255), 1.2, 0.4)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 10) pad.PaddingTop = UDim.new(0, 6)
    pad.Parent = L
    return L
end
local function CreateTab(name, order)
    local B = Create("TextButton", {
        Parent = TabList, BackgroundColor3 = Color3.fromRGB(17,13,29),
        Size = UDim2.new(1,0,0,32), Text = "",
        AutoButtonColor = false, BorderSizePixel = 0,
        LayoutOrder = order, ZIndex = 17,
    })
    Corner(B, 7)
    local L = Create("TextLabel", {
        Parent = B, BackgroundTransparency = 1,
        Position = UDim2.new(0,8,0,0), Size = UDim2.new(1,-16,1,0),
        Text = name, TextColor3 = Color3.fromRGB(255,255,255),
        TextSize = 11, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 18,
    })
    Tabs[name] = {Button = B, Label = L}
    return B
end
local function ShowTab(name)
    for pn, p in pairs(Pages) do p.Visible = (pn == name) end
    for tn, d in pairs(Tabs) do
        if tn == name then
            d.Button.BackgroundColor3 = Color3.fromRGB(0,150,255)
        else
            d.Button.BackgroundColor3 = Color3.fromRGB(17,13,29)
        end
        d.Label.TextColor3 = Color3.fromRGB(255,255,255)
    end
end

--============================================================
-- PAGES
--============================================================
local DiscordPage     = CreatePage("Discord")
local FarmPage        = CreatePage("Farm")
local SeaPage         = CreatePage("Sea")
local QuestItemsPage  = CreatePage("Quest / Items")
local FruitRaidPage   = CreatePage("Fruit / Raid")
local FishingPage     = CreatePage("Fishing")
local StatusPage      = CreatePage("Status")
local PvPPage         = CreatePage("PvP")
local TrialsPage      = CreatePage("Trials")
local SetingPage      = CreatePage("Seting")
local TeleportPage    = CreatePage("Teleport")
local StatsPage       = CreatePage("Stats")
local ShopPage        = CreatePage("Shop")
local MiscPage        = CreatePage("Misc")

CreateButton(DiscordPage, "[CP] Copy Discord Link", function()
    if setclipboard then setclipboard(CONFIG.Discord) Notify("[OK] Discord Copied") end
end)

--============================================================
-- FARM PAGE
--============================================================
CreateDropdown(FarmPage, "Select Weapon Category",
    {"Melee","Sword","Gun","Fruit"},
    function(opt) State.SelectedCategory = opt end)
CreateToggle(FarmPage, "Auto Farm Level", false, function(s)
    State.AutoFarm = s
    if not s then DestroyHitbox() end
end)
CreateToggle(FarmPage, "Auto Farm Nearest", false, function(s)
    State.AutoFarmNearest = s
    if not s and not State.AutoFarm then DestroyHitbox() end
end)
CreateToggle(FarmPage, "Farm Chest", false, function(s)
    State.AutoChest = s
    if s then State.FirstRunChest = true State.UncheckedChests = {} end
end)
CreateToggle(FarmPage, "Farm Factory (Sea 2)", false, function(s)
    State.AutoFarmFactory = s
    if not s and not State.AutoFarmRaidCastle then DestroyHitbox() end
end)
CreateToggle(FarmPage, "Farm Raid Castle (Sea 3)", false, function(s)
    State.AutoFarmRaidCastle = s
    if not s and not State.AutoFarmFactory then DestroyHitbox() end
end)

CreateCustomDropdown(FarmPage, "Select Boss (Auto Sea)", function()
    local sea = GetCurrentSea()
    local list, live = GetBossListForSea(sea)
    local label = sea
    if live and live > 0 then label = sea.." | LIVE: "..live end
    return label, list
end, function(opt)
    State.SelectedBoss = (opt:gsub(" %[LIVE%]$", ""))
end)
CreateButton(FarmPage, "[LIVE] Teleport to Spawned Boss", function()
    local sea = GetCurrentSea()
    local list = GetBossListForSea(sea)
    for _, name in ipairs(list) do
        if string.find(name, "%[LIVE%]") then
            local realName = name:gsub(" %[LIVE%]$", "")
            local boss = FindBoss(realName)
            if boss then
                local trp = boss:FindFirstChild("HumanoidRootPart")
                if trp then
                    TweenToPosition(trp.Position + Vector3.new(0,3,0), 500)
                    Notify("[OK] Tween to "..realName)
                    return
                end
            end
        end
    end
    Notify("[X] No LIVE boss in "..sea)
end)
CreateToggle(FarmPage, "Auto Farm Boss", false, function(s) State.AutoBoss = s end)

CreateLabel(FarmPage, "Bones System", 34)
CreateToggle(FarmPage, "Farm Bone", false, function(s) State.AutoFarmBone = s end)
CreateButton(FarmPage, "[BONE] Random Bone", function()
    Invoke("Bones", "Buy", 1, 1) Notify("[OK] Bone Bought")
end)

CreateLabel(FarmPage, "Materials", 34)
CreateCustomDropdown(FarmPage, "Select Material (Auto Sea)", function()
    local sea = GetSeaNumber()
    local list = GetMaterialNamesBySea(sea)
    return "Sea "..sea, list
end, function(opt)
    State.SelectedMaterial = opt
end)
CreateToggle(FarmPage, "Farm Material", false, function(s)
    State.AutoFarmMaterial = s
    if not s and not State.AutoFarmBone then DestroyHitbox() end
end)

--============================================================
-- SEA PAGE
--============================================================
CreateDropdown(SeaPage, "Select Sea Mob",
    {"Sea Beast","Terrorshark","Shark","Piranha","Fish Crew Member","Fish Crew Warrior"},
    function(opt) State.SelectedSeaMob = opt end)
CreateCustomDropdown(SeaPage, "Select Boat", function()
    local sea = GetCurrentSea()
    return sea, BoatDataBySea[sea] or {"Dinghy"}
end, function(opt) State.SelectedBoat = opt end)
CreateToggle(SeaPage, "Auto Farm Sea", false, function(s) State.AutoFarmSea = s end)
CreateToggle(SeaPage, "Find Mirage", false, function(s) State.FindMirage = s end)
CreateToggle(SeaPage, "Tween Mirage", false, function(s) State.MirageTweenEnabled = s end)
CreateToggle(SeaPage, "Find Azure", false, function(s) State.FindAzure = s end)
CreateSlider(SeaPage, "Azure Level", 0, 300, 0, function(v) State.AzureLevel = v end)
CreateToggle(SeaPage, "Find Prehistoric", false, function(s) State.FindPrehistoric = s end)
CreateToggle(SeaPage, "Find Frozen Dimension", false, function(s) State.FindFrozenDim = s end)
CreateToggle(SeaPage, "Auto Sail (Danger 6)", false, function(s)
    State.SeaEventAutoSail = s
    if s then
        Notify("[OK] Auto Sail ON")
        task.spawn(function()
            while State.SeaEventAutoSail do
                local boat = GetBoat()
                if not boat then
                    Notify("[!] No boat")
                    State.AutoBuyBoat = true
                else
                    AutoSailToDanger(CONFIG.DangerTarget)
                end
                task.wait(3)
            end
        end)
    else
        Notify("[OK] Auto Sail OFF")
    end
end)
CreateToggle(SeaPage, "Auto Drive Tiki", false, function(s) State.AutoDriveTiki = s end)
CreateSlider(SeaPage, "Boat Speed", 0, 1000, 500, function(v) State.BoatSpeed = v end)
CreateSlider(SeaPage, "Boat Height", 0, 100, 5, function(v) State.BoatHeight = v end)
CreateButton(SeaPage, "[BOAT] Apply Boat Speed", function()
    local boat = GetBoat()
    if not boat then Notify("[X] Boat not found") return end
    local seat = boat:FindFirstChildWhichIsA("VehicleSeat", true)
    if not seat then Notify("[X] Seat not found") return end
    pcall(function() seat.MaxSpeed = State.BoatSpeed end)
    pcall(function() seat.Torque = State.BoatSpeed * 100 end)
    Notify("[OK] Boat Speed: "..State.BoatSpeed)
end)
CreateButton(SeaPage, "[UP] Apply Boat Height", function()
    local boat = GetBoat()
    if not boat or not boat.PrimaryPart then Notify("[X] Boat not found") return end
    pcall(function()
        boat.PrimaryPart.CFrame = boat.PrimaryPart.CFrame + Vector3.new(0, State.BoatHeight, 0)
    end)
    Notify("[OK] Height: "..State.BoatHeight)
end)
CreateToggle(SeaPage, "Auto Buy Boat", false, function(s) State.AutoBuyBoat = s end)
CreateToggle(SeaPage, "Auto Collect Bone", false, function(s) State.AutoCollectBone = s end)
CreateToggle(SeaPage, "Auto Collect Dino Egg", false, function(s) State.AutoCollectDinoEgg = s end)
CreateToggle(SeaPage, "Auto Kill Golem", false, function(s) State.AutoKillGolem = s end)

--============================================================
-- QUEST / ITEMS
--============================================================
CreateLabel(QuestItemsPage, "Sea Travel", 34)
CreateButton(QuestItemsPage, "[SEA] Travel Sea 2", function()
    Invoke("TravelDressrosa") Notify("[OK] Sea 2")
end)
CreateButton(QuestItemsPage, "[SEA] Travel Sea 3", function()
    Invoke("TravelZou") Notify("[OK] Sea 3")
end)
CreateLabel(QuestItemsPage, "Quest Chain", 34)
CreateToggle(QuestItemsPage, "Auto Get Saber", false, function(s)
    if s then if StartChain("Saber") then task.spawn(function()
        while QuestChain.Running and QuestChain.ActiveType == "Saber" do
            local prog = Invoke("ProQuestProgress")
            if type(prog) ~= "table" then task.wait(1) else
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
                elseif not prog.KilledMob then
                    Invoke("ProQuestProgress", "SickMan") task.wait(1)
                    Invoke("ProQuestProgress", "RichSon") task.wait(1)
                else
                    Notify("[WIN] Saber Complete!") StopChain() break
                end
            end
            task.wait(0.5)
        end
    end) end else StopChain() end
end)
CreateToggle(QuestItemsPage, "Auto Get CDK", false, function(s)
    if s then if StartChain("CDK") then task.spawn(function()
        while QuestChain.Running and QuestChain.ActiveType == "CDK" do
            if GetLevel() < 2200 then StopChain() break end
            InvokeAny({"ProQuestProgress","CDKQuest","CursedKatana"}, "CDK") task.wait(0.5)
            InvokeAny({"CDKQuest","CursedKatana","ProQuestProgress"}, "OpenDoor") task.wait(0.5)
            InvokeAny({"CDKQuest","CursedKatana","ProQuestProgress"}, "Progress") task.wait(0.5)
            InvokeAny({"CDKQuest","CursedKatana","ProQuestProgress"}, "BoatQuest") task.wait(3)
        end
    end) end else StopChain() end
end)
CreateToggle(QuestItemsPage, "Auto Get Tushita", false, function(s)
    if s then if StartChain("Tushita") then task.spawn(function()
        while QuestChain.Running and QuestChain.ActiveType == "Tushita" do
            InvokeAny({"ProQuestProgress","TushitaQuest"}, "Tushita") task.wait(3)
        end
    end) end else StopChain() end
end)
CreateToggle(QuestItemsPage, "Auto Get Soul Guitar", false, function(s)
    if s then if StartChain("SoulGuitar") then task.spawn(function()
        while QuestChain.Running and QuestChain.ActiveType == "SoulGuitar" do
            InvokeAny({"ProQuestProgress","SoulGuitarQuest"}, "SoulGuitar") task.wait(3)
        end
    end) end else StopChain() end
end)
CreateToggle(QuestItemsPage, "Auto Get Yama", false, function(s)
    if s then if StartChain("Yama") then task.spawn(function()
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
                            if string.find(n, "elitehunter") or string.find(n, "deandre")
                                or string.find(n, "diablo") or string.find(n, "urban") then
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
                            killed += 1 State.EliteProgress = killed
                        end
                    else
                        TweenToPosition(Vector3.new(2700, 60, 3000), 500) task.wait(2)
                    end
                end
                task.wait(0.3)
            end
            if killed >= 30 then Notify("[WIN] Yama Complete!") StopChain() break end
        end
    end) end else StopChain() end
end)
CreateToggle(QuestItemsPage, "Auto Get Dark Dagger", false, function(s)
    if s then if StartChain("DarkDagger") then task.spawn(function()
        while QuestChain.Running and QuestChain.ActiveType == "DarkDagger" do
            local char = Player.Character
            local hasChalice = (char and char:FindFirstChild("God's Chalice"))
                or Player.Backpack:FindFirstChild("God's Chalice")
            if not hasChalice then Notify("[X] Need God's Chalice!") StopChain() break end
            InvokeAny({"PlaceChalice","PlaceGodChalice"}, "God") task.wait(2)
            for _, obj in ipairs(workspace:GetChildren()) do
                if string.find(string.lower(obj.Name), "indra") then AutoAttackNPC(obj, 30) end
            end
            Notify("[DAGGER] Dark Dagger Complete") StopChain() break
        end
    end) end else StopChain() end
end)
CreateToggle(QuestItemsPage, "Auto Get Buddy Sword", false, function(s)
    if s then if StartChain("BuddySword") then task.spawn(function()
        while QuestChain.Running and QuestChain.ActiveType == "BuddySword" do
            local boss = FindBoss("Cake Queen")
            if boss then AutoAttackNPC(boss, 30) Notify("[WAR] Cake Queen") end
            task.wait(2)
        end
    end) end else StopChain() end
end)
CreateToggle(QuestItemsPage, "Auto Get Dough King", false, function(s)
    if s then if StartChain("DoughKing") then task.spawn(function()
        while QuestChain.Running and QuestChain.ActiveType == "DoughKing" do
            local char = Player.Character
            local hasSweet = (char and char:FindFirstChild("Sweet Chalice"))
                or Player.Backpack:FindFirstChild("Sweet Chalice")
            if not hasSweet then Notify("[X] Need Sweet Chalice!") StopChain() break end
            InvokeAny({"DoughKing","PlaceChalice","PlaceSweetChalice"}, "Sweet") task.wait(2)
            for _, obj in ipairs(workspace:GetChildren()) do
                local n = string.lower(obj.Name)
                if string.find(n, "dough") and string.find(n, "king") then AutoAttackNPC(obj, 30) end
            end
            Notify("[CROWN] Dough King Complete!") StopChain() break
        end
    end) end else StopChain() end
end)
CreateLabel(QuestItemsPage, "Race", 34)
CreateToggle(QuestItemsPage, "Auto Race V2", false, function(s) State.AutoRaceV2 = s end)
CreateToggle(QuestItemsPage, "Auto Race V3", false, function(s) State.AutoRaceV3 = s end)
CreateLabel(QuestItemsPage, "Event", 34)
CreateButton(QuestItemsPage, "[SKULL] Blackbeard Reward", function()
    Invoke("BlackbeardReward", "DragonClaw", "1") Notify("[OK] Blackbeard")
end)
CreateButton(QuestItemsPage, "[DICE] Horned Man Bet", function()
    Invoke("HornedMan", "Bet") Notify("[OK] Horned")
end)
CreateButton(QuestItemsPage, "[CHAT] Talk Trevor", function()
    Invoke("TalkTrevor", "1") Notify("[OK] Trevor")
end)
CreateButton(QuestItemsPage, "[X] Abandon Quest", function()
    Invoke("AbandonQuest") Notify("[OK] Abandoned")
end)

--============================================================
-- FRUIT / RAID
--============================================================
CreateToggle(FruitRaidPage, "Tween Fruit (Server-Fly-Store)", false, function(s)
    State.FruitTweenEnabled = s
    if not s then State._fruitActive = nil end
end)
CreateToggle(FruitRaidPage, "Auto Store Fruit", false, function(s) State.FruitStoreEnabled = s end)
CreateToggle(FruitRaidPage, "Random Fruit (Gacha)", false, function(s) State.AutoGacha = s end)
CreateCustomDropdown(FruitRaidPage, "Select Raid", function()
    local sea = GetCurrentSea()
    return sea, RaidDataBySea[sea] or {"Flame"}
end, function(opt) State.SelectedRaid = opt end)
CreateToggle(FruitRaidPage, "Auto Raid", false, function(s) State.AutoRaid = s end)

-- FISHING
CreateToggle(FishingPage, "Auto Fishing", false, function(s) State.AutoFish = s end)

--============================================================
-- STATUS
--============================================================
local StatusLabel = CreateLabel(StatusPage, "Loading...", 320)
StatusLabel.TextSize = 12

local function GetRace()
    return tostring(Player:GetAttribute("Race") or "Unknown")
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
    return tostring(Lighting:GetAttribute("MoonPhase")
        or workspace:GetAttribute("MoonPhase") or "?")
end
local function GetFruitSpawn()
    local fruits = {}
    for _, obj in ipairs(workspace:GetChildren()) do
        if (obj:IsA("Tool") or obj:IsA("Model")) and string.find(obj.Name, "Fruit") then
            table.insert(fruits, obj.Name)
        end
    end
    if #fruits == 0 then return "None" end
    return table.concat(fruits, ", ")
end
local function GetSeaEventSpawn(keyword, attribute)
    for _, obj in ipairs(workspace:GetChildren()) do
        if attribute and obj:GetAttribute(attribute) then return "[OK]" end
        if keyword and string.find(string.lower(obj.Name), keyword) then return "[OK]" end
    end
    local sf = workspace:FindFirstChild("SeaEvents")
    if sf then
        for _, obj in ipairs(sf:GetDescendants()) do
            if attribute and obj:GetAttribute(attribute) then return "[OK]" end
            if keyword and string.find(string.lower(obj.Name), keyword) then return "[OK]" end
        end
    end
    return "[X]"
end
local function GetBackpackFruitCount()
    local c = 0
    for _, t in ipairs(Player.Backpack:GetChildren()) do
        if t:IsA("Tool") and string.find(t.Name, "Fruit") then c += 1 end
    end
    local ch = Player.Character
    if ch then
        for _, t in ipairs(ch:GetChildren()) do
            if t:IsA("Tool") and string.find(t.Name, "Fruit") then c += 1 end
        end
    end
    return c
end

task.spawn(function()
    while task.wait(1) do
        if not StatusLabel.Parent then break end
        pcall(function()
            local s = GetSeaNumber()
            local farmData = GetFarmData(GetLevel())
            local farmStr = farmData and (farmData.Mob.." @ "..farmData.Island.." [Lv "..farmData.Min.."-"..farmData.Max.."]") or "MAX"
            local boss = State.SelectedBoss or "-"
            local mat = State.SelectedMaterial or "-"
            StatusLabel.Text = string.format(
                "--- PLAYER ---\n"..
                "Race      : %s\n"..
                "Level     : %d / %d\n"..
                "Melee     : %s\n"..
                "Fragments : %d\n"..
                "Elite Yama: %d/30\n"..
                "Danger    : %d\n"..
                "Backpack  : %d fruit\n\n"..
                "--- CURRENT AREA ---\n"..
                "Sea       : Sea %d\n"..
                "Farm Tgt  : %s\n"..
                "Boss Pick : %s\n"..
                "Material  : %s\n\n"..
                "--- SERVER ---\n"..
                "Moon   : %s\n"..
                "Fruit  : %s\n"..
                "Mirage : %s\n"..
                "Azure  : %s\n"..
                "Prehis : %s\n"..
                "Frozen : %s",
                GetRace(), GetLevel(), MAX_LEVEL, GetMelee(),
                GetFragments(), State.EliteProgress or 0,
                State._dangerLevel or GetDangerLevel(),
                GetBackpackFruitCount(),
                s, farmStr, boss, mat,
                GetMoonPhase(),
                GetFruitSpawn(),
                GetSeaEventSpawn("mirage", "MirageIsland"),
                GetSeaEventSpawn("azure", "AzureIsland"),
                GetSeaEventSpawn("prehistoric", "PrehistoricIsland"),
                GetSeaEventSpawn("frozen", "FrozenDimension")
            )
        end)
    end
end)

--============================================================
-- PVP
--============================================================
local PvPPlayerOptions = (function()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then table.insert(list, plr.Name) end
    end
    if #list == 0 then list = {"No players"} end
    return list
end)()
CreateDropdown(PvPPage, "Select Player", PvPPlayerOptions, function(opt) State.SelectedPlayer = opt end)
CreateToggle(PvPPage, "Aimbot", false, function(s)
    State.Aimbot = s
    if s then StartAimbot() else StopAimbot() end
end)

--============================================================
-- TRIALS
--============================================================
CreateLabel(TrialsPage, "Race V4 Trial System", 34)
local TrialStatusLabel = CreateLabel(TrialsPage, "RaceV4Progress: -", 34)
task.spawn(function()
    while task.wait(2) do
        if not TrialStatusLabel.Parent then break end
        local prog = CheckV4Progress()
        local stageText = "Unknown"
        if prog == 1 then stageText = "Trial 1"
        elseif prog == 2 then stageText = "Train 1 (x3+1000)"
        elseif prog == 3 then stageText = "Train 2 (x5+1500)"
        elseif prog == 4 then stageText = "Train 3 (x10)"
        elseif prog == 0 then stageText = "V4 Unlocked"
        end
        TrialStatusLabel.Text = "RaceV4Progress: "..tostring(prog).." ("..stageText..")"
    end
end)
CreateToggle(TrialsPage, "Auto Pull Lever", false, function(s)
    State.AutoPullLever = s
    if s then
        task.spawn(function()
            while State.AutoPullLever do
                pcall(function()
                    local hrp = GetHRP()
                    if not hrp then return end
                    local leverPos = Vector3.new(-12440, 550, -7100)
                    if (hrp.Position - leverPos).Magnitude > 20 then
                        TweenToPosition(leverPos, 300)
                    end
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") or obj:IsA("Model") then
                            local n = string.lower(obj.Name)
                            if string.find(n, "lever") or string.find(n, "pull")
                                or string.find(n, "handle") then
                                local part = obj:IsA("BasePart") and obj or obj.PrimaryPart
                                if part and (part.Position - leverPos).Magnitude < 300 then
                                    local pp = obj:FindFirstChildOfClass("ProximityPrompt")
                                        or obj:FindFirstChild("ProximityPrompt", true)
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
    if s then
        task.spawn(function()
            while State.AutoTrialOnly do
                pcall(function()
                    local prog = CheckV4Progress()
                    if prog == 1 then V4Begin() task.wait(1) end
                    KillTrialMobs(5, 30)
                    V4Continue()
                end)
                task.wait(3)
            end
        end)
    end
end)
CreateToggle(TrialsPage, "Auto Train V4", false, function(s)
    State.AutoTrainV4 = s
    if s then
        task.spawn(function()
            while State.AutoTrainV4 do
                pcall(function()
                    local prog = CheckV4Progress()
                    local tk, tf = 5, 1000
                    if prog == 2 then tk = 3  tf = 1000
                    elseif prog == 3 then tk = 5  tf = 1500
                    elseif prog == 4 then tk = 10 tf = 2500
                    else tk = 9 tf = 4000 end
                    KillTrialMobs(tk, 90)
                    WaitFragments(tf, 120)
                    V4Continue()
                    task.wait(2)
                end)
                task.wait(3)
            end
        end)
    end
end)
CreateToggle(TrialsPage, "Auto Trial V4 Complete", false, function(s)
    State.AutoTrialV4 = s
    if s then
        task.spawn(function()
            while State.AutoTrialV4 do
                pcall(function()
                    local prog = CheckV4Progress()
                    if prog == 1 then
                        TweenToPosition(Vector3.new(-12440, 550, -7100), 300)
                        task.wait(1) V4Begin() task.wait(2)
                        KillTrialMobs(5, 30) V4Continue()
                    elseif prog == 2 then
                        KillTrialMobs(3, 60) WaitFragments(1000, 90) V4Continue()
                    elseif prog == 3 then
                        KillTrialMobs(5, 90) WaitFragments(1500, 120) V4Continue()
                    elseif prog == 4 then
                        KillTrialMobs(10, 120) WaitFragments(2500, 150) V4Continue()
                    else
                        KillTrialMobs(9, 120) WaitFragments(4000, 180)
                        Notify("[WIN] Race V4 Complete!")
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
    if s then
        task.spawn(function()
            while State.AutoFragment do
                pcall(function()
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "fragment")
                            and obj:FindFirstChild("TouchInterest") then
                            local hrp = GetHRP()
                            if hrp then TweenToPosition(obj.Position + Vector3.new(0,3,0), 400) end
                        end
                    end
                end)
                task.wait(2)
            end
        end)
    end
end)

--============================================================
-- SETING (ESP)
--============================================================
CreateToggle(SetingPage, "ESP Player", false, function(s) State.ESPPlayer = s end)
CreateToggle(SetingPage, "ESP Fruit", false, function(s) State.ESPFruit = s end)
CreateToggle(SetingPage, "ESP Chest", false, function(s) State.ESPChest = s end)
CreateToggle(SetingPage, "ESP Island", false, function(s) State.ESPIsland = s end)
CreateToggle(SetingPage, "ESP Blue Gear", false, function(s) State.ESPBlueGear = s end)
CreateToggle(SetingPage, "ESP Flower", false, function(s) State.ESPFlower = s end)

--============================================================
-- TELEPORT
--============================================================
CreateCustomDropdown(TeleportPage, "Select Island (Auto Sea)", function()
    local sea = GetCurrentSea()
    return sea, SeaIslands[sea] or {"Starter Island"}
end, function(opt) State.SelectedIsland = opt end)
CreateButton(TeleportPage, "[POS] Tween ke Island", function()
    local pos = IslandCoords[State.SelectedIsland]
    if pos then
        TweenToIslandSmooth(pos + Vector3.new(0,3,0))
        Notify("[OK] Tween: "..State.SelectedIsland)
    else
        Notify("[X] Koordinat tidak ditemukan")
    end
end)
CreateButton(TeleportPage, "[SEA] Travel Sea 1", function() Invoke("TravelMain") Notify("[OK] Sea 1") end)
CreateButton(TeleportPage, "[SEA] Travel Sea 2", function() Invoke("TravelDressrosa") Notify("[OK] Sea 2") end)
CreateButton(TeleportPage, "[SEA] Travel Sea 3", function() Invoke("TravelZou") Notify("[OK] Sea 3") end)

--============================================================
-- STATS
--============================================================
CreateToggle(StatsPage, "Auto Add Stats", false, function(s) State.AutoAddStats = s end)
CreateSlider(StatsPage, "Melee", 0, 100, 0, function(v) State.StatsMelee = v end)
CreateSlider(StatsPage, "Sword", 0, 100, 0, function(v) State.StatsSword = v end)
CreateSlider(StatsPage, "Gun",   0, 100, 0, function(v) State.StatsGun = v end)
CreateSlider(StatsPage, "Fruit", 0, 100, 0, function(v) State.StatsBloxFruit = v end)
CreateButton(StatsPage, "[OK] Apply Stats Now", function()
    local stats = {
        {Name="Melee",Value=State.StatsMelee},
        {Name="Sword",Value=State.StatsSword},
        {Name="Gun",Value=State.StatsGun},
        {Name="Blox Fruit",Value=State.StatsBloxFruit},
    }
    for _, st in ipairs(stats) do
        if st.Value > 0 then Invoke("AddPoint", st.Name, st.Value) task.wait(0.3) end
    end
    Notify("[OK] Stats applied")
end)

--============================================================
-- SHOP
--============================================================
CreateDropdown(ShopPage, "Select Melee", MeleeList, function(opt) State.SelectedMelee = opt end)
CreateButton(ShopPage, "[BUY] Buy Selected Melee", function()
    if not State.SelectedMelee then Notify("[!] Select melee first") return end
    local map = {
        ["Black Leg"]="BuyBlackLeg",["Electro"]="BuyElectro",
        ["Fishman Karate"]="BuyFishmanKarate",["Sharkman Karate"]="BuySharkmanKarate",
        ["Dragon Talon"]="BuyDragonTalon",["Electric Claw"]="BuyElectricClaw",
        ["Death Step"]="BuyDeathStep",["Superhuman"]="BuySuperhuman",
        ["Godhuman"]="BuyGodhuman",
    }
    local fn = map[State.SelectedMelee]
    if fn then
        InvokeAny({fn, "BuyFightingStyle", "BuyItem"}, State.SelectedMelee)
        Notify("[BUY] "..State.SelectedMelee)
    end
end)
CreateDropdown(ShopPage, "Select Sword", SwordList, function(opt) State.SelectedSword = opt end)
CreateButton(ShopPage, "[BUY] Buy Selected Sword", function()
    if State.SelectedSword then
        InvokeAny({"BuyItem","BuyWeapon","BuySword"}, State.SelectedSword)
        Notify("[BUY] "..State.SelectedSword)
    end
end)
CreateDropdown(ShopPage, "Select Gun", GunList, function(opt) State.SelectedGun = opt end)
CreateButton(ShopPage, "[BUY] Buy Selected Gun", function()
    if State.SelectedGun then
        InvokeAny({"BuyItem","BuyWeapon","BuyGun"}, State.SelectedGun)
        Notify("[BUY] "..State.SelectedGun)
    end
end)
CreateDropdown(ShopPage, "Select Ability", AbilityList, function(opt) State.SelectedAbility = opt end)
CreateButton(ShopPage, "[BUY] Buy Selected Ability", function()
    if State.SelectedAbility == "Ken" then InvokeAny({"KenTalk","Ken"}, "Buy")
    elseif State.SelectedAbility == "Buso" then InvokeAny({"BuyHaki","BuyAbility"}, "Buso")
    elseif State.SelectedAbility == "Geppo" then InvokeAny({"BuyHaki","BuyAbility"}, "Geppo")
    elseif State.SelectedAbility == "Soru" then InvokeAny({"BuyHaki","BuyAbility"}, "Soru")
    end
    Notify("[BUY] "..tostring(State.SelectedAbility))
end)
CreateButton(ShopPage, "[BUY] Buy Stat Refund", function()
    Invoke("Bones", "Buy", 1, 2) Notify("[BUY] Stat Refund")
end)
CreateButton(ShopPage, "[BUY] Buy Race Reroll", function()
    Invoke("Bones", "Buy", 1, 3) Notify("[BUY] Race Reroll")
end)

--============================================================
-- MISC
--============================================================
CreateToggle(MiscPage, "Anti AFK", true, function(s) State.AntiAFK = s end)
CreateToggle(MiscPage, "Bring Mob", false, function(s) State.BringMob = s end)
CreateSlider(MiscPage, "Bring Mob Range", 0, 100, 50, function(v) State.BringMobRange = v end)
CreateToggle(MiscPage, "Infinite Jump", false, function(s) State.InfiniteJump = s end)
CreateToggle(MiscPage, "Walk On Water", false, function(s)
    State.WalkWater = s
    if s then EnableWalkWater() else DisableWalkWater() end
end)
CreateToggle(MiscPage, "Boost FPS", false, function(s)
    State.BoostFPS = s
    if s then
        pcall(function()
            State.OriginalLighting = {
                GlobalShadows = Lighting.GlobalShadows,
                Brightness    = Lighting.Brightness,
                Ambient       = Lighting.Ambient,
                FogEnd        = Lighting.FogEnd,
                Outlines      = Lighting.Outlines,
            }
            Lighting.GlobalShadows = false
            Lighting.Brightness    = 0
            Lighting.Ambient       = Color3.fromRGB(0,0,0)
            Lighting.FogEnd        = 100
            Lighting.Outlines      = false
        end)
        Notify("[PWR] Boost FPS ON")
    else
        if State.OriginalLighting then
            pcall(function()
                Lighting.GlobalShadows = State.OriginalLighting.GlobalShadows
                Lighting.Brightness    = State.OriginalLighting.Brightness
                Lighting.Ambient       = State.OriginalLighting.Ambient
                Lighting.FogEnd        = State.OriginalLighting.FogEnd
                Lighting.Outlines      = State.OriginalLighting.Outlines
            end)
        end
        Notify("[PWR] Boost FPS OFF")
    end
end)
CreateButton(MiscPage, "[ANC] Join Marine", function()
    Invoke("SetTeam", "Marines") Notify("[OK] Marines")
end)
CreateButton(MiscPage, "[PIR] Join Pirate", function()
    Invoke("SetTeam", "Pirates") Notify("[OK] Pirates")
end)
CreateButton(MiscPage, "[GIFT] Redeem All Codes", function()
    local codes = {
        "KITT_RESET","SUB2GAMERROBOT_RESET1","SUB2GAMERROBOT_EXP1",
        "SUB2OFFICIALNOOBIE","AXIORE","BLUXXY","JCWK","KITTGAMING",
        "MAGICBUS","STARCODEHEO","STRAWHATMAINE","TANTAIGAMING",
        "THEGREATACE","ENYU_IS_PRO","FUDD10","FUDD10_V2",
        "BIGNEWS","CHANDLER","SECRET_ADMIN","ADMIN_MELEE","ADMIN_MELEE2",
        "REWARD_BOOSTS","BOOSTS_REWARD","DEVSCOOKING","FIBER",
        "SUB2NOOBMASTER123","SECRET_DEV",
    }
    for _, code in ipairs(codes) do Invoke("Redeem", code) task.wait(1) end
    Notify("[GIFT] All codes redeemed")
end)
CreateButton(MiscPage, "[RE] Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId, Player)
end)

--============================================================
-- MAIN LOOPS
--============================================================

-- FARM LEVEL
task.spawn(function()
    while task.wait(0.2) do
        if State.AutoFarm then
            local level = GetLevel()
            if level >= MAX_LEVEL then
                State.AutoFarm = false DestroyHitbox()
                Notify("[WIN] MAX LEVEL!")
            else
                local data = GetFarmData(level)
                if data then
                    Invoke("StartQuest", data.Quest)
                    ActivateHakiOnce()
                    local hrp = GetHRP()
                    if hrp then
                        local nearest, nd = nil, math.huge
                        local folders = {}
                        local ef = workspace:FindFirstChild("Enemies")
                        if ef then table.insert(folders, ef) end
                        local nf = workspace:FindFirstChild("NPCs")
                        if nf then table.insert(folders, nf) end
                        table.insert(folders, workspace)
                        for _, folder in ipairs(folders) do
                            if nearest then break end
                            for _, obj in ipairs(folder:GetChildren()) do
                                if obj.Name == data.Mob
                                    and obj:FindFirstChildOfClass("Humanoid") then
                                    local hum = obj:FindFirstChildOfClass("Humanoid")
                                    local trp = obj:FindFirstChild("HumanoidRootPart")
                                    if hum and trp and hum.Health > 0 then
                                        local d = GetDist(trp.Position, hrp.Position)
                                        if d < nd then nearest, nd = obj, d end
                                    end
                                end
                            end
                        end
                        if nearest then
                            local trp = nearest:FindFirstChild("HumanoidRootPart")
                            if trp then
                                if GetDist(hrp.Position, trp.Position) > 15 then
                                    TweenToPosition(trp.Position + Vector3.new(0,3,0), CONFIG.TweenMobSpeed)
                                end
                                EnsureHitbox().CFrame = CFrame.new(trp.Position)
                                AutoAttackNPC(nearest, 5)
                            end
                        else
                            local islandPos = IslandCoords[data.Island]
                            if islandPos and (hrp.Position - islandPos).Magnitude > 500 then
                                TweenToPosition(islandPos + Vector3.new(0,3,0), 500)
                            else
                                task.wait(0.5)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- FARM NEAREST
task.spawn(function()
    while task.wait(0.15) do
        if State.AutoFarmNearest then
            if GetLevel() >= MAX_LEVEL then
                State.AutoFarmNearest = false DestroyHitbox()
            else
                ActivateHakiOnce()
                local target = GetNearestEnemy(500)
                if target then
                    local hrp = GetHRP()
                    local trp = target:FindFirstChild("HumanoidRootPart")
                    if hrp and trp then
                        if GetDist(hrp.Position, trp.Position) > 15 then
                            TweenToPosition(trp.Position + Vector3.new(0,3,0), CONFIG.TweenMobSpeed)
                        end
                        EnsureHitbox().CFrame = CFrame.new(trp.Position)
                        AutoAttackNPC(target, 5)
                    end
                end
            end
        end
    end
end)

-- CHEST
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoChest then
            local chests = GetChestsSorted()
            if #chests > 0 then
                TweenToPosition(chests[1].Position + Vector3.new(0,3,0), 400)
                task.wait(0.2)
            else
                task.wait(5)
                State.FirstRunChest = true
                State.UncheckedChests = {}
            end
        end
    end
end)

-- FARM FACTORY
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoFarmFactory then
            pcall(function()
                ActivateHakiOnce()
                local hrp = GetHRP()
                if not hrp then return end
                local folder = workspace:FindFirstChild("Enemies")
                local nearest, nd = nil, math.huge
                if folder then
                    for _, obj in ipairs(folder:GetChildren()) do
                        if FactoryRaid:IsRaidMob(obj) then
                            local trp = obj:FindFirstChild("HumanoidRootPart")
                            local hum = obj:FindFirstChildOfClass("Humanoid")
                            if trp and hum and hum.Health > 0 then
                                local d = GetDist(trp.Position, hrp.Position)
                                if d < nd then nearest, nd = obj, d end
                            end
                        end
                    end
                end
                if nearest then
                    local trp = nearest:FindFirstChild("HumanoidRootPart")
                    if trp then
                        if GetDist(hrp.Position, trp.Position) > 15 then
                            TweenToPosition(trp.Position + Vector3.new(0,3,0), CONFIG.TweenMobSpeed)
                        end
                        EnsureHitbox().CFrame = CFrame.new(trp.Position)
                        AutoAttackNPC(nearest, 5)
                    end
                else
                    local islandPos = IslandCoords[FactoryRaid.Island]
                    if islandPos and (hrp.Position - islandPos).Magnitude > 500 then
                        TweenToPosition(islandPos + Vector3.new(0,3,0), 500)
                    else
                        task.wait(0.5)
                    end
                end
            end)
        end
    end
end)

-- FARM RAID CASTLE
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoFarmRaidCastle then
            pcall(function()
                ActivateHakiOnce()
                local hrp = GetHRP()
                if not hrp then return end
                local folder = workspace:FindFirstChild("Enemies")
                local nearest, nd = nil, math.huge
                if folder then
                    for _, obj in ipairs(folder:GetChildren()) do
                        if CastleRaid:IsRaidMob(obj) then
                            local trp = obj:FindFirstChild("HumanoidRootPart")
                            local hum = obj:FindFirstChildOfClass("Humanoid")
                            if trp and hum and hum.Health > 0 then
                                local d = GetDist(trp.Position, hrp.Position)
                                if d < nd then nearest, nd = obj, d end
                            end
                        end
                    end
                end
                if nearest then
                    local trp = nearest:FindFirstChild("HumanoidRootPart")
                    if trp then
                        if GetDist(hrp.Position, trp.Position) > 15 then
                            TweenToPosition(trp.Position + Vector3.new(0,3,0), CONFIG.TweenMobSpeed)
                        end
                        EnsureHitbox().CFrame = CFrame.new(trp.Position)
                        AutoAttackNPC(nearest, 5)
                    end
                else
                    local islandPos = IslandCoords[CastleRaid.Island]
                    if islandPos and (hrp.Position - islandPos).Magnitude > 500 then
                        TweenToPosition(islandPos + Vector3.new(0,3,0), 500)
                    else
                        task.wait(0.5)
                    end
                end
            end)
        end
    end
end)

-- FARM BONE
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoFarmBone then
            pcall(function()
                local hrp = GetHRP()
                if not hrp then return end
                local collected = false
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart")
                        and string.find(string.lower(obj.Name), "bone")
                        and obj:FindFirstChild("TouchInterest") then
                        TweenToPosition(obj.Position + Vector3.new(0,3,0), 400)
                        collected = true
                        break
                    end
                end
                if not collected then
                    ActivateHakiOnce()
                    local folder = workspace:FindFirstChild("Enemies")
                    local nearest, nd = nil, math.huge
                    if folder then
                        for _, obj in ipairs(folder:GetChildren()) do
                            local n = string.lower(obj.Name)
                            if string.find(n, "skeleton") or string.find(n, "zombie")
                                or string.find(n, "reaper") or string.find(n, "demonic")
                                or string.find(n, "mummy") then
                                local trp = obj:FindFirstChild("HumanoidRootPart")
                                local hum = obj:FindFirstChildOfClass("Humanoid")
                                if trp and hum and hum.Health > 0 then
                                    local d = GetDist(trp.Position, hrp.Position)
                                    if d < nd then nearest, nd = obj, d end
                                end
                            end
                        end
                    end
                    if nearest then
                        local trp = nearest:FindFirstChild("HumanoidRootPart")
                        if trp then
                            if GetDist(hrp.Position, trp.Position) > 15 then
                                TweenToPosition(trp.Position + Vector3.new(0,3,0), CONFIG.TweenMobSpeed)
                            end
                            EnsureHitbox().CFrame = CFrame.new(trp.Position)
                            AutoAttackNPC(nearest, 5)
                        end
                    else
                        local islandPos = IslandCoords["Haunted Castle"]
                        if islandPos and (hrp.Position - islandPos).Magnitude > 500 then
                            TweenToPosition(islandPos + Vector3.new(0,3,0), 500)
                        end
                    end
                end
            end)
        end
    end
end)

-- FARM MATERIAL (sesuai material & sea yang dipilih)
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoFarmMaterial then
            pcall(function()
                local hrp = GetHRP()
                if not hrp then return end

                local matName = State.SelectedMaterial
                local matData = matName and GetMaterialData(matName) or nil

                -- 1) coba pickup material drop di sekitar
                local picked = false
                if matData then
                    local kw = string.lower(matData.Name)
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and obj:FindFirstChild("TouchInterest") then
                            local n = string.lower(obj.Name)
                            local match = string.find(n, kw)
                            if not match then
                                if matData.Name == "Scrap Metal" then match = string.find(n, "scrap") end
                                if matData.Name == "Magma Ore"   then match = match or string.find(n, "magma") end
                                if matData.Name == "Fish Tail"   then match = match or string.find(n, "fishtail") end
                                if matData.Name == "Angel Wings" then match = match or string.find(n, "wing") end
                                if matData.Name == "Radioactive Material" then match = match or string.find(n, "radioactive") end
                                if matData.Name == "Conjured Cocoa" then match = match or string.find(n, "cocoa") end
                                if matData.Name == "Dragon Scale" then match = match or string.find(n, "scale") end
                                if matData.Name == "Mini Tusk"    then match = match or string.find(n, "tusk") end
                            end
                            if match then
                                TweenToPosition(obj.Position + Vector3.new(0,3,0), 400)
                                picked = true
                                break
                            end
                        end
                    end
                end

                -- 2) kalau tidak ada drop, kill NPC target
                if not picked and matData then
                    ActivateHakiOnce()
                    local folder = workspace:FindFirstChild("Enemies")
                    local nearest, nd = nil, math.huge
                    if folder then
                        for _, obj in ipairs(folder:GetChildren()) do
                            for _, npcName in ipairs(matData.NPC) do
                                if obj.Name == npcName then
                                    local trp = obj:FindFirstChild("HumanoidRootPart")
                                    local hum = obj:FindFirstChildOfClass("Humanoid")
                                    if trp and hum and hum.Health > 0 then
                                        local d = GetDist(trp.Position, hrp.Position)
                                        if d < nd then nearest, nd = obj, d end
                                    end
                                end
                            end
                        end
                    end
                    if nearest then
                        local trp = nearest:FindFirstChild("HumanoidRootPart")
                        if trp then
                            if GetDist(hrp.Position, trp.Position) > 15 then
                                TweenToPosition(trp.Position + Vector3.new(0,3,0), CONFIG.TweenMobSpeed)
                            end
                            EnsureHitbox().CFrame = CFrame.new(trp.Position)
                            AutoAttackNPC(nearest, 5)
                        end
                    else
                        local loc = IslandCoords[matData.Location]
                        if loc and (hrp.Position - loc).Magnitude > 500 then
                            TweenToPosition(loc + Vector3.new(0,3,0), 500)
                        else
                            task.wait(0.5)
                        end
                    end
                elseif not matData then
                    -- fallback: kill mob biasa
                    ActivateHakiOnce()
                    local target = GetNearestEnemy(500)
                    if target then
                        local trp = target:FindFirstChild("HumanoidRootPart")
                        if trp then
                            if GetDist(hrp.Position, trp.Position) > 15 then
                                TweenToPosition(trp.Position + Vector3.new(0,3,0), CONFIG.TweenMobSpeed)
                            end
                            EnsureHitbox().CFrame = CFrame.new(trp.Position)
                            AutoAttackNPC(target, 5)
                        end
                    end
                end
            end)
        end
    end
end)

-- AUTO BOSS
task.spawn(function()
    while task.wait(0.5) do
        if State.AutoBoss and State.SelectedBoss then
            local boss = FindBoss(State.SelectedBoss)
            if boss then AutoAttackNPC(boss, 10) end
        end
    end
end)

-- SEA LOOP
task.spawn(function()
    while task.wait(0.3) do
        if State.AutoFarmSea then
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
        end
        if State.AutoBuyBoat then
            local hasBoat = false
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:FindFirstChildOfClass("VehicleSeat") then
                    local owner = obj:FindFirstChild("Owner")
                    if owner and owner.Value == Player then hasBoat = true break end
                end
            end
            if not hasBoat then
                InvokeAny({"BuyBoat","Boat","BuyShip"}, State.SelectedBoat or "Dinghy")
            end
        end
        if State.AutoCollectBone then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart")
                    and string.find(string.lower(obj.Name), "bone")
                    and obj:FindFirstChild("TouchInterest") then
                    local hrp = GetHRP()
                    if hrp then TweenToPosition(obj.Position + Vector3.new(0,3,0), 400) end
                end
            end
        end
        if State.AutoCollectDinoEgg then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = string.lower(obj.Name)
                    if ((string.find(n, "dino") and string.find(n, "egg"))
                        or string.find(n, "dinosaur"))
                        and obj:FindFirstChild("TouchInterest") then
                        local hrp = GetHRP()
                        if hrp then TweenToPosition(obj.Position + Vector3.new(0,3,0), 400) end
                    end
                end
            end
        end
        if State.AutoKillGolem then
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
        end
    end
end)

-- SEA EVENT SCANNER
task.spawn(function()
    local lastSeen = { mirage=0, azure=0, pre=0, frozen=0 }
    while task.wait(2) do
        local hrp = GetHRP()
        if hrp then
            if State.FindFrozenDim then
                local frozen = ScanSeaEventBroad(
                    {"frozen","frozendimension","frozenwatcher","leviathan"},
                    {"FrozenDimension","FrozenDimensionSpawn","Leviathan"})
                if frozen then
                    local pos = GetPosition(frozen)
                    if pos then
                        Notify("[ICE] Frozen Dimension Spawned!")
                        TweenToPosition(pos + Vector3.new(0, 15, 0), 300)
                        lastSeen.frozen = tick()
                    end
                elseif State.SeaEventAutoSail and (tick() - lastSeen.frozen > 15) then
                    AutoSailToDanger(CONFIG.DangerTarget)
                end
            end
            if State.FindMirage or State.MirageTweenEnabled then
                local mirage = ScanSeaEventBroad({"mirage","mirageisland"},
                    {"MirageIsland","Mirage"})
                if mirage then
                    local pos = GetPosition(mirage)
                    if pos and (hrp.Position - pos).Magnitude > 20 then
                        Notify("[ISLE] Mirage Spawned!")
                        TweenToPosition(pos + Vector3.new(0, 12, 0), 180)
                        lastSeen.mirage = tick()
                    end
                elseif State.SeaEventAutoSail and (tick() - lastSeen.mirage > 15) then
                    AutoSailToDanger(CONFIG.DangerTarget)
                end
            end
            if State.FindAzure then
                local azure = ScanSeaEventBroad(
                    {"azure","azureisland","azureshrine","azuregrotto"},
                    {"AzureIsland","AzureShrine","Azure"})
                if azure then
                    local pos = GetPosition(azure)
                    if pos then
                        local lvl = azure:GetAttribute("Level")
                            or azure:GetAttribute("AzureLevel") or 0
                        if tonumber(lvl) >= (State.AzureLevel or 0) then
                            Notify("[AZURE] Azure Spawned!")
                            TweenToPosition(pos + Vector3.new(0, 8, 0), 180)
                            lastSeen.azure = tick()
                        end
                    end
                elseif State.SeaEventAutoSail and (tick() - lastSeen.azure > 15) then
                    AutoSailToDanger(CONFIG.DangerTarget)
                end
            end
            if State.FindPrehistoric then
                local pre = ScanSeaEventBroad(
                    {"prehistoric","prehistorichisland","volcano","dinoisland"},
                    {"PrehistoricIsland","Volcano","DragonTether"})
                if pre then
                    local pos = GetPosition(pre)
                    if pos then
                        Notify("[DINO] Prehistoric Spawned!")
                        TweenToPosition(pos + Vector3.new(0, 10, 0), 180)
                        lastSeen.pre = tick()
                    end
                elseif State.SeaEventAutoSail and (tick() - lastSeen.pre > 15) then
                    AutoSailToDanger(CONFIG.DangerTarget)
                end
            end
        end
    end
end)

-- AUTO DRIVE TIKI
task.spawn(function()
    while task.wait(2) do
        if State.AutoDriveTiki then
            local tiki = ScanSeaEventBroad({"tiki","tikioutpost"}, {"TikiIsland"})
            local targetPos = GetPosition(tiki) or Vector3.new(-1000, 60, 6000)
            local hrp = GetHRP()
            if hrp then
                local dist = (hrp.Position - targetPos).Magnitude
                if dist > 50 then
                    local boat = GetBoat()
                    if boat and boat.PrimaryPart then
                        local duration = math.max(dist / (State.BoatSpeed or 300), 0.5)
                        local tw = TweenService:Create(boat.PrimaryPart,
                            TweenInfo.new(duration, Enum.EasingStyle.Linear),
                            { CFrame = CFrame.new(targetPos + Vector3.new(0, State.BoatHeight or 5, 0)) })
                        tw:Play()
                        tw.Completed:Wait()
                    else
                        TweenToPosition(targetPos + Vector3.new(0, 5, 0), 500)
                    end
                else
                    Notify("[OK] Arrived at Tiki")
                    State.AutoDriveTiki = false
                end
            end
        end
    end
end)

-- FRUIT TWEEN
task.spawn(function()
    while task.wait(0.3) do
        if State.FruitTweenEnabled then
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
                    if closest and closest.model ~= State._fruitActive then
                        State._fruitActive = closest.model
                        Notify("[FRUIT] Fly to: "..closest.model.Name)
                        local dist = GetDist(closest.part.Position, hrp.Position)
                        local dur = math.max(dist / CONFIG.FruitTweenSpeed, 0.1)
                        local tw = TweenService:Create(hrp,
                            TweenInfo.new(dur, Enum.EasingStyle.Linear),
                            { CFrame = closest.part.CFrame * CFrame.new(0, 3, 0) })
                        tw:Play()
                        tw.Completed:Wait()
                        if closest.part and closest.part.Parent then
                            hrp.CFrame = closest.part.CFrame * CFrame.new(0, 2, 0)
                            task.wait(0.4)
                        end
                        if State.FruitStoreEnabled then
                            task.wait(0.3)
                            local char = Player.Character
                            local targetTool = nil
                            if char then
                                for _, tool in ipairs(char:GetChildren()) do
                                    if tool:IsA("Tool") and tool.Name:find("Fruit") then
                                        targetTool = tool break
                                    end
                                end
                            end
                            if not targetTool then
                                for _, tool in ipairs(Player.Backpack:GetChildren()) do
                                    if tool:IsA("Tool") and tool.Name:find("Fruit") then
                                        targetTool = tool break
                                    end
                                end
                            end
                            if targetTool and CommF then
                                local fruitName = targetTool.Name:gsub(" Fruit", "")
                                pcall(function()
                                    CommF:InvokeServer("StoreFruit", fruitName, targetTool)
                                end)
                                Notify("[BOX] Stored: "..fruitName)
                            end
                        end
                        State._fruitActive = nil
                    end
                end
            end
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
                        end
                    end
                end
                for _, tool in ipairs(Player.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name:find("Fruit") then
                        local fruitName = tool.Name:gsub(" Fruit", "")
                        CommF:InvokeServer("StoreFruit", fruitName, tool)
                        task.wait(0.5)
                    end
                end
            end)
        end
    end
end)

workspace.DescendantAdded:Connect(function(obj)
    if (obj:IsA("Tool") or obj:IsA("Model")) and string.find(obj.Name, "Fruit") then
        task.wait(0.1)
        if obj.Parent == workspace then Notify("[FRUIT] Spawn: "..obj.Name) end
    end
end)

task.spawn(function()
    while task.wait(60) do
        if State.AutoGacha and not GetHeldFruit() then Invoke("BuyFruit", "Random") end
    end
end)

task.spawn(function()
    while task.wait(10) do
        if State.AutoRaid and State.SelectedRaid then
            InvokeAny({"RaidsNpc","Raid","Raids"}, "Select", State.SelectedRaid)
            task.wait(0.5)
            local map = workspace:FindFirstChild("Map")
            local circle = map and map:FindFirstChild("CircleIsland")
            local summon = circle and circle:FindFirstChild("RaidSummon")
            local button = summon and summon:FindFirstChild("Button")
            local main = button and button:FindFirstChild("Main")
            local cd = main and main:FindFirstChild("ClickDetector")
            if cd then pcall(function() fireclickdetector(cd) end) end
        end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if State.AutoAddStats then
            local stats = {
                {Name="Melee",Value=State.StatsMelee},
                {Name="Sword",Value=State.StatsSword},
                {Name="Gun",Value=State.StatsGun},
                {Name="Blox Fruit",Value=State.StatsBloxFruit},
            }
            for _, st in ipairs(stats) do
                if st.Value > 0 then Invoke("AddPoint", st.Name, st.Value) task.wait(0.3) end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if State.AutoFish then
            local char = Player.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool and string.find(string.lower(tool.Name), "rod") then tool:Activate() end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(5) do
        if State.AutoRaceV2 then
            InvokeAny({"Alchemist","RaceV2","Race"}, "1")
            task.wait(1)
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "flower") then
                    local hrp = GetHRP()
                    if hrp then
                        TweenToPosition(obj.Position + Vector3.new(0,3,0), 300)
                        task.wait(0.5)
                    end
                end
            end
            InvokeAny({"Alchemist","RaceV2","Race"}, "2")
        end
    end
end)

task.spawn(function()
    while task.wait(5) do
        if State.AutoRaceV3 then
            InvokeAny({"TalkTrevor","RaceV3","Race"}, "1")
            task.wait(1)
            InvokeAny({"Wenlocktoad","RaceV3","Race"}, "1")
            task.wait(1)
            local prog = InvokeAny({"Wenlocktoad","RaceV3","Race"}, "2")
            if prog == 2 or prog == 3 then
                InvokeAny({"Wenlocktoad","RaceV3","Race"}, "2")
                Notify("[OK] Race V3 Complete!")
                State.AutoRaceV3 = false
            end
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
                        local mHum  = model:FindFirstChildOfClass("Humanoid")
                        if mRoot and mHum and mHum.Health > 0 then
                            local d = GetDist(mRoot.Position, hrp.Position)
                            if d <= range and d > 3 then
                                mRoot.CFrame = CFrame.new(targetPos)
                                mRoot.AssemblyLinearVelocity  = Vector3.zero
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
        local anyEspOn = State.ESPPlayer or State.ESPIsland or State.ESPFruit
            or State.ESPBlueGear or State.ESPChest or State.ESPFlower
        if not anyEspOn then
            if next(State.ESPObjects) ~= nil then ClearAllESP() end
        else
            if State.ESPPlayer then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= Player and plr.Character then
                        local trp = plr.Character:FindFirstChild("HumanoidRootPart")
                        if trp then
                            local dist = math.floor((trp.Position - myPos).Magnitude)
                            CreateESP(trp, dist.." | "..plr.Name, Color3.fromRGB(255,80,80))
                        end
                    end
                end
            end
            if State.ESPFruit then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and string.find(obj.Name, "Fruit") then
                        if obj.Parent == workspace
                            or (obj.Parent and obj.Parent.Name == "Map") then
                            local dist = math.floor((obj.Position - myPos).Magnitude)
                            CreateESP(obj, dist.." | "..obj.Name, Color3.fromRGB(255,200,80))
                        end
                    end
                end
            end
            if State.ESPChest then
                for _, obj in ipairs(GetChestsSorted()) do
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
        end
    end
end)

--============================================================
-- TAB INIT
--============================================================
local TabDefs = {
    {"Discord"}, {"Farm"}, {"Sea"}, {"Quest / Items"}, {"Fruit / Raid"},
    {"Fishing"}, {"Status"}, {"PvP"}, {"Trials"}, {"Seting"},
    {"Teleport"}, {"Stats"}, {"Shop"}, {"Misc"},
}
for i, d in ipairs(TabDefs) do
    local btn = CreateTab(d[1], i)
    btn.Activated:Connect(function() ShowTab(d[1]) end)
end

--============================================================
-- UI OPEN/CLOSE + LOGO DRAG
--============================================================
local function OpenUI()
    Main.Visible = true
    Main.Size = UDim2.fromOffset(750, 570)
    Main.Position = UDim2.new(0.5, -375, 0.5, -285)
    TweenService:Create(Main,
        TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { Size = UDim2.fromOffset(780, 600), Position = UDim2.new(0.5, -390, 0.5, -300) }
    ):Play()
end
local function CloseUI()
    local tw = TweenService:Create(Main,
        TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
        { Size = UDim2.fromOffset(750, 570), Position = UDim2.new(0.5, -375, 0.5, -285) }
    )
    tw:Play()
    tw.Completed:Once(function() Main.Visible = false end)
end

local LogoDragging, LogoDragStart, LogoStartPosition, LogoMoved = false, nil, nil, false
LogoButton.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch then
        LogoDragging = true
        LogoMoved = false
        LogoDragStart = Input.Position
        LogoStartPosition = LogoButton.Position
        Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                LogoDragging = false
            end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(Input)
    if not LogoDragging then return end
    if Input.UserInputType ~= Enum.UserInputType.MouseMovement
        and Input.UserInputType ~= Enum.UserInputType.Touch then return end
    local Delta = Input.Position - LogoDragStart
    if math.abs(Delta.X) > 5 or math.abs(Delta.Y) > 5 then LogoMoved = true end
    LogoButton.Position = UDim2.new(
        LogoStartPosition.X.Scale,
        LogoStartPosition.X.Offset + Delta.X,
        LogoStartPosition.Y.Scale,
        LogoStartPosition.Y.Offset + Delta.Y
    )
end)
LogoButton.Activated:Connect(function()
    if LogoMoved then LogoMoved = false return end
    if Main.Visible then CloseUI() else OpenUI() end
end)
CloseButton.Activated:Connect(function() CloseUI() end)

local MDragging, MDragStart, MStartPos = false, nil, nil
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        MDragging = true MDragStart = input.Position MStartPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then MDragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not MDragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - MDragStart
    Main.Position = UDim2.new(
        MStartPos.X.Scale, MStartPos.X.Offset + delta.X,
        MStartPos.Y.Scale, MStartPos.Y.Offset + delta.Y
    )
end)

LogoButton.MouseEnter:Connect(function()
    TweenService:Create(LogoButton,
        TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Size = UDim2.fromOffset(68,68) }):Play()
end)
LogoButton.MouseLeave:Connect(function()
    TweenService:Create(LogoButton,
        TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Size = UDim2.fromOffset(62,62) }):Play()
end)

Player.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

ShowTab("Farm")
Notify("[LAUNCH] SysxHub v0.1 loaded")
return true
