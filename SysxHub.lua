--[[
================================================================
 SYSX HUB v2.0 FINAL — Full Featured
 Logo: 114593995135483 | Banner: 71457853614279
================================================================
]]

local RS = game:GetService("ReplicatedStorage")
local MPS = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local function IsBloxFruits()
    local pid = game.PlaceId
    if pid == 2753915549 or pid == 4442272183 or pid == 7449423635 then return true end
    if pid == 85211729168715 or pid == 79091703265657 or pid == 100117331123089 then return true end
    local rem = RS:FindFirstChild("Remotes")
    if rem and rem:FindFirstChild("CommF_") then return true end
    return false
end

if not IsBloxFruits() then
    local msg = "This script only for BloxFruit"
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title="SysxHub", Text=msg, Duration=10}) end)
    task.wait(2)
    pcall(function() Players.LocalPlayer:Kick(msg) end)
    return
end

local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")
local VirtualUser       = game:GetService("VirtualUser")
local TeleportService   = game:GetService("TeleportService")
local Lighting          = game:GetService("Lighting")
local HttpService       = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")

local Player    = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Camera    = Workspace.CurrentCamera

--====== LOGO & BANNER (BARU) ======
local LOGO_ID   = "rbxassetid://114593995135483"
local BANNER_ID = "rbxassetid://71457853614279"

local placeId = game.PlaceId
World1 = (placeId == 2753915549 or placeId == 85211729168715)
World2 = (placeId == 4442272183 or placeId == 79091703265657)
World3 = (placeId == 7449423635 or placeId == 100117331123089)

if not game:IsLoaded() then game.Loaded:Wait() end
repeat task.wait() until Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
local Char = Player.Character
local HRP  = Char:WaitForChild("HumanoidRootPart")

local Remotes        = RS:WaitForChild("Remotes", 10)
local CommF_         = Remotes:WaitForChild("CommF_", 10)
local Modules        = RS:FindFirstChild("Modules")
local Net            = Modules and Modules:FindFirstChild("Net")
local RegisterAttack = Net and Net:WaitForChild("RE/RegisterAttack", 5)
local RegisterHit    = Net and Net:WaitForChild("RE/RegisterHit", 5)

local State = {
    AutoFarm=false, AutoFarmNearest=false, AutoChest=false,
    AutoFarmMaterial=false, AutoFarmBones=false,
    AutoBoss=false, SelectedBoss=nil,
    SelectedMaterial=nil, SelectedWeapon="Melee",
    FastAttack=true, FastAttackDelay=0.08,
    BringMob=true, BringRange=300,
    AutoFarmSea=false, SelectedSeaMob="Terror Shark",
    SelectedBoat="PirateBrigade",
    AutoGetSword=false, SelectedSword="Saber",
    AutoStoreFruit=false, AutoBuyFruit=false, AutoFindFruit=false,
    AutoRaid=false, SelectedChip="Flame", AutoAwaken=false,
    AutoCakePrince=false, AutoDoughKing=false,
    AutoEliteHunter=false, AutoSoulReaper=false,
    AutoFactory=false, AutoPiratesSea=false,
    Aimbot=false, SelectedPlayer=nil, TeleportPlayer=false,
    ESPPlayer=false, ESPFruit=false, ESPChest=false,
    ESPIsland=false, ESPBoss=false, ESPObjects={},
    AntiAFK=true, Noclip=false, HideMob=false,
    AutoTrial=false, AutoKillAfterTrial=false,
    AutoStats=false, StatMelee=0, StatDefense=0, StatSword=0,
    StatGun=0, StatFruit=0, PointsPerClick=5,
    BoostFPS=false, WalkWater=false,
    AutoFishing=false, AutoSellFish=false,
    AutoShark=false, AutoPiranha=false, AutoTerrorshark=false,
    AutoFishCrew=false, AutoSeaBeast=false, ProtectBoat=false,
    AutoLeviathan=false, FindMirage=false, FindPrehistoric=false,
    FindFrozen=false, FindKitsune=false,
    AutoNewWorld=false, AutoThirdSea=false,
    AutoV2=false, AutoV3=false,
    RemoveDamage=false, RemoveNotifications=false, AutoKen=false,
}

getgenv().FarmDistance = 20
getgenv().CustomWalkSpeed = 100
getgenv().EnableWalkSpeed = false
getgenv().CustomJumpPower = 50
getgenv().EnableJumpPower = false
getgenv().InfiniteJump = false
TweenSpeed = 300

pcall(function()
    local Effect = RS:FindFirstChild("Effect") and RS.Effect:FindFirstChild("Container")
    if Effect then
        local Death = Effect:FindFirstChild("Death")
        if Death and hookfunction then
            local f = require(Death)
            if type(f) == "function" then hookfunction(f, function() end) end
        end
    end
    local Util = RS:FindFirstChild("Util")
    if Util then
        local CS = Util:FindFirstChild("CameraShaker")
        if CS then pcall(function() require(CS):Stop() end) end
    end
end)

--============= UTILITY =============
getgenv().HakiTime = getgenv().HakiTime or 0
function AutoHaki()
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    if not Player.Character:FindFirstChild("HasBuso") then
        if tick() - getgenv().HakiTime >= 1 then
            CommF_:InvokeServer("Buso")
            getgenv().HakiTime = tick()
        end
    end
end

getgenv().EquipTime = getgenv().EquipTime or 0
function EquipWeapon(ToolName)
    if tick() - getgenv().EquipTime < 0.3 then return end
    getgenv().EquipTime = tick()
    if not ToolName then return end
    local bp = Player:FindFirstChild("Backpack")
    if not bp then return end
    local tool = bp:FindFirstChild(ToolName)
    if tool and tool:IsA("Tool") then
        Player.Character.Humanoid:EquipTool(tool)
        return
    end
    for _, t in ipairs(bp:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip == ToolName then
            Player.Character.Humanoid:EquipTool(t)
            return
        end
    end
end

function topos(Tween_Pos)
    pcall(function()
        if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
        if Player.Character.Humanoid.Health <= 0 then return end
        local hrp = Player.Character.HumanoidRootPart
        local targetPos = Tween_Pos.Position
        local Distance = (targetPos - hrp.Position).Magnitude
        if Distance <= 3 then
            hrp.CFrame = CFrame.new(Tween_Pos.X, Tween_Pos.Y, Tween_Pos.Z)
            return
        end
        local speed = TweenSpeed
        if Distance < 30 then speed = TweenSpeed * 0.5 end
        local finalCF = CFrame.new(Tween_Pos.X, hrp.Position.Y, Tween_Pos.Z)
        local duration = math.max(Distance / speed, 0.15)
        local tw = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = finalCF})
        tw:Play()
        tw.Completed:Wait()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = finalCF
    end)
end

function AttackNoCoolDown()
    local char = Player.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return end
    local hitTargets, mainTarget = {}, nil
    local myPos = HRP.Position
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
    elseif RegisterAttack and RegisterHit then
        pcall(function()
            RegisterAttack:FireServer(0.1)
            RegisterHit:FireServer(mainTarget, hitTargets)
        end)
    end
end

--============= DYNAMIC QUEST =============
local function SafeRequire(mod)
    local ok, res = pcall(require, mod)
    if ok then return res end
    return nil
end
local QuestsModule = SafeRequire(RS:WaitForChild("Quests", 10))
local GuideModule  = SafeRequire(RS:WaitForChild("GuideModule", 10))

function GetQuestInfo()
    local lvl = Player.Data.Level.Value
    local team = tostring(Player.Team)
    local questName, questLvl, mobName, npcCFrame, lvlReq

    if lvl >= 1 and lvl <= 9 then
        if team == "Marines" then
            questName, questLvl, mobName, lvlReq = "MarineQuest", 1, "Trainee", 1
            npcCFrame = CFrame.new(-2709.67944, 24.5206585, 2104.24585)
        else
            questName, questLvl, mobName, lvlReq = "BanditQuest1", 1, "Bandit", 1
            npcCFrame = CFrame.new(1059.99731, 16.9222069, 1549.28162)
        end
        return {lvlReq, npcCFrame, mobName, questName, questLvl}
    end
    if lvl >= 210 and lvl <= 249 then
        return {210, CFrame.new(5308.93115, 1.65517521, 475.120514), "Dangerous Prisoner", "PrisonerQuest", 2}
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
    if HRP and npcCFrame then
        local d = (npcCFrame.Position - HRP.Position).Magnitude
        if lvl >= 375 and lvl <= 449 and d > 3000 then
            CommF_:InvokeServer("requestEntrance", Vector3.new(61163.85, 11.6797, 1819.7842))
        elseif lvl >= 450 and lvl <= 474 and d > 3000 then
            CommF_:InvokeServer("requestEntrance", Vector3.new(-4607.8228, 872.5425, -1667.5569))
        elseif lvl >= 475 and lvl <= 624 and d > 5000 then
            CommF_:InvokeServer("requestEntrance", Vector3.new(-7894.6177, 5547.1416, -380.2912))
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
        npcCFrame = CFrame.new(5310.60547, 0.350014925, 474.946594)
    elseif questName == "Area2Quest" and questLvl == 2 then
        questLvl, mobName, lvlReq = 1, "Swan Pirate", 775
    end
    if lvl >= 2500 and lvl <= 2524 then mobName = "Sun-kissed Warrior" end
    return {lvlReq, npcCFrame, mobName, questName, questLvl}
end

local NameCache = {}
function FindEnemy(names, maxRange, typeOverride)
    if not HRP then return nil end
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    local pos = HRP.Position
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
                    if d < bestD then best = e bestD = d end
                end
            end
        end
    end
    return best
end

function GetIslandList()
    local list, seen = {}, {}
    local loc = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("Locations")
    if loc then
        for _, c in ipairs(loc:GetChildren()) do
            if not seen[c.Name] then seen[c.Name]=true table.insert(list, c.Name) end
        end
    end
    if World1 then table.insert(list, "Sky 2") table.insert(list, "Sky 3") end
    if #list == 0 then list = {"None"} end
    return list
end

function NavigateToIsland(name)
    local isl = {
        ["Sky 2"] = Vector3.new(-4607.8228, 872.5425, -1667.5569),
        ["Sky 3"] = Vector3.new(-7894.6177, 5547.1416, -380.2912),
    }
    if isl[name] then CommF_:InvokeServer("requestEntrance", isl[name]) return end
    local loc = Workspace._WorldOrigin.Locations
    for _, c in ipairs(loc:GetChildren()) do
        if c.Name == name then topos(c.CFrame * CFrame.new(0, 180, 0)) end
    end
end

function GetBossList()
    local list = {}
    for _, c in ipairs(RS:GetDescendants()) do
        local h = c:FindFirstChildOfClass("Humanoid")
        if h and h.DisplayName and h.DisplayName:find("Boss") then table.insert(list, c.Name) end
    end
    local enemies = Workspace:FindFirstChild("Enemies")
    if enemies then
        for _, c in ipairs(enemies:GetDescendants()) do
            local h = c:FindFirstChildOfClass("Humanoid")
            if h and h.DisplayName and h.DisplayName:find("Boss") then table.insert(list, c.Name) end
        end
    end
    if #list == 0 then list = {"None"} end
    return list
end

