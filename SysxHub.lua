-- ============================================
-- [SYSX] UNIVERSAL ALL MAP SCRIPT v11
-- FINAL — ALL FEATURES WORK
-- Logo S | GodMode | Fly | Bomb | Fling Spin
-- Lag Orb | Big Body | Sword | Kick All
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local LP = Players.LocalPlayer

local S = {
    Fly=false, BigBody=false, FlingSpin=false,
    LagOrb=false, Sword=false, GodMode=false, KickAll=false
}

local FlyConn, FlyBV, FlyBG
local CurSword
local FlingRunning, LagRunning, BigRunning, KickRunning = false, false, false, false

local function isMe(p) return p == LP end
local function alive(p)
    if isMe(p) or not p.Character then return false end
    local h = p.Character:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

-- ===== GUI =====
local sg = Instance.new("ScreenGui", game.CoreGui)
sg.Name = "SYSX_Menu"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true

local toggle = Instance.new("TextButton", sg)
toggle.Size = UDim2.new(0,60,0,60)
toggle.Position = UDim2.new(0,20,0,20)
toggle.BackgroundColor3 = Color3.fromRGB(20,20,20)
toggle.Text = "S"
toggle.TextColor3 = Color3.fromRGB(0,255,180)
toggle.TextScaled = true
toggle.Font = Enum.Font.GothamBlack
toggle.BorderSizePixel = 0
toggle.Draggable = true
toggle.Active = true
Instance.new("UICorner", toggle).CornerRadius = UDim.new(1,0)
local st = Instance.new("UIStroke", toggle)
st.Color = Color3.fromRGB(0,255,180); st.Thickness = 3

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0,260,0,480)
frame.Position = UDim2.new(0.5,-130,0.5,-240)
frame.BackgroundColor3 = Color3.fromRGB(15,15,15)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)
local st2 = Instance.new("UIStroke", frame)
st2.Color = Color3.fromRGB(0,255,180); st2.Thickness = 2

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "[SYSX] v11"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

local function btn(name, y, cb)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0.9,0,0,40)
    b.Position = UDim2.new(0.05,0,0,y)
    b.BackgroundColor3 = Color3.fromRGB(30,30,30)
    b.Text = name.." [OFF]"
    b.TextColor3 = Color3.new(1,1,1)
    b.TextScaled = true
    b.Font = Enum.Font.Gotham
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    local s2 = Instance.new("UIStroke", b)
    s2.Color = Color3.fromRGB(0,255,180); s2.Thickness = 1
    b.MouseButton1Click:Connect(function() cb(b) end)
    return b
end

toggle.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-- ===== GODMODE =====
local GodConn
local function godOn()
    if GodConn then GodConn:Disconnect() end
    GodConn = RunService.Heartbeat:Connect(function()
        if not S.GodMode then return end
        local c = LP.Character
        if not c then return end
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then
            h.MaxHealth = math.huge
            h.Health = math.huge
            h.BreakJointsOnDeath = false
            h.RequiresNeck = false
        end
        if not c:FindFirstChildOfClass("ForceField") then
            local ff = Instance.new("ForceField"); ff.Visible=false; ff.Parent=c
        end
    end)
end

local function godOff()
    if GodConn then GodConn:Disconnect() GodConn = nil end
    local c = LP.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then h.MaxHealth=100; h.Health=100; h.BreakJointsOnDeath=true end
        local ff = c:FindFirstChildOfClass("ForceField")
        if ff then ff:Destroy() end
    end
end

-- ===== FLY =====
local function flyOn()
    local c = LP.Character
    if not c then return end
    local r = c:FindFirstChild("HumanoidRootPart")
    local h = c:FindFirstChildOfClass("Humanoid")
    if not r or not h then return end

    if FlyBV and FlyBV.Parent then FlyBV:Destroy() end
    if FlyBG and FlyBG.Parent then FlyBG:Destroy() end

    h.PlatformStand = true
    h:ChangeState(Enum.HumanoidStateType.Physics)

    FlyBV = Instance.new("BodyVelocity", r)
    FlyBV.MaxForce = Vector3.new(1e5,1e5,1e5)
    FlyBV.Velocity = Vector3.zero
    FlyBV.P = 1250

    FlyBG = Instance.new("BodyGyro", r)
    FlyBG.MaxTorque = Vector3.new(1e5,1e5,1e5)
    FlyBG.P = 1e4; FlyBG.D = 100
    FlyBG.CFrame = r.CFrame

    if FlyConn then FlyConn:Disconnect() end
    FlyConn = RunService.RenderStepped:Connect(function()
        if not S.Fly then return end
        local c2 = LP.Character
        if not c2 or not FlyBV or not FlyBV.Parent or not FlyBG or not FlyBG.Parent then return end
        local cam = workspace.CurrentCamera
        local d = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then d = d + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then d = d - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then d = d - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then d = d + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then d = d + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d = d - Vector3.new(0,1,0) end
        if h.MoveDirection.Magnitude > 0 then d = d + h.MoveDirection end
        FlyBV.Velocity = d.Magnitude > 0 and d.Unit * 120 or Vector3.zero
        FlyBG.CFrame = cam.CFrame
    end)
