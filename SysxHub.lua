-- SysxHub v2.0 | Executor Version | Dark Purple Premium | Discord: https://discord.gg/E5kQJW3hn
local Players = game:GetService("Players")
local RunSvc = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Tw = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local VU = game:GetService("VirtualUser")
local Plr = Players.LocalPlayer
local Cam = workspace.CurrentCamera

local Br = {Name="SysxHub",Discord="https://discord.gg/E5kQJW3hn",Asset="rbxassetid://104799849587740",Ver="2.0"}

local T = {
	Bg=Color3.fromRGB(16,8,24),Bg2=Color3.fromRGB(24,13,35),BgG=Color3.fromRGB(38,18,58),
	Pn=Color3.fromRGB(31,17,45),Pn2=Color3.fromRGB(42,23,60),
	Pr=Color3.fromRGB(118,52,180),PrD=Color3.fromRGB(72,28,112),
	PrL=Color3.fromRGB(160,85,225),Pink=Color3.fromRGB(210,90,200),
	Tx=Color3.fromRGB(245,240,250),Tx2=Color3.fromRGB(180,165,195),
	St=Color3.fromRGB(85,48,110),Ok=Color3.fromRGB(100,210,140),
	Wn=Color3.fromRGB(230,190,80),Er=Color3.fromRGB(220,80,100)
}
local CFG = {W=680,H=500,SW=160,TH=54,CR=12,SO={0.75,0.85,1.0,1.10,1.25}}
local S = {Tool="Melee",Sea=1,Boss=nil,Mat=nil,SeaMob=nil,Plr=nil,Chip=nil,SQ=nil,SQI=nil,Tg={},ChestRange=300,FarmRange=500}

local U = {}
function U.mk(c,p,par) local o=Instance.new(c) for k,v in pairs(p or {}) do pcall(function() o[k]=v end) end if par then o.Parent=par end return o end
function U.cr(o,r) return U.mk("UICorner",{CornerRadius=UDim.new(0,r or CFG.CR)},o) end
function U.st(o,c,t) return U.mk("UIStroke",{Color=c or T.St,Thickness=t or 1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},o) end
function U.pd(o,p) local x=U.mk("UIPadding",{},o) local u=UDim.new(0,p or 8) x.PaddingTop,x.PaddingBottom,x.PaddingLeft,x.PaddingRight=u,u,u,u return x end
function U.gd(o,a,b,r) return U.mk("UIGradient",{Color=ColorSequence.new(a,b),Rotation=r or 90},o) end
function U.tn(o,t,k) local w=Tw:Create(o,t,k) w:Play() return w end

local function getComm()
	local r = RS:FindFirstChild("Remotes")
	if r then return r:FindFirstChild("CommF_") or r:FindFirstChild("CommE_") end
	return nil
end
local function invoke(...)
	local c = getComm()
	if c then
		local ok, res = pcall(function() return c:InvokeServer(...) end)
		if ok then return res end
	end
	return nil
end

local D = {}
D.Tools = {"Melee","Sword","Gun","Blox Fruit"}
D.Chips = {"Flame Chip","Ice Chip","Quake Chip","Light Chip","Dark Chip","Magma Chip","Rumble Chip","Human Chip","Bird Chip"}
D.Codes = {"SUB2GAMERROBOT_EXP1","EASTEREXP","KittGaming","Sub2CaptainMaui","Sub2OfficialNoobie","Sub2Fer999","Enyu_is_Pro","JCWK","StarcodeHEO","MagicBUS","TheGreatAce","Sub2NoobMaster123","Sub2Daigrock","Axiore","StrawHatMaine","TantaiGaming","Bluxxy","KITT_RESET","Sub2UncleKizaru","SUB2GAMERROBOT_RESET1","BIGNEWS","fudd10_V2","fudd10","CHANDLER"}
D.Bosses = {"Gorilla King","Bobby","The Saw","Yeti","Vice Admiral","Saber Expert","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Don Swan","Darkbeard","Order","Cursed Captain","Awakened Ice Admiral","Stone","Hydra Leader","Kilo Admiral","Captain Elephant","Beautiful Pirate","Longma","Cursed Skeleton","Island Empress","Cake Queen"}
D.Mat = {
	["Bones"]={"Skeleton","Jungle",1,"Common",5},["Ectoplasm"]={"Ghost","Graveyard",2,"Uncommon",200},
	["Gunpowder"]={"Pirate","Pirate Village",1,"Common",10},["Scrap Metal"]={"Dock Worker","Port Town",3,"Common",700},
	["Leather"]={"Bandit","Starter Island",1,"Common",1},["Magma Ore"]={"Magma Beast","Magma Village",1,"Rare",90},
	["Fish Tail"]={"Sea Serpent","Underwater City",1,"Uncommon",110},["Mystic Droplet"]={"Fountain Spirit","Fountain City",1,"Rare",130},
	["Vampire Fang"]={"Haunted Knight","Haunted Castle",3,"Epic",1200},["Radioactive Material"]={"Mutant Beast","Green Zone",2,"Epic",175},
	["Shark Tooth"]={"Shark","Underwater City",1,"Uncommon",110},["Conjured Cocoa"]={"Candy Monster","Sea of Treats",3,"Rare",1400},
	["Demonic Wisp"]={"Dark Knight","Dark Arena",2,"Epic",250},["Dragon Scale"]={"Hydra Head","Hydra Island",3,"Legendary",800},
	["Electric Wing"]={"Sky Warrior","Skylands",1,"Rare",40},["Mutant Tooth"]={"Mutant Beast","Forgotten Island",2,"Legendary",500}
}
D.SeaMobs = {
	{n="Sea Beast",s=1},{n="Pirate Ship",s=1},{n="Piranha",s=1},{n="Shark",s=1},{n="FishCrew Member",s=1},
	{n="Cursed Ship",s=2},{n="Big Sea Beast",s=2},{n="Ghost Pirate Ship",s=2},{n="Sea Monster",s=2},
	{n="Terror Shark",s=3},{n="Sea Emperor",s=3},{n="Leviathan",s=3},{n="Kraken",s=3}
}
D.SQ = {
	{i="Starter Island",n="The Finale"},{i="Jungle",n="Perbaiki Zipline"},{i="Jungle",n="Kalahkan Monyet Pencuri"},
	{i="Jungle",n="Jatuhkan Pisang"},{i="Pirate Village",n="Bebaskan Kincir Angin"},{i="Pirate Village",n="Usir 3 Tavern Pirates"},
	{i="Pirate Village",n="Masak Stew"},{i="Desert",n="Selamatkan Hasan"},{i="Desert",n="Bersihkan 8 Rune/Pilar"},
	{i="Desert",n="Kumpulkan 10 Cactus Petals"},{i="Frozen Village",n="Bebaskan Ability Teacher"},{i="Frozen Village",n="Buat Snowman"},
	{i="Frozen Village",n="Hancurkan 3 Bongkahan Es Hijau"},{i="Marine Fortress",n="Pasang Bendera"},{i="Marine Fortress",n="Pertahankan Benteng"},
	{i="Marine Fortress",n="Hancurkan Bangunan"},{i="Lower Skylands",n="Cari Lightning Bolt"},{i="Lower Skylands",n="Usir Penyusup"},
	{i="Lower Skylands",n="Pukul Secret Cloud"},{i="Prison",n="Bantu 3 Tahanan Kabur"},{i="Prison",n="Ambil Kunci & Pink Coat"},
	{i="Prison",n="Atur Tuas"},{i="Colosseum",n="Selesaikan 3 Wave"},{i="Colosseum",n="Aktifkan 4 Patung"},
	{i="Colosseum",n="Hancurkan 18 Target 90s"},{i="Magma Village",n="Hadapi Gelombang Magma"},{i="Magma Village",n="Hancurkan Magma Drill"},
	{i="Magma Village",n="Hancurkan 5 Mini Lava Geyser"},{i="Underwater City",n="Naiki Bubble"},{i="Underwater City",n="Atur Crystal"},
	{i="Underwater City",n="Cari Black Pearl"},{i="Upper Skylands",n="Ambil Relic"},{i="Upper Skylands",n="Serang Awan Petir"},
	{i="Upper Skylands",n="Bunyikan Bell 6 Kali"},{i="Fountain City",n="Perbaiki Pipa Fountain"},{i="Fountain City",n="Kalahkan Megalo Brute"},
	{i="Fountain City",n="Perbaiki Kabel Junkyard"}
}

