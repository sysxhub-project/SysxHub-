-- ============================================
-- [SYSX] UNIVERSAL ALL MAP SCRIPT v4
-- Sword = model pedang REAL (bukan kotak)
-- Lag Server = bawa objek muter map + kill player
-- Fling = fix total, mental beneran
-- Diri sendiri AMAN semua fitur
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local State = {
    Fly = false,
    BigBody = false,
    FlingTouch = false,
    LagServer = false,
    Sword = false,
}

local FlySpeed = 120
local FlyConn, FlyBodyVel, FlyBodyGyro
local FlingTouchConn
local LagConn
local SpiderConn
local SwordConn
local CurrentSword

local function isMe(p) return p == LocalPlayer end
local function isOtherAlive(p)
    if isMe(p) then return false end
    if not p.Character then return false end
    local hum = p.Character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

-- ===== GUI =====
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "S_Logo_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 60, 0, 60)
ToggleBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.Text = "S"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 180)
ToggleBtn.TextScaled = true
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Active = true
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local stroke = Instance.new("UIStroke", ToggleBtn)
stroke.Color = Color3.fromRGB(0, 255, 180)
stroke.Thickness = 3

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 260, 0, 400)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local stroke2 = Instance.new("UIStroke", MainFrame)
stroke2.Color = Color3.fromRGB(0, 255, 180)
stroke2.Thickness = 2

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "[SYSX] ALL MAP v4"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

local function makeButton(name, yPos, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = name .. " [OFF]"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", btn)
    s.Color = Color3.fromRGB(0, 255, 180)
    s.Thickness = 1
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ===== FLY =====
local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if FlyBodyVel and FlyBodyVel.Parent then FlyBodyVel:Destroy() end
    if FlyBodyGyro and FlyBodyGyro.Parent then FlyBodyGyro:Destroy() end

    hum.PlatformStand = true
    hum:ChangeState(Enum.HumanoidStateType.Physics)

    FlyBodyVel = Instance.new("BodyVelocity")
    FlyBodyVel.Name = "SYSX_FlyVel"
    FlyBodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    FlyBodyVel.Velocity = Vector3.zero
    FlyBodyVel.P = 1250
    FlyBodyVel.Parent = hrp

    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.Name = "SYSX_FlyGyro"
    FlyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    FlyBodyGyro.P = 1e4
    FlyBodyGyro.D = 100
    FlyBodyGyro.CFrame = hrp.CFrame
    FlyBodyGyro.Parent = hrp

    if FlyConn then FlyConn:Disconnect() end
    FlyConn = RunService.RenderStepped:Connect(function()
        if not State.Fly then return end
        local c = LocalPlayer.Character
        if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        if not FlyBodyVel or not FlyBodyVel.Parent then return end
        if not FlyBodyGyro or not FlyBodyGyro.Parent then return end

        local cam = workspace.CurrentCamera
        local dir = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
        if hum.MoveDirection.Magnitude > 0 then dir = dir + hum.MoveDirection end

        if dir.Magnitude > 0 then
            FlyBodyVel.Velocity = dir.Unit * FlySpeed
        else
            FlyBodyVel.Velocity = Vector3.zero
        end
        FlyBodyGyro.CFrame = cam.CFrame
    end)
end

local function stopFly()
    if FlyConn then FlyConn:Disconnect() FlyConn = nil end
    if FlyBodyVel and FlyBodyVel.Parent then FlyBodyVel:Destroy() end
    if FlyBodyGyro and FlyBodyGyro.Parent then FlyBodyGyro:Destroy() end
    FlyBodyVel = nil
    FlyBodyGyro = nil
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
        end
    end
end

-- ===== BOMB SERVER =====
local function bombServer()
    for _, p in ipairs(Players:GetPlayers()) do
        if isOtherAlive(p) then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hum then
                hum.Health = 0
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.Dead) end)
            end
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.new(
                    math.random(-3000, 3000),
                    math.random(2000, 5000),
                    math.random(-3000, 3000)
                )
                hrp.RotVelocity = Vector3.new(
                    math.random(-500, 500),
                    math.random(-500, 500),
                    math.random(-500, 500)
                )
            end
            pcall(function() p.Character:BreakJoints() end)
        end
    end
