-- Real Mobile RP Exploits v2 (Anti-Cheat Bypass + Admin Detection)
-- Advanced stealth systems for maximum security

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Anti-Detection Variables
local stealthMode = true
local adminDetected = false
local menuVisible = true
local originalFunctions = {}

-- Admin Detection System (Advanced)
local function detectAdmin()
    local adminKeywords = {"mod", "adm", "admin", "staff", "owner", "dev", "moderador", "administrador"}
    local adminFound = false
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player then
            local name = p.Name:lower()
            local displayName = p.DisplayName:lower()
            
            -- Check names
            for _, keyword in pairs(adminKeywords) do
                if name:find(keyword) or displayName:find(keyword) then
                    adminFound = true
                    break
                end
            end
            
            -- Check for admin badges/groups
            pcall(function()
                local userId = p.UserId
                -- Check if user has admin privileges (common group ranks)
                if game:GetService("GroupService"):GetGroupInfoAsync(p.UserId) then
                    adminFound = true
                end
            end)
            
            if adminFound then break end
        end
    end
    
    return adminFound
end

-- Bypass Anti-Cheat Detection
local function bypassAntiCheat()
    -- Spoof commonly monitored functions
    local oldNamecall = getrawmetatable(game).__namecall
    if oldNamecall then
        getrawmetatable(game).__namecall = function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            -- Block specific anti-cheat calls
            if method == "FireServer" and tostring(self):find("AntiCheat") then
                return -- Block anti-cheat reports
            end
            
            -- Spoof WalkSpeed checks
            if method == "GetPropertyChangedSignal" and args[1] == "WalkSpeed" then
                return -- Block speed monitoring
            end
            
            return oldNamecall(self, ...)
        end
    end
    
    -- Hook into common anti-cheat systems
    pcall(function()
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj.Name:lower():find("anticheat") or obj.Name:lower():find("anticheats") then
                obj:Destroy()
            end
        end
    end)
end

-- Stealth notification system
local function stealthNotify(message, duration, color)
    if adminDetected then return end
    
    local notification = Instance.new("TextLabel")
    notification.Size = UDim2.new(0, 250, 0, 30)
    notification.Position = UDim2.new(1, -260, 0, math.random(50, 200))
    notification.BackgroundColor3 = color or Color3.fromRGB(25, 25, 35)
    notification.BorderSizePixel = 0
    notification.Text = message
    notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    notification.TextSize = 11
    notification.Font = Enum.Font.Gotham
    notification.TextTransparency = 1
    notification.BackgroundTransparency = 1
    notification.Parent = PlayerGui:FindFirstChild("RealRPExploits") or PlayerGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = notification
    
    -- Smooth fade in/out
    local fadeIn = TweenService:Create(notification, TweenInfo.new(0.3), {
        TextTransparency = 0,
        BackgroundTransparency = 0.2
    })
    
    local fadeOut = TweenService:Create(notification, TweenInfo.new(0.3), {
        TextTransparency = 1,
        BackgroundTransparency = 1
    })
    
    fadeIn:Play()
    
    spawn(function()
        wait(duration or 3)
        fadeOut:Play()
        fadeOut.Completed:Wait()
        notification:Destroy()
    end)
end

-- Advanced item duplication
local function duplicateInventory()
    if adminDetected then return false end
    
    local success = false
    
    -- Method 1: Remote manipulation with delay
    spawn(function()
        for i = 1, 3 do -- Multiple attempts
            pcall(function()
                local modules = ReplicatedStorage:FindFirstChild("Modules")
                if modules then
                    local invRemotes = modules:FindFirstChild("InvRemotes")
                    if invRemotes then
                        local invRemot = invRemotes:FindFirstChild("InvRemot")
                        if invRemot and invRemot:IsA("RemoteEvent") then
                            -- Get current inventory state
                            invRemot:FireServer("duplicate", {["Action"] = "copy_all"})
                            wait(0.5)
                            -- Apply duplication
                            invRemot:FireServer("update", {["Multiply"] = 2})
                            success = true
                        end
                    end
                end
            end)
            wait(1)
        end
    end)
    
    -- Method 2: Direct inventory value manipulation
    if not success then
        pcall(function()
            if Player:FindFirstChild("Inventory") then
                local inv = Player.Inventory
                for _, item in pairs(inv:GetChildren()) do
                    if item:IsA("IntValue") or item:IsA("NumberValue") then
                        local currentValue = item.Value
                        if currentValue > 0 then
                            item.Value = currentValue * 2 -- Double items
                            success = true
                        end
                    end
                end
            end
        end)
    end
    
    return success
end

