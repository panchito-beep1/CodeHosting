local Axiom = loadstring(game:HttpGet("https://raw.githubusercontent.com/panchito-beep1/AXIOM/refs/heads/main/AxiomV6"))()
if not Axiom then
    warn("Failed to load Axiom library!")
    return
end

local gameData = game.ReplicatedStorage:WaitForChild("GameData")
local floor = gameData:WaitForChild("Floor")
local isMines = floor.Value == "Mines"
local isHotel = floor.Value == "Hotel"
local isBackdoor = floor.Value == "Backdoor"
local isGarden = floor.Value == "Garden"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Floor = ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Floor")
local LatestRoom = ReplicatedStorage:WaitForChild("GameData"):WaitForChild("LatestRoom")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local MainGame = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainUI").Initiator:WaitForChild("Main_Game")
local RemoteListener = MainGame:WaitForChild("RemoteListener")

local RequiredMainGame

local ClientModules = ReplicatedStorage:FindFirstChild("ModulesClient") or ReplicatedStorage:FindFirstChild("ClientModules")

local RemotesFolder = ReplicatedStorage:FindFirstChild("EntityInfo") and ReplicatedStorage:FindFirstChild("EntityInfo") or ReplicatedStorage:FindFirstChild("Bricks") and ReplicatedStorage:FindFirstChild("Bricks") or ReplicatedStorage:FindFirstChild("RemotesFolder")
local MotorReplication = RemotesFolder:WaitForChild("MotorReplication")
local CollisionClone
local CamLock = RemotesFolder:WaitForChild("CamLock")

local AnchorArgs
local PL = RemotesFolder:WaitForChild("PL")
local ClutchHeartbeat = RemotesFolder:WaitForChild("ClutchHeartbeat")

_G.EspGui           = false
_G.EspHighlight     = false
_G.EspName          = true
_G.EspDistance      = true
_G.EspGuiTextSize   = 15
_G.EspGuiTextColor  = Color3.new(255, 255, 255)
_G.ColorLight       = Color3.fromRGB(255, 255, 255)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function Distance(pos)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        return 0
    end
    return (char.HumanoidRootPart.Position - pos).Magnitude
end

local stats = Axiom.new({
    Title    = "Apex - Stats",
    Icon     = "rbxassetid://10653372143",
    Position = UDim2.new(0, 10, 0, 860),
    Size     = UDim2.new(0, 300, 0, 150)
})

local main = Axiom.new({
    Title = "Apex | Doors | 2.3",
    Icon  = "rbxassetid://10653372143"
})

local statTab    = stats:AddTab({ Name = "Stats" })
local gameTab    = stats:AddTab({ Name = "Game Stats" })
local mainTab    = main:AddTab({ Name = "Main" })
local visualTab  = main:AddTab({ Name = "Visuals" })

local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")

local fpsLabel      = statTab:AddLabel({ Text = "FPS: <font color='#b32222'>0</font>" })
local pingLabel     = statTab:AddLabel({ Text = "Ping: <font color='#FACC15'>0 ms</font>" })
local memoryLabel   = statTab:AddLabel({ Text = "Memory: <font color='#60A5FA'>0 MB</font>" })
local playerLabel   = statTab:AddLabel({ Text = "Players: <font color='#C084FC'>0</font>" })
local positionLabel = statTab:AddLabel({ Text = "Position: <font color='#FB923C'>0, 0, 0</font>" })
local clockLabel    = statTab:AddLabel({ Text = "Time: <font color='#A78BFA'>00:00:00</font>" })

