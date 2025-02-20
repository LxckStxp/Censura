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
