--=========================================================
-- VRO AIM SUITE (PREMIUM EDITION - V5)
--=========================================================

--// SERVICES
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")
local CoreGui           = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera")

--=========================================================
-- PREMIUM CYBER THEME & CONSTANTS
--=========================================================
local ACCENT_GLOW       = Color3.fromRGB(255, 64, 87)
local ACCENT_DARK       = Color3.fromRGB(180, 20, 45)
local SUCCESS_GREEN     = Color3.fromRGB(46, 204, 113)
local BG_MAIN           = Color3.fromRGB(10, 10, 13)
local BG_CARD           = Color3.fromRGB(16, 16, 22)
local BG_PANEL          = Color3.fromRGB(22, 22, 28)
local BG_WIDGET         = Color3.fromRGB(28, 28, 38)
local BG_WIDGET_ACTIVE  = Color3.fromRGB(44, 24, 34)

local TEXT_PREMIUM      = Color3.fromRGB(250, 250, 255)
local TEXT_MUTED        = Color3.fromRGB(160, 160, 180)

local animationsEnabled = true
local menuOpen          = true

--=========================================================
-- STATE MANAGEMENT
--=========================================================
local selectedPlayer   = nil
local targetMode       = "All"

local ESP_Enabled           = true
local ESP_TeamColor         = true
local ESP_FillTransparency  = 0.5
local ESP_MaxDistance       = 2000

local Aimbot_Enabled            = true
local Aimbot_MaxDistance        = 2000 -- NEW: How far the aimbot can see
local Aimbot_WallCheck          = true
local Aimbot_ThinWallCheck      = false
local Aimbot_PenetrationMode    = 1 -- 1: Auto, 2: Heavy (Sniper), 3: Light (Other)
local Aimbot_TeamCheck          = true
local Aimbot_Prediction         = true
local Aimbot_Sensitivity        = 0.18
local Aimbot_FOVRadius          = 250
local Aimbot_ShowFOV            = true
local Aimbot_On                 = false
local Aimbot_360Mode            = false
local Aimbot_EnemyVisibleSound  = false

local RageMode_Enabled          = false
local Rage_FOVRadius            = 550
local Rage_Sensitivity          = 0.5

local SOUND_ENEMY_VISIBLE = "rbxassetid://150975887"
local visibleEnemies = {}

local Settings = {
	AimbotKey = Enum.KeyCode.E,
	MenuKey = Enum.KeyCode.Insert,
	BasePredictionStrength = 0.12,
	DistanceScaleFactor = 0.001,
}

--=========================================================
-- ROOT GUI INITIALIZATION
--=========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VroAimSuite_Premium"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local success = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = player:WaitForChild("PlayerGui") end

--=========================================================
-- NOTIFICATIONS SYSTEM
--=========================================================
local NotificationContainer = Instance.new("Frame")
NotificationContainer.Size = UDim2.new(0, 340, 1, 0)
NotificationContainer.Position = UDim2.new(1, -360, 0, 30)
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.ZIndex = 100
NotificationContainer.Parent = ScreenGui

local NotificationLayout = Instance.new("UIListLayout")
NotificationLayout.Padding = UDim.new(0, 10)
NotificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotificationLayout.Parent = NotificationContainer

local function notify(msg, color)
	color = color or ACCENT_GLOW
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 50)
	card.BackgroundColor3 = BG_CARD
	card.BackgroundTransparency = 1
	card.ZIndex = 101
	card.Parent = NotificationContainer

	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
	local stroke = Instance.new("UIStroke", card)
	stroke.Color = color
	stroke.Thickness = 1.5

	local glowBar = Instance.new("Frame")
	glowBar.Size = UDim2.new(0, 4, 1, 0)
	glowBar.BackgroundColor3 = color
	glowBar.BorderSizePixel = 0
	glowBar.ZIndex = 102
	glowBar.Parent = card

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -20, 1, 0)
	lbl.Position = UDim2.new(0, 14, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = msg
	lbl.TextColor3 = TEXT_PREMIUM
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 13
	lbl.ZIndex = 102
	lbl.Parent = card

	card.Position = UDim2.new(1, 50, 0, 0)
	TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}):Play()

	task.delay(3, function()
		if card.Parent then
			local t = TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1})
			t:Play()
			t.Completed:Wait()
			card:Destroy()
		end
	end)
