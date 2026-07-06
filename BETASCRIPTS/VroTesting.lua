--=========================================================
-- VRO AIM SUITE (PREMIUM EDITION)
--=========================================================

--// SERVICES
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera")
local mouse  = player:GetMouse()

--=========================================================
-- PREMIUM CYBER THEME
--=========================================================
local ACCENT_GLOW       = Color3.fromRGB(255, 64, 87)
local ACCENT_DARK       = Color3.fromRGB(180, 20, 45)
local BG_MAIN           = Color3.fromRGB(10, 10, 13)
local BG_CARD           = Color3.fromRGB(16, 16, 22)
local BG_PANEL          = Color3.fromRGB(22, 22, 28)
local BG_WIDGET         = Color3.fromRGB(28, 28, 38)
local BG_WIDGET_ACTIVE  = Color3.fromRGB(44, 24, 34)

local TEXT_PREMIUM      = Color3.fromRGB(250, 250, 255)
local TEXT_MUTED        = Color3.fromRGB(160, 160, 180)
local TEXT_DARK         = Color3.fromRGB(100, 100, 115)

local animationsEnabled = true

--=========================================================
-- STATE MANAGEMENT
--=========================================================
local selectedPlayer   = nil
local targetMode       = "All"

local ESP_Enabled           = true
local ESP_TeamColor         = true
local ESP_FillTransparency  = 0.5
local ESP_MaxDistance       = 2000

local CurrentTarget = nil
local LostTargetTime = 0
local TargetStickTime = 0.2

local Aimbot_Enabled            = true
local Aimbot_WallCheck          = true
local Aimbot_ThinWallCheck      = false
local Aimbot_TeamCheck          = true
local Aimbot_Prediction         = true
local Aimbot_Sensitivity        = 0.18
local Aimbot_FOVRadius          = 250
local Aimbot_ShowFOV            = true
local Aimbot_On                 = false
local Aimbot_360Mode            = false
local Aimbot_EnemyVisibleSound  = false
local Aimbot_HitSound           = true

local RageMode_Enabled          = false
local Rage_FOVRadius            = 550
local Rage_Sensitivity          = 0.5

local SilentAim_Enabled         = false
local MobileAimButton           = nil

local HitConnection = nil
local LastHitTarget = nil

local SOUND_ENEMY_VISIBLE = "rbxassetid://150975887"
local SOUND_HIT = "rbxassetid://134763632925481"
local visibleEnemies = {}

local Settings = {
	AimbotKey = Enum.KeyCode.E,
	BasePredictionStrength = 0.12,
	DistanceScaleFactor = 0.001,
}

--=========================================================
-- ROOT GUI
--=========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VroAimSuite_Premium"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local uiScale = Instance.new("UIScale")
uiScale.Parent = ScreenGui

local function updateScale()
	if not camera then return end
	local size = camera.ViewportSize
	uiScale.Scale = math.clamp(math.min(size.X, size.Y) / 1080, 0.75, 1.15)
end
updateScale()
RunService.RenderStepped:Connect(updateScale)

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
MainFrame.Size = UDim2.new(0, 760, 0, 460)
MainFrame.Position = UDim2.new(0.5, -380, 0.5, -230)
MainFrame.BackgroundColor3 = BG_MAIN
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 5
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
local frameStroke = Instance.new("UIStroke", MainFrame)
frameStroke.Color = ACCENT_GLOW
frameStroke.Thickness = 2

-- Titlebar
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

local VersionText = Instance.new("TextLabel")
VersionText.Size = UDim2.new(0, 100, 1, 0)
VersionText.Position = UDim2.new(0, 175, 0, 2)
VersionText.BackgroundTransparency = 1
VersionText.TextXAlignment = Enum.TextXAlignment.Left
VersionText.Text = "v3.0 Premium"
VersionText.TextColor3 = ACCENT_GLOW
VersionText.Font = Enum.Font.GothamBold
VersionText.TextSize = 11
VersionText.ZIndex = 6
VersionText.Parent = TitleBar

-- Window Controls
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
MinimizeBtn.TextSize = 18
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.ZIndex = 7
MinimizeBtn.Parent = TitleBar
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 8)

