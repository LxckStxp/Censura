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
function Components.createSlider(parent, text, min, max, default, callback)
    local System = getgenv().CensuraSystem
    if not System then return end
    
    -- Modern container with minimal design
    local container = Create("Frame", {
        Name = "SliderContainer",
        Size = System.UI.SliderSize,
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
    
    -- Clean, minimal labels
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
    
    -- Modern value display
    local valueFrame = Create("Frame", {
        Name = "ValueFrame",
        Position = UDim2.new(1, -60, 0, 0),
        Size = UDim2.new(0, 50, 0, 20),
        BackgroundColor3 = System.Colors.Background,
        BackgroundTransparency = 0.8,
        Parent = container
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 2),
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
    
    -- Sleek slider track
    local sliderTrack = Create("Frame", {
        Name = "SliderTrack",
        Position = UDim2.new(0, 10, 0.7, 0),
        Size = UDim2.new(1, -20, 0, 2), -- Thinner track
        BackgroundColor3 = System.Colors.Border,
        BackgroundTransparency = 0.5,
        Parent = container
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 1),
        Parent = sliderTrack
    })
    
    -- Progress fill with gradient
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
    
    -- Apply subtle gradient to fill
    local fillGradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, System.Colors.Enabled),
            ColorSequenceKeypoint.new(1, System.Colors.Highlight)
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 0.2)
        }),
        Parent = fill
    })
    
    -- Modern minimal knob
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
    
    -- Knob highlight effect
    local knobStroke = Create("UIStroke", {
        Color = System.Colors.Accent,
        Transparency = 1,
        Thickness = 1,
        Parent = knob
    })
    
    -- Slider functionality with improved visual feedback
    local dragging = false
    local value = default
    
    local function updateVisuals(pos)
        value = math.floor(min + ((max - min) * pos))
        valueLabel.Text = tostring(value)
        
        -- Smooth transitions
        Services.Tween:Create(knob, TweenInfo.new(0.1), {
            Position = UDim2.new(pos, -6, 0.5, -6)
        }):Play()
        
        Services.Tween:Create(fill, TweenInfo.new(0.1), {
            Size = UDim2.new(pos, 0, 1, 0)
        }):Play()
    end
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            -- Show knob highlight
            Services.Tween:Create(knobStroke, TweenInfo.new(0.2), {
                Transparency = 0.5
            }):Play()
        end
    end)
    
    Services.Input.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            -- Hide knob highlight
            Services.Tween:Create(knobStroke, TweenInfo.new(0.2), {
                Transparency = 1
            }):Play()
        end
    end)
    
    -- Smooth drag handling
    Services.Run.RenderStepped:Connect(function()
        if dragging then
            local mousePos = Services.Input:GetMouseLocation()
            local sliderPos = sliderTrack.AbsolutePosition
            local sliderSize = sliderTrack.AbsoluteSize
            
            local pos = math.clamp(
                (mousePos.X - sliderPos.X) / sliderSize.X,
                0, 1
            )
            
            updateVisuals(pos)
            
            if typeof(callback) == "function" then
                callback(value)
            end
        end
    end)
    
    -- Hover effects
    sliderTrack.MouseEnter:Connect(function()
        Services.Tween:Create(stroke, Timing.Normal, {
            Transparency = 0.5
        }):Play()
    end)
    
    sliderTrack.MouseLeave:Connect(function()
        if not dragging then
            Services.Tween:Create(stroke, Timing.Normal, {
                Transparency = 0.8
            }):Play()
        end
    end)
    
    return container
end

return Components
