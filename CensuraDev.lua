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
local function LoadDependency(url)
    local success, result = pcall(game.HttpGet, game, url)
    if success then
        return loadstring(result)()
    end
    warn("Failed to load dependency:", url)
    return nil
end

local Styles = LoadDependency("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraStyles.lua")


-- Initialize Styles
assert(Styles and Styles.initialize, "Failed to initialize Styles module")
Styles.initialize()

local Components = LoadDependency("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraComponents.lua")
local Functions = LoadDependency("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraFunctions.lua")
local Animations = LoadDependency("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraAnimations.lua")

-- Window Management
local ActiveWindows = {}

-- Utility Functions
local function Create(className, properties)
    assert(type(className) == "string", "className must be a string")
    assert(type(properties) == "table", "properties must be a table")
    
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

local function CreateMainWindow(parent, system)
    local mainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = system.UI.WindowSize,
        Position = UDim2.new(0.5, -150, 0.5, -200),
        BackgroundColor3 = system.Colors.Background,
        BackgroundTransparency = 0.2,
        Parent = parent
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 2),
        Parent = mainFrame
    })
    
    local mainStroke = Styles.createStroke(system.Colors.Border, 0.6, 0.5)
    mainStroke.Parent = mainFrame
    
    return mainFrame, mainStroke
end

local function CreateTitleBar(parent, system, title)
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        Size = system.UI.TitleBarSize,
        BackgroundColor3 = system.Colors.Background,
        BackgroundTransparency = system.UI.Transparency.TitleBar,
        Parent = parent
    })
    
    local titleGradient = Animations.createAnimatedGradient({
        StartColor = system.Colors.Accent,
        EndColor = system.Colors.Background,
        Rotation = 90
    })
    titleGradient.Parent = titleBar
    
    local titleText = Create("TextLabel", {
        Text = title,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = system.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Parent = titleBar
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 2),
        Parent = titleBar
    })
    
    return titleBar, titleText
end

local function CreateContentFrame(parent, system)
    local contentFrame = Create("ScrollingFrame", {
        Name = "ContentFrame",
        Position = system.UI.ContentPadding,
        Size = UDim2.new(1, -10, 1, -50),
        BackgroundTransparency = 1,
        ScrollBarThickness = 1,
        ScrollBarImageColor3 = system.Colors.Accent,
        ScrollBarImageTransparency = 0.3,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = parent
    })
    
    Create("UIListLayout", {
        Parent = contentFrame,
        Padding = system.UI.ElementSpacing,
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })
    
    Create("UIPadding", {
        Parent = contentFrame,
        PaddingLeft = system.UI.Padding,
        PaddingRight = system.UI.Padding,
        PaddingTop = system.UI.Padding,
        PaddingBottom = system.UI.Padding
    })
    
    return contentFrame
end

-- Constructor
function CensuraDev.new(title)
    assert(type(title) == "string" or title == nil, "Title must be a string or nil")
    
    local self = setmetatable({}, CensuraDev)
    local System = getgenv().CensuraSystem
    
    self.GUI = Create("ScreenGui", {
        Name = "CensuraUI",
        ResetOnSpawn = false,
        Parent = Services.CoreGui
    })
    
    self.MainFrame, self.MainStroke = CreateMainWindow(self.GUI, System)
    self.TitleBar, self.TitleText = CreateTitleBar(self.MainFrame, System, title or System.Settings.DefaultTitle)
    self.ContentFrame = CreateContentFrame(self.MainFrame, System)
    
    Functions.makeDraggable(self.TitleBar, self.MainFrame)
    
    self.TitleBar.MouseEnter:Connect(function()
        Animations.applyHoverState(self.TitleBar, self.MainStroke)
    end)
    
    self.TitleBar.MouseLeave:Connect(function()
        Animations.removeHoverState(self.TitleBar, self.MainStroke)
    end)
    
    self.Visible = true
    self.KeybindConnection = Services.UserInput.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == System.Settings.ToggleKey then
            self:Toggle()
        end
    end)
    
    table.insert(ActiveWindows, self)
    
    return self
end

-- UI Element Creation Methods
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

-- Window Management Methods
function CensuraDev.HideAll()
    for _, window in ipairs(ActiveWindows) do
        if window.Visible then
            window:Hide()
        end
    end
end

function CensuraDev.ShowAll()
    for _, window in ipairs(ActiveWindows) do
        if not window.Visible then
            window:Show()
        end
    end
end

function CensuraDev.DestroyAll()
    for _, window in ipairs(ActiveWindows) do
        window:Destroy()
    end
    table.clear(ActiveWindows)
end

-- Visibility Methods
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

-- Cleanup
function CensuraDev:Destroy()
    if self.KeybindConnection then
        self.KeybindConnection:Disconnect()
    end
    if self.GUI then
        self.GUI:Destroy()
    end
    
    for i, window in ipairs(ActiveWindows) do
        if window == self then
            table.remove(ActiveWindows, i)
            break
        end
    end
end

return CensuraDev