local Nf = {}
local nH
function Nf.Init(par)
	nH = U.mk("Frame",{Name="NH",BackgroundTransparency=1,Size=UDim2.new(0,300,1,-60),Position=UDim2.new(1,-312,0,44)},par)
	U.mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Top},nH)
end
local function nCol(k) if k=="SUCCESS" then return T.Ok end if k=="WARNING" then return T.Wn end if k=="ERROR" then return T.Er end return T.PrL end
function Nf.Push(k,ti,msg,d)
	if not nH then return end
	d = d or 3
	local c = U.mk("Frame",{BackgroundColor3=T.Pn,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),BackgroundTransparency=1},nH)
	U.cr(c,8); U.st(c,nCol(k))
	U.mk("Frame",{BackgroundColor3=nCol(k),BorderSizePixel=0,Size=UDim2.new(0,4,1,-8),Position=UDim2.new(0,4,0,4)},c)
	U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text=ti,TextColor3=T.Tx,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,-20,0,16),Position=UDim2.new(0,14,0,6)},c)
	U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Text=msg,TextColor3=T.Tx2,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Size=UDim2.new(1,-20,0,16),Position=UDim2.new(0,14,0,22)},c)
	U.tn(c,TweenInfo.new(0.28,Enum.EasingStyle.Quart),{Size=UDim2.new(1,0,0,46),BackgroundTransparency=0})
	task.delay(d,function()
		if not c.Parent then return end
		local w = U.tn(c,TweenInfo.new(0.22),{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1})
		w.Completed:Connect(function() c:Destroy() end)
	end)
end

local Gui = U.mk("ScreenGui",{Name="SysxHub",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=999},Plr:WaitForChild("PlayerGui"))
Nf.Init(Gui)

-- Open Button (pakai gambar default Roblox + bg solid biar pasti muncul)
local Ob = U.mk("ImageButton",{
	Name="OpenButton",
	BackgroundColor3=T.Pr,
	Size=UDim2.fromOffset(76,76),
	Position=UDim2.new(0,20,0.5,-38),
	AnchorPoint=Vector2.new(0,0),
	AutoButtonColor=false,
	Image="rbxassetid://104799849587740",
	ScaleType=Enum.ScaleType.Fit
}, Gui)
U.cr(Ob,38); U.st(Ob,T.PrL,2)

local M = U.mk("Frame",{Name="MW",BackgroundColor3=T.Bg,BorderSizePixel=0,Size=UDim2.fromOffset(CFG.W,CFG.H),Position=UDim2.new(0.5,-CFG.W/2,0.5,-CFG.H/2)},Gui)
U.cr(M,14); U.st(M,T.St); U.gd(M,T.Bg,T.BgG,120); M.ClipsDescendants=true
local Sc = U.mk("UIScale",{Scale=1},M)

local TB = U.mk("Frame",{Name="TB",BackgroundColor3=T.Bg2,BorderSizePixel=0,Size=UDim2.new(1,0,0,CFG.TH)},M)
U.cr(TB,14); U.st(TB,T.St); U.gd(TB,T.PrD,T.Bg2,0)

local Lg = U.mk("ImageLabel",{
	BackgroundColor3=T.Pr,
	Image="rbxassetid://104799849587740",
	Size=UDim2.fromOffset(60,60),
	Position=UDim2.new(0,6,0.5,-30),
	ScaleType=Enum.ScaleType.Fit
}, TB)
U.cr(Lg,30)
U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text=Br.Name,TextColor3=T.PrL,TextSize=20,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(0,200,1,0),Position=UDim2.new(0,72,0,0)},TB)

