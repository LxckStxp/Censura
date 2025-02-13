--[[
    Censura/Core/Components.lua
    Purpose: UI Component definitions that integrate with _G.Censura
    Dependencies: Styles module (_G.Censura.Modules.Styles)
]]

-- Initialize if not already done
if not _G.Censura then
    _G.Censura = {
        Modules = {},
        State = {},
        Cache = {},
        UI = {
            ActiveComponents = {}  -- Track active components
        }
    }
end

local Components = {}
_G.Censura.Modules.Components = Components

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Get Styles reference
local Styles = _G.Censura.Modules.Styles

-- Component Base Class
local BaseComponent = {}
BaseComponent.__index = BaseComponent

function BaseComponent.new(name)
    local self = setmetatable({
        Name = name,
        Instance = nil,
        Events = {},
        Connections = {},
        Children = {}
    }, BaseComponent)
    
    -- Register component
    _G.Censura.UI.ActiveComponents[name] = self
    return self
end

function BaseComponent:Destroy()
    -- Cleanup connections
    for _, connection in pairs(self.Connections) do
        connection:Disconnect()
    end
    
    -- Cleanup children
    for _, child in pairs(self.Children) do
        if child.Destroy then
            child:Destroy()
        end
    end
    
    -- Remove from active components
    _G.Censura.UI.ActiveComponents[self.Name] = nil
    
    -- Destroy instance
    if self.Instance then
        self.Instance:Destroy()
    end
end

function BaseComponent:AddChild(child)
    self.Children[child.Name] = child
    return child
end

--[[ Container Component
    Example usage:
    local container = Components.Container.new("MainContainer", parentFrame)
    container:AddToggle("AimbotEnabled", "Enable Aimbot", false)
    container:AddSlider("AimbotFOV", "Aimbot FOV", 0, 500, 100)
]]
Components.Container = {}
Components.Container.__index = Components.Container
setmetatable(Components.Container, BaseComponent)

function Components.Container.new(name, parent)
    local self = BaseComponent.new(name)
    setmetatable(self, Components.Container)
    
    -- Create container frame
    self.Instance = Instance.new("ScrollingFrame")
    self.Instance.Name = name
    self.Instance.BackgroundTransparency = 1
    self.Instance.Size = UDim2.new(1, 0, 1, -Styles.Constants.HeaderHeight)
    self.Instance.Position = UDim2.new(0, 0, 0, Styles.Constants.HeaderHeight)
    self.Instance.ScrollBarThickness = 2
    self.Instance.ScrollBarImageColor3 = Styles.GetColor("Primary")
    self.Instance.Parent = parent

    -- Add layout
    self.Layout = Instance.new("UIListLayout")
    self.Layout.Padding = Styles.Constants.ElementSpacing
    self.Layout.Parent = self.Instance

    -- Add padding
    Styles.Utils.CreatePadding(self.Instance)

    -- Auto-size content
    self.Connections.ContentSize = self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.Instance.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y + 20)
    end)

    return self
end

function Components.Container:AddToggle(name, label, default)
    local toggle = Components.Toggle.new(name, self.Instance, label, default)
    return self:AddChild(toggle)
end

function Components.Container:AddSlider(name, label, min, max, default)
    local slider = Components.Slider.new(name, self.Instance, label, min, max, default)
    return self:AddChild(slider)
end

--[[ Toggle Component
    Example usage:
    local toggle = Components.Toggle.new("AimbotToggle", parent, "Enable Aimbot", false)
    toggle.Events.OnChanged:Connect(function(state)
        print("Aimbot enabled:", state)
    end)
]]
Components.Toggle = {}
Components.Toggle.__index = Components.Toggle
setmetatable(Components.Toggle, BaseComponent)

