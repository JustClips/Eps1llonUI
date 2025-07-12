+291
-188
Lines changed: 291 additions & 188 deletions
Original file line number	Diff line number	Diff line change
@@ -1,39 +1,66 @@
--// Eps1llonUI Library | Modular, Mobile-Ready GUI (2025)
--// Built for external/executor injection. Uses your design & layout.
local Eps1llonUI = {}
Eps1llonUI._VERSION = "2025.07.11"
local player = game.Players.LocalPlayer
local TweenService = game:GetService('TweenService')
local UserInputService = game:GetService('UserInputService')

local uiEnabled = true
local minimized = false
local IS_MOBILE = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled)
local function isTouch(input) return input.UserInputType == Enum.UserInputType.Touch end

local gui = Instance.new('ScreenGui')
gui.Name = 'Eps1llonHub'
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild('PlayerGui')
gui.IgnoreGuiInset = true
pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = player:WaitForChild('PlayerGui') end

-- Main Frame
-- MAIN FRAME
local mainFrame = Instance.new('Frame', gui)
mainFrame.Size = UDim2.new(0, 650, 0, 300)
mainFrame.Position = UDim2.new(0.5, -325, 0.5, -150)
mainFrame.Size = UDim2.new(0, 650, 0, 420)
mainFrame.Position = UDim2.new(0.5, -325, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BackgroundTransparency = 0.14
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Draggable = false
Instance.new('UICorner', mainFrame).CornerRadius = UDim.new(0, 8)
local UIScale = Instance.new("UIScale", mainFrame)
UIScale.Scale = 1

local mainFrameScale = Instance.new("UIScale", mainFrame)
mainFrameScale.Scale = 1
local UIScale = mainFrameScale
-- HEADER (DRAG)
local headerFrame = Instance.new('Frame', mainFrame)
headerFrame.Size = UDim2.new(1, 0, 0, 30)
headerFrame.Position = UDim2.new(0, 0, 0, 0)
headerFrame.BackgroundTransparency = 1
headerFrame.Active = true
do
    local dragging, dragStart, startPos = false, nil, nil
    headerFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or isTouch(input) then
            dragging, dragStart, startPos = true, input.Position, mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or isTouch(input)) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or isTouch(input) then dragging = false end
    end)
end

