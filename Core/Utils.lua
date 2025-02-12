-- Core/Utils.lua
local Utils = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Get references to our modules (will be available after initialization)
local function getStyles()
    return _G.Censura.Modules.Styles
end

-- Enhanced Instance Creation with Default Styling
function Utils.Create(className, properties)
    local Styles = getStyles()
    local instance = Instance.new(className)
    
    -- Apply default styling based on className
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
    for property, value in pairs(properties or {}) do
        instance[property] = value
    end
    
    return instance
end

-- Enhanced Dragging System
function Utils.MakeDraggable(dragObject, dragTarget, options)
    options = options or {}
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    local Styles = getStyles()
    
    -- Add visual feedback
    if options.highlight then
        local originalColor = dragObject.BackgroundColor3
        dragObject.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Utils.Tween(dragObject, {
                    BackgroundColor3 = Styles.Colors.Controls.Button.Pressed
                }, Styles.Animation.Short)
            end
        end)
        
        dragObject.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Utils.Tween(dragObject, {
                    BackgroundColor3 = originalColor
                }, Styles.Animation.Short)
            end
        end)
    end
    
    dragObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = dragTarget.Position
            
            if options.dragStartCallback then
                options.dragStartCallback()
            end
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if options.dragEndCallback then
                        options.dragEndCallback()
                    end
                end
            end)
        end
    end)
    
    dragObject.InputChanged:Connect(function(input)
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

-- Enhanced Tweening System
function Utils.Tween(instance, properties, tweenInfo)
    local Styles = getStyles()
    
    -- Use default animation if not specified
    if type(tweenInfo) == "number" then
        tweenInfo = TweenInfo.new(
            tweenInfo,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )
    elseif not tweenInfo then
        tweenInfo = Styles.Animation.Short
    end
    
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Layout Utilities
function Utils.SetupListLayout(parent, options)
    options = options or {}
    local Styles = getStyles()
    
    local listLayout = Utils.Create("UIListLayout", {
        Parent = parent,
        Padding = options.Padding or UDim.new(0, Styles.Layout.Spacing.Medium),
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

-- UI Enhancement Utilities
function Utils.ApplyCorners(instance, radius)
    local Styles = getStyles()
    return Utils.Create("UICorner", {
        Parent = instance,
        CornerRadius = UDim.new(0, radius or Styles.Layout.Window.CornerRadius)
    })
end

function Utils.CreateShadow(parent)
    local Styles = getStyles()
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
    local Styles = getStyles()
    return Utils.Create("UIPadding", {
        Parent = parent,
        PaddingTop = UDim.new(0, padding or Styles.Layout.Padding.Container),
        PaddingBottom = UDim.new(0, padding or Styles.Layout.Padding.Container),
        PaddingLeft = UDim.new(0, padding or Styles.Layout.Padding.Container),
        PaddingRight = UDim.new(0, padding or Styles.Layout.Padding.Container)
    })
end

-- Color Utilities
function Utils.DarkenColor(color, factor)
    return Color3.new(
        math.clamp(color.R * (1 - factor), 0, 1),
        math.clamp(color.G * (1 - factor), 0, 1),
        math.clamp(color.B * (1 - factor), 0, 1)
    )
end

function Utils.LightenColor(color, factor)
    return Color3.new(
        math.clamp(color.R + (1 - color.R) * factor, 0, 1),
        math.clamp(color.G + (1 - color.G) * factor, 0, 1),
        math.clamp(color.B + (1 - color.B) * factor, 0, 1)
    )
end

return Utils