local function tBt(t,x,c)
	local b = U.mk("TextButton",{BackgroundColor3=c or T.Pn2,BorderSizePixel=0,Text=t,TextColor3=T.Tx,Font=Enum.Font.GothamBold,TextSize=14,AutoButtonColor=false,Size=UDim2.fromOffset(32,30),Position=UDim2.new(1,x,0.5,-15)},TB)
	U.cr(b,6)
	b.MouseEnter:Connect(function() U.tn(b,TweenInfo.new(0.15),{BackgroundColor3=T.Pr}) end)
	b.MouseLeave:Connect(function() U.tn(b,TweenInfo.new(0.15),{BackgroundColor3=c or T.Pn2}) end)
	return b
end
local ScaleBtn = tBt("◱",-108)
local MinBtn = tBt("—",-72)
local ClsBtn = tBt("✕",-36,T.Er)

local Sb = U.mk("Frame",{BackgroundColor3=T.Bg2,BorderSizePixel=0,Size=UDim2.new(0,CFG.SW,1,-CFG.TH),Position=UDim2.new(0,0,0,CFG.TH)},M)
U.st(Sb,T.St)
local SLH = U.mk("Frame",{BackgroundColor3=T.Bg,BorderSizePixel=0,Size=UDim2.new(1,-12,0,112),Position=UDim2.new(0,6,0,6)},Sb)
U.cr(SLH,10)
local SLg = U.mk("ImageLabel",{Image="rbxassetid://104799849587740",BackgroundColor3=T.Pr,Size=UDim2.fromOffset(100,100),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),ScaleType=Enum.ScaleType.Fit},SLH)
U.cr(SLg,50)

local SSb = U.mk("ScrollingFrame",{BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,-124),Position=UDim2.new(0,0,0,124),CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ScrollBarImageColor3=T.Pr},Sb)
U.mk("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},SSb)
U.pd(SSb,6)

local Ct = U.mk("Frame",{BackgroundColor3=T.Bg,BorderSizePixel=0,Size=UDim2.new(1,-CFG.SW,1,-CFG.TH),Position=UDim2.new(0,CFG.SW,0,CFG.TH)},M)
local SR = U.mk("TextBox",{BackgroundColor3=T.Bg2,BorderSizePixel=0,ClearTextOnFocus=false,PlaceholderText="Search Feature...",PlaceholderColor3=T.Tx2,TextColor3=T.Tx,Font=Enum.Font.Gotham,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Text="",Size=UDim2.new(1,-24,0,34),Position=UDim2.new(0,12,0,10)},Ct)
U.cr(SR,6); U.st(SR); U.pd(SR,8)
local CS = U.mk("ScrollingFrame",{BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,-16,1,-60),Position=UDim2.new(0,8,0,54),CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=4,ScrollBarImageColor3=T.Pr},Ct)
U.mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},CS)
U.pd(CS,8)

local CM = {l={}}
function CM:add(c) table.insert(self.l,c) end
function CM:clr() for _,c in ipairs(self.l) do pcall(function() c:Disconnect() end) end self.l={} end
local cT = nil
local function clrC() CM:clr() for _,c in ipairs(CS:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end end

local function secL(t,o)
	local l = U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text="▸ "..t,TextColor3=T.PrL,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,-8,0,22)},CS)
	l.LayoutOrder = o or 0
	return l
end

local function mkTg(t,k,d,cb,o)
	local r = U.mk("Frame",{BackgroundColor3=T.Pn,BorderSizePixel=0,Size=UDim2.new(1,-8,0,38)},CS)
	r.LayoutOrder = o or 0
	U.cr(r,10); U.st(r)
	U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamMedium,Text=t,TextColor3=T.Tx,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,-80,1,0),Position=UDim2.new(0,12,0,0)},r)
	local st = S.Tg[k]
	if st == nil then st = d or false end
	S.Tg[k] = st
	local tr = U.mk("Frame",{BackgroundColor3=st and T.PrL or T.Pn2,BorderSizePixel=0,Size=UDim2.fromOffset(46,22),Position=UDim2.new(1,-58,0.5,-11)},r)
	U.cr(tr,11); U.st(tr)
	local kn = U.mk("Frame",{BackgroundColor3=T.Tx,BorderSizePixel=0,Size=UDim2.fromOffset(18,18),Position=st and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)},tr)
	U.cr(kn,9)
	local bt = U.mk("TextButton",{BackgroundTransparency=1,Text="",Size=UDim2.new(1,0,1,0)},r)
	CM:add(bt.MouseButton1Click:Connect(function()
		st = not st
		S.Tg[k] = st
		local ti = TweenInfo.new(0.18,Enum.EasingStyle.Quart)
		U.tn(tr,ti,{BackgroundColor3=st and T.PrL or T.Pn2})
		U.tn(kn,ti,{Position=st and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)})
		if cb then cb(st) end
	end))
	return r
end

local function mkBt(t,cb,o)
	local b = U.mk("TextButton",{BackgroundColor3=T.Pn,BorderSizePixel=0,Text=t,TextColor3=T.Tx,Font=Enum.Font.GothamMedium,TextSize=13,AutoButtonColor=false,Size=UDim2.new(1,-8,0,36)},CS)
	b.LayoutOrder = o or 0
	U.cr(b,8); U.st(b)
	CM:add(b.MouseEnter:Connect(function() U.tn(b,TweenInfo.new(0.15),{BackgroundColor3=T.Pn2}) end))
	CM:add(b.MouseLeave:Connect(function() U.tn(b,TweenInfo.new(0.15),{BackgroundColor3=T.Pn}) end))
	CM:add(b.MouseButton1Click:Connect(function() if cb then cb() end end))
	return b
end

