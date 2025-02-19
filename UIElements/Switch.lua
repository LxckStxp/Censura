--[[
    Switch Module
    Part of Censura UI Library
    
    Modern toggle switch component with smooth animations and state management
]]

local Switch = {}

-- Services
local Services = {
    Tween = game:GetService("TweenService")
}

-- Utility Function
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

function Switch.new(parent, text, default, callback)
    assert(parent, "Parent is required")
    assert(type(text) == "string", "Text must be a string")
    assert(type(callback) == "function", "Callback must be a function")
    
    local System = getgenv().CensuraSystem
    if not System then return end
    
    -- Main Container
    local container = Create("Frame", {
        Name = "SwitchContainer",
        Size = System.UI.ButtonSize,
        BackgroundColor3 = System.Colors.Background,
        BackgroundTransparency = System.UI.Transparency.Elements,
        Parent = parent
    })
    
    -- Apply corner rounding
    Create("UICorner", {
        CornerRadius = System.UI.CornerRadius,
        Parent = container
    })
    
    -- Container stroke
    local containerStroke = Styles.createStroke(
        System.Colors.Accent,
        System.UI.Transparency.Elements,
        1
    )
    containerStroke.Parent = container
    
    -- Text Label
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
    
    -- Switch Track
    local track = Create("Frame", {
        Name = "Track",
        Position = UDim2.new(1, -34, 0.5, -8),
        Size = UDim2.new(0, 24, 0, 16),
        BackgroundColor3 = default and System.Colors.Enabled or System.Colors.Background,
        BackgroundTransparency = 0.5,
        Parent = container
    })
    
    -- Track corner rounding
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = track
    })
    
    -- Track gradient
    local trackGradient = Animations.createAnimatedGradient({
        StartColor = default and System.Colors.Enabled or System.Colors.Background,
        EndColor = System.Colors.Background,
        Rotation = 90
    })
    trackGradient.Parent = track
    
    -- Switch Knob
    local knob = Create("Frame", {
        Name = "Knob",
        Position = default and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
        Size = UDim2.new(0, 12, 0, 12),
        BackgroundColor3 = System.Colors.Text,
        Parent = track
    })
    
    -- Knob corner rounding
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = knob
    })
    
    -- Knob stroke
    local knobStroke = Styles.createStroke(
        System.Colors.Accent,
        0.8,
        1
    )
    knobStroke.Parent = knob
    
    -- State Management
    local enabled = default or false
    
    -- Switch Logic
    local function updateSwitch(newState)
        enabled = newState
        
        -- Animate switch state
        Animations.toggleSwitch(knob, track, enabled)
        
        -- Update gradient
        trackGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, enabled and System.Colors.Enabled or System.Colors.Background),
            ColorSequenceKeypoint.new(1, System.Colors.Background)
        })
        
        callback(enabled)
    end
    
    -- Input Handling
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSwitch(not enabled)
        end
    end)
    
    -- Container Hover Effects
    container.MouseEnter:Connect(function()
        Animations.applyHoverState(container, containerStroke)
    end)
    
    container.MouseLeave:Connect(function()
        Animations.removeHoverState(container, containerStroke)
    end)
    
    -- Public Interface
    local methods = {
        SetEnabled = function(self, state)
            updateSwitch(state)
        end,
        GetState = function(self)
            return enabled
        end
    }
    
    return setmetatable(methods, {
        __index = container
    })
end

return Switch
