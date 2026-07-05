--=========================================================
-- VRO AIM SUITE
--=========================================================

--// SERVICES
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse  = player:GetMouse()

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
local TEXT_MAIN         = Color3.fromRGB(240, 240, 255)
local TEXT_SUB          = Color3.fromRGB(180, 180, 205)
local TEXT_DIM          = Color3.fromRGB(130, 130, 150)
local ERROR_RED         = Color3.fromRGB(255, 70, 90)
local SUCCESS_GREEN     = Color3.fromRGB(60, 220, 120)

local animationsEnabled = true

--=========================================================
-- SETTINGS (runtime)
--=========================================================
local Settings = {
	AimbotKey            = Enum.KeyCode.E,
	BasePredictionStrength = 0.12,
	DistanceScaleFactor  = 0.001,
}

--=========================================================
-- ROOT GUI + SCALE
--=========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VroAimbot"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local uiScale = Instance.new("UIScale")
uiScale.Parent = ScreenGui

local function updateScale()
	if not camera then return end
	local size = camera.ViewportSize
	local minAxis = math.min(size.X, size.Y)
	uiScale.Scale = math.clamp(minAxis / 1080, 0.7, 1.2)
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
NotificationContainer.ZIndex = 50
NotificationContainer.Parent = ScreenGui

local NotificationLayout = Instance.new("UIListLayout")
NotificationLayout.Padding = UDim.new(0, 8)
NotificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotificationLayout.Parent = NotificationContainer

local function notify(msg, color)
	color = color or ACCENT_RED
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, 56)
	f.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
	f.BackgroundTransparency = 1
	f.ZIndex = 51
	f.Parent = NotificationContainer

	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
	local s = Instance.new("UIStroke", f)
	s.Color = color
	s.Thickness = 2

	local left = Instance.new("Frame")
	left.Size = UDim2.new(0, 4, 1, 0)
	left.BackgroundColor3 = color
	left.BorderSizePixel = 0
	left.ZIndex = 52
	left.Parent = f

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -16, 1, 0)
	lbl.Position = UDim2.new(0, 10, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Text = msg
	lbl.TextColor3 = TEXT_MAIN
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextScaled = true
	lbl.ZIndex = 52
	lbl.Parent = f

	f.Position = UDim2.new(1, 40, 0, 0)
	TweenService:Create(
		f,
		TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}
	):Play()

	task.delay(3.5, function()
		if f.Parent then
			local t = TweenService:Create(
				f,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{Position = UDim2.new(1, 40, 0, 0), BackgroundTransparency = 1}
			)
			t:Play()
			t.Completed:Wait()
			f:Destroy()
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

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 18)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = ACCENT_RED
mainStroke.Thickness = 2.6

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 46)
TitleBar.BackgroundColor3 = DARKEST
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 6
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 18)

local TitleAccent = Instance.new("Frame")
TitleAccent.Size = UDim2.new(0, 4, 1, 0)
TitleAccent.BackgroundColor3 = ACCENT_RED
TitleAccent.BorderSizePixel = 0
TitleAccent.ZIndex = 6
TitleAccent.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -180, 0.6, 0)
TitleText.Position = UDim2.new(0, 16, 0, 2)
TitleText.BackgroundTransparency = 1
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Text = "VRO AIM SUITE"
TitleText.TextColor3 = TEXT_MAIN
TitleText.Font = Enum.Font.GothamBlack
TitleText.TextScaled = true
TitleText.ZIndex = 6
TitleText.Parent = TitleBar

local SubtitleText = Instance.new("TextLabel")
SubtitleText.Size = UDim2.new(1, -180, 0.4, 0)
SubtitleText.Position = UDim2.new(0, 16, 0.58, 0)
SubtitleText.BackgroundTransparency = 1
SubtitleText.TextXAlignment = Enum.TextXAlignment.Left
SubtitleText.Text = "Targeting • ESP • Rage"
SubtitleText.TextColor3 = TEXT_SUB
SubtitleText.Font = Enum.Font.GothamSemibold
SubtitleText.TextScaled = true
SubtitleText.ZIndex = 6
SubtitleText.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 34, 0, 34)
CloseBtn.Position = UDim2.new(1, -42, 0.5, -17)
CloseBtn.BackgroundColor3 = BUTTON_BG
CloseBtn.Text = "X"
CloseBtn.TextColor3 = TEXT_SUB
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextScaled = true
CloseBtn.AutoButtonColor = false
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex = 7
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 34, 0, 34)
MinimizeBtn.Position = UDim2.new(1, -84, 0.5, -17)
MinimizeBtn.BackgroundColor3 = BUTTON_BG
MinimizeBtn.Text = "▾"
MinimizeBtn.TextColor3 = TEXT_SUB
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextScaled = true
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.ZIndex = 7
MinimizeBtn.Parent = TitleBar
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(1, 0)

CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

local minimized = false
local storedSize = MainFrame.Size
MinimizeBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		storedSize = MainFrame.Size
		TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(storedSize.X.Scale, storedSize.X.Offset, 0, 46)}):Play()
		MinimizeBtn.Text = "▴"
	else
		TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = storedSize}):Play()
		MinimizeBtn.Text = "▾"
	end
end)

-- drag
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
-- CONTENT / TABS
--=========================================================
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -46)
Content.Position = UDim2.new(0, 0, 0, 46)
Content.BackgroundTransparency = 1
Content.ZIndex = 5
Content.Parent = MainFrame

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 180, 1, -16)
Sidebar.Position = UDim2.new(0, 10, 0, 8)
Sidebar.BackgroundColor3 = DARKEST
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 5
Sidebar.Parent = Content

Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 14)
local sStroke = Instance.new("UIStroke", Sidebar)
sStroke.Color = ACCENT_RED_DEEP
sStroke.Thickness = 1.6

local sLayout = Instance.new("UIListLayout", Sidebar)
sLayout.Padding = UDim.new(0, 6)
sLayout.SortOrder = Enum.SortOrder.LayoutOrder
sLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local sPad = Instance.new("UIPadding", Sidebar)
sPad.PaddingTop = UDim.new(0, 10)
sPad.PaddingLeft = UDim.new(0, 10)
sPad.PaddingRight = UDim.new(0, 10)

local SideLabel = Instance.new("TextLabel")
SideLabel.Size = UDim2.new(1, -4, 0, 26)
SideLabel.BackgroundTransparency = 1
SideLabel.Text = "MODULES"
SideLabel.TextColor3 = TEXT_DIM
SideLabel.Font = Enum.Font.GothamSemibold
SideLabel.TextScaled = true
SideLabel.ZIndex = 5
SideLabel.LayoutOrder = 0
SideLabel.Parent = Sidebar

local SideSep = Instance.new("Frame")
SideSep.Size = UDim2.new(1, -4, 0, 1)
SideSep.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
SideSep.BorderSizePixel = 0
SideSep.ZIndex = 5
SideSep.LayoutOrder = 1
SideSep.Parent = Sidebar

local MainArea = Instance.new("Frame")
MainArea.Size = UDim2.new(1, -210, 1, -16)
MainArea.Position = UDim2.new(0, 200, 0, 8)
MainArea.BackgroundColor3 = PANEL_BG
MainArea.BorderSizePixel = 0
MainArea.ZIndex = 5
MainArea.Parent = Content
Instance.new("UICorner", MainArea).CornerRadius = UDim.new(0, 14)
local mStroke = Instance.new("UIStroke", MainArea)
mStroke.Color = ACCENT_RED_DEEP
mStroke.Thickness = 1.8

local function createScrollablePanel()
	local scroll = Instance.new("ScrollingFrame")
	scroll.BackgroundTransparency = 1
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.ScrollBarThickness = 6
	scroll.ScrollBarImageColor3 = ACCENT_RED
	scroll.BorderSizePixel = 0
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ZIndex = 5
	scroll.Parent = MainArea

	local layout = Instance.new("UIListLayout", scroll)
	layout.Padding = UDim.new(0, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	local pad = Instance.new("UIPadding", scroll)
	pad.PaddingTop = UDim.new(0, 12)
	pad.PaddingLeft = UDim.new(0, 14)
	pad.PaddingRight = UDim.new(0, 14)
	pad.PaddingBottom = UDim.new(0, 12)

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
	btn.Font = Enum.Font.GothamSemibold
	btn.TextScaled = true
	btn.Text = text
	btn.AutoButtonColor = false
	btn.BorderSizePixel = 0
	btn.ZIndex = 5
	btn.Parent = Sidebar
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
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
		btn.TextColor3       = on and TEXT_MAIN        or TEXT_SUB
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
	container.ZIndex = 5
	container.Parent = parent
	Instance.new("UICorner", container).CornerRadius = UDim.new(0, 10)

	local leftAccent = Instance.new("Frame")
	leftAccent.Size = UDim2.new(0, 4, 1, -10)
	leftAccent.Position = UDim2.new(0, 4, 0, 5)
	leftAccent.BackgroundColor3 = ACCENT_RED
	leftAccent.BorderSizePixel = 0
	leftAccent.ZIndex = 5
	leftAccent.Parent = container

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -18, 0.6, 0)
	titleLbl.Position = UDim2.new(0, 12, 0, 2)
	titleLbl.BackgroundTransparency = 1
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Text = title
	titleLbl.TextColor3 = TEXT_MAIN
	titleLbl.Font = Enum.Font.GothamBlack
	titleLbl.TextScaled = true
	titleLbl.ZIndex = 5
	titleLbl.Parent = container

	local subtitleLbl = Instance.new("TextLabel")
	subtitleLbl.Size = UDim2.new(1, -18, 0.4, 0)
	subtitleLbl.Position = UDim2.new(0, 12, 0.58, 0)
	subtitleLbl.BackgroundTransparency = 1
	subtitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	subtitleLbl.Text = subtitle or ""
	subtitleLbl.TextColor3 = TEXT_SUB
	subtitleLbl.Font = Enum.Font.GothamSemibold
	subtitleLbl.TextScaled = true
	subtitleLbl.ZIndex = 5
	subtitleLbl.Parent = container
