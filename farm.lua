-- Ultimate Blox Fruits AutoQuest & AutoFarm
-- Self-contained, auto-detects level, tweens, equips, and attacks

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- CONFIG
local Config = {
    TweenSpeed = 600,
    HoverHeight = 20,
    AutoEquip = true,
    AutoClick = true,
    HitboxSize = 80,
    QuestInterval = 1,
    EnemyCheckInterval = 0.1,
}

-- WAIT FOR CHARACTER
local function WaitForChar()
    repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    return LocalPlayer.Character
end
local Character = WaitForChar()
local HRP = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Tween helper
local function TweenTo(Pos)
    local dist = (HRP.Position - Pos).Magnitude
    local tween = TweenService:Create(HRP, TweenInfo.new(dist/Config.TweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(Pos.X, Pos.Y + Config.HoverHeight, Pos.Z)})
    tween:Play()
    tween.Completed:Wait()
end

-- Equip first tool
local function EquipFirst()
    if Config.AutoEquip then
        for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                Humanoid:EquipTool(tool)
                break
            end
        end
    end
end

-- CombatFramework patch
local CombatFramework
pcall(function()
    local cfOld = require(LocalPlayer.PlayerScripts:WaitForChild("CombatFramework"))
    CombatFramework = debug.getupvalues(cfOld)[2]
end)

RunService.Stepped:Connect(function()
    if CombatFramework and CombatFramework.activeController then
        local ac = CombatFramework.activeController
        ac.attacking = false
        ac.increment = 3
        ac.blocking = false
        ac.timeToNextBlock = 0
        ac.timeToNextAttack = 0
        ac.hitboxMagnitude = Config.HitboxSize
    end
end)

-- Get quest NPC and enemy
local function GetClosestQuest()
    local QuestsModule = require(ReplicatedStorage:WaitForChild("Quests"))
    local GuideModule = require(ReplicatedStorage:WaitForChild("GuideModule"))
    local lvl = LocalPlayer.Data.Level.Value
    local bestQuest, bestLvl = nil, 0

    -- find best quest
    for _, quest in pairs(QuestsModule) do
        for _, q in pairs(quest) do
            if q.LevelReq <= lvl and q.LevelReq > bestLvl then
                bestQuest = q
                bestLvl = q.LevelReq
            end
        end
    end

    if not bestQuest then return nil end

    -- find NPC
    local NPCPos
    for _, npc in pairs(GuideModule.Data.NPCList) do
        if npc.NPCName == GuideModule.Data.LastClosestNPC then
            NPCPos = npc.Position
        end
    end

    return {Quest=bestQuest, NPCPos=NPCPos, Enemy=next(bestQuest.Task)}
end

-- Start quest
local function StartQuest(q)
    if not q then return end
    local rem = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
    pcall(function() rem:InvokeServer("StartQuest", q.Quest.Name, 1) end)
end

-- Get live enemies
local function GetEnemies(name)
    local list = {}
    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            if v.Humanoid.Health > 0 and v.Name:find(name) then
                table.insert(list, v)
            end
        end
    end
    return list
end

-- Attack logic
local function Attack(enemy)
    if not enemy or not enemy:FindFirstChild("HumanoidRootPart") then return end
    EquipFirst()
    TweenTo(enemy.HumanoidRootPart.Position)
    if Config.AutoClick then
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:Button1Down(Vector2.new(0,0))
    end
end

-- MAIN LOOP
task.spawn(function()
    while true do
        local data = GetClosestQuest()
        if data and data.NPCPos then
            TweenTo(data.NPCPos)
            StartQuest(data)
            local enemies = GetEnemies(data.Enemy)
            for _, e in pairs(enemies) do
                Attack(e)
                task.wait(Config.EnemyCheckInterval)
            end
        end
        task.wait(Config.QuestInterval)
    end
end)
