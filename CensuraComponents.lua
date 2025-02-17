local Components = {}

function Components.createButton(parent, text, callback, COLORS, UI_SETTINGS, TweenService)
    local button = Instance.new("TextButton")
    button.Size = UI_SETTINGS.BUTTON_SIZE
    button.BackgroundColor3 = COLORS.ACCENT
    button.BackgroundTransparency = UI_SETTINGS.TRANSPARENCY.ELEMENTS
    button.Text = text
    button.TextColor3 = COLORS.TEXT
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UI_SETTINGS.CORNER_RADIUS
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.HIGHLIGHT
    stroke.Transparency = 0.8
    stroke.Thickness = 1
    stroke.Parent = button
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = COLORS.HIGHLIGHT
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = COLORS.ACCENT
        }):Play()
    end)
    
    button.MouseButton1Click:Connect(callback)
    return button
end

function Components.createToggle(parent, text, default, callback, COLORS, UI_SETTINGS, TweenService)
    local container = Instance.new("Frame")
    container.Size = UI_SETTINGS.BUTTON_SIZE
    container.BackgroundColor3 = COLORS.ACCENT
    container.BackgroundTransparency = UI_SETTINGS.TRANSPARENCY.ELEMENTS
    container.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UI_SETTINGS.CORNER_RADIUS
    corner.Parent = container
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.HIGHLIGHT
    stroke.Transparency = 0.8
    stroke.Thickness = 1
    stroke.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, -44, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = COLORS.TEXT
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14
    label.Parent = container
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UI_SETTINGS.TOGGLE_SIZE
    toggle.Position = UDim2.new(1, -34, 0.5, -12)
    toggle.BackgroundColor3 = default and COLORS.ENABLED or COLORS.DISABLED
    toggle.Text = ""
    toggle.Parent = container
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggle
    
    local enabled = default or false
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        TweenService:Create(toggle, TweenInfo.new(0.2), {
            BackgroundColor3 = enabled and COLORS.ENABLED or COLORS.DISABLED
        }):Play()
        callback(enabled)
    end)
    
    return container
end

function Components.createSlider(parent, text, min, max, default, callback, COLORS, UI_SETTINGS, TweenService, UserInputService, RunService)
    local container = Instance.new("Frame")
    container.Size = UI_SETTINGS.SLIDER_SIZE
    container.BackgroundColor3 = COLORS.ACCENT
    container.BackgroundTransparency = UI_SETTINGS.TRANSPARENCY.ELEMENTS
    container.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UI_SETTINGS.CORNER_RADIUS
    corner.Parent = container
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.HIGHLIGHT
    stroke.Transparency = 0.8
    stroke.Thickness = 1
    stroke.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = COLORS.TEXT
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14
    label.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Text = tostring(default)
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -60, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = COLORS.TEXT
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Font = Enum.Font.GothamSemibold
    valueLabel.TextSize = 14
    valueLabel.Parent = container
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -20, 0, 4)
    sliderBar.Position = UDim2.new(0, 10, 0.7, 0)
    sliderBar.BackgroundColor3 = COLORS.BACKGROUND
    sliderBar.Parent = container
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 2)
    sliderCorner.Parent = sliderBar
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = COLORS.ENABLED
    sliderFill.Parent = sliderBar
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = sliderFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 16, 0, 16)
    sliderButton.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    sliderButton.BackgroundColor3 = COLORS.ENABLED
    sliderButton.Text = ""
    sliderButton.Parent = sliderBar
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = sliderButton
    
    local dragging = false
    local value = default
    
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mouse = UserInputService:GetMouseLocation()
            local pos = (mouse.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
            pos = math.clamp(pos, 0, 1)
            value = min + ((max - min) * pos)
            
            sliderButton.Position = UDim2.new(pos, -8, 0.5, -8)
            sliderFill.Size = UDim2.new(pos, 0, 1, 0)
            valueLabel.Text = tostring(math.floor(value))
            callback(math.floor(value))
        end
    end)
    
    return container
end

function Components.makeDraggable(titleBar, mainFrame)
    local dragging, dragInput, dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

return Components
