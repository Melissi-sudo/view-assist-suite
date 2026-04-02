--=========================================================
-- VRO VIEW TOOL
--=========================================================

--// SERVICES
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")

--// LOCAL PLAYER
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

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
-- ROOT GUI + LOAD INTRO
--=========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VroAimbot"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Fullscreen intro
local IntroFrame = Instance.new("Frame")
IntroFrame.Size = UDim2.new(1, 0, 1, 0)
IntroFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
IntroFrame.BorderSizePixel = 0
IntroFrame.ZIndex = 1000
IntroFrame.Parent = ScreenGui

local IntroLogo = Instance.new("TextLabel")
IntroLogo.AnchorPoint = Vector2.new(0.5, 0.5)
IntroLogo.Position = UDim2.new(0.5, 0, 0.5, 0)
IntroLogo.Size = UDim2.new(0, 0, 0, 0)
IntroLogo.BackgroundTransparency = 1
IntroLogo.Text = "VRO"
IntroLogo.TextColor3 = ACCENT_RED
IntroLogo.Font = Enum.Font.GothamBlack
IntroLogo.TextScaled = true
IntroLogo.ZIndex = 1001
IntroLogo.Parent = IntroFrame

local IntroSub = Instance.new("TextLabel")
IntroSub.AnchorPoint = Vector2.new(0.5, 0)
IntroSub.Position = UDim2.new(0.5, 0, 0.5, 40)
IntroSub.Size = UDim2.new(0, 320, 0, 30)
IntroSub.BackgroundTransparency = 1
IntroSub.Text = "Aim Suite • ESP & Target Assist"
IntroSub.TextColor3 = Color3.fromRGB(200, 200, 220)
IntroSub.Font = Enum.Font.GothamSemibold
IntroSub.TextScaled = true
IntroSub.ZIndex = 1001
IntroSub.TextTransparency = 1
IntroSub.Parent = IntroFrame

TweenService:Create(
	IntroLogo,
	TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	{Size = UDim2.new(0, 230, 0, 90)}
):Play()

task.wait(0.2)
TweenService:Create(
	IntroSub,
	TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	{TextTransparency = 0}
):Play()

task.wait(1.1)
TweenService:Create(
	IntroFrame,
	TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
	{BackgroundTransparency = 1}
):Play()
TweenService:Create(
	IntroLogo,
	TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
	{TextTransparency = 1}
):Play()
TweenService:Create(
	IntroSub,
	TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
	{TextTransparency = 1}
):Play()

task.delay(0.7, function()
	if IntroFrame then
		IntroFrame:Destroy()
	end
end)

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
-- MAIN FRAME + DRAG
--=========================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "VroAimSuite"
MainFrame.Size = UDim2.new(0, 720, 0, 420)
MainFrame.Position = UDim2.new(0.5, -360, 0.5, -210)
MainFrame.BackgroundColor3 = DARK_BG
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = -1
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 18)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = ACCENT_RED
MainStroke.Thickness = 2.6
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
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
TitleText.Size = UDim2.new(1, -140, 0.6, 0)
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
SubtitleText.Size = UDim2.new(1, -140, 0.4, 0)
SubtitleText.Position = UDim2.new(0, 16, 0.58, 0)
SubtitleText.BackgroundTransparency = 1
SubtitleText.TextXAlignment = Enum.TextXAlignment.Left
SubtitleText.Text = "Targeting • ESP • Smooth Aim"
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

CloseBtn.MouseEnter:Connect(function()
	CloseBtn.BackgroundColor3 = ERROR_RED
	CloseBtn.TextColor3 = Color3.new(1,1,1)
end)

CloseBtn.MouseLeave:Connect(function()
	CloseBtn.BackgroundColor3 = BUTTON_BG
	CloseBtn.TextColor3 = TEXT_SUB
end)

CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- Dragging
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
		if input.UserInputType == Enum.UserInputType.MouseButton1 or
			input.UserInputType == Enum.UserInputType.Touch then
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

	TitleBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or
			input.UserInputType == Enum.UserInputType.Touch then
			if dragging then
				update(input)
			end
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging then
			if input.UserInputType == Enum.UserInputType.MouseMovement or
				input.UserInputType == Enum.UserInputType.Touch then
				update(input)
			end
		end
	end)
end

--=========================================================
-- CONTENT AREA: SIDEBAR + PANELS
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
	scroll.ScrollBarThickness = 8
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