end

--=========================================================
-- MAIN INTERFACE FRAME
--=========================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 0, 0, 0) 
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = BG_MAIN
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 5
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
local frameStroke = Instance.new("UIStroke", MainFrame)
frameStroke.Color = ACCENT_GLOW
frameStroke.Thickness = 2

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = BG_CARD
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 6
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 16)

local TitleBarFix = Instance.new("Frame")
TitleBarFix.Size = UDim2.new(1, 0, 0, 16)
TitleBarFix.Position = UDim2.new(0, 0, 1, -16)
TitleBarFix.BackgroundColor3 = BG_CARD
TitleBarFix.BorderSizePixel = 0
TitleBarFix.ZIndex = 5
TitleBarFix.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0, 250, 1, 0)
TitleText.Position = UDim2.new(0, 20, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Text = "VRO AIM SUITE"
TitleText.TextColor3 = TEXT_PREMIUM
TitleText.Font = Enum.Font.GothamBlack
TitleText.TextSize = 18
TitleText.ZIndex = 6
TitleText.Parent = TitleBar

-- Window Controls (Fixed Minus/Plus Symbols)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -44, 0.5, -16)
CloseBtn.BackgroundColor3 = BG_WIDGET
CloseBtn.Text = "×"
CloseBtn.TextColor3 = TEXT_MUTED
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 22
CloseBtn.AutoButtonColor = false
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 7
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 32, 0, 32)
MinimizeBtn.Position = UDim2.new(1, -84, 0.5, -16)
MinimizeBtn.BackgroundColor3 = BG_WIDGET
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = TEXT_MUTED
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 22
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.ZIndex = 7
MinimizeBtn.Parent = TitleBar
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 8)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local isMinimized = false
local defaultSize = UDim2.new(0, 760, 0, 460)
MinimizeBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 760, 0, 50)}):Play()
		MinimizeBtn.Text = "+"
	else
		TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = defaultSize}):Play()
		MinimizeBtn.Text = "−"
	end
end)

local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true; dragStart = input.Position; startPos = MainFrame.Position
		input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

--=========================================================
-- LAYOUT ARCHITECTURE
--=========================================================
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, 0, 1, -50)
Container.Position = UDim2.new(0, 0, 0, 50)
Container.BackgroundTransparency = 1
Container.ZIndex = 5
Container.Parent = MainFrame

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 200, 1, -20)
Sidebar.Position = UDim2.new(0, 14, 0, 10)
Sidebar.BackgroundColor3 = BG_CARD
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 5
Sidebar.Parent = Container
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
local SidebarPad = Instance.new("UIPadding", Sidebar)
SidebarPad.PaddingTop = UDim.new(0, 14)
SidebarPad.PaddingLeft = UDim.new(0, 12)
SidebarPad.PaddingRight = UDim.new(0, 12)

local MainArea = Instance.new("Frame")
MainArea.Size = UDim2.new(1, -242, 1, -20)
MainArea.Position = UDim2.new(0, 228, 0, 10)
MainArea.BackgroundColor3 = BG_PANEL
MainArea.BorderSizePixel = 0
MainArea.ClipsDescendants = true
MainArea.ZIndex = 5
MainArea.Parent = Container
Instance.new("UICorner", MainArea).CornerRadius = UDim.new(0, 12)

