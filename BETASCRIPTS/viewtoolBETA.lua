--=========================================================
-- VRO AIM SUITE
--=========================================================

--// SERVICES
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")
local GuiService        = game:GetService("GuiService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse  = player:GetMouse() -- for exact cursor positioning [web:150][web:158]

--=========================================================
-- THEME
--=========================================================
local ACCENT_RED        = Color3.fromRGB(220, 35, 60)
local ACCENT_RED_SOFT   = Color3.fromRGB(200, 40, 80)
local ACCENT_RED_DEEP   = Color3.fromRGB(170, 0, 40)
local DARKEST           = Color3.fromRGB(10, 10, 14)
local DARK_BG           = Color3.fromRGB(16, 16, 22)
local PANEL_BG          = Color3.fromRGB(22, 22, 30)
local PANEL_BG_ALT      = Color3.fromRGB(26, 18, 28)
local BUTTON_BG         = Color3.fromRGB(32, 32, 40)
local BUTTON_BG_STRONG  = Color3.fromRGB(48, 18, 26)
local HOVER_BG          = Color3.fromRGB(45, 22, 30)
local TEXT_MAIN         = Color3.fromRGB(240, 240, 255)
local TEXT_SUB          = Color3.fromRGB(180, 180, 205)
local TEXT_DIM          = Color3.fromRGB(130, 130, 150)
local ERROR_RED         = Color3.fromRGB(255, 70, 90)
local SUCCESS_GREEN     = Color3.fromRGB(60, 220, 120)

local animationsEnabled = true

--=========================================================
-- SETTINGS (runtime, editable via UI)
--=========================================================
local Settings = {
	AimbotKey = Enum.KeyCode.E
}

--=========================================================
-- ROOT GUI + SCALING
--=========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VroAimbot"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = false -- important when mixing Mouse.X/Y & GUI [web:153][web:156]
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local uiScale = Instance.new("UIScale")
uiScale.Parent = ScreenGui

local function updateScale()
	if not camera then return end
	local size = camera.ViewportSize
	local minAxis = math.min(size.X, size.Y)
	local scale = minAxis / 1080
	uiScale.Scale = math.clamp(scale, 0.7, 1.2)
end

updateScale()
RunService.RenderStepped:Connect(updateScale)

--=========================================================
-- NOTIFICATIONS
--=========================================================
local NotificationContainer = Instance.new("Frame")
NotificationContainer.Size = UDim2.new(0, 360, 1, 0)
NotificationContainer.Position = UDim2.new(1, -380, 0, 20)
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.BorderSizePixel = 0
NotificationContainer.ZIndex = 50
NotificationContainer.Parent = ScreenGui

local NotificationLayout = Instance.new("UIListLayout")
NotificationLayout.Padding = UDim.new(0, 8)
NotificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotificationLayout.Parent = NotificationContainer

local function notify(text, color)
	color = color or ACCENT_RED
	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(1, 0, 0, 56)
	notif.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
	notif.BackgroundTransparency = 1
	notif.BorderSizePixel = 0
	notif.ZIndex = 51
	notif.Parent = NotificationContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = notif

	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = 2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = notif

	local leftAccent = Instance.new("Frame")
	leftAccent.Size = UDim2.new(0, 4, 1, 0)
	leftAccent.BackgroundColor3 = color
	leftAccent.BorderSizePixel = 0
	leftAccent.ZIndex = 51
	leftAccent.Parent = notif

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -16, 1, 0)
	lbl.Position = UDim2.new(0, 10, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = TEXT_MAIN
	lbl.TextScaled = true
	lbl.Font = Enum.Font.GothamSemibold
	lbl.Text = text
	lbl.ZIndex = 51
	lbl.Parent = notif

	notif.Position = UDim2.new(1, 40, 0, 0)
	if animationsEnabled then
		TweenService:Create(
			notif,
			TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}
		):Play()
	else
		notif.Position = UDim2.new(0, 0, 0, 0)
		notif.BackgroundTransparency = 0
	end

	task.delay(3.5, function()
		if notif.Parent then
			if animationsEnabled then
				local t = TweenService:Create(
					notif,
					TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{Position = UDim2.new(1, 40, 0, 0), BackgroundTransparency = 1}
				)
				t:Play()
				t.Completed:Wait()
			end
			notif:Destroy()
		end
	end)
end

--=========================================================
-- MAIN FRAME + DRAG + MINIMIZE
--=========================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "VroAimSuite"
MainFrame.Size = UDim2.new(0, 720, 0, 430)
MainFrame.Position = UDim2.new(0.5, -360, 0.5, -215)
MainFrame.BackgroundColor3 = DARK_BG
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 5
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 18)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = ACCENT_RED
MainStroke.Thickness = 2.6
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 46)
TitleBar.BackgroundColor3 = DARKEST
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 11
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 18)
TitleCorner.Parent = TitleBar

local TitleAccent = Instance.new("Frame")
TitleAccent.Size = UDim2.new(0, 4, 1, 0)
TitleAccent.BackgroundColor3 = ACCENT_RED
TitleAccent.BorderSizePixel = 0
TitleAccent.ZIndex = 11
TitleAccent.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -180, 0.6, 0)
TitleText.Position = UDim2.new(0, 16, 0, 2)
TitleText.BackgroundTransparency = 1
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Text = "VRO AIM SUITE"
TitleText.TextColor3 = TEXT_MAIN
TitleText.TextScaled = true
TitleText.Font = Enum.Font.GothamBlack
TitleText.ZIndex = 11
TitleText.Parent = TitleBar

