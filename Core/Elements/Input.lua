-- Core/Elements/Input.lua
local Input = {}

local Utils = _G.Censura.Modules.Utils
local Styles = _G.Censura.Modules.Styles

function Input.new(options)
    options = options or {}
    
    -- Create container
    local container = Utils.Create("Frame", {
        Size = UDim2.new(1, 0, 0, Styles.Layout.Controls.ButtonHeight * 1.5),
        BackgroundTransparency = 1,
        LayoutOrder = options.layoutOrder
    })
    
    -- Create label
    if options.text then
        local label = Utils.Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, Styles.Layout.Controls.ButtonHeight/2),
            BackgroundTransparency = 1,
            Text = options.text,
            TextColor3 = Styles.Colors.Text.Primary,
            Font = Styles.Text.Default.Font,
            TextSize = Styles.Text.Default.Size,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        })
    end
    
    -- Create input box
    local inputBox = Utils.Create("TextBox", {
        Size = UDim2.new(1, 0, 0, Styles.Layout.Controls.ButtonHeight),
        Position = UDim2.new(0, 0, 1, -Styles.Layout.Controls.ButtonHeight),
        BackgroundColor3 = Styles.Colors.Controls.Input.Background,
        Text = options.default or "",
        PlaceholderText = options.placeholder or "Enter text...",
        PlaceholderColor3 = Styles.Colors.Controls.Input.PlaceholderText,
        TextColor3 = Styles.Colors.Text.Primary,
        Font = Styles.Text.Default.Font,
        TextSize = Styles.Text.Default.Size,
        ClearTextOnFocus = options.clearOnFocus ~= false,
        Parent = container
    })
    Utils.ApplyCorners(inputBox)
    
    -- Input box effects
    inputBox.Focused:Connect(function()
        Utils.Tween(inputBox, {
            BackgroundColor3 = Styles.Colors.Controls.Input.BackgroundFocused
        })
    end)
    
    inputBox.FocusLost:Connect(function(enterPressed)
        Utils.Tween(inputBox, {
            BackgroundColor3 = Styles.Colors.Controls.Input.Background
        })
        
        if options.onTextChanged then
            options.onTextChanged(inputBox.Text, enterPressed)
        end
    end)
    
    return container
end

return Input
