local Axiom = loadstring(game:HttpGet("https://raw.githubusercontent.com/panchito-beep1/Axiom/refs/heads/main/AxiomV6"))()

local win = Axiom.new({
    Title = "Jump Clicker | Apex | 1.0",
    Size = UDim2.new(0, 500, 0, 480)
})

win:EnableStateSaving({ Folder = "APEX", Filename = "config.json" })

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local clickEvent  = ReplicatedStorage:WaitForChild("IncreaseSpeed")
local rebirthEvent = ReplicatedStorage:WaitForChild("RebirthEvent")
local raceEvent   = ReplicatedStorage:WaitForChild("NPCRace"):WaitForChild("RaceRemote")
local petEvent    = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("PetActionRequest")

local State = {
    AutoClick = false,
    ClickDelay = 0.01,
    AutoRebirth = false,
    AutoRace = false,
    AutoPet = false,
    AutoFollow = false,
    SelectedWorld = "World1"
}

local selectedWorld = "World1"
local tweening = false

local function waitForCharacter()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then
        char = LocalPlayer.CharacterAdded:Wait()
        char:WaitForChild("HumanoidRootPart")
    end
    return char
end

local function tweenToPosition(position, duration)
    duration = duration or 1
    local char = waitForCharacter()
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local goal = CFrame.new(position) * (hrp.CFrame - hrp.CFrame.Position)
    local wasAnchored = hrp.Anchored
    hrp.Anchored = true
    hrp.AssemblyLinearVelocity  = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    local t = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { CFrame = goal })
    t:Play(); t.Completed:Wait()
    hrp.Anchored = wasAnchored
end

local function getWorld(name)
    local wins = workspace:FindFirstChild("Wins")
    return wins and wins:FindFirstChild(name) or nil
end

local function getWorldPosition(obj)
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model")    then return obj:GetPivot().Position end
    return nil
end

local function goToWorld(name, duration)
    duration = duration or 1
    local obj = getWorld(name)
    if not obj then return false end
    local pos = getWorldPosition(obj)
    if not pos then return false end
    tweenToPosition(pos, duration)
    return true
end

local function updateWalkSpeed(v)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
end

local function updateJumpPower(v)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v end
    end
end

local mainTab = win:AddTab({ Name = "Dashboard" })

local coreDiv = mainTab:AddDivision({ Title = "Automation" })
coreDiv:AddCheckbox({ Text = "Enable Fast Auto Clicker", Default = false, StateKey = "autoClick", Callback = function(v)
    State.AutoClick = v
end })
coreDiv:AddSlider({ Text = "Click Delay", Min = 0.001, Max = 0.5, Default = 0.01, Float = true, Decimals = 3, StateKey = "clickDelay", Callback = function(v)
    State.ClickDelay = v
end })
coreDiv:AddCheckbox({ Text = "Auto Rebirth", Default = false, StateKey = "autoRebirth", Callback = function(v)
    State.AutoRebirth = v
end })

local farmDiv = mainTab:AddDivision({ Title = "Farming Controls" })


farmDiv:AddLabel({Text = "OP farm needs the last map to be unlocked."})
farmDiv:AddCheckbox({ Text = "Enable Op Autofarm", Default = false, StateKey = "autoRace", Callback = function(v)
    State.AutoRace = v
end })
farmDiv:AddCheckbox({ Text = "Auto Equip Best Pet", Default = false, StateKey = "autoPet", Callback = function(v)
    State.AutoPet = v
end })
farmDiv:AddCheckbox({ Text = "Auto Farm World", Default = false, StateKey = "autoFollow", Callback = function(v)
    State.AutoFollow = v
end })