RunService.RenderStepped:Connect(function(dt)
    local fps = math.floor(1 / dt + 0.5)
    local ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
    local memory = math.floor(collectgarbage("count") / 1024)
    local char = LocalPlayer.Character
    local pos = Vector3.zero
    if char and char:FindFirstChild("HumanoidRootPart") then
        pos = char.HumanoidRootPart.Position
    end

    fpsLabel:SetText(string.format("FPS: <font color='#A78BFA'><b>%d</b></font>", fps))
    pingLabel:SetText(string.format("Ping: <font color='#FACC15'><b>%d ms</b></font>", ping))
    memoryLabel:SetText(string.format("Memory: <font color='#A78BFA'><b>%d MB</b></font>", memory))
    playerLabel:SetText(string.format("Players: <font color='#FACC15'><b>%d</b></font>", #Players:GetPlayers()))
    positionLabel:SetText(string.format("Position: <font color='#A78BFA'><b>%d, %d, %d</b></font>",
        math.floor(pos.X), math.floor(pos.Y), math.floor(pos.Z)))
    clockLabel:SetText(string.format("Time: <font color='#FACC15'><b>%s</b></font>", os.date("%H:%M:%S")))
end)

local rooms = workspace:WaitForChild("CurrentRooms")
local roomLabel = gameTab:AddLabel({ Text = "Current Room: <font color='#5FD38D'>Unknown</font>" })

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local currentRoom
    for _, room in ipairs(rooms:GetChildren()) do
        if room:IsA("Model") then
            local dist = (room:GetPivot().Position - root.Position).Magnitude
            if dist <= 60 then
                local number = tonumber(room.Name)
                if number and (not currentRoom or number > currentRoom) then
                    currentRoom = number
                end
            end
        end
    end

    roomLabel:SetText(string.format("Current Room: <b><font color='#5FD38D'>%s</font></b>",
        currentRoom or "Unknown"))
end)

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local topbar = playerGui:WaitForChild("TopbarUI"):WaitForChild("Topbar")

local asdadsdas = gameTab:AddLabel({ Text = "Gold" })
local goldLabel = gameTab:AddLabel({ Text = "Loading..." })

local asdadssdas = gameTab:AddLabel({ Text = "Knobs" })
local knobsLabel = gameTab:AddLabel({ Text = "Loading..." })

local goldObject = topbar:WaitForChild("Gold")
local knobsObject = topbar:WaitForChild("Knobs")

local function getValue(obj)
	if obj:IsA("NumberValue") or obj:IsA("IntValue") then
		return obj.Value
	elseif obj:IsA("TextLabel") then
		return obj.Text
	else
		return "?"
	end
end

local function updateLabel(label, obj)
	local val = getValue(obj)
	label:SetText("<font color='#FACC15'>" .. tostring(val) .. "</font>")
end

local function bind(label, obj)
	if obj:IsA("NumberValue") or obj:IsA("IntValue") then
		obj:GetPropertyChangedSignal("Value"):Connect(function()
			updateLabel(label, obj)
		end)
	elseif obj:IsA("TextLabel") then
		obj:GetPropertyChangedSignal("Text"):Connect(function()
			updateLabel(label, obj)
		end)
	end
	updateLabel(label, obj)
end

bind(goldLabel, goldObject)
bind(knobsLabel, knobsObject)

visualTab:AddCheckbox({ Text = "Esp Gui", Default = false, Callback = function(state)
    _G.EspGui = state
end })

visualTab:AddCheckbox({ Text = "Esp Highlight", Default = false, Callback = function(state)
    _G.EspHighlight = state
end })

_G.EspEntityNameDis = {
    ["FigureRig"] = "Figure",
    ["SallyMoving"] = "Window",
    ["RushMoving"] = "Rush",
    ["Eyes"] = "Eyes",
    ["Groundskeeper"] = "Skeeper",
    ["BackdoorLookman"] = "Lookman",
    ["BackdoorRush"] = "Blitz",
    ["MandrakeLive"] = "Mandrake",
    ["GloombatSwarm"] = "Gloombat",
    ["GiggleCeiling"] = "Giggle",
    ["AmbushMoving"] = "Ambush"
}

if not isGarden then
    if isHotel or isBackdoor then
        visualTab:AddCheckbox({ Text = "Esp Key / Lever", Default = false, Callback = function(state)
            _G.EspKey = state
            if state == false then
                _G.KeyAdd = {}
                if KeySpawn then KeySpawn:Disconnect(); KeySpawn = nil end
                if KeyRemove then KeyRemove:Disconnect(); KeyRemove = nil end
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name:find("Key") or v.Name == "LeverForGate" or v.Name:find("FuseObtain") then
                        for i, z in pairs(v:GetChildren()) do
                            if z.Name:find("Esp_") then z:Destroy() end
                        end
                    end
                end
            else
                local function Keys(v)
                    if ((v.Name:find("Key") or v.Name:find("FuseObtain")) and v:FindFirstChild("Hitbox")) or (v.Name == "LeverForGate" and v.PrimaryPart) then
                        if v:FindFirstChild("Esp_Highlight") then
                            v:FindFirstChild("Esp_Highlight").FillColor = _G.ColorLight or Color3.fromRGB(255, 255, 255)
                            v:FindFirstChild("Esp_Highlight").OutlineColor = _G.ColorLight or Color3.fromRGB(255, 255, 255)
                        end
                        if _G.EspHighlight == true and v:FindFirstChild("Esp_Highlight") == nil then
                            local Highlight = Instance.new("Highlight")
                            Highlight.Name = "Esp_Highlight"
                            Highlight.FillColor = Color3.fromRGB(255, 255, 255)
                            Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            Highlight.FillTransparency = 0.5
                            Highlight.OutlineTransparency = 0
                            Highlight.Adornee = v
                            Highlight.Parent = v
                        elseif _G.EspHighlight == false and v:FindFirstChild("Esp_Highlight") then
                            v:FindFirstChild("Esp_Highlight"):Destroy()
                        end
                        if v:FindFirstChild("Esp_Gui") and v["Esp_Gui"]:FindFirstChild("TextLabel") then
                            v["Esp_Gui"]:FindFirstChild("TextLabel").Text =
                                (_G.EspName == true and ((v.Name == "LeverForGate" and "Lever") or (v.Name:find("Key") and "Key") or (v.Name:find("FuseObtain") and "Fuse")) or "") ..
                                (_G.EspDistance == true and "\nDistance (" .. string.format("%.0f", Distance((v.Name == "LeverForGate" and v.PrimaryPart.Position) or ((v.Name:find("Key") or v.Name:find("FuseObtain")) and v.Hitbox.Position))) .. "m)" or "")
                            v["Esp_Gui"]:FindFirstChild("TextLabel").TextSize = _G.EspGuiTextSize or 15
                            v["Esp_Gui"]:FindFirstChild("TextLabel").TextColor3 = _G.EspGuiTextColor or Color3.new(255, 255, 255)
                        end
                        if _G.EspGui == true and v:FindFirstChild("Esp_Gui") == nil then
                            local GuiEsp = Instance.new("BillboardGui", v)
                            GuiEsp.Adornee = v
                            GuiEsp.Name = "Esp_Gui"
                            GuiEsp.Size = UDim2.new(0, 100, 0, 150)
                            GuiEsp.AlwaysOnTop = true
                            local GuiEspText = Instance.new("TextLabel", GuiEsp)
                            GuiEspText.BackgroundTransparency = 1
                            GuiEspText.Font = Enum.Font.Code
                            GuiEspText.Size = UDim2.new(0, 100, 0, 100)
                            GuiEspText.TextSize = 15
                            GuiEspText.TextColor3 = Color3.new(0,0,0)
                            GuiEspText.TextStrokeTransparency = 0.5
                            GuiEspText.Text = ""
                            local UIStroke = Instance.new("UIStroke")
                            UIStroke.Color = Color3.new(0, 0, 0)
                            UIStroke.Thickness = 1.5
                            UIStroke.Parent = GuiEspText
                        elseif _G.EspGui == false and v:FindFirstChild("Esp_Gui") then
                            v:FindFirstChild("Esp_Gui"):Destroy()
                        end
                    end
                end

                local function CheckKey(v)
                    if not table.find(_G.KeyAdd, v) and ((v.Name:find("Key") or v.Name:find("FuseObtain")) and v:FindFirstChild("Hitbox")) or (v.Name == "LeverForGate" and v.PrimaryPart) then
                        table.insert(_G.KeyAdd, v)
                    end
                end

                _G.KeyAdd = {}
                for _, v in ipairs(workspace:GetDescendants()) do
                    CheckKey(v)
                end
                KeySpawn = workspace.DescendantAdded:Connect(function(v) CheckKey(v) end)
                KeyRemove = workspace.DescendantRemoving:Connect(function(v)
                    for i = #_G.KeyAdd, 1, -1 do
                        if _G.KeyAdd[i] == v then
                            table.remove(_G.KeyAdd, i)
                            break
                        end
                    end
                end)

                task.spawn(function()
                    while _G.EspKey do
                        for i, v in pairs(_G.KeyAdd) do
                            if v:IsA("Model") then Keys(v) end
                        end
                        task.wait()
                    end
                    if KeySpawn then KeySpawn:Disconnect(); KeySpawn = nil end
                    if KeyRemove then KeyRemove:Disconnect(); KeyRemove = nil end
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v.Name:find("Key") or v.Name == "LeverForGate" or v.Name:find("FuseObtain") then
                            for i, z in pairs(v:GetChildren()) do
                                if z.Name:find("Esp_") then z:Destroy() end
                            end
                        end
                    end
                end)
            end
        end })
    end

    if isMines then
        visualTab:AddCheckbox({ Text = "Esp Fuse", Default = false, Callback = function(state)
            _G.EspKey = state
        end })
    end
end

visualTab:AddCheckbox({ Text = "Esp Door", Default = false, Callback = function(state)
    _G.EspDoor = state
    if state == false then
        for _, v in pairs(game.Workspace:FindFirstChild("CurrentRooms"):GetChildren()) do
            if v:IsA("Model") then
                for i, z in pairs(v:GetChildren()) do
                    if z.Name:find("Esp_") then z:Destroy() end
                end
            end
        end
    else
        task.spawn(function()
            while _G.EspDoor do
                for i, v in pairs(game.Workspace:FindFirstChild("CurrentRooms"):GetChildren()) do
                    if v:IsA("Model") and v:FindFirstChild("Door") and v.Door:FindFirstChild("Door") then
                        if v:FindFirstChild("Esp_Highlight") then
                            v:FindFirstChild("Esp_Highlight").FillColor = _G.ColorLight or Color3.fromRGB(255, 255, 255)
                            v:FindFirstChild("Esp_Highlight").OutlineColor = _G.ColorLight or Color3.fromRGB(255, 255, 255)
                        end
                        if _G.EspHighlight == true and v:FindFirstChild("Esp_Highlight") == nil then
                            local Highlight = Instance.new("Highlight")
                            Highlight.Name = "Esp_Highlight"
                            Highlight.FillColor = Color3.fromRGB(255, 255, 255)
                            Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            Highlight.FillTransparency = 0.5
                            Highlight.OutlineTransparency = 0
                            Highlight.Adornee = v.Door.Door
                            Highlight.Parent = v
                        elseif _G.EspHighlight == false and v:FindFirstChild("Esp_Highlight") then
                            v:FindFirstChild("Esp_Highlight"):Destroy()
                        end
                        if v:FindFirstChild("Esp_Gui") and v["Esp_Gui"]:FindFirstChild("TextLabel") then
                            local doorText = ""
                            if v.Door:FindFirstChild("Sign") then
                                if v.Door.Sign:FindFirstChild("Stinker") then
                                    doorText = v.Door.Sign.Stinker.Text
                                elseif v.Door.Sign:FindFirstChild("SignText") then
                                    doorText = v.Door.Sign.SignText.Text
                                end
                            end
                            v["Esp_Gui"]:FindFirstChild("TextLabel").Text =
                                (_G.EspName == true and "Door " .. (doorText:gsub("^0+", "") .. (v.Door:FindFirstChild("Lock") and " (lock)" or "")) or "") ..
                                (_G.EspDistance == true and "\nDistance (" .. string.format("%.0f", Distance(v.Door.Door.Position)) .. "m)" or "")
                            v["Esp_Gui"]:FindFirstChild("TextLabel").TextSize = _G.EspGuiTextSize or 15
                            v["Esp_Gui"]:FindFirstChild("TextLabel").TextColor3 = _G.EspGuiTextColor or Color3.new(255, 255, 255)
                        end
                        if _G.EspGui == true and v:FindFirstChild("Esp_Gui") == nil then
                            local GuiEsp = Instance.new("BillboardGui", v)
                            GuiEsp.Adornee = v.Door.Door
                            GuiEsp.Name = "Esp_Gui"
                            GuiEsp.Size = UDim2.new(0, 100, 0, 150)
                            GuiEsp.AlwaysOnTop = true
                            local GuiEspText = Instance.new("TextLabel", GuiEsp)
                            GuiEspText.BackgroundTransparency = 1
                            GuiEspText.Font = Enum.Font.Code
                            GuiEspText.Size = UDim2.new(0, 100, 0, 100)
                            GuiEspText.TextSize = 15
                            GuiEspText.TextColor3 = Color3.new(0,0,0)
                            GuiEspText.TextStrokeTransparency = 0.5
                            GuiEspText.Text = ""
                            local UIStroke = Instance.new("UIStroke")
                            UIStroke.Color = Color3.new(0, 0, 0)
                            UIStroke.Thickness = 1.5
                            UIStroke.Parent = GuiEspText
                        elseif _G.EspGui == false and v:FindFirstChild("Esp_Gui") then
                            v:FindFirstChild("Esp_Gui"):Destroy()
                        end
                    end
                end
                task.wait()
            end
            for _, v in pairs(game.Workspace:FindFirstChild("CurrentRooms"):GetChildren()) do
                if v:IsA("Model") then
                    for i, z in pairs(v:GetChildren()) do
                        if z.Name:find("Esp_") then z:Destroy() end
                    end
                end
            end
        end)
    end
end })

if isBackdoor then
    visualTab:AddCheckbox({ Text = "Esp Time Lever", Default = false, Callback = function(state)
        _G.EspLeverTime = state
        if state == false then
            _G.TimeLeverAdd = {}
            if TimeLeverSpawn then TimeLeverSpawn:Disconnect(); TimeLeverSpawn = nil end
            if TimeLeverRemove then TimeLeverRemove:Disconnect(); TimeLeverRemove = nil end
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name:find("TimerLever") then
                    for i, z in pairs(v:GetChildren()) do
                        if z.Name:find("Esp_") then z:Destroy() end
                    end
                end
            end
        else
            local function LeverTimes(v)
                if v.Name:find("TimerLever") and v.PrimaryPart then
                    if v:FindFirstChild("Esp_Highlight") then
                        v:FindFirstChild("Esp_Highlight").FillColor = _G.ColorLight or Color3.fromRGB(255, 255, 255)
                        v:FindFirstChild("Esp_Highlight").OutlineColor = _G.ColorLight or Color3.fromRGB(255, 255, 255)
                    end
                    if _G.EspHighlight == true and v:FindFirstChild("Esp_Highlight") == nil then
                        local Highlight = Instance.new("Highlight")
                        Highlight.Name = "Esp_Highlight"
                        Highlight.FillColor = Color3.fromRGB(255, 255, 255)
                        Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        Highlight.FillTransparency = 0.5
                        Highlight.OutlineTransparency = 0
                        Highlight.Adornee = v
                        Highlight.Parent = v
                    elseif _G.EspHighlight == false and v:FindFirstChild("Esp_Highlight") then
                        v:FindFirstChild("Esp_Highlight"):Destroy()
                    end
                    if v:FindFirstChild("Esp_Gui") and v["Esp_Gui"]:FindFirstChild("TextLabel") then
                        v["Esp_Gui"]:FindFirstChild("TextLabel").Text =
                            (_G.EspName == true and "Lever Time" or "") ..
                            (_G.EspDistance == true and "\nDistance (" .. string.format("%.0f", Distance(v.PrimaryPart.Position)) .. "m)" or "")
                        v["Esp_Gui"]:FindFirstChild("TextLabel").TextSize = _G.EspGuiTextSize or 15
                        v["Esp_Gui"]:FindFirstChild("TextLabel").TextColor3 = _G.EspGuiTextColor or Color3.new(255, 255, 255)
                    end
                    if _G.EspGui == true and v:FindFirstChild("Esp_Gui") == nil then
                        local GuiEsp = Instance.new("BillboardGui", v)
                        GuiEsp.Adornee = v
                        GuiEsp.Name = "Esp_Gui"
                        GuiEsp.Size = UDim2.new(0, 100, 0, 150)
                        GuiEsp.AlwaysOnTop = true
                        local GuiEspText = Instance.new("TextLabel", GuiEsp)
                        GuiEspText.BackgroundTransparency = 1
                        GuiEspText.Font = Enum.Font.Code
                        GuiEspText.Size = UDim2.new(0, 100, 0, 100)
                        GuiEspText.TextSize = 15
                        GuiEspText.TextColor3 = Color3.new(0,0,0)
                        GuiEspText.TextStrokeTransparency = 0.5
                        GuiEspText.Text = ""
                        local UIStroke = Instance.new("UIStroke")
                        UIStroke.Color = Color3.new(0, 0, 0)
                        UIStroke.Thickness = 1.5
                        UIStroke.Parent = GuiEspText
                    elseif _G.EspGui == false and v:FindFirstChild("Esp_Gui") then
                        v:FindFirstChild("Esp_Gui"):Destroy()
                    end
                end
            end

            local function CheckTimeLever(v)
                if not table.find(_G.TimeLeverAdd, v) and v.Name == "TimerLever" then
                    table.insert(_G.TimeLeverAdd, v)
                end
            end

            _G.TimeLeverAdd = {}
            for _, v in ipairs(workspace:GetDescendants()) do
                CheckTimeLever(v)
            end
            TimeLeverSpawn = workspace.DescendantAdded:Connect(function(v) CheckTimeLever(v) end)
            TimeLeverRemove = workspace.DescendantRemoving:Connect(function(v)
                for i = #_G.TimeLeverAdd, 1, -1 do
                    if _G.TimeLeverAdd[i] == v then
                        table.remove(_G.TimeLeverAdd, i)
                        break
                    end
                end
            end)

            task.spawn(function()
                while _G.EspLeverTime do
                    for i, v in pairs(_G.TimeLeverAdd) do
                        if v:IsA("Model") then LeverTimes(v) end
                    end
                    task.wait()
                end
                if TimeLeverSpawn then TimeLeverSpawn:Disconnect(); TimeLeverSpawn = nil end
                if TimeLeverRemove then TimeLeverRemove:Disconnect(); TimeLeverRemove = nil end
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name:find("TimerLever") then
                        for i, z in pairs(v:GetChildren()) do
                            if z.Name:find("Esp_") then z:Destroy() end
                        end
                    end
                end
            end)
        end
    end })
end

if isHotel then
    visualTab:AddCheckbox({ Text = "Esp Book", Default = false, Callback = function(state)
        _G.EspBook = state
        if state == false then
            _G.BookAdd = {}
            if BookSpawn then BookSpawn:Disconnect(); BookSpawn = nil end
            if BookRemove then BookRemove:Disconnect(); BookRemove = nil end
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name:find("LiveHintBook") then
                    for i, z in pairs(v:GetChildren()) do
                        if z.Name:find("Esp_") then z:Destroy() end
                    end
                end
            end
        else
            local function Books(v)
                if v.Name:find("LiveHintBook") and v.PrimaryPart then
                    if v:FindFirstChild("Esp_Highlight") then
                        v:FindFirstChild("Esp_Highlight").FillColor = _G.ColorLight or Color3.fromRGB(255, 255, 255)
                        v:FindFirstChild("Esp_Highlight").OutlineColor = _G.ColorLight or Color3.fromRGB(255, 255, 255)
                    end
                    if _G.EspHighlight == true and v:FindFirstChild("Esp_Highlight") == nil then
                        local Highlight = Instance.new("Highlight")
                        Highlight.Name = "Esp_Highlight"
                        Highlight.FillColor = Color3.fromRGB(255, 255, 255)
                        Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        Highlight.FillTransparency = 0.5
                        Highlight.OutlineTransparency = 0
                        Highlight.Adornee = v
                        Highlight.Parent = v
                    elseif _G.EspHighlight == false and v:FindFirstChild("Esp_Highlight") then
                        v:FindFirstChild("Esp_Highlight"):Destroy()
                    end
                    if v:FindFirstChild("Esp_Gui") and v["Esp_Gui"]:FindFirstChild("TextLabel") then
                        v["Esp_Gui"]:FindFirstChild("TextLabel").Text =
                            (_G.EspName == true and "Book" or "") ..
                            (_G.EspDistance == true and "\nDistance (" .. string.format("%.0f", Distance(v.PrimaryPart.Position)) .. "m)" or "")
                        v["Esp_Gui"]:FindFirstChild("TextLabel").TextSize = _G.EspGuiTextSize or 15
                        v["Esp_Gui"]:FindFirstChild("TextLabel").TextColor3 = _G.EspGuiTextColor or Color3.new(255, 255, 255)
                    end
                    if _G.EspGui == true and v:FindFirstChild("Esp_Gui") == nil then
                        local GuiEsp = Instance.new("BillboardGui", v)
                        GuiEsp.Adornee = v
                        GuiEsp.Name = "Esp_Gui"
                        GuiEsp.Size = UDim2.new(0, 100, 0, 150)
                        GuiEsp.AlwaysOnTop = true
                        local GuiEspText = Instance.new("TextLabel", GuiEsp)
                        GuiEspText.BackgroundTransparency = 1
                        GuiEspText.Font = Enum.Font.Code
                        GuiEspText.Size = UDim2.new(0, 100, 0, 100)
                        GuiEspText.TextSize = 15
                        GuiEspText.TextColor3 = Color3.new(0,0,0)
                        GuiEspText.TextStrokeTransparency = 0.5
                        GuiEspText.Text = ""
                        local UIStroke = Instance.new("UIStroke")
                        UIStroke.Color = Color3.new(0, 0, 0)
                        UIStroke.Thickness = 1.5
                        UIStroke.Parent = GuiEspText
                    elseif _G.EspGui == false and v:FindFirstChild("Esp_Gui") then
                        v:FindFirstChild("Esp_Gui"):Destroy()
                    end
                end
            end

            local function CheckBook(v)
                if not table.find(_G.BookAdd, v) and v.Name == "LiveHintBook" then
                    table.insert(_G.BookAdd, v)
                end
            end

            _G.BookAdd = {}
            for _, v in ipairs(workspace:GetDescendants()) do
                CheckBook(v)
            end
            BookSpawn = workspace.DescendantAdded:Connect(function(v) CheckBook(v) end)
            BookRemove = workspace.DescendantRemoving:Connect(function(v)
                for i = #_G.BookAdd, 1, -1 do
                    if _G.BookAdd[i] == v then
                        table.remove(_G.BookAdd, i)
                        break
                    end
                end
            end)

            task.spawn(function()
                while _G.EspBook do
                    for i, v in pairs(_G.BookAdd) do
                        if v:IsA("Model") then Books(v) end
                    end
                    task.wait()
                end
                if BookSpawn then BookSpawn:Disconnect(); BookSpawn = nil end
                if BookRemove then BookRemove:Disconnect(); BookRemove = nil end
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name:find("LiveHintBook") then
                        for i, z in pairs(v:GetChildren()) do
                            if z.Name:find("Esp_") then z:Destroy() end
                        end
                    end
                end
            end)
        end
    end })

    visualTab:AddCheckbox({ Text = "Esp Breaker", Default = false, Callback = function(state)
        _G.EspBreaker = state
        if state == false then
            _G.BreakerAdd = {}
            if BreakerSpawn then BreakerSpawn:Disconnect(); BreakerSpawn = nil end
            if BreakerRemove then BreakerRemove:Disconnect(); BreakerRemove = nil end
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name:find("LiveBreakerPolePickup") then
                    for i, z in pairs(v:GetChildren()) do
                        if z.Name:find("Esp_") then z:Destroy() end
                    end
                end
            end
        else
            local function Breakers(v)
                if v.Name == "LiveBreakerPolePickup" and v:FindFirstChildOfClass("ProximityPrompt") then
                    if v:FindFirstChild("Esp_Highlight") then
                        v:FindFirstChild("Esp_Highlight").FillColor = _G.ColorLight or Color3.fromRGB(255, 255, 255)
                        v:FindFirstChild("Esp_Highlight").OutlineColor = _G.ColorLight or Color3.fromRGB(255, 255, 255)
                    end
                    if _G.EspHighlight == true and v:FindFirstChild("Esp_Highlight") == nil then
                        local Highlight = Instance.new("Highlight")
                        Highlight.Name = "Esp_Highlight"
                        Highlight.FillColor = Color3.fromRGB(255, 255, 255)
                        Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        Highlight.FillTransparency = 0.5
                        Highlight.OutlineTransparency = 0
                        Highlight.Adornee = v
                        Highlight.Parent = v
                    elseif _G.EspHighlight == false and v:FindFirstChild("Esp_Highlight") then
                        v:FindFirstChild("Esp_Highlight"):Destroy()
                    end
                    if v:FindFirstChild("Esp_Gui") and v["Esp_Gui"]:FindFirstChild("TextLabel") then
                        v["Esp_Gui"]:FindFirstChild("TextLabel").Text =
                            (_G.EspName == true and "Breaker" or "") ..
                            (_G.EspDistance == true and "\nDistance (" .. string.format("%.0f", Distance(v.PrimaryPart.Position)) .. "m)" or "")
                        v["Esp_Gui"]:FindFirstChild("TextLabel").TextSize = _G.EspGuiTextSize or 15
                        v["Esp_Gui"]:FindFirstChild("TextLabel").TextColor3 = _G.EspGuiTextColor or Color3.new(255, 255, 255)
                    end
                    if _G.EspGui == true and v:FindFirstChild("Esp_Gui") == nil then
                        local GuiEsp = Instance.new("BillboardGui", v)
                        GuiEsp.Adornee = v
                        GuiEsp.Name = "Esp_Gui"
                        GuiEsp.Size = UDim2.new(0, 100, 0, 150)
                        GuiEsp.AlwaysOnTop = true
                        local GuiEspText = Instance.new("TextLabel", GuiEsp)
                        GuiEspText.BackgroundTransparency = 1
                        GuiEspText.Font = Enum.Font.Code
                        GuiEspText.Size = UDim2.new(0, 100, 0, 100)
                        GuiEspText.TextSize = 15
                        GuiEspText.TextColor3 = Color3.new(0,0,0)
                        GuiEspText.TextStrokeTransparency = 0.5
                        GuiEspText.Text = ""
                        local UIStroke = Instance.new("UIStroke")
                        UIStroke.Color = Color3.new(0, 0, 0)
                        UIStroke.Thickness = 1.5
                        UIStroke.Parent = GuiEspText
                    elseif _G.EspGui == false and v:FindFirstChild("Esp_Gui") then
                        v:FindFirstChild("Esp_Gui"):Destroy()
                    end
                end
            end

            local function CheckBreaker(v)
                if not table.find(_G.BreakerAdd, v) and v.Name == "LiveBreakerPolePickup" then
                    table.insert(_G.BreakerAdd, v)
                end
            end

            _G.BreakerAdd = {}
            for _, v in ipairs(workspace:GetDescendants()) do
                CheckBreaker(v)
            end
            BreakerSpawn = workspace.DescendantAdded:Connect(function(v) CheckBreaker(v) end)
            BreakerRemove = workspace.DescendantRemoving:Connect(function(v)
                for i = #_G.BreakerAdd, 1, -1 do
                    if _G.BreakerAdd[i] == v then
                        table.remove(_G.BreakerAdd, i)
                        break
                    end
                end
            end)

            task.spawn(function()
                while _G.EspBreaker do
                    for i, v in pairs(_G.BreakerAdd) do
                        if v.Name == "LiveBreakerPolePickup" then Breakers(v) end
                    end
                    task.wait()
                end
                if BreakerSpawn then BreakerSpawn:Disconnect(); BreakerSpawn = nil end
                if BreakerRemove then BreakerRemove:Disconnect(); BreakerRemove = nil end
                for _, v in pairs(workspace:GetDescendants()) do
                    if v.Name:find("LiveBreakerPolePickup") then
                        for i, z in pairs(v:GetChildren()) do
                            if z.Name:find("Esp_") then z:Destroy() end
                        end
                    end
                end
            end)
        end
    end })
end

visualTab:AddCheckbox({ Text = "Esp Item", Default = false, Callback = function(state)
    _G.EspItem = state
    if state == false then
        _G.ItemAdd = {}
        if ItemSpawn then ItemSpawn:Disconnect(); ItemSpawn = nil end
        if ItemRemove then ItemRemove:Disconnect(); ItemRemove = nil end
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name:find("Handle") then
                for i, z in pairs(v:GetChildren()) do
                    if z.Name:find("Esp_") then z:Destroy() end
                end
            end
        end
    else
        local function Items(v)
            if v.Name == "Handle" and v.Parent:FindFirstChildOfClass("ProximityPrompt") then
                if v:FindFirstChild("Esp_Highlight") then
                    v:FindFirstChild("Esp_Highlight").FillColor = _G.ColorLight or Color3.fromRGB(255, 255, 255)
                    v:FindFirstChild("Esp_Highlight").OutlineColor = _G.ColorLight or Color3.fromRGB(255, 255, 255)
                end
                if _G.EspHighlight == true and v:FindFirstChild("Esp_Highlight") == nil then
                    local Highlight = Instance.new("Highlight")
                    Highlight.Name = "Esp_Highlight"
                    Highlight.FillColor = Color3.fromRGB(255, 255, 255)
                    Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    Highlight.FillTransparency = 0.5
                    Highlight.OutlineTransparency = 0
                    Highlight.Adornee = v.Parent
                    Highlight.Parent = v
                elseif _G.EspHighlight == false and v:FindFirstChild("Esp_Highlight") then
                    v:FindFirstChild("Esp_Highlight"):Destroy()
                end
                if v:FindFirstChild("Esp_Gui") and v["Esp_Gui"]:FindFirstChild("TextLabel") then
                    v["Esp_Gui"]:FindFirstChild("TextLabel").Text =
                        (_G.EspName == true and v.Parent.Name or "") ..
                        (_G.EspDistance == true and "\nDistance (" .. string.format("%.0f", Distance(v.Position)) .. "m)" or "")
                    v["Esp_Gui"]:FindFirstChild("TextLabel").TextSize = _G.EspGuiTextSize or 15
                    v["Esp_Gui"]:FindFirstChild("TextLabel").TextColor3 = _G.EspGuiTextColor or Color3.new(255, 255, 255)
                end
                if _G.EspGui == true and v:FindFirstChild("Esp_Gui") == nil then
                    local GuiEsp = Instance.new("BillboardGui", v)
                    GuiEsp.Adornee = v.Parent
                    GuiEsp.Name = "Esp_Gui"
                    GuiEsp.Size = UDim2.new(0, 100, 0, 150)
                    GuiEsp.AlwaysOnTop = true
                    local GuiEspText = Instance.new("TextLabel", GuiEsp)
                    GuiEspText.BackgroundTransparency = 1
                    GuiEspText.Font = Enum.Font.Code
                    GuiEspText.Size = UDim2.new(0, 100, 0, 100)
                    GuiEspText.TextSize = 15
                    GuiEspText.TextColor3 = Color3.new(0,0,0)
                    GuiEspText.TextStrokeTransparency = 0.5
                    GuiEspText.Text = ""
                    local UIStroke = Instance.new("UIStroke")
                    UIStroke.Color = Color3.new(0, 0, 0)
                    UIStroke.Thickness = 1.5
                    UIStroke.Parent = GuiEspText
                elseif _G.EspGui == false and v:FindFirstChild("Esp_Gui") then
                    v:FindFirstChild("Esp_Gui"):Destroy()
                end
            end
        end

        local function CheckItem(v)
            if not table.find(_G.ItemAdd, v) and v.Name == "Handle" then
                table.insert(_G.ItemAdd, v)
            end
        end

        _G.ItemAdd = {}
        for _, v in ipairs(workspace:GetDescendants()) do
            CheckItem(v)
        end
        ItemSpawn = workspace.DescendantAdded:Connect(function(v) CheckItem(v) end)
        ItemRemove = workspace.DescendantRemoving:Connect(function(v)
            for i = #_G.ItemAdd, 1, -1 do
                if _G.ItemAdd[i] == v then
                    table.remove(_G.ItemAdd, i)
                    break
                end
            end
        end)

        task.spawn(function()
            while _G.EspItem do
                for i, v in pairs(LocalPlayer.Character:GetChildren()) do
                    if v:IsA("Tool") then
                        for i, z in pairs(v:GetChildren()) do
                            if z.Name:find("Esp_") then z:Destroy() end
                        end
                    end
                end
                for i, v in pairs(_G.ItemAdd) do
                    if v.Name == "Handle" then Items(v) end
                end
                task.wait()
            end
            if ItemSpawn then ItemSpawn:Disconnect(); ItemSpawn = nil end
            if ItemRemove then ItemRemove:Disconnect(); ItemRemove = nil end
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name:find("Handle") then
                    for i, z in pairs(v:GetChildren()) do
                        if z.Name:find("Esp_") then z:Destroy() end
                    end
                end
            end
        end)
    end
end })

visualTab:AddCheckbox({ Text = "Esp Entity", Default = false, Callback = function(state)
    _G.EspEntity = state
    if state == false then
        _G.EntityAdd = {}
        if EntitySpawn then EntitySpawn:Disconnect(); EntitySpawn = nil end
        if EntityRemove then EntityRemove:Disconnect(); EntityRemove = nil end
        for _, v in pairs(workspace:GetDescendants()) do
            for x, z in pairs(_G.EspEntityNameDis) do
                if v:IsA("Model") and v.Name == x then
                    if v.PrimaryPart then v.PrimaryPart.Transparency = 1 end
                    for i, z in pairs(v:GetChildren()) do
                        if z.Name:find("Esp_") then z:Destroy() end
                    end
                end
            end
        end
    else
        local function CheckEntity(v)
            for x, z in pairs(_G.EspEntityNameDis) do
                if v:IsA("Model") and v.Name == x then
                    if not table.find(_G.EntityAdd, v) then
                        table.insert(_G.EntityAdd, v)
                    end
                end
            end
        end

        _G.EntityAdd = {}
        for _, v in ipairs(workspace:GetDescendants()) do
            CheckEntity(v)
        end
        EntitySpawn = workspace.DescendantAdded:Connect(function(v) CheckEntity(v) end)
        EntityRemove = workspace.DescendantRemoving:Connect(function(v)
            for i = #_G.EntityAdd, 1, -1 do
                if _G.EntityAdd[i] == v then
                    table.remove(_G.EntityAdd, i)
                    break
                end
            end
        end)

        task.spawn(function()
            while _G.EspEntity do
                for i, v in pairs(_G.EntityAdd) do
                    for x, z in pairs(_G.EspEntityNameDis) do
                        if v:IsA("Model") and v.Name == x then
                            if v.PrimaryPart then v.PrimaryPart.Transparency = 0 end
                            if v:FindFirstChild("Esp_Highlight") then
                                v:FindFirstChild("Esp_Highlight").FillColor = _G.ColorLight or Color3.fromRGB(255, 255, 255)
                                v:FindFirstChild("Esp_Highlight").OutlineColor = _G.ColorLight or Color3.fromRGB(255, 255, 255)
                            end
                            if _G.EspHighlight == true and v:FindFirstChild("Esp_Highlight") == nil then
                                local Highlight = Instance.new("Highlight")
                                Highlight.Name = "Esp_Highlight"
                                Highlight.FillColor = Color3.fromRGB(255, 255, 255)
                                Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                                Highlight.FillTransparency = 0.5
                                Highlight.OutlineTransparency = 0
                                Highlight.Adornee = v
                                Highlight.Parent = v
                            elseif _G.EspHighlight == false and v:FindFirstChild("Esp_Highlight") then
                                v:FindFirstChild("Esp_Highlight"):Destroy()
                            end
                            if v:FindFirstChild("Esp_Gui") and v["Esp_Gui"]:FindFirstChild("TextLabel") then
                                v["Esp_Gui"]:FindFirstChild("TextLabel").Text =
                                    (_G.EspName == true and _G.EspEntityNameDis[v.Name] or "") ..
                                    (_G.EspDistance == true and "\nDistance (" .. string.format("%.0f", Distance(v.PrimaryPart.Position)) .. "m)" or "")
                                v["Esp_Gui"]:FindFirstChild("TextLabel").TextSize = _G.EspGuiTextSize or 15
                                v["Esp_Gui"]:FindFirstChild("TextLabel").TextColor3 = _G.EspGuiTextColor or Color3.new(255, 255, 255)
                            end
                            if _G.EspGui == true and v:FindFirstChild("Esp_Gui") == nil then
                                local GuiEsp = Instance.new("BillboardGui", v)
                                GuiEsp.Adornee = v
                                GuiEsp.Name = "Esp_Gui"
                                GuiEsp.Size = UDim2.new(0, 100, 0, 150)
                                GuiEsp.AlwaysOnTop = true
                                local GuiEspText = Instance.new("TextLabel", GuiEsp)
                                GuiEspText.BackgroundTransparency = 1
                                GuiEspText.Font = Enum.Font.Code
                                GuiEspText.Size = UDim2.new(0, 100, 0, 100)
                                GuiEspText.TextSize = 15
                                GuiEspText.TextColor3 = Color3.new(0,0,0)
                                GuiEspText.TextStrokeTransparency = 0.5
                                GuiEspText.Text = ""
                                local UIStroke = Instance.new("UIStroke")
                                UIStroke.Color = Color3.new(0, 0, 0)
                                UIStroke.Thickness = 1.5
                                UIStroke.Parent = GuiEspText
                            elseif _G.EspGui == false and v:FindFirstChild("Esp_Gui") then
                                v:FindFirstChild("Esp_Gui"):Destroy()
                            end
                        end
                    end
                end
                task.wait()
            end
            for _, v in pairs(workspace:GetDescendants()) do
                for x, z in pairs(_G.EspEntityNameDis) do
                    if v:IsA("Model") and v.Name == x then
                        if v.PrimaryPart then v.PrimaryPart.Transparency = 1 end
                        for i, z in pairs(v:GetChildren()) do
                            if z.Name:find("Esp_") then z:Destroy() end
                        end
                    end
                end
            end
            if EntitySpawn then EntitySpawn:Disconnect(); EntitySpawn = nil end
            if EntityRemove then EntityRemove:Disconnect(); EntityRemove = nil end
        end)
    end
end })

visualTab:AddCheckbox({ Text = "Esp Hiding Spots", Default = false, Callback = function(state)
    _G.EspHiding = state
    if state == false then
        _G.HidingAdd = {}
        if HidingSpawn then HidingSpawn:Disconnect(); HidingSpawn = nil end
        if HidingRemove then HidingRemove:Disconnect(); HidingRemove = nil end
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "Bed" or v.Name == "Wardrobe" or v.Name == "Backdoor_Wardrobe" or v.Name == "Locker_Large" or v.Name == "Rooms_Locker" then
                for i, z in pairs(v:GetChildren()) do
                    if z.Name:find("Esp_") then z:Destroy() end
                end
            end
        end
    else
        local function Hidings(v)
            if (v.Name == "Bed" or v.Name == "Wardrobe" or v.Name == "Backdoor_Wardrobe" or v.Name == "Locker_Large" or v.Name == "Rooms_Locker") and v.PrimaryPart then
                if v:FindFirstChild("Esp_Highlight") then
                    v:FindFirstChild("Esp_Highlight").FillColor = _G.ColorLight or Color3.fromRGB(255, 255, 255)
                    v:FindFirstChild("Esp_Highlight").OutlineColor = _G.ColorLight or Color3.fromRGB(255, 255, 255)
                end
                if _G.EspHighlight == true and v:FindFirstChild("Esp_Highlight") == nil then
                    local Highlight = Instance.new("Highlight")
                    Highlight.Name = "Esp_Highlight"
                    Highlight.FillColor = Color3.fromRGB(255, 255, 255)
                    Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    Highlight.FillTransparency = 0.5
                    Highlight.OutlineTransparency = 0
                    Highlight.Adornee = v
                    Highlight.Parent = v
                elseif _G.EspHighlight == false and v:FindFirstChild("Esp_Highlight") then
                    v:FindFirstChild("Esp_Highlight"):Destroy()
                end
                if v:FindFirstChild("Esp_Gui") and v["Esp_Gui"]:FindFirstChild("TextLabel") then
                    v["Esp_Gui"]:FindFirstChild("TextLabel").Text =
                        (_G.EspName == true and v.Name or "") ..
                        (_G.EspDistance == true and "\nDistance (" .. string.format("%.0f", Distance(v.PrimaryPart.Position)) .. "m)" or "")
                    v["Esp_Gui"]:FindFirstChild("TextLabel").TextSize = _G.EspGuiTextSize or 15
                    v["Esp_Gui"]:FindFirstChild("TextLabel").TextColor3 = _G.EspGuiTextColor or Color3.new(255, 255, 255)
                end
                if _G.EspGui == true and v:FindFirstChild("Esp_Gui") == nil then
                    local GuiEsp = Instance.new("BillboardGui", v)
                    GuiEsp.Adornee = v
                    GuiEsp.Name = "Esp_Gui"
                    GuiEsp.Size = UDim2.new(0, 100, 0, 150)
                    GuiEsp.AlwaysOnTop = true
                    local GuiEspText = Instance.new("TextLabel", GuiEsp)
                    GuiEspText.BackgroundTransparency = 1
                    GuiEspText.Font = Enum.Font.Code
                    GuiEspText.Size = UDim2.new(0, 100, 0, 100)
                    GuiEspText.TextSize = 15
                    GuiEspText.TextColor3 = Color3.new(0,0,0)
                    GuiEspText.TextStrokeTransparency = 0.5
                    GuiEspText.Text = ""
                    local UIStroke = Instance.new("UIStroke")
                    UIStroke.Color = Color3.new(0, 0, 0)
                    UIStroke.Thickness = 1.5
                    UIStroke.Parent = GuiEspText
                elseif _G.EspGui == false and v:FindFirstChild("Esp_Gui") then
                    v:FindFirstChild("Esp_Gui"):Destroy()
                end
            end
        end

        local function CheckHiding(v)
            if not table.find(_G.HidingAdd, v) and (v.Name == "Bed" or v.Name == "Wardrobe" or v.Name == "Backdoor_Wardrobe" or v.Name == "Locker_Large" or v.Name == "Rooms_Locker") then
                table.insert(_G.HidingAdd, v)
            end
        end

        _G.HidingAdd = {}
        for _, v in ipairs(workspace:GetDescendants()) do
            CheckHiding(v)
        end
        HidingSpawn = workspace.DescendantAdded:Connect(function(v) CheckHiding(v) end)
        HidingRemove = workspace.DescendantRemoving:Connect(function(v)
            for i = #_G.HidingAdd, 1, -1 do
                if _G.HidingAdd[i] == v then
                    table.remove(_G.HidingAdd, i)
                    break
                end
            end
        end)

        task.spawn(function()
            while _G.EspHiding do
                for i, v in pairs(_G.HidingAdd) do
                    if v:IsA("Model") then Hidings(v) end
                end
                task.wait()
            end
            if HidingSpawn then HidingSpawn:Disconnect(); HidingSpawn = nil end
            if HidingRemove then HidingRemove:Disconnect(); HidingRemove = nil end
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "Bed" or v.Name == "Wardrobe" or v.Name == "Backdoor_Wardrobe" or v.Name == "Locker_Large" or v.Name == "Rooms_Locker" then
                    for i, z in pairs(v:GetChildren()) do
                        if z.Name:find("Esp_") then z:Destroy() end
                    end
                end
            end
        end)
    end
end })

visualTab:AddCheckbox({ Text = "Highlight Wardrobes", Default = false, Callback = function(state)
    if state then
        highlightActive = true
        wardrobes = {}
        local found = findAllWardrobes()
        prepareHighlights(found)

        if not heartbeatConnection then
            heartbeatConnection = RunService.Heartbeat:Connect(updateHighlights)
        end
    else
        highlightActive = false
        if heartbeatConnection then
            heartbeatConnection:Disconnect()
            heartbeatConnection = nil
        end
        for _, data in ipairs(wardrobes) do
            if data.highlight then
                data.highlight.Enabled = false
            end
        end
    end
end })

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local DISTANCE_THRESHOLD = 100
local chestBoxes = {}
local heartbeatConnection = nil

local function findAllChestBoxes()
	local found = {}
	local currentRooms = workspace:FindFirstChild("CurrentRooms")
	if not currentRooms then return found end

	for _, room in ipairs(currentRooms:GetChildren()) do
		if tonumber(room.Name) then
			for _, assets in ipairs(room:GetDescendants()) do
				if assets.Name == "Assets" then
					for _, child in ipairs(assets:GetChildren()) do
						if child.Name == "ChestBox" then
							table.insert(found, child)
						end
					end
				end
			end
		end
	end
	return found
end

local function prepareHighlights(list)
	for _, item in ipairs(list) do
		local hl = item:FindFirstChildOfClass("Highlight")
		if not hl then
			hl = Instance.new("Highlight")
			hl.Name = "ChestBoxHighlight"
			hl.FillColor = Color3.fromRGB(255, 100, 100)
			hl.OutlineColor = Color3.fromRGB(255, 200, 0)
			hl.Parent = item
		end
		table.insert(chestBoxes, {item = item, highlight = hl})
	end
end

local function updateHighlights()
	local character = localPlayer.Character
	local pos = character and character:GetPivot().Position
	for _, data in ipairs(chestBoxes) do
		if data.item and data.item.Parent then
			if pos then
				local dist = (data.item:GetPivot().Position - pos).Magnitude
				data.highlight.Enabled = (dist <= DISTANCE_THRESHOLD)
			else
				data.highlight.Enabled = false
			end
		else
			data.highlight.Enabled = false
		end
	end
end

visualTab:AddCheckbox({ Text = "Highlight ChestBoxes", Default = false, Callback = function(state)
    if state then
        chestBoxes = {}
        local found = findAllChestBoxes()
        prepareHighlights(found)
        if not heartbeatConnection then
            heartbeatConnection = RunService.Heartbeat:Connect(updateHighlights)
        end
    else
        if heartbeatConnection then
            heartbeatConnection:Disconnect()
            heartbeatConnection = nil
        end
        for _, data in ipairs(chestBoxes) do
            if data.highlight then
                data.highlight.Enabled = false
            end
        end
    end
end })

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local DISTANCE_THRESHOLD = 100
local lockedChests = {}
local lockedHeartbeat = nil

local function findAllLockedChests()
	local found = {}
	local currentRooms = workspace:FindFirstChild("CurrentRooms")
	if not currentRooms then return found end

	for _, room in ipairs(currentRooms:GetChildren()) do
		if tonumber(room.Name) then
			for _, assets in ipairs(room:GetDescendants()) do
				if assets.Name == "Assets" then
					for _, child in ipairs(assets:GetChildren()) do
						if child.Name == "ChestBoxLocked" then
							table.insert(found, child)
						end
					end
				end
			end
		end
	end
	return found
end

local function prepareHighlights(list)
	for _, item in ipairs(list) do
		local hl = item:FindFirstChildOfClass("Highlight")
		if not hl then
			hl = Instance.new("Highlight")
			hl.Name = "LockedChestHighlight"
			hl.FillColor = Color3.fromRGB(255, 0, 0)
			hl.OutlineColor = Color3.fromRGB(200, 0, 0)
			hl.Parent = item
		end
		table.insert(lockedChests, {item = item, highlight = hl})
	end
end

local function updateLockedHighlights()
	local char = localPlayer.Character
	local pos = char and char:GetPivot().Position
	for _, data in ipairs(lockedChests) do
		if data.item and data.item.Parent then
			if pos then
				local dist = (data.item:GetPivot().Position - pos).Magnitude
				data.highlight.Enabled = (dist <= DISTANCE_THRESHOLD)
			else
				data.highlight.Enabled = false
			end
		else
			data.highlight.Enabled = false
		end
	end
end

visualTab:AddCheckbox({ Text = "Highlight Locked Chests", Default = false, Callback = function(state)
    if state then
        lockedChests = {}
        local found = findAllLockedChests()
        prepareHighlights(found)
        if not lockedHeartbeat then
            lockedHeartbeat = RunService.Heartbeat:Connect(updateLockedHighlights)
        end
    else
        if lockedHeartbeat then
            lockedHeartbeat:Disconnect()
            lockedHeartbeat = nil
        end
        for _, data in ipairs(lockedChests) do
            if data.highlight then
                data.highlight.Enabled = false
            end
        end
    end
end })

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local DISTANCE_THRESHOLD = 100
local keyItems = {}
local keyHeartbeat = nil

local function findAllKeyObtains()
	local found = {}
	local currentRooms = workspace:FindFirstChild("CurrentRooms")
	if not currentRooms then return found end

	for _, room in ipairs(currentRooms:GetChildren()) do
		if tonumber(room.Name) then
			for _, assets in ipairs(room:GetDescendants()) do
				if assets.Name == "Assets" then
					for _, child in ipairs(assets:GetChildren()) do
						if child.Name == "KeyObtain" then
							table.insert(found, child)
						end
					end
				end
			end
		end
	end
	return found
end

local function prepareHighlights(list)
	for _, item in ipairs(list) do
		local hl = item:FindFirstChildOfClass("Highlight")
		if not hl then
			hl = Instance.new("Highlight")
			hl.Name = "KeyHighlight"
			hl.FillColor = Color3.fromRGB(0, 255, 0)
			hl.OutlineColor = Color3.fromRGB(0, 180, 0)
			hl.Parent = item
		end
		table.insert(keyItems, {item = item, highlight = hl})
	end
end

local function updateKeyHighlights()
	local char = localPlayer.Character
	local pos = char and char:GetPivot().Position
	for _, data in ipairs(keyItems) do
		if data.item and data.item.Parent then
			if pos then
				local dist = (data.item:GetPivot().Position - pos).Magnitude
				data.highlight.Enabled = (dist <= DISTANCE_THRESHOLD)
			else
				data.highlight.Enabled = false
			end
		else
			data.highlight.Enabled = false
		end
	end
end

visualTab:AddCheckbox({ Text = "Highlight Key Obtains", Default = false, Callback = function(state)
    if state then
        keyItems = {}
        local found = findAllKeyObtains()
        prepareHighlights(found)
        if not keyHeartbeat then
            keyHeartbeat = RunService.Heartbeat:Connect(updateKeyHighlights)
        end
    else
        if keyHeartbeat then
            keyHeartbeat:Disconnect()
            keyHeartbeat = nil
        end
        for _, data in ipairs(keyItems) do
            if data.highlight then
                data.highlight.Enabled = false
            end
        end
    end
end })

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local fireThread = nil
local INTERACTION_RANGE = 100

local function firePromptIfValid(parent, childName, promptName)
	local child = parent:FindFirstChild(childName)
	if child then
		local prompt = child:FindFirstChild(promptName)
		if prompt and prompt:IsA("ProximityPrompt") and fireproximityprompt then
			fireproximityprompt(prompt)
		end
	end
end

local function fireNearbyPrompts()
	local char = localPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local playerPos = root.Position
	local currentRooms = workspace:FindFirstChild("CurrentRooms")
	if not currentRooms then return end

	for _, room in currentRooms:GetChildren() do
		if not tonumber(room.Name) then continue end

		local assets = room:FindFirstChild("Assets")
		if not assets then continue end

		for _, furniture in assets:GetDescendants() do
			if furniture.Name == "Dresser" or furniture.Name == "Table" then
				for _, drawerContainer in furniture:GetChildren() do
					if drawerContainer:IsA("Model") or drawerContainer:IsA("Folder") then
						local containerPos = drawerContainer:GetPivot().Position

						if (containerPos - playerPos).Magnitude <= INTERACTION_RANGE then
							firePromptIfValid(drawerContainer, "Knobs", "ActivateEventPrompt")
							firePromptIfValid(drawerContainer, "GoldPile", "LootPrompt")
						end
					end
				end
			end
		end
	end
end

mainTab:AddCheckbox({ Text = "Auto Loot", Default = false, Callback = function(state)
    if fireThread then
        task.cancel(fireThread)
        fireThread = nil
    end

    if state then
        fireThread = task.spawn(function()
            while true do
                fireNearbyPrompts()
                task.wait(0.3)
            end
        end)
    end
end })

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local AURA_NAMES = {
    "ActivateEventPrompt",
    "AwesomePrompt",
    "FusesPrompt",
    "HerbPrompt",
    "LeverPrompt",
    "LootPrompt",
    "ModulePrompt",
    "SkullPrompt",
    "UnlockPrompt",
    "ValvePrompt",
}

local AUTO_DISTANCE = 12
local MAX_INTERACTIONS = 2

local lootables = {}
local childAddedConn = nil
local childRemovedConn = nil
local autoThread = nil
local isActive = false

local function getDistance(obj)
    local char = localPlayer.Character
    if not char then return math.huge end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return math.huge end
    return (obj:GetPivot().Position - root.Position).Magnitude
end

local function tryAddLootable(prompt)
    if not prompt:IsA("ProximityPrompt") or prompt.Name == "Groundskeeper" then return end
    if table.find(AURA_NAMES, prompt.Name) then
        if not table.find(lootables, prompt) then
            table.insert(lootables, prompt)
        end
    end
end

local function removeLootable(prompt)
    for i = #lootables, 1, -1 do
        if lootables[i] == prompt then
            table.remove(lootables, i)
            break
        end
    end
end

local function autoFireLoop()
    while isActive do
        for _, prompt in ipairs(lootables) do
            if not prompt or not prompt.Parent then continue end
            if table.find(AURA_NAMES, prompt.Name) then
                local interactions = prompt:GetAttribute("Interactions")
                if interactions == nil or interactions <= MAX_INTERACTIONS then
                    if getDistance(prompt.Parent) <= AUTO_DISTANCE then
                        if fireproximityprompt then
                            fireproximityprompt(prompt)
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end

mainTab:AddCheckbox({ Text = "Auto Everything (Aura)", Default = false, Callback = function(state)
    isActive = state
    if state then
        lootables = {}

        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                tryAddLootable(v)
            end
        end

        childAddedConn = workspace.DescendantAdded:Connect(function(v)
            if v:IsA("ProximityPrompt") then
                tryAddLootable(v)
            end
        end)
        childRemovedConn = workspace.DescendantRemoving:Connect(function(v)
            removeLootable(v)
        end)

        autoThread = task.spawn(autoFireLoop)
    else
        if childAddedConn then
            childAddedConn:Disconnect()
            childAddedConn = nil
        end
        if childRemovedConn then
            childRemovedConn:Disconnect()
            childRemovedConn = nil
        end
        lootables = {}
    end
end })

visualTab:AddCheckbox({ Text = "FullBright", Default = false, Callback = function(state)
    local Lighting = game:GetService("Lighting")

    if state then
        if not _G.OldBright then
            _G.OldBright = {
                Brightness = Lighting.Brightness,
                ClockTime = Lighting.ClockTime,
                FogEnd = Lighting.FogEnd,
                GlobalShadows = Lighting.GlobalShadows,
                OutdoorAmbient = Lighting.OutdoorAmbient
            }
        end

        _G.FullBright = true
        task.spawn(function()
            while _G.FullBright do
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
                Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                task.wait()
            end

            for prop, value in pairs(_G.OldBright) do
                Lighting[prop] = value
            end
        end)
    else
        _G.FullBright = false
    end
end })

local noFogBtn = visualTab:AddButton({ Text = "No Fog", Callback = function()
    local Lighting = game:GetService("Lighting")

    if _G.NoFogActive then
        _G.NoFogActive = false
        Lighting.FogStart = _G.OldFogStart or 0
        Lighting.FogEnd = _G.OldFogEnd or 1000
        for _, v in ipairs(Lighting:GetChildren()) do
            if v.ClassName == "Atmosphere" then
                v.Density = 0.3
                v.Haze = 1
            end
        end
        return
    end

    _G.OldFogStart = Lighting.FogStart
    _G.OldFogEnd = Lighting.FogEnd

    _G.NoFogActive = true

    task.spawn(function()
        while _G.NoFogActive do
            Lighting.FogStart = 100000
            Lighting.FogEnd = 200000
            for _, v in ipairs(Lighting:GetChildren()) do
                if v.ClassName == "Atmosphere" then
                    v.Density = 0
                    v.Haze = 0
                end
            end
            task.wait()
        end

        Lighting.FogStart = _G.OldFogStart or 0
        Lighting.FogEnd = _G.OldFogEnd or 1000
        for _, v in ipairs(Lighting:GetChildren()) do
            if v.ClassName == "Atmosphere" then
                v.Density = 0.3
                v.Haze = 1
            end
        end
    end)
end })
noFogBtn:SetIcon("rbxassetid://6031094678")

local tamb = main:AddTab({ Name = "Bypass" })

tamb:AddCheckbox({ Text = "Auto Get Code Library", Default = false, Callback = function(enabled)
    _G.NotifyEntity = enabled
    if enabled then
        local function Deciphercode(v)
            local Hints = game.Players.LocalPlayer.PlayerGui:WaitForChild("PermUI"):WaitForChild("Hints")
            local code = {[1] = "_", [2] = "_", [3] = "_", [4] = "_", [5] = "_"}
            for i, v in pairs(v:WaitForChild("UI"):GetChildren()) do
                if v:IsA("ImageLabel") and v.Name ~= "Image" then
                    for b, n in pairs(Hints:GetChildren()) do
                        if n:IsA("ImageLabel") and n.Visible and v.ImageRectOffset == n.ImageRectOffset then
                            code[tonumber(v.Name)] = n:FindFirstChild("TextLabel").Text
                        end
                    end
                end
            end
            return code
        end

        local function CodeAll(v)
            if v:IsA("Tool") and v.Name == "LibraryHintPaper" then
                local code = table.concat(Deciphercode(v))
                if code then
                    main:Notify({Title = "Code: " .. code, Duration = 5})
                    if _G.NotifyEntityChat then
                        local TextChat = _G.ChatNotify or ""
                        if TextChat ~= "" then
                            game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(TextChat .. code)
                        end
                    end
                    if workspace:FindFirstChild("Padlock") and Distance(workspace.Padlock:GetPivot().Position) <= 30 then
                        if game:GetService("ReplicatedStorage"):FindFirstChild("RemotesFolder") then
                            game:GetService("ReplicatedStorage"):WaitForChild("RemotesFolder"):WaitForChild("LP"):FireServer(code)
                        end
                    end
                end
            end
        end

        Getpaper = game.Players.LocalPlayer.Character.ChildAdded:Connect(function(child)
            CodeAll(child)
        end)
    else
        if Getpaper then
            Getpaper:Disconnect()
            Getpaper = nil
        end
    end
end })

Screech = false
ClutchHeart = false

local old
old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if tostring(self) == "Screech" and method == "FireServer" and Screech == true then
        args[1] = true
        return old(self, unpack(args))
    end

    if tostring(self) == "ClutchHeartbeat" and method == "FireServer" and ClutchHeart == true then
        args[2] = true
        return old(self, unpack(args))
    end

    return old(self, ...)
end))

