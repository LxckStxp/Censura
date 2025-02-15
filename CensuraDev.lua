--[[
    Censura UI System v2.1.0
    Author: LxckStxp
    Modern UI Framework for Roblox
    
    Features:
    - Robust event handling system
    - Advanced theming capabilities
    - Efficient memory management
    - Responsive animations
    - Type-safe component system
]]

-- Services with protected call handling
local Services = setmetatable({
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    Players = game:GetService("Players"),
    CoreGui = game:GetService("CoreGui"),
    RunService = game:GetService("RunService"),
    ContentProvider = game:GetService("ContentProvider")
}, {
    __index = function(_, serviceName)
        local success, service = pcall(game.GetService, game, serviceName)
        assert(success, "Failed to get service: " .. serviceName)
        return service
    end
})

-- Signal Class for Event Management
local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({
        _connections = {},
        _destroyed = false,
        _suspended = false
    }, Signal)
end

function Signal:Connect(fn)
    assert(not self._destroyed, "Cannot connect to destroyed signal")
    local connection = {
        Connected = true,
        _callback = fn,
        Disconnect = function(self)
            self.Connected = false
            for i, conn in ipairs(self._connections) do
                if conn == self then
                    table.remove(self._connections, i)
                    break
                end
            end
        end
    }
    table.insert(self._connections, connection)
    return connection
end

function Signal:Fire(...)
    if self._suspended then return end
    for _, connection in ipairs(self._connections) do
        if connection.Connected then
            task.spawn(connection._callback, ...)
        end
    end
end

function Signal:Suspend()
    self._suspended = true
end

function Signal:Resume()
    self._suspended = true
end

function Signal:Destroy()
    self._destroyed = true
    table.clear(self._connections)
end

-- Create Core Framework
local Censura = {
    Version = "2.1.0",
    Windows = {},
    Config = {
        ToggleKey = Enum.KeyCode.RightControl,
        Theme = {
            Background = Color3.fromRGB(25, 25, 25),
            Primary = Color3.fromRGB(0, 170, 255),
            Secondary = Color3.fromRGB(45, 45, 45),
            Text = Color3.fromRGB(255, 255, 255),
            TextDark = Color3.fromRGB(200, 200, 200),
            Success = Color3.fromRGB(0, 255, 100),
            Error = Color3.fromRGB(255, 50, 50),
            Warning = Color3.fromRGB(255, 165, 0),
            Highlight = Color3.fromRGB(255, 255, 255),
            Disabled = Color3.fromRGB(100, 100, 100)
        },
        Fonts = {
            Header = Enum.Font.GothamBold,
            Text = Enum.Font.Gotham,
            Mono = Enum.Font.Code,
            Size = {
                Header = 16,
                Text = 14,
                Small = 12,
                Tiny = 10
            }
        },
        Animation = {
            VeryShort = TweenInfo.new(0.1, Enum.EasingStyle.Quad),
            Short = TweenInfo.new(0.2, Enum.EasingStyle.Quad),
            Medium = TweenInfo.new(0.3, Enum.EasingStyle.Quad),
            Long = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            Bounce = TweenInfo.new(0.5, Enum.EasingStyle.Bounce),
            Spring = TweenInfo.new(0.6, Enum.EasingStyle.Back)
        },
        Layout = {
            Padding = {
                Small = 4,
                Medium = 8,
                Large = 12,
                ExtraLarge = 16
            },
            CornerRadius = {
                Small = UDim.new(0, 4),
                Medium = UDim.new(0, 6),
                Large = UDim.new(0, 8),
                Round = UDim.new(1, 0)
            },
            DefaultSize = {
                Window = Vector2.new(300, 400),
                Button = Vector2.new(0, 32),
                Input = Vector2.new(0, 30),
                Toggle = Vector2.new(0, 30),
                Slider = Vector2.new(0, 45)
            }
        }
    },
    Active = {
        Elements = {},
        Connections = {},
        Debris = {},
        Signals = {},
        Windows = {}
    },
    Debug = {
        Enabled = false,
        LogLevel = 1, -- 1: Errors, 2: Warnings, 3: Info
        Log = function(self, message, level)
            if not self.Enabled then return end
            if level <= self.LogLevel then
                print(string.format("[Censura] %s: %s", 
                    level == 1 and "ERROR" or level == 2 and "WARNING" or "INFO",
                    message))
            end
        end
    }
}

