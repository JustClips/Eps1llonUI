--[[ Super Cool Blue Pill UI Library ]]--

local UIS = game:GetService("UserInputService")
local UILibrary = {}
UILibrary.__index = UILibrary

local function create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        inst[k] = v
    end
    return inst
end

-- Theme Colors
local theme = {
    Background = Color3.fromRGB(18, 24, 37),
    Section = Color3.fromRGB(24, 33, 54),
    Accent = Color3.fromRGB(52, 120, 246), -- blue
    Button = Color3.fromRGB(37, 45, 66),
    Text = Color3.fromRGB(230,230,240),
    ToggleOff = Color3.fromRGB(75, 87, 117),
    SliderBG = Color3.fromRGB(34, 41, 61)
}

-- Rounding utility
local function roundify(inst, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 18)
    corner.Parent = inst
end

function UILibrary:CreateWindow(title)
    local self = setmetatable({}, UILibrary)

    -- GUI Base
    local sg = create("ScreenGui", {Name="Eps1llonHub_UI", Parent=game.CoreGui, ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Global})
    local main = create("Frame", {
        Size = UDim2.new(0, 410, 0, 500),
        Position = UDim2.new(0.5, -205, 0.5, -250),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Visible = true,
        Parent = sg
    })
    roundify(main, 16)

    -- Title Bar
    local titleBar = create("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        Parent = main
    })
    roundify(titleBar, 16)
    titleBar.ClipsDescendants = true

    local titleLbl = create("TextLabel", {
        Text = "   " .. (title or "Hub UI"),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar
    })

    -- Resize Handle
    local resize = create("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -20, 1, -20),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        Parent = main
    })
    roundify(resize, 8)
    resize.ZIndex = 4

    -- Dragging window
    do
        local dragging, dragStart, startPos
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = main.Position
            end
        end)
        titleBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    -- Resizing
    do
        local resizing, startPos, startSize, dragStart
        resize.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = true
                dragStart = input.Position
                startPos = main.Position
                startSize = main.Size
            end
        end)
        resize.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = false
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                local newX = math.max(330, startSize.X.Offset + delta.X)
                local newY = math.max(180, startSize.Y.Offset + delta.Y)
                main.Size = UDim2.new(0, newX, 0, newY)
            end
        end)
    end

    -- Section layout
    local scroll = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -54),
        Position = UDim2.new(0, 0, 0, 54),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0,0,0,0),
        ScrollBarThickness = 4,
        Parent = main,
        TopImage = "",
        BottomImage = ""
    })

    -- Toggle visible with Insert
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
            main.Visible = not main.Visible
        end
    end)

    self._main = main
    self._scroll = scroll
    self._sections = {}
    self._nextY = 10
    return self
end

function UILibrary:AddSection(name)
    local section = create("Frame", {
        Size = UDim2.new(1, -28, 0, 44),
        Position = UDim2.new(0, 14, 0, self._nextY),
        BackgroundColor3 = theme.Section,
        BorderSizePixel = 0,
        Parent = self._scroll
    })
    roundify(section, 14)

    local lbl = create("TextLabel", {
        Text = name,
        Size = UDim2.new(1, -24, 0, 30),
        Position = UDim2.new(0, 12, 0, 4),
        BackgroundTransparency = 1,
        TextColor3 = theme.Accent,
        Font = Enum.Font.Gotham,
        TextSize = 19,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section
    })

    self._nextY = self._nextY + 54
    self._scroll.CanvasSize = UDim2.new(0,0,0,self._nextY)
    return section
end

function UILibrary:AddButton(section, text, callback)
    local btn = create("TextButton", {
        Size = UDim2.new(1, -24, 0, 36),
        Position = UDim2.new(0, 12, 0, #section:GetChildren()*38+30),
        BackgroundColor3 = theme.Button,
        Text = text,
        TextColor3 = theme.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 18,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = section
    })
    roundify(btn, 18)
    btn.MouseButton1Click:Connect(callback)
    -- hover effect
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = theme.Accent
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = theme.Button
    end)
    return btn
