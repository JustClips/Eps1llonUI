--// Eps1llon Hub | 2025 | Full UI + Combat: Reach/Hitbox Expander & Auto Hit + Inventory: Smart Grabtools
--// Created by: JustClips | Date: 2025-07-12 00:34:28 UTC | Premium Version

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

--// UI LIBRARY LOAD
local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/JustClips/Eps1llonUI/refs/heads/main/UILibrary.lua"))()
_G.UILib = UILib

--// GUI VISIBILITY TOGGLE SYSTEM
local isGUIVisible = true

local function toggleGUIVisibility()
    if UILib and UILib.MainFrame then
        isGUIVisible = not isGUIVisible
        
        local targetTransparency = isGUIVisible and 0 or 1
        local targetPosition = isGUIVisible and 
            UILib.MainFrame.Position or 
            UDim2.new(UILib.MainFrame.Position.X.Scale, UILib.MainFrame.Position.X.Offset, -2, 0)
        
        -- Smooth animation
        local tween = TweenService:Create(UILib.MainFrame, 
            TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            BackgroundTransparency = targetTransparency,
            Position = targetPosition
        })
        
        tween:Play()
        
        -- Animate all children
        for _, child in pairs(UILib.MainFrame:GetChildren()) do
            if child:IsA("GuiObject") then
                local childTween = TweenService:Create(child,
                    TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Visible = isGUIVisible
                })
                childTween:Play()
            end
        end
        
        print(isGUIVisible and "🔼 Eps1llon Hub Shown" or "🔽 Eps1llon Hub Hidden")
    end
end

-- Insert key toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        toggleGUIVisibility()
    end
end)

--// SECTION/ICON Setup
local sectionNames = {"Configuration","Combat","ESP","Inventory","Misc","UI Settings"}
local iconData = {
    Configuration = "134572329997100",
    Combat        = "94883448905030",
    ESP           = "92313485402528",
    Inventory     = "135628846657243",
    Misc          = "121583805460244",
    ["UI Settings"] = "93991072023597",
}
local sections = {}
for _, name in ipairs(sectionNames) do
    sections[name] = UILib:GetSection(name)
end

--// SECTION HEADERS
for name, section in pairs(sections) do
    for _, c in ipairs(section:GetChildren()) do
        if c:IsA("TextLabel") and c.Name == "__SectionTitle" then c:Destroy() end
        if c:IsA("ImageLabel") and c.Name == "__SectionIcon" then c:Destroy() end
        if c:IsA("Frame") and c.Name == "__SectionHeaderContainer" then c:Destroy() end
    end
    local header = Instance.new("Frame")
    header.Name = "__SectionHeaderContainer"
    header.Size = UDim2.new(1, 0, 0, 38)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundTransparency = 1
    header.Parent = section
    local layout = Instance.new("UIListLayout", header)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 6)
    local icon = Instance.new("ImageLabel")
    icon.Name = "__SectionIcon"
    icon.Size = UDim2.new(0, 28, 0, 28)
    icon.BackgroundTransparency = 1
    icon.Image = iconData[name] and ("rbxassetid://"..iconData[name]) or ""
    icon.ImageColor3 = Color3.fromRGB(74, 177, 255)
    icon.Parent = header
    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Name = "__SectionTitle"
    sectionTitle.Size = UDim2.new(0, 200, 1, 0)
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Text = name
    sectionTitle.TextColor3 = Color3.fromRGB(215, 235, 255)
    sectionTitle.Font = Enum.Font.GothamBold
    sectionTitle.TextSize = 24
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.TextYAlignment = Enum.TextYAlignment.Center
    sectionTitle.Parent = header
end

--------------------------------------------
-- CONFIGURATION TAB: Speedwalk/JumpPower --
--------------------------------------------
local premiumGradientColors = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 170, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(74, 255, 230))
}

local function setupSliderDrag(bar, pill, min, max, onChange)
    local dragging = false
    local function updateInput(input)
        local absPos = pill.AbsolutePosition.X
        local absSize = pill.AbsoluteSize.X
        local percent = math.clamp((input.Position.X - absPos) / absSize, 0, 1)
        local value = math.floor(min + (max - min) * percent + 0.5)
        bar.Size = UDim2.new(percent, 0, 1, 0)
        if onChange then onChange(value, percent) end
    end
    pill.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateInput(input)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateInput(input)
        end
    end)
    pill.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Speedwalk
