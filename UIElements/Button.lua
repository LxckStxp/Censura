--[[
    Button Module
    Part of Censura UI Library
    Version: 1.0
    
    Military-tech inspired button component with animated gradient and interaction feedback
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
    -- Input validation
    assert(parent, "Parent is required")
    assert(type(text) == "string", "Text must be a string")
    assert(type(callback) == "function", "Callback must be a function")
    
    -- Get system reference
    local System = getgenv().CensuraSystem
    assert(System, "CensuraSystem not initialized")
    
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
        ClipsDescendants = true,  -- For gradient containment
        Parent = parent
    })
    
    -- Apply corner rounding
    Create("UICorner", {
        CornerRadius = System.UI.CornerRadius,
        Parent = button
    })
    
    -- Create border using system Styles
    local stroke = System.Styles.createStroke(
        System.Colors.Accent,
        System.UI.Transparency.Elements,
        1
    )
    stroke.Parent = button
    
    -- Apply animated gradient using system Animations
    local gradient = System.Animations.createAnimatedGradient({
        StartColor = System.Colors.Accent,
        EndColor = System.Colors.Background,
        Rotation = 45
    })
    gradient.Parent = button
    
    -- State tracking
    local isPressed = false
    
    -- Interaction Feedback
    button.MouseEnter:Connect(function()
        System.Animations.applyHoverState(button, stroke)
    end)
    
    button.MouseLeave:Connect(function()
        if not isPressed then
            System.Animations.removeHoverState(button, stroke)
        end
    end)
    
    button.MouseButton1Down:Connect(function()
        isPressed = true
        System.Animations.buttonPress(button, stroke)
    end)
    
    button.MouseButton1Up:Connect(function()
        isPressed = false
        System.Animations.buttonRelease(button, stroke)
        System.Animations.removeHoverState(button, stroke)
        callback()
    end)
    
    -- Public interface
    local interface = {
        Instance = button,
        
        SetText = function(self, newText)
            button.Text = newText
        end,
        
        SetEnabled = function(self, enabled)
            button.Active = enabled
            button.AutoButtonColor = false
            
            if enabled then
                stroke.Color = System.Colors.Accent
                button.TextColor3 = System.Colors.Text
            else
                stroke.Color = System.Colors.Disabled
                button.TextColor3 = System.Colors.SecondaryText
            end
        end,
        
        Destroy = function(self)
            button:Destroy()
        end
    }
    
    return setmetatable(interface, {
        __index = button
    })
end

return Button