local SubtitleText = Instance.new("TextLabel")
SubtitleText.Size = UDim2.new(1, -180, 0.4, 0)
SubtitleText.Position = UDim2.new(0, 16, 0.58, 0)
SubtitleText.BackgroundTransparency = 1
SubtitleText.TextXAlignment = Enum.TextXAlignment.Left
SubtitleText.Text = "Targeting • ESP • Rage • Silent • Auto"
SubtitleText.TextColor3 = TEXT_SUB
SubtitleText.TextScaled = true
SubtitleText.Font = Enum.Font.GothamSemibold
SubtitleText.ZIndex = 11
SubtitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 34, 0, 34)
CloseBtn.Position = UDim2.new(1, -42, 0.5, -17)
CloseBtn.BackgroundColor3 = BUTTON_BG
CloseBtn.Text = "X"
CloseBtn.TextColor3 = TEXT_SUB
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 12
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 34, 0, 34)
MinimizeBtn.Position = UDim2.new(1, -84, 0.5, -17)
MinimizeBtn.BackgroundColor3 = BUTTON_BG
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = TEXT_SUB
MinimizeBtn.TextScaled = true
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.ZIndex = 12
MinimizeBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(1, 0)
MinCorner.Parent = MinimizeBtn

local isMinimized = false
local storedSize = MainFrame.Size

MinimizeBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		storedSize = MainFrame.Size
		TweenService:Create(
			MainFrame,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Size = UDim2.new(storedSize.X.Scale, storedSize.X.Offset, 0, 46)}
		):Play()
		MinimizeBtn.Text = "[]"
	else
		TweenService:Create(
			MainFrame,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Size = storedSize}
		):Play()
		MinimizeBtn.Text = "-"
	end
end)

CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- drag main frame
do
	local dragging = false
	local dragStart, startPos
	local function update(input)
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
	TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = MainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end)
end

--=========================================================
-- CONTENT AREA + PANELS
--=========================================================
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -46)
Content.Position = UDim2.new(0, 0, 0, 46)
Content.BackgroundTransparency = 1
Content.ZIndex = 10
Content.Parent = MainFrame

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 180, 1, -16)
Sidebar.Position = UDim2.new(0, 10, 0, 8)
Sidebar.BackgroundColor3 = DARKEST
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 10
Sidebar.Parent = Content

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 14)
SidebarCorner.Parent = Sidebar

local SidebarStroke = Instance.new("UIStroke")
SidebarStroke.Color = ACCENT_RED_DEEP
SidebarStroke.Thickness = 1.6
SidebarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
SidebarStroke.Parent = Sidebar

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Parent = Sidebar

local SidebarPad = Instance.new("UIPadding")
SidebarPad.PaddingTop = UDim.new(0, 10)
SidebarPad.PaddingLeft = UDim.new(0, 10)
SidebarPad.PaddingRight = UDim.new(0, 10)
SidebarPad.Parent = Sidebar

local SideLabel = Instance.new("TextLabel")
SideLabel.Size = UDim2.new(1, -4, 0, 26)
SideLabel.BackgroundTransparency = 1
SideLabel.Text = "MODULES"
SideLabel.TextColor3 = TEXT_DIM
SideLabel.TextScaled = true
SideLabel.Font = Enum.Font.GothamSemibold
SideLabel.LayoutOrder = 0
SideLabel.ZIndex = 10
SideLabel.Parent = Sidebar

local SideSep = Instance.new("Frame")
SideSep.Size = UDim2.new(1, -4, 0, 1)
SideSep.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
SideSep.BorderSizePixel = 0
SideSep.LayoutOrder = 1
SideSep.ZIndex = 10
SideSep.Parent = Sidebar

local MainArea = Instance.new("Frame")
MainArea.Size = UDim2.new(1, -210, 1, -16)
MainArea.Position = UDim2.new(0, 200, 0, 8)
MainArea.BackgroundColor3 = PANEL_BG
MainArea.BorderSizePixel = 0
MainArea.ZIndex = 9
MainArea.Parent = Content

local MainAreaCorner = Instance.new("UICorner")
MainAreaCorner.CornerRadius = UDim.new(0, 14)
MainAreaCorner.Parent = MainArea

local MainAreaStroke = Instance.new("UIStroke")
MainAreaStroke.Color = ACCENT_RED_DEEP
MainAreaStroke.Thickness = 1.8
MainAreaStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainAreaStroke.Parent = MainArea

local function createScrollablePanel()
	local scroll = Instance.new("ScrollingFrame")
	scroll.BackgroundTransparency = 1
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.ScrollBarThickness = 6
	scroll.ScrollBarImageColor3 = ACCENT_RED
	scroll.BorderSizePixel = 0
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ZIndex = 9
	scroll.Parent = MainArea

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 12)
	pad.PaddingLeft = UDim.new(0, 14)
	pad.PaddingRight = UDim.new(0, 14)
	pad.PaddingBottom = UDim.new(0, 12)
	pad.Parent = scroll

	return scroll
end

local TargetScroll   = createScrollablePanel()
local AimbotScroll   = createScrollablePanel()
local ESPScroll      = createScrollablePanel()
local SettingsScroll = createScrollablePanel()

TargetScroll.Visible   = true
AimbotScroll.Visible   = false
ESPScroll.Visible      = false
SettingsScroll.Visible = false

local function createTabButton(text)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -4, 0, 34)
	btn.BackgroundColor3 = BUTTON_BG
	btn.TextColor3 = TEXT_SUB
	btn.TextScaled = true
	btn.Font = Enum.Font.GothamSemibold
	btn.Text = text
	btn.AutoButtonColor = false
	btn.BorderSizePixel = 0
	btn.ZIndex = 10
	btn.Parent = Sidebar

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = btn

	return btn
end

