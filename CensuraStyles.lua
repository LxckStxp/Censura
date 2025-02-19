--[[
    CensuraDev Styles Module
    Version: 4.2
    
    Modern military-tech inspired UI styling
]]

local Styles = {}

function Styles.initialize()
    if getgenv().CensuraSystem then return end

    getgenv().CensuraSystem = {
        Colors = {
            -- Core colors (military-tech inspired)
            Background = Color3.fromRGB(15, 17, 19),     -- Very dark gray with slight blue
            Accent = Color3.fromRGB(210, 215, 220),      -- Light gray for borders/accents
            Text = Color3.fromRGB(225, 228, 230),        -- Soft white
            Highlight = Color3.fromRGB(65, 156, 200),    -- Subtle blue highlight
            Enabled = Color3.fromRGB(140, 195, 185),     -- Soft cyan
            Disabled = Color3.fromRGB(180, 70, 70),      -- Muted red
            Border = Color3.fromRGB(40, 45, 50),         -- Dark border
            SecondaryText = Color3.fromRGB(130, 135, 140) -- Muted text
        },
        UI = {
            WindowSize = UDim2.new(0, 300, 0, 400),      -- Slightly more compact
            TitleBarSize = UDim2.new(1, 0, 0, 32),
            ContentPadding = UDim2.new(0, 6, 0, 36),
            ButtonSize = UDim2.new(1, -12, 0, 32),
            ToggleSize = UDim2.new(0, 24, 0, 24),
            SliderSize = UDim2.new(1, -12, 0, 40),
            CornerRadius = UDim.new(0, 4),               -- Sharper corners
            Padding = UDim.new(0, 6),
            ElementSpacing = UDim.new(0, 6),
            Transparency = {
                Background = 0.15,                        -- More transparent
                Accent = 0.1,
                Text = 0,
                Elements = 0.08
            }
        },
        Animation = {
            TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            DragSmoothing = 0.05
        },
        Settings = {
            DefaultTitle = "Censura",
            ToggleKey = Enum.KeyCode.RightAlt,
            Version = "4.2"
        }
    }
end

function Styles.setTheme(theme)
    local System = getgenv().CensuraSystem
    if not System then return end

    local themes = {
        Dark = {
            Background = Color3.fromRGB(15, 17, 19),
            Accent = Color3.fromRGB(210, 215, 220),
            Text = Color3.fromRGB(225, 228, 230),
            Highlight = Color3.fromRGB(65, 156, 200),
            Border = Color3.fromRGB(40, 45, 50)
        },
        Light = {
            Background = Color3.fromRGB(240, 242, 245),
            Accent = Color3.fromRGB(180, 185, 190),
            Text = Color3.fromRGB(40, 42, 45),
            Highlight = Color3.fromRGB(65, 156, 200),
            Border = Color3.fromRGB(200, 205, 210)
        }
    }

    if themes[theme] then
        for key, value in pairs(themes[theme]) do
            System.Colors[key] = value
        end
    end
end

function Styles.getDefaultGradient(rotation)
    rotation = rotation or 90
    local System = getgenv().CensuraSystem
    local gradient = Instance.new("UIGradient")
    
    -- Subtle three-point gradient
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, System.Colors.Border),
        ColorSequenceKeypoint.new(0.5, System.Colors.Background),
        ColorSequenceKeypoint.new(1, System.Colors.Border)
    })
    
    -- Add transparency to make it more subtle
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(0.5, 0.2),
        NumberSequenceKeypoint.new(1, 0.1)
    })
    
    gradient.Rotation = rotation
    return gradient
end

function Styles.applyGradient(uiObject, rotation)
    local gradient = Styles.getDefaultGradient(rotation)
    gradient.Parent = uiObject
    
    -- Add subtle border stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = getgenv().CensuraSystem.Colors.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.7
    stroke.Parent = uiObject
end

return Styles