function GetMaterialList()
    if World1 then return {"Angel Wings","Leather + Scrap Metal","Magma Ore","Fish Tail"}
    elseif World2 then return {"Leather + Scrap Metal","Magma Ore","Mystic Droplet","Radioactive Material","Vampire Fang"}
    elseif World3 then return {"Leather + Scrap Metal","Fish Tail","Gunpowder","Mini Tusk","Conjured Cocoa","Dragon Scale"}
    end
    return {"None"}
end

local MaterialDB = {
    Sea1 = {
        ["Angel Wings"] = {{"Royal Soldier","Royal Squad"}, CFrame.new(-7742, 5634, -1564)},
        ["Leather + Scrap Metal"] = {{"Pirate","Brute"}, CFrame.new(-1257, 54, 4091)},
        ["Magma Ore"] = {{"Military Soldier"}, CFrame.new(-5408, 11, 8456)},
        ["Fish Tail"] = {{"Fishman Warrior"}, CFrame.new(60931, 19, 1574)},
    },
    Sea2 = {
        ["Leather + Scrap Metal"] = {{"Scrap Metal"}, CFrame.new(-1026, 73, 1375)},
        ["Magma Ore"] = {{"Lava Pirate"}, CFrame.new(-5241, 50, -4713)},
        ["Mystic Droplet"] = {{"Water Fighter"}, CFrame.new(-3350, 282, -10527)},
        ["Radioactive Material"] = {{"Factory Staff"}, CFrame.new(-73, 149, -112)},
        ["Vampire Fang"] = {{"Vampire"}, CFrame.new(-6030, 6, -1281)},
    },
    Sea3 = {
        ["Leather + Scrap Metal"] = {{"Pirate Millionaire"}, CFrame.new(-364, 116, 5692)},
        ["Fish Tail"] = {{"Fishman Captain","Fishman Raider"}, CFrame.new(-10679, 398, -8975)},
        ["Gunpowder"] = {{"Pistol Billionaire"}, CFrame.new(-394, 135, 5981)},
        ["Mini Tusk"] = {{"Mythological Pirate"}, CFrame.new(-13510, 584, -6986)},
        ["Conjured Cocoa"] = {{"Cocoa Warrior","Chocolate Bar Battler"}, CFrame.new(400, 81, -12257)},
        ["Dragon Scale"] = {{"Dragon Crew Archer"}, CFrame.new(6689, 378, 331)},
    },
}

function GetMaterialData(name)
    local key = World1 and "Sea1" or (World2 and "Sea2" or "Sea3")
    local entry = MaterialDB[key][name]
    if not entry then return {NPCs={}, Position=nil} end
    return {NPCs = entry[1], Position = entry[2]}
end

function GetPlayerBoat()
    local boats = Workspace:FindFirstChild("Boats")
    if not boats then return nil end
    for _, b in ipairs(boats:GetChildren()) do
        local owner = b:FindFirstChild("Owner")
        local seat = b:FindFirstChildWhichIsA("VehicleSeat", true)
        if owner and seat and tostring(owner.Value) == Player.Name then return b end
    end
    return nil
end

function HopServer()
    local PlaceID = game.PlaceId
    local AllIDs, foundAny = {}, ""
    local actualHour = os.date("!*t").hour
    local function TPReturner()
        local Site
        if foundAny == "" then
            Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/'..PlaceID..'/servers/Public?sortOrder=Asc&limit=100'))
        else
            Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/'..PlaceID..'/servers/Public?sortOrder=Asc&limit=100&cursor='..foundAny))
        end
        local ID = ""
        if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then foundAny = Site.nextPageCursor end
        local num = 0
        for _, v in pairs(Site.data) do
            local possible = true
            ID = tostring(v.id)
            if tonumber(v.maxPlayers) > tonumber(v.playing) then
                for _, ex in pairs(AllIDs) do
                    if num ~= 0 then
                        if ID == tostring(ex) then possible = false end
                    else
                        if tonumber(actualHour) ~= tonumber(ex) then
                            AllIDs = {} table.insert(AllIDs, actualHour)
                        end
                    end
                    num = num + 1
                end
                if possible then
                    table.insert(AllIDs, ID)
                    task.wait(0.1)
                    pcall(function() TeleportService:TeleportToPlaceInstance(PlaceID, ID, Player) end)
                    task.wait(1) break
                end
            end
        end
    end
    for i=1, 3 do pcall(TPReturner) task.wait(1) end
end

--============= UI =============
local function Create(cls, props)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do pcall(function() o[k]=v end) end
    return o
end
local function Corner(p, r) local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r or 8) c.Parent = p end
local function Stroke(p, c, t, tr) local s = Instance.new("UIStroke") s.Color = c or Color3.fromRGB(0,150,255) s.Thickness = t or 1.2 s.Transparency = tr or 0.4 s.Parent = p return s end
local function TW(o, props, t) TweenService:Create(o, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quart), props):Play() end

local old = PlayerGui:FindFirstChild("SysxHub")
if old then old:Destroy() end

local Gui = Create("ScreenGui", {Name="SysxHub", Parent=PlayerGui, ResetOnSpawn=false, IgnoreGuiInset=true, DisplayOrder=999999, ZIndexBehavior=Enum.ZIndexBehavior.Global})
local UIScale = Instance.new("UIScale") UIScale.Scale = 1 UIScale.Parent = Gui

local Notif = Create("TextLabel", {Name="__notif", Parent=Gui, AnchorPoint=Vector2.new(0.5,1), Position=UDim2.new(0.5,0,1,-20), Size=UDim2.fromOffset(340,44), BackgroundColor3=Color3.fromRGB(17,13,29), BackgroundTransparency=0.05, Text="", TextColor3=Color3.fromRGB(255,255,255), TextSize=13, Font=Enum.Font.GothamMedium, Visible=false, ZIndex=999999})
Corner(Notif, 10) Stroke(Notif, Color3.fromRGB(0,150,255), 1.5, 0.3)

local LogoBtn = Create("ImageButton", {Name="SysxLogo", Parent=Gui, Size=UDim2.fromOffset(58,58), Position=UDim2.new(0,18,0.5,-29), BackgroundColor3=Color3.fromRGB(8,14,28), BorderSizePixel=0, Image=LOGO_ID, ScaleType=Enum.ScaleType.Fit, AutoButtonColor=false, ZIndex=100})
Corner(LogoBtn, 16)
local LS = Instance.new("UIStroke") LS.Color=Color3.fromRGB(35,125,255) LS.Thickness=1.5 LS.Transparency=0.1 LS.Parent=LogoBtn

local Main = Create("Frame", {Name="Main", Parent=Gui, Size=UDim2.fromOffset(700,540), Position=UDim2.new(0.5,-350,0.5,-270), BackgroundColor3=Color3.fromRGB(6,11,23), BorderSizePixel=0, Visible=false, ClipsDescendants=true, ZIndex=10})
Corner(Main, 16)
local MS = Instance.new("UIStroke") MS.Color=Color3.fromRGB(38,100,190) MS.Thickness=1.2 MS.Transparency=0.25 MS.Parent=Main

local Header = Create("Frame", {Parent=Main, Size=UDim2.new(1,0,0,72), BackgroundTransparency=1, ZIndex=20})
Create("ImageLabel", {Parent=Header, Size=UDim2.fromOffset(50,50), Position=UDim2.fromOffset(12,8), BackgroundTransparency=1, Image=LOGO_ID, ScaleType=Enum.ScaleType.Fit, ZIndex=22})
Create("TextLabel", {Parent=Header, BackgroundTransparency=1, Position=UDim2.fromOffset(70,6), Size=UDim2.fromOffset(220,24), Text="SysxHub", TextColor3=Color3.fromRGB(235,242,255), TextSize=20, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=22})
local HeaderLvl = Create("TextLabel", {Parent=Header, BackgroundTransparency=1, Position=UDim2.fromOffset(70,30), Size=UDim2.fromOffset(220,18), Text="Lv: 1 | Sea 1", TextColor3=Color3.fromRGB(120,200,255), TextSize=11, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=22})
task.spawn(function()
    while task.wait(1) do
        if not HeaderLvl.Parent then break end
        pcall(function()
            local lv = Player.Data and Player.Data.Level and Player.Data.Level.Value or 1
            local sea = lv >= 1500 and 3 or lv >= 700 and 2 or 1
            HeaderLvl.Text = "Lv: "..lv.." | Sea "..sea
        end)
    end
end)

local CloseBtn = Create("ImageButton", {Parent=Header, Size=UDim2.fromOffset(36,36), Position=UDim2.new(1,-50,0,12), BackgroundColor3=Color3.fromRGB(23,18,38), BackgroundTransparency=0.05, Image=LOGO_ID, ImageColor3=Color3.fromRGB(255,255,255), ScaleType=Enum.ScaleType.Fit, AutoButtonColor=false, ZIndex=25})
Corner(CloseBtn, 9) Stroke(CloseBtn, Color3.fromRGB(0,150,255), 1.5, 0.25)
Create("Frame", {Parent=Header, Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1), BackgroundColor3=Color3.fromRGB(35,55,85), BackgroundTransparency=0.35, BorderSizePixel=0, ZIndex=22})

local BannerHold = Create("Frame", {Parent=Main, Size=UDim2.new(1,-28,0,120), Position=UDim2.fromOffset(14,86), BackgroundColor3=Color3.fromRGB(10,18,34), BorderSizePixel=0, ClipsDescendants=true, ZIndex=12})
Corner(BannerHold, 12) Stroke(BannerHold, Color3.fromRGB(35,95,175), 1, 0.25)
Create("ImageLabel", {Parent=BannerHold, Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Image=BANNER_ID, ScaleType=Enum.ScaleType.Crop, ZIndex=12})
Create("Frame", {Parent=BannerHold, Size=UDim2.fromScale(1,1), BackgroundColor3=Color3.fromRGB(0,10,25), BackgroundTransparency=0.72, BorderSizePixel=0, ZIndex=13})

local Content = Create("Frame", {Parent=Main, Size=UDim2.new(1,-28,1,-222), Position=UDim2.fromOffset(14,218), BackgroundTransparency=1, ZIndex=14})
local Sidebar = Create("Frame", {Parent=Content, BackgroundColor3=Color3.fromRGB(17,13,29), Size=UDim2.new(0,130,1,0), BorderSizePixel=0, ZIndex=15})
Corner(Sidebar, 10) Stroke(Sidebar, Color3.fromRGB(0,150,255), 1, 0.4)
local TabList = Create("ScrollingFrame", {Parent=Sidebar, BackgroundTransparency=1, Position=UDim2.new(0,6,0,6), Size=UDim2.new(1,-12,1,-12), CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=2, ScrollBarImageColor3=Color3.fromRGB(0,150,255), BorderSizePixel=0, ZIndex=16})
local TL = Instance.new("UIListLayout") TL.Padding=UDim.new(0,4) TL.SortOrder=Enum.SortOrder.LayoutOrder TL.Parent=TabList
local ContentScroll = Create("ScrollingFrame", {Parent=Content, BackgroundTransparency=1, Position=UDim2.new(0,138,0,0), Size=UDim2.new(1,-138,1,0), CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=3, ScrollBarImageColor3=Color3.fromRGB(0,150,255), BorderSizePixel=0, ZIndex=14})

local Pages, Tabs = {}, {}

