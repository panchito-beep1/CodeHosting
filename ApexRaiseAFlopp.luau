local Axiom = loadstring(game:HttpGet("https://raw.githubusercontent.com/panchito-beep1/Axiom/refs/heads/main/AxiomV6"))()

local win = Axiom.new({
    Title = "Raise A Floppa 2 | Apex | 1.0",
    Size = UDim2.new(0, 680, 0, 640)
})

win:EnableStateSaving({ Folder = "Floppa", Filename = "config.json" })

local RunService        = game:GetService("RunService")
local player            = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local TweenService      = game:GetService("TweenService")

local Events           = ReplicatedStorage:WaitForChild("Events")
local Cooking          = Events:WaitForChild("Cooking")
local SmallVaultRemote = Events:WaitForChild("Small Vault")
local CollectRent      = Events:WaitForChild("Collect Rent")
local RaiseRent        = Events:WaitForChild("Raise Rent")

local SmallVault   = ReplicatedStorage:WaitForChild("Small Vault")
local Stove        = Workspace:WaitForChild("Key Parts"):WaitForChild("Stove")
local OvenFire     = Stove:WaitForChild("Oven"):WaitForChild("Fire")
local Village      = Workspace:WaitForChild("Village")
local FoodMarket   = Village:WaitForChild("FoodMarket")
local Floppa       = Workspace:WaitForChild("Floppa")

local RECIPES = {
    ["cake"] = {
        Temp = 1,
        Ingredients = {"Sugar", "Flour", "Eggs", "Milk"},
        MarketPrompts = {"Sugar Crate", "Flour Crate"},
        SecondPrompt = "Eggs"
    },
    ["burger"] = {
        Temp = 2,
        Ingredients = {"Bread", "Lettuce", "Tomato", "Beef"},
        MarketPrompts = {"Bread Crate"},
        SecondPrompt = "Beef"
    },
    ["grilled cheese"] = {
        Temp = 3,
        Ingredients = {"Bread", "Cheese"},
        MarketPrompts = {"Bread Crate"},
        SecondPrompt = "Cheese"
    },
    ["vege soup"] = {
        Temp = 1,
        Ingredients = {"Noodles", "Lettuce", "Carrot"},
        MarketPrompts = {},
        SecondPrompt = "Noodles"
    }
}

local ALL_INGREDIENTS = {"Sugar", "Flour", "Eggs", "Milk", "Bread", "Lettuce", "Tomato", "Beef", "Cheese", "Noodles", "Carrot"}
local RecipeNames = {"cake", "burger", "grilled cheese", "vege soup"}

local State = {
    AutoCook = false,
    AutoCookDelay = 5,
    LastCookStatus = "Ready",
    FarmSpeed = 0.5,
    SelectedRecipe = "cake",
    LastCookTime = 0,
    ESPFloppa = false,
    ESPStove = false,
    LetFloppaEat = false,
    EatDuration = 60,
    PetPausedUntil = 0
}

local CookHistory = {}
local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear)
local STOVE_CFRAME = CFrame.new(-55.510318756103516, 73.39999389648438, -61.347320556640625)

local function tweenTo(cf)
    local char = player.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    TweenService:Create(hrp, tweenInfo, {CFrame = cf}):Play()
    return true
end

local function hasIngredient(name)
    local char = player.Character
    if char and char:FindFirstChild(name) then return true end
    local bp = player.Backpack
    if bp and bp:FindFirstChild(name) then return true end
    return false
end

local function grabFromVault(name)
    if SmallVault:FindFirstChild(name) then
        pcall(function() SmallVaultRemote:FireServer(SmallVault[name]) end)
        return true
    end
    return false
end

