--[[
================================================================
 SYSX HUB - v1.0 | Created by Ramanotsugarr
 Full Code - Part 1/2
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

local CONFIG = {
    Name = "SysxHub",
    Version = "v1.0",
    Build = "SysxHub v1.0 | Created by Ramanotsugarr",
    Credit = "Ramanotsugarr",
    Logo = "rbxassetid://136425814447688",
    OpenClose = "rbxassetid://70792832229220",
    Discord = "https://discord.gg/E5kQJW3hn",
    Background = Color3.fromRGB(10, 8, 18),
    Panel = Color3.fromRGB(17, 13, 29),
    Panel2 = Color3.fromRGB(23, 18, 38),
    Panel3 = Color3.fromRGB(30, 24, 48),
    Purple = Color3.fromRGB(125, 70, 255),
    Blue = Color3.fromRGB(80, 140, 255),
    White = Color3.fromRGB(255, 255, 255),
    Radius = 10,
    MaxLevel = 2800,
    AttackRange = 55,
    FarmDelay = 0.12,
    RandomFruitCooldown = 7200,
    RaidMinLevel = 1500,
    ChestDelay = 0.5,
    ChestWaitCooldown = 5,
    BringMobRange = 50,
}

local State = {
    -- Farm
    AutoFarm = false, AutoQuest = false, AutoKillNearest = false,
    AutoBoss = false, AutoChest = false, AutoMaterial = false,
    SelectedWeapon = nil, SelectedCategory = nil,
    SelectedBoss = nil, SelectedBossSea = nil,
    -- Sea
    SelectedSeaMob = nil, AutoFarmSea = false, AutoKillSeaBeast = false,
    AutoTeleportMobs = false, AutoDrive = false, AutoBuyBoat = false,
    DeleteRocks = false, HeightBoat = 0, SpeedBoat = 0,
    LockMoon = false, AzureEmberCount = 0,
    AutoKillGolem = false, AutoPrehistoric = false, AutoCollectBone = false,
    AutoTrade = false,
    -- Quest
    AutoCDK = false, AutoDarkDagger = false, AutoSoulGuitar = false,
    AutoYama = false, AutoTushita = false, AutoBuddySword = false,
    AutoKillIndra = false, AutoSpawnDoughKing = false,
    SelectedSecretLocation = nil, SelectedSecretQuest = nil, ActiveSecretQuest = nil,
    -- Fruit/Raid
    AutoFruit = false, FruitSniper = false, AutoRaid = false, AutoBuyChip = false,
    RandomFruit = false, StoreFruit = false, LastRandomFruit = 0,
    SelectedRaid = nil,
    -- Fishing
    AutoFishing = false, AutoCatch = false,
    -- PvP
    PvPMode = false, ESPPlayers = false, Aimbot = false, Hitbox = false,
    HitboxPart = nil, KillAura = false, LastKillAura = 0,
    -- Stats
    AutoAddStats = false,
    StatsMelee = 0, StatsDefense = 0, StatsSword = 0, StatsGun = 0, StatsBloxFruit = 0,
    -- Misc
    AntiAFK = true, BringMob = false, LastBring = 0, InfiniteJump = false,
    BoostFPS = false, OriginalLighting = nil,
    JobIDInput = "", CodeInput = "",
    -- General
    Notifications = true, UIAnimation = true,
    CurrentIsland = nil, OpenedChests = {}, SearchInput = "",
}

--// CLEAN OLD
local old = PlayerGui:FindFirstChild("SysxHub")
if old then old:Destroy() end

--// HELPERS
local function Create(cls, props)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do
        pcall(function() o[k] = v end)
    end
    return o
end

local function Corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or CONFIG.Radius)
    c.Parent = p
    return c
end

local function Stroke(p, c, t, tr)
    local s = Instance.new("UIStroke")
    s.Color = c or CONFIG.Purple
    s.Thickness = t or 1
    s.Transparency = tr or 0
    s.Parent = p
    return s
end

local function Gradient(p, c1, c2, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1 or CONFIG.Purple, c2 or CONFIG.Blue)
    g.Rotation = rot or 45
    g.Parent = p
    return g
end

local function Padding(p, l, r, t, b)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, l or 0)
    pad.PaddingRight = UDim.new(0, r or 0)
    pad.PaddingTop = UDim.new(0, t or 0)
    pad.PaddingBottom = UDim.new(0, b or 0)
    pad.Parent = p
    return pad
end