local speedwalkEnabled, currentSpeed = false, 12
do
    local section = sections["Configuration"]
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -40, 0, 54)
    row.Position = UDim2.new(0, 20, 0, 50)
    row.BackgroundColor3 = Color3.fromRGB(26, 28, 33)
    row.BackgroundTransparency = 0.08
    row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 13)
    row.Parent = section
    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0, 115, 1, 0)
    label.Position = UDim2.new(0, 13, 0, 0)
    label.Text = "Walkspeed"
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    local min, max, default = 4, 15, 12
    local sliderPill = Instance.new("Frame", row)
    sliderPill.Size = UDim2.new(0, 170, 0, 36)
    sliderPill.Position = UDim2.new(0, 132, 0.5, -18)
    sliderPill.BackgroundColor3 = Color3.fromRGB(33, 41, 57)
    sliderPill.BorderSizePixel = 0
    Instance.new("UICorner", sliderPill).CornerRadius = UDim.new(1, 999)
    local pillShadow = Instance.new("ImageLabel", sliderPill)
    pillShadow.BackgroundTransparency = 1
    pillShadow.Image = "rbxassetid://1316045217"
    pillShadow.Size = UDim2.new(1, 8, 1, 8)
    pillShadow.Position = UDim2.new(0, -4, 0, -2)
    pillShadow.ImageTransparency = 0.78
    pillShadow.ZIndex = 0
    local sliderFill = Instance.new("Frame", sliderPill)
    sliderFill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(80, 170, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.ZIndex = 2
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 999)
    local grad = Instance.new("UIGradient", sliderFill)
    grad.Color = premiumGradientColors
    local valueLabel = Instance.new("TextLabel", sliderPill)
    valueLabel.Size = UDim2.new(0, 48, 1, 0)
    valueLabel.Position = UDim2.new(1, -50, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(220, 240, 255)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 18
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 3
    setupSliderDrag(sliderFill, sliderPill, min, max, function(val, percent)
        currentSpeed = val
        valueLabel.Text = tostring(val)
    end)
    local togglePill = Instance.new("Frame", row)
    togglePill.Size = UDim2.new(0, 72, 0, 36)
    togglePill.Position = UDim2.new(0, 314, 0.5, -18)
    togglePill.BackgroundColor3 = Color3.fromRGB(33, 41, 57)
    togglePill.BorderSizePixel = 0
    Instance.new("UICorner", togglePill).CornerRadius = UDim.new(1, 999)
    local toggleOn = false
    local toggleBar = Instance.new("Frame", togglePill)
    toggleBar.Size = UDim2.new(0, 46, 0, 20)
    toggleBar.Position = UDim2.new(0, 13, 0.5, -10)
    toggleBar.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
    toggleBar.BorderSizePixel = 0
    Instance.new('UICorner', toggleBar).CornerRadius = UDim.new(1, 999)
    local toggleKnob = Instance.new("Frame", toggleBar)
    toggleKnob.Size = UDim2.new(0, 18, 0, 18)
    toggleKnob.Position = UDim2.new(0, 1, 0, 1)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(245,245,250)
    toggleKnob.BorderSizePixel = 0
    Instance.new('UICorner', toggleKnob).CornerRadius = UDim.new(1, 999)
    local function setToggle(val)
        toggleOn = val
        speedwalkEnabled = val
        toggleBar.BackgroundColor3 = val and Color3.fromRGB(80, 170, 255) or Color3.fromRGB(22, 28, 38)
        toggleKnob.Position = val and UDim2.new(1, -19, 0, 1) or UDim2.new(0, 1, 0, 1)
    end
    setToggle(false)
    toggleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            setToggle(not toggleOn)
        end
    end)
    toggleBar.TouchTap:Connect(function() setToggle(not toggleOn) end)
end

RunService.RenderStepped:Connect(function(dt)
    if speedwalkEnabled then
        local c = player.Character
        if c then
            local h = c:FindFirstChildOfClass("Humanoid")
            local r = c:FindFirstChild("HumanoidRootPart")
            if h and r then
                local d = h.MoveDirection
                if d.Magnitude > .1 then
                    r.CFrame += d.Unit * currentSpeed * dt
                end
            end
        end
    end
end)

