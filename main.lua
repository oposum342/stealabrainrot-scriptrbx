local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local RunService = game:GetService("RunService")
local LocalPlayer = game.Players.LocalPlayer
local noclipBoosterEnabled = false
local boosterForce = 1000 -- сила проталкивания

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

function setSpeed(Value)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
    end
end

function setJump(Value)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = Value
    end
end
local function enableBooster()
    noclipBoosterEnabled = true
end

local function disableBooster()
    noclipBoosterEnabled = false
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local bv = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BoosterVelocity")
        if bv then bv:Destroy() end
    end
end

RunService.Stepped:Connect(function()
    if noclipBoosterEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        local bv = hrp:FindFirstChild("BoosterVelocity")

        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "BoosterVelocity"
            bv.MaxForce = Vector3.new(boosterForce, boosterForce, boosterForce)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = hrp
        end

        local moveDir = LocalPlayer.Character:FindFirstChildOfClass("Humanoid").MoveDirection
        bv.Velocity = moveDir * 20 -- скорость движения сквозь препятствия
    end
end)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local blinkEnabled = false
local buffer = {}
local bufferSize = 10 -- сколько кадров задержки

RunService.RenderStepped:Connect(function()
    if blinkEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character.HumanoidRootPart
        table.insert(buffer, hrp.CFrame)

        if #buffer > bufferSize then
            hrp.CFrame = buffer[1] -- применяем старую позицию
            table.remove(buffer, 1)
        end
    end
end)

-- Включение/выключение
function toggleBlink()
    blinkEnabled = not blinkEnabled
    buffer = {}
end



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

-- Очистка ESP
local function clearESP()
    if ESPGui then ESPGui:Destroy() end
    ESPLabels = {}
    for _, box in pairs(ESPBoxes) do
        box:Remove()
    end
    ESPBoxes = {}
end

-- Создание GUI
local function createESPGui()
    ESPGui = Instance.new("ScreenGui")
    ESPGui.Name = "SafeESP"
    ESPGui.ResetOnSpawn = false
    ESPGui.Parent = game:GetService("CoreGui")
end

-- Создание метки и бокса
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

-- Обновление ESP
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

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local noclipEnabled = false

-- Функция включения/выключения noclip
local function toggleNoclip()
    noclipEnabled = not noclipEnabled
end

-- Цикл отключения столкновений
RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end
end)


-- Интерфейс Rayfield
local Window = Rayfield:CreateWindow({
    Name = "Legit Hub | ⚡ Steal a Brainrot",
    Icon = 0,
    LoadingTitle = "Loading interface...",
    LoadingSubtitle = "by fronex",
    ShowText = "HackWare",
    Theme = "Default",
    ToggleUIKeybind = "K",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,

    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "Legit Hub"
    },

    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },

    KeySystem = true,
    KeySettings = {
        Title = "Key System | ✅ Steal a Brainrot",
        Subtitle = "Auth to use this script.",
        Note = "Use a free key while script working in progress, Key: Free",
        FileName = "key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"Free"}
    }
})

-- Вкладка Main
local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateToggle({
    Name = "ESP Box",
    CurrentValue = false,
    Flag = "esp_box",
    Callback = function(Value)
        ESPSettings.Box = Value
        refreshESP()
    end,
})

MainTab:CreateToggle({
    Name = "ESP Name",
    CurrentValue = false,
    Flag = "esp_name",
    Callback = function(Value)
        ESPSettings.Name = Value
        refreshESP()
    end,
})
-- Вкладка Rage
local RageTab = Window:CreateTab("Rage", nil)
RageTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "noclip",
    Callback = function(Value)
        toggleNoclip()
    end,
})
-- Other Tab
local OtherTab = Window:CreateTab("Other Tab", nil)
OtherTab:CreateButton({
    Name = "Unload Interface & Script",
    Callback = function()
        Rayfield.Destroy()
        clearESP()
        ESPActive = false
    end,
})
