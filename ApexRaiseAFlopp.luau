local Axiom = loadstring(game:HttpGet("https://raw.githubusercontent.com/panchito-beep1/Axiom/refs/heads/main/AxiomV6"))()

local win = Axiom.new({
    Title = "Raise A Floppa 2 | Apex | 3.0",
    Size = UDim2.new(0, 500, 0, 550)
})

win:EnableStateSaving({ Folder = "RaiseAFloppa", Filename = "config.json" })

local RunService        = game:GetService("RunService")
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local UserInputService  = game:GetService("UserInputService")
local VirtualUser       = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Events      = ReplicatedStorage:WaitForChild("Events")
local CookingRemote = Events:WaitForChild("Cooking")
local UnlockRemote  = Events:WaitForChild("Unlock")
local SmallVaultRemote = Events:FindFirstChild("Small Vault")
local SmallVault   = ReplicatedStorage:FindFirstChild("Small Vault")

local Stove        = Workspace:WaitForChild("Key Parts"):WaitForChild("Stove")
local OvenFire     = Stove:WaitForChild("Oven"):WaitForChild("Fire")
local Floppa       = Workspace:WaitForChild("Floppa")
local SeedsFolder  = Workspace:WaitForChild("Seeds")
local UnlocksFolder = Workspace:WaitForChild("Unlocks")
local MsFloppa     = UnlocksFolder:WaitForChild("Ms. Floppa")
local FoodMarket   = Workspace.Village.FoodMarket
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")
local FloppaUI     = PlayerGui:WaitForChild("FloppaUI")
local PercentageLabel = FloppaUI.Frame.Floppa.Happiness.Percentage

for _, obj in ipairs(Workspace:GetDescendants()) do
    if obj:IsA("ProximityPrompt") then obj.RequiresLineOfSight = false end
end
for _, obj in ipairs(Workspace:GetDescendants()) do
    if obj:IsA("ClickDetector") then obj.MaxActivationDistance = 9e9 end
end

local OldVoidHeight = Workspace.FallenPartsDestroyHeight

local State = {
    SpeedHack = false, WalkSpeed = 16,
    JumpPowerHack = false, JumpPower = 50,
    Noclip = false, Fly = false, FlySpeed = 60,
    InfiniteJump = false, AntiAFK = false,
    InstantPrompts = false, DisableVoid = false,
    ClickFloppa = false, BabyFloppas = false,
    AutoPet = false, HappinessThreshold = 50,
    LetEat = false, EatDuration = 60, PetPausedUntil = 0,
    AutoDefeat = false,
    CollectMoney = false, CollectGold = false, CollectGems = false,
    CollectMilk = false, CollectSeeds = false, CollectMeteorites = false,
    CollectPoops = false, CollectCrystals = false,
    StealDragonEgg = false, ElGatoParty = false,
    Altar = false, ChargeFloppa = false,
    AutoCook = false, CookDelay = 5, SelectedRecipe = "Grilled Cheese",
    ESPFloppa = false, ESPMsFloppa = false, ESPBabyFloppa = false,
    ESPSeeds = false, ESPMeteorite = false,
    AutoFish = false, FishBlacklist = {},
    ShopItem = "", ShopAmount = 1,
    MuteBills = false
}

local CFrames = {
    Stove      = CFrame.new(-53.4228821, 73.4000092, -61.1771812, 0.999941468, 4.78427431e-08, 0.0108202631, -4.73167248e-08, 1, -4.88701701e-08, -0.0108202631, 4.83553286e-08, 0.999941468),
    Market1    = CFrame.new(49.959228515625, 71.71173095703125, -120.59715270996094),
    Market2    = CFrame.new(58.760929107666016, 69.59998321533203, -117.23761749267578),
    Altar      = CFrame.new(-44.3424339, 55.4200172, -42.0363045, 0.00314115011, 1.24433583e-07, -0.999995053, -3.77266351e-09, 1, 1.24422357e-07, 0.999995053, 3.38181572e-09, 0.00314115011),
    ElGato     = CFrame.new(-78.794281, 73.4000092, -41.9453812, -0.00663209474, 1.63774274e-08, 0.999978006, -9.71405854e-08, 1, -1.70220478e-08, -0.999978006, -9.72513376e-08, -0.00663209474),
    Converter  = CFrame.new(-44.1373291, 110.500015, -62.5137863, 0.999993026, -1.48757948e-08, 0.00373192248, 1.4920424e-08, 1, -1.19307177e-08, -0.00373192248, 1.19863159e-08, 0.999993026),
    DragonEgg  = CFrame.new(5155.99561, -4805.07764, -59343.168, -0.22484614, -0.750962377, 0.620886266, -2.46128593e-08, 0.637202263, 0.77069658, -0.974394262, 0.173288137, -0.143272489),
    AfterEgg   = CFrame.new(-60.7250023, 73.4000092, -41.9992981, 0.999988079, 1.9830372e-08, -0.00488542765, -2.006343e-08, 1, -4.7655945e-08, 0.00488542765, 4.77533959e-08, 0.999988079),
    Reactor    = CFrame.new(-63.1073875, 91.7352219, -114.954048, 0.99960041, 9.17594676e-08, 0.0282677151, -9.0649074e-08, 1, -4.05628988e-08, -0.0282677151, 3.79842469e-08, 0.99960041),
    ToxicGoo   = CFrame.new(-45.8120689, 91.4000168, -116.740303, 0.693651736, 9.65794733e-09, -0.720310569, 6.28898267e-09, 1, 1.94642595e-08, 0.720310569, -1.80314377e-08, 0.693651736),
    FishSpot   = CFrame.new(-41.3120956, 69.5935898, 37.4599171, -0.999871075, 0, -0.0160569679, 0, 1, 0, 0.0160569679, 0, -0.999871075)
}

