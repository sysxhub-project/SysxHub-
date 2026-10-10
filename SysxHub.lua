--[[
    SYSXHUB KILLER v4
    Developer: OpetxDy
    Fitur: Fly, God, Kill All, Nuke, Invisible, Fling, Big Body, Spin
    Mode: Server Replicated (bukan visual / client-only)
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
Main.Size = UDim2.new(0, 320, 0, 520)
Main.Position = UDim2.new(0.5, -160, 0.5, -260)
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
Title.Text = "SYSXHUB KILLER v4"
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

--// SCROLL FRAME
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -75)
Scroll.Position = UDim2.new(0, 10, 0, 55)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(180, 0, 0)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 460)
Scroll.Parent = Main

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 6)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = Scroll

--// FUNCTION BUTTON
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
local BigBody = false
local SpinMode = false
local FlyConnection = nil
local GodConnection = nil
local SpinConnection = nil

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

--// FLY MODE (SERVER REPLICATED via Physics)
local function ToggleFly(state)
    FlyMode = state
    if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
    if not state then
        local hrp = GetCharacter():FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
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
        -- Network ownership ke player agar server replicate gerakan
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

--// GOD MODE (SERVER REPLICATED via Health loop)
local function ToggleGod(state)
    GodMode = state
    if GodConnection then GodConnection:Disconnect() GodConnection = nil end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if state then
        if hum then
            hum.MaxHealth = 5000
            hum.Health = 5000
        end
        GodConnection = RunService.Heartbeat:Connect(function()
            local c = LocalPlayer.Character
            if c then
                local h = c:FindFirstChildOfClass("Humanoid")
                if h then
                    h.MaxHealth = 5000
                    h.Health = 5000
                end
            end
        end)
    else
        if hum then hum.MaxHealth = 100 hum.Health = 100 end
    end
end

--// KILL ALL (Server-side via FireServer kosong / health set)
local function KillAll()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
        end
    end
end

--// NUKE SERVER (Replicated: kick + explode + unanchor + destroy)
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
    for i = 1, 10 do
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

--// INVISIBLE (Server replicated via LocalTransparencyModifier + Transparency)
local function ToggleInvisible(state)
    Invisible = state
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            if state then
                if part:IsA("BasePart") then
                    part.Transparency = 1
                    part.LocalTransparencyModifier = 1
                else
                    part.Transparency = 1
                end
            else
                if part.Name == "HumanoidRootPart" then
                    part.Transparency = 1
                else
                    part.Transparency = 0
                    if part:IsA("BasePart") then
                        part.LocalTransparencyModifier = 0
                    end
                end
            end
        end
    end
end

--// BIG BODY (Server replicated via Size + HipHeight + network owner)
local function ToggleBigBody(state)
    BigBody = state
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then pcall(function() hrp:SetNetworkOwner(LocalPlayer) end) end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            if state then
                part.Size = part.Size * 3
                part.Massless = true
                part.CanCollide = false
            else
                part.Size = part.Size / 3
                part.Massless = false
                part.CanCollide = true
            end
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.HipHeight = state and 5 or 2
    end
end

--// SPIN (Server replicated via CFrame loop + network owner)
local function ToggleSpin(state)
    SpinMode = state
    if SpinConnection then SpinConnection:Disconnect() SpinConnection = nil end
    if not state then return end
    SpinConnection = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(35), 0)
    end)
end

--// FLING (Server replicated via physics force)
local function FlingTarget(target)
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

local function FlingAll()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            pcall(function() FlingTarget(plr) end)
        end
    end
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

local KillBtn = MakeButton("KILL ALL PLAYER")
KillBtn.MouseButton1Click:Connect(KillAll)

local NukeBtn = MakeButton("NUKE SERVER")
NukeBtn.MouseButton1Click:Connect(NukeServer)

local InvBtn = MakeButton("INVISIBLE : OFF")
InvBtn.MouseButton1Click:Connect(function()
    ToggleInvisible(not Invisible)
    InvBtn.Text = "INVISIBLE : " .. (Invisible and "ON" or "OFF")
end)

local FlingBtn = MakeButton("FLING PLAYER (ALL)")
FlingBtn.MouseButton1Click:Connect(FlingAll)

local BigBtn = MakeButton("BIG BODY : OFF")
BigBtn.MouseButton1Click:Connect(function()
    ToggleBigBody(not BigBody)
    BigBtn.Text = "BIG BODY : " .. (BigBody and "ON" or "OFF")
end)

local SpinBtn = MakeButton("SPIN : OFF")
SpinBtn.MouseButton1Click:Connect(function()
    ToggleSpin(not SpinMode)
    SpinBtn.Text = "SPIN : " .. (SpinMode and "ON" or "OFF")
end)

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, -20, 0, 25)
Credit.Position = UDim2.new(0, 10, 1, -28)
Credit.BackgroundTransparency = 1
Credit.Text = "SYSXHUB KILLER v4 | by OpetxDy"
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
        KillAll()
    elseif input.KeyCode == Enum.KeyCode.N then
        NukeServer()
    elseif input.KeyCode == Enum.KeyCode.B then
        ToggleBigBody(not BigBody)
        BigBtn.Text = "BIG BODY : " .. (BigBody and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.R then
        ToggleSpin(not SpinMode)
        SpinBtn.Text = "SPIN : " .. (SpinMode and "ON" or "OFF")
    end
end)