local function mkSl(t,mn,mx,d,cb,o)
	local r = U.mk("Frame",{BackgroundColor3=T.Pn,BorderSizePixel=0,Size=UDim2.new(1,-8,0,50)},CS)
	r.LayoutOrder = o or 0
	U.cr(r,8); U.st(r)
	U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamMedium,Text=t,TextColor3=T.Tx,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,-80,0,18),Position=UDim2.new(0,12,0,4)},r)
	local vl = U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text=string.format("%.0f",d),TextColor3=T.PrL,TextSize=13,TextXAlignment=Enum.TextXAlignment.Right,Size=UDim2.new(0,66,0,18),Position=UDim2.new(1,-78,0,4)},r)
	local br = U.mk("Frame",{BackgroundColor3=T.Bg2,BorderSizePixel=0,Size=UDim2.new(1,-24,0,8),Position=UDim2.new(0,12,0,32)},r)
	U.cr(br,4); U.st(br)
	local fl = U.mk("Frame",{BackgroundColor3=T.PrL,BorderSizePixel=0,Size=UDim2.new((d-mn)/(mx-mn),0,1,0)},br)
	U.cr(fl,4); U.gd(fl,T.PrL,T.Pink,0)
	local kn = U.mk("Frame",{BackgroundColor3=T.Tx,BorderSizePixel=0,Size=UDim2.fromOffset(14,14),Position=UDim2.new((d-mn)/(mx-mn),-7,0.5,-7)},br)
	U.cr(kn,7)
	local dg = false
	local function sX(x)
		local rr = math.clamp((x-br.AbsolutePosition.X)/br.AbsoluteSize.X,0,1)
		local v = mn+(mx-mn)*rr
		fl.Size = UDim2.new(rr,0,1,0)
		kn.Position = UDim2.new(rr,-7,0.5,-7)
		vl.Text = string.format("%.0f",v)
		if cb then cb(v) end
	end
	CM:add(br.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=true sX(i.Position.X) end end))
	CM:add(UIS.InputChanged:Connect(function(i) if dg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then sX(i.Position.X) end end))
	CM:add(UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=false end end))
	return r
end

