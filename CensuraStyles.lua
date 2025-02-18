--[[
    CensuraDev Styles Module
    Version: 4.0
    
    Defines the visual styling and UI configuration for Censura
]]

local Styles = {}

function Styles.initialize()
    -- Check if CensuraSystem already exists
    if getgenv().CensuraSystem then return end
    
    -- Initialize the global styling system
    getgenv().CensuraSystem = {
        Colors = {
            Background = Color3.fromRGB(15, 15, 25),
            Accent = Color3.fromRGB(30, 30, 45),
            Text = Color3.fromRGB(255, 255, 255),
            Highlight = Color3.fromRGB(45, 45, 65),
            Enabled = Color3.fromRGB(126, 131, 255),
            Disabled = Color3.fromRGB(255, 85, 85),
            Border = Color3.fromRGB(60, 60, 80),
            SecondaryText = Color3.fromRGB(180, 180, 190)
        },
        UI = {
            WindowSize = UDim2.new(0, 300, 0, 400),
            TitleBarSize = UDim2.new(1, 0, 0, 32),
            ContentPadding = UDim2.new(0, 5, 0, 35),
            ButtonSize = UDim2.new(1, -12, 0, 32),
            ToggleSize = UDim2.new(0, 24, 0, 24),
            SliderSize = UDim2.new(1, -12, 0, 45),
            CornerRadius = UDim.new(0, 8),
            Padding = UDim.new(0, 6),
            ElementSpacing = UDim.new(0, 8),
            Transparency = {
                Background = 0.2,
                Accent = 0.1,
                Text = 0,
                Elements = 0.05
            }
        },
        Animation = {
            TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            DragSmoothing = 0.05
        },
        Settings = {
            DefaultTitle = "Censura",
            ToggleKey = Enum.KeyCode.RightAlt,
            Version = "4.0"
        }
    }
end

-- Optional: Add theme management functions
function Styles.setTheme(theme)
    local System = getgenv().CensuraSystem
    if not System then return end
    
    -- Example themes
    local themes = {
        Dark = {
            Background = Color3.fromRGB(15, 15, 25),
            Accent = Color3.fromRGB(30, 30, 45),
            -- ... other colors
        },
        Light = {
            Background = Color3.fromRGB(240, 240, 245),
            Accent = Color3.fromRGB(220, 220, 230),
            -- ... other colors
        }
    }
    
    if themes[theme] then
        for color, value in pairs(themes[theme]) do
            System.Colors[color] = value
        end
    end
end

return Styles
