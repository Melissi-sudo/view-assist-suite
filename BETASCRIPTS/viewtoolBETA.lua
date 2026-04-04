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

local RageMode_Enabled          = false
local Rage_FOVRadius            = 550
local Rage_Sensitivity          = 0.5
local Rage_StickFrames          = 14

local SilentAim_Enabled         = false

local SavedAimPos               = nil
local MobileAimButton           = nil

--=========================================================
-- FIRE HANDLER (NO AUTO)
--=========================================================
local function fireWeapon()
	-- call your tool firing logic here
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
	return (result.Position - toPos).Magnitude <= 2
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
	if not targetHead or not targetRoot or not camera then
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

	local scale = Settings.BasePredictionStrength + distance * Settings.DistanceScaleFactor
	scale = math.clamp(scale, 0, 2)

	return targetHead.Position + vel * t * scale
end

local lastRageTarget
local rageStickCounter = 0

local function getBestTargetPos(customFOV, doWallCheck)
	local myChar = player.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot or not camera then return nil end

	local mousePos = Vector2.new(mouse.X, mouse.Y)
	local bestPos, bestPlayer
	local baseFOV = customFOV or (RageMode_Enabled and Rage_FOVRadius or Aimbot_FOVRadius)
	local stickFrames = RageMode_Enabled and Rage_StickFrames or 4
	local smallest = baseFOV

	local function consider(plr)
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

		local screenPos, onScreen = camera:WorldToViewportPoint(aimPos)
		if not onScreen or screenPos.Z <= 0 then return end

		local dist2D = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
		if dist2D <= smallest then
			smallest = dist2D
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
	else -- All
		for _, plr in ipairs(Players:GetPlayers()) do
			consider(plr)
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

-- 360° target picker: ignores FOV and on-screen checks
local function getBestTargetPos360(doWallCheck)
	local myChar = player.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot or not camera then return nil end

	local bestPos, bestPlayer
	local bestDist = math.huge
	local camPos = camera.CFrame.Position

	local function consider(plr)
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
	end

	btnAll.MouseButton1Click:Connect(function()
		targetMode = "All"; refresh()
	end)
	btnEnemies.MouseButton1Click:Connect(function()
		targetMode = "Enemies"; refresh()
	end)
	btnPer.MouseButton1Click:Connect(function()
		targetMode = "PerPlayer"; refresh()
	end)
	refresh()
