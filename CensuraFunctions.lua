--[[
    CensuraDev Functions Module
    Version: 4.1
    
    Optimized utility functions for UI management and window behavior
]]

local Functions = {}

-- Services
local Services = {
    Tween = game:GetService("TweenService"),
    Core = game:GetService("CoreGui"),
    Input = game:GetService("UserInputService"),
    Run = game:GetService("RunService")
}

-- Constants
local DEFAULTS = {
    TWEEN = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    KEYBIND = Enum.KeyCode.RightAlt,
    DRAG_SMOOTH = 0.05,
    SHADOW_ID = "rbxassetid://6015897843"
}

-- Utility Functions
local function Lerp(a, b, t)
    return a + (b - a) * t
end

local function CreateTween(instance, properties, info)
    return Services.Tween:Create(instance, info or DEFAULTS.TWEEN, properties)
end

local function SafeDestroy(instance)
    if instance and instance.Parent then
        instance:Destroy()
    end
end

-- Connection Manager
local ConnectionManager = {
    new = function()
        local connections = {}
        
        return {
            add = function(connection)
                table.insert(connections, connection)
                return connection
            end,
            
            disconnect = function()
                for _, conn in ipairs(connections) do
                    if typeof(conn) == "RBXScriptConnection" then
                        conn:Disconnect()
                    end
                end
                table.clear(connections)
            end
        }
    end
}

--[[ Keybind Handler
    Example:
    local keyHandler = Functions.setupKeybind(function()
        print("Key pressed!")
    end, Enum.KeyCode.RightControl)
]]
function Functions.setupKeybind(callback, customKey)
    local manager = ConnectionManager.new()
    local currentKey = customKey or DEFAULTS.KEYBIND
    
    manager.add(Services.Input.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == currentKey then
            task.spawn(callback)
        end
    end))
    
    return {
        Disconnect = function()
            manager.disconnect()
        end,
        ChangeKey = function(newKey)
            currentKey = newKey
        end
    }
end

--[[ Window Dragging
    Example:
    local dragHandler = Functions.setupDragging(titleBar, mainFrame, {
        smoothing = 0.1,
        bounds = true,
        snapToEdge = true
    })
]]
function Functions.setupDragging(titleBar, mainFrame, options)
    local manager = ConnectionManager.new()
    options = options or {}
    
    local state = {
        dragging = false,
        dragInput = nil,
        dragStart = nil,
        startPos = nil,
        targetPos = nil
    }
    
    local function updateDrag(input)
        local delta = input.Position - state.dragStart
        state.targetPos = UDim2.new(
            state.startPos.X.Scale,
            state.startPos.X.Offset + delta.X,
            state.startPos.Y.Scale,
            state.startPos.Y.Offset + delta.Y
        )
        
        if options.bounds then
            local viewport = workspace.CurrentCamera.ViewportSize
            local frame = mainFrame.AbsoluteSize
            
            state.targetPos = UDim2.new(
                state.targetPos.X.Scale,
                math.clamp(state.targetPos.X.Offset, 0, viewport.X - frame.X),
                state.targetPos.Y.Scale,
                math.clamp(state.targetPos.Y.Offset, 0, viewport.Y - frame.Y)
            )
        end
    end
    
    -- Start drag
    manager.add(titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state.dragging = true
            state.dragStart = input.Position
            state.startPos = mainFrame.Position
            state.targetPos = state.startPos
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    state.dragging = false
                end
            end)
        end
    end))
    
    -- Track mouse movement
    manager.add(Services.Input.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            state.dragInput = input
        end
    end))
    
    -- Update position
    manager.add(Services.Run.RenderStepped:Connect(function()
        if state.dragging and state.dragInput then
            updateDrag(state.dragInput)
            
            mainFrame.Position = UDim2.new(
                state.targetPos.X.Scale,
                Lerp(mainFrame.Position.X.Offset, state.targetPos.X.Offset, options.smoothing or DEFAULTS.DRAG_SMOOTH),
                state.targetPos.Y.Scale,
                Lerp(mainFrame.Position.Y.Offset, state.targetPos.Y.Offset, options.smoothing or DEFAULTS.DRAG_SMOOTH)
            )
        end
    end))
    
    return {
        Disconnect = function()
            manager.disconnect()
        end,
        SetBounds = function(enabled)
            options.bounds = enabled
        end
    }
end

--[[ Window Setup
    Example:
    Functions.setupWindow(mainFrame, {
        gradient = true,
        stroke = true,
        shadow = true,
        blur = true
    })
]]
function Functions.setupWindow(mainFrame, options)
    local System = getgenv().CensuraSystem
    if not System then return end
    
    options = options or {
        gradient = true,
        stroke = true,
        shadow = true
    }
    
    -- Corner
    Instance.new("UICorner", mainFrame).CornerRadius = System.UI.CornerRadius
    
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
        shadow.Image = DEFAULTS.SHADOW_ID
        shadow.ImageColor3 = Color3.new(0, 0, 0)
        shadow.ImageTransparency = 0.5
        shadow.Parent = mainFrame
    end
end

--[[ UI Scaling
    Example:
    Functions.scaleUI(mainFrame, 1.5, {
        smooth = true,
        duration = 0.3,
        onComplete = function() print("Scale complete!") end
    })
]]
function Functions.scaleUI(mainFrame, scale, options)
    options = options or {
        smooth = true,
        duration = 0.2
    }
    
    local newSize = UDim2.new(
        mainFrame.Size.X.Scale * scale,
        mainFrame.Size.X.Offset * scale,
        mainFrame.Size.Y.Scale * scale,
        mainFrame.Size.Y.Offset * scale
    )
    
    if options.smooth then
        local tween = CreateTween(
            mainFrame, 
            {Size = newSize},
            TweenInfo.new(options.duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        )
        
        if options.onComplete then
            tween.Completed:Connect(options.onComplete)
        end
        
        tween:Play()
    else
        mainFrame.Size = newSize
        if options.onComplete then
            options.onComplete()
        end
    end
end

--[[ Window Positioning
    Example:
    Functions.setWindowPosition(mainFrame, "center")
    Functions.setWindowPosition(mainFrame, "custom", UDim2.new(0.2, 0, 0.3, 0))
]]
function Functions.setWindowPosition(mainFrame, position, customPos)
    local viewport = workspace.CurrentCamera.ViewportSize
    local frameSize = mainFrame.AbsoluteSize
    
    local positions = {
        center = UDim2.new(0.5, -frameSize.X/2, 0.5, -frameSize.Y/2),
        topleft = UDim2.new(0, 0, 0, 0),
        topright = UDim2.new(1, -frameSize.X, 0, 0),
        bottomleft = UDim2.new(0, 0, 1, -frameSize.Y),
        bottomright = UDim2.new(1, -frameSize.X, 1, -frameSize.Y)
    }
    
    mainFrame.Position = positions[position] or customPos or positions.center
end

return Functions
