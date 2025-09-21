-- Booting UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
-- Intilizate Other
local setclipboard = setclipboard or writeclipboard
local TeleportService = game:GetService("TeleportService")
local PLACE_ID = game.PlaceId
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local boosterForce = 1000
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local savedPosition = nil
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local blinkEnabled = false
local buffer = {}
local bufferSize = 10
-- ESP
local ESPSettings = {
    Box = false,
    Name = false,
}
local ESPGui = nil
local ESPLabels = {}
local ESPBoxes = {}
local ESPActive = false
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = game.Players.LocalPlayer

local noclipEnabled = false

-- Функция включения/выключения noclip
local noclipEnabled = false

function toggleNoclip(state)
    noclipEnabled = state
end

-- End ESP
-- Smooth Teleport for AutoSteal(Default)
local function smoothTeleport(targetVec3)
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    local targetCFrame = CFrame.new(targetVec3)
    hrp.CanCollide = false

    local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Linear)
    local goal = {CFrame = targetCFrame}
    local tween = TweenService:Create(hrp, tweenInfo, goal)

    tween:Play()
    tween.Completed:Connect(function()
        hrp.CanCollide = true
    end)
end
-- Clear ESP
local function clearESP()
    if ESPGui then ESPGui:Destroy() end
    ESPLabels = {}
    for _, box in pairs(ESPBoxes) do
        box:Remove()
    end
    ESPBoxes = {}
end
-- Create ESP Gui
local function createESPGui()
    ESPGui = Instance.new("ScreenGui")
    ESPGui.Name = "SafeESP"
    ESPGui.ResetOnSpawn = false
    ESPGui.Parent = game:GetService("CoreGui")
end
local function createESPLabel(player)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 100, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 0)
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true
    label.Text = player.Name
    label.Visible = false
    label.Parent = ESPGui
    ESPLabels[player] = label

    local box = Drawing.new("Quad")
    box.Visible = false
    box.Color = Color3.fromRGB(0, 255, 0)
    box.Thickness = 2
    box.Transparency = 1
    ESPBoxes[player] = box
end
-- Refresh ESP
local function refreshESP()
    clearESP()

    if not ESPSettings.Box and not ESPSettings.Name then
        ESPActive = false
        return
    end

    ESPActive = true
    createESPGui()

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createESPLabel(player)
        end
    end

	if not ESPSettings.Box and not ESPSettings.Name then
    ESPActive = false

    -- Скрываем все ESP-объекты
    for _, label in pairs(ESPLabels) do
        label.Visible = false
    end
    for _, box in pairs(ESPBoxes) do
        box.Visible = false
    end
    return
end
end

-- Обновление каждый кадр
RunService.RenderStepped:Connect(function()
    if not ESPActive then return end

    for player, label in pairs(ESPLabels) do
        local character = player.Character
        local box = ESPBoxes[player]

        if character and character:FindFirstChild("HumanoidRootPart") then
            local hrp = character.HumanoidRootPart
            local pos, visible = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))

            if visible and ESPSettings.Name then
                label.Position = UDim2.new(0, pos.X - 50, 0, pos.Y - 10)
                label.Visible = true
            else
                label.Visible = false
            end

            if ESPSettings.Box then
                local size = Vector3.new(2, 3, 1.5)
                local cf = hrp.CFrame
                local corners = {
                    cf * Vector3.new(-size.X, size.Y, 0),
                    cf * Vector3.new(size.X, size.Y, 0),
                    cf * Vector3.new(size.X, -size.Y, 0),
                    cf * Vector3.new(-size.X, -size.Y, 0),
                }

                local screenPoints = {}
                local onScreen = true
                for _, corner in ipairs(corners) do
                    local point, vis = Camera:WorldToViewportPoint(corner)
                    if not vis then
                        onScreen = false
                        break
                    end
                    table.insert(screenPoints, Vector2.new(point.X, point.Y))
                end

                if onScreen then
                    box.PointA = screenPoints[1]
                    box.PointB = screenPoints[2]
                    box.PointC = screenPoints[3]
                    box.PointD = screenPoints[4]
                    box.Visible = true
                else
                    box.Visible = false
                end
            else
                box.Visible = false
            end
        else
            label.Visible = false
            if box then box.Visible = false end
        end
    end
end)

-- Цикл отключения столкновений
RunService.Stepped:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if not char then return end

    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if noclipEnabled then
                part.CanCollide = false
            else
                part.CanCollide = true
            end
        end
    end
end)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local function smoothSteal(pos)
    local player = game.Players.LocalPlayer
    if not player then return warn("No LocalPlayer") end

    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return warn("No HumanoidRootPart") end

    if typeof(pos) ~= "Vector3" then return warn("Invalid savedPosition") end

    hrp.CFrame = CFrame.new(pos)
end

-- Интерфейс Rayfield
local Window = Rayfield:CreateWindow({
   Name = "Excellent | Steal a Brainrot",
   Icon = 0, 
   LoadingTitle = "Loading Excellent Menu...",
   LoadingSubtitle = "by bloodreaper",
   ShowText = "Excellent - AuthSuite", -- for mobile button
   Theme = "Default",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = true,
   DisableBuildWarnings = true,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "Excellent Hub"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = true,
   KeySettings = {
      Title = "Auth Suite",
      Subtitle = "Complete Key System before continue",
      Note = "Buy key on offical FunPay or give in discord if you youtube",
      FileName = "keysystem",
      SaveKey = true,
      GrabKeyFromSite = true,
      Key = {"dev"}
   }
})
-- Вкладка Main
local MainTab = Window:CreateTab("Main", 4483362458)
MainTab:CreateToggle({
    Name = "Trace Player Box",
    CurrentValue = false,
    Flag = "esp_box",
    Callback = function(Value)
        ESPSettings.Box = Value
        refreshESP()
    end,
})