local function Tween(o, props, time)
    TweenService:Create(o, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local function GetCharacter() return Player.Character end
local function GetHRP() local c = Player.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function GetDist(a, b) return (a - b).Magnitude end

local function SafeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[SysxHub Error]", err) return false, err end
    return true
end

local function IsAlive(m)
    local h = m and m:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function IsNPC(m)
    if not m or m == Player.Character then return false end
    if not m:FindFirstChildOfClass("Humanoid") then return false end
    if not m:FindFirstChild("HumanoidRootPart") then return false end
    if Players:GetPlayerFromCharacter(m) then return false end
    return IsAlive(m)
end

local function IsEnemyPlayer(m)
    if not m or m == Player.Character then return false end
    local plr = Players:GetPlayerFromCharacter(m)
    if not plr then return false end
    if plr:IsFriendsWith(Player.UserId) then return false end
    return IsAlive(m)
end

local function FindRemote(...)
    local kws = {...}
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local ln = string.lower(obj.Name)
            for _, kw in ipairs(kws) do
                if string.find(ln, string.lower(kw)) then return obj end
            end
        end
    end
    return nil
end

-- Remote Auto-Detect
local REMOTE_RandomFruit = FindRemote("randomfruit", "gacha", "zioles", "rollfruit")
local REMOTE_BuyChip = FindRemote("buychip", "purchasechip", "raidchip", "microchip")
local REMOTE_StoreFruit = FindRemote("storefruit", "fruitstore", "savefruit")
local REMOTE_Redeem = FindRemote("redeem", "promocode", "code")
local REMOTE_Stats = FindRemote("stats", "statpoint", "updatestats", "point")
local REMOTE_Trade = FindRemote("trade", "traderequest", "tradereq")
local REMOTE_Boat = FindRemote("boat", "spawnboat", "boatspawn")

print("========================================")
print("   SYSX REMOTE AUTO-DETECT")
print("========================================")
print("RandomFruit:", REMOTE_RandomFruit and REMOTE_RandomFruit.Name or "NOT FOUND")
print("BuyChip:", REMOTE_BuyChip and REMOTE_BuyChip.Name or "NOT FOUND")
print("StoreFruit:", REMOTE_StoreFruit and REMOTE_StoreFruit.Name or "NOT FOUND")
print("Stats:", REMOTE_Stats and REMOTE_Stats.Name or "NOT FOUND")
print("Trade:", REMOTE_Trade and REMOTE_Trade.Name or "NOT FOUND")
print("Boat:", REMOTE_Boat and REMOTE_Boat.Name or "NOT FOUND")
print("========================================")

--// FUNC: MOB LEVEL (untuk Auto Farm Level)
local function GetMobLevel(mob)
    -- Prioritas 1: dari Attribute
    local lvl = mob:GetAttribute("Level") or mob:GetAttribute("level")
    if lvl then return lvl end
    
    -- Prioritas 2: dari Humanoid MaxHealth (estimasi)
    local hum = mob:FindFirstChildOfClass("Humanoid")
    if hum then
        local mh = hum.MaxHealth
        if mh <= 50 then return 5
        elseif mh <= 100 then return 10
        elseif mh <= 200 then return 20
        elseif mh <= 500 then return 40
        elseif mh <= 1000 then return 80
        elseif mh <= 2000 then return 120
        elseif mh <= 4000 then return 200
        elseif mh <= 8000 then return 300
        elseif mh <= 15000 then return 450
        elseif mh <= 30000 then return 600
        elseif mh <= 60000 then return 800
        elseif mh <= 100000 then return 1000
        elseif mh <= 200000 then return 1300
        elseif mh <= 400000 then return 1600
        else return math.floor(mh / 500) end
    end
    return 0
end

local function FindMobByLevel(playerLevel, tolerance)
    tolerance = tolerance or 100
    local list = {}
    for _, mob in ipairs(workspace:GetDescendants()) do
        if mob:FindFirstChildOfClass("Humanoid")
            and mob:FindFirstChild("HumanoidRootPart")
            and not Players:GetPlayerFromCharacter(mob)
            and IsAlive(mob) then
            
            local mLvl = GetMobLevel(mob)
            local diff = math.abs(mLvl - playerLevel)
            if diff <= tolerance then
                table.insert(list, {model = mob, level = mLvl, diff = diff})
            end
        end
    end
    table.sort(list, function(a, b) return a.diff < b.diff end)
    return list
end

local function TweenToMob(mob, speed)
    local hrp = GetHRP()
    if not hrp then return end
    local targetHRP = mob:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end
    
    speed = speed or 150
    local startCF = hrp.CFrame
    local targetCF = CFrame.new(targetHRP.Position + Vector3.new(0, 3, 0))
    local distance = (startCF.Position - targetCF.Position).Magnitude
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

--// FUNC: SEARCH GLOBAL
local function GlobalSearch(query)
    if not query or query == "" then return {} end
    local q = string.lower(query)
    local results = {}
    
    -- Cari Secret Quest
    for loc, quests in pairs(SecretQuests) do
        for _, quest in ipairs(quests) do
            if string.find(string.lower(quest.Name), q) then
                table.insert(results, {type = "Quest", location = loc, name = quest.Name})
            end
        end
    end
    
    -- Cari Boss
    for sea, bosses in pairs(BossData) do
        for _, boss in ipairs(bosses) do
            if string.find(string.lower(boss.Name), q) then
                table.insert(results, {type = "Boss", location = boss.Location, name = boss.Name})
            end
        end
    end
    
    -- Cari Island
    for sea, islands in pairs(AllIslands) do
        for _, island in ipairs(islands) do
            if string.find(string.lower(island.Name), q) then
                table.insert(results, {type = "Island", location = sea, name = island.Name})
            end
        end
    end
    
    -- Cari Weapon
    local char = Player.Character
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and string.find(string.lower(tool.Name), q) then
                table.insert(results, {type = "Weapon", location = "Equipped", name = tool.Name})
            end
        end
    end
    for _, tool in ipairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and string.find(string.lower(tool.Name), q) then
            table.insert(results, {type = "Weapon", location = "Backpack", name = tool.Name})
        end
    end
    
    return results
end

--// FUNC: WEAPON CATEGORY
local function GetWeaponCategory(weaponName)
    local name = string.lower(weaponName)
    local swordKws = {"katana","cutlass","sword","saber","rapier","blade","trident","pole","reaper","scythe","dagger","hooks","anchor","cursed","hallow","buddy","shark saw","warden","rengoku","tushita","yama"}
    for _, kw in ipairs(swordKws) do
        if string.find(name, kw) then return "Sword" end
    end
    local gunKws = {"gun","pistol","slingshot","rifle","bazooka","cannon","musket","sniper","flintlock"}
    for _, kw in ipairs(gunKws) do
        if string.find(name, kw) then return "Gun" end
    end
    local fruitKws = {"fruit","dough","leopard","kitsune","dragon","venom","shadow","control","spirit","mammoth","trex","rumble","portal","phoenix","sound","spider","buddha","magma","quake","light","dark","ice","sand","flame"}
    for _, kw in ipairs(fruitKws) do
        if string.find(name, kw) then return "Fruit" end
    end
    return "Melee"
end

local function GetWeaponsByCategory(category)
    local list = {}
    local char = Player.Character
    if not char then return list end
    local function check(t)
        if t:IsA("Tool") and GetWeaponCategory(t.Name) == category then
            table.insert(list, t)
        end
    end
    for _, t in ipairs(char:GetChildren()) do check(t) end
    for _, t in ipairs(Player.Backpack:GetChildren()) do check(t) end
    return list
end

local function SelectWeapon(weaponName)
    local char = Player.Character
    if not char then return false end
    local found = nil
    for _, c in ipairs(char:GetChildren()) do
        if c:IsA("Tool") and c.Name == weaponName then found = c break end
    end
    if not found then
        for _, c in ipairs(Player.Backpack:GetChildren()) do
            if c:IsA("Tool") and c.Name == weaponName then found = c break end
        end
    end
    if not found then Notify("Weapon tidak ada: " .. weaponName) return false end
    State.SelectedWeapon = found.Name
    State.SelectedCategory = GetWeaponCategory(found.Name)
    pcall(function() found.Parent = char end)
    Notify("Equipped [" .. State.SelectedCategory .. "]: " .. found.Name)
    return true
end

local function EquipWeapon()
    local char = Player.Character
    if not char then return nil end
    if State.SelectedWeapon then
        local held = char:FindFirstChild(State.SelectedWeapon)
        if held and held:IsA("Tool") then return held end
        for _, c in ipairs(Player.Backpack:GetChildren()) do
            if c:IsA("Tool") and c.Name == State.SelectedWeapon then
                c.Parent = char return c
            end
        end
    end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then return tool end
    for _, c in ipairs(Player.Backpack:GetChildren()) do
        if c:IsA("Tool") then c.Parent = char return c end
    end
    return nil
end

local function AttackNearest(maxDist)
    maxDist = maxDist or CONFIG.AttackRange
    local hrp = GetHRP()
    if not hrp then return end
    local closest, dist = nil, math.huge
    for _, enemy in ipairs(ScanEnemies()) do
        local ehrp = enemy:FindFirstChild("HumanoidRootPart")
        if ehrp then
            local d = GetDist(ehrp.Position, hrp.Position)
            if d < dist and d <= maxDist then closest, dist = enemy, d end
        end
    end
    if closest then
        local tool = EquipWeapon()
        if tool then pcall(function() tool:Activate() end) end
    end
end

local function TeleportTo(pos)
    local hrp = GetHRP()
    if not hrp then return end
    hrp.CFrame = CFrame.new(pos)
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

local function FindKOKO()
    for _, obj in ipairs(workspace:GetChildren()) do
        if (obj.Name == "Koko" or string.lower(obj.Name) == "koko")
            and obj:FindFirstChildOfClass("Humanoid") then
            return obj
        end
    end
    return nil
end

local function FindChests()
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("BasePart") then
                local name = string.lower(obj.Name)
                if string.find(name, "chest") or string.find(name, "treasure") or string.find(name, "reward") then
                    local isOpened = obj.Transparency >= 1
                        or obj:GetAttribute("Opened") == true
                        or (obj.Parent and obj.Parent:FindFirstChild("Opened"))
                    if not isOpened and obj.Parent then
                        table.insert(list, obj)
                    end
                end
            end
        end)
    end
    return list