local Teleports = {
    ["Rent Guy"]              = CFrame.new(-77.209549, 73.4000092, -41.8216248, -0.0136132091, 0, -0.999907315, 0, 1, 0, 0.999907315, 0, -0.0136132091),
    ["Roof"]                  = CFrame.new(-42.1624832, 145.400024, -42.0087891, -0.0146608381, -8.3999268e-08, -0.999892533, 1.00862922e-10, 1, -8.40097769e-08, 0.999892533, -1.33250577e-09, -0.0146608381),
    ["House"]                 = CFrame.new(-60.7250023, 73.4000092, -41.9992981, 0.999988079, 1.9830372e-08, -0.00488542765, -2.006343e-08, 1, -4.7655945e-08, 0.00488542765, 4.77533959e-08, 0.999988079),
    ["Watering Can Shop"]     = CFrame.new(36.6954918, 69.1000214, -95.8595734, 0.00418849709, -4.57559146e-08, -0.999991238, -2.09726299e-08, 1, -4.58441605e-08, 0.999991238, 2.1164464e-08, 0.00418849709),
    ["Sword Shop"]            = CFrame.new(34.4367142, 69.6000214, -139.268768, -0.25409469, -1.74380013e-08, -0.967179358, -1.97459773e-08, 1, -1.28421416e-08, 0.967179358, 1.58347806e-08, -0.25409469),
    ["Food Shop"]             = CFrame.new(58.6328392, 69.5999985, -119.327972, 0.872580528, -9.26338188e-08, 0.488470227, 7.08403576e-08, 1, 6.30947312e-08, -0.488470227, -2.04518287e-08, 0.872580528),
    ["Lemonade Stand"]        = CFrame.new(-5.89272404, 69.0935898, -109.667778, 0.00313977525, 3.51277336e-08, 0.999995053, -2.76596861e-08, 1, -3.50410616e-08, -0.999995053, -2.75495289e-08, 0.00313977525),
    ["Computer"]              = CFrame.new(-47.8897476, 73.4000092, -40.8341026, 0.0108212391, -1.03630535e-08, -0.999941468, 3.04304315e-08, 1, -1.00343467e-08, 0.999941468, -3.03200629e-08, 0.0108212391),
    ["Outside"]               = CFrame.new(-21.487957, 68.5935898, -52.9398956, 0.000348773785, 1.61803602e-08, 0.99999994, 6.62653621e-09, 1, -1.6182673e-08, -0.99999994, 6.63217969e-09, 0.000348773785),
    ["Basement"]              = CFrame.new(-64.9342499, 55.4000168, -43.1095963, -0.0169861279, 1.53852771e-08, -0.999855697, 3.49273357e-08, 1, 1.47941304e-08, 0.999855697, -3.46710003e-08, -0.0169861279),
    ["Second Floor"]          = CFrame.new(-58.1133461, 91.4000168, -41.8777542, 0.00523509458, 0, 0.999986291, 0, 1, 0, -0.999986291, 0, 0.00523509458),
    ["Room (2nd Floor)"]      = CFrame.new(-68.2723312, 91.4000168, -98.1589966, -0.00383815751, -8.55764597e-08, -0.999992609, -4.77865001e-08, 1, -8.53936726e-08, 0.999992609, 4.74583928e-08, -0.00383815751),
    ["Third Floor"]           = CFrame.new(-59.3578835, 110.500015, -41.95158, 0.00732855452, 0, 0.999973118, 0, 1, 0, -0.999973118, 0, 0.00732855452),
    ["Moon"]                  = CFrame.new(-42175.7188, 528.936157, -82.662674, 0.929988742, -1.45854342e-08, 0.367588013, 3.26767768e-08, 1, -4.29926921e-08, -0.367588013, 5.19943093e-08, 0.929988742),
    ["DJ El Gato"]            = CFrame.new(-78.794281, 73.4000092, -41.9453812, -0.00663209474, 1.63774274e-08, 0.999978006, -9.71405854e-08, 1, -1.70220478e-08, -0.999978006, -9.72513376e-08, -0.00663209474),
    ["Cellar"]                = CFrame.new(-71.616478, 35.9000168, -41.3364449, 0.0254750568, -3.57637582e-08, -0.999675453, 7.03165304e-09, 1, -3.55961802e-08, 0.999675453, -6.12255624e-09, 0.0254750568),
    ["Ascend"]                = CFrame.new(6520.71924, -341.600006, -1.83147562, 0.999638855, 1.18989441e-08, 0.0268737935, -1.29397506e-08, 1, 3.85555055e-08, -0.0268737935, -3.8889322e-08, 0.999638855)
}

local Recipes = {
    ["Grilled Cheese"] = { Ingredients = {{"Bread", 1}, {"Cheese", 1}}, Temp = 3, Market1 = {"Bread Crate"}, Market2 = "Cheese" },
    ["Vegetable Soup"] = { Ingredients = {{"Noodle", 1}, {"Carrot", 1}, {"Lettuce", 1}}, Temp = 1, Market1 = {}, Market2 = "Noodles" },
    ["Burger"]         = { Ingredients = {{"Bread", 1}, {"Lettuce", 1}, {"Tomato", 1}, {"Beef", 1}}, Temp = 2, Market1 = {"Bread Crate"}, Market2 = "Beef" },
    ["Cake"]           = { Ingredients = {{"Eggs", 1}, {"Milk", 1}, {"Flour", 1}, {"Sugar", 1}}, Temp = 1, Market1 = {"Sugar Crate", "Flour Crate"}, Market2 = "Eggs" },
    ["Space Soup"]     = { Ingredients = {{"Meteorite", 2}, {"Carrot", 1}, {"Noodle", 1}}, Temp = 1, Market1 = {}, Market2 = "Noodles" },
    ["Mega Breakfast"] = { Ingredients = {{"Dragon Egg", 1}, {"Beef", 3}}, Temp = 3, Market1 = {}, Market2 = "Beef" }
}

local function safeFirePrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled and prompt.Parent then
        pcall(function() fireproximityprompt(prompt) end)
    end
end

local function getHRP()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function teleportTo(cf)
    local hrp = getHRP()
    if hrp and cf then
        hrp.CFrame = cf
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
end

local function hasIngredient(name)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild(name) then return true end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp and bp:FindFirstChild(name) then return true end
    return false
end

local function grabFromVault(name)
    if SmallVault and SmallVaultRemote and SmallVault:FindFirstChild(name) then
        pcall(function() SmallVaultRemote:FireServer(SmallVault[name]) end)
        return true
    end
    return false
end

local function countIngredient(name)
    local count = 0
    local char = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == name then count = count + 1 end
        end
    end
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool.Name == name then count = count + 1 end
        end
    end
    return count
end

local function hasIngredients(recipeName)
    local data = Recipes[recipeName]
    if not data then return false, {} end
    local missing = {}
    for _, itemInfo in ipairs(data.Ingredients) do
        local name, needed = itemInfo[1], itemInfo[2]
        if countIngredient(name) < needed then
            table.insert(missing, {Name = name, Need = needed - countIngredient(name)})
        end
    end
    return #missing == 0, missing
end

local function buyFromMarket(recipeName)
    local data = Recipes[recipeName]
    if not data then return end
    
    teleportTo(CFrames.Market1)
    task.wait(0.5)
    
    for _, promptName in ipairs(data.Market1 or {}) do
        pcall(function()
            local crate = FoodMarket[promptName]
            if crate and crate.Crate and crate.Crate["Empty Display Crate"] and crate.Crate["Empty Display Crate"].Primary then
                fireproximityprompt(crate.Crate["Empty Display Crate"].Primary.ProximityPrompt)
            end
        end)
        task.wait(0.1)
    end
    
    teleportTo(CFrames.Market2)
    task.wait(0.5)
    
    if data.Market2 then
        pcall(function()
            local obj = FoodMarket[data.Market2]
            if obj and obj:FindFirstChild("ProximityPrompt") then
                fireproximityprompt(obj.ProximityPrompt)
            end
        end)
        task.wait(0.2)
    end
