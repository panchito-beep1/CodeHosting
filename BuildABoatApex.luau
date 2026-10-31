local Axiom = loadstring(game:HttpGet("https://raw.githubusercontent.com/panchito-beep1/Axiom/refs/heads/main/AxiomV6"))()

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local TPS = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local win = Axiom.new({
    Title = "Apex | Build a boat for treasure | v1.0",
    Size = UDim2.new(0, 520, 0, 480)
})

win:EnableStateSaving({ Folder = "OVERKILL_BABFT", Filename = "config.json" })

local farmTab = win:AddTab({ Name = "Farm" })
local playerTab = win:AddTab({ Name = "Player" })
local visualTab = win:AddTab({ Name = "Visual" })
local localPlayerTab = win:AddTab({ Name = "LocalPlayer" })
local shopTab = win:AddTab({ Name = "Shop" })

local wm = win:CreateWatermark({
    Text = "Loading...",
    TextColor = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Position = UDim2.new(0, 10, 0, 10)
})

local fps = 60
local frameCount = 0
local timeElapsed = 0

RunService.Heartbeat:Connect(function(deltaTime)
    frameCount += 1
    timeElapsed += deltaTime
    if timeElapsed >= 0.5 then
        fps = math.round(frameCount / timeElapsed)
        frameCount = 0
        timeElapsed = 0
    end
end)

local player = Players.LocalPlayer

task.spawn(function()
    while task.wait(0.5) do
        local ping = player:GetNetworkPing() * 1000
        wm:Update({ Text = string.format("FPS: %d | Ping: %.0f ms", fps, ping) })
    end
end)

getgenv().BaconHub = getgenv().BaconHub or {}
local Hub = getgenv().BaconHub

if Hub.FarmWaitTime == nil then Hub.FarmWaitTime = 2 end
if Hub.AutoClaimEnabled == nil then Hub.AutoClaimEnabled = true end
if Hub.GoldFarmLaps == nil then Hub.GoldFarmLaps = 0 end
Hub.GoldFarmActive = false
Hub.GoldBlockFarmActive = false
Hub.AutoBuyOnLaps = false
Hub.LapThreshold = 3
Hub.AutoBuyLapItem = "Common Chest"
Hub.AutoBuyLapAmount = 1

local POSITIONS = {
	CFrame.new(-42, 40, 1254),
	CFrame.new(-45, 40, 1518),
	CFrame.new(-58, 40, 2310),
	CFrame.new(-60, 40, 3046),
	CFrame.new(-52, 40, 3829),
	CFrame.new(-37, 40, 4490),
	CFrame.new(-64, 40, 5324),
	CFrame.new(-53, 40, 6078),
	CFrame.new(-54, 40, 6830),
	CFrame.new(-45, 105, 7702)
}

local function TeleportLoop(character, cf)
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local conn = RunService.Heartbeat:Connect(function()
		local liveHRP = character:FindFirstChild("HumanoidRootPart")
		if liveHRP then
			liveHRP.CFrame = cf
		end
	end)
	return conn
end

local function GetBuyRemote()
	for _, container in ipairs({Workspace, ReplicatedStorage}) do
		local remote = container:FindFirstChild("ItemBoughtFromShop")
		if remote then
			return remote
		end
	end
	return nil
end

