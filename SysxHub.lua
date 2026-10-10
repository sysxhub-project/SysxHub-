--[[
    SYSXHUB TROLL PANEL v2
    Developer: OpetxDy
    Layout: Tab | Fitur (Sidebar kiri)
    Mode: FULL SERVER REPLICATED (bukan visual)
    
    Tab TROLL: Spin, Fling, Drag, Dance, Chaos, TP Sky, Freeze, Random Size,
               Invisible, Speed Chaos, Gravity Chaos, Rocket Player, Slap,
               Force Sit, Undress, Strip Tools, Explode, Confuse
    Tab SAFE ZONE: Auto Safe Zone (anti semua bencana)
    Tab ROCKET: Auto Rocket (TP kursi, start, jalanin)
    Tab UTILITY: Anti AFK, Auto Rejoin, Server Hop, Copy Job ID, ESP Player,
                 Fullbright, No Fog, Infinite Jump, Walkspeed, Fly
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

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
Main.Size = UDim2.new(0, 520, 0, 400)
Main.Position = UDim2.new(0.5, -260, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(20, 10, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Visible = false
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

--// HEADER
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
Header.BorderSizePixel = 0
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 12)
HeaderFix.Position = UDim2.new(0, 0, 1, -12)
HeaderFix.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "SYSXHUB TROLL PANEL v2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 26, 0, 26)
Close.Position = UDim2.new(1, -33, 0, 7)
Close.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 13
Close.BorderSizePixel = 0
Close.Parent = Header
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)
Close.MouseButton1Click:Connect(function() Main.Visible = false end)

LogoBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

--// SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -55)
Sidebar.Position = UDim2.new(0, 10, 0, 48)
Sidebar.BackgroundColor3 = Color3.fromRGB(28, 15, 35)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 6)
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 8)
SidebarPadding.PaddingLeft = UDim.new(0, 8)
SidebarPadding.PaddingRight = UDim.new(0, 8)
SidebarPadding.Parent = Sidebar

local function MakeTab(name, order)
    local Tab = Instance.new("TextButton")
    Tab.Size = UDim2.new(1, 0, 0, 32)
    Tab.BackgroundColor3 = Color3.fromRGB(50, 25, 65)
    Tab.Text = name
    Tab.TextColor3 = Color3.fromRGB(220, 220, 220)
    Tab.Font = Enum.Font.GothamBold
    Tab.TextSize = 12
    Tab.BorderSizePixel = 0
    Tab.LayoutOrder = order
    Tab.Parent = Sidebar
    Instance.new("UICorner", Tab).CornerRadius = UDim.new(0, 6)
    return Tab
end

local TabTroll = MakeTab("TROLL", 1)
local TabSafe = MakeTab("SAFE ZONE", 2)
local TabRocket = MakeTab("ROCKET", 3)
local TabUtility = MakeTab("UTILITY", 4)

--// CONTENT
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -160, 1, -55)
Content.Position = UDim2.new(0, 148, 0, 48)
Content.BackgroundColor3 = Color3.fromRGB(28, 15, 35)
Content.BorderSizePixel = 0
Content.Parent = Main
Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 8)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -16)
Scroll.Position = UDim2.new(0, 8, 0, 8)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(200, 0, 255)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.Parent = Content

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 6)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = Scroll

local function MakeButton(name, order)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 38)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 25, 65)
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 13
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
local TrollSpin, TrollFling, TrollDrag, TrollDance, TrollChaos, TrollConfuse = false, false, false, false, false, false
local SafeZone, AutoRocketMode = false, false
local AntiAFK, ESPEnabled, Fullbright, NoFog, InfiniteJump = false, false, false, false, false
local ConnSpin, ConnFling, ConnDrag, ConnDance, ConnChaos, ConnConfuse, ConnSafe, ConnRocket = nil, nil, nil, nil, nil, nil, nil, nil
local ConnAntiAFK, ConnJump, ESPObjects = nil, nil, {}

local function GetPlayers()
    local list = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            table.insert(list, plr)
        end
    end
    return list
end

--// ============ TROLL ============

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