end

local function createToggle(parent, title, subtitle, default, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 56)
	frame.BackgroundColor3 = PANEL_BG
	frame.BorderSizePixel = 0
	frame.ZIndex = 5
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
	local stroke = Instance.new("UIStroke", frame)
	stroke.Color = Color3.fromRGB(60, 60, 80)
	stroke.Thickness = 1.2

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -120, 0, 24)
	titleLbl.Position = UDim2.new(0, 10, 0, 4)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = title
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.TextColor3 = TEXT_MAIN
	titleLbl.Font = Enum.Font.GothamSemibold
	titleLbl.TextScaled = true
	titleLbl.ZIndex = 5
	titleLbl.Parent = frame

	local subtitleLbl = Instance.new("TextLabel")
	subtitleLbl.Size = UDim2.new(1, -120, 0, 20)
	subtitleLbl.Position = UDim2.new(0, 10, 0, 28)
	subtitleLbl.BackgroundTransparency = 1
	subtitleLbl.Text = subtitle or ""
	subtitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	subtitleLbl.TextColor3 = TEXT_DIM
	subtitleLbl.Font = Enum.Font.Gotham
	subtitleLbl.TextScaled = true
	subtitleLbl.ZIndex = 5
	subtitleLbl.Parent = frame

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(0, 90, 0, 30)
	toggleBtn.Position = UDim2.new(1, -100, 0.5, -15)
	toggleBtn.BackgroundColor3 = BUTTON_BG
	toggleBtn.Text = ""
	toggleBtn.AutoButtonColor = false
	toggleBtn.BorderSizePixel = 0
	toggleBtn.ZIndex = 5
	toggleBtn.Parent = frame
	Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 26, 0, 26)
	dot.Position = default and UDim2.new(1, -30, 0.5, -13) or UDim2.new(0, 4, 0.5, -13)
	dot.BackgroundColor3 = default and ACCENT_RED or Color3.fromRGB(110, 110, 125)
	dot.BorderSizePixel = 0
	dot.ZIndex = 6
	dot.Parent = toggleBtn
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

	local state = default
	callback(state)

	local function applyState(instant)
		local pos = state and UDim2.new(1, -30, 0.5, -13) or UDim2.new(0, 4, 0.5, -13)
		local col = state and ACCENT_RED or Color3.fromRGB(110, 110, 125)
		local bg  = state and BUTTON_BG_STRONG or PANEL_BG
		local sc  = state and ACCENT_RED_DEEP or Color3.fromRGB(60, 60, 80)

		if animationsEnabled and not instant then
			TweenService:Create(dot, TweenInfo.new(0.2), {Position = pos, BackgroundColor3 = col}):Play()
			TweenService:Create(frame, TweenInfo.new(0.18), {BackgroundColor3 = bg}):Play()
			TweenService:Create(stroke, TweenInfo.new(0.18), {Color = sc}):Play()
		else
			dot.Position = pos
			dot.BackgroundColor3 = col
			frame.BackgroundColor3 = bg
			stroke.Color = sc
		end
	end
	applyState(true)

	toggleBtn.MouseButton1Click:Connect(function()
		state = not state
		callback(state)
		applyState(false)
	end)
end

