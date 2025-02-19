--[[
    CensuraDev Styles Module
    Version: 4.1

    Defines the visual styling and UI configuration for Censura.
]]

local Styles = {}

function Styles.initialize()
    if getgenv().CensuraSystem then return end

    getgenv().CensuraSystem = {
        Colors = {
            Background = Color3.fromRGB(25, 25, 35),
            Accent = Color3.fromRGB(80, 120, 200),
            Text = Color3.fromRGB(240, 240, 245),
            Highlight = Color3.fromRGB(100, 140, 220),
            Enabled = Color3.fromRGB(80, 120, 200),
            Disabled = Color3.fromRGB(255, 85, 85),
            Border = Color3.fromRGB(50, 50, 65),
            SecondaryText = Color3.fromRGB(150, 150, 160)
        },
        UI = {
            WindowSize = UDim2.new(0, 320, 0, 420),
            TitleBarSize = UDim2.new(1, 0, 0, 36),
            ContentPadding = UDim2.new(0, 8, 0, 40),
            ButtonSize = UDim2.new(1, -16, 0, 36),
            ToggleSize = UDim2.new(0, 28, 0, 28),
            SliderSize = UDim2.new(1, -16, 0, 50),
            CornerRadius = UDim.new(0, 10),
            Padding = UDim.new(0, 8),
            ElementSpacing = UDim.new(0, 10),
            Transparency = {
                Background = 0.1,
                Accent = 0.05,
                Text = 0,
                Elements = 0.0
            }
        },
        Animation = {
            TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            DragSmoothing = 0.05
        },
        Settings = {
            DefaultTitle = "Censura",
            ToggleKey = Enum.KeyCode.RightAlt,
            Version = "4.1"
        }
    }
end

function Styles.setTheme(theme)
    local System = getgenv().CensuraSystem
    if not System then return end

    local themes = {
        Dark = {
            Background = Color3.fromRGB(25, 25, 35),
            Accent = Color3.fromRGB(80, 120, 200),
            Text = Color3.fromRGB(240, 240, 245),
            Highlight = Color3.fromRGB(100, 140, 220),
            Border = Color3.fromRGB(50, 50, 65)
        },
        Light = {
            Background = Color3.fromRGB(245, 245, 250),
            Accent = Color3.fromRGB(200, 200, 210),
            Text = Color3.fromRGB(20, 20, 30),
            Highlight = Color3.fromRGB(180, 180, 190),
            Border = Color3.fromRGB(210, 210, 220)
        }
    }

    if themes[theme] then
        for key, value in pairs(themes[theme]) do
            System.Colors[key] = value
        end
    end
end

function Styles.getDefaultGradient(rotation)
    rotation = rotation or 45
    local System = getgenv().CensuraSystem
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, System.Colors.Accent),
        ColorSequenceKeypoint.new(1, System.Colors.Background)
    })
    gradient.Rotation = rotation
    return gradient
end

function Styles.applyGradient(uiObject, rotation)
    local gradient = Styles.getDefaultGradient(rotation)
    gradient.Parent = uiObject
end

return Styles
