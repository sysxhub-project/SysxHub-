-- ============================================
-- [SYSX] UNIVERSAL ALL MAP SCRIPT v5
-- Logo S = Open/Close Menu
-- GodMode | Fly | Bomb Server | Fling Touch | Lag Server Orb | Big Body Spider | Get Sword
-- Semua fitur TOGGLE, diri sendiri AMAN (GodMode)
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
    GodMode = false,
}

local FlySpeed = 120
local FlyConn, FlyBodyVel, FlyBodyGyro
local FlingTouchConn, LagConn, SpiderConn, SwordConn, GodConn
local CurrentSword
local LagObjects = {}

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
MainFrame.Size = UDim2.new(0, 260, 0, 440)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -220)
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
Title.Text = "[SYSX] ALL MAP v5"
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

-- ===== GODMODE =====
local function startGodMode()
    if GodConn then GodConn:Disconnect() end
    GodConn = RunService.Heartbeat:Connect(function()
        if not State.GodMode then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
            hum.BreakJointsOnDeath = false
        end
        if not char:FindFirstChildOfClass("ForceField") then
            local ff = Instance.new("ForceField")
            ff.Visible = false
            ff.Parent = char
        end
    end)
end

local function stopGodMode()
    if GodConn then GodConn:Disconnect() GodConn = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.MaxHealth = 100
            hum.Health = 100
            hum.BreakJointsOnDeath = true
        end
        local ff = char:FindFirstChildOfClass("ForceField")
        if ff then ff:Destroy() end
    end
end

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
                hum.BreakJointsOnDeath = true
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

-- ===== FLING TOUCH =====
local function startFlingTouch()
    if FlingTouchConn then FlingTouchConn:Disconnect() end
    FlingTouchConn = RunService.Heartbeat:Connect(function()
        if not State.FlingTouch then return end
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myHrp = myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end

        myHrp.AssemblyLinearVelocity = Vector3.new(myHrp.AssemblyLinearVelocity.X, 0, myHrp.AssemblyLinearVelocity.Z)
        myHrp.RotVelocity = Vector3.zero

        for _, p in ipairs(Players:GetPlayers()) do
            if isOtherAlive(p) then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hum then
                    local dist = (hrp.Position - myHrp.Position).Magnitude
                    if dist < 30 then
                        local dir = (hrp.Position - myHrp.Position)
                        if dir.Magnitude < 1 then
                            dir = Vector3.new(math.random(-1,1), 0.5, math.random(-1,1))
                        end
                        dir = dir.Unit

                        hrp.AssemblyLinearVelocity = dir * 20000 + Vector3.new(0, 8000, 0)
                        hrp.AssemblyAngularVelocity = Vector3.new(
                            math.random(-999, 999),
                            math.random(-999, 999),
                            math.random(-999, 999)
                        )
                        hum:TakeDamage(math.random(50, 99))

                        task.spawn(function()
                            for i = 1, 20 do
                                if hrp and hrp.Parent then
                                    hrp.AssemblyLinearVelocity = dir * 20000 + Vector3.new(0, 8000, 0)
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
end

-- ===== LAG SERVER ORB =====
local function startLagServer()
    if LagConn then LagConn:Disconnect() end
    LagConn = RunService.Heartbeat:Connect(function()
        if not State.LagServer then return end
        local mapCenter = Vector3.new(0, 50, 0)

        for i = 1, 8 do
            local orb = Instance.new("Part")
            orb.Name = "SYSX_LagOrb"
            orb.Shape = Enum.PartType.Ball
            orb.Size = Vector3.new(60, 60, 60)
            orb.Material = Enum.Material.Neon
            orb.Color = Color3.fromRGB(255, 0, 255)
            orb.Anchored = true
            orb.CanCollide = true
            orb.Position = mapCenter
            orb.Parent = workspace
            table.insert(LagObjects, orb)
            game:GetService("Debris"):AddItem(orb, 15)

            task.spawn(function()
                local angle = math.random() * math.pi * 2
                local radius = 150 + i * 40
                for _ = 1, 100 do
                    if not orb.Parent or not State.LagServer then break end
                    angle = angle + 0.15
                    orb.CFrame = CFrame.new(
                        mapCenter.X + math.cos(angle) * radius,
                        mapCenter.Y + math.sin(angle * 3) * 40,
                        mapCenter.Z + math.sin(angle) * radius
                    )
                    for _, p in ipairs(Players:GetPlayers()) do
                        if isOtherAlive(p) then
                            local hum = p.Character:FindFirstChildOfClass("Humanoid")
                            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                            if hrp and hum and (hrp.Position - orb.Position).Magnitude < 55 then
                                hum.Health = 0
                                pcall(function() hum:ChangeState(Enum.HumanoidStateType.Dead) end)
                                pcall(function() p.Character:BreakJoints() end)
                            end
                        end
                    end
                    task.wait(0.03)
                end
            end)
        end

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

-- ===== GET SWORD =====
local function createSword()
    local char = LocalPlayer.Character
    if not char then return end
    if CurrentSword and CurrentSword.Parent then CurrentSword:Destroy() end

    local tool = Instance.new("Tool")
    tool.Name = "SYSX_Sword"
    tool.RequiresHandle = true
    tool.CanBeDropped = false

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.4, 1.2, 0.4)
    handle.Material = Enum.Material.Metal
    handle.Color = Color3.fromRGB(60, 30, 10)
    handle.Parent = tool

    local guard = Instance.new("Part")
    guard.Name = "Guard"
    guard.Size = Vector3.new(2, 0.3, 0.4)
    guard.Material = Enum.Material.Metal
    guard.Color = Color3.fromRGB(200, 180, 50)
    guard.CanCollide = false
    guard.Parent = tool
    local wg = Instance.new("Weld", handle) wg.Part0 = handle wg.Part1 = guard wg.C0 = CFrame.new(0, 0.6, 0)

    local blade = Instance.new("Part")
    blade.Name = "Blade"
    blade.Size = Vector3.new(0.15, 5, 1)
    blade.Material = Enum.Material.Metal
    blade.Color = Color3.fromRGB(220, 220, 230)
    blade.CanCollide = false
    blade.Parent = tool
    local wb = Instance.new("Weld", handle) wb.Part0 = handle wb.Part1 = blade wb.C0 = CFrame.new(0, 3.1, 0)

    local tip = Instance.new("WedgePart")
    tip.Name = "Tip"
    tip.Size = Vector3.new(0.15, 1, 1)
    tip.Material = Enum.Material.Metal
    tip.Color = Color3.fromRGB(230, 230, 240)
    tip.CanCollide = false
    tip.Parent = tool
    local wt = Instance.new("Weld", handle) wt.Part0 = handle wt.Part1 = tip wt.C0 = CFrame.new(0, 5.8, 0) * CFrame.Angles(0,0,math.rad(180))

    local pommel = Instance.new("Part")
    pommel.Shape = Enum.PartType.Ball
    pommel.Size = Vector3.new(0.5, 0.5, 0.5)
    pommel.Material = Enum.Material.Metal
    pommel.Color = Color3.fromRGB(200, 180, 50)
    pommel.CanCollide = false
    pommel.Parent = tool
    local wp = Instance.new("Weld", handle) wp.Part0 = handle wp.Part1 = pommel wp.C0 = CFrame.new(0, -0.8, 0)

    local light = Instance.new("PointLight", handle)
    light.Color = Color3.fromRGB(255, 0, 0)
    light.Range = 8
    light.Brightness = 2

    tool.Activated:Connect(function()
        if not State.Sword then return end
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if isOtherAlive(p) then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hum and (hrp.Position - myHrp.Position).Magnitude < 25 then
                    hum.Health = 0
                    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Dead) end)
                    pcall(function() p.Character:BreakJoints() end)
                end
            end
        end
    end)

    if SwordConn then SwordConn:Disconnect() end
    SwordConn = RunService.Heartbeat:Connect(function()
        if not State.Sword then return end
        if not tool.Parent then return end
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if isOtherAlive(p) then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hum and (hrp.Position - myHrp.Position).Magnitude < 12 then
                    hum.Health = 0
                    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Dead) end)
                    pcall(function() p.Character:BreakJoints() end)
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
makeButton("GodMode (Anti Mati)", 50, function(btn)
    State.GodMode = not State.GodMode
    if State.GodMode then startGodMode() btn.Text = "GodMode [ON]" else stopGodMode() btn.Text = "GodMode [OFF]" end
end)

