--[[
    Slider Module
    Part of Censura UI Library
    Version: 1.0
    
    Military-tech inspired slider with precise value control and visual feedback
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
    -- Input validation
    assert(parent, "Parent is required")
    assert(type(text) == "string", "Text must be a string")
    assert(type(min) == "number", "Min must be a number")
    assert(type(max) == "number", "Max must be a number")
    assert(type(callback) == "function", "Callback must be a function")
    assert(min < max, "Min must be less than max")
    assert(default >= min and default <= max, "Default must be between min and max")
    
    -- Get system reference
    local System = getgenv().CensuraSystem
    assert(System, "CensuraSystem not initialized")
    
    -- Main Container
    local container = Create("Frame", {
        Name = "SliderContainer",
        Size = System.UI.SliderSize,
        BackgroundColor3 = System.Colors.Background,
        BackgroundTransparency = System.UI.Transparency.Elements,
        ClipsDescendants = true,
        Parent = parent
    })
    
    Create("UICorner", {
        CornerRadius = System.UI.CornerRadius,
        Parent = container
    })
    
    local containerStroke = System.Styles.createStroke(
        System.Colors.Accent,
        System.UI.Transparency.Elements,
        1
    )
    containerStroke.Parent = container
    
    -- Container Gradient
    local containerGradient = System.Animations.createAnimatedGradient({
        StartColor = System.Colors.Accent,
        EndColor = System.Colors.Background,
        Rotation = 45
    })
    containerGradient.Parent = container
    
    -- Label and Value Display
    local labelContainer = Create("Frame", {
        Name = "LabelContainer",
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Parent = container
    })
    
    local label = Create("TextLabel", {
        Name = "Label",
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -70, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = System.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Parent = labelContainer
    })
    
    local valueFrame = Create("Frame", {
        Name = "ValueFrame",
        Position = UDim2.new(1, -60, 0, 0),
        Size = UDim2.new(0, 50, 1, 0),
        BackgroundColor3 = System.Colors.Background,
        BackgroundTransparency = 0.8,
        Parent = labelContainer
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
    local trackContainer = Create("Frame", {
        Name = "TrackContainer",
        Position = UDim2.new(0, 10, 0.7, 0),
        Size = UDim2.new(1, -20, 0, 2),
        BackgroundTransparency = 1,
        Parent = container
    })
    
    local track = Create("Frame", {
        Name = "Track",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = System.Colors.Border,
        BackgroundTransparency = 0.5,
        Parent = trackContainer
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
    
    local fillGradient = System.Animations.createAnimatedGradient({
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
    local dragging = false
    local value = default
    local isLocked = false
    local precision = 0
    
    -- Value Update Logic
    local function updateValue(pos, skipCallback)
        if isLocked then return end
        
        local newValue = min + ((max - min) * pos)
        if precision > 0 then
            newValue = math.floor(newValue * (10 ^ precision)) / (10 ^ precision)
        else
            newValue = math.floor(newValue)
        end
        
        if newValue ~= value then
            value = newValue
            valueLabel.Text = tostring(value)
            System.Animations.updateSlider(knob, fill, pos, value)
            
            if not skipCallback then
                callback(value)
            end
        end
    end
    
    -- Input Handling
    local function handleTrackClick(input)
        if isLocked then return end
        
        local trackPos = track.AbsolutePosition.X
        local trackSize = track.AbsoluteSize.X
        local mousePos = input.Position.X
        
        local pos = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
        updateValue(pos)
    end
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not isLocked then
            dragging = true
            System.Animations.applyHoverState(knob, knobStroke)
        end
    end)
    
    Services.Input.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            System.Animations.removeHoverState(knob, knobStroke)
        end
    end)
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            handleTrackClick(input)
        end
    end)
    
    Services.Run.RenderStepped:Connect(function()
        if dragging then
            local mousePos = Services.Input:GetMouseLocation().X
            local trackPos = track.AbsolutePosition.X
            local trackSize = track.AbsoluteSize.X
            
            local pos = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
            updateValue(pos)
        end
    end)
    
    -- Hover Effects
    container.MouseEnter:Connect(function()
        if not isLocked then
            System.Animations.applyHoverState(container, containerStroke)
        end
    end)
    
    container.MouseLeave:Connect(function()
        if not dragging then
            System.Animations.removeHoverState(container, containerStroke)
        end
    end)
    
    -- Public Interface
    local interface = {
        SetValue = function(self, newValue, skipCallback)
            local pos = math.clamp((newValue - min) / (max - min), 0, 1)
            updateValue(pos, skipCallback)
        end,
        
        GetValue = function(self)
            return value
        end,
        
        SetLocked = function(self, locked)
            isLocked = locked
            container.BackgroundTransparency = locked and 0.7 or System.UI.Transparency.Elements
            label.TextColor3 = locked and System.Colors.SecondaryText or System.Colors.Text
        end,
        
        SetPrecision = function(self, decimals)
            precision = math.clamp(decimals or 0, 0, 10)
            self:SetValue(value, true)
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

return Slider
