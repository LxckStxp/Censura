--[[
    CensuraDev UI Library
    Version: 4.1
    Author: LxckStxp
    
    A modern, lightweight UI library for Roblox
    with optimized performance and enhanced features
]]

local CensuraDev = {}
CensuraDev.__index = CensuraDev

-- Services
local Services = {
    CoreGui = game:GetService("CoreGui"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService")
}

-- Constants
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Global Configuration
getgenv().CensuraSystem = {
    Colors = {
        Background = Color3.fromRGB(20, 20, 30),
        Accent = Color3.fromRGB(35, 35, 50),
        Text = Color3.fromRGB(240, 240, 245),
        Highlight = Color3.fromRGB(50, 50, 70),
        Enabled = Color3.fromRGB(98, 150, 255),
        Disabled = Color3.fromRGB(255, 75, 95),
        Border = Color3.fromRGB(60, 60, 80),
        SecondaryText = Color3.fromRGB(180, 180, 190)
    },
    UI = {
        WindowSize = UDim2.new(0, 300, 0, 400),
        TitleBarSize = UDim2.new(1, 0, 0, 40),
        ContentPadding = UDim2.new(0, 5, 0, 45),
        ButtonSize = UDim2.new(1, -16, 0, 36),
        ToggleSize = UDim2.new(0, 26, 0, 26),
        SliderSize = UDim2.new(1, -16, 0, 50),
        CornerRadius = UDim.new(0, 6),
        Padding = UDim.new(0, 8),
        ElementSpacing = UDim.new(0, 8),
        Transparency = {
            Background = 0.05,
            Accent = 0.08,
            Text = 0,
            Elements = 0.04
        }
    },
    Settings = {
        DefaultTitle = "Censura",
        ToggleKey = Enum.KeyCode.RightAlt,
        DragSpeed = 0.05,
        Version = "4.1"
    }
}

-- Load External Modules
local Components = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraComponents.lua"))()
local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraFunctions.lua"))()

-- Utility Functions
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

local function CreateTween(instance, properties)
    return Services.TweenService:Create(instance, TWEEN_INFO, properties)
end

-- Main Constructor
function CensuraDev.new(title, options)
    local self = setmetatable({}, CensuraDev)
    
    -- Initialize State
    self.Elements = {}
    self.Connections = {}
    self.Visible = true
    self.Title = title or CensuraSystem.Settings.DefaultTitle
    self.Options = options or {}
    
    -- Create UI
    self:Initialize()
    
    return self
end

-- Initialization
function CensuraDev:Initialize()
    self:CreateBaseGUI()
    self:SetupWindowBehavior()
    self:ApplyCustomOptions()
end

-- GUI Creation
function CensuraDev:CreateBaseGUI()
    -- ScreenGui
    self.GUI = Create("ScreenGui", {
        Name = "CensuraUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = Services.CoreGui
    })
    
    -- Main Container
    self.MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = CensuraSystem.UI.WindowSize,
        Position = UDim2.new(0.5, -150, 0.5, -200),
        BackgroundColor3 = CensuraSystem.Colors.Background,
        BackgroundTransparency = CensuraSystem.UI.Transparency.Background,
        Parent = self.GUI
    })
    
    Functions.setupWindow(self.MainFrame, {
        gradient = true,
        stroke = true,
        shadow = self.Options.shadow ~= false
    })
    
    -- Title Bar with Close Button
    self.TitleBar = Create("Frame", {
        Name = "TitleBar",
        Size = CensuraSystem.UI.TitleBarSize,
        BackgroundColor3 = CensuraSystem.Colors.Accent,
        BackgroundTransparency = CensuraSystem.UI.Transparency.Accent,
        Parent = self.MainFrame
    })
    
    Create("UICorner", {
        Parent = self.TitleBar,
        CornerRadius = CensuraSystem.UI.CornerRadius
    })
    
    -- Title Text
    self.TitleText = Create("TextLabel", {
        Text = self.Title,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = CensuraSystem.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        Parent = self.TitleBar
    })
    
    -- Content Container
    self.ContentFrame = Create("ScrollingFrame", {
        Name = "ContentFrame",
        Position = CensuraSystem.UI.ContentPadding,
        Size = UDim2.new(1, -10, 1, -50),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = CensuraSystem.Colors.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = self.MainFrame
    })
    
    -- Layout and Padding
    Create("UIListLayout", {
        Parent = self.ContentFrame,
        Padding = CensuraSystem.UI.ElementSpacing,
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })
    
    Create("UIPadding", {
        Parent = self.ContentFrame,
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8)
    })
