-- Core/Utils.lua
local Utils = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

--[[ Instance Creation Utility
    Example:
    local button = Utils.Create("TextButton", {
        Size = UDim2.new(0, 100, 0, 30),
        Position = UDim2.new(0.5, -50, 0.5, -15),
        Text = "Click Me",
        BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    })
]]
function Utils.Create(className, properties)
    local instance = Instance.new(className)
    
    for property, value in pairs(properties) do
        instance[property] = value
    end
    
    return instance
end

--[[ Dragging Utility
    Example:
    -- Make a window draggable by its title bar
    Utils.MakeDraggable(titleBar, windowFrame, {
        DragStartCallback = function()
            print("Started dragging")
        end,
        DragEndCallback = function()
            print("Stopped dragging")
        end
    })
]]
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
            }, 0.1)
        end
    end)
end

--[[ Tween Utility
    Example:
    -- Fade out an element
    Utils.Tween(frame, {
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0, -50)
    }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
]]
function Utils.Tween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

--[[ List Layout Utility
    Example:
    local scrollingFrame = Instance.new("ScrollingFrame")
    Utils.SetupListLayout(scrollingFrame, {
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })
]]
function Utils.SetupListLayout(parent, options)
    options = options or {}
    
    local listLayout = Utils.Create("UIListLayout", {
        Parent = parent,
        Padding = options.Padding or UDim.new(0, 5),
        FillDirection = options.FillDirection or Enum.FillDirection.Vertical,
        HorizontalAlignment = options.HorizontalAlignment or Enum.HorizontalAlignment.Left,
        VerticalAlignment = options.VerticalAlignment or Enum.VerticalAlignment.Top,
        SortOrder = options.SortOrder or Enum.SortOrder.LayoutOrder
    })
    
    -- Auto-size canvas if parent is a ScrollingFrame
    if parent:IsA("ScrollingFrame") then
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            parent.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
        end)
    end
    
    return listLayout
end

--[[ Corner Radius Utility
    Example:
    Utils.ApplyCorners(frame, 6)
]]
function Utils.ApplyCorners(instance, radius)
    return Utils.Create("UICorner", {
        Parent = instance,
        CornerRadius = UDim.new(0, radius or 6)
    })
end

--[[ Aspect Ratio Utility
    Example:
    Utils.MaintainAspectRatio(imageFrame, 16, 9)
]]
function Utils.MaintainAspectRatio(instance, width, height)
    return Utils.Create("UIAspectRatioConstraint", {
        Parent = instance,
        AspectRatio = width/height
    })
end

--[[ Color Utility
    Example:
    local darkerColor = Utils.DarkenColor(Color3.fromRGB(255, 100, 100), 0.2)
    local lighterColor = Utils.LightenColor(Color3.fromRGB(100, 100, 255), 0.3)
]]
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

--[[ Mouse Hover Effect Utility
    Example:
    Utils.ApplyHoverEffect(button, {
        Normal = Color3.fromRGB(50, 50, 50),
        Hover = Color3.fromRGB(70, 70, 70)
    })
]]
function Utils.ApplyHoverEffect(instance, colors)
    instance.MouseEnter:Connect(function()
        Utils.Tween(instance, {BackgroundColor3 = colors.Hover}, 0.2)
    end)
    
    instance.MouseLeave:Connect(function()
        Utils.Tween(instance, {BackgroundColor3 = colors.Normal}, 0.2)
    end)
end

return Utils
