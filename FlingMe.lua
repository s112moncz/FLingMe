local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextButton = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local PlayerList = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

-- Properties:
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
Frame.BorderSizePixel = 2
Frame.Position = UDim2.new(0.341826946, 0, 0.367763907, 0)
Frame.Size = UDim2.new(0, 350, 0, 450)

TextButton.Parent = Frame
TextButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TextButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
TextButton.BorderSizePixel = 2
TextButton.Position = UDim2.new(0.0835492909, 0, 0.88, 0)
TextButton.Size = UDim2.new(0, 290, 0, 37)
TextButton.Font = Enum.Font.SourceSans
TextButton.Text = "🚀 TELEPORT FLING"
TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TextButton.TextSize = 24.000

TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1.000
TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.BorderSizePixel = 0
TextLabel.Position = UDim2.new(0.0649713054, 0, 0.02, 0)
TextLabel.Size = UDim2.new(0, 290, 0, 39)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "🔪 Touch Fling Menu"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextSize = 28.000

-- Player List
PlayerList.Parent = Frame
PlayerList.Name = "PlayerList"
PlayerList.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
PlayerList.BorderColor3 = Color3.fromRGB(100, 100, 100)
PlayerList.BorderSizePixel = 1
PlayerList.Position = UDim2.new(0.0835492909, 0, 0.12, 0)
PlayerList.Size = UDim2.new(0, 290, 0, 300)
PlayerList.ScrollBarThickness = 8
PlayerList.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
PlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)

-- UIListLayout pro správné uspořádání
UIListLayout.Parent = PlayerList
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.Name

-- Proměnné
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SelectedPlayer = nil
local IsFlinging = false
local TouchFlingActive = false
local OriginalPosition = nil
local PlayerButtons = {}

-- Funkce pro vytvoření tlačítka hráče
local function createPlayerButton(player)
    local playerButton = Instance.new("TextButton")
    playerButton.Name = player.Name
    playerButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    playerButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
    playerButton.BorderSizePixel = 1
    playerButton.Size = UDim2.new(1, -10, 0, 35)
    playerButton.Position = UDim2.new(0, 5, 0, 0)
    playerButton.Font = Enum.Font.SourceSans
    playerButton.Text = "👤 " .. player.Name
    playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerButton.TextSize = 16
    playerButton.TextXAlignment = Enum.TextXAlignment.Left
    playerButton.TextTruncate = Enum.TextTruncate.AtEnd
    playerButton.Parent = PlayerList
    
    -- Přidat padding textu
    local padding = Instance.new("UIPadding")
    padding.Parent = playerButton
    padding.PaddingLeft = UDim.new(0, 10)
    
    return playerButton
end

