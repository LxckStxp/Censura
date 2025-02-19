--[[
    CensuraDev UI Library
    Version: 4.1

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
    
    -- Main Window with modern styling
    self.MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = System.UI.WindowSize,
        Position = UDim2.new(0.5, -150, 0.5, -200),
        BackgroundColor3 = System.Colors.Background,
        BackgroundTransparency = 0.1,
        Parent = self.GUI
    })
    
    -- Apply minimal corner radius
    Create("UICorner", {
        CornerRadius = UDim.new(0, 2),
        Parent = self.MainFrame
    })
    
    -- Add subtle stroke to main frame
    local mainStroke = Create("UIStroke", {
        Color = System.Colors.Border,
        Transparency = 0.7,
        Thickness = 1,
        Parent = self.MainFrame
    })
    
    -- Title Bar with minimal design
    self.TitleBar = Create("Frame", {
        Name = "TitleBar",
        Size = System.UI.TitleBarSize,
        BackgroundColor3 = System.Colors.Background,
        BackgroundTransparency = 0.1,
        Parent = self.MainFrame
    })
    
    -- Apply gradient and stroke to TitleBar
    Styles.applyGradient(self.TitleBar, 90)
    
    -- Modern minimal title text
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
    
    -- Minimal corner radius for TitleBar
    Create("UICorner", {
        CornerRadius = UDim.new(0, 2),
        Parent = self.TitleBar
    })
    
    -- Content Container with clean styling
    self.ContentFrame = Create("ScrollingFrame", {
        Name = "ContentFrame",
        Position = System.UI.ContentPadding,
        Size = UDim2.new(1, -10, 1, -50),
        BackgroundTransparency = 1,
        ScrollBarThickness = 1, -- Thinner scrollbar
        ScrollBarImageColor3 = System.Colors.Accent,
        ScrollBarImageTransparency = 0.5,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = self.MainFrame
    })
    
    -- Clean content layout
    Create("UIListLayout", {
        Parent = self.ContentFrame,
        Padding = System.UI.ElementSpacing,
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })
    
    -- Adjusted padding for cleaner spacing
    Create("UIPadding", {
        Parent = self.ContentFrame,
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6)
    })
    
    -- Setup dragging with smooth animation
    Functions.makeDraggable(self.TitleBar, self.MainFrame)
    
    -- Add hover effect to TitleBar
    self.TitleBar.MouseEnter:Connect(function()
        Services.Tween:Create(mainStroke, System.Animation.TweenInfo, {
            Transparency = 0.5
        }):Play()
    end)
    
    self.TitleBar.MouseLeave:Connect(function()
        Services.Tween:Create(mainStroke, System.Animation.TweenInfo, {
            Transparency = 0.7
        }):Play()
    end)
    
    -- Toggle Visibility with fade animation
    self.Visible = true
    self.KeybindConnection = Services.UserInput.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == System.Settings.ToggleKey then
            self:Toggle()
        end
    end)
    
    return self
end

-- UI Element Creation Methods (unchanged for compatibility)
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

-- Enhanced visibility methods with smooth transitions
function CensuraDev:Show()
    self.Visible = true
    self.GUI.Enabled = true
    
    -- Fade in with slight scale animation
    self.MainFrame.Size = self.MainFrame.Size - UDim2.new(0, 10, 0, 10)
    self.MainFrame.BackgroundTransparency = 1
    
    Services.Tween:Create(self.MainFrame, TweenInfo.new(0.2), {
        Size = System.UI.WindowSize,
        BackgroundTransparency = 0.1
    }):Play()
end

function CensuraDev:Hide()
    -- Fade out with slight scale animation
    local hideTween = Services.Tween:Create(self.MainFrame, TweenInfo.new(0.2), {
        Size = self.MainFrame.Size - UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1
    })
    
    hideTween:Play()
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