end

local function GetChestKey(chest)
    local pos = chest.Position
    return string.format("%.1f_%.1f_%.1f", pos.X, pos.Y, pos.Z)
end

local function FindMaterials()
    local list = {}
    local kws = {"material", "ore", "wood", "stone", "crystal", "shard", "relic"}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            for _, kw in ipairs(kws) do
                if string.find(string.lower(obj.Name), kw) then
                    table.insert(list, obj) break
                end
            end
        end
    end
    return list
end

local function FindFruits()
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "fruit") then
            table.insert(list, obj)
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

local function GetHeldChip()
    local char = Player.Character
    if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and string.find(string.lower(tool.Name), "chip") then
            return tool
        end
    end
    return nil
end

--// FUNC: SEA MOBS
local function FindSeaMob(mobName)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == mobName and obj:FindFirstChildOfClass("Humanoid") then
            if obj:FindFirstChild("HumanoidRootPart") then return obj end
        end
    end
    return nil
end

local function TeleportToSeaMob(mobName)
    local mob = FindSeaMob(mobName)
    if not mob then return false end
    local hrp = mob:FindFirstChild("HumanoidRootPart")
    if hrp then
        TeleportTo(hrp.Position + Vector3.new(0, 3, 0))
        return true
    end
    return false
end

local function FindObjectByKeyword(keyword)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if string.find(string.lower(obj.Name), string.lower(keyword)) then
            if obj:IsA("BasePart") or obj:IsA("Model") then
                return obj
            end
        end
    end
    return nil
end

local function GetPlayerBoat()
    local char = Player.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (string.find(string.lower(obj.Name), "boat")
            or string.find(string.lower(obj.Name), "ship")) then
            if obj.PrimaryPart and GetDist(obj.PrimaryPart.Position, hrp.Position) < 50 then
                return obj
            end
        end
    end
    return nil
end

--// FUNC: IS IN RAID AREA
local function IsInRaidArea()
    local leaderstats = Player:FindFirstChild("leaderstats")
    local LevelValue = leaderstats and leaderstats:FindFirstChild("Level")
    if not LevelValue or LevelValue.Value < CONFIG.RaidMinLevel then return false end
    local hrp = GetHRP()
    if not hrp then return false end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Folder") or obj:IsA("Model") then
            local name = string.lower(obj.Name)
            if string.find(name, "raid") or string.find(name, "room") or string.find(name, "pass") then
                if obj:IsA("BasePart") and GetDist(obj.Position, hrp.Position) <= 500 then return true end
                if obj:IsA("Model") and obj.PrimaryPart and GetDist(obj.PrimaryPart.Position, hrp.Position) <= 500 then return true end
            end
        end
    end
    return false
end

--// FUNC: AUTO ADD STATS
local function AutoAddStats()
    if not REMOTE_Stats then
        Notify("Remote Stats tidak ditemukan")
        return false
    end
    
    -- Cek stat point tersedia
    local leaderstats = Player:FindFirstChild("leaderstats")
    if not leaderstats then return false end
    local Points = leaderstats:FindFirstChild("Points") or leaderstats:FindFirstChild("Stat Points")
    if not Points or Points.Value <= 0 then
        Notify("Tidak ada stat point")
        return false
    end
    
    -- Prioritas: Melee > Defense > Sword > Gun > BloxFruit
    local priority = {
        {Name = "Melee", Value = State.StatsMelee},
        {Name = "Defense", Value = State.StatsDefense},
        {Name = "Sword", Value = State.StatsSword},
        {Name = "Gun", Value = State.StatsGun},
        {Name = "Blox Fruit", Value = State.StatsBloxFruit},
    }
    
    for _, stat in ipairs(priority) do
        if stat.Value > 0 then
            pcall(function()
                if REMOTE_Stats:IsA("RemoteEvent") then
                    REMOTE_Stats:FireServer(stat.Name, stat.Value)
                else
                    REMOTE_Stats:InvokeServer(stat.Name, stat.Value)
                end
            end)
            Notify("Add " .. stat.Name .. ": " .. stat.Value)
            task.wait(0.3)
        end
    end
    
    return true