-- Interaction Tweens for Controls
local function hookHover(btn, activeBg, normBg)
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = activeBg, TextColor3 = TEXT_PREMIUM}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = normBg, TextColor3 = TEXT_MUTED}):Play()
	end)
end
hookHover(CloseBtn, Color3.fromRGB(240, 50, 70), BG_WIDGET)
hookHover(MinimizeBtn, ACCENT_DARK, BG_WIDGET)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local isMinimized = false
local defaultSize = MainFrame.Size
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

-- Dragging Logic
do
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
end

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
local sideStroke = Instance.new("UIStroke", Sidebar)
sideStroke.Color = Color3.fromRGB(30, 30, 40)

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
MainArea.ZIndex = 5
MainArea.Parent = Container
Instance.new("UICorner", MainArea).CornerRadius = UDim.new(0, 12)
local mainAreaStroke = Instance.new("UIStroke", MainArea)
mainAreaStroke.Color = Color3.fromRGB(30, 30, 40)

local function createPanel()
	local scroll = Instance.new("ScrollingFrame")
	scroll.BackgroundTransparency = 1
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = ACCENT_GLOW
	scroll.BorderSizePixel = 0
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
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

local TargetScroll   = createPanel()
local AimbotScroll   = createPanel()
local ESPScroll      = createPanel()
local SettingsScroll = createPanel()

local function setTab(activeName)
	TargetScroll.Visible   = (activeName == "Target")
	AimbotScroll.Visible   = (activeName == "Aimbot")
	ESPScroll.Visible      = (activeName == "ESP")
	SettingsScroll.Visible = (activeName == "Settings")
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

	btn.MouseEnter:Connect(function()
		if btn.BackgroundColor3 ~= BG_WIDGET_ACTIVE then
			TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(36, 36, 48), TextColor3 = TEXT_PREMIUM}):Play()
		end
	end)
	btn.MouseLeave:Connect(function()
		if btn.BackgroundColor3 ~= BG_WIDGET_ACTIVE then
			TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = BG_WIDGET, TextColor3 = TEXT_MUTED}):Play()
		end
	end)

	return btn, indicator
end

local tBtn, tInd = createTabBtn("Target Customization", 1, "Target")
local aBtn, aInd = createTabBtn("Aimbot & Rage", 2, "Aimbot")
local eBtn, eInd = createTabBtn("Visuals / ESP", 3, "ESP")
local sBtn, sInd = createTabBtn("Global Settings", 4, "Settings")

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
selectTab("Target")

