-- Core/Elements/Button.lua
local Button = {}

local Utils = _G.Censura.Modules.Utils
local Styles = _G.Censura.Modules.Styles

function Button.new(options)
    options = options or {}
    
    local button = Utils.Create("TextButton", {
        Size = UDim2.new(1, 0, 0, Styles.Layout.Controls.ButtonHeight),
        BackgroundColor3 = Styles.Colors.Controls.Button.Default,
        Text = options.text or "Button",
        TextColor3 = Styles.Colors.Text.Primary,
        Font = Styles.Text.Default.Font,
        TextSize = Styles.Text.Default.Size,
        AutoButtonColor = false,
        LayoutOrder = options.layoutOrder
    })
    
    Utils.ApplyCorners(button)
    Utils.ApplyHoverEffect(button)
    
    if options.onClick then
        button.MouseButton1Click:Connect(options.onClick)
    end
    
    return button
end

return Button

-- Core/Elements/Label.lua
local Label = {}

local Utils = _G.Censura.Modules.Utils
local Styles = _G.Censura.Modules.Styles

function Label.new(options)
    options = options or {}
    
    local label = Utils.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, options.height or Styles.Layout.Controls.ButtonHeight),
        BackgroundTransparency = 1,
        Text = options.text or "Label",
        TextColor3 = options.color or Styles.Colors.Text.Primary,
        Font = options.font or Styles.Text.Default.Font,
        TextSize = options.textSize or Styles.Text.Default.Size,
        TextXAlignment = options.alignment or Enum.TextXAlignment.Left,
        LayoutOrder = options.layoutOrder
    })
    
    return label
end

return Label

-- Core/Elements/Toggle.lua
local Toggle = {}

local Utils = _G.Censura.Modules.Utils
local Styles = _G.Censura.Modules.Styles

function Toggle.new(options)
    options = options or {}
    
    -- Create container
    local container = Utils.Create("Frame", {
        Size = UDim2.new(1, 0, 0, Styles.Layout.Controls.ButtonHeight),
        BackgroundTransparency = 1,
        LayoutOrder = options.layoutOrder
    })
    
    -- Create label
    local label = Utils.Create("TextLabel", {
        Size = UDim2.new(1, -Styles.Layout.Controls.ToggleWidth - 10, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = options.text or "Toggle",
        TextColor3 = Styles.Colors.Text.Primary,
        Font = Styles.Text.Default.Font,
        TextSize = Styles.Text.Default.Size,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    })
    
    -- Create toggle background
    local toggleBackground = Utils.Create("Frame", {
        Size = UDim2.new(0, Styles.Layout.Controls.ToggleWidth, 0, Styles.Layout.Controls.ToggleHeight),
        Position = UDim2.new(1, -Styles.Layout.Controls.ToggleWidth, 0.5, -Styles.Layout.Controls.ToggleHeight/2),
        BackgroundColor3 = Styles.Colors.Controls.Toggle.Background,
        Parent = container
    })
    
    Utils.ApplyCorners(toggleBackground, Styles.Layout.Controls.ToggleHeight/2)
    
    -- Create toggle knob
    local knob = Utils.Create("Frame", {
        Size = UDim2.new(0, Styles.Layout.Controls.ToggleHeight - 4, 0, Styles.Layout.Controls.ToggleHeight - 4),
        Position = UDim2.new(0, 2, 0.5, -((Styles.Layout.Controls.ToggleHeight - 4)/2)),
        BackgroundColor3 = Styles.Colors.Controls.Toggle.Knob,
        Parent = toggleBackground
    })
    
    Utils.ApplyCorners(knob, (Styles.Layout.Controls.ToggleHeight - 4)/2)
    
    -- Toggle state
    local enabled = options.default or false
    local function updateToggle()
        local targetPos = enabled and 
            UDim2.new(1, -(Styles.Layout.Controls.ToggleHeight - 2), 0.5, -((Styles.Layout.Controls.ToggleHeight - 4)/2)) or
            UDim2.new(0, 2, 0.5, -((Styles.Layout.Controls.ToggleHeight - 4)/2))
            
        local targetColor = enabled and 
            Styles.Colors.Controls.Toggle.BackgroundEnabled or
            Styles.Colors.Controls.Toggle.Background
            
        Utils.Tween(knob, {Position = targetPos})
        Utils.Tween(toggleBackground, {BackgroundColor3 = targetColor})
        
        if options.onToggle then
            options.onToggle(enabled)
        end
    end
    
    -- Click handling
    toggleBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            enabled = not enabled
            updateToggle()
        end
    end)
    
    -- Initialize state
    updateToggle()
    
    return container
end

return Toggle