-- Funkce pro aktualizaci seznamu VŠECH hráčů
local function updatePlayerList()
    print("🔄 Aktualizuji seznam hráčů...")
    
    -- Smazat stará tlačítka
    for _, child in pairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    PlayerButtons = {}
    
    -- Získat VŠECHNY hráče kromě LocalPlayer
    local allPlayers = Players:GetPlayers()
    local otherPlayers = {}
    
    -- Přidat pouze ostatní hráče
    for _, player in pairs(allPlayers) do
        if player ~= LocalPlayer then
            table.insert(otherPlayers, player)
        end
    end
    
    -- Seřadit hráče podle jména
    table.sort(otherPlayers, function(a, b)
        return a.Name:lower() < b.Name:lower()
    end)
    
    print("📊 Počet hráčů v servru: " .. #allPlayers)
    print("📊 Počet ostatních hráčů: " .. #otherPlayers)
    
    -- Pokud nejsou žádní další hráči
    if #otherPlayers == 0 then
        local noPlayersLabel = Instance.new("TextLabel")
        noPlayersLabel.Name = "NoPlayersLabel"
        noPlayersLabel.BackgroundTransparency = 1
        noPlayersLabel.Size = UDim2.new(1, -20, 0, 50)
        noPlayersLabel.Position = UDim2.new(0, 10, 0.4, 0)
        noPlayersLabel.Font = Enum.Font.SourceSans
        noPlayersLabel.Text = "Žádní další hráči v servru"
        noPlayersLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        noPlayersLabel.TextSize = 16
        noPlayersLabel.TextWrapped = true
        noPlayersLabel.Parent = PlayerList
        
        SelectedPlayer = nil
        TextLabel.Text = "🔪 Touch Fling Menu"
        print("ℹ️ Žádní další hráči v servru")
        return
    end
    
    -- Vytvořit tlačítka pro všechny hráče
    for _, player in pairs(otherPlayers) do
        local playerButton = createPlayerButton(player)
        
        -- Efekt při najetí myší
        playerButton.MouseEnter:Connect(function()
            if SelectedPlayer ~= player then
                playerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                playerButton.Text = "👉 " .. player.Name
            end
        end)
        
        playerButton.MouseLeave:Connect(function()
            if SelectedPlayer ~= player then
                playerButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                playerButton.Text = "👤 " .. player.Name
            end
        end)
        
        -- Výběr hráče
        playerButton.MouseButton1Click:Connect(function()
            print("🎯 Vybrán hráč: " .. player.Name)
            
            -- Resetovat barvy všech tlačítek
            for _, btn in pairs(PlayerList:GetChildren()) do
                if btn:IsA("TextButton") then
                    local btnPlayer = Players:FindFirstChild(btn.Name)
                    if btnPlayer and btnPlayer == SelectedPlayer then
                        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                        btn.Text = "👤 " .. btn.Name
                    end
                end
            end
            
            -- Zvýraznit vybraného
            playerButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
            playerButton.Text = "✅ " .. player.Name
            SelectedPlayer = player
            TextLabel.Text = "🎯 " .. player.Name
        end)
        
        table.insert(PlayerButtons, playerButton)
    end
    
    -- Pokud jsou hráči a žádný není vybrán, vybrat prvního
    if #PlayerButtons > 0 and not SelectedPlayer then
        local firstButton = PlayerButtons[1]
        local firstPlayer = Players:FindFirstChild(firstButton.Name)
        if firstPlayer then
            firstButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
            firstButton.Text = "✅ " .. firstPlayer.Name
            SelectedPlayer = firstPlayer
            TextLabel.Text = "🎯 " .. firstPlayer.Name
            print("🎯 Auto-výběr prvního hráče: " .. firstPlayer.Name)
        end
    end
    
    -- Aktualizovat velikost canvasu
    local totalHeight = (#PlayerButtons * 40) + ((#PlayerButtons - 1) * 5)
    PlayerList.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
    
    print("✅ Seznam hráčů aktualizován")
end

-- TOUCH FLING funkce
local function startTouchFling(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    
    TouchFlingActive = true
    TextLabel.Text = "🌀 Touch Fling: ZAPNUTO"
    TextButton.Text = "⏹️ STOP FLING"
    TextButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    if not myRoot then return end
    
    -- Uložit původní pozici
    OriginalPosition = myRoot.Position
    
    -- Hlavní smyčka touch flingu
    spawn(function()
        while TouchFlingActive and SelectedPlayer == targetPlayer do
            local targetChar = targetPlayer.Character
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            
            if targetRoot and targetRoot.Parent and myRoot and myRoot.Parent then
                -- Rychlé teleportování
                myRoot.CFrame = targetRoot.CFrame
                RunService.Heartbeat:Wait()
                
                myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2)
                RunService.Heartbeat:Wait()
                
                myRoot.CFrame = targetRoot.CFrame
                RunService.Heartbeat:Wait()
                
                myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 3, 0)
                RunService.Heartbeat:Wait()
                
                myRoot.CFrame = targetRoot.CFrame
                
                -- Fling efekt
                if math.random(1, 3) == 1 then
                    spawn(function()
                        local flingPart = Instance.new("Part")
                        flingPart.Name = "TouchFlingPart"
                        flingPart.Size = Vector3.new(2, 2, 2)
                        flingPart.Transparency = 1
                        flingPart.CanCollide = false
                        flingPart.Anchored = false
                        flingPart.Parent = targetChar
                        
                        local bodyVelocity = Instance.new("BodyVelocity")
                        bodyVelocity.Velocity = Vector3.new(
                            math.random(-200, 200),
                            math.random(300, 500),
                            math.random(-200, 200)
                        )
                        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bodyVelocity.Parent = flingPart
                        
                        flingPart.CFrame = targetRoot.CFrame
                        
                        local weld = Instance.new("WeldConstraint")
                        weld.Parent = flingPart
                        weld.Part0 = flingPart
                        weld.Part1 = targetRoot
                        
                        game:GetService("Debris"):AddItem(flingPart, 0.5)
                    end)
                end
            else
                if targetPlayer ~= SelectedPlayer then
                    TouchFlingActive = false
                end
            end
            
            RunService.Heartbeat:Wait()
        end
        
        -- Vrátit se na původní pozici
        if myRoot and OriginalPosition then
            myRoot.CFrame = CFrame.new(OriginalPosition)
        end
        
        -- Resetovat UI
        TouchFlingActive = false
        if SelectedPlayer then
            TextLabel.Text = "🎯 " .. SelectedPlayer.Name
        else
            TextLabel.Text = "🔪 Touch Fling Menu"
        end
        TextButton.Text = "🚀 TELEPORT FLING"
        TextButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    end)
end

-- Hlavní funkce pro teleport + touch fling
local function teleportAndTouchFling()
    if TouchFlingActive then
        TouchFlingActive = false
        TextLabel.Text = "⏹️ Touch Fling: VYPNUTO"
        wait(0.5)
        if SelectedPlayer then
            TextLabel.Text = "🎯 " .. SelectedPlayer.Name
        end
        return
    end
    
    if not SelectedPlayer or not SelectedPlayer.Character then 
        TextLabel.Text = "❌ Vyber hráče!"
        return 
    end
    
    if IsFlinging then return end
    IsFlinging = true
    
    TextButton.Text = "🌀 TELEPORTUJI..."
    TextButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    
    local targetChar = SelectedPlayer.Character
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    if not targetRoot or not myChar or not myRoot then
        TextLabel.Text = "❌ Chyba: HRP!"
        IsFlinging = false
        TextButton.Text = "🚀 TELEPORT FLING"
        TextButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        return
    end
    
    -- Teleportace
    TextLabel.Text = "📍 Teleportuji do hráče..."
    OriginalPosition = myRoot.Position
    myRoot.CFrame = targetRoot.CFrame
    
    wait(0.2)
    TextLabel.Text = "🌀 Spouštím Touch Fling..."
    wait(0.3)
    
    IsFlinging = false
    startTouchFling(SelectedPlayer)
end

-- Funkce pro otevření/zavření GUI pomocí CTRL
local guiVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
            guiVisible = not guiVisible
            Frame.Visible = guiVisible
        end
    end
end)

-- Inicializace
local function initScript()
    -- Hlavní událost tlačítka
    TextButton.MouseButton1Click:Connect(function()
        teleportAndTouchFling()
    end)
    
    -- Inicializace seznamu hráčů
    wait(1) -- Krátký delay pro stabilitu
    updatePlayerList()
    
    -- Automatická aktualizace seznamu
    Players.PlayerAdded:Connect(function(player)
        wait(0.5)
        updatePlayerList()
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        if player == SelectedPlayer then
            SelectedPlayer = nil
            TouchFlingActive = false
            TextLabel.Text = "🔪 Touch Fling Menu"
            TextButton.Text = "🚀 TELEPORT FLING"
            TextButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        end
        updatePlayerList()
    end)
end

-- Skript pro pohyblivé GUI
Frame.Active = true
Frame.Draggable = true

-- Přidat tlačítko pro refresh seznamu
local RefreshButton = Instance.new("TextButton")
RefreshButton.Name = "RefreshButton"
RefreshButton.Parent = Frame
RefreshButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
RefreshButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
RefreshButton.BorderSizePixel = 1
RefreshButton.Position = UDim2.new(0.08, 0, 0.8, 0)
RefreshButton.Size = UDim2.new(0, 140, 0, 25)
RefreshButton.Font = Enum.Font.SourceSans
RefreshButton.Text = "🔄 Obnovit seznam"
RefreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshButton.TextSize = 16

RefreshButton.MouseButton1Click:Connect(function()
    updatePlayerList()
    TextLabel.Text = "✅ Seznam obnoven!"
    wait(1)
    if SelectedPlayer then
        TextLabel.Text = "🎯 " .. SelectedPlayer.Name
    else
        TextLabel.Text = "🔪 Touch Fling Menu"
    end
end)

-- Přidat tlačítko pro zrušení výběru
local ClearButton = Instance.new("TextButton")
ClearButton.Name = "ClearButton"
ClearButton.Parent = Frame
ClearButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ClearButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
ClearButton.BorderSizePixel = 1
ClearButton.Position = UDim2.new(0.55, 0, 0.8, 0)
ClearButton.Size = UDim2.new(0, 140, 0, 25)
ClearButton.Font = Enum.Font.SourceSans
ClearButton.Text = "⏹️ Stop & Clear"
ClearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearButton.TextSize = 16

ClearButton.MouseButton1Click:Connect(function()
    TouchFlingActive = false
    SelectedPlayer = nil
    TextLabel.Text = "🔪 Touch Fling Menu"
    TextButton.Text = "🚀 TELEPORT FLING"
    TextButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    
    -- Resetovat barvy tlačítek
    for _, btn in pairs(PlayerList:GetChildren()) do
        if btn:IsA("TextButton") then
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            btn.Text = "👤 " .. btn.Name
        end
    end
end)

-- Přidat status label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Parent = Frame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0.08, 0, 0.76, 0)
StatusLabel.Size = UDim2.new(0, 290, 0, 20)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.Text = "Načítám hráče..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 14
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Přidat info label
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Parent = Frame
InfoLabel.BackgroundTransparency = 1
InfoLabel.Position = UDim2.new(0.08, 0, 0.84, 0)
InfoLabel.Size = UDim2.new(0, 290, 0, 20)
InfoLabel.Font = Enum.Font.SourceSans
InfoLabel.Text = "CTRL: Otevřít/Zavřít • Táhni: Přesunout"
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
InfoLabel.TextSize = 12
InfoLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Funkce pro aktualizaci statusu
spawn(function()
    while true do
        wait(2)
        local playerCount = #Players:GetPlayers() - 1
        if playerCount < 0 then playerCount = 0 end
        
        local statusText = "Hráčů v servru: " .. playerCount
        
        if TouchFlingActive then
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            statusText = statusText .. " | 🌀 Fling aktivní"
        elseif SelectedPlayer then
            StatusLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
            statusText = statusText .. " | 🎯 " .. SelectedPlayer.Name
        else
            StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        
        StatusLabel.Text = statusText
    end
end)

-- Spustit inicializaci
initScript()

print("========================================")
print("✅ Touch Fling GUI načteno!")
print("📌 Otevřeno: CTRL")
print("📌 Táhni myší pro přesun okna")
print("📌 Vyber hráče a klikni TELEPORT FLING")
print("📌 Klikni znovu pro zastavení")
print("========================================")

-- Notifikace
game.StarterGui:SetCore("SendNotification", {
    Title = "🌀 Touch Fling Menu",
    Text = "GUI načteno! Vyber hráče ze seznamu",
    Duration = 5,
})

-- Made by s112moncz