-- Initialize core signals
Censura.Signals = {
    WindowCreated = Signal.new(),
    WindowDestroyed = Signal.new(),
    ThemeUpdated = Signal.new(),
    VisibilityChanged = Signal.new()
}

-- Core utility functions
function Censura:SetTheme(newTheme)
    for key, value in pairs(newTheme) do
        if self.Config.Theme[key] then
            self.Config.Theme[key] = value
        end
    end
    self.Signals.ThemeUpdated:Fire(self.Config.Theme)
end

function Censura:GetTheme()
    return table.clone(self.Config.Theme)
end

function Censura:SetToggleKey(key)
    assert(typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode, "Invalid key type")
    self.Config.ToggleKey = key
end

-- Memory management
function Censura:Clean()
    for _, item in ipairs(self.Active.Debris) do
        if typeof(item) == "RBXScriptConnection" then
            item:Disconnect()
        elseif typeof(item) == "Instance" then
            item:Destroy()
        end
    end
    table.clear(self.Active.Debris)
end

-- Protected instance creation
function Censura:Create(className, properties)
    assert(typeof(className) == "string", "ClassName must be a string")
    local success, instance = pcall(Instance.new, className)
    assert(success, "Failed to create instance of " .. className)
    
    if properties then
        for prop, value in pairs(properties) do
            success, instance[prop] = pcall(function()
                return value
            end)
            if not success then
                self.Debug:Log("Failed to set property " .. prop, 2)
            end
        end
    end
    
    return instance
end

-- Component Base Class and Factory
local ComponentFactory = {}
ComponentFactory.__index = ComponentFactory

function ComponentFactory.new(className, properties)
    local self = setmetatable({
        Instance = Censura:Create(className, properties),
        Events = {},
        Children = {},
        _destroyed = false
    }, ComponentFactory)
    
    -- Add to active elements for management
    table.insert(Censura.Active.Elements, self)
    return self
end

-- UI Components
local Components = {
    Button = function(options)
        local button = ComponentFactory.new("TextButton", {
            Size = options.size or Censura.Config.Layout.DefaultSize.Button,
            Position = options.position,
            BackgroundColor3 = options.backgroundColor or Censura.Config.Theme.Primary,
            Text = options.text or "Button",
            TextColor3 = Censura.Config.Theme.Text,
            Font = Censura.Config.Fonts.Text,
            TextSize = Censura.Config.Fonts.Size.Text,
            AutoButtonColor = true,
            Parent = options.parent
        })

        -- Add hover effect
        local hoverSignal = Censura:Create("BindableEvent")
        button.Instance.MouseEnter:Connect(function()
            Services.TweenService:Create(button.Instance, 
                Censura.Config.Animation.Short, 
                {BackgroundColor3 = Censura.Config.Theme.Highlight}
            ):Play()
        end)

        button.Instance.MouseLeave:Connect(function()
            Services.TweenService:Create(button.Instance, 
                Censura.Config.Animation.Short, 
                {BackgroundColor3 = Censura.Config.Theme.Primary}
            ):Play()
        end)

        -- Add click effect
        button.Instance.MouseButton1Click:Connect(function()
            -- Ripple effect
            local ripple = Censura:Create("Frame", {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundColor3 = Censura.Config.Theme.Highlight,
                BackgroundTransparency = 0.8,
                Parent = button.Instance
            })
            
            local corner = Censura:Create("UICorner", {
                CornerRadius = Censura.Config.Layout.CornerRadius.Round,
                Parent = ripple
            })

            -- Animate ripple
            Services.TweenService:Create(ripple, 
                Censura.Config.Animation.Medium, 
                {
                    Size = UDim2.new(1.5, 0, 1.5, 0),
                    BackgroundTransparency = 1
                }
            ):Play()

            -- Clean up ripple
            task.delay(0.4, function()
                ripple:Destroy()
            end)

            if options.callback then
                options.callback()
            end
        end)

        return button
    end,

    Toggle = function(options)
        local container = ComponentFactory.new("Frame", {
            Size = Censura.Config.Layout.DefaultSize.Toggle,
            BackgroundTransparency = 1,
            Parent = options.parent
        })

        local label = Censura:Create("TextLabel", {
            Size = UDim2.new(1, -50, 1, 0),
            BackgroundTransparency = 1,
            Text = options.text or "Toggle",
            TextColor3 = Censura.Config.Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Censura.Config.Fonts.Text,
            TextSize = Censura.Config.Fonts.Size.Text,
            Parent = container.Instance
        })

        local toggleButton = Censura:Create("Frame", {
            Size = UDim2.new(0, 40, 0, 20),
            Position = UDim2.new(1, -40, 0.5, -10),
            BackgroundColor3 = Censura.Config.Theme.Error,
            Parent = container.Instance
        })

        local corner = Censura:Create("UICorner", {
            CornerRadius = Censura.Config.Layout.CornerRadius.Round,
            Parent = toggleButton
        })

        local knob = Censura:Create("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 2, 0.5, -8),
            BackgroundColor3 = Censura.Config.Theme.Text,
            Parent = toggleButton
        })

        Censura:Create("UICorner", {
            CornerRadius = Censura.Config.Layout.CornerRadius.Round,
            Parent = knob
        })

        -- Toggle state
        local enabled = options.default or false
        local function updateVisual()
            Services.TweenService:Create(toggleButton, 
                Censura.Config.Animation.Short,
                {BackgroundColor3 = enabled and Censura.Config.Theme.Success or Censura.Config.Theme.Error}
            ):Play()

            Services.TweenService:Create(knob,
                Censura.Config.Animation.Short,
                {Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}
            ):Play()
        end

        -- Initialize state
        updateVisual()

        -- Click handling
        toggleButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                enabled = not enabled
                updateVisual()
                if options.callback then
                    options.callback(enabled)
                end
            end
        end)

        return {
            Instance = container.Instance,
            SetValue = function(value)
                enabled = value
                updateVisual()
            end,
            GetValue = function()
                return enabled
            end
        }
    end
}