end

function UILibrary:AddToggle(section, text, callback)
    local toggled = false
    local frame = create("Frame", {
        Size = UDim2.new(1, -24, 0, 36),
        Position = UDim2.new(0, 12, 0, #section:GetChildren()*38+30),
        BackgroundTransparency = 1,
        Parent = section
    })

    -- Pill toggle background
    local bg = create("Frame", {
        Size = UDim2.new(0, 54, 0, 26),
        Position = UDim2.new(1, -62, 0, 5),
        BackgroundColor3 = theme.ToggleOff,
        BorderSizePixel = 0,
        Parent = frame
    })
    roundify(bg, 13)

    -- Blue circle indicator
    local dot = create("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 4, 0.5, -9),
        BackgroundColor3 = Color3.fromRGB(230,230,240),
        BorderSizePixel = 0,
        Parent = bg
    })
    roundify(dot, 9)

    -- Toggle label
    local lbl = create("TextLabel", {
        Text = text,
        Size = UDim2.new(1, -68, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })

    local function setToggle(state)
        toggled = state
        if toggled then
            bg.BackgroundColor3 = theme.Accent
            dot.Position = UDim2.new(1, -22, 0.5, -9)
            dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
        else
            bg.BackgroundColor3 = theme.ToggleOff
            dot.Position = UDim2.new(0, 4, 0.5, -9)
            dot.BackgroundColor3 = Color3.fromRGB(230,230,240)
        end
        callback(toggled)
    end

    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            setToggle(not toggled)
        end
    end)
    lbl.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            setToggle(not toggled)
        end
    end)

    setToggle(false)
    return frame
end

function UILibrary:AddSlider(section, text, min, max, default, callback)
    min, max = min or 0, max or 100
    default = default or min

    local frame = create("Frame", {
        Size = UDim2.new(1, -24, 0, 48),
        Position = UDim2.new(0, 12, 0, #section:GetChildren()*50+30),
        BackgroundTransparency = 1,
        Parent = section
    })

    local lbl = create("TextLabel", {
        Text = text,
        Size = UDim2.new(1, -74, 0, 24),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })

    -- Pill slider
    local sliderBG = create("Frame", {
        Size = UDim2.new(1, -58, 0, 16),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = theme.SliderBG,
        BorderSizePixel = 0,
        Parent = frame
    })
    roundify(sliderBG, 8)

    local fill = create("Frame", {
        Size = UDim2.new((default-min)/(max-min), 0, 1, 0),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        Parent = sliderBG
    })
    roundify(fill, 8)

    local dragBtn = create("TextButton", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new((default-min)/(max-min), -12, 0.5, -12),
        BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = sliderBG
    })
    roundify(dragBtn, 12)

    -- Value label
    local valueLbl = create("TextLabel", {
        Text = tostring(default),
        Size = UDim2.new(0, 48, 0, 24),
        Position = UDim2.new(1, 6, 0, 18),
        BackgroundTransparency = 1,
        TextColor3 = theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = frame
    })

    local val = default
    local function setSlider(x)
        x = math.clamp(x, 0, 1)
        local v = math.floor(min + (max-min)*x + 0.5)
        fill.Size = UDim2.new(x, 0, 1, 0)
        dragBtn.Position = UDim2.new(x, -12, 0.5, -12)
        valueLbl.Text = tostring(v)
        if v ~= val then
            val = v
            callback(v)
        end
    end
    setSlider((default-min)/(max-min))

    local dragging = false
    local function getX(input)
        local rel = input.Position.X - sliderBG.AbsolutePosition.X
        return rel/math.max(1, sliderBG.AbsoluteSize.X)
    end
    dragBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    dragBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    sliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            setSlider(getX(input))
            dragging = true
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setSlider(getX(input))
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return frame
end

return UILibrary
