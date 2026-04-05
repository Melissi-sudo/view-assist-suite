--=========================================================
-- VRO UI LIBRARY (Polished Window / Tabs / Controls)
--=========================================================

local UILib = {}
UILib.__index = UILib

-- Services
local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- Default theme
local DefaultTheme = {
    Background    = Color3.fromRGB(12, 12, 18),
    Background2   = Color3.fromRGB(18, 18, 26),
    Background3   = Color3.fromRGB(24, 24, 34),
    Accent        = Color3.fromRGB(220, 60, 80),
    AccentSoft    = Color3.fromRGB(210, 90, 120),
    AccentGlow    = Color3.fromRGB(255, 120, 160),
    Stroke        = Color3.fromRGB(50, 50, 70),
    StrokeSoft    = Color3.fromRGB(35, 35, 50),
    Text          = Color3.fromRGB(235, 235, 245),
    TextSub       = Color3.fromRGB(165, 165, 190),
    TextDim       = Color3.fromRGB(120, 120, 140),
    Error         = Color3.fromRGB(255, 80, 105),
    Success       = Color3.fromRGB(80, 220, 140),
    Warning       = Color3.fromRGB(255, 190, 80),
}

local function deepCopyTheme(t)
    local n = {}
    for k,v in pairs(t) do
        n[k] = v
    end
    return n
end

-- Root ScreenGui (one per session)
local ScreenGui
local UIScaleObj

local function ensureGui()
    if ScreenGui and ScreenGui.Parent then
        return ScreenGui
    end

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VRO_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    UIScaleObj = Instance.new("UIScale")
    UIScaleObj.Parent = ScreenGui

    local function updateScale()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local size = cam.ViewportSize
        local minAxis = math.min(size.X, size.Y)
        UIScaleObj.Scale = math.clamp(minAxis / 1080, 0.7, 1.1)
    end
    updateScale()
    RunService.RenderStepped:Connect(updateScale)

    return ScreenGui
end

-- Tween helper
local function tween(obj, ti, props)
    local t = TweenService:Create(obj, ti, props)
    t:Play()
    return t
end

--=========================================================
-- NOTIFICATIONS
--=========================================================
local NotificationContainer

local function ensureNotificationContainer(theme)
    ensureGui()
    if NotificationContainer and NotificationContainer.Parent then
        return NotificationContainer
    end

    NotificationContainer = Instance.new("Frame")
    NotificationContainer.Name = "VRO_Notifications"
    NotificationContainer.Size = UDim2.new(0, 320, 1, 0)
    NotificationContainer.Position = UDim2.new(1, -340, 0, 20)
    NotificationContainer.BackgroundTransparency = 1
    NotificationContainer.ZIndex = 9990
    NotificationContainer.Parent = ScreenGui

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = NotificationContainer

    return NotificationContainer
end

local function makeNotification(theme, text, kind)
    ensureNotificationContainer(theme)
    kind = kind or "info"

    local color = theme.Accent
    if kind == "error" then
        color = theme.Error
    elseif kind == "success" then
        color = theme.Success
    elseif kind == "warn" then
        color = theme.Warning
    end

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = theme.Background3
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 1
    frame.ZIndex = 9991
    frame.Parent = NotificationContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 1.7
    stroke.Transparency = 0.4
    stroke.Parent = frame

    local glow = Instance.new("Frame")
    glow.BackgroundColor3 = color
    glow.Size = UDim2.new(1, 0, 1, 0)
    glow.BorderSizePixel = 0
    glow.BackgroundTransparency = 1
    glow.ZIndex = 9990
    glow.Parent = frame

    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, 8)
    glowCorner.Parent = glow

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -12, 1, 0)
    label.Position = UDim2.new(0, 6, 0, 0)
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextColor3 = theme.Text
    label.TextScaled = true
    label.ZIndex = 9992
    label.Parent = frame

    frame.Position = UDim2.new(1, 40, 0, 0)
    tween(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 0.05
    })
    tween(glow, TweenInfo.new(0.2), {BackgroundTransparency = 0.6})

    task.delay(3, function()
        if frame.Parent then
            local t1 = tween(glow, TweenInfo.new(0.2), {BackgroundTransparency = 1})
            local t2 = tween(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 40, 0, 0),
                BackgroundTransparency = 1
            })
            t2.Completed:Wait()
            if frame then frame:Destroy() end
        end
    end)
