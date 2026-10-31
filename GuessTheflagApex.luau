local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local LocalPlayer       = Players.LocalPlayer

local Modules = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules")
local Net     = require(Modules:WaitForChild("Net"))
local Images  = require(Modules:WaitForChild("Images"))

local imageMap = {}
for _, v in ipairs(Images) do
    if type(v) == "table" and v.image then
        imageMap[v.image] = v.name
    end
end

local ACCENT = Color3.fromRGB(0, 220, 180)
local DIM    = Color3.fromRGB(120, 120, 130)
local RED    = Color3.fromRGB(255, 60, 60)
local BLUE   = Color3.fromRGB(80, 200, 255)

local Axiom = loadstring(game:HttpGet("https://raw.githubusercontent.com/panchito-beep1/Axiom/refs/heads/main/AxiomV6"))()

local win = Axiom.new({    
    Title = "Guess The Flag | Apex | 3.0" ,     
    Size = UDim2.new(0, 300, 0, 420),
})

local getMyFlag, clickAnswerInUI

local mainTab = win:AddTab({ Name = "Main" })
local autoGuessTab = win:AddTab({ Name = "Auto Guess" })
local settingsTab = win:AddTab({ Name = "Settings" })

local flagImage = mainTab:AddImage({ Image = "", Size = UDim2.new(1, 0, 0, 120), ScaleType = Enum.ScaleType.Fit, BackgroundTransparency = 1, Border = false })
local flagLabel   = mainTab:AddLabel({ Text = "flag   →  —" })
local opponentLabel = mainTab:AddLabel({ Text = "opponent →  —" })
local statusLabel = mainTab:AddLabel({ Text = "round  →  waiting" })

local controlRow = mainTab:AddLayout({ Style = "Horizontal", Size = UDim2.new(1, 0, 0, 24), Padding = 6 })
local copyBtn = controlRow:AddButton({ Text = "Copy Name", Size = UDim2.new(0, 100, 1, 0) })
local autoCopyToggle = mainTab:AddTextToggle({ Text = "Auto-Copy to Clipboard", Default = false, OnColor = ACCENT, OffColor = DIM })
local copyBind = mainTab:AddKeybindPicker({ Text = "Manual Copy Keybind", Default = "C" })

mainTab:AddSection({ Text = "Recent Flags" })
local historyTable = mainTab:AddTable({ Headers = { "Flag Name", "Time" }, Rows = {}, MaxHeight = 120, RowHeight = 22 })

autoGuessTab:AddSection({ Text = "Auto Guesser" })
local autoDebugLbl = autoGuessTab:AddLabel({ Text = "Auto: Idle", Color = DIM })
local autoGuessToggle = autoGuessTab:AddCheckbox({ Text = "Enable Auto Select", Default = false })
autoGuessTab:AddLabel({ Text = "Set the minimum and maximum delay (in seconds).\nThe game gives you 20 seconds total." })

local minTimeSlider = autoGuessTab:AddSlider({ Text = "Min Delay", Min = 0, Max = 20, Default = 1.0, Float = true, Decimals = 1 })
local maxTimeSlider = autoGuessTab:AddSlider({ Text = "Max Delay", Min = 0, Max = 20, Default = 3.0, Float = true, Decimals = 1 })
local autoGuessStatus = autoGuessTab:AddLabel({ Text = "Status: Idle", Color = DIM })

autoGuessTab:AddSection({ Text = "Debug Tools" })
local testBox = autoGuessTab:AddTextBox({ Text = "Manual Answer", Placeholder = "e.g., Brazil" })

autoGuessTab:AddButton({ 
    Text = "Test Click (UI Only)", 
    Callback = function() 
        local txt = testBox:GetValue()
        if txt and txt ~= "" then
            win:Notify({ Title = "Testing UI", Description = "Looking for " .. txt .. "...", Type = "info" })
            local success, msg = clickAnswerInUI(txt)
            if success then
                win:Notify({ Title = "Test Success", Description = "Clicked " .. txt, Type = "success" })
            else
                win:Notify({ Title = "Test Failed", Description = msg, Type = "error" })
            end
        else
            win:Notify({ Title = "Debug", Description = "Type a country name first.", Type = "warn" })
        end
    end 
})

settingsTab:AddSection({ Text = "Features" })
local opponentToggle = settingsTab:AddCheckbox({ Text = "Reveal Opponent's Flag", Default = false })
local notifToggle = settingsTab:AddCheckbox({ Text = "Enable Wrong Guess Notifications", Default = true })

local function colorize(text, color)
    if not color then return text end
    return string.format("<font color='rgb(%d,%d,%d)'>%s</font>",
        math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5), text)
end

local function normalize(str)
    if not str then return "" end
    local s = string.gsub(str, "[^%w]", "")
    return string.lower(s)
end

local pending    = { flag = nil, opponent = nil, status = nil, image = nil, name = nil }
local notifyQ    = {}
local logHistory = {}