local function RunGoldCycle(firstCycle)
	local cancelled = false
	local tpConn = nil
	for i, cf in ipairs(POSITIONS) do
		if not Hub.GoldFarmActive then cancelled = true; break end
		local character = Players.LocalPlayer.Character
		if not character then cancelled = true; break end
		tpConn = TeleportLoop(character, cf)
		if not firstCycle and i == 1 then task.wait(5) end
		local ok, err = pcall(task.wait, Hub.FarmWaitTime)
		if not ok then
			if tostring(err):find("cancelled") then cancelled = true end
			if tpConn then tpConn:Disconnect(); tpConn = nil end
			break
		end
		if tpConn then tpConn:Disconnect(); tpConn = nil end
		if Hub.AutoClaimEnabled then
			pcall(function() Workspace.ClaimRiverResultsGold:FireServer() end)
		end
	end
	if not cancelled and Hub.GoldFarmActive then
		Hub.GoldFarmLaps = Hub.GoldFarmLaps + 1
		
		if Hub.AutoBuyOnLaps and Hub.GoldFarmLaps >= Hub.LapThreshold then
			local remote = GetBuyRemote()
			if remote then
				local namesToTry = {Hub.AutoBuyLapItem, Hub.AutoBuyLapItem:gsub(" ", "")}
				local purchased = false
				for _, name in ipairs(namesToTry) do
					local success = pcall(function()
						remote:InvokeServer(name, Hub.AutoBuyLapAmount)
					end)
					if success then
						purchased = true
						local qty = tostring(Hub.AutoBuyLapAmount)
						win:Notify({ Title = "Lap Auto-Buy", Description = "Bought " .. qty .. "x " .. name, Type = "success" })
						break
					end
				end
				if not purchased then
					win:Notify({ Title = "Lap Auto-Buy", Description = "Purchase failed.", Type = "error" })
				end
			else
				win:Notify({ Title = "Lap Auto-Buy", Description = "Remote not found!", Type = "error" })
			end
			Hub.GoldFarmLaps = 0
		end
		local character = Players.LocalPlayer.Character
		if character then pcall(function() character:BreakJoints() end) end
	end
	if tpConn then tpConn:Disconnect() end
end

local function LaunchGoldCycle(firstCycle)
	if Hub.GoldFarmThread then
		task.cancel(Hub.GoldFarmThread)
		Hub.GoldFarmThread = nil
	end
	local newThread = task.spawn(function()
		pcall(RunGoldCycle, firstCycle)
		if Hub.GoldFarmThread == newThread then Hub.GoldFarmThread = nil end
	end)
	Hub.GoldFarmThread = newThread
end

local function StartGoldFarm()
	if Hub.GoldFarmActive then return end
	if Hub.GoldBlockFarmActive then StopGoldBlockFarm() end
	Hub.GoldFarmActive = true
	if Hub.GoldFarmThread then
		task.cancel(Hub.GoldFarmThread)
		Hub.GoldFarmThread = nil
	end
	LaunchGoldCycle(true)
	if Hub.GoldFarmConnection then Hub.GoldFarmConnection:Disconnect() end
	Hub.GoldFarmConnection = Players.LocalPlayer.CharacterAdded:Connect(function(char)
		if not Hub.GoldFarmActive then return end
		repeat task.wait() until char:FindFirstChild("HumanoidRootPart")
		task.wait(0.5)
		LaunchGoldCycle(false)
	end)
	win:Notify({ Title = "Gold Farm", Description = "Started", Type = "success" })
end

local function StopGoldFarm()
	Hub.GoldFarmActive = false
	if Hub.GoldFarmThread then task.cancel(Hub.GoldFarmThread); Hub.GoldFarmThread = nil end
	if Hub.GoldFarmConnection then Hub.GoldFarmConnection:Disconnect(); Hub.GoldFarmConnection = nil end
	local char = Players.LocalPlayer.Character
	if char then pcall(function() char:BreakJoints() end) end
	win:Notify({ Title = "Gold Farm", Description = "Stopped", Type = "warn" })
end