workspace.DescendantAdded:Connect(function(v)
    if v:IsA("Model") and v.Name == "Screech" then
        v:Destroy()
    end
end)

tamb:AddCheckbox({ Text = "Anti Screech", Default = false, Callback = function(state)
    Screech = state
    _G.AntiScreech = state
end })

tamb:AddCheckbox({ Text = "Auto Clutch Heart Win", Default = false, Callback = function(state)
    ClutchHeart = state
end })

tamb:AddCheckbox({ Text = "Anti Halt", Default = false, Callback = function(state)
    _G.NoHalt = state
    local HaltShade = EntityModules:FindFirstChild("Shade") or EntityModules:FindFirstChild("_Shade")
    if HaltShade then
        HaltShade.Name = state and "_Shade" or "Shade"
    end
end })

tamb:AddCheckbox({ Text = "Anti Eyes / Lookman", Default = false, Callback = function(state)
    _G.NoEyes = state
    if state then
        task.spawn(function()
            while _G.NoEyes do
                if workspace:FindFirstChild("Eyes") or workspace:FindFirstChild("BackdoorLookman") then
                    local remotesFolder = game:GetService("ReplicatedStorage"):FindFirstChild("RemotesFolder")
                    if remotesFolder then
                        local motorReplication = remotesFolder:FindFirstChild("MotorReplication")
                        if motorReplication then
                            motorReplication:FireServer(-649)
                        end
                    end
                end
                task.wait()
            end
        end)
    end
end })