local function copyToClipboard()
    if pending.name then
        if setclipboard then setclipboard(pending.name) end
        win:Notify({ Title = "Copied", Description = pending.name, Type = "success" })
    end
end
copyBtn:SetCallback(copyToClipboard)
copyBind:SetCallback(copyToClipboard)

local function applyUpdates()
    if pending.flag ~= nil then flagLabel:SetText(pending.flag); pending.flag = nil end
    if pending.opponent ~= nil then opponentLabel:SetText(pending.opponent); pending.opponent = nil end
    if pending.status ~= nil then statusLabel:SetText(pending.status); pending.status = nil end
    if pending.image ~= nil then flagImage:SetImage(pending.image); pending.image = nil end
    
    for i = 1, #notifyQ do
        pcall(function() win:Notify(notifyQ[i]) end)
    end
    table.clear(notifyQ)
end

task.spawn(function()
    task.wait(0.1)
    while true do
        applyUpdates()
        task.wait(0.033)
    end
end)

local function setFlag(text, color, name, imageId)
    pending.flag = colorize(text, color)
    pending.name = name
    if imageId then pending.image = imageId else pending.image = "" end
    
    if name and autoCopyToggle:GetValue() then
        if setclipboard then setclipboard(name) end
    end
    
    if name and (#logHistory == 0 or logHistory[#logHistory][1] ~= name) then
        table.insert(logHistory, { name, os.date("%X") })
        if #logHistory > 20 then table.remove(logHistory, 1) end
        local displayData = {}
        for i = #logHistory, 1, -1 do table.insert(displayData, logHistory[i]) end
        historyTable:SetData(displayData)
    end
end

local function setOpponent(text, color) pending.opponent = colorize(text, color) end
local function setStatus(text, color) pending.status = colorize(text, color) end

function getMyFlag()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local seat = hum.SeatPart
    if not seat then return nil end

    for _, tbl in ipairs(Workspace.Tables:GetChildren()) do
        for i = 1, 2 do
            local s = tbl:FindFirstChild("Seat" .. i)
            if s and s == seat then
                local imgPart = tbl:FindFirstChild("Image" .. i)
                if imgPart then
                    local g = imgPart:FindFirstChild("ImageGui")
                    local img = g and g:FindFirstChild("Image")
                    if img and img.Image ~= "" then
                        return imageMap[img.Image]
                    end
                end
            end
        end
    end
    return nil
end

function getOpponentFlag()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local seat = hum.SeatPart
    if not seat then return nil end

    for _, tbl in ipairs(Workspace.Tables:GetChildren()) do
        for i = 1, 2 do
            local s = tbl:FindFirstChild("Seat" .. i)
            if s and s == seat then
                local oppIdx = (i == 1) and 2 or 1
                local oppImgPart = tbl:FindFirstChild("Image" .. oppIdx)
                if oppImgPart then
                    local g = oppImgPart:FindFirstChild("ImageGui")
                    local img = g and g:FindFirstChild("Image")
                    if img and img.Image ~= "" then
                        return imageMap[img.Image]
                    end
                end
            end
        end
    end
    return nil
end

local function getButtonText(btn)
    if btn:IsA("TextButton") then
        return btn.Text or ""
    elseif btn:IsA("ImageButton") then
        local lbl = btn:FindFirstChildWhichIsA("TextLabel")
        if lbl then return lbl.Text or "" end
    end
    return ""
end

local function clickButton(btn)
    if firesignal then
        pcall(firesignal, btn.MouseButton1Click)
        pcall(firesignal, btn.MouseButton1Down)
        pcall(firesignal, btn.MouseButton1Up)
        pcall(firesignal, btn.Activated)
    elseif getconnections then
        for _, conn in pairs(getconnections(btn.MouseButton1Click)) do
            pcall(function() conn.Function() end)
        end
    else
        pcall(function() btn:Activate() end)
    end
end

function clickAnswerInUI(answer)
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local ui = pg and pg:FindFirstChild("UI")
    local hud = ui and ui:FindFirstChild("HUD")
    local index = hud and hud:FindFirstChild("Index")
    local list = index and index:FindFirstChild("List")
    if not list then return false, "UI not open" end
    
    local normAnswer = normalize(answer)
    for _, btn in ipairs(list:GetChildren()) do
        if btn:IsA("TextButton") or btn:IsA("ImageButton") then
            local btnName = normalize(btn.Name)
            local btnText = normalize(getButtonText(btn))
            
            if string.find(btnName, normAnswer, 1, true) or string.find(btnText, normAnswer, 1, true) then
                clickButton(btn)
                return true, "Success"
            end
        end
    end
    return false, "Answer not found in list."
end

local function isUIOpen()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return false end
    local ui = pg:FindFirstChild("UI")
    if not ui then return false end
    local hud = ui:FindFirstChild("HUD")
    if not hud then return false end
    local index = hud:FindFirstChild("Index")
    if not index then return false end
    local list = index:FindFirstChild("List")
    if not list then return false end
    
    if not list.Visible then return false end
    local screenGui = list:FindFirstAncestorOfClass("ScreenGui")
    if screenGui and not screenGui.Enabled then return false end
    
    return #list:GetChildren() > 0
end

local isGuessing = false

function attemptAutoGuess(answer, force)
    if not force and not autoGuessToggle:GetValue() then return end
    if isGuessing then return end
    
    isGuessing = true
    local minT = minTimeSlider:GetValue()
    local maxT = maxTimeSlider:GetValue()
    if minT > maxT then minT, maxT = maxT, minT end
    local delay = minT + math.random() * (maxT - minT)
    
    autoGuessStatus:SetText("Status: Waiting " .. string.format("%.1f", delay) .. "s...")
    
    task.spawn(function()
        task.wait(delay)
        
        local timeout = os.clock() + 15
        local clicked = false
        
        while os.clock() < timeout do
            local success, msg = clickAnswerInUI(answer)
            if success then
                autoGuessStatus:SetText("Status: Guessed " .. answer)
                clicked = true
                break
            end
            task.wait(0.1)
        end
        
        if not clicked then
            autoGuessStatus:SetText("Status: Failed to find button.")
        end
        
        task.wait(1.5)
        isGuessing = false 
        if autoGuessStatus.Text == "Status: Guessed " .. answer then
            autoGuessStatus:SetText("Status: Idle")
        end
    end)
end

local function updateFlag()
    if LocalPlayer:GetAttribute("InRound") ~= true then
        setFlag("flag   →  —", DIM, nil, nil)
        if opponentToggle:GetValue() then setOpponent("opponent →  —", DIM) end
        return
    end
    
    local myName = getMyFlag()
    if myName then
        local imageId = nil
        for id, name in pairs(imageMap) do
            if name == myName then imageId = id; break end
        end
        setFlag("flag   →  " .. myName, ACCENT, myName, imageId)
    else
        setFlag("flag   →  hidden by game", DIM, nil, nil)
    end

    if opponentToggle:GetValue() then
        local oppName = getOpponentFlag()
        if oppName then
            setOpponent("opponent → " .. oppName, RED)
        else
            setOpponent("opponent →  —", DIM)
        end
    end
end

local function syncRound()
    if LocalPlayer:GetAttribute("InRound") == true then updateFlag() end
end

LocalPlayer:GetAttributeChangedSignal("InRound"):Connect(syncRound)

-- NET EVENTS
Net:Connect("RoundUIState", function(active, _, _, _, _, _, answer, _)
    if active and typeof(answer) == "string" and answer ~= "" then
        setStatus("round  →  " .. answer, ACCENT)
        return
    end
    if not active then
        local inRound = LocalPlayer:GetAttribute("InRound") == true
        setStatus(inRound and "round  →  active" or "round  →  waiting", inRound and BLUE or DIM)
    end
end)

Net:Connect("RoundConsumableState", function(action, consumable, _, answer)
    if action == "set" and consumable == "Reveal" and typeof(answer) == "string" and answer ~= "" then
        setStatus("round  →  " .. answer, ACCENT)
        return
    end
    if action == "reset" then
        local inRound = LocalPlayer:GetAttribute("InRound") == true
        setStatus(inRound and "round  →  active" or "round  →  waiting", inRound and BLUE or DIM)
    end
end)

Net:RemoteEvent("RoundWrongGuess").OnClientEvent:Connect(function()
    setStatus("round  →  wrong", RED)
    if notifToggle:GetValue() then
        table.insert(notifyQ, { Title = "Wrong Guess", Description = "That guess was wrong.", Type = "error", Duration = 3 })
    end
    task.delay(3, function() setStatus("round  →  active", BLUE) end)
end)

task.spawn(function()
    while task.wait(0.03) do
        if autoGuessToggle:GetValue() then
            if isUIOpen() then
                if not isGuessing then
                    local answer = getMyFlag()
                    
                    if answer then
                        autoDebugLbl:SetText("Auto: Selecting " .. answer)
                        attemptAutoGuess(answer)
                    else
                        autoDebugLbl:SetText("Auto: Waiting for my flag...")
                    end
                end
            else
                autoDebugLbl:SetText("Auto: Waiting for my turn...")
                isGuessing = false
            end
        else
            autoDebugLbl:SetText("Auto: Disabled")
        end
    end
end)

local function hookCharacter(char)
    local hum = char:WaitForChild("Humanoid")
    hum:GetPropertyChangedSignal("Sit"):Connect(updateFlag)
    hum:GetPropertyChangedSignal("SeatPart"):Connect(updateFlag)
    updateFlag()
end

local char = LocalPlayer.Character
if char and char:FindFirstChildOfClass("Humanoid") then hookCharacter(char) end
LocalPlayer.CharacterAdded:Connect(hookCharacter)
syncRound()

while task.wait(0.25) do
    if LocalPlayer:GetAttribute("InRound") == true then updateFlag() end
end