local function CreatePage(name)
    local P = Create("ScrollingFrame", {Name=name, Parent=ContentScroll, BackgroundTransparency=1, Position=UDim2.new(0,4,0,4), Size=UDim2.new(1,-8,1,-8), CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=3, ScrollBarImageColor3=Color3.fromRGB(0,150,255), BorderSizePixel=0, Visible=false, ZIndex=12})
    local L = Instance.new("UIListLayout") L.Padding=UDim.new(0,5) L.SortOrder=Enum.SortOrder.LayoutOrder L.Parent=P
    Pages[name] = P
    return P
end

local function CreateToggle(parent, text, default, cb)
    local state = default or false
    local B = Create("TextButton", {Parent=parent, BackgroundColor3=Color3.fromRGB(17,13,29), Size=UDim2.new(1,0,0,34), Text="", AutoButtonColor=false, BorderSizePixel=0, ZIndex=100})
    Corner(B, 7) Stroke(B, Color3.fromRGB(0,150,255), 1.2, 0.4)
    Create("TextLabel", {Parent=B, BackgroundTransparency=1, Position=UDim2.new(0,10,0,0), Size=UDim2.new(1,-55,1,0), Text=text, TextColor3=Color3.fromRGB(255,255,255), TextSize=11, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=101})
    local Ind = Create("Frame", {Parent=B, BackgroundColor3=Color3.fromRGB(55,50,65), Size=UDim2.fromOffset(32,16), Position=UDim2.new(1,-40,0.5,-8), ZIndex=101})
    Corner(Ind, 20)
    local Dot = Create("Frame", {Parent=Ind, BackgroundColor3=Color3.fromRGB(190,185,200), Size=UDim2.fromOffset(11,11), Position=UDim2.new(0,3,0.5,-5.5), ZIndex=102})
    Corner(Dot, 20)
    local function upd()
        if state then
            Ind.BackgroundColor3 = Color3.fromRGB(0,150,255)
            Dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
            TW(Dot, {Position=UDim2.new(1,-14,0.5,-5.5)}, 0.15)
        else
            Ind.BackgroundColor3 = Color3.fromRGB(55,50,65)
            Dot.BackgroundColor3 = Color3.fromRGB(190,185,200)
            TW(Dot, {Position=UDim2.new(0,3,0.5,-5.5)}, 0.15)
        end
    end
    B.Activated:Connect(function()
        state = not state upd()
        if cb then pcall(cb, state) end
    end)
    upd()
    if state and cb then task.defer(function() pcall(cb, true) end) end
    return B
end

local function CreateButton(parent, text, cb)
    local B = Create("TextButton", {Parent=parent, BackgroundColor3=Color3.fromRGB(17,13,29), Size=UDim2.new(1,0,0,34), Text=text, TextColor3=Color3.fromRGB(255,255,255), TextSize=11, Font=Enum.Font.GothamMedium, AutoButtonColor=false, BorderSizePixel=0, ZIndex=100})
    Corner(B, 7) Stroke(B, Color3.fromRGB(0,150,255), 1.2, 0.4)
    B.MouseEnter:Connect(function() TW(B, {BackgroundColor3=Color3.fromRGB(0,150,255)}, 0.1) end)
    B.MouseLeave:Connect(function() TW(B, {BackgroundColor3=Color3.fromRGB(17,13,29)}, 0.1) end)
    B.Activated:Connect(function() if cb then pcall(cb) end end)
    return B
end

