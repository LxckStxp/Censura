--[[
    CensuraAnimations Module
    Version: 1.0
    
    Handles subtle animations and transitions for Censura UI
]]

local Animations = {}

local Services = {
    Tween = game:GetService("TweenService"),
    Run = game:GetService("RunService")
}

-- Consistent animation timing
local Timing = {
    Quick = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Normal = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
}

-- Subtle gradient animation
function Animations.createAnimatedGradient(properties)
    properties = properties or {}
    local System = getgenv().CensuraSystem
    
    local gradient = Instance.new("UIGradient")
    
    -- Use explicit colors with optional hold point
    local startColor = properties.StartColor or System.Colors.Accent
    local endColor = properties.EndColor or System.Colors.Background
    
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, startColor),
        ColorSequenceKeypoint.new(0.4, startColor),      -- Hold the start color
        ColorSequenceKeypoint.new(1, endColor)
    })
    
    -- Less transparent gradient for better visibility
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.05),    -- More visible start
        NumberSequenceKeypoint.new(0.4, 0.1),   -- Subtle fade during hold
        NumberSequenceKeypoint.new(1, 0.3)      -- Gradual end transition
    })
    
    gradient.Rotation = properties.Rotation or 90
    
    -- Subtle animation
    local offset = 0
    local connection
    connection = Services.Run.RenderStepped:Connect(function(deltaTime)
        if not gradient.Parent then
            connection:Disconnect()
            return
        end
        offset = (offset + deltaTime * 0.1) % 1
        gradient.Offset = Vector2.new(offset, 0)
    end)
    
    return gradient
end

-- Element Hover States
function Animations.applyHoverState(object, stroke)
    Services.Tween:Create(stroke, Timing.Quick, {
        Transparency = 0.6
    }):Play()
    Services.Tween:Create(object, Timing.Quick, {
        BackgroundTransparency = object.BackgroundTransparency - 0.1
    }):Play()
end

function Animations.removeHoverState(object, stroke)
    Services.Tween:Create(stroke, Timing.Quick, {
        Transparency = 0.8
    }):Play()
    Services.Tween:Create(object, Timing.Quick, {
        BackgroundTransparency = object.BackgroundTransparency + 0.1
    }):Play()
end

-- Toggle Animation
function Animations.toggleSwitch(knob, frame, enabled)
    local targetPos = enabled and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    local targetColor = enabled and getgenv().CensuraSystem.Colors.Enabled 
                               or getgenv().CensuraSystem.Colors.Background
    
    Services.Tween:Create(knob, Timing.Normal, {
        Position = targetPos
    }):Play()
    
    Services.Tween:Create(frame, Timing.Normal, {
        BackgroundColor3 = targetColor
    }):Play()
end

-- Slider Interactions
function Animations.updateSlider(knob, fill, pos, value)
    Services.Tween:Create(knob, Timing.Quick, {
        Position = UDim2.new(pos, -6, 0.5, -6)
    }):Play()
    
    Services.Tween:Create(fill, Timing.Quick, {
        Size = UDim2.new(pos, 0, 1, 0)
    }):Play()
end

-- Window Transitions
function Animations.showWindow(frame)
    frame.BackgroundTransparency = 1
    local show = Services.Tween:Create(frame, Timing.Smooth, {
        BackgroundTransparency = 0.1
    })
    show:Play()
    return show
end

function Animations.hideWindow(frame)
    local hide = Services.Tween:Create(frame, Timing.Smooth, {
        BackgroundTransparency = 1
    })
    hide:Play()
    return hide
end

-- Button Feedback
function Animations.buttonPress(button, stroke)
    Services.Tween:Create(button, Timing.Quick, {
        BackgroundTransparency = 0.7
    }):Play()
    
    Services.Tween:Create(stroke, Timing.Quick, {
        Transparency = 0.4
    }):Play()
end

function Animations.buttonRelease(button, stroke)
    Services.Tween:Create(button, Timing.Quick, {
        BackgroundTransparency = 0.8
    }):Play()
    
    Services.Tween:Create(stroke, Timing.Quick, {
        Transparency = 0.6
    }):Play()
end

return Animations