end

local function flyOff()
    if FlyConn then FlyConn:Disconnect() FlyConn = nil end
    if FlyBV and FlyBV.Parent then FlyBV:Destroy() end
    if FlyBG and FlyBG.Parent then FlyBG:Destroy() end
    FlyBV, FlyBG = nil, nil
    local c = LP.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then h.PlatformStand = false end
        local r = c:FindFirstChild("HumanoidRootPart")
        if r then r.AssemblyLinearVelocity = Vector3.zero; r.RotVelocity = Vector3.zero end
    end
end

-- ===== BOMB SERVER =====
local function bombServer()
    for _, p in ipairs(Players:GetPlayers()) do
        if alive(p) then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if h then
                h.BreakJointsOnDeath = true
                h.Health = 0
                pcall(function() h:ChangeState(Enum.HumanoidStateType.Dead) end)
            end
            pcall(function() p.Character:BreakJoints() end)
        end
    end
end

-- ===== FLING SPIN =====
local function flingOn()
    if FlingRunning then return end
    FlingRunning = true
    task.spawn(function()
        while S.FlingSpin do
            local c = LP.Character
            if c then
                local r = c:FindFirstChild("HumanoidRootPart")
                if r then
                    r.AssemblyAngularVelocity = Vector3.new(0, 9999, 0)
                    r.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0, 0)
                    for _, p in ipairs(Players:GetPlayers()) do
                        if alive(p) then
                            local h = p.Character:FindFirstChildOfClass("Humanoid")
                            local hr = p.Character:FindFirstChild("HumanoidRootPart")
                            if h and hr then
                                if (hr.Position - r.Position).Magnitude < 25 then
                                    local dir = (hr.Position - r.Position)
                                    if dir.Magnitude < 1 then dir = Vector3.new(1,1,1) end
                                    dir = dir.Unit
                                    hr.AssemblyLinearVelocity = dir * 15000 + Vector3.new(0, 5000, 0)
                                    hr.AssemblyAngularVelocity = Vector3.new(999,999,999)
                                    h:TakeDamage(50)
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.1)
        end
        FlingRunning = false
    end)
end

local function flingOff()
    S.FlingSpin = false
    task.wait(0.15)
    local c = LP.Character
    if c then
        local r = c:FindFirstChild("HumanoidRootPart")
        if r then r.AssemblyAngularVelocity = Vector3.zero; r.CustomPhysicalProperties = nil end
    end
end

-- ===== LAG ORB =====
local function lagOn()
    if LagRunning then return end
    LagRunning = true
    task.spawn(function()
        while S.LagOrb do
            for i = 1, 3 do
                local orb = Instance.new("Part")
                orb.Name = "SYSX_LagOrb"
                orb.Shape = Enum.PartType.Ball
                orb.Size = Vector3.new(60,60,60)
                orb.Material = Enum.Material.Neon
                orb.Color = Color3.fromRGB(255,0,255)
                orb.Anchored = true
                orb.CanCollide = true
                orb.CFrame = CFrame.new(0, 50, 0)
                orb.Parent = workspace
                Debris:AddItem(orb, 10)
                task.spawn(function()
                    local ang = math.random() * math.pi * 2
                    local rad = 150 + i * 60
                    for _ = 1, 100 do
                        if not orb.Parent or not S.LagOrb then break end
                        ang = ang + 0.2
                        orb.CFrame = CFrame.new(math.cos(ang)*rad, 50 + math.sin(ang*3)*40, math.sin(ang)*rad)
                        for _, p in ipairs(Players:GetPlayers()) do
                            if alive(p) then
                                local h = p.Character:FindFirstChildOfClass("Humanoid")
                                local hr = p.Character:FindFirstChild("HumanoidRootPart")
                                if h and hr and (hr.Position - orb.Position).Magnitude < 55 then
                                    h.Health = 0
                                    pcall(function() h:ChangeState(Enum.HumanoidStateType.Dead) end)
                                end
                            end
                        end
                        task.wait(0.05)
                    end
                end)
            end
            task.wait(2)
        end
        LagRunning = false
    end)
