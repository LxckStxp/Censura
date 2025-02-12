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
    
    -- Create header
    if options.title then
        local header = Utils.Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, Styles.Layout.Controls.ButtonHeight),
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
        Parent = container
    })
    
    -- Setup auto-sizing
    local padding = Utils.CreatePadding(content)
    local listLayout = Utils.SetupListLayout(content)
    
    -- Update container size when content changes
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.Size = UDim2.new(1, 0, 0, listLayout.AbsoluteContentSize.Y + 
            (options.title and Styles.Layout.Controls.ButtonHeight or 0) +
            Styles.Layout.Padding.Container * 2)
    end)
    
    -- Helper function to add elements
    function container:AddElement(element)
        element.Parent = content
        return element
    end
    
    return container
end

return Section
