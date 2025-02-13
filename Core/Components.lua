--[[
    Censura/Core/Components.lua
    Author: LxckStxp
    Purpose: UI Component System for Censura Framework
    Version: 2.0.0
]]

local Components = {
    Active = {},
    Cache = {}
}

-- Services
local Services = {
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService")
}

-- Base Component Creation
local function CreateBaseComponent(options)
    return {
        Name = options.name or options.type .. "_" .. tostring(#Components.Active + 1),
        Type = options.type,
        Elements = {},
        Connections = {},
        Options = options
    }
end

-- Style System for Consistent UI Creation
local StyleSystem = {
    ApplyTheming = function(instance, styles)
        for property, value in pairs(styles) do
            instance[property] = value
        end
        return instance
    end,
    
    ApplyHoverEffect = function(instance, normalColor, hoverColor)
        local connections = {}
        
        table.insert(connections, instance.MouseEnter:Connect(function()
            Services.TweenService:Create(
                instance,
                Styles.Animations.Short,
                {BackgroundColor3 = hoverColor}
            ):Play()
        end))
        
        table.insert(connections, instance.MouseLeave:Connect(function()
            Services.TweenService:Create(
                instance,
                Styles.Animations.Short,
                {BackgroundColor3 = normalColor}
            ):Play()
        end))
        
        return connections
    end,
    
    CreateContainer = function(options)
        local frame = Instance.new(options.instanceType or "Frame")
        StyleSystem.ApplyTheming(frame, {
            Name = options.name,
            Size = options.size,
            Position = options.position,
            BackgroundTransparency = options.transparency or 0,
            BackgroundColor3 = options.backgroundColor,
            BorderSizePixel = 0,
            Parent = options.parent
        })
        
        if options.cornerRadius then
            Styles.Utils.CreateCorner(frame, options.cornerRadius)
        end
        
        return frame
    end,
    
    CreateLabel = function(options)
        local label = Instance.new("TextLabel")
        StyleSystem.ApplyTheming(label, {
            Name = options.name,
            Size = options.size,
            Position = options.position,
            BackgroundTransparency = 1,
            Text = options.text,
            TextColor3 = options.textColor or Styles.GetColor("Text"),
            Font = options.font or Styles.Fonts.Label.Font,
            TextSize = options.textSize or Styles.Fonts.Label.Size,
            TextXAlignment = options.alignment or Enum.TextXAlignment.Left,
            TextWrapped = options.wrap or false,
            Parent = options.parent
        })
        return label
    end
}

-- Component Registration
local function RegisterComponent(component)
    Components.Active[component.Name] = component
    return component
end

local function UnregisterComponent(name)
    Components.Active[name] = nil
end

-- Connection Management
local function CleanupConnections(connections)
    for _, connection in pairs(connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end
end

-- Container Component
local function CreateContainer(options)
    local component = CreateBaseComponent({
        type = "Container",
        name = options.name
    })
    
    component.Instance = StyleSystem.CreateContainer({
        instanceType = "ScrollingFrame",
        name = component.Name,
        size = UDim2.new(1, 0, 1, -Styles.Constants.HeaderHeight),
        position = UDim2.new(0, 0, 0, Styles.Constants.HeaderHeight),
        transparency = 1,
        parent = options.parent
    })
    
    StyleSystem.ApplyTheming(component.Instance, {
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Styles.GetColor("Primary")
    })
    
    -- Add Layout
    component.Layout = Instance.new("UIListLayout")
    component.Layout.Padding = Styles.Constants.ElementSpacing
    component.Layout.Parent = component.Instance
    
    -- Add Padding
    Styles.Utils.CreatePadding(component.Instance)
    
    -- Auto-size Canvas
    component.Connections.ContentSize = component.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        component.Instance.CanvasSize = UDim2.new(0, 0, 0, component.Layout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Element Creation Methods
    component.AddToggle = function(toggleOptions)
        toggleOptions.parent = component.Instance
        local toggle = Components.CreateToggle(toggleOptions)
        component.Elements[toggle.Name] = toggle
        return toggle
    end
    
    component.AddButton = function(buttonOptions)
        buttonOptions.parent = component.Instance
        local button = Components.CreateButton(buttonOptions)
        component.Elements[button.Name] = button
        return button
    end
    
    component.AddSlider = function(sliderOptions)
        sliderOptions.parent = component.Instance
        local slider = Components.CreateSlider(sliderOptions)
        component.Elements[slider.Name] = slider
        return slider
    end
    
    component.AddLabel = function(labelOptions)
        labelOptions.parent = component.Instance
        local label = Components.CreateLabel(labelOptions)
        component.Elements[label.Name] = label
        return label
    end
    
    -- Cleanup
    component.Destroy = function()
        CleanupConnections(component.Connections)
        for _, element in pairs(component.Elements) do
            if element.Destroy then
                element:Destroy()
            end
        end
        component.Instance:Destroy()
        UnregisterComponent(component.Name)
    end
    
    return RegisterComponent(component)
end

-- Button Component
local function CreateButton(options)
    local component = CreateBaseComponent({
        type = "Button",
        name = options.name
    })
    
    component.Elements.Button = StyleSystem.CreateContainer({
        instanceType = "TextButton",
        name = component.Name,
        size = UDim2.new(1, -20, 0, 32),
        position = UDim2.new(0, 10, 0, 0),
        backgroundColor = Styles.GetColor("Primary"),
        cornerRadius = Styles.Constants.ButtonCornerRadius,
        parent = options.parent
    })
    
    StyleSystem.ApplyTheming(component.Elements.Button, {
        Text = options.label or component.Name,
        TextColor3 = Styles.GetColor("Text"),
        Font = Styles.Fonts.Button.Font,
        TextSize = Styles.Fonts.Button.Size,
        AutoButtonColor = false
    })
    
    -- Effects
    component.Connections = StyleSystem.ApplyHoverEffect(
        component.Elements.Button,
        Styles.GetColor("Primary"),
        Styles.GetColor("PrimaryHover")
    )
    
    -- Click Handler
    table.insert(component.Connections, 
        component.Elements.Button.MouseButton1Click:Connect(function()
            if options.callback then
                options.callback()
            end
            
            Services.TweenService:Create(
                component.Elements.Button,
                Styles.Animations.Quick,
                {BackgroundColor3 = Styles.GetColor("PrimaryLight")}
            ):Play()
            
            task.delay(0.1, function()
                Services.TweenService:Create(
                    component.Elements.Button,
                    Styles.Animations.Short,
                    {BackgroundColor3 = Styles.GetColor("Primary")}
                ):Play()
            end)
        end)
    )
    
    component.Destroy = function()
        CleanupConnections(component.Connections)
        component.Elements.Button:Destroy()
        UnregisterComponent(component.Name)
    end
    
    return RegisterComponent(component)
end

-- Toggle Component
local function CreateToggle(options)
    local component = CreateBaseComponent({
        type = "Toggle",
        name = options.name
    })
    
    component.Value = options.default or false
    
    -- Create Container
    component.Elements.Container = StyleSystem.CreateContainer({
        name = component.Name,
        size = UDim2.new(1, 0, 0, Styles.Constants.ToggleHeight),
        transparency = 1,
        parent = options.parent
    })
    
    -- Create Label
    component.Elements.Label = StyleSystem.CreateLabel({
        name = "Label",
        size = UDim2.new(1, -Styles.Constants.ToggleWidth - 10, 1, 0),
        text = options.label or component.Name,
        parent = component.Elements.Container
    })
    
    -- Create Toggle Button
    component.Elements.Button = StyleSystem.CreateContainer({
        instanceType = "TextButton",
        name = "Button",
        size = UDim2.new(0, Styles.Constants.ToggleWidth, 0, 24),
        position = UDim2.new(1, -Styles.Constants.ToggleWidth, 0.5, -12),
        backgroundColor = component.Value and Styles.GetColor("Success") or Styles.GetColor("Error"),
        cornerRadius = Styles.Constants.ButtonCornerRadius,
        parent = component.Elements.Container
    })
    
    -- Create Toggle Circle
    component.Elements.Circle = StyleSystem.CreateContainer({
        name = "Circle",
        size = UDim2.new(0, 20, 0, 20),
        position = component.Value and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2),
        backgroundColor = Styles.GetColor("Highlight"),
        cornerRadius = Styles.Constants.CircleCornerRadius,
        parent = component.Elements.Button
    })
    
    -- Toggle Logic
    local animating = false
    local function SetValue(newValue, silent)
        if animating then return end
        animating = true
        component.Value = newValue
        
        -- Animate
        local circleTween = Services.TweenService:Create(
            component.Elements.Circle,
            Styles.Animations.Short,
            {Position = newValue and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2)}
        )
        
        local colorTween = Services.TweenService:Create(
            component.Elements.Button,
            Styles.Animations.Short,
            {BackgroundColor3 = newValue and Styles.GetColor("Success") or Styles.GetColor("Error")}
        )
        
        circleTween:Play()
        colorTween:Play()
        
        if not silent and options.callback then
            options.callback(newValue)
        end
        
        circleTween.Completed:Connect(function()
            animating = false
        end)
    end
    
    -- Connect Events
    table.insert(component.Connections,
        component.Elements.Button.MouseButton1Click:Connect(function()
            SetValue(not component.Value)
        end)
    )
    
    -- Add hover effect
    component.Connections = StyleSystem.ApplyHoverEffect(
        component.Elements.Button,
        component.Value and Styles.GetColor("Success") or Styles.GetColor("Error"),
        component.Value and Styles.GetColor("Success") or Styles.GetColor("Error")
    )
    
    -- Public Methods
    component.SetValue = SetValue
    component.GetValue = function()
        return component.Value
    end
    
    component.Destroy = function()
        CleanupConnections(component.Connections)
        component.Elements.Container:Destroy()
        UnregisterComponent(component.Name)
    end
    
    return RegisterComponent(component)
end

-- Slider Component
local function CreateSlider(options)
    local component = CreateBaseComponent({
        type = "Slider",
        name = options.name
    })
    
    component.Value = options.default or 0
    component.Min = options.min or 0
    component.Max = options.max or 100
    component.Dragging = false
    
    -- Create Container
    component.Elements.Container = StyleSystem.CreateContainer({
        name = component.Name,
        size = UDim2.new(1, 0, 0, Styles.Constants.SliderHeight),
        transparency = 1,
        parent = options.parent
    })
    
    -- Create Label
    component.Elements.Label = StyleSystem.CreateLabel({
        name = "Label",
        size = UDim2.new(1, -50, 0, 20),
        text = options.label or component.Name,
        parent = component.Elements.Container
    })
    
    -- Create Value Display
    component.Elements.Value = StyleSystem.CreateLabel({
        name = "Value",
        size = UDim2.new(0, 45, 0, 20),
        position = UDim2.new(1, -45, 0, 0),
        text = tostring(component.Value),
        font = Styles.Fonts.Value.Font,
        textSize = Styles.Fonts.Value.Size,
        parent = component.Elements.Container
    })
    
    -- Create Slider Background
    component.Elements.Background = StyleSystem.CreateContainer({
        name = "Background",
        size = UDim2.new(1, 0, 0, Styles.Constants.SliderThickness),
        position = UDim2.new(0, 0, 0, 30),
        backgroundColor = Styles.GetColor("LightAccent"),
        cornerRadius = UDim.new(0, 3),
        parent = component.Elements.Container
    })
    
    -- Create Fill Bar
    component.Elements.Fill = StyleSystem.CreateContainer({
        name = "Fill",
        size = UDim2.new((component.Value - component.Min) / (component.Max - component.Min), 0, 1, 0),
        backgroundColor = Styles.GetColor("Primary"),
        cornerRadius = UDim.new(0, 3),
        parent = component.Elements.Background
    })
    
    -- Create Drag Button
    component.Elements.Button = StyleSystem.CreateContainer({
        instanceType = "TextButton",
        name = "Button",
        size = UDim2.new(0, 12, 0, 12),
        position = UDim2.new((component.Value - component.Min) / (component.Max - component.Min), -6, 0.5, -6),
        backgroundColor = Styles.GetColor("Highlight"),
        cornerRadius = Styles.Constants.CircleCornerRadius,
        parent = component.Elements.Background
    })
    
    -- Slider Logic
    local function SetValue(newValue, silent)
        component.Value = math.clamp(newValue, component.Min, component.Max)
        local scale = (component.Value - component.Min) / (component.Max - component.Min)
        
        Services.TweenService:Create(
            component.Elements.Fill,
            Styles.Animations.Short,
            {Size = UDim2.new(scale, 0, 1, 0)}
        ):Play()
        
        Services.TweenService:Create(
            component.Elements.Button,
            Styles.Animations.Short,
            {Position = UDim2.new(scale, -6, 0.5, -6)}
        ):Play()
        
        component.Elements.Value.Text = tostring(math.round(component.Value))
        
        if not silent and options.callback then
            options.callback(component.Value)
        end
    end
    
    -- Handle Dragging
    table.insert(component.Connections,
        component.Elements.Button.MouseButton1Down:Connect(function()
            component.Dragging = true
        end)
    )
    
    table.insert(component.Connections,
        Services.UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                component.Dragging = false
            end
        end)
    )
    
    table.insert(component.Connections,
        Services.UserInputService.InputChanged:Connect(function(input)
            if component.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = Services.UserInputService:GetMouseLocation()
                local sliderPos = component.Elements.Background.AbsolutePosition
                local sliderSize = component.Elements.Background.AbsoluteSize
                
                local scale = math.clamp(
                    (mousePos.X - sliderPos.X) / sliderSize.X,
                    0,
                    1
                )
                
                local newValue = component.Min + (component.Max - component.Min) * scale
                SetValue(newValue)
            end
        end)
    )
    
    -- Hover Effects
    local hoverConnections = StyleSystem.ApplyHoverEffect(
        component.Elements.Button,
        Styles.GetColor("Highlight"),
        Styles.GetColor("Primary")
    )
    
    for _, connection in ipairs(hoverConnections) do
        table.insert(component.Connections, connection)
    end
    
    -- Public Methods
    component.SetValue = SetValue
    component.GetValue = function()
        return component.Value
    end
    
    component.Destroy = function()
        CleanupConnections(component.Connections)
        component.Elements.Container:Destroy()
        UnregisterComponent(component.Name)
    end
    
    return RegisterComponent(component)
