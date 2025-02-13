--[[
    Censura/Core/Components.lua
    Author: LxckStxp
    Purpose: Simplified UI Component System
    Version: 2.0.0
]]

local Components = {
    Active = {}
}

Styles = _G.Censura.System.Styles

-- Services
local Services = {
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService")
}

-- Utility Functions
local function RegisterComponent(component)
    Components.Active[component.Name] = component
    return component
end

local function UnregisterComponent(name)
    Components.Active[name] = nil
end

-- Container Component
local function CreateContainer(options)
    local container = {
        Name = options.name or "Container_" .. #Components.Active,
        Elements = {},
        Connections = {}
    }
    
    -- Create ScrollingFrame
    container.Instance = Instance.new("ScrollingFrame")
    container.Instance.Name = container.Name
    container.Instance.BackgroundTransparency = 1
    container.Instance.Size = UDim2.new(1, 0, 1, -40) -- Accounting for header
    container.Instance.Position = UDim2.new(0, 0, 0, 40)
    container.Instance.ScrollBarThickness = 2
    container.Instance.ScrollBarImageColor3 = Styles.GetColor("Primary")
    container.Instance.Parent = options.parent
    
    -- Add Layout
    container.Layout = Instance.new("UIListLayout")
    container.Layout.Padding = UDim.new(0, 5)
    container.Layout.Parent = container.Instance
    
    -- Add Padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 10)
    padding.Parent = container.Instance
    
    -- Auto-size content
    container.Connections.ContentSize = container.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.Instance.CanvasSize = UDim2.new(0, 0, 0, container.Layout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Element Creation Methods
    container.AddToggle = function(opts)
        local toggle = Components.CreateToggle({
            parent = container.Instance,
            name = opts.name,
            label = opts.label,
            default = opts.default,
            callback = opts.callback
        })
        container.Elements[toggle.Name] = toggle
        return toggle
    end
    
    container.AddSlider = function(opts)
        local slider = Components.CreateSlider({
            parent = container.Instance,
            name = opts.name,
            label = opts.label,
            min = opts.min,
            max = opts.max,
            default = opts.default,
            callback = opts.callback
        })
        container.Elements[slider.Name] = slider
        return slider
    end
    
    container.AddButton = function(opts)
        local button = Components.CreateButton({
            parent = container.Instance,
            name = opts.name,
            label = opts.label,
            callback = opts.callback
        })
        container.Elements[button.Name] = button
        return button
    end
    
    container.AddLabel = function(opts)
        local label = Components.CreateLabel({
            parent = container.Instance,
            text = opts.text
        })
        container.Elements[label.Name] = label
        return label
    end
    
    -- Cleanup
    container.Destroy = function()
        for _, element in pairs(container.Elements) do
            if element.Destroy then element:Destroy() end
        end
        for _, connection in pairs(container.Connections) do
            connection:Disconnect()
        end
        container.Instance:Destroy()
        UnregisterComponent(container.Name)
    end
    
    return RegisterComponent(container)
end

-- Toggle Component
local function CreateToggle(options)
    local toggle = {
        Name = options.name or "Toggle_" .. #Components.Active,
        Value = options.default or false,
        Elements = {}
    }
    
    -- Create container
    toggle.Elements.Container = Instance.new("Frame")
    toggle.Elements.Container.Name = toggle.Name
    toggle.Elements.Container.Size = UDim2.new(1, 0, 0, 30)
    toggle.Elements.Container.BackgroundTransparency = 1
    toggle.Elements.Container.Parent = options.parent
    
    -- Create label
    toggle.Elements.Label = Instance.new("TextLabel")
    toggle.Elements.Label.BackgroundTransparency = 1
    toggle.Elements.Label.Size = UDim2.new(1, -50, 1, 0)
    toggle.Elements.Label.Text = options.label or toggle.Name
    toggle.Elements.Label.TextColor3 = Styles.GetColor("Text")
    toggle.Elements.Label.TextXAlignment = Enum.TextXAlignment.Left
    toggle.Elements.Label.Font = Styles.Fonts.Label.Font
    toggle.Elements.Label.TextSize = Styles.Fonts.Label.Size
    toggle.Elements.Label.Parent = toggle.Elements.Container
    
    -- Create button
    toggle.Elements.Button = Instance.new("TextButton")
    toggle.Elements.Button.Size = UDim2.new(0, 40, 0, 20)
    toggle.Elements.Button.Position = UDim2.new(1, -40, 0.5, -10)
    toggle.Elements.Button.BackgroundColor3 = toggle.Value and Styles.GetColor("Success") or Styles.GetColor("Error")
    toggle.Elements.Button.Text = ""
    toggle.Elements.Button.Parent = toggle.Elements.Container
    
    -- Add corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = toggle.Elements.Button
    
    -- Create circle
    toggle.Elements.Circle = Instance.new("Frame")
    toggle.Elements.Circle.Size = UDim2.new(0, 16, 0, 16)
    toggle.Elements.Circle.Position = toggle.Value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    toggle.Elements.Circle.BackgroundColor3 = Styles.GetColor("Highlight")
    toggle.Elements.Circle.Parent = toggle.Elements.Button
    
    -- Add circle corner
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = toggle.Elements.Circle
    
    -- Handle clicking
    toggle.Elements.Button.MouseButton1Click:Connect(function()
        toggle.Value = not toggle.Value
        
        -- Animate
        Services.TweenService:Create(toggle.Elements.Button, 
            Styles.Animations.Short,
            {BackgroundColor3 = toggle.Value and Styles.GetColor("Success") or Styles.GetColor("Error")}
        ):Play()
        
        Services.TweenService:Create(toggle.Elements.Circle,
            Styles.Animations.Short,
            {Position = toggle.Value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}
        ):Play()
        
        if options.callback then
            options.callback(toggle.Value)
        end
    end)
    
    -- Methods
    toggle.SetValue = function(value)
        toggle.Value = value
        toggle.Elements.Button.BackgroundColor3 = value and Styles.GetColor("Success") or Styles.GetColor("Error")
        toggle.Elements.Circle.Position = value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    end
    
    toggle.Destroy = function()
        toggle.Elements.Container:Destroy()
        UnregisterComponent(toggle.Name)
    end
    
    return RegisterComponent(toggle)
end

-- Slider Component
local function CreateSlider(options)
    local slider = {
        Name = options.name or "Slider_" .. #Components.Active,
        Value = options.default or 0,
        Min = options.min or 0,
        Max = options.max or 100,
        Elements = {},
        Dragging = false
    }
    
    -- Create container
    slider.Elements.Container = Instance.new("Frame")
    slider.Elements.Container.Name = slider.Name
    slider.Elements.Container.Size = UDim2.new(1, 0, 0, 45)
    slider.Elements.Container.BackgroundTransparency = 1
    slider.Elements.Container.Parent = options.parent
    
    -- Create label and value
    slider.Elements.Label = Instance.new("TextLabel")
    slider.Elements.Label.BackgroundTransparency = 1
    slider.Elements.Label.Size = UDim2.new(1, -50, 0, 20)
    slider.Elements.Label.Text = options.label or slider.Name
    slider.Elements.Label.TextColor3 = Styles.GetColor("Text")
    slider.Elements.Label.TextXAlignment = Enum.TextXAlignment.Left
    slider.Elements.Label.Font = Styles.Fonts.Label.Font
    slider.Elements.Label.TextSize = Styles.Fonts.Label.Size
    slider.Elements.Label.Parent = slider.Elements.Container
    
    slider.Elements.Value = Instance.new("TextLabel")
    slider.Elements.Value.BackgroundTransparency = 1
    slider.Elements.Value.Position = UDim2.new(1, -45, 0, 0)
    slider.Elements.Value.Size = UDim2.new(0, 45, 0, 20)
    slider.Elements.Value.Text = tostring(slider.Value)
    slider.Elements.Value.TextColor3 = Styles.GetColor("Text")
    slider.Elements.Value.Font = Styles.Fonts.Label.Font
    slider.Elements.Value.TextSize = Styles.Fonts.Label.Size
    slider.Elements.Value.Parent = slider.Elements.Container
    
    -- Create slider
    slider.Elements.SliderBG = Instance.new("Frame")
    slider.Elements.SliderBG.Position = UDim2.new(0, 0, 0, 25)
    slider.Elements.SliderBG.Size = UDim2.new(1, 0, 0, 4)
    slider.Elements.SliderBG.BackgroundColor3 = Styles.GetColor("Border")
    slider.Elements.SliderBG.Parent = slider.Elements.Container
    
    slider.Elements.Fill = Instance.new("Frame")
    slider.Elements.Fill.Size = UDim2.new((slider.Value - slider.Min)/(slider.Max - slider.Min), 0, 1, 0)
    slider.Elements.Fill.BackgroundColor3 = Styles.GetColor("Primary")
    slider.Elements.Fill.Parent = slider.Elements.SliderBG
    
    -- Add corners
    Instance.new("UICorner", slider.Elements.SliderBG).CornerRadius = UDim.new(1, 0)
    Instance.new("UICorner", slider.Elements.Fill).CornerRadius = UDim.new(1, 0)
    
    -- Handle dragging
    local function updateValue(input)
        local pos = input.Position.X
        local sliderPos = slider.Elements.SliderBG.AbsolutePosition.X
        local sliderSize = slider.Elements.SliderBG.AbsoluteSize.X
        
        local relative = math.clamp((pos - sliderPos) / sliderSize, 0, 1)
        local value = slider.Min + (slider.Max - slider.Min) * relative
        
        slider.Value = value
        slider.Elements.Value.Text = tostring(math.floor(value))
        slider.Elements.Fill.Size = UDim2.new(relative, 0, 1, 0)
        
        if options.callback then
            options.callback(value)
        end
    end
    
    slider.Elements.SliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            slider.Dragging = true
            updateValue(input)
        end
    end)
    
    Services.UserInputService.InputChanged:Connect(function(input)
        if slider.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateValue(input)
        end
    end)
    
    Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            slider.Dragging = false
        end
    end)
    
    -- Methods
    slider.SetValue = function(value)
        value = math.clamp(value, slider.Min, slider.Max)
        local relative = (value - slider.Min)/(slider.Max - slider.Min)
        slider.Value = value
        slider.Elements.Value.Text = tostring(math.floor(value))
        slider.Elements.Fill.Size = UDim2.new(relative, 0, 1, 0)
    end
    
    slider.Destroy = function()
        slider.Elements.Container:Destroy()
        UnregisterComponent(slider.Name)
    end
    
    return RegisterComponent(slider)
