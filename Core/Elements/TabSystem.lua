-- Core/Elements/TabSystem.lua
local TabSystem = {}

local Utils = _G.Censura.Modules.Utils
local Styles = _G.Censura.Modules.Styles

function TabSystem.new(options)
    options = options or {}
    
    -- Internal state
    local self = {
        tabs = {},
        currentTab = nil,
        onTabChanged = options.onTabChanged
    }
    
    -- Create main container
    local container = Utils.Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        LayoutOrder = options.layoutOrder
    })
    
    -- Create tab bar with better styling
    local tabBar = Utils.Create("Frame", {
        Size = UDim2.new(1, 0, 0, Styles.Layout.Controls.ButtonHeight),
        BackgroundColor3 = Styles.Colors.Window.TitleBar,
        Parent = container
    })
    Utils.ApplyCorners(tabBar)
    
    -- Improved tab button container
    local tabButtons = Utils.Create("Frame", {
        Size = UDim2.new(1, -10, 1, -4),
        Position = UDim2.new(0, 5, 0, 2),
        BackgroundTransparency = 1,
        Parent = tabBar
    })
    
    -- Auto-sizing tab layout
    local tabLayout = Utils.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = tabButtons
    })
    
    -- Add auto-sizing behavior
    local function updateTabButtonSizes()
        local tabCount = #self.tabs
        if tabCount > 0 then
            local availableWidth = tabButtons.AbsoluteSize.X - (tabLayout.Padding.Offset * (tabCount - 1))
            local buttonWidth = math.floor(availableWidth / tabCount)
            for _, tab in ipairs(self.tabs) do
                tab.button.Size = UDim2.new(0, buttonWidth, 1, 0)
            end
        end
    end
    
    tabButtons:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateTabButtonSizes)
    
    -- Improved content container with smooth transitions
    local contentContainer = Utils.Create("Frame", {
        Size = UDim2.new(1, 0, 1, -(Styles.Layout.Controls.ButtonHeight + 5)),
        Position = UDim2.new(0, 0, 0, Styles.Layout.Controls.ButtonHeight + 5),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = container
    })
    
    -- Enhanced tab button creation
    local function createTabButton(name, index)
        local button = Utils.Create("TextButton", {
            BackgroundColor3 = Styles.Colors.Controls.Button.Default,
            Text = name,
            TextColor3 = Styles.Colors.Text.Primary,
            Font = Styles.Text.Default.Font,
            TextSize = Styles.Text.Default.Size,
            AutoButtonColor = false,
            LayoutOrder = index,
            Parent = tabButtons
        })
        Utils.ApplyCorners(button)
        
        -- Improved selection indicator
        local indicator = Utils.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = Styles.Colors.Primary.Main,
            BackgroundTransparency = 1,
            Parent = button
        })
        
        -- Add hover effect
        button.MouseEnter:Connect(function()
            if self.currentTab and self.currentTab.button ~= button then
                Utils.Tween(button, {
                    BackgroundColor3 = Styles.Colors.Controls.Button.Hover
                })
            end
        end)
        
        button.MouseLeave:Connect(function()
            if self.currentTab and self.currentTab.button ~= button then
                Utils.Tween(button, {
                    BackgroundColor3 = Styles.Colors.Controls.Button.Default
                })
            end
        end)
        
        return button, indicator
    end
    
    -- Improved tab switching with animations
    local function switchTab(tab)
        if self.currentTab == tab then return end
        
        -- Store previous tab for animation
        local previousTab = self.currentTab
        self.currentTab = tab
        
        -- Update all tabs
        for _, t in ipairs(self.tabs) do
            local isSelected = t == tab
            
            -- Animate button
            Utils.Tween(t.button, {
                BackgroundColor3 = isSelected 
                    and Styles.Colors.Controls.Button.Pressed
                    or Styles.Colors.Controls.Button.Default
            })
            
            -- Animate indicator
            Utils.Tween(t.indicator, {
                BackgroundTransparency = isSelected and 0 or 1
            })
            
            -- Handle content visibility and transitions
            if t.content then
                if isSelected then
                    t.content.Position = UDim2.new(0.1, 0, 0, 0)
                    t.content.BackgroundTransparency = 1
                    t.content.Visible = true
                    
                    Utils.Tween(t.content, {
                        Position = UDim2.new(0, 0, 0, 0),
                        BackgroundTransparency = 0
                    })
                else
                    if t == previousTab then
                        Utils.Tween(t.content, {
                            Position = UDim2.new(-0.1, 0, 0, 0),
                            BackgroundTransparency = 1
                        }).Completed:Connect(function()
                            t.content.Visible = false
                        end)
                    else
                        t.content.Visible = false
                    end
                end
            end
        end
        
        -- Call onTabChanged callback if provided
        if self.onTabChanged then
            self.onTabChanged(tab.name)
        end
    end
    
    -- Public methods
    function container:AddTab(name)
        local index = #self.tabs + 1
        local button, indicator = createTabButton(name, index)
        
        -- Create scrolling content frame
        local content = Utils.Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Styles.Colors.Controls.ScrollBar.Bar,
            Visible = false,
            Parent = contentContainer
        })
        
        -- Setup content layout
        Utils.SetupListLayout(content)
        Utils.CreatePadding(content)
        
        -- Create tab data
        local tab = {
            name = name,
            button = button,
            indicator = indicator,
            content = content,
            index = index
        }
        
        -- Setup button click handler
        button.MouseButton1Click:Connect(function()
            switchTab(tab)
        end)
        
        -- Add to tabs table
        table.insert(self.tabs, tab)
        updateTabButtonSizes()
        
        -- Switch to first tab automatically
        if #self.tabs == 1 then
            switchTab(tab)
        end
        
        return content
    end
    
    function container:SelectTab(name)
        for _, tab in ipairs(self.tabs) do
            if tab.name == name then
                switchTab(tab)
                break
            end
        end
    end
    
    function container:GetCurrentTab()
        return self.currentTab and self.currentTab.name
    end
    
    function container:GetTabs()
        local tabNames = {}
        for _, tab in ipairs(self.tabs) do
            table.insert(tabNames, tab.name)
        end
        return tabNames
    end
    
    return container
end

return TabSystem