local TargetScroll = createScrollablePanel()
local AimbotScroll = createScrollablePanel()
local ESPScroll    = createScrollablePanel()

TargetScroll.Visible = true
AimbotScroll.Visible = false
ESPScroll.Visible    = false

local function createTabButton(text)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -4, 0, 34)
	btn.BackgroundColor3 = BUTTON_BG
	btn.TextColor3 = TEXT_MAIN
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

local TargetTab = createTabButton("Targeting")
local AimbotTab = createTabButton("Aimbot")
local ESPTab    = createTabButton("ESP")

local function setTab(active)
	TargetScroll.Visible = (active == "Target")
	AimbotScroll.Visible = (active == "Aimbot")
	ESPScroll.Visible    = (active == "ESP")

	local function style(btn, on)
		btn.BackgroundColor3 = on and BUTTON_BG_STRONG or BUTTON_BG
		btn.TextColor3 = on and TEXT_MAIN or TEXT_SUB
	end

	style(TargetTab, active == "Target")
	style(AimbotTab, active == "Aimbot")
	style(ESPTab,    active == "ESP")
end

TargetTab.MouseButton1Click:Connect(function() setTab("Target") end)
AimbotTab.MouseButton1Click:Connect(function() setTab("Aimbot") end)
ESPTab.MouseButton1Click:Connect(function() setTab("ESP") end)

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
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local rel = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
			updateValue(minVal + rel * (maxVal - minVal))
		end
	end)

	updateValue(default)
	return frame
end

--=========================================================
-- ESP / AIMBOT STATE
--=========================================================
local selectedPlayer   = nil
local targetMode       = "All" -- "PerPlayer", "All", "Enemies"

local ESP_Enabled           = true
local ESP_TeamColor         = true
local ESP_FillTransparency  = 0.6
local ESP_MaxDistance       = 2000

local ESP_HighlightsFolder = Instance.new("Folder")
ESP_HighlightsFolder.Name  = "VRO_ESP_Highlights"
ESP_HighlightsFolder.Parent = ScreenGui

local Aimbot_Enabled            = true
local Aimbot_ToggleKey          = Enum.KeyCode.E
local Aimbot_WallCheck          = true
local Aimbot_TeamCheck          = true
local Aimbot_Prediction         = true
local Aimbot_PredictionStrength = 0.12
local Aimbot_Sensitivity        = 0.18
local Aimbot_FOVRadius          = 250
local Aimbot_ShowFOV            = true
local Aimbot_On                 = false

local FOVCircleGui          = Instance.new("Frame")
FOVCircleGui.Name           = "VRO_FOV"
FOVCircleGui.Size           = UDim2.new(0, Aimbot_FOVRadius * 2, 0, Aimbot_FOVRadius * 2)
FOVCircleGui.AnchorPoint    = Vector2.new(0.5, 0.5)
FOVCircleGui.Position       = UDim2.new(0.5, 0, 0.5, 0)
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

--=========================================================
-- TARGETING TAB UI (PLAYER DROPDOWN, MODE)
--=========================================================
createHeader(TargetScroll, "PLAYER TARGETING", "Modes and per-player selection")

local ModeFrame = Instance.new("Frame")
ModeFrame.Size = UDim2.new(1, 0, 0, 90)
ModeFrame.BackgroundColor3 = PANEL_BG
ModeFrame.BorderSizePixel = 0
ModeFrame.ZIndex = 9
ModeFrame.Parent = TargetScroll

local ModeCorner = Instance.new("UICorner")
ModeCorner.CornerRadius = UDim.new(0, 10)
ModeCorner.Parent = ModeFrame

local ModeStroke = Instance.new("UIStroke")
ModeStroke.Color = Color3.fromRGB(60, 60, 80)
ModeStroke.Thickness = 1.2
ModeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ModeStroke.Parent = ModeFrame

local ModeTitle = Instance.new("TextLabel")
ModeTitle.Size = UDim2.new(1, -140, 0, 26)
ModeTitle.Position = UDim2.new(0, 10, 0, 6)
ModeTitle.BackgroundTransparency = 1
ModeTitle.Text = "Target Mode"
ModeTitle.TextColor3 = TEXT_MAIN
ModeTitle.TextScaled = true
ModeTitle.Font = Enum.Font.GothamSemibold
ModeTitle.TextXAlignment = Enum.TextXAlignment.Left
ModeTitle.ZIndex = 9
ModeTitle.Parent = ModeFrame