local function mkDd(lb,opt,cb,o,sk)
	local h = U.mk("Frame",{BackgroundColor3=T.Pn,BorderSizePixel=0,Size=UDim2.new(1,-8,0,38)},CS)
	h.LayoutOrder = o or 0
	U.cr(h,8); U.st(h); h.ClipsDescendants = true
	local it = (sk and S[sk]) or opt[1] or "-"
	local hd = U.mk("TextButton",{BackgroundColor3=T.Pn,BorderSizePixel=0,Text="  "..lb..": "..tostring(it),TextColor3=T.Tx,Font=Enum.Font.GothamMedium,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,Size=UDim2.new(1,0,0,38)},h)
	local lh = U.mk("Frame",{BackgroundColor3=T.Bg2,BorderSizePixel=0,Size=UDim2.new(1,-16,0,0),Position=UDim2.new(0,8,0,40)},h)
	U.cr(lh,6); lh.ClipsDescendants = true
	U.mk("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder},lh)
	local op = false
	for i,v in ipairs(opt) do
		local ib = U.mk("TextButton",{BackgroundColor3=T.Pn,BorderSizePixel=0,Text="  "..v,TextColor3=T.Tx,Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,Size=UDim2.new(1,-8,0,28),LayoutOrder=i},lh)
		U.cr(ib,4)
		CM:add(ib.MouseEnter:Connect(function() U.tn(ib,TweenInfo.new(0.12),{BackgroundColor3=T.Pn2}) end))
		CM:add(ib.MouseLeave:Connect(function() U.tn(ib,TweenInfo.new(0.12),{BackgroundColor3=T.Pn}) end))
		CM:add(ib.MouseButton1Click:Connect(function()
			hd.Text = "  "..lb..": "..v
			if sk then S[sk] = v end
			op = false
			U.tn(h,TweenInfo.new(0.2),{Size=UDim2.new(1,-8,0,38)})
			U.tn(lh,TweenInfo.new(0.2),{Size=UDim2.new(1,-16,0,0)})
			if cb then cb(v) end
		end))
	end
	CM:add(hd.MouseButton1Click:Connect(function()
		op = not op
		local hh = math.min(#opt*30+8,180)
		U.tn(h,TweenInfo.new(0.2),{Size=UDim2.new(1,-8,0,op and 38+hh+8 or 38)})
		U.tn(lh,TweenInfo.new(0.2),{Size=UDim2.new(1,-16,0,op and hh or 0)})
	end))
	return h
end

local function getChar()
	local c = Plr.Character
	if c and c:FindFirstChild("HumanoidRootPart") and c:FindFirstChildOfClass("Humanoid") and c:FindFirstChildOfClass("Humanoid").Health > 0 then
		return c
	end
	return nil
end
local function activateTool()
	local c = getChar()
	if not c then return end
	local tool = c:FindFirstChildOfClass("Tool")
	if tool then pcall(function() tool:Activate() end) end
end
local function isValidMob(m)
	if not m:IsA("Model") then return false end
	local hum = m:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return false end
	if Players:GetPlayerFromCharacter(m) then return false end
	if m.Name:lower():find("npc") or m.Name:lower():find("quest") then return false end
	return true
end
local function getNearestMob(range)
	local c = getChar()
	if not c then return nil, math.huge end
	local pos = c.HumanoidRootPart.Position
	local best, dist = nil, range or S.FarmRange
	for _, m in ipairs(workspace:GetDescendants()) do
		if isValidMob(m) then
			local hrp = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
			if hrp then
				local d = (hrp.Position - pos).Magnitude
				if d < dist then best, dist = m, d end
			end
		end
	end
	return best, dist
end
local function getNearestChest(range)
	local c = getChar()
	if not c then return nil, math.huge end
	local pos = c.HumanoidRootPart.Position
	local best, dist = nil, range or S.ChestRange
	for _, o in ipairs(workspace:GetDescendants()) do
		if o:IsA("Model") and o.Name:lower():find("chest") then
			local pp = o:FindFirstChild("HumanoidRootPart") or o.PrimaryPart
			if pp then
				local d = (pp.Position - pos).Magnitude
				if d < dist then best, dist = o, d end
			end
		end
	end
	return best, dist
end
local function interactPrompt(obj)
	if not obj then return false end
	for _, d in ipairs(obj:GetDescendants()) do
		if d:IsA("ProximityPrompt") then
			pcall(function()
				d:InputHoldBegin()
				task.wait(d.HoldDuration or 0.2)
				d:InputHoldEnd()
			end)
			return true
		end
	end
	return false
end

task.spawn(function()
	while true do
		if S.Tg["F_L"] or S.Tg["F_N"] or S.Tg["F_Fa"] or S.Tg["F_E"] or S.Tg["AKB"] or S.Tg["AFM"] or S.Tg["AFS"] then
			local c = getChar()
			if c then
				local mob, dist = getNearestMob(S.FarmRange)
				if mob and dist < S.FarmRange then
					local hrp = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
					if hrp then
						c:PivotTo(hrp.CFrame * CFrame.new(0, 0, 4))
						if S.Tg["CA"] or S.Tg["AAT"] then activateTool() end
					end
				end
			end
		end
		task.wait(0.25)
	end
end)

task.spawn(function()
	while true do
		if S.Tg["AC"] then
			local c = getChar()
			if c then
				local chest, dist = getNearestChest(S.ChestRange)
				if chest then
					local pp = chest:FindFirstChild("HumanoidRootPart") or chest.PrimaryPart
					if pp then
						c:PivotTo(pp.CFrame + Vector3.new(0,3,0))
						task.wait(0.3)
						if interactPrompt(chest) then
							Nf.Push("SUCCESS","Chest","Opened: "..chest.Name,1.5)
						end
					end
				end
			end
		end
		task.wait(0.4)
	end
end)

task.spawn(function()
	while true do
		if S.Tg["CA"] or S.Tg["AAT"] or S.Tg["AAM"] then
			activateTool()
		end
		task.wait(0.35)
	end
end)

RunSvc.RenderStepped:Connect(function(dt)
	if not S.Tg["Aim"] then return end
	if not S.Plr or S.Plr == "None" then return end
	local t = Players:FindFirstChild(S.Plr)
	if not t or not t.Character then return end
	local hrp = t.Character:FindFirstChild("HumanoidRootPart")
	local head = t.Character:FindFirstChild("Head")
	local c = getChar()
	local myHead = c and c:FindFirstChild("Head")
	if not hrp or not myHead then return end
	local dist = (hrp.Position - myHead.Position).Magnitude
	if dist > 1000 then return end
	local aimPos = head and head.Position or hrp.Position
	local want = CFrame.lookAt(Cam.CFrame.Position, aimPos)
	local alpha = 1 - math.exp(-12 * dt)
	Cam.CFrame = Cam.CFrame:Lerp(want, alpha)
	if S.Tg["AAT"] then activateTool() end
end)

UIS.JumpRequest:Connect(function()
	if not S.Tg["IJ"] then return end
	local c = getChar()
	if c then
		local hum = c:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

task.spawn(function()
	while true do
		if S.Tg["AAF"] then
			VU:CaptureController()
			VU:ClickButton2(Vector2.new())
		end
		task.wait(60)
	end
end)

task.spawn(function()
	while true do
		if S.Tg["NC"] then
			local c = getChar()
			if c then
				for _, p in ipairs(c:GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide = false end
				end
			end
		end
		task.wait(0.2)
	end
end)

local function getFruitsInChar()
	local out = {}
	local char = Plr.Character
	if char then
		for _, t in ipairs(char:GetChildren()) do
			if t:IsA("Tool") and string.find(string.lower(t.Name), "fruit") then table.insert(out, t) end
		end
	end
	local bp = Plr:FindFirstChild("Backpack")
	if bp then
		for _, t in ipairs(bp:GetChildren()) do
			if t:IsA("Tool") and string.find(string.lower(t.Name), "fruit") then table.insert(out, t) end
		end
	end
	return out
end

local function randomFruit()
	local r1 = invoke("Cousin", "Buy")
	local r2 = invoke("Cousin", "Buy", "Random")
	if r1 or r2 then
		Nf.Push("SUCCESS","Random Fruit","Berhasil beli",2)
	else
		Nf.Push("WARNING","Random Fruit","Dekat Fruit Dealer dulu",2)
	end
end

local function storeFruit(tool)
	if not tool or not tool.Parent then return end
	local name = tool.Name
	local ok = invoke("StoreFruit", name)
	if ok then
		Nf.Push("SUCCESS","Stored",name,1.5)
	else
		Nf.Push("WARNING","Store",name.." gagal",1.5)
	end
end

local function findSpawnedFruit()
	local best, dist = nil, math.huge
	local c = getChar()
	if not c then return nil end
	local pos = c.HumanoidRootPart.Position
	for _, o in ipairs(workspace:GetChildren()) do
		if o:IsA("Tool") and string.find(string.lower(o.Name), "fruit") then
			local handle = o:FindFirstChild("Handle")
			if handle then
				local d = (handle.Position - pos).Magnitude
				if d < dist then best, dist = o, d end
			end
		end
	end
	return best
end

local function tweenFruitToSpawn(tool)
	local c = getChar()
	if not c or not tool then return end
	local hrp = c:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local handle = tool:FindFirstChild("Handle")
	if not handle then return end
	local targetFruit = findSpawnedFruit()
	local targetPos = targetFruit and targetFruit:FindFirstChild("Handle") and targetFruit.Handle.Position or (hrp.Position + Vector3.new(0, 20, 0))
	local clone = handle:Clone()
	clone.Parent = workspace
	clone.CanCollide = false
	clone.Anchored = true
	clone.CFrame = hrp.CFrame * CFrame.new(0, -2, -2)
	local tw = Tw:Create(clone, TweenInfo.new(1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {CFrame = CFrame.new(targetPos)})
	tw:Play()
	tw.Completed:Wait()
	local fade = Tw:Create(clone, TweenInfo.new(0.3), {Transparency = 1})
	fade:Play()
	fade.Completed:Wait()
	clone:Destroy()
	storeFruit(tool)
end

task.spawn(function()
	while true do
		if S.Tg["ASF"] then
			for _, t in ipairs(getFruitsInChar()) do
				storeFruit(t)
				task.wait(0.3)
			end
		end
		if S.Tg["TweenF"] then
			for _, t in ipairs(getFruitsInChar()) do
				tweenFruitToSpawn(t)
				task.wait(1.5)
			end
		end
		task.wait(3)
	end
end)

local function startQuest(questName, level)
	if not questName then return end
	invoke("StartQuest", questName, level or 1)
	Nf.Push("SUCCESS","Quest","Start: "..questName,2)
end

local TBU = {}

TBU["Discord"] = function()
	secL("Community",1)
	mkBt("Join Discord — "..Br.Discord,function()
		if setclipboard then pcall(setclipboard,Br.Discord) end
		Nf.Push("SUCCESS","Discord",Br.Discord,3)
	end,2)
	secL("Info",3)
	mkBt("Version: "..Br.Ver,function() end,4)
end

TBU["Farm"] = function()
	secL("Farm Config",1)
	mkDd("Select Tool",D.Tools,function(v) S.Tool=v end,2,"Tool")
	mkSl("UI Scale",0.5,1.5,1.0,function(v) Sc.Scale=v end,3)
	mkSl("Farm Range",100,1000,500,function(v) S.FarmRange=v end,4)
	secL("Auto Farm",10)
	mkTg("Auto Farm Level","F_L",false,function(on) Nf.Push(on and "SUCCESS" or "INFO","Farm Level",on and "ON" or "OFF",2) end,11)
	mkTg("Auto Farm Nearest","F_N",false,function(on) Nf.Push(on and "SUCCESS" or "INFO","Farm Nearest",on and "ON" or "OFF",2) end,12)
	mkTg("Auto Factory","F_Fa",false,function(on) Nf.Push(on and "SUCCESS" or "INFO","Factory",on and "ON" or "OFF",2) end,13)
	mkTg("Auto Farm Ectoplasm","F_E",false,function(on) Nf.Push(on and "SUCCESS" or "INFO","Ectoplasm",on and "ON" or "OFF",2) end,14)
	secL("Chest Farm",20)
	mkTg("Auto Chest","AC",false,function(on) Nf.Push(on and "SUCCESS" or "INFO","Chest",on and "ON" or "OFF",2) end,21)
	mkSl("Max Chest Range",50,500,300,function(v) S.ChestRange=v end,22)
	secL("Combat",40)
	mkTg("Auto Haki","CH",false,function(on) Nf.Push(on and "SUCCESS" or "INFO","Haki",on and "ON" or "OFF",2) end,41)
	mkTg("Auto Ken","CK",false,function(on) Nf.Push(on and "SUCCESS" or "INFO","Ken",on and "ON" or "OFF",2) end,42)
	mkTg("Auto Attack","CA",false,function(on) Nf.Push(on and "SUCCESS" or "INFO","Auto Attack",on and "ON" or "OFF",2) end,43)
end

TBU["Boss"] = function()
	secL("Boss",1)
	mkDd("Select Boss",D.Bosses,function(v) S.Boss=v Nf.Push("INFO","Boss",v,2) end,2,"Boss")
	secL("Boss Combat",10)
	mkTg("Auto Kill Selected Boss","AKB",false,function(on) Nf.Push(on and "SUCCESS" or "INFO","Boss Kill",on and "ON" or "OFF",2) end,11)
end

TBU["Material"] = function()
	secL("Material",1)
	local mn = {"Select Material..."}
	for n in pairs(D.Mat) do table.insert(mn,n) end
	table.sort(mn)
	mkDd("Select Material",mn,function(v)
		if v=="Select Material..." then return end
		S.Mat = v
		local i = D.Mat[v]
		if i then Nf.Push("SUCCESS","Material",v.." @ "..i[2],4) end
	end,2,"Mat")
	secL("Auto Farm",20)
	mkTg("Auto Farm Material","AFM",false,function(on) Nf.Push(on and "SUCCESS" or "INFO","Material",on and "ON" or "OFF",2) end,21)
end

TBU["Sea"] = function()
	secL("Sea Config",1)
	mkDd("Select Sea",{"Sea 1","Sea 2","Sea 3"},function(v)
		S.Sea = tonumber(v:match("%d+")) or 1
		oT("Sea")
	end,2,"Sea")
	local cs = S.Sea or 1
	local ml = {"Select Sea Mob..."}
	for _,m in ipairs(D.SeaMobs) do
		if m.s == cs then table.insert(ml, m.n) end
	end
	if #ml == 1 then ml = {"(No mob)"} end
	mkDd("Enemies [Select]",ml,function(v)
		if v=="Select Sea Mob..." or v=="(No mob)" then return end
		S.SeaMob = v
		Nf.Push("INFO","Sea Mob",v,3)
	end,3,"SeaMob")
	secL("Sea Farm",10)
	mkTg("Auto Farm Sea","AFS",false,function(on) Nf.Push(on and "SUCCESS" or "INFO","Sea Farm",on and "ON" or "OFF",2) end,11)
end

TBU["Quests / Items"] = function()
	secL("Secret Quest",1)
	local iS = {}
	for _,q in ipairs(D.SQ) do iS[q.i]=true end
	local iL = {"All Islands"}
	for n in pairs(iS) do table.insert(iL,n) end
	table.sort(iL)
	mkDd("Select Island",iL,function(v)
		S.SQI = (v=="All Islands") and nil or v
		oT("Quests / Items")
	end,2,"SQI")
	local sel = S.SQI or "All Islands"
	local ql = {"Select Quest..."}
	local qm = {}
	for _,q in ipairs(D.SQ) do
		if sel=="All Islands" or q.i==sel then
			local lb = q.n.." @"..q.i
			table.insert(ql,lb)
			qm[lb] = q
		end
	end
	if #ql==1 then ql={"(Kosong)"} end
	mkDd("Select Quest",ql,function(v)
		if v=="Select Quest..." or v=="(Kosong)" then return end
		local q = qm[v]
		if q then S.SQ = q.n S.SQI = q.i Nf.Push("INFO","Secret",q.n,4) end
	end,3,"SQ")
	mkBt("Start Selected Quest",function()
		if not S.SQ then Nf.Push("WARNING","Quest","Pilih dulu",2) return end
		startQuest(S.SQ, 1)
	end,4)
	secL("Boss Special",20)
	mkBt("Kill Cake Prince",function() startQuest("Cake Prince",1) end,21)
	mkBt("Auto Spawn & Kill Dough King",function() startQuest("Dough King",1) end,22)
	mkBt("Kill Soul Reaper",function() startQuest("Soul Reaper",1) end,23)
	mkBt("Auto Spawn & Kill rip_indra",function() startQuest("rip_indra",1) end,24)
end

TBU["Fruit / Raid"] = function()
	secL("Raid",1)
	mkDd("Select Chip",D.Chips,function(v) S.Chip=v end,2,"Chip")
	mkBt("Start Raid",function()
		invoke("Raid", "Start", S.Chip)
		Nf.Push("INFO","Raid","Start "..tostring(S.Chip),2)
	end,3)
	secL("Fruit Roll",10)
	mkBt("Random Fruit",function() randomFruit() end,11)
	secL("Fruit Store",20)
	mkTg("Auto Store Fruit","ASF",false,function(on) Nf.Push(on and "SUCCESS" or "INFO","Store",on and "ON" or "OFF",2) end,21)
	mkTg("Tween Fruit → Spawn","TweenF",false,function(on) Nf.Push(on and "SUCCESS" or "INFO","Tween Fruit",on and "ON" or "OFF",2) end,22)
end

TBU["Fishing"] = function()
	secL("Fishing",1)
	mkTg("Auto Fish","AF",false,function(on) Nf.Push(on and "SUCCESS" or "INFO","Fishing",on and "ON" or "OFF",2) end,2)
	mkTg("Auto Cast","ACa",false,function(on) Nf.Push(on and "SUCCESS" or "INFO","Cast",on and "ON" or "OFF",2) end,3)
end

TBU["Status"] = function()
	secL("Server Status",1)
	local tl = U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Text="Server Time: -",TextColor3=T.Tx,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,-8,0,20)},CS)
	tl.LayoutOrder = 4
	task.spawn(function()
		while Gui.Parent do
			tl.Text = "Server Time: "..os.date("%H:%M:%S")
			task.wait(1)
		end
	end)
end

TBU["PvP"] = function()
	secL("PvP",1)
	local pn = {"None"}
	for _,p in ipairs(Players:GetPlayers()) do
		if p ~= Plr then table.insert(pn,p.Name) end
	end
	mkDd("Select Player",pn,function(v) S.Plr = v end,2,"Plr")
	mkTg("Aimbot (Smooth Cam)","Aim",false,function(on)
		Nf.Push(on and "SUCCESS" or "INFO","Aimbot",on and (S.Plr or "None") or "OFF",2)
	end,3)
	mkTg("Auto Attack Target","AAT",false,function(on) Nf.Push(on and "SUCCESS" or "INFO","Auto Attack",on and "ON" or "OFF",2) end,4)
end

TBU["Stats"] = function()
	secL("Stat Allocation",1)
	mkTg("Start Add Stats","SAS",false,function(on) Nf.Push(on and "SUCCESS" or "INFO","Stats",on and "ON" or "OFF",2) end,2)
	mkSl("Melee",0,100,0,function(v) end,3)
	mkSl("Sword",0,100,0,function(v) end,4)
	mkSl("Gun",0,100,0,function(v) end,5)
	mkSl("Defense",0,100,0,function(v) end,6)
	mkSl("Blox Fruit %",0,100,0,function(v) end,7)
end

TBU["Misc"] = function()
	secL("Server",1)
	U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Text="Job ID: "..game.JobId,TextColor3=T.Tx,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Size=UDim2.new(1,-8,0,32)},CS).LayoutOrder = 2
	mkBt("Copy Job ID",function()
		if setclipboard then pcall(setclipboard,game.JobId) end
		Nf.Push("SUCCESS","Job ID","Copied",2)
	end,3)
	secL("Utility",10)
	mkBt("Redeem All Code",function()
		Nf.Push("INFO","Redeem","Kirim "..#D.Codes,3)
		for i,c in ipairs(D.Codes) do
			invoke("Redeem", c)
			Nf.Push("INFO","Redeem "..i.."/"..#D.Codes,c,1.5)
			task.wait(0.5)
		end
		Nf.Push("SUCCESS","Redeem","Selesai",4)
	end,11)
	mkTg("Anti AFK","AAF",false,function(on) Nf.Push(on and "SUCCESS" or "INFO","AntiAFK",on and "ON" or "OFF",2) end,12)
	mkTg("No Clip","NC",false,function(on) Nf.Push(on and "SUCCESS" or "INFO","NoClip",on and "ON" or "OFF",2) end,13)
	mkTg("Infinite Jump","IJ",false,function(on) Nf.Push(on and "SUCCESS" or "INFO","Inf Jump",on and "ON" or "OFF",2) end,14)
	mkTg("Auto Attack","AAM",false,function(on) Nf.Push(on and "SUCCESS" or "INFO","Auto Attack",on and "ON" or "OFF",2) end,15)
	local fp = U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Text="FPS: -",TextColor3=T.Tx,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,-8,0,20)},CS)
	fp.LayoutOrder = 16
	local fr,ls = 0,tick()
	CM:add(RunSvc.RenderStepped:Connect(function()
		fr = fr + 1
		if tick() - ls >= 1 then
			fp.Text = "FPS: "..fr
			fr = 0
			ls = tick()
		end
	end))