end

--=========================================================
-- WINDOW OBJECT
--=========================================================
local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

function UILib:CreateWindow(opts)
    opts = opts or {}
    local theme = deepCopyTheme(DefaultTheme)
    if opts.Theme and type(opts.Theme) == "table" then
        for k,v in pairs(opts.Theme) do
            if theme[k] ~= nil then
                theme[k] = v
            end
        end
    end

    ensureGui()

    local self = setmetatable({}, Window)
    self.Theme = theme
    self.Tabs  = {}

    local frame = Instance.new("Frame")
    frame.Name = "VRO_Window"
    frame.Size = opts.Size or UDim2.new(0, 720, 0, 430)
    frame.Position = UDim2.new(0.5, -frame.Size.X.Offset / 2, 0.5, -frame.Size.Y.Offset / 2)
    frame.BackgroundColor3 = theme.Background2
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.ZIndex = 10
    frame.Parent = ScreenGui
    self.Frame = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    local strokeOuter = Instance.new("UIStroke")
    strokeOuter.Color = theme.Stroke
    strokeOuter.Thickness = 2
    strokeOuter.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    strokeOuter.Parent = frame

    local innerGlow = Instance.new("UIStroke")
    innerGlow.Color = theme.StrokeSoft
    innerGlow.Thickness = 3
    innerGlow.LineJoinMode = Enum.LineJoinMode.Round
    innerGlow.Transparency = 0.6
    innerGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    innerGlow.Parent = frame

    -- Title bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 44)
    TitleBar.BackgroundColor3 = theme.Background3
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 11
    TitleBar.Parent = frame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = TitleBar

    local leftAccent = Instance.new("Frame")
    leftAccent.Size = UDim2.new(0, 4, 1, -8)
    leftAccent.Position = UDim2.new(0, 4, 0, 4)
    leftAccent.BackgroundColor3 = theme.Accent
    leftAccent.BorderSizePixel = 0
    leftAccent.ZIndex = 11
    leftAccent.Parent = TitleBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size = UDim2.new(1, -200, 0.55, 0)
    TitleLabel.Position = UDim2.new(0, 14, 0, 2)
    TitleLabel.Text = opts.Title or "VRO UI"
    TitleLabel.TextColor3 = theme.Text
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextScaled = true
    TitleLabel.ZIndex = 12
    TitleLabel.Parent = TitleBar

    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Size = UDim2.new(1, -200, 0.45, 0)
    SubtitleLabel.Position = UDim2.new(0, 14, 0.55, 0)
    SubtitleLabel.Text = opts.Subtitle or ""
    SubtitleLabel.TextColor3 = theme.TextSub
    SubtitleLabel.Font = Enum.Font.Gotham
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLabel.TextScaled = true
    SubtitleLabel.ZIndex = 12
    SubtitleLabel.Parent = TitleBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -36, 0.5, -14)
    CloseBtn.BackgroundColor3 = theme.Background
    CloseBtn.Text = "X"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextColor3 = theme.TextDim
    CloseBtn.TextScaled = true
    CloseBtn.AutoButtonColor = false
    CloseBtn.BorderSizePixel = 0
    CloseBtn.ZIndex = 13
    CloseBtn.Parent = TitleBar
    local closeCorner = Instance.new("UICorner", CloseBtn)
    closeCorner.CornerRadius = UDim.new(1, 0)

    CloseBtn.MouseEnter:Connect(function()
        tween(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = theme.Error, TextColor3 = Color3.new(1,1,1)})
    end)
    CloseBtn.MouseLeave:Connect(function()
        tween(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = theme.Background, TextColor3 = theme.TextDim})
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        tween(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            BackgroundTransparency = 1,
            Size = frame.Size * 0.9
        })
        task.delay(0.2, function()
            ScreenGui:Destroy()
        end)
    end)

    -- Dragging
    do
        local dragging = false
        local dragStart, startPos

        local function update(input)
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end

        TitleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos  = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                update(input)
            end
        end)
    end

    -- Tab bar + content
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 190, 1, -52)
    Sidebar.Position = UDim2.new(0, 10, 0, 46)
    Sidebar.BackgroundColor3 = theme.Background3
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex = 10
    Sidebar.Parent = frame

    local sideCorner = Instance.new("UICorner")
    sideCorner.CornerRadius = UDim.new(0, 10)
    sideCorner.Parent = Sidebar

    local sideStroke = Instance.new("UIStroke")
    sideStroke.Color = theme.StrokeSoft
    sideStroke.Thickness = 1.4
    sideStroke.Parent = Sidebar

    local sPad = Instance.new("UIPadding")
    sPad.PaddingTop = UDim.new(0, 10)
    sPad.PaddingLeft = UDim.new(0, 10)
    sPad.PaddingRight = UDim.new(0, 10)
    sPad.Parent = Sidebar

    local sList = Instance.new("UIListLayout")
    sList.Padding = UDim.new(0, 6)
    sList.SortOrder = Enum.SortOrder.LayoutOrder
    sList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sList.Parent = Sidebar

    local modulesLabel = Instance.new("TextLabel")
    modulesLabel.Size = UDim2.new(1, -4, 0, 22)
    modulesLabel.BackgroundTransparency = 1
    modulesLabel.Text = "MODULES"
    modulesLabel.TextColor3 = theme.TextDim
    modulesLabel.Font = Enum.Font.GothamSemibold
    modulesLabel.TextScaled = true
    modulesLabel.ZIndex = 11
    modulesLabel.Parent = Sidebar

    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, -4, 0, 1)
    sep.BackgroundColor3 = theme.StrokeSoft
    sep.BorderSizePixel = 0
    sep.ZIndex = 11
    sep.Parent = Sidebar

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -220, 1, -52)
    Content.Position = UDim2.new(0, 210, 0, 46)
    Content.BackgroundColor3 = theme.Background3
    Content.BorderSizePixel = 0
    Content.ZIndex = 10
    Content.Parent = frame
    local cCorner = Instance.new("UICorner", Content)
    cCorner.CornerRadius = UDim.new(0, 10)
    local cStroke = Instance.new("UIStroke", Content)
    cStroke.Color = theme.Stroke
    cStroke.Thickness = 1.8

    self.Sidebar = Sidebar
    self.Content = Content
    self.CurrentTab = nil

    -- Window open animation
    frame.Size = (opts.Size or UDim2.new(0, 720, 0, 430)) * 0.9
    frame.BackgroundTransparency = 1
    tween(frame, TweenInfo.new(0.23, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = opts.Size or UDim2.new(0, 720, 0, 430),
        BackgroundTransparency = 0
    })

    function self:Notify(text, kind)
        makeNotification(self.Theme, text, kind)
    end

    return self
