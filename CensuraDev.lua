--[[
    Censura UI System v2.1.0
    Author: LxckStxp
    Modern UI Framework for Roblox
]]

-- Load Components module
local Components = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraComponents.lua"))()

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
    self._suspended = false
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
    window.Frame = self:Create("Frame", {
        Name = options.title or "Window",
        Size = options.size or UDim2.new(0, 500, 0, 350),
        Position = options.position or UDim2.new(0.5, -250, 0.5, -175),
        BackgroundColor3 = self.Config.Theme.Background,
        Parent = self.GUI
    })

    -- Add shadow
    local shadow = self:Create("ImageLabel", {
        Size = UDim2.new(1, 47, 1, 47),
        Position = UDim2.new(0, -24, 0, -24),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.5,
        Parent = window.Frame
    })

    -- Create title bar
    local titleBar = self:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = self.Config.Theme.Primary,
        Parent = window.Frame
    })

    self:Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = titleBar
    })

    local title = self:Create("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = options.title or "New Window",
        TextColor3 = self.Config.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = self.Config.Fonts.Header,
        TextSize = self.Config.Fonts.Size.Header,
        Parent = titleBar
    })

    -- Window controls
    local controls = self:Create("Frame", {
        Size = UDim2.new(0, 90, 1, 0),
        Position = UDim2.new(1, -90, 0, 0),
        BackgroundTransparency = 1,
        Parent = titleBar
    })

    local minimizeBtn = self:Create("ImageButton", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 10, 0.5, -8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://7072719338",
        ImageColor3 = self.Config.Theme.Text,
        Parent = controls
    })

    local closeBtn = self:Create("ImageButton", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -26, 0.5, -8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://7072725342",
        ImageColor3 = self.Config.Theme.Text,
        Parent = controls
    })

    -- Tab system
    local tabContainer = self:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 35),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = self.Config.Theme.Secondary,
        Parent = window.Frame
    })

    local tabList = self:Create("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = tabContainer
    })

    local tabLayout = self:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = tabList
    })

    -- Content container
    local contentContainer = self:Create("Frame", {
        Size = UDim2.new(1, -20, 1, -75),
        Position = UDim2.new(0, 10, 0, 65),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = window.Frame
    })

    -- Tab creation method
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

        -- Add component methods to tab
        function tab:AddToggle(options)
            options.parent = self.Content
            return Components.Initialize(Censura, Services).Toggle(options)
        end

        function tab:AddSlider(options)
            options.parent = self.Content
            return Components.Initialize(Censura, Services).Slider(options)
        end

        function tab:AddButton(options)
            options.parent = self.Content
            return Components.Initialize(Censura, Services).Button(options)
        end

        function tab:AddDropdown(options)
            options.parent = self.Content
            return Components.Initialize(Censura, Services).Dropdown(options)
        end

        function tab:AddInputField(options)
            options.parent = self.Content
            return Components.Initialize(Censura, Services).InputField(options)
        end

        -- Tab content layout
        local layout = Censura:Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            Parent = tab.Content
        })

        Censura:Create("UIPadding", {
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
            Parent = tab.Content
        })

        -- Tab selection logic
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

        -- Connect tab button
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

        -- Window dragging implementation
    local dragging, dragInput, dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Frame.Position
            
            -- Track input ending
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
            
            -- Add to active connections for cleanup
            table.insert(self.Active.Connections, connection)
        end
    end)

    -- Handle drag input
    local dragConnection = Services.UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    table.insert(self.Active.Connections, dragConnection)

    -- Update drag position
    local updateDragConnection = Services.RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            local targetPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )

            -- Smooth drag animation
            Services.TweenService:Create(window.Frame,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad),
                {Position = targetPos}
            ):Play()
        end
    end)
    table.insert(self.Active.Connections, updateDragConnection)

    -- Window controls functionality
    local minimized = false
    local originalSize = options.size or UDim2.new(0, 500, 0, 350)
    
    -- Minimize button functionality
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        
        -- Store content visibility state
        local contentVisible = contentContainer.Visible
        
        -- Animate window size
        local targetSize = minimized and UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 30) or originalSize
        
        -- Animate minimize
        Services.TweenService:Create(window.Frame,
            self.Config.Animation.Medium,
            {Size = targetSize}
        ):Play()
        
        -- Handle content visibility
        if minimized then
            contentContainer.Visible = false
            tabContainer.Visible = false
        else
            task.delay(0.2, function()
                contentContainer.Visible = true
                tabContainer.Visible = true
            end)
        end
        
        -- Minimize button rotation animation
        Services.TweenService:Create(minimizeBtn,
            self.Config.Animation.Short,
            {Rotation = minimized and 180 or 0}
        ):Play()
    end)

    -- Close button functionality with animation
    closeBtn.MouseButton1Click:Connect(function()
        -- Animate window closing
        local closeSequence = function()
            -- Fade out animation
            local fadeTween = Services.TweenService:Create(window.Frame,
                self.Config.Animation.Medium,
                {
                    Size = UDim2.new(0, window.Frame.Size.X.Offset, 0, 0),
                    Position = UDim2.new(
                        window.Frame.Position.X.Scale,
                        window.Frame.Position.X.Offset,
                        window.Frame.Position.Y.Scale + 0.5,
                        window.Frame.Position.Y.Offset
                    ),
                    BackgroundTransparency = 1
                }
            )
            
            -- Fade out all children
            for _, child in ipairs(window.Frame:GetDescendants()) do
                if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("ImageLabel") then
                    Services.TweenService:Create(child,
                        self.Config.Animation.Medium,
                        {BackgroundTransparency = 1, TextTransparency = 1, ImageTransparency = 1}
                    ):Play()
                end
            end
            
            fadeTween:Play()
            fadeTween.Completed:Wait()
            
            -- Clean up
            window.Frame:Destroy()
            
            -- Remove from windows table
            for i, w in ipairs(self.Windows) do
                if w == window then
                    table.remove(self.Windows, i)
                    break
                end
            end
            
            -- Fire window destroyed signal
            self.Signals.WindowDestroyed:Fire(window)
        end
        
        task.spawn(closeSequence)
    end)
    
    -- Store window reference
    table.insert(self.Windows, window)
    
    -- Fire window created signal
    self.Signals.WindowCreated:Fire(window)
    
    return window
