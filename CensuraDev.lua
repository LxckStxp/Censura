--[[
    CensuraDev UI Library
    Version: 3.3
    Author: LxckStxp
    
    A modern, modular UI library for Roblox exploits
    featuring smooth animations and easy customization.
--]]

local CensuraDev = {}
CensuraDev.__index = CensuraDev

-- Initialize Global System
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
        },
        
        TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
    }
}

-- Services
local Services = {
    CoreGui = game:GetService("CoreGui"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService")
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

-- Element Class
local UIElement = {}
UIElement.__index = UIElement

function UIElement.new(elementType, instance, properties)
    local self = setmetatable({}, UIElement)
    self.Type = elementType
    self.Instance = instance
    self.Properties = properties
    self.StyleData = {}
    return self
end

function UIElement:ApplyStyle()
    for object, properties in pairs(self.StyleData) do
        for property, value in pairs(properties) do
            object[property] = value
        end
    end
end

-- Main UI Creation
function CensuraDev.new()
    local self = setmetatable({}, CensuraDev)
    
    self.Elements = {}
    self.Visible = true
    
    -- Create ScreenGui
    self.GUI = Create("ScreenGui", {
        Name = "CensuraUI",
        ResetOnSpawn = false,
        Parent = Services.CoreGui
    })
    
    -- Create Main Frame
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
    
    -- Create Title Bar
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
        Text = "Censura",
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
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    -- Initialize Window Functionality
    Functions.setupDragging(self.TitleBar, self.MainFrame)
    Functions.setupKeybind(function()
        self:Toggle()
    end)
    
    return self
end

function CensuraDev:CreateButton(text, callback)
    local button = Components.createButton(self.ContentFrame, text, callback)
    local element = UIElement.new("Button", button, {
        Text = text,
        Callback = callback
    })
    
    element.StyleData = {
        [button] = {
            BackgroundColor3 = CensuraSystem.Colors.Accent,
            BackgroundTransparency = CensuraSystem.UI.Transparency.Elements
        },
        [button:FindFirstChild("TextLabel")] = {
            TextColor3 = CensuraSystem.Colors.Text
        }
    }
    
    table.insert(self.Elements, element)
    element:ApplyStyle()
    return element
end

function CensuraDev:CreateToggle(text, default, callback)
    local toggle = Components.createToggle(self.ContentFrame, text, default, callback)
    local element = UIElement.new("Toggle", toggle, {
        Text = text,
        Enabled = default,
        Callback = callback
    })
    
    element.StyleData = {
        [toggle] = {
            BackgroundColor3 = CensuraSystem.Colors.Accent,
            BackgroundTransparency = CensuraSystem.UI.Transparency.Elements
        },
        [toggle:FindFirstChild("TextLabel")] = {
            TextColor3 = CensuraSystem.Colors.Text
        },
        [toggle:FindFirstChild("Indicator")] = {
            BackgroundColor3 = default and CensuraSystem.Colors.Enabled or CensuraSystem.Colors.Disabled
        }
    }
    
    table.insert(self.Elements, element)
    element:ApplyStyle()
    return element
end

function CensuraDev:CreateSlider(text, min, max, default, callback)
    local slider = Components.createSlider(self.ContentFrame, text, min, max, default, callback)
    local element = UIElement.new("Slider", slider, {
        Text = text,
        Min = min,
        Max = max,
        Value = default,
        Callback = callback
    })
    
    element.StyleData = {
        [slider] = {
            BackgroundColor3 = CensuraSystem.Colors.Accent,
            BackgroundTransparency = CensuraSystem.UI.Transparency.Elements
        },
        [slider:FindFirstChild("TextLabel")] = {
            TextColor3 = CensuraSystem.Colors.Text
        },
        [slider:FindFirstChild("SliderBar")] = {
            BackgroundColor3 = CensuraSystem.Colors.Enabled
        }
    }
    
    table.insert(self.Elements, element)
    element:ApplyStyle()
    return element
end

function CensuraDev:RefreshStyles()
    for _, element in ipairs(self.Elements) do
        element:ApplyStyle()
    end
end

function CensuraDev:Show()
    self.Visible = true
    self.GUI.Enabled = true
    self:RefreshStyles()
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

return CensuraDev
