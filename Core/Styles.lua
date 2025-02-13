--[[
    Censura/Core/Styles.lua
    Purpose: Central styling and theming system that integrates with _G.Censura
]]

-- Initialize global Censura table if it doesn't exist
if not _G.Censura then
    _G.Censura = {
        Modules = {},
        State = {},
        Cache = {}
    }
end

local Styles = {}
_G.Censura.Modules.Styles = Styles

-- Services
local TweenService = game:GetService("TweenService")

-- Theme Definitions
Styles.Themes = {
    Default = {
        Background = Color3.fromRGB(25, 25, 25),
        DarkAccent = Color3.fromRGB(30, 30, 30),
        LightAccent = Color3.fromRGB(40, 40, 40),
        Text = Color3.fromRGB(255, 255, 255),
        Primary = Color3.fromRGB(0, 170, 255),
        Success = Color3.fromRGB(0, 255, 100),
        Error = Color3.fromRGB(255, 50, 50),
        Highlight = Color3.fromRGB(255, 255, 255)
    },
    Dark = {
        Background = Color3.fromRGB(15, 15, 15),
        DarkAccent = Color3.fromRGB(20, 20, 20),
        LightAccent = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(255, 255, 255),
        Primary = Color3.fromRGB(0, 140, 225),
        Success = Color3.fromRGB(0, 225, 90),
        Error = Color3.fromRGB(225, 45, 45),
        Highlight = Color3.fromRGB(245, 245, 245)
    }
}

-- Store active theme in global state
_G.Censura.State.ActiveTheme = "Default"
_G.Censura.State.Theme = Styles.Themes.Default

-- Animation Presets
Styles.Animations = {
    Short = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Medium = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Long = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    
    Bounce = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
    Elastic = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
}

-- UI Constants
Styles.Constants = {
    CornerRadius = UDim.new(0, 8),
    ButtonCornerRadius = UDim.new(0, 12),
    CircleCornerRadius = UDim.new(1, 0),
    Padding = UDim.new(0, 15),
    ElementSpacing = UDim.new(0, 8),
    HeaderHeight = 40,
    ToggleHeight = 35,
    SliderHeight = 50,
    ToggleWidth = 40,
    SliderThickness = 6
}

-- Font Styles
Styles.Fonts = {
    Header = {
        Font = Enum.Font.GothamBold,
        Size = 16
    },
    Label = {
        Font = Enum.Font.Gotham,
        Size = 14
    },
    Value = {
        Font = Enum.Font.GothamBold,
        Size = 14
    }
}

-- Utility Functions
Styles.Utils = {
    CreateShadow = function(parent)
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.BackgroundTransparency = 1
        shadow.Position = UDim2.new(0, -15, 0, -15)
        shadow.Size = UDim2.new(1, 30, 1, 30)
        shadow.Image = "rbxassetid://6015897843"
        shadow.ImageColor3 = Color3.new(0, 0, 0)
        shadow.ImageTransparency = 0.5
        shadow.Parent = parent
        return shadow
    end,

    CreateCorner = function(parent, radius)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = radius or Styles.Constants.CornerRadius
        corner.Parent = parent
        return corner
    end,

    CreatePadding = function(parent, padding)
        local uiPadding = Instance.new("UIPadding")
        uiPadding.PaddingLeft = padding or Styles.Constants.Padding
        uiPadding.PaddingRight = padding or Styles.Constants.Padding
        uiPadding.PaddingTop = padding or Styles.Constants.Padding
        uiPadding.PaddingBottom = padding or Styles.Constants.Padding
        uiPadding.Parent = parent
        return uiPadding
    end,

    Lerp = function(start, goal, alpha)
        return start + (goal - start) * alpha
    end,

    LerpColor = function(c1, c2, alpha)
        local r = Styles.Utils.Lerp(c1.R, c2.R, alpha)
        local g = Styles.Utils.Lerp(c1.G, c2.G, alpha)
        local b = Styles.Utils.Lerp(c1.B, c2.B, alpha)
        return Color3.new(r, g, b)
    end
}

-- Theme Management
function Styles.SetTheme(themeName)
    if Styles.Themes[themeName] then
        _G.Censura.State.ActiveTheme = themeName
        _G.Censura.State.Theme = Styles.Themes[themeName]
        
        -- Emit theme change event if we have an event system
        if _G.Censura.Events and _G.Censura.Events.emit then
            _G.Censura.Events.emit("themeChanged", themeName)
        end
        
        return true
    end
    return false
end

function Styles.GetColor(colorName)
    return _G.Censura.State.Theme[colorName]
end

-- Create Basic Tween
function Styles.CreateTween(instance, properties, duration, style)
    local tweenInfo = style or Styles.Animations.Short
    return TweenService:Create(instance, tweenInfo, properties)
end

-- Cache frequently used values
function Styles.CacheValue(key, value)
    _G.Censura.Cache[key] = value
end

function Styles.GetCachedValue(key)
    return _G.Censura.Cache[key]
end

-- Example usage:
--[[
    -- Initialize Censura with Styles
    local Styles = require(path.to.Styles)
    
    -- Access from anywhere
    local theme = _G.Censura.State.Theme
    local activeTheme = _G.Censura.State.ActiveTheme
    
    -- Use utility functions
    local button = Instance.new("TextButton")
    button.BackgroundColor3 = _G.Censura.Modules.Styles.GetColor("Primary")
    _G.Censura.Modules.Styles.Utils.CreateCorner(button)
    
    -- Change theme
    _G.Censura.Modules.Styles.SetTheme("Dark")
]]

return Styles