local function CreateDropdown(parent, title, options, cb)
    options = options or {"-"}
    local Hold = Create("Frame", {Parent=parent, BackgroundColor3=Color3.fromRGB(17,13,29), Size=UDim2.new(1,0,0,34), BorderSizePixel=0, ZIndex=100})
    Corner(Hold, 7) Stroke(Hold, Color3.fromRGB(0,150,255), 1.2, 0.4)
    local Sel = options[1] or "-"
    local Lbl = Create("TextLabel", {Parent=Hold, BackgroundTransparency=1, Position=UDim2.new(0,10,0,0), Size=UDim2.new(1,-30,1,0), Text=title..": "..Sel, TextColor3=Color3.fromRGB(255,255,255), TextSize=11, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=101})
    Create("TextLabel", {Parent=Hold, BackgroundTransparency=1, Position=UDim2.new(1,-20,0,0), Size=UDim2.new(0,16,1,0), Text="v", TextColor3=Color3.fromRGB(255,255,255), TextSize=10, Font=Enum.Font.GothamBold, ZIndex=101})
    local clickBtn = Create("TextButton", {Parent=Hold, BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Text="", AutoButtonColor=false, ZIndex=110})
    clickBtn.Activated:Connect(function()
        local Pop = Create("Frame", {Parent=Gui, AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0), Size=UDim2.fromOffset(280, math.min(#options*34+70, 380)), BackgroundColor3=Color3.fromRGB(10,18,34), BorderSizePixel=0, ZIndex=999990})
        Corner(Pop, 12)
        local ps = Instance.new("UIStroke") ps.Color=Color3.fromRGB(0,150,255) ps.Thickness=2 ps.Parent=Pop
        Create("TextLabel", {Parent=Pop, BackgroundTransparency=1, Position=UDim2.fromOffset(15,8), Size=UDim2.new(1,-55,0,22), Text=title, TextColor3=Color3.fromRGB(235,242,255), TextSize=14, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=999991})
        local xBtn = Create("TextButton", {Parent=Pop, Position=UDim2.new(1,-38,0,8), Size=UDim2.fromOffset(28,22), Text="x", TextColor3=Color3.fromRGB(255,255,255), TextSize=20, BackgroundTransparency=1, Font=Enum.Font.GothamBold, AutoButtonColor=false, ZIndex=999992})
        xBtn.Activated:Connect(function() Pop:Destroy() end)
        local LS = Create("ScrollingFrame", {Parent=Pop, BackgroundTransparency=1, Position=UDim2.fromOffset(10,38), Size=UDim2.new(1,-20,1,-46), CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollBarThickness=3, ScrollBarImageColor3=Color3.fromRGB(0,150,255), BorderSizePixel=0, ZIndex=999991})
        local LL = Instance.new("UIListLayout") LL.Padding=UDim.new(0,4) LL.SortOrder=Enum.SortOrder.LayoutOrder LL.Parent=LS
        for i, opt in ipairs(options) do
            local OB = Create("TextButton", {Parent=LS, BackgroundColor3=Color3.fromRGB(17,13,29), Size=UDim2.new(1,-8,0,30), Position=UDim2.new(0,4,0,0), Text=opt, TextColor3=Color3.fromRGB(255,255,255), TextSize=12, Font=Enum.Font.GothamMedium, AutoButtonColor=false, BorderSizePixel=0, LayoutOrder=i, ZIndex=999992, TextXAlignment=Enum.TextXAlignment.Left})
            Corner(OB, 6)
            local pad = Instance.new("UIPadding") pad.PaddingLeft=UDim.new(0,10) pad.Parent=OB
            OB.MouseEnter:Connect(function() TW(OB, {BackgroundColor3=Color3.fromRGB(0,150,255)}, 0.1) end)
            OB.MouseLeave:Connect(function() TW(OB, {BackgroundColor3=Color3.fromRGB(17,13,29)}, 0.1) end)
            OB.Activated:Connect(function()
                Sel = opt Lbl.Text = title..": "..opt
                if cb then pcall(cb, opt) end
                Pop:Destroy()
            end)
        end
    end)
    return Hold
end

local function CreateSlider(parent, title, minV, maxV, defV, cb)
    local val = defV or minV
    local Hold = Create("Frame", {Parent=parent, BackgroundColor3=Color3.fromRGB(17,13,29), Size=UDim2.new(1,0,0,42), BorderSizePixel=0, ZIndex=100})
    Corner(Hold, 7) Stroke(Hold, Color3.fromRGB(0,150,255), 1.2, 0.4)
    Create("TextLabel", {Parent=Hold, BackgroundTransparency=1, Position=UDim2.new(0,10,0,4), Size=UDim2.new(1,-65,0,13), Text=title, TextColor3=Color3.fromRGB(255,255,255), TextSize=10, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=101})
    local ValLbl = Create("TextLabel", {Parent=Hold, BackgroundTransparency=1, Position=UDim2.new(1,-60,0,4), Size=UDim2.new(0,50,0,13), Text=tostring(val), TextColor3=Color3.fromRGB(255,255,255), TextSize=10, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Right, ZIndex=101})
    local Bar = Create("Frame", {Parent=Hold, BackgroundColor3=Color3.fromRGB(23,18,38), Position=UDim2.new(0,10,0,24), Size=UDim2.new(1,-20,0,6), BorderSizePixel=0, ZIndex=101})
    Corner(Bar, 4)
    local Fill = Create("Frame", {Parent=Bar, BackgroundColor3=Color3.fromRGB(0,150,255), Size=UDim2.new((val-minV)/(maxV-minV),0,1,0), BorderSizePixel=0, ZIndex=102})
    Corner(Fill, 4)
    local Btn = Create("TextButton", {Parent=Hold, BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Text="", AutoButtonColor=false, ZIndex=110})
    local dragging = false
    local function upd(mx)
        local abs = Bar.AbsolutePosition
        local sz = Bar.AbsoluteSize
        if sz.X == 0 then return end
        local rel = math.clamp((mx-abs.X)/sz.X, 0, 1)
        val = math.floor(minV + (maxV-minV)*rel + 0.5)
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        ValLbl.Text = tostring(val)
        if cb then pcall(cb, val) end
    end
    Btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true upd(i.Position.X) end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    return Hold
end

local function CreateLabel(parent, text, sz)
    local L = Create("TextLabel", {Parent=parent, BackgroundColor3=Color3.fromRGB(17,13,29), Size=UDim2.new(1,0,0,sz or 28), Text=text, TextColor3=Color3.fromRGB(255,255,255), TextSize=10, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top, BorderSizePixel=0, ZIndex=100})
    Corner(L, 7) Stroke(L, Color3.fromRGB(0,150,255), 1.2, 0.4)
    local pad = Instance.new("UIPadding") pad.PaddingLeft=UDim.new(0,10) pad.PaddingTop=UDim.new(0,5) pad.Parent=L
    return L
end

local function CreateTab(name, order)
    local B = Create("TextButton", {Parent=TabList, BackgroundColor3=Color3.fromRGB(17,13,29), Size=UDim2.new(1,0,0,28), Text="", AutoButtonColor=false, BorderSizePixel=0, LayoutOrder=order, ZIndex=17})
    Corner(B, 6)
    local L = Create("TextLabel", {Parent=B, BackgroundTransparency=1, Position=UDim2.new(0,8,0,0), Size=UDim2.new(1,-14,1,0), Text=name, TextColor3=Color3.fromRGB(255,255,255), TextSize=10, Font=Enum.Font.GothamMedium, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=18})
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

local DiscordPage    = CreatePage("Discord")
local FarmPage       = CreatePage("Farm")
local SeaPage        = CreatePage("Sea")
local QuestItemsPage = CreatePage("Quest / Items")
local FruitRaidPage  = CreatePage("Fruit / Raid")
local FishingPage    = CreatePage("Fishing")
local StatusPage     = CreatePage("Status")
local PvPPage        = CreatePage("PvP")
local TrialsPage     = CreatePage("Trials")
local SetingPage     = CreatePage("Seting")
local TeleportPage   = CreatePage("Teleport")
local StatsPage      = CreatePage("Stats")
local ShopPage       = CreatePage("Shop")
local MiscPage       = CreatePage("Misc")

local TabDefs = {{"Discord"},{"Farm"},{"Sea"},{"Quest / Items"},{"Fruit / Raid"},{"Fishing"},{"Status"},{"PvP"},{"Trials"},{"Seting"},{"Teleport"},{"Stats"},{"Shop"},{"Misc"}}
for i, d in ipairs(TabDefs) do
    local btn = CreateTab(d[1], i)
    btn.Activated:Connect(function() ShowTab(d[1]) end)
end

function Notify(text)
    if not Notif or not Notif.Parent then return end
    Notif.__tk = (Notif.__tk or 0) + 1
    local tk = Notif.__tk
    Notif.Text = tostring(text)
    Notif.Visible = true
    Notif.TextTransparency = 1
    Notif.BackgroundTransparency = 1
    TW(Notif, {TextTransparency=0, BackgroundTransparency=0.05}, 0.2)
    task.delay(2.5, function()
        if tk ~= Notif.__tk then return end
        TW(Notif, {TextTransparency=1, BackgroundTransparency=1}, 0.2)
        task.wait(0.2)
        if tk == Notif.__tk then Notif.Visible = false end
    end)
end

--============= TAB: DISCORD =============
CreateButton(DiscordPage, "[CP] Copy Discord Link", function()
    if setclipboard then setclipboard("https://discord.gg/E5kQJW3hn") Notify("[OK] Discord copied") end
end)
CreateLabel(DiscordPage, "SysxHub v2.0 FINAL", 34)

--============= TAB: FARM =============
CreateLabel(FarmPage, "=== Farm Settings ===", 24)
CreateDropdown(FarmPage, "Select Weapon", {"Melee","Sword","Blox Fruit","Gun"}, function(opt) State.SelectedWeapon = opt end)
CreateSlider(FarmPage, "Farm Distance", 5, 50, 20, function(v) getgenv().FarmDistance = v end)
CreateToggle(FarmPage, "Auto Farm Level", false, function(s) State.AutoFarm = s end)
CreateToggle(FarmPage, "Auto Farm Nearest", false, function(s) State.AutoFarmNearest = s end)
CreateToggle(FarmPage, "Auto Collect Chest", false, function(s) State.AutoChest = s end)
CreateToggle(FarmPage, "Auto Farm Bones", false, function(s) State.AutoFarmBones = s end)

CreateLabel(FarmPage, "=== Material Farm ===", 24)
CreateDropdown(FarmPage, "Select Material", GetMaterialList(), function(opt) State.SelectedMaterial = opt end)
CreateToggle(FarmPage, "Auto Farm Material", false, function(s) State.AutoFarmMaterial = s end)

CreateLabel(FarmPage, "=== Boss Farm ===", 24)
CreateDropdown(FarmPage, "Select Boss", GetBossList(), function(opt) State.SelectedBoss = opt end)
local BossStatus = CreateLabel(FarmPage, "Boss Status: -", 24)
CreateToggle(FarmPage, "Auto Attack Boss", false, function(s) State.AutoBoss = s end)
CreateToggle(FarmPage, "Auto Hop If Boss Not Spawn", false, function(s) getgenv().AutoHopBoss = s end)

CreateLabel(FarmPage, "=== Special Boss ===", 24)
CreateToggle(FarmPage, "Auto Cake Prince", false, function(s) State.AutoCakePrince = s end)
CreateToggle(FarmPage, "Auto Dough King", false, function(s) State.AutoDoughKing = s end)
CreateToggle(FarmPage, "Auto Elite Hunter", false, function(s) State.AutoEliteHunter = s end)
CreateToggle(FarmPage, "Auto Soul Reaper", false, function(s) State.AutoSoulReaper = s end)
CreateToggle(FarmPage, "Auto Factory", false, function(s) State.AutoFactory = s end)
CreateToggle(FarmPage, "Auto Pirates Sea", false, function(s) State.AutoPiratesSea = s end)

--============= TAB: SEA =============
CreateLabel(SeaPage, "=== Sea Settings ===", 24)
CreateDropdown(SeaPage, "Select Sea Mob", {"Terror Shark","Piranha","Shark","Fish Crew Member","Sea Beast"}, function(opt) State.SelectedSeaMob = opt end)
CreateDropdown(SeaPage, "Select Boat", {"PirateBrigade","PirateGrandBrigade","MarineBrigade","MarineGrandBrigade","Beast Hunter"}, function(opt) State.SelectedBoat = opt end)
CreateToggle(SeaPage, "Auto Farm Sea", false, function(s) State.AutoFarmSea = s end)
CreateToggle(SeaPage, "Protect Boat", false, function(s) State.ProtectBoat = s end)

CreateLabel(SeaPage, "=== Attack Options ===", 24)
CreateToggle(SeaPage, "Auto Shark", false, function(s) State.AutoShark = s end)
CreateToggle(SeaPage, "Auto Piranha", false, function(s) State.AutoPiranha = s end)
CreateToggle(SeaPage, "Auto Terrorshark", false, function(s) State.AutoTerrorshark = s end)
CreateToggle(SeaPage, "Auto Fish Crew", false, function(s) State.AutoFishCrew = s end)
CreateToggle(SeaPage, "Auto Sea Beast", false, function(s) State.AutoSeaBeast = s end)

CreateLabel(SeaPage, "=== Find Island ===", 24)
CreateToggle(SeaPage, "Find Mirage Island", false, function(s) State.FindMirage = s end)
CreateToggle(SeaPage, "Find Prehistoric Island", false, function(s) State.FindPrehistoric = s end)
CreateToggle(SeaPage, "Find Frozen Dimension", false, function(s) State.FindFrozen = s end)
CreateToggle(SeaPage, "Find Kitsune Island", false, function(s) State.FindKitsune = s end)

CreateLabel(SeaPage, "=== Leviathan ===", 24)
CreateToggle(SeaPage, "Auto Attack Leviathan", false, function(s) State.AutoLeviathan = s end)

--============= TAB: QUEST / ITEMS =============
CreateLabel(QuestItemsPage, "=== Sea Travel ===", 24)
CreateButton(QuestItemsPage, "[SEA] Travel Sea 1", function() CommF_:InvokeServer("TravelMain") Notify("[OK] Sea 1") end)
CreateButton(QuestItemsPage, "[SEA] Travel Sea 2", function() CommF_:InvokeServer("TravelDressrosa") Notify("[!] Coba Auto New World") end)
CreateButton(QuestItemsPage, "[SEA] Travel Sea 3", function() CommF_:InvokeServer("TravelZou") Notify("[!] Coba Auto Third Sea") end)

CreateLabel(QuestItemsPage, "=== Auto Unlock Sea ===", 24)
CreateToggle(QuestItemsPage, "Auto New World (Sea 2)", false, function(s) State.AutoNewWorld = s end)
CreateToggle(QuestItemsPage, "Auto Third Sea (Sea 3)", false, function(s) State.AutoThirdSea = s end)

CreateLabel(QuestItemsPage, "=== Race Upgrade ===", 24)
CreateToggle(QuestItemsPage, "Auto V2", false, function(s) State.AutoV2 = s end)
CreateToggle(QuestItemsPage, "Auto V3", false, function(s) State.AutoV3 = s end)

--============= TAB: FRUIT / RAID =============
local FruitNameMap = {
    ["Rocket"]="Rocket-Rocket",["Spin"]="Spin-Spin",["Chop"]="Chop-Chop",
    ["Spring"]="Spring-Spring",["Bomb"]="Bomb-Bomb",["Smoke"]="Smoke-Smoke",
    ["Spike"]="Spike-Spike",["Flame"]="Flame-Flame",["Falcon"]="Falcon-Falcon",
    ["Ice"]="Ice-Ice",["Sand"]="Sand-Sand",["Dark"]="Dark-Dark",
    ["Ghost"]="Ghost-Ghost",["Diamond"]="Diamond-Diamond",["Light"]="Light-Light",
    ["Rubber"]="Rubber-Rubber",["Barrier"]="Barrier-Barrier",["Magma"]="Magma-Magma",
    ["Quake"]="Quake-Quake",["Buddha"]="Buddha-Buddha",["Love"]="Love-Love",
    ["Spider"]="Spider-Spider",["Sound"]="Sound-Sound",["Phoenix"]="Phoenix-Phoenix",
    ["Portal"]="Portal-Portal",["Rumble"]="Rumble-Rumble",["Pain"]="Pain-Pain",
    ["Blizzard"]="Blizzard-Blizzard",["Gravity"]="Gravity-Gravity",
    ["Mammoth"]="Mammoth-Mammoth",["T-Rex"]="T-Rex-T-Rex",["Dough"]="Dough-Dough",
    ["Shadow"]="Shadow-Shadow",["Venom"]="Venom-Venom",["Gas"]="Gas-Gas",
    ["Control"]="Control-Control",["Spirit"]="Spirit-Spirit",
    ["Leopard"]="Leopard-Leopard",["Yeti"]="Yeti-Yeti",["Kitsune"]="Kitsune-Kitsune",
    ["Dragon"]="Dragon-Dragon",["Blade"]="Blade-Blade",
}
local function GetFruitKeyFromTool(toolName)
    local clean = toolName:gsub(" Fruit",""):gsub(" ","")
    if clean:find("%-") then return clean end
    return FruitNameMap[clean] or (clean.."-"..clean)
end

CreateLabel(FruitRaidPage, "=== Fruit ===", 24)
CreateToggle(FruitRaidPage, "Auto Store Fruit", false, function(s) State.AutoStoreFruit = s end)
CreateToggle(FruitRaidPage, "Auto Buy Random Fruit", false, function(s) State.AutoBuyFruit = s end)
CreateToggle(FruitRaidPage, "Tween To Fruit", false, function(s) State.AutoFindFruit = s end)

CreateLabel(FruitRaidPage, "=== Raid ===", 24)
CreateDropdown(FruitRaidPage, "Select Chip", {"Flame","Ice","Sand","Dark","Light","Magma","Quake","Buddha","Love","Spider","Sound","Phoenix","Portal","Rumble","Pain","Blizzard","Gravity"}, function(opt) State.SelectedChip = opt end)
CreateToggle(FruitRaidPage, "Auto Raid", false, function(s) State.AutoRaid = s end)
CreateToggle(FruitRaidPage, "Auto Awaken Fruit", false, function(s) State.AutoAwaken = s end)

--============= TAB: FISHING =============
CreateLabel(FishingPage, "=== Fishing ===", 24)
CreateToggle(FishingPage, "Auto Equip Rod", false, function(s)
    getgenv().AutoEquipRod = s
    if s then
        task.spawn(function()
            while getgenv().AutoEquipRod do
                pcall(function()
                    local tool = Player.Character and Player.Character:FindFirstChildWhichIsA("Tool")
                    if not tool or tool:GetAttribute("InventoryCategory") ~= "Rod" then
                        for _, t in ipairs(Player.Backpack:GetChildren()) do
                            if t:IsA("Tool") and t:GetAttribute("InventoryCategory") == "Rod" then
                                Player.Character.Humanoid:EquipTool(t)
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
CreateToggle(FishingPage, "Auto Fishing", false, function(s) State.AutoFishing = s end)
CreateToggle(FishingPage, "Auto Sell Fish", false, function(s) State.AutoSellFish = s end)

--============= TAB: STATUS =============
local StatusLbl = CreateLabel(StatusPage, "Loading...", 200)
StatusLbl.TextSize = 11
task.spawn(function()
    while task.wait(1) do
        if not StatusLbl.Parent then break end
        pcall(function()
            local lv = Player.Data.Level.Value
            local sea = lv >= 1500 and 3 or lv >= 700 and 2 or 1
            local q = GetQuestInfo()
            StatusLbl.Text = string.format("PLAYER: %s\nLevel: %d | Sea: %d\nRace: %s\nBeli: %d\n\nFARM\nQuest: %s\nMob: %s\nBoss: %s\nMaterial: %s",
                Player.Name, lv, sea, tostring(Player.Data.Race.Value), Player.Data.Beli.Value,
                tostring(q[4] or "-"), tostring(q[3] or "-"),
                tostring(State.SelectedBoss or "-"), tostring(State.SelectedMaterial or "-"))
        end)
    end
end)

--============= TAB: PVP =============
local pvpPlayers = {"None"}
for _, p in ipairs(Players:GetPlayers()) do if p ~= Player then table.insert(pvpPlayers, p.Name) end end
CreateDropdown(PvPPage, "Select Player", pvpPlayers, function(opt) State.SelectedPlayer = opt end)
CreateToggle(PvPPage, "Teleport To Player", false, function(s) State.TeleportPlayer = s end)
CreateToggle(PvPPage, "Auto Aimbot", false, function(s) State.Aimbot = s end)

--============= TAB: TRIALS =============
CreateLabel(TrialsPage, "=== Race V4 Trial ===", 24)
CreateButton(TrialsPage, "[DOOR] Teleport To Trial Door", function()
    local race = Player.Data.Race.Value
    local poses = {
        Human = CFrame.new(29221.822, 14890.975, -205.991),
        Skypiea = CFrame.new(28960.158, 14919.624, 235.039),
        Fishman = CFrame.new(28231.175, 14890.975, -211.641),
        Cyborg  = CFrame.new(28502.681, 14895.975, -423.727),
        Ghoul   = CFrame.new(28674.244, 14890.676, 445.431),
        Mink    = CFrame.new(29012.341, 14890.975, -380.149),
    }
    if poses[race] then topos(poses[race]) Notify("[OK] Trial door") end
end)
CreateButton(TrialsPage, "[LEVER] Pull Lever", function()
    for _, d in ipairs(Workspace.Map["Temple of Time"]:GetDescendants()) do
        if d.Name == "ProximityPrompt" then
            pcall(function() fireproximityprompt(d, math.huge) end)
        end
    end
    Notify("[OK] Lever pulled")
end)
CreateToggle(TrialsPage, "Auto Trial V4", false, function(s) State.AutoTrial = s end)
CreateToggle(TrialsPage, "Auto Kill Player After Trial", false, function(s) State.AutoKillAfterTrial = s end)

--============= TAB: SETING (ESP ONLY) =============
local function ClearESPByCategory(cat)
    for part, bb in pairs(State.ESPObjects) do
        if bb and bb.Name == "SysxESP_" .. cat then
            pcall(function() bb:Destroy() end)
            State.ESPObjects[part] = nil
        end
    end
end

CreateLabel(SetingPage, "=== ESP ===", 24)
CreateToggle(SetingPage, "ESP Player", false, function(s)
    State.ESPPlayer = s
    if not s then ClearESPByCategory("Player") end
end)
CreateToggle(SetingPage, "ESP Fruit", false, function(s)
    State.ESPFruit = s
    if not s then ClearESPByCategory("Fruit") end
end)
CreateToggle(SetingPage, "ESP Chest", false, function(s)
    State.ESPChest = s
    if not s then ClearESPByCategory("Chest") end
end)
CreateToggle(SetingPage, "ESP Island", false, function(s)
    State.ESPIsland = s
    if not s then ClearESPByCategory("Island") end
end)
CreateToggle(SetingPage, "ESP Boss", false, function(s)
    State.ESPBoss = s
    if not s then ClearESPByCategory("Boss") end
end)
CreateButton(SetingPage, "[X] Clear All ESP", function()
    for part, bb in pairs(State.ESPObjects) do
        pcall(function() bb:Destroy() end)
    end
    State.ESPObjects = {}
    State.ESPPlayer = false State.ESPFruit = false State.ESPChest = false
    State.ESPIsland = false State.ESPBoss = false
    Notify("[OK] All ESP cleared")
end)

--============= TAB: TELEPORT =============
CreateLabel(TeleportPage, "=== Island Teleport ===", 24)
CreateDropdown(TeleportPage, "Select Island", GetIslandList(), function(opt) getgenv().SysxSelectIsland = opt end)
CreateButton(TeleportPage, "[GO] Tween To Island", function()
    if getgenv().SysxSelectIsland then
        NavigateToIsland(getgenv().SysxSelectIsland)
        Notify("[OK] Tween: "..getgenv().SysxSelectIsland)
    end
end)

--============= TAB: STATS =============
CreateLabel(StatsPage, "=== Auto Allocate Stats ===", 24)
CreateSlider(StatsPage, "Points Per Click", 1, 50, 5, function(v) State.PointsPerClick = v end)
CreateToggle(StatsPage, "Auto Melee", false, function(s) State.StatMelee = s and 1 or 0 end)
CreateToggle(StatsPage, "Auto Defense", false, function(s) State.StatDefense = s and 1 or 0 end)
CreateToggle(StatsPage, "Auto Sword", false, function(s) State.StatSword = s and 1 or 0 end)
CreateToggle(StatsPage, "Auto Gun", false, function(s) State.StatGun = s and 1 or 0 end)
CreateToggle(StatsPage, "Auto Blox Fruit", false, function(s) State.StatFruit = s and 1 or 0 end)
CreateToggle(StatsPage, "Enable Auto Stats", false, function(s) State.AutoStats = s end)

--============= TAB: SHOP =============
local function TryBuy(cmd, ...)
    local args = {...}
    local ok, res = pcall(function() return CommF_:InvokeServer(cmd, table.unpack(args)) end)
    if ok then Notify("[BUY] "..cmd.." → "..tostring(res or "OK"))
    else Notify("[X] "..cmd.." → "..tostring(res)) end
end

CreateLabel(ShopPage, "=== Teleport Shop ===", 24)
CreateButton(ShopPage, "[TP] Fighting Style NPC", function() topos(CFrame.new(-2300, 60, 3000)) end)
CreateButton(ShopPage, "[TP] Ability Teacher", function() topos(CFrame.new(-5050, 30, 4100)) end)

CreateLabel(ShopPage, "=== Fighting Style ===", 24)
CreateButton(ShopPage, "Buy Black Leg", function() TryBuy("BuyBlackLeg") end)
CreateButton(ShopPage, "Buy Electro", function() TryBuy("BuyElectro") end)
CreateButton(ShopPage, "Buy Fishman Karate", function() TryBuy("BuyFishmanKarate") end)
CreateButton(ShopPage, "Buy Superhuman", function() TryBuy("BuySuperhuman") end)
CreateButton(ShopPage, "Buy Death Step", function() TryBuy("BuyDeathStep") end)
CreateButton(ShopPage, "Buy Sharkman Karate", function() TryBuy("BuySharkmanKarate", true) task.wait(0.3) TryBuy("BuySharkmanKarate") end)
CreateButton(ShopPage, "Buy Electric Claw", function() TryBuy("BuyElectricClaw") end)
CreateButton(ShopPage, "Buy Dragon Talon", function() TryBuy("BuyDragonTalon") end)
CreateButton(ShopPage, "Buy God Human", function() TryBuy("BuyGodhuman") end)
CreateButton(ShopPage, "Buy Sanguine Art", function() TryBuy("BuySanguineArt", true) task.wait(0.3) TryBuy("BuySanguineArt") end)

CreateLabel(ShopPage, "=== Abilities ===", 24)
CreateButton(ShopPage, "Buy Geppo", function() TryBuy("BuyHaki", "Geppo") end)
CreateButton(ShopPage, "Buy Buso", function() TryBuy("BuyHaki", "Buso") end)
CreateButton(ShopPage, "Buy Ken", function() TryBuy("KenTalk", "Buy") end)
CreateButton(ShopPage, "Buy Soru", function() TryBuy("BuyHaki", "Soru") end)

CreateLabel(ShopPage, "=== Misc ===", 24)
CreateButton(ShopPage, "Buy Stat Refund", function() TryBuy("BlackbeardReward", "Refund", "1") task.wait(0.3) TryBuy("BlackbeardReward", "Refund", "2") end)
CreateButton(ShopPage, "Buy Race Reroll", function() TryBuy("BlackbeardReward", "Reroll", "1") task.wait(0.3) TryBuy("BlackbeardReward", "Reroll", "2") end)
CreateButton(ShopPage, "Buy Ghoul Race", function() TryBuy("Ectoplasm", "BuyCheck", 4) task.wait(0.3) TryBuy("Ectoplasm", "Change", 4) end)
CreateButton(ShopPage, "Buy Cyborg Race", function() TryBuy("CyborgTrainer", "Buy") end)

--============= TAB: MISC =============
CreateLabel(MiscPage, "=== Combat ===", 24)
CreateToggle(MiscPage, "Fast Attack", true, function(s) State.FastAttack = s end)
CreateToggle(MiscPage, "Bring Mob", true, function(s) State.BringMob = s end)
CreateSlider(MiscPage, "Bring Mob Range", 50, 1000, 300, function(v) State.BringRange = v end)
CreateSlider(MiscPage, "Tween Speed", 100, 500, 300, function(v) TweenSpeed = v Notify("[OK] Speed: "..v) end)

CreateLabel(MiscPage, "=== Local ===", 24)
CreateToggle(MiscPage, "Anti AFK", true, function(s) State.AntiAFK = s end)
CreateToggle(MiscPage, "No Clip", false, function(s) State.Noclip = s end)
CreateToggle(MiscPage, "Hide Mob", false, function(s) State.HideMob = s end)
CreateToggle(MiscPage, "Auto Ken", false, function(s) State.AutoKen = s end)

CreateLabel(MiscPage, "=== Server ===", 24)
CreateButton(MiscPage, "[RE] Rejoin Server", function() TeleportService:Teleport(game.PlaceId, Player) end)
CreateButton(MiscPage, "[HOP] Server Hop", function() HopServer() end)

CreateLabel(MiscPage, "=== Movement ===", 24)
CreateToggle(MiscPage, "Custom WalkSpeed", false, function(s)
    getgenv().EnableWalkSpeed = s
    if not s then
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end)
CreateSlider(MiscPage, "WalkSpeed Value", 16, 300, 100, function(v)
    getgenv().CustomWalkSpeed = v
    if getgenv().EnableWalkSpeed then
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
end)
CreateToggle(MiscPage, "Custom JumpPower", false, function(s)
    getgenv().EnableJumpPower = s
    if not s then
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = 50 end
    end
end)
CreateSlider(MiscPage, "JumpPower Value", 50, 500, 100, function(v)
    getgenv().CustomJumpPower = v
    if getgenv().EnableJumpPower then
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v end
    end
end)
CreateToggle(MiscPage, "Infinite Jump", false, function(s) getgenv().InfiniteJump = s end)

CreateLabel(MiscPage, "=== Performance ===", 24)
CreateToggle(MiscPage, "Boost FPS", false, function(s)
    if s then
        pcall(function()
            Lighting.GlobalShadows = false Lighting.Brightness = 0
            Lighting.FogEnd = 1e10 Lighting.Outlines = false
            for _, e in pairs(Lighting:GetChildren()) do
                if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled = false end
            end
        end)
    else
        pcall(function()
            Lighting.GlobalShadows = true Lighting.Brightness = 2
            Lighting.FogEnd = 100000 Lighting.Outlines = true
        end)
    end
end)
CreateToggle(MiscPage, "Walk On Water", false, function(s)
    State.WalkWater = s
    local water = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("WaterBase-Plane")
    if water then water.Size = s and Vector3.new(1000, 113, 1000) or Vector3.new(1000, 80, 1000) end
end)
CreateToggle(MiscPage, "Remove Damage Numbers", false, function(s) State.RemoveDamage = s end)
CreateToggle(MiscPage, "Remove Notifications", false, function(s) State.RemoveNotifications = s end)

CreateLabel(MiscPage, "=== Codes ===", 24)
CreateButton(MiscPage, "[GIFT] Redeem All Codes", function()
    local codes = {"KITT_RESET","SUB2GAMERROBOT_RESET1","SUB2GAMERROBOT_EXP1","SUB2OFFICIALNOOBIE","AXIORE","BLUXXY","JCWK","KITTGAMING","MAGICBUS","STARCODEHEO","STRAWHATMAINE","TANTAIGAMING","THEGREATACE","ENYU_IS_PRO","FUDD10","FUDD10_V2","BIGNEWS","CHANDLER","SECRET_ADMIN","ADMIN_MELEE"}
    for _, c in ipairs(codes) do pcall(function() Remotes.Redeem:InvokeServer(c) end) task.wait(1) end
    Notify("[GIFT] All codes redeemed")
end)

--============= UI OPEN/CLOSE =============
local function OpenUI()
    Main.Visible = true
    Main.Size = UDim2.fromOffset(680, 520)
    Main.Position = UDim2.new(0.5, -340, 0.5, -260)
    TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {Size=UDim2.fromOffset(700,540), Position=UDim2.new(0.5,-350,0.5,-270)}):Play()
end
local function CloseUI()
    local tw = TweenService:Create(Main, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {Size=UDim2.fromOffset(680,520), Position=UDim2.new(0.5,-340,0.5,-260)})
    tw:Play()
    tw.Completed:Once(function() Main.Visible = false end)
end

local dragLogo, dragStart, logoStart, moved = false, nil, nil, false
LogoBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        dragLogo = true moved = false dragStart = inp.Position logoStart = LogoBtn.Position
        inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then dragLogo = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if not dragLogo then return end
    if inp.UserInputType ~= Enum.UserInputType.MouseMovement and inp.UserInputType ~= Enum.UserInputType.Touch then return end
    local d = inp.Position - dragStart
    if math.abs(d.X) > 5 or math.abs(d.Y) > 5 then moved = true end
    LogoBtn.Position = UDim2.new(logoStart.X.Scale, logoStart.X.Offset+d.X, logoStart.Y.Scale, logoStart.Y.Offset+d.Y)
end)
LogoBtn.Activated:Connect(function()
    if moved then moved = false return end
    if Main.Visible then CloseUI() else OpenUI() end
end)
CloseBtn.Activated:Connect(CloseUI)

local dragM, mStart, mPos = false, nil, nil
Header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragM = true mStart = i.Position mPos = Main.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragM = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if not dragM then return end
    if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
    local d = i.Position - mStart
    Main.Position = UDim2.new(mPos.X.Scale, mPos.X.Offset+d.X, mPos.Y.Scale, mPos.Y.Offset+d.Y)
end)

--============= LOOPS =============

task.spawn(function()
    while task.wait(0.5) do pcall(AutoHaki) end
end)

task.spawn(function()
    while task.wait(0.3) do
        if State.AutoFarm then
            pcall(function()
                local q = GetQuestInfo()
                local lvlReq, npcCF, mobName, questName, questLvl = table.unpack(q)
                if not npcCF or not questName then return end
                local hasQuest = false
                local qFrame = PlayerGui:FindFirstChild("TrackedQuestFrame")
                if qFrame and qFrame:FindFirstChild("Frame") and qFrame.Frame.Visible then hasQuest = true end
                if not hasQuest then
                    local qg = PlayerGui:FindFirstChild("Main") and PlayerGui.Main:FindFirstChild("Quest")
                    if qg and qg.Visible then hasQuest = true end
                end
                if not hasQuest then
                    local dist = (HRP.Position - npcCF.Position).Magnitude
                    if dist > 15 then topos(npcCF * CFrame.new(0, 0, -5))
                    else CommF_:InvokeServer("StartQuest", questName, questLvl) task.wait(0.5) end
                else
                    local enemy = FindEnemy({mobName}, 5000)
                    if enemy then
                        local trp = enemy:FindFirstChild("HumanoidRootPart")
                        if trp then
                            EquipWeapon(State.SelectedWeapon)
                            if (trp.Position - HRP.Position).Magnitude > 15 then
                                topos(trp.CFrame * CFrame.new(0, getgenv().FarmDistance, 0))
                            end
                            trp.CanCollide = false
                            trp.Size = Vector3.new(60, 60, 60)
                            enemy.Humanoid.WalkSpeed = 0
                            if enemy:FindFirstChild("Head") then enemy.Head.CanCollide = false end
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if State.AutoFarmNearest then
            pcall(function()
                local enemies = Workspace:FindFirstChild("Enemies")
                if not enemies then return end
                local best, bestD = nil, math.huge
                for _, e in ipairs(enemies:GetChildren()) do
                    local h = e:FindFirstChild("Humanoid")
                    local trp = e:FindFirstChild("HumanoidRootPart")
                    if h and trp and h.Health > 0 then
                        local d = (trp.Position - HRP.Position).Magnitude
                        if d < bestD and d < 2000 then best = e bestD = d end
                    end
                end
                if best then
                    local trp = best:FindFirstChild("HumanoidRootPart")
                    if trp then
                        EquipWeapon(State.SelectedWeapon)
                        if (trp.Position - HRP.Position).Magnitude > 15 then
                            topos(trp.CFrame * CFrame.new(0, getgenv().FarmDistance, 0))
                        end
                        trp.CanCollide = false
                        trp.Size = Vector3.new(60, 60, 60)
                        best.Humanoid.WalkSpeed = 0
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    local chestsCache = nil
    local firstRun = true
    while task.wait(0.3) do
        if State.AutoChest then
            pcall(function()
                if firstRun then
                    firstRun = false
                    chestsCache = {}
                    for _, obj in pairs(game:GetDescendants()) do
                        if obj.Name:find("Chest") and obj.ClassName == "Part" then
                            table.insert(chestsCache, obj)
                        end
                    end
                end
                local valid = {}
                for _, c in ipairs(chestsCache or {}) do
                    if c.Parent and c:FindFirstChild("TouchInterest") then
                        table.insert(valid, c)
                    end
                end
                if #valid > 0 then
                    local rootPos = HRP.Position
                    table.sort(valid, function(a, b)
                        return (rootPos - a.Position).Magnitude < (rootPos - b.Position).Magnitude
                    end)
                    HRP.CFrame = CFrame.new(valid[1].Position + Vector3.new(0, 2, 0))
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if State.AutoFarmMaterial and State.SelectedMaterial then
            pcall(function()
                local data = GetMaterialData(State.SelectedMaterial)
                if not data or not data.NPCs or #data.NPCs == 0 then return end
                local enemy = FindEnemy(data.NPCs, 3000)
                if enemy then
                    local trp = enemy:FindFirstChild("HumanoidRootPart")
                    if trp then
                        EquipWeapon(State.SelectedWeapon)
                        topos(trp.CFrame * CFrame.new(0, getgenv().FarmDistance, 0))
                        trp.CanCollide = false
                        enemy.Humanoid.WalkSpeed = 0
                    end
                elseif data.Position then
                    topos(data.Position + Vector3.new(0, 30, 0))
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if State.AutoFarmBones then
            pcall(function()
                local enemy = FindEnemy({"Reborn Skeleton","Living Zombie","Demonic Soul","Posessed Mummy","Soul Reaper"}, 3000)
                if enemy then
                    local trp = enemy:FindFirstChild("HumanoidRootPart")
                    if trp then
                        EquipWeapon(State.SelectedWeapon)
                        topos(trp.CFrame * CFrame.new(0, getgenv().FarmDistance, 0))
                        trp.CanCollide = false
                        enemy.Humanoid.WalkSpeed = 0
                    end
                else
                    topos(CFrame.new(-9516, 142, 5537) + Vector3.new(0, 30, 0))
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
                if BossStatus and BossStatus.Parent then
                    BossStatus.Text = spawned and "Boss Status: OK Spawned" or "Boss Status: X Not Spawned"
                end
                if enemy then
                    local trp = enemy:FindFirstChild("HumanoidRootPart")
                    if trp then
                        EquipWeapon(State.SelectedWeapon)
                        topos(trp.CFrame * CFrame.new(0, getgenv().FarmDistance, 0))
                        trp.CanCollide = false
                        trp.Size = Vector3.new(80,80,80)
                        enemy.Humanoid.WalkSpeed = 0
                    end
                elseif rsBoss and rsBoss:FindFirstChild("HumanoidRootPart") then
                    topos(rsBoss.HumanoidRootPart.CFrame * CFrame.new(5, 10, 5))
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if State.AutoCakePrince then
            pcall(function()
                local mirror = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("CakeLoaf") and Workspace.Map.CakeLoaf:FindFirstChild("BigMirror")
                local isInMirror = mirror and mirror:FindFirstChild("Other") and mirror.Other.Transparency == 0
                local function AttackTarget(name)
                    local e = FindEnemy({name}, 5000)
                    if e then
                        local trp = e:FindFirstChild("HumanoidRootPart")
                        if trp then
                            EquipWeapon(State.SelectedWeapon)
                            topos(trp.CFrame * CFrame.new(0, getgenv().FarmDistance, 0))
                            trp.CanCollide = false
                            trp.Size = Vector3.new(80,80,80)
                            e.Humanoid.WalkSpeed = 0
                            return true
                        end
                    end
                    return false
                end
                if AttackTarget("Cake Prince") or AttackTarget("Dough King") then return end
                if AttackTarget("Cookie Crafter") or AttackTarget("Cake Guard") or AttackTarget("Baking Staff") or AttackTarget("Head Baker") then
                    local resp = CommF_:InvokeServer("CakePrinceSpawner", true)
                    if resp and resp:find("open the portal now") then
                        CommF_:InvokeServer("CakePrinceSpawner")
                    end
                    return
                end
                if isInMirror and HRP then
                    local main = Workspace.Map.CakeLoaf.BigMirror.Main
                    pcall(function() firetouchinterest(HRP, main, 0) task.wait() firetouchinterest(HRP, main, 1) end)
                else
                    topos(CFrame.new(-2077, 252, -12373))
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if State.AutoDoughKing then
            pcall(function()
                local hasChalice = (Player.Character and Player.Character:FindFirstChild("God's Chalice")) or Player.Backpack:FindFirstChild("God's Chalice")
                local hasSweet = (Player.Character and Player.Character:FindFirstChild("Sweet Chalice")) or Player.Backpack:FindFirstChild("Sweet Chalice")
                if hasChalice then
                    local resp = CommF_:InvokeServer("SweetChaliceNpc")
                    if resp and string.find(resp, "Where") then
                        local e = FindEnemy({"Chocolate Bar Battler","Cocoa Warrior"}, 5000)
                        if e and e:FindFirstChild("HumanoidRootPart") then
                            EquipWeapon(State.SelectedWeapon)
                            topos(e.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
                            e.HumanoidRootPart.CanCollide = false
                            e.Humanoid.WalkSpeed = 0
                        end
                    else
                        CommF_:InvokeServer("SweetChaliceNpc")
                    end
                elseif hasSweet then
                    local resp = CommF_:InvokeServer("CakePrinceSpawner")
                    if resp and string.find(resp, "Do you want to open the portal now") then
                        CommF_:InvokeServer("CakePrinceSpawner")
                    else
                        local e = FindEnemy({"Baking Staff","Head Baker","Cake Guard","Cookie Crafter"}, 5000)
                        if e and e:FindFirstChild("HumanoidRootPart") then
                            EquipWeapon(State.SelectedWeapon)
                            topos(e.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
                            e.HumanoidRootPart.CanCollide = false
                            e.Humanoid.WalkSpeed = 0
                        end
                    end
                else
                    local e = FindEnemy({"Dough King"}, 99999)
                    if e and e:FindFirstChild("HumanoidRootPart") then
                        EquipWeapon(State.SelectedWeapon)
                        topos(e.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().FarmDistance, 0))
                        e.HumanoidRootPart.CanCollide = false
                        e.Humanoid.WalkSpeed = 0
                    else
                        topos(CFrame.new(-2077, 252, -12373))
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
                local found = false
                for _, name in ipairs({"Diablo","Deandre","Urban"}) do
                    local e = FindEnemy({name}, 99999)
                    if e and e:FindFirstChild("HumanoidRootPart") then
                        EquipWeapon(State.SelectedWeapon)
                        topos(e.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().FarmDistance, 0))
                        e.HumanoidRootPart.CanCollide = false
                        e.Humanoid.WalkSpeed = 0
                        found = true
                        break
                    end
                end
                if not found then CommF_:InvokeServer("EliteHunter") end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if State.AutoSoulReaper then
            pcall(function()
                local e = FindEnemy({"Soul Reaper"}, 99999)
                if e and e:FindFirstChild("HumanoidRootPart") then
                    EquipWeapon(State.SelectedWeapon)
                    topos(e.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().FarmDistance, 0))
                    e.HumanoidRootPart.CanCollide = false
                    e.Humanoid.WalkSpeed = 0
                else
                    local hasHallow = (Player.Character and Player.Character:FindFirstChild("Hallow Essence")) or Player.Backpack:FindFirstChild("Hallow Essence")
                    if hasHallow then
                        local t = Player.Backpack:FindFirstChild("Hallow Essence") or Player.Character:FindFirstChild("Hallow Essence")
                        if t then Player.Character.Humanoid:EquipTool(t) end
                        pcall(function()
                            local hc = Workspace.Map["Haunted Castle"]
                            if hc and hc:FindFirstChild("Summoner") and hc.Summoner:FindFirstChild("Detection") then
                                topos(hc.Summoner.Detection.CFrame)
                            end
                        end)
                    else
                        topos(CFrame.new(-9529, 316, 6712))
                    end
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
                if e and e:FindFirstChild("HumanoidRootPart") then
                    EquipWeapon(State.SelectedWeapon)
                    topos(e.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().FarmDistance, 0))
                    e.HumanoidRootPart.CanCollide = false
                    e.Humanoid.WalkSpeed = 0
                else
                    topos(CFrame.new(502.7, 143.1, -379.1))
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
                local found = nil
                for _, e in ipairs(enemies:GetChildren()) do
                    if e.Name ~= "rip_indra True Form" and e.Name ~= "Blank Buddy" then
                        local h = e:FindFirstChild("Humanoid")
                        if h and h.Health > 0 and e.PrimaryPart then
                            if (e.PrimaryPart.Position - Vector3.new(-5556, 314, -2988)).Magnitude < 700 then
                                found = e
                                break
                            end
                        end
                    end
                end
                if found and found:FindFirstChild("HumanoidRootPart") then
                    EquipWeapon(State.SelectedWeapon)
                    topos(found.HumanoidRootPart.CFrame * CFrame.new(0, getgenv().FarmDistance, 0))
                    found.HumanoidRootPart.CanCollide = false
                    found.Humanoid.WalkSpeed = 0
                else
                    topos(CFrame.new(-5556, 314, -2988))
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoFarmSea then
            pcall(function()
                local mobs = {}
                if State.AutoShark then table.insert(mobs, "Shark") end
                if State.AutoPiranha then table.insert(mobs, "Piranha") end
                if State.AutoTerrorshark then table.insert(mobs, "Terrorshark") end
                if State.AutoFishCrew then table.insert(mobs, "Fish Crew Member") end
                if State.AutoSeaBeast then table.insert(mobs, "SeaBeast1") end
                if #mobs > 0 then
                    local enemy = FindEnemy(mobs, 3000)
                    if enemy then
                        local trp = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("VehicleSeat")
                        if trp then
                            EquipWeapon(State.SelectedWeapon)
                            topos(trp.CFrame * CFrame.new(0, 55, 0))
                            if trp.Parent:FindFirstChild("Humanoid") then trp.Size = Vector3.new(60, 60, 60) end
                            trp.CanCollide = false
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    local savedCF = nil
    while task.wait(0.3) do
        if State.ProtectBoat then
            pcall(function()
                local boat = GetPlayerBoat()
                local char = Player.Character
                if boat and char and char:FindFirstChild("Humanoid") and not char.Humanoid.Sit then
                    local seat = boat:FindFirstChildWhichIsA("VehicleSeat", true)
                    if seat then
                        if not savedCF then savedCF = seat.CFrame end
                        seat.CFrame = savedCF + Vector3.new(math.random(75,100), math.random(75,100), math.random(75,100))
                    end
                else
                    savedCF = nil
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        pcall(function()
            if State.FindMirage then
                local loc = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("Locations")
                local mirage = loc and loc:FindFirstChild("Mirage Island")
                if mirage then topos(mirage.CFrame * CFrame.new(0, 500, 0)) Notify("[FIND] Mirage!") end
            end
            if State.FindPrehistoric then
                local map = Workspace:FindFirstChild("Map")
                local pre = map and map:FindFirstChild("PrehistoricIsland")
                if pre then topos(pre:GetPivot() * CFrame.new(0, 500, 0)) Notify("[FIND] Prehistoric!") State.FindPrehistoric = false end
            end
            if State.FindFrozen then
                local loc = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("Locations")
                local frozen = loc and loc:FindFirstChild("Frozen Dimension")
                if frozen then topos(frozen.CFrame * CFrame.new(0, 500, 0)) Notify("[FIND] Frozen Dimension!") end
            end
            if State.FindKitsune then
                local map = Workspace:FindFirstChild("Map")
                local kit = map and map:FindFirstChild("KitsuneIsland")
                if kit and kit:FindFirstChild("ShrineActive") then
                    local p = kit.ShrineActive:FindFirstChild("NeonShrinePart")
                    if p then topos(p.CFrame * CFrame.new(0, 40, 10)) Notify("[FIND] Kitsune!") end
                end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoLeviathan then
            pcall(function()
                local sb = Workspace:FindFirstChild("SeaBeasts")
                if not sb then return end
                for _, v in ipairs(sb:GetChildren()) do
                    if v.Name == "Leviathan" and v:FindFirstChild("HumanoidRootPart") then
                        EquipWeapon(State.SelectedWeapon)
                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 900, 100))
                        v.HumanoidRootPart.CanCollide = false
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if State.AutoNewWorld then
            pcall(function()
                if not World1 then State.AutoNewWorld = false return end
                if Player.Data.Level.Value < 700 then Notify("[!] Need Lv.700+") State.AutoNewWorld = false return end
                local iceDoor = Workspace.Map:FindFirstChild("Ice") and Workspace.Map.Ice:FindFirstChild("Door")
                if iceDoor and iceDoor.CanCollide == false then
                    topos(CFrame.new(4849.29883, 5.65138149, 719.611877))
                    task.wait(0.5)
                    CommF_:InvokeServer("DressrosaQuestProgress", "Detective")
                    task.wait(0.5)
                    local key = Player.Backpack:FindFirstChild("Key") or (Player.Character and Player.Character:FindFirstChild("Key"))
                    if key then Player.Character.Humanoid:EquipTool(key) end
                    task.wait(0.3)
                    topos(CFrame.new(1347.7124, 37.3751602, -1325.6488))
                    task.wait(0.5)
                    CommF_:InvokeServer("TravelDressrosa")
                    Notify("[OK] Traveling to Sea 2")
                    State.AutoNewWorld = false
                else
                    local enemy = FindEnemy({"Ice Admiral"}, 5000)
                    if enemy and enemy:FindFirstChild("HumanoidRootPart") then
                        EquipWeapon(State.SelectedWeapon)
                        topos(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
                        enemy.HumanoidRootPart.CanCollide = false
                        enemy.HumanoidRootPart.Size = Vector3.new(60,60,60)
                        enemy.Humanoid.WalkSpeed = 0
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if State.AutoThirdSea then
            pcall(function()
                if not World2 then State.AutoThirdSea = false return end
                if Player.Data.Level.Value < 1500 then Notify("[!] Need Lv.1500+") State.AutoThirdSea = false return end
                local prog = CommF_:InvokeServer("ZQuestProgress", "General")
                if prog == 0 then
                    topos(CFrame.new(-1926.322, 12.82, 1738.309))
                    task.wait(1)
                    CommF_:InvokeServer("ZQuestProgress", "Begin")
                    task.wait(1.5)
                end
                local enemy = FindEnemy({"rip_indra"}, 5000)
                if enemy and enemy:FindFirstChild("HumanoidRootPart") then
                    EquipWeapon(State.SelectedWeapon)
                    topos(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
                    enemy.HumanoidRootPart.CanCollide = false
                    enemy.Humanoid.WalkSpeed = 0
                    task.wait(0.5)
                    CommF_:InvokeServer("TravelZou")
                else
                    topos(CFrame.new(-26880.934, 22.849, 473.19))
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if State.AutoV2 then
            pcall(function()
                local r = CommF_:InvokeServer("Alchemist","1")
                if r == 0 then
                    topos(CFrame.new(-2779.83521, 72.9661407, -3574.02002))
                    task.wait(1.3)
                    CommF_:InvokeServer("Alchemist","2")
                elseif r == 1 then
                    for _, name in ipairs({"Flower 1","Flower 2","Flower 3"}) do
                        if not Player.Backpack:FindFirstChild(name) and not Player.Character:FindFirstChild(name) then
                            local obj = Workspace:FindFirstChild(name)
                            if obj then topos(obj.CFrame) break end
                        end
                    end
                    local z = FindEnemy({"Zombie"}, 5000)
                    if z and z:FindFirstChild("HumanoidRootPart") then
                        topos(z.HumanoidRootPart.CFrame * CFrame.new(0,15,0))
                    end
                elseif r == 2 then
                    CommF_:InvokeServer("Alchemist","3")
                end
            end)
        end
        if State.AutoV3 then
            pcall(function()
                local r = CommF_:InvokeServer("Wenlocktoad","1")
                if r == 0 then CommF_:InvokeServer("Wenlocktoad","2")
                elseif r == 2 then CommF_:InvokeServer("Wenlocktoad","3")
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if State.AutoTrial then
            pcall(function()
                local race = Player.Data.Race.Value
                if race == "Human" or race == "Ghoul" then
                    local enemies = Workspace:FindFirstChild("Enemies")
                    if enemies then
                        for _, e in ipairs(enemies:GetChildren()) do
                            local h = e:FindFirstChild("Humanoid")
                            if h and h.Health > 0 then
                                h.Health = 0
                                if e:FindFirstChild("HumanoidRootPart") then e.HumanoidRootPart.CanCollide = false end
                            end
                        end
                    end
                elseif race == "Skypiea" then
                    local trial = Workspace.Map:FindFirstChild("SkyTrial")
                    if trial and trial:FindFirstChild("Model") then
                        for _, o in pairs(trial.Model:GetDescendants()) do
                            if o.Name == "snowisland_Cylinder.081" then
                                if HRP then HRP.CFrame = o.CFrame end
                                break
                            end
                        end
                    end
                elseif race == "Cyborg" then
                    topos(CFrame.new(28654, 14898, -30))
                elseif race == "Mink" then
                    for _, o in pairs(Workspace:GetDescendants()) do
                        if o.Name == "StartPoint" then
                            topos(o.CFrame * CFrame.new(0, 10, 0))
                            break
                        end
                    end
                elseif race == "Fishman" then
                    local beast = Workspace:FindFirstChild("SeaBeasts") and Workspace.SeaBeasts:FindFirstChild("SeaBeast1")
                    if beast and beast:FindFirstChild("HumanoidRootPart") then
                        topos(beast.HumanoidRootPart.CFrame)
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if State.AutoKillAfterTrial then
            pcall(function()
                local chars = Workspace:FindFirstChild("Characters")
                if not chars then return end
                for _, v in pairs(chars:GetChildren()) do
                    if v.Name ~= Player.Name and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                        if v.Humanoid.Health > 0 and (HRP.Position - v.HumanoidRootPart.Position).Magnitude <= 250 then
                            EquipWeapon(State.SelectedWeapon)
                            topos(v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 15))
                            v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                            v.HumanoidRootPart.CanCollide = false
                            v.Humanoid.WalkSpeed = 0
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        if State.AutoStoreFruit then
            pcall(function()
                local function tryStore(tool)
                    if tool and tool:IsA("Tool") and tool.Name:find("Fruit") then
                        local key = GetFruitKeyFromTool(tool.Name)
                        CommF_:InvokeServer("StoreFruit", key, tool)
                    end
                end
                local char = Player.Character
                if char then for _, tool in ipairs(char:GetChildren()) do tryStore(tool) end end
                for _, tool in ipairs(Player.Backpack:GetChildren()) do tryStore(tool) task.wait(0.3) end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if State.AutoBuyFruit then pcall(function() CommF_:InvokeServer("Cousin", "Buy") end) end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoFindFruit then
            pcall(function()
                local best, bestD = nil, math.huge
                for _, o in ipairs(Workspace:GetChildren()) do
                    if (o:IsA("Tool") or o:IsA("Model")) and string.find(o.Name, "Fruit") then
                        local h = o:IsA("Tool") and o:FindFirstChildWhichIsA("BasePart") or (o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart", true))
                        if h then
                            local d = (h.Position - HRP.Position).Magnitude
                            if d < bestD then best = h bestD = d end
                        end
                    end
                end
                if best then topos(best.CFrame) end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if State.AutoRaid then
            pcall(function()
                CommF_:InvokeServer("RaidsNpc", "Select", State.SelectedChip)
                task.wait(0.5)
                local map = Workspace:FindFirstChild("Map")
                local circle = map and map:FindFirstChild("CircleIsland")
                local summon = circle and circle:FindFirstChild("RaidSummon2")
                local btn = summon and summon:FindFirstChild("Button") and summon.Button:FindFirstChild("Main")
                local cd = btn and btn:FindFirstChild("ClickDetector")
                if cd then fireclickdetector(cd) end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if State.AutoAwaken then
            pcall(function()
                CommF_:InvokeServer("Awakener", "Check")
                CommF_:InvokeServer("Awakener", "Awaken")
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if State.Aimbot and State.SelectedPlayer then
            pcall(function()
                local target = Players:FindFirstChild(State.SelectedPlayer)
                if target and target.Character then
                    local trp = target.Character:FindFirstChild("HumanoidRootPart")
                    if trp then
                        local tool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
                        if tool and tool:FindFirstChild("RemoteEvent") then
                            tool.RemoteEvent:FireServer(trp.Position)
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if State.TeleportPlayer and State.SelectedPlayer then
            pcall(function()
                local p = Players:FindFirstChild(State.SelectedPlayer)
                if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    topos(p.Character.HumanoidRootPart.CFrame)
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if State.AutoStats then
            pcall(function()
                local stats = {{"Melee", State.StatMelee},{"Defense", State.StatDefense},{"Sword", State.StatSword},{"Gun", State.StatGun},{"Demon Fruit", State.StatFruit}}
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
    while task.wait(0.05) do
        if State.FastAttack then
            pcall(AttackNoCoolDown)
            task.wait(State.FastAttackDelay)
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if State.BringMob and (State.AutoFarm or State.AutoFarmNearest or State.AutoFarmMaterial or State.AutoFarmBones or State.AutoBoss or State.AutoCakePrince or State.AutoDoughKing or State.AutoEliteHunter or State.AutoSoulReaper) then
            pcall(function()
                local enemies = Workspace:FindFirstChild("Enemies")
                if not enemies then return end
                local myPos = HRP.Position
                for _, e in ipairs(enemies:GetChildren()) do
                    local h = e:FindFirstChild("Humanoid")
                    local trp = e:FindFirstChild("HumanoidRootPart")
                    if h and trp and h.Health > 0 then
                        local d = (trp.Position - myPos).Magnitude
                        if d <= State.BringRange and d > 3 then
                            trp.CFrame = CFrame.new(myPos + Vector3.new(0, 0, -3))
                            h.WalkSpeed = 0
                        end
                    end
                end
                if sethiddenproperty then pcall(function() sethiddenproperty(Player, "SimulationRadius", math.huge) end) end
            end)
        end
    end
end)

RunService.Stepped:Connect(function()
    if State.Noclip then
        pcall(function()
            for _, v in pairs(Player.Character:GetDescendants()) do
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
        if State.RemoveNotifications then pcall(function() PlayerGui.Notifications.Enabled = false end) end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if State.AutoFishing then
            pcall(function()
                local char = Player.Character
                local tool = char and char:FindFirstChildWhichIsA("Tool")
                if tool and tool:GetAttribute("InventoryCategory") == "Rod" then
                    if tool:GetAttribute("SkillChargeAlpha") and tool:GetAttribute("SkillChargeAlpha") >= 1 then
                        Net:FindFirstChild("RF/JobToolAbilities"):InvokeServer("Z", true)
                    end
                    local state = tool:GetAttribute("State")
                    if state == "ReeledIn" then
                        RS.FishReplicated.FishingRequest:InvokeServer("StartCasting")
                        task.wait(0.7)
                    elseif state == "Biting" then
                        RS.FishReplicated.FishingRequest:InvokeServer("Catching", true)
                        task.wait(0.25)
                        RS.FishReplicated.FishingRequest:InvokeServer("Catch", 1)
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if State.AutoSellFish then
            pcall(function() Net:FindFirstChild("RF/JobsRemoteFunction"):InvokeServer("FishingNPC", "SellFish") end)
        end
    end
end)

local function createESP(part, text, color, category)
    if not part or not part:IsA("BasePart") then return end
    category = category or "misc"
    local existing = State.ESPObjects[part]
    if existing and existing.Parent and existing:FindFirstChild("ESPLabel") then
        existing.ESPLabel.Text = text
        return
    end
    local bb = Instance.new("BillboardGui")
    bb.Name = "SysxESP_" .. category
    bb.Size = UDim2.new(0, 140, 0, 30)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = part
    local lbl = Instance.new("TextLabel")
    lbl.Name = "ESPLabel"
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(255,255,255)
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.new(0,0,0)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold
    lbl.Parent = bb
    State.ESPObjects[part] = bb
end

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            for part, bb in pairs(State.ESPObjects) do
                if not bb.Parent or not part.Parent then
                    pcall(function() bb:Destroy() end)
                    State.ESPObjects[part] = nil
                end
            end
            local myPos = HRP.Position
            if State.ESPPlayer then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= Player and plr.Character then
                        local trp = plr.Character:FindFirstChild("HumanoidRootPart")
                        if trp then
                            local d = math.floor((trp.Position - myPos).Magnitude)
                            createESP(trp, d.." | "..plr.Name, Color3.fromRGB(255,80,80), "Player")
                        end
                    end
                end
            end
            if State.ESPFruit then
                for _, o in ipairs(Workspace:GetChildren()) do
                    if (o:IsA("Tool") or o:IsA("Model")) and string.find(o.Name, "Fruit") then
                        local h = o:IsA("Tool") and o:FindFirstChildWhichIsA("BasePart") or (o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart", true))
                        if h then
                            local d = math.floor((h.Position - myPos).Magnitude)
                            createESP(h, d.." | "..o.Name, Color3.fromRGB(255,200,80), "Fruit")
                        end
                    end
                end
            end
            if State.ESPChest then
                for _, c in ipairs(CollectionService:GetTagged("_ChestTagged")) do
                    if not c:GetAttribute("IsDisabled") then
                        local pp = c:FindFirstChildWhichIsA("BasePart") or c.PrimaryPart
                        if pp then
                            local d = math.floor((pp.Position - myPos).Magnitude)
                            createESP(pp, d.." | Chest", Color3.fromRGB(255,215,0), "Chest")
                        end
                    end
                end
            end
            if State.ESPIsland then
                local loc = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("Locations")
                if loc then
                    for _, c in ipairs(loc:GetChildren()) do
                        if c:IsA("BasePart") then
                            local d = math.floor((c.Position - myPos).Magnitude)
                            createESP(c, d.." | "..c.Name, Color3.fromRGB(80,200,255), "Island")
                        end
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
                                local d = math.floor((trp.Position - myPos).Magnitude)
                                createESP(trp, d.." | "..e.Name, Color3.fromRGB(255,50,50), "Boss")
                            end
                        end
                    end
                end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
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
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

Player.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

ShowTab("Farm")
Notify("[LAUNCH] SysxHub v2.0 - Logo & Banner Updated")
