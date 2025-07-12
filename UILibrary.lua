--// Eps1llonUI Library | Modular, Mobile-Ready GUI (2025)
--// Built for external/executor injection. Uses your design & layout.

local Eps1llonUI = {}
Eps1llonUI._VERSION = "2025.07.11"

local player = game.Players.LocalPlayer
local TweenService = game:GetService('TweenService')
local UserInputService = game:GetService('UserInputService')

local IS_MOBILE = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled)
local function isTouch(input) return input.UserInputType == Enum.UserInputType.Touch end

-- CREATE SCREENGUI
local gui = Instance.new('ScreenGui')
gui.Name = 'Eps1llonHub'
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = player:WaitForChild('PlayerGui') end

-- MAIN FRAME
local mainFrame = Instance.new('Frame', gui)
mainFrame.Size = UDim2.new(0, 650, 0, 360)               -- height reduced
mainFrame.Position = UDim2.new(0.5, -325, 0.5, -180)     -- adjusted offset
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BackgroundTransparency = 0.14
mainFrame.Active = true
mainFrame.Draggable = false
Instance.new('UICorner', mainFrame).CornerRadius = UDim.new(0, 8)
local UIScale = Instance.new("UIScale", mainFrame)
UIScale.Scale = 1

-- HEADER (DRAG)
local headerFrame = Instance.new('Frame', mainFrame)
headerFrame.Size = UDim2.new(1, 0, 0, 30)
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
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or isTouch(input) then dragging = false end
    end)
end

local title = Instance.new('TextLabel', headerFrame)
title.Size = UDim2.new(1, -65, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = 'Eps1llon Hub'
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

local underline = Instance.new('Frame', mainFrame)
underline.Size = UDim2.new(1, 0, 0, 4)
underline.Position = UDim2.new(0, 0, 0, 30)
underline.BackgroundColor3 = Color3.fromRGB(31, 81, 138)
underline.BorderSizePixel = 0

local minimize = Instance.new('TextButton', headerFrame)
minimize.Size = UDim2.new(0, 25, 0, 25)
minimize.Position = UDim2.new(1, -50, 0, 2)
minimize.Text = '-'
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 20
minimize.TextColor3 = Color3.fromRGB(255,255,255)
minimize.BackgroundTransparency = 1

local close = Instance.new('TextButton', headerFrame)
close.Size = UDim2.new(0, 25, 0, 25)
close.Position = UDim2.new(1, -25, 0, 2)
close.Text = 'X'
close.Font = Enum.Font.GothamBold
close.TextSize = 16
close.TextColor3 = Color3.fromRGB(255,255,255)
close.BackgroundTransparency = 1
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- SIDEBAR
local sidebar = Instance.new('Frame', mainFrame)
sidebar.Size = UDim2.new(0, 140, 0, 280)
sidebar.Position = UDim2.new(0, 10, 0, 50)
sidebar.BackgroundColor3 = Color3.fromRGB(30,30,30)
sidebar.BackgroundTransparency = 0.12
sidebar.BorderSizePixel = 0
Instance.new('UICorner', sidebar).CornerRadius = UDim.new(0,6)
local outline = Instance.new('UIStroke', sidebar)
outline.Thickness = 2
outline.Color = Color3.fromRGB(31,81,138)
outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local highlighter = Instance.new('Frame', sidebar)
highlighter.Size = UDim2.new(1, 0, 0, 30)
highlighter.Position = UDim2.new(0, 0, 0, 10)
highlighter.BackgroundColor3 = Color3.fromRGB(31,81,138)
highlighter.BackgroundTransparency = 0.3
highlighter.ZIndex = 2
Instance.new('UICorner', highlighter).CornerRadius = UDim.new(1,999)

-- CONTENT FRAME
local contentFrame = Instance.new('Frame', mainFrame)
contentFrame.Size = UDim2.new(0, 480, 0, 280)
contentFrame.Position = UDim2.new(0, 160, 0, 50)
contentFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
contentFrame.BackgroundTransparency = 0.7
contentFrame.BorderSizePixel = 0
Instance.new('UICorner', contentFrame).CornerRadius = UDim.new(0,6)
local outlineContentFrame = Instance.new('UIStroke', contentFrame)
outlineContentFrame.Thickness = 2
outlineContentFrame.Color = Color3.fromRGB(31,81,138)
outlineContentFrame.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- TABS SETUP
local _TABS = {"Configuration","Combat","ESP","Inventory","Misc","UI Settings"}
local iconData = {
    Configuration="134572329997100",
    Combat="94883448905030",
    ESP="92313485402528",
    Inventory="135628846657243",
    Misc="121583805460244",
    ["UI Settings"]="93991072023597",
}
local sidebarButtons, tabSections, tabCallbacks = {}, {}, {}
local DEFAULT_COLOR, ACTIVE_COLOR = Color3.fromRGB(210,210,210), Color3.fromRGB(255,255,255)
local DEFAULT_SIZE, ACTIVE_SIZE = 16, 18

local function createSection(name)
    local sec = Instance.new('Frame')
    sec.Name = name
    sec.Size = UDim2.new(1,0,1,0)
    sec.BackgroundTransparency = 1
    sec.Visible = false
    sec.Parent = contentFrame
    return sec
end

local function setButtonActive(idx)
    for i, group in ipairs(sidebarButtons) do
        local btn = group.TextButton
        local isActive = (i==idx)
        TweenService:Create(btn, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {
            TextSize = isActive and ACTIVE_SIZE or DEFAULT_SIZE,
            TextColor3 = isActive and ACTIVE_COLOR or DEFAULT_COLOR
        }):Play()
        btn.Font = Enum.Font.GothamBold
        if isActive then
            TweenService:Create(highlighter, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
                Position = group.ButtonFrame.Position,
                Size = group.ButtonFrame.Size,
                BackgroundTransparency = 0.13
            }):Play()
        end
    end
