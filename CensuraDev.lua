--[[
    Censura UI System v2.0.0
    Author: LxckStxp
    A lightweight UI framework for Roblox exploits
]]

-- Create Core Framework
local Censura = {}

-- Initialize core components before anything else
do
    -- Services
    Censura.Services = {
        TweenService = game:GetService("TweenService"),
        UserInput = game:GetService("UserInputService"),
        Players = game:GetService("Players"),
        CoreGui = game:GetService("CoreGui")
    }
    
    -- Core properties
    Censura.Version = "2.0.0"
    Censura.Windows = {}
    Censura.Config = {
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
    }
    Censura.Active = {
        Elements = {},
        Connections = {}
    }
end

-- Load Components
do
    -- First, load the components script
    local componentsSource = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraComponents.lua"))()
    
    -- Create a temporary function environment
    local env = {
        Censura = Censura,
        game = game,
        Instance = Instance,
        UDim2 = UDim2,
        UDim = UDim,
        Color3 = Color3,
        Enum = Enum,
        table = table,
        math = math,
        task = task
    }
    
    -- Load components into our environment
    local componentsFunc = loadstring(componentsSource)
    setfenv(componentsFunc, env)
    
    -- Execute and store components
    Censura.Components = componentsFunc()
end

-- Utility Functions
Censura.Utility = {
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
    end,
    
    MakeDraggable = function(frame, handle)
        local dragging, dragInput, dragStart, startPos
        
        local beginConnection = handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
            end
        end)
        table.insert(Censura.Active.Connections, beginConnection)
        
        local changeConnection = Censura.Services.UserInput.InputChanged:Connect(function(input)
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
        
        local endConnection = Censura.Services.UserInput.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        table.insert(Censura.Active.Connections, endConnection)
        
        return {
            BeginConnection = beginConnection,
            ChangeConnection = changeConnection,
            EndConnection = endConnection
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
    self.Utility.CreateCorner(window.Frame)
    
    -- Create header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = self.Config.Theme.Primary
    header.BorderSizePixel = 0
    header.Parent = window.Frame
    self.Utility.CreateCorner(header)
    
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
    self.Utility.MakeDraggable(window.Frame, header)
    
    -- Window methods
    function window:AddToggle(options)
        options.parent = content
        local toggle = Censura.Components.CreateToggle(options)
        table.insert(self.Elements, toggle)
        return toggle
    end
    
    function window:AddSlider(options)
        options.parent = content
        local slider = Censura.Components.CreateSlider(options)
        table.insert(self.Elements, slider)
        return slider
    end
    
    function window:AddButton(options)
        options.parent = content
        local button = Censura.Components.CreateButton(options)
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
        Censura.GUI.Parent = Censura.Services.CoreGui
    end)
    
    if not Censura.GUI.Parent then
        Censura.GUI.Parent = Censura.Services.Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Setup toggle
    Censura.Utility.Connect(Censura.Services.UserInput.InputBegan, function(input)
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
