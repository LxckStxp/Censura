-- Core/Elements/TabSystem.lua
local TabSystem = {}

local Utils = _G.Censura.Modules.Utils
local Styles = _G.Censura.Modules.Styles

function TabSystem.new(options)
    options = options or {}
    local tabs = {}
    local currentTab = nil
    
    -- Create main container
    local container = Utils.Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        LayoutOrder = options.layoutOrder
    })
    
    -- Create tab bar
    local tabBar = Utils.Create("Frame", {
        Size = UDim2.new(1, 0, 0, Styles.Layout.Controls.ButtonHeight),
        BackgroundColor3 = Styles.Colors.Window.TitleBar,
        Parent = container
    })
    Utils.ApplyCorners(tabBar)
    
    -- Create tab button container
    local tabButtons = Utils.Create("Frame", {
        Size = UDim2.new(1, -10, 1, -4),
        Position = UDim2.new(0, 5, 0, 2),
        BackgroundTransparency = 1,
        Parent = tabBar
    })
    
    -- Setup tab button layout
    local tabLayout = Utils.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = tabButtons
    })
    
    -- Create content container
    local contentContainer = Utils.Create("Frame", {
        Size = UDim2.new(1, 0, 1, -(Styles.Layout.Controls.ButtonHeight + 5)),
        Position = UDim2.new(0, 0, 0, Styles.Layout.Controls.ButtonHeight + 5),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = container
    })
    
    -- Tab management functions
    local function createTabButton(name)
        local button = Utils.Create("TextButton", {
            Size = UDim2.new(0, 100, 1, 0),
            BackgroundColor3 = Styles.Colors.Controls.Button.Default,
            Text = name,
            TextColor3 = Styles.Colors.Text.Primary,
            Font = Styles.Text.Default.Font,
            TextSize = Styles.Text.Default.Size,
            AutoButtonColor = false,
            Parent = tabButtons
        })
        Utils.ApplyCorners(button)
        
        -- Create selection indicator
        local indicator = Utils.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = Styles.Colors.Primary.Main,
            BackgroundTransparency = 1,
            Parent = button
        })
        
        return button, indicator
    end
    
    local function switchTab(tab)
        if currentTab == tab then return end
        
        -- Update button styles
        for _, t in pairs(tabs) do
            local isSelected = t == tab
            Utils.Tween(t.button, {
                BackgroundColor3 = isSelected 
                    and Styles.Colors.Controls.Button.Pressed
                    or Styles.Colors.Controls.Button.Default
            })
            Utils.Tween(t.indicator, {
                BackgroundTransparency = isSelected and 0 or 1
            })
            
            -- Animate content
            if t.content then
                if isSelected then
                    t.content.Visible = true
                    Utils.Tween(t.content, {
                        Position = UDim2.new(0, 0, 0, 0),
                        BackgroundTransparency = 0
                    })
                else
                    Utils.Tween(t.content, {
                        Position = UDim2.new(0.1, 0, 0, 0),
                        BackgroundTransparency = 1
                    }).Completed:Connect(function()
                        t.content.Visible = false
                    end)
                end
            end
        end
        
        currentTab = tab
    end
    
    -- Public methods
    function container:AddTab(name)
        local button, indicator = createTabButton(name)
        
        -- Create content frame
        local content = Utils.Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Styles.Colors.Controls.ScrollBar.Bar,
            Visible = false,
            Parent = contentContainer
        })
        
        -- Setup content layout
        Utils.SetupListLayout(content, {
            Padding = UDim.new(0, Styles.Layout.Spacing.Medium)
        })
        Utils.CreatePadding(content)
        
        -- Create tab data
        local tab = {
            name = name,
            button = button,
            indicator = indicator,
            content = content
        }
        
        -- Setup button click handler
        button.MouseButton1Click:Connect(function()
            switchTab(tab)
        end)
        
        -- Add to tabs table
        table.insert(tabs, tab)
        
        -- Switch to first tab automatically
        if #tabs == 1 then
            switchTab(tab)
        end
        
        -- Return content frame for adding elements
        return content
    end
    
    -- Optional: Add method to switch tabs programmatically
    function container:SelectTab(name)
        for _, tab in pairs(tabs) do
            if tab.name == name then
                switchTab(tab)
                break
            end
        end
    end
    
    -- Optional: Add method to get current tab
    function container:GetCurrentTab()
        return currentTab and currentTab.name
    end
    
    return container
end

return TabSystem
