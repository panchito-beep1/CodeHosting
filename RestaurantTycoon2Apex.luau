local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local instantCookEnabled = false
local origCookProgressRun, origMultiClickStart, origMouseMovementStart, origMouseSpinStart

local function enableInstantCook()
    if instantCookEnabled then return end
    instantCookEnabled = true
    pcall(function()
        local Cooking = game.Players.LocalPlayer.PlayerScripts.CookingNew
        local CookProgress = require(Cooking.CookProgress)
        local MultiClick = require(Cooking.InputDetectors.MultiClick)
        local MouseMovement = require(Cooking.InputDetectors.MouseMovement)
        local MouseSpin = require(Cooking.InputDetectors.MouseSpin)

        origCookProgressRun = CookProgress.run
        CookProgress.run = function(...)
            local ARGS = {...}
            ARGS[3] = 0
            return origCookProgressRun(unpack(ARGS))
        end

        origMultiClickStart = MultiClick.start
        MultiClick.start = function(...)
            ({...})[3]()
        end

        origMouseMovementStart = MouseMovement.start
        MouseMovement.start = function(...)
            ({...})[3]()
        end

        origMouseSpinStart = MouseSpin.start
        MouseSpin.start = function(...)
            ({...})[3]()
        end
    end)
end

local function disableInstantCook()
    if not instantCookEnabled then return end
    instantCookEnabled = false
    pcall(function()
        local Cooking = game.Players.LocalPlayer.PlayerScripts.CookingNew
        local CookProgress = require(Cooking.CookProgress)
        local MultiClick = require(Cooking.InputDetectors.MultiClick)
        local MouseMovement = require(Cooking.InputDetectors.MouseMovement)
        local MouseSpin = require(Cooking.InputDetectors.MouseSpin)

        if origCookProgressRun then CookProgress.run = origCookProgressRun end
        if origMultiClickStart then MultiClick.start = origMultiClickStart end
        if origMouseMovementStart then MouseMovement.start = origMouseMovementStart end
        if origMouseSpinStart then MouseSpin.start = origMouseSpinStart end
    end)
end

repeat task.wait() until game:IsLoaded()
getgenv().antiAfkEnabled = true

if getgenv().antiAfkEnabled then
    for _, v in pairs(getconnections(LocalPlayer.Idled)) do
        v:Disable()
    end
end

local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function()
    repeat task.wait()
        char = LocalPlayer.Character
        if char then
            hum = char:FindFirstChild("Humanoid")
            root = char:FindFirstChild("HumanoidRootPart")
        end
    until char and hum and root
    if getgenv().antiAfkEnabled then
        for _, v in pairs(getconnections(LocalPlayer.Idled)) do
            v:Disable()
        end
    end
end)

local plotWaitStart = os.clock()
repeat
    task.wait()
    for _, tycoon in pairs(Workspace.Tycoons:GetChildren()) do
        if tostring(tycoon.Player.Value) == LocalPlayer.Name then
            getgenv().PlayerPlot = tycoon
            break
        end
    end
    if not getgenv().PlayerPlot and os.clock() - plotWaitStart > 15 then
        warn("[Script Info]: Could not find your restaurant plot after 15s. Make sure you're fully loaded into the game, then re-execute.")
        return
    end
until getgenv().PlayerPlot

local plot = getgenv().PlayerPlot

local statsWaitStart = os.clock()
while not (plot:FindFirstChild("Stats") and plot.Stats:FindFirstChild("IsLoading")) do
    task.wait()
    if os.clock() - statsWaitStart > 10 then
        warn("[Script Info]: Could not find plot.Stats.IsLoading — the game hasn't finished initializing your plot. Re-execute in a moment.")
        return
    end
end

if plot.Stats.IsLoading.Value then
    warn("[Script Info]: Your restaurant is still loading. Waiting up to 60 seconds...")
    local loadWaitStart = os.clock()
    repeat
        task.wait()
        if os.clock() - loadWaitStart > 60 then
            warn("[Script Info]: Restaurant took longer than 60s to load. Aborting — load your restaurant first, then re-execute.")
            return
        end
    until not plot.Stats.IsLoading.Value
    print("[Script Info]: Restaurant loaded successfully.")
end

getgenv().settingsTable = {
    billstoggle = false, dishestoggle = false, takeorders = false,
    deliverfood = false, deliverdrinks = false, seatcustomers = false,
    autocleandishes = false, autoCook = false
}
getgenv().automationDelay = 0.1

