--[[
    CensuraDev Functions Module
    Version: 4.2.1  -- Updated version number due to changes
    
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

-- Load Animations Module
local Animations = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraAnimations.lua"))() or {}

-- Utility Functions
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

-- Enhanced Dragging System
-- Enhanced Dragging System
function Functions.makeDraggable(titleBar, mainFrame, dragOptions)
    assert(titleBar, "TitleBar is required")
    assert(mainFrame, "MainFrame is required")
    
    local System = getgenv().CensuraSystem
    if not System then return end
    
    dragOptions = dragOptions or {
        dragThreshold = 1,
        dragInertia = 0.07,
        snapToScreen = false,
        bounds = {
            minX = 0,
            minY = 0,
            maxX = 1,
            maxY = 1
        }
    }
    
    local dragging = false
    local dragStart
    local startPos
    local lastMousePos
    local lastGoalPos
    local dragInertia = Vector2.new()
    
    local function isMouseOver(element, mousePos)
        local absPos = element.AbsolutePosition
        local absSize = element.AbsoluteSize
        return mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X and
               mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y
    end

    local function updateDrag(inputPos)
        local delta = inputPos - dragStart
        local goalPos = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        
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
        
        if dragOptions.dragInertia > 0 then
            lastGoalPos = goalPos
            if lastMousePos then
                dragInertia = (inputPos - lastMousePos) * dragOptions.dragInertia
            end
            lastMousePos = inputPos
        else
            mainFrame.Position = goalPos
        end
    end
    
    -- Use global input events for better dragging behavior
    Services.Input.InputBegan:Connect(function(input, processed)
        if not processed and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = Services.Input:GetMouseLocation()
            if isMouseOver(titleBar, mousePos) then
                dragging = true
                dragStart = mousePos
                startPos = mainFrame.Position
                lastMousePos = dragStart
                Animations.applyHoverState(titleBar, titleBar:FindFirstChild("UIStroke") or titleBar:FindFirstChildOfClass("UIStroke") or Create("UIStroke", {Parent = titleBar}))
            end
        end
    end)
    
    Services.Input.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            updateDrag(input.Position)
        end
    end)
    
    Services.Input.InputEnded:Connect(function(input, processed)
        if not processed and input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            dragging = false
            Animations.removeHoverState(titleBar, titleBar:FindFirstChild("UIStroke") or titleBar:FindFirstChildOfClass("UIStroke") or Create("UIStroke", {Parent = titleBar}))
        end
    end)
    
    if dragOptions.dragInertia > 0 then
        Services.Run.RenderStepped:Connect(function(deltaTime)
            if not dragging and dragInertia.Magnitude > 0.1 then
                local newPos = mainFrame.Position + UDim2.new(0, dragInertia.X, 0, dragInertia.Y)
                dragInertia = dragInertia * 0.9
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


-- Enhanced Window Setup (unchanged from original code)
function Functions.setupWindow(frame, options)
    local System = getgenv().CensuraSystem
    if not System then return end
    
    options = options or {
        gradient = true,
        corners = true,
        stroke = true,
        shadow = true
    }
    
    local effects = {}

    if options.gradient then
        effects.gradient = Animations.createAnimatedGradient and Animations.createAnimatedGradient {
            StartColor = System.Colors.Background,
            EndColor = System.Colors.Accent,
            Rotation = 45
        } or Create("UIGradient", {
            Color = ColorSequence.new {
                ColorSequenceKeypoint.new(0, System.Colors.Background), 
                ColorSequenceKeypoint.new(1, System.Colors.Accent) 
            },
            Rotation = 45,
            Parent = frame
        }) 
    end

    if options.corners then
        effects.corner = Create("UICorner", {
            CornerRadius = System.UI.CornerRadius,
            Parent = frame
        }) 
    end

    if options.stroke then
        effects.stroke = System.Styles.createStroke and System.Styles.createStroke(System.Colors.Border, System.UI.Transparency.Elements, 1.5) or Create("UIStroke", {
            Color = System.Colors.Border, 
            Thickness = 1.5, 
            Transparency = System.UI.Transparency.Elements, 
            Parent = frame
        }) 
    end

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

-- Enhanced Animation Utilities (unchanged from original code, with minor improvements for robustness)
function Functions.fadeIn(frame, duration, callback) 
    local System = getgenv().CensuraSystem 
    if not System then return end 
    
    frame.BackgroundTransparency = 1 
    local tween = Services.Tween:Create( 
        frame,  
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {BackgroundTransparency = System.UI.Transparency.Background or 0} 
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