--=========================================================
-- UI FACTORY COMPONENT WRAPPERS
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
	local stroke = Instance.new("UIStroke", card)
	stroke.Thickness = 1
	stroke.Color = Color3.fromRGB(40, 40, 52)

	local tLbl = Instance.new("TextLabel")
	tLbl.Size = UDim2.new(1, -120, 0, 22)
	tLbl.Position = UDim2.new(0, 14, 0, 6)
	tLbl.BackgroundTransparency = 1
	tLbl.Text = title
	tLbl.TextColor3 = TEXT_PREMIUM
	tLbl.Font = Enum.Font.GothamWithHinting
	tLbl.TextSize = 14
	tLbl.TextXAlignment = Enum.TextXAlignment.Left
	tLbl.ZIndex = 6
	tLbl.Parent = card

	local sLbl = Instance.new("TextLabel")
	sLbl.Size = UDim2.new(1, -120, 0, 18)
	sLbl.Position = UDim2.new(0, 14, 0, 28)
	sLbl.BackgroundTransparency = 1
	sLbl.Text = subtitle or ""
	sLbl.TextColor3 = TEXT_MUTED
	sLbl.Font = Enum.Font.Gotham
	sLbl.TextSize = 11
	sLbl.TextXAlignment = Enum.TextXAlignment.Left
	sLbl.ZIndex = 6
	sLbl.Parent = card

	local switch = Instance.new("TextButton")
	switch.Size = UDim2.new(0, 46, 0, 24)
	switch.Position = UDim2.new(1, -60, 0.5, -12)
	switch.BackgroundColor3 = BG_WIDGET
	switch.Text = ""
	switch.AutoButtonColor = false
	switch.ZIndex = 6
	switch.Parent = card
	Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)
	local sStroke = Instance.new("UIStroke", switch)
	sStroke.Color = Color3.fromRGB(60, 60, 75)

	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 18, 0, 18)
	dot.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
	dot.BackgroundColor3 = default and ACCENT_GLOW or TEXT_MUTED
	dot.BorderSizePixel = 0
	dot.ZIndex = 7
	dot.Parent = switch
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

	local state = default
	callback(state)

	local function updateView(instant)
		local p = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
		local c = state and ACCENT_GLOW or TEXT_MUTED
		local bg = state and Color3.fromRGB(38, 22, 32) or BG_CARD
		local bc = state and ACCENT_GLOW or Color3.fromRGB(40, 40, 52)

		if animationsEnabled and not instant then
			TweenService:Create(dot, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Position = p, BackgroundColor3 = c}):Play()
			TweenService:Create(card, TweenInfo.new(0.2), {BackgroundColor3 = bg}):Play()
			TweenService:Create(stroke, TweenInfo.new(0.2), {Color = bc}):Play()
		else
			dot.Position = p
			dot.BackgroundColor3 = c
			card.BackgroundColor3 = bg
			stroke.Color = bc
		end
	end
	updateView(true)

	switch.MouseButton1Click:Connect(function()
		state = not state
		callback(state)
		updateView(false)
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
	local stroke = Instance.new("UIStroke", card)
	stroke.Color = Color3.fromRGB(40, 40, 52)

	local tLbl = Instance.new("TextLabel")
	tLbl.Size = UDim2.new(1, -100, 0, 22)
	tLbl.Position = UDim2.new(0, 14, 0, 8)
	tLbl.BackgroundTransparency = 1
	tLbl.Text = title
	tLbl.TextColor3 = TEXT_PREMIUM
	tLbl.Font = Enum.Font.GothamWithHinting
	tLbl.TextSize = 14
	tLbl.TextXAlignment = Enum.TextXAlignment.Left
	tLbl.ZIndex = 6
	tLbl.Parent = card

	local vLbl = Instance.new("TextLabel")
	vLbl.Size = UDim2.new(0, 80, 0, 22)
	vLbl.Position = UDim2.new(1, -94, 0, 8)
	vLbl.BackgroundTransparency = 1
	vLbl.Text = tostring(default) .. (metric or "")
	vLbl.TextColor3 = ACCENT_GLOW
	vLbl.Font = Enum.Font.GothamBold
	vLbl.TextSize = 14
	vLbl.TextXAlignment = Enum.TextXAlignment.Right
	vLbl.ZIndex = 6
	vLbl.Parent = card

	local lane = Instance.new("Frame")
	lane.Size = UDim2.new(1, -28, 0, 6)
	lane.Position = UDim2.new(0, 14, 0, 48)
	lane.BackgroundColor3 = BG_WIDGET
	lane.BorderSizePixel = 0
	lane.ZIndex = 6
	lane.Parent = card
	Instance.new("UICorner", lane).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - minVal) / (maxVal - minVal), 0, 1, 0)
	fill.BackgroundColor3 = ACCENT_GLOW
	fill.BorderSizePixel = 0
	fill.ZIndex = 6
	fill.Parent = lane
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = UDim2.new((default - minVal) / (maxVal - minVal), -7, 0.5, -7)
	knob.BackgroundColor3 = TEXT_PREMIUM
	knob.Text = ""
	knob.AutoButtonColor = false
	knob.BorderSizePixel = 0
	knob.ZIndex = 7
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

--=========================================================
-- POPULATE TARGET CUSTOMIZATION MODULE
--=========================================================
createHeader(TargetScroll, "Core Filtering Modes")