--// CONFUSE (bikin player random gerak)
local function ToggleTrollConfuse(state)
    TrollConfuse = state
    if ConnConfuse then ConnConfuse:Disconnect() ConnConfuse = nil end
    if not state then return end
    ConnConfuse = RunService.Heartbeat:Connect(function()
        for _, plr in pairs(GetPlayers()) do
            local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = math.random(-50, 200)
                hum.JumpPower = math.random(0, 200)
            end
        end
    end)
end

--// ROCKET PLAYER (kirim player ke angkasa)
local function RocketPlayer(plr)
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    pcall(function() hrp:SetNetworkOwner(nil) end)
    local bv = Instance.new("BodyVelocity", hrp)
    bv.Velocity = Vector3.new(0, 500, 0)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    task.delay(5, function() if bv then bv:Destroy() end end)
end

--// SLAP (dorong player)
local function SlapPlayer(plr)
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    local theirHrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not theirHrp then return end
    local dir = (theirHrp.Position - myHrp.Position).Unit
    pcall(function() theirHrp:SetNetworkOwner(nil) end)
    local bv = Instance.new("BodyVelocity", theirHrp)
    bv.Velocity = dir * 500 + Vector3.new(0, 200, 0)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    task.delay(1, function() if bv then bv:Destroy() end end)
end

--// FORCE SIT (paksa player duduk di lantai)
local function ForceSitAll()
    for _, plr in pairs(GetPlayers()) do
        local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function() hum.Sit = true end)
        end
    end
end

--// UNDRESS (hapus aksesoris + pakaian player)
local function UndressAll()
    for _, plr in pairs(GetPlayers()) do
        for _, obj in pairs(plr.Character:GetDescendants()) do
            if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") then
                pcall(function() obj:Destroy() end)
            end
        end
    end
end

--// STRIP TOOLS (hapus semua tool di tangan player)
local function StripToolsAll()
    for _, plr in pairs(GetPlayers()) do
        local backpack = plr:FindFirstChild("Backpack")
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then pcall(function() tool:Destroy() end) end
            end
        end
        local char = plr.Character
        if char then
            for _, tool in pairs(char:GetChildren()) do
                if tool:IsA("Tool") then pcall(function() tool:Destroy() end) end
            end
        end
    end
end

--// EXPLODE (bikin player meledak)
local function ExplodePlayer(plr)
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local boom = Instance.new("Explosion")
    boom.Position = hrp.Position
    boom.BlastRadius = 15
    boom.BlastPressure = 500000
    boom.DestroyJointRadiusPercent = 1
    boom.Parent = workspace
end

local function ExplodeAll()
    for _, plr in pairs(GetPlayers()) do
        pcall(function() ExplodePlayer(plr) end)
    end
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

--// ============ SAFE ZONE ============
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

--// ============ AUTO ROCKET ============
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

--// ============ UTILITY ============

--// ANTI AFK
local function ToggleAntiAFK(state)
    AntiAFK = state
    if ConnAntiAFK then ConnAntiAFK:Disconnect() ConnAntiAFK = nil end
    if not state then return end
    ConnAntiAFK = LocalPlayer.Idled:Connect(function()
        pcall(function()
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):ClickButton2(Vector2.new())
        end)
    end)
end

--// AUTO REJOIN
local function AutoRejoin()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

