-- ============================================
-- [SYSX] UNIVERSAL ALL MAP SCRIPT v1
-- Logo S = Open / Close Menu
-- Fly (FIXED) | Bomb Server (KILL ALL REAL) | Fling Touch (Mental)
-- Lag Server (REAL) | Big Body Spider (TOGGLE CLEAN)
-- SEMUA NON-VISUAL, SERVER REPLICATION
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
}

local FlySpeed = 120
local FlyConn, FlyBodyVel, FlyBodyGyro
local FlingTouchConn
local LagConn
local SpiderConn

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
MainFrame.Size = UDim2.new(0, 260, 0, 340)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -170)
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
Title.Text = "[SYSX] ALL MAP v1"
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
    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)
    return btn
end

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ===== FLY (FIXED - CAMERA BASED) =====
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

        if hum.MoveDirection.Magnitude > 0 then
            dir = dir + hum.MoveDirection
        end

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

-- ===== BOMB SERVER (KILL ALL - REAL) =====
local function bombServer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hum then
                hum.Health = 0
                pcall(function()
                    hum:ChangeState(Enum.HumanoidStateType.Dead)
                end)
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
        end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        pcall(function()
            p.Character:BreakJoints()
        end)
    end
end

-- ===== FLING TOUCH (MENTAL - HANYA ORANG LAIN) =====
local function startFlingTouch()
    if FlingTouchConn then FlingTouchConn:Disconnect() end
    FlingTouchConn = RunService.Heartbeat:Connect(function()
        if not State.FlingTouch then return end
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myHrp = myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end

        -- bekuin badan kita biar ga mental sendiri
        myHrp.AssemblyLinearVelocity = Vector3.new(myHrp.AssemblyLinearVelocity.X, 0, myHrp.AssemblyLinearVelocity.Z)

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hum and hum.Health > 0 then
                    local dist = (hrp.Position - myHrp.Position).Magnitude
                    if dist < 20 then
                        local dir = (hrp.Position - myHrp.Position)
                        if dir.Magnitude < 1 then
                            dir = Vector3.new(math.random(-1,1), 0.5, math.random(-1,1))
                        end
                        dir = dir.Unit

                        hrp.AssemblyLinearVelocity = dir * 8000 + Vector3.new(0, 3000, 0)
                        hrp.RotVelocity = Vector3.new(
                            math.random(-999, 999),
                            math.random(-999, 999),
                            math.random(-999, 999)
                        )
                        hum:TakeDamage(math.random(30, 80))

                        task.spawn(function()
                            for i = 1, 10 do
                                if hrp and hrp.Parent then
                                    hrp.AssemblyLinearVelocity = dir * 8000 + Vector3.new(0, 3000, 0)
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

-- ===== LAG SERVER (REAL IMPACT) =====
local function startLagServer()
    if LagConn then LagConn:Disconnect() end
    LagConn = RunService.Heartbeat:Connect(function()
        if not State.LagServer then return end

        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(
                        math.random(-1000, 1000),
                        math.random(50, 500),
                        math.random(-1000, 1000)
                    )
                end

                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    for i = 1, 5 do
                        local attach = Instance.new("Attachment")
                        attach.Parent = hum.RootPart or hum.Parent:FindFirstChild("HumanoidRootPart")
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

        pcall(function()
            game.Lighting.ClockTime = tick() % 24
            game.Lighting.FogEnd = math.random(0, 1000)
        end)

        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    p.Character.HumanoidRootPart:SetNetworkOwner(nil)
                end)
            end
        end
    end)
end

local function stopLagServer()
    if LagConn then LagConn:Disconnect() LagConn = nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                p.Character.HumanoidRootPart:SetNetworkOwner(p)
            end)
        end
    end
end

-- ===== BIG BODY SPIDER (TOGGLE CLEAN) =====
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
        if p.Character then
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
            if p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 then
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
        if p.Character then
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

-- ===== BUTTONS =====
makeButton("Fly", 50, function(btn)
    State.Fly = not State.Fly
    if State.Fly then
        startFly()
        btn.Text = "Fly [ON]"
    else
        stopFly()
        btn.Text = "Fly [OFF]"
    end
end)

makeButton("Bomb Server (KILL ALL)", 100, function(btn)
    bombServer()
    btn.Text = "Bomb Server [!!]"
    task.wait(2)
    btn.Text = "Bomb Server [OFF]"
end)

makeButton("Fling Touch (Mental)", 150, function(btn)
    State.FlingTouch = not State.FlingTouch
    if State.FlingTouch then
        startFlingTouch()
        btn.Text = "Fling Touch [ON]"
    else
        stopFlingTouch()
        btn.Text = "Fling Touch [OFF]"
    end
end)

makeButton("Lag Server (Real)", 200, function(btn)
    State.LagServer = not State.LagServer
    if State.LagServer then
        startLagServer()
        btn.Text = "Lag Server [ON]"
    else
        stopLagServer()
        btn.Text = "Lag Server [OFF]"
    end
end)

makeButton("Big Body Spider", 250, function(btn)
    State.BigBody = not State.BigBody
    if State.BigBody then
        bigBodyON()
        btn.Text = "Big Body [ON]"
    else
        bigBodyOFF()
        btn.Text = "Big Body [OFF]"
    end
end)

-- ===== AUTO HANDLE RESPAWN =====
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if State.Fly then
        task.wait(1)
        startFly()
    end
    if State.BigBody then
        task.wait(1)
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

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        task.wait(2)
        if State.BigBody then
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

print("[SYSX] Universal All Map Script v1 loaded ✅")
