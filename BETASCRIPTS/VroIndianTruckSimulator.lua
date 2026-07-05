--// VRO Indian Truck Simulator - Auto Win Suite

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--====================================================
-- CONFIG
--====================================================
local config = {
	TargetPartName = "Win Part",
	AutoReturnDistance = 100,
	TeleportHeightOffset = 4,
	TeleportTweenTime = 1.15,
	AutoReturnEnabled = true,
}

--====================================================
-- STATE
--====================================================
local state = {
	teleportActive = false,
	teleportInProgress = false,
	uiMinimized = false,
	currentPage = "Home",
	switchingPage = false,
	guardCooldownUntil = 0,
}

--====================================================
-- HELPERS
--====================================================
local function now()
	return time()
end

local function clampNumber(v, minV, maxV, fallback)
	v = tonumber(v)
	if not v then
		return fallback
	end
	if minV and v < minV then
		return minV
	end
	if maxV and v > maxV then
		return maxV
	end
	return v
end

local function getCharacter()
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid", 10)
	local hrp = char:WaitForChild("HumanoidRootPart", 10)
	return char, hum, hrp
end

local function resolveTargetPart()
	local target = workspace:FindFirstChild(config.TargetPartName, true)
	if not target then
		return nil
	end

	if target:IsA("BasePart") then
		return target
	end

	if target:IsA("Model") then
		if target.PrimaryPart and target.PrimaryPart:IsA("BasePart") then
			return target.PrimaryPart
		end
		return target:FindFirstChildWhichIsA("BasePart", true)
	end

	return nil
end

local function resolveStageOne()
	local stages = workspace:FindFirstChild("Stages")
	if not stages then
		return nil
	end
	return stages:FindFirstChild("1")
end

local function resolveSpawnLocation()
	return workspace:FindFirstChild("SpawnLocation", true)
end

local function distanceToPart(part, hrp)
	if not part or not hrp then
		return math.huge
	end
	return (part.Position - hrp.Position).Magnitude
end

local function makeCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	return c
end

local function makeStroke(parent, color, transparency, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.fromRGB(110, 20, 20)
	s.Transparency = transparency or 0.2
	s.Thickness = thickness or 1
	s.Parent = parent
	return s
end

local function makeGradient(parent, rotation, c1, c2)
	local g = Instance.new("UIGradient")
	g.Rotation = rotation or 0
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, c1 or Color3.fromRGB(30, 12, 12)),
		ColorSequenceKeypoint.new(1, c2 or Color3.fromRGB(16, 16, 18)),
	})
	g.Parent = parent
	return g
end

local function animateButton(button, baseColor, hoverColor, strokeColor)
	button.AutoButtonColor = false
	button.BackgroundColor3 = baseColor
	button.BorderSizePixel = 0
	button.TextColor3 = Color3.fromRGB(245, 245, 245)
	button.Font = Enum.Font.GothamSemibold

	local stroke = makeStroke(button, strokeColor or Color3.fromRGB(110, 20, 20), 0.28, 1)

	local normalSize = button.Size
	local pressedSize = UDim2.new(normalSize.X.Scale, math.max(0, normalSize.X.Offset - 1), normalSize.Y.Scale, math.max(0, normalSize.Y.Offset - 1))

	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = hoverColor
		}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Color = strokeColor or Color3.fromRGB(235, 70, 70),
			Transparency = 0.06
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = baseColor
		}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Color = Color3.fromRGB(110, 20, 20),
			Transparency = 0.28
		}):Play()
	end)

	button.MouseButton1Down:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = pressedSize
		}):Play()
	end)

	button.MouseButton1Up:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = normalSize
		}):Play()
	end)

	return stroke
end

local function createLabel(parent, text, size, color, bold)
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = size or UDim2.new(1, 0, 0, 18)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextYAlignment = Enum.TextYAlignment.Center
	lbl.TextWrapped = false
	lbl.Text = text or ""
	lbl.Font = bold and Enum.Font.GothamBold or Enum.Font.GothamMedium
	lbl.TextSize = 12
	lbl.TextColor3 = color or Color3.fromRGB(210, 210, 214)
	lbl.Parent = parent
	return lbl
end

local function createCard(parent, height, titleText, descText)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, height)
	card.BackgroundColor3 = Color3.fromRGB(26, 26, 29)
	card.BorderSizePixel = 0
	card.Parent = parent
	makeCorner(card, 16)
	makeStroke(card, Color3.fromRGB(90, 22, 22), 0.22, 1)
	makeGradient(card, 90, Color3.fromRGB(34, 18, 18), Color3.fromRGB(22, 22, 26))

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 12)
	pad.PaddingLeft = UDim.new(0, 12)
	pad.PaddingRight = UDim.new(0, 12)
	pad.PaddingBottom = UDim.new(0, 12)
	pad.Parent = card

	local title = createLabel(card, titleText, UDim2.new(1, 0, 0, 20), Color3.fromRGB(255, 236, 236), true)
	title.TextSize = 15
	title.Position = UDim2.new(0, 0, 0, 0)

	local desc = createLabel(card, descText or "", UDim2.new(1, 0, 0, math.max(18, height - 48)), Color3.fromRGB(200, 200, 205), false)
	desc.TextWrapped = true
	desc.TextYAlignment = Enum.TextYAlignment.Top
	desc.Position = UDim2.new(0, 0, 0, 24)
	desc.TextSize = 12

	return card, title, desc