end

--=========================================================
-- TAB CREATION
--=========================================================
function Window:AddTab(name)
    local theme = self.Theme

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 32)
    btn.BackgroundColor3 = theme.Background2
    btn.Text = name
    btn.TextColor3 = theme.TextSub
    btn.Font = Enum.Font.Gotham
    btn.TextScaled = true
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.ZIndex = 11
    btn.Parent = self.Sidebar
    local bCorner = Instance.new("UICorner", btn)
    bCorner.CornerRadius = UDim.new(0, 8)

    local Content = self.Content

    local Page = Instance.new("ScrollingFrame")
    Page.BackgroundTransparency = 1
    Page.Size = UDim2.new(1, -8, 1, -8)
    Page.Position = UDim2.new(0, 4, 0, 4)
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = theme.Accent
    Page.BorderSizePixel = 0
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.ZIndex = 10
    Page.Visible = false
    Page.Parent = Content

    local layout = Instance.new("UIListLayout", Page)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local pad = Instance.new("UIPadding", Page)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)

    local tab = setmetatable({}, Tab)
    tab.Name = name
    tab.Button = btn
    tab.Page = Page
    tab.Window = self

    local function setActive(on)
        if on then
            tween(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = theme.AccentSoft,
                TextColor3       = theme.Text
            })
        else
            tween(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = theme.Background2,
                TextColor3       = theme.TextSub
            })
        end
    end
    tab.SetActive = setActive

    btn.MouseButton1Click:Connect(function()
        if self.CurrentTab == tab then return end
        if self.CurrentTab then
            self.CurrentTab.Page.Visible = false
            self.CurrentTab.SetActive(false)
        end
        Page.Visible = true
        setActive(true)
        self.CurrentTab = tab
    end)

    if not self.CurrentTab then
        Page.Visible = true
        setActive(true)
        self.CurrentTab = tab
    end

    table.insert(self.Tabs, tab)
    return tab