local function RunGoldBlockCycle()
	local p = Players.LocalPlayer
	local character = p.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end

	Workspace.ClaimRiverResultsGold:FireServer()
	task.wait(0.1)

	local root = character.HumanoidRootPart
	local lastCFrame = root.CFrame
	root.Anchored = false
	root.CFrame = CFrame.new(-45, 75, 1450)

	local plat = Instance.new("Part")
	plat.Parent = workspace
	plat.Anchored = true
	plat.Transparency = 1
	plat.CanCollide = true
	plat.Size = Vector3.new(10, 1, 10)
	plat.CFrame = CFrame.new(root.Position - Vector3.new(0, 3, 0))

	local start = tick()
	while tick() - start < 5 do
		if not Hub.GoldBlockFarmActive then plat:Destroy(); return end
		task.wait(0.1)
	end
	plat:Destroy()
	root.CFrame = lastCFrame
	task.wait(0.1)
	if not Hub.GoldBlockFarmActive then return end

	local chestTrigger = workspace.BoatStages.NormalStages.TheEnd.GoldenChest.Trigger
	chestTrigger.CFrame = root.CFrame
	task.wait(1)
	chestTrigger.CFrame = CFrame.new(-55.7065125, -358.739624, 9492.35645, 0,0,-1,0,1,0,1,0,0)

	local timer = 0
	while timer < 15 and not p.PlayerGui:FindFirstChild("NoChestAnimation") do
		if not Hub.GoldBlockFarmActive then return end
		task.wait(0.1)
		timer += 0.1
	end
	if timer > 10 and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
		p.Character.HumanoidRootPart.CFrame = CFrame.new(-56, -339, 9486)
	end
	if not Hub.GoldBlockFarmActive then return end

	timer = 0
	while timer < 60 and p.PlayerGui:FindFirstChild("RiverResultsGui") do
		if not Hub.GoldBlockFarmActive then return end
		task.wait(0.5)
		timer += 0.5
	end
	timer = 0
	while timer < 60 do
		if not Hub.GoldBlockFarmActive then return end
		local gui = p.PlayerGui:FindFirstChild("RiverResultsGui")
		if gui and gui:FindFirstChild("Frame") and not gui.Frame.Visible then break end
		task.wait(0.5)
		timer += 0.5
	end
end

local function LaunchGoldBlockLoop()
	if Hub.GoldBlockFarmThread then task.cancel(Hub.GoldBlockFarmThread); Hub.GoldBlockFarmThread = nil end
	local loopThread = task.spawn(function()
		while Hub.GoldBlockFarmActive do
			local ok, err = pcall(RunGoldBlockCycle)
			if not ok then
				if err ~= "Task was cancelled" then
					warn("Gold Block Farm error: ", err)
				end
				break
			end
		end
	end)
	Hub.GoldBlockFarmThread = loopThread
end

function StopGoldBlockFarm()
	Hub.GoldBlockFarmActive = false
	if Hub.GoldBlockFarmThread then task.cancel(Hub.GoldBlockFarmThread); Hub.GoldBlockFarmThread = nil end
	if Hub.GoldBlockFarmConnection then Hub.GoldBlockFarmConnection:Disconnect(); Hub.GoldBlockFarmConnection = nil end
	win:Notify({ Title = "Gold Block Farm", Description = "Stopped", Type = "warn" })
end

local function StartGoldBlockFarm()
	if Hub.GoldBlockFarmActive then return end
	if Hub.GoldFarmActive then StopGoldFarm() end
	Hub.GoldBlockFarmActive = true
	LaunchGoldBlockLoop()
	if Hub.GoldBlockFarmConnection then Hub.GoldBlockFarmConnection:Disconnect() end
	Hub.GoldBlockFarmConnection = Players.LocalPlayer.CharacterAdded:Connect(function(char)
		if not Hub.GoldBlockFarmActive then return end
		repeat task.wait() until char:FindFirstChild("HumanoidRootPart")
		task.wait(0.5)
		LaunchGoldBlockLoop()
	end)
	win:Notify({ Title = "Gold Block Farm", Description = "Started", Type = "success" })
end

local GoldFarmCheckbox = farmTab:AddCheckbox({ Text = "Gold Farm", Default = false, Callback = function(state)
	if state then StartGoldFarm() else StopGoldFarm() end
end })

