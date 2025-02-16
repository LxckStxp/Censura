--[[
    CensuraDev UI Library
    Modern, Semi-Transparent Theme
    Version 2.0
--]]

local CensuraDev = {}
CensuraDev.__index = CensuraDev

-- Services
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Modern Color Scheme
local COLORS = {
    BACKGROUND = Color3.fromRGB(15, 15, 25),
    ACCENT = Color3.fromRGB(30, 30, 45),
    TEXT = Color3.fromRGB(255, 255, 255),
    HIGHLIGHT = Color3.fromRGB(45, 45, 65),
    ENABLED = Color3.fromRGB(126, 131, 255),
    DISABLED = Color3.fromRGB(255, 85, 85),
    GRADIENT_START = Color3.fromRGB(20, 20, 35),
    GRADIENT_END = Color3.fromRGB(30, 30, 45)
}

-- UI Configuration
local UI_SETTINGS = {
    CORNER_RADIUS = UDim.new(0, 8),
    PADDING = UDim.new(0, 6),
    BUTTON_SIZE = UDim2.new(1, -12, 0, 32),
    TOGGLE_SIZE = UDim2.new(0, 24, 0, 24),
    SLIDER_SIZE = UDim2.new(1, -12, 0, 45),
    TRANSPARENCY = {
        BACKGROUND = 0.2,
        ACCENT = 0.1,
        TEXT = 0,
        ELEMENTS = 0.05
    }
}

-- Improved Dragging Function
local function makeDraggable(titleBar, mainFrame)
    local dragging, dragInput, dragStart, startPos
    
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
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
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

-- Create New UI Instance
function CensuraDev.new()
    local self = setmetatable({}, CensuraDev)
    
    -- Main ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "CensuraUI"
    self.ScreenGui.ResetOnSpawn = false
    
    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 300, 0, 400)
    self.MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    self.MainFrame.BackgroundColor3 = COLORS.BACKGROUND
    self.MainFrame.BackgroundTransparency = UI_SETTINGS.TRANSPARENCY.BACKGROUND
    self.MainFrame.Parent = self.ScreenGui
    
    -- Main Frame Gradient
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.GRADIENT_START),
        ColorSequenceKeypoint.new(1, COLORS.GRADIENT_END)
    })
    gradient.Rotation = 45
    gradient.Parent = self.MainFrame
    
    -- Main Frame Corner and Stroke
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UI_SETTINGS.CORNER_RADIUS
    corner.Parent = self.MainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.ACCENT
    stroke.Transparency = 0.7
    stroke.Thickness = 1.5
    stroke.Parent = self.MainFrame
    
    -- Title Bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 32)
    self.TitleBar.BackgroundColor3 = COLORS.ACCENT
    self.TitleBar.BackgroundTransparency = UI_SETTINGS.TRANSPARENCY.ACCENT
    self.TitleBar.Parent = self.MainFrame
    
    -- Title Bar Gradient
    local titleGradient = Instance.new("UIGradient")
    titleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.ACCENT),
        ColorSequenceKeypoint.new(1, COLORS.HIGHLIGHT)
    })
    titleGradient.Rotation = 90
    titleGradient.Parent = self.TitleBar
    
    -- Title Bar Corner
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UI_SETTINGS.CORNER_RADIUS
    titleCorner.Parent = self.TitleBar
    
    -- Title Text
    local title = Instance.new("TextLabel")
    title.Text = "Censura"
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = COLORS.TEXT
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = self.TitleBar
    
    -- Content Frame
    self.ContentFrame = Instance.new("ScrollingFrame")
    self.ContentFrame.Name = "ContentFrame"
    self.ContentFrame.Size = UDim2.new(1, -10, 1, -45)
    self.ContentFrame.Position = UDim2.new(0, 5, 0, 35)
    self.ContentFrame.BackgroundTransparency = 1
    self.ContentFrame.ScrollBarThickness = 2
    self.ContentFrame.ScrollBarImageColor3 = COLORS.ACCENT
    self.ContentFrame.Parent = self.MainFrame
    
    -- Content Layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UI_SETTINGS.PADDING
    listLayout.Parent = self.ContentFrame
    
    -- Initialize Dragging
    makeDraggable(self.TitleBar, self.MainFrame)
    
    -- Visibility Toggle
    self.Visible = true
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.RightAlt then
            self.Visible = not self.Visible
            self.MainFrame.Visible = self.Visible
        end
    end)
    
    return self
end