-- JumpPower
local jumppowerEnabled, currentJump, lastJump = false, 50, 0
do
    local section = sections["Configuration"]
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -40, 0, 54)
    row.Position = UDim2.new(0, 20, 0, 110)
    row.BackgroundColor3 = Color3.fromRGB(26, 28, 33)
    row.BackgroundTransparency = 0.08
    row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 13)
    row.Parent = section
    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0, 115, 1, 0)
    label.Position = UDim2.new(0, 13, 0, 0)
    label.Text = "JumpPower"
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    local min, max, default = 5, 100, 50
    local sliderPill = Instance.new("Frame", row)
    sliderPill.Size = UDim2.new(0, 170, 0, 36)
    sliderPill.Position = UDim2.new(0, 132, 0.5, -18)
    sliderPill.BackgroundColor3 = Color3.fromRGB(33, 41, 57)
    sliderPill.BorderSizePixel = 0
    Instance.new("UICorner", sliderPill).CornerRadius = UDim.new(1, 999)
    local pillShadow = Instance.new("ImageLabel", sliderPill)
    pillShadow.BackgroundTransparency = 1
    pillShadow.Image = "rbxassetid://1316045217"
    pillShadow.Size = UDim2.new(1, 8, 1, 8)
    pillShadow.Position = UDim2.new(0, -4, 0, -2)
    pillShadow.ImageTransparency = 0.78
    pillShadow.ZIndex = 0
    local sliderFill = Instance.new("Frame", sliderPill)
    sliderFill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(80, 170, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.ZIndex = 2
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 999)
    local grad = Instance.new("UIGradient", sliderFill)
    grad.Color = premiumGradientColors
    local valueLabel = Instance.new("TextLabel", sliderPill)
    valueLabel.Size = UDim2.new(0, 48, 1, 0)
    valueLabel.Position = UDim2.new(1, -50, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(220, 240, 255)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 18
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 3
    setupSliderDrag(sliderFill, sliderPill, min, max, function(val, percent)
        currentJump = val
        valueLabel.Text = tostring(val)
    end)
    local togglePill = Instance.new("Frame", row)
    togglePill.Size = UDim2.new(0, 72, 0, 36)
    togglePill.Position = UDim2.new(0, 314, 0.5, -18)
    togglePill.BackgroundColor3 = Color3.fromRGB(33, 41, 57)
    togglePill.BorderSizePixel = 0
    Instance.new("UICorner", togglePill).CornerRadius = UDim.new(1, 999)
    local toggleOn = false
    local toggleBar = Instance.new("Frame", togglePill)
    toggleBar.Size = UDim2.new(0, 46, 0, 20)
    toggleBar.Position = UDim2.new(0, 13, 0.5, -10)
    toggleBar.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
    toggleBar.BorderSizePixel = 0
    Instance.new('UICorner', toggleBar).CornerRadius = UDim.new(1, 999)
    local toggleKnob = Instance.new("Frame", toggleBar)
    toggleKnob.Size = UDim2.new(0, 18, 0, 18)
    toggleKnob.Position = UDim2.new(0, 1, 0, 1)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(245,245,250)
    toggleKnob.BorderSizePixel = 0
    Instance.new('UICorner', toggleKnob).CornerRadius = UDim.new(1, 999)
    local function setToggle(val)
        toggleOn = val
        jumppowerEnabled = val
        toggleBar.BackgroundColor3 = val and Color3.fromRGB(80, 170, 255) or Color3.fromRGB(22, 28, 38)
        toggleKnob.Position = val and UDim2.new(1, -19, 0, 1) or UDim2.new(0, 1, 0, 1)
    end
    setToggle(false)
    toggleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            setToggle(not toggleOn)
        end
    end)
    toggleBar.TouchTap:Connect(function() setToggle(not toggleOn) end)
end

RunService.RenderStepped:Connect(function()
    if jumppowerEnabled then
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoid and rootPart and humanoid:GetState() == Enum.HumanoidStateType.Jumping then
                if tick() - lastJump > 0.15 then
                    rootPart.Velocity = Vector3.new(rootPart.Velocity.X, currentJump, rootPart.Velocity.Z)
                    lastJump = tick()
                end
            end
        end
    end
end)