end

local function createSidebarButton(text, y, idx)
    local frame = Instance.new('Frame', sidebar)
    frame.Size = UDim2.new(1,0,0,30)
    frame.Position = UDim2.new(0,0,0,y)
    frame.BackgroundTransparency = 1
    frame.ZIndex = 3
    if iconData[text] then
        local img = Instance.new('ImageLabel', frame)
        img.Size = UDim2.new(0,24,0,24)
        img.Position = UDim2.new(0,6,0.5,-12)
        img.BackgroundTransparency = 1
        img.Image = "rbxassetid://"..iconData[text]
        img.ImageColor3 = Color3.new(1,1,1)
        img.ScaleType = Enum.ScaleType.Fit
        img.ZIndex = 4
    end
    local btn = Instance.new('TextButton', frame)
    btn.Size = UDim2.new(1,-34,1,0)
    btn.Position = UDim2.new(0,34,0,0)
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = DEFAULT_SIZE
    btn.TextColor3 = DEFAULT_COLOR
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.ZIndex = 5
    btn.MouseButton1Click:Connect(function()
        for _,s in pairs(tabSections) do s.Visible = false end
        tabSections[text].Visible = true
        setButtonActive(idx)
        if tabCallbacks[text] then tabCallbacks[text]() end
    end)
    btn.TouchTap:Connect(btn.MouseButton1Click)
    sidebarButtons[idx] = { ButtonFrame = frame, TextButton = btn }
    return frame
end

for i,name in ipairs(_TABS) do
    tabSections[name] = createSection(name)
    createSidebarButton(name, 10 + (i-1)*35, i)
end
tabSections[_TABS[1]].Visible = true
setButtonActive(1)