-- Create Button
function CensuraDev:CreateButton(text, callback)
    local button = Instance.new("TextButton")
    button.Size = UI_SETTINGS.BUTTON_SIZE
    button.BackgroundColor3 = COLORS.ACCENT
    button.BackgroundTransparency = UI_SETTINGS.TRANSPARENCY.ELEMENTS
    button.Text = text
    button.TextColor3 = COLORS.TEXT
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.Parent = self.ContentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UI_SETTINGS.CORNER_RADIUS
    corner.Parent = button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.HIGHLIGHT
    stroke.Transparency = 0.8
    stroke.Thickness = 1
    stroke.Parent = button
    
    -- Hover Effects
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = COLORS.HIGHLIGHT
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = COLORS.ACCENT
        }):Play()
    end)
    
    button.MouseButton1Click:Connect(callback)
    return button
end

-- Create Toggle
function CensuraDev:CreateToggle(text, default, callback)
    local container = Instance.new("Frame")
    container.Size = UI_SETTINGS.BUTTON_SIZE
    container.BackgroundColor3 = COLORS.ACCENT
    container.BackgroundTransparency = UI_SETTINGS.TRANSPARENCY.ELEMENTS
    container.Parent = self.ContentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UI_SETTINGS.CORNER_RADIUS
    corner.Parent = container
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.HIGHLIGHT
    stroke.Transparency = 0.8
    stroke.Thickness = 1
    stroke.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, -44, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = COLORS.TEXT
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14
    label.Parent = container
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UI_SETTINGS.TOGGLE_SIZE
    toggle.Position = UDim2.new(1, -34, 0.5, -12)
    toggle.BackgroundColor3 = default and COLORS.ENABLED or COLORS.DISABLED
    toggle.Text = ""
    toggle.Parent = container
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggle
    
    local enabled = default or false
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        TweenService:Create(toggle, TweenInfo.new(0.2), {
            BackgroundColor3 = enabled and COLORS.ENABLED or COLORS.DISABLED
        }):Play()
        callback(enabled)
    end)
    
    return container
end

-- Create Slider
function CensuraDev:CreateSlider(text, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Size = UI_SETTINGS.SLIDER_SIZE
    container.BackgroundColor3 = COLORS.ACCENT
    container.BackgroundTransparency = UI_SETTINGS.TRANSPARENCY.ELEMENTS
    container.Parent = self.ContentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UI_SETTINGS.CORNER_RADIUS
    corner.Parent = container
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.HIGHLIGHT
    stroke.Transparency = 0.8
    stroke.Thickness = 1
    stroke.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = COLORS.TEXT
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 14
    label.Parent = container
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Text = tostring(default)
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -60, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = COLORS.TEXT
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Font = Enum.Font.GothamSemibold
    valueLabel.TextSize = 14
    valueLabel.Parent = container
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -20, 0, 4)
    sliderBar.Position = UDim2.new(0, 10, 0.7, 0)
    sliderBar.BackgroundColor3 = COLORS.BACKGROUND
    sliderBar.Parent = container
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 2)
    sliderCorner.Parent = sliderBar
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = COLORS.ENABLED
    sliderFill.Parent = sliderBar
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = sliderFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 16, 0, 16)
    sliderButton.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    sliderButton.BackgroundColor3 = COLORS.ENABLED
    sliderButton.Text = ""
    sliderButton.Parent = sliderBar
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = sliderButton
    
    local dragging = false
    local value = default
    
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mouse = UserInputService:GetMouseLocation()
            local pos = (mouse.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
            pos = math.clamp(pos, 0, 1)
            value = min + ((max - min) * pos)
            
            sliderButton.Position = UDim2.new(pos, -8, 0.5, -8)
            sliderFill.Size = UDim2.new(pos, 0, 1, 0)
            valueLabel.Text = tostring(math.floor(value))
            callback(math.floor(value))
        end
    end)
    
    return container
end

-- Show/Hide Methods
function CensuraDev:Show()
    self.ScreenGui.Parent = CoreGui
    self.Visible = true
    self.MainFrame.Visible = true
    
    -- Add fade-in animation
    self.MainFrame.BackgroundTransparency = 1
    TweenService:Create(self.MainFrame, TweenInfo.new(0.2), {
        BackgroundTransparency = UI_SETTINGS.TRANSPARENCY.BACKGROUND
    }):Play()
end

function CensuraDev:Hide()
    -- Add fade-out animation
    TweenService:Create(self.MainFrame, TweenInfo.new(0.2), {
        BackgroundTransparency = 1
    }):Play()
    
    task.wait(0.2)
    self.Visible = false
    self.MainFrame.Visible = false
end

return CensuraDev
