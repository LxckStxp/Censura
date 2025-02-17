local Components = {}

-- Utility function to create basic instance with properties
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

-- Create Window
function Components.createWindow()
    local window = Create("ScreenGui", {
        Name = "CensuraUI",
        ResetOnSpawn = false
    })
    
    local mainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = window,
        Size = UDim2.new(0, 300, 0, 400),
        Position = UDim2.new(0.5, -150, 0.5, -200),
        BackgroundColor3 = Color3.fromRGB(20, 20, 30),
        BackgroundTransparency = 0.15
    })
    
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(35, 35, 50),
        BackgroundTransparency = 0.08
    })
    
    local title = Create("TextLabel", {
        Parent = titleBar,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "Censura",
        TextColor3 = Color3.fromRGB(240, 240, 245),
        Font = Enum.Font.GothamBold,
        TextSize = 18
    })
    
    local contentFrame = Create("ScrollingFrame", {
        Name = "ContentFrame",
        Parent = mainFrame,
        Position = UDim2.new(0, 5, 0, 45),
        Size = UDim2.new(1, -10, 1, -50),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    
    Create("UIListLayout", {
        Parent = contentFrame,
        Padding = UDim.new(0, 8)
    })
    
    -- Apply corners
    for _, frame in pairs({mainFrame, titleBar}) do
        Create("UICorner", {
            Parent = frame,
            CornerRadius = UDim.new(0, 6)
        })
    end
    
    return window, mainFrame, contentFrame
end

-- Create Button
function Components.createButton(parent, text, callback, COLORS, UI_SETTINGS)
    local button = Create("TextButton", {
        Parent = parent,
        Size = UI_SETTINGS.BUTTON_SIZE,
        BackgroundColor3 = COLORS.ACCENT,
        BackgroundTransparency = UI_SETTINGS.TRANSPARENCY.ELEMENTS,
        Text = text,
        TextColor3 = COLORS.TEXT,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14
    })
    
    Create("UICorner", {
        Parent = button,
        CornerRadius = UI_SETTINGS.CORNER_RADIUS
    })
    
    -- Hover Effects
    local function updateColor(isHovered)
        button.BackgroundColor3 = isHovered and COLORS.HIGHLIGHT or COLORS.ACCENT
    end
    
    button.MouseEnter:Connect(function() updateColor(true) end)
    button.MouseLeave:Connect(function() updateColor(false) end)
    button.MouseButton1Click:Connect(callback)
    
    return button
end

-- Create Toggle
function Components.createToggle(parent, text, default, callback, COLORS, UI_SETTINGS)
    local container = Create("Frame", {
        Parent = parent,
        Size = UI_SETTINGS.BUTTON_SIZE,
        BackgroundColor3 = COLORS.ACCENT,
        BackgroundTransparency = UI_SETTINGS.TRANSPARENCY.ELEMENTS
    })
    
    Create("UICorner", {
        Parent = container,
        CornerRadius = UI_SETTINGS.CORNER_RADIUS
    })
    
    local label = Create("TextLabel", {
        Parent = container,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -44, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = COLORS.TEXT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14
    })
    
    local toggle = Create("TextButton", {
        Parent = container,
        Position = UDim2.new(1, -34, 0.5, -12),
        Size = UI_SETTINGS.TOGGLE_SIZE,
        BackgroundColor3 = default and COLORS.ENABLED or COLORS.DISABLED,
        Text = ""
    })
    
    Create("UICorner", {
        Parent = toggle,
        CornerRadius = UDim.new(0, 12)
    })
    
    local enabled = default or false
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.BackgroundColor3 = enabled and COLORS.ENABLED or COLORS.DISABLED
        callback(enabled)
    end)
    
    return container
end

-- Create Slider
function Components.createSlider(parent, text, min, max, default, callback, COLORS, UI_SETTINGS)
    local container = Create("Frame", {
        Parent = parent,
        Size = UI_SETTINGS.SLIDER_SIZE,
        BackgroundColor3 = COLORS.ACCENT,
        BackgroundTransparency = UI_SETTINGS.TRANSPARENCY.ELEMENTS
    })
    
    Create("UICorner", {
        Parent = container,
        CornerRadius = UI_SETTINGS.CORNER_RADIUS
    })
    
    local label = Create("TextLabel", {
        Parent = container,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -70, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = COLORS.TEXT,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14
    })
    
    local valueLabel = Create("TextLabel", {
        Parent = container,
        Position = UDim2.new(1, -60, 0, 0),
        Size = UDim2.new(0, 50, 0, 20),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = COLORS.TEXT,
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14
    })
    
    local sliderBar = Create("Frame", {
        Parent = container,
        Position = UDim2.new(0, 10, 0.7, 0),
        Size = UDim2.new(1, -20, 0, 4),
        BackgroundColor3 = COLORS.BACKGROUND
    })
    
    local fill = Create("Frame", {
        Parent = sliderBar,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = COLORS.ENABLED
    })
    
    for _, frame in pairs({sliderBar, fill}) do
        Create("UICorner", {
            Parent = frame,
            CornerRadius = UDim.new(0, 2)
        })
    end
    
    local button = Create("TextButton", {
        Parent = sliderBar,
        Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        BackgroundColor3 = COLORS.ENABLED,
        Text = ""
    })
    
    Create("UICorner", {
        Parent = button,
        CornerRadius = UDim.new(1, 0)
    })
    
    local dragging = false
    local value = default
    
    button.MouseButton1Down:Connect(function() dragging = true end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("RunService").RenderStepped:Connect(function()
        if dragging then
            local mouse = game:GetService("UserInputService"):GetMouseLocation()
            local pos = (mouse.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
            pos = math.clamp(pos, 0, 1)
            value = min + ((max - min) * pos)
            
            button.Position = UDim2.new(pos, -8, 0.5, -8)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            valueLabel.Text = tostring(math.floor(value))
            callback(math.floor(value))
        end
    end)
    
    return container
end

-- Make Window Draggable
function Components.makeDraggable(titleBar, mainFrame)
    local dragging, dragInput, dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
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
