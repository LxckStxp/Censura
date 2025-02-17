--[[
    CensuraDev UI Library
    Version: 4.0
    Author: LxckStxp
    
    A lightweight, efficient UI library for Roblox exploits
]]

local CensuraDev = {}
CensuraDev.__index = CensuraDev

-- Initialize Services
local Services = {
    CoreGui = game:GetService("CoreGui"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService")
}

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
            Background = 0.15,
            Accent = 0.08,
            Text = 0,
            Elements = 0.04
        }
    },
    Keybind = Enum.KeyCode.RightAlt,
    Version = "4.0"
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

-- Main Library Constructor
function CensuraDev.new(title)
    local self = setmetatable({}, CensuraDev)
    
    -- Initialize State
    self.Elements = {}
    self.Visible = true
    self.Dragging = false
    self.Title = title or "Censura"
    
    -- Create Base GUI
    self:CreateBaseGUI()
    
    -- Setup Window Functionality
    self:SetupWindowBehavior()
    
    return self
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
    
    -- Apply Window Styling
    Functions.setupWindow(self.MainFrame)
    
    -- Title Bar
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
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = CensuraSystem.Colors.Text,
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
    Functions.setupDragging(self.TitleBar, self.MainFrame)
    
    -- Keybind
    Functions.setupKeybind(function()
        self:Toggle()
    end)
    
    -- Auto-cleanup
    self.GUI.Parent.ChildRemoved:Connect(function(child)
        if child == self.GUI then
            self:Cleanup()
        end
    end)
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
    table.insert(self.Elements, {Type = "Slider", Instance = slider})
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
    for _, element in ipairs(self.Elements) do
        if element.Instance then
            element.Instance:Destroy()
        end
    end
    
    self.Elements = {}
    self.GUI:Destroy()
end

return CensuraDev