local function createPanel(name)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = name
	scroll.BackgroundTransparency = 1
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.Position = UDim2.new(0, 50, 0, 0) 
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = ACCENT_GLOW
	scroll.BorderSizePixel = 0
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Visible = false
	scroll.ZIndex = 6
	scroll.Parent = MainArea

	local layout = Instance.new("UIListLayout", scroll)
	layout.Padding = UDim.new(0, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	local pad = Instance.new("UIPadding", scroll)
	pad.PaddingTop = UDim.new(0, 14)
	pad.PaddingLeft = UDim.new(0, 14)
	pad.PaddingRight = UDim.new(0, 14)
	pad.PaddingBottom = UDim.new(0, 14)

	return scroll
end

local TargetScroll   = createPanel("Target")
local AimbotScroll   = createPanel("Aimbot")
local ESPScroll      = createPanel("ESP")
local SettingsScroll = createPanel("Settings")

local panels = {TargetScroll, AimbotScroll, ESPScroll, SettingsScroll}

local function setTab(activeName)
	for _, panel in ipairs(panels) do
		if panel.Name == activeName then
			panel.Visible = true
			panel.Position = UDim2.new(0, 30, 0, 0) 
			TweenService:Create(panel, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
		else
			panel.Visible = false
		end
	end
end

local function createTabBtn(text, order, tabID)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 38)
	btn.BackgroundColor3 = BG_WIDGET
	btn.TextColor3 = TEXT_MUTED
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 13
	btn.Text = text
	btn.LayoutOrder = order
	btn.AutoButtonColor = false
	btn.BorderSizePixel = 0
	btn.ZIndex = 6
	btn.Parent = Sidebar
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0, 3, 0, 16)
	indicator.Position = UDim2.new(0, 8, 0.5, -8)
	indicator.BackgroundColor3 = ACCENT_GLOW
	indicator.BorderSizePixel = 0
	indicator.Visible = false
	indicator.Parent = btn

	return btn, indicator
end

local tBtn, tInd = createTabBtn("Target Settings", 1, "Target")
local aBtn, aInd = createTabBtn("Aimbot & Rage", 2, "Aimbot")
local eBtn, eInd = createTabBtn("Visuals / ESP", 3, "ESP")
local sBtn, sInd = createTabBtn("Settings", 4, "Settings")

local tabs = {
	{btn = tBtn, ind = tInd, name = "Target"},
	{btn = aBtn, ind = aInd, name = "Aimbot"},
	{btn = eBtn, ind = eInd, name = "ESP"},
	{btn = sBtn, ind = sInd, name = "Settings"},
}

local function selectTab(name)
	for _, t in ipairs(tabs) do
		if t.name == name then
			t.btn.BackgroundColor3 = BG_WIDGET_ACTIVE
			t.btn.TextColor3 = TEXT_PREMIUM
			t.ind.Visible = true
			setTab(name)
		else
			t.btn.BackgroundColor3 = BG_WIDGET
			t.btn.TextColor3 = TEXT_MUTED
			t.ind.Visible = false
		end
	end
end

tBtn.MouseButton1Click:Connect(function() selectTab("Target") end)
aBtn.MouseButton1Click:Connect(function() selectTab("Aimbot") end)
eBtn.MouseButton1Click:Connect(function() selectTab("ESP") end)
sBtn.MouseButton1Click:Connect(function() selectTab("Settings") end)

--=========================================================
-- UI FACTORY COMPONENTS
--=========================================================
local function createHeader(parent, title)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 24)
	lbl.BackgroundTransparency = 1
	lbl.Text = string.upper(title)
	lbl.TextColor3 = ACCENT_GLOW
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 6
	lbl.Parent = parent
end