-----------------------------------------------
-- COMBAT TAB: Reach/Hitbox Expander (Slider) --
-----------------------------------------------
local reachEnabled, reachRadius = false, 12
local autoHitEnabled = false
do
    local section = sections["Combat"]
    -- Reach/Hitbox Row
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -40, 0, 54)
    row.Position = UDim2.new(0, 20, 0, 50)
    row.BackgroundColor3 = Color3.fromRGB(26, 28, 33)
    row.BackgroundTransparency = 0.08
    row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 13)
    row.Parent = section
    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0, 145, 1, 0)
    label.Position = UDim2.new(0, 13, 0, 0)
    label.Text = "Reach Radius"
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    local min, max, default = 5, 15, 12
    local sliderPill = Instance.new("Frame", row)
    sliderPill.Size = UDim2.new(0, 170, 0, 36)
    sliderPill.Position = UDim2.new(0, 162, 0.5, -18)
    sliderPill.BackgroundColor3 = Color3.fromRGB(33, 41, 57)
    sliderPill.BorderSizePixel = 0
    Instance.new("UICorner", sliderPill).CornerRadius = UDim.new(1, 999)
    local pillShadow = Instance.new("ImageLabel", sliderPill)
    pillShadow.BackgroundTransparency = 1
    pillShadow.Image = "rbxassetid://1316045217"
    pillShadow.Size = UDim2.new(1, 8, 1, 8)
    pillShadow.Position = UDim2.new(0, -4, 0, -2)
    pillShadow.ImageTransparency = 0.78
    pillShadow.ZIndex = 0
    local sliderFill = Instance.new("Frame", sliderPill)
    sliderFill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(80, 170, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.ZIndex = 2
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 999)
    local grad = Instance.new("UIGradient", sliderFill)
    grad.Color = premiumGradientColors
    local valueLabel = Instance.new("TextLabel", sliderPill)
    valueLabel.Size = UDim2.new(0, 48, 1, 0)
    valueLabel.Position = UDim2.new(1, -50, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(220, 240, 255)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 18
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 3
    setupSliderDrag(sliderFill, sliderPill, min, max, function(val, percent)
        reachRadius = val
        valueLabel.Text = tostring(val)
    end)
    local togglePill = Instance.new("Frame", row)
    togglePill.Size = UDim2.new(0, 72, 0, 36)
    togglePill.Position = UDim2.new(0, 344, 0.5, -18)
    togglePill.BackgroundColor3 = Color3.fromRGB(33, 41, 57)
    togglePill.BorderSizePixel = 0
    Instance.new("UICorner", togglePill).CornerRadius = UDim.new(1, 999)
    local toggleOn = false
    local toggleBar = Instance.new("Frame", togglePill)
    toggleBar.Size = UDim2.new(0, 46, 0, 20)
    toggleBar.Position = UDim2.new(0, 13, 0.5, -10)
    toggleBar.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
    toggleBar.BorderSizePixel = 0
    Instance.new('UICorner', toggleBar).CornerRadius = UDim.new(1, 999)
    local toggleKnob = Instance.new("Frame", toggleBar)
    toggleKnob.Size = UDim2.new(0, 18, 0, 18)
    toggleKnob.Position = UDim2.new(0, 1, 0, 1)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(245,245,250)
    toggleKnob.BorderSizePixel = 0
    Instance.new('UICorner', toggleKnob).CornerRadius = UDim.new(1, 999)
    local function setToggle(val)
        toggleOn = val
        reachEnabled = val
        toggleBar.BackgroundColor3 = val and Color3.fromRGB(80, 170, 255) or Color3.fromRGB(22, 28, 38)
        toggleKnob.Position = val and UDim2.new(1, -19, 0, 1) or UDim2.new(0, 1, 0, 1)
    end
    setToggle(false)
    toggleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            setToggle(not toggleOn)
        end
    end)
    toggleBar.TouchTap:Connect(function() setToggle(not toggleOn) end)

    -- "Auto Hit" toggle directly below
    local row2 = Instance.new("Frame")
    row2.Size = UDim2.new(1, -40, 0, 54)
    row2.Position = UDim2.new(0, 20, 0, 110)
    row2.BackgroundColor3 = Color3.fromRGB(26, 28, 33)
    row2.BackgroundTransparency = 0.08
    row2.BorderSizePixel = 0
    Instance.new("UICorner", row2).CornerRadius = UDim.new(0, 13)
    row2.Parent = section
    local label2 = Instance.new("TextLabel", row2)
    label2.Size = UDim2.new(0, 145, 1, 0)
    label2.Position = UDim2.new(0, 13, 0, 0)
    label2.Text = "Auto Hit"
    label2.TextColor3 = Color3.fromRGB(230, 230, 240)
    label2.BackgroundTransparency = 1
    label2.Font = Enum.Font.GothamBold
    label2.TextSize = 18
    label2.TextXAlignment = Enum.TextXAlignment.Left
    local togglePill2 = Instance.new("Frame", row2)
    togglePill2.Size = UDim2.new(0, 72, 0, 36)
    togglePill2.Position = UDim2.new(0, 162, 0.5, -18)
    togglePill2.BackgroundColor3 = Color3.fromRGB(33, 41, 57)
    togglePill2.BorderSizePixel = 0
    Instance.new("UICorner", togglePill2).CornerRadius = UDim.new(1, 999)
    local toggleBar2 = Instance.new("Frame", togglePill2)
    toggleBar2.Size = UDim2.new(0, 46, 0, 20)
    toggleBar2.Position = UDim2.new(0, 13, 0.5, -10)
    toggleBar2.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
    toggleBar2.BorderSizePixel = 0
    Instance.new('UICorner', toggleBar2).CornerRadius = UDim.new(1, 999)
    local toggleKnob2 = Instance.new("Frame", toggleBar2)
    toggleKnob2.Size = UDim2.new(0, 18, 0, 18)
    toggleKnob2.Position = UDim2.new(0, 1, 0, 1)
    toggleKnob2.BackgroundColor3 = Color3.fromRGB(245,245,250)
    toggleKnob2.BorderSizePixel = 0
    Instance.new('UICorner', toggleKnob2).CornerRadius = UDim.new(1, 999)
    local function setAutoHit(val)
        autoHitEnabled = val
        toggleBar2.BackgroundColor3 = val and Color3.fromRGB(80, 170, 255) or Color3.fromRGB(22, 28, 38)
        toggleKnob2.Position = val and UDim2.new(1, -19, 0, 1) or UDim2.new(0, 1, 0, 1)
    end
    setAutoHit(false)
    toggleBar2.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            setAutoHit(not autoHitEnabled)
        end
    end)
    toggleBar2.TouchTap:Connect(function() setAutoHit(not autoHitEnabled) end)
