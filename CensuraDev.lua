--[[
    CensuraDev UI Library
    Version: 3.0
    Author: LxckStxp
    
    Features:
    - Modern, sleek design
    - Smooth animations
    - Customizable elements
    - Right Alt toggle
--]]

local CensuraDev = {}
CensuraDev.__index = CensuraDev

-- Services
local Services = {
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService")
}

-- Load Components
local Components = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraComponents.lua"))()

-- Theme Configuration
local Theme = {
    Colors = {
        Background = Color3.fromRGB(20, 20, 30),
        Accent = Color3.fromRGB(35, 35, 50),
        Text = Color3.fromRGB(240, 240, 245),
        Highlight = Color3.fromRGB(50, 50, 70),
        Enabled = Color3.fromRGB(98, 150, 255),
        Disabled = Color3.fromRGB(255, 75, 95),
        Border = Color3.fromRGB(60, 60, 80),
        SecondaryText = Color3.fromRGB(180, 180, 190),
        Gradient = {
            Start = Color3.fromRGB(25, 25, 35),
            End = Color3.fromRGB(35, 35, 45)
        }
    },
    
    UI = {
        -- Corner Radiuses
        CornerRadius = UDim.new(0, 6),
        ButtonRadius = UDim.new(0, 6),
        ToggleRadius = UDim.new(0, 12),
        
        -- Spacing
        Padding = UDim.new(0, 8),
        ElementSpacing = UDim.new(0, 10),
        
        -- Element Sizes
        ButtonSize = UDim2.new(1, -16, 0, 36),
        ToggleSize = UDim2.new(0, 26, 0, 26),
        SliderSize = UDim2.new(1, -16, 0, 50),
        
        -- Window Size
        WindowSize = UDim2.new(0, 300, 0, 400),
        TitleBarSize = UDim2.new(1, 0, 0, 40),
        
        -- Transparency
        Transparency = {
            Background = 0.15,
            Accent = 0.08,
            Text = 0,
            Elements = 0.04
        },
        
        -- Text Settings
        Font = {
            Title = Enum.Font.GothamBold,
            Button = Enum.Font.GothamMedium,
            Label = Enum.Font.Gotham
        },
        
        TextSize = {
            Title = 18,
            Button = 14,
            Label = 13
        },
        
        -- Animation
        TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
    }
}

-- Utility Functions
local function CreateElement(className, properties)
    local element = Instance.new(className)
    for property, value in pairs(properties) do
        element[property] = value
    end
    return element
end

-- Main UI Creation
function CensuraDev.new()
    local self = setmetatable({}, CensuraDev)
    
    -- Create ScreenGui
    self.GUI = CreateElement("ScreenGui", {
        Name = "CensuraUI",
        ResetOnSpawn = false
    })
    
    -- Create Main Window
    self.MainFrame = CreateElement("Frame", {
        Name = "MainFrame",
        Size = Theme.UI.WindowSize,
        Position = UDim2.new(0.5, -150, 0.5, -200),
        BackgroundColor3 = Theme.Colors.Background,
        BackgroundTransparency = Theme.UI.Transparency.Background,
        Parent = self.GUI
    })
    
    -- Apply Window Styling
    CreateElement("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Colors.Gradient.Start),
            ColorSequenceKeypoint.new(1, Theme.Colors.Gradient.End)
        }),
        Rotation = 45,
        Parent = self.MainFrame
    })
    
    CreateElement("UICorner", {
        CornerRadius = Theme.UI.CornerRadius,
        Parent = self.MainFrame
    })
    
    CreateElement("UIStroke", {
        Color = Theme.Colors.Border,
        Transparency = 0.7,
        Thickness = 1.5,
        Parent = self.MainFrame
    })
    
    -- Create Title Bar
    self.TitleBar = CreateElement("Frame", {
        Name = "TitleBar",
        Size = Theme.UI.TitleBarSize,
        BackgroundColor3 = Theme.Colors.Accent,
        BackgroundTransparency = Theme.UI.Transparency.Accent,
        Parent = self.MainFrame
    })
    
    CreateElement("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Colors.Accent),
            ColorSequenceKeypoint.new(1, Theme.Colors.Highlight)
        }),
        Rotation = 90,
        Parent = self.TitleBar
    })
    
    CreateElement("UICorner", {
        CornerRadius = Theme.UI.CornerRadius,
        Parent = self.TitleBar
    })
    
    CreateElement("TextLabel", {
        Text = "Censura",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = Theme.Colors.Text,
        Font = Theme.UI.Font.Title,
        TextSize = Theme.UI.TextSize.Title,
        Parent = self.TitleBar
    })
    
    -- Create Content Area
    self.ContentFrame = CreateElement("ScrollingFrame", {
        Name = "ContentFrame",
        Size = UDim2.new(1, -10, 1, -50),
        Position = UDim2.new(0, 5, 0, 45),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Colors.Accent,
        Parent = self.MainFrame
    })
    
    CreateElement("UIListLayout", {
        Padding = Theme.UI.ElementSpacing,
        Parent = self.ContentFrame
    })
    
    -- Initialize Dragging
    Components.makeDraggable(self.TitleBar, self.MainFrame)
    
    -- Setup Visibility Toggle
    self.Visible = true
    Services.UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.RightAlt then
            self:Toggle()
        end
    end)
    
    return self
end

-- UI Methods
function CensuraDev:CreateButton(text, callback)
    return Components.createButton(self.ContentFrame, text, callback, Theme.Colors, Theme.UI, Services.TweenService)
end

function CensuraDev:CreateToggle(text, default, callback)
    return Components.createToggle(self.ContentFrame, text, default, callback, Theme.Colors, Theme.UI, Services.TweenService)
end

function CensuraDev:CreateSlider(text, min, max, default, callback)
    return Components.createSlider(
        self.ContentFrame, 
        text, 
        min, 
        max, 
        default, 
        callback, 
        Theme.Colors, 
        Theme.UI, 
        Services.TweenService,
        Services.UserInputService,
        Services.RunService
    )
end

-- Visibility Methods
function CensuraDev:Show()
    self.GUI.Parent = Services.CoreGui
    self.Visible = true
    self.MainFrame.Visible = true
    
    Services.TweenService:Create(self.MainFrame, Theme.UI.TweenInfo, {
        BackgroundTransparency = Theme.UI.Transparency.Background
    }):Play()
end

function CensuraDev:Hide()
    Services.TweenService:Create(self.MainFrame, Theme.UI.TweenInfo, {
        BackgroundTransparency = 1
    }):Play()
    
    task.wait(Theme.UI.TweenInfo.Time)
    self.Visible = false
    self.MainFrame.Visible = false
end

function CensuraDev:Toggle()
    if self.Visible then
        self:Hide()
    else
        self:Show()
    end
end

return CensuraDev