end

local function createInput(parent, placeholder, defaultText)
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, 0, 0, 38)
	box.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
	box.BorderSizePixel = 0
	box.Text = defaultText or ""
	box.PlaceholderText = placeholder or ""
	box.PlaceholderColor3 = Color3.fromRGB(125, 125, 130)
	box.ClearTextOnFocus = false
	box.TextColor3 = Color3.fromRGB(245, 245, 245)
	box.Font = Enum.Font.GothamSemibold
	box.TextSize = 13
	box.Parent = parent
	makeCorner(box, 12)
	makeStroke(box, Color3.fromRGB(90, 22, 22), 0.28, 1)

	box.Focused:Connect(function()
		TweenService:Create(box, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(28, 18, 18)
		}):Play()
	end)

	box.FocusLost:Connect(function()
		TweenService:Create(box, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(20, 20, 23)
		}):Play()
	end)

	return box
end

local function createTab(parent, iconText, labelText, order)
	local tab = Instance.new("TextButton")
	tab.Size = UDim2.new(1, -16, 0, 42)
	tab.LayoutOrder = order or 1
	tab.Text = iconText .. "  " .. labelText
	tab.TextXAlignment = Enum.TextXAlignment.Left
	tab.TextSize = 13
	tab.Font = Enum.Font.GothamSemibold
	tab.TextColor3 = Color3.fromRGB(240, 240, 240)
	tab.BackgroundColor3 = Color3.fromRGB(29, 29, 32)
	tab.BorderSizePixel = 0
	tab.Parent = parent
	makeCorner(tab, 12)

	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0, 3, 0, 18)
	indicator.Position = UDim2.new(0, 8, 0.5, -9)
	indicator.BackgroundColor3 = Color3.fromRGB(235, 60, 60)
	indicator.BorderSizePixel = 0
	indicator.Parent = tab
	makeCorner(indicator, 3)

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 18)
	pad.Parent = tab

	animateButton(tab, Color3.fromRGB(29, 29, 32), Color3.fromRGB(46, 22, 22), Color3.fromRGB(220, 60, 60))
	return tab, indicator
end

local function setTextWithColor(label, text, color)
	label.Text = text
	if color then
		label.TextColor3 = color
	end
end

--====================================================
-- GUI ROOT
--====================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VRO_IndianTruckSimulator_AssistSuite"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 9999
screenGui.Parent = playerGui

local backdrop = Instance.new("Frame")
backdrop.Size = UDim2.new(1, 0, 1, 0)
backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
backdrop.BackgroundTransparency = 1
backdrop.BorderSizePixel = 0
backdrop.Parent = screenGui

local blur = Lighting:FindFirstChild("VRO_AssistSuite_Blur")
if not blur then
	blur = Instance.new("BlurEffect")
	blur.Name = "VRO_AssistSuite_Blur"
	blur.Size = 0
	blur.Parent = Lighting
end

local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(0, 632, 0, 402)
shadow.Position = UDim2.new(0.5, -316, 0.5, -201)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.42
shadow.BorderSizePixel = 0
shadow.Parent = screenGui
makeCorner(shadow, 18)

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 620, 0, 390)
main.Position = UDim2.new(0.5, -310, 0.5, -195)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = screenGui
makeCorner(main, 18)
makeStroke(main, Color3.fromRGB(120, 25, 25), 0.12, 1)
makeGradient(main, 0, Color3.fromRGB(35, 12, 12), Color3.fromRGB(14, 14, 16))

local topbar = Instance.new("Frame")
topbar.Size = UDim2.new(1, 0, 0, 46)
topbar.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
topbar.BorderSizePixel = 0
topbar.Parent = main
makeCorner(topbar, 18)
makeGradient(topbar, 0, Color3.fromRGB(96, 18, 18), Color3.fromRGB(28, 28, 32))

local topbarCover = Instance.new("Frame")
topbarCover.Size = UDim2.new(1, 0, 0, 18)
topbarCover.Position = UDim2.new(0, 0, 1, -18)
topbarCover.BackgroundColor3 = topbar.BackgroundColor3
topbarCover.BorderSizePixel = 0
topbarCover.Parent = topbar

local title = createLabel(topbar, "VRO Indian Truck Simulator", UDim2.new(1, -200, 0, 18), Color3.fromRGB(255, 240, 240), true)
title.Position = UDim2.new(0, 16, 0, 6)
title.TextSize = 16

local subtitle = createLabel(topbar, "Assist Suite", UDim2.new(1, -200, 0, 16), Color3.fromRGB(215, 150, 150), false)
subtitle.Position = UDim2.new(0, 16, 0, 24)
subtitle.TextSize = 11

local statusPill = Instance.new("Frame")
statusPill.Size = UDim2.new(0, 118, 0, 26)
statusPill.Position = UDim2.new(1, -190, 0, 10)
statusPill.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
statusPill.BorderSizePixel = 0
statusPill.Parent = topbar
makeCorner(statusPill, 13)
makeStroke(statusPill, Color3.fromRGB(110, 20, 20), 0.28, 1)

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 10, 0, 10)
statusDot.Position = UDim2.new(0, 10, 0.5, -5)
statusDot.BackgroundColor3 = Color3.fromRGB(120, 220, 120)
statusDot.BorderSizePixel = 0
statusDot.Parent = statusPill
makeCorner(statusDot, 5)

