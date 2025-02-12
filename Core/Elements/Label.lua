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