local title = Instance.new('TextLabel', headerFrame)
title.Size = UDim2.new(1, -65, 1, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = 'Eps1llon Hub || Beta'
title.Text = 'Eps1llon Hub'
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
@@ -47,7 +74,6 @@ underline.BackgroundTransparency = 0
underline.BackgroundColor3 = Color3.fromRGB(31, 81, 138)
underline.BorderSizePixel = 0

-- Minimize Button
local minimize = Instance.new('TextButton', headerFrame)
minimize.Size = UDim2.new(0, 25, 0, 25)
minimize.Position = UDim2.new(1, -50, 0, 2)
@@ -58,7 +84,6 @@ minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
minimize.BackgroundTransparency = 1
minimize.BorderSizePixel = 0

-- Close Button
local close = Instance.new('TextButton', headerFrame)
close.Size = UDim2.new(0, 25, 0, 25)
close.Position = UDim2.new(1, -25, 0, 2)
@@ -68,18 +93,16 @@ close.TextSize = 16
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.BackgroundTransparency = 1
close.BorderSizePixel = 0
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- SIDEBAR
local sidebar = Instance.new('Frame', mainFrame)
sidebar.Size = UDim2.new(0, 140, 0, 220)
sidebar.Size = UDim2.new(0, 140, 0, 340)
sidebar.Position = UDim2.new(0, 10, 0, 50)
sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
sidebar.BackgroundTransparency = 0.1
sidebar.BackgroundTransparency = 0.12
sidebar.BorderSizePixel = 0
Instance.new('UICorner', sidebar).CornerRadius = UDim.new(0, 6)
local outline = Instance.new('UIStroke', sidebar)
outline.Thickness = 2
outline.Color = Color3.fromRGB(31, 81, 138)
@@ -94,80 +117,55 @@ highlighter.BorderSizePixel = 0
highlighter.ZIndex = 2
Instance.new('UICorner', highlighter).CornerRadius = UDim.new(1, 999)

-- CONTENT FRAME
local contentFrame = Instance.new('Frame', mainFrame)
contentFrame.Size = UDim2.new(0, 480, 0, 220)
contentFrame.Size = UDim2.new(0, 480, 0, 340)
contentFrame.Position = UDim2.new(0, 160, 0, 50)
contentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
contentFrame.BackgroundTransparency = 0.7
contentFrame.BorderSizePixel = 0
Instance.new('UICorner', contentFrame).CornerRadius = UDim.new(0, 6)
local outlineContentFrame = Instance.new('UIStroke', contentFrame)
outlineContentFrame.Thickness = 2
outlineContentFrame.Color = Color3.fromRGB(31, 81, 138)
outlineContentFrame.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local function createSection(name)
    local section = Instance.new('Frame')
    section.Name = name
    section.Size = UDim2.new(1, 0, 1, 0)
    section.BackgroundTransparency = 1
    section.Visible = false
    section.Parent = contentFrame
    return section
end
local buttonNames = {
-- TABS
local _TABS = {
    "Configuration",
    "Combat",
    "ESP",
    "Inventory",
    "Misc",
    "UI Settings",
}
local sectionKeys = {
    Configuration = "Configuration",
    Combat = "Hunt",
    ESP = "ESP",
    Inventory = "Inventory",
    Misc = "Teleports",
    ["UI Settings"] = "UI Settings",
local iconData = {
    Configuration = "134572329997100", Combat = "94883448905030", ESP = "92313485402528", Inventory = "135628846657243",
    Misc = "121583805460244", ["UI Settings"] = "93991072023597",
}
local ICON_SIZE, ICON_LEFT_PAD, TEXT_LEFT_PAD = 24, 6, 34
local sidebarButtons, tabSections, tabCallbacks = {}, {}, {}

local sections = {}
for k, v in pairs(sectionKeys) do
    sections[k] = createSection(k)
end
local sidebarButtons = {}
local DEFAULT_COLOR = Color3.fromRGB(210,210,210)
local ACTIVE_COLOR = Color3.fromRGB(255,255,255)
local DEFAULT_SIZE = 16
local ACTIVE_SIZE = 18
local DEFAULT_COLOR, ACTIVE_COLOR, DEFAULT_SIZE, ACTIVE_SIZE = Color3.fromRGB(210,210,210), Color3.fromRGB(255,255,255), 16, 18

local iconData = {
    Configuration = "134572329997100",
    Combat = "94883448905030",
    ESP = "92313485402528",
    Inventory = "135628846657243",
    Misc = "121583805460244",
    ["UI Settings"] = "93991072023597",
}
local ICON_SIZE = 24
local ICON_LEFT_PAD = 6
local TEXT_LEFT_PAD = ICON_LEFT_PAD + ICON_SIZE + 4
local function createSection(name)
    local section = Instance.new('Frame')
    section.Name = name
    section.Size = UDim2.new(1, 0, 1, 0)
    section.BackgroundTransparency = 1
    section.Visible = false
    section.Parent = contentFrame
    return section
end

local function setButtonActive(idx)
    for i, group in ipairs(sidebarButtons) do
        local btn = group.TextButton
        local isActive = (i == idx)
        local btn, isActive = group.TextButton, (i == idx)
        TweenService:Create(btn, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {
            TextSize = isActive and ACTIVE_SIZE or DEFAULT_SIZE,
            TextColor3 = isActive and ACTIVE_COLOR or DEFAULT_COLOR
        }):Play()
        btn.Font = Enum.Font.GothamBold
        if isActive then
            TweenService:Create(highlighter, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = group.ButtonFrame.Position,
@@ -184,7 +182,6 @@ local function createSidebarButton(text, yPos, idx)
    buttonFrame.Position = UDim2.new(0, 0, 0, yPos)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.ZIndex = 3
    if iconData[text] then
        local image = Instance.new("ImageLabel", buttonFrame)
        image.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
@@ -195,7 +192,6 @@ local function createSidebarButton(text, yPos, idx)
        image.ScaleType = Enum.ScaleType.Fit
        image.ZIndex = 4
    end
    local button = Instance.new('TextButton', buttonFrame)
    button.Size = UDim2.new(1, -TEXT_LEFT_PAD, 1, 0)
    button.Position = UDim2.new(0, TEXT_LEFT_PAD, 0, 0)
@@ -206,36 +202,210 @@ local function createSidebarButton(text, yPos, idx)
    button.BackgroundTransparency = 1
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.ZIndex = 5
    button.MouseButton1Click:Connect(function()
        for _, sec in pairs(sections) do sec.Visible = false end
        sections[text].Visible = true
        for _, sec in pairs(tabSections) do sec.Visible = false end
        tabSections[text].Visible = true
        setButtonActive(idx)
        if tabCallbacks[text] then tabCallbacks[text]() end
    end)
    button.TouchTap:Connect(function()
        for _, sec in pairs(tabSections) do sec.Visible = false end
        tabSections[text].Visible = true
        setButtonActive(idx)
        if tabCallbacks[text] then tabCallbacks[text]() end
    end)
    sidebarButtons[idx] = { ButtonFrame = buttonFrame, TextButton = button }
    return buttonFrame
end

for i, name in ipairs(buttonNames) do
for i, name in ipairs(_TABS) do
    tabSections[name] = createSection(name)
    createSidebarButton(name, 10 + (i - 1) * 35, i)
end
sections["Configuration"].Visible = true
tabSections[_TABS[1]].Visible = true
setButtonActive(1)

-- Minimized floating "ES" circle (grey, smaller text, top-left of GUI)
local minimizedButton = Instance.new('ImageButton')
-- PUBLIC: API
function Eps1llonUI:AddButton(tab, opts)
    local section = tabSections[tab]
    assert(section, "Tab "..tostring(tab).." does not exist.")
    local btn = Instance.new("TextButton", section)
    btn.Size = UDim2.new(0, 210, 0, 38)
    btn.Position = UDim2.new(0, opts.X or 20, 0, opts.Y or (#section:GetChildren()-1)*42 + 15)
    btn.Text = opts.Name or "Button"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 17
    btn.TextColor3 = opts.TextColor3 or Color3.fromRGB(220,240,255)
    btn.BackgroundColor3 = opts.BackgroundColor3 or Color3.fromRGB(32,32,36)
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.TextXAlignment = Enum.TextXAlignment.Center
    btn.TextYAlignment = Enum.TextYAlignment.Center
    btn.MouseButton1Click:Connect(function() if opts.Callback then opts.Callback() end end)
    btn.TouchTap:Connect(function() if opts.Callback then opts.Callback() end end)
    return btn
end
function Eps1llonUI:AddLabel(tab, opts)
    local section = tabSections[tab]
    assert(section, "Tab "..tostring(tab).." does not exist.")
    local lbl = Instance.new("TextLabel", section)
    lbl.Size = UDim2.new(1, -40, 0, opts.Height or 30)
    lbl.Position = UDim2.new(0, opts.X or 20, 0, opts.Y or (#section:GetChildren()-1)*32 + 12)
    lbl.Text = opts.Text or "Label"
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = opts.TextSize or 16
    lbl.TextColor3 = opts.TextColor3 or Color3.fromRGB(220, 220, 220)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = opts.TextXAlignment or Enum.TextXAlignment.Left
    lbl.TextYAlignment = opts.TextYAlignment or Enum.TextYAlignment.Center
    return lbl
end
function Eps1llonUI:AddToggle(tab, opts)
    local section = tabSections[tab]
    assert(section, "Tab "..tostring(tab).." does not exist.")
    local container = Instance.new("Frame", section)
    container.Size = UDim2.new(0, 210, 0, 40)
    container.Position = UDim2.new(0, opts.X or 20, 0, opts.Y or (#section:GetChildren()-1)*44 + 12)
    container.BackgroundColor3 = opts.BackgroundColor3 or Color3.fromRGB(32, 32, 36)
    container.BackgroundTransparency = 0.17
    container.BorderSizePixel = 0
    Instance.new('UICorner', container).CornerRadius = UDim.new(0, 11)
    local label = Instance.new("TextLabel", container)
    label.Text = opts.Name or "Toggle"
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0.05, 0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 16
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    local pillow = Instance.new("Frame", container)
    pillow.Size = UDim2.new(0, 52, 0, 24)
    pillow.Position = UDim2.new(1, -60, 0.5, -12)
    pillow.BackgroundColor3 = opts.Default and Color3.fromRGB(43,110,158) or Color3.fromRGB(44,44,47)
    pillow.BorderSizePixel = 0
    Instance.new("UICorner", pillow).CornerRadius = UDim.new(1, 999)
    local knob = Instance.new("Frame", pillow)
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = opts.Default and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2)
    knob.BackgroundColor3 = Color3.fromRGB(230,230,255)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 999)
    local value = opts.Default and true or false
    local function setToggle(val)
        value = val
        pillow.BackgroundColor3 = val and Color3.fromRGB(43,110,158) or Color3.fromRGB(44,44,47)
        TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Position = val and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2)}):Play()
        if opts.Callback then opts.Callback(val) end
    end
    pillow.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or isTouch(input) then
            setToggle(not value)
        end
    end)
    pillow.TouchTap:Connect(function() setToggle(not value) end)
    return container
end
function Eps1llonUI:AddSlider(tab, opts)
    local section = tabSections[tab]
    assert(section, "Tab "..tostring(tab).." does not exist.")
    local frame = Instance.new("Frame", section)
    frame.Size = UDim2.new(1, -40, 0, 54)
    frame.Position = UDim2.new(0, 20, 0, opts.Y or (#section:GetChildren()-1)*58 + 10)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.41
    frame.BorderSizePixel = 0
    Instance.new('UICorner', frame).CornerRadius = UDim.new(0, 12)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.3, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = opts.Name or "Slider"
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 17
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    local barBG = Instance.new("Frame", frame)
    barBG.Size = UDim2.new(0.62, -20, 0, 20)
    barBG.Position = UDim2.new(0.35, 10, 0, 16)
    barBG.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    barBG.BorderSizePixel = 0
    barBG.ClipsDescendants = true
    Instance.new("UICorner", barBG).CornerRadius = UDim.new(1, 999)
    local fill = Instance.new("Frame", barBG)
    fill.Size = UDim2.new(((opts.Default or opts.Min)-opts.Min)/(opts.Max-opts.Min), 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = Color3.fromRGB(43, 110, 158)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 999)
    local valText = Instance.new("TextLabel", fill)
    valText.Size = UDim2.new(1, -8, 1, 0)
    valText.Position = UDim2.new(0, 8, 0, 0)
    valText.BackgroundTransparency = 1
    valText.TextColor3 = Color3.fromRGB(210, 240, 255)
    valText.Font = Enum.Font.GothamBold
    valText.TextSize = 16
    valText.TextXAlignment = Enum.TextXAlignment.Right
    valText.TextYAlignment = Enum.TextYAlignment.Center
    valText.Text = tostring(opts.Default or opts.Min)
    local function setSliderPos(x)
        local percent = math.clamp(x / barBG.AbsoluteSize.X, 0, 1)
        local value = math.floor((opts.Min or 0) + ((opts.Max or 100) - (opts.Min or 0))*percent + 0.5)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        valText.Text = tostring(value)
        if opts.Callback then opts.Callback(value) end
    end
    local draggingSlider = false
    local function beginDrag(input)
        draggingSlider = true
        setSliderPos(input.Position.X - barBG.AbsolutePosition.X)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingSlider = false end
        end)
    end
    barBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or isTouch(input) then
            beginDrag(input)
        end
    end)
    barBG.TouchTap:Connect(function(x, y)
        if barBG.AbsoluteSize.X > 0 then
            setSliderPos(x - barBG.AbsolutePosition.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or isTouch(input)) then
            setSliderPos(input.Position.X - barBG.AbsolutePosition.X)
        end
    end)
    return frame, valText
end
function Eps1llonUI:SetTabCallback(tab, callback)
    assert(tabSections[tab], "Tab "..tostring(tab).." does not exist.")
    tabCallbacks[tab] = callback
end
-- Minimize Button & Logic
local minimizedButton = Instance.new('ImageButton', gui)
minimizedButton.Name = "Eps1llonMini"
minimizedButton.Size = UDim2.new(0, 55, 0, 55)
minimizedButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
minimizedButton.BackgroundTransparency = 0.08
minimizedButton.AutoButtonColor = true
minimizedButton.Visible = false
minimizedButton.Parent = gui
Instance.new('UICorner', minimizedButton).CornerRadius = UDim.new(1, 999)
-- "ES" text, even smaller
local esText = Instance.new('TextLabel', minimizedButton)
esText.Size = UDim2.new(1, 0, 1, 0)
esText.Position = UDim2.new(0, 0, 0, 0)
@@ -249,12 +419,6 @@ esText.ZIndex = 2
esText.TextYAlignment = Enum.TextYAlignment.Center
esText.TextXAlignment = Enum.TextXAlignment.Center
esText.TextSize = 12
esText:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    esText.TextSize = math.min(esText.AbsoluteSize.Y * 0.32, 13) -- Smaller: 32% height, max 13px
end)
-- Animate function (scale & transparency)
local function animateObj(obj, scaleFrom, scaleTo, transpFrom, transpTo, duration, cb)
    local scaleObj = obj:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", obj)
    scaleObj.Scale = scaleFrom
@@ -263,122 +427,61 @@ local function animateObj(obj, scaleFrom, scaleTo, transpFrom, transpTo, duratio
    local tw1 = TweenService:Create(scaleObj, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = scaleTo})
    local tw2 = TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = transpTo})
    tw1:Play() tw2:Play()
    tw1.Completed:Connect(function()
        if cb then cb() end
    end)
    tw1.Completed:Connect(function() if cb then cb() end end)
end
-- Draggable circle
local draggingMini, dragInput, dragStart, startPos
local draggingMini, dragStartMini, startPosMini
minimizedButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
    if input.UserInputType == Enum.UserInputType.MouseButton1 or isTouch(input) then
        draggingMini = true
        dragStart = input.Position
        startPos = minimizedButton.Position
        dragStartMini = input.Position
        startPosMini = minimizedButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingMini = false
            end
            if input.UserInputState == Enum.UserInputState.End then draggingMini = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingMini and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
    if draggingMini and (input.UserInputType == Enum.UserInputType.MouseMovement or isTouch(input)) then
        local delta = input.Position - dragStartMini
        minimizedButton.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
            startPosMini.X.Scale, startPosMini.X.Offset + delta.X,
            startPosMini.Y.Scale, startPosMini.Y.Offset + delta.Y
        )
    end