end

--// FUNC: AUTO TRADE
local function AutoTradeAccept()
    if not REMOTE_Trade then
        Notify("Remote Trade tidak ditemukan")
        return false
    end
    
    -- Cari GUI trade
    local tradeGui = PlayerGui:FindFirstChild("Trade", true) 
                  or PlayerGui:FindFirstChild("TradeFrame", true)
    
    if tradeGui then
        -- Cari tombol Accept / Confirm
        for _, btn in ipairs(tradeGui:GetDescendants()) do
            if btn:IsA("TextButton") then
                local name = string.lower(btn.Name)
                if string.find(name, "accept") or string.find(name, "confirm") then
                    pcall(function() btn:Activate() end)
                    Notify("Trade: " .. btn.Name)
                end
            end
        end
    else
        -- Fire remote langsung
        pcall(function()
            if REMOTE_Trade:IsA("RemoteEvent") then
                REMOTE_Trade:FireServer("Accept")
            else
                REMOTE_Trade:InvokeServer("Accept")
            end
        end)
        Notify("Auto Trade: Fire remote")
    end
    return true
end

--// FUNC: NOTIFY (dibutuhkan sebelum dipakai)
local Gui = Create("ScreenGui", {
    Name = "SysxHub", Parent = PlayerGui, ResetOnSpawn = false,
    IgnoreGuiInset = true, DisplayOrder = 999999,
    ZIndexBehavior = Enum.ZIndexBehavior.Global,
})

local UIScale = Instance.new("UIScale")
UIScale.Scale = 1
UIScale.Parent = Gui

local function UpdateScale()
    if not Camera then return end
    local vp = Camera.ViewportSize
    if vp.X <= 500 then UIScale.Scale = math.clamp(vp.X / 420, 0.82, 1)
    elseif vp.X <= 800 then UIScale.Scale = 0.9
    else UIScale.Scale = 1 end
end
UpdateScale()
if Camera then Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale) end

local OpenButton = Create("ImageButton", {
    Name = "OpenButton", Parent = Gui, BackgroundColor3 = CONFIG.Panel,
    BackgroundTransparency = 0, Size = UDim2.fromOffset(64, 64),
    Position = UDim2.new(0, 18, 0.5, -32), Image = CONFIG.OpenClose,
    AutoButtonColor = false, Visible = true, ZIndex = 100,
})
Corner(OpenButton, 16)
Stroke(OpenButton, CONFIG.Purple, 2, 0.15)
Gradient(OpenButton, CONFIG.Purple, CONFIG.Blue, 45)

local Main = Create("Frame", {
    Name = "Main", Parent = Gui, AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(0, 760, 0, 480),
    BackgroundColor3 = CONFIG.Background, BorderSizePixel = 0,
    Visible = true, ZIndex = 10,
})
Corner(Main, 14)
Stroke(Main, CONFIG.Purple, 1, 0.45)

local MainConstraint = Instance.new("UISizeConstraint")
MainConstraint.MaxSize = Vector2.new(850, 560)
MainConstraint.MinSize = Vector2.new(310, 360)
MainConstraint.Parent = Main

local TopBar = Create("Frame", {
    Name = "TopBar", Parent = Main, BackgroundColor3 = CONFIG.Panel,
    Size = UDim2.new(1, 0, 0, 64), BorderSizePixel = 0, ZIndex = 20,
})
Corner(TopBar, 14)
Gradient(TopBar, CONFIG.Panel, CONFIG.Panel2, 0)

Create("ImageLabel", {
    Name = "Logo", Parent = TopBar, BackgroundTransparency = 1,
    Size = UDim2.fromOffset(48, 48), Position = UDim2.new(0, 10, 0.5, -24),
    Image = CONFIG.Logo, ScaleType = Enum.ScaleType.Fit, ZIndex = 21,
})

Create("TextLabel", {
    Name = "Title", Parent = TopBar, BackgroundTransparency = 1,
    Position = UDim2.new(0, 66, 0, 8), Size = UDim2.new(0, 250, 0, 25),
    Text = "SysxHub", TextColor3 = CONFIG.White, TextSize = 20,
    Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 21,
})

Create("TextLabel", {
    Name = "Subtitle", Parent = TopBar, BackgroundTransparency = 1,
    Position = UDim2.new(0, 67, 0, 33), Size = UDim2.new(0, 400, 0, 18),
    Text = CONFIG.Build, TextColor3 = CONFIG.White,
    TextSize = 11, Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 21,
})

local CloseButton = Create("TextButton", {
    Name = "Close", Parent = TopBar, BackgroundColor3 = CONFIG.Panel2,
    Size = UDim2.fromOffset(38, 38), Position = UDim2.new(1, -50, 0.5, -19),
    Text = "X", TextColor3 = CONFIG.White, TextSize = 20,
    Font = Enum.Font.GothamBold, AutoButtonColor = false, ZIndex = 25,
})
Corner(CloseButton, 10)
Stroke(CloseButton, CONFIG.Purple, 1, 0.5)

local Sidebar = Create("Frame", {
    Name = "Sidebar", Parent = Main, BackgroundColor3 = CONFIG.Panel,
    Position = UDim2.new(0, 0, 0, 64), Size = UDim2.new(0, 155, 1, -64),
    BorderSizePixel = 0, ZIndex = 15,
})
Corner(Sidebar, 14)

local TabList = Create("ScrollingFrame", {
    Name = "Tabs", Parent = Sidebar, BackgroundTransparency = 1,
    Position = UDim2.new(0, 8, 0, 10), Size = UDim2.new(1, -16, 1, -20),
    CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 2, ScrollBarImageColor3 = CONFIG.Purple,
    BorderSizePixel = 0, ZIndex = 16,
})
local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 5)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabList

local Content = Create("Frame", {
    Name = "Content", Parent = Main, BackgroundTransparency = 1,
    Position = UDim2.new(0, 155, 0, 64), Size = UDim2.new(1, -155, 1, -64),
    BorderSizePixel = 0, ZIndex = 11,
})

local Notification = Create("TextLabel", {
    Name = "Notification", Parent = Gui, AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -20), Size = UDim2.fromOffset(340, 44),
    BackgroundColor3 = CONFIG.Panel, BackgroundTransparency = 0.05,
    Text = "", TextColor3 = CONFIG.White, TextSize = 13,
    Font = Enum.Font.GothamMedium, Visible = false, ZIndex = 500,
})
Corner(Notification, 10)
Stroke(Notification, CONFIG.Purple, 1, 0.35)

local NotifyToken = 0
local function Notify(text)
    if not State.Notifications then return end
    NotifyToken += 1
    local token = NotifyToken
    Notification.Text = tostring(text)
    Notification.Visible = true
    Notification.TextTransparency = 1
    Notification.BackgroundTransparency = 1
    Tween(Notification, {TextTransparency = 0, BackgroundTransparency = 0.05}, 0.2)
    task.delay(2.5, function()
        if token ~= NotifyToken then return end
        Tween(Notification, {TextTransparency = 1, BackgroundTransparency = 1}, 0.2)
        task.wait(0.2)
        if token == NotifyToken then Notification.Visible = false end
    end)
end

--// PAGE SYSTEM
local Pages, Tabs = {}, {}

local function CreatePage(name)
    local P = Create("ScrollingFrame", {
        Name = name, Parent = Content, BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 10), Size = UDim2.new(1, -20, 1, -20),
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3, ScrollBarImageColor3 = CONFIG.Purple,
        BorderSizePixel = 0, Visible = false, ZIndex = 12,
    })
    Padding(P, 8, 8, 8, 8)
    local L = Instance.new("UIListLayout")
    L.Padding = UDim.new(0, 9)
    L.SortOrder = Enum.SortOrder.LayoutOrder
    L.Parent = P
    Pages[name] = P
    return P
end

local function CreateSection(parent, title, desc)
    local S = Create("Frame", {
        Parent = parent, BackgroundColor3 = CONFIG.Panel,
        Size = UDim2.new(1, 0, 0, 72), BorderSizePixel = 0, ZIndex = 13,
    })
    Corner(S, 10)
    Stroke(S, CONFIG.Purple, 1, 0.85)
    Create("TextLabel", {
        Parent = S, BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 10), Size = UDim2.new(1, -28, 0, 23),
        Text = title, TextColor3 = CONFIG.White, TextSize = 15,
        Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
    })
    Create("TextLabel", {
        Parent = S, BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 35), Size = UDim2.new(1, -28, 0, 25),
        Text = desc or "", TextColor3 = CONFIG.White, TextSize = 11,
        Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
    })
    return S
end

local function CreateButton(parent, text, cb)
    local B = Create("TextButton", {
        Parent = parent, BackgroundColor3 = CONFIG.Panel,
        Size = UDim2.new(1, 0, 0, 48), Text = text,
        TextColor3 = CONFIG.White, TextSize = 13,
        Font = Enum.Font.GothamMedium, AutoButtonColor = false,
        BorderSizePixel = 0, ZIndex = 13,
    })
    Corner(B, 9)
    Stroke(B, CONFIG.Purple, 1, 0.7)
    Gradient(B, CONFIG.Panel, CONFIG.Panel2, 45)
    B.MouseEnter:Connect(function() Tween(B, {BackgroundColor3 = CONFIG.Panel2}, 0.15) end)
    B.MouseLeave:Connect(function() Tween(B, {BackgroundColor3 = CONFIG.Panel}, 0.15) end)
    B.Activated:Connect(function()
        if cb then
            local ok, err = pcall(cb)
            if not ok then warn("[Btn Error]", err) Notify("Error: " .. tostring(err)) end
        end
    end)
    return B
end

local function CreateToggle(parent, text, default, cb)
    local S2 = default or false
    local B = Create("TextButton", {
        Parent = parent, BackgroundColor3 = CONFIG.Panel,
        Size = UDim2.new(1, 0, 0, 48), Text = "",
        AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 13,
    })
    Corner(B, 9)
    Stroke(B, CONFIG.Purple, 1, 0.7)
    Create("TextLabel", {
        Parent = B, BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -75, 1, 0),
        Text = text, TextColor3 = CONFIG.White, TextSize = 13,
        Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
    })
    local Indicator = Create("Frame", {
        Parent = B, BackgroundColor3 = Color3.fromRGB(55, 50, 65),
        Size = UDim2.fromOffset(42, 22), Position = UDim2.new(1, -56, 0.5, -11), ZIndex = 14,
    })
    Corner(Indicator, 20)
    local Dot = Create("Frame", {
        Parent = Indicator, BackgroundColor3 = Color3.fromRGB(190, 185, 200),
        Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 3, 0.5, -8), ZIndex = 15,
    })
    Corner(Dot, 20)
    local function Update()
        if S2 then
            Indicator.BackgroundColor3 = CONFIG.Purple
            Dot.BackgroundColor3 = Color3.new(1, 1, 1)
            Tween(Dot, {Position = UDim2.new(1, -19, 0.5, -8)}, 0.15)
        else
            Indicator.BackgroundColor3 = Color3.fromRGB(55, 50, 65)
            Dot.BackgroundColor3 = Color3.fromRGB(190, 185, 200)
            Tween(Dot, {Position = UDim2.new(0, 3, 0.5, -8)}, 0.15)
        end
    end
    B.Activated:Connect(function()
        S2 = not S2 Update()
        if cb then
            local ok, err = pcall(cb, S2)
            if not ok then warn("[Toggle Error]", err) Notify("Error: " .. tostring(err)) end
        end
    end)
    Update()
    return B
end