end

--// HITBOX EXPANDER MECHANIC
local function expandHitbox(tool)
    local hitbox = tool:FindFirstChild("Hitbox", true)
    local handle = tool:FindFirstChild("Handle")
    if hitbox and handle and hitbox:IsA("BasePart") and handle:IsA("BasePart") then
        hitbox.Size         = Vector3.new(reachRadius*2, reachRadius*2, reachRadius*2)
        hitbox.Massless     = true
        hitbox.CanCollide   = false
        hitbox.Transparency = 1
        for _,c in ipairs(hitbox:GetChildren()) do
            if c:IsA("SpecialMesh") or c:IsA("Weld") or c:IsA("WeldConstraint") or c:IsA("BoxHandleAdornment") then
                c:Destroy()
            end
        end
        local weld = Instance.new("WeldConstraint")
        weld.Part0  = handle
        weld.Part1  = hitbox
        weld.Parent = hitbox
    end
end

local function trackTool(tool)
    expandHitbox(tool)
    if tool:IsA("Tool") then
        tool.Equipped:Connect(function() expandHitbox(tool) end)
        tool.Unequipped:Connect(function() expandHitbox(tool) end)
    end
end

local function updateHitboxes()
    if player.Character then
        for _,tool in ipairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") then expandHitbox(tool) end
        end
    end
end

local function initHitboxSystem()
    if player.Character then
        for _,tool in ipairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") then trackTool(tool) end
        end
        player.Character.ChildAdded:Connect(function(c)
            if c:IsA("Tool") then wait(0.1) trackTool(c) end
        end)
    end
    player.CharacterAdded:Connect(function(ch)
        for _,tool in ipairs(ch:GetChildren()) do
            if tool:IsA("Tool") then trackTool(tool) end
        end
        ch.ChildAdded:Connect(function(c)
            if c:IsA("Tool") then wait(0.1) trackTool(c) end
        end)
    end)
end

-- Enable/Disable system (runs only if enabled)
local hitboxConn
local function enableReachSystem(val)
    if val then
        if not hitboxConn then
            hitboxConn = RunService.RenderStepped:Connect(updateHitboxes)
        end
        initHitboxSystem()
    else
        if hitboxConn then hitboxConn:Disconnect() hitboxConn = nil end
    end
end

-- Toggle logic (auto-updates)
coroutine.wrap(function()
    local prevEnabled = false
    while true do
        if reachEnabled ~= prevEnabled then
            enableReachSystem(reachEnabled)
            prevEnabled = reachEnabled
        end
        wait(0.22)
    end
end)()

------------------------------------------------
-- COMBAT: AUTO HIT SYSTEM
------------------------------------------------
coroutine.wrap(function()
    while true do
        if autoHitEnabled and player.Character then
            local tool = nil
            for _,v in ipairs(player.Character:GetChildren()) do
                if v:IsA("Tool") and v:FindFirstChild("Handle") then
                    tool = v
                    break
                end
            end
            if tool and tool.Activate then
                pcall(function() tool:Activate() end)
            end
        end
        wait(0.12)
    end
end)()

-----------------------------------------------
-- INVENTORY TAB: Smart Grabtools System --
-----------------------------------------------
local targetToolNames = {}
local grabtoolsConnection = nil
local toolCountDisplay = nil
local toolListFrame = nil
local toolListLabels = {}

-- Helper function to check if tool should be picked up (ONLY if input box has content)
local function shouldPickupTool(toolName)
    if #targetToolNames == 0 then
        return false -- DON'T pick up anything if input box is empty
    end
    for _, targetName in ipairs(targetToolNames) do
        if string.lower(toolName):find(string.lower(targetName)) then
            return true
        end
    end
    return false
end

-- Function to parse comma-separated tool names
local function parseToolNames(inputText)
    local names = {}
    if inputText == "" then return names end
    for name in string.gmatch(inputText, "([^,]+)") do
        local trimmedName = string.match(name, "^%s*(.-)%s*$")
        if trimmedName ~= "" then
            table.insert(names, trimmedName)
        end
    end
    return names
