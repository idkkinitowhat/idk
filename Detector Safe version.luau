-- Roblox System Deep Checker
-- Place this LocalScript in StarterPlayerScripts
-- SAFE: does NOT call any exploit-only APIs. Uses pcall for safety.

--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local LocalizationService = game:GetService("LocalizationService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = pcall(function() return game:GetService("MarketplaceService") end) and game:GetService("MarketplaceService") or nil
local Stats = pcall(function() return game:GetService("Stats") end) and game:GetService("Stats") or nil
local ProximityPromptService = pcall(function() return game:GetService("ProximityPromptService") end) and game:GetService("ProximityPromptService") or nil
local AvatarEditorService = pcall(function() return game:GetService("AvatarEditorService") end) and game:GetService("AvatarEditorService") or nil
local Teams = pcall(function() return game:GetService("Teams") end) and game:GetService("Teams") or nil
local TeleportService = pcall(function() return game:GetService("TeleportService") end) and game:GetService("TeleportService") or nil

local player = Players.LocalPlayer
assert(player, "LocalPlayer not found. Run as a LocalScript in StarterPlayerScripts.")

---
## Utility Functions
---
local function safeCall(func)
	local ok, res = pcall(func)
	return ok, res
end

local function new(parent, className, props)
	local obj = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			if k == "Parent" then
				obj.Parent = v
			else
				pcall(function() obj[k] = v end)
			end
		end
	end
	if parent and not obj.Parent then
		obj.Parent = parent
	end
	return obj
end

---
## UI Creation
---
local screenGui, frame, titleBar, refreshBtn, hideBtn, exitBtn, autoRefreshToggle, refreshIntervalLabel, increaseBtn, decreaseBtn, scoreLabel, progressFill, scroll, infoText, listLayout2

local function createUI()
	local playerGui = player:WaitForChild("PlayerGui")
	screenGui = new(playerGui, "ScreenGui", {Name = "RobloxDeepChecker", ResetOnSpawn = false})

	-- Main Frame
	frame = new(screenGui, "Frame", {
		Name = "Main",
		Size = UDim2.new(0, 750, 0, 520),
		Position = UDim2.new(0.5, -375, 0.5, -260),
		BackgroundColor3 = Color3.fromRGB(15, 15, 20), -- Darker background for glow contrast
		BorderSizePixel = 0,
	})
	new(frame, "UICorner", {CornerRadius = UDim.new(0, 14)})
	
	-- Simulated Glow Effect using UIStroke
	-- Outer glow: a slightly transparent, lighter blue stroke
	new(frame, "UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = 2, -- Thicker for glow effect
		Color = Color3.fromRGB(120, 180, 255), -- Blank blue
		Transparency = 0.6,
		LineJoinMode = Enum.LineJoinMode.Round
	})
	-- Inner glow: a less transparent, darker blue stroke
	new(frame, "UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = 1, -- Thinner, closer to the edge
		Color = Color3.fromRGB(40, 80, 150), -- Darker blue
		Transparency = 0.2,
		LineJoinMode = Enum.LineJoinMode.Round
	})

	-- Title bar
	titleBar = new(frame, "Frame", {
		Name = "TitleBar",
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundColor3 = Color3.fromRGB(25, 25, 35), -- Darker blue tint
		BorderSizePixel = 0
	})
	new(titleBar, "UICorner", {CornerRadius = UDim.new(0, 12)})
	new(titleBar, "TextLabel", {
		Size = UDim2.new(0.6, -20, 1, 0),
		Position = UDim2.new(0, 18, 0, 0),
		BackgroundTransparency = 1,
		Text = "Roblox Deep Environment Checker",
		TextColor3 = Color3.fromRGB(200,220,255), -- Lighter blue text
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	new(titleBar, "TextLabel", {
		Size = UDim2.new(0.25, -40, 1, 0),
		Position = UDim2.new(0.6, 12, 0, 0),
		BackgroundTransparency = 1,
		Text = "v1.1 (safe)",
		TextColor3 = Color3.fromRGB(150,170,200), -- Subtly lighter
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local function mkBtn(text, x)
		local b = new(titleBar, "TextButton", {
			Size = UDim2.new(0, 44, 0, 28),
			Position = UDim2.new(1, -120 + x, 0.5, -14),
			Text = text,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextColor3 = Color3.fromRGB(220,235,255), -- Light blue text
			BackgroundColor3 = Color3.fromRGB(40,40,55), -- Darker blue tint
			Name = text.."Btn"
		})
		new(b, "UICorner", {CornerRadius = UDim.new(0, 8)})
		return b
	end

	refreshBtn = mkBtn("↻", 6)
	hideBtn = mkBtn("−", 56)
	exitBtn = mkBtn("✕", 106)

	-- Left panel: controls & summary
	local leftPanel = new(frame, "Frame", {
		Size = UDim2.new(0, 260, 1, -70),
		Position = UDim2.new(0, 16, 0, 64),
		BackgroundTransparency = 1
	})

	new(leftPanel, "TextLabel", {
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1,
		Text = "Controls & Summary",
		TextColor3 = Color3.fromRGB(180,200,225), -- Light blue
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	new(leftPanel, "TextLabel", {
		Position = UDim2.new(0, 0, 0, 36),
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = "Auto-refresh every:",
		TextColor3 = Color3.fromRGB(150,170,200), -- Medium blue
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	autoRefreshToggle = new(leftPanel, "TextButton", {
		Position = UDim2.new(0, 0, 0, 62),
		Size = UDim2.new(1, 0, 0, 30),
		Text = "Auto-refresh: OFF",
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(220,235,255),
		BackgroundColor3 = Color3.fromRGB(45,45,60) -- Dark blue
	})
	new(autoRefreshToggle, "UICorner", {CornerRadius = UDim.new(0, 8)})

	refreshIntervalLabel = new(leftPanel, "TextLabel", {
		Position = UDim2.new(0, 0, 0, 104),
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = "Interval (sec): 10",
		TextColor3 = Color3.fromRGB(150,170,200),
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	increaseBtn = new(leftPanel, "TextButton", {
		Position = UDim2.new(0, 0, 0, 130),
		Size = UDim2.new(0.5, -6, 0, 28),
		Text = "+",
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		BackgroundColor3 = Color3.fromRGB(60,60,80), -- Darker blue
		TextColor3 = Color3.fromRGB(220,235,255)
	})
	new(increaseBtn, "UICorner", {CornerRadius = UDim.new(0, 8)})

	decreaseBtn = new(leftPanel, "TextButton", {
		Position = UDim2.new(0.5, 6, 0, 130),
		Size = UDim2.new(0.5, -6, 0, 28),
		Text = "-",
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		BackgroundColor3 = Color3.fromRGB(60,60,80), -- Darker blue
		TextColor3 = Color3.fromRGB(220,235,255)
	})
	new(decreaseBtn, "UICorner", {CornerRadius = UDim.new(0, 8)})

	scoreLabel = new(leftPanel, "TextLabel", {
		Position = UDim2.new(0, 0, 0, 176),
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		Text = "Score: --%",
		TextColor3 = Color3.fromRGB(220,235,255),
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local progressBack = new(leftPanel, "Frame", {
		Position = UDim2.new(0, 0, 0, 206),
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundColor3 = Color3.fromRGB(35,35,50), -- Dark blue
	})
	new(progressBack, "UICorner", {CornerRadius = UDim.new(0, 8)})
	progressFill = new(progressBack, "Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(70,170,255), -- Bright blue for progress
	})
	new(progressFill, "UICorner", {CornerRadius = UDim.new(0, 8)})

	infoText = new(leftPanel, "TextLabel", {
		Position = UDim2.new(0, 0, 0, 236),
		Size = UDim2.new(1, 0, 0, 180),
		BackgroundTransparency = 1,
		Text = "This checker runs ROBLOX-safe environment checks only.\nExecutor-detection is NOT executed.\nPlaceholder rows will report \"Unavailable in safe runtime\".",
		TextWrapped = true,
		TextColor3 = Color3.fromRGB(130,150,180), -- Subtler blue
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	-- Right panel: results
	local rightPanel = new(frame, "Frame", {
		Size = UDim2.new(1, -310, 1, -80),
		Position = UDim2.new(0, 290, 0, 64),
		BackgroundTransparency = 1
	})

	new(rightPanel, "TextLabel", {
		Size = UDim2.new(1, 0, 0, 24),
		BackgroundTransparency = 1,
		Text = "Checks",
		TextColor3 = Color3.fromRGB(180,200,225),
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	scroll = new(rightPanel, "ScrollingFrame", {
		Position = UDim2.new(0, 0, 0, 28),
		Size = UDim2.new(1, 0, 1, -28),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 10,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(20,20,30) -- Darker background for scroll frame
	})
	new(scroll, "UICorner", {CornerRadius = UDim.new(0, 8)}) -- Add corner to scroll frame
	listLayout2 = new(scroll, "UIListLayout", {Padding = UDim.new(0, 6)})
end

---
## Test Definitions
---
type CheckFunc = () -> (boolean, string?)
local checks: {string: CheckFunc} = {}

-- Basic service presence checks
local serviceNames = {
	"Workspace", "Players", "ReplicatedStorage", "Lighting", "SoundService",
	"HttpService", "TweenService", "RunService", "StarterGui", "StarterPlayer",
	"UserInputService", "GuiService", "TextService", "LocalizationService",
	"ProximityPromptService", "AvatarEditorService", "Teams", "TeleportService"
}
for _, svcName in ipairs(serviceNames) do
	checks["Service: "..svcName] = (function(name)
		return function()
			local ok, svc = safeCall(function() return game:GetService(name) end)
			return ok and svc ~= nil, ok and (typeof(svc) == "Instance" and "Available" or "Present")
		end
	end)(svcName)
end

-- Core function checks
checks["Core: pcall"] = function()
	return pcall(function() end), "pcall working"
end

checks["Core: task.wait / task.spawn"] = function()
	return safeCall(function() task.spawn(function() end); task.wait(0) end), "task available"
end

checks["Core: JSON encode/decode"] = function()
	return safeCall(function()
		local s = HttpService:JSONEncode({ok=true})
		local t = HttpService:JSONDecode(s)
		return t and t.ok
	end)
end

checks["Core: Lua math library"] = function()
	return pcall(function() return math.abs(-10) == 10 end), "math OK"
end

checks["Core: string library"] = function()
	return pcall(function() return string.upper("test") == "TEST" end), "string OK"
end

checks["Core: table library"] = function()
	return pcall(function() local t = {1, 2}; table.insert(t, 3); return #t == 3 end), "table OK"
end

-- Player & character checks
checks["Player: Backpack exists"] = function()
	return player:FindFirstChildOfClass("Backpack") ~= nil, "Backpack exists"
end

checks["Player: PlayerGui writable"] = function()
	return safeCall(function()
		local g = Instance.new("ScreenGui", player:FindFirstChild("PlayerGui") or player.PlayerGui)
		g:Destroy()
		return true
	end)
end

checks["Character: Humanoid present"] = function()
	local ok, char = safeCall(function() return player.Character or player.CharacterAdded:Wait() end)
	return ok and char:FindFirstChildWhichIsA("Humanoid") ~= nil, ok and "Humanoid found" or "Character not found or no Humanoid"
end

checks["Character: HumanoidRootPart present"] = function()
	local ok, char = safeCall(function() return player.Character or player.CharacterAdded:Wait() end)
	return ok and char:FindFirstChild("HumanoidRootPart") ~= nil, ok and "HumanoidRootPart found" or "Character not found or no HumanoidRootPart"
end

-- Workspace checks
checks["Workspace: Can create & parent Part"] = function()
	return safeCall(function()
		local p = Instance.new("Part", workspace); p:Destroy()
		return true
	end)
end

checks["Workspace: CurrentCamera exists"] = function()
	return workspace.CurrentCamera ~= nil, "CurrentCamera found"
end

-- UI checks
checks["UI: Create Frame & UIListLayout"] = function()
	return safeCall(function()
		local s = Instance.new("ScreenGui"); local f = Instance.new("Frame", s); local l = Instance.new("UIListLayout", f); s:Destroy()
		return true
	end)
end

checks["UI: Text measurement (TextService)"] = function()
	return safeCall(function()
		local size = TextService:GetTextSize("Test", 14, Enum.Font.Gotham, Vector2.new(300, 200))
		return size.X > 0, "TextService is working"
	end)
end

checks["UI: Create ScrollingFrame"] = function()
	return safeCall(function()
		local s = Instance.new("ScreenGui"); local sf = Instance.new("ScrollingFrame", s); s:Destroy()
		return true
	end)
end

-- Sound & Lighting
checks["SoundService: Can create Sound"] = function()
	return safeCall(function()
		local s = Instance.new("Sound", game:GetService("SoundService")); s:Destroy()
		return true
	end)
end

checks["Lighting: Can access properties"] = function()
	return safeCall(function()
		local old = game:GetService("Lighting").ClockTime; game:GetService("Lighting").ClockTime = old;
		return true
	end)
end

-- Networking-safe checks (no remote invocation)
checks["ReplicatedStorage: Create RemoteEvent (non-used)"] = function()
	return safeCall(function()
		local ev = Instance.new("RemoteEvent", ReplicatedStorage); ev:Destroy()
		return true
	end)
end

checks["MarketplaceService: Accessible"] = function()
	return MarketplaceService ~= nil, "MarketplaceService is present"
end

checks["TeleportService: Accessible"] = function()
	return TeleportService ~= nil, "TeleportService is present"
end

-- Physics checks (safe)
checks["Physics: Create Constraint & delete"] = function()
	return safeCall(function()
		local p1 = Instance.new("Part", workspace); local p2 = Instance.new("Part", workspace); local w = Instance.new("WeldConstraint", p1); w.Part0 = p1; w.Part1 = p2; w:Destroy(); p1:Destroy(); p2:Destroy()
		return true
	end)
end

-- Datamodel & introspection
checks["Introspection: typeof() is a function"] = function()
	return typeof(typeof) == "function", "typeof is a function"
end

checks["Introspection: debug.info exists?"] = function()
	return typeof(debug.info) == "function", "debug.info is a function"
end

checks["Stats: FrameTime reading"] = function()
	return Stats ~= nil and safeCall(function() return Stats.FrameTime > 0 end), "Stats.FrameTime is readable"
end

-- New checks for extended version
checks["Physics: Can create AssemblyLinearVelocity"] = function()
	return safeCall(function()
		local part = Instance.new("Part", workspace)
		part.AssemblyLinearVelocity = Vector3.new(10, 0, 0)
		part:Destroy()
		return true
	end), "AssemblyLinearVelocity writable"
end

checks["Physics: Can create RopeConstraint"] = function()
	return safeCall(function()
		local a = Instance.new("Attachment", workspace.CurrentCamera) -- Attach to camera for quick creation
		local b = Instance.new("Attachment", workspace.CurrentCamera)
		local rope = Instance.new("RopeConstraint", a)
		rope.Attachment1 = b
		rope:Destroy()
		a:Destroy()
		b:Destroy()
		return true
	end), "RopeConstraint can be created"
end

checks["AvatarEditorService: IsClientAllowedToOpen"] = function()
	return safeCall(function()
		if not AvatarEditorService then return false end
		return typeof(AvatarEditorService.IsClientAllowedToOpen) == "function", "IsClientAllowedToOpen exists"
	end)
end

checks["Teams: Can create a Team"] = function()
	return safeCall(function()
		if not Teams then return false end
		local team = Instance.new("Team", Teams)
		team:Destroy()
		return true
	end), "Team can be created"
end

checks["ProximityPromptService: Can access service"] = function()
	return ProximityPromptService ~= nil, "ProximityPromptService is present"
end

checks["Remote signals: Create BindableEvent"] = function()
	return safeCall(function()
		local b = Instance.new("BindableEvent", ReplicatedStorage); b:Destroy()
		return true
	end), "BindableEvent can be created"
end

checks["LocalizationService: GetCountryRegionForPlayer"] = function()
	return safeCall(function()
		local ok, _ = pcall(function() return LocalizationService:GetCountryRegionForPlayer(player) end)
		return ok, "Method callable"
	end)
end

checks["UserInputService: MouseLocation is CFrame"] = function()
	return safeCall(function()
		local mousePos = UserInputService:GetMouseLocation()
		return typeof(mousePos) == "Vector2" and mousePos.X >= 0 and mousePos.Y >= 0, "MouseLocation available"
	end)
end

checks["HttpService: GenerateGUID"] = function()
	return safeCall(function()
		local guid = HttpService:GenerateGUID(false)
		return typeof(guid) == "string" and #guid > 0, "GUID generation works"
	end)
end

checks["CollectionService: Add Tag"] = function()
	return safeCall(function()
		local CollectionService = game:GetService("CollectionService")
		local p = Instance.new("Part", workspace)
		CollectionService:AddTag(p, "TestTag")
		local hasTag = CollectionService:HasTag(p, "TestTag")
		CollectionService:RemoveTag(p, "TestTag")
		p:Destroy()
		return hasTag, "CollectionService tags work"
	end)
end

checks["RunService: Heartbeat Connection"] = function()
	return safeCall(function()
		local connection = RunService.Heartbeat:Connect(function() end)
		connection:Disconnect()
		return true, "Heartbeat connect/disconnect works"
	end)
end

checks["Player: Chatted event accessible"] = function()
	return safeCall(function()
		return typeof(player.Chatted) == "RBXScriptSignal", "Chatted event accessible"
	end)
end

checks["Workspace: StreamingEnabled Property"] = function()
	return safeCall(function()
		return typeof(workspace.StreamingEnabled) == "boolean", "StreamingEnabled property exists"
	end)
end

checks["Lighting: Brightness Property"] = function()
	return safeCall(function()
		local oldBrightness = game:GetService("Lighting").Brightness
		game:GetService("Lighting").Brightness = oldBrightness
		return true, "Brightness property is accessible"
	end)
end

checks["SoundService: RespectsFilteringEnabled Property"] = function()
	return safeCall(function()
		return typeof(game:GetService("SoundService").RespectFilteringEnabled) == "boolean", "RespectFilteringEnabled property exists"
	end)
end

checks["StarterPlayer: CameraMaxZoomDistance Property"] = function()
	return safeCall(function()
		local StarterPlayer = game:GetService("StarterPlayer")
		return typeof(StarterPlayer.CameraMaxZoomDistance) == "number", "CameraMaxZoomDistance accessible"
	end)
end

checks["Executor-detection: Safe Placeholder"] = function()
	return false, "Unavailable in safe runtime (exploit-only)"
end

---
## Core Logic
---
local function addStatusRow(titleText, ok, detailText)
	local row = new(scroll, "Frame", {
		Size = UDim2.new(1, -12, 0, 24),
		BackgroundColor3 = Color3.fromRGB(30,30,40), -- Darker blue for rows
		BorderSizePixel = 0
	})
	new(row, "UICorner", {CornerRadius = UDim.new(0, 4)})

	new(row, "TextLabel", {
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(0.68, -10, 1, 0),
		BackgroundTransparency = 1,
		Text = titleText,
		TextColor3 = Color3.fromRGB(190,210,240), -- Light blue text
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	new(row, "TextLabel", {
		Position = UDim2.new(0.7, 0, 0, 0),
		Size = UDim2.new(0.3, -12, 1, 0),
		BackgroundTransparency = 1,
		Text = detailText or (ok and "✅ Passed" or "❌ Failed"),
		TextColor3 = ok and Color3.fromRGB(100,200,255) or Color3.fromRGB(255,100,100), -- Bright blue for pass, red for fail
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right
	})

	scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout2.AbsoluteContentSize.Y + 10)
end

local function runAllChecks()
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	
	local total, passed = 0, 0
	for name, fn in pairs(checks) do
		local ok, detail = fn()
		addStatusRow(name, ok, detail)
		if ok then passed += 1 end
		total += 1
		
		local percent = total == 0 and 0 or math.floor(passed / total * 100)
		scoreLabel.Text = ("Score: %d%% — %d / %d"):format(percent, passed, total)
		local tween = TweenService:Create(progressFill, TweenInfo.new(0.15), {Size = UDim2.new(percent / 100, 0, 1, 0)})
		tween:Play()
		task.wait(0.01)
	end
end

---
## Main Execution
---
createUI()

refreshBtn.MouseButton1Click:Connect(runAllChecks)
hideBtn.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible end)
exitBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

local interval = 10
local autoOn = false
autoRefreshToggle.MouseButton1Click:Connect(function()
	autoOn = not autoOn
	autoRefreshToggle.Text = autoOn and ("Auto-refresh: ON ("..interval.."s)") or "Auto-refresh: OFF"
end)
increaseBtn.MouseButton1Click:Connect(function()
	interval = math.clamp(interval + 1, 1, 3600)
	refreshIntervalLabel.Text = "Interval (sec): "..tostring(interval)
	autoRefreshToggle.Text = autoOn and ("Auto-refresh: ON ("..interval.."s)") or "Auto-refresh: OFF"
end)
decreaseBtn.MouseButton1Click:Connect(function()
	interval = math.clamp(interval - 1, 1, 3600)
	refreshIntervalLabel.Text = "Interval (sec): "..tostring(interval)
	autoRefreshToggle.Text = autoOn and ("Auto-refresh: ON ("..interval.."s)") or "Auto-refresh: OFF"
end)

local dragging = false
local dragStart, startPos
titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)
titleBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
RunService.RenderStepped:Connect(function()
	if dragging then
		local mouse = UserInputService:GetMouseLocation()
		local delta = mouse - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

runAllChecks()
task.spawn(function()
	while task.wait(0.5) and screenGui.Parent do
		if autoOn then
			task.wait(interval)
			if autoOn and screenGui.Parent then
				runAllChecks()
			end
		end
	end
end)
