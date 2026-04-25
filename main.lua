repeat task.wait() until game:IsLoaded()

-- =======================================================
-- PINATHUB - BRAINROTS COLLECTOR
-- =======================================================

-- ============================================
-- SERVICES
-- ============================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- ============================================
-- PLAYER VARIABLES
-- ============================================
local player = LocalPlayer
local UIS = UserInputService

-- Settings
local flags = {
    infiniteJump = false,
    autoCollect = false,
    hideNotifs = false,
    autoGrabBrainrots = false
}
local walkSpeedValue = 16

-- Reset Character variables
local resetCooldown = false

-- Brainrots variables
local selectedRarities = {"All"}
local raritiesList = {"All","Common","Uncommon","Rare","Epic","Legendary","Mythic","Cosmic","Secret","Celestial","Divine","OG"}
local notifConnection = nil

-- ============================================
-- LOGO LAUNCHER
-- ============================================
local logoGui = Instance.new("ScreenGui")
logoGui.Name = "PinatHubLogo"
logoGui.ResetOnSpawn = false
logoGui.Parent = player:WaitForChild("PlayerGui", 5)

local logoButton = Instance.new("ImageButton")
logoButton.Name = "LogoButton"
logoButton.Size = UDim2.new(0, 60, 0, 60)
logoButton.Position = UDim2.new(0.5, -30, 0.5, -30)
logoButton.BackgroundTransparency = 1
logoButton.Image = "rbxassetid://118264723961739"
logoButton.ImageColor3 = Color3.fromRGB(180, 0, 255)
logoButton.ScaleType = Enum.ScaleType.Fit
logoButton.Parent = logoGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = logoButton

-- Animasi kecil
local hoverTween = TweenService:Create(logoButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 70, 0, 70)})
local unhoverTween = TweenService:Create(logoButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 60, 0, 60)})

logoButton.MouseEnter:Connect(function()
    hoverTween:Play()
end)

logoButton.MouseLeave:Connect(function()
    unhoverTween:Play()
end)

-- Fitur drag
local dragging = false
local dragInput, dragStart, startPos

logoButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = logoButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

logoButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        logoButton.Position = newPos
    end
end)

-- ============================================
-- WIND UI SETUP
-- ============================================
local WindUI = (function()
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua", true))()
    end)
    return success and result or nil
end)()

if not WindUI then 
    print("Failed to load WindUI Library")
    return 
end

local Window = WindUI:CreateWindow({
    Title = "PinatHub | Brainrots",
    Author = "Skateboard for Brainrots",
    Folder = "pinathub",
    NewElements = true,
    OpenButton = {
        Enabled = false,
    },
    Topbar = { Height = 44, ButtonsType = "Default" }
})

Window:Tag({ Title = "@viunze on tiktok", Icon = "star", Color = Color3.fromHex("#BA00FF"), Border = true })

-- Fungsi untuk buka/tutup via logo
local guiVisible = true
logoButton.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    if Window then
        pcall(function()
            if guiVisible then
                Window:Open()
            else
                Window:Minimize()
            end
        end)
    end
end)

-- Create Tabs
local PlayerTab = Window:Tab({ Title = "Player", Icon = "user", IconColor = Color3.fromHex("#30FF6A"), Border = true })
local BrainrotTab = Window:Tab({ Title = "Brainrots", Icon = "brain", IconColor = Color3.fromHex("#FF6B9D"), Border = true })
local MiscTab = Window:Tab({ Title = "Misc", Icon = "settings", IconColor = Color3.fromHex("#9B59B6"), Border = true })
local CommunityTab = Window:Tab({ Title = "Community", Icon = "message-circle", IconColor = Color3.fromHex("#9B59B6"), Border = true })

-- ============================================
-- RESET CHARACTER FUNCTION
-- ============================================
local function resetCharacter()
    if resetCooldown then
        return
    end
    resetCooldown = true
    player.Character:BreakJoints()
    task.wait(6) 
    resetCooldown = false
end

-- ============================================
-- WALKSPEED FUNCTION
-- ============================================
local function setWalkSpeed(value)
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
end

-- WalkSpeed loop
local walkSpeedConn = nil
local walkSpeedActive = false

local function startWalkSpeed()
    if walkSpeedActive then return end
    walkSpeedActive = true
    walkSpeedConn = RunService.RenderStepped:Connect(function()
        setWalkSpeed(walkSpeedValue)
    end)
end

local function stopWalkSpeed()
    walkSpeedActive = false
    if walkSpeedConn then
        walkSpeedConn:Disconnect()
        walkSpeedConn = nil
    end
    setWalkSpeed(16)
end