end

local function cookRecipe(recipeName, force)
    local data = Recipes[recipeName]
    if not data then return false end
    if not LocalPlayer.Character then return false end

    for _, itemInfo in ipairs(data.Ingredients) do
        local name, needed = itemInfo[1], itemInfo[2]
        while countIngredient(name) < needed do
            if not grabFromVault(name) then break end
            task.wait(0.1)
        end
    end

    buyFromMarket(recipeName)
    task.wait(0.5)

    local ok, missing = hasIngredients(recipeName)
    if not ok and not force then
        local names = {}
        for _, m in ipairs(missing) do table.insert(names, m.Name) end
        win:Notify({ Title = "Missing", Description = table.concat(names, ", "), Type = "error" })
        return false
    end

    teleportTo(CFrames.Stove)
    task.wait(0.3)

    local hum = getHum()
    for _, itemInfo in ipairs(data.Ingredients) do
        local name, amount = itemInfo[1], itemInfo[2]
        for i = 1, amount do
            local bp = LocalPlayer:FindFirstChild("Backpack")
            local char = LocalPlayer.Character
            local tool = (bp and bp:FindFirstChild(name)) or (char and char:FindFirstChild(name))
            if tool and hum then
                hum:EquipTool(tool)
                task.wait(0.1)
                safeFirePrompt(Stove.Parts.Primary.ProximityPrompt)
                task.wait(0.1)
            end
        end
    end

    CookingRemote:FireServer("Change Temperature", data.Temp)
    task.wait(0.05)
    CookingRemote:FireServer("Cook")
    win:Notify({ Title = "Cooking", Description = recipeName, Type = "success" })
    return true
end

local function addESP(model, color)
    if not model or not model.Parent then return end
    if model:FindFirstChild("ESP_Highlight") then return end
    local hl = Instance.new("Highlight")
    hl.Name = "ESP_Highlight"
    hl.Adornee = model
    hl.FillColor = color
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = model
end

local function removeESP(model)
    if not model then return end
    local h = model:FindFirstChild("ESP_Highlight")
    if h then h:Destroy() end
end

local loadScreen = win:ShowLoadingScreen({ Title = "Loading Raise A Floppa 2..." })
task.spawn(function()
    loadScreen:SetProgress(25, "Loading modules")
    task.wait(0.5)
    loadScreen:SetProgress(55, "Binding remotes")
    task.wait(0.5)
    loadScreen:SetProgress(85, "Starting UI")
    task.wait(0.5)
    loadScreen:SetProgress(100, "Ready!")
    win._mainFrame.Visible = true
    win._screen.Enabled = true
end)

local mainTab = win:AddTab({ Name = "Dashboard" })

local statsDiv = mainTab:AddDivision({ Title = "Live Monitor" })
local moneyLabel = statsDiv:AddLabel({ Text = "Money: ..." })
local goldLabel = statsDiv:AddLabel({ Text = "Gold: ..." })
local happinessLabel = statsDiv:AddLabel({ Text = "Happiness: ..." })
local happinessBar = statsDiv:AddProgressBar({ Text = "Happiness", Min = 0, Max = 100, Default = 0, Height = 20 })
local faithLabel = statsDiv:AddLabel({ Text = "Faith: ..." })
local faithBar = statsDiv:AddProgressBar({ Text = "Faith", Min = 0, Max = 100, Default = 0, Height = 20 })

local playerDiv = mainTab:AddDivision({ Title = "Player Mods" })
playerDiv:AddCheckbox({ Text = "Speed Hack", Default = false, StateKey = "speedHack", Callback = function(v)
    State.SpeedHack = v
    local hum = getHum()
    if hum then hum.WalkSpeed = v and State.WalkSpeed or 16 end
end })
playerDiv:AddSlider({ Text = "Walk Speed", Min = 16, Max = 250, Default = 16, StateKey = "walkspeed", Callback = function(v)
    State.WalkSpeed = v
    local hum = getHum()
    if hum and State.SpeedHack then hum.WalkSpeed = v end
end })
playerDiv:AddCheckbox({ Text = "Jump Power", Default = false, StateKey = "jumpPower", Callback = function(v)
    State.JumpPowerHack = v
    local hum = getHum()
    if hum then hum.JumpPower = v and State.JumpPower or 50 end
end })
playerDiv:AddSlider({ Text = "Jump Power Amount", Min = 50, Max = 250, Default = 50, StateKey = "jumppower", Callback = function(v)
    State.JumpPower = v
    local hum = getHum()
    if hum and State.JumpPowerHack then hum.JumpPower = v end
end })

playerDiv:AddSection({ Text = "Movement" })
playerDiv:AddCheckbox({ Text = "Noclip", Default = false, StateKey = "noclip", Callback = function(v) State.Noclip = v end })
playerDiv:AddCheckbox({ Text = "Fly", Default = false, StateKey = "fly", Callback = function(v) State.Fly = v end })
playerDiv:AddSlider({ Text = "Fly Speed", Min = 10, Max = 250, Default = 60, StateKey = "flySpeed", Callback = function(v) State.FlySpeed = v end })
playerDiv:AddCheckbox({ Text = "Infinite Jump", Default = false, StateKey = "infiniteJump", Callback = function(v) State.InfiniteJump = v end })

playerDiv:AddSection({ Text = "Misc" })
playerDiv:AddCheckbox({ Text = "Anti-AFK", Default = false, StateKey = "antiAFK", Callback = function(v) State.AntiAFK = v end })
playerDiv:AddCheckbox({ Text = "Instant Prompts", Default = false, StateKey = "instantPrompts", Callback = function(v)
    State.InstantPrompts = v
    if v then
        for _, p in ipairs(Workspace:GetDescendants()) do
            if p:IsA("ProximityPrompt") then p.HoldDuration = 0 end
        end
    end
end })
playerDiv:AddCheckbox({ Text = "Disable Void", Default = false, StateKey = "disableVoid", Callback = function(v)
    State.DisableVoid = v
    Workspace.FallenPartsDestroyHeight = v and -math.huge or OldVoidHeight
end })