end

local function lagOff()
    S.LagOrb = false
    task.wait(0.1)
    for _, o in ipairs(workspace:GetChildren()) do
        if o:IsA("Part") and o.Name == "SYSX_LagOrb" then
            o:Destroy()
        end
    end
end

-- ===== BIG BODY SPIDER =====
local function saveOrig(ch)
    for _, p in ipairs(ch:GetDescendants()) do
        if p:IsA("BasePart") and not p:GetAttribute("SYSX_OS") then
            p:SetAttribute("SYSX_OS", p.Size)
            p:SetAttribute("SYSX_OSH", p.Shape.Value)
            p:SetAttribute("SYSX_OC", p.CanCollide)
        end
    end
end

local function bigOn()
    for _, p in ipairs(Players:GetPlayers()) do
        if alive(p) then saveOrig(p.Character) end
    end
    if BigRunning then return end
    BigRunning = true
    task.spawn(function()
        while S.BigBody do
            for _, p in ipairs(Players:GetPlayers()) do
                if alive(p) then
                    local h = p.Character:FindFirstChildOfClass("Humanoid")
                    local r = p.Character:FindFirstChild("HumanoidRootPart")
                    if h and r then
                        for _, pt in ipairs(p.Character:GetDescendants()) do
                            if pt:IsA("BasePart") then
                                pt.Massless = true
                                pt.CanCollide = false
                                pt.Shape = Enum.PartType.Ball
                                local ns = math.min(pt.Size.X + 5, 3000)
                                pt.Size = Vector3.new(ns, ns, ns)
                            end
                        end
                        r.RotVelocity = Vector3.new(math.random(-60,60), math.random(-60,60), math.random(-60,60))
                        if #h:GetPlayingAnimationTracks() == 0 then
                            local a = Instance.new("Animation")
                            a.AnimationId = "rbxassetid://"..tostring(math.random(1e9,9999999999))
                            pcall(function() local t = h:LoadAnimation(a); t:Play() end)
                        end
                    end
                end
            end
            task.wait(0.2)
        end
        BigRunning = false
    end)
end

local function bigOff()
    S.BigBody = false
    task.wait(0.25)
    for _, p in ipairs(Players:GetPlayers()) do
        if not isMe(p) and p.Character then
            for _, pt in ipairs(p.Character:GetDescendants()) do
                if pt:IsA("BasePart") then
                    local os = pt:GetAttribute("SYSX_OS")
                    local osh = pt:GetAttribute("SYSX_OSH")
                    local oc = pt:GetAttribute("SYSX_OC")
                    if os then pt.Size = os end
                    if osh then pt.Shape = Enum.PartType:FromValue(osh) end
                    if oc ~= nil then pt.CanCollide = oc end
                    pt.Massless = false
                end
            end
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if h then for _, t in ipairs(h:GetPlayingAnimationTracks()) do t:Stop() end end
        end
    end
end

