--[[
    SYSXHUB TROLL + SAFE + ROCKET
    Fitur:
    - Troll: Spin, Fling, Drag, Dance, Chaos, TP Sky, Freeze, Random Size,
             Invisible, Speed Chaos, Gravity Chaos
    - Safe Zone: Anti semua bencana + Auto TP Safe Zone
    - Auto Rocket: TP ke kursi roket, start, jalankan
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SYSXHUB_TROLL"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

--// LOGO S
local LogoBtn = Instance.new("TextButton")
LogoBtn.Size = UDim2.new(0, 55, 0, 55)
LogoBtn.Position = UDim2.new(0, 20, 0.5, -27)
LogoBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
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
LogoStroke.Color = Color3.fromRGB(200, 0, 255)
LogoStroke.Thickness = 2

--// MAIN FRAME
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 340, 0, 520)
Main.Position = UDim2.new(0.5, -170, 0.5, -260)
Main.BackgroundColor3 = Color3.fromRGB(20, 10, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
Title.Text = "SYSXHUB TROLL"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.BorderSizePixel = 0
Title.Parent = Main
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 15)
TitleFix.Position = UDim2.new(0, 0, 1, -15)
TitleFix.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
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

--// TAB BUTTONS
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 0, 30)
TabContainer.Position = UDim2.new(0, 10, 0, 55)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = Main

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 4)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabContainer

local function MakeTab(name, order)
    local Tab = Instance.new("TextButton")
    Tab.Size = UDim2.new(0, 96, 0, 28)
    Tab.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Tab.Text = name
    Tab.TextColor3 = Color3.fromRGB(200, 200, 200)
    Tab.Font = Enum.Font.GothamBold
    Tab.TextSize = 12
    Tab.BorderSizePixel = 0
    Tab.LayoutOrder = order
    Tab.Parent = TabContainer
    Instance.new("UICorner", Tab).CornerRadius = UDim.new(0, 6)
    return Tab
end

local TabTroll = MakeTab("TROLL", 1)
local TabSafe = MakeTab("SAFE ZONE", 2)
local TabRocket = MakeTab("ROCKET", 3)

--// SCROLL
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -145)
Scroll.Position = UDim2.new(0, 10, 0, 90)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(200, 0, 255)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = Main

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 6)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = Scroll

local function MakeButton(name, order)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 20, 50)
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 14
    Btn.BorderSizePixel = 0
    Btn.LayoutOrder = order or 0
    Btn.Parent = Scroll
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    return Btn
end

local function ClearButtons()
    for _, v in pairs(Scroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
end

--// STATE
local TrollSpin, TrollFling, TrollDrag, TrollDance, TrollChaos = false, false, false, false, false
local SafeZone, AutoRocketMode = false, false
local ConnSpin, ConnFling, ConnDrag, ConnDance, ConnChaos, ConnSafe, ConnRocket = nil, nil, nil, nil, nil, nil, nil

local function GetPlayers()
    local list = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            table.insert(list, plr)
        end
    end
    return list
end

--// SPIN
local function ToggleTrollSpin(state)
    TrollSpin = state
    if ConnSpin then ConnSpin:Disconnect() ConnSpin = nil end
    if not state then return end
    ConnSpin = RunService.Heartbeat:Connect(function()
        for _, plr in pairs(GetPlayers()) do
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                pcall(function() hrp:SetNetworkOwner(nil) end)
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(45), math.rad(15))
            end
        end
    end)
end

--// FLING
local function FlingPlayer(plr)
    local char = plr.Character
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

local function ToggleTrollFling(state)
    TrollFling = state
    if ConnFling then ConnFling:Disconnect() ConnFling = nil end
    if not state then return end
    ConnFling = RunService.Heartbeat:Connect(function()
        for _, plr in pairs(GetPlayers()) do
            pcall(function() FlingPlayer(plr) end)
        end
    end)
end

--// DRAG
local function DragPlayer(plr)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local theirHrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not theirHrp then return end
    if (hrp.Position - theirHrp.Position).Magnitude > 5 then
        pcall(function() theirHrp:SetNetworkOwner(LocalPlayer) end)
        theirHrp.CFrame = theirHrp.CFrame + (hrp.Position - theirHrp.Position).Unit * 2
    end
end

local function ToggleTrollDrag(state)
    TrollDrag = state
    if ConnDrag then ConnDrag:Disconnect() ConnDrag = nil end
    if not state then return end
    ConnDrag = RunService.Heartbeat:Connect(function()
        for _, plr in pairs(GetPlayers()) do
            pcall(function() DragPlayer(plr) end)
        end
    end)
