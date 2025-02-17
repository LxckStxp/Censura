local Functions = {}

-- Services
local Services = {
    TweenService = game:GetService("TweenService"),
    CoreGui = game:GetService("CoreGui"),
    UserInputService = game:GetService("UserInputService")
}

-- Visibility Functions
function Functions.handleVisibility(gui, mainFrame, showing)
    local System = getgenv().CensuraSystem
    
    if showing then
        gui.Parent = Services.CoreGui
        mainFrame.Visible = true
        
        -- Fade in animation
        Services.TweenService:Create(
            mainFrame,
            System.UI.TweenInfo,
            {BackgroundTransparency = System.UI.Transparency.Background}
        ):Play()
        
        -- Fade in elements
        for _, element in ipairs(mainFrame:GetDescendants()) do
            if element:IsA("Frame") and element.BackgroundTransparency < 1 then
                Services.TweenService:Create(
                    element,
                    System.UI.TweenInfo,
                    {BackgroundTransparency = System.UI.Transparency.Elements}
                ):Play()
            end
        end
    else
        -- Fade out animation
        Services.TweenService:Create(
            mainFrame,
            System.UI.TweenInfo,
            {BackgroundTransparency = 1}
        ):Play()
        
        -- Fade out elements
        for _, element in ipairs(mainFrame:GetDescendants()) do
            if element:IsA("Frame") and element.BackgroundTransparency < 1 then
                Services.TweenService:Create(
                    element,
                    System.UI.TweenInfo,
                    {BackgroundTransparency = 1}
                ):Play()
            end
        end
        
        task.wait(System.UI.TweenInfo.Time)
        mainFrame.Visible = false
    end
    
    return showing
end

-- Keybind Handler
function Functions.setupKeybind(callback)
    Services.UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.RightAlt then
            callback()
        end
    end)
end

-- Window Movement Functions
function Functions.setupDragging(titleBar, mainFrame)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
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
    
    Services.UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
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

-- Window Setup Functions
function Functions.setupWindow(mainFrame)
    local System = getgenv().CensuraSystem
    
    -- Apply corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = System.UI.CornerRadius
    corner.Parent = mainFrame
    
    -- Apply stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = System.Colors.Border
    stroke.Transparency = 0.7
    stroke.Thickness = 1.5
    stroke.Parent = mainFrame
    
    -- Apply gradient
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 45
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, System.Colors.Background),
        ColorSequenceKeypoint.new(1, System.Colors.Accent)
    })
    gradient.Parent = mainFrame
end

-- Animation Functions
function Functions.fadeElement(element, transparency, duration)
    local System = getgenv().CensuraSystem
    
    Services.TweenService:Create(
        element,
        TweenInfo.new(duration or System.UI.TweenInfo.Time),
        {BackgroundTransparency = transparency}
    ):Play()
end

-- Utility Functions
function Functions.scaleUI(mainFrame, scale)
    local currentSize = mainFrame.Size
    local newSize = UDim2.new(
        currentSize.X.Scale * scale,
        currentSize.X.Offset * scale,
        currentSize.Y.Scale * scale,
        currentSize.Y.Offset * scale
    )
    
    Services.TweenService:Create(
        mainFrame,
        getgenv().CensuraSystem.UI.TweenInfo,
        {Size = newSize}
    ):Play()
end

function Functions.centerWindow(mainFrame)
    local viewportSize = workspace.CurrentCamera.ViewportSize
    mainFrame.Position = UDim2.new(0.5, -mainFrame.AbsoluteSize.X/2, 0.5, -mainFrame.AbsoluteSize.Y/2)
end

return Functions