-- ============================================
-- INFINITE JUMP
-- ============================================
local InfiniteJumpEnabled = false

UIS.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState("Jumping")
            end
        end
    end
end)

-- ============================================
-- UI: PLAYER TAB
-- ============================================
local movementSection = PlayerTab:Section({ Title = "Movement" })

movementSection:Toggle({
    Title = "WalkSpeed",
    Default = false,
    Callback = function(value)
        if value then
            startWalkSpeed()
        else
            stopWalkSpeed()
        end
    end
})

movementSection:Slider({
    Title = "WalkSpeed Value",
    Description = "Custom walk speed (16-1000)",
    Value = { Min = 16, Default = 50, Max = 1000 },
    Callback = function(value)
        walkSpeedValue = value
        if walkSpeedActive then
            setWalkSpeed(value)
        end
    end
})

movementSection:Toggle({
    Title = "Infinite Jump",
    Default = false,
    Callback = function(value)
        InfiniteJumpEnabled = value
    end
})

-- Reset Character Section
local resetSection = PlayerTab:Section({ Title = "Character" })

resetSection:Button({
    Title = "Reset Character",
    Callback = function()
        resetCharacter()
    end
})

-- ============================================
-- UI: BRAINROT TAB (INTEGRATED)
-- ============================================

local brainrotSection = BrainrotTab:Section({ Title = "Brainrot Automation" })