Components.Slider = function(options)
    local container = ComponentFactory.new("Frame", {
        Size = Censura.Config.Layout.DefaultSize.Slider,
        BackgroundTransparency = 1,
        Parent = options.parent
    })

    -- Header with value display
    local header = Censura:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Parent = container.Instance
    })

    local label = Censura:Create("TextLabel", {
        Size = UDim2.new(1, -45, 1, 0),
        BackgroundTransparency = 1,
        Text = options.text or "Slider",
        TextColor3 = Censura.Config.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Censura.Config.Fonts.Text,
        TextSize = Censura.Config.Fonts.Size.Text,
        Parent = header
    })

    local valueDisplay = Censura:Create("TextLabel", {
        Size = UDim2.new(0, 40, 1, 0),
        Position = UDim2.new(1, -40, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(options.default or options.min or 0),
        TextColor3 = Censura.Config.Theme.TextDark,
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = Censura.Config.Fonts.Mono,
        TextSize = Censura.Config.Fonts.Size.Text,
        Parent = header
    })

    -- Slider track
    local track = Censura:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 4),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Censura.Config.Theme.Secondary,
        Parent = container.Instance
    })

    Censura:Create("UICorner", {
        CornerRadius = Censura.Config.Layout.CornerRadius.Round,
        Parent = track
    })

    local fill = Censura:Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Censura.Config.Theme.Primary,
        Parent = track
    })

    Censura:Create("UICorner", {
        CornerRadius = Censura.Config.Layout.CornerRadius.Round,
        Parent = fill
    })

    local knob = Censura:Create("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, -8, 0.5, -8),
        BackgroundColor3 = Censura.Config.Theme.Primary,
        Parent = fill
    })

    Censura:Create("UICorner", {
        CornerRadius = Censura.Config.Layout.CornerRadius.Round,
        Parent = knob
    })

    -- Add shadow to knob
    local shadow = Censura:Create("ImageLabel", {
        Size = UDim2.new(1.5, 0, 1.5, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://7912134082",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.6,
        Parent = knob
    })

    -- Slider functionality
    local min = options.min or 0
    local max = options.max or 100
    local defaultValue = math.clamp(options.default or min, min, max)
    local dragging = false

    local function updateValue(input)
        local pos = input.Position
        local abs = track.AbsolutePosition
        local size = track.AbsoluteSize
        
        local relative = math.clamp((pos.X - abs.X) / size.X, 0, 1)
        local value = math.floor(min + (max - min) * relative)
        
        -- Update visual elements
        fill.Size = UDim2.new(relative, 0, 1, 0)
        valueDisplay.Text = tostring(value)
        
        -- Callback
        if options.callback then
            options.callback(value)
        end
        
        return value
    end

    -- Input handling
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateValue(input)
        end
    end)

    Services.UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateValue(input)
        end
    end)

    Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Dropdown component
    Components.Dropdown = function(options)
        local container = ComponentFactory.new("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Censura.Config.Theme.Secondary,
            Parent = options.parent
        })

        Censura:Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = container.Instance
        })

        local selected = Censura:Create("TextLabel", {
            Size = UDim2.new(1, -30, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = options.default or "Select...",
            TextColor3 = Censura.Config.Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Censura.Config.Fonts.Text,
            TextSize = Censura.Config.Fonts.Size.Text,
            Parent = container.Instance
        })

        local arrow = Censura:Create("ImageLabel", {
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(1, -20, 0.5, -6),
            BackgroundTransparency = 1,
            Image = "rbxassetid://6034818372",
            ImageColor3 = Censura.Config.Theme.TextDark,
            Parent = container.Instance
        })

        -- Dropdown list
        local listContainer = Censura:Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 1, 5),
            BackgroundColor3 = Censura.Config.Theme.Secondary,
            ClipsDescendants = true,
            Visible = false,
            Parent = container.Instance
        })

        Censura:Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = listContainer
        })

        local list = Censura:Create("ScrollingFrame", {
            Size = UDim2.new(1, -4, 1, -4),
            Position = UDim2.new(0, 2, 0, 2),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Censura.Config.Theme.Primary,
            Parent = listContainer
        })

        local layout = Censura:Create("UIListLayout", {
            Padding = UDim.new(0, 2),
            Parent = list
        })

        -- Add items
        local items = options.items or {}
        local expanded = false
        local selectedItem = options.default

        local function createItem(text)
            local item = Censura:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = Censura.Config.Theme.Secondary,
                Text = text,
                TextColor3 = Censura.Config.Theme.Text,
                Font = Censura.Config.Fonts.Text,
                TextSize = Censura.Config.Fonts.Size.Text,
                Parent = list
            })

            item.MouseButton1Click:Connect(function()
                selected.Text = text
                selectedItem = text
                
                -- Animate collapse
                Services.TweenService:Create(listContainer,
                    Censura.Config.Animation.Short,
                    {Size = UDim2.new(1, 0, 0, 0)}
                ):Play()
                
                expanded = false
                
                if options.callback then
                    options.callback(text)
                end
            end)

            return item
        end

        -- Populate items
        for _, item in ipairs(items) do
            createItem(item)
        end

        -- Toggle dropdown
        container.Instance.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                expanded = not expanded
                
                -- Animate arrow
                Services.TweenService:Create(arrow,
                    Censura.Config.Animation.Short,
                    {Rotation = expanded and 180 or 0}
                ):Play()
                
                -- Animate list
                listContainer.Visible = true
                Services.TweenService:Create(listContainer,
                    Censura.Config.Animation.Short,
                    {Size = UDim2.new(1, 0, expanded and #items * 32 + 4 or 0, 0)}
                ):Play()
            end
        end)

        return {
            Instance = container.Instance,
            SetValue = function(value)
                selected.Text = value
                selectedItem = value
            end,
            GetValue = function()
                return selectedItem
            end,
            AddItem = function(text)
                table.insert(items, text)
                createItem(text)
            end,
            RemoveItem = function(text)
                for i, item in ipairs(items) do
                    if item == text then
                        table.remove(items, i)
                        list:FindFirstChild(text):Destroy()
                        break
                    end
                end
            end
        }
    end

    -- Initialize slider value
    local initialRelative = (defaultValue - min) / (max - min)
    fill.Size = UDim2.new(initialRelative, 0, 1, 0)
    valueDisplay.Text = tostring(defaultValue)

    return {
        Instance = container.Instance,
        SetValue = function(value)
            local relative = (value - min) / (max - min)
            fill.Size = UDim2.new(relative, 0, 1, 0)
            valueDisplay.Text = tostring(value)
        end,
        GetValue = function()
            return tonumber(valueDisplay.Text)
        end
    }
end

-- Input Field component
Components.InputField = function(options)
    local container = ComponentFactory.new("Frame", {
        Size = Censura.Config.Layout.DefaultSize.Input,
        BackgroundColor3 = Censura.Config.Theme.Secondary,
        Parent = options.parent
    })

    Censura:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = container.Instance
    })

    local input = Censura:Create("TextBox", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = options.default or "",
        PlaceholderText = options.placeholder or "Enter text...",
        TextColor3 = Censura.Config.Theme.Text,
        PlaceholderColor3 = Censura.Config.Theme.TextDark,
        Font = Censura.Config.Fonts.Text,
        TextSize = Censura.Config.Fonts.Size.Text,
        ClearTextOnFocus = options.clearOnFocus ~= false,
        Parent = container.Instance
    })

    -- Add focus highlight
    local focusHighlight = Censura:Create("UIStroke", {
        Color = Censura.Config.Theme.Primary,
        Transparency = 1,
        Thickness = 1.5,
        Parent = container.Instance
    })

    input.Focused:Connect(function()
        Services.TweenService:Create(focusHighlight,
            Censura.Config.Animation.Short,
            {Transparency = 0}
        ):Play()
    end)

    input.FocusLost:Connect(function(enterPressed)
        Services.TweenService:Create(focusHighlight,
            Censura.Config.Animation.Short,
            {Transparency = 1}
        ):Play()

        if options.callback then
            options.callback(input.Text, enterPressed)
        end
    end)

    return {
        Instance = container.Instance,
        SetValue = function(value)
            input.Text = value
        end,
        GetValue = function()
            return input.Text
        end
    }