local GoldBlockFarmCheckbox = farmTab:AddCheckbox({ Text = "Gold Block Farm", Default = false, Callback = function(state)
	if state then StartGoldBlockFarm() else StopGoldBlockFarm() end
end })

local GoldLabel = farmTab:AddLabel({ Text = "Gold: Loading..." })
task.spawn(function()
	while true do
		local amount = Players.LocalPlayer.PlayerGui:FindFirstChild("GoldGui")
		if amount then amount = amount:FindFirstChild("Frame") and amount.Frame:FindFirstChild("Amount") end
		pcall(function() GoldLabel:SetText("Gold: " .. (amount and amount.Text or "?")) end)
		task.wait(0.1)
	end
end)

local GoldBlocksLabel = farmTab:AddLabel({ Text = "Gold Blocks: Loading..." })
task.spawn(function()
	while true do
		local inv = Players.LocalPlayer.PlayerGui:FindFirstChild("BuildGui")
		local amtText = nil
		if inv then
			local sf = inv:FindFirstChild("InventoryFrame") and inv.InventoryFrame:FindFirstChild("ScrollingFrame")
			if sf then
				local bf = sf:FindFirstChild("BlocksFrame")
				if bf then
					local gb = bf:FindFirstChild("GoldBlock")
					if gb then amtText = gb:FindFirstChild("AmountText") end
				end
			end
		end
		pcall(function() GoldBlocksLabel:SetText("Gold Blocks: " .. (amtText and amtText.Text or "No gold blocks found")) end)
		task.wait(0.1)
	end
end)

local LapLabel = farmTab:AddLabel({ Text = "Laps: " .. Hub.GoldFarmLaps })
task.spawn(function()
	while true do
		pcall(function() LapLabel:SetText("Laps: " .. tostring(Hub.GoldFarmLaps)) end)
		task.wait(0.5)
	end
end)

farmTab:AddButton({ Text = "Stop All Farms", Callback = function()
	if Hub.GoldFarmActive then StopGoldFarm() end
	if Hub.GoldBlockFarmActive then StopGoldBlockFarm() end
	GoldFarmCheckbox:SetValue(false)
	GoldBlockFarmCheckbox:SetValue(false)
	win:Notify({ Title = "Stopped", Description = "All farms halted.", Type = "info" })
end })

farmTab:AddSection({ Text = "Settings" })
farmTab:AddCheckbox({ Text = "Auto Claim", Default = Hub.AutoClaimEnabled, Callback = function(state) Hub.AutoClaimEnabled = state end })
farmTab:AddSlider({ Text = "Gold Farm Wait (s)", Min = 1, Max = 10, Default = Hub.FarmWaitTime, Callback = function(value) Hub.FarmWaitTime = value end })
farmTab:AddKeybindPicker({ Text = "Toggle Gold Farm", Default = "G", Toggle = true, DefaultState = false, Callback = function(key, state)
	if state then StartGoldFarm() else StopGoldFarm() end
	GoldFarmCheckbox:SetValue(state)
end })

farmTab:AddLabel({ Text = "Run only ONE farming method at a time.", Color = Color3.fromRGB(255, 80, 80) })

farmTab:AddButton({ Text = "Reset Lap Counter", Callback = function()
	Hub.GoldFarmLaps = 0
	win:Notify({ Title = "Laps Reset", Description = "Lap counter set to 0", Type = "success" })
end })

playerTab:AddLabel({ Text = "Select A Team To Teleport To", Color = Color3.fromRGB(128,128,128) })
playerTab:AddSearchableDropdown({ Text = "Select Zone To TP", Items = {"White","Red","Blue","Purple","Black","Green","Yellow"}, Default = "Blue", Callback = function(selected)
	local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")
	local positions = {
		White = Vector3.new(-49, -10, -500), Red = Vector3.new(375, -10, -65),
		Blue = Vector3.new(375, -10, 300), Purple = Vector3.new(375, -10, 647),
		Black = Vector3.new(-483, -10, -294), Green = Vector3.new(-483, -10, 294),
		Yellow = Vector3.new(-483, -10, 640)
	}
	local pos = positions[selected]
	if pos then root.CFrame = CFrame.new(pos) end
end })

