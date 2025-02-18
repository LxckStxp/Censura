--[[
    CensuraDev Functions Module
    Version: 4.0
    
    Provides utility functions for UI management and window behavior
]]

local Functions = {}

-- Services
local Services = {
    TweenService = game:GetService("TweenService"),
    CoreGui = game:GetService("CoreGui"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService")
}

-- Constants
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local DEFAULT_KEYBIND = Enum.KeyCode.RightAlt
local DRAG_SMOOTHING = 0.05

-- Utility Functions
local function CreateTween(instance, properties)
    return Services.TweenService:Create(instance, TWEEN_INFO, properties)
end

--[[ Keybind Handler
    Example:
    Functions.setupKeybind(function()
        print("Keybind pressed!")
    end, Enum.KeyCode.RightControl) -- Custom keybind
]]
function Functions.setupKeybind(callback, customKey)
    assert(type(callback) == "function", "Callback must be a function")
    
    local keybind = customKey or DEFAULT_KEYBIND
    local connection
    
    connection = Services.UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == keybind then
            callback()
        end
    end)
    
    return {
        Disconnect = function()
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end,
        ChangeKey = function(newKey)
            keybind = newKey
        end
    }
end

--[[ Window Dragging
    Example:
    Functions.setupDragging(titleBar, mainFrame, {
        smoothing = 0.1,
        bounds = true
    })
]]
function Functions.setupDragging(titleBar, mainFrame, options)
    assert(titleBar and mainFrame, "TitleBar and MainFrame are required")
    
    options = options or {}
    local smoothing = options.smoothing or DRAG_SMOOTHING
    local bounds = options.bounds
    
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    local targetPos
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        targetPos = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        
        if bounds then
            local viewportSize = workspace.CurrentCamera.ViewportSize
            local frameSize = mainFrame.AbsoluteSize
            
            -- Fixed bounds calculation
            targetPos = UDim2.new(
                targetPos.X.Scale,
                math.clamp(targetPos.X.Offset, -frameSize.X * 0.5, viewportSize.X - frameSize.X * 0.5),
                targetPos.Y.Scale,
                math.clamp(targetPos.Y.Offset, -frameSize.Y * 0.5, viewportSize.Y - frameSize.Y * 0.5)
            )
        end
    end
    
    local dragConnection
    local inputChangedConnection
    local renderSteppedConnection
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            targetPos = startPos
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    inputChangedConnection = Services.UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    renderSteppedConnection = Services.RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            updateDrag(dragInput)
            
            -- Smooth movement
            mainFrame.Position = UDim2.new(
                targetPos.X.Scale,
                lerp(mainFrame.Position.X.Offset, targetPos.X.Offset, smoothing),
                targetPos.Y.Scale,
                lerp(mainFrame.Position.Y.Offset, targetPos.Y.Offset, smoothing)
            )
        end
    end)
    
    -- Add lerp function locally
    local function lerp(a, b, t)
        return a + (b - a) * t
    end
    
    return {
        Disconnect = function()
            if inputChangedConnection then inputChangedConnection:Disconnect() end
            if renderSteppedConnection then renderSteppedConnection:Disconnect() end
        end,
        SetBounds = function(enabled)
            bounds = enabled
        end
    }
end

--[[ Window Setup
    Example:
    Functions.setupWindow(mainFrame, {
        gradient = true,
        stroke = true,
        shadow = true
    })
]]
function Functions.setupWindow(mainFrame, options)
    assert(mainFrame, "MainFrame is required")
    local System = getgenv().CensuraSystem
    options = options or {gradient = true, stroke = true, shadow = true}
    
    -- Corner Radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = System.UI.CornerRadius
    corner.Parent = mainFrame
    
    -- Stroke
    if options.stroke then
        local stroke = Instance.new("UIStroke")
        stroke.Color = System.Colors.Border
        stroke.Transparency = 0.7
        stroke.Thickness = 1.5
        stroke.Parent = mainFrame
    end
    
    -- Gradient
    if options.gradient then
        local gradient = Instance.new("UIGradient")
        gradient.Rotation = 45
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, System.Colors.Background),
            ColorSequenceKeypoint.new(1, System.Colors.Accent)
        })
        gradient.Parent = mainFrame
    end
    
    -- Shadow
    if options.shadow then
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.AnchorPoint = Vector2.new(0.5, 0.5)
        shadow.BackgroundTransparency = 1
        shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
        shadow.Size = UDim2.new(1, 47, 1, 47)
        shadow.ZIndex = -1
        shadow.Image = "rbxassetid://6015897843"
        shadow.ImageColor3 = Color3.new(0, 0, 0)
        shadow.ImageTransparency = 0.5
        shadow.Parent = mainFrame
    end
end

--[[ UI Scaling
    Example:
    Functions.scaleUI(mainFrame, 1.5, {
        smooth = true,
        duration = 0.3
    })
]]
function Functions.scaleUI(mainFrame, scale, options)
    assert(mainFrame and type(scale) == "number", "MainFrame and scale are required")
    options = options or {smooth = true, duration = 0.2}
    
    local currentSize = mainFrame.Size
    local newSize = UDim2.new(
        currentSize.X.Scale * scale,
        currentSize.X.Offset * scale,
        currentSize.Y.Scale * scale,
        currentSize.Y.Offset * scale
    )
    
    if options.smooth then
        CreateTween(mainFrame, {Size = newSize}):Play()
    else
        mainFrame.Size = newSize
    end
end

--[[ Window Positioning
    Example:
    Functions.setWindowPosition(mainFrame, "center")
    Functions.setWindowPosition(mainFrame, "custom", UDim2.new(0.2, 0, 0.3, 0))
]]
function Functions.setWindowPosition(mainFrame, position, customPos)
    assert(mainFrame, "MainFrame is required")
    
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local frameSize = mainFrame.AbsoluteSize
    
    if position == "center" then
        mainFrame.Position = UDim2.new(0.5, -frameSize.X/2, 0.5, -frameSize.Y/2)
    elseif position == "custom" and customPos then
        mainFrame.Position = customPos
    end
end

return Functions