end

-- ===== FLING TOUCH (FIX TOTAL) =====
local function startFlingTouch()
    if FlingTouchConn then FlingTouchConn:Disconnect() end
    FlingTouchConn = RunService.Heartbeat:Connect(function()
        if not State.FlingTouch then return end
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myHrp = myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end

        -- KUNCI DIRI SENDIRI TOTAL
        myHrp.AssemblyLinearVelocity = Vector3.new(myHrp.AssemblyLinearVelocity.X, 0, myHrp.AssemblyLinearVelocity.Z)
        myHrp.RotVelocity = Vector3.zero
        myHrp.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 0)

        for _, p in ipairs(Players:GetPlayers()) do
            if isOtherAlive(p) then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hum then
                    local dist = (hrp.Position - myHrp.Position).Magnitude
                    if dist < 25 then
                        -- arah mental dari kita ke mereka
                        local dir = (hrp.Position - myHrp.Position)
                        if dir.Magnitude < 1 then
                            dir = Vector3.new(math.random(-1,1), 0.5, math.random(-1,1))
                        end
                        dir = dir.Unit

                        -- MENTAL REAL (velocity + angular)
                        hrp.AssemblyLinearVelocity = dir * 15000 + Vector3.new(0, 5000, 0)
                        hrp.AssemblyAngularVelocity = Vector3.new(
                            math.random(-999, 999),
                            math.random(-999, 999),
                            math.random(-999, 999)
                        )
                        hrp.RotVelocity = Vector3.new(
                            math.random(-999, 999),
                            math.random(-999, 999),
                            math.random(-999, 999)
                        )
                        hum:TakeDamage(math.random(40, 90))

                        -- extra loop biar mental jauh & ga balik
                        task.spawn(function()
                            for i = 1, 15 do
                                if hrp and hrp.Parent then
                                    hrp.AssemblyLinearVelocity = dir * 15000 + Vector3.new(0, 5000, 0)
                                    hrp.AssemblyAngularVelocity = Vector3.new(
                                        math.random(-999, 999),
                                        math.random(-999, 999),
                                        math.random(-999, 999)
                                    )
                                end
                                task.wait(0.05)
                            end
                        end)
                    end
                end
            end
        end
    end)
end

local function stopFlingTouch()
    if FlingTouchConn then FlingTouchConn:Disconnect() FlingTouchConn = nil end
    local myChar = LocalPlayer.Character
    if myChar then
        local myHrp = myChar:FindFirstChild("HumanoidRootPart")
        if myHrp then myHrp.CustomPhysicalProperties = nil end
    end
end

-- ===== LAG SERVER = OBJEK MUTER MAP + KILL PLAYER =====
local LagObjects = {}

