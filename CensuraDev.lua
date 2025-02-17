--[[
    CensuraDev UI Library
    Version: 3.4
    Author: LxckStxp
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
        }
    }
}

-- Services
local CoreGui = game:GetService("CoreGui")

-- Load External Modules
local Components = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraComponents.lua"))()
local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraFunctions.lua"))()

-- Utility Function
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

-- Main UI Creation
function CensuraDev.new()
    local self = setmetatable({}, CensuraDev)
    
    -- Create ScreenGui
    self.GUI = Create("ScreenGui", {
        Name = "CensuraUI",
        ResetOnSpawn = false,
        Parent = CoreGui
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
    
    Create("TextLabel", {
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
    
    self.Visible = true
    return self
end

-- UI Element Creation Methods
function CensuraDev:CreateButton(text, callback)
    return Components.createButton(self.ContentFrame, text, callback)
end

function CensuraDev:CreateToggle(text, default, callback)
    return Components.createToggle(self.ContentFrame, text, default, callback)
end

function CensuraDev:CreateSlider(text, min, max, default, callback)
    return Components.createSlider(self.ContentFrame, text, min, max, default, callback)
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

return CensuraDev