local TargetTab   = createTabButton("Targeting")
local AimbotTab   = createTabButton("Aimbot / Rage")
local ESPTab      = createTabButton("ESP")
local SettingsTab = createTabButton("Settings")

local function setTab(active)
	TargetScroll.Visible   = (active == "Target")
	AimbotScroll.Visible   = (active == "Aimbot")
	ESPScroll.Visible      = (active == "ESP")
	SettingsScroll.Visible = (active == "Settings")

	local function style(btn, on)
		btn.BackgroundColor3 = on and BUTTON_BG_STRONG or BUTTON_BG
		btn.TextColor3 = on and TEXT_MAIN or TEXT_SUB
	end
	style(TargetTab,   active == "Target")
	style(AimbotTab,   active == "Aimbot")
	style(ESPTab,      active == "ESP")
	style(SettingsTab, active == "Settings")
end

TargetTab.MouseButton1Click:Connect(function() setTab("Target") end)
AimbotTab.MouseButton1Click:Connect(function() setTab("Aimbot") end)
ESPTab.MouseButton1Click:Connect(function() setTab("ESP") end)
SettingsTab.MouseButton1Click:Connect(function() setTab("Settings") end)
setTab("Target")

local function createHeader(parent, title, subtitle)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 50)
	container.BackgroundColor3 = PANEL_BG_ALT
	container.BorderSizePixel = 0
	container.ZIndex = 9
	container.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = container

	local leftAccent = Instance.new("Frame")
	leftAccent.Size = UDim2.new(0, 4, 1, -10)
	leftAccent.Position = UDim2.new(0, 4, 0, 5)
	leftAccent.BackgroundColor3 = ACCENT_RED
	leftAccent.BorderSizePixel = 0
	leftAccent.ZIndex = 9
	leftAccent.Parent = container

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -18, 0.6, 0)
	titleLbl.Position = UDim2.new(0, 12, 0, 2)
	titleLbl.BackgroundTransparency = 1
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Text = title
	titleLbl.TextColor3 = TEXT_MAIN
	titleLbl.TextScaled = true
	titleLbl.Font = Enum.Font.GothamBlack
	titleLbl.ZIndex = 9
	titleLbl.Parent = container

	local subtitleLbl = Instance.new("TextLabel")
	subtitleLbl.Size = UDim2.new(1, -18, 0.4, 0)
	subtitleLbl.Position = UDim2.new(0, 12, 0.58, 0)
	subtitleLbl.BackgroundTransparency = 1
	subtitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	subtitleLbl.Text = subtitle or ""
	subtitleLbl.TextColor3 = TEXT_SUB
	subtitleLbl.TextScaled = true
	subtitleLbl.Font = Enum.Font.GothamSemibold
	subtitleLbl.ZIndex = 9
	subtitleLbl.Parent = container

	return container
end

local function createToggle(parent, title, subtitle, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 56)
	frame.BackgroundColor3 = PANEL_BG
	frame.BorderSizePixel = 0
	frame.ZIndex = 9
	frame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(60, 60, 80)
	stroke.Thickness = 1.2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = frame

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -120, 0, 24)
	titleLbl.Position = UDim2.new(0, 10, 0, 4)
	titleLbl.BackgroundTransparency = 1
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Text = title
	titleLbl.TextColor3 = TEXT_MAIN
	titleLbl.TextScaled = true
	titleLbl.Font = Enum.Font.GothamSemibold
	titleLbl.ZIndex = 9
	titleLbl.Parent = frame

	local subtitleLbl = Instance.new("TextLabel")
	subtitleLbl.Size = UDim2.new(1, -120, 0, 20)
	subtitleLbl.Position = UDim2.new(0, 10, 0, 28)
	subtitleLbl.BackgroundTransparency = 1
	subtitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	subtitleLbl.Text = subtitle or ""
	subtitleLbl.TextColor3 = TEXT_DIM
	subtitleLbl.TextScaled = true
	subtitleLbl.Font = Enum.Font.Gotham
	subtitleLbl.ZIndex = 9
	subtitleLbl.Parent = frame

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(0, 90, 0, 30)
	toggleBtn.Position = UDim2.new(1, -100, 0.5, -15)
	toggleBtn.BackgroundColor3 = BUTTON_BG
	toggleBtn.Text = ""
	toggleBtn.AutoButtonColor = false
	toggleBtn.BorderSizePixel = 0
	toggleBtn.ZIndex = 9
	toggleBtn.Parent = frame

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(1, 0)
	toggleCorner.Parent = toggleBtn

	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 26, 0, 26)
	dot.Position = default and UDim2.new(1, -30, 0.5, -13) or UDim2.new(0, 4, 0.5, -13)
	dot.BackgroundColor3 = default and ACCENT_RED or Color3.fromRGB(110, 110, 125)
	dot.BorderSizePixel = 0
	dot.ZIndex = 10
	dot.Parent = toggleBtn

	local dotCorner = Instance.new("UICorner")
	dotCorner.CornerRadius = UDim.new(1, 0)
	dotCorner.Parent = dot

	local state = default
	callback(state)

	local function applyState(instant)
		local goalPos = state and UDim2.new(1, -30, 0.5, -13) or UDim2.new(0, 4, 0.5, -13)
		local goalColor = state and ACCENT_RED or Color3.fromRGB(110, 110, 125)
		local frameColor = state and BUTTON_BG_STRONG or PANEL_BG
		local strokeColor = state and ACCENT_RED_DEEP or Color3.fromRGB(60, 60, 80)

		if animationsEnabled and not instant then
			TweenService:Create(
				dot,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Position = goalPos, BackgroundColor3 = goalColor}
			):Play()
			TweenService:Create(
				frame,
				TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{BackgroundColor3 = frameColor}
			):Play()
			TweenService:Create(
				stroke,
				TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Color = strokeColor}
			):Play()
		else
			dot.Position = goalPos
			dot.BackgroundColor3 = goalColor
			frame.BackgroundColor3 = frameColor
			stroke.Color = strokeColor
		end
	end

	applyState(true)

	toggleBtn.MouseButton1Click:Connect(function()
		state = not state
		callback(state)
		applyState(false)
	end)

	return frame