end

-- Function to get tool counts in workspace
local function getToolCounts()
    local toolCounts = {}
    local totalTools = 0
    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("Tool") and child:FindFirstChild("Handle") then
            local toolName = child.Name
            toolCounts[toolName] = (toolCounts[toolName] or 0) + 1
            totalTools = totalTools + 1
        end
    end
    return toolCounts, totalTools
end

-- Function to equip ONE specific tool (for clicking)
local function equipSpecificTool(toolName)
    if not player.Character then return false end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    
    -- Find the FIRST tool with this name and grab it
    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("Tool") and child:FindFirstChild("Handle") and child.Name == toolName then
            humanoid:EquipTool(child)
            print("✅ Grabbed one " .. toolName)
            return true
        end
    end
    return false
end

-- Function to equip tools automatically (ONLY if input box has content)
local function equipTools()
    if #targetToolNames == 0 then return end -- DON'T grab anything if empty
    if not player.Character then return end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    for _, child in ipairs(workspace:GetChildren()) do
        if player.Character and child:IsA("Tool") and child:FindFirstChild("Handle") then
            if shouldPickupTool(child.Name) then
                humanoid:EquipTool(child)
                wait(0.05) -- Small delay to prevent lag
            end
        end
    end
end

-- Update tool count display
local function updateToolCountDisplay()
    if not toolCountDisplay then return end
    
    local toolCounts, totalTools = getToolCounts()
    
    if totalTools > 0 then
        local targetText = #targetToolNames > 0 and " (Targeting: " .. #targetToolNames .. ")" or ""
        toolCountDisplay.Text = "Tools Available: " .. totalTools .. targetText
        toolCountDisplay.TextColor3 = Color3.fromRGB(74, 177, 255)
    else
        toolCountDisplay.Text = "No Tools Available"
        toolCountDisplay.TextColor3 = Color3.fromRGB(120, 120, 120)
    end
end