end

-- Button Component
local function CreateButton(options)
    local button = {
        Name = options.name or "Button_" .. #Components.Active,
        Elements = {}
    }
    
    button.Elements.Button = Instance.new("TextButton")
    button.Elements.Button.Name = button.Name
    button.Elements.Button.Size = UDim2.new(1, 0, 0, 32)
    button.Elements.Button.BackgroundColor3 = Styles.GetColor("Primary")
    button.Elements.Button.Text = options.label or button.Name
    button.Elements.Button.TextColor3 = Styles.GetColor("Text")
    button.Elements.Button.Font = Styles.Fonts.Button.Font
    button.Elements.Button.TextSize = Styles.Fonts.Button.Size
    button.Elements.Button.Parent = options.parent
    
    Instance.new("UICorner", button.Elements.Button).CornerRadius = UDim.new(0, 6)
    
    -- Click effect
    button.Elements.Button.MouseButton1Click:Connect(function()
        Services.TweenService:Create(button.Elements.Button,
            Styles.Animations.Short,
            {BackgroundColor3 = Styles.GetColor("PrimaryLight")}
        ):Play()
        
        if options.callback then
            options.callback()
        end
        
        task.wait(0.2)
        Services.TweenService:Create(button.Elements.Button,
            Styles.Animations.Short,
            {BackgroundColor3 = Styles.GetColor("Primary")}
        ):Play()
    end)
    
    button.Destroy = function()
        button.Elements.Button:Destroy()
        UnregisterComponent(button.Name)
    end
    
    return RegisterComponent(button)
end

-- Label Component
local function CreateLabel(options)
    local label = {
        Name = options.name or "Label_" .. #Components.Active,
        Elements = {}
    }
    
    label.Elements.Label = Instance.new("TextLabel")
    label.Elements.Label.Name = label.Name
    label.Elements.Label.Size = UDim2.new(1, 0, 0, 25)
    label.Elements.Label.BackgroundTransparency = 1
    label.Elements.Label.Text = options.text or ""
    label.Elements.Label.TextColor3 = Styles.GetColor("Text")
    label.Elements.Label.TextXAlignment = Enum.TextXAlignment.Left
    label.Elements.Label.Font = Styles.Fonts.Label.Font
    label.Elements.Label.TextSize = Styles.Fonts.Label.Size
    label.Elements.Label.Parent = options.parent
    
    -- Methods
    label.SetText = function(text)
        label.Elements.Label.Text = text
    end
    
    label.Destroy = function()
        label.Elements.Label:Destroy()
        UnregisterComponent(label.Name)
    end
    
    return RegisterComponent(label)
end

-- Add components to API
Components.Create = {
    Container = CreateContainer,
    Toggle = CreateToggle,
    Slider = CreateSlider,
    Button = CreateButton,
    Label = CreateLabel
}

return Components