end

--// DANCE
local function DancePlayer(plr)
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)
    hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(20), 0, math.rad(20))
end

local function ToggleTrollDance(state)
    TrollDance = state
    if ConnDance then ConnDance:Disconnect() ConnDance = nil end
    if not state then return end
    ConnDance = RunService.Heartbeat:Connect(function()
        for _, plr in pairs(GetPlayers()) do
            pcall(function() DancePlayer(plr) end)
        end
    end)
end

--// CHAOS
local function ToggleTrollChaos(state)
    TrollChaos = state
    if ConnChaos then ConnChaos:Disconnect() ConnChaos = nil end
    if not state then return end
    ConnChaos = RunService.Heartbeat:Connect(function()
        for _, plr in pairs(GetPlayers()) do
            local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)
                hrp.CFrame = hrp.CFrame * CFrame.Angles(
                    math.rad(math.random(-30,30)),
                    math.rad(math.random(-30,30)),
                    math.rad(math.random(-30,30))
                )
                hrp.AssemblyLinearVelocity = Vector3.new(math.random(-100,100), math.random(50,200), math.random(-100,100))
            end
        end
    end)
end

--// INSTANT TROLL
local function TeleportAllToSky()
    for _, plr in pairs(GetPlayers()) do
        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function()
                hrp:SetNetworkOwner(nil)
                hrp.CFrame = CFrame.new(hrp.Position.X, 5000, hrp.Position.Z)
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end)
        end
    end
end

local function FreezeAll()
    for _, plr in pairs(GetPlayers()) do
        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if hrp then pcall(function() hrp:SetNetworkOwner(nil) hrp.Anchored = true end) end
    end
    task.delay(5, function()
        for _, plr in pairs(GetPlayers()) do
            local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then pcall(function() hrp.Anchored = false end) end
        end
    end)
end

local function RandomSizeAll()
    for _, plr in pairs(GetPlayers()) do
        for _, part in pairs(plr.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                local scale = math.random(1, 5)
                pcall(function() part.Size = part.Size * scale part.Massless = true end)
            end
        end
    end
end

local function InvisibleAll()
    for _, plr in pairs(GetPlayers()) do
        for _, part in pairs(plr.Character:GetDescendants()) do
            if part:IsA("BasePart") then pcall(function() part.Transparency = 1 end) end
        end
    end
end

local function SpeedChaosAll()
    for _, plr in pairs(GetPlayers()) do
        local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = math.random(1, 500) hum.JumpPower = math.random(1, 500) end
    end
end

local function GravityChaosAll()
    for _, plr in pairs(GetPlayers()) do
        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            pcall(function() hrp:SetNetworkOwner(nil) end)
            local bf = Instance.new("BodyForce", hrp)
            bf.Force = Vector3.new(math.random(-5000,5000), math.random(0,10000), math.random(-5000,5000))
            task.delay(3, function() bf:Destroy() end)
        end
    end
end

--// SAFE ZONE
local function ToggleSafeZone(state)
    SafeZone = state
    if ConnSafe then ConnSafe:Disconnect() ConnSafe = nil end
    if not state then return end
    ConnSafe = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp then return end
        pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)
        if hum then hum.MaxHealth = 5000 hum.Health = 5000 end
        hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.y, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        if hrp.Position.Y < 50 then
            hrp.CFrame = CFrame.new(0, 500, 0)
        end
        for _, obj in pairs(char:GetDescendants()) do
            if obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then obj:Destroy() end
        end
    end)
end