local flyEnabled = false
local flySpeed = 60
local flyConn, bodyGyro, bodyVelocity

local function stopFly()
	flyEnabled = false
	if flyConn then flyConn:Disconnect(); flyConn = nil end
	local char = Players.LocalPlayer.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.PlatformStand = false end
		if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
		if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
	end
end

playerTab:AddCheckbox({ Text = "Enable Fly", Default = false, Callback = function(state)
	flyEnabled = state
	local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end

	if state then
		hum.PlatformStand = true
		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(1e6,1e6,1e6)
		bodyGyro.D = 500
		bodyGyro.P = 1e5
		bodyGyro.Parent = root
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(1e6,1e6,1e6)
		bodyVelocity.Velocity = Vector3.zero
		bodyVelocity.Parent = root

		flyConn = RunService.RenderStepped:Connect(function()
			if not flyEnabled then return end
			local cam = workspace.CurrentCamera
			local moveDir = Vector3.zero
			if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
			if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0,1,0) end
			bodyVelocity.Velocity = moveDir * flySpeed
			bodyGyro.CFrame = cam.CFrame
		end)
	else
		stopFly()
	end
end })
playerTab:AddSlider({ Text = "Fly Speed", Min = 10, Max = 1000, Default = 60, Callback = function(value) flySpeed = value end })

playerTab:AddLabel({ Text = "Select a Chest To Auto Buy", Color = Color3.fromRGB(128,128,128) })
playerTab:AddSearchableDropdown({ Text = "Select Chest", Items = chestList, Default = "Common Chest", Callback = function(selected)
	_G.SelectedChest = selected or "Common Chest"
end })
playerTab:AddCheckbox({ Text = "Auto Buy Selected", Default = false, Callback = function(state)
	_G.AutoBuy = state
	if state then
		task.spawn(function()
			while _G.AutoBuy do
				pcall(function()
					local remote = GetBuyRemote()
					if remote then
						remote:InvokeServer(_G.SelectedChest, 1)
					end
				end)
				task.wait(1)
			end
		end)
	end
end })

visualTab:AddLabel({ Text = "Edit How Much Money You Have (visual)", Color = Color3.fromRGB(128,128,128) })
visualTab:AddTextBox({ Text = "Gold", Placeholder = "Enter Gold", Default = "...", Callback = function(text)
	pcall(function()
		Players.LocalPlayer.PlayerGui.GoldGui.Frame.Amount.Text = text
	end)
end })
visualTab:AddLabel({ Text = "Remember These Are Client-Side ONLY", Color = Color3.fromRGB(128,128,128) })

visualTab:AddButton({ Text = "Remove Water (Collision)", Callback = function()
	for _,v in ipairs(workspace:GetDescendants()) do if v.Name == "Water" then v:Destroy() end end
	win:Notify({ Title = "Ocean Dried", Description = "Water removed client-side.", Type = "success" })
end })
visualTab:AddButton({ Text = "Clear Obstacles (Rocks)", Callback = function()
	for _,v in ipairs(workspace:GetDescendants()) do
		if v.Name == "Rock" or string.find(v.Name, "Obstacle") then v:Destroy() end
	end
	win:Notify({ Title = "Cleared", Description = "Obstacles removed.", Type = "success" })
end })
visualTab:AddButton({ Text = "Infinite Block Health (Local)", Callback = function()
	win:Notify({ Title = "Reinforced", Description = "Visual integrity increased.", Type = "info" })
end })