-- PUBLIC API
function Eps1llonUI:AddButton(tab, opts)
    local sec = tabSections[tab]
    assert(sec, "Tab "..tostring(tab).." does not exist.")
    local btn = Instance.new("TextButton", sec)
    btn.Size = UDim2.new(0,210,0,38)
    btn.Position = UDim2.new(0, opts.X or 20, 0, opts.Y or (#sec:GetChildren()-1)*42 + 15)
    btn.Text = opts.Name or "Button"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 17
    btn.TextColor3 = opts.TextColor3 or Color3.fromRGB(220,240,255)
    btn.BackgroundColor3 = opts.BackgroundColor3 or Color3.fromRGB(32,32,36)
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    btn.TextXAlignment = Enum.TextXAlignment.Center
    btn.TextYAlignment = Enum.TextYAlignment.Center
    btn.MouseButton1Click:Connect(function() if opts.Callback then opts.Callback() end end)
    btn.TouchTap:Connect(function() if opts.Callback then opts.Callback() end end)
    return btn
end

function Eps1llonUI:AddLabel(tab, opts)
    local sec = tabSections[tab]
    assert(sec, "Tab "..tostring(tab).." does not exist.")
    local lbl = Instance.new("TextLabel", sec)
    lbl.Size = UDim2.new(1,-40,0,opts.Height or 30)
    lbl.Position = UDim2.new(0,opts.X or 20,0,opts.Y or (#sec:GetChildren()-1)*32 + 12)
    lbl.Text = opts.Text or "Label"
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = opts.TextSize or 16
    lbl.TextColor3 = opts.TextColor3 or Color3.fromRGB(220,220,220)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = opts.TextXAlignment or Enum.TextXAlignment.Left
    lbl.TextYAlignment = opts.TextYAlignment or Enum.TextYAlignment.Center
    return lbl
end

function Eps1llonUI:AddToggle(tab, opts)
    local sec = tabSections[tab]
    assert(sec, "Tab "..tostring(tab).." does not exist.")
    local cont = Instance.new("Frame", sec)
    cont.Size = UDim2.new(0,210,0,40)
    cont.Position = UDim2.new(0,opts.X or 20,0,opts.Y or (#sec:GetChildren()-1)*44 + 12)
    cont.BackgroundColor3 = opts.BackgroundColor3 or Color3.fromRGB(32,32,36)
    cont.BackgroundTransparency = 0.17
    cont.BorderSizePixel = 0
    Instance.new("UICorner", cont).CornerRadius = UDim.new(0,11)

    local lbl = Instance.new("TextLabel", cont)
    lbl.Size = UDim2.new(0.7,0,1,0)
    lbl.Position = UDim2.new(0.05,0,0,0)
    lbl.Text = opts.Name or "Toggle"
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 16
    lbl.TextColor3 = Color3.fromRGB(220,220,220)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center

    local pillow = Instance.new("Frame", cont)
    pillow.Size = UDim2.new(0,52,0,24)
    pillow.Position = UDim2.new(1,-60,0.5,-12)
    pillow.BackgroundColor3 = opts.Default and Color3.fromRGB(43,110,158) or Color3.fromRGB(44,44,47)
    pillow.BorderSizePixel = 0
    Instance.new("UICorner", pillow).CornerRadius = UDim.new(1,999)

    local knob = Instance.new("Frame", pillow)
    knob.Size = UDim2.new(0,20,0,20)
    knob.Position = opts.Default and UDim2.new(1,-22,0,2) or UDim2.new(0,2,0,2)
    knob.BackgroundColor3 = Color3.fromRGB(230,230,255)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,999)

    local value = opts.Default and true or false
    local function setToggle(val)
        value = val
        pillow.BackgroundColor3 = val and Color3.fromRGB(43,110,158) or Color3.fromRGB(44,44,47)
        TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
            Position = val and UDim2.new(1,-22,0,2) or UDim2.new(0,2,0,2)
        }):Play()
        if opts.Callback then opts.Callback(val) end
    end

    pillow.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or isTouch(i) then
            setToggle(not value)
        end
    end)
    pillow.TouchTap:Connect(function() setToggle(not value) end)

    return cont
end

function Eps1llonUI:AddSlider(tab, opts)
    local sec = tabSections[tab]
    assert(sec, "Tab "..tostring(tab).." does not exist.")
    local frame = Instance.new("Frame", sec)
    frame.Size = UDim2.new(1,-40,0,54)
    frame.Position = UDim2.new(0,20,0,opts.Y or (#sec:GetChildren()-1)*58 + 10)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.BackgroundTransparency = 0.41
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.3,0,1,0)
    lbl.Position = UDim2.new(0,10,0,0)
    lbl.Text = opts.Name or "Slider"
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 17
    lbl.TextColor3 = Color3.fromRGB(220,220,220)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center

    local barBG = Instance.new("Frame", frame)
    barBG.Size = UDim2.new(0.62,-20,0,20)
    barBG.Position = UDim2.new(0.35,10,0,16)
    barBG.BackgroundColor3 = Color3.fromRGB(30,30,30)
    barBG.BorderSizePixel = 0
    barBG.ClipsDescendants = true
    Instance.new("UICorner", barBG).CornerRadius = UDim.new(1,999)

    local fill = Instance.new("Frame", barBG)
    fill.Size = UDim2.new(((opts.Default or opts.Min)-opts.Min)/(opts.Max-opts.Min),0,1,0)
    fill.Position = UDim2.new(0,0,0,0)
    fill.BackgroundColor3 = Color3.fromRGB(43,110,158)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,999)

    local valText = Instance.new("TextLabel", fill)
    valText.Size = UDim2.new(1,-8,1,0)
    valText.Position = UDim2.new(0,8,0,0)
    valText.BackgroundTransparency = 1
    valText.TextColor3 = Color3.fromRGB(210,240,255)
    valText.Font = Enum.Font.GothamBold
    valText.TextSize = 16
    valText.TextXAlignment = Enum.TextXAlignment.Right
    valText.TextYAlignment = Enum.TextYAlignment.Center
    valText.Text = tostring(opts.Default or opts.Min)

    local function setSliderPos(x)
        local pct = math.clamp(x/barBG.AbsoluteSize.X,0,1)
        local v = math.floor((opts.Min or 0) + ((opts.Max or 100)-(opts.Min or 0))*pct + .5)
        fill.Size = UDim2.new(pct,0,1,0)
        valText.Text = tostring(v)
        if opts.Callback then opts.Callback(v) end
    end

    local dragging = false
    barBG.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or isTouch(i) then
            dragging = true
            setSliderPos(i.Position.X - barBG.AbsolutePosition.X)
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or isTouch(i)) then
            setSliderPos(i.Position.X - barBG.AbsolutePosition.X)
        end
    end)
    barBG.TouchTap:Connect(function(x) setSliderPos(x - barBG.AbsolutePosition.X) end)

    return frame, valText