end

-- Add Components to Censura
Censura.Components = Components

-- Window Management System
function Censura:CreateWindow(options)
    local window = {
        Elements = {},
        Tabs = {},
        ActiveTab = nil,
        Visible = true,
        Dragging = false
    }

    -- Create main window frame
    window.Frame = Censura:Create("Frame", {
        Name = options.title or "Window",
        Size = options.size or UDim2.new(0, 500, 0, 350),
        Position = options.position or UDim2.new(0.5, -250, 0.5, -175),
        BackgroundColor3 = Censura.Config.Theme.Background,
        Parent = self.GUI
    })

    -- Add shadow
    local shadow = Censura:Create("ImageLabel", {
        Size = UDim2.new(1, 47, 1, 47),
        Position = UDim2.new(0, -24, 0, -24),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.5,
        Parent = window.Frame
    })

    -- Create title bar
    local titleBar = Censura:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Censura.Config.Theme.Primary,
        Parent = window.Frame
    })

    Censura:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = titleBar
    })

    local title = Censura:Create("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = options.title or "New Window",
        TextColor3 = Censura.Config.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Censura.Config.Fonts.Header,
        TextSize = Censura.Config.Fonts.Size.Header,
        Parent = titleBar
    })

    -- Window controls
    local controls = Censura:Create("Frame", {
        Size = UDim2.new(0, 90, 1, 0),
        Position = UDim2.new(1, -90, 0, 0),
        BackgroundTransparency = 1,
        Parent = titleBar
    })

    local minimizeBtn = Censura:Create("ImageButton", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 10, 0.5, -8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://7072719338",
        ImageColor3 = Censura.Config.Theme.Text,
        Parent = controls
    })

    local closeBtn = Censura:Create("ImageButton", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -26, 0.5, -8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://7072725342",
        ImageColor3 = Censura.Config.Theme.Text,
        Parent = controls
    })

    -- Tab system
    local tabContainer = Censura:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 35),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Censura.Config.Theme.Secondary,
        Parent = window.Frame
    })

    local tabList = Censura:Create("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = tabContainer
    })

    local tabLayout = Censura:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = tabList
    })

    -- Content container
    local contentContainer = Censura:Create("Frame", {
        Size = UDim2.new(1, -20, 1, -75),
        Position = UDim2.new(0, 10, 0, 65),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = window.Frame
    })

        -- Window Methods
    function window:AddTab(name)
        local tab = {
            Name = name,
            Content = Censura:Create("ScrollingFrame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Censura.Config.Theme.Primary,
                Visible = false,
                Parent = contentContainer
            }),
            Button = Censura:Create("TextButton", {
                Size = UDim2.new(0, 100, 1, -10),
                Position = UDim2.new(0, 0, 0, 5),
                BackgroundColor3 = Censura.Config.Theme.Secondary,
                Text = name,
                TextColor3 = Censura.Config.Theme.TextDark,
                Font = Censura.Config.Fonts.Text,
                TextSize = Censura.Config.Fonts.Size.Text,
                Parent = tabList
            })
        }
    
        -- Add layout to tab content
        local layout = Censura:Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            Parent = tab.Content
        })
    
        -- Add padding
        Censura:Create("UIPadding", {
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
            Parent = tab.Content
        })
    
        -- Create a function for tab selection logic
        local function selectTab()
            if window.ActiveTab then
                window.ActiveTab.Content.Visible = false
                window.ActiveTab.Button.BackgroundColor3 = Censura.Config.Theme.Secondary
                window.ActiveTab.Button.TextColor3 = Censura.Config.Theme.TextDark
            end
            
            window.ActiveTab = tab
            tab.Content.Visible = true
            
            Services.TweenService:Create(tab.Button,
                Censura.Config.Animation.Short,
                {
                    BackgroundColor3 = Censura.Config.Theme.Primary,
                    TextColor3 = Censura.Config.Theme.Text
                }
            ):Play()
        end
    
        -- Connect the selection logic to the button
        tab.Button.MouseButton1Click:Connect(selectTab)
    
        -- Add corner to button
        Censura:Create("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = tab.Button
        })
    
        -- Store tab
        window.Tabs[name] = tab
        
        -- Select first tab automatically
        if not window.ActiveTab then
            selectTab()
        end
    
        return tab
    end

    -- Window dragging
    local dragging, dragInput, dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Services.UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    Services.RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            window.Frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Window controls functionality
    local minimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        
        Services.TweenService:Create(window.Frame,
            Censura.Config.Animation.Medium,
            {Size = minimized and UDim2.new(0, 500, 0, 30) or options.size or UDim2.new(0, 500, 0, 350)}
        ):Play()
    end)

    closeBtn.MouseButton1Click:Connect(function()
        Services.TweenService:Create(window.Frame,
            Censura.Config.Animation.Medium,
            {
                Size = UDim2.new(0, window.Frame.Size.X.Offset, 0, 0),
                Position = UDim2.new(
                    window.Frame.Position.X.Scale,
                    window.Frame.Position.X.Offset,
                    window.Frame.Position.Y.Scale + 0.5,
                    window.Frame.Position.Y.Offset
                )
            }
        ):Play()
        
        task.wait(0.3)
        window.Frame:Destroy()
    end)

    return window