do
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 84)
	card.BackgroundColor3 = BG_CARD
	card.BorderSizePixel = 0
	card.ZIndex = 6
	card.Parent = TargetScroll
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
	local s = Instance.new("UIStroke", card)
	s.Color = Color3.fromRGB(40, 40, 52)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 24)
	title.Position = UDim2.new(0, 14, 0, 8)
	title.BackgroundTransparency = 1
	title.Text = "Target Selection Matrix"
	title.TextColor3 = TEXT_PREMIUM
	title.Font = Enum.Font.GothamSemibold
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = card

	local function makeModeBtn(txt, pos, modeVal)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0, 85, 0, 28)
		b.Position = pos
		b.Font = Enum.Font.GothamBold
		b.TextSize = 11
		b.Text = txt
		b.BorderSizePixel = 0
		b.AutoButtonColor = false
		b.ZIndex = 7
		b.Parent = card
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
		return b
	end

	local bAll = makeModeBtn("ALL PLAYERS", UDim2.new(0, 14, 0, 42), "All")
	local bEn  = makeModeBtn("ONLY ENEMIES", UDim2.new(0, 106, 0, 42), "Enemies")
	local bPer = makeModeBtn("LOCKED PER", UDim2.new(0, 198, 0, 42), "PerPlayer")

	local function refreshButtons()
		bAll.BackgroundColor3 = (targetMode == "All") and ACCENT_DARK or BG_WIDGET
		bAll.TextColor3       = (targetMode == "All") and TEXT_PREMIUM or TEXT_MUTED
		bEn.BackgroundColor3  = (targetMode == "Enemies") and ACCENT_DARK or BG_WIDGET
		bEn.TextColor3        = (targetMode == "Enemies") and TEXT_PREMIUM or TEXT_MUTED
		bPer.BackgroundColor3 = (targetMode == "PerPlayer") and ACCENT_DARK or BG_WIDGET
		bPer.TextColor3       = (targetMode == "PerPlayer") and TEXT_PREMIUM or TEXT_MUTED
	end
	refreshButtons()

	bAll.MouseButton1Click:Connect(function() targetMode = "All"; selectedPlayer = nil; refreshButtons() end)
	bEn.MouseButton1Click:Connect(function() targetMode = "Enemies"; selectedPlayer = nil; refreshButtons() end)
	bPer.MouseButton1Click:Connect(function() targetMode = "PerPlayer"; refreshButtons() end)
end

createHeader(TargetScroll, "Environment Rules")
-- MOVED HERE: Thin wall penetration is now perfectly visible right on the main target tab
createToggle(TargetScroll, "Thin Wall Penetration", "Aimbot locks onto targets behind thin walls (<3 studs)", Aimbot_ThinWallCheck, function(v)
	Aimbot_ThinWallCheck = v
end)

--=========================================================
-- POPULATE AIMBOT & RAGE MODULE
--=========================================================
createHeader(AimbotScroll, "Standard Systems")
createToggle(AimbotScroll, "Aimbot Active State", "Master automation state override", Aimbot_Enabled, function(v)
	Aimbot_Enabled = v; if not v then Aimbot_On = false end
end)
createToggle(AimbotScroll, "360° Spherical Targeting", "Disables visual FOV fields to scan full perimeter", Aimbot_360Mode, function(v)
	Aimbot_360Mode = v
end)
createToggle(AimbotScroll, "Draw Target Boundaries (FOV)", "Renders perimeter vector circle on screen", Aimbot_ShowFOV, function(v)
	Aimbot_ShowFOV = v
end)
createToggle(AimbotScroll, "Kinematic Motion Prediction", "Projects trajectories dynamically based on latency/velocity", Aimbot_Prediction, function(v)
	Aimbot_Prediction = v
end)
createToggle(AimbotScroll, "Geometric Raycast Wallcheck", "Requires absolute structural clearance", Aimbot_WallCheck, function(v)
	Aimbot_WallCheck = v
end)

createSlider(AimbotScroll, "Field of View Radius", 80, 700, Aimbot_FOVRadius, function(v)
	Aimbot_FOVRadius = v
end, "px")
createSlider(AimbotScroll, "Linear Interpolation Axis", 0.05, 1.0, Aimbot_Sensitivity, function(v)
	Aimbot_Sensitivity = v
end, "")

createHeader(AimbotScroll, "Rage Override Array")
createToggle(AimbotScroll, "Aggressive Rage Lock-On", "Enables immediate sticky prioritization frames", RageMode_Enabled, function(v)
	RageMode_Enabled = v
end)
createSlider(AimbotScroll, "Rage Search FOV", 100, 1000, Rage_FOVRadius, function(v)
	Rage_FOVRadius = v
end, "px")
createSlider(AimbotScroll, "Rage Smoothing Coeff.", 0.1, 1.0, Rage_Sensitivity, function(v)
	Rage_Sensitivity = v
end, "")