end

function Eps1llonUI:SetTabCallback(tab, callback)
    assert(tabSections[tab], "Tab "..tostring(tab).." does not exist.")
    tabCallbacks[tab] = callback
end

-- MINIMIZE LOGIC
local minimizedButton = Instance.new('ImageButton', gui)
minimizedButton.Name = "Eps1llonMini"
minimizedButton.Size = UDim2.new(0,55,0,55)
minimizedButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
minimizedButton.BackgroundTransparency = 0.08
minimizedButton.AutoButtonColor = true
minimizedButton.Visible = false
Instance.new('UICorner', minimizedButton).CornerRadius = UDim.new(1,999)
local esText = Instance.new('TextLabel', minimizedButton)
esText.Size = UDim2.new(1,0,1,0)
esText.BackgroundTransparency = 1
esText.Text = "ES"
esText.Font = Enum.Font.GothamBlack
esText.TextScaled = true
esText.TextColor3 = Color3.fromRGB(255,255,255)
esText.TextStrokeTransparency = 0.25
esText.ZIndex = 2
esText.TextXAlignment = Enum.TextXAlignment.Center
esText.TextYAlignment = Enum.TextYAlignment.Center
esText.TextSize = 12

local function animateObj(obj, sFrom, sTo, tFrom, tTo, d, cb)
    local sc = obj:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", obj)
    sc.Scale = sFrom
    obj.BackgroundTransparency = tFrom
    obj.Visible = true
    local tw1 = TweenService:Create(sc, TweenInfo.new(d, Enum.EasingStyle.Quad), {Scale=sTo})
    local tw2 = TweenService:Create(obj, TweenInfo.new(d, Enum.EasingStyle.Quad), {BackgroundTransparency=tTo})
    tw1:Play(); tw2:Play()
    tw1.Completed:Connect(function() if cb then cb() end end)
