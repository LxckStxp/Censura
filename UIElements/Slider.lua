--[[
    Slider Module
    Part of Censura UI Library
    
    Precise value control with smooth animations and visual feedback
]]

local Slider = {}

-- Services
local Services = {
    Tween = game:GetService("TweenService"),
    Input = game:GetService("UserInputService"),
    Run = game:GetService("RunService")
}

-- Utility Function
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

function Slider.new(parent, text, min, max, default, callback)
    assert(parent, "Parent is required")
    assert(type(text) == "string", "Text must be a string")
    assert(type(min) == "number", "Min must be a number")
    assert(type(max) == "number", "Max must be a number")
    assert(type(callback) == "function", "Callback must be a function")
    
    local System = getgenv().CensuraSystem
    if not System then return end
    
    -- Main Container
    local container = Create("Frame", {
        Name = "SliderContainer",
        Size = System.UI.SliderSize,
        BackgroundColor3 = System.Colors.Background,
        BackgroundTransparency = System.UI.Transparency.Elements,
        Parent = parent
    })
    
    Create("UICorner", {
        CornerRadius = System.UI.CornerRadius,
        Parent = container
    })
    
    local containerStroke = Styles.createStroke(
        System.Colors.Accent,
        System.UI.Transparency.Elements,
        1
    )
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
    local track = Create("Frame", {
        Name = "Track",
        Position = UDim2.new(0, 10, 0.7, 0),
        Size = UDim2.new(1, -20, 0, 2),
        BackgroundColor3 = System.Colors.Border,
        BackgroundTransparency = 0.5,
        Parent = container
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 1),
        Parent = track
    })
    
    -- Fill Bar
    local fill = Create("Frame", {
        Name = "Fill",
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = System.Colors.Enabled,
        Parent = track
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 1),
        Parent = fill
    })
    
    -- Fill Gradient
    local fillGradient = Animations.createAnimatedGradient({
        StartColor = System.Colors.Enabled,
        EndColor = System.Colors.Highlight,
        Rotation = 0
    })
    fillGradient.Parent = fill
    
    -- Slider Knob
    local knob = Create("Frame", {
        Name = "Knob",
        Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6),
        Size = UDim2.new(0, 12, 0, 12),
        BackgroundColor3 = System.Colors.Text,
        Parent = track
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = knob
    })
    
    local knobStroke = Styles.createStroke(
        System.Colors.Accent,
        0.8,
        1
    )
    knobStroke.Parent = knob
    
    -- Slider Logic
    local dragging = false
    local value = default
    
    local function updateValue(pos)
        local newValue = math.floor(min + ((max - min) * pos))
        if newValue ~= value then
            value = newValue
            valueLabel.Text = tostring(value)
            Animations.updateSlider(knob, fill, pos, value)
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
    
    -- Track Click
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local trackPos = track.AbsolutePosition.X
            local trackSize = track.AbsoluteSize.X
            local mousePos = input.Position.X
            
            local pos = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
            updateValue(pos)
        end
    end)
    
    -- Drag Handling
    Services.Run.RenderStepped:Connect(function()
        if dragging then
            local mousePos = Services.Input:GetMouseLocation().X
            local trackPos = track.AbsolutePosition.X
            local trackSize = track.AbsoluteSize.X
            
            local pos = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
            updateValue(pos)
        end
    end)
    
    -- Container Hover Effects
    container.MouseEnter:Connect(function()
        Animations.applyHoverState(container, containerStroke)
    end)
    
    container.MouseLeave:Connect(function()
        if not dragging then
            Animations.removeHoverState(container, containerStroke)
        end
    end)
    
    -- Public Interface
    local methods = {
        SetValue = function(self, newValue)
            local pos = math.clamp((newValue - min) / (max - min), 0, 1)
            updateValue(pos)
        end,
        GetValue = function(self)
            return value
        end
    }
    
    return setmetatable(methods, {
        __index = container
    })
end

return Slider
