--[[
    Censura UI System
    Author: LxckStxp
    Version: 2.0.0
    
    A lightweight, modular UI framework for Roblox exploits
]]

-- Core Framework


_G.Censura = {
    Version = "2.0.0",
    Windows = {},
    Config = {
        DefaultTheme = "Dark",
        ToggleKey = Enum.KeyCode.RightControl,
        DisplayOrder = 999
    },
    System = {
        Active = {
            Elements = {},
            Connections = {}
        }
    }
}

local Censura = _G.Censura

-- Services
local Services = {
    UserInput = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    Players = game:GetService("Players"),
    CoreGui = game:GetService("CoreGui"),
    HttpService = game:GetService("HttpService")
}

-- Load Core Modules
local function LoadModules()
    local baseUrl = "https://raw.githubusercontent.com/LxckStxp/Censura/main/Core/"
    local modules = {
        Styles = "Styles.lua",
        Components = "Components.lua"
    }
    
    for name, file in pairs(modules) do
        local success, module = pcall(function()
            return loadstring(game:HttpGet(baseUrl .. file))()
        end)
        
        if not success or not module then
            return false
        end
        
        Censura.System[name] = module
    end
    
    return true
end

-- Window Creation
function Censura:CreateWindow(options)
    options = type(options) == "table" and options or {title = tostring(options)}
    
    local window = {
        Elements = {},
        Visible = true,
        Options = options
    }
    
    -- Create Window Frame
    window.Frame = Instance.new("Frame")
    window.Frame.Name = options.title or "CensuraWindow"
    window.Frame.Size = options.size or UDim2.new(0, 300, 0, 400)
    window.Frame.Position = options.position or UDim2.new(0.5, -150, 0.5, -200)
    window.Frame.BackgroundColor3 = self.System.Styles.GetColor("Background")
    window.Frame.BorderSizePixel = 0
    window.Frame.Parent = self.GUI
    
    -- Create Header
    window.Header = Instance.new("Frame")
    window.Header.Name = "Header"
    window.Header.Size = UDim2.new(1, 0, 0, 30)
    window.Header.BackgroundColor3 = self.System.Styles.GetColor("Primary")
    window.Header.BorderSizePixel = 0
    window.Header.Parent = window.Frame
    
    -- Create Title
    window.Title = Instance.new("TextLabel")
    window.Title.Size = UDim2.new(1, -10, 1, 0)
    window.Title.Position = UDim2.new(0, 10, 0, 0)
    window.Title.BackgroundTransparency = 1
    window.Title.Text = options.title or "Censura Window"
    window.Title.TextColor3 = self.System.Styles.GetColor("Text")
    window.Title.TextXAlignment = Enum.TextXAlignment.Left
    window.Title.Font = self.System.Styles.Fonts.Header.Font
    window.Title.TextSize = self.System.Styles.Fonts.Header.Size
    window.Title.Parent = window.Header
    
    -- Create Content Container
    window.Content = Instance.new("Frame")
    window.Content.Name = "Content"
    window.Content.Size = UDim2.new(1, 0, 1, -30)
    window.Content.Position = UDim2.new(0, 0, 0, 30)
    window.Content.BackgroundTransparency = 1
    window.Content.Parent = window.Frame
    
    -- Add Styling
    self.System.Styles.Utils.CreateCorner(window.Frame)
    self.System.Styles.Utils.CreateCorner(window.Header)
    
    -- Make Window Draggable
    local dragging, dragStart, startPos
    
    local function UpdateDrag(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            window.Frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end
    
    window.Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Frame.Position
        end
    end)
    
    Services.UserInput.InputChanged:Connect(UpdateDrag)
    Services.UserInput.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Window Methods
    function window:AddContainer()
        return Censura.System.Components.Create.Container({
            parent = self.Content
        })
    end
    
    function window:Show()
        self.Frame.Visible = true
        self.Visible = true
    end
    
    function window:Hide()
        self.Frame.Visible = false
        self.Visible = false
    end
    
    function window:Toggle()
        self.Visible = not self.Visible
        self.Frame.Visible = self.Visible
    end
    
    -- Add to Windows Collection
    table.insert(self.Windows, window)
    return window
end

-- Initialize Framework
local function Initialize()
    -- Cleanup Existing Instance
    if _G.Censura then
        pcall(function() 
            _G.Censura.GUI:Destroy() 
        end)
        _G.Censura = nil
    end
    
    -- Load Required Modules
    if not LoadModules() then
        return false
    end
    
    -- Create GUI Container
    Censura.GUI = Instance.new("ScreenGui")
    Censura.GUI.Name = "CensuraGUI"
    Censura.GUI.ResetOnSpawn = false
    Censura.GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Censura.GUI.DisplayOrder = Censura.Config.DisplayOrder
    
    -- Parent GUI
    local success = pcall(function()
        Censura.GUI.Parent = Services.CoreGui
    end)
    
    if not success then
        Censura.GUI.Parent = Services.Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Setup Global Toggle
    Censura.ToggleConnection = Services.UserInput.InputBegan:Connect(function(input)
        if input.KeyCode == Censura.Config.ToggleKey then
            for _, window in ipairs(Censura.Windows) do
                window:Toggle()
            end
        end
    end)
    
    return true
end

-- Cleanup Method
function Censura:Destroy()
    if self.ToggleConnection then
        self.ToggleConnection:Disconnect()
    end
    
    if self.GUI then
        self.GUI:Destroy()
    end
    
    _G.Censura = nil
end

-- Initialize and Return
if Initialize() then
    return Censura
end

return nil