local function startLagServer()
    if LagConn then LagConn:Disconnect() end
    LagConn = RunService.Heartbeat:Connect(function()
        if not State.LagServer then return end
        local mapCenter = Vector3.new(0, 50, 0)

        -- spawn objek besar yang muter di map
        for i = 1, 5 do
            local orb = Instance.new("Part")
            orb.Name = "SYSX_LagOrb"
            orb.Shape = Enum.PartType.Ball
            orb.Size = Vector3.new(80, 80, 80)
            orb.Material = Enum.Material.Neon
            orb.Color = Color3.fromRGB(255, 0, 255)
            orb.Anchored = true
            orb.CanCollide = true
            orb.Position = mapCenter
            orb.Parent = workspace
            table.insert(LagObjects, orb)
            game:GetService("Debris"):AddItem(orb, 20)

            -- bikin objek muter map
            task.spawn(function()
                local angle = 0
                local radius = 200 + i * 50
                for _ = 1, 200 do
                    if not orb.Parent or not State.LagServer then break end
                    angle = angle + 0.1
                    orb.CFrame = CFrame.new(
                        mapCenter.X + math.cos(angle) * radius,
                        mapCenter.Y + math.sin(angle * 2) * 30,
                        mapCenter.Z + math.sin(angle) * radius
                    )
                    task.wait(0.03)
                end
            end)

            -- objek kill player yang dekat
            task.spawn(function()
                for _ = 1, 200 do
                    if not orb.Parent or not State.LagServer then break end
                    for _, p in ipairs(Players:GetPlayers()) do
                        if isOtherAlive(p) then
                            local hum = p.Character:FindFirstChildOfClass("Humanoid")
                            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                            if hrp and hum then
                                local dist = (hrp.Position - orb.Position).Magnitude
                                if dist < 60 then
                                    hum.Health = 0
                                    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Dead) end)
                                    pcall(function() p.Character:BreakJoints() end)
                                end
                            end
                        end
                    end
                    task.wait(0.05)
                end
            end)
        end

        -- lag real: teleport spam + attachment spam ke player lain
        for _, p in ipairs(Players:GetPlayers()) do
            if isOtherAlive(p) then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hrp then
                    hrp.CFrame = CFrame.new(
                        math.random(-1000, 1000),
                        math.random(50, 500),
                        math.random(-1000, 1000)
                    )
                    pcall(function() hrp:SetNetworkOwner(nil) end)
                end
                if hum then
                    for i = 1, 8 do
                        local attach = Instance.new("Attachment")
                        attach.Parent = hum.RootPart or hrp
                        game:GetService("Debris"):AddItem(attach, 1)
                    end
                    pcall(function()
                        hum:ChangeState(Enum.HumanoidStateType.Physics)
                        hum:ChangeState(Enum.HumanoidStateType.Running)
                        hum:ChangeState(Enum.HumanoidStateType.Freefall)
                    end)
                end
            end
        end
    end)
end

