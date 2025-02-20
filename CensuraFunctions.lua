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
function Functions.makeDraggable(titleBar, mainFrame)
    assert(titleBar, "TitleBar is required")
    assert(mainFrame, "MainFrame is required")
    
    local UserInputService = game:GetService("UserInputService")
    local dragToggle = nil
    local dragSpeed = 0.1
    local dragStart = nil
    local startPos = nil

    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        game:GetService('TweenService'):Create(mainFrame, TweenInfo.new(dragSpeed), {Position = position}):Play()
    end

    titleBar.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1) then
            dragToggle = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragToggle then
                updateInput(input)
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