local function doCook(recipeName, force)
    local recipe = RECIPES[recipeName:lower()]
    if not recipe then return false end

    if not player.Character then return false end
    State.LastCookStatus = "Preparing: " .. recipeName

    local missing = {}
    if not force then
        for _, ing in ipairs(recipe.Ingredients) do
            if not hasIngredient(ing) then
                if not grabFromVault(ing) then
                    table.insert(missing, ing)
                end
            end
        end
    end

    if #missing > 0 then
        win:Notify({ Title = "Missing", Description = table.concat(missing, ", "), Type = "error" })
        State.LastCookStatus = "Missing: " .. table.concat(missing, ", ")
        return false
    end

    tweenTo(CFrame.new(49.959228515625, 71.71173095703125, -120.59715270996094))
    task.wait(0.5)

    for _, promptName in ipairs(recipe.MarketPrompts) do
        pcall(function()
            local crate = FoodMarket[promptName]
            if crate and crate.Crate and crate.Crate["Empty Display Crate"] and crate.Crate["Empty Display Crate"].Primary then
                fireproximityprompt(crate.Crate["Empty Display Crate"].Primary.ProximityPrompt)
            end
        end)
    end

    tweenTo(CFrame.new(58.760929107666016, 69.59998321533203, -117.23761749267578))
    task.wait(0.5)

    pcall(function()
        if FoodMarket[recipe.SecondPrompt] then
            fireproximityprompt(FoodMarket[recipe.SecondPrompt].ProximityPrompt)
        end
    end)

    tweenTo(STOVE_CFRAME)
    task.wait(0.5)

    Cooking:FireServer("Change Temperature", recipe.Temp)
    for _, ing in ipairs(recipe.Ingredients) do
        Cooking:FireServer("Add Ingredient", ing)
    end
    Cooking:FireServer("Cook")

    State.LastCookStatus = "Cooking: " .. recipeName
    State.LastCookTime = os.clock()

    table.insert(CookHistory, 1, {Recipe = recipeName, Time = os.date("%X")})
    if #CookHistory > 15 then table.remove(CookHistory) end
    return true
end

local mainTab = win:AddTab({ Name = "Dashboard" })

local cookDiv = mainTab:AddDivision({ Title = "Cooking Controls" })
cookDiv:AddDropdown({
    Text = "Recipe",
    Items = RecipeNames,
    Default = "cake",
    StateKey = "selectedRecipe",
    Callback = function(v) State.SelectedRecipe = v end
})
cookDiv:AddCheckbox({ Text = "Auto Cook", Default = false, StateKey = "autoCook", Callback = function(v) State.AutoCook = v end })
cookDiv:AddSlider({ Text = "Auto Delay", Min = 1, Max = 15, Default = 5, StateKey = "autoCookDelay", Callback = function(v) State.AutoCookDelay = v end })
local cookProgress = cookDiv:AddProgressBar({ Text = "Cook Progress", Default = 0, Height = 20 })
local cookBtns = cookDiv:AddLayout({ Style = "Horizontal", Size = UDim2.new(1, 0, 0, 24), Padding = 6 })
cookBtns:AddButton({ Text = "Cook", Size = UDim2.new(0, 80, 1, 0), Callback = function() doCook(State.SelectedRecipe) end })
cookBtns:AddButton({ Text = "Force Cook", Size = UDim2.new(0, 100, 1, 0), Callback = function() doCook(State.SelectedRecipe, true) end })

local farmDiv = mainTab:AddDivision({ Title = "Farming Controls" })
farmDiv:AddCheckbox({ Text = "Auto Collect Rent", Default = false, StateKey = "autoCollect", Callback = function(v) end })
farmDiv:AddCheckbox({ Text = "Auto Raise Rent", Default = false, StateKey = "autoRaise", Callback = function(v) end })
farmDiv:AddCheckbox({ Text = "Auto Click Floppa", Default = false, StateKey = "autoClick", Callback = function(v) end })
farmDiv:AddCheckbox({ Text = "Auto Pet Floppa", Default = false, StateKey = "autoPet", Callback = function(v) end })

farmDiv:AddSection({ Text = "Floppa Feeding" })
local letEatCb
letEatCb = farmDiv:AddCheckbox({ Text = "Let Floppa Eat (Pause Pet)", Default = false, StateKey = "letFloppaEat", Callback = function(v)
    State.LetFloppaEat = v
    if v then
        State.PetPausedUntil = os.clock() + State.EatDuration
        win:Notify({ Title = "Floppa", Description = "Auto Pet paused for " .. State.EatDuration .. "s", Type = "info" })
    else
        State.PetPausedUntil = 0
    end
end })