local function stopLagServer()
    if LagConn then LagConn:Disconnect() LagConn = nil end
    for _, obj in ipairs(LagObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    LagObjects = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if not isMe(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function() p.Character.HumanoidRootPart:SetNetworkOwner(p) end)
        end
    end
end

-- ===== BIG BODY SPIDER =====
local function saveOriginal(char)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if not part:GetAttribute("SYSX_OrigSize") then
                part:SetAttribute("SYSX_OrigSize", part.Size)
                part:SetAttribute("SYSX_OrigShape", part.Shape.Value)
                part:SetAttribute("SYSX_OrigCollide", part.CanCollide)
            end
        end
    end
end

local function bigBodyON()
    for _, p in ipairs(Players:GetPlayers()) do
        if isOtherAlive(p) then
            saveOriginal(p.Character)
            for _, part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Massless = true
                    part.CanCollide = false
                    part.Shape = Enum.PartType.Ball
                end
            end
        end
    end

    if SpiderConn then SpiderConn:Disconnect() end
    SpiderConn = RunService.Heartbeat:Connect(function()
        if not State.BigBody then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if isOtherAlive(p) then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hum and hrp then
                    for _, part in ipairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            local newSize = math.min(part.Size.X + 3, 3000)
                            part.Size = Vector3.new(newSize, newSize, newSize)
                        end
                    end
                    hrp.RotVelocity = Vector3.new(
                        math.random(-60, 60),
                        math.random(-60, 60),
                        math.random(-60, 60)
                    )
                    local anims = hum:GetPlayingAnimationTracks()
                    if #anims == 0 then
                        local anim = Instance.new("Animation")
                        anim.AnimationId = "rbxassetid://" .. tostring(math.random(1e9, 9999999999))
                        pcall(function()
                            local t = hum:LoadAnimation(anim)
                            t:Play()
                        end)
                    end
                end
            end
        end
    end)
end

local function bigBodyOFF()
    if SpiderConn then SpiderConn:Disconnect() SpiderConn = nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if not isMe(p) and p.Character then
            for _, part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    local origSize = part:GetAttribute("SYSX_OrigSize")
                    local origShape = part:GetAttribute("SYSX_OrigShape")
                    local origCollide = part:GetAttribute("SYSX_OrigCollide")
                    if origSize then part.Size = origSize end
                    if origShape then part.Shape = Enum.PartType:FromValue(origShape) end
                    if origCollide ~= nil then part.CanCollide = origCollide end
                    part.Massless = false
                end
            end
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
                    t:Stop()
                end
            end
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.RotVelocity = Vector3.zero
            end
        end
    end
end

-- ===== GET SWORD (MODEL PEDANG REAL) =====
local function createSword()
    local char = LocalPlayer.Character
    if not char then return end

    if CurrentSword and CurrentSword.Parent then CurrentSword:Destroy() end

    local tool = Instance.new("Tool")
    tool.Name = "SYSX_Sword"
    tool.RequiresHandle = true
    tool.CanBeDropped = false
    tool.GripPos = Vector3.new(0, 0, 0)

    -- HANDLE (pegangan)
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.4, 1.2, 0.4)
    handle.Material = Enum.Material.Metal
    handle.Color = Color3.fromRGB(60, 30, 10)
    handle.TopSurface = Enum.SurfaceType.Smooth
    handle.BottomSurface = Enum.SurfaceType.Smooth
    handle.Parent = tool

    -- GUARD (pelindung tangan)
    local guard = Instance.new("Part")
    guard.Name = "Guard"
    guard.Size = Vector3.new(2, 0.3, 0.4)
    guard.Material = Enum.Material.Metal
    guard.Color = Color3.fromRGB(200, 180, 50)
    guard.CanCollide = false
    guard.Parent = tool

    local weldGuard = Instance.new("Weld")
    weldGuard.Part0 = handle
    weldGuard.Part1 = guard
    weldGuard.C0 = CFrame.new(0, 0.6, 0)
    weldGuard.Parent = handle

    -- BLADE (mata pedang) — panjang & runcing
    local blade = Instance.new("Part")
    blade.Name = "Blade"
    blade.Size = Vector3.new(0.15, 5, 1) -- tipis & panjang
    blade.Material = Enum.Material.Metal
    blade.Color = Color3.fromRGB(220, 220, 230)
    blade.CanCollide = false
    blade.TopSurface = Enum.SurfaceType.Smooth
    blade.BottomSurface = Enum.SurfaceType.Smooth
    blade.Parent = tool

    local weldBlade = Instance.new("Weld")
    weldBlade.Part0 = handle
    weldBlade.Part1 = blade
    weldBlade.C0 = CFrame.new(0, 3.1, 0)
    weldBlade.Parent = handle

    -- TIP (ujung runcing)
    local tip = Instance.new("WedgePart")
    tip.Name = "Tip"
    tip.Size = Vector3.new(0.15, 1, 1)
    tip.Material = Enum.Material.Metal
    tip.Color = Color3.fromRGB(230, 230, 240)
    tip.CanCollide = false
    tip.Parent = tool

    local weldTip = Instance.new("Weld")
    weldTip.Part0 = handle
    weldTip.Part1 = tip
    weldTip.C0 = CFrame.new(0, 5.8, 0) * CFrame.Angles(0, 0, math.rad(180))
    weldTip.Parent = handle

    -- POMMEL (ujung bawah)
    local pommel = Instance.new("Part")
    pommel.Name = "Pommel"
    pommel.Shape = Enum.PartType.Ball
    pommel.Size = Vector3.new(0.5, 0.5, 0.5)
    pommel.Material = Enum.Material.Metal
    pommel.Color = Color3.fromRGB(200, 180, 50)
    pommel.CanCollide = false
    pommel.Parent = tool

    local weldPommel = Instance.new("Weld")
    weldPommel.Part0 = handle
    weldPommel.Part1 = pommel
    weldPommel.C0 = CFrame.new(0, -0.8, 0)
    weldPommel.Parent = handle

    -- GLOW effect (PointLight)
    local light = Instance.new("PointLight", handle)
    light.Color = Color3.fromRGB(255, 0, 0)
    light.Range = 8
    light.Brightness = 2

    -- Trail di blade
    local a0 = Instance.new("Attachment", blade)
    a0.Position = Vector3.new(0, 2.5, 0)
    local a1 = Instance.new("Attachment", blade)
    a1.Position = Vector3.new(0, -2.5, 0)

    local trail = Instance.new("Trail", blade)
    trail.Attachment0 = a0
    trail.Attachment1 = a1
    trail.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 255, 0))
    trail.Lifetime = 0.4
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 1)
    })

    -- ONE HIT KILL saat klik
    tool.Activated:Connect(function()
        if not State.Sword then return end
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myHrp = myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end

        for _, p in ipairs(Players:GetPlayers()) do
            if isOtherAlive(p) then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hum then
                    local dist = (hrp.Position - myHrp.Position).Magnitude
                    if dist < 20 then
                        hum.Health = 0
                        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Dead) end)
                        pcall(function() p.Character:BreakJoints() end)
                        local explode = Instance.new("Explosion")
                        explode.BlastRadius = 8
                        explode.BlastPressure = 30000
                        explode.Position = hrp.Position
                        explode.Parent = workspace
                    end
                end
            end
        end
    end)

    tool.Parent = LocalPlayer.Backpack
    task.wait(0.1)
    tool.Parent = LocalPlayer.Character
    CurrentSword = tool