local statusText = createLabel(statusPill, "READY", UDim2.new(1, -26, 1, 0), Color3.fromRGB(245, 245, 245), true)
statusText.Position = UDim2.new(0, 26, 0, 0)
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.TextSize = 11

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 34, 0, 24)
minimizeBtn.Position = UDim2.new(1, -62, 0, 11)
minimizeBtn.Text = "–"
minimizeBtn.TextSize = 18
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextColor3 = Color3.fromRGB(255, 245, 245)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(46, 18, 18)
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = topbar
makeCorner(minimizeBtn, 8)
animateButton(minimizeBtn, Color3.fromRGB(46, 18, 18), Color3.fromRGB(68, 24, 24), Color3.fromRGB(235, 60, 60))

local rail = Instance.new("Frame")
rail.Size = UDim2.new(0, 148, 1, -46)
rail.Position = UDim2.new(0, 0, 0, 46)
rail.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
rail.BorderSizePixel = 0
rail.Parent = main
makeStroke(rail, Color3.fromRGB(80, 20, 20), 0.25, 1)
makeGradient(rail, 90, Color3.fromRGB(26, 14, 14), Color3.fromRGB(18, 18, 22))

local railPad = Instance.new("UIPadding")
railPad.PaddingTop = UDim.new(0, 14)
railPad.PaddingLeft = UDim.new(0, 10)
railPad.PaddingRight = UDim.new(0, 10)
railPad.Parent = rail

local railList = Instance.new("UIListLayout")
railList.Padding = UDim.new(0, 10)
railList.SortOrder = Enum.SortOrder.LayoutOrder
railList.Parent = rail

local contentHost = Instance.new("Frame")
contentHost.Size = UDim2.new(1, -148, 1, -46)
contentHost.Position = UDim2.new(0, 148, 0, 46)
contentHost.BackgroundTransparency = 1
contentHost.BorderSizePixel = 0
contentHost.Parent = main

local contentPad = Instance.new("UIPadding")
contentPad.PaddingTop = UDim.new(0, 14)
contentPad.PaddingLeft = UDim.new(0, 14)
contentPad.PaddingRight = UDim.new(0, 14)
contentPad.PaddingBottom = UDim.new(0, 14)
contentPad.Parent = contentHost

local pageHost = Instance.new("Frame")
pageHost.Size = UDim2.new(1, 0, 1, 0)
pageHost.BackgroundTransparency = 1
pageHost.BorderSizePixel = 0
pageHost.ClipsDescendants = true
pageHost.Parent = contentHost

local pages = {}
local tabButtons = {}

local function createPage(name)
	local page = Instance.new("ScrollingFrame")
	page.Name = name
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.Visible = false
	page.ScrollBarThickness = 4
	page.ScrollBarImageColor3 = Color3.fromRGB(180, 60, 60)
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Parent = pageHost

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 12)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = page

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 2)
	pad.PaddingLeft = UDim.new(0, 2)
	pad.PaddingRight = UDim.new(0, 2)
	pad.PaddingBottom = UDim.new(0, 12)
	pad.Parent = page

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
	end)

	return page
end

local homePage = createPage("Home")
local teleportPage = createPage("Teleport")
local settingsPage = createPage("Settings")

local function createTabSafe(iconText, labelText, order)
	local tab = Instance.new("TextButton")
	tab.Size = UDim2.new(1, -16, 0, 42)
	tab.LayoutOrder = order or 1
	tab.Text = iconText .. "  " .. labelText
	tab.TextXAlignment = Enum.TextXAlignment.Left
	tab.TextSize = 13
	tab.Font = Enum.Font.GothamSemibold
	tab.TextColor3 = Color3.fromRGB(240, 240, 240)
	tab.BackgroundColor3 = Color3.fromRGB(29, 29, 32)
	tab.BorderSizePixel = 0
	tab.Parent = rail
	makeCorner(tab, 12)

	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0, 3, 0, 18)
	indicator.Position = UDim2.new(0, 8, 0.5, -9)
	indicator.BackgroundColor3 = Color3.fromRGB(235, 60, 60)
	indicator.BorderSizePixel = 0
	indicator.Parent = tab
	makeCorner(indicator, 3)

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 18)
	pad.Parent = tab

	animateButton(tab, Color3.fromRGB(29, 29, 32), Color3.fromRGB(46, 22, 22), Color3.fromRGB(220, 60, 60))
	return tab, indicator
end

local tabHome, indHome = createTabSafe("⌂", "Home", 1)
local tabTeleport, indTeleport = createTabSafe("↯", "Teleport", 2)
local tabSettings, indSettings = createTabSafe("⚙", "Settings", 3)

tabButtons.Home = {button = tabHome, indicator = indHome}
tabButtons.Teleport = {button = tabTeleport, indicator = indTeleport}
tabButtons.Settings = {button = tabSettings, indicator = indSettings}

local function updateTabs()
	for name, data in pairs(tabButtons) do
		local active = (state.currentPage == name)
		TweenService:Create(data.button, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = active and Color3.fromRGB(58, 18, 18) or Color3.fromRGB(29, 29, 32)
		}):Play()
		TweenService:Create(data.indicator, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = active and UDim2.new(0, 4, 0, 22) or UDim2.new(0, 3, 0, 18),
			BackgroundColor3 = active and Color3.fromRGB(255, 86, 86) or Color3.fromRGB(235, 60, 60)
		}):Play()
	end