-- Advanced corpse teleportation
local function teleportToCorpse()
    if adminDetected then return false end
    
    local corpses = {}
    local success = false
    
    -- Find dead bodies/ragdolls
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("corpse") or obj.Name:lower():find("body") or obj.Name:lower():find("ragdoll") then
            if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
                table.insert(corpses, obj.HumanoidRootPart.Position)
            end
        end
        
        -- Look for humanoids with health = 0
        if obj:IsA("Humanoid") and obj.Health <= 0 and obj.Parent:FindFirstChild("HumanoidRootPart") then
            table.insert(corpses, obj.Parent.HumanoidRootPart.Position)
        end
    end
    
    -- Teleport to random corpse
    if #corpses > 0 then
        local randomCorpse = corpses[math.random(1, #corpses)]
        local character = Player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            -- Smooth teleport to avoid detection
            local startPos = character.HumanoidRootPart.CFrame
            local endPos = CFrame.new(randomCorpse + Vector3.new(0, 3, 0))
            
            for i = 0, 1, 0.1 do
                character.HumanoidRootPart.CFrame = startPos:Lerp(endPos, i)
                wait(0.05)
            end
            success = true
        end
    end
    
    return success
end

-- Advanced Fly System (Stealth)
local flyEnabled = false
local bodyVelocity = nil
local bodyAngularVelocity = nil

local function toggleFly(enabled)
    if adminDetected then return false end
    
    flyEnabled = enabled
    local character = Player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local rootPart = character.HumanoidRootPart
    
    if enabled then
        -- Create fly components
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = rootPart
        
        bodyAngularVelocity = Instance.new("BodyAngularVelocity")
        bodyAngularVelocity.MaxTorque = Vector3.new(400000, 400000, 400000)
        bodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
        bodyAngularVelocity.Parent = rootPart
        
        -- Fly control loop
        spawn(function()
            local camera = workspace.CurrentCamera
            while flyEnabled and bodyVelocity and bodyVelocity.Parent do
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    local moveVector = humanoid.MoveDirection
                    local speed = 50
                    
                    -- Calculate movement direction
                    local direction = Vector3.new(0, 0, 0)
                    if moveVector.Magnitude > 0 then
                        direction = camera.CFrame.LookVector * moveVector.Z + camera.CFrame.RightVector * moveVector.X
                        direction = direction * speed
                    end
                    
                    -- Vertical movement
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) or humanoid.Jump then
                        direction = direction + Vector3.new(0, speed, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        direction = direction + Vector3.new(0, -speed, 0)
                    end
                    
                    bodyVelocity.Velocity = direction
                end
                wait()
            end
        end)
    else
        -- Cleanup
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyAngularVelocity then bodyAngularVelocity:Destroy() end
        bodyVelocity = nil
        bodyAngularVelocity = nil
    end
    
    return true
end

-- Enhanced exploit functions
local function safeExploit(func, successMsg, failMsg)
    if adminDetected then 
        stealthNotify("⚠️ Admin detectado - Funções desabilitadas!", 3, Color3.fromRGB(255, 100, 100))
        return false 
    end
    
    local success = func()
    if success then
        stealthNotify("✅ " .. successMsg, 3, Color3.fromRGB(100, 255, 100))
    else
        stealthNotify("❌ " .. failMsg, 3, Color3.fromRGB(255, 100, 100))
    end
    return success
end

-- Main exploit functions
local RealExploits = {
    GetFreeMoney = function()
        return safeExploit(function()
            local amounts = {5000, 10000, 15000, 25000}
            local amount = amounts[math.random(1, #amounts)]
            
            -- Try multiple money remotes
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    local name = remote.Name:lower()
                    if name:find("money") or name:find("cash") or name:find("salary") or name:find("pay") then
                        pcall(function()
                            remote:FireServer(amount)
                            remote:FireServer("add", amount)
                            remote:FireServer("give", Player, amount)
                        end)
                    end
                end
            end
            
            -- Manipulate leaderstats
            pcall(function()
                local leaderstats = Player:FindFirstChild("leaderstats")
                if leaderstats then
                    for _, stat in pairs(leaderstats:GetChildren()) do
                        local statName = stat.Name:lower()
                        if statName:find("money") or statName:find("cash") or statName:find("dinheiro") then
                            stat.Value = stat.Value + amount
                        end
                    end
                end
            end)
            
            return true
        end, "Dinheiro adicionado!", "Falha ao adicionar dinheiro")
    end,
    
    DuplicateItems = function()
        return safeExploit(duplicateInventory, "Itens duplicados!", "Falha na duplicação")
    end,
    
    TeleportToCorpse = function()
        return safeExploit(teleportToCorpse, "Teleportado para corpo!", "Nenhum corpo encontrado")
    end,
    
    ToggleFly = function()
        flyEnabled = not flyEnabled
        return safeExploit(function()
            return toggleFly(flyEnabled)
        end, flyEnabled and "Fly ativado!" or "Fly desativado!", "Falha no fly")
    end,
    
    SpeedHack = function()
        return safeExploit(function()
            spawn(function()
                local character = Player.Character
                if character and character:FindFirstChild("Humanoid") then
                    -- Gradual speed increase to avoid detection
                    for speed = 16, 50, 2 do
                        if adminDetected then break end
                        character.Humanoid.WalkSpeed = speed
                        wait(0.1)
                    end
                end
            end)
            return true
        end, "Speed hack ativado!", "Falha no speed hack")
    end,
    
    AntiKick = function()
        return safeExploit(function()
            -- Advanced anti-kick protection
            originalFunctions.kick = Player.Kick
            Player.Kick = function(...)
                stealthNotify("🛡️ Kick bloqueado!", 2, Color3.fromRGB(255, 255, 100))
            end
            
            -- Block remote kicks
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") and remote.Name:lower():find("kick") then
                    remote.OnClientEvent:Connect(function() end)
                end
            end
            
            return true
        end, "Anti-kick ativado!", "Falha no anti-kick")
    end
}

-- Create main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RealRPExploits"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Toggle button (always visible)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Position = UDim2.new(0, 10, 0.5, -30)
ToggleButton.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "⛩️"
ToggleButton.TextColor3 = Color3.fromRGB(255, 50, 50)
ToggleButton.TextSize = 24
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(255, 50, 50)
ToggleStroke.Thickness = 2
ToggleStroke.Parent = ToggleButton

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 450)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = menuVisible
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 50, 50)
MainStroke.Thickness = 3
MainStroke.Parent = MainFrame

-- Title with admin warning
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "💉 Boboca Hube"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Admin warning label
local AdminWarning = Instance.new("TextLabel")
AdminWarning.Size = UDim2.new(1, -10, 0, 30)
AdminWarning.Position = UDim2.new(0, 5, 0, 50)
AdminWarning.BackgroundTransparency = 1
AdminWarning.Text = ""
AdminWarning.TextColor3 = Color3.fromRGB(255, 100, 100)
AdminWarning.TextSize = 12
AdminWarning.Font = Enum.Font.GothamBold
AdminWarning.TextWrapped = true
AdminWarning.Visible = false
AdminWarning.Parent = MainFrame

-- Button creation function
local function createExploitButton(name, icon, position, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 40)
    Button.Position = UDim2.new(0, 10, 0, 90 + (position * 45))
    Button.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Button.BorderSizePixel = 0
    Button.Text = icon .. " " .. name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamSemibold
    Button.Parent = MainFrame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 10)
    ButtonCorner.Parent = Button
    
    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = Color3.fromRGB(50, 50, 60)
    ButtonStroke.Thickness = 1
    ButtonStroke.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        if adminDetected then
            stealthNotify("⚠️ Admin no servidor - Função desabilitada!", 3, Color3.fromRGB(255, 100, 100))
            return
        end
        
        Button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        ButtonStroke.Color = Color3.fromRGB(255, 100, 100)
        
        spawn(function()
            callback()
            wait(0.3)
            Button.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            ButtonStroke.Color = Color3.fromRGB(50, 50, 60)
        end)
    end)
    
    return Button