tamb:AddCheckbox({ Text = "Inf Oxygen", Default = false, Callback = function(state)
    _G.ActiveInfOxygen = state
    if state then
        task.spawn(function()
            while _G.ActiveInfOxygen do
                local char = game.Players.LocalPlayer.Character
                if char and char:GetAttribute("Oxygen") then
                    char:SetAttribute("Oxygen", 99999)
                end
                task.wait()
            end
            local char = game.Players.LocalPlayer.Character
            if char and char:GetAttribute("Oxygen") then
                char:SetAttribute("Oxygen", 100)
            end
        end)
    else
        local char = game.Players.LocalPlayer.Character
        if char and char:GetAttribute("Oxygen") then
            char:SetAttribute("Oxygen", 100)
        end
    end
end })

local tambmb = main:AddTab({ Name = "Misc" })

tambmb:AddMultiSelectDropdown({
    Text = "Choose Entity",
    Items = {"Rush", "Seek", "Eyes", "Window", "LookMan", "Giggle", "GloombatSwarm", "Ambush", "A-60", "A-120"},
    Defaults = {"Rush"},
    Callback = function(selected)
        _G.EntityChoose = selected
    end
})

tambmb:AddCheckbox({ Text = "Notification Entity", Default = false, Callback = function(state)
    _G.NotifyEntity = state
    if state then
        EntityChild = workspace.ChildAdded:Connect(function(child)
            if not _G.EntityChoose then return end
            for _, v in ipairs(_G.EntityChoose) do
                if child:IsA("Model") and child.Name:find(v) then
                    repeat task.wait() until not child:IsDescendantOf(workspace)
                        or (game.Players.LocalPlayer:DistanceFromCharacter(child:GetPivot().Position) < 1000)
                    if child:IsDescendantOf(workspace) then
                        main:Notify({Title = v .. " Spawn!!", Description = "Be carefull, hide, dont look at it, run.", Duration = 5})
                        if _G.NotifyEntityChat then
                            local text = _G.ChatNotify or ""
                            game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(text .. v .. " Spawn!!")
                        end
                    end
                end
            end
        end)
    else
        if EntityChild then
            EntityChild:Disconnect()
            EntityChild = nil
        end
    end
end })

