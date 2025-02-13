--[[
    Censura/Core/Components.lua
    Author: LxckStxp
    Purpose: UI Component System for Censura Framework
]]

-- Initialize Global State
if not _G.Censura then
    _G.Censura = {
        Modules = {},
        State = {},
        Cache = {},
        UI = {
            ActiveComponents = {},
            Windows = {}
        }
    }
end

-- Module Definition
local Components = {
    Active = {},
    Cache = {}
}

-- Register in Global Space
_G.Censura.Modules.Components = Components

-- Services
local Services = {
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService")
}

-- Get Styles Reference
local Styles = _G.Censura.Modules.Styles

-- Utility Functions
local function RegisterComponent(component)
    Components.Active[component.Name] = component
    return component
end

local function UnregisterComponent(name)
    Components.Active[name] = nil
end

local function CreateConnection(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(_G.Censura.System.Active.Connections, connection)
    return connection
end

local function CleanupConnections(connections)
    for _, connection in pairs(connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end
end

-- Container Component Implementation
local function CreateContainer(options)
    local container = {
        Name = options.name or "Container_" .. tostring(#Components.Active + 1),
        Instance = nil,
        Elements = {},
        Connections = {}
    }
    
    -- Create Main Frame
    container.Instance = Instance.new("ScrollingFrame")
    container.Instance.Name = container.Name
    container.Instance.BackgroundTransparency = 1
    container.Instance.Size = UDim2.new(1, 0, 1, -Styles.Constants.HeaderHeight)
    container.Instance.Position = UDim2.new(0, 0, 0, Styles.Constants.HeaderHeight)
    container.Instance.ScrollBarThickness = 2
    container.Instance.ScrollBarImageColor3 = Styles.GetColor("Primary")
    container.Instance.Parent = options.parent

    -- Add Layout System
    container.Layout = Instance.new("UIListLayout")
    container.Layout.Padding = Styles.Constants.ElementSpacing
    container.Layout.Parent = container.Instance

    -- Add Padding
    Styles.Utils.CreatePadding(container.Instance)

    -- Setup Auto-Sizing
    container.Connections.ContentSize = CreateConnection(
        container.Layout:GetPropertyChangedSignal("AbsoluteContentSize"),
        function()
            container.Instance.CanvasSize = UDim2.new(0, 0, 0, container.Layout.AbsoluteContentSize.Y + 20)
        end
    )

    -- Element Creation Methods
    container.AddToggle = function(toggleOptions)
        local toggle = Components.CreateToggle({
            name = toggleOptions.name,
            parent = container.Instance,
            label = toggleOptions.label,
            default = toggleOptions.default,
            callback = toggleOptions.callback
        })
        container.Elements[toggle.Name] = toggle
        return toggle
    end

    container.AddSlider = function(sliderOptions)
        local slider = Components.CreateSlider({
            name = sliderOptions.name,
            parent = container.Instance,
            label = sliderOptions.label,
            min = sliderOptions.min,
            max = sliderOptions.max,
            default = sliderOptions.default,
            callback = sliderOptions.callback
        })
        container.Elements[slider.Name] = slider
        return slider
    end

    container.AddButton = function(buttonOptions)
        local button = Components.CreateButton({
            name = buttonOptions.name,
            parent = container.Instance,
            label = buttonOptions.label,
            callback = buttonOptions.callback
        })
        container.Elements[button.Name] = button
        return button
    end

    container.AddLabel = function(labelOptions)
        local label = Components.CreateLabel({
            name = labelOptions.name,
            parent = container.Instance,
            text = labelOptions.text
        })
        container.Elements[label.Name] = label
        return label
    end

    -- Cleanup Method
    container.Destroy = function()
        -- Cleanup all elements
        for _, element in pairs(container.Elements) do
            if element.Destroy then
                element:Destroy()
            end
        end

        -- Cleanup connections
        CleanupConnections(container.Connections)

        -- Destroy instance
        if container.Instance then
            container.Instance:Destroy()
        end

        -- Unregister from active components
        UnregisterComponent(container.Name)
    end

    -- Register and return container
    return RegisterComponent(container)
end

-- Add to Components API
Components.CreateContainer = CreateContainer

-- Toggle Component Implementation
local function CreateToggle(options)
    local toggle = {
        Name = options.name or "Toggle_" .. tostring(#Components.Active + 1),
        Value = options.default or false,
        Elements = {},
        Connections = {},
        Callback = options.callback
    }
    
    -- Create Main Container
    toggle.Elements.Container = Instance.new("Frame")
    toggle.Elements.Container.Name = toggle.Name
    toggle.Elements.Container.BackgroundTransparency = 1
    toggle.Elements.Container.Size = UDim2.new(1, 0, 0, Styles.Constants.ToggleHeight)
    toggle.Elements.Container.Parent = options.parent

    -- Create Toggle Button
    toggle.Elements.Button = Instance.new("TextButton")
    toggle.Elements.Button.Name = "Button"
    toggle.Elements.Button.Position = UDim2.new(1, -Styles.Constants.ToggleWidth, 0.5, -12)
    toggle.Elements.Button.Size = UDim2.new(0, Styles.Constants.ToggleWidth, 0, 24)
    toggle.Elements.Button.BackgroundColor3 = toggle.Value and 
        Styles.GetColor("Success") or 
        Styles.GetColor("Error")
    toggle.Elements.Button.BorderSizePixel = 0
    toggle.Elements.Button.Text = ""
    toggle.Elements.Button.AutoButtonColor = false
    toggle.Elements.Button.Parent = toggle.Elements.Container

    -- Create Toggle Circle
    toggle.Elements.Circle = Instance.new("Frame")
    toggle.Elements.Circle.Size = UDim2.new(0, 20, 0, 20)
    toggle.Elements.Circle.Position = toggle.Value and 
        UDim2.new(1, -22, 0, 2) or 
        UDim2.new(0, 2, 0, 2)
    toggle.Elements.Circle.BackgroundColor3 = Styles.GetColor("Highlight")
    toggle.Elements.Circle.BorderSizePixel = 0
    toggle.Elements.Circle.Parent = toggle.Elements.Button

    -- Create Label
    toggle.Elements.Label = Instance.new("TextLabel")
    toggle.Elements.Label.BackgroundTransparency = 1
    toggle.Elements.Label.Position = UDim2.new(0, 0, 0, 0)
    toggle.Elements.Label.Size = UDim2.new(1, -Styles.Constants.ToggleWidth - 10, 1, 0)
    toggle.Elements.Label.Font = Styles.Fonts.Label.Font
    toggle.Elements.Label.Text = options.label or toggle.Name
    toggle.Elements.Label.TextColor3 = Styles.GetColor("Text")
    toggle.Elements.Label.TextSize = Styles.Fonts.Label.Size
    toggle.Elements.Label.TextXAlignment = Enum.TextXAlignment.Left
    toggle.Elements.Label.Parent = toggle.Elements.Container

    -- Add Corners
    Styles.Utils.CreateCorner(toggle.Elements.Button, Styles.Constants.ButtonCornerRadius)
    Styles.Utils.CreateCorner(toggle.Elements.Circle, Styles.Constants.CircleCornerRadius)

    -- Animation State
    local animating = false

    -- Toggle Value Function
    local function SetValue(newValue, silent)
        if animating then return end
        animating = true
        toggle.Value = newValue

        -- Create Animations
        local circleTween = Services.TweenService:Create(
            toggle.Elements.Circle,
            Styles.Animations.Short,
            {Position = newValue and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2)}
        )

        local colorTween = Services.TweenService:Create(
            toggle.Elements.Button,
            Styles.Animations.Short,
            {BackgroundColor3 = newValue and Styles.GetColor("Success") or Styles.GetColor("Error")}
        )

        -- Play Animations
        circleTween:Play()
        colorTween:Play()

        -- Handle Callback
        if not silent and toggle.Callback then
            toggle.Callback(newValue)
        end

        -- Reset Animation State
        circleTween.Completed:Connect(function()
            animating = false
        end)
    end

    -- Connect Events
    toggle.Connections.Click = CreateConnection(
        toggle.Elements.Button.MouseButton1Click,
        function()
            SetValue(not toggle.Value)
        end
    )

    -- Hover Effects
    toggle.Connections.MouseEnter = CreateConnection(
        toggle.Elements.Button.MouseEnter,
        function()
            Services.TweenService:Create(
                toggle.Elements.Button,
                Styles.Animations.Short,
                {BackgroundTransparency = 0.2}
            ):Play()
        end
    )

    toggle.Connections.MouseLeave = CreateConnection(
        toggle.Elements.Button.MouseLeave,
        function()
            Services.TweenService:Create(
                toggle.Elements.Button,
                Styles.Animations.Short,
                {BackgroundTransparency = 0}
            ):Play()
        end
    )

    -- Public Methods
    toggle.SetValue = SetValue
    toggle.GetValue = function()
        return toggle.Value
    end

    toggle.Destroy = function()
        CleanupConnections(toggle.Connections)
        toggle.Elements.Container:Destroy()
        UnregisterComponent(toggle.Name)
    end

    return RegisterComponent(toggle)
end

-- Add to Components API
Components.CreateToggle = CreateToggle

-- Slider Component Implementation
local function CreateSlider(options)
    local slider = {
        Name = options.name or "Slider_" .. tostring(#Components.Active + 1),
        Value = options.default or 0,
        Min = options.min or 0,
        Max = options.max or 100,
        Elements = {},
        Connections = {},
        Callback = options.callback,
        Dragging = false
    }
    
    -- Create Main Container
    slider.Elements.Container = Instance.new("Frame")
    slider.Elements.Container.Name = slider.Name
    slider.Elements.Container.BackgroundTransparency = 1
    slider.Elements.Container.Size = UDim2.new(1, 0, 0, Styles.Constants.SliderHeight)
    slider.Elements.Container.Parent = options.parent

    -- Create Label
    slider.Elements.Label = Instance.new("TextLabel")
    slider.Elements.Label.BackgroundTransparency = 1
    slider.Elements.Label.Size = UDim2.new(1, -50, 0, 20)
    slider.Elements.Label.Font = Styles.Fonts.Label.Font
    slider.Elements.Label.Text = options.label or slider.Name
    slider.Elements.Label.TextColor3 = Styles.GetColor("Text")
    slider.Elements.Label.TextSize = Styles.Fonts.Label.Size
    slider.Elements.Label.TextXAlignment = Enum.TextXAlignment.Left
    slider.Elements.Label.Parent = slider.Elements.Container

    -- Create Value Display
    slider.Elements.Value = Instance.new("TextLabel")
    slider.Elements.Value.BackgroundTransparency = 1
    slider.Elements.Value.Position = UDim2.new(1, -45, 0, 0)
    slider.Elements.Value.Size = UDim2.new(0, 45, 0, 20)
    slider.Elements.Value.Font = Styles.Fonts.Value.Font
    slider.Elements.Value.Text = tostring(slider.Value)
    slider.Elements.Value.TextColor3 = Styles.GetColor("Text")
    slider.Elements.Value.TextSize = Styles.Fonts.Value.Size
    slider.Elements.Value.Parent = slider.Elements.Container

    -- Create Slider Background
    slider.Elements.Background = Instance.new("Frame")
    slider.Elements.Background.BackgroundColor3 = Styles.GetColor("LightAccent")
    slider.Elements.Background.BorderSizePixel = 0
    slider.Elements.Background.Position = UDim2.new(0, 0, 0, 30)
    slider.Elements.Background.Size = UDim2.new(1, 0, 0, Styles.Constants.SliderThickness)
    slider.Elements.Background.Parent = slider.Elements.Container

    -- Create Fill Bar
    slider.Elements.Fill = Instance.new("Frame")
    slider.Elements.Fill.BackgroundColor3 = Styles.GetColor("Primary")
    slider.Elements.Fill.BorderSizePixel = 0
    slider.Elements.Fill.Size = UDim2.new(
        (slider.Value - slider.Min) / (slider.Max - slider.Min),
        0,
        1,
        0
    )
    slider.Elements.Fill.Parent = slider.Elements.Background

    -- Create Drag Button
    slider.Elements.Button = Instance.new("TextButton")
    slider.Elements.Button.BackgroundColor3 = Styles.GetColor("Highlight")
    slider.Elements.Button.Position = UDim2.new(
        (slider.Value - slider.Min) / (slider.Max - slider.Min),
        -6,
        0.5,
        -6
    )
    slider.Elements.Button.Size = UDim2.new(0, 12, 0, 12)
    slider.Elements.Button.Text = ""
    slider.Elements.Button.Parent = slider.Elements.Background

    -- Add Corners
    Styles.Utils.CreateCorner(slider.Elements.Background, UDim.new(0, 3))
    Styles.Utils.CreateCorner(slider.Elements.Fill, UDim.new(0, 3))
    Styles.Utils.CreateCorner(slider.Elements.Button, Styles.Constants.CircleCornerRadius)

    -- Value Update Function
    local function SetValue(newValue, silent)
        slider.Value = math.clamp(newValue, slider.Min, slider.Max)
        local scale = (slider.Value - slider.Min) / (slider.Max - slider.Min)

        -- Update UI
        Services.TweenService:Create(
            slider.Elements.Fill,
            Styles.Animations.Short,
            {Size = UDim2.new(scale, 0, 1, 0)}
        ):Play()

        Services.TweenService:Create(
            slider.Elements.Button,
            Styles.Animations.Short,
            {Position = UDim2.new(scale, -6, 0.5, -6)}
        ):Play()

        slider.Elements.Value.Text = tostring(math.round(slider.Value))

        if not silent and slider.Callback then
            slider.Callback(slider.Value)
        end
    end

    -- Handle Dragging
    slider.Connections.ButtonDown = CreateConnection(
        slider.Elements.Button.MouseButton1Down,
        function()
            slider.Dragging = true
        end
    )

    slider.Connections.InputEnded = CreateConnection(
        Services.UserInputService.InputEnded,
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                slider.Dragging = false
            end
        end
    )

    slider.Connections.InputChanged = CreateConnection(
        Services.UserInputService.InputChanged,
        function(input)
            if slider.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = Services.UserInputService:GetMouseLocation()
                local sliderPos = slider.Elements.Background.AbsolutePosition
                local sliderSize = slider.Elements.Background.AbsoluteSize
                
                local scale = math.clamp(
                    (mousePos.X - sliderPos.X) / sliderSize.X,
                    0,
                    1
                )
                
                local newValue = slider.Min + (slider.Max - slider.Min) * scale
                SetValue(newValue)
            end
        end
    )

    -- Hover Effects
    slider.Connections.MouseEnter = CreateConnection(
        slider.Elements.Button.MouseEnter,
        function()
            Services.TweenService:Create(
                slider.Elements.Button,
                Styles.Animations.Short,
                {Size = UDim2.new(0, 14, 0, 14)}
            ):Play()
        end
    )

    slider.Connections.MouseLeave = CreateConnection(
        slider.Elements.Button.MouseLeave,
        function()
            Services.TweenService:Create(
                slider.Elements.Button,
                Styles.Animations.Short,
                {Size = UDim2.new(0, 12, 0, 12)}
            ):Play()
        end
    )

    -- Public Methods
    slider.SetValue = SetValue
    slider.GetValue = function()
        return slider.Value
    end

    slider.Destroy = function()
        CleanupConnections(slider.Connections)
        slider.Elements.Container:Destroy()
        UnregisterComponent(slider.Name)
    end

    return RegisterComponent(slider)
end

-- Add to Components API
Components.CreateSlider = CreateSlider

-- Utility Components Implementation

-- Button Component
local function CreateButton(options)
    local button = {
        Name = options.name or "Button_" .. tostring(#Components.Active + 1),
        Elements = {},
        Connections = {},
        Callback = options.callback
    }
    
    -- Create Button Instance
    button.Elements.Button = Instance.new("TextButton")
    button.Elements.Button.Name = button.Name
    button.Elements.Button.Size = UDim2.new(1, -20, 0, 32)
    button.Elements.Button.Position = UDim2.new(0, 10, 0, 0)
    button.Elements.Button.BackgroundColor3 = Styles.GetColor("Primary")
    button.Elements.Button.BorderSizePixel = 0
    button.Elements.Button.Text = options.label or button.Name
    button.Elements.Button.TextColor3 = Styles.GetColor("Text")
    button.Elements.Button.Font = Styles.Fonts.Button.Font
    button.Elements.Button.TextSize = Styles.Fonts.Button.Size
    button.Elements.Button.AutoButtonColor = false
    button.Elements.Button.Parent = options.parent

    -- Add Corner
    Styles.Utils.CreateCorner(button.Elements.Button, Styles.Constants.ButtonCornerRadius)

    -- Click Effect
    button.Connections.Click = CreateConnection(
        button.Elements.Button.MouseButton1Click,
        function()
            -- Visual feedback
            Services.TweenService:Create(
                button.Elements.Button,
                Styles.Animations.Quick,
                {BackgroundColor3 = Styles.GetColor("PrimaryLight")}
            ):Play()
            
            task.delay(0.1, function()
                Services.TweenService:Create(
                    button.Elements.Button,
                    Styles.Animations.Short,
                    {BackgroundColor3 = Styles.GetColor("Primary")}
                ):Play()
            end)

            -- Execute callback
            if button.Callback then
                button.Callback()
            end
        end
    )

    -- Hover Effects
    button.Connections.MouseEnter = CreateConnection(
        button.Elements.Button.MouseEnter,
        function()
            Services.TweenService:Create(
                button.Elements.Button,
                Styles.Animations.Short,
                {BackgroundColor3 = Styles.GetColor("PrimaryHover")}
            ):Play()
        end
    )

    button.Connections.MouseLeave = CreateConnection(
        button.Elements.Button.MouseLeave,
        function()
            Services.TweenService:Create(
                button.Elements.Button,
                Styles.Animations.Short,
                {BackgroundColor3 = Styles.GetColor("Primary")}
            ):Play()
        end
    )

    -- Cleanup Method
    button.Destroy = function()
        CleanupConnections(button.Connections)
        button.Elements.Button:Destroy()
        UnregisterComponent(button.Name)
    end

    return RegisterComponent(button)
end

-- Label Component
local function CreateLabel(options)
    local label = {
        Name = options.name or "Label_" .. tostring(#Components.Active + 1),
        Elements = {},
        Text = options.text or ""
    }
    
    -- Create Label Instance
    label.Elements.Label = Instance.new("TextLabel")
    label.Elements.Label.Name = label.Name
    label.Elements.Label.Size = UDim2.new(1, -20, 0, 20)
    label.Elements.Label.Position = UDim2.new(0, 10, 0, 0)
    label.Elements.Label.BackgroundTransparency = 1
    label.Elements.Label.Text = label.Text
    label.Elements.Label.TextColor3 = Styles.GetColor("Text")
    label.Elements.Label.Font = Styles.Fonts.Label.Font
    label.Elements.Label.TextSize = Styles.Fonts.Label.Size
    label.Elements.Label.TextXAlignment = options.alignment or Enum.TextXAlignment.Left
    label.Elements.Label.TextWrapped = options.wrap or false
    label.Elements.Label.Parent = options.parent

    -- Update Method
    label.SetText = function(text)
        label.Text = text
        label.Elements.Label.Text = text
    end

    -- Cleanup Method
    label.Destroy = function()
        label.Elements.Label:Destroy()
        UnregisterComponent(label.Name)
    end

    return RegisterComponent(label)
end

-- Separator Component
local function CreateSeparator(options)
    local separator = {
        Name = options.name or "Separator_" .. tostring(#Components.Active + 1),
        Elements = {}
    }
    
    -- Create Line
    separator.Elements.Line = Instance.new("Frame")
    separator.Elements.Line.Name = separator.Name
    separator.Elements.Line.Size = UDim2.new(1, -20, 0, 1)
    separator.Elements.Line.Position = UDim2.new(0, 10, 0, 0)
    separator.Elements.Line.BackgroundColor3 = Styles.GetColor("Border")
    separator.Elements.Line.BorderSizePixel = 0
    separator.Elements.Line.Parent = options.parent

    -- Cleanup Method
    separator.Destroy = function()
        separator.Elements.Line:Destroy()
        UnregisterComponent(separator.Name)
    end

    return RegisterComponent(separator)
end

-- Add Components to API
Components.CreateButton = CreateButton
Components.CreateLabel = CreateLabel
Components.CreateSeparator = CreateSeparator

return Components
