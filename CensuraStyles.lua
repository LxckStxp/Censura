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
            Background = Color3.fromRGB(15, 17, 19),      -- Deep dark gray
            Accent = Color3.fromRGB(255, 30, 50),         -- Hot rod red
            Text = Color3.fromRGB(225, 228, 230),         -- Soft white
            Highlight = Color3.fromRGB(255, 65, 85),      -- Lighter red for highlights
            Enabled = Color3.fromRGB(50, 200, 100),       -- Success green
            Disabled = Color3.fromRGB(180, 70, 70),       -- Muted red
            Border = Color3.fromRGB(40, 45, 50),          -- Dark border
            SecondaryText = Color3.fromRGB(130, 135, 140) -- Muted text
        },
        UI = {
            WindowSize = UDim2.new(0, 300, 0, 400),
            TitleBarSize = UDim2.new(1, 0, 0, 32),
            ContentPadding = UDim2.new(0, 6, 0, 36),
            ButtonSize = UDim2.new(1, -12, 0, 32),
            ToggleSize = UDim2.new(0, 24, 0, 24),
            SliderSize = UDim2.new(1, -12, 0, 40),
            CornerRadius = UDim.new(0, 4),               -- Corrected to UDim
            Padding = UDim.new(0, 6),                    -- Corrected to UDim
            ElementSpacing = UDim.new(0, 6),             -- Corrected to UDim
            Transparency = {
                Background = 0.15,
                Accent = 0.1,
                Text = 0,
                Elements = 0.08,
                TitleBar = 0.8
            }
        },
        Animation = {  -- Add this section
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
            Accent = Color3.fromRGB(255, 30, 50),
            Text = Color3.fromRGB(225, 228, 230),
            Highlight = Color3.fromRGB(255, 65, 85),
            Border = Color3.fromRGB(40, 45, 50)
        },
        Light = {
            Background = Color3.fromRGB(240, 242, 245),
            Accent = Color3.fromRGB(255, 30, 50),
            Text = Color3.fromRGB(40, 42, 45),
            Highlight = Color3.fromRGB(255, 65, 85),
            Border = Color3.fromRGB(200, 205, 210)
        }
    }

    if themes[theme] then
        for key, value in pairs(themes[theme]) do
            System.Colors[key] = value
        end
    end
end

function Styles.createStroke(color, transparency, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or getgenv().CensuraSystem.Colors.Border
    stroke.Transparency = transparency or 0.7
    stroke.Thickness = thickness or 1
    return stroke
end

return Styles