--// SERVER HOP
local function ServerHop()
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local ok, result = pcall(function() return game:HttpGet(url) end)
    if ok and result then
        local data = HttpService:JSONDecode(result)
        if data and data.data then
            for _, server in pairs(data.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    return
                end
            end
        end
    end
end

--// COPY JOB ID
local function CopyJobID()
    if setclipboard then
        setclipboard(game.JobId)
    end
end

--// ESP PLAYER
local function ToggleESP(state)
    ESPEnabled = state
    for _, obj in pairs(ESPObjects) do
        pcall(function() obj:Destroy() end)
    end
    ESPObjects = {}
    if not state then return end
    
    local function CreateESP(plr)
        if plr == LocalPlayer then return end
        local function AddHighlight()
            local char = plr.Character
            if not char then return end
            local hl = Instance.new("Highlight")
            hl.Name = "SYSXHUB_ESP"
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.Adornee = char
            hl.Parent = char
            table.insert(ESPObjects, hl)
            
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "SYSXHUB_NAME"
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.AlwaysOnTop = true
            billboard.Adornee = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            billboard.Parent = char
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = plr.Name .. " [" .. math.floor((LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - (char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position or Vector3.zero)).Magnitude) or 0) .. "]"
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextStrokeTransparency = 0
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 14
            nameLabel.Parent = billboard
            table.insert(ESPObjects, billboard)
        end
        AddHighlight()
        plr.CharacterAdded:Connect(function()
            task.wait(0.5)
            if ESPEnabled then AddHighlight() end
        end)
    end
    
    for _, plr in pairs(Players:GetPlayers()) do
        CreateESP(plr)
    end
    Players.PlayerAdded:Connect(function(plr)
        if ESPEnabled then CreateESP(plr) end
    end)
end

--// FULLBRIGHT
local function ToggleFullbright(state)
    Fullbright = state
    if state then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 3
    else
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.Brightness = 1
    end
end

--// NO FOG
local function ToggleNoFog(state)
    NoFog = state
    if state then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
    else
        Lighting.FogEnd = 1000
        Lighting.FogStart = 0
    end
end

--// INFINITE JUMP
local function ToggleInfiniteJump(state)
    InfiniteJump = state
    if ConnJump then ConnJump:Disconnect() ConnJump = nil end
    if not state then return end
    ConnJump = UserInputService.JumpRequest:Connect(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
end

--// WALKSPEED
local function SetWalkSpeed(speed)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = speed end
    end
end

--// FLY (utility)
local FlyUtilityConn = nil
local FlyUtility = false
local function ToggleUtilityFly(state)
    FlyUtility = state
    if FlyUtilityConn then FlyUtilityConn:Disconnect() FlyUtilityConn = nil end
    if not state then return end
    local bodyGyro, bodyVel
    FlyUtilityConn = RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)
        if not bodyVel or not bodyVel.Parent then
            bodyVel = Instance.new("BodyVelocity", hrp)
            bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        end
        if not bodyGyro or not bodyGyro.Parent then
            bodyGyro = Instance.new("BodyGyro", hrp)
            bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            bodyGyro.P = 1e4
        end
        bodyGyro.CFrame = Camera.CFrame
        local move = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0, 1, 0) end
        bodyVel.Velocity = move * 80
    end)
end