end

-- Label Component
local function CreateLabel(options)
    local component = CreateBaseComponent({
        type = "Label",
        name = options.name
    })
    
    component.Elements.Label = StyleSystem.CreateLabel({
        name = component.Name,
        size = UDim2.new(1, -20, 0, 20),
        position = UDim2.new(0, 10, 0, 0),
        text = options.text or component.Name,
        alignment = options.alignment,
        wrap = options.wrap,
        parent = options.parent
    })
    
    -- Update Method
    component.SetText = function(text)
        component.Elements.Label.Text = text
    end
    
    component.Destroy = function()
        component.Elements.Label:Destroy()
        UnregisterComponent(component.Name)
    end
    
    return RegisterComponent(component)
end

-- Separator Component
local function CreateSeparator(options)
    local component = CreateBaseComponent({
        type = "Separator",
        name = options.name
    })
    
    component.Elements.Line = StyleSystem.CreateContainer({
        name = component.Name,
        size = UDim2.new(1, -20, 0, 1),
        position = UDim2.new(0, 10, 0, 0),
        backgroundColor = Styles.GetColor("Border"),
        parent = options.parent
    })
    
    component.Destroy = function()
        component.Elements.Line:Destroy()
        UnregisterComponent(component.Name)
    end
    
    return RegisterComponent(component)
end

-- Add Components to API
Components.Create = {
    Container = CreateContainer,
    Button = CreateButton,
    Toggle = CreateToggle,
    Slider = CreateSlider,
    Label = CreateLabel,
    Separator = CreateSeparator
}

return Components
    