local ModeHint = Instance.new("TextLabel")
ModeHint.Size = UDim2.new(1, -140, 0, 20)
ModeHint.Position = UDim2.new(0, 10, 0, 32)
ModeHint.BackgroundTransparency = 1
ModeHint.Text = "All (nearest), Enemies, or fixed Per-player"
ModeHint.TextColor3 = TEXT_DIM
ModeHint.TextScaled = true
ModeHint.Font = Enum.Font.Gotham
ModeHint.TextXAlignment = Enum.TextXAlignment.Left
ModeHint.ZIndex = 9
ModeHint.Parent = ModeFrame

local modeAllBtn = Instance.new("TextButton")
modeAllBtn.Size = UDim2.new(0, 64, 0, 26)
modeAllBtn.Position = UDim2.new(0, 10, 0, 60)
modeAllBtn.BackgroundColor3 = BUTTON_BG_STRONG
modeAllBtn.TextColor3 = TEXT_MAIN
modeAllBtn.TextScaled = true
modeAllBtn.Font = Enum.Font.GothamSemibold
modeAllBtn.BorderSizePixel = 0
modeAllBtn.Text = "All"
modeAllBtn.ZIndex = 9
modeAllBtn.Parent = ModeFrame

local modeAllCorner = Instance.new("UICorner")
modeAllCorner.CornerRadius = UDim.new(0, 8)
modeAllCorner.Parent = modeAllBtn

local modeEnemiesBtn = Instance.new("TextButton")
modeEnemiesBtn.Size = UDim2.new(0, 96, 0, 26)
modeEnemiesBtn.Position = UDim2.new(0, 84, 0, 60)
modeEnemiesBtn.BackgroundColor3 = BUTTON_BG
modeEnemiesBtn.TextColor3 = TEXT_MAIN
modeEnemiesBtn.TextScaled = true
modeEnemiesBtn.Font = Enum.Font.GothamSemibold
modeEnemiesBtn.BorderSizePixel = 0
modeEnemiesBtn.Text = "Enemies"
modeEnemiesBtn.ZIndex = 9
modeEnemiesBtn.Parent = ModeFrame

local modeEnemiesCorner = Instance.new("UICorner")
modeEnemiesCorner.CornerRadius = UDim.new(0, 8)
modeEnemiesCorner.Parent = modeEnemiesBtn

local function updateModeButtons()
	if targetMode == "All" then
		modeAllBtn.BackgroundColor3 = BUTTON_BG_STRONG
		modeEnemiesBtn.BackgroundColor3 = BUTTON_BG
	elseif targetMode == "Enemies" then
		modeEnemiesBtn.BackgroundColor3 = BUTTON_BG_STRONG
		modeAllBtn.BackgroundColor3 = BUTTON_BG
	else
		modeAllBtn.BackgroundColor3 = BUTTON_BG
		modeEnemiesBtn.BackgroundColor3 = BUTTON_BG
	end
end

modeAllBtn.MouseButton1Click:Connect(function()
	targetMode = "All"
	selectedPlayer = nil
	updateModeButtons()
	notify("Target mode: All (nearest)", ACCENT_RED)
end)

modeEnemiesBtn.MouseButton1Click:Connect(function()
	targetMode = "Enemies"
	selectedPlayer = nil
	updateModeButtons()
	notify("Target mode: Enemies (nearest)", ACCENT_RED)
end)

updateModeButtons()

-- PER-PLAYER DROPDOWN (NON-OVERLAPPING)
local PlayerDropdownFrame = Instance.new("Frame")
PlayerDropdownFrame.Size = UDim2.new(1, 0, 0, 110)
PlayerDropdownFrame.BackgroundColor3 = PANEL_BG
PlayerDropdownFrame.BorderSizePixel = 0
PlayerDropdownFrame.ZIndex = 9
PlayerDropdownFrame.Parent = TargetScroll

local PlayerDropdownCorner = Instance.new("UICorner")
PlayerDropdownCorner.CornerRadius = UDim.new(0, 10)
PlayerDropdownCorner.Parent = PlayerDropdownFrame

local PlayerDropdownStroke = Instance.new("UIStroke")
PlayerDropdownStroke.Color = Color3.fromRGB(60, 60, 80)
PlayerDropdownStroke.Thickness = 1.2
PlayerDropdownStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
PlayerDropdownStroke.Parent = PlayerDropdownFrame