local function createToggle(parent, title, subtitle, default, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 56)
	card.BackgroundColor3 = BG_CARD
	card.BorderSizePixel = 0
	card.ZIndex = 6
	card.Parent = parent
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

	local tLbl = Instance.new("TextLabel")
	tLbl.Size = UDim2.new(1, -120, 0, 22)
	tLbl.Position = UDim2.new(0, 14, 0, 6)
	tLbl.BackgroundTransparency = 1
	tLbl.Text = title
	tLbl.TextColor3 = TEXT_PREMIUM
	tLbl.Font = Enum.Font.GothamBold
	tLbl.TextSize = 13
	tLbl.TextXAlignment = Enum.TextXAlignment.Left
	tLbl.Parent = card

	local switch = Instance.new("TextButton")
	switch.Size = UDim2.new(0, 46, 0, 24)
	switch.Position = UDim2.new(1, -60, 0.5, -12)
	switch.BackgroundColor3 = BG_WIDGET
	switch.Text = ""
	switch.AutoButtonColor = false
	switch.Parent = card
	Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 18, 0, 18)
	dot.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
	dot.BackgroundColor3 = default and ACCENT_GLOW or TEXT_MUTED
	dot.Parent = switch
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

	local state = default
	callback(state)

	switch.MouseButton1Click:Connect(function()
		state = not state
		callback(state)
		local p = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
		local c = state and ACCENT_GLOW or TEXT_MUTED
		if animationsEnabled then
			TweenService:Create(dot, TweenInfo.new(0.2), {Position = p, BackgroundColor3 = c}):Play()
		else
			dot.Position = p; dot.BackgroundColor3 = c
		end
	end)
end

local function createSlider(parent, title, minVal, maxVal, default, callback, metric)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 74)
	card.BackgroundColor3 = BG_CARD
	card.BorderSizePixel = 0
	card.ZIndex = 6
	card.Parent = parent
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

	local tLbl = Instance.new("TextLabel")
	tLbl.Size = UDim2.new(1, -100, 0, 22)
	tLbl.Position = UDim2.new(0, 14, 0, 8)
	tLbl.BackgroundTransparency = 1
	tLbl.Text = title
	tLbl.TextColor3 = TEXT_PREMIUM
	tLbl.Font = Enum.Font.GothamBold
	tLbl.TextSize = 13
	tLbl.TextXAlignment = Enum.TextXAlignment.Left
	tLbl.Parent = card

	local vLbl = Instance.new("TextLabel")
	vLbl.Size = UDim2.new(0, 80, 0, 22)
	vLbl.Position = UDim2.new(1, -94, 0, 8)
	vLbl.BackgroundTransparency = 1
	vLbl.Text = tostring(default) .. (metric or "")
	vLbl.TextColor3 = ACCENT_GLOW
	vLbl.Font = Enum.Font.GothamBold
	vLbl.TextSize = 13
	vLbl.TextXAlignment = Enum.TextXAlignment.Right
	vLbl.Parent = card

	local lane = Instance.new("Frame")
	lane.Size = UDim2.new(1, -28, 0, 6)
	lane.Position = UDim2.new(0, 14, 0, 48)
	lane.BackgroundColor3 = BG_WIDGET
	lane.BorderSizePixel = 0
	lane.Parent = card
	Instance.new("UICorner", lane).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - minVal) / (maxVal - minVal), 0, 1, 0)
	fill.BackgroundColor3 = ACCENT_GLOW
	fill.BorderSizePixel = 0
	fill.Parent = lane
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = UDim2.new((default - minVal) / (maxVal - minVal), -7, 0.5, -7)
	knob.BackgroundColor3 = TEXT_PREMIUM
	knob.Text = ""
	knob.AutoButtonColor = false
	knob.BorderSizePixel = 0
	knob.Parent = lane
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local isDragging = false
	local function updateSlider(val)
		val = math.clamp(val, minVal, maxVal)
		local percentage = (val - minVal) / (maxVal - minVal)
		fill.Size = UDim2.new(percentage, 0, 1, 0)
		knob.Position = UDim2.new(percentage, -7, 0.5, -7)
		vLbl.Text = string.format("%.1f", val) .. (metric or "")
		callback(val)
	end

	knob.MouseButton1Down:Connect(function() isDragging = true end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then isDragging = false end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if isDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local deltaPercent = (i.Position.X - lane.AbsolutePosition.X) / lane.AbsoluteSize.X
			updateSlider(minVal + deltaPercent * (maxVal - minVal))
		end
	end)
end