end

local function setPage(name)
	if state.switchingPage or state.currentPage == name then
		return
	end

	state.switchingPage = true

	local current = pages[state.currentPage]
	local nextPage = pages[name]

	if not nextPage then
		state.switchingPage = false
		return
	end

	if current then
		nextPage.Visible = true
		nextPage.Position = UDim2.new(1, 18, 0, 0)

		local outTween = TweenService:Create(current, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.new(-1, -18, 0, 0)
		})
		local inTween = TweenService:Create(nextPage, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, 0, 0, 0)
		})

		outTween:Play()
		inTween:Play()
		inTween.Completed:Wait()

		current.Visible = false
		current.Position = UDim2.new(0, 0, 0, 0)
	else
		nextPage.Visible = true
		nextPage.Position = UDim2.new(0, 0, 0, 0)
	end

	state.currentPage = name
	updateTabs()
	state.switchingPage = false
end

pages.Home = homePage
pages.Teleport = teleportPage
pages.Settings = settingsPage

--====================================================
-- HOME PAGE
--====================================================
local homeHero = createCard(homePage, 110, "Control Hub", "Polished teleport control with auto-return protection, smooth motion, and an adjustable custom target part.")
local homeReadout = createLabel(homeHero, "Status: Initializing", UDim2.new(1, 0, 0, 18), Color3.fromRGB(120, 220, 120), true)
homeReadout.Position = UDim2.new(0, 0, 1, -22)
homeReadout.TextSize = 12

local homeTargetLine = createLabel(homeHero, "Target: ...", UDim2.new(1, 0, 0, 18), Color3.fromRGB(220, 220, 224), false)
homeTargetLine.Position = UDim2.new(0, 0, 0, 58)
homeTargetLine.TextSize = 11

local homeGuardLine = createLabel(homeHero, "Guard: Enabled", UDim2.new(1, 0, 0, 18), Color3.fromRGB(220, 220, 224), false)
homeGuardLine.Position = UDim2.new(0, 0, 0, 74)
homeGuardLine.TextSize = 11

local homeButtons = Instance.new("Frame")
homeButtons.Size = UDim2.new(1, 0, 0, 42)
homeButtons.BackgroundTransparency = 1
homeButtons.Parent = homePage

local homeButtonsLayout = Instance.new("UIListLayout")
homeButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
homeButtonsLayout.Padding = UDim.new(0, 10)
homeButtonsLayout.Parent = homeButtons

local quickTeleportBtn = Instance.new("TextButton")
quickTeleportBtn.Size = UDim2.new(0.5, -5, 1, 0)
quickTeleportBtn.Text = "↯  Teleport Now"
quickTeleportBtn.TextSize = 14
quickTeleportBtn.TextColor3 = Color3.fromRGB(255, 245, 245)
quickTeleportBtn.Font = Enum.Font.GothamBold
quickTeleportBtn.BackgroundColor3 = Color3.fromRGB(58, 18, 18)
quickTeleportBtn.BorderSizePixel = 0
quickTeleportBtn.Parent = homeButtons
makeCorner(quickTeleportBtn, 12)
animateButton(quickTeleportBtn, Color3.fromRGB(58, 18, 18), Color3.fromRGB(82, 28, 28), Color3.fromRGB(235, 60, 60))

local rescanBtn = Instance.new("TextButton")
rescanBtn.Size = UDim2.new(0.5, -5, 1, 0)
rescanBtn.Text = "⟳  Re-scan Target"
rescanBtn.TextSize = 14
rescanBtn.TextColor3 = Color3.fromRGB(245, 245, 245)
rescanBtn.Font = Enum.Font.GothamBold
rescanBtn.BackgroundColor3 = Color3.fromRGB(27, 27, 31)
rescanBtn.BorderSizePixel = 0
rescanBtn.Parent = homeButtons
makeCorner(rescanBtn, 12)
animateButton(rescanBtn, Color3.fromRGB(27, 27, 31), Color3.fromRGB(44, 22, 22), Color3.fromRGB(235, 60, 60))

local homeStats = Instance.new("Frame")
homeStats.Size = UDim2.new(1, 0, 0, 76)
homeStats.BackgroundTransparency = 1
homeStats.Parent = homePage

local homeStatsLayout = Instance.new("UIListLayout")
homeStatsLayout.FillDirection = Enum.FillDirection.Horizontal
homeStatsLayout.Padding = UDim.new(0, 10)
homeStatsLayout.Parent = homeStats

local statLeft = Instance.new("Frame")
statLeft.Size = UDim2.new(0.5, -5, 1, 0)
statLeft.BackgroundColor3 = Color3.fromRGB(26, 26, 29)
statLeft.BorderSizePixel = 0
statLeft.Parent = homeStats
makeCorner(statLeft, 14)
makeStroke(statLeft, Color3.fromRGB(90, 22, 22), 0.25, 1)

local statRight = Instance.new("Frame")
statRight.Size = UDim2.new(0.5, -5, 1, 0)
statRight.BackgroundColor3 = Color3.fromRGB(26, 26, 29)
statRight.BorderSizePixel = 0
statRight.Parent = homeStats
makeCorner(statRight, 14)
makeStroke(statRight, Color3.fromRGB(90, 22, 22), 0.25, 1)

