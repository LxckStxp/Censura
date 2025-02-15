--[[
    Censura UI Components v2.1.0
    Part of the Censura UI System
]]

-- This module requires the main Censura module
local Components = {}

-- Component Base Class and Factory
local function CreateComponentFactory(Censura, Services)
    local ComponentFactory = {}
    ComponentFactory.__index = ComponentFactory

    function ComponentFactory.new(className, properties)
        local self = setmetatable({
            Instance = Censura:Create(className, properties),
            Events = {},
            Children = {},
            _destroyed = false
        }, ComponentFactory)
        
        -- Add to active elements for management
        table.insert(Censura.Active.Elements, self)
        return self
    end

    return ComponentFactory
end

-- Create component definitions
function Components.Initialize(Censura, Services)
    local ComponentFactory = CreateComponentFactory(Censura, Services)

    -- Button Component
    local function CreateButton(options)
        local button = ComponentFactory.new("TextButton", {
            Size = options.size or Censura.Config.Layout.DefaultSize.Button,
            Position = options.position,
            BackgroundColor3 = options.backgroundColor or Censura.Config.Theme.Primary,
            Text = options.text or "Button",
            TextColor3 = Censura.Config.Theme.Text,
            Font = Censura.Config.Fonts.Text,
            TextSize = Censura.Config.Fonts.Size.Text,
            AutoButtonColor = true,
            Parent = options.parent
        })

        -- Add hover effect
        button.Instance.MouseEnter:Connect(function()
            Services.TweenService:Create(button.Instance, 
                Censura.Config.Animation.Short, 
                {BackgroundColor3 = Censura.Config.Theme.Highlight}
            ):Play()
        end)

        button.Instance.MouseLeave:Connect(function()
            Services.TweenService:Create(button.Instance, 
                Censura.Config.Animation.Short, 
                {BackgroundColor3 = Censura.Config.Theme.Primary}
            ):Play()
        end)

        -- Add click effect
        button.Instance.MouseButton1Click:Connect(function()
            -- Ripple effect
            local ripple = Censura:Create("Frame", {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundColor3 = Censura.Config.Theme.Highlight,
                BackgroundTransparency = 0.8,
                Parent = button.Instance
            })
            
            Censura:Create("UICorner", {
                CornerRadius = Censura.Config.Layout.CornerRadius.Round,
                Parent = ripple
            })

            Services.TweenService:Create(ripple, 
                Censura.Config.Animation.Medium, 
                {
                    Size = UDim2.new(1.5, 0, 1.5, 0),
                    BackgroundTransparency = 1
                }
            ):Play()

            task.delay(0.4, function()
                ripple:Destroy()
            end)

            if options.callback then
                options.callback()
            end
        end)

        return button
    end

    -- Toggle Component
    local function CreateToggle(options)
        local container = ComponentFactory.new("Frame", {
            Size = Censura.Config.Layout.DefaultSize.Toggle,
            BackgroundTransparency = 1,
            Parent = options.parent
        })

        local label = Censura:Create("TextLabel", {
            Size = UDim2.new(1, -50, 1, 0),
            BackgroundTransparency = 1,
            Text = options.text or "Toggle",
            TextColor3 = Censura.Config.Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Censura.Config.Fonts.Text,
            TextSize = Censura.Config.Fonts.Size.Text,
            Parent = container.Instance
        })

        local toggleButton = Censura:Create("Frame", {
            Size = UDim2.new(0, 40, 0, 20),
            Position = UDim2.new(1, -40, 0.5, -10),
            BackgroundColor3 = Censura.Config.Theme.Error,
            Parent = container.Instance
        })

        Censura:Create("UICorner", {
            CornerRadius = Censura.Config.Layout.CornerRadius.Round,
            Parent = toggleButton
        })

        local knob = Censura:Create("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = Censura.Config.Theme.Text,
            Parent = toggleButton
        })

        Censura:Create("UICorner", {
            CornerRadius = Censura.Config.Layout.CornerRadius.Round,
            Parent = knob
        })

        -- Toggle state
        local enabled = options.default or false
        local function updateVisual()
            Services.TweenService:Create(toggleButton, 
                Censura.Config.Animation.Short,
                {BackgroundColor3 = enabled and Censura.Config.Theme.Success or Censura.Config.Theme.Error}
            ):Play()

            Services.TweenService:Create(knob,
                Censura.Config.Animation.Short,
                {Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}
            ):Play()
        end

        updateVisual()

        toggleButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                enabled = not enabled
                updateVisual()
                if options.callback then
                    options.callback(enabled)
                end
            end
        end)

        return {
            Instance = container.Instance,
            SetValue = function(value)
                enabled = value
                updateVisual()
            end,
            GetValue = function()
                return enabled
            end
        }
    end

    -- Return the component constructors
    return {
        Button = CreateButton,
        Toggle = CreateToggle
        -- More components will be added in the next part
    }
end