local function CreateInput(parent, placeholder, cb)
    local Box = Create("TextBox", {
        Parent = parent, BackgroundColor3 = CONFIG.Panel2,
        Size = UDim2.new(1, 0, 0, 40), Text = "",
        PlaceholderText = placeholder or "Search...",
        PlaceholderColor3 = CONFIG.White,
        TextColor3 = CONFIG.White, TextSize = 13,
        Font = Enum.Font.GothamMedium, AutoButtonColor = false,
        BorderSizePixel = 0, ZIndex = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    })
    Corner(Box, 9)
    Stroke(Box, CONFIG.Purple, 1, 0.7)
    Padding(Box, 12, 12, 0, 0)
    Box:GetPropertyChangedSignal("Text"):Connect(function()
        if cb then pcall(cb, Box.Text) end
    end)
    return Box
end

--// DROPDOWN COMPONENT
local function CreateDropdown(parent, title, options, cb)
    local Holder = Create("Frame", {
        Parent = parent, BackgroundColor3 = CONFIG.Panel,
        Size = UDim2.new(1, 0, 0, 48), BorderSizePixel = 0, ZIndex = 13,
        ClipsDescendants = false,
    })
    Corner(Holder, 9)
    Stroke(Holder, CONFIG.Purple, 1, 0.7)

    local Selected = options[1] or "Select"
    local IsOpen = false

    local TitleLbl = Create("TextLabel", {
        Parent = Holder, BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -100, 1, 0),
        Text = title .. ": " .. Selected,
        TextColor3 = CONFIG.White, TextSize = 13,
        Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
    })

    local Arrow = Create("TextLabel", {
        Parent = Holder, BackgroundTransparency = 1,
        Position = UDim2.new(1, -70, 0, 0), Size = UDim2.new(0, 20, 1, 0),
        Text = "v",
        TextColor3 = CONFIG.White, TextSize = 12,
        Font = Enum.Font.GothamBold, ZIndex = 14,
    })

    local ListHolder = Create("ScrollingFrame", {
        Parent = Holder, BackgroundColor3 = CONFIG.Panel2,
        Position = UDim2.new(0, 0, 1, 4), Size = UDim2.new(1, 0, 0, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3, ScrollBarImageColor3 = CONFIG.Purple,
        BorderSizePixel = 0, ZIndex = 200, Visible = false,
    })
    Corner(ListHolder, 9)
    Stroke(ListHolder, CONFIG.Purple, 1, 0.5)

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 4)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = ListHolder

    local function RefreshOptions()
        for _, c in ipairs(ListHolder:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for i, opt in ipairs(options) do
            local OptBtn = Create("TextButton", {
                Parent = ListHolder, BackgroundColor3 = CONFIG.Panel,
                Size = UDim2.new(1, -8, 0, 36),
                Position = UDim2.new(0, 4, 0, 4),
                Text = opt,
                TextColor3 = CONFIG.White, TextSize = 12,
                Font = Enum.Font.GothamMedium, AutoButtonColor = false,
                BorderSizePixel = 0, LayoutOrder = i, ZIndex = 201,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            Corner(OptBtn, 6)
            Padding(OptBtn, 10, 10, 0, 0)
            OptBtn.MouseEnter:Connect(function() Tween(OptBtn, {BackgroundColor3 = CONFIG.Purple}, 0.1) end)
            OptBtn.MouseLeave:Connect(function() Tween(OptBtn, {BackgroundColor3 = CONFIG.Panel}, 0.1) end)
            OptBtn.Activated:Connect(function()
                Selected = opt
                TitleLbl.Text = title .. ": " .. opt
                ListHolder.Visible = false
                ListHolder.Size = UDim2.new(1, 0, 0, 0)
                IsOpen = false
                if cb then pcall(cb, opt) end
            end)
        end
    end

    Holder.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            if IsOpen then
                ListHolder.Visible = false
                ListHolder.Size = UDim2.new(1, 0, 0, 0)
                IsOpen = false
            else
                RefreshOptions()
                local h = math.min(#options * 40 + 8, 200)
                ListHolder.Size = UDim2.new(1, 0, 0, h)
                ListHolder.Visible = true
                IsOpen = true
            end
        end
    end)

    return Holder
end

--// SLIDER COMPONENT
local function CreateSlider(parent, title, minVal, maxVal, defaultVal, cb)
    local val = defaultVal or minVal
    local Holder = Create("Frame", {
        Parent = parent, BackgroundColor3 = CONFIG.Panel,
        Size = UDim2.new(1, 0, 0, 56), BorderSizePixel = 0, ZIndex = 13,
    })
    Corner(Holder, 9)
    Stroke(Holder, CONFIG.Purple, 1, 0.7)

    local TitleLbl = Create("TextLabel", {
        Parent = Holder, BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 6), Size = UDim2.new(1, -80, 0, 18),
        Text = title, TextColor3 = CONFIG.White, TextSize = 13,
        Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14,
    })

    local ValueLbl = Create("TextLabel", {
        Parent = Holder, BackgroundTransparency = 1,
        Position = UDim2.new(1, -70, 0, 6), Size = UDim2.new(0, 60, 0, 18),
        Text = tostring(val), TextColor3 = CONFIG.White, TextSize = 13,
        Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 14,
    })

    local Bar = Create("Frame", {
        Parent = Holder, BackgroundColor3 = CONFIG.Panel2,
        Position = UDim2.new(0, 14, 0, 34), Size = UDim2.new(1, -28, 0, 10),
        BorderSizePixel = 0, ZIndex = 14,
    })
    Corner(Bar, 5)

    local Fill = Create("Frame", {
        Parent = Bar, BackgroundColor3 = CONFIG.Purple,
        Size = UDim2.new((val - minVal) / (maxVal - minVal), 0, 1, 0),
        BorderSizePixel = 0, ZIndex = 15,
    })
    Corner(Fill, 5)

    local Btn = Create("TextButton", {
        Parent = Holder, BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 1, 0),
        Text = "", AutoButtonColor = false, ZIndex = 16,
    })

    local dragging = false
    local function Update(mouseX)
        local abs = Bar.AbsolutePosition
        local size = Bar.AbsoluteSize
        local rel = math.clamp((mouseX - abs.X) / size.X, 0, 1)
        val = math.floor(minVal + (maxVal - minVal) * rel + 0.5)
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        ValueLbl.Text = tostring(val)
        if cb then pcall(cb, val) end
    end

    Btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            Update(input.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            Update(input.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return Holder
end

local function CreateTab(name, order)
    local B = Create("TextButton", {
        Parent = TabList, BackgroundColor3 = CONFIG.Panel,
        Size = UDim2.new(1, 0, 0, 40), Text = "",
        AutoButtonColor = false, BorderSizePixel = 0,
        LayoutOrder = order, ZIndex = 17,
    })
    Corner(B, 8)
    local L = Create("TextLabel", {
        Parent = B, BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -20, 1, 0),
        Text = name, TextColor3 = CONFIG.White,
        TextSize = 12, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 18,
    })
    Tabs[name] = {Button = B, Label = L}
    return B
end

local function ShowTab(name)
    for pageName, page in pairs(Pages) do page.Visible = pageName == name end
    for tabName, data in pairs(Tabs) do
        local active = tabName == name
        if active then
            data.Button.BackgroundColor3 = CONFIG.Purple
            data.Label.TextColor3 = CONFIG.White
        else
            data.Button.BackgroundColor3 = CONFIG.Panel
            data.Label.TextColor3 = CONFIG.White
        end
    end
end

--// DATA ISLANDS
local AllIslands = {
    Sea1 = {
        {Name = "Starter Island", MinLevel = 1, MaxLevel = 9},
        {Name = "Jungle", MinLevel = 10, MaxLevel = 14},
        {Name = "Pirate Village", MinLevel = 15, MaxLevel = 29},
        {Name = "Desert Island", MinLevel = 30, MaxLevel = 59},
        {Name = "Frozen Village", MinLevel = 60, MaxLevel = 89},
        {Name = "Marine Ford", MinLevel = 90, MaxLevel = 119},
        {Name = "Skylands", MinLevel = 120, MaxLevel = 149},
        {Name = "Colosseum", MinLevel = 150, MaxLevel = 179},
        {Name = "Magma Village", MinLevel = 180, MaxLevel = 224},
        {Name = "Underwater City", MinLevel = 225, MaxLevel = 269},
        {Name = "Baratie Quest", MinLevel = 270, MaxLevel = 299},
        {Name = "Sky Island", MinLevel = 300, MaxLevel = 329},
        {Name = "Fountain City", MinLevel = 330, MaxLevel = 369},
        {Name = "Volcano Island", MinLevel = 370, MaxLevel = 399},
    },
    Sea2 = {
        {Name = "Kingdom of Rose", MinLevel = 700, MaxLevel = 799},
        {Name = "Green Zone", MinLevel = 800, MaxLevel = 899},
        {Name = "Graveyard", MinLevel = 900, MaxLevel = 999},
        {Name = "Snow Mountain", MinLevel = 1000, MaxLevel = 1099},
        {Name = "Hot and Cold", MinLevel = 1100, MaxLevel = 1199},
        {Name = "Cursed Ship", MinLevel = 1200, MaxLevel = 1299},
        {Name = "Ice Castle", MinLevel = 1300, MaxLevel = 1399},
        {Name = "Forgotten Island", MinLevel = 1400, MaxLevel = 1499},
    },
    Sea3 = {
        {Name = "Port Town", MinLevel = 1500, MaxLevel = 1574},
        {Name = "Hydra Island", MinLevel = 1575, MaxLevel = 1699},
        {Name = "Great Tree", MinLevel = 1700, MaxLevel = 1774},
        {Name = "Floating Turtle", MinLevel = 1775, MaxLevel = 1974},
        {Name = "Haunted Castle", MinLevel = 1975, MaxLevel = 2074},
        {Name = "Sea of Treats", MinLevel = 2075, MaxLevel = 2449},
        {Name = "Tiki Outpost", MinLevel = 2450, MaxLevel = 2800},
    },
}

local function GetIslandByLevel(level)
    for sea, islands in pairs(AllIslands) do
        for _, island in ipairs(islands) do
            if level >= island.MinLevel and level <= island.MaxLevel then
                return island.Name, sea
            end
        end
    end
    if level > 2800 then return "Tiki Outpost", "Sea3" end
    return nil, nil
end

--// BOSS DATA
local BossData = {
    Sea1 = {
        {Name = "Gorilla King", Level = 25, Location = "Jungle"},
        {Name = "Bobby (Chef)", Level = 55, Location = "Pirate Village"},
        {Name = "The Saw", Level = 100, Location = "Middle Town"},
        {Name = "Yeti", Level = 110, Location = "Frozen Village"},
        {Name = "Mob Leader", Level = 120, Location = "Pirate Starter Area"},
        {Name = "Vice Admiral", Level = 130, Location = "Marine Fortress"},
        {Name = "Saber Expert", Level = 200, Location = "Jungle Cave"},
        {Name = "Warden", Level = 220, Location = "Prison"},
        {Name = "Chief Warden", Level = 230, Location = "Prison"},
        {Name = "Swan", Level = 240, Location = "Prison"},
        {Name = "Magma Admiral", Level = 350, Location = "Magma Village"},
        {Name = "Fishman Lord", Level = 425, Location = "Underwater City"},
        {Name = "Wysper", Level = 500, Location = "Upper Skylands"},
        {Name = "Thunder God", Level = 575, Location = "Upper Skylands"},
        {Name = "Cyborg", Level = 675, Location = "Fountain City"},
        {Name = "Ice Admiral", Level = 700, Location = "Frozen Cave"},
    },
    Sea2 = {
        {Name = "Diamond", Level = 750, Location = "Kingdom of Rose"},
        {Name = "Jeremy", Level = 850, Location = "Kingdom of Rose"},
        {Name = "Orbitus", Level = 925, Location = "Green Zone"},
        {Name = "Don Swan", Level = 1000, Location = "Swan Mansion"},
        {Name = "Darkbeard", Level = 1000, Location = "Dark Arena", Raid = true},
        {Name = "Smoke Admiral", Level = 1150, Location = "Hot and Cold"},
        {Name = "Order", Level = 1250, Location = "Hot and Cold", Raid = true},
        {Name = "Cursed Captain", Level = 1325, Location = "Cursed Ship"},
        {Name = "Awakened Ice Admiral", Level = 1400, Location = "Ice Castle"},
        {Name = "Tide Keeper", Level = 1475, Location = "Forgotten Island"},
    },
    Sea3 = {
        {Name = "Stone", Level = 1550, Location = "Port Town"},
        {Name = "Island Empress", Level = 1675, Location = "Hydra Island"},
        {Name = "Kilo Admiral", Level = 1750, Location = "Great Tree"},
        {Name = "Captain Elephant", Level = 1875, Location = "Floating Turtle"},
        {Name = "Beautiful Pirate", Level = 1950, Location = "Floating Turtle"},
        {Name = "Longma", Level = 2000, Location = "Floating Turtle"},
        {Name = "Soul Reaper", Level = 2100, Location = "Haunted Castle", Raid = true},
        {Name = "Cake Queen", Level = 2175, Location = "Ice Cream Land"},
        {Name = "Cake Prince", Level = 2300, Location = "Sea of Treats", Raid = true},
        {Name = "Dough King", Level = 2300, Location = "Sea of Treats", Raid = true},
        {Name = "Tyrant of the Skies", Level = 2600, Location = "Tiki Outpost"},
        {Name = "rip_indra", Level = 5000, Location = "Castle on the Sea", Raid = true},
    },
}

--// SECRET QUEST DATA
local SecretQuests = {
    Jungle = {
        {Name = "Find Grappling Hook + repair Zipline", Steps = {"Cari Grappling Hook", "Repair Zipline"}},
        {Name = "Find Monkey tracks + knock Monkey down + return Hat", Steps = {"Cari jejak Monkey", "Knock Monkey", "Return Hat"}},
        {Name = "Trigger Gorilla King + knock bananas + defeat Gorilla King", Steps = {"Trigger Gorilla King", "Knock bananas", "Defeat Gorilla King"}},
    },
    ["Pirate Village"] = {
        {Name = "Break all Windmill ropes", Steps = {"Cari windmill", "Putus semua tali"}},
        {Name = "Wait Tavern enemies + defeat them + talk Bartender", Steps = {"Tunggu musuh", "Kalahkan", "Talk Bartender"}},
        {Name = "Help Chef + complete his task", Steps = {"Bantu Chef", "Selesaikan task"}},
    },
    Desert = {
        {Name = "Rescue Hasan under the Pyramid", Steps = {"Masuk Pyramid", "Cari Hasan", "Rescue"}},
        {Name = "Find and interact with 8 stone monuments", Steps = {"Cari 8 monument", "Interact semua"}},
        {Name = "Collect Cactus fruits", Steps = {"Cari cactus", "Collect fruit"}},
    },
    ["Frozen Village"] = {
        {Name = "Find Ability Teacher + complete his task", Steps = {"Cari Teacher", "Selesaikan task"}},
        {Name = "Build 3 Snowmen", Steps = {"Kumpulkan bahan", "Build 3"}},
        {Name = "Trigger Yeti + defeat Yeti", Steps = {"Trigger Yeti", "Defeat Yeti"}},
    },
    ["Marine Fortress"] = {
        {Name = "Find Rope + raise the Flag", Steps = {"Cari Rope", "Naikkan Flag"}},
        {Name = "Wait for Pirate Raid + defeat invading ships", Steps = {"Tunggu Raid", "Defeat ships"}},
        {Name = "Trigger Vice Admiral + defeat Vice Admiral", Steps = {"Trigger", "Defeat"}},
    },
    ["Lower Skylands"] = {
        {Name = "Find Angel Guard + retrieve the Golden Chest", Steps = {"Cari Angel Guard", "Ambil Chest"}},
        {Name = "Find Lightning Bolt + return to Mad Scientist", Steps = {"Cari Bolt", "Return"}},
        {Name = "Find the Crumpled Letter + deliver it", Steps = {"Cari Letter", "Deliver"}},
    },
    Prison = {
        {Name = "Stop 3 Escaped Prisoners", Steps = {"Cari 3 prisoner", "Stop"}},
        {Name = "Find Cell Block Key + retrieve the Coat", Steps = {"Cari Key", "Ambil Coat"}},
        {Name = "Activate Lever + defeat Prison Boss", Steps = {"Activate Lever", "Defeat Boss"}},
    },
    Colosseum = {
        {Name = "Defeat the 3 waves in the Colosseum", Steps = {"Wave 1", "Wave 2", "Wave 3"}},
        {Name = "Interact with Former Champions statues", Steps = {"Cari statues", "Interact"}},
        {Name = "Complete the Crowd Favorite 1v1", Steps = {"Masuk 1v1", "Menang"}},
    },
    ["Magma Village"] = {
        {Name = "Defeat the Evil Slimes", Steps = {"Cari Slimes", "Defeat"}},
        {Name = "Collect Magma Ore + complete extraction", Steps = {"Collect Ore", "Extract"}},
        {Name = "Trigger Magma General + defeat Magma General", Steps = {"Trigger", "Defeat"}},
    },
    ["Underwater City"] = {
        {Name = "Find Bubble Cove + help King Neptune", Steps = {"Cari Cove", "Bantu Neptune"}},
        {Name = "Activate Crystal Beam + help Water Kung Fu Teacher", Steps = {"Activate", "Bantu Teacher"}},
        {Name = "Find Black Pearl + defeat Fishman Lord", Steps = {"Cari Pearl", "Defeat Lord"}},
    },
    ["Upper Skylands"] = {
        {Name = "Find Temple Intel", Steps = {"Cari Intel"}},
        {Name = "Trigger Sky Warlord + defeat Sky Warlord", Steps = {"Trigger", "Defeat"}},
        {Name = "Find Yellow Bell + trigger Thunder God", Steps = {"Cari Bell", "Trigger"}},
    },
    ["Fountain City"] = {
        {Name = "Repair the broken Pipes", Steps = {"Cari pipes", "Repair"}},
        {Name = "Enter Sewer + defeat Sewer Gang", Steps = {"Masuk Sewer", "Defeat Gang"}},
        {Name = "Repair Cyborg's wires + defeat Cyborg", Steps = {"Repair wires", "Defeat Cyborg"}},
    },
}
