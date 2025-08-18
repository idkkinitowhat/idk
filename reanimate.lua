local Reanimator = Instance.new("ScreenGui")
Reanimator.Name = "Reanimator"
Reanimator.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Reanimator.Parent = game.StarterGui

local Reanim = Instance.new("TextButton")
Reanim.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
Reanim.TextColor3 = Color3.fromRGB(0, 0, 0)
Reanim.BorderColor3 = Color3.fromRGB(0, 0, 0)
Reanim.Text = "Re animate - R6 ONLY"
Reanim.AnchorPoint = Vector2.new(0.5, 1)
Reanim.Name = "Reanim"
Reanim.Position = UDim2.new(0.5, 0, 1, 0)
Reanim.Size = UDim2.new(0, 200, 0, 50)
Reanim.BorderSizePixel = 0
Reanim.TextSize = 14
Reanim.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Reanim.Parent = Reanimator

local ReanimatorGuiLogic = Instance.new("LocalScript")
ReanimatorGuiLogic.Name = "ReanimatorGuiLogic"
ReanimatorGuiLogic.Source = "local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Get GUI elements
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local reanimatorGui = playerGui:WaitForChild("Reanimator")
local reanimButton = reanimatorGui:WaitForChild("Reanim")

-- Add status and warning labels if not present
local statusLabel = reanimatorGui:FindFirstChild("StatusLabel")
if not statusLabel then
    statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(0, 400, 0, 40)
    statusLabel.Position = UDim2.new(0.5, -200, 0.8, -60)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(255,255,0)
    statusLabel.Font = Enum.Font.SourceSansBold
    statusLabel.TextSize = 24
    statusLabel.Text = ""
    statusLabel.Parent = reanimatorGui
end

local warningLabel = reanimatorGui:FindFirstChild("WarningLabel")
if not warningLabel then
    warningLabel = Instance.new("TextLabel")
    warningLabel.Name = "WarningLabel"
    warningLabel.Size = UDim2.new(0, 400, 0, 30)
    warningLabel.Position = UDim2.new(0.5, -200, 0.8, -100)
    warningLabel.BackgroundTransparency = 1
    warningLabel.TextColor3 = Color3.fromRGB(255,0,0)
    warningLabel.Font = Enum.Font.SourceSansBold
    warningLabel.TextSize = 22
    warningLabel.Text = "WARNING: R6 ONLY! This script will not work with R15 avatars."
    warningLabel.Parent = reanimatorGui
end

local FAST_SPEED = 250

-- Utility: Cleanup previous dummy and welds
local function cleanupPrevious()
    for i, obj in Workspace:GetChildren() do
        if obj:IsA("Model") and obj.Name == "R6Dummy" then
            obj:Destroy()
        end
    end
    local character = LocalPlayer.Character
    if character then
        for i, part in character:GetChildren() do
            if part:IsA("BasePart") then
                for j, weld in part:GetChildren() do
                    if weld:IsA("Weld") and weld.Name == "ReanimateWeld" then
                        weld:Destroy()
                    end
                end
            end
        end
    end
end

-- Utility: Unweld all player character parts
local function unweldPlayerCharacter()
    local character = LocalPlayer.Character
    if character then
        for i, part in character:GetChildren() do
            if part:IsA("BasePart") then
                for j, weld in part:GetChildren() do
                    if weld:IsA("Weld") then
                        weld:Destroy()
                    end
                end
            end
        end
    end
end

-- Utility: Make player character noclip (no collisions)
local function makePlayerNoclip()
    local character = LocalPlayer.Character
    if character then
        for i, part in character:GetChildren() do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        -- Keep CanCollide off in case Roblox resets it
        local function noclipLoop()
            while character and character.Parent do
                for i, part in character:GetChildren() do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                task.wait(0.5)
            end
        end
        coroutine.wrap(noclipLoop)()
    end
end

-- Utility: Set movement speed for player and dummy
local function setSpeeds(dummy)
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = FAST_SPEED
        end
    end
    if dummy then
        local dummyHumanoid = dummy:FindFirstChildOfClass("Humanoid")
        if dummyHumanoid then
            dummyHumanoid.WalkSpeed = FAST_SPEED
        end
    end
end

-- Insert dummy from asset
local function insertDummy()
    local assetId = 8246626421
    local dummyModel
    local success, result = pcall(function()
        return InsertService:LoadAsset(assetId)
    end)
    if success and result then
        for i, obj in result:GetChildren() do
            if obj:IsA("Model") then
                dummyModel = obj
                break
            end
        end
        if not dummyModel and result:IsA("Model") then
            dummyModel = result
        end
        if dummyModel then
            dummyModel.Name = "R6Dummy"
            dummyModel.Parent = Workspace
            -- Move dummy to player's position
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            if char and char:GetPivot() then
                dummyModel:PivotTo(char:GetPivot())
            end
            -- Unanchor all dummy parts
            for i, part in dummyModel:GetChildren() do
                if part:IsA("BasePart") then
                    part.Anchored = false
                end
            end
            return dummyModel
        end
    end
    return nil
end