end

-- Create buttons
createExploitButton("Free Money", "💉", 0, RealExploits.GetFreeMoney)
createExploitButton("Duplicate Items", "💉", 1, RealExploits.DuplicateItems)
createExploitButton("Speed Hack", "💉", 2, RealExploits.SpeedHack)
createExploitButton("Toggle Fly", "💉", 3, RealExploits.ToggleFly)
createExploitButton("Teleport to Corpse", "💉", 4, RealExploits.TeleportToCorpse)
createExploitButton("Anti Kick", "🛡️", 5, RealExploits.AntiKick)

-- Toggle functionality
ToggleButton.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    MainFrame.Visible = menuVisible
    
    local tween = TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
        Rotation = menuVisible and 0 or 90
    })
    tween:Play()
end)

-- Admin detection loop
spawn(function()
    while wait(5) do
        local wasDetected = adminDetected
        adminDetected = detectAdmin()
        
        if adminDetected ~= wasDetected then
            if adminDetected then
                AdminWarning.Text = "⚠️ ADMIN DETECTADO! Todas as funções foram desabilitadas por segurança."
                AdminWarning.Visible = true
                MainStroke.Color = Color3.fromRGB(255, 200, 0)
                ToggleStroke.Color = Color3.fromRGB(255, 200, 0)
                stealthNotify("⚠️ Admin no servidor detectado!", 5, Color3.fromRGB(255, 200, 0))
            else
                AdminWarning.Visible = false
                MainStroke.Color = Color3.fromRGB(255, 50, 50)
                ToggleStroke.Color = Color3.fromRGB(255, 50, 50)
                stealthNotify("✅ Admin saiu - Funções reativadas!", 3, Color3.fromRGB(100, 255, 100))
            end
        end
    end
end)

-- Initialize systems
spawn(function()
    wait(1)
    bypassAntiCheat()
    RealExploits.AntiKick()
    stealthNotify("🧛 Boboca Hube", 3)
end)

print("🔥 boboca hube loaded with advanced security!")

return RealExploits