createHeader(AimbotScroll, "Audio Systems")
createToggle(AimbotScroll, "Audible Detection Alerts", "Plays sound signature when target breaks cover", Aimbot_EnemyVisibleSound, function(v)
	Aimbot_EnemyVisibleSound = v
end)
createToggle(AimbotScroll, "Target Damage Confirmation", "Plays feedback sound upon verified structural delta", Aimbot_HitSound, function(v)
	Aimbot_HitSound = v
end)

--=========================================================
-- POPULATE VISUALS / ESP MODULE
--=========================================================
createHeader(ESPScroll, "Spatial Rendering Matrix")
createToggle(ESPScroll, "Active ESP Diagnostics", "Generates high-frequency overlay geometry frameworks", ESP_Enabled, function(v)
	ESP_Enabled = v; if not v then pcall(clearAllESP) end
end)
createToggle(ESPScroll, "Synchronize Team Colors", "Dynamically updates colors instantly when teams change", ESP_TeamColor, function(v)
	ESP_TeamColor = v
end)
createSlider(ESPScroll, "Chroma Fill Transparency", 0.0, 1.0, ESP_FillTransparency, function(v)
	ESP_FillTransparency = v
end, "")
createSlider(ESPScroll, "Maximum Culling Distance", 100, 4000, ESP_MaxDistance, function(v)
	ESP_MaxDistance = v
end, " studs")

--=========================================================
-- POPULATE GLOBAL SETTINGS MODULE
--=========================================================
createHeader(SettingsScroll, "Performance & Core Features")
createToggle(SettingsScroll, "Fluid Transition System", "Enables hardware-interpolated UI tweens", animationsEnabled, function(v)
	animationsEnabled = v
end)

--=========================================================
-- FOV CANVAS OVERLAYS
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
-- RE-ENGINEERED HIGH-PERFORMANCE ESP ENGINE
--=========================================================
local ESP_Storage = workspace:FindFirstChild("VRO_ESP_Storage")
if not ESP_Storage then
	ESP_Storage = Instance.new("Folder")
	ESP_Storage.Name = "VRO_ESP_Storage"
	ESP_Storage.Parent = workspace
end

local function cleanPlayerESP(plr)
	local oldHighlight = ESP_Storage:FindFirstChild(plr.Name .. "_Highlight")
	if oldHighlight then oldHighlight:Destroy() end
	if plr.Character then
		local head = plr.Character:FindFirstChild("Head")
		local bbg = head and head:FindFirstChild("ESP_Billboard")
		if bbg then bbg:Destroy() end
	end
end

local function sameTeam(a, b)
	if not a or not b then return false end
	return a.Team == b.Team and a.Team ~= nil
end

local function updateESP()
	if not ESP_Enabled then
		ESP_Storage:ClearAllChildren()
		return
	end

	local myChar = player.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == player then continue end

		local char = plr.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local head = char and char:FindFirstChild("Head")

		if char and hum and root and head and hum.Health > 0 then
			local distance = myRoot and (root.Position - myRoot.Position).Magnitude or 0

			if distance <= ESP_MaxDistance then
				-- INSTANT COLOR RESOLUTION MATRIX
				local finalColor = ACCENT_GLOW
				if ESP_TeamColor and plr.Team then
					finalColor = plr.TeamColor.Color
				elseif sameTeam(player, plr) then
					finalColor = Color3.fromRGB(0, 160, 255)
				end

				-- Highlight Management
				local highlight = ESP_Storage:FindFirstChild(plr.Name .. "_Highlight")
				if not highlight then
					highlight = Instance.new("Highlight")
					highlight.Name = plr.Name .. "_Highlight"
					highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
					highlight.OutlineTransparency = 0.2
					highlight.Parent = ESP_Storage
				end
				highlight.Adornee = char
				highlight.Enabled = true
				highlight.FillColor = finalColor
				highlight.FillTransparency = ESP_FillTransparency

				-- Billboard Text Elements
				local billboard = head:FindFirstChild("ESP_Billboard")
				if not billboard then
					billboard = Instance.new("BillboardGui")
					billboard.Name = "ESP_Billboard"
					billboard.Size = UDim2.new(0, 160, 0, 26)
					billboard.StudsOffset = Vector3.new(0, 3, 0)
					billboard.AlwaysOnTop = true
					billboard.ResetOnSpawn = false

					local lbl = Instance.new("TextLabel")
					lbl.Name = "Label"
					lbl.Size = UDim2.new(1, 0, 1, 0)
					lbl.BackgroundTransparency = 1
					lbl.Font = Enum.Font.GothamBold
					lbl.TextSize = 11
					lbl.TextStrokeTransparency = 0
					lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
					lbl.Parent = billboard
					billboard.Parent = head
				end
				billboard.Enabled = true
				local infoLabel = billboard:FindFirstChild("Label")
				if infoLabel then
					infoLabel.Text = string.format("%s [%d]", plr.Name, math.floor(distance))
					infoLabel.TextColor3 = finalColor
				end
			else
				cleanPlayerESP(plr)
			end
		else
			cleanPlayerESP(plr)
		end
	end
