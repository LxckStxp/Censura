--[[
    CensuraDev Functions Module
    Version: 4.1
    
    Core utility functions for UI interaction and behavior
    with improved dragging and window management
]]

local Functions = {}

-- Services
local Services = {
    Tween = game:GetService("TweenService"),
    Input = game:GetService("UserInputService"),
    Run = game:GetService("RunService")
}

-- Utility Functions
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

-- Enhanced Dragging System
function Functions.makeDraggable(titleBar, mainFrame, dragOptions)
    assert(titleBar, "TitleBar is required")
    assert(mainFrame, "MainFrame is required")
    
    local System = getgenv().CensuraSystem
    if not System then return end
    
    dragOptions = dragOptions or {
        dragThreshold = 1,
        dragInertia = 0.07,
        snapToScreen = true,
        bounds = {
            minX = 0,
            minY = 0,
            maxX = 1,
            maxY = 1
        }
    }
    
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    local lastMousePos
    local lastGoalPos
    local dragInertia = Vector2.new()
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        local goalPos = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        
        -- Apply bounds if snapToScreen is enabled
        if dragOptions.snapToScreen then
            local viewportSize = workspace.CurrentCamera.ViewportSize
            local frameSize = mainFrame.AbsoluteSize
            
            goalPos = UDim2.new(
                goalPos.X.Scale,
                math.clamp(goalPos.X.Offset, 0, viewportSize.X - frameSize.X),
                goalPos.Y.Scale,
                math.clamp(goalPos.Y.Offset, 0, viewportSize.Y - frameSize.Y)
            )
        end
        
        -- Apply smooth dragging
        if dragOptions.dragInertia > 0 then
            lastGoalPos = goalPos
            if lastMousePos then
                dragInertia = (input.Position - lastMousePos) * dragOptions.dragInertia
            end
            lastMousePos = input.Position
        else
            mainFrame.Position = goalPos
        end
    end
    
    -- Drag start
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            lastMousePos = dragStart
            
            -- Highlight effect on drag
            System.Animations.applyHoverState(titleBar, titleBar:FindFirstChild("UIStroke"))
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    System.Animations.removeHoverState(titleBar, titleBar:FindFirstChild("UIStroke"))
                end
            end)
        end
    end)
    
    -- Track drag input
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    -- Update drag position
    Services.Input.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)
    
    -- Apply inertia
    if dragOptions.dragInertia > 0 then
        Services.Run.RenderStepped:Connect(function()
            if not dragging and dragInertia.Magnitude > 0.1 then
                local newPos = mainFrame.Position + UDim2.new(0, dragInertia.X, 0, dragInertia.Y)
                dragInertia = dragInertia * 0.9
                
                -- Apply bounds
                if dragOptions.snapToScreen then
                    local viewportSize = workspace.CurrentCamera.ViewportSize
                    local frameSize = mainFrame.AbsoluteSize
                    
                    newPos = UDim2.new(
                        newPos.X.Scale,
                        math.clamp(newPos.X.Offset, 0, viewportSize.X - frameSize.X),
                        newPos.Y.Scale,
                        math.clamp(newPos.Y.Offset, 0, viewportSize.Y - frameSize.Y)
                    )
                end
                
                mainFrame.Position = newPos
            end
        end)
    end
end

-- Enhanced Window Setup
function Functions.setupWindow(frame, options)
    local System = getgenv().CensuraSystem
    if not System then return end
    
    options = options or {
        gradient = true,
        corners = true,
        stroke = true,
        shadow = true
    }
    
    -- Container for effects
    local effects = {}
    
    -- Gradient background
    if options.gradient then
        effects.gradient = System.Animations.createAnimatedGradient({
            StartColor = System.Colors.Background,
            EndColor = System.Colors.Accent,
            Rotation = 45
        })
        effects.gradient.Parent = frame
    end
    
    -- Corner rounding
    if options.corners then
        effects.corner = Create("UICorner", {
            CornerRadius = System.UI.CornerRadius,
            Parent = frame
        })
    end
    
    -- Border stroke
    if options.stroke then
        effects.stroke = System.Styles.createStroke(
            System.Colors.Border,
            System.UI.Transparency.Elements,
            1.5
        )
        effects.stroke.Parent = frame
    end
    
    -- Drop shadow
    if options.shadow then
        effects.shadow = Create("ImageLabel", {
            Name = "Shadow",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 20, 1, 20),
            BackgroundTransparency = 1,
            Image = "rbxassetid://7912134082",
            ImageColor3 = System.Colors.Background,
            ImageTransparency = 0.6,
            Parent = frame
        })
        effects.shadow.ZIndex = frame.ZIndex - 1
    end
    
    return effects
end

-- Enhanced Animation Utilities
function Functions.fadeIn(frame, duration, callback)
    local System = getgenv().CensuraSystem
    if not System then return end
    
    frame.BackgroundTransparency = 1
    local tween = Services.Tween:Create(
        frame, 
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = System.UI.Transparency.Background}
    )
    
    if callback then
        tween.Completed:Connect(callback)
    end
    
    tween:Play()
    return tween
end

function Functions.fadeOut(frame, duration, callback)
    local tween = Services.Tween:Create(
        frame,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundTransparency = 1}
    )
    
    if callback then
        tween.Completed:Connect(callback)
    end
    
    tween:Play()
    return tween
end

return Functions