local function createCycle(parent, title, subtitle, options, defaultIdx, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 56)
	card.BackgroundColor3 = BG_CARD
	card.BorderSizePixel = 0
	card.Parent = parent
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

	local tLbl = Instance.new("TextLabel")
	tLbl.Size = UDim2.new(1, -160, 0, 22)
	tLbl.Position = UDim2.new(0, 14, 0, 6)
	tLbl.BackgroundTransparency = 1
	tLbl.Text = title
	tLbl.TextColor3 = TEXT_PREMIUM
	tLbl.Font = Enum.Font.GothamBold
	tLbl.TextSize = 13
	tLbl.TextXAlignment = Enum.TextXAlignment.Left
	tLbl.Parent = card

	local sLbl = Instance.new("TextLabel")
	sLbl.Size = UDim2.new(1, -160, 0, 18)
	sLbl.Position = UDim2.new(0, 14, 0, 28)
	sLbl.BackgroundTransparency = 1
	sLbl.Text = subtitle or ""
	sLbl.TextColor3 = TEXT_MUTED
	sLbl.Font = Enum.Font.Gotham
	sLbl.TextSize = 11
	sLbl.TextXAlignment = Enum.TextXAlignment.Left
	sLbl.Parent = card

	local cycleBtn = Instance.new("TextButton")
	cycleBtn.Size = UDim2.new(0, 130, 0, 30)
	cycleBtn.Position = UDim2.new(1, -144, 0.5, -15)
	cycleBtn.BackgroundColor3 = BG_WIDGET
	cycleBtn.TextColor3 = ACCENT_GLOW
	cycleBtn.Font = Enum.Font.GothamBold
	cycleBtn.TextSize = 11
	cycleBtn.Text = string.upper(options[defaultIdx])
	cycleBtn.AutoButtonColor = false
	cycleBtn.BorderSizePixel = 0
	cycleBtn.Parent = card
	Instance.new("UICorner", cycleBtn).CornerRadius = UDim.new(0, 6)

	local currentIndex = defaultIdx
	cycleBtn.MouseButton1Click:Connect(function()
		currentIndex = currentIndex + 1
		if currentIndex > #options then currentIndex = 1 end
		cycleBtn.Text = string.upper(options[currentIndex])
		callback(currentIndex)
	end)
end

--=========================================================
-- POPULATE MODULES
--=========================================================
-- TARGET
createHeader(TargetScroll, "Environment Rules")
createToggle(TargetScroll, "Thin Wall Penetration", "Locks onto targets behind barriers", Aimbot_ThinWallCheck, function(v) Aimbot_ThinWallCheck = v end)
createCycle(TargetScroll, "Wall Check Type", "How deep aimbot sees into walls", {"Auto (Weapon)", "Heavy (3 Studs)", "Light (1.5 Studs)"}, Aimbot_PenetrationMode, function(idx)
	Aimbot_PenetrationMode = idx
end)

-- AIMBOT
createHeader(AimbotScroll, "Standard Systems")
createToggle(AimbotScroll, "Aimbot Active State", "Master automation state override", Aimbot_Enabled, function(v) Aimbot_Enabled = v; if not v then Aimbot_On = false end end)
createToggle(AimbotScroll, "360° Spherical Targeting", "Disables visual FOV fields to scan full perimeter", Aimbot_360Mode, function(v) Aimbot_360Mode = v end)
createToggle(AimbotScroll, "Draw Target Boundaries", "Renders FOV circle", Aimbot_ShowFOV, function(v) Aimbot_ShowFOV = v end)
createToggle(AimbotScroll, "Kinematic Prediction", "Projects trajectories dynamically", Aimbot_Prediction, function(v) Aimbot_Prediction = v end)
createToggle(AimbotScroll, "Geometric Wallcheck", "Requires absolute structural clearance", Aimbot_WallCheck, function(v) Aimbot_WallCheck = v end)

createSlider(AimbotScroll, "Aimbot Max Range", 50, 5000, Aimbot_MaxDistance, function(v) Aimbot_MaxDistance = v end, "st")
createSlider(AimbotScroll, "FOV Radius", 50, 800, Aimbot_FOVRadius, function(v) Aimbot_FOVRadius = v end, "px")
createSlider(AimbotScroll, "Aim Sensitivity", 0.05, 1.0, Aimbot_Sensitivity, function(v) Aimbot_Sensitivity = v end, "")