local PlayerLabel = Instance.new("TextLabel")
PlayerLabel.Size = UDim2.new(1, -130, 0, 26)
PlayerLabel.Position = UDim2.new(0, 10, 0, 6)
PlayerLabel.BackgroundTransparency = 1
PlayerLabel.Text = "Per-player Selection"
PlayerLabel.TextColor3 = TEXT_MAIN
PlayerLabel.TextScaled = true
PlayerLabel.Font = Enum.Font.GothamSemibold
PlayerLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayerLabel.ZIndex = 9
PlayerLabel.Parent = PlayerDropdownFrame

local PlayerHintLabel = Instance.new("TextLabel")
PlayerHintLabel.Size = UDim2.new(1, -130, 0, 22)
PlayerHintLabel.Position = UDim2.new(0, 10, 0, 32)
PlayerHintLabel.BackgroundTransparency = 1
PlayerHintLabel.Text = "Tap a player to lock to them (mode switches to Per-player)"
PlayerHintLabel.TextColor3 = TEXT_DIM
PlayerHintLabel.TextScaled = true
PlayerHintLabel.Font = Enum.Font.Gotham
PlayerHintLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayerHintLabel.ZIndex = 9
PlayerHintLabel.Parent = PlayerDropdownFrame

local DropdownButton = Instance.new("TextButton")
DropdownButton.Size = UDim2.new(0, 190, 0, 34)
DropdownButton.Position = UDim2.new(1, -200, 0, 10)
DropdownButton.BackgroundColor3 = BUTTON_BG
DropdownButton.Text = ""
DropdownButton.AutoButtonColor = false
DropdownButton.BorderSizePixel = 0
DropdownButton.ZIndex = 20
DropdownButton.Parent = PlayerDropdownFrame

local DropdownCorner = Instance.new("UICorner")
DropdownCorner.CornerRadius = UDim.new(1, 0)
DropdownCorner.Parent = DropdownButton

local DropdownStroke = Instance.new("UIStroke")
DropdownStroke.Color = Color3.fromRGB(70, 70, 90)
DropdownStroke.Thickness = 1.4
DropdownStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
DropdownStroke.Parent = DropdownButton

local DropdownLabel = Instance.new("TextLabel")
DropdownLabel.Size = UDim2.new(1, -28, 1, 0)
DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
DropdownLabel.BackgroundTransparency = 1
DropdownLabel.Text = "Per-player: None"
DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
DropdownLabel.TextColor3 = TEXT_SUB
DropdownLabel.TextScaled = true
DropdownLabel.Font = Enum.Font.GothamSemibold
DropdownLabel.ZIndex = 21
DropdownLabel.Parent = DropdownButton

local DropdownArrow = Instance.new("TextLabel")
DropdownArrow.Size = UDim2.new(0, 18, 1, 0)
DropdownArrow.Position = UDim2.new(1, -20, 0, 0)
DropdownArrow.BackgroundTransparency = 1
DropdownArrow.Text = "▼"
DropdownArrow.TextColor3 = TEXT_SUB
DropdownArrow.TextScaled = true
DropdownArrow.Font = Enum.Font.GothamBold
DropdownArrow.ZIndex = 21
DropdownArrow.Parent = DropdownButton

local DropdownOpen = false

local DropdownListFrame = Instance.new("Frame")
DropdownListFrame.Size = UDim2.new(0, 210, 0, 0)
DropdownListFrame.Position = UDim2.new(1, -200, 0, 50)
DropdownListFrame.BackgroundColor3 = DARKEST
DropdownListFrame.BorderSizePixel = 0
DropdownListFrame.Visible = false
DropdownListFrame.ZIndex = 25
DropdownListFrame.Parent = PlayerDropdownFrame

local DropdownListCorner = Instance.new("UICorner")
DropdownListCorner.CornerRadius = UDim.new(0, 10)
DropdownListCorner.Parent = DropdownListFrame

local DropdownListStroke = Instance.new("UIStroke")
DropdownListStroke.Color = Color3.fromRGB(70, 70, 90)
DropdownListStroke.Thickness = 1.4
DropdownListStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
DropdownListStroke.Parent = DropdownListFrame

local DropdownListScroll = Instance.new("ScrollingFrame")
DropdownListScroll.Size = UDim2.new(1, 0, 1, 0)
DropdownListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
DropdownListScroll.ScrollBarThickness = 6
DropdownListScroll.ScrollBarImageColor3 = ACCENT_RED
DropdownListScroll.BackgroundTransparency = 1
DropdownListScroll.BorderSizePixel = 0
DropdownListScroll.ZIndex = 26
DropdownListScroll.Parent = DropdownListFrame