end

-- Initialization and Cleanup Systems
function Censura:Initialize()
    -- Create main GUI container
    self.GUI = Censura:Create("ScreenGui", {
        Name = "CensuraUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    -- Try to parent to CoreGui (exploits) or PlayerGui
    local success, error = pcall(function()
        if syn and syn.protect_gui then -- Synapse X support
            syn.protect_gui(self.GUI)
            self.GUI.Parent = Services.CoreGui
        elseif protect_gui then -- Other exploit support
            protect_gui(self.GUI)
            self.GUI.Parent = Services.CoreGui
        else -- Regular game support
            self.GUI.Parent = Services.Players.LocalPlayer:WaitForChild("PlayerGui")
        end
    end)

    if not success then
        warn("[Censura] Failed to parent GUI:", error)
        self.GUI.Parent = Services.Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Create notification system
    self.NotificationSystem = {
        Container = Censura:Create("Frame", {
            Name = "Notifications",
            Size = UDim2.new(0, 300, 1, 0),
            Position = UDim2.new(1, -310, 0, 0),
            BackgroundTransparency = 1,
            Parent = self.GUI
        }),
        Queue = {},
        Active = {}
    }

    -- Add layout for notifications
    local notifLayout = Censura:Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Parent = self.NotificationSystem.Container
    })

    -- Initialize keybind system
    self.KeybindSystem = {
        Binds = {},
        Active = true
    }

    -- Setup global toggle keybind
    Services.UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == self.Config.ToggleKey then
            self:ToggleUI()
        end
    end)

    -- Example usage:
    --[[
        Censura:Initialize()
        
        -- Create a window
        local window = Censura:CreateWindow({
            title = "Example Window",
            size = UDim2.new(0, 500, 0, 350)
        })
        
        -- Show a notification
        Censura:Notify({
            title = "Initialization Complete",
            message = "UI system is ready to use!",
            duration = 3
        })
    ]]

    return self
