--[[
    CensuraDev Components Module
    Version: 4.1
    
    Modern military-tech inspired UI components
]]

local Components = {}

-- Services
local Services = {
    Tween = game:GetService("TweenService"),
    Input = game:GetService("UserInputService"),
    Run = game:GetService("RunService")
}

local Timing = {
    Quick = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Normal = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
}

local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

-- Button Component
function Components.createButton(parent, text, callback)
    local System = getgenv().CensuraSystem
    if not System then return end
    
    local button = Create("TextButton", {
        Name = "Button",
        Size = System.UI.ButtonSize,
        BackgroundColor3 = System.Colors.Background,
        BackgroundTransparency = 0.9, -- More transparent background
        Text = text,
        TextColor3 = System.Colors.Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        AutoButtonColor = false,
        Parent = parent
    })
    
    -- Minimal corner radius
    Create("UICorner", {
        CornerRadius = UDim.new(0, 2),
        Parent = button
    })
    
    -- Sleek border
    local stroke = Create("UIStroke", {
        Color = System.Colors.Accent,
        Transparency = 0.8,
        Thickness = 1,
        Parent = button
    })
    
    -- Hover Effects
    button.MouseEnter:Connect(function()
        Services.Tween:Create(stroke, Timing.Normal, {
            Transparency = 0.2
        }):Play()
        Services.Tween:Create(button, Timing.Normal, {
            BackgroundTransparency = 0.7
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        Services.Tween:Create(stroke, Timing.Normal, {
            Transparency = 0.8
        }):Play()
        Services.Tween:Create(button, Timing.Normal, {
            BackgroundTransparency = 0.9
        }):Play()
    end)
    
    -- Click Effect
    button.MouseButton1Down:Connect(function()
        Services.Tween:Create(button, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.5
        }):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        Services.Tween:Create(button, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.7
        }):Play()
        if typeof(callback) == "function" then
            callback()
        end
    end)
    
    return button
end

-- Toggle Component
function Components.createToggle(parent, text, default, callback)
    local System = getgenv().CensuraSystem
    if not System then return end
    
    local container = Create("Frame", {
        Name = "ToggleContainer",
        Size = System.UI.ButtonSize,
        BackgroundColor3 = System.Colors.Background,
        BackgroundTransparency = 0.9,
        Parent = parent
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 2),
        Parent = container
    })
    
    local stroke = Create("UIStroke", {
        Color = System.Colors.Accent,
        Transparency = 0.8,
        Thickness = 1,
        Parent = container
    })
    
    local label = Create("TextLabel", {
        Name = "Label",
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -44, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = System.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Parent = container
    })
    
    -- Modern toggle design
    local toggleFrame = Create("Frame", {
        Name = "ToggleFrame",
        Position = UDim2.new(1, -34, 0.5, -8),
        Size = UDim2.new(0, 24, 0, 16),
        BackgroundColor3 = default and System.Colors.Enabled or System.Colors.Background,
        BackgroundTransparency = 0.5,
        Parent = container
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = toggleFrame
    })
    
    local toggleKnob = Create("Frame", {
        Name = "Knob",
        Position = default and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
        Size = UDim2.new(0, 12, 0, 12),
        BackgroundColor3 = System.Colors.Text,
        Parent = toggleFrame
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = toggleKnob
    })
    
    local enabled = default or false
    
    toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            enabled = not enabled
            
            -- Animate toggle
            local targetPos = enabled and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
            local targetColor = enabled and System.Colors.Enabled or System.Colors.Background
            
            Services.Tween:Create(toggleKnob, TweenInfo.new(0.2), {
                Position = targetPos
            }):Play()
            
            Services.Tween:Create(toggleFrame, TweenInfo.new(0.2), {
                BackgroundColor3 = targetColor
            }):Play()
            
            if typeof(callback) == "function" then
                callback(enabled)
            end
        end
    end)
    
    return container
end