end

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
	lbl.Size = UDim2.new(1, -140, 0, 26)
	lbl.Position = UDim2.new(0, 10, 0, 4)
	lbl.BackgroundTransparency = 1
	lbl.Text = "Locked Player"
	lbl.TextColor3 = TEXT_MAIN
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextScaled = true
	lbl.ZIndex = 5
	lbl.Parent = frame

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, -140, 0, 20)
	sub.Position = UDim2.new(0, 10, 0, 30)
	sub.BackgroundTransparency = 1
	sub.Text = "Used when mode = Per"
	sub.TextColor3 = TEXT_DIM
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextScaled = true
	sub.ZIndex = 5
	sub.Parent = frame

	local current = Instance.new("TextLabel")
	current.Size = UDim2.new(1, -140, 0, 20)
	current.Position = UDim2.new(0, 10, 0, 52)
	current.BackgroundTransparency = 1
	current.Text = "Current: none"
	current.TextColor3 = TEXT_SUB
	current.TextXAlignment = Enum.TextXAlignment.Left
	current.Font = Enum.Font.Gotham
	current.TextScaled = true
	current.ZIndex = 5
	current.Parent = frame

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 120, 0, 30)
	btn.Position = UDim2.new(1, -130, 0.5, -15)
	btn.BackgroundColor3 = BUTTON_BG
	btn.Text = "Select"
	btn.TextColor3 = TEXT_MAIN
	btn.Font = Enum.Font.GothamSemibold
	btn.TextScaled = true
	btn.AutoButtonColor = false
	btn.BorderSizePixel = 0
	btn.ZIndex = 5
	btn.Parent = frame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

	local dropdown = Instance.new("Frame")
	dropdown.Size = UDim2.new(0, 180, 0, 0)
	dropdown.Position = UDim2.new(1, -190, 1, 4)
	dropdown.BackgroundColor3 = PANEL_BG
	dropdown.BorderSizePixel = 0
	dropdown.Visible = false
	dropdown.ZIndex = 10
	dropdown.Parent = frame
	Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 8)
	local dStroke = Instance.new("UIStroke", dropdown)
	dStroke.Color = ACCENT_RED_DEEP
	dStroke.Thickness = 1.2

	local dLayout = Instance.new("UIListLayout", dropdown)
	dLayout.Padding = UDim.new(0, 2)
	local dPad = Instance.new("UIPadding", dropdown)
	dPad.PaddingTop = UDim.new(0, 4)
	dPad.PaddingBottom = UDim.new(0, 4)
	dPad.PaddingLeft = UDim.new(0, 4)
	dPad.PaddingRight = UDim.new(0, 4)

	local function refreshDropdown()
		for _, child in ipairs(dropdown:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		local count = 0
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				count += 1
				local b = Instance.new("TextButton")
				b.Size = UDim2.new(1, -8, 0, 22)
				b.BackgroundColor3 = BUTTON_BG
				b.TextColor3 = TEXT_MAIN
				b.Text = plr.Name
				b.Font = Enum.Font.Gotham
				b.TextScaled = true
				b.AutoButtonColor = false
				b.BorderSizePixel = 0
				b.ZIndex = 11
				b.Parent = dropdown
				Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)

				b.MouseButton1Click:Connect(function()
					selectedPlayer = plr
					current.Text = "Current: " .. plr.Name
					dropdown.Visible = false
					dropdown.Size = UDim2.new(0, 180, 0, 0)
				end)
			end
		end
		dropdown.Size = UDim2.new(0, 180, 0, math.min(22 * count + 8, 150))
	end

	btn.MouseButton1Click:Connect(function()
		if dropdown.Visible then
			dropdown.Visible = false
			dropdown.Size = UDim2.new(0, 180, 0, 0)
		else
			refreshDropdown()
			dropdown.Visible = true
		end
	end)
end

--=========================================================
-- AIMBOT / RAGE UI
--=========================================================
createHeader(AimbotScroll, "AIMBOT / RAGE", "Main aim assist controls")

createToggle(AimbotScroll, "Aimbot Enabled", "Global aim assist", Aimbot_Enabled, function(v)
	Aimbot_Enabled = v
	if not v then Aimbot_On = false end
end)

createToggle(AimbotScroll, "Silent Aim", "One-tick snap on click (360°)", SilentAim_Enabled, function(v)
	SilentAim_Enabled = v
end)

createToggle(AimbotScroll, "Rage Mode", "Sticky, large FOV", RageMode_Enabled, function(v)
	RageMode_Enabled = v
	RageCircleGui.Visible = v
end)

createToggle(AimbotScroll, "Team Check", "Ignore teammates", Aimbot_TeamCheck, function(v)
	Aimbot_TeamCheck = v
end)

createToggle(AimbotScroll, "Wall Check", "Requires line of sight", Aimbot_WallCheck, function(v)
	Aimbot_WallCheck = v
end)

createToggle(AimbotScroll, "Prediction Enabled", "Turn off to use raw head", Aimbot_Prediction, function(v)
	Aimbot_Prediction = v
end)

createSlider(AimbotScroll, "Aim Smoothness", 0.02, 0.5, Aimbot_Sensitivity, function(v)
	Aimbot_Sensitivity = v
end, "Lower = snappier")

createSlider(AimbotScroll, "FOV Radius", 40, 600, Aimbot_FOVRadius, function(v)
	Aimbot_FOVRadius = v
	FOVCircleGui.Size = UDim2.new(0, v * 2, 0, v * 2)
end, "Circle size")

createSlider(AimbotScroll, "Base Prediction", 0, 0.5, Settings.BasePredictionStrength, function(v)
	Settings.BasePredictionStrength = v
end, "Base lead")

createSlider(AimbotScroll, "Distance Scale", 0, 0.003, Settings.DistanceScaleFactor, function(v)
	Settings.DistanceScaleFactor = v
end, "Lead grows with distance")

--=========================================================
-- ESP UI
--=========================================================
createHeader(ESPScroll, "ESP", "Highlights around players")