local function createSlider(parent, title, minVal, maxVal, default, callback, hint)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 80)
	frame.BackgroundColor3 = PANEL_BG
	frame.BorderSizePixel = 0
	frame.ZIndex = 5
	frame.Parent = parent
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
	local stroke = Instance.new("UIStroke", frame)
	stroke.Color = Color3.fromRGB(60, 60, 80)
	stroke.Thickness = 1.2

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -90, 0, 26)
	titleLbl.Position = UDim2.new(0, 10, 0, 4)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = title
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.TextColor3 = TEXT_MAIN
	titleLbl.Font = Enum.Font.GothamSemibold
	titleLbl.TextScaled = true
	titleLbl.ZIndex = 5
	titleLbl.Parent = frame

	local hintLbl = Instance.new("TextLabel")
	hintLbl.Size = UDim2.new(1, -90, 0, 20)
	hintLbl.Position = UDim2.new(0, 10, 0, 28)
	hintLbl.BackgroundTransparency = 1
	hintLbl.Text = hint or ""
	hintLbl.TextXAlignment = Enum.TextXAlignment.Left
	hintLbl.TextColor3 = TEXT_DIM
	hintLbl.Font = Enum.Font.Gotham
	hintLbl.TextScaled = true
	hintLbl.ZIndex = 5
	hintLbl.Parent = frame

	local valueLbl = Instance.new("TextLabel")
	valueLbl.Size = UDim2.new(0, 80, 0, 26)
	valueLbl.Position = UDim2.new(1, -82, 0, 4)
	valueLbl.BackgroundTransparency = 1
	valueLbl.Text = tostring(default)
	valueLbl.TextXAlignment = Enum.TextXAlignment.Right
	valueLbl.TextColor3 = ACCENT_RED
	valueLbl.Font = Enum.Font.GothamBold
	valueLbl.TextScaled = true
	valueLbl.ZIndex = 5
	valueLbl.Parent = frame

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, -20, 0, 12)
	bar.Position = UDim2.new(0, 10, 0, 54)
	bar.BackgroundColor3 = BUTTON_BG
	bar.BorderSizePixel = 0
	bar.ZIndex = 5
	bar.Parent = frame
	Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 6)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - minVal) / (maxVal - minVal), 0, 1, 0)
	fill.BackgroundColor3 = ACCENT_RED
	fill.BorderSizePixel = 0
	fill.ZIndex = 5
	fill.Parent = bar
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 6)

	local knob = Instance.new("TextButton")
	knob.AutoButtonColor = false
	knob.Size = UDim2.new(0, 22, 0, 22)
	knob.Position = UDim2.new((default - minVal) / (maxVal - minVal), -11, 0.5, -11)
	knob.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
	knob.Text = ""
	knob.BorderSizePixel = 0
	knob.ZIndex = 5
	knob.Parent = bar
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local dragging = false
	local function setVal(v)
		v = math.clamp(v, minVal, maxVal)
		local pct = (v - minVal) / (maxVal - minVal)
		fill.Size = UDim2.new(pct, 0, 1, 0)
		knob.Position = UDim2.new(pct, -11, 0.5, -11)
		valueLbl.Text = tostring(math.floor(v * 100 + 0.5) / 100)
		callback(v)
	end

	knob.MouseButton1Down:Connect(function()
		dragging = true
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1
			or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
			or i.UserInputType == Enum.UserInputType.Touch) then
			local rel = (i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
			setVal(minVal + rel * (maxVal - minVal))
		end
	end)

	setVal(default)
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

local CurrentTarget = nil
local LostTargetTime = 0
local TargetStickTime = 0.2 -- seconds

local ESP_HighlightsFolder = Instance.new("Folder")
ESP_HighlightsFolder.Name  = "VRO_ESP_Highlights"
ESP_HighlightsFolder.Parent = ScreenGui

local Aimbot_Enabled            = true
local Aimbot_WallCheck          = true
local Aimbot_TeamCheck          = true
local Aimbot_Prediction         = true
local Aimbot_Sensitivity        = 0.18
local Aimbot_FOVRadius          = 250
local Aimbot_ShowFOV            = true
local Aimbot_On                 = false
local Aimbot_360Mode            = false
local Aimbot_EnemyVisibleSound  = true
local Aimbot_HitSound           = true

local RageMode_Enabled          = false
local Rage_FOVRadius            = 550
local Rage_Sensitivity          = 0.5
local Rage_StickFrames          = 14

local SilentAim_Enabled         = false

local SavedAimPos               = nil
local MobileAimButton           = nil

-- Sound IDs
local SOUND_ENEMY_VISIBLE = "rbxassetid://150975887"
local SOUND_HIT = "rbxassetid://134763632925481"

-- Track visible enemies for sound
local visibleEnemies = {}
local lastPlayedSounds = {}

--=========================================================
-- FIRE HANDLER (NO AUTO)
--=========================================================
local function fireWeapon()
	-- impossible to autofire on mobile
end

--=========================================================
-- FOV CIRCLES (centered on mouse)
--=========================================================
local FOVCircleGui = Instance.new("Frame")
FOVCircleGui.Size = UDim2.new(0, Aimbot_FOVRadius * 2, 0, Aimbot_FOVRadius * 2)
FOVCircleGui.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircleGui.BackgroundTransparency = 1
FOVCircleGui.BorderSizePixel = 0
FOVCircleGui.Visible = Aimbot_ShowFOV
FOVCircleGui.ZIndex = 20
FOVCircleGui.Parent = ScreenGui

local fovCircle = Instance.new("ImageLabel")
fovCircle.Size = UDim2.new(1, 0, 1, 0)
fovCircle.BackgroundTransparency = 1
fovCircle.Image = "rbxassetid://12201347372"
fovCircle.ImageColor3 = Color3.fromRGB(255, 255, 255)
fovCircle.ImageTransparency = 0.3
fovCircle.ZIndex = 20
fovCircle.Parent = FOVCircleGui
fovCircle.ScaleType = Enum.ScaleType.Fit

