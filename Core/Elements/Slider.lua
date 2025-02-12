-- Core/Elements/Slider.lua
local Slider = {}

local Utils = _G.Censura.Modules.Utils
local Styles = _G.Censura.Modules.Styles

function Slider.new(options)
    options = options or {}
    local min = options.min or 0
    local max = options.max or 100
    local default = math.clamp(options.default or min, min, max)
    
    -- Create container
    local container = Utils.Create("Frame", {
        Size = UDim2.new(1, 0, 0, Styles.Layout.Controls.ButtonHeight * 1.5),
        BackgroundTransparency = 1,
        LayoutOrder = options.layoutOrder
    })
    
    -- Create label and value display
    local label = Utils.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, Styles.Layout.Controls.ButtonHeight/2),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = options.text or "Slider",
        TextColor3 = Styles.Colors.Text.Primary,
        Font = Styles.Text.Default.Font,
        TextSize = Styles.Text.Default.Size,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    local valueLabel = Utils.Create("TextLabel", {
        Size = UDim2.new(0, 50, 0, Styles.Layout.Controls.ButtonHeight/2),
        Position = UDim2.new(1, -50, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = Styles.Colors.Text.Secondary,
        Font = Styles.Text.Default.Font,
        TextSize = Styles.Text.Default.Size,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = container
    })
    
    -- Create slider bar
    local sliderBar = Utils.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 4),
        Position = UDim2.new(0, 0, 0.7, 0),
        BackgroundColor3 = Styles.Colors.Controls.Button.Default,
        Parent = container
    })
    Utils.ApplyCorners(sliderBar, 2)
    
    -- Create slider fill
    local sliderFill = Utils.Create("Frame", {
        Size = UDim2.new((default - min)/(max - min), 0, 1, 0),
        BackgroundColor3 = Styles.Colors.Primary.Main,
        Parent = sliderBar
    })
    Utils.ApplyCorners(sliderFill, 2)
    
    -- Create slider knob
    local knob = Utils.Create("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new((default - min)/(max - min), -8, 0.5, -8),
        BackgroundColor3 = Styles.Colors.Primary.Main,
        Parent = sliderBar
    })
    Utils.ApplyCorners(knob, 8)
    
    -- Slider functionality
    local dragging = false
    local function updateSlider(input)
        local relative = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (relative * (max - min)))
        
        sliderFill.Size = UDim2.new(relative, 0, 1, 0)
        knob.Position = UDim2.new(relative, -8, 0.5, -8)
        valueLabel.Text = tostring(value)
        
        if options.onValueChanged then
            options.onValueChanged(value)
        end
    end
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    return container
end

return Slider
