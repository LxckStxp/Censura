--[[
    Button Module
    Version: 1.0
    
    Modern, minimal button component with hover and click animations
]]

local Button = {}

-- Services
local Services = {
    Tween = game:GetService("TweenService")
}

-- Load Dependencies
local Styles = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraStyles.lua"))()
local Animations = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraAnimations.lua"))()

-- Utility Functions
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

-- Button Constructor
function Button.new(parent, text, callback)
    assert(parent, "Parent is required")
    assert(type(text) == "string", "Text must be a string")
    assert(type(callback) == "function", "Callback must be a function")
    
    local System = getgenv().CensuraSystem
    if not System then return end
    
    -- Create main button instance
    local button = Create("TextButton", {
        Name = "Button",
        Size = System.UI.ButtonSize,
        BackgroundColor3 = System.Colors.Background,
        BackgroundTransparency = 0.9,
        Text = text,
        TextColor3 = System.Colors.Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        AutoButtonColor = false,
        Parent = parent
    })
    
    -- Apply corner rounding
    Create("UICorner", {
        CornerRadius = System.UI.CornerRadius,
        Parent = button
    })
    
    -- Create stroke effect
    local stroke = Styles.createStroke(System.Colors.Accent, 0.8, 1)
    stroke.Parent = button
    
    -- Optional: Add gradient effect
    local gradient = Animations.createAnimatedGradient({
        StartColor = System.Colors.Accent,
        EndColor = System.Colors.Background,
        Rotation = 45
    })
    gradient.Parent = button
    
    -- Hover Effects
    button.MouseEnter:Connect(function()
        Animations.applyHoverState(button, stroke)
    end)
    
    button.MouseLeave:Connect(function()
        Animations.removeHoverState(button, stroke)
    end)
    
    -- Click Effects
    button.MouseButton1Down:Connect(function()
        Animations.buttonPress(button, stroke)
    end)
    
    button.MouseButton1Up:Connect(function()
        Animations.buttonRelease(button, stroke)
        callback()
    end)
    
    -- Public Methods
    local methods = {}
    
    function methods:SetText(newText)
        button.Text = newText
    end
    
    function methods:SetEnabled(enabled)
        button.Active = enabled
        button.AutoButtonColor = enabled
        
        if enabled then
            stroke.Color = System.Colors.Accent
        else
            stroke.Color = System.Colors.Disabled
        end
    end
    
    function methods:Destroy()
        button:Destroy()
    end
    
    return setmetatable(methods, {
        __index = button
    })
end

return Button