local statPad1 = Instance.new("UIPadding")
statPad1.PaddingTop = UDim.new(0, 10)
statPad1.PaddingLeft = UDim.new(0, 10)
statPad1.PaddingRight = UDim.new(0, 10)
statPad1.PaddingBottom = UDim.new(0, 10)
statPad1.Parent = statLeft

local statPad2 = Instance.new("UIPadding")
statPad2.PaddingTop = UDim.new(0, 10)
statPad2.PaddingLeft = UDim.new(0, 10)
statPad2.PaddingRight = UDim.new(0, 10)
statPad2.PaddingBottom = UDim.new(0, 10)
statPad2.Parent = statRight

createLabel(statLeft, "Target Part", UDim2.new(1, 0, 0, 18), Color3.fromRGB(255, 235, 235), true)
local statLeftValue = createLabel(statLeft, "Loading...", UDim2.new(1, 0, 0, 18), Color3.fromRGB(220, 220, 224), false)
statLeftValue.Position = UDim2.new(0, 0, 0, 26)
statLeftValue.TextSize = 11

createLabel(statRight, "Auto-Return", UDim2.new(1, 0, 0, 18), Color3.fromRGB(255, 235, 235), true)
local statRightValue = createLabel(statRight, "Enabled", UDim2.new(1, 0, 0, 18), Color3.fromRGB(220, 220, 224), false)
statRightValue.Position = UDim2.new(0, 0, 0, 26)
statRightValue.TextSize = 11

--====================================================
-- TELEPORT PAGE
--====================================================
local teleCard = createCard(teleportPage, 126, "Smooth Teleport", "Moves your character to the assigned part with a tweened pivot path for a cleaner visual effect.")
local teleStatus = createLabel(teleCard, "Ready", UDim2.new(1, 0, 0, 18), Color3.fromRGB(120, 220, 120), true)
teleStatus.Position = UDim2.new(0, 0, 1, -22)
teleStatus.TextSize = 12

local teleportNowBtn = Instance.new("TextButton")
teleportNowBtn.Size = UDim2.new(1, 0, 0, 44)
teleportNowBtn.Text = "↯  TELEPORT NOW"
teleportNowBtn.TextSize = 15
teleportNowBtn.TextColor3 = Color3.fromRGB(255, 245, 245)
teleportNowBtn.Font = Enum.Font.GothamBold
teleportNowBtn.BackgroundColor3 = Color3.fromRGB(62, 18, 18)
teleportNowBtn.BorderSizePixel = 0
teleportNowBtn.Parent = teleportPage
makeCorner(teleportNowBtn, 14)
animateButton(teleportNowBtn, Color3.fromRGB(62, 18, 18), Color3.fromRGB(88, 28, 28), Color3.fromRGB(235, 60, 60))

local toggleCard = Instance.new("Frame")
toggleCard.Size = UDim2.new(1, 0, 0, 76)
toggleCard.BackgroundColor3 = Color3.fromRGB(26, 26, 29)
toggleCard.BorderSizePixel = 0
toggleCard.Parent = teleportPage
makeCorner(toggleCard, 16)
makeStroke(toggleCard, Color3.fromRGB(90, 22, 22), 0.22, 1)
makeGradient(toggleCard, 90, Color3.fromRGB(30, 16, 16), Color3.fromRGB(23, 23, 26))

local togglePad = Instance.new("UIPadding")
togglePad.PaddingTop = UDim.new(0, 12)
togglePad.PaddingLeft = UDim.new(0, 12)
togglePad.PaddingRight = UDim.new(0, 12)
togglePad.PaddingBottom = UDim.new(0, 12)
togglePad.Parent = toggleCard

local toggleTitle = createLabel(toggleCard, "Auto-return guard", UDim2.new(1, -80, 0, 18), Color3.fromRGB(255, 235, 235), true)
toggleTitle.TextSize = 14

local toggleSub = createLabel(toggleCard, "If you move within range of workspace.Stages.1 or workspace.SpawnLocation, the script teleports you back to the assigned part.", UDim2.new(1, -80, 0, 34), Color3.fromRGB(200, 200, 205), false)
toggleSub.Position = UDim2.new(0, 0, 0, 22)
toggleSub.TextWrapped = true
toggleSub.TextSize = 11

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 58, 0, 30)
toggleButton.Position = UDim2.new(1, -68, 0, 22)
toggleButton.Text = ""
toggleButton.BackgroundColor3 = Color3.fromRGB(52, 52, 56)
toggleButton.BorderSizePixel = 0
toggleButton.Parent = toggleCard
makeCorner(toggleButton, 15)
animateButton(toggleButton, Color3.fromRGB(52, 52, 56), Color3.fromRGB(68, 24, 24), Color3.fromRGB(235, 60, 60))

local knob = Instance.new("Frame")
knob.Size = UDim2.new(0, 24, 0, 24)
knob.Position = UDim2.new(0, 3, 0, 3)
knob.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
knob.BorderSizePixel = 0
knob.Parent = toggleButton
makeCorner(knob, 12)
makeStroke(knob, Color3.fromRGB(255, 80, 80), 0.45, 1)