MainTab:CreateToggle({
    Name = "Trace Player Name",
    CurrentValue = false,
    Flag = "esp_name",
    Callback = function(Value)
        ESPSettings.Name = Value
        refreshESP()
    end,
})

local SmoothStealKeyBind = MainTab:CreateKeybind({
   Name = "Smooth Steal Keybind",
   CurrentKeybind = "Q",
   HoldToInteract = false,
   Flag = "smoothstealkeybind",
   Callback = function(Keybind)
        if savedPosition then
            smoothTeleport(savedPosition)
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Please, save a teleport pos before using auto steal!",
                Duration = 3,
				Image = "rewind",
            })
        end
   end,
})

local InstantStealKeybind = MainTab:CreateKeybind({
   Name = "Instant Steal Keybind",
   CurrentKeybind = "F",
   HoldToInteract = false,
   Flag = "instantstealkeybind",
   Callback = function(Keybind)
        if savedPosition then
            smoothSteal(savedPosition)
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Please, save a teleport pos before using auto steal!",
                Duration = 3,
				Image = "rewind",
            })
        end
   end,
})

-- Вкладка Steal
local StealTab = Window:CreateTab("Steal", nil)
-- 🖱️ Кнопка: Установить позицию
StealTab:CreateButton({
    Name = "📍 Set Auto Steal postion",
    Callback = function()
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        savedPosition = hrp.Position
        Rayfield:Notify({
            Title = "Success",
            Content = "Auto Steal teleport postion saved!",
            Duration = 3,
			Image = "rewind",
        })
    end
})

-- 🖱️ Кнопка: Телепорт
StealTab:CreateButton({
    Name = "🚀 Smooth Steal",
    Callback = function()
        if savedPosition then
            smoothTeleport(savedPosition)
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Please, save a teleport pos before using auto steal!",
                Duration = 3,
				Image = "rewind",
            })
        end
    end
})

StealTab:CreateButton({
    Name = "💾 Instant Steal",
    Callback = function()
	     if savedPosition then
            smoothSteal(savedPosition)
        else
        Rayfield:Notify({
            Title = "Error",
            Content = "Cannot find a saved steal postion!",
            Duration = 3,
			Image = "rewind",
        })
        end
    end
})

local RageTab = Window:CreateTab("Rage", nil)
RageTab:CreateToggle({
    Name = "⚡ Noclip",
    CurrentValue = false,
    Flag = "noclip",
    Callback = function(Value)
       toggleNoclip(Value)
   end,
})

local MiscTab = Window:CreateTab("Misc", "rewind")
local JobIdTextBox = MiscTab:CreateInput({
   Name = "JobID TextBox",
   CurrentValue = "",
   PlaceholderText = "Enter a JobID to join",
   RemoveTextAfterFocusLost = false,
   Flag = "jobidtextbox",
   Callback = function(Text)
          -- none
   end,
})

local JoinByJobIdButton = MiscTab:CreateButton({
   Name = "👣 Join by JobId",
   Callback = function()
        local jobId = Rayfield.Flags["jobidtextbox"].Value
        if jobId and jobId ~= "" then
        TeleportService:TeleportToPlaceInstance(PLACE_ID, jobId, LocalPlayer)
        else
        Rayfield:Notify({
            Title = "Error",
            Content = "Invalid/Incorrect JobID!",
            Duration = 3,
			Image = "rewind",
        })
	  end
   end,
})

local CopyCurrentJobIDButton = MiscTab:CreateButton({
   Name = "🗣️ Copy JobID of Current server",
   Callback = function()
    if setclipboard then
        setclipboard(game.JobId)
        Rayfield:Notify({
            Title = "Copied!",
            Content = "Current JobId copied to clipboard.",
            Duration = 3
        })
    else
        Rayfield:Notify({
            Title = "Fatal Error",
            Content = "Clipboard API Not available!",
            Duration = 3,
			Image = "rewind",
        })
    end
   end,
})

local ServerHopButton = MiscTab:CreateButton({
   Name = "🔄 Server Hop",
   Callback = function()
            local servers = {}
    local cursor = ""

    local function fetchServers()
        local url = "https://games.roblox.com/v1/games/" .. PLACE_ID .. "/servers/Public?limit=100&sortOrder=Asc&cursor=" .. cursor
        local response = HttpService:JSONDecode(game:HttpGet(url))
        cursor = response.nextPageCursor or ""

        for _, server in ipairs(response.data) do
            if server.playing < server.maxPlayers then
                table.insert(servers, server.id)
            end
        end
    end

    fetchServers()
    if #servers > 0 then
        local randomServer = servers[math.random(1, #servers)]
		if jobId == game.JobId then
    Rayfield:Notify({
        Title = "Already Here",
        Content = "You're already in this server.",
        Duration = 3
    })
    return
    end
        TeleportService:TeleportToPlaceInstance(PLACE_ID, randomServer, LocalPlayer)
    else
        warn("No available servers found")
    end
   end,
})
-- Other Tab
local OtherTab = Window:CreateTab("Other", nil)
OtherTab:CreateButton({
    Name = "Unload Interface & Script",
    Callback = function()
        Rayfield.Destroy()
        clearESP()
        ESPActive = false
    end,
})