end

local function createSlider(parent, title, minVal, maxVal, default, callback, hint)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 80)
	frame.BackgroundColor3 = PANEL_BG
	frame.BorderSizePixel = 0
	frame.ZIndex = 9
	frame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(60, 60, 80)
	stroke.Thickness = 1.2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = frame

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -90, 0, 26)
	titleLbl.Position = UDim2.new(0, 10, 0, 4)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = title
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.TextColor3 = TEXT_MAIN
	titleLbl.TextScaled = true
	titleLbl.Font = Enum.Font.GothamSemibold
	titleLbl.ZIndex = 9
	titleLbl.Parent = frame

	local hintLbl = Instance.new("TextLabel")
	hintLbl.Size = UDim2.new(1, -90, 0, 20)
	hintLbl.Position = UDim2.new(0, 10, 0, 28)
	hintLbl.BackgroundTransparency = 1
	hintLbl.Text = hint or ""
	hintLbl.TextXAlignment = Enum.TextXAlignment.Left
	hintLbl.TextColor3 = TEXT_DIM
	hintLbl.TextScaled = true
	hintLbl.Font = Enum.Font.Gotham
	hintLbl.ZIndex = 9
	hintLbl.Parent = frame

	local valueLbl = Instance.new("TextLabel")
	valueLbl.Size = UDim2.new(0, 80, 0, 26)
	valueLbl.Position = UDim2.new(1, -82, 0, 4)
	valueLbl.BackgroundTransparency = 1
	valueLbl.Text = tostring(default)
	valueLbl.TextXAlignment = Enum.TextXAlignment.Right
	valueLbl.TextColor3 = ACCENT_RED
	valueLbl.TextScaled = true
	valueLbl.Font = Enum.Font.GothamBold
	valueLbl.ZIndex = 9
	valueLbl.Parent = frame

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, -20, 0, 12)
	bar.Position = UDim2.new(0, 10, 0, 54)
	bar.BackgroundColor3 = BUTTON_BG
	bar.BorderSizePixel = 0
	bar.ZIndex = 9
	bar.Parent = frame

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 6)
	barCorner.Parent = bar

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - minVal) / (maxVal - minVal), 0, 1, 0)
	fill.BackgroundColor3 = ACCENT_RED
	fill.BorderSizePixel = 0
	fill.ZIndex = 9
	fill.Parent = bar

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 6)
	fillCorner.Parent = fill

	local knob = Instance.new("TextButton")
	knob.AutoButtonColor = false
	knob.Size = UDim2.new(0, 22, 0, 22)
	knob.Position = UDim2.new((default - minVal) / (maxVal - minVal), -11, 0.5, -11)
	knob.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
	knob.Text = ""
	knob.BorderSizePixel = 0
	knob.ZIndex = 9
	knob.Parent = bar

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob

	local dragging = false
	local function updateValue(val)
		val = math.clamp(val, minVal, maxVal)
		local percent = (val - minVal) / (maxVal - minVal)
		if animationsEnabled then
			TweenService:Create(
				fill,
				TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Size = UDim2.new(percent, 0, 1, 0)}
			):Play()
			TweenService:Create(
				knob,
				TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Position = UDim2.new(percent, -11, 0.5, -11)}
			):Play()
		else
			fill.Size = UDim2.new(percent, 0, 1, 0)
			knob.Position = UDim2.new(percent, -11, 0.5, -11)
		end
		valueLbl.Text = tostring(math.floor(val * 100 + 0.5) / 100)
		callback(val)
	end

	knob.MouseButton1Down:Connect(function()
		dragging = true
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local rel = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
			updateValue(minVal + rel * (maxVal - minVal))
		end
	end)

	updateValue(default)
	return frame
end

--=========================================================
-- STATE
--=========================================================
local selectedPlayer   = nil
local targetMode       = "All"

local ESP_Enabled           = true
local ESP_TeamColor         = true
local ESP_FillTransparency  = 0.6
local ESP_MaxDistance       = 2000
local lastESPRefresh        = 0

local ESP_HighlightsFolder = Instance.new("Folder")
ESP_HighlightsFolder.Name  = "VRO_ESP_Highlights"
ESP_HighlightsFolder.Parent = ScreenGui

local Aimbot_Enabled            = true
local Aimbot_WallCheck          = true
local Aimbot_TeamCheck          = true
local Aimbot_Prediction         = true
local Aimbot_PredictionStrength = 0.12
local Aimbot_Sensitivity        = 0.18
local Aimbot_FOVRadius          = 250
local Aimbot_ShowFOV            = true
local Aimbot_On                 = false

local RageMode_Enabled          = false
local Rage_FOVRadius            = 550
local Rage_Sensitivity          = 0.5
local Rage_StickFrames          = 14

local AutoFire_Enabled          = false
local AutoFire_Cooldown         = 0.11
local lastAutoFireTime          = 0

local SilentAim_Enabled      = false
local SilentAim_FOVRadius    = 260
local SilentAim_WallCheck    = true

local SavedAimPos            = nil
local MobileAimButton        = nil

--=========================================================
-- FIRE HANDLER HOOK
--=========================================================
local function fireWeapon(hitPos)
	-- plug your gun logic here; hitPos is target position (silent aim)
end

