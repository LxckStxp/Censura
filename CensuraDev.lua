-- CensuraDev.lua
local CensuraDev = {}
CensuraDev.__index = CensuraDev

-- Services
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Constants for styling
local COLORS = {
    BACKGROUND = Color3.fromRGB(25, 25, 25),
    ACCENT = Color3.fromRGB(45, 45, 45),
    TEXT = Color3.fromRGB(255, 255, 255),
    HIGHLIGHT = Color3.fromRGB(65, 65, 65),
    ENABLED = Color3.fromRGB(0, 255, 127),
    DISABLED = Color3.fromRGB(255, 68, 68)
}

local UI_SETTINGS = {
    CORNER_RADIUS = UDim.new(0, 6),
    PADDING = UDim.new(0, 5),
    BUTTON_SIZE = UDim2.new(1, -10, 0, 30),
    TOGGLE_SIZE = UDim2.new(0, 20, 0, 20),
    SLIDER_SIZE = UDim2.new(1, -10, 0, 40),
}

-- Add dragging functionality
local function makeDraggable(frame)
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function CensuraDev.new()
    local self = setmetatable({}, CensuraDev)
    
    -- Create main UI
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "CensuraUI"
    self.ScreenGui.ResetOnSpawn = false
    
    -- Create title bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 30)
    self.TitleBar.BackgroundColor3 = COLORS.ACCENT
    self.TitleBar.Parent = self.MainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UI_SETTINGS.CORNER_RADIUS
    titleCorner.Parent = self.TitleBar
    
    local title = Instance.new("TextLabel")
    title.Text = "Censura"
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = COLORS.TEXT
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = self.TitleBar
    
    -- Create main frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 300, 0, 400)
    self.MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    self.MainFrame.BackgroundColor3 = COLORS.BACKGROUND
    self.MainFrame.Parent = self.ScreenGui
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UI_SETTINGS.CORNER_RADIUS
    corner.Parent = self.MainFrame
    
    -- Add content frame
    self.ContentFrame = Instance.new("ScrollingFrame")
    self.ContentFrame.Name = "ContentFrame"
    self.ContentFrame.Size = UDim2.new(1, -10, 1, -45) -- Adjusted for title bar
    self.ContentFrame.Position = UDim2.new(0, 5, 0, 35) -- Positioned below title bar
    self.ContentFrame.BackgroundTransparency = 1
    self.ContentFrame.ScrollBarThickness = 4
    self.ContentFrame.Parent = self.MainFrame
    
    -- Add list layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UI_SETTINGS.PADDING
    listLayout.Parent = self.ContentFrame
    
    -- Make the frame draggable using the title bar
    makeDraggable(self.TitleBar)
    
    -- Set up visibility toggle with Right Control
    self.Visible = true
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.RightControl then
            self.Visible = not self.Visible
            self.MainFrame.Visible = self.Visible
        end
    end)
    
    return self
end

function CensuraDev:CreateButton(text, callback)
    local button = Instance.new("TextButton")
    button.Size = UI_SETTINGS.BUTTON_SIZE
    button.BackgroundColor3 = COLORS.ACCENT
    button.Text = text
    button.TextColor3 = COLORS.TEXT
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.Parent = self.ContentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UI_SETTINGS.CORNER_RADIUS
    corner.Parent = button
    
    button.MouseButton1Click:Connect(callback)
    return button
end

function CensuraDev:CreateToggle(text, default, callback)
    local container = Instance.new("Frame")
    container.Size = UI_SETTINGS.BUTTON_SIZE
    container.BackgroundColor3 = COLORS.ACCENT
    container.Parent = self.ContentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UI_SETTINGS.CORNER_RADIUS
    corner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = COLORS.TEXT
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = container
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UI_SETTINGS.TOGGLE_SIZE
    toggle.Position = UDim2.new(1, -30, 0.5, -10)
    toggle.BackgroundColor3 = default and COLORS.ENABLED or COLORS.DISABLED
    toggle.Text = ""
    toggle.Parent = container
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UI_SETTINGS.CORNER_RADIUS
    toggleCorner.Parent = toggle
    
    local enabled = default or false
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.BackgroundColor3 = enabled and COLORS.ENABLED or COLORS.DISABLED
        callback(enabled)
    end)
    
    return container
end

function CensuraDev:CreateSlider(text, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Size = UI_SETTINGS.SLIDER_SIZE
    container.BackgroundColor3 = COLORS.ACCENT
    container.Parent = self.ContentFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UI_SETTINGS.CORNER_RADIUS
    corner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = COLORS.TEXT
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = container
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, -20, 0, 4)
    sliderBar.Position = UDim2.new(0, 10, 0.7, 0)
    sliderBar.BackgroundColor3 = COLORS.BACKGROUND
    sliderBar.Parent = container
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 2)
    sliderCorner.Parent = sliderBar
    
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
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("RunService").RenderStepped:Connect(function()
        if dragging then
            local mouse = game:GetService("UserInputService"):GetMouseLocation()
            local pos = (mouse.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
            pos = math.clamp(pos, 0, 1)
            value = min + ((max - min) * pos)
            sliderButton.Position = UDim2.new(pos, -8, 0.5, -8)
            callback(math.floor(value))
        end
    end)
    
    return container
end

function CensuraDev:Show()
    self.ScreenGui.Parent = CoreGui
    self.Visible = true
    self.MainFrame.Visible = true
end

function CensuraDev:Hide()
    self.Visible = false
    self.MainFrame.Visible = false
end

return CensuraDev