-- Slider Component
-- Slider Component
function Components.createSlider(parent, text, min, max, default, callback)
    local System = getgenv().CensuraSystem
    if not System then return end
    
    -- Container
    local container = Create("Frame", {
        Name = "SliderContainer",
        Size = System.UI.SliderSize,
        BackgroundColor3 = System.Colors.Background,
        BackgroundTransparency = 0.9,
        Parent = parent
    })
    
    -- Apply corner and stroke
    Create("UICorner", {
        CornerRadius = System.UI.CornerRadius,
        Parent = container
    })
    
    local containerStroke = Styles.createStroke(System.Colors.Accent, 0.8, 1)
    containerStroke.Parent = container
    
    -- Label
    local label = Create("TextLabel", {
        Name = "Label",
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -70, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = System.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Parent = container
    })
    
    -- Value Display
    local valueFrame = Create("Frame", {
        Name = "ValueFrame",
        Position = UDim2.new(1, -60, 0, 0),
        Size = UDim2.new(0, 50, 0, 20),
        BackgroundColor3 = System.Colors.Background,
        BackgroundTransparency = 0.8,
        Parent = container
    })
    
    Create("UICorner", {
        CornerRadius = System.UI.CornerRadius,
        Parent = valueFrame
    })
    
    local valueLabel = Create("TextLabel", {
        Name = "Value",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = System.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Center,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Parent = valueFrame
    })
    
    -- Slider Track
    local sliderTrack = Create("Frame", {
        Name = "SliderTrack",
        Position = UDim2.new(0, 10, 0.7, 0),
        Size = UDim2.new(1, -20, 0, 2),
        BackgroundColor3 = System.Colors.Border,
        BackgroundTransparency = 0.5,
        Parent = container
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 1),
        Parent = sliderTrack
    })
    
    -- Fill Bar with Animated Gradient
    local fill = Create("Frame", {
        Name = "Fill",
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = System.Colors.Enabled,
        Parent = sliderTrack
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 1),
        Parent = fill
    })
    
    -- Animated gradient for fill
    local fillGradient = Animations.createAnimatedGradient({
        StartColor = System.Colors.Enabled,
        EndColor = System.Colors.Highlight,
        Rotation = 0
    })
    fillGradient.Parent = fill
    
    -- Knob
    local knob = Create("Frame", {
        Name = "Knob",
        Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6),
        Size = UDim2.new(0, 12, 0, 12),
        BackgroundColor3 = System.Colors.Text,
        BackgroundTransparency = 0,
        Parent = sliderTrack
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = knob
    })
    
    local knobStroke = Styles.createStroke(System.Colors.Accent, 1, 1)
    knobStroke.Parent = knob
    
    -- Slider Logic
    local dragging = false
    local value = default
    
    local function updateValue(pos)
        value = math.floor(min + ((max - min) * pos))
        valueLabel.Text = tostring(value)
        
        Animations.updateSlider(knob, fill, pos, value)
        
        if typeof(callback) == "function" then
            callback(value)
        end
    end
    
    -- Input Handling
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            Animations.applyHoverState(knob, knobStroke)
        end
    end)
    
    Services.Input.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            Animations.removeHoverState(knob, knobStroke)
        end
    end)
    
    -- Track click handling
    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = input.Position.X
            local trackPos = sliderTrack.AbsolutePosition.X
            local trackSize = sliderTrack.AbsoluteSize.X
            
            local pos = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
            updateValue(pos)
        end
    end)
    
    -- Drag handling
    Services.Run.RenderStepped:Connect(function()
        if dragging then
            local mousePos = Services.Input:GetMouseLocation()
            local trackPos = sliderTrack.AbsolutePosition
            local trackSize = sliderTrack.AbsoluteSize
            
            local pos = math.clamp(
                (mousePos.X - trackPos.X) / trackSize.X,
                0, 1
            )
            
            updateValue(pos)
        end
    end)
    
    -- Container hover effects
    container.MouseEnter:Connect(function()
        Animations.applyHoverState(container, containerStroke)
    end)
    
    container.MouseLeave:Connect(function()
        if not dragging then
            Animations.removeHoverState(container, containerStroke)
        end
    end)
    
    return container
end

return Components
