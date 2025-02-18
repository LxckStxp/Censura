--[[
    CensuraDev Components Module
    Version: 4.1
    
    Provides modular UI components with optimized performance and smooth animations
]]

local Components = {}

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Constants
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local CLICK_ANIMATION_SCALE = 0.95

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

--[[ Button Component
    Example usage:
    local button = Components.createButton(parent, "Click Me", function()
        print("Button clicked!")
    end)
]]
function Components.createButton(parent, text, callback)
    local System = getgenv().CensuraSystem
    
    -- Create container
    local container = Create("Frame", {
        Name = "ButtonContainer",
        Parent = parent,
        Size = System.UI.ButtonSize,
        BackgroundTransparency = 1
    })
    
    -- Create button
    local button = Create("TextButton", {
        Name = "Button",
        Parent = container,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = System.Colors.Accent,
        BackgroundTransparency = System.UI.Transparency.Elements,
        Text = text,
        TextColor3 = System.Colors.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        AutoButtonColor = false
    })
    
    -- Apply corner
    Create("UICorner", {
        Parent = button,
        CornerRadius = System.UI.CornerRadius
    })
    
    -- Button animations
    local currentTween
    local isHovered = false
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        isHovered = true
        if currentTween then currentTween:Cancel() end
        currentTween = CreateTween(button, {
            BackgroundColor3 = System.Colors.Highlight
        })
        currentTween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        isHovered = false
        if currentTween then currentTween:Cancel() end
        currentTween = CreateTween(button, {
            BackgroundColor3 = System.Colors.Accent
        })
        currentTween:Play()
    end)
    
    -- Click animation
    button.MouseButton1Down:Connect(function()
        if currentTween then currentTween:Cancel() end
        CreateTween(button, {Size = UDim2.new(CLICK_ANIMATION_SCALE, 0, CLICK_ANIMATION_SCALE, 0)}):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        if currentTween then currentTween:Cancel() end
        CreateTween(button, {Size = UDim2.new(1, 0, 1, 0)}):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        callback()
    end)
    
    -- Cleanup method
    function container:Destroy()
        if currentTween then currentTween:Cancel() end
        container:Destroy()
    end
    
    return container
end

--[[ Toggle Component
    Example usage:
    local toggle = Components.createToggle(parent, "Enable Feature", false, function(enabled)
        print("Toggle state:", enabled)
    end)
]]
function Components.createToggle(parent, text, default, callback)
    local System = getgenv().CensuraSystem
    
    -- Create container
    local container = Create("Frame", {
        Name = "ToggleContainer",
        Parent = parent,
        Size = System.UI.ButtonSize,
        BackgroundColor3 = System.Colors.Accent,
        BackgroundTransparency = System.UI.Transparency.Elements
    })
    
    Create("UICorner", {
        Parent = container,
        CornerRadius = System.UI.CornerRadius
    })
    
    -- Create label
    local label = Create("TextLabel", {
        Name = "Label",
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
    
    -- Create toggle button
    local toggle = Create("TextButton", {
        Name = "Toggle",
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
    
    -- Toggle state and animation
    local enabled = default or false
    local currentTween
    
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        
        if currentTween then currentTween:Cancel() end
        currentTween = CreateTween(toggle, {
            BackgroundColor3 = enabled and System.Colors.Enabled or System.Colors.Disabled,
            Size = UDim2.new(0, 24, 0, 24)
        })
        currentTween:Play()
        
        -- Reset size after animation
        task.delay(0.1, function()
            if currentTween then currentTween:Cancel() end
            CreateTween(toggle, {Size = System.UI.ToggleSize}):Play()
        end)
        
        callback(enabled)
    end)
    
    -- Cleanup method
    function container:Destroy()
        if currentTween then currentTween:Cancel() end
        container:Destroy()
    end
    
    return container
end

--[[ Slider Component
    Example usage:
    local slider = Components.createSlider(parent, "Volume", 0, 100, 50, function(value)
        print("Slider value:", value)
    end)
]]
function Components.createSlider(parent, text, min, max, default, callback)
    local System = getgenv().CensuraSystem
    
    -- Create container
    local container = Create("Frame", {
        Name = "SliderContainer",
        Parent = parent,
        Size = System.UI.SliderSize,
        BackgroundColor3 = System.Colors.Accent,
        BackgroundTransparency = System.UI.Transparency.Elements
    })
    
    Create("UICorner", {
        Parent = container,
        CornerRadius = System.UI.CornerRadius
    })
    
    -- Create labels
    local label = Create("TextLabel", {
        Name = "Label",
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
        Name = "Value",
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
    
    -- Create slider bar
    local sliderBar = Create("Frame", {
        Name = "SliderBar",
        Parent = container,
        Position = UDim2.new(0, 10, 0.7, 0),
        Size = UDim2.new(1, -20, 0, 4),
        BackgroundColor3 = System.Colors.Background
    })
    
    Create("UICorner", {
        Parent = sliderBar,
        CornerRadius = UDim.new(0, 2)
    })
    
    -- Create fill
    local fill = Create("Frame", {
        Name = "Fill",
        Parent = sliderBar,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = System.Colors.Enabled
    })
    
    Create("UICorner", {
        Parent = fill,
        CornerRadius = UDim.new(0, 2)
    })
    
    -- Create knob
    local knob = Create("TextButton", {
        Name = "Knob",
        Parent = sliderBar,
        Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        BackgroundColor3 = System.Colors.Enabled,
        Text = ""
    })
    
    Create("UICorner", {
        Parent = knob,
        CornerRadius = UDim.new(1, 0)
    })
    
    -- Slider functionality
    local dragging = false
    local value = default
    local dragConnection
    local currentTween
    
    local function updateSlider(input)
        local pos = math.clamp(
            (input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X,
            0, 1
        )
        
        value = math.floor(min + ((max - min) * pos))
        valueLabel.Text = tostring(value)
        
        if currentTween then currentTween:Cancel() end
        
        -- Smooth movement
        CreateTween(knob, {
            Position = UDim2.new(pos, -8, 0.5, -8)
        }):Play()
        
        CreateTween(fill, {
            Size = UDim2.new(pos, 0, 1, 0)
        }):Play()
        
        callback(value)
    end
    
    knob.MouseButton1Down:Connect(function()
        dragging = true
        
        if dragConnection then
            dragConnection:Disconnect()
        end
        
        dragConnection = RunService.RenderStepped:Connect(function()
            if dragging then
                updateSlider({Position = UserInputService:GetMouseLocation()})
            end
        end)
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            if dragConnection then
                dragConnection:Disconnect()
                dragConnection = nil
            end
        end
    end)
    
    -- Cleanup method
    function container:Destroy()
        if dragConnection then dragConnection:Disconnect() end
        if currentTween then currentTween:Cancel() end
        container:Destroy()
    end
    
    return container
end

return Components