makeButton("Fly", 100, function(btn)
    State.Fly = not State.Fly
    if State.Fly then startFly() btn.Text = "Fly [ON]" else stopFly() btn.Text = "Fly [OFF]" end
end)

makeButton("Bomb Server", 150, function(btn)
    bombServer()
    btn.Text = "Bomb Server [!!]"
    task.wait(2)
    btn.Text = "Bomb Server [OFF]"
end)

makeButton("Fling Touch", 200, function(btn)
    State.FlingTouch = not State.FlingTouch
    if State.FlingTouch then startFlingTouch() btn.Text = "Fling Touch [ON]" else stopFlingTouch() btn.Text = "Fling Touch [OFF]" end
end)

makeButton("Lag Server (Orb)", 250, function(btn)
    State.LagServer = not State.LagServer
    if State.LagServer then startLagServer() btn.Text = "Lag Server [ON]" else stopLagServer() btn.Text = "Lag Server [OFF]" end
end)

makeButton("Big Body Spider", 300, function(btn)
    State.BigBody = not State.BigBody
    if State.BigBody then bigBodyON() btn.Text = "Big Body [ON]" else bigBodyOFF() btn.Text = "Big Body [OFF]" end
end)

makeButton("Get Sword", 350, function(btn)
    State.Sword = not State.Sword
    if State.Sword then createSword() btn.Text = "Sword [ON]" else removeSword() btn.Text = "Sword [OFF]" end
end)

-- ===== AUTO RESPAWN =====
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if State.GodMode then task.wait(0.5) startGodMode() end
    if State.Fly then task.wait(0.5) startFly() end
    if State.Sword then task.wait(0.5) createSword() end
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

print("[SYSX] v5 loaded — GodMode + Toggle + All Fix ✅")