local petDiv = mainTab:AddDivision({ Title = "Floppa Petting" })
petDiv:AddCheckbox({ Text = "Auto Pet (Happiness)", Default = false, StateKey = "autoPet", Callback = function(v) State.AutoPet = v end })
petDiv:AddSlider({ Text = "Happiness Threshold", Min = 5, Max = 90, Default = 50, StateKey = "happinessThreshold", Callback = function(v) State.HappinessThreshold = v end })
petDiv:AddCheckbox({ Text = "Let Floppa Eat (Pause)", Default = false, StateKey = "letEat", Callback = function(v)
    State.LetEat = v
    if v then
        State.PetPausedUntil = os.clock() + State.EatDuration
        win:Notify({ Title = "Floppa", Description = "Pet paused for " .. State.EatDuration .. "s", Type = "info" })
    else
        State.PetPausedUntil = 0
    end
end })
petDiv:AddSlider({ Text = "Eat Duration (s)", Min = 30, Max = 180, Default = 60, StateKey = "eatDuration", Callback = function(v)
    State.EatDuration = v
    if State.LetEat then State.PetPausedUntil = os.clock() + v end
end })
local petStatusLabel = petDiv:AddLabel({ Text = "Pet: Idle" })

local farmDiv = mainTab:AddDivision({ Title = "Auto Farm" })
farmDiv:AddCheckbox({ Text = "Click Floppa", Default = false, StateKey = "clickFloppa", Callback = function(v) State.ClickFloppa = v end })
farmDiv:AddCheckbox({ Text = "Baby Floppas", Default = false, StateKey = "babyFloppas", Callback = function(v) State.BabyFloppas = v end })
farmDiv:AddCheckbox({ Text = "Auto Defeat Enemies", Default = false, StateKey = "autoDefeat", Callback = function(v) State.AutoDefeat = v end })

local collectDiv = mainTab:AddDivision({ Title = "Auto Collect" })
collectDiv:AddCheckbox({ Text = "Money", Default = false, StateKey = "collectMoney", Callback = function(v) State.CollectMoney = v end })
collectDiv:AddCheckbox({ Text = "Gold", Default = false, StateKey = "collectGold", Callback = function(v) State.CollectGold = v end })
collectDiv:AddCheckbox({ Text = "Gems", Default = false, StateKey = "collectGems", Callback = function(v) State.CollectGems = v end })
collectDiv:AddCheckbox({ Text = "Milk", Default = false, StateKey = "collectMilk", Callback = function(v) State.CollectMilk = v end })
collectDiv:AddCheckbox({ Text = "Seeds", Default = false, StateKey = "collectSeeds", Callback = function(v) State.CollectSeeds = v end })
collectDiv:AddCheckbox({ Text = "Meteorites", Default = false, StateKey = "collectMeteorites", Callback = function(v) State.CollectMeteorites = v end })
collectDiv:AddCheckbox({ Text = "Poops", Default = false, StateKey = "collectPoops", Callback = function(v) State.CollectPoops = v end })

local unlockDiv = mainTab:AddDivision({ Title = "Auto Unlocks" })
unlockDiv:AddCheckbox({ Text = "Crystals", Default = false, StateKey = "collectCrystals", Callback = function(v) State.CollectCrystals = v end })
unlockDiv:AddCheckbox({ Text = "Steal Dragon Egg", Default = false, StateKey = "stealDragonEgg", Callback = function(v) State.StealDragonEgg = v end })
unlockDiv:AddCheckbox({ Text = "El Gato Party", Default = false, StateKey = "elGatoParty", Callback = function(v) State.ElGatoParty = v end })
unlockDiv:AddCheckbox({ Text = "Auto Charge Floppa", Default = false, StateKey = "chargeFloppa", Callback = function(v) State.ChargeFloppa = v end })

local altarDiv = mainTab:AddDivision({ Title = "Auto Altar" })
altarDiv:AddCheckbox({ Text = "Auto Altar", Default = false, StateKey = "autoAltar", Callback = function(v) State.Altar = v end })
altarDiv:AddLabel({ Text = "Faith increases to 100, then waits for reset." })

local cookDiv = mainTab:AddDivision({ Title = "Auto Cook" })
cookDiv:AddDropdown({ Text = "Recipe", Items = {"Grilled Cheese", "Vegetable Soup", "Burger", "Cake", "Space Soup", "Mega Breakfast"}, Default = "Grilled Cheese", StateKey = "selectedRecipe", Callback = function(v) State.SelectedRecipe = v end })
local ingredientLabel = cookDiv:AddLabel({ Text = "Ingredients: ..." })
cookDiv:AddButton({ Text = "Cook Now", Callback = function() cookRecipe(State.SelectedRecipe) end })
cookDiv:AddButton({ Text = "Force Cook", Callback = function() cookRecipe(State.SelectedRecipe, true) end })
cookDiv:AddCheckbox({ Text = "Auto Cook", Default = false, StateKey = "autoCook", Callback = function(v) State.AutoCook = v end })
cookDiv:AddSlider({ Text = "Auto Cook Delay", Min = 1, Max = 15, Default = 5, StateKey = "cookDelay", Callback = function(v) State.CookDelay = v end })
local cookProgress = cookDiv:AddProgressBar({ Text = "Cook Progress", Min = 0, Max = 100, Default = 0, Height = 20 })

local espDiv = mainTab:AddDivision({ Title = "ESPs" })
espDiv:AddCheckbox({ Text = "Floppa", Default = false, StateKey = "espFloppa", Callback = function(v)
    State.ESPFloppa = v
    if v then addESP(Floppa, Color3.fromRGB(255, 80, 80)) else removeESP(Floppa) end
end })
espDiv:AddCheckbox({ Text = "Ms. Floppa", Default = false, StateKey = "espMsFloppa", Callback = function(v)
    State.ESPMsFloppa = v
    if v then addESP(MsFloppa, Color3.fromRGB(251, 116, 168)) else removeESP(MsFloppa) end
end })
espDiv:AddCheckbox({ Text = "Baby Floppas", Default = false, StateKey = "espBabyFloppa", Callback = function(v)
    State.ESPBabyFloppa = v
    for _, obj in ipairs(UnlocksFolder:GetChildren()) do
        if obj.Name == "Baby Floppa" then
            if v then addESP(obj, Color3.fromRGB(0, 115, 187)) else removeESP(obj) end
        end
    end
end })
espDiv:AddCheckbox({ Text = "Seeds", Default = false, StateKey = "espSeeds", Callback = function(v)
    State.ESPSeeds = v
    for _, seed in ipairs(SeedsFolder:GetChildren()) do
        if v then addESP(seed, Color3.fromRGB(255, 255, 0)) else removeESP(seed) end
    end
end })
espDiv:AddCheckbox({ Text = "Meteorites", Default = false, StateKey = "espMeteorite", Callback = function(v)
    State.ESPMeteorite = v
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Tool") and obj.Name == "Meteorite" then
            if v then addESP(obj, Color3.fromRGB(255, 140, 0)) else removeESP(obj) end
        end
    end
end })