-- Procedurally create an R6 dummy if asset insertion fails
local function createDummy()
    local dummy = Instance.new("Model")
    dummy.Name = "R6Dummy"
    local parts = {}
    local partProps = {
        ["Head"] = {size = Vector3.new(2, 1, 1), pos = Vector3.new(0, 4.5, 0)},
        ["Torso"] = {size = Vector3.new(2, 2, 1), pos = Vector3.new(0, 3, 0)},
        ["Left Arm"] = {size = Vector3.new(1, 2, 1), pos = Vector3.new(-1.5, 3, 0)},
        ["Right Arm"] = {size = Vector3.new(1, 2, 1), pos = Vector3.new(1.5, 3, 0)},
        ["Left Leg"] = {size = Vector3.new(1, 2, 1), pos = Vector3.new(-0.5, 1, 0)},
        ["Right Leg"] = {size = Vector3.new(1, 2, 1), pos = Vector3.new(0.5, 1, 0)},
    }
    for name, data in partProps do
        local part = Instance.new("Part")
        part.Name = name
        part.Size = data.size
        part.Position = data.pos
        part.Anchored = false
        part.CanCollide = true
        part.Parent = dummy
        parts[name] = part
    end
    -- Humanoid
    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = dummy
    -- Move dummy to player's position
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if char and char:GetPivot() then
        dummy:PivotTo(char:GetPivot())
    end
    dummy.Parent = Workspace
    return dummy
end

-- Weld player character parts onto the dummy (dummy is Part0, player is Part1)
local function dummyWeldToPlayer(dummy)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local mapping = {
        ["Torso"] = "Torso",
        ["Head"] = "Head",
        ["Left Arm"] = "Left Arm",
        ["Right Arm"] = "Right Arm",
        ["Left Leg"] = "Left Leg",
        ["Right Leg"] = "Right Leg"
    }
    for dummyPartName, charPartName in mapping do
        local dummyPart = dummy:FindFirstChild(dummyPartName)
        local charPart = character:FindFirstChild(charPartName)
        if dummyPart and charPart then
            local weld = Instance.new("Weld")
            weld.Name = "ReanimateWeld"
            weld.Part0 = dummyPart
            weld.Part1 = charPart
            if dummyPartName == "Head" then
                weld.C0 = CFrame.new()
                weld.C1 = dummyPart.CFrame:toObjectSpace(charPart.CFrame)
            else
                weld.C0 = CFrame.new()
                weld.C1 = CFrame.new()
            end
            weld.Parent = dummyPart
            charPart.Anchored = false
        end
    end
    -- Weld accessories and hats to dummy's head
    for i, acc in character:GetChildren() do
        if acc:IsA("Accessory") then
            local handle = acc:FindFirstChild("Handle")
            if handle then
                local dummyHead = dummy:FindFirstChild("Head")
                if dummyHead then
                    local weld = Instance.new("Weld")
                    weld.Name = "ReanimateWeld"
                    weld.Part0 = dummyHead
                    weld.Part1 = handle
                    weld.C0 = CFrame.new()
                    weld.C1 = CFrame.new()
                    weld.Parent = dummyHead
                    handle.Anchored = false
                end
            end
        end
    end
end

-- Synchronize dummy animation and movement with player
local function syncAnimation(dummy)
    local dummyHumanoid = dummy:FindFirstChildOfClass("Humanoid")
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if dummyHumanoid and humanoid then
        -- Copy animation tracks
        local function copyTracks()
            for i, track in dummyHumanoid:GetPlayingAnimationTracks() do
                local anim = track.Animation
                if anim then
                    local newTrack = humanoid:LoadAnimation(anim)
                    newTrack:Play()
                end
            end
        end
        dummyHumanoid.AnimationPlayed:Connect(function(track)
            local anim = track.Animation
            if anim then
                local newTrack = humanoid:LoadAnimation(anim)
                newTrack:Play()
            end
        end)
        -- Sync movement
        dummyHumanoid.Running:Connect(function(speed)
            humanoid:Move(Vector3.new(0,0,0), false)
        end)
        dummyHumanoid.Jumping:Connect(function(active)
            humanoid.Jump = active
        end)
        -- Sync health
        dummyHumanoid.HealthChanged:Connect(function(health)
            humanoid.Health = health
        end)
        -- Sync state
        dummyHumanoid.StateChanged:Connect(function(old, new)
            humanoid:ChangeState(new)
        end)
        copyTracks()
    end
end

-- Main reanimate logic
local function reanimate()
    statusLabel.Text = "Cleaning up previous dummy..."
    cleanupPrevious()
    statusLabel.Text = "Unwelding player character..."
    unweldPlayerCharacter()
    statusLabel.Text = "Making player noclip..."
    makePlayerNoclip()
    statusLabel.Text = "Inserting dummy model..."
    local dummy = insertDummy()
    if not dummy then
        statusLabel.Text = "Asset insert failed. Creating dummy manually..."
        dummy = createDummy()
    end
    if dummy then
        statusLabel.Text = "Welding player onto dummy..."
        dummyWeldToPlayer(dummy)
        statusLabel.Text = "Setting speeds..."
        setSpeeds(dummy)
        statusLabel.Text = "Synchronizing animation..."
        syncAnimation(dummy)
        statusLabel.Text = "Reanimation complete!"
    else
        statusLabel.Text = "Failed to create dummy model!"
    end
end

reanimButton.MouseButton1Click:Connect(function()
    reanimate()
end)

-- Support respawn/reanimation
LocalPlayer.CharacterAdded:Connect(function()
    statusLabel.Text = "Player respawned. Ready to reanimate."
end)

-- Initial status
statusLabel.Text = "Ready to reanimate."

"
ReanimatorGuiLogic.Parent = Reanimator