end

--=========================================================
-- TAB WIDGET HELPERS
--=========================================================
local function createSectionHeader(tab, text)
    local theme = tab.Window.Theme
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 26)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = theme.Text
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextScaled = true
    lbl.ZIndex = 11
    lbl.Parent = tab.Page
end

local function createRow(tab, height)
    height = height or 54
    local theme = tab.Window.Theme

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, height)
    frame.BackgroundColor3 = theme.Background2
    frame.BorderSizePixel = 0
    frame.ZIndex = 10
    frame.Parent = tab.Page
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = theme.StrokeSoft
    stroke.Thickness = 1.2

    local left = Instance.new("Frame")
    left.Size = UDim2.new(1, -130, 1, 0)
    left.BackgroundTransparency = 1
    left.ZIndex = 11
    left.Parent = frame

    local right = Instance.new("Frame")
    right.Size = UDim2.new(0, 120, 1, 0)
    right.Position = UDim2.new(1, -120, 0, 0)
    right.BackgroundTransparency = 1
    right.ZIndex = 11
    right.Parent = frame

    return frame, left, right
end

local function setRowTexts(left, theme, title, desc)
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -8, 0, 24)
    t.Position = UDim2.new(0, 6, 0, 2)
    t.BackgroundTransparency = 1
    t.Text = title
    t.Font = Enum.Font.Gotham
    t.TextColor3 = theme.Text
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.TextScaled = true
    t.ZIndex = 11
    t.Parent = left

    if desc and desc ~= "" then
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, -8, 0, 20)
        d.Position = UDim2.new(0, 6, 0, 26)
        d.BackgroundTransparency = 1
        d.Text = desc
        d.Font = Enum.Font.Gotham
        d.TextColor3 = theme.TextDim
        d.TextXAlignment = Enum.TextXAlignment.Left
        d.TextScaled = true
        d.ZIndex = 11
        d.Parent = left
    end
end

--=========================================================
-- TAB METHODS
--=========================================================
function Tab:AddSection(title)
    createSectionHeader(self, title)
end

function Tab:AddToggle(opts)
    opts = opts or {}
    local theme = self.Window.Theme
    local default = opts.Default == nil and false or opts.Default

    local frame, left, right = createRow(self, 54)
    setRowTexts(left, theme, opts.Text or "Toggle", opts.Description or "")

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 64, 0, 26)
    btn.Position = UDim2.new(0.5, -32, 0.5, -13)
    btn.BackgroundColor3 = default and theme.Accent or theme.Background3
    btn.Text = default and "ON" or "OFF"
    btn.Font = Enum.Font.GothamSemibold
    btn.TextColor3 = default and Color3.new(1,1,1) or theme.TextDim
    btn.TextScaled = true
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.ZIndex = 12
    btn.Parent = right
    local bCorner = Instance.new("UICorner", btn)
    bCorner.CornerRadius = UDim.new(1, 0)

    local glow = Instance.new("UIStroke")
    glow.Color = theme.AccentGlow
    glow.Thickness = 3
    glow.Transparency = default and 0.55 or 1
    glow.Parent = btn

    local state = default
    if opts.Callback then
        task.spawn(function()
            opts.Callback(state)
        end)
    end

    local function setState(on)
        state = on
        local bkg = on and theme.Accent or theme.Background3
        local txt = on and Color3.new(1,1,1) or theme.TextDim
        btn.Text = on and "ON" or "OFF"
        tween(btn, TweenInfo.new(0.15), {BackgroundColor3 = bkg, TextColor3 = txt})
        tween(glow, TweenInfo.new(0.15), {Transparency = on and 0.55 or 1})
        if opts.Callback then
            task.spawn(function()
                opts.Callback(state)
            end)
        end
    end

    btn.MouseButton1Click:Connect(function()
        setState(not state)
    end)

    local toggleObj = {}
    function toggleObj:Set(newState)
        setState(newState and true or false)
    end
    function toggleObj:Get()
        return state
    end
    return toggleObj
end