--=========================================================
-- FOV CIRCLES (centered exactly on cursor)
--=========================================================
local FOVCircleGui          = Instance.new("Frame")
FOVCircleGui.Name           = "VRO_FOV"
FOVCircleGui.Size           = UDim2.new(0, Aimbot_FOVRadius * 2, 0, Aimbot_FOVRadius * 2)
FOVCircleGui.AnchorPoint    = Vector2.new(0.50005, 0.50005)
FOVCircleGui.BackgroundTransparency = 1
FOVCircleGui.BorderSizePixel = 0
FOVCircleGui.Visible        = Aimbot_ShowFOV
FOVCircleGui.ZIndex         = 30
FOVCircleGui.Parent         = ScreenGui

local fovCircle = Instance.new("ImageLabel")
fovCircle.Size = UDim2.new(1, 0, 1, 0)
fovCircle.BackgroundTransparency = 1
fovCircle.Image = "rbxassetid://12201347372"
fovCircle.ImageColor3 = Color3.fromRGB(255, 255, 255)
fovCircle.ImageTransparency = 0.3
fovCircle.ZIndex = 30
fovCircle.Parent = FOVCircleGui

local RageCircleGui = Instance.new("Frame")
RageCircleGui.Name = "VRO_RageFOV"
RageCircleGui.Size = UDim2.new(0, Rage_FOVRadius * 2, 0, Rage_FOVRadius * 2)
RageCircleGui.AnchorPoint = Vector2.new(0.5, 0.5)
RageCircleGui.BackgroundTransparency = 1
RageCircleGui.BorderSizePixel = 0
RageCircleGui.Visible = false
RageCircleGui.ZIndex = 29
RageCircleGui.Parent = ScreenGui

local rageCircle = Instance.new("ImageLabel")
rageCircle.Size = UDim2.new(1, 0, 1, 0)
rageCircle.BackgroundTransparency = 1
rageCircle.Image = "rbxassetid://12201347372"
rageCircle.ImageColor3 = ACCENT_RED_SOFT
rageCircle.ImageTransparency = 0.6
rageCircle.ZIndex = 29
rageCircle.Parent = RageCircleGui

--=========================================================
-- HELPERS
--=========================================================
local function sameTeam(a, b)
	if not a or not b then return false end
	if a.Team and b.Team then
		return a.Team == b.Team
	end
	return false
end

local function getDistance(p1, p2)
	return (p1 - p2).Magnitude
end

local function getOrCreateHighlight(plr)
	local tag = ESP_HighlightsFolder:FindFirstChild(plr.Name)
	if not tag then
		tag = Instance.new("Highlight")
		tag.Name = plr.Name
		tag.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		tag.FillTransparency = ESP_FillTransparency
		tag.FillColor = ACCENT_RED
		tag.OutlineColor = Color3.new(1, 1, 1)
		tag.OutlineTransparency = 0
		tag.Parent = ESP_HighlightsFolder
	end
	return tag
end

local function visible(fromPos, toPos, ignore)
	if not fromPos or not toPos then return false end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = ignore
	local dir = toPos - fromPos
	local result = Workspace:Raycast(fromPos, dir, params)
	if not result then return true end
	return (result.Position - toPos).Magnitude < 3
end

local function getHead(char)
	if not char then return nil end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local head = char:FindFirstChild("Head")
	if hum and hum.Health > 0 and head then
		return head
	end
	return nil
end

local function predictedPosition(targetHead, targetRoot)
	if not targetHead or not targetRoot then
		return nil
	end
	if not Aimbot_Prediction then
		return targetHead.Position
	end
	local vel = targetRoot.AssemblyLinearVelocity or Vector3.zero
	local camPos = camera.CFrame.Position
	local distance = (targetHead.Position - camPos).Magnitude
	local bulletSpeed = 350
	local t = distance / bulletSpeed
	local factor = math.clamp(1 + Aimbot_PredictionStrength, 1, 1.7)
	return targetHead.Position + vel * t * factor
end

local lastRageTarget
local rageStickCounter = 0

local function getBestTargetPos(customFOV, doWallCheck)
	local myChar = player.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return nil end

	local mousePos = Vector2.new(mouse.X, mouse.Y) -- pure mouse coords [web:150][web:151]
	local bestPos = nil
	local bestPlayer = nil

	local baseFOV = customFOV or (RageMode_Enabled and Rage_FOVRadius or Aimbot_FOVRadius)
	local stickFrames = RageMode_Enabled and Rage_StickFrames or 4
	local smallestDist = baseFOV

	local function consider(plr)
		if plr == player then return end
		if Aimbot_TeamCheck and sameTeam(player, plr) then return end
		local char = plr.Character
		local head = char and getHead(char)
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not head or not root then return end

		local aimPos = predictedPosition(head, root)
		if not aimPos then return end

		if doWallCheck then
			if not visible(myRoot.Position, aimPos, {myChar, char}) then
				return
			end
		end

		local screenPos, onScreen = camera:WorldToViewportPoint(aimPos)
		if not onScreen or screenPos.Z <= 0 then
			return
		end

		local dist2D = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
		if dist2D <= smallestDist then
			smallestDist = dist2D
			bestPos = aimPos
			bestPlayer = plr
		end
	end

	if targetMode == "PerPlayer" then
		if selectedPlayer then
			consider(selectedPlayer)
		end
	elseif targetMode == "All" then
		for _, plr in ipairs(Players:GetPlayers()) do
			consider(plr)
		end
	elseif targetMode == "Enemies" then
		for _, plr in ipairs(Players:GetPlayers()) do
			if not sameTeam(player, plr) then
				consider(plr)
			end
		end
	end

	if RageMode_Enabled and not customFOV then
		if bestPos and bestPlayer then
			lastRageTarget = bestPlayer
			rageStickCounter = stickFrames
			return bestPos, bestPlayer
		end

		if lastRageTarget and rageStickCounter > 0 then
			rageStickCounter -= 1
			local char = lastRageTarget.Character
			local head = char and getHead(char)
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if head and root then
				return predictedPosition(head, root), lastRageTarget
			end
		else
			lastRageTarget = nil
		end
	end

	return bestPos, bestPlayer
