-- ============================================
-- [OPT] UNIVERSAL ALL MAP SCRIPT v5
-- Logo S = Open / Close Menu
-- Fly (FIXED) | Bomb Server (KILL ALL) | Fling Touch (Mental) | Lag Server
-- Big Body = Badan laba-laba, gede terus, muter-muter
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
local FlyConn, FlingTouchConn, LagConn, SpiderConn, TouchConn
local MapSize = 2000

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
ToggleBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
ToggleBtn.TextScaled = true
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Active = true
ToggleBtn.Draggable = true
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local stroke = Instance.new("UIStroke", ToggleBtn)
stroke.Color = Color3.fromRGB(255, 0, 0)
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
stroke2.Color = Color3.fromRGB(255, 0, 0)
stroke2.Thickness = 2

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "[OPT] ALL MAP SCRIPT"
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
    s.Color = Color3.fromRGB(255, 0, 0)
    s.Thickness = 1
    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)
    return btn
end

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ===== FLY (FIXED) =====
local FlyBodyVel, FlyBodyGyro

local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if FlyBodyVel and FlyBodyVel.Parent then FlyBodyVel:Destroy() end
    if FlyBodyGyro and FlyBodyGyro.Parent then FlyBodyGyro:Destroy() end

    FlyBodyVel = Instance.new("BodyVelocity")
    FlyBodyVel.Name = "OPT_FlyBodyVel"
    FlyBodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    FlyBodyVel.Velocity = Vector3.zero
    FlyBodyVel.Parent = hrp

    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.Name = "OPT_FlyBodyGyro"
    FlyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    FlyBodyGyro.P = 1e4
    FlyBodyGyro.D = 100
    FlyBodyGyro.CFrame = hrp.CFrame
    FlyBodyGyro.Parent = hrp

    if FlyConn then FlyConn:Disconnect() end
    FlyConn = RunService.RenderStepped:Connect(function()
        if not State.Fly then return end
        local currentChar = LocalPlayer.Character
        if not currentChar then return end
        local currentHrp = currentChar:FindFirstChild("HumanoidRootPart")
        if not currentHrp then return end
        if not FlyBodyVel or not FlyBodyVel.Parent then return end
        if not FlyBodyGyro or not FlyBodyGyro.Parent then return end

        local cam = workspace.CurrentCamera
        local dir = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end

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
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
        end
    end
end

-- ===== BIG BODY: LABA-LABA, GEDE TERUS, MUTER-MUTER =====
local function applyBigBody()
    -- reset dulu biar ga numpuk
    if SpiderConn then SpiderConn:Disconnect() end

    SpiderConn = RunService.Heartbeat:Connect(function()
        if not State.BigBody then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum then
                    for _, part in ipairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            -- gede terus (grow terus tiap frame)
                            part.Size = part.Size + Vector3.new(5, 5, 5)
                            part.Massless = true
                            part.CanCollide = false
                            part.Shape = Enum.PartType.Ball -- bentuk laba-laba bulat
                        end
                    end
                    -- muter-muter badan
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(
                        math.rad(math.random(-40, 40)),
                        math.rad(math.random(-40, 40)),
                        math.rad(math.random(-40, 40))
                    )
                    hrp.RotVelocity = Vector3.new(
                        math.random(-80, 80),
                        math.random(-80, 80),
                        math.random(-80, 80)
                    )
                    -- emote gajelas (gerak-gerak laba-laba)
                    local anims = hum:GetPlayingAnimationTracks()
                    if #anims == 0 then
                        local anim = Instance.new("Animation")
                        anim.AnimationId = "rbxassetid://" .. tostring(math.random(1e9, 9999999999))
                        pcall(function()
                            local track = hum:LoadAnimation(anim)
                            track:Play()
                        end)
                    end
                    -- mental ke atas biar keliatan laba-laba terbang
                    hrp.AssemblyLinearVelocity = Vector3.new(
                        math.random(-30, 30),
                        math.random(10, 60),
                        math.random(-30, 30)
                    )
                end
            end
        end
    end)
end

local function revertBigBody()
    if SpiderConn then SpiderConn:Disconnect() SpiderConn = nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            for _, part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    if part.Name == "Head" then part.Size = Vector3.new(2,1,1)
                    elseif part.Name == "HumanoidRootPart" then part.Size = Vector3.new(2,2,1)
                    else part.Size = Vector3.new(2,2,2) end
                    part.Shape = Enum.PartType.Block
                    part.CanCollide = true
                end
            end
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                    track:Stop()
                end
            end
        end
    end
end

-- ===== BOMB SERVER = KILL SEMUA PLAYER =====
local function bombServer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
        end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local explode = Instance.new("Explosion")
                explode.BlastRadius = 500
                explode.BlastPressure = 5000000
                explode.DestroyJointRadiusPercent = 1
                explode.Position = hrp.Position
                explode.Parent = workspace
            end
        end
    end
    for i = 1, 30 do
        local pos = Vector3.new(math.random(-800,800), math.random(20,300), math.random(-800,800))
        local explode = Instance.new("Explosion")
        explode.BlastRadius = 300
        explode.BlastPressure = 5000000
        explode.DestroyJointRadiusPercent = 1
        explode.Position = pos
        explode.Parent = workspace
    end
end

-- ===== FLING TOUCH = SENTUH PLAYER = MENTAL JAUH =====
local function startFlingTouch()
    if TouchConn then TouchConn:Disconnect() end
    TouchConn = RunService.Heartbeat:Connect(function()
        if not State.FlingTouch then return end
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myHrp = myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (hrp.Position - myHrp.Position).Magnitude
                    if dist < 15 then
                        local dir = (hrp.Position - myHrp.Position).Unit
                        hrp.AssemblyLinearVelocity = dir * 5000 + Vector3.new(0, 2000, 0)
                        hrp.RotVelocity = Vector3.new(
                            math.random(-500, 500),
                            math.random(-500, 500),
                            math.random(-500, 500)
                        )
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        if hum then hum:TakeDamage(math.random(20, 60)) end
                    end
                end
            end
        end
    end)
end

local function stopFlingTouch()
    if TouchConn then TouchConn:Disconnect() TouchConn = nil end
end

-- ===== LAG SERVER = DAMPAK KE SEMUA PLAYER =====
local function startLagServer()
    if LagConn then LagConn:Disconnect() end
    LagConn = RunService.Heartbeat:Connect(function()
        if not State.LagServer then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for i = 1, 15 do
                        local part = Instance.new("Part")
                        part.Size = Vector3.new(
                            math.random(20, 80),
                            math.random(20, 80),
                            math.random(20, 80)
                        )
                        part.Position = hrp.Position + Vector3.new(
                            math.random(-100, 100),
                            math.random(-100, 100),
                            math.random(-100, 100)
                        )
                        part.Anchored = false
                        part.CanCollide = true
                        part.Material = Enum.Material.Neon
                        part.Color = Color3.fromRGB(
                            math.random(0,255),
                            math.random(0,255),
                            math.random(0,255)
                        )
                        part.Parent = workspace
                        game:GetService("Debris"):AddItem(part, 8)
                    end
                end
            end
        end
        for i = 1, 10 do
            local part = Instance.new("Part")
            part.Size = Vector3.new(
                math.random(30, 100),
                math.random(30, 100),
                math.random(30, 100)
            )
            part.Position = Vector3.new(
                math.random(-800, 800),
                math.random(50, 400),
                math.random(-800, 800)
            )
            part.Anchored = false
            part.CanCollide = true
            part.Material = Enum.Material.Neon
            part.Color = Color3.fromRGB(
                math.random(0,255),
                math.random(0,255),
                math.random(0,255)
            )
            part.Parent = workspace
            game:GetService("Debris"):AddItem(part, 8)
        end
    end)
end

local function stopLagServer()
    if LagConn then LagConn:Disconnect() LagConn = nil end
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
    if State.FlingTouch then startFlingTouch() btn.Text = "Fling Touch [ON]" else stopFlingTouch() btn.Text = "Fling Touch [OFF]" end
end)

makeButton("Lag Server (Dampak)", 200, function(btn)
    State.LagServer = not State.LagServer
    if State.LagServer then startLagServer() btn.Text = "Lag Server [ON]" else stopLagServer() btn.Text = "Lag Server [OFF]" end
end)

makeButton("Big Body Spider", 250, function(btn)
    State.BigBody = not State.BigBody
    if State.BigBody then applyBigBody() btn.Text = "Big Body Spider [ON]" else revertBigBody() btn.Text = "Big Body Spider [OFF]" end
end)

-- ===== AUTO REAPPLY SAAT RESPAWN =====
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1)
        if State.BigBody then applyBigBody() end
    end)
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if State.Fly then startFly() end
    if State.BigBody then applyBigBody() end
    task.wait(2)
    if State.Fly then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and not hrp:FindFirstChild("OPT_FlyBodyVel") then
            startFly()
        end
    end
end)

print("[OPT] Script v5 loaded — Big Body Spider ✅")