end

function clearAllESP()
	ESP_Storage:ClearAllChildren()
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Character then
			local head = p.Character:FindFirstChild("Head")
			local b = head and head:FindFirstChild("ESP_Billboard")
			if b then b:Destroy() end
		end
	end
end

-- CRITICAL FIX: Direct property listeners trigger an absolute wipe & reset on team change!
local function trackPlayerTeam(plr)
	local function forceReset()
		cleanPlayerESP(plr)
		task.wait()
		updateESP()
	end
	plr:GetPropertyChangedSignal("Team"):Connect(forceReset)
	plr:GetPropertyChangedSignal("TeamColor"):Connect(forceReset)
end

for _, p in ipairs(Players:GetPlayers()) do trackPlayerTeam(p) end
Players.PlayerAdded:Connect(trackPlayerTeam)
Players.PlayerRemoving:Connect(cleanPlayerESP)

task.spawn(function()
	while true do
		pcall(updateESP)
		task.wait(0.05)
	end
end)

--=========================================================
-- SIGHTLINE RAYCAST CORE ENGINE
--=========================================================
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

local function checkVisionLine(origin, targetPos, targetChar)
	rayParams.FilterDescendantsInstances = {player.Character, targetChar, ESP_Storage}
	local result = workspace:Raycast(origin, targetPos - origin, rayParams)

	if not result then return true end
	if (result.Position - targetPos).Magnitude <= 0.6 then return true end

	-- High-Fidelity Thin Wall Calculation Array
	if Aimbot_ThinWallCheck then
		local backRayDir = result.Position - targetPos
		local backResult = workspace:Raycast(targetPos, backRayDir, rayParams)
		if backResult then
			local thickness = (result.Position - backResult.Position).Magnitude
			if thickness <= 3.0 then -- Penetrates up to 3 structural studs cleanly
				return true
			end
		end
	end

	return false
end

local function calculatePrediction(head, root)
	if not Aimbot_Prediction then return head.Position end
	local vel = root.AssemblyLinearVelocity or Vector3.zero
	local distance = (head.Position - camera.CFrame.Position).Magnitude
	local scale = Settings.BasePredictionStrength + distance * Settings.DistanceScaleFactor
	return head.Position + (vel * (distance / 300) * math.clamp(scale, 0, 2))
end

local function isPlayerValid(plr)
	if not plr or plr == player then return false end
	if Aimbot_TeamCheck and sameTeam(player, plr) then return false end
	local char = plr.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	return hum and hum.Health > 0 and char:FindFirstChild("Head") and char:FindFirstChild("HumanoidRootPart")
end

