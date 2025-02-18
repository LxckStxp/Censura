--[[
    CensuraDev Components Module
    Version: 4.2
    
    Optimized UI components with enhanced performance and reliability
]]

local Components = {}

-- Services
local Services = {
    UserInput = game:GetService("UserInputService"),
    Tween = game:GetService("TweenService"),
    Run = game:GetService("RunService")
}

-- Constants
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local CLICK_ANIMATION_SCALE = 0.95

-- Connection Management
local ConnectionManager = {
    new = function()
        local connections = {}
        
        return {
            add = function(connection)
                table.insert(connections, connection)
                return connection
            end,
            
            clear = function()
                for _, connection in ipairs(connections) do
                    if typeof(connection) == "RBXScriptConnection" then
                        connection:Disconnect()
                    end
                end
                table.clear(connections)
            end
        }
    end
}

-- Utility Functions
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

local function CreateTween(instance, properties)
    return Services.Tween:Create(instance, TWEEN_INFO, properties)
end

local function SafeCallback(callback, ...)
    if typeof(callback) == "function" then
        local success, result = pcall(callback, ...)
        if not success then
            warn("Callback error:", result)
        end
    end
end

-- Component Base
local function CreateComponent(name, initFn)
    return function(...)
        local System = getgenv().CensuraSystem
        if not System then
            error("CensuraSystem not initialized")
            return nil
        end
        
        local container = Create("Frame", {
            Name = name .. "Container",
            BackgroundTransparency = 1,
            Size = System.UI.ButtonSize
        })
        
        -- Connection management
        local connections = ConnectionManager.new()
        local tweens = {}
        
        -- Cleanup handler
        container.Destroying:Connect(function()
            connections.clear()
            for _, tween in ipairs(tweens) do
                tween:Cancel()
            end
            table.clear(tweens)
        end)
        
        -- Initialize component
        local success, result = pcall(initFn, container, connections, tweens, System, ...)
        
        if not success then
            warn("Failed to create " .. name .. ":", result)
            container:Destroy()
            return nil
        end
        
        -- Set parent last
        container.Parent = select(1, ...)
        
        return container
    end
end

-- Button Component
Components.createButton = CreateComponent("Button", function(container, connections, tweens, System, parent, text, callback)
    local button = Create("TextButton", {
        Name = "Button",
        Parent = container,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = System.Colors.Accent,
        BackgroundTransparency = System.UI.Transparency.Elements,
        Text = text,
        TextColor3 = System.Colors.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        AutoButtonColor = false
    })
    
    Create("UICorner", {
        Parent = button,
        CornerRadius = System.UI.CornerRadius
    })
    
    -- Hover effect
    connections.add(button.MouseEnter:Connect(function()
        local tween = CreateTween(button, {BackgroundColor3 = System.Colors.Highlight})
        table.insert(tweens, tween)
        tween:Play()
    end))
    
    connections.add(button.MouseLeave:Connect(function()
        local tween = CreateTween(button, {BackgroundColor3 = System.Colors.Accent})
        table.insert(tweens, tween)
        tween:Play()
    end))
    
    -- Click animation
    connections.add(button.MouseButton1Down:Connect(function()
        local tween = CreateTween(button, {
            Size = UDim2.new(CLICK_ANIMATION_SCALE, 0, CLICK_ANIMATION_SCALE, 0)
        })
        table.insert(tweens, tween)
        tween:Play()
    end))
    
    connections.add(button.MouseButton1Up:Connect(function()
        local tween = CreateTween(button, {
            Size = UDim2.new(1, 0, 1, 0)
        })
        table.insert(tweens, tween)
        tween:Play()
    end))
    
    connections.add(button.MouseButton1Click:Connect(function()
        SafeCallback(callback)
    end))
end)