local guardInfo = createCard(teleportPage, 80, "Guard Readout", "Waiting for a valid teleport and nearby location check.")
local guardInfoText = createLabel(guardInfo, "Distance threshold: 100 studs", UDim2.new(1, 0, 0, 18), Color3.fromRGB(220, 220, 224), false)
guardInfoText.Position = UDim2.new(0, 0, 0, 50)
guardInfoText.TextSize = 11

--====================================================
-- SETTINGS PAGE
--====================================================
local settingsCard = Instance.new("Frame")
settingsCard.Size = UDim2.new(1, 0, 0, 278)
settingsCard.BackgroundColor3 = Color3.fromRGB(26, 26, 29)
settingsCard.BorderSizePixel = 0
settingsCard.Parent = settingsPage
makeCorner(settingsCard, 16)
makeStroke(settingsCard, Color3.fromRGB(90, 22, 22), 0.22, 1)
makeGradient(settingsCard, 90, Color3.fromRGB(30, 16, 16), Color3.fromRGB(22, 22, 26))

local settingsPad = Instance.new("UIPadding")
settingsPad.PaddingTop = UDim.new(0, 12)
settingsPad.PaddingLeft = UDim.new(0, 12)
settingsPad.PaddingRight = UDim.new(0, 12)
settingsPad.PaddingBottom = UDim.new(0, 12)
settingsPad.Parent = settingsCard

local settingsTitle = createLabel(settingsCard, "Teleport Settings", UDim2.new(1, 0, 0, 18), Color3.fromRGB(255, 235, 235), true)
settingsTitle.TextSize = 15

local settingsSub = createLabel(settingsCard, "Edit the target part name and teleport behavior directly from the UI.", UDim2.new(1, 0, 0, 18), Color3.fromRGB(200, 200, 205), false)
settingsSub.Position = UDim2.new(0, 0, 0, 24)
settingsSub.TextSize = 11

local inputHolder = Instance.new("Frame")
inputHolder.Size = UDim2.new(1, 0, 0, 160)
inputHolder.Position = UDim2.new(0, 0, 0, 54)
inputHolder.BackgroundTransparency = 1
inputHolder.Parent = settingsCard

local inputLayout = Instance.new("UIListLayout")
inputLayout.Padding = UDim.new(0, 10)
inputLayout.SortOrder = Enum.SortOrder.LayoutOrder
inputLayout.Parent = inputHolder

local targetLabel = createLabel(inputHolder, "Target part name", UDim2.new(1, 0, 0, 16), Color3.fromRGB(255, 235, 235), true)
targetLabel.LayoutOrder = 1
local targetBox = createInput(inputHolder, "Win Part", config.TargetPartName)

local distanceLabel = createLabel(inputHolder, "Auto-return distance", UDim2.new(1, 0, 0, 16), Color3.fromRGB(255, 235, 235), true)
distanceLabel.LayoutOrder = 3
local distanceBox = createInput(inputHolder, "100", tostring(config.AutoReturnDistance))

local offsetLabel = createLabel(inputHolder, "Height offset", UDim2.new(1, 0, 0, 16), Color3.fromRGB(255, 235, 235), true)
offsetLabel.LayoutOrder = 5
local offsetBox = createInput(inputHolder, "4", tostring(config.TeleportHeightOffset))

local tweenLabel = createLabel(inputHolder, "Tween time", UDim2.new(1, 0, 0, 16), Color3.fromRGB(255, 235, 235), true)
tweenLabel.LayoutOrder = 7
local tweenBox = createInput(inputHolder, "1.15", tostring(config.TeleportTweenTime))

local settingsButtons = Instance.new("Frame")
settingsButtons.Size = UDim2.new(1, 0, 0, 42)
settingsButtons.Position = UDim2.new(0, 0, 0, 226)
settingsButtons.BackgroundTransparency = 1
settingsButtons.Parent = settingsCard

local settingsButtonsLayout = Instance.new("UIListLayout")
settingsButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
settingsButtonsLayout.Padding = UDim.new(0, 10)
settingsButtonsLayout.Parent = settingsButtons

local applyBtn = Instance.new("TextButton")
applyBtn.Size = UDim2.new(0.5, -5, 1, 0)
applyBtn.Text = "✓  Apply"
applyBtn.TextSize = 14
applyBtn.TextColor3 = Color3.fromRGB(255, 245, 245)
applyBtn.Font = Enum.Font.GothamBold
applyBtn.BackgroundColor3 = Color3.fromRGB(58, 18, 18)
applyBtn.BorderSizePixel = 0
applyBtn.Parent = settingsButtons
makeCorner(applyBtn, 12)
animateButton(applyBtn, Color3.fromRGB(58, 18, 18), Color3.fromRGB(84, 28, 28), Color3.fromRGB(235, 60, 60))

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0.5, -5, 1, 0)
resetBtn.Text = "↺  Defaults"
resetBtn.TextSize = 14
resetBtn.TextColor3 = Color3.fromRGB(245, 245, 245)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
resetBtn.BorderSizePixel = 0
resetBtn.Parent = settingsButtons
makeCorner(resetBtn, 12)
animateButton(resetBtn, Color3.fromRGB(28, 28, 32), Color3.fromRGB(44, 22, 22), Color3.fromRGB(235, 60, 60))

local settingsFoot = createCard(settingsPage, 72, "Live Readout", "These settings affect both the teleport button and the auto-return guard.")
local settingsFootText = createLabel(settingsFoot, "", UDim2.new(1, 0, 0, 18), Color3.fromRGB(220, 220, 224), false)
settingsFootText.Position = UDim2.new(0, 0, 0, 50)
settingsFootText.TextSize = 11