createHeader(AimbotScroll, "Rage Settings")
createToggle(AimbotScroll, "Aggressive Rage Lock", "Immediate sticky prioritization", RageMode_Enabled, function(v) RageMode_Enabled = v end)

-- ESP
createHeader(ESPScroll, "Spatial Rendering")
createToggle(ESPScroll, "Active ESP Diagnostics", "Generates high-frequency overlay frameworks", ESP_Enabled, function(v) ESP_Enabled = v end)
createToggle(ESPScroll, "Synchronize Team Colors", "Updates colors instantly when teams change", ESP_TeamColor, function(v) ESP_TeamColor = v end)
createSlider(ESPScroll, "ESP Max Range", 100, 5000, ESP_MaxDistance, function(v) ESP_MaxDistance = v end, "st")

-- SETTINGS
createHeader(SettingsScroll, "Performance")
createToggle(SettingsScroll, "Fluid Transition System", "Enables UI animations", animationsEnabled, function(v) animationsEnabled = v end)

--=========================================================
-- SCRIPT INTRO ANIMATION & INITIALIZATION
--=========================================================
selectTab("Target")
notify("Press INSERT to Toggle UI", SUCCESS_GREEN)

TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
	Size = UDim2.new(0, 760, 0, 460),
	Position = UDim2.new(0.5, -380, 0.5, -230)
}):Play()

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	
	if input.KeyCode == Settings.MenuKey then
		menuOpen = not menuOpen
		if menuOpen then
			TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 760, 0, 460), Position = UDim2.new(0.5, -380, 0.5, -230)}):Play()
		else
			TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
		end
	end

	if input.KeyCode == Settings.AimbotKey then
		if not Aimbot_Enabled then return end
		Aimbot_On = not Aimbot_On
		notify("Aimbot: " .. (Aimbot_On and "LOCKED" or "UNLOCKED"), Aimbot_On and SUCCESS_GREEN or ACCENT_GLOW)
	end
end)

--=========================================================
-- FOV CIRCLES
--=========================================================
local FOVCircleGui = Instance.new("Frame")
FOVCircleGui.Size = UDim2.new(0, Aimbot_FOVRadius * 2, 0, Aimbot_FOVRadius * 2)
FOVCircleGui.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircleGui.BackgroundTransparency = 1
FOVCircleGui.ZIndex = 1
FOVCircleGui.Parent = ScreenGui

local fovCircle = Instance.new("ImageLabel")
fovCircle.Size = UDim2.new(1, 0, 1, 0)
fovCircle.BackgroundTransparency = 1
fovCircle.Image = "rbxassetid://12201347372"
fovCircle.ImageColor3 = ACCENT_GLOW
fovCircle.ImageTransparency = 0.4
fovCircle.ScaleType = Enum.ScaleType.Fit
fovCircle.Parent = FOVCircleGui

local RageCircleGui = Instance.new("Frame")
RageCircleGui.Size = UDim2.new(0, Rage_FOVRadius * 2, 0, Rage_FOVRadius * 2)
RageCircleGui.AnchorPoint = Vector2.new(0.5, 0.5)
RageCircleGui.BackgroundTransparency = 1
RageCircleGui.ZIndex = 1
RageCircleGui.Parent = ScreenGui

local rageCircle = Instance.new("ImageLabel")
rageCircle.Size = UDim2.new(1, 0, 1, 0)
rageCircle.BackgroundTransparency = 1
rageCircle.Image = "rbxassetid://12201347372"
rageCircle.ImageColor3 = Color3.fromRGB(255, 150, 0)
rageCircle.ImageTransparency = 0.7
rageCircle.ScaleType = Enum.ScaleType.Fit
rageCircle.Parent = RageCircleGui

