local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Aaditya Lala Hub",
    LoadingTitle = "Hunty Zombies",
    LoadingSubtitle = " by Aaditya Lala",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AadityaLalaHub", -- Custom folder for hub
        FileName = "Main"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false, -- Enable for protected access
    KeySettings = {
        Title = "Aaditya Lala Hub Key",
        Subtitle = "Hunty Zombies Access",
        Note = "Contact Aaditya Lala for key",
        FileName = "AadityaLalaKey",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"AadityaLala2025"} -- Add your keys here
    }
})

-- Core Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Configuration Variables
local KillAuraConfig = {
    Enabled = false,
    Range = 15,
    ThroughWalls = false,
    TargetZombies = true,
    TargetPlayers = false,
    AutoFire = true,
    Visuals = true
}

local Connections = {}
local ESPObjects = {}
local KillCount = 0

-- Utility Functions
local function UpdateCharacter()
    Character = LocalPlayer.Character
    if Character then
        Humanoid = Character:WaitForChild("Humanoid")
        RootPart = Character:WaitForChild("HumanoidRootPart")
    end
end

local function IsValidTarget(target)
    if not target or not target.Parent then return false end
    local humanoid = target:FindFirstChildOfClass("Humanoid")
    local rootPart = target:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return false end
    if humanoid.Health <= 0 then return false end
    
    -- Skip local player
    if target == Character then return false end
    
    -- Check if it's a zombie/enemy (Hunty Zombies specific)
    local isZombie = string.find(string.lower(target.Name), "zombie") or 
                     string.find(string.lower(target.Name), "enemy") or
                     string.find(string.lower(target.Name), "walker") or
                     target:FindFirstChild("Zombie") or
                     (target ~= LocalPlayer.Character and humanoid.MaxHealth <= 100) -- Common zombie health
    
    return isZombie
end

local function GetTargetsInRange(range)
    local targets = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and IsValidTarget(obj) then
            local rootPart = obj:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local distance = (RootPart.Position - rootPart.Position).Magnitude
                
                -- Wall check option
                local raycast = Workspace:Raycast(RootPart.Position, (rootPart.Position - RootPart.Position).Unit * distance)
                local wallCheck = not KillAuraConfig.ThroughWalls and raycast and raycast.Instance and raycast.Instance.CanCollide
                
                if distance <= range and not wallCheck then
                    table.insert(targets, obj)
                end
            end
        end
    end
    return targets
end

local function CreateESP(target)
    if not KillAuraConfig.Visuals then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "KillAuraESP"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0
    highlight.Parent = target
    
    -- Health bar
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HealthBar"
    billboard.Size = UDim2.new(0, 100, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = target:FindFirstChild("Head") or target.PrimaryPart
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    frame.BorderSizePixel = 0
    frame.Parent = billboard
    
    local healthFrame = Instance.new("Frame")
    healthFrame.Name = "Health"
    healthFrame.Size = UDim2.new(1, 0, 1, 0)
    healthFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthFrame.BorderSizePixel = 0
    healthFrame.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 2)
    corner.Parent = frame
    
    table.insert(ESPObjects, {highlight = highlight, billboard = billboard})
end

local function RemoveESP(target)
    for i = #ESPObjects, 1, -1 do
        local esp = ESPObjects[i]
        if esp.highlight and esp.highlight.Parent == target then
            esp.highlight:Destroy()
            if esp.billboard then esp.billboard:Destroy() end
            table.remove(ESPObjects, i)
        end
    end
end

local function AttackTarget(target)
    pcall(function()
        local humanoid = target:FindFirstChildOfClass("Humanoid")
        local rootPart = target:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart then
            -- Method 1: Tool activation (if player has weapon)
            local tool = Character:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
            end
            
            -- Method 2: Move to target for auto-attack
            Humanoid:MoveTo(rootPart.Position)
            
            -- Method 3: Fire game-specific remotes (Hunty Zombies)
            local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
            for _, remote in pairs(remotes:GetDescendants()) do
                if remote:IsA("RemoteEvent") and (
                    string.find(string.lower(remote.Name), "damage") or
                    string.find(string.lower(remote.Name), "hit") or
                    string.find(string.lower(remote.Name), "attack")
                ) then
                    remote:FireServer(target, "head") -- Common damage call
                end
            end
            
            KillCount = KillCount + 1
            print("Aaditya Lala Hub: Attacked " .. target.Name .. " (Kills: " .. KillCount .. ")")
        end
    end)
end

-- KILL AURA TAB
local KillAuraTab = Window:CreateTab("🎯 Kill Aura", 4483362458)