farmDiv:AddSlider({ Text = "Eat Duration (Seconds)", Min = 30, Max = 180, Default = 60, StateKey = "eatDuration", Callback = function(v)
    State.EatDuration = v
    if State.LetFloppaEat then
        State.PetPausedUntil = os.clock() + v
    end
end })

local petStatusLabel = farmDiv:AddLabel({ Text = "Pet Status: Idle" })

farmDiv:AddSlider({ Text = "Farm Speed", Min = 0.1, Max = 2, Default = 0.5, Float = true, Decimals = 2, StateKey = "farmSpeed", Callback = function(v) State.FarmSpeed = v end })
local clickGraph = farmDiv:AddGraph({ Title = "Clicks/sec", MaxPoints = 60, LineColor = Color3.fromRGB(160, 80, 255), Height = 80 })

local playerDiv = mainTab:AddDivision({ Title = "Player Mods" })
playerDiv:AddSlider({ Text = "WalkSpeed", Min = 16, Max = 200, Default = 16, StateKey = "walkspeed", Callback = function(v)
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = v end
end })
playerDiv:AddSlider({ Text = "JumpPower", Min = 16, Max = 200, Default = 50, StateKey = "jumppower", Callback = function(v)
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = v end
end })
playerDiv:AddButton({ Text = "TP to Stove", Callback = function() tweenTo(STOVE_CFRAME) end })
playerDiv:AddButton({ Text = "TP to Market", Callback = function() tweenTo(CFrame.new(49.959228515625, 71.71173095703125, -120.59715270996094)) end })
playerDiv:AddButton({ Text = "TP to Floppa", Callback = function() 
    local hrp = Floppa:FindFirstChild("HumanoidRootPart")
    if hrp then tweenTo(hrp.CFrame * CFrame.new(0, 3, 0)) end
end })

local visualDiv = mainTab:AddDivision({ Title = "Visuals & Tools" })
visualDiv:AddCheckbox({ Text = "ESP Floppa", Default = false, StateKey = "espFloppa", Callback = function(v)
    State.ESPFloppa = v
    if not v then
        local h = Floppa:FindFirstChild("ESP_Highlight")
        if h then h:Destroy() end
    end
end })
visualDiv:AddCheckbox({ Text = "ESP Stove", Default = false, StateKey = "espStove", Callback = function(v)
    State.ESPStove = v
    if not v then
        local h = Stove:FindFirstChild("ESP_Highlight")
        if h then h:Destroy() end
    end
end })
visualDiv:AddKeybindPicker({ Text = "Panic Key", Default = "RightShift", Toggle = false, Callback = function()
    State.AutoCook = false
    State.ESPFloppa = false
    State.ESPStove = false
    State.LetFloppaEat = false
    State.PetPausedUntil = 0
    win:Notify({ Title = "PANIC", Description = "All automations stopped", Type = "error" })
end })

local invDiv = mainTab:AddDivision({ Title = "Inventory (Backpack)" })
local invLabels = {}
for _, ing in ipairs(ALL_INGREDIENTS) do
    invLabels[ing] = invDiv:AddLabel({ Text = ing .. ": ..." })
end

local vaultDiv = mainTab:AddDivision({ Title = "Vault Stock" })
local vaultLabels = {}
for _, ing in ipairs(ALL_INGREDIENTS) do
    vaultLabels[ing] = vaultDiv:AddLabel({ Text = ing .. ": ..." })
end

local historyDiv = mainTab:AddDivision({ Title = "Cook History" })
local historyTable = historyDiv:AddTable({
    Headers = { "Recipe", "Time" },
    Rows = {},
    MaxHeight = 180,
    RowHeight = 22
})

task.spawn(function()
    if getconnections then
        for _, conn in pairs(getconnections(player.Idled)) do
            conn:Disable()
        end
    end
end)

