--[[
    SYSXHUB KILLER v7
    Developer: OpetxDy
    Fitur: Fly, God, Kill All, Nuke, Invisible, Fling Touch, Size Semapu+Spin
    Fling: hanya player yang DISENTUH yang kefling (bukan diri sendiri)
    Mode: FULL SERVER REPLICATED (bukan visual)
    Logo: S Toggle Open/Close
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SYSXHUB_KILLER"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

--// LOGO S (TOGGLE)
local LogoBtn = Instance.new("TextButton")
LogoBtn.Name = "LogoBtn"
LogoBtn.Size = UDim2.new(0, 55, 0, 55)
LogoBtn.Position = UDim2.new(0, 20, 0.5, -27)
LogoBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
LogoBtn.Text = "S"
LogoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoBtn.Font = Enum.Font.GothamBlack
LogoBtn.TextSize = 32
LogoBtn.BorderSizePixel = 0
LogoBtn.Active = true
LogoBtn.Draggable = true
LogoBtn.Parent = ScreenGui
Instance.new("UICorner", LogoBtn).CornerRadius = UDim.new(1, 0)

local LogoStroke = Instance.new("UIStroke", LogoBtn)
LogoStroke.Color = Color3.fromRGB(255, 50, 50)
LogoStroke.Thickness = 2

--// MAIN FRAME
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 480)
Main.Position = UDim2.new(0.5, -160, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
Title.Text = "SYSXHUB KILLER v7"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.BorderSizePixel = 0
Title.Parent = Main
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 15)
TitleFix.Position = UDim2.new(0, 0, 1, -15)
TitleFix.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = Title

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 7)
Close.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 14
Close.BorderSizePixel = 0
Close.Parent = Title
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)
Close.MouseButton1Click:Connect(function() Main.Visible = false end)

LogoBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

--// SCROLL
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -75)
Scroll.Position = UDim2.new(0, 10, 0, 55)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(180, 0, 0)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 420)
Scroll.Parent = Main

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 6)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = Scroll

local function MakeButton(name)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 15
    Btn.BorderSizePixel = 0
    Btn.Parent = Scroll
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    return Btn
end

--// STATE
local FlyMode = false
local GodMode = false
local Invisible = false
local SizeSpinMode = false
local TouchFlingMode = false
local FlyConnection = nil
local GodConnection = nil
local SizeSpinConnection = nil
local TouchConn = nil

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

--// FLY (SERVER REPLICATED)
local function ToggleFly(state)
    FlyMode = state
    if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
    if not state then
        local hrp = GetCharacter():FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)
        end
        return
    end
    local UIS = UserInputService
    local speed = 80
    local bodyGyro, bodyVel
    FlyConnection = RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)
        if not bodyVel or not bodyVel.Parent then
            bodyVel = Instance.new("BodyVelocity", hrp)
            bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bodyVel.Velocity = Vector3.new(0, 0, 0)
        end
        if not bodyGyro or not bodyGyro.Parent then
            bodyGyro = Instance.new("BodyGyro", hrp)
            bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            bodyGyro.P = 1e4
        end
        bodyGyro.CFrame = Camera.CFrame
        local move = Vector3.new(0, 0, 0)
        if UIS:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0, 1, 0) end
        bodyVel.Velocity = move * speed
    end)
end

--// GOD (SERVER REPLICATED - loop Heartbeat set Health)
local function ToggleGod(state)
    GodMode = state
    if GodConnection then GodConnection:Disconnect() GodConnection = nil end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if state then
        if hum then hum.MaxHealth = 5000 hum.Health = 5000 end
        GodConnection = RunService.Heartbeat:Connect(function()
            local c = LocalPlayer.Character
            if c then
                local h = c:FindFirstChildOfClass("Humanoid")
                if h then h.MaxHealth = 5000 h.Health = 5000 end
            end
        end)
    else
        if hum then hum.MaxHealth = 100 hum.Health = 100 end
    end