end

local function getSilentAimHit()
	if not SilentAim_Enabled then return nil, nil end
	if not Aimbot_Enabled then return nil, nil end
	-- uses its own radius around cursor, independent of visible FOV circle
	local pos, plr = getBestTargetPos(SilentAim_FOVRadius, SilentAim_WallCheck)
	return pos, plr
end

--=========================================================
-- TARGETING / AIMBOT / ESP UI (minimal to keep script length sane)
--=========================================================
createHeader(TargetScroll, "PLAYER TARGETING", "Modes and per-player selection")
-- you can add your mode buttons & dropdown here (same as previous versions)

createHeader(AimbotScroll, "AIM ASSIST", "Rage, Silent, auto fire")

createToggle(
	AimbotScroll,
	"Aimbot Enabled",
	"Global aim assist",
	Aimbot_Enabled,
	function(state)
		Aimbot_Enabled = state
		Aimbot_On = false
	end
)

createToggle(
	AimbotScroll,
	"Rage Mode",
	"Very sticky, large FOV",
	RageMode_Enabled,
	function(state)
		RageMode_Enabled = state
		RageCircleGui.Visible = state
	end
)

createToggle(
	AimbotScroll,
	"Auto Fire",
	"Auto shoot when locked",
	AutoFire_Enabled,
	function(state)
		AutoFire_Enabled = state
	end
)

createToggle(
	AimbotScroll,
	"Silent Aim",
	"Clicks/taps lock bullets to targets",
	SilentAim_Enabled,
	function(state)
		SilentAim_Enabled = state
	end
)

createToggle(
	AimbotScroll,
	"Silent Aim Wall Check",
	"Silent Aim respects line of sight",
	SilentAim_WallCheck,
	function(state)
		SilentAim_WallCheck = state
	end
)

createToggle(
	AimbotScroll,
	"Wall Check",
	"Aimbot respects line of sight",
	Aimbot_WallCheck,
	function(state)
		Aimbot_WallCheck = state
	end
)

createSlider(
	AimbotScroll,
	"Aim Smoothness",
	0.02,
	0.5,
	Aimbot_Sensitivity,
	function(v) Aimbot_Sensitivity = v end,
	"Lower = snappier"
)

createSlider(
	AimbotScroll,
	"Silent Aim Radius",
	40,
	600,
	SilentAim_FOVRadius,
	function(v) SilentAim_FOVRadius = v end,
	"Around cursor"
)

createHeader(ESPScroll, "ESP VISUALS", "Highlights around players")

createToggle(
	ESPScroll,
	"ESP Enabled",
	"Highlights players within range",
	ESP_Enabled,
	function(state)
		ESP_Enabled = state
		if not state then
			for _, h in ipairs(ESP_HighlightsFolder:GetChildren()) do
				h.Enabled = false
			end
		end
	end
)

createToggle(
	ESPScroll,
	"Use Team Color",
	"Tint highlight using team color",
	ESP_TeamColor,
	function(state) ESP_TeamColor = state end
)

createSlider(
	ESPScroll,
	"ESP Max Distance",
	50,
	5000,
	ESP_MaxDistance,
	function(v) ESP_MaxDistance = v end,
	"Max range"
)

createSlider(
	ESPScroll,
	"Fill Transparency",
	0.1,
	0.9,
	ESP_FillTransparency,
	function(v) ESP_FillTransparency = v end,
	"Lower = more solid"
)

--=========================================================
-- SETTINGS TAB: keybind + mobile aim position
--=========================================================
createHeader(SettingsScroll, "SETTINGS", "Keybinds & Mobile Controls")

local function keyNameFromKeyCode(kc)
	local s = tostring(kc)
	return string.sub(s, 14)
end

local waitingForAimbotKey = false

local AimbotKeyFrame = Instance.new("Frame")
AimbotKeyFrame.Size = UDim2.new(1, 0, 0, 60)
AimbotKeyFrame.BackgroundColor3 = PANEL_BG
AimbotKeyFrame.BorderSizePixel = 0
AimbotKeyFrame.ZIndex = 9
AimbotKeyFrame.Parent = SettingsScroll

local akCorner = Instance.new("UICorner")
akCorner.CornerRadius = UDim.new(0, 10)
akCorner.Parent = AimbotKeyFrame

local akStroke = Instance.new("UIStroke")
akStroke.Color = Color3.fromRGB(60, 60, 80)
akStroke.Thickness = 1.2
akStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
akStroke.Parent = AimbotKeyFrame

local akLabel = Instance.new("TextLabel")
akLabel.Size = UDim2.new(1, -140, 0, 26)
akLabel.Position = UDim2.new(0, 10, 0, 4)
akLabel.BackgroundTransparency = 1
akLabel.Text = "Aimbot Toggle Key"
akLabel.TextColor3 = TEXT_MAIN
akLabel.TextScaled = true
akLabel.Font = Enum.Font.GothamSemibold
akLabel.TextXAlignment = Enum.TextXAlignment.Left
akLabel.ZIndex = 9
akLabel.Parent = AimbotKeyFrame