--====================================================
-- VISUAL STATE
--====================================================
local function setTopStatus(text, color)
	statusText.Text = text
	statusText.TextColor3 = color or Color3.fromRGB(245, 245, 245)
	statusDot.BackgroundColor3 = color or Color3.fromRGB(245, 245, 245)
end

local function applyToggleVisual()
	if config.AutoReturnEnabled then
		TweenService:Create(toggleButton, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(122, 28, 28)
		}):Play()
		TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -27, 0, 3),
			BackgroundColor3 = Color3.fromRGB(255, 245, 245)
		}):Play()
	else
		TweenService:Create(toggleButton, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(52, 52, 56)
		}):Play()
		TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, 3, 0, 3),
			BackgroundColor3 = Color3.fromRGB(235, 235, 235)
		}):Play()
	end
end

local function refreshReadouts()
	local targetPart = resolveTargetPart()
	local targetExists = targetPart ~= nil

	local targetText = targetExists and ("Target: " .. config.TargetPartName .. "  •  Found") or ("Target: " .. config.TargetPartName .. "  •  Missing")
	local targetColor = targetExists and Color3.fromRGB(120, 220, 120) or Color3.fromRGB(255, 130, 130)

	setTextWithColor(statLeftValue, targetText, targetColor)
	setTextWithColor(homeTargetLine, targetText, targetColor)

	local guardText = config.AutoReturnEnabled and "Enabled" or "Disabled"
	local guardColor = config.AutoReturnEnabled and Color3.fromRGB(120, 220, 120) or Color3.fromRGB(210, 210, 210)
	setTextWithColor(statRightValue, guardText, guardColor)
	setTextWithColor(homeGuardLine, "Guard: " .. guardText, guardColor)

	guardInfoText.Text = ("Distance threshold: %d studs"):format(math.floor(config.AutoReturnDistance))
	settingsFootText.Text = ("Target: %s  •  Distance: %d  •  Offset: %d  •  Tween: %.2fs"):format(
		config.TargetPartName,
		math.floor(config.AutoReturnDistance),
		math.floor(config.TeleportHeightOffset),
		config.TeleportTweenTime
	)

	if state.teleportInProgress then
		setTopStatus("TELEPORTING", Color3.fromRGB(255, 210, 120))
	elseif config.AutoReturnEnabled and state.teleportActive then
		setTopStatus("GUARD ON", Color3.fromRGB(120, 220, 120))
	else
		setTopStatus("READY", Color3.fromRGB(120, 220, 120))
	end
end

local function setUiVisible(visible)
	TweenService:Create(main, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = visible and UDim2.new(0, 620, 0, 390) or UDim2.new(0, 620, 0, 46)
	}):Play()

	TweenService:Create(shadow, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = visible and UDim2.new(0, 632, 0, 402) or UDim2.new(0, 632, 0, 58),
		BackgroundTransparency = visible and 0.42 or 1
	}):Play()

	TweenService:Create(backdrop, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		BackgroundTransparency = visible and 0.56 or 1
	}):Play()

	TweenService:Create(blur, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = visible and 10 or 0
	}):Play()

	rail.Visible = visible
	contentHost.Visible = visible

	if visible then
		pages.Home.Visible = state.currentPage == "Home"
		pages.Teleport.Visible = state.currentPage == "Teleport"
		pages.Settings.Visible = state.currentPage == "Settings"
	else
		pages.Home.Visible = false
		pages.Teleport.Visible = false
		pages.Settings.Visible = false
	end

	minimizeBtn.Text = visible and "–" or "+"
	state.uiMinimized = not visible
end

local function setPageVisibleState(pageName)
	for name, page in pairs(pages) do
		page.Visible = (name == pageName)
	end
end