local RageCircleGui = Instance.new("Frame")
RageCircleGui.Size = UDim2.new(0, Rage_FOVRadius * 2, 0, Rage_FOVRadius * 2)
RageCircleGui.AnchorPoint = Vector2.new(0.5, 0.5)
RageCircleGui.BackgroundTransparency = 1
RageCircleGui.BorderSizePixel = 0
RageCircleGui.Visible = false
RageCircleGui.ZIndex = 19
RageCircleGui.Parent = ScreenGui

local rageCircle = Instance.new("ImageLabel")
rageCircle.Size = UDim2.new(1, 0, 1, 0)
rageCircle.BackgroundTransparency = 1
rageCircle.Image = "rbxassetid://12201347372"
rageCircle.ImageColor3 = ACCENT_RED_SOFT
rageCircle.ImageTransparency = 0.6
rageCircle.ZIndex = 19
rageCircle.Parent = RageCircleGui
rageCircle.ScaleType = Enum.ScaleType.Fit

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
	params.IgnoreWater = true
	local dir = toPos - fromPos
	local result = Workspace:Raycast(fromPos, dir, params)
	if not result then return true end
return (result.Position - toPos).Magnitude <= 1
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

local function playSound(soundId, volume)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume or 0.5
	sound.Parent = workspace
	game:GetService("Debris"):AddItem(sound, 2)
	sound:Play()
end

local function predictedPosition(targetHead, targetRoot)
	if not targetHead or not targetRoot or not camera then
		return nil
	end
	if not Aimbot_Prediction then
		return targetHead.Position
	end

	local vel = targetRoot.AssemblyLinearVelocity or Vector3.zero
	local camPos = camera.CFrame.Position
	local distance = (targetHead.Position - camPos).Magnitude

	local bulletSpeed = 300
	local t = distance / bulletSpeed

	local scale = Settings.BasePredictionStrength + distance * Settings.DistanceScaleFactor
	scale = math.clamp(scale, 0, 2)

	return targetHead.Position + vel * t * scale
end

local lastRageTarget
local rageStickCounter = 0

-------------------
local function isTargetValid(plr)
	if not plr or plr == player then
		return false
	end

	if Aimbot_TeamCheck and sameTeam(player, plr) then
		return false
	end

	local char = plr.Character
	if not char then
		return false
	end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then
		return false
	end

	return char:FindFirstChild("Head") ~= nil
		and char:FindFirstChild("HumanoidRootPart") ~= nil
end 
------------------------------

local function getBestTargetPos(customFOV, doWallCheck)
	local myChar = player.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot or not camera then
		return nil
	end

	local mousePos

	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		local vp = camera.ViewportSize
		mousePos = Vector2.new(vp.X / 2, vp.Y / 2)
	else
		mousePos = Vector2.new(mouse.X, mouse.Y)
	end

	local bestPos
	local bestPlayer

	local baseFOV = customFOV or (RageMode_Enabled and Rage_FOVRadius or Aimbot_FOVRadius)
	local smallest = baseFOV

	local function consider(plr)
		    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        return
		end
		
		if plr == player then
			return
		end

		if Aimbot_TeamCheck and sameTeam(player, plr) then
			return
		end

		if not isTargetValid(plr) then
			return
		end

		local char = plr.Character
		local head = char.Head
		local root = char.HumanoidRootPart

		local aimPos = predictedPosition(head, root)
		if not aimPos then
			return
		end

		if doWallCheck and not visible(myRoot.Position, aimPos, {myChar, char}) then
			return
		end

		local screenPos, onScreen = camera:WorldToViewportPoint(aimPos)
		if not onScreen or screenPos.Z <= 0 then
			return
		end

		local dist = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude

		if dist < smallest then
			smallest = dist
			bestPos = aimPos
			bestPlayer = plr
		end
	end

	if targetMode == "PerPlayer" then
		if selectedPlayer then
			consider(selectedPlayer)
		end
	elseif targetMode == "Enemies" then
		for _, plr in ipairs(Players:GetPlayers()) do
			if not sameTeam(player, plr) then
				consider(plr)
			end
		end
	else
		for _, plr in ipairs(Players:GetPlayers()) do
			consider(plr)
		end
	end

	-- Keep current target briefly for smoother aiming
	if bestPlayer then
		CurrentTarget = bestPlayer
		LostTargetTime = tick()
		return bestPos, bestPlayer
	end

	if CurrentTarget then
		if tick() - LostTargetTime < TargetStickTime and isTargetValid(CurrentTarget) then
			local char = CurrentTarget.Character
			return predictedPosition(char.Head, char.HumanoidRootPart), CurrentTarget
		end
	end

	CurrentTarget = nil
	return nil, nil
end