--// TAB HIGHLIGHT
local ActiveTabBtn = nil
local function SetActiveTab(btn)
    if ActiveTabBtn then
        ActiveTabBtn.BackgroundColor3 = Color3.fromRGB(50, 25, 65)
        ActiveTabBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    end
    ActiveTabBtn = btn
    btn.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
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
        local cf = MakeButton("CONFUSE : OFF", 6)
        cf.MouseButton1Click:Connect(function() ToggleTrollConfuse(not TrollConfuse) cf.Text = "CONFUSE : " .. (TrollConfuse and "ON" or "OFF") end)
        local f = MakeButton("TELEPORT ALL TO SKY", 7)
        f.MouseButton1Click:Connect(TeleportAllToSky)
        local g = MakeButton("FREEZE ALL (5 detik)", 8)
        g.MouseButton1Click:Connect(FreezeAll)
        local h = MakeButton("RANDOM SIZE ALL", 9)
        h.MouseButton1Click:Connect(RandomSizeAll)
        local i = MakeButton("INVISIBLE ALL", 10)
        i.MouseButton1Click:Connect(InvisibleAll)
        local j = MakeButton("SPEED CHAOS", 11)
        j.MouseButton1Click:Connect(SpeedChaosAll)
        local k = MakeButton("GRAVITY CHAOS", 12)
        k.MouseButton1Click:Connect(GravityChaosAll)
        local l = MakeButton("ROCKET PLAYER (ALL)", 13)
        l.MouseButton1Click:Connect(function() for _, plr in pairs(GetPlayers()) do pcall(function() RocketPlayer(plr) end) end end)
        local m = MakeButton("SLAP PLAYER (ALL)", 14)
        m.MouseButton1Click:Connect(function() for _, plr in pairs(GetPlayers()) do pcall(function() SlapPlayer(plr) end) end end)
        local n = MakeButton("FORCE SIT ALL", 15)
        n.MouseButton1Click:Connect(ForceSitAll)
        local o = MakeButton("UNDRESS ALL", 16)
        o.MouseButton1Click:Connect(UndressAll)
        local p = MakeButton("STRIP TOOLS ALL", 17)
        p.MouseButton1Click:Connect(StripToolsAll)
        local q = MakeButton("EXPLODE ALL", 18)
        q.MouseButton1Click:Connect(ExplodeAll)

    elseif tab == "SAFE" then
        local a = MakeButton("AUTO SAFE ZONE : OFF", 1)
        a.MouseButton1Click:Connect(function() ToggleSafeZone(not SafeZone) a.Text = "AUTO SAFE ZONE : " .. (SafeZone and "ON" or "OFF") end)

    elseif tab == "ROCKET" then
        local a = MakeButton("AUTO ROCKET : OFF", 1)
        a.MouseButton1Click:Connect(function() ToggleAutoRocket(not AutoRocketMode) a.Text = "AUTO ROCKET : " .. (AutoRocketMode and "ON" or "OFF") end)

    elseif tab == "UTILITY" then
        local a = MakeButton("ANTI AFK : OFF", 1)
        a.MouseButton1Click:Connect(function() ToggleAntiAFK(not AntiAFK) a.Text = "ANTI AFK : " .. (AntiAFK and "ON" or "OFF") end)
        local b = MakeButton("ESP PLAYER : OFF", 2)
        b.MouseButton1Click:Connect(function() ToggleESP(not ESPEnabled) b.Text = "ESP PLAYER : " .. (ESPEnabled and "ON" or "OFF") end)
        local c = MakeButton("FULLBRIGHT : OFF", 3)
        c.MouseButton1Click:Connect(function() ToggleFullbright(not Fullbright) c.Text = "FULLBRIGHT : " .. (Fullbright and "ON" or "OFF") end)
        local d = MakeButton("NO FOG : OFF", 4)
        d.MouseButton1Click:Connect(function() ToggleNoFog(not NoFog) d.Text = "NO FOG : " .. (NoFog and "ON" or "OFF") end)
        local e = MakeButton("INFINITE JUMP : OFF", 5)
        e.MouseButton1Click:Connect(function() ToggleInfiniteJump(not InfiniteJump) e.Text = "INFINITE JUMP : " .. (InfiniteJump and "ON" or "OFF") end)
        local f = MakeButton("FLY UTILITY : OFF", 6)
        f.MouseButton1Click:Connect(function() ToggleUtilityFly(not FlyUtility) f.Text = "FLY UTILITY : " .. (FlyUtility and "ON" or "OFF") end)
        local g = MakeButton("WALKSPEED 100", 7)
        g.MouseButton1Click:Connect(function() SetWalkSpeed(100) end)
        local h = MakeButton("WALKSPEED 200", 8)
        h.MouseButton1Click:Connect(function() SetWalkSpeed(200) end)
        local i = MakeButton("AUTO REJOIN", 9)
        i.MouseButton1Click:Connect(AutoRejoin)
        local j = MakeButton("SERVER HOP", 10)
        j.MouseButton1Click:Connect(ServerHop)
        local k = MakeButton("COPY JOB ID", 11)
        k.MouseButton1Click:Connect(CopyJobID)
    end
end

TabTroll.MouseButton1Click:Connect(function() ShowTab("TROLL") SetActiveTab(TabTroll) end)
TabSafe.MouseButton1Click:Connect(function() ShowTab("SAFE") SetActiveTab(TabSafe) end)
TabRocket.MouseButton1Click:Connect(function() ShowTab("ROCKET") SetActiveTab(TabRocket) end)
TabUtility.MouseButton1Click:Connect(function() ShowTab("UTILITY") SetActiveTab(TabUtility) end)

ShowTab("TROLL")
SetActiveTab(TabTroll)