SeedsFolder.ChildAdded:Connect(function(seed)
    if State.ESPSeeds then
        task.wait(0.2)
        addESP(seed, Color3.fromRGB(255, 255, 0))
    end
end)

Workspace.ChildAdded:Connect(function(obj)
    if State.ESPMeteorite and obj:IsA("Tool") and obj.Name == "Meteorite" then
        task.wait(0.2)
        addESP(obj, Color3.fromRGB(255, 140, 0))
    end
end)

UnlocksFolder.ChildAdded:Connect(function(obj)
    if State.ESPBabyFloppa and obj.Name == "Baby Floppa" then
        task.wait(0.2)
        addESP(obj, Color3.fromRGB(0, 115, 187))
    end
end)

local utilDiv = mainTab:AddDivision({ Title = "Utilities" })
utilDiv:AddButton({ Text = "Clean All Poops", Callback = function()
    local hrp = getHRP()
    if not hrp then return end
    for _, a in ipairs(Workspace:GetDescendants()) do
        if a:IsA("ProximityPrompt") and a.Parent and a.Parent.Name == "Poop" then
            hrp.CFrame = a.Parent.WorldPivot + Vector3.new(0, 3, 0)
            task.wait(0.25)
            safeFirePrompt(a)
            task.wait(0.25)
        end
    end
end })
utilDiv:AddButton({ Text = "Collect All Seeds", Callback = function()
    local hrp = getHRP()
    if not hrp then return end
    for _, v in ipairs(SeedsFolder:GetDescendants()) do
        if v.Name == "Seed" and v:IsA("BasePart") then
            hrp.CFrame = v.CFrame
            task.wait(0.2)
        end
        if v:IsA("ProximityPrompt") then
            task.wait(0.05)
            safeFirePrompt(v)
        end
    end
end })
utilDiv:AddButton({ Text = "Collect All Meteorites", Callback = function()
    local hrp = getHRP()
    if not hrp then return end
    for _, v in ipairs(Workspace:GetChildren()) do
        if v.Name == "Meteorite" and v:IsA("Tool") then
            hrp.CFrame = v.WorldPivot
            task.wait(0.1)
        end
    end
end })
utilDiv:AddButton({ Text = "Buy Floppa Food", Callback = function()
    UnlockRemote:FireServer("Floppa Food", "the_interwebs")
end })

local tpDiv = mainTab:AddDivision({ Title = "Teleports" })
local tpNames = {}
for name in pairs(Teleports) do table.insert(tpNames, name) end
table.sort(tpNames)
tpDiv:AddDropdown({ Text = "Location", Items = tpNames, Default = "House", StateKey = "tpLocation", Callback = function() end })
tpDiv:AddButton({ Text = "Teleport", Callback = function()
    local reg = win._stateRegistry["tpLocation"]
    local loc = reg and reg.get and reg.get() or "House"
    teleportTo(Teleports[loc])
end })

local fishDiv = mainTab:AddDivision({ Title = "Auto Fishing" })
fishDiv:AddCheckbox({ Text = "Enable Auto Fish", Default = false, StateKey = "autoFish", Callback = function(v) State.AutoFish = v end })
fishDiv:AddMultiSelectSearchableDropdown({ Text = "Blacklist", Items = {"Fish","Almond Water","Mushroom","Burguer","Milk","Catnip","Space Soup","Money Bag","Treasure","Jumbo Treasure","Speed Potion","Sanity Potion","Carrot Seed","Money Seed","Fungal Spore","Lettuce Seed","Catnip Seed","Space Crystal","Flopptonium","The Big One","Dirty Old Boot","Meteorite","Gift"}, Defaults = {}, StateKey = "fishBlacklist", Callback = function(list)
    State.FishBlacklist = {}
    for _, name in ipairs(list) do State.FishBlacklist[name] = true end
end })

local shopDiv = mainTab:AddDivision({ Title = "Smart Shop" })
local function getUnlocksList()
    local list = {}
    local unlocks = PlayerGui:FindFirstChild("PlayerUI") and PlayerGui.PlayerUI:FindFirstChild("the_interwebs") and PlayerGui.PlayerUI.the_interwebs:FindFirstChild("Unlocks")
    if unlocks then
        for _, child in ipairs(unlocks:GetChildren()) do
            if child:IsA("Frame") then table.insert(list, child.Name) end
        end
    end
    return #list > 0 and list or {"No items found"}
end
local shopDropdown = shopDiv:AddDropdown({ Text = "Item", Items = getUnlocksList(), Default = "No items found", StateKey = "shopItem", Callback = function(v) State.ShopItem = v end })
shopDiv:AddTextBox({ Text = "Amount", Placeholder = "1", Default = "1", StateKey = "shopAmount", Callback = function(v) State.ShopAmount = tonumber(v) or 1 end })
shopDiv:AddButton({ Text = "Refresh List", Callback = function()
    shopDropdown:SetItems(getUnlocksList())
    win:Notify({ Title = "Shop", Description = "Refreshed", Type = "info" })
end })
shopDiv:AddButton({ Text = "Buy Selected", Callback = function()
    local item = State.ShopItem
    local amount = State.ShopAmount
    if not item or item == "No items found" or amount <= 0 then return end
    local unlocks = PlayerGui.PlayerUI.the_interwebs.Unlocks
    local frame = unlocks:FindFirstChild(item)
    if not frame then return end
    local btn = frame:FindFirstChildWhichIsA("TextButton")
    if btn and btn.Text:find("Owned") then
        win:Notify({ Title = "Shop", Description = "Already owned!", Type = "warn" }); return
    end
    local priceFrame = frame:FindFirstChild("Item Price")
    if not priceFrame then return end
    local priceText = priceFrame.Text
    local isGold = priceText:lower():find("gold")
    local currency = isGold and LocalPlayer:FindFirstChild("Gold") or LocalPlayer:FindFirstChild("Money")
    if not currency then return end
    local cleaned = priceText:gsub("Price:", ""):gsub("Gold", ""):gsub("%$", ""):gsub(" ", ""):lower()
    local number = tonumber(cleaned:match("[%d%.]+"))
    if not number then return end
    local mult = 1
    if cleaned:find("k") then mult = 1e3
    elseif cleaned:find("m") then mult = 1e6
    elseif cleaned:find("b") then mult = 1e9
    elseif cleaned:find("t") then mult = 1e12 end
    local totalCost = number * mult * amount
    if currency.Value >= totalCost then
        for i = 1, amount do
            UnlockRemote:FireServer(item, "the_interwebs")
            task.wait(0.05)
        end
        win:Notify({ Title = "Shop", Description = "Bought " .. amount .. "x " .. item, Type = "success" })
    else
        win:Notify({ Title = "Shop", Description = "Not enough currency!", Type = "error" })
    end
end })