createToggle(ESPScroll, "ESP Enabled", "Highlights players in range", ESP_Enabled, function(v)
	ESP_Enabled = v
	if not v then
		for _, h in ipairs(ESP_HighlightsFolder:GetChildren()) do
			h.Enabled = false
		end
	end
end)

createToggle(ESPScroll, "Team Colors", "Tint with team color", ESP_TeamColor, function(v)
	ESP_TeamColor = v
end)

createSlider(ESPScroll, "Max Distance", 50, 5000, ESP_MaxDistance, function(v)
	ESP_MaxDistance = v
end, "Max ESP range")

createSlider(ESPScroll, "Fill Transparency", 0.1, 0.9, ESP_FillTransparency, function(v)
	ESP_FillTransparency = v
end, "Lower = more solid")

--=========================================================
-- SETTINGS UI (KEYBIND + MOBILE)
--=========================================================
createHeader(SettingsScroll, "SETTINGS", "Keybinds & Mobile")

local function keyNameFromKeyCode(kc)
	local s = tostring(kc)
	return string.sub(s, 14)
end

local waitingForAimbotKey = false

do
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 60)
	frame.BackgroundColor3 = PANEL_BG
	frame.BorderSizePixel = 0
	frame.ZIndex = 5
	frame.Parent = SettingsScroll
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
	Instance.new("UIStroke", frame).Color = Color3.fromRGB(60,60,80)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -140, 0, 26)
	lbl.Position = UDim2.new(0, 10, 0, 4)
	lbl.BackgroundTransparency = 1
	lbl.Text = "Aimbot Toggle Key"
	lbl.TextColor3 = TEXT_MAIN
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextScaled = true
	lbl.ZIndex = 5
	lbl.Parent = frame

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, -140, 0, 20)
	sub.Position = UDim2.new(0, 10, 0, 30)
	sub.BackgroundTransparency = 1
	sub.Text = "Click and press a key"
	sub.TextColor3 = TEXT_DIM
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Font = Enum.Font.Gotham
	sub.TextScaled = true
	sub.ZIndex = 5
	sub.Parent = frame

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 120, 0, 32)
	btn.Position = UDim2.new(1, -130, 0.5, -16)
	btn.BackgroundColor3 = BUTTON_BG
	btn.Text = keyNameFromKeyCode(Settings.AimbotKey)
	btn.TextColor3 = TEXT_MAIN
	btn.Font = Enum.Font.GothamSemibold
	btn.TextScaled = true
	btn.AutoButtonColor = false
	btn.BorderSizePixel = 0
	btn.ZIndex = 5
	btn.Parent = frame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

	btn.MouseButton1Click:Connect(function()
		waitingForAimbotKey = true
		btn.Text = "Press..."
	end)

	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if waitingForAimbotKey and input.UserInputType == Enum.UserInputType.Keyboard then
			waitingForAimbotKey = false
			Settings.AimbotKey = input.KeyCode
			btn.Text = keyNameFromKeyCode(Settings.AimbotKey)
			notify("Aimbot key = " .. btn.Text, SUCCESS_GREEN)
		end
	end)
end