function Tab:AddSlider(opts)
    opts = opts or {}
    local theme = self.Window.Theme

    local min = opts.Min or 0
    local max = opts.Max or 1
    local default = opts.Default or min
    local decimals = opts.Decimals or 2

    local frame, left, right = createRow(self, 74)
    setRowTexts(left, theme, opts.Text or "Slider", opts.Description or "")

    local valueLbl = Instance.new("TextLabel")
    valueLbl.Size = UDim2.new(1, 0, 0, 18)
    valueLbl.Position = UDim2.new(0, 0, 0, 2)
    valueLbl.BackgroundTransparency = 1
    valueLbl.TextColor3 = theme.Accent
    valueLbl.Font = Enum.Font.GothamBold
    valueLbl.TextScaled = true
    valueLbl.ZIndex = 12
    valueLbl.Parent = right

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 8)
    bar.Position = UDim2.new(0, 0, 0, 26)
    bar.BackgroundColor3 = theme.Background
    bar.BorderSizePixel = 0
    bar.ZIndex = 11
    bar.Parent = right
    local bCorner = Instance.new("UICorner", bar)
    bCorner.CornerRadius = UDim.new(0, 4)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = theme.Accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 12
    fill.Parent = bar
    local fCorner = Instance.new("UICorner", fill)
    fCorner.CornerRadius = UDim.new(0, 4)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new(0, -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
    knob.BorderSizePixel = 0
    knob.ZIndex = 13
    knob.Parent = bar
    local kCorner = Instance.new("UICorner", knob)
    kCorner.CornerRadius = UDim.new(1, 0)

    local dragging = false
    local value = default

    local function formatVal(v)
        local p = 10 ^ decimals
        return math.floor(v * p + 0.5) / p
    end

    local function setValue(v, fireCallback)
        v = math.clamp(v, min, max)
        value = v
        local pct = (v - min) / (max - min)
        tween(fill, TweenInfo.new(0.08), {Size = UDim2.new(pct, 0, 1, 0)})
        tween(knob, TweenInfo.new(0.08), {Position = UDim2.new(pct, -6, 0.5, -6)})
        valueLbl.Text = tostring(formatVal(v))
        if fireCallback and opts.Callback then
            task.spawn(function()
                opts.Callback(v)
            end)
        end
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
            setValue(min + rel * (max - min), true)
        end
    end)

    setValue(default, true)

    local sliderObj = {}
    function sliderObj:Set(v)
        setValue(v, true)
    end
    function sliderObj:Get()
        return value
    end
    return sliderObj
end