local vulnDiv = mainTab:AddDivision({ Title = "Flopptonium Dupe" })
vulnDiv:AddTextBox({ Text = "Amount", Placeholder = "1", Default = "1", StateKey = "dupeAmount", Callback = function() end })
vulnDiv:AddButton({ Text = "Give Flopptonium", Callback = function()
    local hrp = getHRP()
    local reactor = UnlocksFolder:FindFirstChild("Flopptonium Reactor")
    if not reactor or not hrp then return end
    local primary = reactor:FindFirstChild("PRIMARY")
    local cooldown = primary and primary:FindFirstChild("Cooldown")
    if cooldown and cooldown.Value ~= 0 then
        win:Notify({ Title = "Dupe", Description = "Wait for cooldown!", Type = "warn" }); return
    end
    local mainPrompt = primary and primary:FindFirstChild("ProximityPrompt")
    local secondPrompt
    pcall(function() secondPrompt = reactor["Toxic Goo Pile"]["Blood Splater"]:GetChildren()[2].ProximityPrompt end)
    if not mainPrompt or not secondPrompt then return end
    teleportTo(CFrames.ToxicGoo)
    task.wait(0.15)
    safeFirePrompt(secondPrompt)
    task.wait(0.1)
    teleportTo(CFrames.Reactor)
    task.wait(0.15)
    local reg = win._stateRegistry["dupeAmount"]
    local amount = (reg and reg.get and tonumber(reg.get())) or 1
    mainPrompt.HoldDuration = 0
    for i = 1, amount do
        safeFirePrompt(mainPrompt)
        if i % 15 == 0 then task.wait() end
    end
    win:Notify({ Title = "Dupe", Description = "Gave " .. amount .. " flopptonium", Type = "success" })
end })

local settingsDiv = mainTab:AddDivision({ Title = "Settings & Server" })
settingsDiv:AddKeybindPicker({ Text = "Panic Key", Default = "RightShift", Toggle = false, Callback = function()
    for k in pairs(State) do
        if type(State[k]) == "boolean" then State[k] = false end
    end
    State.LetEat = false; State.PetPausedUntil = 0
    win:Notify({ Title = "PANIC", Description = "All automations stopped", Type = "error" })
end })
settingsDiv:AddButton({ Text = "Rejoin Server", Callback = function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end })
settingsDiv:AddPlayerList({ Height = 180, ExcludeLocal = false })
settingsDiv:AddSection({ Text = "Sound" })
settingsDiv:AddCheckbox({ Text = "Mute Money SFX", Default = false, StateKey = "muteBills", Callback = function(v)
    State.MuteBills = v
    for _, snd in ipairs(Workspace:GetDescendants()) do
        if snd:IsA("Sound") and snd.Name == "DollaDollaBills" then
            snd.Volume = v and 0 or 0.2
            if v then snd:Stop() end
        end
    end
end })

local function CheckHappiness()
    if not State.AutoPet then return end
    if os.clock() < State.PetPausedUntil then return end
    local text = PercentageLabel.Text
    local val = tonumber(text:match("(%d+)"))
    if val and val <= State.HappinessThreshold then
        local hrp = getHRP()
        if hrp and Floppa then
            hrp.CFrame = Floppa:GetPivot()
            task.wait(0.1)
            safeFirePrompt(Floppa:FindFirstChild("HumanoidRootPart") and Floppa.HumanoidRootPart:FindFirstChild("ProximityPrompt"))
        end
    end
end
PercentageLabel:GetPropertyChangedSignal("Text"):Connect(CheckHappiness)