-- Continue adding components to the Initialize function
    -- Slider Component
    local function CreateSlider(options)
        local container = ComponentFactory.new("Frame", {
            Size = Censura.Config.Layout.DefaultSize.Slider,
            BackgroundTransparency = 1,
            Parent = options.parent
        })

        -- Header with value display
        local header = Censura:Create("Frame", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Parent = container.Instance
        })

        local label = Censura:Create("TextLabel", {
            Size = UDim2.new(1, -45, 1, 0),
            BackgroundTransparency = 1,
            Text = options.text or "Slider",
            TextColor3 = Censura.Config.Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Censura.Config.Fonts.Text,
            TextSize = Censura.Config.Fonts.Size.Text,
            Parent = header
        })

        local valueDisplay = Censura:Create("TextLabel", {
            Size = UDim2.new(0, 40, 1, 0),
            Position = UDim2.new(1, -40, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(options.default or options.min or 0),
            TextColor3 = Censura.Config.Theme.TextDark,
            TextXAlignment = Enum.TextXAlignment.Right,
            Font = Censura.Config.Fonts.Mono,
            TextSize = Censura.Config.Fonts.Size.Text,
            Parent = header
        })

        -- Slider track
        local track = Censura:Create("Frame", {
            Size = UDim2.new(1, 0, 0, 4),
            Position = UDim2.new(0, 0, 0, 30),
            BackgroundColor3 = Censura.Config.Theme.Secondary,
            Parent = container.Instance
        })

        Censura:Create("UICorner", {
            CornerRadius = Censura.Config.Layout.CornerRadius.Round,
            Parent = track
        })

        local fill = Censura:Create("Frame", {
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = Censura.Config.Theme.Primary,
            Parent = track
        })

        Censura:Create("UICorner", {
            CornerRadius = Censura.Config.Layout.CornerRadius.Round,
            Parent = fill
        })

        local knob = Censura:Create("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, -8, 0.5, -8),
            BackgroundColor3 = Censura.Config.Theme.Primary,
            Parent = fill
        })

        Censura:Create("UICorner", {
            CornerRadius = Censura.Config.Layout.CornerRadius.Round,
            Parent = knob
        })

        -- Add shadow to knob
        Censura:Create("ImageLabel", {
            Size = UDim2.new(1.5, 0, 1.5, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Image = "rbxassetid://7912134082",
            ImageColor3 = Color3.new(0, 0, 0),
            ImageTransparency = 0.6,
            Parent = knob
        })

        -- Slider functionality
        local min = options.min or 0
        local max = options.max or 100
        local defaultValue = math.clamp(options.default or min, min, max)
        local dragging = false

        local function updateValue(input)
            local pos = input.Position
            local abs = track.AbsolutePosition
            local size = track.AbsoluteSize
            
            local relative = math.clamp((pos.X - abs.X) / size.X, 0, 1)
            local value = math.floor(min + (max - min) * relative)
            
            fill.Size = UDim2.new(relative, 0, 1, 0)
            valueDisplay.Text = tostring(value)
            
            if options.callback then
                options.callback(value)
            end
            
            return value
        end

        -- Input handling
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateValue(input)
            end
        end)

        Services.UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateValue(input)
            end
        end)

        Services.UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        -- Initialize slider value
        local initialRelative = (defaultValue - min) / (max - min)
        fill.Size = UDim2.new(initialRelative, 0, 1, 0)
        valueDisplay.Text = tostring(defaultValue)

        return {
            Instance = container.Instance,
            SetValue = function(value)
                local relative = (value - min) / (max - min)
                fill.Size = UDim2.new(relative, 0, 1, 0)
                valueDisplay.Text = tostring(value)
            end,
            GetValue = function()
                return tonumber(valueDisplay.Text)
            end
        }
    end

    -- Dropdown Component
    local function CreateDropdown(options)
        local container = ComponentFactory.new("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Censura.Config.Theme.Secondary,
            Parent = options.parent
        })

        Censura:Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = container.Instance
        })

        local selected = Censura:Create("TextLabel", {
            Size = UDim2.new(1, -30, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = options.default or "Select...",
            TextColor3 = Censura.Config.Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Censura.Config.Fonts.Text,
            TextSize = Censura.Config.Fonts.Size.Text,
            Parent = container.Instance
        })

        local arrow = Censura:Create("ImageLabel", {
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(1, -20, 0.5, -6),
            BackgroundTransparency = 1,
            Image = "rbxassetid://6034818372",
            ImageColor3 = Censura.Config.Theme.TextDark,
            Parent = container.Instance
        })

        -- Dropdown list
        local listContainer = Censura:Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 1, 5),
            BackgroundColor3 = Censura.Config.Theme.Secondary,
            ClipsDescendants = true,
            Visible = false,
            Parent = container.Instance
        })

        Censura:Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = listContainer
        })

        local list = Censura:Create("ScrollingFrame", {
            Size = UDim2.new(1, -4, 1, -4),
            Position = UDim2.new(0, 2, 0, 2),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Censura.Config.Theme.Primary,
            Parent = listContainer
        })

        local layout = Censura:Create("UIListLayout", {
            Padding = UDim.new(0, 2),
            Parent = list
        })

        -- Dropdown state management
        local items = options.items or {}
        local expanded = false
        local selectedItem = options.default

        local function createItem(text)
            local item = Censura:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = Censura.Config.Theme.Secondary,
                Text = text,
                TextColor3 = Censura.Config.Theme.Text,
                Font = Censura.Config.Fonts.Text,
                TextSize = Censura.Config.Fonts.Size.Text,
                Parent = list
            })

            item.MouseButton1Click:Connect(function()
                selected.Text = text
                selectedItem = text
                
                Services.TweenService:Create(listContainer,
                    Censura.Config.Animation.Short,
                    {Size = UDim2.new(1, 0, 0, 0)}
                ):Play()
                
                expanded = false
                
                if options.callback then
                    options.callback(text)
                end
            end)

            return item
        end

        -- Populate initial items
        for _, item in ipairs(items) do
            createItem(item)
        end

        -- Toggle dropdown
        container.Instance.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                expanded = not expanded
                
                Services.TweenService:Create(arrow,
                    Censura.Config.Animation.Short,
                    {Rotation = expanded and 180 or 0}
                ):Play()
                
                listContainer.Visible = true
                Services.TweenService:Create(listContainer,
                    Censura.Config.Animation.Short,
                    {Size = UDim2.new(1, 0, expanded and #items * 32 + 4 or 0, 0)}
                ):Play()
            end
        end)

        return {
            Instance = container.Instance,
            SetValue = function(value)
                selected.Text = value
                selectedItem = value
            end,
            GetValue = function()
                return selectedItem
            end,
            AddItem = function(text)
                table.insert(items, text)
                createItem(text)
            end,
            RemoveItem = function(text)
                for i, item in ipairs(items) do
                    if item == text then
                        table.remove(items, i)
                        list:FindFirstChild(text):Destroy()
                        break
                    end
                end
            end
        }
    end

    -- Add all components to the return table
    return {
        Button = CreateButton,
        Toggle = CreateToggle,
        Slider = CreateSlider,
        Dropdown = CreateDropdown
        -- InputField will be added in the next part
    }
end

    -- InputField Component
    local function CreateInputField(options)
        local container = ComponentFactory.new("Frame", {
            Size = Censura.Config.Layout.DefaultSize.Input,
            BackgroundColor3 = Censura.Config.Theme.Secondary,
            Parent = options.parent
        })

        -- Add rounded corners
        Censura:Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = container.Instance
        })

        -- Create the input box
        local input = Censura:Create("TextBox", {
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = options.default or "",
            PlaceholderText = options.placeholder or "Enter text...",
            TextColor3 = Censura.Config.Theme.Text,
            PlaceholderColor3 = Censura.Config.Theme.TextDark,
            Font = Censura.Config.Fonts.Text,
            TextSize = Censura.Config.Fonts.Size.Text,
            ClearTextOnFocus = options.clearOnFocus ~= false,
            Parent = container.Instance
        })

        -- Add focus highlight effect
        local focusHighlight = Censura:Create("UIStroke", {
            Color = Censura.Config.Theme.Primary,
            Transparency = 1,
            Thickness = 1.5,
            Parent = container.Instance
        })

        -- Focus effects
        input.Focused:Connect(function()
            Services.TweenService:Create(focusHighlight,
                Censura.Config.Animation.Short,
                {Transparency = 0}
            ):Play()

            -- Optional focus callback
            if options.onFocus then
                options.onFocus()
            end
        end)

        input.FocusLost:Connect(function(enterPressed)
            Services.TweenService:Create(focusHighlight,
                Censura.Config.Animation.Short,
                {Transparency = 1}
            ):Play()

            if options.callback then
                options.callback(input.Text, enterPressed)
            end
        end)

        -- Character limit handling
        if options.maxLength then
            input:GetPropertyChangedSignal("Text"):Connect(function()
                if #input.Text > options.maxLength then
                    input.Text = input.Text:sub(1, options.maxLength)
                end
            end)
        end

        -- Input validation (if provided)
        if options.validate then
            input:GetPropertyChangedSignal("Text"):Connect(function()
                local valid = options.validate(input.Text)
                Services.TweenService:Create(container.Instance,
                    Censura.Config.Animation.Short,
                    {BackgroundColor3 = valid and 
                        Censura.Config.Theme.Secondary or 
                        Censura.Config.Theme.Error
                    }
                ):Play()
            end)
        end

        -- Return component interface
        return {
            Instance = container.Instance,
            SetValue = function(value)
                input.Text = tostring(value)
            end,
            GetValue = function()
                return input.Text
            end,
            Clear = function()
                input.Text = ""
            end,
            Focus = function()
                input:CaptureFocus()
            end,
            Blur = function()
                input:ReleaseFocus()
            end
        }
    end

    -- Final return table with all components
    return {
        Button = CreateButton,
        Toggle = CreateToggle,
        Slider = CreateSlider,
        Dropdown = CreateDropdown,
        InputField = CreateInputField
    }
end

return Components