local RemoveHazards = false
visualTab:AddLabel({ Text = "Extrem-er version (LAGGY)", Color = Color3.fromRGB(128,128,128) })
visualTab:AddCheckbox({ Text = "Remove Stage Obstacles", Default = false, Callback = function(state)
	RemoveHazards = state
	if not state then win:Notify({ Title = "Obstacle Remover", Description = "Disabled.", Type = "warn" }); return end
	win:Notify({ Title = "Obstacle Remover", Description = "Enabled.", Type = "success" })
	task.spawn(function()
		local ExactNames = {
			DestroyBoatPart = true, Rock = true, Rock1 = true, Rock2 = true,
			Rock3 = true, Rock4 = true, Rocks = true, SpawnRocks = true,
			PointedRocks = true, FireRock = true, FallRock1 = true, FallRock2 = true,
			Fish = true, Hotdog = true, Pretzel = true, CottonCandy = true,
			Potion = true, Acid = true, Chip = true, Traces = true,
			Resister = true, Resister2 = true, Circuit = true,
			LED1 = true, LED2 = true, LED3 = true,
			Tape = true, Ticket = true, Pencil = true, Brush = true,
			Paint = true, Crystal = true, CrystalSpike = true
		}
		for i=1,50 do ExactNames["Rock"..i] = true; ExactNames["Fish"..i] = true
			ExactNames["Potion"..i] = true; ExactNames["ZapPart"..i] = true
			ExactNames["Crystal"..i] = true; ExactNames["LED"..i] = true end
		local Keywords = {"rock","fish","cotton","candy","pretzel","hotdog","potion","acid","crystal","spike","tape","ticket","pencil","brush","paint","gear","zap","laser","fire","bomb","missile","cannon","arrow","spear","thorn","vine","trap","mine","destroyboatpart"}
		local function ShouldDestroy(obj)
			local name = obj.Name
			if ExactNames[name] then return true end
			local lower = name:lower():gsub("[%s_%-]","")
			for _,kw in ipairs(Keywords) do
				if lower:find(kw,1,true) then return true end
			end
			return false
		end
		while RemoveHazards do
			local boatStages = workspace:FindFirstChild("BoatStages")
			if boatStages then
				for _,folderName in ipairs({"NormalStages","OtherStages"}) do
					local folder = boatStages:FindFirstChild(folderName)
					if folder then
						for _,stage in ipairs(folder:GetChildren()) do
							for _,obj in ipairs(stage:GetDescendants()) do
								if ShouldDestroy(obj) then pcall(function() obj:Destroy() end) end
							end
						end
					end
				end
			end
			task.wait(0.2)
		end
	end)
end })

