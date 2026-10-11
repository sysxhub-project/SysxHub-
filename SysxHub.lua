-- ============================================================
-- AUTO FARM LEVEL 1 - 2800 + TOGGLE UI
-- Alur: Take Quest → Attack Mob → Quest Done → Take Quest
-- ============================================================

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer:FindFirstChild("DataLoaded")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local CommF_ = ReplicatedStorage.Remotes.CommF_

-- ============================================================
-- 1. MODUL ASLI GAME
-- ============================================================
local GuideModule = require(ReplicatedStorage:WaitForChild("GuideModule"))
local NPCList = GuideModule.Data.NPCList
local Quests = require(ReplicatedStorage:WaitForChild("Quests"))

local BLACKLIST = {
    BartiloQuest = true, CitizenQuest = true, Trainees = true,
    MarineQuest = true,  ImpelQuest = true,
}

-- ============================================================
-- 2. STATE
-- ============================================================
getgenv().FarmLevelEnabled = false

-- ============================================================
-- 3. UI TOGGLE
-- ============================================================
local function CreateUI()
    local CoreGui = game:GetService("CoreGui")
    local existing = CoreGui:FindFirstChild("FarmLevelUI")
    if existing then existing:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FarmLevelUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui

    -- Main frame
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 220, 0, 130)
    main.Position = UDim2.new(0, 20, 0, 100)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = main

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 120, 200)
    stroke.Thickness = 1.5
    stroke.Parent = main

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 32)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    title.BorderSizePixel = 0
    title.Text = "Farm Level 1-2800"
    title.TextColor3 = Color3.fromRGB(200, 220, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = main

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = title

    -- Status label
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(1, -20, 0, 20)
    status.Position = UDim2.new(0, 10, 0, 40)
    status.BackgroundTransparency = 1
    status.Text = "Status: OFF"
    status.TextColor3 = Color3.fromRGB(255, 100, 100)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = main

    -- Info label (level + quest)
    local info = Instance.new("TextLabel")
    info.Name = "Info"
    info.Size = UDim2.new(1, -20, 0, 20)
    info.Position = UDim2.new(0, 10, 0, 62)
    info.BackgroundTransparency = 1
    info.Text = "Lv: - | Quest: -"
    info.TextColor3 = Color3.fromRGB(180, 180, 200)
    info.Font = Enum.Font.Gotham
    info.TextSize = 11
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = main

    -- Toggle button
    local toggle = Instance.new("TextButton")
    toggle.Name = "Toggle"
    toggle.Size = UDim2.new(1, -20, 0, 32)
    toggle.Position = UDim2.new(0, 10, 1, -42)
    toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    toggle.BorderSizePixel = 0
    toggle.Text = "ENABLE FARM"
    toggle.TextColor3 = Color3.fromRGB(200, 220, 255)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 13
    toggle.Parent = main

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = toggle

    return {
        ScreenGui = screenGui,
        Main = main,
        Status = status,
        Info = info,
        Toggle = toggle,
    }
end

local UI = CreateUI()

-- ============================================================
-- 4. TOGGLE LOGIC
-- ============================================================
UI.Toggle.MouseButton1Click:Connect(function()
    getgenv().FarmLevelEnabled = not getgenv().FarmLevelEnabled
    if getgenv().FarmLevelEnabled then
        UI.Toggle.Text = "DISABLE FARM"
        UI.Toggle.BackgroundColor3 = Color3.fromRGB(40, 100, 60)
        UI.Status.Text = "Status: ON"
        UI.Status.TextColor3 = Color3.fromRGB(100, 255, 130)
    else
        UI.Toggle.Text = "ENABLE FARM"
        UI.Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        UI.Status.Text = "Status: OFF"
        UI.Status.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- ============================================================
-- 5. CARI QUEST SESUAI LEVEL
-- ============================================================
local function GetCurrentQuest()
    local lvl = LocalPlayer.Data.Level.Value
    local bestReq, bestData = 0, nil

    for questId, questChain in pairs(Quests) do
        if not BLACKLIST[questId] and type(questChain) == "table" then
            for idx, questInfo in pairs(questChain) do
                if type(questInfo) == "table"
                    and questInfo.LevelReq
                    and questInfo.LevelReq <= lvl
                    and questInfo.LevelReq >= bestReq
                    and type(questInfo.Task) == "table" then
                    for mobName, killReq in pairs(questInfo.Task) do
                        if killReq > 1 then
                            bestReq  = questInfo.LevelReq
                            bestData = {
                                QuestId   = questId,
                                QuestName = questId,
                                Index     = idx,
                                MobName   = mobName,
                                Level     = questInfo.LevelReq,
                                NPC       = nil,
                            }
                        end
                    end
                end
            end
        end
    end

    if bestData then
        for _, npcData in pairs(NPCList) do
            if npcData.InternalQuestName == bestData.QuestName then
                for _, lv in ipairs(npcData.Levels) do
                    if lv == bestData.Level then
                        bestData.NPC = npcData.CFrame
                    end
                end
            end
        end
    end

    return bestData
end

-- ============================================================
-- 6. UTIL
-- ============================================================
local function Distance(pos)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return math.huge end
    if typeof(pos) == "CFrame" then pos = pos.Position end
    return (pos - hrp.Position).Magnitude
end

-- ============================================================
-- 7. TWEEN
-- ============================================================
local TweenInstance
local function TweenTo(cf, speed)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not cf then return end
    if TweenInstance then pcall(function() TweenInstance:Cancel() end) end

    for _, v in ipairs(LocalPlayer.Character:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end

    if typeof(cf) == "Vector3" then cf = CFrame.new(cf) end
    local dist = (hrp.Position - cf.Position).Magnitude
    TweenInstance = TweenService:Create(
        hrp,
        TweenInfo.new(math.max(dist / (speed or 350), 0.05), Enum.EasingStyle.Linear),
        { CFrame = cf }
    )
    TweenInstance:Play()
    TweenInstance.Completed:Wait()
end

-- ============================================================
-- 8. FIND & ATTACK MOB
-- ============================================================
local function FindMob(name)
    local closest, closestDist = nil, math.huge
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    for _, mob in ipairs(workspace.Enemies:GetChildren()) do
        if mob.Name == name
            and mob:FindFirstChild("HumanoidRootPart")
            and mob:FindFirstChild("Humanoid")
            and mob.Humanoid.Health > 0 then
            local d = (mob.HumanoidRootPart.Position - hrp.Position).Magnitude
            if d < closestDist then
                closest, closestDist = mob, d
            end
        end
    end
    return closest
end

local function EquipMelee()
    local char = LocalPlayer.Character
    if not char then return end
    if char:FindFirstChildOfClass("Tool") then return end
    for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip == "Melee" then
            char.Humanoid:EquipTool(t)
            return
        end
    end
end

local function IsQuestActive()
    local ok, vis = pcall(function()
        return LocalPlayer.PlayerGui.Main.Quest.Visible
    end)
    return ok and vis
end

local function AttackMobUntilDone(mobName)
    local noMobTimer = 0
    while IsQuestActive() and getgenv().FarmLevelEnabled do
        EquipMelee()
        local mob = FindMob(mobName)
        if not mob then
            noMobTimer = noMobTimer + 1
            if noMobTimer >= 30 then
                CommF_:InvokeServer("AbandonQuest")
                break
            end
            task.wait(0.1)
        else
            noMobTimer = 0
            local mobHrp = mob:FindFirstChild("HumanoidRootPart")
            if mobHrp and mob.Humanoid.Health > 0 then
                local myHrp = LocalPlayer.Character.HumanoidRootPart
                myHrp.CFrame = mobHrp.CFrame * CFrame.new(0, 15, 0)
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                    tool:Activate()
                    tool:Activate()
                else
                    VirtualUser:Button1Down(Vector2.new(0, 0))
                end
            end
            task.wait(0.08)
        end
    end
end

-- ============================================================
-- 9. MAIN LOOP
-- ============================================================
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if not getgenv().FarmLevelEnabled then return end

            local q = GetCurrentQuest()
            if not q or not q.NPC then
                task.wait(2)
                return
            end

            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end

            -- Update info UI
            UI.Info.Text = string.format("Lv: %d | Quest: %s", LocalPlayer.Data.Level.Value, q.MobName)

            -- STEP 1: TAKE QUEST
            if IsQuestActive() then
                CommF_:InvokeServer("AbandonQuest")
                task.wait(0.3)
            end

            TweenTo(q.NPC * CFrame.new(0, 5, 5))
            task.wait(0.3)
            CommF_:InvokeServer("StartQuest", q.QuestName, q.Index)
            task.wait(0.5)

            -- STEP 2: ATTACK MOB SAMPAI DONE
            AttackMobUntilDone(q.MobName)

            -- STEP 3: DONE — loop balik ke atas
            task.wait(0.3)
        end)
    end
end)

-- ============================================================
-- 10. ANTI AFK
-- ============================================================
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0))
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0))
end)

print("[Farm Level] Script loaded — klik tombol untuk enable")