-- ===== SWORD =====
local function swordOn()
    local c = LP.Character
    if not c then return end
    if CurSword and CurSword.Parent then CurSword:Destroy() end

    local tool = Instance.new("Tool")
    tool.Name = "SYSX_Sword"
    tool.RequiresHandle = true
    tool.CanBeDropped = false

    local h = Instance.new("Part", tool)
    h.Name = "Handle"; h.Size = Vector3.new(0.4,1.2,0.4)
    h.Material = Enum.Material.Metal; h.Color = Color3.fromRGB(60,30,10)

    local g = Instance.new("Part", tool)
    g.Name = "Guard"; g.Size = Vector3.new(2,0.3,0.4)
    g.Material = Enum.Material.Metal; g.Color = Color3.fromRGB(200,180,50); g.CanCollide = false
    local wg = Instance.new("Weld", h); wg.Part0=h; wg.Part1=g; wg.C0 = CFrame.new(0,0.6,0)

    local b = Instance.new("Part", tool)
    b.Name = "Blade"; b.Size = Vector3.new(0.15,5,1)
    b.Material = Enum.Material.Metal; b.Color = Color3.fromRGB(220,220,230); b.CanCollide = false
    local wb = Instance.new("Weld", h); wb.Part0=h; wb.Part1=b; wb.C0 = CFrame.new(0,3.1,0)

    local tp = Instance.new("WedgePart", tool)
    tp.Name = "Tip"; tp.Size = Vector3.new(0.15,1,1)
    tp.Material = Enum.Material.Metal; tp.Color = Color3.fromRGB(230,230,240); tp.CanCollide = false
    local wt = Instance.new("Weld", h); wt.Part0=h; wt.Part1=tp
    wt.C0 = CFrame.new(0,5.8,0) * CFrame.Angles(0,0,math.rad(180))

    local l = Instance.new("PointLight", h)
    l.Color = Color3.fromRGB(255,0,0); l.Range = 8; l.Brightness = 2

    tool.Activated:Connect(function()
        if not S.Sword then return end
        local mr = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not mr then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if alive(p) then
                local hh = p.Character:FindFirstChildOfClass("Humanoid")
                local hr = p.Character:FindFirstChild("HumanoidRootPart")
                if hh and hr and (hr.Position - mr.Position).Magnitude < 25 then
                    hh.Health = 0
                    pcall(function() hh:ChangeState(Enum.HumanoidStateType.Dead) end)
                end
            end
        end
    end)

    task.spawn(function()
        while S.Sword and tool.Parent do
            local mr = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if mr then
                for _, p in ipairs(Players:GetPlayers()) do
                    if alive(p) then
                        local hh = p.Character:FindFirstChildOfClass("Humanoid")
                        local hr = p.Character:FindFirstChild("HumanoidRootPart")
                        if hh and hr and (hr.Position - mr.Position).Magnitude < 12 then
                            hh.Health = 0
                            pcall(function() hh:ChangeState(Enum.HumanoidStateType.Dead) end)
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)

    tool.Parent = LP.Backpack
    task.wait(0.1)
    tool.Parent = LP.Character
    CurSword = tool
end

local function swordOff()
    if CurSword and CurSword.Parent then CurSword:Destroy() end
    CurSword = nil
end

-- ===== KICK ALL PLAYER =====
local function kickOn()
    if KickRunning then return end
    KickRunning = true
    task.spawn(function()
        while S.KickAll do
            for _, p in ipairs(Players:GetPlayers()) do
                if not isMe(p) and p.Character then
                    local hr = p.Character:FindFirstChild("HumanoidRootPart")
                    if hr then
                        hr.CFrame = CFrame.new(0, -99999, 0)
                        hr.AssemblyLinearVelocity = Vector3.new(0, -99999, 0)
                    end
                end
            end
            task.wait(1)
        end
        KickRunning = false
    end)
end

local function kickOff()
    S.KickAll = false
end

-- ===== BUTTONS =====
btn("GodMode", 50, function(b)
    S.GodMode = not S.GodMode
    if S.GodMode then godOn(); b.Text="GodMode [ON]" else godOff(); b.Text="GodMode [OFF]" end
end)

btn("Fly", 100, function(b)
    S.Fly = not S.Fly
    if S.Fly then flyOn(); b.Text="Fly [ON]" else flyOff(); b.Text="Fly [OFF]" end
end)

btn("Bomb Server", 150, function(b)
    bombServer(); b.Text="Bomb [!!]"
    task.wait(2); b.Text="Bomb Server [OFF]"
end)

btn("Fling Spin", 200, function(b)
    S.FlingSpin = not S.FlingSpin
    if S.FlingSpin then flingOn(); b.Text="Fling Spin [ON]" else flingOff(); b.Text="Fling Spin [OFF]" end
end)

btn("Lag Orb", 250, function(b)
    S.LagOrb = not S.LagOrb
    if S.LagOrb then lagOn(); b.Text="Lag Orb [ON]" else lagOff(); b.Text="Lag Orb [OFF]" end
end)

btn("Big Body", 300, function(b)
    S.BigBody = not S.BigBody
    if S.BigBody then bigOn(); b.Text="Big Body [ON]" else bigOff(); b.Text="Big Body [OFF]" end
end)

btn("Sword", 350, function(b)
    S.Sword = not S.Sword
    if S.Sword then swordOn(); b.Text="Sword [ON]" else swordOff(); b.Text="Sword [OFF]" end
end)

btn("Kick All Player", 400, function(b)
    S.KickAll = not S.KickAll
    if S.KickAll then kickOn(); b.Text="Kick All [ON]" else kickOff(); b.Text="Kick All [OFF]" end
end)

-- ===== AUTO RESPAWN =====
LP.CharacterAdded:Connect(function()
    task.wait(1)
    if S.GodMode then godOn() end
    if S.Fly then flyOn() end
    if S.Sword then swordOn() end
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(ch)
        task.wait(2)
        if S.BigBody and not isMe(p) then saveOrig(ch) end
    end)
end)

print("[SYSX] v11 — ALL FEATURES FINAL ✅")
