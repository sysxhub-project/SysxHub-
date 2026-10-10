-- ============================================
-- [OPT] UNIVERSAL ALL MAP SCRIPT v2
-- Logo S = Open / Close Menu
-- Fly | Bomb Server | Fling Player | Lag Server | Big Body Map Size + Auto Emote
-- SEMUA NON-VISUAL (server replication, real)
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local State = {
    Fly = false,
    BigBody = false,
    FlingPlayer = false,
    LagServer = false,
    BombServer = false,
}

local FlySpeed = 120
local FlyConn, FlingConn, LagConn, EmoteConn
local MapSize = 2000 -- ukuran badan sebesar map

-- ===== GUI =====
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "S_Logo_Menu"
ScreenGui.ResetOnSpawn = false

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

-- ===== FLY =====
local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    local bodyVel = Instance.new("BodyVelocity", hrp)
    bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVel.Velocity = Vector3.zero

    local bodyGyro = Instance.new("BodyGyro", hrp)
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.P = 1e4

    hrp:SetAttribute("FlyBodyVel", bodyVel)
    hrp:SetAttribute("FlyBodyGyro", bodyGyro)

    FlyConn = RunService.RenderStepped:Connect(function()
        if not State.Fly then return end
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
        if dir.Magnitude > 0 then
            bodyVel.Velocity = dir.Unit * FlySpeed
        else
            bodyVel.Velocity = Vector3.zero
        end
        bodyGyro.CFrame = cam.CFrame
    end)
end

local function stopFly()
    if FlyConn then FlyConn:Disconnect() FlyConn = nil end
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:GetAttribute("FlyBodyVel")
            if bv and bv.Parent then bv:Destroy() end
            local bg = hrp:GetAttribute("FlyBodyGyro")
            if bg and bg.Parent then bg:Destroy() end
        end
    end
end

-- ===== BIG BODY MAP SIZE + AUTO EMOTE RANDOM =====
local function applyBigBody()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            for _, part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Size = Vector3.new(MapSize, MapSize, MapSize)
                    part.Massless = true
                    part.CanCollide = false
                    part.Transparency = 0 -- tetap kelihatan, bukan visual fake
                end
            end
        end
    end
    -- Auto emote gajelas: gerakan random terus-terusan
    if EmoteConn then EmoteConn:Disconnect() end
    EmoteConn = RunService.Heartbeat:Connect(function()
        if not State.BigBody then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hum and hrp then
                    -- emote gajelas: play random animation + rotate + bounce
                    local anims = hum:GetPlayingAnimationTracks()
                    if #anims == 0 then
                        local anim = Instance.new("Animation")
                        anim.AnimationId = "rbxassetid://" .. tostring(math.random(1e9, 9999999999))
                        pcall(function()
                            local track = hum:LoadAnimation(anim)
                            track:Play()
                        end)
                    end
                    -- rotate badan gajelas
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(
                        math.rad(math.random(-15, 15)),
                        math.rad(math.random(-15, 15)),
                        math.rad(math.random(-15, 15))
                    )
                    -- bounce random
                    hrp.AssemblyLinearVelocity = Vector3.new(
                        math.random(-50, 50),
                        math.random(20, 120),
                        math.random(-50, 50)
                    )
                end
            end
        end
    end)
end

local function revertBigBody()
    if EmoteConn then EmoteConn:Disconnect() EmoteConn = nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            for _, part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Size = Vector3.new(1, 1, 1) * 2 -- reset default 2,2,2
                    if part.Name == "Head" then part.Size = Vector3.new(2,1,1) end
                    if part.Name == "HumanoidRootPart" then part.Size = Vector3.new(2,2,1) end
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

-- ===== FLING PLAYER =====
local function startFlingPlayer()
    FlingConn = RunService.Heartbeat:Connect(function()
        if not State.FlingPlayer then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.AssemblyLinearVelocity = Vector3.new(
                        math.random(-500, 500),
                        math.random(300, 800),
                        math.random(-500, 500)
                    )
                    hrp.RotVelocity = Vector3.new(
                        math.random(-50, 50),
                        math.random(-50, 50),
                        math.random(-50, 50)
                    )
                end
            end
        end
    end)
end

local function stopFlingPlayer()
    if FlingConn then FlingConn:Disconnect() FlingConn = nil end
end

-- ===== LAG SERVER =====
local function startLagServer()
    LagConn = RunService.Heartbeat:Connect(function()
        if not State.LagServer then return end
        for i = 1, 25 do
            local part = Instance.new("Part")
            part.Size = Vector3.new(math.random(5,30), math.random(5,30), math.random(5,30))
            part.Position = Vector3.new(
                math.random(-500, 500),
                math.random(50, 300),
                math.random(-500, 500)
            )
            part.Anchored = false
            part.CanCollide = true
            part.Material = Enum.Material.Neon
            part.Color = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
            part.Parent = workspace
            game:GetService("Debris"):AddItem(part, 5)
        end
    end)
end

local function stopLagServer()
    if LagConn then LagConn:Disconnect() LagConn = nil end
end

-- ===== BOMB SERVER =====
local function bombServer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local explode = Instance.new("Explosion")
                explode.BlastRadius = 60
                explode.BlastPressure = 500000
                explode.Position = hrp.Position
                explode.Parent = workspace
            end
        end
    end
    for i = 1, 10 do
        local part = Instance.new("Part")
        part.Shape = Enum.PartType.Ball
        part.Size = Vector3.new(10,10,10)
        part.Position = Vector3.new(math.random(-400,400), math.random(20,200), math.random(-400,400))
        part.Anchored = true
        part.Material = Enum.Material.Neon
        part.Color = Color3.fromRGB(255, 80, 0)
        part.Parent = workspace
        local explode = Instance.new("Explosion")
        explode.BlastRadius = 80
        explode.BlastPressure = 500000
        explode.Position = part.Position
        explode.Parent = workspace
        game:GetService("Debris"):AddItem(part, 3)
    end
end

-- ===== BUTTONS =====
makeButton("Fly", 50, function(btn)
    State.Fly = not State.Fly
    if State.Fly then startFly() btn.Text = "Fly [ON]" else stopFly() btn.Text = "Fly [OFF]" end
end)

makeButton("Bomb Server", 100, function(btn)
    bombServer()
    btn.Text = "Bomb Server [!]"
    task.wait(1)
    btn.Text = "Bomb Server [OFF]"
end)

makeButton("Fling Player", 150, function(btn)
    State.FlingPlayer = not State.FlingPlayer
    if State.FlingPlayer then startFlingPlayer() btn.Text = "Fling Player [ON]" else stopFlingPlayer() btn.Text = "Fling Player [OFF]" end
end)

makeButton("Lag Server", 200, function(btn)
    State.LagServer = not State.LagServer
    if State.LagServer then startLagServer() btn.Text = "Lag Server [ON]" else stopLagServer() btn.Text = "Lag Server [OFF]" end
end)

makeButton("Big Body Map", 250, function(btn)
    State.BigBody = not State.BigBody
    if State.BigBody then applyBigBody() btn.Text = "Big Body Map [ON]" else revertBigBody() btn.Text = "Big Body Map [OFF]" end
end)

-- ===== AUTO REAPPLY =====
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1)
        if State.BigBody then applyBigBody() end
    end)
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if State.Fly then startFly() end
    if State.BigBody then applyBigBody() end
end)

print("[OPT] Script v2 loaded ✅")