local DropdownListLayout = Instance.new("UIListLayout")
DropdownListLayout.Padding = UDim.new(0, 3)
DropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder
DropdownListLayout.Parent = DropdownListScroll

local DropdownListPadding = Instance.new("UIPadding")
DropdownListPadding.PaddingTop = UDim.new(0, 4)
DropdownListPadding.PaddingLeft = UDim.new(0, 4)
DropdownListPadding.PaddingRight = UDim.new(0, 4)
DropdownListPadding.PaddingBottom = UDim.new(0, 4)
DropdownListPadding.Parent = DropdownListScroll

local function rebuildPlayerDropdown()
	for _, child in ipairs(DropdownListScroll:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			local option = Instance.new("TextButton")
			option.Size = UDim2.new(1, 0, 0, 28)
			option.BackgroundColor3 = BUTTON_BG
			option.TextColor3 = TEXT_MAIN
			option.TextScaled = true
			option.TextXAlignment = Enum.TextXAlignment.Left
			option.Text = plr.Name
			option.Font = Enum.Font.Gotham
			option.AutoButtonColor = false
			option.BorderSizePixel = 0
			option.ZIndex = 26
			option.Parent = DropdownListScroll

			local optCorner = Instance.new("UICorner")
			optCorner.CornerRadius = UDim.new(0, 8)
			optCorner.Parent = option

			option.MouseEnter:Connect(function()
				option.BackgroundColor3 = HOVER_BG
			end)

			option.MouseLeave:Connect(function()
				option.BackgroundColor3 = BUTTON_BG
			end)

			option.MouseButton1Click:Connect(function()
				selectedPlayer = plr
				targetMode = "PerPlayer"
				updateModeButtons()
				DropdownLabel.Text = "Per-player: " .. plr.Name
				DropdownLabel.TextColor3 = ACCENT_RED
				notify("Selected player: " .. plr.Name, ACCENT_RED)
				DropdownOpen = false
				DropdownListFrame.Visible = false
			end)
		end
	end

	local contentHeight = DropdownListLayout.AbsoluteContentSize.Y
	local finalHeight = math.clamp(contentHeight + 8, 0, 180)
	DropdownListScroll.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 4)
	DropdownListFrame.Size = UDim2.new(0, 210, 0, finalHeight)
end

Players.PlayerAdded:Connect(rebuildPlayerDropdown)
Players.PlayerRemoving:Connect(function(plr)
	if plr == selectedPlayer then
		selectedPlayer = nil
		DropdownLabel.Text = "Per-player: None"
		DropdownLabel.TextColor3 = TEXT_SUB
	end
	rebuildPlayerDropdown()
end)

DropdownButton.MouseButton1Click:Connect(function()
	DropdownOpen = not DropdownOpen
	if DropdownOpen then
		rebuildPlayerDropdown()
		DropdownListFrame.Visible = true
	else
		DropdownListFrame.Visible = false
	end
end)

--=========================================================
-- AIMBOT TAB UI
--=========================================================
createHeader(AimbotScroll, "AIM ASSIST", "Toggle, prediction, and smoothness")

createToggle(
	AimbotScroll,
	"Aimbot Enabled",
	"Global toggle for aim assist (key: E)",
	Aimbot_Enabled,
	function(state)
		Aimbot_Enabled = state
		Aimbot_On = false
		if state then
			notify("Aimbot armed (press E to toggle)", ACCENT_RED)
		else
			notify("Aimbot disabled", ACCENT_RED)
		end
	end
)

createToggle(
	AimbotScroll,
	"Wall Check",
	"Only lock when line of sight is clear",
	Aimbot_WallCheck,
	function(state) Aimbot_WallCheck = state end
)

createToggle(
	AimbotScroll,
	"Team Check",
	"Skip targets on your team",
	Aimbot_TeamCheck,
	function(state) Aimbot_TeamCheck = state end
)

createToggle(
	AimbotScroll,
	"Prediction",
	"Lead moving targets based on velocity",
	Aimbot_Prediction,
	function(state) Aimbot_Prediction = state end
)