-- Toggle Component
Components.createToggle = CreateComponent("Toggle", function(container, connections, tweens, System, parent, text, default, callback)
    container.Size = System.UI.ButtonSize
    container.BackgroundColor3 = System.Colors.Accent
    container.BackgroundTransparency = System.UI.Transparency.Elements
    
    Create("UICorner", {
        Parent = container,
        CornerRadius = System.UI.CornerRadius
    })
    
    local label = Create("TextLabel", {
        Name = "Label",
        Parent = container,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -44, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = System.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14
    })
    
    local toggle = Create("TextButton", {
        Name = "Toggle",
        Parent = container,
        Position = UDim2.new(1, -34, 0.5, -12),
        Size = System.UI.ToggleSize,
        BackgroundColor3 = default and System.Colors.Enabled or System.Colors.Disabled,
        Text = ""
    })
    
    Create("UICorner", {
        Parent = toggle,
        CornerRadius = UDim.new(0, 12)
    })
    
    local enabled = default or false
    
    connections.add(toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        
        local tween = CreateTween(toggle, {
            BackgroundColor3 = enabled and System.Colors.Enabled or System.Colors.Disabled
        })
        table.insert(tweens, tween)
        tween:Play()
        
        SafeCallback(callback, enabled)
    end))
end)

-- Slider Component
function Components.createSlider(parent, text, min, max, default, callback)
    local System = getgenv().CensuraSystem
    
    -- Create main container
    local container = Create("Frame", {
        Name = "SliderContainer",
        Parent = parent,
        Size = System.UI.SliderSize,
        BackgroundColor3 = System.Colors.Accent,
        BackgroundTransparency = System.UI.Transparency.Elements
    })
    
    -- Add corner to container
    Create("UICorner", {
        Parent = container,
        CornerRadius = System.UI.CornerRadius
    })
    
    -- Create title label
    local label = Create("TextLabel", {
        Name = "Label",
        Parent = container,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -70, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = System.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14
    })
    
    -- Create value display label
    local valueLabel = Create("TextLabel", {
        Name = "Value",
        Parent = container,
        Position = UDim2.new(1, -60, 0, 0),
        Size = UDim2.new(0, 50, 0, 20),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = System.Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.GothamSemibold,
        TextSize = 14
    })
    
    -- Create slider track
    local sliderBar = Create("Frame", {
        Name = "SliderBar",
        Parent = container,
        Position = UDim2.new(0, 10, 0.7, 0),
        Size = UDim2.new(1, -20, 0, 4),
        BackgroundColor3 = System.Colors.Background
    })
    
    -- Add corner to track
    Create("UICorner", {
        Parent = sliderBar,
        CornerRadius = UDim.new(0, 2)
    })
    
    -- Create fill bar
    local fill = Create("Frame", {
        Name = "Fill",
        Parent = sliderBar,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = System.Colors.Enabled
    })
    
    -- Add corner to fill
    Create("UICorner", {
        Parent = fill,
        CornerRadius = UDim.new(0, 2)
    })
    
    -- Create drag knob
    local knob = Create("TextButton", {
        Name = "Knob",
        Parent = sliderBar,
        Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        BackgroundColor3 = System.Colors.Enabled,
        Text = ""
    })
    
    -- Add corner to knob
    Create("UICorner", {
        Parent = knob,
        CornerRadius = UDim.new(1, 0)
    })
    
    -- Slider state variables
    local dragging = false
    local value = default
    local connections = {}
    local currentTween
    
    -- Update slider function
    local function updateSlider(input)
        -- Calculate position
        local pos = math.clamp(
            (input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X,
            0, 1
        )
        
        -- Calculate value
        value = math.floor(min + ((max - min) * pos))
        valueLabel.Text = tostring(value)
        
        -- Cancel existing tween
        if currentTween then 
            currentTween:Cancel()
        end
        
        -- Animate knob
        currentTween = CreateTween(knob, {
            Position = UDim2.new(pos, -8, 0.5, -8)
        })
        currentTween:Play()
        
        -- Animate fill
        CreateTween(fill, {
            Size = UDim2.new(pos, 0, 1, 0)
        }):Play()
        
        -- Fire callback
        callback(value)
    end
    
    -- Knob drag start
    table.insert(connections, knob.MouseButton1Down:Connect(function()
        dragging = true
    end))
    
    -- Knob drag
    table.insert(connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end))
    
    -- Knob drag end
    table.insert(connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))
    
    -- Track click
    table.insert(connections, sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input)
        end
    end))
    
    -- Cleanup
    container.Destroying:Connect(function()
        -- Disconnect all connections
        for _, connection in ipairs(connections) do
            connection:Disconnect()
        end
        -- Cancel current tween
        if currentTween then
            currentTween:Cancel()
        end
    end)
    
    return container
end

return Components