end

-- Notification System
function Censura:Notify(options)
    local notification = {
        Frame = Censura:Create("Frame", {
            Size = UDim2.new(1, -10, 0, 0), -- Will be tweened
            BackgroundColor3 = Censura.Config.Theme.Secondary,
            BackgroundTransparency = 1,
            Parent = self.NotificationSystem.Container
        })
    }

    -- Add corner
    Censura:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = notification.Frame
    })

    -- Create content
    local content = Censura:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 80),
        BackgroundTransparency = 1,
        Parent = notification.Frame
    })

    local title = Censura:Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 24),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = options.title or "Notification",
        TextColor3 = Censura.Config.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Censura.Config.Fonts.Header,
        TextSize = Censura.Config.Fonts.Size.Header,
        Parent = content
    })

    local message = Censura:Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 36),
        Position = UDim2.new(0, 10, 0, 34),
        BackgroundTransparency = 1,
        Text = options.message or "",
        TextColor3 = Censura.Config.Theme.TextDark,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Font = Censura.Config.Fonts.Text,
        TextSize = Censura.Config.Fonts.Size.Text,
        Parent = content
    })

    -- Progress bar
    local progressBar = Censura:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Censura.Config.Theme.Primary,
        Parent = notification.Frame
    })

    -- Animate in
    notification.Frame.Size = UDim2.new(1, -10, 0, 80)
    Services.TweenService:Create(notification.Frame,
        Censura.Config.Animation.Medium,
        {BackgroundTransparency = 0}
    ):Play()

    -- Progress bar animation
    local duration = options.duration or 3
    Services.TweenService:Create(progressBar,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0, 0, 0, 2)}
    ):Play()

    -- Cleanup
    task.delay(duration, function()
        Services.TweenService:Create(notification.Frame,
            Censura.Config.Animation.Medium,
            {
                BackgroundTransparency = 1,
                Position = UDim2.new(1, 0, 0, notification.Frame.Position.Y.Offset)
            }
        ):Play()
        
        task.wait(0.3)
        notification.Frame:Destroy()
    end)

    return notification