--// AUTO ROCKET
local function RunAutoRocket()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or not hum then return end
    pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)

    local rocket, seat = nil, nil
    for _, obj in pairs(workspace:GetDescendants()) do
        local n = obj.Name:lower()
        if obj:IsA("Model") and (n:find("rocket") or n:find("roket")) then
            rocket = obj
            break
        end
    end
    if not rocket then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("VehicleSeat") then
                if obj.Name:lower():find("rocket") or obj.Name:lower():find("roket") or obj.Parent.Name:lower():find("rocket") then
                    rocket = obj.Parent
                    seat = obj
                    break
                end
            end
        end
    end
    if not rocket then return end
    if not seat then
        for _, obj in pairs(rocket:GetDescendants()) do
            if obj:IsA("VehicleSeat") or obj:IsA("Seat") then
                seat = obj
                break
            end
        end
    end
    if not seat then return end

    hrp.CFrame = seat.CFrame + Vector3.new(0, 3, 0)
    task.wait(0.2)
    hum.Sit = true
    seat:Sit(hum)
    task.wait(0.3)

    for _, obj in pairs(rocket:GetDescendants()) do
        if obj:IsA("BasePart") then
            pcall(function() obj:SetNetworkOwner(LocalPlayer) end)
            pcall(function()
                firetouchinterest(hrp, obj, 0)
                firetouchinterest(hrp, obj, 1)
            end)
            if obj:IsA("VehicleSeat") then
                pcall(function() obj.Throttle = 1 obj.Steer = 0 end)
            end
        elseif obj:IsA("ClickDetector") then
            pcall(function() fireclickdetector(obj) end)
        elseif obj:IsA("RemoteEvent") then
            pcall(function() obj:FireServer() end)
        elseif obj:IsA("ProximityPrompt") then
            pcall(function() fireproximityprompt(obj) end)
        end
    end
end

local function ToggleAutoRocket(state)
    AutoRocketMode = state
    if ConnRocket then ConnRocket:Disconnect() ConnRocket = nil end
    if not state then return end
    RunAutoRocket()
    ConnRocket = RunService.Heartbeat:Connect(function()
        if AutoRocketMode then pcall(RunAutoRocket) end
    end)
end

--// TAB SWITCH
local function ShowTab(tab)
    ClearButtons()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

    if tab == "TROLL" then
        local a = MakeButton("SPIN PLAYER : OFF", 1)
        a.MouseButton1Click:Connect(function() ToggleTrollSpin(not TrollSpin) a.Text = "SPIN PLAYER : " .. (TrollSpin and "ON" or "OFF") end)
        local b = MakeButton("FLING PLAYER : OFF", 2)
        b.MouseButton1Click:Connect(function() ToggleTrollFling(not TrollFling) b.Text = "FLING PLAYER : " .. (TrollFling and "ON" or "OFF") end)
        local c = MakeButton("DRAG PLAYER : OFF", 3)
        c.MouseButton1Click:Connect(function() ToggleTrollDrag(not TrollDrag) c.Text = "DRAG PLAYER : " .. (TrollDrag and "ON" or "OFF") end)
        local d = MakeButton("DANCE : OFF", 4)
        d.MouseButton1Click:Connect(function() ToggleTrollDance(not TrollDance) d.Text = "DANCE : " .. (TrollDance and "ON" or "OFF") end)
        local e = MakeButton("CHAOS MODE : OFF", 5)
        e.MouseButton1Click:Connect(function() ToggleTrollChaos(not TrollChaos) e.Text = "CHAOS MODE : " .. (TrollChaos and "ON" or "OFF") end)
        local f = MakeButton("TELEPORT ALL TO SKY", 6)
        f.MouseButton1Click:Connect(TeleportAllToSky)
        local g = MakeButton("FREEZE ALL (5 detik)", 7)
        g.MouseButton1Click:Connect(FreezeAll)
        local h = MakeButton("RANDOM SIZE ALL", 8)
        h.MouseButton1Click:Connect(RandomSizeAll)
        local i = MakeButton("INVISIBLE ALL", 9)
        i.MouseButton1Click:Connect(InvisibleAll)
        local j = MakeButton("SPEED CHAOS", 10)
        j.MouseButton1Click:Connect(SpeedChaosAll)
        local k = MakeButton("GRAVITY CHAOS", 11)
        k.MouseButton1Click:Connect(GravityChaosAll)

    elseif tab == "SAFE" then
        local a = MakeButton("AUTO SAFE ZONE : OFF", 1)
        a.MouseButton1Click:Connect(function() ToggleSafeZone(not SafeZone) a.Text = "AUTO SAFE ZONE : " .. (SafeZone and "ON" or "OFF") end)

    elseif tab == "ROCKET" then
        local a = MakeButton("AUTO ROCKET : OFF", 1)
        a.MouseButton1Click:Connect(function() ToggleAutoRocket(not AutoRocketMode) a.Text = "AUTO ROCKET : " .. (AutoRocketMode and "ON" or "OFF") end)
    end
end

TabTroll.MouseButton1Click:Connect(function() ShowTab("TROLL") end)
TabSafe.MouseButton1Click:Connect(function() ShowTab("SAFE") end)
TabRocket.MouseButton1Click:Connect(function() ShowTab("ROCKET") end)

ShowTab("TROLL")