--====================================================
-- TELEPORT SYSTEM
--====================================================
local function smoothTeleportToTarget()
	if state.teleportInProgress then
		return
	end

	local targetPart = resolveTargetPart()
	if not targetPart then
		setTopStatus("TARGET MISSING", Color3.fromRGB(255, 130, 130))
		setTextWithColor(teleStatus, "Target part not found.", Color3.fromRGB(255, 130, 130))
		refreshReadouts()
		return
	end

	local char, hum, hrp = getCharacter()
	if not char or not hum or not hrp then
		setTopStatus("CHARACTER WAIT", Color3.fromRGB(255, 210, 120))
		setTextWithColor(teleStatus, "Character not ready.", Color3.fromRGB(255, 130, 130))
		return
	end

	state.teleportInProgress = true
	setTopStatus("TELEPORTING", Color3.fromRGB(255, 210, 120))
	setTextWithColor(teleStatus, "Teleporting to target...", Color3.fromRGB(255, 210, 120))

	local oldWalkSpeed = hum.WalkSpeed
	local oldJumpPower = hum.JumpPower
	local oldAutoRotate = hum.AutoRotate

	hum.WalkSpeed = 0
	hum.JumpPower = 0
	hum.AutoRotate = false

	local destination = targetPart.CFrame + Vector3.new(0, config.TeleportHeightOffset, 0)

	local cframeValue = Instance.new("CFrameValue")
	cframeValue.Value = char:GetPivot()

	local pivotConn
	pivotConn = cframeValue:GetPropertyChangedSignal("Value"):Connect(function()
		if char and char.Parent then
			char:PivotTo(cframeValue.Value)
		end
	end)

	local tween = TweenService:Create(
		cframeValue,
		TweenInfo.new(config.TeleportTweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
		{ Value = destination }
	)

	tween:Play()
	tween.Completed:Wait()

	if pivotConn then
		pivotConn:Disconnect()
	end
	cframeValue:Destroy()

	if hum and hum.Parent then
		hum.WalkSpeed = oldWalkSpeed
		hum.JumpPower = oldJumpPower
		hum.AutoRotate = oldAutoRotate
	end

	if hrp and hrp.Parent then
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
	end

	state.teleportActive = true
	state.guardCooldownUntil = now() + 1.1

	setTopStatus("TELEPORTED", Color3.fromRGB(120, 220, 120))
	setTextWithColor(teleStatus, "Teleport complete.", Color3.fromRGB(120, 220, 120))
	refreshReadouts()

	state.teleportInProgress = false
end

local function toggleAutoReturn()
	config.AutoReturnEnabled = not config.AutoReturnEnabled
	applyToggleVisual()
	refreshReadouts()
end

local function applySettingsFromInputs()
	local targetName = tostring(targetBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if targetName ~= "" then
		config.TargetPartName = targetName
	end

	config.AutoReturnDistance = clampNumber(distanceBox.Text, 1, 5000, config.AutoReturnDistance)
	config.TeleportHeightOffset = clampNumber(offsetBox.Text, 0, 100, config.TeleportHeightOffset)
	config.TeleportTweenTime = clampNumber(tweenBox.Text, 0.15, 8, config.TeleportTweenTime)

	targetBox.Text = config.TargetPartName
	distanceBox.Text = tostring(config.AutoReturnDistance)
	offsetBox.Text = tostring(config.TeleportHeightOffset)
	tweenBox.Text = tostring(config.TeleportTweenTime)

	refreshReadouts()
	setTopStatus("SETTINGS APPLIED", Color3.fromRGB(120, 220, 120))
	setTextWithColor(teleStatus, "Settings updated.", Color3.fromRGB(120, 220, 120))
end

local function resetDefaults()
	config.TargetPartName = "Win Part"
	config.AutoReturnDistance = 100
	config.TeleportHeightOffset = 4
	config.TeleportTweenTime = 1.15
	config.AutoReturnEnabled = true

	targetBox.Text = config.TargetPartName
	distanceBox.Text = tostring(config.AutoReturnDistance)
	offsetBox.Text = tostring(config.TeleportHeightOffset)
	tweenBox.Text = tostring(config.TeleportTweenTime)

	applyToggleVisual()
	refreshReadouts()
	setTopStatus("DEFAULTS RESTORED", Color3.fromRGB(120, 220, 120))
end

--====================================================
-- DRAGGING
--====================================================
local dragging = false
local dragStart
local startPos

topbar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

topbar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local delta = input.Position - dragStart
	main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	shadow.Position = UDim2.new(main.Position.X.Scale, main.Position.X.Offset + 6, main.Position.Y.Scale, main.Position.Y.Offset + 6)
end)

--====================================================
-- TAB / BUTTON EVENTS
--====================================================
minimizeBtn.MouseButton1Click:Connect(function()
	setUiVisible(state.uiMinimized)
end)

tabHome.MouseButton1Click:Connect(function()
	setPage("Home")
end)

tabTeleport.MouseButton1Click:Connect(function()
	setPage("Teleport")
end)

tabSettings.MouseButton1Click:Connect(function()
	setPage("Settings")
end)

quickTeleportBtn.MouseButton1Click:Connect(smoothTeleportToTarget)
teleportNowBtn.MouseButton1Click:Connect(smoothTeleportToTarget)
rescanBtn.MouseButton1Click:Connect(refreshReadouts)
toggleButton.MouseButton1Click:Connect(toggleAutoReturn)
applyBtn.MouseButton1Click:Connect(applySettingsFromInputs)
resetBtn.MouseButton1Click:Connect(resetDefaults)

--====================================================
-- AUTO RETURN CHECK
--====================================================
local acc = 0
RunService.Heartbeat:Connect(function(dt)
	acc += dt
	if acc < 0.2 then
		return
	end
	acc = 0

	refreshReadouts()

	if not config.AutoReturnEnabled then
		return
	end
	if not state.teleportActive then
		return
	end
	if state.teleportInProgress then
		return
	end
	if now() < state.guardCooldownUntil then
		return
	end

	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	local stageOne = resolveStageOne()
	local spawnLocation = resolveSpawnLocation()

	local nearStage = stageOne and distanceToPart(stageOne, hrp) <= config.AutoReturnDistance
	local nearSpawn = spawnLocation and distanceToPart(spawnLocation, hrp) <= config.AutoReturnDistance

	if nearStage or nearSpawn then
		task.spawn(smoothTeleportToTarget)
	end
end)

player.CharacterAdded:Connect(function()
	task.wait(0.75)
	state.guardCooldownUntil = now() + 1
	refreshReadouts()
end)

--====================================================
-- INITIALIZE
--====================================================
pages.Home.Visible = true
pages.Teleport.Visible = false
pages.Settings.Visible = false
updateTabs()
applyToggleVisual()
refreshReadouts()
setUiVisible(true)
