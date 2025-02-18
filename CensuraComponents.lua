--[[
    CensuraDev Components Module
    Version: 4.0
    
    Handles creation and management of UI components with optimized performance
    and consistent styling
--]]

local Components = {}

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Animation Configuration
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

--[[ Button Component
    Usage:
    local button = Components.createButton(parent, "Click Me", function()
        print("Button clicked!")
    end)
]]
function Components.createButton(parent, text, callback)
    local System = getgenv().CensuraSystem
    
    local container = Create("Frame", {
        Name = "ButtonContainer",
        Parent = parent,
        Size = System.UI.ButtonSize,
        BackgroundTransparency = 1,
    })
    
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
    
    Create("UICorner", {
        CornerRadius = System.UI.CornerRadius,
        Parent = button
    })
    
    -- Hover Effects with Tween Management
    local currentTween
    
    button.MouseEnter:Connect(function()
        if currentTween then currentTween:Cancel() end
        currentTween = CreateTween(button, {
            BackgroundColor3 = System.Colors.Highlight
        })
        currentTween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        if currentTween then currentTween:Cancel() end
        currentTween = CreateTween(button, {
            BackgroundColor3 = System.Colors.Accent
        })
        currentTween:Play()
    end)
    
    button.MouseButton1Click:Connect(callback)
    
    return container
end

--[[ Toggle Component
    Usage:
    local toggle = Components.createToggle(parent, "Enable Feature", false, function(enabled)
        print("Toggle state:", enabled)
    end)
]]
function Components.createToggle(parent, text, default, callback)
    local System = getgenv().CensuraSystem
    
    local container = Create("Frame", {
        Name = "ToggleContainer",
        Parent = parent,
        Size = System.UI.ButtonSize,
        BackgroundColor3 = System.Colors.Accent,
        BackgroundTransparency = System.UI.Transparency.Elements
    })
    
    Create("UICorner", {
        CornerRadius = System.UI.CornerRadius,
        Parent = container
    })
    
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
    
    local toggle = Create("TextButton", {
        Name = "Toggle",
        Parent = container,
        Position = UDim2.new(1, -34, 0.5, -12),
        Size = System.UI.ToggleSize,
        BackgroundColor3 = default and System.Colors.Enabled or System.Colors.Disabled,
        Text = ""
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = toggle
    })
    
    local enabled = default or false
    local currentTween
    
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        
        if currentTween then currentTween:Cancel() end
        currentTween = CreateTween(toggle, {
            BackgroundColor3 = enabled and System.Colors.Enabled or System.Colors.Disabled
        })
        currentTween:Play()
        
        callback(enabled)
    end)
    
    return container
end

--[[ Slider Component
    Usage:
    local slider = Components.createSlider(parent, "Speed", 0, 100, 50, function(value)
        print("Slider value:", value)
    end)
]]
function Components.createSlider(parent, text, min, max, default, callback)
    local System = getgenv().CensuraSystem
    
    local container = Create("Frame", {
        Name = "SliderContainer",
        Parent = parent,
        Size = System.UI.SliderSize,
        BackgroundColor3 = System.Colors.Accent,
        BackgroundTransparency = System.UI.Transparency.Elements
    })
    
    Create("UICorner", {
        CornerRadius = System.UI.CornerRadius,
        Parent = container
    })
    
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
    
    local sliderBar = Create("Frame", {
        Name = "SliderBar",
        Parent = container,
        Position = UDim2.new(0, 10, 0.7, 0),
        Size = UDim2.new(1, -20, 0, 4),
        BackgroundColor3 = System.Colors.Background
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 2),
        Parent = sliderBar
    })
    
    local fill = Create("Frame", {
        Name = "Fill",
        Parent = sliderBar,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = System.Colors.Enabled
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 2),
        Parent = fill
    })
    
    local button = Create("TextButton", {
        Name = "Knob",
        Parent = sliderBar,
        Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        BackgroundColor3 = System.Colors.Enabled,
        Text = ""
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = button
    })
    
    -- Slider Logic
    local dragging = false
    local value = default
    local dragConnection
    
    local function updateSlider(input)
        local pos = math.clamp(
            (input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X,
            0, 1
        )
        
        value = math.floor(min + ((max - min) * pos))
        valueLabel.Text = tostring(value)
        
        -- Smooth movement using tweens
        CreateTween(button, {
            Position = UDim2.new(pos, -8, 0.5, -8)
        }):Play()
        
        CreateTween(fill, {
            Size = UDim2.new(pos, 0, 1, 0)
        }):Play()
        
        callback(value)
    end
    
    button.MouseButton1Down:Connect(function()
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
        if dragConnection then
            dragConnection:Disconnect()
        end
        container:Destroy()
    end
    
    return container
end

return Components
