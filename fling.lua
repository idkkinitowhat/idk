--[=[
 d888b  db    db d888888b      .d888b.      db      db    db  .d8b.  
88' Y8b 88    88   `88'        VP  `8D      88      88    88 d8' `8b 
88      88    88    88            odD'      88      88    88 88ooo88 
88  ooo 88    88    88          .88'        88      88    88 88~~~88 
88. ~8~ 88b  d88   .88.        j88.         88booo. 88b  d88 88   88    @uniquadev
 Y888P  ~Y8888P' Y888888P      888888D      Y88888P ~Y8888P' YP   YP  CONVERTER 
]=]

-- Instances: 8 | Scripts: 1 | Modules: 0 | Tags: 0
local G2L = {};

-- StarterGui.secretguiflingomgyesskibidiCode_888sssss39u3o4895t389t539484ft3809
G2L["1"] = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"));
G2L["1"]["Name"] = [[secretguiflingomgyesskibidiCode_888sssss39u3o4895t389t539484ft3809]];
G2L["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;


-- StarterGui.secretguiflingomgyesskibidiCode_888sssss39u3o4895t389t539484ft3809.Frame
G2L["2"] = Instance.new("Frame", G2L["1"]);
G2L["2"]["BorderSizePixel"] = 0;
G2L["2"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 41);
G2L["2"]["Size"] = UDim2.new(0, 233, 0, 300);
G2L["2"]["Position"] = UDim2.new(0.10786, 0, 0.25275, 0);
G2L["2"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);


-- StarterGui.secretguiflingomgyesskibidiCode_888sssss39u3o4895t389t539484ft3809.Frame.FlingButton
G2L["3"] = Instance.new("TextButton", G2L["2"]);
G2L["3"]["BorderSizePixel"] = 0;
G2L["3"]["TextSize"] = 14;
G2L["3"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["3"]["BackgroundColor3"] = Color3.fromRGB(55, 55, 55);
G2L["3"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["3"]["Size"] = UDim2.new(0, 200, 0, 50);
G2L["3"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["3"]["Text"] = [[Fling player]];
G2L["3"]["Name"] = [[FlingButton]];
G2L["3"]["Position"] = UDim2.new(0.06901, 0, 0.75333, 0);


-- StarterGui.secretguiflingomgyesskibidiCode_888sssss39u3o4895t389t539484ft3809.Frame.PlayerList
G2L["4"] = Instance.new("ScrollingFrame", G2L["2"]);
G2L["4"]["Active"] = true;
G2L["4"]["BorderSizePixel"] = 0;
G2L["4"]["BackgroundColor3"] = Color3.fromRGB(113, 113, 113);
G2L["4"]["Name"] = [[PlayerList]];
G2L["4"]["Size"] = UDim2.new(0, 200, 0, 179);
G2L["4"]["ScrollBarImageColor3"] = Color3.fromRGB(0, 0, 0);
G2L["4"]["Position"] = UDim2.new(0.06867, 0, 0.11333, 0);
G2L["4"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);


-- StarterGui.secretguiflingomgyesskibidiCode_888sssss39u3o4895t389t539484ft3809.Frame.SelectedUser
G2L["5"] = Instance.new("TextLabel", G2L["2"]);
G2L["5"]["BorderSizePixel"] = 0;
G2L["5"]["TextSize"] = 14;
G2L["5"]["TextStrokeColor3"] = Color3.fromRGB(255, 255, 255);
G2L["5"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 41);
G2L["5"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["5"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["5"]["Size"] = UDim2.new(0, 233, 0, 34);
G2L["5"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["5"]["Text"] = [[Selected player : No one]];
G2L["5"]["Name"] = [[SelectedUser]];
G2L["5"]["Position"] = UDim2.new(-0, 0, 0, 0);


-- StarterGui.secretguiflingomgyesskibidiCode_888sssss39u3o4895t389t539484ft3809.Frame.UICorner
G2L["6"] = Instance.new("UICorner", G2L["2"]);



-- StarterGui.secretguiflingomgyesskibidiCode_888sssss39u3o4895t389t539484ft3809.Frame.UIDragDetector
G2L["7"] = Instance.new("UIDragDetector", G2L["2"]);



-- StarterGui.secretguiflingomgyesskibidiCode_888sssss39u3o4895t389t539484ft3809.FlingGuiLocalScript
G2L["8"] = Instance.new("LocalScript", G2L["1"]);
G2L["8"]["Name"] = [[FlingGuiLocalScript]];


-- StarterGui.secretguiflingomgyesskibidiCode_888sssss39u3o4895t389t539484ft3809.FlingGuiLocalScript
local function C_8()
local script = G2L["8"];
	local Players = game:GetService("Players")
	local TweenService = game:GetService("TweenService")
	local Workspace = game:GetService("Workspace")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local LocalPlayer = Players.LocalPlayer
	
	local gui = script.Parent
	local frame = gui:FindFirstChildWhichIsA("Frame")
	local playerList = frame:FindFirstChild("PlayerList")
	local flingButton = frame:FindFirstChild("FlingButton")
	local selectedUserLabel = frame:FindFirstChild("SelectedUser")
	
	local selectedPlayer = nil
	local isFlinging = false
	local originalGravity = Workspace.Gravity
	local flingGyro = nil
	local flingAV = nil
	
	-- Popup GUI creation
	local function createPopup(message, yesCallback, noCallback, options)
	    options = options or {}
	    local popup = Instance.new("Frame")
	    popup.Size = UDim2.new(0, 300, 0, 150)
	    popup.Position = UDim2.new(0.5, -150, 0.5, -75)
	    popup.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	    popup.BorderSizePixel = 0
	    popup.Parent = gui
	    popup.Name = "PopupWarning"
	
	    local corner = Instance.new("UICorner")
	    corner.Parent = popup
	
	    local label = Instance.new("TextLabel")
	    label.Size = UDim2.new(1, -20, 0, 60)
	    label.Position = UDim2.new(0, 10, 0, 10)
	    label.BackgroundTransparency = 1
	    label.Text = message
	    label.TextColor3 = Color3.fromRGB(255, 255, 255)
	    label.Font = Enum.Font.SourceSansBold
	    label.TextSize = 20
	    label.TextWrapped = true
	    label.Parent = popup
	
	    if options and options.okayButton then
	        local okayBtn = Instance.new("TextButton")
	        okayBtn.Size = UDim2.new(0, 120, 0, 40)
	        okayBtn.Position = UDim2.new(0.5, -60, 1, -50)
	        okayBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 180)
	        okayBtn.Text = "Okay"
	        okayBtn.TextColor3 = Color3.fromRGB(255,255,255)
	        okayBtn.Font = Enum.Font.SourceSansBold
	        okayBtn.TextSize = 18
	        okayBtn.Parent = popup
	
	        local closed = false
	        local function closePopup()
	            if not closed then
	                closed = true
	                popup:Destroy()
	                if options and options.okayCallback then
	                    options.okayCallback()
	                end
	            end
	        end
	
	        okayBtn.MouseButton1Click:Connect(closePopup)
	
	        if options and options.timeout then
	            task.spawn(function()
	                task.wait(options.timeout)
	                closePopup()
	            end)
	        end
	    else
	        local yesBtn = Instance.new("TextButton")
	        yesBtn.Size = UDim2.new(0, 120, 0, 40)
	        yesBtn.Position = UDim2.new(0, 20, 1, -50)
	        yesBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
	        yesBtn.Text = "Yes"
	        yesBtn.TextColor3 = Color3.fromRGB(255,255,255)
	        yesBtn.Font = Enum.Font.SourceSansBold
	        yesBtn.TextSize = 18
	        yesBtn.Parent = popup
	
	        local noBtn = Instance.new("TextButton")
	        noBtn.Size = UDim2.new(0, 120, 0, 40)
	        noBtn.Position = UDim2.new(1, -140, 1, -50)
	        noBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
	        noBtn.Text = "No"
	        noBtn.TextColor3 = Color3.fromRGB(255,255,255)
	        noBtn.Font = Enum.Font.SourceSansBold
	        noBtn.TextSize = 18
	        noBtn.Parent = popup
	
	        yesBtn.MouseButton1Click:Connect(function()
	            popup:Destroy()
	            if yesCallback then yesCallback() end
	        end)
	        noBtn.MouseButton1Click:Connect(function()
	            popup:Destroy()
	            if noCallback then noCallback() end
	        end)
	    end
	end
	
	-- Helper to clear player list
	local function clearPlayerList()
	    for i, child in playerList:GetChildren() do
	        if child:IsA("TextButton") then
	            child:Destroy()
	        end
	    end
	end
	
	-- Helper to update SelectedUser label
	local function updateSelectedUser()
	    if selectedPlayer then
	        selectedUserLabel.Text = "SelectedUser : " .. selectedPlayer.Name
	    else
	        selectedUserLabel.Text = "SelectedUser : (None)"
	    end
	end
	
	-- Helper to create player buttons
	local function populatePlayerList()
	    clearPlayerList()
	    local playerCount = 0
	    for i, player in Players:GetPlayers() do
	        if player ~= LocalPlayer then
	            playerCount = playerCount + 1
	            local btn = Instance.new("TextButton")
	            btn.Size = UDim2.new(1, 0, 0, 30)
	            btn.Text = player.Name
	            btn.Name = player.Name .. "_Btn"
	            btn.Parent = playerList
	            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	            btn.AutoButtonColor = true
	            btn.Font = Enum.Font.SourceSans
	            btn.TextSize = 18
	            btn.MouseButton1Click:Connect(function()
	                selectedPlayer = player
	                updateSelectedUser()
	            end)
	        end
	    end
	    -- If no other players, show popup
	    if playerCount == 0 then
	        createPopup(
	            "No other players are in this server.\nWould you like to leave and join another server manually?",
	            function()
	                -- Kick the player with a custom message
	                Players.LocalPlayer:Kick("Join another server manually by on the server list, Please.")
	            end,
	            function()
	                -- Do nothing, just close popup
	            end
	        )
	    end
	end
	
	-- Listen for player join/leave to update list
	Players.PlayerAdded:Connect(populatePlayerList)
	Players.PlayerRemoving:Connect(function(player)
	    if selectedPlayer == player then
	        stopFling()
	        createPopup(
	            "The victim (" .. player.Name .. ") left the game.\nFlinging has been stopped.",
	            nil,
	            nil,
	            {okayButton = true, timeout = 60}
	        )
	        selectedPlayer = nil
	        updateSelectedUser()
	    end
	    populatePlayerList()
	end)
	
	populatePlayerList()
	updateSelectedUser()
	
	-- Fling logic
	local function startFling()
	    if not selectedPlayer or not selectedPlayer.Character then return end
	    local char = selectedPlayer.Character
	    local torso = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
	    if not torso then return end
	
	    -- Tween to local player's torso
	    local localChar = LocalPlayer.Character
	    if not localChar then return end
	    local localTorso = localChar:FindFirstChild("HumanoidRootPart") or localChar:FindFirstChild("Torso")
	    if not localTorso then return end
	
	    -- Tween position
	    local tween = TweenService:Create(
	        torso,
	        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	        {CFrame = localTorso.CFrame}
	    )
	    tween:Play()
	
	    -- Set gravity to 0
	    Workspace.Gravity = 0
	
	    -- Add BodyGyro and BodyAngularVelocity for spinning
	    flingGyro = Instance.new("BodyGyro")
	    flingGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
	    flingGyro.P = 1e6
	    flingGyro.CFrame = torso.CFrame
	    flingGyro.Parent = torso
	
	    flingAV = Instance.new("BodyAngularVelocity")
	    flingAV.AngularVelocity = Vector3.new(0, 500, 0)
	    flingAV.MaxTorque = Vector3.new(0, 1e9, 0)
	    flingAV.Parent = torso
	
	    isFlinging = true
	    flingButton.Text = "Stop flinging"
	end
	
	function stopFling()
	    Workspace.Gravity = originalGravity
	    if flingGyro then
	        flingGyro:Destroy()
	        flingGyro = nil
	    end
	    if flingAV then
	        flingAV:Destroy()
	        flingAV = nil
	    end
	    isFlinging = false
	    flingButton.Text = "Fling"
	end
	
	flingButton.MouseButton1Click:Connect(function()
	    if not isFlinging then
	        startFling()
	    else
	        stopFling()
	    end
	end)
	
	-- Reset on respawn
	LocalPlayer.CharacterAdded:Connect(function()
	    stopFling()
	end)
	
	
end;
task.spawn(C_8);

return G2L["1"], require;