local akSub = Instance.new("TextLabel")
akSub.Size = UDim2.new(1, -140, 0, 20)
akSub.Position = UDim2.new(0, 10, 0, 30)
akSub.BackgroundTransparency = 1
akSub.Text = "Click button and press key"
akSub.TextColor3 = TEXT_DIM
akSub.TextScaled = true
akSub.Font = Enum.Font.Gotham
akSub.TextXAlignment = Enum.TextXAlignment.Left
akSub.ZIndex = 9
akSub.Parent = AimbotKeyFrame

local akButton = Instance.new("TextButton")
akButton.Size = UDim2.new(0, 120, 0, 32)
akButton.Position = UDim2.new(1, -130, 0.5, -16)
akButton.BackgroundColor3 = BUTTON_BG
akButton.Text = keyNameFromKeyCode(Settings.AimbotKey)
akButton.TextColor3 = TEXT_MAIN
akButton.TextScaled = true
akButton.Font = Enum.Font.GothamSemibold
akButton.AutoButtonColor = false
akButton.BorderSizePixel = 0
akButton.ZIndex = 9
akButton.Parent = AimbotKeyFrame

local akBtnCorner = Instance.new("UICorner")
akBtnCorner.CornerRadius = UDim.new(1, 0)
akBtnCorner.Parent = akButton

akButton.MouseButton1Click:Connect(function()
	waitingForAimbotKey = true
	akButton.Text = "Press key..."
end)

-- mobile settings row
local MobileSettingsFrame = Instance.new("Frame")
MobileSettingsFrame.Size = UDim2.new(1, 0, 0, 80)
MobileSettingsFrame.BackgroundColor3 = PANEL_BG
MobileSettingsFrame.BorderSizePixel = 0
MobileSettingsFrame.ZIndex = 9
MobileSettingsFrame.Parent = SettingsScroll

local msCorner = Instance.new("UICorner")
msCorner.CornerRadius = UDim.new(0, 10)
msCorner.Parent = MobileSettingsFrame

local msStroke = Instance.new("UIStroke")
msStroke.Color = Color3.fromRGB(60, 60, 80)
msStroke.Thickness = 1.2
msStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
msStroke.Parent = MobileSettingsFrame

local msLabel = Instance.new("TextLabel")
msLabel.Size = UDim2.new(1, -140, 0, 26)
msLabel.Position = UDim2.new(0, 10, 0, 4)
msLabel.BackgroundTransparency = 1
msLabel.Text = "Mobile Aim Button"
msLabel.TextColor3 = TEXT_MAIN
msLabel.TextScaled = true
msLabel.Font = Enum.Font.GothamSemibold
msLabel.TextXAlignment = Enum.TextXAlignment.Left
msLabel.ZIndex = 9
msLabel.Parent = MobileSettingsFrame

local msSub = Instance.new("TextLabel")
msSub.Size = UDim2.new(1, -140, 0, 20)
msSub.Position = UDim2.new(0, 10, 0, 30)
msSub.BackgroundTransparency = 1
msSub.Text = "Drag button on screen, then Save"
msSub.TextColor3 = TEXT_DIM
msSub.TextScaled = true
msSub.Font = Enum.Font.Gotham
msSub.TextXAlignment = Enum.TextXAlignment.Left
msSub.ZIndex = 9
msSub.Parent = MobileSettingsFrame

local SaveMobilePosBtn = Instance.new("TextButton")
SaveMobilePosBtn.Size = UDim2.new(0, 120, 0, 32)
SaveMobilePosBtn.Position = UDim2.new(1, -130, 0, 10)
SaveMobilePosBtn.BackgroundColor3 = BUTTON_BG
SaveMobilePosBtn.Text = "Save Position"
SaveMobilePosBtn.TextColor3 = TEXT_MAIN
SaveMobilePosBtn.TextScaled = true
SaveMobilePosBtn.Font = Enum.Font.GothamSemibold
SaveMobilePosBtn.AutoButtonColor = false
SaveMobilePosBtn.BorderSizePixel = 0
SaveMobilePosBtn.ZIndex = 9
SaveMobilePosBtn.Parent = MobileSettingsFrame

local msBtnCorner = Instance.new("UICorner")
msBtnCorner.CornerRadius = UDim.new(1, 0)
msBtnCorner.Parent = SaveMobilePosBtn

--=========================================================
-- MOBILE AIM BUTTON (frame 999, text 1000, moved up)
--=========================================================
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
	MobileAimButton = Instance.new("TextButton")
	MobileAimButton.Size = UDim2.new(0, 80, 0, 40)
	MobileAimButton.Position = SavedAimPos or UDim2.new(1, -110, 1, -140)
	MobileAimButton.AnchorPoint = Vector2.new(0, 0)
	MobileAimButton.BackgroundColor3 = BUTTON_BG_STRONG
	MobileAimButton.Text = "AIM"
	MobileAimButton.TextColor3 = TEXT_MAIN
	MobileAimButton.TextScaled = true
	MobileAimButton.Font = Enum.Font.GothamBold
	MobileAimButton.AutoButtonColor = false
	MobileAimButton.BorderSizePixel = 0
	MobileAimButton.ZIndex = 999
	MobileAimButton.Parent = ScreenGui

	local mbCorner = Instance.new("UICorner")
	mbCorner.CornerRadius = UDim.new(1, 0)
	mbCorner.Parent = MobileAimButton

	local mbStroke = Instance.new("UIStroke")
	mbStroke.Color = ACCENT_RED_DEEP
	mbStroke.Thickness = 1.6
	mbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	mbStroke.Parent = MobileAimButton

	-- text label inside button to bump ZIndex
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "AIM"
	label.TextColor3 = TEXT_MAIN
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.ZIndex = 1000
	label.Parent = MobileAimButton

	local dragging = false
	local dragOffset

	MobileAimButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragOffset = input.Position - MobileAimButton.AbsolutePosition
		end
	end)

	MobileAimButton.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.Touch then
			local vp = camera.ViewportSize
			local newPos = input.Position - dragOffset
			MobileAimButton.Position = UDim2.new(
				0,
				math.clamp(newPos.X, 0, vp.X - MobileAimButton.AbsoluteSize.X),
				0,
				math.clamp(newPos.Y, 0, vp.Y - MobileAimButton.AbsoluteSize.Y)
			)
		end
	end)

	UserInputService.TouchEnded:Connect(function()
		dragging = false
	end)

	local function refreshMobileState()
		MobileAimButton.BackgroundColor3 = Aimbot_On and ACCENT_RED or BUTTON_BG_STRONG
	end

	MobileAimButton.MouseButton1Click:Connect(function()
		if not Aimbot_Enabled then
			notify("Enable aimbot first", ERROR_RED)
			return
		end
		Aimbot_On = not Aimbot_On
		refreshMobileState()
	end)

	SaveMobilePosBtn.MouseButton1Click:Connect(function()
		if not MobileAimButton then return end
		SavedAimPos = MobileAimButton.Position
		notify("Saved mobile aim position", SUCCESS_GREEN)
	end)

	refreshMobileState()
