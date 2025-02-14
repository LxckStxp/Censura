--[[
    Censura UI System v2.0.0
    Author: LxckStxp
    Condensed by: [Your Name]
    A lightweight UI framework for Roblox exploits
]]

-- Services
local Services = {
    TweenService = game:GetService("TweenService"),
    UserInput = game:GetService("UserInputService"),
    Players = game:GetService("Players"),
    CoreGui = game:GetService("CoreGui")
}

-- Create Core Framework
local Censura = {
    Version = "2.0.0",
    Windows = {},
    Config = {
        ToggleKey = Enum.KeyCode.RightControl,
        Theme = {
            Background = Color3.fromRGB(25, 25, 25),
            Primary = Color3.fromRGB(0, 170, 255),
            Text = Color3.fromRGB(255, 255, 255),
            Success = Color3.fromRGB(0, 255, 100),
            Error = Color3.fromRGB(255, 50, 50),
            Highlight = Color3.fromRGB(255, 255, 255)
        },
        Fonts = {
            Header = Enum.Font.GothamBold,
            Text = Enum.Font.Gotham,
            Size = {
                Header = 16,
                Text = 14
            }
        },
        Animation = {
            Short = TweenInfo.new(0.2),
            Long = TweenInfo.new(0.5)
        }
    },
    Active = {
        Elements = {},
        Connections = {}
    }
}

-- Utility Functions
local Utility = {
    CreateCorner = function(instance, radius)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = radius or UDim.new(0, 6)
        corner.Parent = instance
        return corner
    end,
    
    Connect = function(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(Censura.Active.Connections, connection)
        return connection
    end
}

-- Add MakeDraggable separately to avoid self-reference
function Utility.MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    
    -- Store connections
    local connections = {}
    
    -- Input Begin
    local beginConnection = handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    table.insert(Censura.Active.Connections, beginConnection)
    
    -- Input Changed
    local changeConnection = Services.UserInput.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    table.insert(Censura.Active.Connections, changeConnection)
    
    -- Input End
    local endConnection = Services.UserInput.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    table.insert(Censura.Active.Connections, endConnection)
    
    -- Return connections for cleanup if needed
    return {
        BeginConnection = beginConnection,
        ChangeConnection = changeConnection,
        EndConnection = endConnection
    }
end

-- Component Creation Functions
local Components = {
    CreateToggle = function(options)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 30)
        container.BackgroundTransparency = 1
        container.Parent = options.parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -50, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = options.label
        label.TextColor3 = Censura.Config.Theme.Text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Censura.Config.Fonts.Text
        label.TextSize = Censura.Config.Fonts.Size.Text
        label.Parent = container
        
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0, 40, 0, 20)
        button.Position = UDim2.new(1, -40, 0.5, -10)
        button.BackgroundColor3 = Censura.Config.Theme.Error
        button.Text = ""
        button.Parent = container
        Utility.CreateCorner(button, UDim.new(1, 0))
        
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 16, 0, 16)
        circle.Position = UDim2.new(0, 2, 0.5, -8)
        circle.BackgroundColor3 = Censura.Config.Theme.Highlight
        circle.Parent = button
        Utility.CreateCorner(circle, UDim.new(1, 0))
        
        local toggled = false
        button.MouseButton1Click:Connect(function()
            toggled = not toggled
            
            Services.TweenService:Create(button, 
                Censura.Config.Animation.Short,
                {BackgroundColor3 = toggled and Censura.Config.Theme.Success or Censura.Config.Theme.Error}
            ):Play()
            
            Services.TweenService:Create(circle,
                Censura.Config.Animation.Short,
                {Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}
            ):Play()
            
            if options.callback then
                options.callback(toggled)
            end
        end)
        
        return {
            Instance = container,
            SetValue = function(value)
                toggled = value
                button.BackgroundColor3 = value and Censura.Config.Theme.Success or Censura.Config.Theme.Error
                circle.Position = value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            end
        }
    end,
    