end

-- Global UI Toggle
function Censura:ToggleUI()
    self.Active.UIVisible = not self.Active.UIVisible
    
    for _, window in ipairs(self.Windows) do
        if window.Frame then
            Services.TweenService:Create(window.Frame,
                Censura.Config.Animation.Short,
                {
                    BackgroundTransparency = self.Active.UIVisible and 0 or 1,
                    Position = self.Active.UIVisible and 
                        window.Frame.Position or 
                        UDim2.new(window.Frame.Position.X.Scale, window.Frame.Position.X.Offset, 1.5, 0)
                }
            ):Play()
        end
    end
end

-- Cleanup
function Censura:Destroy()
    -- Cleanup connections
    for _, connection in ipairs(self.Active.Connections) do
        connection:Disconnect()
    end

    -- Cleanup notifications
    for _, notification in ipairs(self.NotificationSystem.Active) do
        if notification.Frame then
            notification.Frame:Destroy()
        end
    end

    -- Cleanup windows
    for _, window in ipairs(self.Windows) do
        if window.Frame then
            window.Frame:Destroy()
        end
    end

    -- Remove GUI
    if self.GUI then
        self.GUI:Destroy()
    end

    -- Clear tables
    table.clear(self.Active.Elements)
    table.clear(self.Active.Connections)
    table.clear(self.Active.Debris)
    table.clear(self.Windows)
end

-- Initialization System
function Censura:Initialize()
    -- Create main GUI container
    self.GUI = self:Create("ScreenGui", {
        Name = "CensuraUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    -- Try to parent to CoreGui (exploits) or PlayerGui
    local success, error = pcall(function()
        -- Synapse X support
        if syn and syn.protect_gui then
            syn.protect_gui(self.GUI)
            self.GUI.Parent = Services.CoreGui
        -- Other exploit support
        elseif protect_gui then
            protect_gui(self.GUI)
            self.GUI.Parent = Services.CoreGui
        -- Regular game support
        else
            self.GUI.Parent = Services.Players.LocalPlayer:WaitForChild("PlayerGui")
        end
    end)

    if not success then
        warn("[Censura] GUI Parenting failed:", error)
        self.GUI.Parent = Services.Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Initialize notification system
    self.NotificationSystem = {
        Container = self:Create("Frame", {
            Name = "Notifications",
            Size = UDim2.new(0, 300, 1, 0),
            Position = UDim2.new(1, -310, 0, 0),
            BackgroundTransparency = 1,
            Parent = self.GUI
        }),
        Queue = {},
        Active = {}
    }

    -- Add notification layout
    self:Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Parent = self.NotificationSystem.Container
    })

    -- Setup global toggle keybind
    local connection = Services.UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == self.Config.ToggleKey then
            self:ToggleUI()
        end
    end)
    table.insert(self.Active.Connections, connection)

    return self
end

return Censura
