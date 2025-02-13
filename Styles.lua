--[[
    Censura UI System - Styles Module
    Author: LxckStxp
    Version: 2.0.0
    
    This module contains all styling configurations for the Censura UI system.
    It provides a comprehensive theming system with consistent colors, animations,
    and layout settings.
--]]

local Styles = {
    Theme = {
        -- Main Color Palette
        Primary = {
            Main = Color3.fromRGB(90, 90, 255),      -- Primary accent color
            Light = Color3.fromRGB(120, 120, 255),   -- Lighter variant
            Dark = Color3.fromRGB(70, 70, 235),      -- Darker variant
            Text = Color3.fromRGB(255, 255, 255)     -- Text on primary
        },
        
        -- Background Colors
        Background = {
            Main = Color3.fromRGB(25, 25, 25),       -- Main background
            Light = Color3.fromRGB(30, 30, 30),      -- Lighter background
            Dark = Color3.fromRGB(20, 20, 20),       -- Darker background
            Accent = Color3.fromRGB(35, 35, 35)      -- Accent background
        },
        
        -- Text Colors
        Text = {
            Primary = Color3.fromRGB(255, 255, 255),    -- Primary text
            Secondary = Color3.fromRGB(200, 200, 200),  -- Secondary text
            Disabled = Color3.fromRGB(150, 150, 150),   -- Disabled text
            Accent = Color3.fromRGB(90, 90, 255)        -- Accent text
        },
        
        -- UI Element Colors
        Elements = {
            Window = {
                Background = Color3.fromRGB(25, 25, 25),
                TitleBar = Color3.fromRGB(30, 30, 30),
                Border = Color3.fromRGB(40, 40, 40),
                Shadow = Color3.fromRGB(0, 0, 0)
            },
            
            Button = {
                Default = Color3.fromRGB(45, 45, 45),
                Hover = Color3.fromRGB(55, 55, 55),
                Press = Color3.fromRGB(35, 35, 35),
                Disabled = Color3.fromRGB(40, 40, 40)
            },
            
            Toggle = {
                Background = Color3.fromRGB(40, 40, 40),
                BackgroundEnabled = Color3.fromRGB(90, 90, 255),
                Knob = Color3.fromRGB(255, 255, 255),
                KnobEnabled = Color3.fromRGB(255, 255, 255)
            },
            
            Slider = {
                Background = Color3.fromRGB(40, 40, 40),
                Fill = Color3.fromRGB(90, 90, 255),
                Knob = Color3.fromRGB(255, 255, 255)
            },
            
            Input = {
                Background = Color3.fromRGB(40, 40, 40),
                BackgroundFocused = Color3.fromRGB(45, 45, 45),
                PlaceholderText = Color3.fromRGB(150, 150, 150),
                Text = Color3.fromRGB(255, 255, 255)
            },
            
            ScrollBar = {
                Background = Color3.fromRGB(35, 35, 35),
                Bar = Color3.fromRGB(55, 55, 55),
                Hover = Color3.fromRGB(65, 65, 65)
            }
        },
        
        -- Status Colors
        Status = {
            Success = Color3.fromRGB(60, 200, 60),
            Warning = Color3.fromRGB(255, 189, 68),
            Error = Color3.fromRGB(255, 75, 75),
            Info = Color3.fromRGB(75, 155, 255)
        }
    },
    
    -- Typography
    Font = {
        Default = {
            Family = Enum.Font.Gotham,
            Size = 14,
            Weight = Enum.FontWeight.Regular
        },
        Title = {
            Family = Enum.Font.GothamBold,
            Size = 16,
            Weight = Enum.FontWeight.Bold
        },
        Small = {
            Family = Enum.Font.Gotham,
            Size = 12,
            Weight = Enum.FontWeight.Regular
        }
    },
    
    -- Layout Settings
    Layout = {
        Window = {
            MinWidth = 200,
            MinHeight = 150,
            DefaultWidth = 300,
            DefaultHeight = 400,
            TitleHeight = 30,
            CornerRadius = 6,
            Shadow = {
                Size = 4,
                Transparency = 0.5
            }
        },
        
        Elements = {
            ButtonHeight = 32,
            ToggleWidth = 44,
            ToggleHeight = 24,
            SliderHeight = 4,
            InputHeight = 32,
            ScrollBarWidth = 4
        },
        
        Spacing = {
            Tiny = 4,
            Small = 8,
            Medium = 12,
            Large = 16,
            ExtraLarge = 24
        },
        
        Padding = {
            Window = 12,
            Container = 8,
            Element = 6
        }
    },
    
    -- Animation Presets
    Animation = {
        -- TweenInfo Presets
        Short = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        Medium = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        Long = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        
        -- Spring Parameters
        Spring = {
            Default = {
                Frequency = 4,
                Damping = 0.8
            },
            Bouncy = {
                Frequency = 3.5,
                Damping = 0.6
            },
            Tight = {
                Frequency = 6,
                Damping = 0.9
            }
        }
    }
}

-- Utility Functions for Style Management
function Styles:GetColor(path)
    local value = self.Theme
    for _, key in ipairs(path:split(".")) do
        value = value[key]
        if not value then
            return nil
        end
    end
    return value
end

function Styles:GetFont(style)
    return self.Font[style] or self.Font.Default
end

function Styles:GetAnimation(style)
    return self.Animation[style] or self.Animation.Short
end

-- Example Usage:
--[[
    local color = Styles:GetColor("Elements.Button.Default")
    local font = Styles:GetFont("Title")
    local animation = Styles:GetAnimation("Short")
    
    -- Create a button with these styles:
    local button = Instance.new("TextButton")
    button.BackgroundColor3 = color
    button.Font = font.Family
    button.TextSize = font.Size
    
    -- Animate the button:
    local tween = TweenService:Create(button, animation, {
        BackgroundColor3 = Styles:GetColor("Elements.Button.Hover")
    })
    tween:Play()
--]]

return Styles
