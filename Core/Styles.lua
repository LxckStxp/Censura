-- Core/Styles.lua
local Styles = {
    -- Color Schemes
    Colors = {
        -- Primary Theme Colors
        Primary = {
            Main = Color3.fromRGB(90, 90, 255),    -- Main accent color
            Light = Color3.fromRGB(120, 120, 255), -- Lighter variant
            Dark = Color3.fromRGB(70, 70, 235),    -- Darker variant
        },
        
        -- Window Colors
        Window = {
            Background = Color3.fromRGB(25, 25, 25),    -- Main window background
            TitleBar = Color3.fromRGB(30, 30, 30),     -- Title bar background
            Content = Color3.fromRGB(35, 35, 35),      -- Content area background
            Border = Color3.fromRGB(40, 40, 40),       -- Window border
            Shadow = Color3.fromRGB(0, 0, 0),          -- Window shadow
        },
        
        -- Text Colors
        Text = {
            Primary = Color3.fromRGB(255, 255, 255),   -- Primary text
            Secondary = Color3.fromRGB(200, 200, 200), -- Secondary text
            Disabled = Color3.fromRGB(150, 150, 150),  -- Disabled text
            Accent = Color3.fromRGB(90, 90, 255),      -- Accent text
        },
        
        -- Control Colors
        Controls = {
            Button = {
                Default = Color3.fromRGB(45, 45, 45),
                Hover = Color3.fromRGB(55, 55, 55),
                Pressed = Color3.fromRGB(35, 35, 35),
                Disabled = Color3.fromRGB(40, 40, 40),
            },
            Input = {
                Background = Color3.fromRGB(40, 40, 40),
                BackgroundFocused = Color3.fromRGB(45, 45, 45),
                PlaceholderText = Color3.fromRGB(150, 150, 150),
            },
            Toggle = {
                Background = Color3.fromRGB(40, 40, 40),
                BackgroundEnabled = Color3.fromRGB(90, 90, 255),
                Knob = Color3.fromRGB(255, 255, 255),
            },
            Dropdown = {
                Background = Color3.fromRGB(40, 40, 40),
                Option = Color3.fromRGB(45, 45, 45),
                OptionHover = Color3.fromRGB(50, 50, 50),
            },
            ScrollBar = {
                Background = Color3.fromRGB(35, 35, 35),
                Bar = Color3.fromRGB(55, 55, 55),
                BarHover = Color3.fromRGB(65, 65, 65),
            }
        },
        
        -- Status Colors
        Status = {
            Success = Color3.fromRGB(60, 200, 60),
            Warning = Color3.fromRGB(255, 189, 68),
            Error = Color3.fromRGB(255, 75, 75),
            Info = Color3.fromRGB(75, 155, 255),
        }
    },
    
    -- Sizing and Spacing
    Layout = {
        -- Window Dimensions
        Window = {
            MinWidth = 200,
            MinHeight = 150,
            DefaultWidth = 300,
            DefaultHeight = 400,
            TitleBarHeight = 30,
            CornerRadius = 6,
            BorderSize = 1,
            ShadowSize = 4,
        },
        
        -- Control Dimensions
        Controls = {
            ButtonHeight = 32,
            InputHeight = 32,
            ToggleWidth = 44,
            ToggleHeight = 24,
            DropdownHeight = 32,
            ScrollBarThickness = 4,
        },
        
        -- Spacing
        Spacing = {
            Tiny = 4,
            Small = 8,
            Medium = 12,
            Large = 16,
            ExtraLarge = 24,
        },
        
        -- Padding
        Padding = {
            Window = 12,
            Container = 8,
            Control = 6,
        }
    },
    
    -- Typography
    Text = {
        Title = {
            Font = Enum.Font.GothamBold,
            Size = 14,
        },
        Header = {
            Font = Enum.Font.GothamBold,
            Size = 14,
        },
        Default = {
            Font = Enum.Font.Gotham,
            Size = 13,
        },
        Small = {
            Font = Enum.Font.Gotham,
            Size = 12,
        }
    },
    
    -- Animation Presets
    Animation = {
        -- Tween Info Presets
        Short = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        Medium = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        Long = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        
        -- Spring Parameters
        Spring = {
            Default = {
                Frequency = 4,
                Damping = 0.8,
            },
            Bouncy = {
                Frequency = 3.5,
                Damping = 0.6,
            },
            Tight = {
                Frequency = 6,
                Damping = 0.9,
            }
        }
    }
}

-- Example usage functions
function Styles.ApplyWindowStyle(frame)
    frame.BackgroundColor3 = Styles.Colors.Window.Background
    frame.BorderSizePixel = Styles.Layout.Window.BorderSize
    frame.BorderColor3 = Styles.Colors.Window.Border
    
    -- Apply corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, Styles.Layout.Window.CornerRadius)
    corner.Parent = frame
end

function Styles.ApplyButtonStyle(button)
    button.BackgroundColor3 = Styles.Colors.Controls.Button.Default
    button.TextColor3 = Styles.Colors.Text.Primary
    button.Font = Styles.Text.Default.Font
    button.TextSize = Styles.Text.Default.Size
    button.Size = UDim2.new(1, 0, 0, Styles.Layout.Controls.ButtonHeight)
    
    -- Apply corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    -- Add hover effect
    button.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(
            button,
            Styles.Animation.Short,
            {BackgroundColor3 = Styles.Colors.Controls.Button.Hover}
        ):Play()
    end)
    
    button.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(
            button,
            Styles.Animation.Short,
            {BackgroundColor3 = Styles.Colors.Controls.Button.Default}
        ):Play()
    end)
end

return Styles