function Components.Toggle.new(name, parent, label, default)
    local self = BaseComponent.new(name)
    setmetatable(self, Components.Toggle)
    
    -- Create main frame
    self.Instance = Instance.new("Frame")
    self.Instance.Name = name
    self.Instance.BackgroundTransparency = 1
    self.Instance.Size = UDim2.new(1, 0, 0, Styles.Constants.ToggleHeight)
    self.Instance.Parent = parent

    -- Create toggle elements
    self.Button = Instance.new("TextButton")
    self.Button.Name = "Button"
    self.Button.Position = UDim2.new(1, -Styles.Constants.ToggleWidth, 0.5, -12)
    self.Button.Size = UDim2.new(0, Styles.Constants.ToggleWidth, 0, 24)
    self.Button.BackgroundColor3 = default and Styles.GetColor("Success") or Styles.GetColor("Error")
    self.Button.BorderSizePixel = 0
    self.Button.Text = ""
    self.Button.AutoButtonColor = false
    self.Button.Parent = self.Instance

    self.Circle = Instance.new("Frame")
    self.Circle.Size = UDim2.new(0, 20, 0, 20)
    self.Circle.Position = default and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2)
    self.Circle.BackgroundColor3 = Styles.GetColor("Highlight")
    self.Circle.BorderSizePixel = 0
    self.Circle.Parent = self.Button

    -- Add corners
    Styles.Utils.CreateCorner(self.Button, Styles.Constants.ButtonCornerRadius)
    Styles.Utils.CreateCorner(self.Circle, Styles.Constants.CircleCornerRadius)

    -- Add label
    self.Label = Instance.new("TextLabel")
    self.Label.BackgroundTransparency = 1
    self.Label.Position = UDim2.new(0, 0, 0, 0)
    self.Label.Size = UDim2.new(1, -Styles.Constants.ToggleWidth - 10, 1, 0)
    self.Label.Font = Styles.Fonts.Label.Font
    self.Label.Text = label
    self.Label.TextColor3 = Styles.GetColor("Text")
    self.Label.TextSize = Styles.Fonts.Label.Size
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.Parent = self.Instance

    -- State handling
    self.State = default
    self.Tweening = false

    function self:SetState(newState, silent)
        if self.Tweening then return end
        self.Tweening = true
        self.State = newState

        -- Animate transition
        local circleTween = Styles.CreateTween(
            self.Circle,
            {Position = newState and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2)}
        )

        local colorTween = Styles.CreateTween(
            self.Button,
            {BackgroundColor3 = newState and Styles.GetColor("Success") or Styles.GetColor("Error")}
        )

        circleTween:Play()
        colorTween:Play()

        -- Emit event if not silent
        if not silent and self.Events.OnChanged then
            self.Events.OnChanged(newState)
        end

        circleTween.Completed:Wait()
        self.Tweening = false
    end

    -- Connect events
    self.Connections.Clicked = self.Button.MouseButton1Click:Connect(function()
        self:SetState(not self.State)
    end)

    -- Hover effects
    self.Connections.MouseEnter = self.Button.MouseEnter:Connect(function()
        Styles.CreateTween(self.Button, {BackgroundTransparency = 0.2}):Play()
    end)

    self.Connections.MouseLeave = self.Button.MouseLeave:Connect(function()
        Styles.CreateTween(self.Button, {BackgroundTransparency = 0}):Play()
    end)

    return self
end

--[[ Slider Component
    Example usage:
    local slider = Components.Slider.new("FOVSlider", parent, "FOV", 0, 500, 100)
    slider.Events.OnChanged:Connect(function(value)
        print("FOV changed:", value)
    end)
]]
Components.Slider = {}
Components.Slider.__index = Components.Slider
setmetatable(Components.Slider, BaseComponent)

