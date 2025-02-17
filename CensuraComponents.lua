local Components = {}

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

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
    -- Example of accessing global system
    local System = getgenv().CensuraSystem
    
    local button = Create("TextButton", {
        Parent = parent,
        Size = System.UI.ButtonSize,
        BackgroundColor3 = System.Colors.Accent,
        BackgroundTransparency = System.UI.Transparency.Elements,
        Text = text,
        TextColor3 = System.Colors.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        AutoButtonColor = false -- We'll handle hover effects manually
    })
    
    -- Apply corner
    Create("UICorner", {
        Parent = button,
        CornerRadius = System.UI.CornerRadius
    })
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        TweenService:Create(button, System.UI.TweenInfo, {
            BackgroundColor3 = System.Colors.Highlight
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, System.UI.TweenInfo, {
            BackgroundColor3 = System.Colors.Accent
        }):Play()
    end)
    
    button.MouseButton1Click:Connect(callback)
    return button
end

-- Toggle Component
function Components.createToggle(parent, text, default, callback)
    local System = getgenv().CensuraSystem
    
    local container = Create("Frame", {
        Parent = parent,
        Size = System.UI.ButtonSize,
        BackgroundColor3 = System.Colors.Accent,
        BackgroundTransparency = System.UI.Transparency.Elements
    })
    
    Create("UICorner", {
        Parent = container,
        CornerRadius = System.UI.CornerRadius
    })
    
    -- Text Label
    local label = Create("TextLabel", {
        Parent = container,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -44, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = System.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14
    })
    
    -- Toggle Button
    local toggle = Create("TextButton", {
        Parent = container,
        Position = UDim2.new(1, -34, 0.5, -12),
        Size = System.UI.ToggleSize,
        BackgroundColor3 = default and System.Colors.Enabled or System.Colors.Disabled,
        Text = ""
    })
    
    Create("UICorner", {
        Parent = toggle,
        CornerRadius = UDim.new(0, 12)
    })
    
    -- Toggle Logic
    local enabled = default or false
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        TweenService:Create(toggle, System.UI.TweenInfo, {
            BackgroundColor3 = enabled and System.Colors.Enabled or System.Colors.Disabled
        }):Play()
        callback(enabled)
    end)
    
    return container
end

-- Slider Component
function Components.createSlider(parent, text, min, max, default, callback)
    local System = getgenv().CensuraSystem
    
    -- Container
    local container = Create("Frame", {
        Parent = parent,
        Size = System.UI.SliderSize,
        BackgroundColor3 = System.Colors.Accent,
        BackgroundTransparency = System.UI.Transparency.Elements
    })
    
    Create("UICorner", {
        Parent = container,
        CornerRadius = System.UI.CornerRadius
    })
    
    -- Labels
    local label = Create("TextLabel", {
        Parent = container,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -70, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = System.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14
    })
    
    local valueLabel = Create("TextLabel", {
        Parent = container,
        Position = UDim2.new(1, -60, 0, 0),
        Size = UDim2.new(0, 50, 0, 20),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = System.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14
    })
    
    -- Slider Bar
    local sliderBar = Create("Frame", {
        Parent = container,
        Position = UDim2.new(0, 10, 0.7, 0),
        Size = UDim2.new(1, -20, 0, 4),
        BackgroundColor3 = System.Colors.Background
    })
    
    Create("UICorner", {
        Parent = sliderBar,
        CornerRadius = UDim.new(0, 2)
    })
    
    -- Slider Fill
    local fill = Create("Frame", {
        Parent = sliderBar,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = System.Colors.Enabled
    })
    
    Create("UICorner", {
        Parent = fill,
        CornerRadius = UDim.new(0, 2)
    })
    
    -- Slider Button
    local button = Create("TextButton", {
        Parent = sliderBar,
        Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        BackgroundColor3 = System.Colors.Enabled,
        Text = ""
    })
    
    Create("UICorner", {
        Parent = button,
        CornerRadius = UDim.new(1, 0)
    })
    
    -- Slider Logic
    local dragging = false
    local value = default
    
    button.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mouse = UserInputService:GetMouseLocation()
            local pos = (mouse.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
            pos = math.clamp(pos, 0, 1)
            value = min + ((max - min) * pos)
            
            button.Position = UDim2.new(pos, -8, 0.5, -8)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            valueLabel.Text = tostring(math.floor(value))
            callback(math.floor(value))
        end
    end)
    
    return container
end

-- Window Dragging
function Components.makeDraggable(titleBar, mainFrame)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

return Components