end)
-- Restore GUI with animation
local function restoreGUI()
    animateObj(minimizedButton, 1, 0.2, 0.08, 1, 0.21, function()
        minimizedButton.Visible = false
        mainFrame.Visible = true
        UIScale.Scale = 0.8
        mainFrame.BackgroundTransparency = 1
        animateObj(mainFrame, 0.8, 1, 1, 0.1, 0.21)
        uiEnabled = true
        minimized = false
    end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or isTouch(input) then draggingMini = false end
end)
local function setMainVisible(val)
     mainFrame.Visible = val
    minimizedButton.Visible = not val
end
minimizedButton.MouseButton1Click:Connect(restoreGUI)
-- Minimize logic w/ animation
local function minimizeGUI()
    animateObj(mainFrame, 1, 0.8, 0.1, 1, 0.21, function()
        mainFrame.Visible = false
        -- Put at top-left of main GUI (relative to screen)
        local guiAbsPos = mainFrame.AbsolutePosition
        minimizedButton.Position = UDim2.new(0, guiAbsPos.X, 0, guiAbsPos.Y)
        animateObj(minimizedButton, 0.2, 1, 1, 0.08, 0.21)
        minimizedButton.Visible = true
        minimized = true
minimize.MouseButton1Click:Connect(function()
    animateObj(mainFrame, 1, 0, 0.14, 1, 0.22, function()
        setMainVisible(false)
        animateObj(minimizedButton, 0, 1, 1, 0.08, 0.22)
    end)
end
minimize.MouseButton1Click:Connect(minimizeGUI)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        if minimized then
            restoreGUI()
        else
            minimizeGUI()
        end
    end
end)
local resizeCorner = Instance.new('Frame', mainFrame)
resizeCorner.Size = UDim2.new(0, 18, 0, 18)
resizeCorner.Position = UDim2.new(1, -18, 1, -18)
resizeCorner.BackgroundColor3 = Color3.fromRGB(31, 81, 138)
resizeCorner.BorderSizePixel = 0
resizeCorner.BackgroundTransparency = 0.3
resizeCorner.Active = true
resizeCorner.ZIndex = 5
Instance.new('UICorner', resizeCorner).CornerRadius = UDim.new(0, 8)
local resizing = false
local resizeStartSize, inputStartPos
resizeCorner.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true
        mainFrame.Draggable = false
        resizeStartSize = mainFrame.Size
        inputStartPos = input.Position
        resizeCorner.BackgroundTransparency = 0
    end
minimizedButton.MouseButton1Click:Connect(function()
    animateObj(minimizedButton, 1, 0, 0.08, 1, 0.18, function()
        setMainVisible(true)
        animateObj(mainFrame, 0, 1, 1, 0.14, 0.23)
    end)
end)
UserInputService.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - inputStartPos
        local newWidth = math.clamp(resizeStartSize.X.Offset + delta.X, 400, 1000)
        local newHeight = math.clamp(resizeStartSize.Y.Offset + delta.Y, 200, 700)
        mainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        sidebar.Size = UDim2.new(0, 140, 0, mainFrame.Size.Y.Offset - 80)
        contentFrame.Size = UDim2.new(0, mainFrame.Size.X.Offset - 170, 0, mainFrame.Size.Y.Offset - 80)
        contentFrame.Position = UDim2.new(0, 160, 0, 50)
        resizeCorner.Position = UDim2.new(1, -18, 1, -18)
    end
minimizedButton.TouchTap:Connect(function()
    animateObj(minimizedButton, 1, 0, 0.08, 1, 0.18, function()
        setMainVisible(true)
        animateObj(mainFrame, 0, 1, 1, 0.14, 0.23)
    end)
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = false
        mainFrame.Draggable = true
        resizeCorner.BackgroundTransparency = 0.3
    end
end)
-- Scale for Mobile/Tablet
function Eps1llonUI:SetScale(val) UIScale.Scale = val end

mainFrame:GetPropertyChangedSignal("Size"):Connect(function()
    sidebar.Size = UDim2.new(0, 140, 0, mainFrame.Size.Y.Offset - 80)
    contentFrame.Size = UDim2.new(0, mainFrame.Size.X.Offset - 170, 0, mainFrame.Size.Y.Offset - 80)
    contentFrame.Position = UDim2.new(0, 160, 0, 50)
    resizeCorner.Position = UDim2.new(1, -18, 1, -18)
end)
-- API: Get section for custom elements
function Eps1llonUI:GetSection(tab) return tabSections[tab] end
-- API: Remove GUI
function Eps1llonUI:Destroy() gui:Destroy() end
return Eps1llonUI
