-- Core/Elements/Window.lua
local Window = {}

local Utils = _G.Censura.Modules.Utils
local Styles = _G.Censura.Modules.Styles

function Window.new(options)
    options = options or {}
    
    -- Main window frame
    local window = Utils.Create("Frame", {
        Size = options.size or UDim2.new(0, 300, 0, 400),
        Position = options.position or UDim2.new(0.5, -150, 0.5, -200),
        BackgroundColor3 = Styles.Colors.Window.Background,
        Visible = false, -- Start invisible for fade effect
    })
    Utils.ApplyCorners(window)
    Utils.CreateShadow(window)
    
    -- Title bar
    local titleBar = Utils.Create("Frame", {
        Size = UDim2.new(1, 0, 0, Styles.Layout.Window.TitleBarHeight),
        BackgroundColor3 = Styles.Colors.Window.TitleBar,
        Parent = window
    })
    Utils.ApplyCorners(titleBar)
    Utils.MakeDraggable(titleBar, window)
    
    -- Title text
    local title = Utils.Create("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = options.title or "Window",
        TextColor3 = Styles.Colors.Text.Primary,
        Font = Styles.Text.Title.Font,
        TextSize = Styles.Text.Title.Size,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar
    })
    
    -- Control buttons
    local controlButtons = Utils.Create("Frame", {
        Size = UDim2.new(0, 60, 1, -10),
        Position = UDim2.new(1, -65, 0, 5),
        BackgroundTransparency = 1,
        Parent = titleBar
    })
    
    -- Minimize button
    local minimizeBtn = Utils.Create("TextButton", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Styles.Colors.Status.Warning,
        Text = "",
        Parent = controlButtons
    })
    Utils.ApplyCorners(minimizeBtn, 10)
    
    -- Close button
    local closeBtn = Utils.Create("TextButton", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -20, 0, 0),
        BackgroundColor3 = Styles.Colors.Status.Error,
        Text = "",
        Parent = controlButtons
    })
    Utils.ApplyCorners(closeBtn, 10)
    
    -- Content container
    local content = Utils.Create("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -(Styles.Layout.Window.TitleBarHeight + 10)),
        Position = UDim2.new(0, 10, 0, Styles.Layout.Window.TitleBarHeight + 5),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Styles.Colors.Controls.ScrollBar.Bar,
        Parent = window
    })
    
    -- Setup auto-sizing content
    Utils.SetupListLayout(content)
    
    -- Window functionality
    local minimized = false
    local originalSize = window.Size
    
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        local targetSize = minimized and 
            UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, Styles.Layout.Window.TitleBarHeight) or
            originalSize
            
        Utils.Tween(window, {Size = targetSize}, Styles.Animation.Short)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        Utils.Tween(window, {
            BackgroundTransparency = 1,
            Position = window.Position + UDim2.new(0, 0, 0, -20)
        }, Styles.Animation.Short).Completed:Connect(function()
            window:Destroy()
        end)
    end)
    
    -- Show window with fade effect
    window.BackgroundTransparency = 1
    window.Visible = true
    Utils.Tween(window, {BackgroundTransparency = 0}, Styles.Animation.Medium)
    
    return window, content
end

return Window