-- Update tool list display (FIXED TO FIT WITHIN BLUE BORDER)
local function updateToolList()
    if not toolListFrame then return end
    
    -- Clear existing labels
    for _, label in pairs(toolListLabels) do
        if label then
            label:Destroy()
        end
    end
    toolListLabels = {}
    
    local toolCounts, totalTools = getToolCounts()
    local yOffset = 5
    
    if totalTools == 0 then
        local noToolsLabel = Instance.new("TextLabel")
        noToolsLabel.Size = UDim2.new(1, -10, 0, 20)
        noToolsLabel.Position = UDim2.new(0, 5, 0, yOffset)
        noToolsLabel.Text = "No tools found in workspace"
        noToolsLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
        noToolsLabel.BackgroundTransparency = 1
        noToolsLabel.Font = Enum.Font.Gotham
        noToolsLabel.TextSize = 12
        noToolsLabel.TextXAlignment = Enum.TextXAlignment.Center
        noToolsLabel.Parent = toolListFrame
        table.insert(toolListLabels, noToolsLabel)
        return
    end
    
    -- Sort tools alphabetically
    local sortedTools = {}
    for toolName, count in pairs(toolCounts) do
        table.insert(sortedTools, {name = toolName, count = count})
    end
    table.sort(sortedTools, function(a, b) return a.name < b.name end)
    
    -- LIMIT TO FIRST 5 TOOLS TO FIT WITHIN BLUE BORDER PROPERLY
    local maxItems = 5
    local itemsToShow = math.min(#sortedTools, maxItems)
    
    -- Create tool list items
    for i = 1, itemsToShow do
        local toolData = sortedTools[i]
        local itemFrame = Instance.new("TextButton")
        itemFrame.Size = UDim2.new(1, -10, 0, 18) -- SMALLER HEIGHT
        itemFrame.Position = UDim2.new(0, 5, 0, yOffset)
        itemFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 26)
        itemFrame.BackgroundTransparency = 0.3
        itemFrame.BorderSizePixel = 0
        itemFrame.Text = ""
        Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 4)
        itemFrame.Parent = toolListFrame
        
        local toolNameLabel = Instance.new("TextLabel")
        toolNameLabel.Size = UDim2.new(1, -35, 1, 0)
        toolNameLabel.Position = UDim2.new(0, 5, 0, 0)
        toolNameLabel.Text = toolData.name
        toolNameLabel.TextColor3 = shouldPickupTool(toolData.name) and Color3.fromRGB(74, 177, 255) or Color3.fromRGB(200, 200, 200)
        toolNameLabel.BackgroundTransparency = 1
        toolNameLabel.Font = Enum.Font.Gotham
        toolNameLabel.TextSize = 10 -- SMALLER TEXT
        toolNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        toolNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        toolNameLabel.Parent = itemFrame
        
        local countLabel = Instance.new("TextLabel")
        countLabel.Size = UDim2.new(0, 30, 1, 0)
        countLabel.Position = UDim2.new(1, -30, 0, 0)
        countLabel.Text = "x" .. toolData.count
        countLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        countLabel.BackgroundTransparency = 1
        countLabel.Font = Enum.Font.GothamBold
        countLabel.TextSize = 9 -- SMALLER TEXT
        countLabel.TextXAlignment = Enum.TextXAlignment.Right
        countLabel.Parent = itemFrame
        
        -- Hover effect
        itemFrame.MouseEnter:Connect(function()
            TweenService:Create(itemFrame, TweenInfo.new(0.15), {BackgroundTransparency = 0.1}):Play()
            TweenService:Create(toolNameLabel, TweenInfo.new(0.15), {TextSize = 11}):Play()
        end)
        itemFrame.MouseLeave:Connect(function()
            TweenService:Create(itemFrame, TweenInfo.new(0.15), {BackgroundTransparency = 0.3}):Play()
            TweenService:Create(toolNameLabel, TweenInfo.new(0.15), {TextSize = 10}):Play()
        end)
        
        -- Click to grab ONE tool
        itemFrame.MouseButton1Click:Connect(function()
            local success = equipSpecificTool(toolData.name)
            if success then
                -- Visual feedback
                TweenService:Create(itemFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(74, 177, 255)}):Play()
                wait(0.1)
                TweenService:Create(itemFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 22, 26)}):Play()
                updateToolList() -- Refresh list after grabbing
            end
        end)
        
        table.insert(toolListLabels, itemFrame)
        yOffset = yOffset + 20 -- SMALLER SPACING
    end
    
    -- Show "... and X more" if there are more tools
    if #sortedTools > maxItems then
        local moreLabel = Instance.new("TextLabel")
        moreLabel.Size = UDim2.new(1, -10, 0, 16)
        moreLabel.Position = UDim2.new(0, 5, 0, yOffset)
        moreLabel.Text = "... and " .. (#sortedTools - maxItems) .. " more tools"
        moreLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
        moreLabel.BackgroundTransparency = 1
        moreLabel.Font = Enum.Font.GothamItalic
        moreLabel.TextSize = 9
        moreLabel.TextXAlignment = Enum.TextXAlignment.Center
        moreLabel.Parent = toolListFrame
        table.insert(toolListLabels, moreLabel)
        yOffset = yOffset + 18
    end
    
    -- Update scrolling frame canvas size
    toolListFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 5)
end