else
	MobileSettingsFrame.Visible = false
end

-- every 9 seconds ensure mobile aim button is visible and on-screen [web:145][web:148]
task.spawn(function()
	while ScreenGui.Parent do
		task.wait(9)
		if MobileAimButton and MobileAimButton.Parent == ScreenGui then
			local vp = camera.ViewportSize
			local pos = MobileAimButton.AbsolutePosition
			local size = MobileAimButton.AbsoluteSize
			if pos.X + size.X < 0 or pos.Y + size.Y < 0 or pos.X > vp.X or pos.Y > vp.Y then
				MobileAimButton.Position = SavedAimPos or UDim2.new(1, -110, 1, -140)
			end
			MobileAimButton.Visible = true
			MobileAimButton.ZIndex = 999
			for _, c in ipairs(MobileAimButton:GetChildren()) do
				if c:IsA("TextLabel") then
					c.ZIndex = 1000
				end
			end
		end
	end
end)

--=========================================================
-- INPUT: keybind change, aimbot toggle, silent aim click/tap
--=========================================================
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end

	-- capture keybind
	if waitingForAimbotKey and input.UserInputType == Enum.UserInputType.Keyboard then
		waitingForAimbotKey = false
		Settings.AimbotKey = input.KeyCode
		akButton.Text = keyNameFromKeyCode(Settings.AimbotKey)
		notify("Aimbot keybind set to " .. akButton.Text, SUCCESS_GREEN)
		return
	end

	-- toggle aimbot via key
	if input.UserInputType == Enum.UserInputType.Keyboard
		and input.KeyCode == Settings.AimbotKey then
		if not Aimbot_Enabled then return end
		Aimbot_On = not Aimbot_On
		notify("Aimbot: " .. (Aimbot_On and "ON" or "OFF"), ACCENT_RED)
		if MobileAimButton then
			MobileAimButton.BackgroundColor3 = Aimbot_On and ACCENT_RED or BUTTON_BG_STRONG
		end
	end

	-- silent aim click/tap
	if SilentAim_Enabled and Aimbot_Enabled then
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			local hitPos, targetPlr = getSilentAimHit()
			if hitPos and targetPlr then
				fireWeapon(hitPos)
			end
		end
	end
end)

--=========================================================
-- RENDERSTEP: ESP every 9s + FOV circle + aimbot / auto-fire
--=========================================================
RunService.RenderStepped:Connect(function()
	local myChar = player.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local now = tick()

	-- ESP refresh every 9 seconds
	if ESP_Enabled and myRoot and now - lastESPRefresh >= 9 then
		lastESPRefresh = now
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				local char = plr.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				local h = getOrCreateHighlight(plr)
				if root and hum and hum.Health > 0 then
					local dist = getDistance(myRoot.Position, root.Position)
					if dist <= ESP_MaxDistance then
						h.Enabled = true
						h.Adornee = char
						if ESP_TeamColor and plr.Team and plr.TeamColor then
							h.FillColor = plr.TeamColor.Color
						else
							h.FillColor = ACCENT_RED
						end
						h.FillTransparency = ESP_FillTransparency
						h.OutlineTransparency = 0
					else
						h.Enabled = false
					end
				else
					h.Enabled = false
				end
			end
		end
	elseif not ESP_Enabled then
		for _, h in ipairs(ESP_HighlightsFolder:GetChildren()) do
			h.Enabled = false
		end
	end

	-- FOV circles exactly on cursor
	if Aimbot_ShowFOV then
		FOVCircleGui.Position = UDim2.fromOffset(mouse.X, mouse.Y)
	end
	if RageMode_Enabled then
		RageCircleGui.Position = UDim2.fromOffset(mouse.X, mouse.Y)
	end

	-- aimbot / rage logic + auto fire
	if Aimbot_Enabled and Aimbot_On then
		local aimPos, targetPlr = getBestTargetPos(nil, Aimbot_WallCheck)
		if aimPos then
			local currentCF = camera.CFrame
			local targetCF = CFrame.new(currentCF.Position, aimPos)
			local smooth = RageMode_Enabled and Rage_Sensitivity or Aimbot_Sensitivity
			camera.CFrame = currentCF:Lerp(targetCF, smooth)

			if AutoFire_Enabled and targetPlr then
				if now - lastAutoFireTime >= AutoFire_Cooldown then
					lastAutoFireTime = now
					fireWeapon(aimPos)
				end
			end
		end
	end
end)

          notify("Aim Suite Loaded", ACCENT_RED_SOFT)