local function getClientTycoonInput()
    local events = ReplicatedStorage:FindFirstChild("Events")
    if events then
        local remote = events:FindFirstChild("ClientTycoonInput")
        if remote and remote:IsA("RemoteEvent") then return remote end
    end
    for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
        if desc.Name == "ClientTycoonInput" and desc:IsA("RemoteEvent") then return desc end
    end
    return nil
end
local ClientTycoonInput = getClientTycoonInput()

local Axiom = loadstring(game:HttpGet("https://raw.githubusercontent.com/panchito-beep1/Axiom/refs/heads/main/AxiomV6"))()

local win = Axiom.new({    
    Title = "Apex | Restaurant Tycoon 2 | 1.0",
    Size = UDim2.new(0, 300, 0, 480),
})

win:EnableStateSaving({ Folder = "OVERKILL", Filename = "rt2_config.json" })
win:Notify({ Title = "OVERKILL", Description = "Script loaded successfully.", Type = "success" })

local mainTab = win:AddTab({ Name = "Main" })
local autoTab = win:AddTab({ Name = "Automation" })
local playersTab = win:AddTab({ Name = "Players" })

mainTab:AddMenuBar({
    Menus = {
        { Text = "File", Items = {
            { Text = "Save Config", Callback = function() win:SaveState(); win:Notify({Title="Saved", Description="Config saved", Type="success"}) end },
            { Text = "Load Config", Callback = function() win:LoadState() end }
        }},
        { Text = "Automation", Items = {
            { Text = "Start All", Callback = function()
                for k in pairs(getgenv().settingsTable) do getgenv().settingsTable[k] = true end
                win:Notify({Title="Automation", Description="Started all tasks", Type="info"})
            end },
            { Text = "Stop All", Callback = function()
                for k in pairs(getgenv().settingsTable) do getgenv().settingsTable[k] = false end
                win:Notify({Title="Automation", Description="Stopped all tasks", Type="warn"})
            end }
        }}
    }
})

mainTab:AddSection({ Text = "General" })
mainTab:AddLabel({ Text = "<b>Discord: None yet</b>" })

mainTab:AddCheckbox({ 
    Text = "Instant Cook", 
    Default = false, 
    StateKey = "rt2_instantcook",
    Callback = function(state)
        if state then enableInstantCook() else disableInstantCook() end
    end 
})

mainTab:AddCheckbox({ 
    Text = "Anti-AFK (Disable Idle Kick)", 
    Default = true, 
    StateKey = "rt2_antiafk",
    Callback = function(state)
        getgenv().antiAfkEnabled = state
        if state then
            for _, v in pairs(getconnections(LocalPlayer.Idled)) do v:Disable() end
        end
    end 
})

mainTab:AddSection({ Text = "Panic Key" })
mainTab:AddLabel({ Text = "Press this key to instantly stop all automation." })
mainTab:AddKeybindPicker({
    Text = "Panic Keybind",
    Default = "RightShift",
    Toggle = false,
    Callback = function(key)
        for k in pairs(getgenv().settingsTable) do getgenv().settingsTable[k] = false end
        win:Notify({ Title = "PANIC", Description = "All automation stopped!", Type = "error" })
    end
})

autoTab:AddSection({ Text = "Configuration" })
autoTab:AddLabel({ Text = "Adjust the loop delay. Lower = faster but laggier." })
autoTab:AddDragFloat({
    Text = "Loop Delay",
    Min = 0.05, Max = 3, Default = 0.1, Decimals = 2,
    StateKey = "rt2_delay",
    Callback = function(v)
        getgenv().automationDelay = math.floor(v * 100 + 0.5) / 100
    end
})

autoTab:AddSection({ Text = "Orders" })
autoTab:AddCheckbox({ Text = "Take Orders Automatically", StateKey = "rt2_takeorders", Callback = function(s) getgenv().settingsTable.takeorders = s end })
autoTab:AddCheckbox({ Text = "Seat Customer Automatically", StateKey = "rt2_seatcustomers", Callback = function(s) getgenv().settingsTable.seatcustomers = s end })
autoTab:AddCheckbox({ Text = "Deliver Food Automatically", StateKey = "rt2_deliverfood", Callback = function(s) getgenv().settingsTable.deliverfood = s end })
autoTab:AddCheckbox({ Text = "Deliver Drinks Automatically", StateKey = "rt2_deliverdrinks", Callback = function(s) getgenv().settingsTable.deliverdrinks = s end })