function Tab:AddDropdown(opts)
    opts = opts or {}
    local theme = self.Window.Theme

    local options = opts.Options or {}
    local default = opts.Default or options[1]

    local frame, left, right = createRow(self, 64)
    setRowTexts(left, theme, opts.Text or "Dropdown", opts.Description or "")

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.Position = UDim2.new(0, 0, 0.5, -13)
    btn.BackgroundColor3 = theme.Background
    btn.Text = tostring(default or "Select")
    btn.Font = Enum.Font.Gotham
    btn.TextColor3 = theme.Text
    btn.TextScaled = true
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.ZIndex = 12
    btn.Parent = right
    local bCorner = Instance.new("UICorner", btn)
    bCorner.CornerRadius = UDim.new(0, 6)

    local arrow = Instance.new("ImageLabel")
    arrow.Size = UDim2.new(0, 14, 0, 14)
    arrow.Position = UDim2.new(1, -18, 0.5, -7)
    arrow.BackgroundTransparency = 1
    arrow.Image = "rbxassetid://7072706620" -- small arrow
    arrow.ImageColor3 = theme.TextDim
    arrow.ZIndex = 13
    arrow.Parent = btn

    local dropFrame = Instance.new("Frame")
    dropFrame.BackgroundColor3 = theme.Background2
    dropFrame.Size = UDim2.new(0, 160, 0, 0)
    dropFrame.Position = UDim2.new(1, -160, 1, 4)
    dropFrame.BorderSizePixel = 0
    dropFrame.Visible = false
    dropFrame.ZIndex = 50
    dropFrame.Parent = frame
    local dCorner = Instance.new("UICorner", dropFrame)
    dCorner.CornerRadius = UDim.new(0, 6)
    local dStroke = Instance.new("UIStroke", dropFrame)
    dStroke.Color = theme.Stroke
    dStroke.Thickness = 1.3

    local dList = Instance.new("UIListLayout", dropFrame)
    dList.Padding = UDim.new(0, 2)
    dList.SortOrder = Enum.SortOrder.LayoutOrder
    local dPad = Instance.new("UIPadding", dropFrame)
    dPad.PaddingTop = UDim.new(0, 4)
    dPad.PaddingBottom = UDim.new(0, 4)
    dPad.PaddingLeft = UDim.new(0, 4)
    dPad.PaddingRight = UDim.new(0, 4)

    local current = default

    local function setValue(v, fromClick)
        current = v
        btn.Text = tostring(v)
        if opts.Callback and fromClick then
            task.spawn(function()
                opts.Callback(v)
            end)
        end
    end

    local function rebuild()
        for _,child in ipairs(dropFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        local count = 0
        for _,v in ipairs(options) do
            count += 1
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -4, 0, 22)
            b.BackgroundColor3 = theme.Background3
            b.Text = tostring(v)
            b.TextColor3 = theme.Text
            b.Font = Enum.Font.Gotham
            b.TextScaled = true
            b.AutoButtonColor = false
            b.BorderSizePixel = 0
            b.ZIndex = 51
            b.Parent = dropFrame
            local c = Instance.new("UICorner", b)
            c.CornerRadius = UDim.new(0, 4)

            b.MouseButton1Click:Connect(function()
                setValue(v, true)
                tween(dropFrame, TweenInfo.new(0.15), {Size = UDim2.new(0, 160, 0, 0)})
                dropFrame.Visible = false
            end)
        end
        local height = math.min(count * 24 + 8, 160)
        dropFrame.Size = UDim2.new(0, 160, 0, height)
    end
    rebuild()
    setValue(default, false)

    btn.MouseButton1Click:Connect(function()
        if dropFrame.Visible then
            tween(dropFrame, TweenInfo.new(0.15), {Size = UDim2.new(0, 160, 0, 0)})
            dropFrame.Visible = false
        else
            rebuild()
            dropFrame.Visible = true
        end
    end)

    local ddObj = {}
    function ddObj:SetOptions(list)
        options = list or {}
        rebuild()
    end
    function ddObj:Set(v)
        setValue(v, true)
    end
    function ddObj:Get()
        return current
    end
    return ddObj
end

function Tab:AddKeybind(opts)
    opts = opts or {}
    local theme = self.Window.Theme

    local defaultKey = opts.Default or Enum.KeyCode.E
    local currentKey = defaultKey

    local frame, left, right = createRow(self, 60)
    setRowTexts(left, theme, opts.Text or "Keybind", opts.Description or "Click and press key")

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.Position = UDim2.new(0, 0, 0.5, -13)
    btn.BackgroundColor3 = theme.Background
    btn.Text = tostring(defaultKey):gsub("Enum.KeyCode.", "")
    btn.Font = Enum.Font.Gotham
    btn.TextColor3 = theme.Text
    btn.TextScaled = true
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.ZIndex = 12
    btn.Parent = right
    local bCorner = Instance.new("UICorner", btn)
    bCorner.CornerRadius = UDim.new(0, 6)

    local waiting = false

    btn.MouseButton1Click:Connect(function()
        waiting = true
        btn.Text = "Press..."
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if waiting and input.UserInputType == Enum.UserInputType.Keyboard then
            waiting = false
            currentKey = input.KeyCode
            btn.Text = tostring(currentKey):gsub("Enum.KeyCode.", "")
            if opts.Callback then
                task.spawn(function()
                    opts.Callback(currentKey)
                end)
            end
        end
    end)

    local kbObj = {}
    function kbObj:Get()
        return currentKey
    end
    function kbObj:Set(k)
        currentKey = k
        btn.Text = tostring(k):gsub("Enum.KeyCode.", "")
        if opts.Callback then
            task.spawn(function()
                opts.Callback(k)
            end)
        end
    end
    return kbObj
end

--=========================================================
-- PUBLIC API
--=========================================================
function UILib:Notify(text, kind)
    ensureGui()
    makeNotification(DefaultTheme, text, kind)
end

function UILib:SetTheme(themeTable)
    for k,v in pairs(themeTable or {}) do
        if DefaultTheme[k] ~= nil then
            DefaultTheme[k] = v
        end
    end
end

return UILib