-- Auto collect by firing touch interest
brainrotSection:Toggle({
    Title = "Auto Collect",
    Default = false,
    Callback = function(value)
        flags.autoCollect = value
        if value then
            task.spawn(function()
                while flags.autoCollect do
                    local plot = LocalPlayer:GetAttribute("Plot")
                    if plot then
                        local pPath = Workspace:FindFirstChild("Required") and Workspace.Required:FindFirstChild("Plots") and Workspace.Required.Plots:FindFirstChild(tostring(plot))
                        local collector = pPath and pPath:FindFirstChild("Slots") and pPath.Slots:FindFirstChild("1") and pPath.Slots["1"]:FindFirstChild("Collector") and pPath.Slots["1"].Collector:FindFirstChild("TouchInterest")
                        if collector and collector.Parent then
                            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChildWhichIsA("BasePart")
                            if hrp then
                                firetouchinterest(hrp, collector.Parent, 0)
                                firetouchinterest(hrp, collector.Parent, 1)
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

-- Hide Notifications
brainrotSection:Toggle({
    Title = "Hide Notifications",
    Default = false,
    Callback = function(value)
        flags.hideNotifs = value
        if value then
            local mainGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("MainGui") and LocalPlayer.PlayerGui.MainGui:FindFirstChild("Ignore")
            if mainGui then
                for _, c in ipairs(mainGui:GetChildren()) do
                    if c.Name == "CashTemplate" then 
                        c:Destroy() 
                    end
                end
                notifConnection = mainGui.ChildAdded:Connect(function(c)
                    if c.Name == "CashTemplate" then 
                        c:Destroy() 
                    end
                end)
            end
        else
            if notifConnection then
                notifConnection:Disconnect()
                notifConnection = nil
            end
        end
    end
})

brainrotSection:Divider()

-- Rarities dropdown (MULTI SELECT)
brainrotSection:Dropdown({
    Title = "Brainrot Rarities",
    Icon = "sparkles",
    Multi = true,
    Values = raritiesList,
    Value = {"All"},
    Callback = function(value)
        selectedRarities = value
    end
})

-- Auto Grab Brainrots
brainrotSection:Toggle({
    Title = "Auto Grab Brainrots",
    Default = false,
    Callback = function(value)
        flags.autoGrabBrainrots = value
        if value then
            task.spawn(function()
                while flags.autoGrabBrainrots do
                    local bf = Workspace:FindFirstChild("Required") and Workspace.Required:FindFirstChild("Brainrots")
                    if bf then
                        local allSel = false
                        for _, r in ipairs(selectedRarities) do 
                            if r == "All" then 
                                allSel = true 
                                break 
                            end 
                        end
                        for _, brainrot in ipairs(bf:GetChildren()) do
                            if not flags.autoGrabBrainrots then break end
                            local rarity = brainrot:GetAttribute("Rarity")
                            if rarity and (allSel or (function() 
                                for _, r in ipairs(selectedRarities) do 
                                    if r == rarity then return true end 
                                end 
                                return false 
                            end)()) then
                                local hitbox = brainrot:FindFirstChild("Hitbox")
                                local prompt = hitbox and hitbox:FindFirstChild("BrainrotPrompt")
                                if prompt then
                                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                                    if hrp and hitbox and hitbox:IsA("BasePart") then
                                        hrp.CFrame = CFrame.new(hitbox.Position + Vector3.new(0, 5, 0))
                                        task.wait(0.15)
                                        prompt.RequiresLineOfSight = false
                                        fireproximityprompt(prompt)
                                        task.wait(0.2)
                                        local fl = Workspace:FindFirstChild("Required") and Workspace.Required:FindFirstChild("FinishLine")
                                        local ft = fl and fl:FindFirstChild("TouchInterest")
                                        if ft and ft.Parent then
                                            firetouchinterest(hrp, ft.Parent, 0)
                                            firetouchinterest(hrp, ft.Parent, 1)
                                        end
                                        task.wait(0.4)
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

-- ============================================
-- UI: MISC TAB
-- ============================================

-- Anti AFK Section
local afkSection = MiscTab:Section({ Title = "Utilities" })

local antiAFKActive = false
local antiAFKConn = nil

afkSection:Toggle({
    Title = "Anti-AFK",
    Default = false,
    Callback = function(value)
        antiAFKActive = value
        if value then
            antiAFKConn = player.Idled:Connect(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        else
            if antiAFKConn then
                antiAFKConn:Disconnect()
                antiAFKConn = nil
            end
        end
    end
})

-- Server Tools Section
local serverSection = MiscTab:Section({ Title = "Server Tools" })

local function serverHop()
    local placeId = game.PlaceId
    local servers = {}
    local req = syn and syn.request or http_request or request or httprequest

    if req then
        local cursor = ""
        for _ = 1, 3 do
            local url = "https://games.roblox.com/v1/games/" .. placeId
                .. "/servers/Public?sortOrder=Asc&limit=100"
                .. (cursor ~= "" and ("&cursor=" .. cursor) or "")

            local ok, response = pcall(req, { Url = url, Method = "GET" })
            if not ok or not response or not response.Body then break end

            local ok2, data = pcall(function()
                return HttpService:JSONDecode(response.Body)
            end)
            if not ok2 or not data or not data.data then break end

            for _, server in ipairs(data.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    table.insert(servers, server.id)
                end
            end

            local nextCursor = data.nextPageCursor
            if not nextCursor or nextCursor == "" or nextCursor == "null" then break end
            cursor = tostring(nextCursor)
        end
    end

    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], player)
    else
        TeleportService:Teleport(placeId, player)
    end
end

local function rejoinServer()
    local placeId = game.PlaceId
    local jobId = game.JobId

    if not jobId or jobId == "" then
        pcall(function() TeleportService:Teleport(placeId, player) end)
        return
    end

    local ok1, err1 = pcall(function()
        local opts = Instance.new("TeleportOptions")
        opts.ServerInstanceId = jobId
        TeleportService:TeleportAsync(placeId, { player }, opts)
    end)
    if ok1 then return end

    local ok2, err2 = pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
    end)
    if ok2 then return end

    pcall(function() TeleportService:Teleport(placeId, player) end)
end

serverSection:Button({
    Title = "Server Hop",
    Callback = function()
        serverHop()
        Window:Notify("Server Hop", "Joining new server...", 3)
    end
})

serverSection:Button({
    Title = "Rejoin Server",
    Callback = function()
        rejoinServer()
        Window:Notify("Rejoin", "Rejoining server...", 2)
    end
})

-- ============================================
-- UI: COMMUNITY TAB
-- ============================================

local whatsappSection = CommunityTab:Section({ Title = "WhatsApp Group" })

whatsappSection:Button({
    Title = "Join WhatsApp Group",
    Callback = function()
        if setclipboard then
            setclipboard("https://chat.whatsapp.com/I8hG44FLgrRAwQcS3lvEft")
            Window:Notify("Success", "WhatsApp link copied to clipboard!", 3)
        else
            Window:Notify("Error", "Clipboard not supported!", 2)
        end
    end
})

local discordSection = CommunityTab:Section({ Title = "Discord Server" })

discordSection:Button({
    Title = "Join Discord Server",
    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/eDbaHKEf7G")
            Window:Notify("Success", "Discord link copied to clipboard!", 3)
        else
            Window:Notify("Error", "Clipboard not supported!", 2)
        end
    end
})

-- ============================================
-- CHARACTER RESPAWN HANDLER
-- ============================================
player.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart", 10)
    task.wait(0.5)
    if walkSpeedActive then
        setWalkSpeed(walkSpeedValue)
    end
end)

-- ============================================
-- INITIAL NOTIFICATION
-- ============================================
task.wait(1)
Window:Open()

print("PinatHub Loaded")
Window:Notify("PinatHub", "Loaded", 3)