local FakeScreech = Instance.new("RemoteEvent", RemotesFolder)
FakeScreech.Name = "Screech_"
local FakeA90 = Instance.new("RemoteEvent", RemotesFolder)
FakeA90.Name = "A90_"
local Surge = Instance.new("RemoteEvent", ReplicatedStorage)
Surge.Name = "SurgeRemote"

local gotToggled = false
local gotToggled2 = false

local section = mainTab:AddCollapsible({ Title = "Bypasses" })

section:AddCheckbox({ Text = "Anti Screech Damage", Default = false, Callback = function(enabled)
    if enabled then
        gotToggled = true
        RemotesFolder.Screech.Name = "Screech_"
        FakeScreech.Name = "Screech"
    else
        if gotToggled then
            RemotesFolder["Screech_"].Name = "Screech"
            FakeScreech.Name = "Screech_"
        end
    end
end })

section:AddCheckbox({ Text = "Anti A90 Damage", Default = false, Callback = function(enabled)
    if enabled then
        gotToggled2 = true
        RemotesFolder.A90.Name = "A90_"
        FakeA90.Name = "A90"
    else
        if gotToggled2 then
            RemotesFolder["A90_"].Name = "A90"
            FakeA90.Name = "A90_"
        end
    end
end })

section:AddCheckbox({ Text = "Anti Dread", Default = false, Callback = function(enabled)
    local Dread = LocalPlayer:FindFirstChild("Dread", true) or LocalPlayer:FindFirstChild("_Dread", true)
    if Dread then
        Dread.Name = enabled and "_Dread" or "Dread"
    end
end })