local tpDiv = mainTab:AddDivision({ Title = "Teleports & Player" })
tpDiv:AddDropdown({
    Text = "Select World To Farm",
    Items = {"World1", "World2", "World3", "World4", "World5", "World6", "World7", "World8", "World9", "World10", "World11", "World12", "World13", "World14", "World15", "World16", "World17", "World18", "World19"},
    Default = "World1",
    StateKey = "selectedWorld",
    Callback = function(v) selectedWorld = v end
})
tpDiv:AddButton({ Text = "Go To Selected World once", Callback = function()
    goToWorld(selectedWorld, 1)
end })
tpDiv:AddButton({ Text = "Gain 1 win", Callback = function()
    tweenToPosition(Vector3.new(-10240, 1875, 135), 3)
end })
tpDiv:AddSlider({ Text = "WalkSpeed", Min = 16, Max = 200, Default = 16, StateKey = "walkspeed", Callback = updateWalkSpeed })
tpDiv:AddSlider({ Text = "JumpPower", Min = 16, Max = 200, Default = 50, StateKey = "jumppower", Callback = updateJumpPower })

local toolDiv = mainTab:AddDivision({ Title = "Visuals & Tools" })
local espActive = false
local espHighlights = {}

toolDiv:AddCheckbox({ Text = "ESP Worlds (Wins)", Default = false, StateKey = "espWorlds", Callback = function(v)
    espActive = v
    if not v then
        for _, h in pairs(espHighlights) do
            if h and h.Parent then h:Destroy() end
        end
        espHighlights = {}
    end
end })
toolDiv:AddKeybindPicker({ Text = "Panic Key (Stop All)", Default = "RightShift", Toggle = false, Callback = function()
    State.AutoClick = false
    State.AutoRebirth = false
    State.AutoRace = false
    State.AutoPet = false
    State.AutoFollow = false
    local reg = win._stateRegistry
    if reg then
        for _, key in ipairs({"autoClick", "autoRebirth", "autoRace", "autoPet", "autoFollow"}) do
            if reg[key] and reg[key].set then pcall(reg[key].set, false) end
        end
    end
    win:Notify({ Title = "PANIC", Description = "All stopped.", Type = "error" })
end })
toolDiv:AddButton({ Text = "Rejoin Server", Callback = function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end })

task.spawn(function()
    while task.wait(State.ClickDelay) do
        if State.AutoClick then
            pcall(function() clickEvent:FireServer() end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoRebirth then
            pcall(function() rebirthEvent:FireServer() end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if State.AutoRace then
            pcall(function()
                raceEvent:FireServer("Start", "Champion")
                task.wait(6)
                raceEvent:FireServer("Finish", "Champion")
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(5) do
        if State.AutoPet then
            pcall(function()
                petEvent:InvokeServer("EquipBest", { Pets = {} })
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoFollow and not tweening then
            local obj = getWorld(selectedWorld)
            if obj then
                local targetPos = getWorldPosition(obj)
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if targetPos and hrp then
                    if (hrp.Position - targetPos).Magnitude > 5 then
                        tweening = true
                        goToWorld(selectedWorld, 0.4)
                        tweening = false
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if espActive then
            local wins = workspace:FindFirstChild("Wins")
            if wins then
                for _, obj in ipairs(wins:GetChildren()) do
                    if (obj:IsA("BasePart") or obj:IsA("Model")) and not espHighlights[obj] then
                        local h = Instance.new("Highlight")
                        h.FillColor = Color3.fromRGB(160, 80, 255)
                        h.OutlineColor = Color3.fromRGB(255, 255, 255)
                        h.Adornee = obj
                        h.Parent = obj
                        espHighlights[obj] = h
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    if getconnections then
        for _, conn in pairs(getconnections(LocalPlayer.Idled)) do
            conn:Disable()
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    local reg = win._stateRegistry
    if reg then
        if reg["walkspeed"] then
            local v = reg["walkspeed"].get()
            if v then hum.WalkSpeed = v end
        end
        if reg["jumppower"] then
            local v = reg["jumppower"].get()
            if v then hum.JumpPower = v end
        end
    end
end)

pcall(function() win:LoadState() end)