task.spawn(function()
    while task.wait(0.5) do
        if State.AutoPet and not (os.clock() < State.PetPausedUntil) then CheckHappiness() end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if State.ClickFloppa and Floppa and Floppa:FindFirstChild("ClickDetector") then
            pcall(function() fireclickdetector(Floppa.ClickDetector) end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if State.BabyFloppas then
            for _, v in ipairs(UnlocksFolder:GetChildren()) do
                if v.Name == "Baby Floppa" and v:FindFirstChild("ClickDetector") then
                    pcall(function() fireclickdetector(v.ClickDetector) end)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if State.AutoDefeat then
            pcall(function()
                local enemyFolder = Workspace:FindFirstChild("Enemies")
                if not enemyFolder then return end
                for _, enemy in ipairs(enemyFolder:GetChildren()) do
                    if not State.AutoDefeat then break end
                    if enemy:IsA("Model") then
                        local ehum = enemy:FindFirstChildOfClass("Humanoid")
                        local target = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChildWhichIsA("BasePart")
                        if ehum and target then
                            while State.AutoDefeat and enemy.Parent and ehum.Health > 0 do
                                local char = LocalPlayer.Character
                                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                                local hum = char and char:FindFirstChildOfClass("Humanoid")
                                if not hrp or not hum then break end
                                local bp = LocalPlayer:FindFirstChild("Backpack")
                                local weapon = char:FindFirstChild("Excalibur") or (bp and bp:FindFirstChild("Excalibur")) or char:FindFirstChild("Sword") or (bp and bp:FindFirstChild("Sword"))
                                if weapon and weapon.Parent ~= char then hum:EquipTool(weapon); task.wait(0.15) end
                                hrp.CFrame = CFrame.new(target.Position - target.CFrame.LookVector * 3, target.Position)
                                hrp.AssemblyLinearVelocity = Vector3.zero
                                local cam = Workspace.CurrentCamera
                                local vp = cam.ViewportSize
                                local cx, cy = vp.X / 2, vp.Y / 2
                                VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
                                task.wait(0.02)
                                VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
                                task.wait(0.1)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if State.CollectMoney then
            local hrp = getHRP()
            if hrp then
                for _, v in ipairs(Workspace:GetChildren()) do
                    if v:IsA("BasePart") and (v.Name == "Money" or v.Name == "Money Bag") then
                        pcall(function()
                            firetouchinterest(hrp, v, 0)
                            firetouchinterest(hrp, v, 1)
                        end)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.CollectGold then
            local hrp = getHRP()
            if hrp then
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("MeshPart") and v.Name:match("Gold") then
                        pcall(function()
                            firetouchinterest(hrp, v, 0)
                            task.wait(0.01)
                            firetouchinterest(hrp, v, 1)
                        end)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if State.CollectGems then
            local hrp = getHRP()
            if hrp then
                local gemNames = {Diamond = true, Emerald = true, Ruby = true, Sapphire = true}
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if obj:IsA("BasePart") and gemNames[obj.Name] then
                        obj.Position = hrp.Position
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if State.CollectMilk then
            local milk = Workspace:FindFirstChild("Milk Delivery")
            local hrp = getHRP()
            if milk and hrp then
                hrp.CFrame = milk.WorldPivot
                task.wait(0.5)
                safeFirePrompt(milk.Crate.ProximityPrompt)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if State.CollectSeeds then
            local hrp = getHRP()
            if hrp then
                for _, v in ipairs(SeedsFolder:GetChildren()) do
                    if v:IsA("BasePart") then
                        pcall(function()
                            hrp.CFrame = v.CFrame
                            task.wait(0.15)
                            if v:FindFirstChildWhichIsA("ProximityPrompt", true) then
                                safeFirePrompt(v:FindFirstChildWhichIsA("ProximityPrompt", true))
                            end
                        end)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if State.CollectMeteorites then
            local hrp = getHRP()
            if hrp then
                for _, v in ipairs(Workspace:GetChildren()) do
                    if v.Name == "Meteorite" and v:IsA("Tool") then
                        hrp.CFrame = v.WorldPivot
                        task.wait(0.1)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if State.CollectPoops then
            local hrp = getHRP()
            if hrp then
                for _, a in ipairs(Workspace:GetDescendants()) do
                    if a:IsA("ProximityPrompt") and a.Parent and a.Parent.Name == "Poop" then
                        hrp.CFrame = a.Parent.WorldPivot + Vector3.new(0, 3, 0)
                        task.wait(0.25)
                        safeFirePrompt(a)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.CollectCrystals then
            local wormhole = UnlocksFolder:FindFirstChild("Wormhole Machine")
            local crystalFolder = wormhole and wormhole:FindFirstChild("Crystal")
            local hrp = getHRP()
            if crystalFolder and hrp then
                for _, crystal in ipairs(crystalFolder:GetChildren()) do
                    if not State.CollectCrystals then break end
                    if crystal:IsA("MeshPart") then
                        hrp.CFrame = crystal.CFrame
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        task.wait(0.2)
                        local prompt = crystal:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then safeFirePrompt(prompt); task.wait(0.3) end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if State.StealDragonEgg then
            pcall(function()
                local au2 = Workspace:FindFirstChild("AU2")
                local nest = au2 and au2:FindFirstChild("Dragon Nest")
                local egg = nest and nest:FindFirstChild("Lava Egg")
                if egg then
                    local hrp = getHRP()
                    if not hrp then return end
                    hrp.CFrame = CFrames.DragonEgg
                    task.wait(0.1)
                    for _, v in ipairs(Workspace:GetDescendants()) do
                        if v:IsA("ProximityPrompt") and v.Parent and v.Parent:IsA("BasePart") then
                            if (hrp.Position - v.Parent.Position).Magnitude <= 30 then safeFirePrompt(v) end
                        end
                    end
                    hrp.CFrame = CFrames.AfterEgg
                    win:Notify({ Title = "Egg", Description = "Stole Dragon Egg", Type = "success" })
                    task.wait(2)
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.ElGatoParty then
            local elgato = UnlocksFolder:FindFirstChild("DJ El Gato")
            if elgato then
                local cooldown = elgato:FindFirstChild("Cooldown")
                local primary = elgato:FindFirstChild("Primary")
                local prompt = primary and primary:FindFirstChildOfClass("ProximityPrompt")
                local hrp = getHRP()
                if cooldown and cooldown:IsA("ValueBase") and cooldown.Value == 0 and hrp then
                    hrp.CFrame = CFrames.ElGato
                    task.wait(0.1)
                    safeFirePrompt(prompt)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.ChargeFloppa then
            local converter = UnlocksFolder:FindFirstChild("Crystal Converter")
            if converter then
                local crystalPart = converter:FindFirstChild("Crystal")
                local primary = converter:FindFirstChild("Primary")
                if crystalPart and crystalPart.Transparency >= 1 then
                    local bp = LocalPlayer:FindFirstChild("Backpack")
                    local tool = bp and bp:FindFirstChild("Space Crystal")
                    local hum = getHum()
                    local hrp = getHRP()
                    if tool and hum and hrp then
                        hum:EquipTool(tool)
                        task.wait(0.1)
                        hrp.CFrame = CFrames.Converter
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        task.wait(0.2)
                        local prompt = primary and primary:FindFirstChild("ProximityPrompt")
                        if prompt then safeFirePrompt(prompt); win:Notify({ Title = "Charged", Description = "Floppa charged", Type = "success" }); task.wait(1) end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if State.Altar then
            local altar = UnlocksFolder:FindFirstChild("Altar")
            if altar then
                local faith = altar:FindFirstChild("Faith")
                local cost = altar:FindFirstChild("Cost")
                local isGold = altar:FindFirstChild("Gold")
                local floppaCube = altar:FindFirstChild("Floppa Cube")
                local cube = floppaCube and floppaCube:FindFirstChild("Floppa cube")
                local prompt = cube and cube:FindFirstChild("ProximityPrompt")
                local money = LocalPlayer:FindFirstChild("Money")
                local gold = LocalPlayer:FindFirstChild("Gold")
                local hrp = getHRP()
                if faith and cost and prompt and hrp then
                    if not (isGold and isGold.Value) then
                        if faith.Value < 100 and money and money.Value >= cost.Value then
                            hrp.CFrame = CFrames.Altar
                            task.wait(0.05)
                            safeFirePrompt(prompt)
                        elseif faith.Value >= 100 then
                            hrp.CFrame = CFrames.Altar
                            task.wait(0.05)
                            safeFirePrompt(prompt)
                            repeat task.wait(1) until faith.Value <= 0 or not State.Altar
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if State.AutoCook and not OvenFire.Enabled then
            task.wait(State.CookDelay)
            if State.AutoCook and not OvenFire.Enabled then
                cookRecipe(State.SelectedRecipe)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        local ok, missing = hasIngredients(State.SelectedRecipe)
        if ok then
            ingredientLabel:SetText("Ingredients: <font color='#5FD38D'>✔ Ready</font>")
        else
            local names = {}
            for _, m in ipairs(missing) do table.insert(names, m.Name) end
            ingredientLabel:SetText("Missing: <font color='#FF6060'>" .. table.concat(names, ", ") .. "</font>")
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        local pct = OvenFire.Enabled and 100 or 0
        pcall(function() cookProgress:SetValue(pct) end)
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        local money = LocalPlayer:FindFirstChild("Money")
        local gold = LocalPlayer:FindFirstChild("Gold")
        moneyLabel:SetText("Money: <font color='#5FD38D'>" .. (money and tostring(money.Value) or "?") .. "</font>")
        goldLabel:SetText("Gold: <font color='#FACC15'>" .. (gold and tostring(gold.Value) or "?") .. "</font>")
        if PercentageLabel then
            local txt = PercentageLabel.Text
            local val = tonumber(txt:match("(%d+)")) or 0
            happinessLabel:SetText("Happiness: <font color='#FB923C'>" .. val .. "%</font>")
            pcall(function() happinessBar:SetValue(val) end)
        end
        local altar = UnlocksFolder:FindFirstChild("Altar")
        local faith = altar and altar:FindFirstChild("Faith")
        if faith then
            faithLabel:SetText("Faith: <font color='#A78BFA'>" .. faith.Value .. "</font>")
            pcall(function() faithBar:SetValue(faith.Value) end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.LetEat and os.clock() < State.PetPausedUntil then
            local left = math.ceil(State.PetPausedUntil - os.clock())
            petStatusLabel:SetText("Pet: <font color='#FACC15'>Paused (" .. left .. "s)</font>")
        else
            if State.LetEat and os.clock() >= State.PetPausedUntil then
                State.LetEat = false
                State.PetPausedUntil = 0
            end
            petStatusLabel:SetText(State.AutoPet and "Pet: <font color='#5FD38D'>Active</font>" or "Pet: Idle")
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if State.Noclip then
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end
end)

local flyBodyVel, flyBodyGyro, flyConn
local function stopFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
    if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
    local hum = getHum()
    if hum then hum.PlatformStand = false end
end

task.spawn(function()
    while task.wait(0.5) do
        if State.Fly and not flyConn then
            local hrp = getHRP()
            if hrp then
                local hum = getHum()
                if hum then hum.PlatformStand = true end
                flyBodyVel = Instance.new("BodyVelocity")
                flyBodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                flyBodyVel.Velocity = Vector3.zero
                flyBodyVel.Parent = hrp
                flyBodyGyro = Instance.new("BodyGyro")
                flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
                flyBodyGyro.P = 1e5
                flyBodyGyro.CFrame = Workspace.CurrentCamera.CFrame
                flyBodyGyro.Parent = hrp
                flyConn = RunService.RenderStepped:Connect(function()
                    if not State.Fly then return end
                    local cam = Workspace.CurrentCamera
                    local moveVec = Vector3.zero
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec += cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec -= cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec -= cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec += cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVec += cam.CFrame.UpVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVec -= cam.CFrame.UpVector end
                    flyBodyVel.Velocity = moveVec.Magnitude > 0 and moveVec.Unit * State.FlySpeed or Vector3.zero
                    flyBodyGyro.CFrame = cam.CFrame
                end)
            end
        elseif not State.Fly and flyConn then
            stopFly()
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    task.wait(0.5)
    if State.SpeedHack then hum.WalkSpeed = State.WalkSpeed end
    if State.JumpPowerHack then hum.JumpPower = State.JumpPower end
end)

-- ════════════════════════════════════════════════════════════════════════════
--  FISHING (FULL LOOP)
-- ════════════════════════════════════════════════════════════════════════════
local FishSpots = {
    CFrames.FishSpot,
    CFrames.FishSpot * CFrame.new(10, 0, 0),
    CFrames.FishSpot * CFrame.new(-10, 0, 0)
}
local currentSpotIndex = 1
local castCounter = 0
local OriginalHipHeight = nil

local function getBestRod()
    local char = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not char or not bp then return nil end
    local rod = char:FindFirstChild("Golden Fishing Rod") or bp:FindFirstChild("Golden Fishing Rod")
        or char:FindFirstChild("Fishing Rod") or bp:FindFirstChild("Fishing Rod")
    if rod then return rod end
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Tool") and v.Name:find("Rod") then return v end
    end
    for _, v in ipairs(bp:GetChildren()) do
        if v:IsA("Tool") and v.Name:find("Rod") then return v end
    end
    return nil
end

local function deleteBlacklistedItems()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not bp then return end
    for _, tool in ipairs(bp:GetChildren()) do
        if State.FishBlacklist[tool.Name] then
            tool:Destroy()
        end
    end
end

local function fishClick()
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    local x, y = vp.X / 2, vp.Y / 2
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    if isMobile then
        VirtualInputManager:SendTouchEvent(0, Enum.UserInputState.Begin, Vector2.new(x, y), nil)
        task.wait(0.05)
        VirtualInputManager:SendTouchEvent(0, Enum.UserInputState.End, Vector2.new(x, y), nil)
    else
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
    end
end

task.spawn(function()
    while true do
        local ok, err = pcall(function()
            if not State.AutoFish then
                if LocalPlayer.Character and OriginalHipHeight then
                    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                    if hum then hum.HipHeight = OriginalHipHeight end
                    OriginalHipHeight = nil
                end
                return
            end

            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            local hum = char:WaitForChild("Humanoid")

            if not OriginalHipHeight then OriginalHipHeight = hum.HipHeight end

            deleteBlacklistedItems()

            local rod = getBestRod()

            if not rod then
                hrp.CFrame = CFrame.new(4.516, 69.6, -128.26)
                task.wait(0.6)
                local npc = Workspace:FindFirstChild("Village") and Workspace.Village.FishStore.NPC
                local prompt = npc and npc.Torso:FindFirstChild("ProximityPrompt")
                safeFirePrompt(prompt)
                task.wait(1.5)
                rod = getBestRod()
                if not rod then return end
            end

            if rod.Parent ~= char then
                hum:EquipTool(rod)
                task.wait(0.25)
            end

            if castCounter >= 2 then
                castCounter = 0
                currentSpotIndex += 1
                if currentSpotIndex > #FishSpots then currentSpotIndex = 1 end
            end

            hrp.CFrame = FishSpots[currentSpotIndex]
            hrp.AssemblyLinearVelocity = Vector3.zero
            task.wait(0.3)

            fishClick()
            castCounter += 1

            while State.AutoFish do
                task.wait(1)
                if rod.Parent ~= char then break end
                local uiVisible = false
                pcall(function()
                    local playerFolder = Workspace:FindFirstChild(LocalPlayer.Name)
                    local rodModel = playerFolder and playerFolder:FindFirstChild(rod.Name)
                    local hook = rodModel and rodModel:FindFirstChild("Hook")
                    local notif = hook and hook:FindFirstChild("Notification")
                    local frame = notif and notif:FindFirstChild("Frame")
                    local label = frame and frame:FindFirstChild("TextLabel")
                    if label and label.Visible then uiVisible = true end
                end)
                if not uiVisible then
                    fishClick()
                else
                    local hook = rod:FindFirstChild("Hook")
                    local sparkles = hook and hook:FindFirstChild("Sparkles")
                    if sparkles and sparkles.Enabled then break end
                end
            end

            fishClick()
            task.wait(1)
        end)
        if not ok then
            warn("AutoFish Loop Error:", err)
            currentSpotIndex = 1
            castCounter = 0
            task.wait(1)
        end
        task.wait(0.1)
    end
end)

pcall(function() win:LoadState() end)