function Components.Slider.new(name, parent, label, min, max, default)
    local self = BaseComponent.new(name)
    setmetatable(self, Components.Slider)
    
    -- Create main frame
    self.Instance = Instance.new("Frame")
    self.Instance.Name = name
    self.Instance.BackgroundTransparency = 1
    self.Instance.Size = UDim2.new(1, 0, 0, Styles.Constants.SliderHeight)
    self.Instance.Parent = parent

    -- Create slider elements
    self.Label = Instance.new("TextLabel")
    self.Label.BackgroundTransparency = 1
    self.Label.Size = UDim2.new(1, -50, 0, 20)
    self.Label.Font = Styles.Fonts.Label.Font
    self.Label.Text = label
    self.Label.TextColor3 = Styles.GetColor("Text")
    self.Label.TextSize = Styles.Fonts.Label.Size
    self.Label.TextXAlignment = Enum.TextXAlignment.Left
    self.Label.Parent = self.Instance

    self.Background = Instance.new("Frame")
    self.Background.BackgroundColor3 = Styles.GetColor("LightAccent")
    self.Background.BorderSizePixel = 0
    self.Background.Position = UDim2.new(0, 0, 0, 30)
    self.Background.Size = UDim2.new(1, 0, 0, Styles.Constants.SliderThickness)
    self.Background.Parent = self.Instance

    self.Fill = Instance.new("Frame")
    self.Fill.BackgroundColor3 = Styles.GetColor("Primary")
    self.Fill.BorderSizePixel = 0
    self.Fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    self.Fill.Parent = self.Background

    self.Button = Instance.new("TextButton")
    self.Button.BackgroundColor3 = Styles.GetColor("Highlight")
    self.Button.Position = UDim2.new((default - min)/(max - min), -6, 0.5, -6)
    self.Button.Size = UDim2.new(0, 12, 0, 12)
    self.Button.Text = ""
    self.Button.Parent = self.Background

    self.Value = Instance.new("TextLabel")
    self.Value.BackgroundTransparency = 1
    self.Value.Position = UDim2.new(1, -45, 0, 0)
    self.Value.Size = UDim2.new(0, 45, 0, 20)
    self.Value.Font = Styles.Fonts.Value.Font
    self.Value.Text = tostring(default)
    self.Value.TextColor3 = Styles.GetColor("Text")
    self.Value.TextSize = Styles.Fonts.Value.Size
    self.Value.Parent = self.Instance

    -- Add corners
    Styles.Utils.CreateCorner(self.Background, UDim.new(0, 3))
    Styles.Utils.CreateCorner(self.Fill, UDim.new(0, 3))
    Styles.Utils.CreateCorner(self.Button, Styles.Constants.CircleCornerRadius)

    -- Slider properties
    self.Min = min
    self.Max = max
    self.Value = default
    self.Dragging = false

    function self:SetValue(newValue, silent)
        self.Value = math.clamp(newValue, self.Min, self.Max)
        local scale = (self.Value - self.Min) / (self.Max - self.Min)

        -- Update visuals
        Styles.CreateTween(self.Fill, {Size = UDim2.new(scale, 0, 1, 0)}):Play()
        Styles.CreateTween(self.Button, {Position = UDim2.new(scale, -6, 0.5, -6)}):Play()
        self.Value.Text = tostring(math.round(self.Value))

        -- Emit event if not silent
        if not silent and self.Events.OnChanged then
            self.Events.OnChanged(self.Value)
        end
    end

    -- Connect events
    self.Connections.ButtonDown = self.Button.MouseButton1Down:Connect(function()
        self.Dragging = true
    end)

    self.Connections.InputEnded = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = false
        end
    end)

    self.Connections.InputChanged = UserInputService.InputChanged:Connect(function(input)
        if self.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = self.Background.AbsolutePosition
            local sliderSize = self.Background.AbsoluteSize
            
            local scale = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
            local newValue = self.Min + (self.Max - self.Min) * scale
            
            self:SetValue(newValue)
        end
    end)

    -- Hover effects
    self.Connections.MouseEnter = self.Button.MouseEnter:Connect(function()
        Styles.CreateTween(self.Button, {Size = UDim2.new(0, 14, 0, 14)}):Play()
    end)

    self.Connections.MouseLeave = self.Button.MouseLeave:Connect(function()
        Styles.CreateTween(self.Button, {Size = UDim2.new(0, 12, 0, 12)}):Play()
    end)

    return self
end

return Components