--=========================================================
-- BULLETPROOF ESP ENGINE (FIXED FOR NEW PLAYERS)
--=========================================================
local ESP_Storage = workspace:FindFirstChild("VRO_ESP_Storage") or Instance.new("Folder", workspace)
ESP_Storage.Name = "VRO_ESP_Storage"

local function cleanPlayerESP(plr)
	local tag = ESP_Storage:FindFirstChild(plr.Name .. "_Highlight")
	if tag then tag:Destroy() end
	if plr.Character then
		local head = plr.Character:FindFirstChild("Head")
		if head and head:FindFirstChild("ESP_Billboard") then
			head.ESP_Billboard:Destroy()
		end
	end
end

local function sameTeam(a, b)
	if not a or not b then return false end
	return a.Team == b.Team and a.Team ~= nil
end

local function refreshSingleESP(plr)
	if not ESP_Enabled or plr == player then 
		cleanPlayerESP(plr)
		return 
	end

	local char = plr.Character
	if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") then
		local myChar = player.Character
		local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
		local theirRoot = char.HumanoidRootPart
		
		local dist = myRoot and (theirRoot.Position - myRoot.Position).Magnitude or 0
		if dist <= ESP_MaxDistance then
			local color = (ESP_TeamColor and plr.Team) and plr.TeamColor.Color or ACCENT_GLOW
			if not ESP_TeamColor and sameTeam(player, plr) then color = Color3.fromRGB(0, 160, 255) end

			local highlight = ESP_Storage:FindFirstChild(plr.Name .. "_Highlight")
			if not highlight then
				highlight = Instance.new("Highlight")
				highlight.Name = plr.Name .. "_Highlight"
				highlight.Parent = ESP_Storage
			end
			highlight.Adornee = char
			highlight.FillColor = color
			highlight.FillTransparency = ESP_FillTransparency
			highlight.OutlineColor = Color3.fromRGB(255, 255, 255)

			local head = char.Head
			local billboard = head:FindFirstChild("ESP_Billboard")
			if not billboard then
				billboard = Instance.new("BillboardGui")
				billboard.Name = "ESP_Billboard"
				billboard.Size = UDim2.new(0, 160, 0, 26)
				billboard.StudsOffset = Vector3.new(0, 3, 0)
				billboard.AlwaysOnTop = true
				
				local lbl = Instance.new("TextLabel")
				lbl.Name = "Label"
				lbl.Size = UDim2.new(1, 0, 1, 0)
				lbl.BackgroundTransparency = 1
				lbl.Font = Enum.Font.GothamBold
				lbl.TextSize = 11
				lbl.TextStrokeTransparency = 0
				lbl.Parent = billboard
				billboard.Parent = head
			end
			billboard.Label.Text = string.format("%s [%d]", plr.Name, math.floor(dist))
			billboard.Label.TextColor3 = color
		else
			cleanPlayerESP(plr)
		end
	else
		cleanPlayerESP(plr)
	end
end

local function updateAllESP()
	if not ESP_Enabled then ESP_Storage:ClearAllChildren(); return end
	for _, plr in ipairs(Players:GetPlayers()) do
		refreshSingleESP(plr)
	end
end

-- Bulletproof Hook for New Players & Respawns
Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function() task.wait(0.5); refreshSingleESP(plr) end)
end)
for _, plr in ipairs(Players:GetPlayers()) do
	plr.CharacterAdded:Connect(function() task.wait(0.5); refreshSingleESP(plr) end)
end
Players.PlayerRemoving:Connect(cleanPlayerESP)

task.spawn(function()
	while task.wait(0.1) do pcall(updateAllESP) end
end)

--=========================================================
-- DYNAMIC THIN WALL & TARGETING ENGINE
--=========================================================
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

local function getPenetrationDepth()
	if Aimbot_PenetrationMode == 2 then return 3.0 end -- Heavy
	if Aimbot_PenetrationMode == 3 then return 1.5 end -- Light
	
	-- Auto (Weapon Based)
	local char = player.Character
	local tool = char and char:FindFirstChildOfClass("Tool")
	if tool then
		local name = string.lower(tool.Name)
		if string.find(name, "sniper") or string.find(name, "awp") or string.find(name, "scout") or string.find(name, "barret") or string.find(name, "intervention") then
			return 3.0
		end
	end
	return 1.5 
