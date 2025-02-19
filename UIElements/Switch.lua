--[[
    Switch Module
    Part of Censura UI Library
    Version: 1.0
    
    Military-tech inspired toggle switch with animated transitions
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
    -- Input validation
    assert(parent, "Parent is required")
    assert(type(text) == "string", "Text must be a string")
    assert(type(callback) == "function", "Callback must be a function")
    
    -- Get system reference
    local System = getgenv().CensuraSystem
    assert(System, "CensuraSystem not initialized")
    
    -- Main Container
    local container = Create("Frame", {
        Name = "SwitchContainer",
        Size = System.UI.ButtonSize,
        BackgroundColor3 = System.Colors.Background,
        BackgroundTransparency = System.UI.Transparency.Elements,
        ClipsDescendants = true,
        Parent = parent
    })
    
    -- Apply corner rounding
    Create("UICorner", {
        CornerRadius = System.UI.CornerRadius,
        Parent = container
    })
    
    -- Container stroke
    local containerStroke = System.Styles.createStroke(
        System.Colors.Accent,
        System.UI.Transparency.Elements,
        1
    )
    containerStroke.Parent = container
    
    -- Container gradient
    local containerGradient = System.Animations.createAnimatedGradient({
        StartColor = System.Colors.Accent,
        EndColor = System.Colors.Background,
        Rotation = 45
    })
    containerGradient.Parent = container
    
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
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = track
    })
    
    -- Track gradient
    local trackGradient = System.Animations.createAnimatedGradient({
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
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = knob
    })
    
    local knobStroke = System.Styles.createStroke(
        System.Colors.Accent,
        0.8,
        1
    )
    knobStroke.Parent = knob
    
    -- State Management
    local enabled = default or false
    local isLocked = false
    
    -- Switch Logic
    local function updateSwitch(newState, skipCallback)
        if isLocked then return end
        
        enabled = newState
        System.Animations.toggleSwitch(knob, track, enabled)
        
        trackGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, enabled and System.Colors.Enabled or System.Colors.Background),
            ColorSequenceKeypoint.new(1, System.Colors.Background)
        })
        
        if not skipCallback then
            callback(enabled)
        end
    end
    
    -- Input Handling
    local function handleClick()
        if not isLocked then
            updateSwitch(not enabled)
        end
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            handleClick()
        end
    end)
    
    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            handleClick()
        end
    end)
    
    -- Hover Effects
    container.MouseEnter:Connect(function()
        if not isLocked then
            System.Animations.applyHoverState(container, containerStroke)
        end
    end)
    
    container.MouseLeave:Connect(function()
        System.Animations.removeHoverState(container, containerStroke)
    end)
    
    -- Public Interface
    local interface = {
        SetState = function(self, state, skipCallback)
            updateSwitch(state, skipCallback)
        end,
        
        GetState = function(self)
            return enabled
        end,
        
        SetLocked = function(self, locked)
            isLocked = locked
            container.BackgroundTransparency = locked and 0.7 or System.UI.Transparency.Elements
            label.TextColor3 = locked and System.Colors.SecondaryText or System.Colors.Text
        end,
        
        SetText = function(self, newText)
            label.Text = newText
        end,
        
        Destroy = function(self)
            container:Destroy()
        end
    }
    
    return setmetatable(interface, {
        __index = container
    })
end

return Switch
