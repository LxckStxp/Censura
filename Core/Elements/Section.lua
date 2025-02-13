-- Core/Elements/Section.lua
local Section = {}

local Utils = _G.Censura.Modules.Utils
local Styles = _G.Censura.Modules.Styles

function Section.new(options)
    options = options or {}
    
    -- Create container
    local container = Utils.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0), -- Auto-size
        BackgroundColor3 = Styles.Colors.Window.Content,
        LayoutOrder = options.layoutOrder
    })
    Utils.ApplyCorners(container)
    
    -- Create header if title is provided
    local headerHeight = 0
    if options.title then
        headerHeight = Styles.Layout.Controls.ButtonHeight
        local header = Utils.Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, headerHeight),
            BackgroundTransparency = 1,
            Text = options.title,
            TextColor3 = Styles.Colors.Text.Primary,
            Font = Styles.Text.Header.Font,
            TextSize = Styles.Text.Header.Size,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        })
    end
    
    -- Create content holder
    local content = Utils.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0), -- Auto-size
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, headerHeight),
        Parent = container
    })
    
    -- Setup auto-sizing
    local padding = Utils.CreatePadding(content)
    local listLayout = Utils.SetupListLayout(content)
    
    -- Update container size when content changes
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.Size = UDim2.new(1, 0, 0, listLayout.AbsoluteContentSize.Y)
        container.Size = UDim2.new(1, 0, 0, content.Size.Y.Offset + 
            headerHeight +
            Styles.Layout.Padding.Container * 2)
    end)
    
    -- Create a table with both the container and content frame
    local section = {
        Container = container,
        ContentFrame = content -- This is what was missing
    }
    
    return section
end

return Section
