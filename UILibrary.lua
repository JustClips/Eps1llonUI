--[[ Melonity V2 Inspired Roblox UI Library ]]--

local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Blur = Instance.new("BlurEffect")
Blur.Size = 0
Blur.Parent = game:GetService("Lighting")

local UILibrary = {}
UILibrary.__index = UILibrary

-- Theme
local theme = {
    Accent = Color3.fromRGB(44, 210, 80), -- Melonity green
    TabIdle = Color3.fromRGB(38, 45, 50),
    TabActive = Color3.fromRGB(44, 210, 80),
    TabTextIdle = Color3.fromRGB(170, 255, 180),
    TabTextActive = Color3.fromRGB(255,255,255),
    WindowBG = Color3.fromRGB(24, 27, 32),
    SectionBG = Color3.fromRGB(32, 34, 39),
    Button = Color3.fromRGB(37, 39, 46),
    ToggleOff = Color3.fromRGB(60, 60, 60),
    ToggleOn = Color3.fromRGB(44, 210, 80),
    SliderBG = Color3.fromRGB(40, 42, 50),
    SliderFill = Color3.fromRGB(44, 210, 80),
    Text = Color3.fromRGB(230,240,230),
    Shadow = Color3.fromRGB(10,10,10)
}

local function roundify(inst, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = inst
end

local function shadowify(inst, spread)
    local s = Instance.new("ImageLabel")
    s.BackgroundTransparency = 1
    s.Image = "rbxassetid://1316045217"
    s.Size = UDim2.new(1,spread or 24,1,spread or 24)
    s.Position = UDim2.new(0,-(spread or 12)/2,0,-(spread or 12)/2)
    s.ImageColor3 = theme.Shadow
    s.ImageTransparency = 0.8
    s.ZIndex = inst.ZIndex-1
    s.Parent = inst
end

function UILibrary:CreateWindow(title)
    local self = setmetatable({}, UILibrary)
    local sg = Instance.new("ScreenGui")
    sg.Name = "MelonityUILib"
    sg.Parent = game.CoreGui
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
    sg.ResetOnSpawn = false

    local window = Instance.new("Frame")
    window.Size = UDim2.new(0, 520, 0, 410)
    window.Position = UDim2.new(0.5, -260, 0.5, -205)
    window.BackgroundColor3 = theme.WindowBG
    window.Active = true
    window.Draggable = true
    window.BorderSizePixel = 0
    window.Parent = sg
    window.ZIndex = 10
    roundify(window, 14)
    shadowify(window, 32)

    -- Blur Toggle Button
    local blurBtn = Instance.new("TextButton")
    blurBtn.Size = UDim2.new(0, 42, 0, 42)
    blurBtn.Position = UDim2.new(1, -52, 0, 10)
    blurBtn.BackgroundTransparency = 0.7
    blurBtn.BackgroundColor3 = theme.SectionBG
    blurBtn.Text = "🟢"
    blurBtn.Font = Enum.Font.GothamBold
    blurBtn.TextSize = 20
    blurBtn.TextColor3 = theme.Accent
    blurBtn.Parent = window
    blurBtn.ZIndex = 21
    roundify(blurBtn, 12)

    -- Glass blur toggle logic
    local glassOn = false
    local function setBlur(state)
        glassOn = state
        TweenService:Create(Blur, TweenInfo.new(0.2), {Size = glassOn and 24 or 0}):Play()
        blurBtn.Text = glassOn and "🟢" or "⚪"
        blurBtn.TextColor3 = glassOn and theme.Accent or Color3.fromRGB(180,180,180)
    end
    blurBtn.MouseButton1Click:Connect(function() setBlur(not glassOn) end)
    setBlur(false)

    -- Title
    local titleBar = Instance.new("TextLabel")
    titleBar.BackgroundTransparency = 1
    titleBar.Size = UDim2.new(1, 0, 0, 46)
    titleBar.Position = UDim2.new(0,0,0,0)
    titleBar.Font = Enum.Font.GothamBold
    titleBar.Text = "   " .. (title or "Melonity Hub")
    titleBar.TextColor3 = theme.Accent
    titleBar.TextSize = 24
    titleBar.TextXAlignment = Enum.TextXAlignment.Left
    titleBar.Parent = window
    titleBar.ZIndex = 20

    -- Side tab bar
    local tabbar = Instance.new("Frame")
    tabbar.Size = UDim2.new(0, 110, 1, -32)
    tabbar.Position = UDim2.new(0, 10, 0, 56)
    tabbar.BackgroundTransparency = 0.4
    tabbar.BackgroundColor3 = theme.SectionBG
    tabbar.BorderSizePixel = 0
    tabbar.Parent = window
    tabbar.ZIndex = 12
    roundify(tabbar, 10)

    -- Tabs list
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0,8)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabbar

    -- Main content holder
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -140, 1, -60)
    content.Position = UDim2.new(0, 130, 0, 56)
    content.BackgroundTransparency = 0.55
    content.BackgroundColor3 = theme.SectionBG
    content.BorderSizePixel = 0
    content.Parent = window
    content.ZIndex = 13
    roundify(content, 14)

    -- Tabs logic
    self._tabs = {}
    self._activeTab = nil
    self._tabBar = tabbar
    self._content = content

    function self:AddTab(tabname)
        local tab = {}
        tab.Button = Instance.new("TextButton")
        tab.Button.Size = UDim2.new(1, -8, 0, 42)
        tab.Button.BackgroundColor3 = theme.TabIdle
        tab.Button.TextColor3 = theme.TabTextIdle
        tab.Button.Font = Enum.Font.GothamBold
        tab.Button.Text = tabname
        tab.Button.TextSize = 18
        tab.Button.BorderSizePixel = 0
        tab.Button.Parent = tabbar
        tab.Button.ZIndex = 13
        roundify(tab.Button, 8)

        tab.Holder = Instance.new("Frame")
        tab.Holder.BackgroundTransparency = 1
        tab.Holder.Size = UDim2.new(1,0,1,0)
        tab.Holder.Visible = false
        tab.Holder.Parent = content
        tab.Holder.ZIndex = 14

        tab._sections = {}
        tab._nextY = 18

        -- Tab switch logic
        tab.Button.MouseButton1Click:Connect(function()
            for _, t in pairs(self._tabs) do
                t.Button.BackgroundColor3 = theme.TabIdle
                t.Button.TextColor3 = theme.TabTextIdle
                t.Holder.Visible = false
            end
            tab.Button.BackgroundColor3 = theme.TabActive
            tab.Button.TextColor3 = theme.TabTextActive
            tab.Holder.Visible = true
            self._activeTab = tab
        end)

        table.insert(self._tabs, tab)

        -- Auto-select first tab
        if #self._tabs == 1 then
            tab.Button.BackgroundColor3 = theme.TabActive
            tab.Button.TextColor3 = theme.TabTextActive
            tab.Holder.Visible = true
            self._activeTab = tab
        end

        function tab:AddSection(secname)
            local section = {}
            section.Frame = Instance.new("Frame")
            section.Frame.Size = UDim2.new(1, -28, 0, 44)
            section.Frame.Position = UDim2.new(0, 14, 0, tab._nextY)
            section.Frame.BackgroundColor3 = theme.WindowBG
            section.Frame.BorderSizePixel = 0
            section.Frame.Parent = tab.Holder
            section.Frame.ZIndex = 15
            roundify(section.Frame, 10)

            local lbl = Instance.new("TextLabel")
            lbl.Text = secname
            lbl.Size = UDim2.new(1, -16, 0, 28)
            lbl.Position = UDim2.new(0, 12, 0, 6)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = theme.Accent
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 18
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = section.Frame
            lbl.ZIndex = 16

            section._nextY = 38
            section._frame = section.Frame

            -- Control adding
            function section:AddButton(text, callback)
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -24, 0, 36)
                btn.Position = UDim2.new(0, 12, 0, section._nextY)
                btn.BackgroundColor3 = theme.Button
                btn.Text = text
                btn.TextColor3 = theme.Text
                btn.Font = Enum.Font.GothamSemibold
                btn.TextSize = 16
                btn.BorderSizePixel = 0
                btn.AutoButtonColor = false
                btn.Parent = section.Frame
                btn.ZIndex = 17
                roundify(btn, 10)
                btn.MouseButton1Click:Connect(callback)
                btn.MouseEnter:Connect(function() btn.BackgroundColor3 = theme.Accent end)
                btn.MouseLeave:Connect(function() btn.BackgroundColor3 = theme.Button end)
                section._nextY = section._nextY + 40
                return btn
            end

            function section:AddToggle(text, callback)
                local toggled = false
                local toggleBG = Instance.new("Frame")
                toggleBG.Size = UDim2.new(0, 44, 0, 22)
                toggleBG.Position = UDim2.new(1, -54, 0, section._nextY+8)
                toggleBG.BackgroundColor3 = theme.ToggleOff
                toggleBG.BorderSizePixel = 0
                toggleBG.Parent = section.Frame
                toggleBG.ZIndex = 17
                roundify(toggleBG, 11)

                local dot = Instance.new("Frame")
                dot.Size = UDim2.new(0, 16, 0, 16)
                dot.Position = UDim2.new(0, 3, 0.5, -8)
                dot.BackgroundColor3 = Color3.fromRGB(240,240,240)
                dot.BorderSizePixel = 0
                dot.Parent = toggleBG
                dot.ZIndex = 18
                roundify(dot, 8)

                local lbl = Instance.new("TextLabel")
                lbl.Text = text
                lbl.Size = UDim2.new(1, -62, 0, 24)
                lbl.Position = UDim2.new(0, 10, 0, section._nextY+5)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = theme.Text
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 16
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = section.Frame
                lbl.ZIndex = 17

                local function setToggle(state)
                    toggled = state
                    if toggled then
                        toggleBG.BackgroundColor3 = theme.ToggleOn
                        dot.Position = UDim2.new(1, -19, 0.5, -8)
                        dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
                    else
                        toggleBG.BackgroundColor3 = theme.ToggleOff
                        dot.Position = UDim2.new(0, 3, 0.5, -8)
                        dot.BackgroundColor3 = Color3.fromRGB(240,240,240)
                    end
                    callback(toggled)
                end

                toggleBG.InputBegan:Connect(function(input)
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
                section._nextY = section._nextY + 36
                return toggleBG
            end

            function section:AddSlider(text, min, max, default, callback)
                min, max = min or 0, max or 100
                default = default or min
                local lbl = Instance.new("TextLabel")
                lbl.Text = text
                lbl.Size = UDim2.new(1, -70, 0, 24)
                lbl.Position = UDim2.new(0, 10, 0, section._nextY+8)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = theme.Text
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 16
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = section.Frame
                lbl.ZIndex = 17

                local sliderBG = Instance.new("Frame")
                sliderBG.Size = UDim2.new(1, -90, 0, 16)
                sliderBG.Position = UDim2.new(0, 10, 0, section._nextY+30)
                sliderBG.BackgroundColor3 = theme.SliderBG
                sliderBG.BorderSizePixel = 0
                sliderBG.Parent = section.Frame
                sliderBG.ZIndex = 17
                roundify(sliderBG, 8)

                local fill = Instance.new("Frame")
                fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
                fill.BackgroundColor3 = theme.SliderFill
                fill.BorderSizePixel = 0
                fill.Parent = sliderBG
                fill.ZIndex = 18
                roundify(fill, 8)

                local dragBtn = Instance.new("TextButton")
                dragBtn.Size = UDim2.new(0, 22, 0, 22)
                dragBtn.Position = UDim2.new((default-min)/(max-min), -11, 0.5, -11)
                dragBtn.BackgroundColor3 = theme.SliderFill
                dragBtn.BorderSizePixel = 0
                dragBtn.Text = ""
                dragBtn.AutoButtonColor = false
                dragBtn.Parent = sliderBG
                dragBtn.ZIndex = 19
                roundify(dragBtn, 11)

                local valueLbl = Instance.new("TextLabel")
                valueLbl.Text = tostring(default)
                valueLbl.Size = UDim2.new(0, 40, 0, 22)
                valueLbl.Position = UDim2.new(1, 8, 0, section._nextY+26)
                valueLbl.BackgroundTransparency = 1
                valueLbl.TextColor3 = theme.Accent
                valueLbl.Font = Enum.Font.GothamBold
                valueLbl.TextSize = 16
                valueLbl.TextXAlignment = Enum.TextXAlignment.Right
                valueLbl.Parent = section.Frame
                valueLbl.ZIndex = 17

                local val = default
                local function setSlider(x)
                    x = math.clamp(x, 0, 1)
                    local v = math.floor(min + (max-min)*x + 0.5)
                    fill.Size = UDim2.new(x, 0, 1, 0)
                    dragBtn.Position = UDim2.new(x, -11, 0.5, -11)
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

                section._nextY = section._nextY + 52
                return sliderBG
            end

            tab._nextY = tab._nextY + section._nextY + 8
            return section
        end

        return tab
    end

    -- Insert key toggles visibility
    UIS.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.Insert then
            window.Visible = not window.Visible
        end
    end)

    -- Clean up blur if GUI closes/destroys
    sg.AncestryChanged:Connect(function()
        if not sg:IsDescendantOf(game) then
            Blur.Size = 0
            Blur:Destroy()
        end
    end)

    return self
end

return UILibrary