end

local TAB_FEAT = {
	Discord={"Join Discord","Version"},
	Farm={"Select Tool","UI Scale","Farm Range","Auto Farm Level","Auto Farm Nearest","Auto Factory","Auto Farm Ectoplasm","Auto Chest","Max Chest Range","Auto Haki","Auto Ken","Auto Attack"},
	Boss={"Select Boss","Auto Kill Selected Boss"},
	Material={"Select Material","Auto Farm Material"},
	Sea={"Select Sea","Enemies","Auto Farm Sea"},
	["Quests / Items"]={"Secret Quest","Select Island","Select Quest","Start Selected Quest","Kill Cake Prince","Dough King","Soul Reaper","rip_indra"},
	["Fruit / Raid"]={"Select Chip","Start Raid","Random Fruit","Auto Store Fruit","Tween Fruit"},
	Fishing={"Auto Fish","Auto Cast"},
	Status={"Server Time"},
	PvP={"Select Player","Aimbot","Auto Attack Target"},
	Stats={"Start Add Stats","Melee","Sword","Gun","Defense","Blox Fruit"},
	Misc={"Copy Job ID","Redeem All Code","Anti AFK","No Clip","Infinite Jump","Auto Attack","FPS"}
}

local oT
oT = function(n)
	cT = n
	clrC()
	if TBU[n] then pcall(TBU[n]) end
	for _, b in ipairs(SSb:GetChildren()) do
		if b:IsA("TextButton") then
			local a = (b.Name == "Tab_"..n)
			U.tn(b,TweenInfo.new(0.15),{BackgroundColor3 = a and T.Pr or T.Bg2,TextColor3 = a and T.Tx or T.Tx2})
		end
	end