CreateSlider = function(options)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 45)
    container.BackgroundTransparency = 1
    container.Parent = options.parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = options.label
    label.TextColor3 = Censura.Config.Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Censura.Config.Fonts.Text
    label.TextSize = Censura.Config.Fonts.Size.Text
    label.Parent = container
    
    -- Create an interaction frame
    local interactionFrame = Instance.new("TextButton")
    interactionFrame.Position = UDim2.new(0, 0, 0, 25)
    interactionFrame.Size = UDim2.new(1, 0, 0, 20) -- Made taller for easier interaction
    interactionFrame.BackgroundTransparency = 1
    interactionFrame.Text = ""
    interactionFrame.Parent = container
    
    local sliderBG = Instance.new("Frame")
    sliderBG.Position = UDim2.new(0, 0, 0.5, -2)
    sliderBG.Size = UDim2.new(1, 0, 0, 4)
    sliderBG.BackgroundColor3 = Censura.Config.Theme.Background
    sliderBG.Parent = interactionFrame
    Utility.CreateCorner(sliderBG, UDim.new(1, 0))
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Censura.Config.Theme.Primary
    fill.Parent = sliderBG
    Utility.CreateCorner(fill, UDim.new(1, 0))
    
    -- Add slider knob
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, -8, 0.5, -8)
    knob.BackgroundColor3 = Censura.Config.Theme.Primary
    knob.Parent = fill
    Utility.CreateCorner(knob, UDim.new(1, 0))
    
    -- Add value label
    local value = Instance.new("TextLabel")
    value.Position = UDim2.new(1, -45, 0, 0)
    value.Size = UDim2.new(0, 45, 0, 20)
    value.BackgroundTransparency = 1
    value.Text = tostring(options.default or 0)
    value.TextColor3 = Censura.Config.Theme.Text
    value.Font = Censura.Config.Fonts.Text
    value.TextSize = Censura.Config.Fonts.Size.Text
    value.Parent = container
    
    local dragging = false
    local function updateValue(input)
        local pos = input.Position.X
        local sliderPos = sliderBG.AbsolutePosition.X
        local sliderSize = sliderBG.AbsoluteSize.X
        
        local relative = math.clamp((pos - sliderPos) / sliderSize, 0, 1)
        local newValue = math.floor(options.min + (options.max - options.min) * relative)
        
        value.Text = tostring(newValue)
        fill.Size = UDim2.new(relative, 0, 1, 0)
        
        if options.callback then
            options.callback(newValue)
        end
    end
    
    -- Connect interaction frame instead of sliderBG
    Utility.Connect(interactionFrame.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateValue(input)
        end
    end)
    
    Utility.Connect(Services.UserInput.InputChanged, function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateValue(input)
        end
    end)
    
    Utility.Connect(Services.UserInput.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Set initial value if provided
    if options.default then
        local relative = (options.default - options.min) / (options.max - options.min)
        fill.Size = UDim2.new(relative, 0, 1, 0)
        value.Text = tostring(options.default)
    end
    
    return {
        Instance = container,
        SetValue = function(newValue)
            local relative = (newValue - options.min) / (options.max - options.min)
            value.Text = tostring(math.floor(newValue))
            fill.Size = UDim2.new(relative, 0, 1, 0)
        end
    }
end,
    
    CreateButton = function(options)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 32)
        button.BackgroundColor3 = Censura.Config.Theme.Primary
        button.Text = options.label
        button.TextColor3 = Censura.Config.Theme.Text
        button.Font = Censura.Config.Fonts.Text
        button.TextSize = Censura.Config.Fonts.Size.Text
        button.Parent = options.parent
        Utility.CreateCorner(button)
        
        button.MouseButton1Click:Connect(function()
            Services.TweenService:Create(button,
                Censura.Config.Animation.Short,
                {BackgroundColor3 = Censura.Config.Theme.Highlight}
            ):Play()
            
            if options.callback then
                options.callback()
            end
            
            task.wait(0.2)
            Services.TweenService:Create(button,
                Censura.Config.Animation.Short,
                {BackgroundColor3 = Censura.Config.Theme.Primary}
            ):Play()
        end)
        
        return {
            Instance = button
        }
    end
}

-- Window Creation
function Censura:CreateWindow(options)
    local window = {
        Elements = {},
        Visible = true
    }
    
    -- Create window frame
    window.Frame = Instance.new("Frame")
    window.Frame.Name = options.title or "Window"
    window.Frame.Size = options.size or UDim2.new(0, 300, 0, 400)
    window.Frame.Position = options.position or UDim2.new(0.5, -150, 0.5, -200)
    window.Frame.BackgroundColor3 = self.Config.Theme.Background
    window.Frame.BorderSizePixel = 0
    window.Frame.Parent = self.GUI
    Utility.CreateCorner(window.Frame)
    
    -- Create header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = self.Config.Theme.Primary
    header.BorderSizePixel = 0
    header.Parent = window.Frame
    Utility.CreateCorner(header)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = options.title or "Window"
    title.TextColor3 = self.Config.Theme.Text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = self.Config.Fonts.Header
    title.TextSize = self.Config.Fonts.Size.Header
    title.Parent = header
    
    -- Create content container
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -20, 1, -40)
    content.Position = UDim2.new(0, 10, 0, 35)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 2
    content.Parent = window.Frame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = content
    
    -- Make window draggable
    Utility.MakeDraggable(window.Frame, header)
    
    -- Window methods
    function window:AddToggle(options)
        options.parent = content
        local toggle = Components.CreateToggle(options)
        table.insert(self.Elements, toggle)
        return toggle
    end
    
    function window:AddSlider(options)
        options.parent = content
        local slider = Components.CreateSlider(options)
        table.insert(self.Elements, slider)
        return slider
    end
    
    function window:AddButton(options)
        options.parent = content
        local button = Components.CreateButton(options)
        table.insert(self.Elements, button)
        return button
    end
    
    function window:Toggle()
        self.Visible = not self.Visible
        self.Frame.Visible = self.Visible
    end
    
    table.insert(self.Windows, window)
    return window
end

-- Initialize
local function Initialize()
    -- Create GUI
    Censura.GUI = Instance.new("ScreenGui")
    Censura.GUI.Name = "CensuraGUI"
    Censura.GUI.ResetOnSpawn = false
    
    -- Parent GUI
    pcall(function()
        Censura.GUI.Parent = Services.CoreGui
    end)
    
    if not Censura.GUI.Parent then
        Censura.GUI.Parent = Services.Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Setup toggle
    Utility.Connect(Services.UserInput.InputBegan, function(input)
        if input.KeyCode == Censura.Config.ToggleKey then
            for _, window in ipairs(Censura.Windows) do
                window:Toggle()
            end
        end
    end)
end

-- Cleanup
function Censura:Destroy()
    for _, connection in ipairs(self.Active.Connections) do
        connection:Disconnect()
    end
    if self.GUI then
        self.GUI:Destroy()
    end
end

-- Initialize and return
Initialize()
return Censura
