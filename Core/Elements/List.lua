-- Core/Elements/List.lua
local List = {}

local Utils = _G.Censura.Modules.Utils
local Styles = _G.Censura.Modules.Styles

function List.new(options)
    options = options or {}
    local items = options.items or {}
    local selected = options.default or nil
    
    -- Create container
    local container = Utils.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 200),
        BackgroundColor3 = Styles.Colors.Window.Content,
        LayoutOrder = options.layoutOrder
    })
    Utils.ApplyCorners(container)
    
    -- Create header
    if options.title then
        local header = Utils.Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Text = options.title,
            TextColor3 = Styles.Colors.Text.Primary,
            Font = Styles.Text.Header.Font,
            TextSize = Styles.Text.Header.Size,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        })
    end
    
    -- Create scrolling frame
    local scrollFrame = Utils.Create("ScrollingFrame", {
        Size = UDim2.new(1, -10, 1, options.title and -40 or -10),
        Position = UDim2.new(0, 5, 0, options.title and 35 or 5),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        Parent = container
    })
    
    -- Setup list layout
    local listLayout = Utils.SetupListLayout(scrollFrame)
    
    -- Create list items
    local function createItem(text)
        local item = Utils.Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Styles.Colors.Controls.Button.Default,
            Text = text,
            TextColor3 = Styles.Colors.Text.Primary,
            Font = Styles.Text.Default.Font,
            TextSize = Styles.Text.Default.Size,
            AutoButtonColor = false,
            Parent = scrollFrame
        })
        Utils.ApplyCorners(item)
        Utils.ApplyHoverEffect(item)
        
        item.MouseButton1Click:Connect(function()
            selected = text
            if options.onSelect then
                options.onSelect(text)
            end
        end)
        
        return item
    end
    
    -- Add initial items
    for _, item in ipairs(items) do
        createItem(item)
    end
    
    -- Add methods
    function container:AddItem(text)
        table.insert(items, text)
        createItem(text)
    end
    
    function container:RemoveItem(text)
        for i, item in ipairs(items) do
            if item == text then
                table.remove(items, i)
                break
            end
        end
        
        for _, child in ipairs(scrollFrame:GetChildren()) do
            if child:IsA("TextButton") and child.Text == text then
                child:Destroy()
                break
            end
        end
    end
    
    function container:GetSelected()
        return selected
    end
    
    return container
end

return List
