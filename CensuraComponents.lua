local Components = {}

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Constants
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Utility Functions
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

local function CreateTween(instance, properties)
    return TweenService:Create(instance, TWEEN_INFO, properties)
end

-- Button Component
function Components.createButton(parent, text, callback)
    local System = getgenv().CensuraSystem
    
    -- Create container for better organization
    local container = Create("Frame", {
        Parent = parent,
        Size = System.UI.ButtonSize,
        BackgroundTransparency = 1,
        Name = "ButtonContainer"
    })
    
    local button = Create("TextButton", {
        Parent = container,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = System.Colors.Accent,
        BackgroundTransparency = System.UI.Transparency.Elements,
        Text = "",
        AutoButtonColor = false
    })
    
    local textLabel = Create("TextLabel", {
        Parent = button,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = System.Colors.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14
    })
    
    Create("UICorner", {
        Parent = button,
        CornerRadius = System.UI.CornerRadius
    })
    
    -- Hover Effects
    local hoverTween
    local originalTween
    
    button.MouseEnter:Connect(function()
        if hoverTween then hoverTween:Cancel() end
        hoverTween = CreateTween(button, {BackgroundColor3 = System.Colors.Highlight})
        hoverTween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        if originalTween then originalTween:Cancel() end
        originalTween = CreateTween(button, {BackgroundColor3 = System.Colors.Accent})
        originalTween:Play()
    end)
    
    button.MouseButton1Click:Connect(callback)
    return container
end

-- Toggle Component
function Components.createToggle(parent, text, default, callback)
    local System = getgenv().CensuraSystem
    
    local container = Create("Frame", {
        Parent = parent,
        Size = System.UI.ButtonSize,
        BackgroundColor3 = System.Colors.Accent,
        BackgroundTransparency = System.UI.Transparency.Elements,
        Name = "ToggleContainer"
    })
    
    Create("UICorner", {
        Parent = container,
        CornerRadius = System.UI.CornerRadius
    })
    
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
    
    local toggleButton = Create("TextButton", {
        Parent = container,
        Position = UDim2.new(1, -34, 0.5, -12),
        Size = System.UI.ToggleSize,
        BackgroundColor3 = default and System.Colors.Enabled or System.Colors.Disabled,
        Text = "",
        Name = "ToggleButton"
    })
    
    Create("UICorner", {
        Parent = toggleButton,
        CornerRadius = UDim.new(0, 12)
    })
    
    local enabled = default or false
    local toggleTween
    
    toggleButton.MouseButton1Click:Connect(function()
        enabled = not enabled
        if toggleTween then toggleTween:Cancel() end
        
        toggleTween = CreateTween(toggleButton, {
            BackgroundColor3 = enabled and System.Colors.Enabled or System.Colors.Disabled
        })
        toggleTween:Play()
        
        callback(enabled)
    end)
    
    return container
end

-- Slider Component
function Components.createSlider(parent, text, min, max, default, callback)
    local System = getgenv().CensuraSystem
    
    local container = Create("Frame", {
        Parent = parent,
        Size = System.UI.SliderSize,
        BackgroundColor3 = System.Colors.Accent,
        BackgroundTransparency = System.UI.Transparency.Elements,
        Name = "SliderContainer"
    })
    
    Create("UICorner", {
        Parent = container,
        CornerRadius = System.UI.CornerRadius
    })
    
    -- Create other elements (labels, slider bar, etc.) as before...
    -- [Previous slider implementation remains the same until the dragging logic]
    
    -- Improved Slider Logic
    local dragging = false
    local value = default
    local connection
    
    local function updateSlider(input)
        local mouse = input.Position
        local pos = (mouse.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
        pos = math.clamp(pos, 0, 1)
        value = min + ((max - min) * pos)
        
        CreateTween(button, {Position = UDim2.new(pos, -8, 0.5, -8)}):Play()
        CreateTween(fill, {Size = UDim2.new(pos, 0, 1, 0)}):Play()
        
        valueLabel.Text = tostring(math.floor(value))
        callback(math.floor(value))
    end
    
    button.MouseButton1Down:Connect(function()
        dragging = true
        if connection then connection:Disconnect() end
        connection = RunService.RenderStepped:Connect(function()
            if dragging then
                updateSlider({Position = UserInputService:GetMouseLocation()})
            end
        end)
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end)
    
    return container
end

return Components
