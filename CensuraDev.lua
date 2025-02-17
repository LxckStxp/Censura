--[[
    CensuraDev UI Library
    Version: 3.1
    Author: LxckStxp
--]]

-- Global System Table
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
        -- Sizes
        WindowSize = UDim2.new(0, 300, 0, 400),
        ButtonSize = UDim2.new(1, -16, 0, 36),
        ToggleSize = UDim2.new(0, 26, 0, 26),
        SliderSize = UDim2.new(1, -16, 0, 50),
        
        -- Styling
        CornerRadius = UDim.new(0, 6),
        Padding = UDim.new(0, 8),
        
        -- Transparency
        Transparency = {
            Background = 0.15,
            Accent = 0.08,
            Text = 0,
            Elements = 0.04
        },
        
        -- Animation
        TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
    }
}

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

-- Example usage of the global system:
function CensuraDev.new()
    local self = setmetatable({}, CensuraDev)
    
    -- Create Main GUI
    self.GUI = Instance.new("ScreenGui")
    self.GUI.Name = "CensuraUI"
    self.GUI.ResetOnSpawn = false
    
    -- Main Container using global settings
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = CensuraSystem.UI.WindowSize
    self.MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    self.MainFrame.BackgroundColor3 = CensuraSystem.Colors.Background
    self.MainFrame.BackgroundTransparency = CensuraSystem.UI.Transparency.Background
    self.MainFrame.Parent = self.GUI
    
    -- Apply Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = CensuraSystem.UI.CornerRadius
    corner.Parent = self.MainFrame
    
    -- Apply Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = CensuraSystem.Colors.Border
    stroke.Transparency = 0.7
    stroke.Thickness = 1.5
    stroke.Parent = self.MainFrame
    
    -- Create Title Bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 40)
    self.TitleBar.BackgroundColor3 = CensuraSystem.Colors.Accent
    self.TitleBar.BackgroundTransparency = CensuraSystem.UI.Transparency.Accent
    self.TitleBar.Parent = self.MainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = CensuraSystem.UI.CornerRadius
    titleCorner.Parent = self.TitleBar
    
    -- Title Text
    local title = Instance.new("TextLabel")
    title.Text = "Censura"
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = CensuraSystem.Colors.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = self.TitleBar
    
    -- Content Frame
    self.ContentFrame = Instance.new("ScrollingFrame")
    self.ContentFrame.Name = "ContentFrame"
    self.ContentFrame.Size = UDim2.new(1, -10, 1, -50)
    self.ContentFrame.Position = UDim2.new(0, 5, 0, 45)
    self.ContentFrame.BackgroundTransparency = 1
    self.ContentFrame.ScrollBarThickness = 2
    self.ContentFrame.ScrollBarImageColor3 = CensuraSystem.Colors.Accent
    self.ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.ContentFrame.Parent = self.MainFrame
    
    -- Content Layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = CensuraSystem.UI.Padding
    listLayout.Parent = self.ContentFrame
    
    -- Initialize Dragging
    Components.makeDraggable(self.TitleBar, self.MainFrame)
    
    -- Setup Toggle
    self.Visible = true
    Services.UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.RightAlt then
            self:Toggle()
        end
    end)
    
    return self
end

-- UI Methods (Now using global system)
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
    self.GUI.Parent = Services.CoreGui
    self.Visible = true
    self.MainFrame.Visible = true
    
    Services.TweenService:Create(self.MainFrame, CensuraSystem.UI.TweenInfo, {
        BackgroundTransparency = CensuraSystem.UI.Transparency.Background
    }):Play()
end

function CensuraDev:Hide()
    Services.TweenService:Create(self.MainFrame, CensuraSystem.UI.TweenInfo, {
        BackgroundTransparency = 1
    }):Play()
    
    task.wait(CensuraSystem.UI.TweenInfo.Time)
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
