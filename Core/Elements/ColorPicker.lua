-- Core/Elements/ColorPicker.lua
local ColorPicker = {}

local Utils = _G.Censura.Modules.Utils
local Styles = _G.Censura.Modules.Styles

function ColorPicker.new(options)
    options = options or {}
    local currentColor = options.default or Color3.fromRGB(255, 255, 255)
    local open = false
    
    -- Create container
    local container = Utils.Create("Frame", {
        Size = UDim2.new(1, 0, 0, Styles.Layout.Controls.ButtonHeight),
        BackgroundTransparency = 1,
        LayoutOrder = options.layoutOrder
    })
    
    -- Create label
    local label = Utils.Create("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        Text = options.text or "Color",
        TextColor3 = Styles.Colors.Text.Primary,
        Font = Styles.Text.Default.Font,
        TextSize = Styles.Text.Default.Size,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    -- Create color preview
    local preview = Utils.Create("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -30, 0.5, -15),
        BackgroundColor3 = currentColor,
        Text = "",
        AutoButtonColor = false,
        Parent = container
    })
    Utils.ApplyCorners(preview)
    
    -- Create color picker popup
    local popup = Utils.Create("Frame", {
        Size = UDim2.new(0, 200, 0, 220),
        Position = UDim2.new(1, 10, 0, 0),
        BackgroundColor3 = Styles.Colors.Window.Background,
        Visible = false,
        Parent = container
    })
    Utils.ApplyCorners(popup)
    
    -- Create RGB sliders
    local function createColorSlider(color, defaultValue, yPos)
        local slider = Utils.Create("Frame", {
            Size = UDim2.new(1, -20, 0, 20),
            Position = UDim2.new(0, 10, 0, yPos),
            BackgroundTransparency = 1,
            Parent = popup
        })
        
        local colorBar = Utils.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 4),
            Position = UDim2.new(0, 0, 0.5, -2),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            Parent = slider
        })
        Utils.ApplyCorners(colorBar, 2)
        
        local knob = Utils.Create("Frame", {
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(defaultValue/255, -6, 0.5, -6),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = colorBar
        })
        Utils.ApplyCorners(knob, 6)
        
        -- Slider functionality
        local dragging = false
        
        colorBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local relative = math.clamp((input.Position.X - colorBar.AbsolutePosition.X) / colorBar.AbsoluteSize.X, 0, 1)
                knob.Position = UDim2.new(relative, -6, 0.5, -6)
                return math.floor(relative * 255)
            end
        end)
        
        return slider
    end
    
    local rSlider = createColorSlider("R", currentColor.R * 255, 20)
    local gSlider = createColorSlider("G", currentColor.G * 255, 50)
    local bSlider = createColorSlider("B", currentColor.B * 255, 80)
    
    -- Toggle popup
    preview.MouseButton1Click:Connect(function()
        open = not open
        popup.Visible = open
    end)
    
    return container
end

return ColorPicker
