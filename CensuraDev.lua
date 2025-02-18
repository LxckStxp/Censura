--[[
    CensuraDev UI Library
    Version: 4.3
    A lightweight, performant UI library for Roblox
]]

-- Core Setup
local CensuraDev = {}
CensuraDev.__index = CensuraDev

-- Services
local Services = {
    CoreGui = game:GetService("CoreGui"),
    UserInput = game:GetService("UserInputService"),
    Tween = game:GetService("TweenService"),
    Run = game:GetService("RunService")
}

-- Load External Dependencies
local Components = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraComponents.lua"))()
local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraFunctions.lua"))()

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
        ToggleKey = Enum.KeyCode.RightAlt
    }
}

-- Utility Functions
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

-- Constructor
function CensuraDev.new(title, options)
    local self = setmetatable({}, CensuraDev)
    
    self.Elements = {}
    self.Connections = {}
    self.Title = title or "Censura"
    self.Options = options or {}
    self.Visible = true
    
    self:Initialize()
    return self
end

-- GUI Creation and Setup
function CensuraDev:Initialize()
    -- Create ScreenGui
    self.GUI = Create("ScreenGui", {
        Name = "CensuraUI",
        ResetOnSpawn = false,
        Parent = Services.CoreGui
    })
    
    -- Create Main Window
    self.MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = CensuraSystem.UI.WindowSize,
        Position = UDim2.new(0.5, -150, 0.5, -200),
        BackgroundColor3 = CensuraSystem.Colors.Background,
        BackgroundTransparency = CensuraSystem.UI.Transparency.Background,
        Parent = self.GUI
    })
    
    -- Apply Window Styling
    Functions.setupWindow(self.MainFrame, {
        gradient = true,
        stroke = true,
        shadow = self.Options.shadow ~= false
    })
    
    -- Create Title Bar
    self.TitleBar = Create("Frame", {
        Name = "TitleBar",
        Size = CensuraSystem.UI.TitleBarSize,
        BackgroundColor3 = CensuraSystem.Colors.Accent,
        BackgroundTransparency = CensuraSystem.UI.Transparency.Accent,
        Parent = self.MainFrame
    })
    
    Create("UICorner", {
        CornerRadius = CensuraSystem.UI.CornerRadius,
        Parent = self.TitleBar
    })
    
    -- Create Title Text
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
    
    -- Create Content Container
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
    
    -- Setup Content Layout
    Create("UIListLayout", {
        Padding = CensuraSystem.UI.ElementSpacing,
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = self.ContentFrame
    })
    
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        Parent = self.ContentFrame
    })
    
    -- Setup Window Behavior
    self:SetupBehavior()
end

-- Window Behavior Setup
function CensuraDev:SetupBehavior()
    -- Window Dragging
    local dragHandler = Functions.setupDragging(self.TitleBar, self.MainFrame, {
        smoothing = 0.05,
        bounds = true
    })
    table.insert(self.Connections, dragHandler)
    
    -- Toggle Visibility Keybind
    if self.Options.toggleKey then
        local keybindHandler = Functions.setupKeybind(function()
            self:Toggle()
        end, self.Options.toggleKey)
        table.insert(self.Connections, keybindHandler)
    end
end

-- Element Creation Methods
function CensuraDev:CreateButton(text, callback)
    local button = Components.createButton(self.ContentFrame, text, callback)
    if button then
        table.insert(self.Elements, button)
    end
    return button
end

function CensuraDev:CreateToggle(text, default, callback)
    local toggle = Components.createToggle(self.ContentFrame, text, default, callback)
    if toggle then
        table.insert(self.Elements, toggle)
    end
    return toggle
end

function CensuraDev:CreateSlider(text, min, max, default, callback)
    local slider = Components.createSlider(self.ContentFrame, text, min, max, default, callback)
    if slider then
        table.insert(self.Elements, slider)
    end
    return slider
end

-- Visibility Methods
function CensuraDev:Show()
    self.Visible = true
    self.GUI.Enabled = true
end

function CensuraDev:Hide()
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
    for _, connection in pairs(self.Connections) do
        if typeof(connection) == "table" and connection.Disconnect then
            connection:Disconnect()
        end
    end
    
    for _, element in pairs(self.Elements) do
        if element then
            element:Destroy()
        end
    end
    
    if self.GUI then
        self.GUI:Destroy()
    end
    
    self.Elements = {}
    self.Connections = {}
end

return CensuraDev