-- 360° target picker: ignores FOV and on-screen checks
local function getBestTargetPos360(doWallCheck)
	local myChar = player.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot or not camera then return nil end

	local bestPos, bestPlayer
	local bestDist = math.huge
	local camPos = camera.CFrame.Position

	local function consider(plr)
		local hum = char and char:FindFirstChildOfClass("Humanoid")
if not hum or hum.Health <= 0 then
	return
end
		if plr == player then return end
		if Aimbot_TeamCheck and sameTeam(player, plr) then return end
		local char = plr.Character
		local head = char and getHead(char)
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not head or not root then return end

		local aimPos = predictedPosition(head, root)
		if not aimPos then return end

		if doWallCheck and not visible(myRoot.Position, aimPos, {myChar, char}) then
			return
		end

		local dist = (aimPos - camPos).Magnitude
		if dist < bestDist then
			bestDist = dist
			bestPos = aimPos
			bestPlayer = plr
		end
	end

	if targetMode == "PerPlayer" then
		if selectedPlayer then
			consider(selectedPlayer)
		end
	elseif targetMode == "Enemies" then
		for _, plr in ipairs(Players:GetPlayers()) do
			if not sameTeam(player, plr) then
				consider(plr)
			end
		end
	else
		for _, plr in ipairs(Players:GetPlayers()) do
			consider(plr)
		end
	end

	return bestPos, bestPlayer
    end

--=========================================================
-- TARGETING UI
--=========================================================
createHeader(TargetScroll, "TARGETING", "Mode and locked target")

do
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 80)
	frame.BackgroundColor3 = PANEL_BG
	frame.BorderSizePixel = 0
	frame.ZIndex = 5
	frame.Parent = TargetScroll
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
	Instance.new("UIStroke", frame).Color = Color3.fromRGB(60,60,80)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 26)
	lbl.Position = UDim2.new(0, 10, 0, 4)
	lbl.BackgroundTransparency = 1
	lbl.Text = "Target Mode"
	lbl.TextColor3 = TEXT_MAIN
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextScaled = true
	lbl.ZIndex = 5
	lbl.Parent = frame

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, 0, 0, 20)
	sub.Position = UDim2.new(0, 10, 0, 30)
	sub.BackgroundTransparency = 1
	sub.Text = "All players, enemies only, or a locked player"
	sub.TextColor3 = TEXT_DIM
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextScaled = true
	sub.ZIndex = 5
	sub.Parent = frame

	local btnAll = Instance.new("TextButton")
	btnAll.Size = UDim2.new(0, 80, 0, 26)
	btnAll.Position = UDim2.new(0, 10, 0, 50)
	btnAll.BackgroundColor3 = BUTTON_BG_STRONG
	btnAll.Text = "All"
	btnAll.TextColor3 = TEXT_MAIN
	btnAll.Font = Enum.Font.GothamSemibold
	btnAll.TextScaled = true
	btnAll.AutoButtonColor = false
	btnAll.BorderSizePixel = 0
	btnAll.ZIndex = 5
	btnAll.Parent = frame
	Instance.new("UICorner", btnAll).CornerRadius = UDim.new(0, 6)

	local btnEnemies = btnAll:Clone()
	btnEnemies.Text = "Enemies"
	btnEnemies.Position = UDim2.new(0, 96, 0, 50)
	btnEnemies.Parent = frame

	local btnPer = btnAll:Clone()
	btnPer.Text = "Per"
	btnPer.Position = UDim2.new(0, 182, 0, 50)
	btnPer.Parent = frame

	local function refresh()
		btnAll.BackgroundColor3     = targetMode == "All"       and ACCENT_RED_DEEP or BUTTON_BG
		btnEnemies.BackgroundColor3 = targetMode == "Enemies"   and ACCENT_RED_DEEP or BUTTON_BG
		btnPer.BackgroundColor3     = targetMode == "PerPlayer" and ACCENT_RED_DEEP or BUTTON_BG
		btnAll.TextColor3     = targetMode == "All"       and TEXT_MAIN or TEXT_SUB
		btnEnemies.TextColor3 = targetMode == "Enemies"   and TEXT_MAIN or TEXT_SUB
		btnPer.TextColor3     = targetMode == "PerPlayer" and TEXT_MAIN or TEXT_SUB
	end
	refresh()

	btnAll.MouseButton1Click:Connect(function()
		targetMode = "All"
		selectedPlayer = nil
		refresh()
	end)
	btnEnemies.MouseButton1Click:Connect(function()
		targetMode = "Enemies"
		selectedPlayer = nil
		refresh()
	end)
	btnPer.MouseButton1Click:Connect(function()
		targetMode = "PerPlayer"
		refresh()
	end)
end

createHeader(AimbotScroll, "AIMBOT", "Prediction, wallcheck, and sensitivity")

createToggle(AimbotScroll, "Aimbot Enabled", "Global aim assist", Aimbot_Enabled, function(val)
	Aimbot_Enabled = val
	if not val then Aimbot_On = false end
end)