end

local function removeSword()
    if SwordConn then SwordConn:Disconnect() SwordConn = nil end
    if CurrentSword and CurrentSword.Parent then
        CurrentSword:Destroy()
        CurrentSword = nil
    end
end

-- ===== BUTTONS =====
makeButton("Fly", 50, function(btn)
    State.Fly = not State.Fly
    if State.Fly then startFly() btn.Text = "Fly [ON]" else stopFly() btn.Text = "Fly [OFF]" end
end)

makeButton("Bomb Server", 100, function(btn)
    bombServer()
    btn.Text = "Bomb Server [!!]"
    task.wait(2)
    btn.Text = "Bomb Server [OFF]"
end)

makeButton("Fling Touch", 150, function(btn)
    State.FlingTouch = not State.FlingTouch
    if State.FlingTouch then startFlingTouch() btn.Text = "Fling Touch [ON]" else stopFlingTouch() btn.Text = "Fling Touch [OFF]" end
end)

makeButton("Lag Server (Orb Killer)", 200, function(btn)
    State.LagServer = not State.LagServer
    if State.LagServer then startLagServer() btn.Text = "Lag Server [ON]" else stopLagServer() btn.Text = "Lag Server [OFF]" end
end)

makeButton("Big Body Spider", 250, function(btn)
    State.BigBody = not State.BigBody
    if State.BigBody then bigBodyON() btn.Text = "Big Body [ON]" else bigBodyOFF() btn.Text = "Big Body [OFF]" end
end)

makeButton("Get Sword (Real)", 300, function(btn)
    State.Sword = not State.Sword
    if State.Sword then giveSword() btn.Text = "Sword [ON]" else removeSword() btn.Text = "Sword [OFF]" end
end)

-- ===== AUTO RESPAWN =====
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if State.Fly then task.wait(1) startFly() end
    if State.Sword then task.wait(1) createSword() end
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        task.wait(2)
        if State.BigBody and not isMe(p) then
            saveOriginal(char)
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Massless = true
                    part.CanCollide = false
                    part.Shape = Enum.PartType.Ball
                end
            end
        end
    end)
end)

print("[SYSX] v4 — Real Sword + Lag Orb Killer + Fling Fix ✅")
