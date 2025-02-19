--[[
    Switch Module
    Part of Censura UI Library
    Version: 1.1
    
    Military-tech inspired toggle switch with enhanced animations
]]

local Switch = {}

-- Services
local Services = {
    Tween = game:GetService("TweenService")
}

-- Constants
local KNOB_POSITIONS = {
    OFF = UDim2.new(0, 2, 0.5, -6),
    ON = UDim2.new(1, -14, 0.5, -6)
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
    
    -- Enhanced container gradient
    local containerGradient = System.Animations.createAnimatedGradient({
        StartColor = System.Colors.Accent,
        EndColor = System.Colors.Background,
        Rotation = 45,
        Speed = 0.5
    })
    containerGradient.Parent = container
    
    -- Text Label with shadow
    local labelShadow = Create("TextLabel", {
        Name = "LabelShadow",
        Position = UDim2.new(0, 11, 0, 1),
        Size = UDim2.new(1, -44, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = System.Colors.Background,
        TextTransparency = 0.8,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
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
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Parent = container
    })
    
    -- Enhanced Track
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
    
    -- Animated track gradient
    local trackGradient = System.Animations.createAnimatedGradient({
        StartColor = default and System.Colors.Enabled or System.Colors.Background,
        EndColor = System.Colors.Background,
        Rotation = 90,
        Speed = 1
    })
    trackGradient.Parent = track
    
    -- Enhanced Knob
    local knob = Create("Frame", {
        Name = "Knob",
        Position = default and KNOB_POSITIONS.ON or KNOB_POSITIONS.OFF,
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
    
    -- Knob highlight
    local knobHighlight = Create("Frame", {
        Name = "Highlight",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = System.Colors.Highlight,
        BackgroundTransparency = 1,
        Parent = knob
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = knobHighlight
    })
    
    -- State Management
    local enabled = default or false
    local isLocked = false
    local isHovered = false
    
    -- Enhanced Switch Logic
    local function updateSwitch(newState, skipCallback)
        if isLocked then return end
        
        enabled = newState
        
        -- Animate knob position
        System.Animations.toggleSwitch(knob, track, enabled)
        
        -- Update track gradient
        trackGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, enabled and System.Colors.Enabled or System.Colors.Background),
            ColorSequenceKeypoint.new(1, System.Colors.Background)
        })
        
        -- Animate knob highlight
        Services.Tween:Create(knobHighlight, TweenInfo.new(0.2), {
            BackgroundTransparency = enabled and 0.7 or 1
        }):Play()
        
        if not skipCallback then
            callback(enabled)
        end
    end
    
    -- Enhanced Input Handling
    local function handleClick()
        if isLocked then return end
        
        -- Click feedback animation
        Services.Tween:Create(knob, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 10, 0, 10)
        }):Play()
        
        task.delay(0.1, function()
            Services.Tween:Create(knob, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 12, 0, 12)
            }):Play()
        end)
        
        updateSwitch(not enabled)
    end
    
    -- Input Connections
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
    
    -- Enhanced Hover Effects
    container.MouseEnter:Connect(function()
        if not isLocked then
            isHovered = true
            System.Animations.applyHoverState(container, containerStroke)
            
            -- Track hover effect
            Services.Tween:Create(track, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.3
            }):Play()
        end
    end)
    
    container.MouseLeave:Connect(function()
        isHovered = false
        System.Animations.removeHoverState(container, containerStroke)
        
        -- Reset track transparency
        Services.Tween:Create(track, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.5
        }):Play()
    end)
    
    -- Enhanced Public Interface
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
            track.BackgroundTransparency = locked and 0.7 or (isHovered and 0.3 or 0.5)
        end,
        
        SetText = function(self, newText)
            label.Text = newText
            labelShadow.Text = newText
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