end

for i,t in ipairs({"Discord","Farm","Boss","Material","Sea","Quests / Items","Fruit / Raid","Fishing","Status","PvP","Stats","Misc"}) do
	local b = U.mk("TextButton",{Name="Tab_"..t,BackgroundColor3=T.Bg2,BorderSizePixel=0,Text="  "..t,TextColor3=T.Tx2,Font=Enum.Font.GothamMedium,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,Size=UDim2.new(1,-4,0,34)},SSb)
	b.LayoutOrder = i
	U.cr(b,6)
	b.MouseEnter:Connect(function() if cT~=t then U.tn(b,TweenInfo.new(0.12),{BackgroundColor3=T.Pn}) end end)
	b.MouseLeave:Connect(function() if cT~=t then U.tn(b,TweenInfo.new(0.12),{BackgroundColor3=T.Bg2}) end end)
	b.MouseButton1Click:Connect(function() oT(t) end)
end

oT("Discord")

local sRes = nil
SR:GetPropertyChangedSignal("Text"):Connect(function()
	local q = string.lower(SR.Text)
	if q == "" then
		if sRes then sRes:Destroy() sRes = nil end
		if cT then oT(cT) end
		return
	end
	if sRes then sRes:Destroy() end
	sRes = U.mk("Frame",{BackgroundColor3=T.Bg2,BorderSizePixel=0,Size=UDim2.new(1,-16,1,-60),Position=UDim2.new(0,8,0,54),ZIndex=5},Ct)
	U.cr(sRes,8); U.st(sRes,T.Pr)
	U.mk("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},sRes)
	U.pd(sRes,8)
	local found = {}
	for tn,fs in pairs(TAB_FEAT) do
		for _,fn in ipairs(fs) do
			if string.find(string.lower(fn),q,1,true) or string.find(string.lower(tn),q,1,true) then
				table.insert(found,{tab=tn,f=fn})
			end
		end
	end
	if #found == 0 then
		U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text="Feature not found: \""..SR.Text.."\"",TextColor3=T.Er,TextSize=13,Size=UDim2.new(1,-8,0,30),LayoutOrder=1},sRes)
		return
	end
	for i,r in ipairs(found) do
		local btn = U.mk("TextButton",{BackgroundColor3=T.Pn,BorderSizePixel=0,Text="  ▸ ["..r.tab.."]  "..r.f,TextColor3=T.Tx,Font=Enum.Font.GothamMedium,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,Size=UDim2.new(1,-8,0,32),LayoutOrder=i},sRes)
		U.cr(btn,6); U.st(btn)
		btn.MouseButton1Click:Connect(function() SR.Text = "" oT(r.tab) end)
	end