createToggle(AimbotScroll, "360 Mode", "Detect all enemies in 360°", Aimbot_360Mode, function(val)
	Aimbot_360Mode = val
end)

createToggle(AimbotScroll, "Show FOV", "", Aimbot_ShowFOV, function(val)
	Aimbot_ShowFOV = val
	FOVCircleGui.Visible = val
end)

createToggle(AimbotScroll, "Prediction Enabled", "Turn off to use raw head", Aimbot_Prediction, function(val)
	Aimbot_Prediction = val
end)

createToggle(AimbotScroll, "Wall Check", "Requires line of sight", Aimbot_WallCheck, function(val)
	Aimbot_WallCheck = val
end)

createSlider(AimbotScroll, "FOV Radius", 100, 800, Aimbot_FOVRadius, function(val)
	Aimbot_FOVRadius = val
	FOVCircleGui.Size = UDim2.new(0, val * 2, 0, val * 2)
end, "Pixels")

createSlider(AimbotScroll, "Sensitivity", 0, 1, Aimbot_Sensitivity, function(val)
	Aimbot_Sensitivity = val
end)

createHeader(AimbotScroll, "RAGE MODE", "Strong, sticky targeting")

createToggle(AimbotScroll, "Rage Mode", "", RageMode_Enabled, function(val)
	RageMode_Enabled = val
	RageCircleGui.Visible = val
end)

createSlider(AimbotScroll, "Rage FOV", 100, 1000, Rage_FOVRadius, function(val)
	Rage_FOVRadius = val
	RageCircleGui.Size = UDim2.new(0, val * 2, 0, val * 2)
end)

createSlider(AimbotScroll, "Rage Sensitivity", 0, 1, Rage_Sensitivity, function(val)
	Rage_Sensitivity = val
end)

createSlider(AimbotScroll, "Stick Frames", 1, 30, Rage_StickFrames, function(val)
	Rage_StickFrames = math.floor(val)
end)

createHeader(AimbotScroll, "AUDIO", "Sound notifications")

createToggle(AimbotScroll, "Enemy Visible Sound", "Play when enemy is in view", Aimbot_EnemyVisibleSound, function(val)
	Aimbot_EnemyVisibleSound = val
end)

createToggle(AimbotScroll, "Hit Sound", "Play when aimed target takes dmg", Aimbot_HitSound, function(val)
	Aimbot_HitSound = val
end)

createHeader(ESPScroll, "ESP", "Wallhacks and player highlights")

createToggle(ESPScroll, "ESP Enabled", "Highlights players in range", ESP_Enabled, function(val)
	ESP_Enabled = val
	if not val then
		for _, h in ipairs(ESP_HighlightsFolder:GetChildren()) do
			h.Enabled = false
		end
	end
end)

createSlider(ESPScroll, "Max Distance", 500, 5000, ESP_MaxDistance, function(val)
	ESP_MaxDistance = val
end, "Studs")

createSlider(ESPScroll, "Fill Opacity", 0, 1, 1 - ESP_FillTransparency, function(val)
	ESP_FillTransparency = 1 - val
	for _, child in ipairs(ESP_HighlightsFolder:GetChildren()) do
		if child:IsA("Highlight") then
			child.FillTransparency = ESP_FillTransparency
		end
	end
end)

createHeader(SettingsScroll, "SETTINGS", "Behavior and visuals")

createToggle(SettingsScroll, "Animations", "Smooth UI transitions", animationsEnabled, function(val)
	animationsEnabled = val
end)

-- FOV circle update loop + enemy detection + audio monitoring
RunService.RenderStepped:Connect(function()
	local scale = uiScale.Scale
	local myChar = player.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		-- Mobile: keep FOV in the center
		local center = camera.ViewportSize / 2

		FOVCircleGui.Position = UDim2.fromOffset(
			center.X / scale,
			center.Y / scale
		)

		RageCircleGui.Position = UDim2.fromOffset(
			center.X / scale,
			center.Y / scale
		)
	else
		-- PC: follow mouse
		local mouseLocation = UserInputService:GetMouseLocation()

		FOVCircleGui.Position = UDim2.fromOffset(
			mouseLocation.X / scale,
			mouseLocation.Y / scale
		)

		RageCircleGui.Position = UDim2.fromOffset(
			mouseLocation.X / scale,
			mouseLocation.Y / scale
		)
	end

	-- Track enemy sounds
	if Aimbot_EnemyVisibleSound and myRoot then
		local newVisibleEnemies = {}
		
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				local char = plr.Character
				local head = char and getHead(char)
				
				if head and (not Aimbot_TeamCheck or not sameTeam(player, plr)) then
					newVisibleEnemies[plr.UserId] = true
					
					if not visibleEnemies[plr.UserId] then
						-- Enemy just became visible
						playSound(SOUND_ENEMY_VISIBLE, 1.2)
					end
				end
			end
		end
		
		visibleEnemies = newVisibleEnemies
	end
end)