do
    local section = sections["Inventory"]
    
    -- Tool Input Row
    local inputRow = Instance.new("Frame")
    inputRow.Size = UDim2.new(1, -40, 0, 74)
    inputRow.Position = UDim2.new(0, 20, 0, 50)
    inputRow.BackgroundColor3 = Color3.fromRGB(26, 28, 33)
    inputRow.BackgroundTransparency = 0.08
    inputRow.BorderSizePixel = 0
    Instance.new("UICorner", inputRow).CornerRadius = UDim.new(0, 13)
    inputRow.Parent = section
    
    local inputLabel = Instance.new("TextLabel", inputRow)
    inputLabel.Size = UDim2.new(1, -20, 0, 20)
    inputLabel.Position = UDim2.new(0, 13, 0, 8)
    inputLabel.Text = "Target Tools (comma separated, empty = no auto-grab)"
    inputLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    inputLabel.BackgroundTransparency = 1
    inputLabel.Font = Enum.Font.Gotham
    inputLabel.TextSize = 14
    inputLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local toolInput = Instance.new("TextBox", inputRow)
    toolInput.Size = UDim2.new(1, -86, 0, 28)
    toolInput.Position = UDim2.new(0, 13, 0, 32)
    toolInput.PlaceholderText = "e.g: Spear, Stick, Bone"
    toolInput.Text = ""
    toolInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    toolInput.BackgroundColor3 = Color3.fromRGB(33, 41, 57)
    toolInput.BorderSizePixel = 0
    toolInput.Font = Enum.Font.Gotham
    toolInput.TextSize = 16
    toolInput.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", toolInput).CornerRadius = UDim.new(0, 8)
    
    local updateBtn = Instance.new("TextButton", inputRow)
    updateBtn.Size = UDim2.new(0, 60, 0, 28)
    updateBtn.Position = UDim2.new(1, -73, 0, 32)
    updateBtn.Text = "Update"
    updateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    updateBtn.BackgroundColor3 = Color3.fromRGB(80, 170, 255)
    updateBtn.BorderSizePixel = 0
    updateBtn.Font = Enum.Font.GothamBold
    updateBtn.TextSize = 14
    Instance.new("UICorner", updateBtn).CornerRadius = UDim.new(0, 8)
    local updateGrad = Instance.new("UIGradient", updateBtn)
    updateGrad.Color = premiumGradientColors
    
    -- Tool Counter Display Row
    local counterRow = Instance.new("Frame")
    counterRow.Size = UDim2.new(1, -40, 0, 54)
    counterRow.Position = UDim2.new(0, 20, 0, 134)
    counterRow.BackgroundColor3 = Color3.fromRGB(26, 28, 33)
    counterRow.BackgroundTransparency = 0.08
    counterRow.BorderSizePixel = 0
    Instance.new("UICorner", counterRow).CornerRadius = UDim.new(0, 13)
    counterRow.Parent = section
    
    toolCountDisplay = Instance.new("TextLabel", counterRow)
    toolCountDisplay.Size = UDim2.new(0, 280, 1, 0)
    toolCountDisplay.Position = UDim2.new(0, 13, 0, 0)
    toolCountDisplay.Text = "Tools Available: 0"
    toolCountDisplay.TextColor3 = Color3.fromRGB(120, 120, 120)
    toolCountDisplay.BackgroundTransparency = 1
    toolCountDisplay.Font = Enum.Font.GothamBold
    toolCountDisplay.TextSize = 16
    toolCountDisplay.TextXAlignment = Enum.TextXAlignment.Left
    
    local refreshBtn = Instance.new("TextButton", counterRow)
    refreshBtn.Size = UDim2.new(0, 72, 0, 36)
    refreshBtn.Position = UDim2.new(0, 314, 0.5, -18)
    refreshBtn.Text = "Refresh"
    refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(80, 170, 255)
    refreshBtn.BorderSizePixel = 0
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.TextSize = 14
    Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 8)
    local refreshGrad = Instance.new("UIGradient", refreshBtn)
    refreshGrad.Color = premiumGradientColors
    
    -- Tool List Frame (FIXED SIZE TO FIT WITHIN BLUE BORDER)
    toolListFrame = Instance.new("ScrollingFrame")
    toolListFrame.Size = UDim2.new(1, -40, 0, 120) -- REDUCED HEIGHT TO FIT BORDER
    toolListFrame.Position = UDim2.new(0, 20, 0, 198)
    toolListFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 26)
    toolListFrame.BackgroundTransparency = 0.1
    toolListFrame.BorderSizePixel = 0
    toolListFrame.ScrollBarThickness = 3
    toolListFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 170, 255)
    toolListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    toolListFrame.Visible = true
    toolListFrame.Parent = section
    Instance.new("UICorner", toolListFrame).CornerRadius = UDim.new(0, 13)
    
    -- Button Events
    updateBtn.MouseButton1Click:Connect(function()
        targetToolNames = parseToolNames(toolInput.Text)
        local targetText = #targetToolNames > 0 and table.concat(targetToolNames, ", ") or "none (auto-grab disabled)"
        print("🎯 Grabtools target updated: " .. targetText)
        updateToolCountDisplay()
        updateToolList()
    end)
    
    toolInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            targetToolNames = parseToolNames(toolInput.Text)
            updateToolCountDisplay()
            updateToolList()
        end
    end)
    
    refreshBtn.MouseButton1Click:Connect(function()
        updateToolCountDisplay()
        updateToolList()
    end)
    
    -- Initialize the list
    updateToolList()
    
    -- Auto-update tool counter every 3 seconds
    coroutine.wrap(function()
        while true do
            updateToolCountDisplay()
            updateToolList()
            wait(3)
        end
    end)()
    
    -- Always-on grabtools (but only works if input box has content)
    grabtoolsConnection = workspace.ChildAdded:Connect(function(child)
        if player.Character and child:IsA("Tool") and child:FindFirstChild("Handle") then
            if shouldPickupTool(child.Name) then
                wait(0.1)
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:EquipTool(child)
                end
            end
        end
    end)
    
    -- Character respawn handling
    player.CharacterAdded:Connect(function(character)
        wait(1)
        equipTools() -- Only grabs if input box has content
    end)
end

print("🎯 Eps1llon Hub 2025 Loaded Successfully!")
print("📋 Features: Combat (Reach/Auto Hit) + Inventory (Smart Grabtools)")
print("⌨️  Keybinds: Insert = Toggle GUI Visibility")
print("👤 Welcome back, JustClips!")
print("📅 Updated: 2025-07-12 00:34:28 UTC")

--// End of Eps1llon Hub 2025 Premium Script (Fixed Final Version)