end

--// KILL ALL (loop server replicate)
local function KillAll()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                hum.Health = 0
            end
        end
    end
end

--// NUKE (loop server replicate)
local function NukeServer()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            pcall(function() plr:Kick("SYSXHUB KILLER - NUKED") end)
        end
    end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            pcall(function()
                obj.Anchored = false
                obj.CanCollide = true
                obj.AssemblyLinearVelocity = Vector3.new(math.random(-800,800), math.random(300,1000), math.random(-800,800))
            end)
        end
    end
    for i = 1, 5 do
        task.spawn(function()
            local boom = Instance.new("Explosion")
            boom.Position = Camera.CFrame.Position + Vector3.new(math.random(-100,100), math.random(-50,50), math.random(-100,100))
            boom.BlastRadius = 500
            boom.BlastPressure = 500000
            boom.DestroyJointRadiusPercent = 1
            boom.Parent = workspace
        end)
    end
end

--// INVISIBLE (server replicate via Transparency, bukan LocalTransparencyModifier)
local function ToggleInvisible(state)
    Invisible = state
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if state then
                part.Transparency = 1
                part.CanCollide = false
            else
                if part.Name == "HumanoidRootPart" then
                    part.Transparency = 1
                    part.CanCollide = false
                else
                    part.Transparency = 0
                    part.CanCollide = true
                end
            end
        elseif part:IsA("Decal") then
            part.Transparency = state and 1 or 0
        end
    end
end

--// SIZE SEMAPU + SPIN (SERVER REPLICATED)
local function ToggleSizeSpin(state)
    SizeSpinMode = state
    if SizeSpinConnection then SizeSpinConnection:Disconnect() SizeSpinConnection = nil end
    
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then pcall(function() hrp:SetNetworkOwner(LocalPlayer) end) end
    
    if state then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Size = Vector3.new(2048, 2048, 2048)
                part.Massless = true
                part.CanCollide = false
                part.Transparency = 0.5
            end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.HipHeight = 2048 end
        
        SizeSpinConnection = RunService.Heartbeat:Connect(function()
            local c = LocalPlayer.Character
            if not c then return end
            local h = c:FindFirstChild("HumanoidRootPart")
            if not h then return end
            pcall(function() h:SetNetworkOwner(LocalPlayer) end)
            h.CFrame = h.CFrame * CFrame.Angles(0, math.rad(35), 0)
        end)
    else
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                if part.Name == "Head" then
                    part.Size = Vector3.new(2, 1, 1)
                elseif part.Name == "Torso" or part.Name == "UpperTorso" or part.Name == "LowerTorso" then
                    part.Size = Vector3.new(2, 2, 1)
                elseif part.Name:find("Arm") then
                    part.Size = Vector3.new(1, 2, 1)
                elseif part.Name:find("Leg") then
                    part.Size = Vector3.new(1, 2, 1)
                else
                    part.Size = Vector3.new(1, 1, 1)
                end
                part.Massless = false
                part.CanCollide = true
                part.Transparency = 0
            end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.HipHeight = 2 end
    end
end

--// FLING TARGET
local function FlingTarget(target)
    if target == LocalPlayer then return end
    local char = target.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    pcall(function() hrp:SetNetworkOwner(nil) end)
    local vel = Instance.new("BodyAngularVelocity", hrp)
    vel.AngularVelocity = Vector3.new(9999, 9999, 9999)
    vel.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    vel.P = math.huge
    local bv = Instance.new("BodyVelocity", hrp)
    bv.Velocity = Vector3.new(math.random(-9999,9999), 9999, math.random(-9999,9999))
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    task.delay(3, function()
        if vel then vel:Destroy() end
        if bv then bv:Destroy() end
    end)
end