autoTab:AddSection({ Text = "Cooking" })
autoTab:AddCheckbox({ Text = "Auto Cook (Start Cooking)", StateKey = "rt2_autocook", Callback = function(s) getgenv().settingsTable.autoCook = s end })
autoTab:AddCheckbox({ Text = "Auto Clean Dishes", StateKey = "rt2_autoclean", Callback = function(s) getgenv().settingsTable.autocleandishes = s end })

autoTab:AddSection({ Text = "Money" })
autoTab:AddCheckbox({ Text = "Collect Bills, Tips, Drops Automatically", StateKey = "rt2_bills", Callback = function(s) getgenv().settingsTable.billstoggle = s end })
autoTab:AddCheckbox({ Text = "Collect Dishes Automatically", StateKey = "rt2_dishes", Callback = function(s) getgenv().settingsTable.dishestoggle = s end })

playersTab:AddSection({ Text = "Server Players" })
playersTab:AddPlayerList({ Height = 250 })

function SeatCustomers()
    if not ClientTycoonInput then return end
    for _, group in ipairs(plot.Customers:GetChildren()) do
        task.wait(0.05)
        local groupName = group.Name
        local data = group:FindFirstChild("Data")
        if data then
            local seatedAt = data:FindFirstChild("SeatedAt")
            local seatedValue = seatedAt and seatedAt.Value
            if not seatedAt or seatedValue == "" or seatedValue == nil then
                local customers = group:FindFirstChild("Customers")
                if customers then
                    for _, customer in ipairs(customers:GetChildren()) do
                        task.wait(0.05)
                        local customerName = customer.Name
                        for _, surface in ipairs(plot.Items.OftenFiltered.Surface:GetChildren()) do
                            task.wait(0.05)
                            if surface:FindFirstChild("InUse") and not surface.InUse.Value then
                                ClientTycoonInput:FireServer(plot, {
                                    name = "SendToTable", obj = surface, group = groupName,
                                    tycoon = Workspace.Tycoons.Tycoon, customer = customerName
                                })
                            end
                        end
                    end
                end
            end
        end
    end
end

function DeliverDrinks()
    if not ClientTycoonInput then return end
    for _, group in ipairs(plot.Customers:GetChildren()) do
        task.wait(0.05)
        local groupName = group.Name
        local customers = group:FindFirstChild("Customers")
        if customers then
            for _, customer in ipairs(customers:GetChildren()) do
                task.wait(0.05)
                local customerName = customer.Name
                local mealChoice = customer:FindFirstChild("MealChoice")
                if mealChoice then
                    local drink = mealChoice.Value
                    local fridge = plot.Items.OftenFiltered.Kitchen:FindFirstChild("68")
                    if not fridge then break end
                    ReplicatedStorage.Events.RequestGrab:InvokeServer("Fridge", fridge, plot)
                    for _, drinkItem in ipairs(plot.Resources.Drinks:GetChildren()) do
                        if not customer:FindFirstChild(drink) and drink and drink ~= "" and drinkItem.Name == drink then
                            ClientTycoonInput:FireServer(plot, {
                                models = {}, name = "ManageFood", model = drinkItem,
                                customer = customerName, tycoon = plot, group = groupName
                            })
                        end
                    end
                end
            end
        end
    end
end

function DeliverFood()
    if not ClientTycoonInput then return end
    for _, group in ipairs(plot.Customers:GetChildren()) do
        task.wait(0.05)
        local groupName = group.Name
        local customers = group:FindFirstChild("Customers")
        if customers then
            for _, customer in ipairs(customers:GetChildren()) do
                task.wait(0.05)
                local customerName = customer.Name
                local mealChoice = customer:FindFirstChild("MealChoice")
                if mealChoice then
                    local meal = mealChoice.Value
                    for _, surface in ipairs(plot.Items.OftenFiltered.Surface:GetChildren()) do
                        task.wait(0.05)
                        if meal and meal ~= "" then
                            local orderedFoods = surface:FindFirstChild("OrderedFoods")
                            if orderedFoods and orderedFoods:FindFirstChild(meal) then
                                ClientTycoonInput:FireServer(plot, {
                                    models = {orderedFoods[meal]}, name = "ManageFood",
                                    model = orderedFoods[meal], customer = customerName,
                                    tycoon = plot, group = groupName
                                })
                            end
                        end
                    end
                end
            end
        end
    end
end