section:AddCheckbox({ Text = "Anti Halt", Default = false, Callback = function(enabled)
    local Shade = ClientModules.EntityModules:FindFirstChild("Shade", true) or ClientModules.EntityModules:FindFirstChild("_Shade", true)
    if Shade then
        Shade.Name = enabled and "_Shade" or "Shade"
    end
end })

section:AddCheckbox({ Text = "Anti Jamming", Default = false, Callback = function(enabled)
    if ReplicatedStorage:FindFirstChild("LiveModifiers") and ReplicatedStorage.LiveModifiers:FindFirstChild("Jammin") then
        local Jam = LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.Health.Jam
        Jam.Playing = not enabled
        local Jamming = game:GetService("SoundService").Main.Jamming
        Jamming.Enabled = not enabled
    end
end })

section:AddCheckbox({ Text = "Anti Surge Damage", Default = false, Callback = function(enabled)
    if enabled then
        if RemotesFolder:FindFirstChild("SurgeRemote") then
            RemotesFolder.SurgeRemote.Parent = ReplicatedStorage
            Surge.Parent = RemotesFolder
        end
    else
        if RemotesFolder:FindFirstChild("SurgeRemote") then
            ReplicatedStorage.SurgeRemote.Parent = RemotesFolder
            Surge.Parent = ReplicatedStorage
        end
    end
end })

