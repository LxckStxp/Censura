-- Core/Utils.lua
local Utils = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Get Styles reference
local Styles = _G.Censura.Modules.Styles

function Utils.Create(className, properties)
    local instance = Instance.new(className)
    
    -- Apply default styles based on className
    if className == "TextButton" then
        instance.BackgroundColor3 = Styles.Colors.Controls.Button.Default
        instance.TextColor3 = Styles.Colors.Text.Primary
        instance.Font = Styles.Text.Default.Font
        instance.TextSize = Styles.Text.Default.Size
        instance.AutoButtonColor = false
    elseif className == "TextLabel" then
        instance.BackgroundTransparency = 1
        instance.TextColor3 = Styles.Colors.Text.Primary
        instance.Font = Styles.Text.Default.Font
        instance.TextSize = Styles.Text.Default.Size
    elseif className == "Frame" then
        instance.BackgroundColor3 = Styles.Colors.Window.Background
        instance.BorderSizePixel = 0
    elseif className == "ScrollingFrame" then
        instance.BackgroundTransparency = 1
        instance.ScrollBarThickness = Styles.Layout.Controls.ScrollBarThickness
        instance.ScrollBarImageColor3 = Styles.Colors.Controls.ScrollBar.Bar
    end
    
    -- Apply custom properties
    for property, value in pairs(properties) do
        instance[property] = value
    end
    
    return instance
end

function Utils.MakeDraggable(dragObject, dragTarget, callbacks)
    callbacks = callbacks or {}
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    dragObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = dragTarget.Position
            
            if callbacks.DragStartCallback then
                callbacks.DragStartCallback()
            end
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if callbacks.DragEndCallback then
                        callbacks.DragEndCallback()
                    end
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            Utils.Tween(dragTarget, {
                Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            }, Styles.Animation.Short)
        end
    end)
end

function Utils.Tween(instance, properties, tweenInfo)
    tweenInfo = tweenInfo or Styles.Animation.Short
    
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utils.SetupListLayout(parent, options)
    options = options or {}
    
    local listLayout = Utils.Create("UIListLayout", {
        Parent = parent,
        Padding = UDim.new(0, options.Padding or Styles.Layout.Spacing.Medium),
        FillDirection = options.FillDirection or Enum.FillDirection.Vertical,
        HorizontalAlignment = options.HorizontalAlignment or Enum.HorizontalAlignment.Left,
        VerticalAlignment = options.VerticalAlignment or Enum.VerticalAlignment.Top,
        SortOrder = options.SortOrder or Enum.SortOrder.LayoutOrder
    })
    
    if parent:IsA("ScrollingFrame") then
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            parent.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + Styles.Layout.Padding.Container)
        end)
    end
    
    return listLayout
end

function Utils.ApplyCorners(instance, radius)
    return Utils.Create("UICorner", {
        Parent = instance,
        CornerRadius = UDim.new(0, radius or Styles.Layout.Window.CornerRadius)
    })
end

function Utils.ApplyHoverEffect(instance, colors)
    colors = colors or {
        Normal = Styles.Colors.Controls.Button.Default,
        Hover = Styles.Colors.Controls.Button.Hover,
        Pressed = Styles.Colors.Controls.Button.Pressed
    }
    
    instance.MouseEnter:Connect(function()
        Utils.Tween(instance, {BackgroundColor3 = colors.Hover})
    end)
    
    instance.MouseLeave:Connect(function()
        Utils.Tween(instance, {BackgroundColor3 = colors.Normal})
    end)
    
    instance.MouseButton1Down:Connect(function()
        Utils.Tween(instance, {BackgroundColor3 = colors.Pressed})
    end)
    
    instance.MouseButton1Up:Connect(function()
        Utils.Tween(instance, {BackgroundColor3 = colors.Hover})
    end)
end

function Utils.CreateShadow(parent)
    local shadow = Utils.Create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Styles.Colors.Window.Shadow,
        ImageTransparency = 0.5,
        Size = UDim2.new(1, Styles.Layout.Window.ShadowSize * 2, 1, Styles.Layout.Window.ShadowSize * 2),
        Position = UDim2.new(0, -Styles.Layout.Window.ShadowSize, 0, -Styles.Layout.Window.ShadowSize),
        ZIndex = parent.ZIndex - 1,
        Parent = parent
    })
    
    return shadow
end

function Utils.CreatePadding(parent, padding)
    return Utils.Create("UIPadding", {
        Parent = parent,
        PaddingTop = UDim.new(0, padding or Styles.Layout.Padding.Container),
        PaddingBottom = UDim.new(0, padding or Styles.Layout.Padding.Container),
        PaddingLeft = UDim.new(0, padding or Styles.Layout.Padding.Container),
        PaddingRight = UDim.new(0, padding or Styles.Layout.Padding.Container)
    })
end

return Utils