function TakeOrders()
    if not ClientTycoonInput then return end
    for _, group in ipairs(plot.Customers:GetChildren()) do
        task.wait(0.05)
        local groupName = group.Name
        local customers = group:FindFirstChild("Customers")
        if customers then
            for _, customer in ipairs(customers:GetChildren()) do
                task.wait(0.05)
                ClientTycoonInput:FireServer(plot, {
                    customer = customer.Name, tycoon = plot,
                    name = "ManageCustomers", group = groupName
                })
            end
        end
    end
end

function GetBills()
    if not ClientTycoonInput then return end
    for _, surface in ipairs(plot.Items.OftenFiltered.Surface:GetChildren()) do
        if surface:FindFirstChild("Bill") then
            ClientTycoonInput:FireServer(plot, { name = "CollectBill", model = surface })
        end
    end
    for _, furniture in ipairs(plot.Items.AlwaysFiltered.Furniture:GetChildren()) do
        local jar = furniture:FindFirstChild("Jar")
        if jar and jar.BillboardGui.Frame.Amt.Text ~= "0 Cash" then
            ClientTycoonInput:FireServer(plot, { name = "CollectTip" })
        end
    end
    for _, drop in pairs(Workspace.DropFolder:GetChildren()) do
        if drop:FindFirstChild("TouchInterest") then
            firetouchinterest(root, drop, 0)
            task.wait(0.25)
            firetouchinterest(root, drop, 1)
        end
    end
end

function CollectDishes()
    if not ClientTycoonInput then return end
    for _, surface in ipairs(plot.Items.OftenFiltered.Surface:GetChildren()) do
        if surface:FindFirstChild("Trash") then
            ClientTycoonInput:FireServer(plot, { name = "ClearTrash", model = surface })
        end
    end
end

function AutoCook()
    local function firePromptIfValid(prompt)
        if prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled then
            local parentPart = prompt.Parent
            if parentPart and parentPart:IsA("BasePart") then
                local charRoot = root
                if charRoot and (parentPart.Position - charRoot.Position).Magnitude <= 50 then
                    pcall(function()
                        if fireproximityprompt then fireproximityprompt(prompt) end
                    end)
                    return true
                end
            end
        end
        return false
    end

    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.ActionText == "Cook" then
            if firePromptIfValid(v) then return end
        end
    end

    for _, v in ipairs(plot:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.Enabled and (v.ObjectText == "Cook" or v.ActionText == "Cook") then
            if firePromptIfValid(v) then return end
        end
    end

    local surfaceFolder = plot.Items.OftenFiltered:FindFirstChild("Surface")
    if surfaceFolder then
        for _, surface in ipairs(surfaceFolder:GetChildren()) do
            if not surface:IsA("Model") then continue end
            local inUse = surface:FindFirstChild("InUse")
            if inUse and inUse.Value == true then continue end
            for _, desc in ipairs(surface:GetDescendants()) do
                if desc:IsA("ProximityPrompt") and desc.Enabled then
                    pcall(function()
                        if fireproximityprompt then fireproximityprompt(desc) end
                    end)
                    return
                end
            end
        end
    end

    local kitchenFolder = plot.Items.OftenFiltered:FindFirstChild("Kitchen")
    if not kitchenFolder then return end
    for _, item in ipairs(kitchenFolder:GetChildren()) do
        if not item:IsA("Model") then continue end
        local inUse = item:FindFirstChild("InUse")
        if inUse and inUse.Value == true then continue end
        for _, desc in ipairs(item:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and desc.Enabled then
                pcall(function()
                    if fireproximityprompt then fireproximityprompt(desc) end
                end)
                return
            end
        end
    end
end

function AutoCleanDishes()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.ActionText == "Clean Dishes" and v.Enabled then
            local parentPart = v.Parent
            if parentPart and parentPart:IsA("BasePart") and root then
                if (parentPart.Position - root.Position).Magnitude <= 50 then
                    pcall(function()
                        v:InputHoldBegin(hum)
                        task.wait(1.5)
                        v:InputHoldEnd(hum)
                    end)
                    return
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(getgenv().automationDelay) do
        local s = getgenv().settingsTable
        
        if s.takeorders then TakeOrders() end
        if s.seatcustomers then SeatCustomers() end
        if s.deliverfood then DeliverFood() end
        if s.deliverdrinks then DeliverDrinks() end
        
        if s.autoCook then AutoCook() end
        if s.autocleandishes then AutoCleanDishes() end
        
        if s.billstoggle then GetBills() end
        if s.dishestoggle then CollectDishes() end
    end
end)

pcall(function() win:LoadState() end)