section:AddCheckbox({ Text = "Anti Snare", Default = false, Callback = function(enabled)
    for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
        if v.Name == "Snare" then
            local waitTime = 0
            repeat
                task.wait(0.01)
                waitTime = waitTime + 0.01
            until waitTime > 2 or v:FindFirstChild("Hitbox")
            if v:FindFirstChild("Hitbox") then
                v.Hitbox.CanTouch = not enabled
            end
        end
    end
end })

section:AddCheckbox({ Text = "Anti Giggle", Default = false, Callback = function(enabled)
    if Floor.Value == "Fools" and RemotesFolder.Name == "Bricks" then
        return
    end

    for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do
        if v.Name == "GiggleCeiling" then
            local waitTime = 0
            repeat
                task.wait(0.01)
                waitTime = waitTime + 0.01
            until waitTime > 2 or v:FindFirstChild("Hitbox")
            if v:FindFirstChild("Hitbox") then
                v.Hitbox.CanTouch = not enabled
            end
        end
    end
end })

local tab123 = mainTab:AddCollapsible({ Title = "LocalPlayer" })

local LocalPlayer = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local BypassEnabled = false
local BypassMethod = "Method 1"
local MovementSpeed = 15
local MovementEnabled = false

local Params = RaycastParams.new()
Params.FilterType = Enum.RaycastFilterType.Exclude
local Direction = Vector3.new(0, -100, 0)

