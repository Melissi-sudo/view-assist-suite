--// VRO INDIAN TRUCK SIMULATOR - ASSIST SUITE \\--

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()

--========================--
-- CONFIG
--========================--
local CUSTOM_PART_NAME = "Win Part" --<< change this to your workspace part

--========================--
-- UI SETUP
--========================--
local gui = Instance.new("ScreenGui")
gui.Name = "VRO_AssistSuite"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 520, 0, 320)
main.Position = UDim2.new(0.5, -260, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local top = Instance.new("TextLabel")
top.Size = UDim2.new(1, 0, 0, 40)
top.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
top.Text = "VRO INDIAN TRUCK SIMULATOR - ASSIST SUITE"
top.TextColor3 = Color3.fromRGB(255, 170, 0)
top.Font = Enum.Font.GothamBold
top.TextSize = 14
top.Parent = main

--========================--
-- TAB BUTTONS
--========================--
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(0, 120, 1, -40)
tabFrame.Position = UDim2.new(0, 0, 0, 40)
tabFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
tabFrame.Parent = main

local function makeTab(name, pos)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 40)
	b.Position = UDim2.new(0, 0, 0, pos)
	b.Text = name
	b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	b.TextColor3 = Color3.fromRGB(255,255,255)
	b.Font = Enum.Font.Gotham
	b.TextSize = 13
	b.Parent = tabFrame
	return b
end

local tpTab = makeTab("Teleport", 0)
local gameTab = makeTab("Mini Games", 40)
local musicTab = makeTab("Music", 80)

--========================--
-- CONTENT FRAME
--========================--
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -120, 1, -40)
content.Position = UDim2.new(0, 120, 0, 40)
content.BackgroundTransparency = 1
content.Parent = main

local function clearContent()
	for _, v in pairs(content:GetChildren()) do
		v:Destroy()
	end
end

--========================--
-- TELEPORT SYSTEM
--========================--
local function teleport()
	local part = workspace:FindFirstChild(CUSTOM_PART_NAME)
	if not part then
		warn("Teleport part not found!")
		return
	end

	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0)
	end
end

--========================--
-- MINI GAMES
--========================--
local clickCount = 0

local function loadGames()
	clearContent()

	local clicker = Instance.new("TextButton")
	clicker.Size = UDim2.new(0, 200, 0, 60)
	clicker.Position = UDim2.new(0, 20, 0, 20)
	clicker.Text = "Click Me: 0"
	clicker.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	clicker.TextColor3 = Color3.fromRGB(255,255,255)
	clicker.Parent = content

	clicker.MouseButton1Click:Connect(function()
		clickCount += 1
		clicker.Text = "Click Me: " .. clickCount
	end)

	local reaction = Instance.new("TextButton")
	reaction.Size = UDim2.new(0, 200, 0, 60)
	reaction.Position = UDim2.new(0, 20, 0, 100)
	reaction.Text = "Reaction Game"
	reaction.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
	reaction.TextColor3 = Color3.fromRGB(255,255,255)
	reaction.Parent = content

	local active = false
	local startTime = 0

	reaction.MouseButton1Click:Connect(function()
		if active then return end
		active = true

		task.wait(math.random(2,5))
		startTime = tick()
		reaction.Text = "CLICK NOW!"

		local conn
		conn = reaction.MouseButton1Click:Connect(function()
			if startTime > 0 then
				local reactionTime = tick() - startTime
				reaction.Text = "Time: " .. string.format("%.2f", reactionTime) .. "s"
				startTime = 0
				active = false
				conn:Disconnect()
			end
		end)
	end)
end

--========================--
-- MUSIC SYSTEM
--========================--
local saved = {}
local currentSound = nil

local soundLibrary = {
	["Engine"] = "rbxassetid://1843529632",
	["Radio"] = "rbxassetid://9118823100",
	["Ambient"] = "rbxassetid://1848354536"
}

local function playSound(id)
	if currentSound then
		currentSound:Destroy()
	end

	local s = Instance.new("Sound")
	s.SoundId = id
	s.Volume = 1
	s.Parent = SoundService
	s:Play()

	currentSound = s
end

local function loadMusic()
	clearContent()

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0, 250, 0, 40)
	box.Position = UDim2.new(0, 20, 0, 20)
	box.PlaceholderText = "Enter SoundId or keyword..."
	box.Text = ""
	box.Parent = content

	local play = Instance.new("TextButton")
	play.Size = UDim2.new(0, 120, 0, 40)
	play.Position = UDim2.new(0, 20, 0, 80)
	play.Text = "Play"
	play.Parent = content

	local save = Instance.new("TextButton")
	save.Size = UDim2.new(0, 120, 0, 40)
	save.Position = UDim2.new(0, 150, 0, 80)
	save.Text = "Save"
	save.Parent = content

	local list = Instance.new("TextLabel")
	list.Size = UDim2.new(1, -40, 0, 120)
	list.Position = UDim2.new(0, 20, 0, 140)
	list.Text = "Saved Sounds:\n"
	list.TextColor3 = Color3.new(1,1,1)
	list.BackgroundTransparency = 0.3
	list.Parent = content

	local function refresh()
		list.Text = "Saved Sounds:\n"
		for i,v in ipairs(saved) do
			list.Text ..= i .. ". " .. v .. "\n"
		end
	end

	play.MouseButton1Click:Connect(function()
		local input = box.Text
		if soundLibrary[input] then
			playSound(soundLibrary[input])
		else
			playSound("rbxassetid://" .. input)
		end
	end)

	save.MouseButton1Click:Connect(function()
		table.insert(saved, box.Text)
		refresh()
	end)
end

--========================--
-- TAB CONNECTIONS
--========================--
tpTab.MouseButton1Click:Connect(function()
	clearContent()

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 200, 0, 60)
	btn.Position = UDim2.new(0, 20, 0, 20)
	btn.Text = "TELEPORT NOW"
	btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	btn.Parent = content

	btn.MouseButton1Click:Connect(teleport)
end)

gameTab.MouseButton1Click:Connect(loadGames)
musicTab.MouseButton1Click:Connect(loadMusic)

-- default tab
tpTab.MouseButton1Click:Fire()