player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    local ws = win._stateRegistry and win._stateRegistry["walkspeed"]
    local jp = win._stateRegistry and win._stateRegistry["jumppower"]
    if ws then
        local v = ws.get()
        if v then hum.WalkSpeed = v end
    end
    if jp then
        local v = jp.get()
        if v then hum.JumpPower = v end
    end
end)

local clickCount = 0
task.spawn(function()
    while task.wait(State.FarmSpeed) do
        local reg = win._stateRegistry or {}
        local function flag(name)
            local entry = reg[name]
            if not entry then return false end
            local ok, v = pcall(entry.get)
            return ok and v == true
        end
        
        if flag("autoCollect") then pcall(function() CollectRent:FireServer() end) end
        if flag("autoRaise") then pcall(function() RaiseRent:FireServer() end) end
        if flag("autoClick") then 
            pcall(function()
                if fireclickdetector then fireclickdetector(Floppa.ClickDetector) end
                clickCount = clickCount + 1
            end)
        end
        
        if flag("autoPet") and os.clock() >= State.PetPausedUntil then
            pcall(function()
                local hrp = Floppa:FindFirstChild("HumanoidRootPart")
                local char = player.Character
                if hrp and char then
                    local chrp = char:FindFirstChild("HumanoidRootPart")
                    if chrp then chrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 3) end
                    if fireproximityprompt then fireproximityprompt(hrp.ProximityPrompt) end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        for _, ing in ipairs(ALL_INGREDIENTS) do
            local inv = hasIngredient(ing)
            if invLabels[ing] then
                invLabels[ing]:SetText(ing .. ": " .. (inv and "<font color='#5FD38D'>✔ Owned</font>" or "<font color='#FF6060'>✘ Missing</font>"))
            end
            
            if vaultLabels[ing] then
                local inVault = SmallVault:FindFirstChild(ing)
                vaultLabels[ing]:SetText(ing .. ": " .. (inVault and "<font color='#FACC15'>✔ In Vault</font>" or "<font color='#FF6060'>✘ Empty</font>"))
            end
        end
        
        if State.LetFloppaEat and os.clock() < State.PetPausedUntil then
            local left = math.ceil(State.PetPausedUntil - os.clock())
            petStatusLabel:SetText("Pet Status: <font color='#FFAA00'>Paused (" .. left .. "s)</font>")
        else
            if State.LetFloppaEat then
                State.LetFloppaEat = false
                State.PetPausedUntil = 0
                if letEatCb then letEatCb:SetValue(false) end
            end
            petStatusLabel:SetText("Pet Status: <font color='#5FD38D'>Active</font>")
        end
    end
end)

OvenFire:GetPropertyChangedSignal("Enabled"):Connect(function()
    if State.AutoCook and not OvenFire.Enabled then
        task.wait(State.AutoCookDelay)
        if State.AutoCook and not OvenFire.Enabled then
            doCook(State.SelectedRecipe, false)
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
    while task.wait(1) do
        local display = {}
        for _, h in ipairs(CookHistory) do table.insert(display, {h.Recipe, h.Time}) end
        pcall(function() historyTable:SetData(display) end)
    end
end)

task.spawn(function()
    while task.wait(1) do
        pcall(function() clickGraph:Push(clickCount) end)
        clickCount = 0
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if State.ESPFloppa and not Floppa:FindFirstChild("ESP_Highlight") then
            local h = Instance.new("Highlight")
            h.Name = "ESP_Highlight"
            h.FillColor = Color3.fromRGB(255, 80, 80)
            h.OutlineColor = Color3.fromRGB(255, 255, 255)
            h.Parent = Floppa
        end
        if State.ESPStove and not Stove:FindFirstChild("ESP_Highlight") then
            local h = Instance.new("Highlight")
            h.Name = "ESP_Highlight"
            h.FillColor = Color3.fromRGB(80, 255, 80)
            h.OutlineColor = Color3.fromRGB(255, 255, 255)
            h.Parent = Stove
        end
    end
end)

pcall(function() win:LoadState() end)