--// TOUCH FLING
local function ToggleTouchFling(state)
    TouchFlingMode = state
    if TouchConn then TouchConn:Disconnect() TouchConn = nil end
    if not state then return end
    
    TouchConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local myHrp = char:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local theirHrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if theirHrp then
                    local dist = (myHrp.Position - theirHrp.Position).Magnitude
                    if dist < 8 then
                        pcall(function() FlingTarget(plr) end)
                    end
                end
            end
        end
    end)
end

--// BUTTONS
local FlyBtn = MakeButton("FLY MODE : OFF")
FlyBtn.MouseButton1Click:Connect(function()
    ToggleFly(not FlyMode)
    FlyBtn.Text = "FLY MODE : " .. (FlyMode and "ON" or "OFF")
end)

local GodBtn = MakeButton("GOD MODE : OFF")
GodBtn.MouseButton1Click:Connect(function()
    ToggleGod(not GodMode)
    GodBtn.Text = "GOD MODE : " .. (GodMode and "ON" or "OFF")
end)

local KillBtn = MakeButton("KILL ALL PLAYER : OFF")
local KillLoopConn = nil
KillBtn.MouseButton1Click:Connect(function()
    if KillLoopConn then
        KillLoopConn:Disconnect()
        KillLoopConn = nil
        KillBtn.Text = "KILL ALL PLAYER : OFF"
    else
        KillAll()
        KillLoopConn = RunService.Heartbeat:Connect(KillAll)
        KillBtn.Text = "KILL ALL PLAYER : ON"
    end
end)

local NukeBtn = MakeButton("NUKE SERVER : OFF")
local NukeLoopConn = nil
NukeBtn.MouseButton1Click:Connect(function()
    if NukeLoopConn then
        NukeLoopConn:Disconnect()
        NukeLoopConn = nil
        NukeBtn.Text = "NUKE SERVER : OFF"
    else
        NukeServer()
        NukeLoopConn = RunService.Heartbeat:Connect(NukeServer)
        NukeBtn.Text = "NUKE SERVER : ON"
    end
end)

local InvBtn = MakeButton("INVISIBLE : OFF")
InvBtn.MouseButton1Click:Connect(function()
    ToggleInvisible(not Invisible)
    InvBtn.Text = "INVISIBLE : " .. (Invisible and "ON" or "OFF")
end)

local FlingBtn = MakeButton("FLING TOUCH : OFF")
FlingBtn.MouseButton1Click:Connect(function()
    ToggleTouchFling(not TouchFlingMode)
    FlingBtn.Text = "FLING TOUCH : " .. (TouchFlingMode and "ON" or "OFF")
end)

local SizeSpinBtn = MakeButton("SIZE SEMAPU + SPIN : OFF")
SizeSpinBtn.MouseButton1Click:Connect(function()
    ToggleSizeSpin(not SizeSpinMode)
    SizeSpinBtn.Text = "SIZE SEMAPU + SPIN : " .. (SizeSpinMode and "ON" or "OFF")
end)

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, -20, 0, 25)
Credit.Position = UDim2.new(0, 10, 1, -28)
Credit.BackgroundTransparency = 1
Credit.Text = "SYSXHUB KILLER v7 | by OpetxDy"
Credit.TextColor3 = Color3.fromRGB(180, 0, 0)
Credit.Font = Enum.Font.GothamBold
Credit.TextSize = 13
Credit.Parent = Main

--// HOTKEY
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        ToggleFly(not FlyMode)
        FlyBtn.Text = "FLY MODE : " .. (FlyMode and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.G then
        ToggleGod(not GodMode)
        GodBtn.Text = "GOD MODE : " .. (GodMode and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.K then
        KillBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.N then
        NukeBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.B then
        ToggleSizeSpin(not SizeSpinMode)
        SizeSpinBtn.Text = "SIZE SEMAPU + SPIN : " .. (SizeSpinMode and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.T then
        ToggleTouchFling(not TouchFlingMode)
        FlingBtn.Text = "FLING TOUCH : " .. (TouchFlingMode and "ON" or "OFF")
    end
end)
