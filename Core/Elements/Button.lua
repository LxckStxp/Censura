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