end

local dragMini, startMini, startPosMini
minimizedButton.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or isTouch(i) then
        dragMini = true
        startMini = i.Position
        startPosMini = minimizedButton.Position
        i.Changed:Connect(function()
            if i.UserInputState==Enum.UserInputState.End then dragMini = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragMini and (i.UserInputType==Enum.UserInputType.MouseMovement or isTouch(i)) then
        local delta = i.Position - startMini
        minimizedButton.Position = UDim2.new(
            startPosMini.X.Scale, startPosMini.X.Offset + delta.X,
            startPosMini.Y.Scale, startPosMini.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or isTouch(i) then dragMini = false end
end)

local function setMainVisible(v)
    mainFrame.Visible = v
    minimizedButton.Visible = not v
end
minimize.MouseButton1Click:Connect(function()
    animateObj(mainFrame, 1, 0, 0.14, 1, 0.22, function()
        setMainVisible(false)
        animateObj(minimizedButton, 0, 1, 1, 0.08, 0.22)
    end)
end)
minimizedButton.MouseButton1Click:Connect(function()
    animateObj(minimizedButton, 1, 0, 0.08, 1, 0.18, function()
        setMainVisible(true)
        animateObj(mainFrame, 0, 1, 1, 0.14, 0.23)
    end)
end)
minimizedButton.TouchTap:Connect(minimizedButton.MouseButton1Click)

-- MOBILE SCALE
function Eps1llonUI:SetScale(val) UIScale.Scale = val end
-- GET SECTION
function Eps1llonUI:GetSection(tab) return tabSections[tab] end
-- DESTROY
function Eps1llonUI:Destroy() gui:Destroy() end

-- THEME HANDLING
local themes = {
    Red    = { main = Color3.fromRGB(35,25,25),   accent = Color3.fromRGB(255,69,69)   },
    Green  = { main = Color3.fromRGB(25,35,25),   accent = Color3.fromRGB(69,255,69)   },
    Purple = { main = Color3.fromRGB(25,25,35),   accent = Color3.fromRGB(138,43,226)  },
    Yellow = { main = Color3.fromRGB(35,35,25),   accent = Color3.fromRGB(255,255,69)  },
    Black  = { main = Color3.fromRGB(20,20,20),   accent = Color3.fromRGB(180,180,180) },
    Orange = { main = Color3.fromRGB(35,20,0),    accent = Color3.fromRGB(255,165,0)   },
    White  = { main = Color3.fromRGB(240,240,240),accent = Color3.fromRGB(200,200,200) },
    Brown  = { main = Color3.fromRGB(60,40,20),   accent = Color3.fromRGB(160,82,45)   },
    Pink   = { main = Color3.fromRGB(35,20,30),   accent = Color3.fromRGB(255,105,180) },
}
local currentTheme = "Red"
local function applyTheme(name)
    local t = themes[name]
    if not t then return end
    currentTheme = name
    mainFrame.BackgroundColor3    = t.main
    underline.BackgroundColor3    = t.accent
    outline.Color                 = t.accent
    outlineContentFrame.Color     = t.accent
    highlighter.BackgroundColor3  = t.accent
end
applyTheme(currentTheme)

-- TOGGLE KEYBIND (default Insert)
local toggleKey = Enum.KeyCode.Insert
UserInputService.InputBegan:Connect(function(i, p)
    if p then return end
    if i.UserInputType==Enum.UserInputType.Keyboard and i.KeyCode==toggleKey then
        setMainVisible(not mainFrame.Visible)
    end
end)

-- UI SETTINGS LAYOUT
do
    local uiSettings = tabSections["UI Settings"]

    -- Row 1: Toggle Keybind (lowered)
    local row1 = Instance.new("Frame", uiSettings)
    row1.Size = UDim2.new(1, -40, 0, 30)
    row1.Position = UDim2.new(0, 20, 0, 30)         -- was 20, now 30
    row1.BackgroundTransparency = 1

    local keyLabel = Instance.new("TextLabel", row1)
    keyLabel.Size = UDim2.new(0.4, 0, 1, 0)
    keyLabel.Text = "Toggle Keybind"
    keyLabel.Font = Enum.Font.GothamBold
    keyLabel.TextSize = 16
    keyLabel.TextColor3 = Color3.fromRGB(220,220,220)
    keyLabel.BackgroundTransparency = 1
    keyLabel.TextXAlignment = Enum.TextXAlignment.Left

    local keyBtn = Instance.new("TextButton", row1)
    keyBtn.Size = UDim2.new(0.4, 0, 1, 0)
    keyBtn.Position = UDim2.new(0.6, 0, 0, 0)
    keyBtn.Text = toggleKey.Name
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.TextSize = 16
    keyBtn.TextColor3 = Color3.fromRGB(220,220,220)
    keyBtn.BackgroundColor3 = Color3.fromRGB(32,32,36)
    keyBtn.BorderSizePixel = 0
    Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0,4)
    keyBtn.MouseButton1Click:Connect(function()
        keyBtn.Text = "Press any key..."
        local conn
        conn = UserInputService.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                toggleKey = inp.KeyCode
                keyBtn.Text = toggleKey.Name
                conn:Disconnect()
            end
        end)
    end)

    -- Row 2: Theme Dropdown (lowered)
    local row2 = Instance.new("Frame", uiSettings)
    row2.Size = UDim2.new(1, -40, 0, 30)
    row2.Position = UDim2.new(0, 20, 0, 80)         -- was 70, now 80
    row2.BackgroundTransparency = 1

    local themeLabel = Instance.new("TextLabel", row2)
    themeLabel.Size = UDim2.new(0.4, 0, 1, 0)
    themeLabel.Text = "Theme"
    themeLabel.Font = Enum.Font.GothamBold
    themeLabel.TextSize = 16
    themeLabel.TextColor3 = Color3.fromRGB(220,220,220)
    themeLabel.BackgroundTransparency = 1
    themeLabel.TextXAlignment = Enum.TextXAlignment.Left

    local themeNames = {"Red","Green","Purple","Yellow","Black","Orange","White","Brown","Pink"}

    local themeBtn = Instance.new("TextButton", row2)
    themeBtn.Size = UDim2.new(0.4, 0, 1, 0)
    themeBtn.Position = UDim2.new(0.6, 0, 0, 0)
    themeBtn.Text = currentTheme
    themeBtn.Font = Enum.Font.GothamBold
    themeBtn.TextSize = 16
    themeBtn.TextColor3 = Color3.fromRGB(220,220,220)
    themeBtn.BackgroundColor3 = Color3.fromRGB(32,32,36)
    themeBtn.BorderSizePixel = 0
    Instance.new("UICorner", themeBtn).CornerRadius = UDim.new(0,4)

    local themeList = Instance.new("Frame", row2)
    themeList.Size = UDim2.new(0.4, 0, 0, #themeNames * 28)
    themeList.Position = UDim2.new(0.6, 0, 1, 2)
    themeList.BackgroundColor3 = Color3.fromRGB(32,32,36)
    themeList.BorderSizePixel = 0
    themeList.Visible = false
    Instance.new("UICorner", themeList).CornerRadius = UDim.new(0,4)

    for i, name in ipairs(themeNames) do
        local opt = Instance.new("TextButton", themeList)
        opt.Size = UDim2.new(1, 0, 0, 28)
        opt.Position = UDim2.new(0, 0, 0, (i-1)*28)
        opt.BackgroundColor3 = Color3.fromRGB(32,32,36)
        opt.BorderSizePixel = 0
        opt.Text = name
        opt.Font = Enum.Font.Gotham
        opt.TextSize = 14
        opt.TextColor3 = Color3.fromRGB(220,220,220)
        Instance.new("UICorner", opt).CornerRadius = UDim.new(0,2)
        opt.MouseButton1Click:Connect(function()
            applyTheme(name)
            themeBtn.Text = name
            themeList.Visible = false
        end)
    end

    themeBtn.MouseButton1Click:Connect(function()
        themeList.Visible = not themeList.Visible
    end)
end

return Eps1llonUI
