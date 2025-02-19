--[[
    CensuraDev UI Library
    Version: 4.2

    Modern, minimal UI library for Roblox games
    with optimized performance and military-tech inspired styling
]]

local CensuraDev = {}
CensuraDev.__index = CensuraDev

-- Services
local Services = {
    CoreGui = game:GetService("CoreGui"),
    UserInput = game:GetService("UserInputService"),
    Tween = game:GetService("TweenService")
}

-- Load Dependencies
local Styles = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraStyles.lua"))()
local Components = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraComponents.lua"))()
local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraFunctions.lua"))()
local Animations = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraAnimations.lua"))()

-- Initialize Styles
Styles.initialize()

-- Utility function
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

-- Constructor
function CensuraDev.new(title)
    local self = setmetatable({}, CensuraDev)
    local System = getgenv().CensuraSystem

    -- Initialize UI
    self.GUI = Create("ScreenGui", {
        Name = "CensuraUI",
        ResetOnSpawn = false,
        Parent = Services.CoreGui
    })
    
    -- Main Window
    self.MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = System.UI.WindowSize,
        Position = UDim2.new(0.5, -150, 0.5, -200),
        BackgroundColor3 = System.Colors.Background,
        BackgroundTransparency = 0.2, -- Less transparent
        Parent = self.GUI
    })
    
    -- Minimal corners
    Create("UICorner", {
        CornerRadius = UDim.new(0, 2),
        Parent = self.MainFrame
    })
    
    -- Main frame stroke
    local mainStroke = Styles.createStroke(System.Colors.Border, 0.6, 1)
    mainStroke.Parent = self.MainFrame
    
    -- Title Bar
    self.TitleBar = Create("Frame", {
        Name = "TitleBar",
        Size = System.UI.TitleBarSize,
        BackgroundColor3 = System.Colors.Background,
        BackgroundTransparency = 0.15, -- Slightly more solid than main frame
        Parent = self.MainFrame
    })
    
    -- Apply animated gradient to TitleBar
    local titleGradient = Animations.createAnimatedGradient({
        StartColor = System.Colors.Accent,
        EndColor = System.Colors.Background,
        Rotation = 90
    })
    titleGradient.Parent = self.TitleBar
    
    -- Title Text
    self.TitleText = Create("TextLabel", {
        Text = title or System.Settings.DefaultTitle,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = System.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Parent = self.TitleBar
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 2),
        Parent = self.TitleBar
    })
    
    -- Content Container
    self.ContentFrame = Create("ScrollingFrame", {
        Name = "ContentFrame",
        Position = System.UI.ContentPadding,
        Size = UDim2.new(1, -10, 1, -50),
        BackgroundTransparency = 1,
        ScrollBarThickness = 1,
        ScrollBarImageColor3 = System.Colors.Accent,
        ScrollBarImageTransparency = 0.3, -- More visible scrollbar
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = self.MainFrame
    })
    
    -- Content Layout
    Create("UIListLayout", {
        Parent = self.ContentFrame,
        Padding = System.UI.ElementSpacing,
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })
    
    Create("UIPadding", {
        Parent = self.ContentFrame,
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6)
    })
    
    -- Setup dragging
    Functions.makeDraggable(self.TitleBar, self.MainFrame)
    
    -- Hover effects using Animations module
    self.TitleBar.MouseEnter:Connect(function()
        Animations.applyHoverState(self.TitleBar, mainStroke)
    end)
    
    self.TitleBar.MouseLeave:Connect(function()
        Animations.removeHoverState(self.TitleBar, mainStroke)
    end)
    
    -- Toggle Visibility
    self.Visible = true
    self.KeybindConnection = Services.UserInput.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == System.Settings.ToggleKey then
            self:Toggle()
        end
    end)
    
    return self
end

-- UI Element Creation Methods (unchanged)
function CensuraDev:CreateButton(text, callback)
    assert(type(text) == "string", "Button text must be a string")
    assert(type(callback) == "function", "Button callback must be a function")
    return Components.createButton(self.ContentFrame, text, callback)
end

function CensuraDev:CreateToggle(text, default, callback)
    assert(type(text) == "string", "Toggle text must be a string")
    assert(type(callback) == "function", "Toggle callback must be a function")
    return Components.createToggle(self.ContentFrame, text, default, callback)
end

function CensuraDev:CreateSlider(text, min, max, default, callback)
    assert(type(text) == "string", "Slider text must be a string")
    assert(type(min) == "number", "Minimum value must be a number")
    assert(type(max) == "number", "Maximum value must be a number")
    assert(type(callback) == "function", "Slider callback must be a function")
    return Components.createSlider(self.ContentFrame, text, min, max, default, callback)
end

-- Visibility Methods using Animations module
function CensuraDev:Show()
    self.Visible = true
    self.GUI.Enabled = true
    Animations.showWindow(self.MainFrame)
end

function CensuraDev:Hide()
    local hideTween = Animations.hideWindow(self.MainFrame)
    hideTween.Completed:Wait()
    self.Visible = false
    self.GUI.Enabled = false
end

function CensuraDev:Toggle()
    if self.Visible then
        self:Hide()
    else
        self:Show()
    end
end

-- Cleanup Method
function CensuraDev:Destroy()
    if self.KeybindConnection then
        self.KeybindConnection:Disconnect()
    end
    if self.GUI then
        self.GUI:Destroy()
    end
end

return CensuraDev
