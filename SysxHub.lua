-- SysxHub v1.8.0 | Client+Server dalam 1 file | Discord: https://discord.gg/E5kQJW3hn
-- Taruh di ServerScriptService sebagai Script

local RunService = game:GetService("RunService")
local RS         = game:GetService("ReplicatedStorage")
local Players    = game:GetService("Players")

-- ══════════════════════════════════════════════════════════════════════════
-- SECTION SERVER (jalan di server)
-- ══════════════════════════════════════════════════════════════════════════
if RunService:IsServer() then

	local root = RS:FindFirstChild("SysxHub")
	if not root then root = Instance.new("Folder"); root.Name="SysxHub"; root.Parent=RS end
	local rem = root:FindFirstChild("Remotes")
	if not rem then rem = Instance.new("Folder"); rem.Name="Remotes"; rem.Parent=root end
	for _,n in ipairs({"Farm","Chest","Boss","Material","Sea","Quest","Raid","Fishing","PvP","Stats","Combat","Misc","Discord","Status","Fruit"}) do
		if not rem:FindFirstChild(n) then
			local r=Instance.new("RemoteEvent"); r.Name=n; r.Parent=rem
		end
	end
	local R=function(n) return rem:FindFirstChild(n) end
	local T={Tools={Melee=true,Sword=true,Gun=true,["Blox Fruit"]=true}}

	-- ═══════ Combat ═══════
	R("Combat").OnServerEvent:Connect(function(player,action,data)
		if action=="Attack" then
			local ch=player.Character
			if ch then
				local tool=ch:FindFirstChildOfClass("Tool")
				if tool then pcall(function() tool:Activate() end) end
			end
		elseif action=="AutoHaki" or action=="AutoKen" then
			player:SetAttribute(action,data and data.enable)
		elseif action=="RequestTargets" then
			-- server kirim daftar NPC target (opsional)
		end
	end)

	-- ═══════ Farm ═══════
	R("Farm").OnServerEvent:Connect(function(player,action,data)
		if action=="setTool" then
			if T.Tools[data.tool] then player:SetAttribute("Tool",data.tool) end
		elseif action=="setLevel" then
			player:SetAttribute("TargetLevel",tonumber(data.value) or 100)
		elseif action=="selectQuest" then
			player:SetAttribute("Quest",data.quest)
			player:SetAttribute("QuestIsland",data.island)
		elseif action=="start" then
			player:SetAttribute("AutoFarm",true)
			task.spawn(function()
				while player:GetAttribute("AutoFarm") do
					-- cari NPC target terdekat
					local ch=player.Character
					if ch and ch:FindFirstChild("HumanoidRootPart") then
						local pos=ch.HumanoidRootPart.Position
						local nearest,dist=nil,math.huge
						for _,m in ipairs(workspace:GetDescendants()) do
							if m:IsA("Model") and m:FindFirstChild("Humanoid")
							   and m.Humanoid.Health>0 and m~=ch then
								local root=m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
								if root then
									local d=(root.Position-pos).Magnitude
									if d<dist and d<500 then nearest,dist=m,d end
								end
							end
						end
						if nearest then
							local root=nearest:FindFirstChild("HumanoidRootPart") or nearest.PrimaryPart
							if root then ch:PivotTo(root.CFrame*CFrame.new(0,0,4)) end
							local tool=ch:FindFirstChildOfClass("Tool")
							if tool then pcall(function() tool:Activate() end) end
						end
					end
					task.wait(0.35)
				end
			end)
		elseif action=="stop" then
			player:SetAttribute("AutoFarm",false)
		end
	end)

	-- ═══════ CHEST (dengan farm chest) ═══════
	local chestCounts={}
	R("Chest").OnServerEvent:Connect(function(player,action,data)
		if action=="start" then
			player:SetAttribute("AutoChest",true)
			task.spawn(function()
				local opened=0
				while player:GetAttribute("AutoChest") do
					local ch=player.Character
					if not ch or not ch:FindFirstChild("HumanoidRootPart") then task.wait(0.5) continue end
					-- cari chest
					local chest,dist=nil,math.huge
					local pos=ch.HumanoidRootPart.Position
					local rng=player:GetAttribute("ChestRange") or 150
					for _,obj in ipairs(workspace:GetDescendants()) do
						if obj:IsA("Model") and obj.Name:lower():find("chest")
						   and not obj:GetAttribute("Opened") then
							local p=obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
							if p then
								local d=(p.Position-pos).Magnitude
								if d<dist and d<rng then chest,dist=obj,d end
							end
						end
					end
					if chest then
						local p=chest:FindFirstChild("HumanoidRootPart") or chest.PrimaryPart
						if p then ch:PivotTo(p.CFrame+Vector3.new(0,3,0)) end
						task.wait(0.4)
						chest:SetAttribute("Opened",true)
						opened=opened+1
						chestCounts[player]=opened
						R("Chest"):FireClient(player,"count",opened)
						local items={"Sword","Money","Fruit","Material","Potion"}
						local got=items[math.random(1,#items)]
						R("Chest"):FireClient(player,"lastItem",got)
						if player:GetAttribute("ChestStopItem") and got~="Money" then
							player:SetAttribute("AutoChest",false)
							R("Chest"):FireClient(player,"stop",got)
							break
						end
					end
					task.wait(player:GetAttribute("ChestSpeed") or 0.5)
				end
			end)
		elseif action=="stop" then
			player:SetAttribute("AutoChest",false)
		elseif action=="stopWhenItem" then
			player:SetAttribute("ChestStopItem",data.enable)
		elseif action=="setRange" then
			player:SetAttribute("ChestRange",data.value)
		elseif action=="setSpeed" then
			player:SetAttribute("ChestSpeed",data.value)
		elseif action=="collectItem" then
			player:SetAttribute("ChestCollect",data.enable)
		elseif action=="setType" then
			player:SetAttribute("ChestType",data.type)
		elseif action=="setPriority" then
			player:SetAttribute("ChestPriority",data.priority)
		elseif action=="setArea" then
			player:SetAttribute("ChestArea",data.area)
		elseif action=="teleport" or action=="tween" or action=="skipOpened" or action=="respawn" then
			player:SetAttribute(action,data.enable)
		elseif data and data.mode=="instant" and action=="start" then
			-- handled di action start
		end
	end)
	Players.PlayerRemoving:Connect(function(p) chestCounts[p]=nil end)

	-- ═══════ Boss ═══════
	R("Boss").OnServerEvent:Connect(function(player,action,data)
		if action=="select" then
			player:SetAttribute("Boss",data.boss)
		elseif action=="killSelected" then
			player:SetAttribute("AutoKillBoss",data.enable)
			if data.enable then
				task.spawn(function()
					while player:GetAttribute("AutoKillBoss") do
						local target=player:GetAttribute("Boss")
						for _,m in ipairs(workspace:GetDescendants()) do
							if m:IsA("Model") and m.Name==target and m:FindFirstChild("Humanoid")
							   and m.Humanoid.Health>0 then
								local ch=player.Character
								if ch and ch:FindFirstChild("HumanoidRootPart") then
									local p=m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
									if p then
										ch:PivotTo(p.CFrame*CFrame.new(0,0,4))
										local tool=ch:FindFirstChildOfClass("Tool")
										if tool then pcall(function() tool:Activate() end) end
									end
								end
								break
							end
						end
						task.wait(0.35)
					end
				end)
			end
		elseif action=="farmAll" then
			player:SetAttribute("AutoFarmAllBoss",data.enable)
		elseif action=="takeQuest" then
			player:SetAttribute("TakeBossQuest",data.enable)
		elseif action=="updateList" then
			-- refresh list
		end
	end)

	-- ═══════ Material ═══════
	R("Material").OnServerEvent:Connect(function(player,action,data)
		if action=="select" then
			player:SetAttribute("Material",data.material)
			player:SetAttribute("MatNPC",data.npc)
		elseif action=="start" then
			player:SetAttribute("AutoMaterial",true)
			task.spawn(function()
				while player:GetAttribute("AutoMaterial") do
					local target=player:GetAttribute("MatNPC")
					if target then
						local ch=player.Character
						if ch and ch:FindFirstChild("HumanoidRootPart") then
							for _,m in ipairs(workspace:GetDescendants()) do
								if m:IsA("Model") and m.Name==target and m:FindFirstChild("Humanoid") and m.Humanoid.Health>0 then
									local p=m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
									if p then
										ch:PivotTo(p.CFrame*CFrame.new(0,0,4))
										local tool=ch:FindFirstChildOfClass("Tool")
										if tool then pcall(function() tool:Activate() end) end
									end
									break
								end
							end
						end
					end
					task.wait(0.35)
				end
			end)
		elseif action=="stop" then
			player:SetAttribute("AutoMaterial",false)
		elseif action=="stopWhenObtained" then
			player:SetAttribute("MatStop",data.enable)
		end
	end)

	-- ═══════ Sea ═══════
	R("Sea").OnServerEvent:Connect(function(player,action,data)
		if action=="selectMob" then
			player:SetAttribute("SeaMob",data.mob)
		elseif action=="selectEnemy" then
			player:SetAttribute("SeaMob",data.enemy)
		elseif action=="farm" then
			player:SetAttribute("AutoSea",data.enable)
			if data.enable then
				task.spawn(function()
					while player:GetAttribute("AutoSea") do
						local target=player:GetAttribute("SeaMob")
						if target then
							local ch=player.Character
							if ch and ch:FindFirstChild("HumanoidRootPart") then
								for _,m in ipairs(workspace:GetDescendants()) do
									if m:IsA("Model") and m.Name==target and m:FindFirstChild("Humanoid") and m.Humanoid.Health>0 then
										local p=m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
										if p then
											ch:PivotTo(p.CFrame*CFrame.new(0,5,15))
											local tool=ch:FindFirstChildOfClass("Tool")
											if tool then pcall(function() tool:Activate() end) end
										end
										break
									end
								end
							end
						end
						task.wait(0.35)
					end
				end)
			end
		elseif action=="start" then
			player:SetAttribute("Sea"..(data.mode or "misc"),true)
		elseif action=="stop" then
			player:SetAttribute("Sea"..(data.mode or "misc"),false)
		elseif action=="boatHeight" then
			local boat=workspace:FindFirstChild("Boats") and workspace.Boats:FindFirstChild(player.Name)
			if boat and boat.PrimaryPart then
				local y=math.clamp(data.value,0,100)
				boat:PivotTo(boat:GetPivot()+Vector3.new(0,y,0))
			end
		elseif action=="boatSpeed" then
			local boat=workspace:FindFirstChild("Boats") and workspace.Boats:FindFirstChild(player.Name)
			if boat then
				local vel=boat.PrimaryPart and boat.PrimaryPart:FindFirstChildOfClass("BodyVelocity")
				if vel then vel.Velocity=Vector3.new(0,0,math.clamp(data.value,0,200)) end
			end
		end
	end)

	-- ═══════ Quest / Secret ═══════
	R("Quest").OnServerEvent:Connect(function(player,action,data)
		if action=="startSecret" then
			player:SetAttribute("SecretRunning",true)
		elseif action=="stopSecret" then
			player:SetAttribute("SecretRunning",false)
		elseif action=="selectSecret" then
			player:SetAttribute("SecretQuest",data.name)
		elseif action=="killCakePrince" or action=="spawnDoughKing"
			or action=="killSoulReaper" or action=="spawnIndra"
			or action=="getYama" or action=="getTushita"
			or action=="getBuddySword" or action=="getSoulGuitar"
			or action=="getHallowScythe" then
			player:SetAttribute(action,true)
		end
	end)

	-- ═══════ Raid / Fruit ═══════
	R("Raid").OnServerEvent:Connect(function(player,action,data)
		if action=="selectChip" then player:SetAttribute("Chip",data.chip)
		elseif action=="start" then player:SetAttribute("AutoRaid",true)
		elseif action=="stop" then player:SetAttribute("AutoRaid",false)
		elseif action=="rolled" then
			local fruits={"Flame","Ice","Light","Dark","Rubber","Quake","Dough"}
			R("Raid"):FireClient(player,"rolled",fruits[math.random(1,#fruits)])
		elseif action=="store" then
			player:SetAttribute("AutoStoreFruit",true)
		end
	end)

	R("Fruit").OnServerEvent:Connect(function(player,action,data)
		if action=="store" then
			local itemName=data.item
			if type(itemName)~="string" then return end
			local ch=player.Character
			local bp=player:FindFirstChild("Backpack")
			local src=nil
			if ch then for _,t in ipairs(ch:GetChildren()) do
				if t:IsA("Tool") and t.Name==itemName then src=t break end
			end end
			if not src and bp then for _,t in ipairs(bp:GetChildren()) do
				if t:IsA("Tool") and t.Name==itemName then src=t break end
			end end
			if src then
				local storage=player:FindFirstChild("Storage")
				if not storage then
					storage=Instance.new("Folder"); storage.Name="Storage"; storage.Parent=player
				end
				src.Parent=storage
				R("Fruit"):FireClient(player,"stored",{item=itemName})
			end
		end
	end)

	-- ═══════ Fishing ═══════
	R("Fishing").OnServerEvent:Connect(function(player,action,data)
		if action=="start" then
			player:SetAttribute("Fishing_"..(data.mode or "auto"),true)
		elseif action=="stop" then
			player:SetAttribute("Fishing_"..(data.mode or "auto"),false)
		end
	end)

	-- ═══════ PvP ═══════
	R("PvP").OnServerEvent:Connect(function(player,action,data)
		if action=="select" then player:SetAttribute("PvPTarget",data.player)
		elseif action=="start" then player:SetAttribute("PvP_"..(data.mode or "auto"),true)
		elseif action=="stop" then player:SetAttribute("PvP_"..(data.mode or "auto"),false)
		elseif action=="teleport" then
			local tgt=Players:FindFirstChild(player:GetAttribute("PvPTarget") or "")
			if tgt and tgt.Character and player.Character then
				player.Character:PivotTo(tgt.Character:GetPivot()+Vector3.new(0,0,4))
			end
		end
	end)

	-- ═══════ Stats ═══════
	R("Stats").OnServerEvent:Connect(function(player,action,data)
		if action=="melee" or action=="sword" or action=="gun"
			or action=="defense" or action=="fruit" then
			local v=math.clamp(tonumber(data.value) or 0,0,100)
			player:SetAttribute("Stat_"..action,v)
		elseif action=="start" then player:SetAttribute("AddStats",true)
		elseif action=="stop" then player:SetAttribute("AddStats",false)
		end
	end)

	-- ═══════ Misc (Redeem) ═══════
	local VALID={
		["SUB2GAMERROBOT_EXP1"]=true,["EASTEREXP"]=true,["KittGaming"]=true,
		["Sub2CaptainMaui"]=true,["Sub2OfficialNoobie"]=true,["Sub2Fer999"]=true,
		["Enyu_is_Pro"]=true,["JCWK"]=true,["StarcodeHEO"]=true,["MagicBUS"]=true,
		["TheGreatAce"]=true,["Sub2NoobMaster123"]=true,["Sub2Daigrock"]=true,
		["Axiore"]=true,["StrawHatMaine"]=true,["TantaiGaming"]=true,
		["Bluxxy"]=true,["KITT_RESET"]=true,["Sub2UncleKizaru"]=true,
		["SUB2GAMERROBOT_RESET1"]=true,["BIGNEWS"]=true,["fudd10_V2"]=true,
		["fudd10"]=true,["CHANDLER"]=true,
	}
	local cd={}
	R("Misc").OnServerEvent:Connect(function(player,action,data)
		if action=="redeem" then
			local code=data and data.code
			if type(code)~="string" or #code>64 then return end
			local now=tick()
			cd[player]=cd[player] or 0
			if now-cd[player]<0.5 then return end
			cd[player]=now
			if not VALID[code] then return end
			local f=player:FindFirstChild("RedeemedCodes")
			if not f then f=Instance.new("Folder"); f.Name="RedeemedCodes"; f.Parent=player end
			if f:FindFirstChild(code) then return end
			Instance.new("BoolValue",f).Name=code
			R("Misc"):FireClient(player,"redeemResult",{code=code,success=true})
		elseif action=="start" then
			player:SetAttribute("Misc_"..(data.mode or "auto"),true)
		elseif action=="stop" then
			player:SetAttribute("Misc_"..(data.mode or "auto"),false)
		elseif action=="checkMap" then
			R("Misc"):FireClient(player,"fruitStatus",false)
			R("Misc"):FireClient(player,"mapStatus","OK")
		end
	end)
	Players.PlayerRemoving:Connect(function(p) cd[p]=nil end)

	print("[SysxHub] Server v1.8.0 ready")
end

-- ══════════════════════════════════════════════════════════════════════════
-- SECTION CLIENT (jalan di client)
-- ══════════════════════════════════════════════════════════════════════════
if RunService:IsClient() then

	local UIS = game:GetService("UserInputService")
	local Tw  = game:GetService("TweenService")
	local TS  = game:GetService("TeleportService")
	local Plr = Players.LocalPlayer

	local Br={Name="SysxHub",Discord="https://discord.gg/E5kQJW3hn",Asset="rbxassetid://70792832229220",Ver="1.8.0"}
	local T={Bg=Color3.fromRGB(18,10,27),Bg2=Color3.fromRGB(25,14,37),Pn=Color3.fromRGB(31,17,45),Pn2=Color3.fromRGB(39,21,56),Pr=Color3.fromRGB(105,45,160),PrD=Color3.fromRGB(72,28,112),PrL=Color3.fromRGB(145,75,205),Tx=Color3.fromRGB(245,240,250),Tx2=Color3.fromRGB(175,160,190),St=Color3.fromRGB(75,42,95),Ok=Color3.fromRGB(100,210,140),Wn=Color3.fromRGB(230,190,80),Er=Color3.fromRGB(220,80,100)}
	local CFG={W=660,H=480,SW=158,TH=50,CR=10,SO={0.75,0.85,1.0,1.10,1.25},Tabs={"Discord","Farm","Chest","Boss","Material","Sea","Quests / Items","Fruit / Raid","Fishing","Status","PvP","Stats","Misc"}}
	local S={Tool="Melee",Level=100,Sea=1,Quest=nil,Boss=nil,Mat=nil,Enemy=nil,SeaMob=nil,Plr=nil,Chip=nil,SQ=nil,SQI=nil,Tg={},Sl={}}
	local U={}
	function U.mk(c,p,par)local o=Instance.new(c)for k,v in pairs(p or{})do o[k]=v end if par then o.Parent=par end return o end
	function U.cr(o,r)return U.mk("UICorner",{CornerRadius=UDim.new(0,r or CFG.CR)},o)end
	function U.st(o,c,t)return U.mk("UIStroke",{Color=c or T.St,Thickness=t or 1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},o)end
	function U.pd(o,p)local x=U.mk("UIPadding",{},o)local u=UDim.new(0,p or 8)x.PaddingTop,x.PaddingBottom,x.PaddingLeft,x.PaddingRight=u,u,u,u return x end
	function U.gd(o,a,b,r)return U.mk("UIGradient",{Color=ColorSequence.new(a,b),Rotation=r or 90},o)end
	function U.tn(o,t,k)local w=Tw:Create(o,t,k)w:Play()return w end
	function U.tr(f,e)local o,x=pcall(f)if not o and e then e(x)end return o,x end

	local D={}
	D.Tools={"Melee","Sword","Gun","Blox Fruit"}
	D.Chips={"Flame Chip","Ice Chip","Quake Chip","Light Chip"}
	D.Codes={"SUB2GAMERROBOT_EXP1","EASTEREXP","KittGaming","Sub2CaptainMaui","Sub2OfficialNoobie","Sub2Fer999","Enyu_is_Pro","JCWK","StarcodeHEO","MagicBUS","TheGreatAce","Sub2NoobMaster123","Sub2Daigrock","Axiore","StrawHatMaine","TantaiGaming","Bluxxy","KITT_RESET","Sub2UncleKizaru","SUB2GAMERROBOT_RESET1","BIGNEWS","fudd10_V2","fudd10","CHANDLER"}
	D.Mat={["Bones"]={"Skeleton","Jungle",1,"Common",5,"Instant"},["Ectoplasm"]={"Ghost","Graveyard",2,"Uncommon",200,"20s"},["Gunpowder"]={"Pirate","Pirate Village",1,"Common",10,"10s"},["Scrap Metal"]={"Dock Worker","Port Town",3,"Common",700,"15s"},["Leather"]={"Bandit","Starter Island",1,"Common",1,"Instant"},["Magma Ore"]={"Magma Beast","Magma Village",1,"Rare",90,"2m"},["Fish Tail"]={"Sea Serpent","Underwater City",1,"Uncommon",110,"30s"},["Mystic Droplet"]={"Fountain Spirit","Fountain City",1,"Rare",130,"1m"},["Vampire Fang"]={"Haunted Knight","Haunted Castle",3,"Epic",1200,"3m"},["Radioactive Material"]={"Mutant Beast","Green Zone",2,"Epic",175,"3m"},["Shark Tooth"]={"Shark","Underwater City",1,"Uncommon",110,"45s"},["Conjured Cocoa"]={"Candy Monster","Sea of Treats",3,"Rare",1400,"2m"},["Demonic Wisp"]={"Dark Knight","Dark Arena",2,"Epic",250,"3m"},["Dragon Scale"]={"Hydra Head","Hydra Island",3,"Legendary",800,"5m"},["Electric Wing"]={"Sky Warrior","Skylands",1,"Rare",40,"2m"},["Mutant Tooth"]={"Mutant Beast","Forgotten Island",2,"Legendary",500,"5m"}}
	D.Bosses={"Gorilla King","Bobby","The Saw","Yeti","Vice Admiral","Saber Expert","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Don Swan","Darkbeard","Order","Cursed Captain","Awakened Ice Admiral","Stone","Hydra Leader","Kilo Admiral","Captain Elephant","Beautiful Pirate","Longma","Cursed Skeleton","Island Empress","Cake Queen"}
	D.Enemies={"Bandit","Skeleton","Pirate","Desert Bandit","Frozen Soldier","Marine Captain","Sky Warrior","Prison Guard","Gladiator","Magma Beast","Sea Serpent","Fountain Spirit","Rose Guard","Mutant Beast","Zombie","Dark Knight","Snow Golem","Twin Beast","Ghost Pirate","Ice King","Forgotten Knight","Usoap","Barista","Don Swan Servant","Dock Worker","Hydra Head","Tree Guardian","Turtle Guard","Haunted Knight","Candy Monster","Castle Guard","Beautiful Pirate","Tiki Warrior"}
	D.SeaMobs={
	{name="Sea Beast",sea=1,lv=100,hp=8000,type="Beast"},{name="Pirate Ship",sea=1,lv=120,hp=15000,type="Ship"},{name="Piranha",sea=1,lv=80,hp=2500,type="Beast"},{name="Shark",sea=1,lv=90,hp=5000,type="Beast"},{name="FishCrew Member",sea=1,lv=70,hp=3000,type="NPC"},
	{name="Cursed Ship",sea=2,lv=1100,hp=60000,type="Ship"},{name="Big Sea Beast",sea=2,lv=1150,hp=100000,type="Beast"},{name="Ghost Pirate Ship",sea=2,lv=1200,hp=150000,type="Ship"},{name="Sea Monster",sea=2,lv=1300,hp=200000,type="Beast"},
	{name="Terror Shark",sea=3,lv=1600,hp=400000,type="Beast"},{name="Sea Emperor",sea=3,lv=1700,hp=500000,type="Boss"},{name="Leviathan",sea=3,lv=1800,hp=800000,type="Boss"},{name="Kraken",sea=3,lv=2000,hp=1000000,type="Boss"}}
	D.SQ={{island="Starter Island",name="The Finale"},{island="Jungle",name="Perbaiki Zipline"},{island="Jungle",name="Kalahkan Monyet Pencuri & Kembalikan Topi"},{island="Jungle",name="Jatuhkan Pisang untuk Membangunkan Awakened Gorilla King"},{island="Pirate Village",name="Bebaskan Kincir Angin"},{island="Pirate Village",name="Usir 3 Tavern Pirates"},{island="Pirate Village",name="Masak Stew untuk Membangunkan Awakened Chef"},{island="Desert",name="Selamatkan Hasan"},{island="Desert",name="Bersihkan 8 Rune/Pilar"},{island="Desert",name="Kumpulkan 10 Cactus Petals"},{island="Frozen Village",name="Bebaskan Ability Teacher dari Es"},{island="Frozen Village",name="Buat Snowman"},{island="Frozen Village",name="Hancurkan 3 Bongkahan Es Hijau"},{island="Marine Fortress",name="Pasang/Naikkan Bendera"},{island="Marine Fortress",name="Pertahankan Benteng dari Serangan Bajak Laut"},{island="Marine Fortress",name="Hancurkan Bagian Bangunan"},{island="Lower Skylands",name="Cari Lightning Bolt untuk Mad Scientist"},{island="Lower Skylands",name="Usir Penyusup dari Skylands Castle & Temukan Kode Vault"},{island="Lower Skylands",name="Pukul Secret Cloud hingga Menjatuhkan Chest"},{island="Prison",name="Bantu 3 Tahanan Kabur"},{island="Prison",name="Ambil Kunci & Pink Coat"},{island="Prison",name="Atur Tuas"},{island="Colosseum",name="Selesaikan 3 Wave Pertarungan"},{island="Colosseum",name="Aktifkan 4 Patung dengan Tipe Serangan Sesuai"},{island="Colosseum",name="Hancurkan 18 Target dalam 90 Detik"},{island="Magma Village",name="Hadapi Gelombang Magma Elemental"},{island="Magma Village",name="Hancurkan Magma Drill"},{island="Magma Village",name="Hancurkan 5 Mini Lava Geyser"},{island="Underwater City",name="Naiki Bubble ke Hidden Cove & Ambil Chest"},{island="Underwater City",name="Atur Crystal untuk Membuka Jalan"},{island="Underwater City",name="Cari Black Pearl di Kerang"},{island="Upper Skylands",name="Ambil Relic di Old Temple"},{island="Upper Skylands",name="Serang Awan Petir Gelap"},{island="Upper Skylands",name="Bunyikan Bell 6 Kali Sesuai Simbol"},{island="Fountain City",name="Perbaiki Pipa Fountain & Naik Boat"},{island="Fountain City",name="Buka Manhole & Kalahkan Megalo Brute"},{island="Fountain City",name="Perbaiki Kabel Junkyard"}}

	local root=RS:WaitForChild("SysxHub")
	local rem=root:WaitForChild("Remotes")
	local R=function(n)return rem:FindFirstChild(n)end
	local fire=function(n,a,d)local r=R(n)if r then r:FireServer(a,d or{})end end

	local Cb={run=false,tg={Haki=false,Ken=false,Attack=false}}
	function Cb:set(k,v)self.tg[k]=v end
	function Cb:go()if self.run then return end self.run=true task.spawn(function()if self.tg.Haki then fire("Combat","AutoHaki",{enable=true})end task.wait(0.15)if self.tg.Ken then fire("Combat","AutoKen",{enable=true})end task.wait(0.15)fire("Combat","RequestTargets",{})while self.run do if self.tg.Attack then fire("Combat","Attack",{})end task.wait(0.35)end fire("Combat","Stop",{})end)end
	function Cb:stop()self.run=false end

	local Nf={}local nH
	local function nCol(k)if k=="SUCCESS"then return T.Ok end if k=="WARNING"then return T.Wn end if k=="ERROR"then return T.Er end return T.PrL end
	function Nf.Init(par)nH=U.mk("Frame",{Name="NH",BackgroundTransparency=1,Size=UDim2.new(0,300,1,-60),Position=UDim2.new(1,-312,0,44)},par)U.mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Top},nH)end
	function Nf.Push(k,ti,msg,d)if not nH then return end d=d or 3 local c=U.mk("Frame",{BackgroundColor3=T.Pn,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),BackgroundTransparency=1},nH)U.cr(c,8)U.st(c,nCol(k))U.mk("Frame",{BackgroundColor3=nCol(k),BorderSizePixel=0,Size=UDim2.new(0,4,1,-8),Position=UDim2.new(0,4,0,4)},c)U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text=ti,TextColor3=T.Tx,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,-20,0,16),Position=UDim2.new(0,14,0,6)},c)U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Text=msg,TextColor3=T.Tx2,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Size=UDim2.new(1,-20,0,16),Position=UDim2.new(0,14,0,22)},c)U.tn(c,TweenInfo.new(0.28,Enum.EasingStyle.Quart),{Size=UDim2.new(1,0,0,46),BackgroundTransparency=0})task.delay(d,function()if not c.Parent then return end local w=U.tn(c,TweenInfo.new(0.22),{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1})w.Completed:Connect(function()c:Destroy()end)end)end

	local Gui=U.mk("ScreenGui",{Name="SysxHub",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},Plr:WaitForChild("PlayerGui"))Nf.Init(Gui)
	local Ob=U.mk("ImageButton",{Name="OpenButton",Image=Br.Asset,BackgroundTransparency=1,Size=UDim2.fromOffset(64,64),Position=UDim2.new(0,20,0.5,-32),AnchorPoint=Vector2.new(0,0),ScaleType=Enum.ScaleType.Fit},Gui)U.cr(Ob,32)U.mk("UIAspectRatioConstraint",{AspectRatio=1,AspectType=Enum.AspectType.FitWithinMaxSize,DominantAxis=Enum.DominantAxis.Width},Ob)
	local M=U.mk("Frame",{Name="MW",BackgroundColor3=T.Bg,BorderSizePixel=0,Size=UDim2.fromOffset(CFG.W,CFG.H),Position=UDim2.new(0.5,-CFG.W/2,0.5,-CFG.H/2)},Gui)U.cr(M,12)U.st(M,T.St)M.ClipsDescendants=true local Sc=U.mk("UIScale",{Scale=1},M)
	local TB=U.mk("Frame",{Name="TB",BackgroundColor3=T.Bg2,BorderSizePixel=0,Size=UDim2.new(1,0,0,CFG.TH)},M)U.cr(TB,12)U.st(TB,T.St)U.gd(TB,T.PrD,T.Bg2,0)
	local Lg=U.mk("ImageLabel",{Image=Br.Asset,BackgroundTransparency=1,Size=UDim2.fromOffset(50,50),Position=UDim2.new(0,6,0.5,-25),ScaleType=Enum.ScaleType.Fit},TB)U.mk("UIAspectRatioConstraint",{AspectRatio=1,AspectType=Enum.AspectType.FitWithinMaxSize,DominantAxis=Enum.DominantAxis.Width},Lg)
	U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text=Br.Name,TextColor3=T.PrL,TextSize=18,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(0,200,1,0),Position=UDim2.new(0,62,0,0)},TB)
	local function tBt(t,x,c)local b=U.mk("TextButton",{BackgroundColor3=c or T.Pn2,BorderSizePixel=0,Text=t,TextColor3=T.Tx,Font=Enum.Font.GothamBold,TextSize=14,AutoButtonColor=false,Size=UDim2.fromOffset(30,28),Position=UDim2.new(1,x,0.5,-14)},TB)U.cr(b,6)b.MouseEnter:Connect(function()U.tn(b,TweenInfo.new(0.15),{BackgroundColor3=T.Pr})end)b.MouseLeave:Connect(function()U.tn(b,TweenInfo.new(0.15),{BackgroundColor3=c or T.Pn2})end)return b end
	local ScaleBtn=tBt("◱",-102)local MinBtn=tBt("—",-68)local ClsBtn=tBt("✕",-34,T.Er)
	local Sb=U.mk("Frame",{BackgroundColor3=T.Bg2,BorderSizePixel=0,Size=UDim2.new(0,CFG.SW,1,-CFG.TH),Position=UDim2.new(0,0,0,CFG.TH)},M)U.st(Sb,T.St)
	local SLH=U.mk("Frame",{BackgroundColor3=T.Bg2,BorderSizePixel=0,Size=UDim2.new(1,-12,0,100),Position=UDim2.new(0,6,0,6)},Sb)U.cr(SLH,8)
	local SLg=U.mk("ImageLabel",{Image=Br.Asset,BackgroundTransparency=1,Size=UDim2.fromOffset(88,88),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),ScaleType=Enum.ScaleType.Fit},SLH)U.mk("UIAspectRatioConstraint",{AspectRatio=1,AspectType=Enum.AspectType.FitWithinMaxSize,DominantAxis=Enum.DominantAxis.Width},SLg)
	local SSb=U.mk("ScrollingFrame",{BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,-112),Position=UDim2.new(0,0,0,112),CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=3,ScrollBarImageColor3=T.Pr},Sb)U.mk("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},SSb)U.pd(SSb,6)
	local Ct=U.mk("Frame",{BackgroundColor3=T.Bg,BorderSizePixel=0,Size=UDim2.new(1,-CFG.SW,1,-CFG.TH),Position=UDim2.new(0,CFG.SW,0,CFG.TH)},M)
	local SR=U.mk("TextBox",{BackgroundColor3=T.Bg2,BorderSizePixel=0,ClearTextOnFocus=false,PlaceholderText="Search Feature...",PlaceholderColor3=T.Tx2,TextColor3=T.Tx,Font=Enum.Font.Gotham,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Text="",Size=UDim2.new(1,-24,0,32),Position=UDim2.new(0,12,0,10)},Ct)U.cr(SR,6)U.st(SR)U.pd(SR,8)
	local CS=U.mk("ScrollingFrame",{BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,-16,1,-58),Position=UDim2.new(0,8,0,52),CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=4,ScrollBarImageColor3=T.Pr},Ct)U.mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},CS)U.pd(CS,8)
	local CM={l={}}
	function CM:add(c)table.insert(self.l,c)end
	function CM:clr()for _,c in ipairs(self.l)do pcall(function()c:Disconnect()end)end self.l={}end
	local cT,reg=nil,{}
	local function clrC()CM:clr()for _,c in ipairs(CS:GetChildren())do if c:IsA("GuiObject")then c:Destroy()end end reg={}end
	local function secL(t,o)local l=U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text="▸ "..t,TextColor3=T.PrL,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,-8,0,22)},CS)l.LayoutOrder=o or 0 table.insert(reg,{cT,t,l})return l end
	local function mkTg(t,k,d,cb,o)local r=U.mk("Frame",{BackgroundColor3=T.Pn,BorderSizePixel=0,Size=UDim2.new(1,-8,0,36)},CS)r.LayoutOrder=o or 0 U.cr(r,8)U.st(r)U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamMedium,Text=t,TextColor3=T.Tx,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,-80,1,0),Position=UDim2.new(0,12,0,0)},r)local st=S.Tg[k]if st==nil then st=d or false end local tr=U.mk("Frame",{BackgroundColor3=st and T.PrL or T.Pn2,BorderSizePixel=0,Size=UDim2.fromOffset(46,22),Position=UDim2.new(1,-58,0.5,-11)},r)U.cr(tr,11)U.st(tr)local kn=U.mk("Frame",{BackgroundColor3=T.Tx,BorderSizePixel=0,Size=UDim2.fromOffset(18,18),Position=st and UDim2.new(1,-20,0.5,-9)or UDim2.new(0,2,0.5,-9)},tr)U.cr(kn,9)local bt=U.mk("TextButton",{BackgroundTransparency=1,Text="",Size=UDim2.new(1,0,1,0)},r)CM:add(bt.MouseButton1Click:Connect(function()st=not st S.Tg[k]=st local ti=TweenInfo.new(0.18,Enum.EasingStyle.Quart)U.tn(tr,ti,{BackgroundColor3=st and T.PrL or T.Pn2})U.tn(kn,ti,{Position=st and UDim2.new(1,-20,0.5,-9)or UDim2.new(0,2,0.5,-9)})if cb then U.tr(function()cb(st)end,function(e)Nf.Push("ERROR","Toggle",tostring(e),3)end)end end))table.insert(reg,{cT,t,r})return r end
	local function mkBt(t,cb,o)local b=U.mk("TextButton",{BackgroundColor3=T.Pn,BorderSizePixel=0,Text=t,TextColor3=T.Tx,Font=Enum.Font.GothamMedium,TextSize=13,AutoButtonColor=false,Size=UDim2.new(1,-8,0,34)},CS)b.LayoutOrder=o or 0 U.cr(b,8)U.st(b)CM:add(b.MouseEnter:Connect(function()U.tn(b,TweenInfo.new(0.15),{BackgroundColor3=T.Pn2})end))CM:add(b.MouseLeave:Connect(function()U.tn(b,TweenInfo.new(0.15),{BackgroundColor3=T.Pn})end))CM:add(b.MouseButton1Click:Connect(function()if cb then U.tr(cb)end end))table.insert(reg,{cT,t,b})return b end
	local function mkSl(t,mn,mx,d,cb,o)local r=U.mk("Frame",{BackgroundColor3=T.Pn,BorderSizePixel=0,Size=UDim2.new(1,-8,0,48)},CS)r.LayoutOrder=o or 0 U.cr(r,8)U.st(r)U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamMedium,Text=t,TextColor3=T.Tx,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,-80,0,18),Position=UDim2.new(0,12,0,4)},r)local vl=U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text=string.format("%.0f",d),TextColor3=T.PrL,TextSize=13,TextXAlignment=Enum.TextXAlignment.Right,Size=UDim2.new(0,66,0,18),Position=UDim2.new(1,-78,0,4)},r)local br=U.mk("Frame",{BackgroundColor3=T.Bg2,BorderSizePixel=0,Size=UDim2.new(1,-24,0,8),Position=UDim2.new(0,12,0,30)},r)U.cr(br,4)U.st(br)local fl=U.mk("Frame",{BackgroundColor3=T.PrL,BorderSizePixel=0,Size=UDim2.new((d-mn)/(mx-mn),0,1,0)},br)U.cr(fl,4)local kn=U.mk("Frame",{BackgroundColor3=T.Tx,BorderSizePixel=0,Size=UDim2.fromOffset(14,14),Position=UDim2.new((d-mn)/(mx-mn),-7,0.5,-7)},br)U.cr(kn,7)local dg=false local function sX(x)local rr=math.clamp((x-br.AbsolutePosition.X)/br.AbsoluteSize.X,0,1)local v=mn+(mx-mn)*rr fl.Size=UDim2.new(rr,0,1,0)kn.Position=UDim2.new(rr,-7,0.5,-7)vl.Text=string.format("%.0f",v)if cb then U.tr(function()cb(v)end)end end CM:add(br.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=true sX(i.Position.X)end end))CM:add(UIS.InputChanged:Connect(function(i)if dg and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then sX(i.Position.X)end end))CM:add(UIS.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=false end end))table.insert(reg,{cT,t,r})return r end
	local function mkDd(lb,opt,cb,o,sk)local h=U.mk("Frame",{BackgroundColor3=T.Pn,BorderSizePixel=0,Size=UDim2.new(1,-8,0,36)},CS)h.LayoutOrder=o or 0 U.cr(h,8)U.st(h)h.ClipsDescendants=true local it=(sk and S[sk])or opt[1]or"-" local hd=U.mk("TextButton",{BackgroundColor3=T.Pn,BorderSizePixel=0,Text="  "..lb..": "..tostring(it),TextColor3=T.Tx,Font=Enum.Font.GothamMedium,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,Size=UDim2.new(1,0,0,36)},h)local lh=U.mk("Frame",{BackgroundColor3=T.Bg2,BorderSizePixel=0,Size=UDim2.new(1,-16,0,0),Position=UDim2.new(0,8,0,38)},h)U.cr(lh,6)lh.ClipsDescendants=true U.mk("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder},lh)local op=false for i,v in ipairs(opt)do local ib=U.mk("TextButton",{BackgroundColor3=T.Pn,BorderSizePixel=0,Text="  "..v,TextColor3=T.Tx,Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,Size=UDim2.new(1,-8,0,28),LayoutOrder=i},lh)U.cr(ib,4)CM:add(ib.MouseEnter:Connect(function()U.tn(ib,TweenInfo.new(0.12),{BackgroundColor3=T.Pn2})end))CM:add(ib.MouseLeave:Connect(function()U.tn(ib,TweenInfo.new(0.12),{BackgroundColor3=T.Pn})end))CM:add(ib.MouseButton1Click:Connect(function()hd.Text="  "..lb..": "..v if sk then S[sk]=v end op=false U.tn(h,TweenInfo.new(0.2),{Size=UDim2.new(1,-8,0,36)})U.tn(lh,TweenInfo.new(0.2),{Size=UDim2.new(1,-16,0,0)})if cb then U.tr(function()cb(v)end)end end))end CM:add(hd.MouseButton1Click:Connect(function()op=not op local hh=math.min(#opt*30+8,180)U.tn(h,TweenInfo.new(0.2),{Size=UDim2.new(1,-8,0,op and 36+hh+8 or 36)})U.tn(lh,TweenInfo.new(0.2),{Size=UDim2.new(1,-16,0,op and hh or 0)})end))CM:add(UIS.InputBegan:Connect(function(i)if not op then return end if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then op=false U.tn(h,TweenInfo.new(0.2),{Size=UDim2.new(1,-8,0,36)})U.tn(lh,TweenInfo.new(0.2),{Size=UDim2.new(1,-16,0,0)})end end))table.insert(reg,{cT,lb,h})return h end
	local function mkI(o,ht)local h=U.mk("Frame",{BackgroundColor3=T.Pn,BorderSizePixel=0,Size=UDim2.new(1,-8,0,ht or 100)},CS)h.LayoutOrder=o or 0 U.cr(h,8)U.st(h)return h end
	local function fI(h,ls)for _,c in ipairs(h:GetChildren())do if c:IsA("GuiObject")then c:Destroy()end end U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Text=table.concat(ls,"\n"),TextColor3=T.Tx,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextWrapped=true,Size=UDim2.new(1,-16,1,-16),Position=UDim2.new(0,8,0,8)},h)end

	local TBU={}
	TBU["Discord"]=function()secL("Community",1)mkBt("Join Discord — "..Br.Discord,function()if setclipboard then pcall(setclipboard,Br.Discord)end Nf.Push("SUCCESS","Discord",Br.Discord,3)end,2)secL("Info",3)mkBt("Version: "..Br.Ver,function()end,4)mkBt("Copy Asset Toggle ID",function()if setclipboard then pcall(setclipboard,"70792832229220")end Nf.Push("SUCCESS","Asset","Copied",2)end,5)end
	TBU["Farm"]=function()secL("Farm Config",1)mkDd("Select Tool",D.Tools,function(v)fire("Farm","setTool",{tool=v})end,2,"Tool")mkSl("UI Scale",0.5,1.5,1.0,function(v)Sc.Scale=v end,3)secL("Quest",4)local ql={"Select Quest..."}for _,q in ipairs(D.SQ)do table.insert(ql,q.name.." @"..q.island)end mkDd("Quest",ql,function(v)if v=="Select Quest..."then return end local q,i=v:match("^(.-) @(.+)$")S.Quest=q S.SQI=i Nf.Push("INFO","Quest",v,3)fire("Farm","selectQuest",{quest=q,island=i,sea=S.Sea})end,5)secL("Level",6)mkSl("Target Level",1,3000,S.Level,function(v)S.Level=math.floor(v)fire("Farm","setLevel",{value=S.Level})end,7)secL("Nearest",8)mkTg("Auto Farm Nearest","AFN",false,function(on)fire("Farm",on and"start"or"stop",{mode="nearest",enable=on})end,9)secL("Auto Farm",10)local o=11 local function ft(n,rn,ac)mkTg(n,rn,false,function(on)fire(rn or"Farm",ac or(on and"start"or"stop"),{enable=on})Nf.Push(on and"SUCCESS"or"INFO",n,on and"ON"or"OFF",2)end,o)o=o+1 end ft("Auto Farm Level","Farm","start")ft("Auto Factory","Farm","start")ft("Auto Farm Ectoplasm","Farm","start")ft("Auto Accept Quest","Quest","start")secL("Combat",o)o=o+1 local function ct(n,k)mkTg(n,"C_"..k,false,function(on)Cb:set(k,on)fire("Combat",n,{enable=on})end,o)o=o+1 end ct("Auto Haki","Haki")ct("Auto Ken","Ken")ct("Auto Attack","Attack")mkTg("Auto Quest Combat","AQC",false,function(on)if on then Cb:go()else Cb:stop()end end,o)end
	TBU["Chest"]=function()secL("Chest Farm",1)mkTg("Auto Farm Chest [Tween]","AC",false,function(on)fire("Chest",on and"start"or"stop",{enable=on})Nf.Push(on and"SUCCESS"or"INFO","Auto Chest",on and"ON"or"OFF",2)end,2)mkTg("Auto Open Chest [Instant]","AOC",false,function(on)fire("Chest",on and"start"or"stop",{mode="instant",enable=on})end,3)mkTg("Auto Collect Chest Item","ACCI",false,function(on)fire("Chest","collectItem",{enable=on})end,4)mkTg("Stop When Get Item in Chest","CSI",false,function(on)fire("Chest","stopWhenItem",{enable=on})end,5)secL("Chest Filter",10)mkDd("Chest Type",{"All Chests","Common Chest","Rare Chest","Legendary Chest","Event Chest"},function(v)fire("Chest","setType",{type=v})end,11,"ChestType")mkDd("Chest Priority",{"Nearest First","Rare First","Legendary First","Value First"},function(v)fire("Chest","setPriority",{priority=v})end,12,"ChestPriority")secL("Chest Area",20)mkDd("Area Filter",{"Current Island","All Island","All Sea","Custom Area"},function(v)fire("Chest","setArea",{area=v})end,21,"ChestArea")mkSl("Max Chest Range",50,500,150,function(v)fire("Chest","setRange",{value=v})end,22)mkSl("Farm Speed",0.1,2.0,0.5,function(v)fire("Chest","setSpeed",{value=v})end,23)secL("Auto Action",30)mkTg("Auto Teleport to Chest","ATC",false,function(on)fire("Chest","teleport",{enable=on})end,31)mkTg("Auto Tween to Chest","ATwC",false,function(on)fire("Chest","tween",{enable=on})end,32)mkTg("Skip Opened Chest","SOC",true,function(on)fire("Chest","skipOpened",{enable=on})end,33)secL("Stats",40)local cl=U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Text="Chests Opened: 0",TextColor3=T.Tx,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,-8,0,20)},CS)cl.LayoutOrder=41 local il=U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Text="Last Item: -",TextColor3=T.Tx,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,-8,0,20)},CS)il.LayoutOrder=42 local cr=R("Chest")if cr then CM:add(cr.OnClientEvent:Connect(function(k,d)if k=="count"then cl.Text="Chests Opened: "..tostring(d)elseif k=="lastItem"then il.Text="Last Item: "..tostring(d)end end))end end
	TBU["Boss"]=function()secL("Boss",1)mkDd("Select Boss",D.Bosses,function(v)S.Boss=v fire("Boss","select",{boss=v})Nf.Push("INFO","Boss",v,2)end,2,"Boss")mkBt("Update Boss List",function()fire("Boss","updateList",{})Nf.Push("SUCCESS","Boss","Updated",2)end,3)secL("Boss Combat",10)mkTg("Auto Kill Selected Boss","AKB",false,function(on)fire("Boss",on and"killSelected"or"stop",{boss=S.Boss,enable=on})end,11)mkTg("Auto Farm All Bosses","AFAB",false,function(on)fire("Boss",on and"farmAll"or"stop",{enable=on})end,12)mkTg("Take Boss Quest","TBQ",false,function(on)fire("Boss",on and"takeQuest"or"stop",{enable=on})end,13)end
	TBU["Material"]=function()secL("Material",1)local mn={"Select Material..."}for n in pairs(D.Mat)do table.insert(mn,n)end table.sort(mn)mkDd("Select Material",mn,function(v)if v=="Select Material..."then return end S.Mat=v local i=D.Mat[v]if i then Nf.Push("SUCCESS","Material",v.." | "..i[2].." | NPC: "..i[1],4)fire("Material","select",{material=v,npc=i[1],island=i[2],sea=i[3],dropType=i[4],reqLevel=i[5],respawn=i[6]})end TBU["Material"]()end,2,"Mat")secL("Info",10)local ip=mkI(11,130)if S.Mat then local i=D.Mat[S.Mat]if i then fI(ip,{"Material  : "..S.Mat,"Source NPC: "..i[1],"Location  : "..i[2].." (Sea "..i[3]..")","Drop Type : "..i[4],"Req Level : "..i[5],"Respawn   : "..i[6]})end else fI(ip,{"Select material."})end secL("Auto Farm",20)mkTg("Auto Farm Material","AFM",false,function(on)fire("Material",on and"start"or"stop",{material=S.Mat,enable=on})end,21)mkTg("Stop When Obtained","MSO",false,function(on)fire("Material","stopWhenObtained",{enable=on})end,22)end
	TBU["Sea"]=function()secL("Sea Config",1)mkDd("Select Sea",{"Sea 1","Sea 2","Sea 3"},function(v)S.Sea=tonumber(v:match("%d+"))or 1 TBU["Sea"]()end,2,"Sea")local curSea=S.Sea or 1 local sml={"Select Sea Mob..."}for _,m in ipairs(D.SeaMobs)do if m.sea==curSea then table.insert(sml,m.name.." ("..m.type.." · "..m.hp.." HP)")end end if #sml==1 then sml={"(No mob)"}end mkDd("Select Sea Mob",sml,function(v)if v=="Select Sea Mob..."or v=="(No mob)"then return end S.SeaMob=v Nf.Push("INFO","Sea Mob",v,3)fire("Sea","selectMob",{mob=v,sea=curSea})end,3,"SeaMob")secL("Sea Farm",10)mkTg("Auto Farm Sea","AFS",false,function(on)fire("Sea",on and"farm"or"stop",{enable=on,mob=S.SeaMob,sea=curSea})end,11)mkTg("Auto Destroy Boats","ADB",false,function(on)fire("Sea",on and"start"or"stop",{mode="boats",enable=on})end,12)mkTg("Auto Destroy Sea Beast","ADS",false,function(on)fire("Sea",on and"start"or"stop",{mode="seabeast",enable=on})end,13)mkTg("Auto Hunt Leviathan","AHL",false,function(on)fire("Sea",on and"start"or"stop",{mode="leviathan",enable=on})end,14)mkTg("Buy Boat","BB",false,function(on)fire("Sea",on and"start"or"stop",{mode="buyBoat",enable=on})end,15)mkTg("Auto No-Clip Boat","NCB",false,function(on)fire("Sea",on and"start"or"stop",{mode="noclip",enable=on})end,16)mkTg("Auto Destroy Rocks","ADR",false,function(on)fire("Sea",on and"start"or"stop",{mode="rocks",enable=on})end,17)mkSl("Boat Height",0,100,10,function(v)fire("Sea","boatHeight",{value=v})end,18)mkSl("Boat Speed",0,200,50,function(v)fire("Sea","boatSpeed",{value=v})end,19)end
	TBU["Quests / Items"]=function()secL("Secret Quest (Sea 1)",1)if S.Sea~=1 then U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamMedium,Text="Secret Quest hanya di Sea 1.",TextColor3=T.Wn,TextSize=12,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,-8,0,40)},CS).LayoutOrder=2 else local iS={}for _,q in ipairs(D.SQ)do iS[q.island]=true end local iL={"All Islands"}for n in pairs(iS)do table.insert(iL,n)end table.sort(iL)mkDd("Select Island",iL,function(v)S.SQI=(v=="All Islands")and nil or v TBU["Quests / Items"]()end,2,"SQI")local sel=S.SQI or"All Islands"local ql={"Select Quest..."}local qm={}for _,q in ipairs(D.SQ)do if sel=="All Islands"or q.island==sel then local lb=q.name.." @"..q.island table.insert(ql,lb)qm[lb]=q end end if #ql==1 then ql={"(Kosong)"}end mkDd("Select Quest",ql,function(v)if v=="Select Quest..."or v=="(Kosong)"then return end local q=qm[v]if q then S.SQ=q.name S.SQI=q.island Nf.Push("INFO","Secret",q.name.." @"..q.island,4)fire("Quest","selectSecret",{name=q.name,island=q.island})end end,3,"SQ")secL("Quest Info",4)local ip=mkI(5,80)if S.SQ then fI(ip,{"Quest : "..S.SQ,"Island: "..(S.SQI or"-")})else fI(ip,{"Pilih quest."})end mkBt("Start Selected Quest",function()if not S.SQ then Nf.Push("WARNING","Quest","Pilih dulu",2)return end fire("Quest","startSecret",{name=S.SQ,island=S.SQI})Nf.Push("INFO","Secret","Mulai: "..S.SQ,3)end,6)mkBt("Auto All Secret Quests",function()fire("Quest","startSecret",{auto_all=true})Nf.Push("INFO","Secret","Auto semua",3)end,7)mkBt("Stop Auto Secret",function()fire("Quest","stopSecret",{})Nf.Push("INFO","Secret","Stop",2)end,8)end secL("Boss Special",20)local o=21 local function bb(n,a)mkBt(n,function()fire("Quest",a,{enable=true})Nf.Push("INFO",n,"Started",2)end,o)o=o+1 end bb("Kill Cake Prince","killCakePrince")bb("Auto Spawn & Kill Dough King","spawnDoughKing")bb("Kill Soul Reaper","killSoulReaper")bb("Auto Spawn & Kill rip_indra","spawnIndra")secL("Weapon Grind",o)o=o+1 local function ib(n,a)mkBt(n,function()fire("Quest",a,{enable=true})Nf.Push("INFO",n,"Started",2)end,o)o=o+1 end ib("Auto Get Yama","getYama")ib("Auto Get Tushita","getTushita")ib("Auto Get Buddy Sword","getBuddySword")ib("Auto Get Soul Guitar","getSoulGuitar")ib("Auto Get Hallow Scythe","getHallowScythe")end
	TBU["Fruit / Raid"]=function()secL("Raid",1)mkDd("Select Chip",D.Chips,function(v)S.Chip=v fire("Raid","selectChip",{chip=v})end,2,"Chip")mkBt("Start Raid",function()fire("Raid","start",{})end,3)mkTg("AutoKillRaid","AKR",false,function(on)fire("Raid",on and"start"or"stop",{enable=on})end,4)secL("Fruit Roll & Store",10)mkBt("Rolled Fruit",function()fire("Raid","rolled",{})end,11)mkTg("Auto Store Fruit","ASF",false,function(on)if on then local function st()local ch=Plr.Character if not ch then return end for _,t in ipairs(ch:GetChildren())do if t:IsA("Tool")and string.find(string.lower(t.Name),"fruit")then fire("Fruit","store",{item=t.Name,from="character"})Nf.Push("SUCCESS","Stored",t.Name,1.5)task.wait(0.3)end end local bp=Plr:FindFirstChild("Backpack")if bp then for _,t in ipairs(bp:GetChildren())do if t:IsA("Tool")and string.find(string.lower(t.Name),"fruit")then fire("Fruit","store",{item=t.Name,from="backpack"})Nf.Push("SUCCESS","Stored",t.Name,1.5)task.wait(0.3)end end end end task.spawn(function()while S.Tg.ASF do U.tr(st)task.wait(5)end end)Nf.Push("SUCCESS","Store Fruit","ON",2)else fire("Fruit","store_stop",{})Nf.Push("INFO","Store Fruit","OFF",2)end end,12)end
	TBU["Fishing"]=function()secL("Fishing",1)mkTg("Auto Fish","AF",false,function(on)fire("Fishing",on and"start"or"stop",{enable=on})end,2)mkTg("Auto Cast","ACa",false,function(on)fire("Fishing",on and"start"or"stop",{mode="cast",enable=on})end,3)end
	TBU["Status"]=function()secL("Server Status",1)local fl=U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Text="Fruit Spawn: -",TextColor3=T.Tx,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,-8,0,20)},CS)fl.LayoutOrder=2 local ml=U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Text="Map Check: -",TextColor3=T.Tx,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,-8,0,20)},CS)ml.LayoutOrder=3 local tl=U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Text="Server Time: -",TextColor3=T.Tx,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,-8,0,20)},CS)tl.LayoutOrder=4 mkBt("Check Entire Map",function()fire("Misc","checkMap",{})Nf.Push("INFO","Map","Checking",2)end,5)local sr=R("Misc")if sr then CM:add(sr.OnClientEvent:Connect(function(k,d)if k=="fruitStatus"then fl.Text="Fruit Spawn: "..(d and"Yes"or"No")elseif k=="mapStatus"then ml.Text="Map Check: "..tostring(d)end end))end task.spawn(function()while Gui.Parent do tl.Text="Server Time: "..os.date("%H:%M:%S")task.wait(1)end end)end
	TBU["PvP"]=function()secL("PvP",1)local pn={"None"}for _,p in ipairs(Players:GetPlayers())do if p~=Plr then table.insert(pn,p.Name)end end mkDd("Select Player",pn,function(v)S.Plr=v fire("PvP","select",{player=v})end,2,"Plr")mkTg("Aimbot","Aimb",false,function(on)fire("PvP",on and"start"or"stop",{enable=on})end,3)mkBt("Teleport to Player",function()fire("PvP","teleport",{player=S.Plr})end,4)mkTg("Auto Skill","ASk",false,function(on)fire("PvP",on and"start"or"stop",{enable=on})end,5)end
	TBU["Stats"]=function()secL("Stat Allocation",1)mkTg("Start Add Stats","SAS",false,function(on)fire("Stats",on and"start"or"stop",{enable=on})end,2)mkSl("Melee",0,100,0,function(v)fire("Stats","melee",{value=v})end,3)mkSl("Sword",0,100,0,function(v)fire("Stats","sword",{value=v})end,4)mkSl("Gun",0,100,0,function(v)fire("Stats","gun",{value=v})end,5)mkSl("Defense",0,100,0,function(v)fire("Stats","defense",{value=v})end,6)mkSl("Blox Fruit %",0,100,0,function(v)fire("Stats","fruit",{value=v})end,7)end
	TBU["Misc"]=function()secL("Server",1)U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Text="Job ID: "..game.JobId,TextColor3=T.Tx,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Size=UDim2.new(1,-8,0,32)},CS).LayoutOrder=2 mkBt("Copy Job ID",function()if setclipboard then pcall(setclipboard,game.JobId)end Nf.Push("SUCCESS","Job ID","Copied",2)end,3)local jb=U.mk("TextBox",{BackgroundColor3=T.Bg2,BorderSizePixel=0,ClearTextOnFocus=false,PlaceholderText="Enter Job ID",PlaceholderColor3=T.Tx2,TextColor3=T.Tx,Font=Enum.Font.Gotham,TextSize=12,Text="",Size=UDim2.new(1,-8,0,30)},CS)U.cr(jb,6)U.st(jb)jb.LayoutOrder=4 mkBt("Join Job ID",function()local id=jb.Text if id and #id>=8 then pcall(function()TS:TeleportToPlaceInstance(game.PlaceId,id,Plr)end)Nf.Push("INFO","Job ID","Joining "..id,2)else Nf.Push("WARNING","Job ID","Invalid",2)end end,5)secL("Utility",10)mkBt("Redeem All Code",function()Nf.Push("INFO","Redeem","Kirim "..#D.Codes.." kode",3)for i,c in ipairs(D.Codes)do fire("Misc","redeem",{code=c})Nf.Push("INFO","Redeem "..i.."/"..#D.Codes,c,1.5)task.wait(0.8)end Nf.Push("SUCCESS","Redeem","Selesai",4)end,11)mkTg("Anti AFK","AAF",false,function(on)fire("Misc",on and"start"or"stop",{enable=on})end,12)mkTg("No Clip","NC",false,function(on)fire("Misc",on and"start"or"stop",{mode="noclip",enable=on})end,13)mkTg("Infinite Jump","IJ",false,function(on)fire("Misc",on and"start"or"stop",{mode="infjump",enable=on})end,14)mkTg("Auto Attack","AAM",false,function(on)fire("Combat",on and"start"or"stop",{enable=on})Cb:set("Attack",on)end,15)local fp=U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Text="FPS: -",TextColor3=T.Tx,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,-8,0,20)},CS)fp.LayoutOrder=16 local fr,ls=0,tick()CM:add(RunService.RenderStepped:Connect(function()fr=fr+1 if tick()-ls>=1 then fp.Text="FPS: "..fr fr=0 ls=tick()end end))end

	local function oT(n)cT=n clrC()if TBU[n]then U.tr(TBU[n],function(e)Nf.Push("ERROR","Tab",tostring(e),3)end)else U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.Gotham,Text="Coming soon...",TextColor3=T.Tx2,TextSize=13,Size=UDim2.new(1,-8,0,20)},CS)end for _,b in ipairs(SSb:GetChildren())do if b:IsA("TextButton")then local a=(b.Name=="Tab_"..n)U.tn(b,TweenInfo.new(0.15),{BackgroundColor3=a and T.Pr or T.Bg2,TextColor3=a and T.Tx or T.Tx2})end end end
	for i,t in ipairs(CFG.Tabs)do local b=U.mk("TextButton",{Name="Tab_"..t,BackgroundColor3=T.Bg2,BorderSizePixel=0,Text="  "..t,TextColor3=T.Tx2,Font=Enum.Font.GothamMedium,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,Size=UDim2.new(1,-4,0,32)},SSb)b.LayoutOrder=i U.cr(b,6)b.MouseEnter:Connect(function()if cT~=t then U.tn(b,TweenInfo.new(0.12),{BackgroundColor3=T.Pn})end end)b.MouseLeave:Connect(function()if cT~=t then U.tn(b,TweenInfo.new(0.12),{BackgroundColor3=T.Bg2})end end)b.MouseButton1Click:Connect(function()oT(t)end)end
	oT("Discord")
	SR:GetPropertyChangedSignal("Text"):Connect(function()local q=string.lower(SR.Text)if q==""then if cT then oT(cT)end return end local rs={}for _,e in ipairs(reg)do local tn=e[1]and string.lower(e[1])or""local fn=e[2]and string.lower(e[2])or""if string.find(tn,q,1,true)or string.find(fn,q,1,true)then table.insert(rs,e)end end for _,c in ipairs(CS:GetChildren())do if c:IsA("GuiObject")then c.Visible=false end end if #rs==0 then U.mk("TextLabel",{BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text="Feature not found",TextColor3=T.Er,TextSize=13,Size=UDim2.new(1,-8,0,24)},CS).Visible=true return end for _,e in ipairs(rs)do local o=e[3]if o and o.Parent then o.Visible=true end end end)
	local isO=true local function setW(op)isO=op U.tn(M,TweenInfo.new(0.28,Enum.EasingStyle.Quart),{Size=op and UDim2.fromOffset(CFG.W,CFG.H)or UDim2.fromOffset(0,0)})end
	Ob.MouseButton1Click:Connect(function()if isO then setW(false)else setW(true)end end)
	ClsBtn.MouseButton1Click:Connect(function()setW(false)end)
	MinBtn.MouseButton1Click:Connect(function()setW(false)end)
	local si=3 ScaleBtn.MouseButton1Click:Connect(function()si=si%#CFG.SO+1 Sc.Scale=CFG.SO[si]Nf.Push("INFO","UI Scale",tostring(math.floor(CFG.SO[si]*100)).."%",1.5)end)
	do local d,sP,st TB.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=true sP=i.Position st=M.Position end end)UIS.InputChanged:Connect(function(i)if not d then return end if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then local dl=i.Position-sP M.Position=UDim2.new(st.X.Scale,st.X.Offset+dl.X,st.Y.Scale,st.Y.Offset+dl.Y)end end)UIS.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=false end end)end
	do local d,sP,st Ob.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=true sP=i.Position st=Ob.Position end end)UIS.InputChanged:Connect(function(i)if not d then return end if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then local dl=i.Position-sP Ob.Position=UDim2.new(st.X.Scale,st.X.Offset+dl.X,st.Y.Scale,st.Y.Offset+dl.Y)end end)UIS.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=false end end)end
	if UIS.TouchEnabled then SSb.ScrollingDirection=Enum.ScrollingDirection.Y CS.ScrollingDirection=Enum.ScrollingDirection.Y end
	Plr.CharacterRemoving:Connect(function()Cb:stop()end)
	Nf.Push("SUCCESS","SysxHub","Loaded v"..Br.Ver,3)
end