end

local function checkVisionLine(origin, targetPos, targetChar)
	rayParams.FilterDescendantsInstances = {player.Character, targetChar, ESP_Storage}
	local result = workspace:Raycast(origin, targetPos - origin, rayParams)

	if not result then return true end
	if (result.Position - targetPos).Magnitude <= 0.6 then return true end

	if Aimbot_ThinWallCheck then
		local backRayDir = result.Position - targetPos
		local backResult = workspace:Raycast(targetPos, backRayDir, rayParams)
		if backResult then
			local thickness = (result.Position - backResult.Position).Magnitude
			if thickness <= getPenetrationDepth() then 
				return true
			end
		end
	end
	return false
end

local function isPlayerValid(plr)
	if not plr or plr == player then return false end
	if Aimbot_TeamCheck and sameTeam(player, plr) then return false end
	local char = plr.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	return hum and hum.Health > 0 and char:FindFirstChild("Head") and char:FindFirstChild("HumanoidRootPart")
end

local function getTarget()
	local myChar = player.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return nil end

	local mousePos = UserInputService:GetMouseLocation()
	local closestDistance = Aimbot_360Mode and math.huge or (RageMode_Enabled and Rage_FOVRadius or Aimbot_FOVRadius)
	local selectedPos = nil

	for _, p in ipairs(Players:GetPlayers()) do
		if isPlayerValid(p) then
			local head = p.Character.Head
			local root = p.Character.HumanoidRootPart
			local distToTarget = (myRoot.Position - root.Position).Magnitude
			
			-- Max Range Guard
			if distToTarget <= Aimbot_MaxDistance then
				local targetHeadPos = head.Position
				if Aimbot_Prediction then
					local vel = root.AssemblyLinearVelocity or Vector3.zero
					local scale = Settings.BasePredictionStrength + distToTarget * Settings.DistanceScaleFactor
					targetHeadPos = targetHeadPos + (vel * (distToTarget / 300) * math.clamp(scale, 0, 2))
				end

				if not Aimbot_WallCheck or checkVisionLine(myRoot.Position, targetHeadPos, p.Character) then
					if Aimbot_360Mode then
						if distToTarget < closestDistance then
							closestDistance = distToTarget
							selectedPos = targetHeadPos
						end
					else
						local screenPos, onScreen = camera:WorldToViewportPoint(targetHeadPos)
						if onScreen and screenPos.Z > 0 then
							local cursorDist = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
							if cursorDist < closestDistance then
								closestDistance = cursorDist
								selectedPos = targetHeadPos
							end
						end
					end
				end
			end
		end
	end
	return selectedPos
end

--=========================================================
-- RENDER & CAMERA ENGINE
--=========================================================
RunService.RenderStepped:Connect(function()
	local mousePos = UserInputService:GetMouseLocation()
	
	FOVCircleGui.Position = UDim2.fromOffset(mousePos.X, mousePos.Y)
	RageCircleGui.Position = UDim2.fromOffset(mousePos.X, mousePos.Y)
	FOVCircleGui.Size = UDim2.fromOffset(Aimbot_FOVRadius * 2, Aimbot_FOVRadius * 2)
	RageCircleGui.Size = UDim2.fromOffset(Rage_FOVRadius * 2, Rage_FOVRadius * 2)

	if Aimbot_360Mode then
		FOVCircleGui.Visible = false
		RageCircleGui.Visible = false
	else
		FOVCircleGui.Visible = Aimbot_ShowFOV
		RageCircleGui.Visible = RageMode_Enabled
	end

	if Aimbot_On and Aimbot_Enabled then
		local target = getTarget()
		if target then
			camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, target), RageMode_Enabled and Rage_Sensitivity or Aimbot_Sensitivity)
		end
	end
end)
