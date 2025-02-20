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
function Functions.makeDraggable(titleBar, mainFrame, dragOptions)
    assert(titleBar, "TitleBar is required")
    assert(mainFrame, "MainFrame is required")
    
    local System = getgenv().CensuraSystem
    if not System then return end
    
    dragOptions = dragOptions or {
        dragInertia = 0.07,
        snapToScreen = true
    }
    
    local state = {
        dragging = false,
        dragStart = nil,
        startPos = nil
    }
    
    -- Mouse down
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state.dragging = true
            state.dragStart = input.Position
            state.startPos = mainFrame.Position
            
            -- Apply hover effect
            if titleBar:FindFirstChild("UIStroke") then
                Services.Tween:Create(titleBar:FindFirstChild("UIStroke"), 
                    TweenInfo.new(0.2), 
                    {Transparency = 0.2}
                ):Play()
            end
        end
    end)
    
    -- Mouse move
    Services.Input.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and state.dragging then
            local delta = input.Position - state.dragStart
            local targetPos = UDim2.new(
                state.startPos.X.Scale,
                state.startPos.X.Offset + delta.X,
                state.startPos.Y.Scale,
                state.startPos.Y.Offset + delta.Y
            )
            
            -- Apply bounds if snapToScreen is enabled
            if dragOptions.snapToScreen then
                local viewportSize = workspace.CurrentCamera.ViewportSize
                local frameSize = mainFrame.AbsoluteSize
                
                targetPos = UDim2.new(
                    targetPos.X.Scale,
                    math.clamp(targetPos.X.Offset, 0, viewportSize.X - frameSize.X),
                    targetPos.Y.Scale,
                    math.clamp(targetPos.Y.Offset, 0, viewportSize.Y - frameSize.Y)
                )
            end
            
            -- Apply position with smoothing
            mainFrame.Position = targetPos
        end
    end)
    
    -- Mouse up
    Services.Input.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state.dragging = false
            
            -- Remove hover effect
            if titleBar:FindFirstChild("UIStroke") then
                Services.Tween:Create(titleBar:FindFirstChild("UIStroke"), 
                    TweenInfo.new(0.2), 
                    {Transparency = System.UI.Transparency.Elements}
                ):Play()
            end
        end
    end)
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