local CollisionClone = nil
local Passed = false

tab123:AddCheckbox({ Text = "Speed Bypass", Default = false, Callback = function(state)
    BypassEnabled = state
    print("[UI] BypassEnabled =", state)
end })

tab123:AddDropdown({
    Text = "Speed Bypass Method",
    Items = {"Method 1", "Method 2"},
    Default = "Method 1",
    Callback = function(selected)
        BypassMethod = selected
        print("[UI] BypassMethod =", selected)
    end
})

tab123:AddSlider({
    Text = "Movement Speed",
    Min = 15,
    Max = 75,
    Default = 15,
    Callback = function(value)
        MovementSpeed = value
        if MovementEnabled then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = (not BypassEnabled and value > 21) and 21 or value
            end
        end
    end
})

tab123:AddCheckbox({ Text = "Enable Movement Speed", Default = false, Callback = function(enabled)
    MovementEnabled = enabled
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then
        hum.WalkSpeed = enabled and ((not BypassEnabled and MovementSpeed > 21) and 21 or MovementSpeed) or 15
    end
end })

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then
        CollisionClone = nil
        return
    end

    local existingClone = char:FindFirstChild("CollisionClone")
    if not existingClone then
        local cp = char:FindFirstChild("CollisionPart")
        if cp then
            local clone = cp:Clone()
            clone.Parent = char
            clone.Name = "CollisionClone"
            clone.RootPriority = 127
            clone.Anchored = false
            clone.CanCollide = false
            local crouch = clone:FindFirstChild("CollisionCrouch")
            if crouch then crouch:Destroy() end
            CollisionClone = clone
            print("[Clone] Created CollisionClone")
        end
    else
        CollisionClone = existingClone
    end
end)

task.spawn(function()
    while task.wait(BypassMethod == "Method 1" and 0 or 0.209) do
        if BypassMethod == "Method 1" then
            if BypassEnabled and CollisionClone then
                CollisionClone.Massless = true
                RemotesFolder.Crouch:FireServer(true, true)
            end
        elseif BypassMethod == "Method 2" then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if LocalPlayer:GetAttribute("Alive") and hrp and CollisionClone and CollisionClone.Parent then
                Params.FilterDescendantsInstances = {char, CollisionClone}

                if not Workspace:Raycast(hrp.Position, Direction, Params) or not BypassEnabled then
                    CollisionClone.Massless = true
                else
                    local cp = char:FindFirstChild("CollisionPart")
                    if cp and (cp.Anchored or Passed) then
                        CollisionClone.Massless = true
                        repeat task.wait() until not cp.Anchored or not cp.Parent
                        if CollisionClone and CollisionClone.Parent then
                            CollisionClone.Massless = true
                            task.wait(0.5)
                            if CollisionClone and CollisionClone.Parent then
                                CollisionClone.Massless = false
                            end
                        end
                    else
                        if LocalPlayer:GetAttribute("Alive") then CollisionClone.Massless = true end
                        task.wait(0.209)
                        if LocalPlayer:GetAttribute("Alive") and CollisionClone and CollisionClone.Parent then
                            CollisionClone.Massless = false
                        end
                    end
                end
            end
        end
    end
end)
