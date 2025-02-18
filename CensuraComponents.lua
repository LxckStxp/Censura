--[[
    CensuraDev Components Module
    Version: 4.0
    
    UI Components with consistent styling and behavior
]]

local Components = {}

-- Services
local Services = {
    Tween = game:GetService("TweenService"),
    Input = game:GetService("UserInputService"),
    Run = game:GetService("RunService")
}

-- Utility function for creating instances
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
        BackgroundColor3 = System.Colors.Accent,
        BackgroundTransparency = System.UI.Transparency.Elements,
        Text = text,
        TextColor3 = System.Colors.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        AutoButtonColor = false,
        Parent = parent
    })
    
    -- Apply corner
    Create("UICorner", {
        CornerRadius = System.UI.CornerRadius,
        Parent = button
    })
    
    -- Apply stroke
    Create("UIStroke", {
        Color = System.Colors.Highlight,
        Transparency = 0.8,
        Thickness = 1,
        Parent = button
    })
    
    -- Hover Effects
    button.MouseEnter:Connect(function()
        Services.Tween:Create(button, System.Animation.TweenInfo, {
            BackgroundColor3 = System.Colors.Highlight
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        Services.Tween:Create(button, System.Animation.TweenInfo, {
            BackgroundColor3 = System.Colors.Accent
        }):Play()
    end)
    
    -- Click handling
    button.MouseButton1Click:Connect(function()
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
    
    -- Create container
    local container = Create("Frame", {
        Name = "ToggleContainer",
        Size = System.UI.ButtonSize,
        BackgroundColor3 = System.Colors.Accent,
        BackgroundTransparency = System.UI.Transparency.Elements,
        Parent = parent
    })
    
    Create("UICorner", {
        CornerRadius = System.UI.CornerRadius,
        Parent = container
    })
    
    Create("UIStroke", {
        Color = System.Colors.Highlight,
        Transparency = 0.8,
        Thickness = 1,
        Parent = container
    })
    
    -- Create label
    local label = Create("TextLabel", {
        Name = "Label",
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -44, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = System.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        Parent = container
    })
    
    -- Create toggle button
    local toggle = Create("TextButton", {
        Name = "Toggle",
        Position = UDim2.new(1, -34, 0.5, -12),
        Size = System.UI.ToggleSize,
        BackgroundColor3 = default and System.Colors.Enabled or System.Colors.Disabled,
        Text = "",
        Parent = container
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = toggle
    })
    
    -- Toggle state and animation
    local enabled = default or false
    
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        
        Services.Tween:Create(toggle, System.Animation.TweenInfo, {
            BackgroundColor3 = enabled and System.Colors.Enabled or System.Colors.Disabled
        }):Play()
        
        if typeof(callback) == "function" then
            callback(enabled)
        end
    end)
    
    return container
end

-- Slider Component
function Components.createSlider(parent, text, min, max, default, callback)
    local System = getgenv().CensuraSystem
    if not System then return end
    
    -- Create container
    local container = Create("Frame", {
        Name = "SliderContainer",
        Size = System.UI.SliderSize,
        BackgroundColor3 = System.Colors.Accent,
        BackgroundTransparency = System.UI.Transparency.Elements,
        Parent = parent
    })
    
    Create("UICorner", {
        CornerRadius = System.UI.CornerRadius,
        Parent = container
    })
    
    Create("UIStroke", {
        Color = System.Colors.Highlight,
        Transparency = 0.8,
        Thickness = 1,
        Parent = container
    })
    
    -- Create labels
    local label = Create("TextLabel", {
        Name = "Label",
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -70, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = System.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        Parent = container
    })
    
    local valueLabel = Create("TextLabel", {
        Name = "Value",
        Position = UDim2.new(1, -60, 0, 0),
        Size = UDim2.new(0, 50, 0, 20),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = System.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        Parent = container
    })
    
    -- Create slider bar
    local sliderBar = Create("Frame", {
        Name = "SliderBar",
        Position = UDim2.new(0, 10, 0.7, 0),
        Size = UDim2.new(1, -20, 0, 4),
        BackgroundColor3 = System.Colors.Background,
        Parent = container
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 2),
        Parent = sliderBar
    })
    
    -- Create fill
    local fill = Create("Frame", {
        Name = "Fill",
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = System.Colors.Enabled,
        Parent = sliderBar
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 2),
        Parent = fill
    })
    
    -- Create knob
    local knob = Create("TextButton", {
        Name = "Knob",
        Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        BackgroundColor3 = System.Colors.Enabled,
        Text = "",
        Parent = sliderBar
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = knob
    })
    
    -- Slider functionality
    local dragging = false
    local value = default
    
    knob.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    Services.Input.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    Services.Run.RenderStepped:Connect(function()
        if dragging then
            local mousePos = Services.Input:GetMouseLocation()
            local sliderPos = sliderBar.AbsolutePosition
            local sliderSize = sliderBar.AbsoluteSize
            
            local pos = math.clamp(
                (mousePos.X - sliderPos.X) / sliderSize.X,
                0, 1
            )
            
            value = math.floor(min + ((max - min) * pos))
            valueLabel.Text = tostring(value)
            
            -- Update visuals
            knob.Position = UDim2.new(pos, -8, 0.5, -8)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            
            if typeof(callback) == "function" then
                callback(value)
            end
        end
    end)
    
    return container
end

return Components
