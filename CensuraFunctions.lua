--[[
    CensuraDev Functions Module
    Version: 4.0
    
    Core utility functions for UI interaction and behavior
]]

local Functions = {}

-- Services
local Services = {
    Tween = game:GetService("TweenService"),
    Input = game:GetService("UserInputService"),
    Run = game:GetService("RunService")
}

-- Dragging functionality
function Functions.makeDraggable(titleBar, mainFrame)
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
    
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
    
    Services.Input.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)
end

-- Window setup with styling
function Functions.setupWindow(frame)
    local System = getgenv().CensuraSystem
    if not System then return end
    
    -- Gradient background
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, System.Colors.Background),
        ColorSequenceKeypoint.new(1, System.Colors.Accent)
    })
    gradient.Rotation = 45
    gradient.Parent = frame
    
    -- Corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = System.UI.CornerRadius
    corner.Parent = frame
    
    -- Border stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = System.Colors.Border
    stroke.Transparency = 0.7
    stroke.Thickness = 1.5
    stroke.Parent = frame
end

-- Animation utilities
function Functions.fadeIn(frame)
    local System = getgenv().CensuraSystem
    if not System then return end
    
    frame.BackgroundTransparency = 1
    Services.Tween:Create(frame, TweenInfo.new(0.2), {
        BackgroundTransparency = System.UI.Transparency.Background
    }):Play()
end

function Functions.fadeOut(frame)
    Services.Tween:Create(frame, TweenInfo.new(0.2), {
        BackgroundTransparency = 1
    }):Play()
end

return Functions