createSlider(
	AimbotScroll,
	"Prediction Strength",
	0,
	0.5,
	Aimbot_PredictionStrength,
	function(v)
		Aimbot_PredictionStrength = v
	end,
	"Higher = more aggressive leading"
)

createSlider(
	AimbotScroll,
	"Aim Smoothness",
	0.02,
	0.5,
	Aimbot_Sensitivity,
	function(v)
		Aimbot_Sensitivity = v
	end,
	"Lower = snappier, higher = smoother"
)

createSlider(
	AimbotScroll,
	"FOV Radius",
	40,
	600,
	Aimbot_FOVRadius,
	function(v)
		Aimbot_FOVRadius = v
		FOVCircleGui.Size = UDim2.new(0, Aimbot_FOVRadius * 2, 0, Aimbot_FOVRadius * 2)
	end,
	"Max distance from cursor for locking"
)

createToggle(
	AimbotScroll,
	"Show FOV Circle",
	"Draw the circle used for target selection",
	Aimbot_ShowFOV,
	function(state)
		Aimbot_ShowFOV = state
		FOVCircleGui.Visible = state
	end
)

--=========================================================
-- ESP TAB UI
--=========================================================
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
	"Tint highlight using player team color",
	ESP_TeamColor,
	function(state)
		ESP_TeamColor = state
	end
)

createSlider(
	ESPScroll,
	"ESP Max Distance",
	50,
	5000,
	ESP_MaxDistance,
	function(v)
		ESP_MaxDistance = v
	end,
	"Only players closer than this are highlighted"
)

createSlider(
	ESPScroll,
	"Fill Transparency",
	0.1,
	0.9,
	ESP_FillTransparency,
	function(v)
		ESP_FillTransparency = v
	end,
	"Lower = more solid highlight"
)

--=========================================================
-- CORE LOGIC: HELPERS + RENDERSTEP
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

local function getBestTargetPos()
	local myChar = player.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return nil end

	local mousePos = UserInputService:GetMouseLocation()
	local bestPos = nil
	local smallestDist = Aimbot_FOVRadius

	local function consider(plr)
		if plr == player then return end
		if Aimbot_TeamCheck and sameTeam(player, plr) then
			return
		end
		local char = plr.Character
		local head = char and getHead(char)
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not head or not root then return end

		local aimPos = predictedPosition(head, root)
		if not aimPos then return end

		if Aimbot_WallCheck then
			if not visible(myRoot.Position, aimPos, {myChar, char}) then
				return
			end
		end

		local screenPos, onScreen = camera:WorldToViewportPoint(aimPos)
		if not onScreen or screenPos.Z <= 0 then
			return
		end

		local dist2D = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
		if dist2D <= smallestDist then
			smallestDist = dist2D
			bestPos = aimPos
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

	return bestPos
end

RunService.RenderStepped:Connect(function()
	local myChar = player.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

	-- ESP
	if not ESP_Enabled or not myRoot then
		for _, h in ipairs(ESP_HighlightsFolder:GetChildren()) do
			h.Enabled = false
		end
	else
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				local root = plr.Character:FindFirstChild("HumanoidRootPart")
				local hum = plr.Character:FindFirstChildOfClass("Humanoid")
				if root and hum and hum.Health > 0 then
					local dist = getDistance(myRoot.Position, root.Position)
					local h = getOrCreateHighlight(plr)
					if dist <= ESP_MaxDistance then
						h.Enabled = true
						h.Adornee = plr.Character
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
					local h = ESP_HighlightsFolder:FindFirstChild(plr.Name)
					if h then
						h.Enabled = false
					end
				end
			end
		end
	end

	-- FOV circle follows cursor
	if Aimbot_ShowFOV then
		local mousePos = UserInputService:GetMouseLocation()
		FOVCircleGui.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
	end

	-- Aimbot
	if Aimbot_Enabled and Aimbot_On then
		local aimPos = getBestTargetPos()
		if aimPos then
			local currentCF = camera.CFrame
			local targetCF = CFrame.new(currentCF.Position, aimPos)
			camera.CFrame = currentCF:Lerp(targetCF, Aimbot_Sensitivity)
		end
	end
end)

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Aimbot_ToggleKey and Aimbot_Enabled then
		Aimbot_On = not Aimbot_On
		if Aimbot_On then
			notify("Aimbot: ON", ACCENT_RED)
		else
			notify("Aimbot: OFF", ACCENT_RED)
		end
	end
end)

notify("VRO Aim Suite loaded", ACCENT_RED_SOFT)