local function getClosestScreenTarget()
	local myChar = player.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return nil end

	local mousePos = UserInputService:GetMouseLocation()
	local maxFOV = RageMode_Enabled and Rage_FOVRadius or Aimbot_FOVRadius
	local closestDistance = maxFOV
	local selectedPos, selectedPlr = nil, nil

	local function process(plr)
		if not isPlayerValid(plr) then return end
		local char = plr.Character
		local predictedHead = calculatePrediction(char.Head, char.HumanoidRootPart)

		if Aimbot_WallCheck and not checkVisionLine(myRoot.Position, predictedHead, char) then return end

		local screenPos, visibleOnScreen = camera:WorldToViewportPoint(predictedHead)
		if not visibleOnScreen or screenPos.Z <= 0 then return end

		local dist = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
		if dist < closestDistance then
			closestDistance = dist
			selectedPos = predictedHead
			selectedPlr = plr
		end
	end

	if targetMode == "PerPlayer" and selectedPlayer then
		process(selectedPlayer)
	else
		for _, p in ipairs(Players:GetPlayers()) do process(p) end
	end

	return selectedPos
end

local function getClosest360Target()
	local myChar = player.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return nil end

	local shortestMag = math.huge
	local selectedPos = nil

	local function process(plr)
		if not isPlayerValid(plr) then return end
		local char = plr.Character
		local predictedHead = calculatePrediction(char.Head, char.HumanoidRootPart)

		if Aimbot_WallCheck and not checkVisionLine(myRoot.Position, predictedHead, char) then return end

		local mag = (predictedHead - camera.CFrame.Position).Magnitude
		if mag < shortestMag then
			shortestMag = mag
			selectedPos = predictedHead
		end
	end

	if targetMode == "PerPlayer" and selectedPlayer then
		process(selectedPlayer)
	else
		for _, p in ipairs(Players:GetPlayers()) do process(p) end
	end

	return selectedPos
end

--=========================================================
-- CYCLIC LOOPS AND INPUT TRANSLATIONS
--=========================================================
local function playSound(id)
	local s = Instance.new("Sound", workspace)
	s.SoundId = id
	s.Volume = 0.5
	game:GetService("Debris"):AddItem(s, 2)
	s:Play()
end

RunService.RenderStepped:Connect(function()
	local mousePos = UserInputService:GetMouseLocation()
	local s = uiScale.Scale

	FOVCircleGui.Position = UDim2.fromOffset(mousePos.X / s, mousePos.Y / s)
	RageCircleGui.Position = UDim2.fromOffset(mousePos.X / s, mousePos.Y / s)

	FOVCircleGui.Size = UDim2.fromOffset((Aimbot_FOVRadius * 2) / s, (Aimbot_FOVRadius * 2) / s)
	RageCircleGui.Size = UDim2.fromOffset((Rage_FOVRadius * 2) / s, (Rage_FOVRadius * 2) / s)

	-- CRITICAL VISIBILITY LOGIC TRIPPING SWITCH
	if Aimbot_360Mode then
		FOVCircleGui.Visible = false
		RageCircleGui.Visible = false
	else
		FOVCircleGui.Visible = Aimbot_ShowFOV
		RageCircleGui.Visible = RageMode_Enabled
	end

	-- Sound confirmation checks
	if Aimbot_EnemyVisibleSound and myRoot then
		local currentVis = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= player and isPlayerValid(p) then
				if checkVisionLine(player.Character.HumanoidRootPart.Position, p.Character.Head.Position, p.Character) then
					currentVis[p.UserId] = true
					if not visibleEnemies[p.UserId] then playSound(SOUND_ENEMY_VISIBLE) end
				end
			end
		end
		visibleEnemies = currentVis
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Settings.AimbotKey then
		if not Aimbot_Enabled then return end
		Aimbot_On = not Aimbot_On
		notify("Aimbot Status: " .. (Aimbot_On and "ACTIVATED" or "DEACTIVATED"), Aimbot_On and SUCCESS_GREEN or ACCENT_GLOW)
	end
end)

RunService.RenderStepped:Connect(function()
	if not Aimbot_On or not Aimbot_Enabled then return end

	local target = Aimbot_360Mode and getClosest360Target() or getClosestScreenTarget()
	if target then
		local currentCF = camera.CFrame
		local lookTarget = CFrame.new(currentCF.Position, target)
		camera.CFrame = currentCF:Lerp(lookTarget, RageMode_Enabled and Rage_Sensitivity or Aimbot_Sensitivity)
	end
end)

notify("VRO Suite Premium Engine Initialized", ACCENT_GLOW)