end

-- Window Behavior Setup
function CensuraDev:SetupWindowBehavior()
    -- Dragging
    local dragHandler = Functions.setupDragging(self.TitleBar, self.MainFrame, {
        smoothing = CensuraSystem.Settings.DragSpeed,
        bounds = true
    })
    table.insert(self.Connections, dragHandler)
    
    -- Keybind
    local keybindHandler = Functions.setupKeybind(function()
        self:Toggle()
    end, self.Options.toggleKey or CensuraSystem.Settings.ToggleKey)
    table.insert(self.Connections, keybindHandler)
    
    -- Auto-cleanup
    self.GUI.Parent.ChildRemoved:Connect(function(child)
        if child == self.GUI then
            self:Cleanup()
        end
    end)
end

-- Custom Options
function CensuraDev:ApplyCustomOptions()
    if self.Options.position then
        Functions.setWindowPosition(self.MainFrame, self.Options.position)
    end
    
    if self.Options.scale then
        Functions.scaleUI(self.MainFrame, self.Options.scale, {smooth = true})
    end
end

-- Element Creation Methods
function CensuraDev:CreateButton(text, callback)
    assert(type(text) == "string", "Button text must be a string")
    assert(type(callback) == "function", "Button callback must be a function")
    
    local button = Components.createButton(self.ContentFrame, text, callback)
    table.insert(self.Elements, {Type = "Button", Instance = button})
    return button
end

function CensuraDev:CreateToggle(text, default, callback)
    assert(type(text) == "string", "Toggle text must be a string")
    assert(type(callback) == "function", "Toggle callback must be a function")
    
    local toggle = Components.createToggle(self.ContentFrame, text, default, callback)
    table.insert(self.Elements, {Type = "Toggle", Instance = toggle})
    return toggle
end

function CensuraDev:CreateSlider(text, min, max, default, callback)
    assert(type(text) == "string", "Slider text must be a string")
    assert(type(min) == "number", "Minimum value must be a number")
    assert(type(max) == "number", "Maximum value must be a number")
    assert(type(callback) == "function", "Slider callback must be a function")
    
    local slider = Components.createSlider(self.ContentFrame, text, min, max, default, callback)
    table.insert(self.Elements, {Type = "Slider", Instance = toggle})
    return slider
end

-- Visibility Methods
function CensuraDev:Show()
    if not self.Visible then
        self.Visible = true
        self.GUI.Enabled = true
    end
end

function CensuraDev:Hide()
    if self.Visible then
        self.Visible = false
        self.GUI.Enabled = false
    end
end

function CensuraDev:Toggle()
    if self.Visible then
        self:Hide()
    else
        self:Show()
    end
end

-- Cleanup Method
function CensuraDev:Cleanup()
    -- Cleanup connections
    for _, connection in ipairs(self.Connections) do
        if typeof(connection) == "table" and connection.Disconnect then
            connection:Disconnect()
        end
    end
    
    -- Cleanup elements
    for _, element in ipairs(self.Elements) do
        if element.Instance then
            element.Instance:Destroy()
        end
    end
    
    self.Elements = {}
    self.Connections = {}
    self.GUI:Destroy()
end

return CensuraDev