KillAuraTab:CreateToggle({
    Name = "Enable Kill Aura",
    CurrentValue = false,
    Flag = "KillAuraEnabled",
    Callback = function(Value)
        KillAuraConfig.Enabled = Value
        if Value then
            Connections.KillAura = RunService.Heartbeat:Connect(function()
                if Character and RootPart and KillAuraConfig.Enabled then
                    local targets = GetTargetsInRange(KillAuraConfig.Range)
                    
                    -- ESP for visible targets
                    for _, target in pairs(targets) do
                        if not target:FindFirstChild("KillAuraESP") then
                            CreateESP(target)
                        end
                        
                        if KillAuraConfig.AutoFire then
                            AttackTarget(target)
                        end
                    end
                    
                    -- Clean up ESP for targets out of range
                    for i = #ESPObjects, 1, -1 do
                        local espTarget = ESPObjects[i].highlight.Parent
                        if espTarget and IsValidTarget(espTarget) then
                            local rootPart = espTarget:FindFirstChild("HumanoidRootPart")
                            if rootPart then
                                local distance = (RootPart.Position - rootPart.Position).Magnitude
                                if distance > KillAuraConfig.Range then
                                    RemoveESP(espTarget)
                                end
                            end
                        end
                    end
                end
            end)
            
            Rayfield:Notify({
                Title = "Kill Aura Activated",
                Content = "Aaditya Lala Hub: Targeting zombies within " .. KillAuraConfig.Range .. " studs",
                Duration = 4.0,
                Image = 4483362458,
            })
        else
            if Connections.KillAura then
                Connections.KillAura:Disconnect()
            end
            
            -- Clean up all ESP
            for _, esp in pairs(ESPObjects) do
                if esp.highlight then esp.highlight:Destroy() end
                if esp.billboard then esp.billboard:Destroy() end
            end
            ESPObjects = {}
            
            Rayfield:Notify({
                Title = "Kill Aura Disabled",
                Content = "All targeting stopped.",
                Duration = 3.0,
                Image = 4483362458,
            })
        end
    end,
})

KillAuraTab:CreateSlider({
    Name = "Kill Aura Range",
    Range = {5, 50},
    Increment = 1,
    CurrentValue = 15,
    Flag = "KillAuraRange",
    Callback = function(Value)
        KillAuraConfig.Range = Value
        Rayfield:Notify({
            Title = "Range Updated",
            Content = "New range: " .. Value .. " studs",
            Duration = 2.0,
            Image = nil,
        })
    end,
})

KillAuraTab:CreateToggle({
    Name = "Through Walls",
    CurrentValue = false,
    Flag = "KillAuraWalls",
    Callback = function(Value)
        KillAuraConfig.ThroughWalls = Value
    end,
})

KillAuraTab:CreateToggle({
    Name = "ESP Visuals",
    CurrentValue = true,
    Flag = "KillAuraESP",
    Callback = function(Value)
        KillAuraConfig.Visuals = Value
        if not Value then
            for _, esp in pairs(ESPObjects) do
                if esp.highlight then esp.highlight:Destroy() end
                if esp.billboard then esp.billboard:Destroy() end
            end
            ESPObjects = {}
        end
    end,
})

KillAuraTab:CreateToggle({
    Name = "Auto Attack",
    CurrentValue = true,
    Flag = "KillAuraAutoFire",
    Callback = function(Value)
        KillAuraConfig.AutoFire = Value
    end,
})

-- DISPLAY TAB
local DisplayTab = Window:CreateTab("📊 Display", 4483362458)

DisplayTab:CreateParagraph({
    Title = "Kill Statistics",
    Content = "Kills: 0 | Range: " .. KillAuraConfig.Range .. " studs | Status: Inactive"
})

-- Update stats display
spawn(function()
    while true do
        wait(1)
        if Rayfield.Flags["KillAuraEnabled"] then
            -- Update display (Rayfield doesn't have direct paragraph update, so notify)
            Rayfield:Notify({
                Title = "Stats Update",
                Content = "Kills: " .. KillCount .. " | Range: " .. KillAuraConfig.Range,
                Duration = 1.0,
                Image = nil,
            })
        end
    end
end)

-- UTILITY TAB
local UtilityTab = Window:CreateTab("⚙️ Utility", 4483362458)

UtilityTab:CreateButton({
    Name = "Reset Kill Counter",
    Callback = function()
        KillCount = 0
        Rayfield:Notify({
            Title = "Counter Reset",
            Content = "Kill counter reset to 0",
            Duration = 2.0,
            Image = nil,
        })
    end,
})

UtilityTab:CreateButton({
    Name = "Clear ESP",
    Callback = function()
        for _, esp in pairs(ESPObjects) do
            if esp.highlight then esp.highlight:Destroy() end
            if esp.billboard then esp.billboard:Destroy() end
        end
        ESPObjects = {}
        Rayfield:Notify({
            Title = "ESP Cleared",
            Content = "All visual indicators removed",
            Duration = 2.0,
            Image = nil,
        })
    end,
})

UtilityTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end,
})

-- Character Respawn Handler
LocalPlayer.CharacterAdded:Connect(function()
    wait(3)
    UpdateCharacter()
    -- Clean up old ESP
    for _, esp in pairs(ESPObjects) do
        if esp.highlight then esp.highlight:Destroy() end
        if esp.billboard then esp.billboard:Destroy() end
    end
    ESPObjects = {}
end)

-- Cleanup Function
local function Cleanup()
    if Connections.KillAura then
        Connections.KillAura:Disconnect()
    end
    for _, esp in pairs(ESPObjects) do
        if esp.highlight then esp.highlight:Destroy() end
        if esp.billboard then esp.billboard:Destroy() end
    end
end

-- Override Rayfield destroy to cleanup
local oldDestroy = Rayfield.DestroyGui
Rayfield.DestroyGui = function()
    Cleanup()
    if oldDestroy then oldDestroy() end
end

-- Initial Notification
Rayfield:Notify({
    Title = "Aaditya Lala Hub Loaded",
    Content = "Hunty Zombies Kill Aura System Ready!\nRange: " .. KillAuraConfig.Range .. " studs",
    Duration = 6.0,
    Image = 4483362458,
})

print("=== Aaditya Lala Hub ===")
print("Hunty Zombies Kill Aura Loaded Successfully")
print("Developer: Aaditya Lala")
print("Educational Use Only")
