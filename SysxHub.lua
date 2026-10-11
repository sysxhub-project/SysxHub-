-- ============================================================
-- FARM LEVEL ONLY (dari VxezeHub_Fixed.lua)
-- Alur: Take Quest → Attack Mob → Quest Done → Take Quest
-- Range: Level 1 - 2800
-- ============================================================

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer:FindFirstChild("DataLoaded")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local CommF_ = ReplicatedStorage.Remotes.CommF_

-- ============================================================
-- QUEST SYSTEM
-- ============================================================
local QuestSys = {
    CurrentLevel = 3,
    CurrentQuests = {},
    BlacklistedQuestIds = {
        BartiloQuest = 1, CitizenQuest = 1, Trainees = 1,
        MarineQuest = 1,  ImpelQuest = 1,
    },
    Quests = require(ReplicatedStorage.Quests),
    NPCList = require(ReplicatedStorage.GuideModule).Data.NPCList,
}

function QuestSys:RefreshQuest()
    while not LocalPlayer.Data.Level.Value do task.wait(1) end
    local lvl = LocalPlayer.Data.Level.Value
    local bestReq, bestQuests = 0
    for qid, chain in pairs(self.Quests) do
        if not self.BlacklistedQuestIds[qid] then
            if chain[1].LevelReq >= bestReq and chain[1].LevelReq <= lvl then
                bestReq = chain[1].LevelReq
                bestQuests = chain
                self.CurrentQuestId = qid
            end
        end
    end
    if not bestQuests then return end
    for _, v in bestQuests[#bestQuests].Task do
        if v == 1 then table.remove(bestQuests, #bestQuests) end
    end
    for _, npcData in pairs(self.NPCList) do
        for _, lv in ipairs(npcData.Levels) do
            if lv == bestQuests[#bestQuests].LevelReq then
                self.CurrentNpc = npcData.CFrame
            end
        end
    end
    self.CurrentQuests = bestQuests
end

function QuestSys:GetCurrentQuest()
    local idx = (self.CurrentQuests[self.CurrentLevel]
        and self.CurrentQuests[self.CurrentLevel].LevelReq <= LocalPlayer.Data.Level.Value)
        and self.CurrentLevel or 1
    for mobName in self.CurrentQuests[idx].Task do
        return mobName, self.CurrentNpc, self.CurrentQuestId, idx, self.CurrentQuests[idx].Name
    end
end

function QuestSys:MarkAsCompleted()
    self.CurrentLevel = self.CurrentLevel % 3 + 1
end

function QuestSys:AbandonQuest()
    CommF_:InvokeServer("AbandonQuest")
end

function QuestSys:StartQuest(questName, idx)
    CommF_:InvokeServer("ColorsDealer", "2")
    return CommF_:InvokeServer("StartQuest", questName, idx)
end

-- ============================================================
-- UTIL
-- ============================================================
local TweenService = game:GetService("TweenService")
local TweenInstance

local function Distance(pos)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return math.huge end
    if typeof(pos) == "CFrame" then pos = pos.Position end
    return (pos - hrp.Position).Magnitude
end

local function TweenTo(cf, speed)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not cf then return end
    if TweenInstance then pcall(function() TweenInstance:Cancel() end) end
    for _, v in ipairs(LocalPlayer.Character:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end
    if typeof(cf) == "Vector3" then cf = CFrame.new(cf) end
    cf = CFrame.new(cf.Position)
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
-- FIND & ATTACK MOB
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

local function GetCurrentClaimQuest()
    local visible = LocalPlayer.PlayerGui.Main.Quest.Visible
    if not visible then return nil end
    local title = LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text
    return title
end

local function AttackMobUntilDone(mobName)
    local noMobTimer = 0
    while IsQuestActive() do
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
                LocalPlayer.Character.HumanoidRootPart.CFrame = mobHrp.CFrame * CFrame.new(0, 15, 0)
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                    tool:Activate()
                    tool:Activate()
                else
                    game:GetService("VirtualUser"):Button1Down(Vector2.new(0, 0))
                end
            end
            task.wait(0.08)
        end
    end
end

-- ============================================================
-- MAIN LOOP
-- ============================================================
QuestSys:RefreshQuest()

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local q = QuestSys:GetCurrentQuest()
            if not q then return end
            local mobName, npcPos, questId, idx, questName = q

            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end

            -- STEP 1: TAKE QUEST
            if IsQuestActive() then
                CommF_:InvokeServer("AbandonQuest")
                task.wait(0.3)
            end

            if npcPos then
                TweenTo(npcPos * CFrame.new(0, 5, 5))
                task.wait(0.3)
                CommF_:InvokeServer("StartQuest", questId, idx)
                task.wait(0.5)
            end

            -- STEP 2: ATTACK MOB SAMPAI DONE
            AttackMobUntilDone(mobName)

            -- STEP 3: DONE → loop balik ke atas
            task.wait(0.3)
        end)
    end
end)

-- Auto refresh quest kalau selesai
local Notification = require(ReplicatedStorage.Notification)
local oldNew = Notification.new
Notification.new = function(...)
    local text = tostring(...) 
    if string.find(string.lower(text), "quest completed") then
        QuestSys:RefreshQuest()
        if not IsQuestActive() then QuestSys:MarkAsCompleted() end
    end
    return oldNew(...)
end

-- Anti AFK
LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):Button2Down(Vector2.new(0, 0))
    task.wait(1)
    game:GetService("VirtualUser"):Button2Up(Vector2.new(0, 0))
end)

print("[Farm Level] Started - auto quest 1-2800")