local antiAFKConn = nil
visualTab:AddCheckbox({ Text = "Anti-AFK", Default = false, Callback = function(state)
	if state then
		antiAFKConn = Players.LocalPlayer.Idled:Connect(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
	else
		if antiAFKConn then antiAFKConn:Disconnect(); antiAFKConn = nil end
	end
end })

visualTab:AddCheckbox({ Text = "Server Hop", Default = false, Callback = function(state)
	if not state then return end
	local placeId = game.PlaceId
	local url = "https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
	local function listServers(cursor)
		local raw = game:HttpGet(url .. (cursor and "&cursor="..cursor or ""))
		return HttpService:JSONDecode(raw)
	end
	local server, next
	repeat
		local servers = listServers(next)
		server = servers.data[math.random(1, #servers.data)]
		next = servers.nextPageCursor
	until server
	TPS:TeleportToPlaceInstance(placeId, server.id, Players.LocalPlayer)
end })

localPlayerTab:AddSlider({ Text = "Speed", Min = 16, Max = 1000, Default = 16, Callback = function(value)
	local char = Players.LocalPlayer.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = value end
	end
end })
localPlayerTab:AddSlider({ Text = "JumpPower", Min = 50, Max = 1000, Default = 50, Callback = function(value)
	local char = Players.LocalPlayer.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.JumpPower = value end
	end
end })
localPlayerTab:AddSlider({ Text = "Gravity", Min = 196.2, Max = 1000, Default = 196.2, Callback = function(value)
	workspace.Gravity = value
end })

localPlayerTab:AddCheckbox({ Text = "Auto-Equip TP Tool", Default = false, Callback = function(state)
	Hub.AutoEquipTPTool = state
	if state then
		local function giveTool()
			local p = Players.LocalPlayer
			if p.Backpack:FindFirstChild("Tp tool") or (p.Character and p.Character:FindFirstChild("Tp tool")) then
				return
			end
			local mouse = p:GetMouse()
			local tool = Instance.new("Tool")
			tool.RequiresHandle = false
			tool.Name = "Tp tool"
			tool.Activated:Connect(function()
				if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
					local pos = mouse.Hit.Position + Vector3.new(0,2.5,0)
					p.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
				end
			end)
			tool.Parent = p.Backpack
		end
		giveTool()
		if Hub.TPToolConnection then Hub.TPToolConnection:Disconnect() end
		Hub.TPToolConnection = Players.LocalPlayer.CharacterAdded:Connect(function()
			task.wait(1)
			giveTool()
		end)
	else
		if Hub.TPToolConnection then
			Hub.TPToolConnection:Disconnect()
			Hub.TPToolConnection = nil
		end
	end
end })

localPlayerTab:AddButton({ Text = "Give TP Tool Now", Callback = function()
	local p = Players.LocalPlayer
	local mouse = p:GetMouse()
	local tool = Instance.new("Tool")
	tool.RequiresHandle = false
	tool.Name = "Tp tool"
	tool.Activated:Connect(function()
		if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local pos = mouse.Hit.Position + Vector3.new(0,2.5,0)
			p.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
		end
	end)
	tool.Parent = p.Backpack
	win:Notify({ Title = "Tool", Description = "TP tool added to backpack.", Type = "success" })
end })

localPlayerTab:AddButton({ Text = "Infinite Yield", Callback = function()
	loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end })

local noclipEnabled = false
local noclipConnection
localPlayerTab:AddLabel({ Text = "This Can Help Bypass Isolation Mode", Color = Color3.fromRGB(128,128,128) })
localPlayerTab:AddCheckbox({ Text = "Enable Noclip", Default = false, Callback = function(state)
	noclipEnabled = state
	if state then
		if noclipConnection then noclipConnection:Disconnect() end
		noclipConnection = RunService.Stepped:Connect(function()
			if noclipEnabled then
				local char = Players.LocalPlayer.Character
				if char then
					for _,part in ipairs(char:GetDescendants()) do
						if part:IsA("BasePart") then part.CanCollide = false end
					end
				end
			end
		end)
	else
		if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
		local char = Players.LocalPlayer.Character
		if char then
			for _,part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = true end
			end
		end
	end
end })

Players.LocalPlayer.CharacterAdded:Connect(function()
	if noclipEnabled then
		if noclipConnection then noclipConnection:Disconnect() end
		noclipConnection = RunService.Stepped:Connect(function()
			if noclipEnabled then
				local char = Players.LocalPlayer.Character
				if char then
					for _,part in ipairs(char:GetDescendants()) do
						if part:IsA("BasePart") then part.CanCollide = false end
					end
				end
			end
		end)
	end
end)

shopTab:AddLabel({ Text = "Some may stop working.", Color = Color3.fromRGB(128,128,128) })
local chestList = {"Common Chest", "Uncommon Chest", "Rare Chest", "Epic Chest", "Legendary Chest"}
local Blocks = {"WoodBlock","SmoothWoodBlock","GlassBlock","StoneBlock","FabricBlock","PlasticBlock","GrassBlock","SandBlock","RustedBlock","BouncyBlock","MetalBlock","ConcreteBlock","TitaniumBlock","CoalBlock","BricksBlock","MarbleBlock","IceBlock"}
local Components = {"BoatMotor","Car Parts","Plane Parts","LegacyCarPack","Parachutes","Shield Generators","Balloons","JetPacks","Switch","Button","LightBulb","Camera","CameraDome","Note","HingeBlocks","Delay","Pistons","Magnets","SensorBlock","Gate","DisplayBlock","RemoteController","Rope","Bar"}
local PVP = {"SticksOfTNT","SpikeTrap","Cannon","MiniGun","CannonTurret","SwordMount","GunMount","CannonMount","Harpoon","newSlotGold"}
local ExtrasBlocks = {"ConcreteRod","CornerWedge","RustedRod","StoneRod","TitaniumRod","Truss","MarbleRod","MetalRod","Wedge","WoodRod"}
local Especials = {"BigSwitch","BoxingGlove","BundlesOfPotions","MegaThruster","MountedCandyCaneSword","Portal","EasterJetpack","EggCannon","SnowballLauncher","SpookyThruster","StarBalloonBlock","StarJetpack","SteampunkJetpack","Gameboard","LaserLauncher","Lever","WinterThruster","WinterJetTurbine","WinterBoatMotor","Bread","DragonEgg","SecretTreasure","Star","Heart","I-Beam","LifePreserver","TreasureChest","pumpkin1","HugeWheel"}

local buyAmount = 1
local selBlocks, selComps, selPVP, selExtra, selChests, selEspecials = {}, {}, {}, {}, {}, {}

shopTab:AddTextBox({ Text = "Amount", Placeholder = "Enter amount", Default = "1", Callback = function(value)
	local num = tonumber(value)
	if num and num > 0 then buyAmount = num else buyAmount = 1 end
end })

shopTab:AddMultiSelectSearchableDropdown({ Text = "Blocks to Buy", Items = Blocks, Callback = function(selected) selBlocks = selected end })
shopTab:AddMultiSelectSearchableDropdown({ Text = "Components to Buy", Items = Components, Callback = function(selected) selComps = selected end })
shopTab:AddMultiSelectSearchableDropdown({ Text = "PVP Components to Buy", Items = PVP, Callback = function(selected) selPVP = selected end })
shopTab:AddMultiSelectSearchableDropdown({ Text = "Block Extras", Items = ExtrasBlocks, Callback = function(selected) selExtra = selected end })
shopTab:AddMultiSelectSearchableDropdown({ Text = "Chest To Shop", Items = chestList, Callback = function(selected) selChests = selected end })
shopTab:AddLabel({ Text = "Method To Get These Is SUPER Broken And Old", Color = Color3.fromRGB(128,128,128) })
shopTab:AddMultiSelectSearchableDropdown({ Text = "Especials", Items = Especials, Callback = function(selected) selEspecials = selected end })

shopTab:AddButton({ Text = "Buy Selected Items", Callback = function()
	local remote = GetBuyRemote()
	if not remote then win:Notify({ Title = "Error", Description = "Remote not found!", Type = "error" }) return end
	
	local allSelected = {}
	for _, t in ipairs({selBlocks, selComps, selPVP, selExtra, selChests, selEspecials}) do
		for _, item in ipairs(t) do table.insert(allSelected, item) end
	end
	
	if #allSelected == 0 then win:Notify({ Title = "Error", Description = "No items selected!", Type = "error" }) return end
	for _,item in ipairs(allSelected) do
		pcall(function() remote:InvokeServer(item, buyAmount) end)
	end
	win:Notify({ Title = "Buy", Description = "Purchased "..#allSelected.." item(s) x"..buyAmount, Type = "success" })
end })

shopTab:AddLabel({ Text = "Buy Pine Tree Module", Color = Color3.fromRGB(128,128,128) })
shopTab:AddButton({ Text = "Buy Pine Trees", Callback = function()
	local remote = GetBuyRemote()
	if remote then
		pcall(function() remote:InvokeServer("PineTree", 10) end)
		win:Notify({ Title = "Bought", Description = "10 Pine Trees", Type = "success" })
	else
		win:Notify({ Title = "Error", Description = "Remote not found!", Type = "error" })
	end
end })

pcall(function() win:LoadState() end)