end)

local isO = true
local function setW(op)
	isO = op
	U.tn(M,TweenInfo.new(0.28,Enum.EasingStyle.Quart),{Size=op and UDim2.fromOffset(CFG.W,CFG.H) or UDim2.fromOffset(0,0)})
end
Ob.MouseButton1Click:Connect(function() if isO then setW(false) else setW(true) end end)
ClsBtn.MouseButton1Click:Connect(function() setW(false) end)
MinBtn.MouseButton1Click:Connect(function() setW(false) end)

local si = 3
ScaleBtn.MouseButton1Click:Connect(function()
	si = si % #CFG.SO + 1
	Sc.Scale = CFG.SO[si]
	Nf.Push("INFO","UI Scale",tostring(math.floor(CFG.SO[si]*100)).."%",1.5)
end)

do
	local d, sP, st
	TB.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			d = true; sP = i.Position; st = M.Position
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if not d then return end
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
			local dl = i.Position - sP
			M.Position = UDim2.new(st.X.Scale, st.X.Offset + dl.X, st.Y.Scale, st.Y.Offset + dl.Y)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = false end
	end)
end

do
	local d, sP, st
	Ob.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			d = true; sP = i.Position; st = Ob.Position
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if not d then return end
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
			local dl = i.Position - sP
			Ob.Position = UDim2.new(st.X.Scale, st.X.Offset + dl.X, st.Y.Scale, st.Y.Offset + dl.Y)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = false end
	end)
end

if UIS.TouchEnabled then
	SSb.ScrollingDirection = Enum.ScrollingDirection.Y
	CS.ScrollingDirection = Enum.ScrollingDirection.Y
end

Plr.CharacterRemoving:Connect(function()
	S.Tg["CA"] = false
	S.Tg["AC"] = false
	S.Tg["F_L"] = false
	S.Tg["F_N"] = false
	S.Tg["Aim"] = false
end)

Nf.Push("SUCCESS","SysxHub","Loaded v"..Br.Ver,3)