end  -- This ends the CreateWindow function

-- Initialize Censura
function Censura:Initialize()
    -- Create main GUI container with protection handling
    self.GUI = self:Create("ScreenGui", {
        Name = "CensuraUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    -- Protected GUI handling for different exploit environments
    local success, error = pcall(function()
        if syn and syn.protect_gui then 
            -- Synapse X protection
            syn.protect_gui(self.GUI)
            self.GUI.Parent = Services.CoreGui
        elseif protect_gui then 
            -- Other exploit protection
            protect_gui(self.GUI)
            self.GUI.Parent = Services.CoreGui
        else 
            -- Standard game environment
            self.GUI.Parent = Services.Players.LocalPlayer:WaitForChild("PlayerGui")
        end
    end)

    if not success then
        self.Debug:Log("GUI Parenting failed: " .. tostring(error), 1)
        -- Fallback parenting
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

    -- Notification layout
    self:Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Parent = self.NotificationSystem.Container
    })

    -- Initialize component system
    self.Components = Components.Initialize(self, Services)

    -- Setup global toggle keybind
    local toggleConnection = Services.UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == self.Config.ToggleKey then
            self:ToggleUI()
        end
    end)
    table.insert(self.Active.Connections, toggleConnection)

    -- Initialize UI visibility state
    self.Active.UIVisible = true

    return self
end

-- UI Visibility Toggle
function Censura:ToggleUI()
    self.Active.UIVisible = not self.Active.UIVisible
    
    -- Animate all windows
    for _, window in ipairs(self.Windows) do
        if window.Frame then
            -- Create smooth fade animation
            Services.TweenService:Create(window.Frame,
                self.Config.Animation.Short,
                {
                    BackgroundTransparency = self.Active.UIVisible and 0 or 1,
                    Position = self.Active.UIVisible and 
                        window.Frame.Position or 
                        UDim2.new(window.Frame.Position.X.Scale, window.Frame.Position.X.Offset, 1.5, 0)
                }
            ):Play()

            -- Fade all elements
            for _, element in ipairs(window.Frame:GetDescendants()) do
                if element:IsA("Frame") or element:IsA("TextLabel") or 
                   element:IsA("TextButton") or element:IsA("ImageLabel") then
                    Services.TweenService:Create(element,
                        self.Config.Animation.Short,
                        {
                            BackgroundTransparency = self.Active.UIVisible and 
                                element.BackgroundTransparency or 1,
                            TextTransparency = self.Active.UIVisible and 0 or 1,
                            ImageTransparency = self.Active.UIVisible and 0 or 1
                        }
                    ):Play()
                end
            end
        end
    end

    -- Fire visibility changed signal
    self.Signals.VisibilityChanged:Fire(self.Active.UIVisible)
end

-- Cleanup System
function Censura:Destroy()
    -- Cleanup active connections
    for _, connection in ipairs(self.Active.Connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end

    -- Cleanup notifications
    for _, notification in ipairs(self.NotificationSystem.Active) do
        if notification.Frame then
            notification.Frame:Destroy()
        end
    end

    -- Cleanup windows with animation
    for _, window in ipairs(self.Windows) do
        if window.Frame then
            -- Fade out animation
            Services.TweenService:Create(window.Frame,
                self.Config.Animation.Medium,
                {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(
                        window.Frame.Position.X.Scale,
                        window.Frame.Position.X.Offset,
                        1.5,
                        0
                    )
                }
            ):Play()
            
            task.delay(0.3, function()
                window.Frame:Destroy()
            end)
        end
    end

    -- Cleanup main GUI
    if self.GUI then
        self.GUI:Destroy()
    end

    -- Clear all tables
    table.clear(self.Active.Elements)
    table.clear(self.Active.Connections)
    table.clear(self.Active.Debris)
    table.clear(self.Windows)
    
    -- Clear signals
    for _, signal in pairs(self.Signals) do
        signal:Destroy()
    end
end

return Censura
