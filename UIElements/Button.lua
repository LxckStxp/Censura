--[[
    Button Module
    Part of Censura UI Library
    
    Military-tech inspired button component with animated feedback
]]

local Button = {}

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

function Button.new(parent, text, callback)
    assert(parent, "Parent is required")
    assert(type(text) == "string", "Text must be a string")
    assert(type(callback) == "function", "Callback must be a function")
    
    local System = getgenv().CensuraSystem
    if not System then return end
    
    -- Main Button Container
    local button = Create("TextButton", {
        Name = "Button",
        Size = System.UI.ButtonSize,
        BackgroundColor3 = System.Colors.Background,
        BackgroundTransparency = System.UI.Transparency.Elements,
        Text = text,
        TextColor3 = System.Colors.Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        AutoButtonColor = false,
        Parent = parent
    })
    
    -- Apply corner rounding from system settings
    Create("UICorner", {
        CornerRadius = System.UI.CornerRadius,
        Parent = button
    })
    
    -- Create border using Styles module
    local stroke = Styles.createStroke(
        System.Colors.Accent,
        System.UI.Transparency.Elements,
        1
    )
    stroke.Parent = button
    
    -- Apply animated gradient using Animations module
    local gradient = Animations.createAnimatedGradient({
        StartColor = System.Colors.Accent,
        EndColor = System.Colors.Background,
        Rotation = 45
    })
    gradient.Parent = button
    
    -- Interaction Feedback
    button.MouseEnter:Connect(function()
        Animations.applyHoverState(button, stroke)
    end)
    
    button.MouseLeave:Connect(function()
        Animations.removeHoverState(button, stroke)
    end)
    
    button.MouseButton1Down:Connect(function()
        Animations.buttonPress(button, stroke)
    end)
    
    button.MouseButton1Up:Connect(function()
        Animations.buttonRelease(button, stroke)
        callback()
    end)
    
    return button
end

return Button