-- Monitor hit sounds
if Aimbot_HitSound then
	local function onPlayerHit()
	local char = player.Character
	if not char then return end

	local humanoid = char:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end
		
		local lastHealth = humanoid.Health
		
		humanoid.HealthChanged:Connect(function(newHealth)
			if newHealth < lastHealth and newHealth > 0 then
				playSound(SOUND_HIT, 0.5)
			end
			lastHealth = newHealth
		end)
	end
	
if player.Character then
	onPlayerHit()
end

player.CharacterAdded:Connect(function()
	task.wait(0.1)
	onPlayerHit()
end)
end

if UserInputService.TouchEnabled then
    MobileAimButton = Instance.new("TextButton")
    MobileAimButton.Size = UDim2.new(0, 70, 0, 70)
    MobileAimButton.Position = UDim2.new(1, -90, 0.5, -35)
    MobileAimButton.AnchorPoint = Vector2.new(0.5, 0.5)
    MobileAimButton.BackgroundColor3 = BUTTON_BG_STRONG
    MobileAimButton.Text = "AIM"
    MobileAimButton.TextScaled = true
    MobileAimButton.Font = Enum.Font.GothamBold
    MobileAimButton.TextColor3 = TEXT_MAIN
    MobileAimButton.Parent = ScreenGui

    Instance.new("UICorner", MobileAimButton).CornerRadius = UDim.new(1, 0)

    MobileAimButton.MouseButton1Click:Connect(function()
        if not Aimbot_Enabled then return end

        Aimbot_On = not Aimbot_On
        MobileAimButton.BackgroundColor3 = Aimbot_On and ACCENT_RED or BUTTON_BG_STRONG

        notify("Aimbot: " .. (Aimbot_On and "ON" or "OFF"), ACCENT_RED)
    end)
end

-- Input: Aimbot toggle + Silent Aim 360
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end

	-- toggle aimbot
	if input.UserInputType == Enum.UserInputType.Keyboard
		and input.KeyCode == Settings.AimbotKey then
		if not Aimbot_Enabled then return end
		Aimbot_On = not Aimbot_On
		notify("Aimbot: " .. (Aimbot_On and "ON" or "OFF"), ACCENT_RED)
		if MobileAimButton then
			MobileAimButton.BackgroundColor3 = Aimbot_On and ACCENT_RED or BUTTON_BG_STRONG
		end
	end

	-- Silent Aim 360°: one-tick snap and revert
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if Aimbot_Enabled and SilentAim_Enabled then
			local bestPos = select(1, getBestTargetPos360(Aimbot_WallCheck))
			if bestPos then
				local originalCF = camera.CFrame
				local snapCF = CFrame.new(originalCF.Position, bestPos)
				camera.CFrame = snapCF
				RunService.RenderStepped:Wait()
				camera.CFrame = originalCF
			end
		end

		-- normal fire
		fireWeapon()
	end
end)

RunService.RenderStepped:Connect(function()
	if not Aimbot_On or not Aimbot_Enabled then
		return
	end

	local targetPos

	if Aimbot_360Mode then
		targetPos = select(1, getBestTargetPos360(Aimbot_WallCheck))
	else
		targetPos = select(1, getBestTargetPos(nil, Aimbot_WallCheck))
	end

	if targetPos then
		local camCF = camera.CFrame
		local desired = CFrame.new(camCF.Position, targetPos)

		camera.CFrame = camCF:Lerp(
			desired,
			RageMode_Enabled and Rage_Sensitivity or Aimbot_Sensitivity
		)
	end
end)

RunService.RenderStepped:Connect(function()
	if not ESP_Enabled then
		for _, h in ipairs(ESP_HighlightsFolder:GetChildren()) do
			if h:IsA("Highlight") then
				h.Enabled = false
				h.Adornee = nil
			end
		end
		return
	end

	local myChar = player.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			local char = plr.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")

			local highlight = getOrCreateHighlight(plr)

			if root and hum and hum.Health > 0 then
				local dist = (root.Position - myRoot.Position).Magnitude

				if dist <= ESP_MaxDistance then
					highlight.Adornee = char
					highlight.Enabled = true
					highlight.FillTransparency = ESP_FillTransparency

					if ESP_TeamColor and sameTeam(player, plr) then
						highlight.FillColor = Color3.fromRGB(0, 170, 255)
						highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
					else
						highlight.FillColor = ACCENT_RED
						highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
					end
				else
					highlight.Enabled = false
					highlight.Adornee = nil
				end
			else
				highlight.Enabled = false
				highlight.Adornee = nil
			end
		end
	end
end)

notify("VRO Aim Suite loaded", ACCENT_RED_SOFT)
