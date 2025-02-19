--[[
    Button Module
    Part of Censura UI Library
    Version: 1.1
    
    Military-tech inspired button component with enhanced interaction feedback
]]

local Button = {}

-- Services
local Services = {
    Tween = game:GetService("TweenService")
}

-- Load Styles Module
local Styles = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraStyles.lua"))()

-- Constants
local PRESS_SCALE = 0.95
local ANIMATION_INFO = {
    HOVER = TweenInfo.new(0.2),
    PRESS = TweenInfo.new(0.1),
    RELEASE = TweenInfo.new(0.2)
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
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        AutoButtonColor = false,
        ClipsDescendants = true,
        Parent = parent
    })
    
    Create("UICorner", {
        CornerRadius = System.UI.CornerRadius,
        Parent = button
    })
    
    -- Button stroke
    local stroke = Styles.createStroke(
        System.Colors.Accent,
        System.UI.Transparency.Elements,
        1
    )
    stroke.Parent = button
    
    -- Text shadow for depth
    local textShadow = Create("TextLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 1, 0.5, 1),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = System.Colors.Background,
        TextTransparency = 0.8,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Parent = button
    })
    
    -- State Management
    local state = {
        pressed = false,
        enabled = true,
        hovering = false
    }
    
    -- Animation Functions
    local function animateHover()
        if not state.enabled then return end
        
        state.hovering = true
        Services.Tween:Create(stroke, ANIMATION_INFO.HOVER, {
            Transparency = 0.2
        }):Play()
        
        Services.Tween:Create(button, ANIMATION_INFO.HOVER, {
            BackgroundTransparency = 0.7
        }):Play()
    end
    
    local function animateUnhover()
        if state.pressed then return end
        
        state.hovering = false
        Services.Tween:Create(stroke, ANIMATION_INFO.HOVER, {
            Transparency = System.UI.Transparency.Elements
        }):Play()
        
        Services.Tween:Create(button, ANIMATION_INFO.HOVER, {
            BackgroundTransparency = System.UI.Transparency.Elements
        }):Play()
    end
    
    local function animatePress()
        if not state.enabled then return end
        
        state.pressed = true
        Services.Tween:Create(button, ANIMATION_INFO.PRESS, {
            Size = button.Size * PRESS_SCALE
        }):Play()
        
        Services.Tween:Create(stroke, ANIMATION_INFO.PRESS, {
            Transparency = 0
        }):Play()
    end
    
    local function animateRelease()
        state.pressed = false
        Services.Tween:Create(button, ANIMATION_INFO.RELEASE, {
            Size = System.UI.ButtonSize
        }):Play()
        
        if not state.hovering then
            Services.Tween:Create(stroke, ANIMATION_INFO.RELEASE, {
                Transparency = System.UI.Transparency.Elements
            }):Play()
        end
    end
    
    -- Input Handling
    button.MouseEnter:Connect(animateHover)
    button.MouseLeave:Connect(animateUnhover)
    
    button.MouseButton1Down:Connect(function()
        if state.enabled then
            animatePress()
        end
    end)
    
    button.MouseButton1Up:Connect(function()
        if state.enabled then
            animateRelease()
            callback()
        end
    end)
    
    -- Public Interface
    local interface = {
        SetText = function(self, newText)
            button.Text = newText
            textShadow.Text = newText
        end,
        
        SetEnabled = function(self, enabled)
            state.enabled = enabled
            button.Active = enabled
            
            if enabled then
                stroke.Color = System.Colors.Accent
                button.TextColor3 = System.Colors.Text
                button.BackgroundTransparency = System.UI.Transparency.Elements
            else
                stroke.Color = System.Colors.Disabled
                button.TextColor3 = System.Colors.SecondaryText
                button.BackgroundTransparency = 0.8
            end
            
            if not enabled and state.hovering then
                animateUnhover()
            end
        end,
        
        IsEnabled = function(self)
            return state.enabled
        end,
        
        SetCallback = function(self, newCallback)
            assert(type(newCallback) == "function", "Callback must be a function")
            callback = newCallback
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