local MobileSettingsFrame = Instance.new("Frame")
MobileSettingsFrame.Size = UDim2.new(1, 0, 0, 80)
MobileSettingsFrame.BackgroundColor3 = PANEL_BG
MobileSettingsFrame.BorderSizePixel = 0
MobileSettingsFrame.ZIndex = 5
MobileSettingsFrame.Parent = SettingsScroll
Instance.new("UICorner", MobileSettingsFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", MobileSettingsFrame).Color = Color3.fromRGB(60,60,80)

local msLabel = Instance.new("TextLabel")
msLabel.Size = UDim2.new(1, -140, 0, 26)
msLabel.Position = UDim2.new(0, 10, 0, 4)
msLabel.BackgroundTransparency = 1
msLabel.Text = "Mobile Aim Button"
msLabel.TextColor3 = TEXT_MAIN
msLabel.TextScaled = true
msLabel.Font = Enum.Font.GothamSemibold
msLabel.TextXAlignment = Enum.TextXAlignment.Left
msLabel.ZIndex = 5
msLabel.Parent = MobileSettingsFrame

local msSub = Instance.new("TextLabel")
msSub.Size = UDim2.new(1, -140, 0, 20)
msSub.Position = UDim2.new(0, 10, 0, 30)
msSub.BackgroundTransparency = 1
msSub.Text = "Drag button, then Save"
msSub.TextColor3 = TEXT_DIM
msSub.TextScaled = true
msSub.Font = Enum.Font.Gotham
msSub.TextXAlignment = Enum.TextXAlignment.Left
msSub.ZIndex = 5
msSub.Parent = MobileSettingsFrame

local SaveMobilePosBtn = Instance.new("TextButton")
SaveMobilePosBtn.Size = UDim2.new(0, 120, 0, 32)
SaveMobilePosBtn.Position = UDim2.new(1, -130, 0, 10)
SaveMobilePosBtn.BackgroundColor3 = BUTTON_BG
SaveMobilePosBtn.Text = "Save Position"
SaveMobilePosBtn.TextColor3 = TEXT_MAIN
SaveMobilePosBtn.Font = Enum.Font.GothamSemibold
SaveMobilePosBtn.TextScaled = true
SaveMobilePosBtn.AutoButtonColor = false
SaveMobilePosBtn.BorderSizePixel = 0
SaveMobilePosBtn.ZIndex = 5
SaveMobilePosBtn.Parent = MobileSettingsFrame
Instance.new("UICorner", SaveMobilePosBtn).CornerRadius = UDim.new(1, 0)

--=========================================================
-- MOBILE AIM BUTTON
--=========================================================
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
	MobileAimButton = Instance.new("TextButton")
	MobileAimButton.Size = UDim2.new(0, 80, 0, 40)
	MobileAimButton.Position = SavedAimPos or UDim2.new(1, -110, 1, -140)
	MobileAimButton.AnchorPoint = Vector2.new(0, 0)
	MobileAimButton.BackgroundColor3 = BUTTON_BG_STRONG
	MobileAimButton.Text = ""
	MobileAimButton.TextColor3 = TEXT_MAIN
	MobileAimButton.Font = Enum.Font.GothamBold
	MobileAimButton.TextScaled = true
	MobileAimButton.AutoButtonColor = false
	MobileAimButton.BorderSizePixel = 0
	MobileAimButton.ZIndex = 999
	MobileAimButton.Parent = ScreenGui
	Instance.new("UICorner", MobileAimButton).CornerRadius = UDim.new(1, 0)
	local mbStroke = Instance.new("UIStroke", MobileAimButton)
	mbStroke.Color = ACCENT_RED_DEEP
	mbStroke.Thickness = 1.6

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "AIM"
	label.TextColor3 = TEXT_MAIN
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
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

-- check mobile aim button every 9 seconds
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
-- INPUT: AIMBOT TOGGLE + SILENT AIM 360
--=========================================================
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

	-- SILENT AIM 360°: one-tick snap and revert
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

--=========================================================
-- RENDERSTEP: ESP every 9s + FOV + AIM
--=========================================================
RunService.RenderStepped:Connect(function()
	local myChar = player.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local now = tick()

	-- ESP (9s refresh)
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

	-- FOV circles exactly under mouse (account for UIScale)
	local mouseLocation = UserInputService:GetMouseLocation()
	local scale = uiScale.Scale
	FOVCircleGui.Position  = UDim2.fromOffset(mouseLocation.X / scale, mouseLocation.Y / scale)
	RageCircleGui.Position = UDim2.fromOffset(mouseLocation.X / scale, mouseLocation.Y / scale)

	-- aimbot / rage
	if Aimbot_Enabled and Aimbot_On then
		local aimPos = select(1, getBestTargetPos(nil, Aimbot_WallCheck))
		if aimPos then
			local currentCF = camera.CFrame
			local targetCF = CFrame.new(currentCF.Position, aimPos)
			local smooth = RageMode_Enabled and Rage_Sensitivity or Aimbot_Sensitivity
			camera.CFrame = currentCF:Lerp(targetCF, smooth)
		end
	end
end)

notify("VRO Aim Suite loaded", ACCENT_RED_SOFT)
