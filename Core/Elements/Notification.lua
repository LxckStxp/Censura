-- Core/Elements/Notification.lua
local Notification = {}

local TweenService = game:GetService("TweenService")
local Utils = _G.Censura.Modules.Utils
local Styles = _G.Censura.Modules.Styles

-- Constants for notification positioning and timing
local NOTIFICATION_HEIGHT = 65
local NOTIFICATION_WIDTH = 280
local NOTIFICATION_PADDING = 10
local DEFAULT_DURATION = 3
local SLIDE_DURATION = 0.4
local FADE_DURATION = 0.3

-- Track active notifications
local activeNotifications = {}

-- Get notification icon based on type
local NOTIFICATION_ICONS = {
    success = "rbxassetid://9073052584", -- Green checkmark
    error = "rbxassetid://9072944922",   -- Red X
    warning = "rbxassetid://9072448788", -- Yellow triangle
    info = "rbxassetid://9072464832"     -- Blue circle
}

-- Get notification colors based on type
local NOTIFICATION_COLORS = {
    success = Styles.Colors.Status.Success,
    error = Styles.Colors.Status.Error,
    warning = Styles.Colors.Status.Warning,
    info = Styles.Colors.Status.Info
}

function Notification.new(options)
    options = options or {}
    local notifType = options.type or "info"
    local duration = options.duration or DEFAULT_DURATION
    
    -- Create notification container
    local notification = Utils.Create("Frame", {
        Size = UDim2.new(0, NOTIFICATION_WIDTH, 0, NOTIFICATION_HEIGHT),
        Position = UDim2.new(1, NOTIFICATION_WIDTH, 1, 0), -- Start off screen
        BackgroundColor3 = Styles.Colors.Window.Background,
        Parent = _G.Censura.GUI -- Assuming this is our main GUI container
    })
    Utils.ApplyCorners(notification)
    Utils.CreateShadow(notification)
    
    -- Create accent bar
    local accentBar = Utils.Create("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = NOTIFICATION_COLORS[notifType],
        Parent = notification
    })
    Utils.ApplyCorners(accentBar)
    
    -- Create icon
    local icon = Utils.Create("ImageLabel", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 15, 0, 8),
        BackgroundTransparency = 1,
        Image = NOTIFICATION_ICONS[notifType],
        ImageColor3 = NOTIFICATION_COLORS[notifType],
        Parent = notification
    })
    
    -- Create title
    local title = Utils.Create("TextLabel", {
        Size = UDim2.new(1, -55, 0, 20),
        Position = UDim2.new(0, 45, 0, 10),
        BackgroundTransparency = 1,
        Text = options.title or "Notification",
        TextColor3 = Styles.Colors.Text.Primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Styles.Text.Header.Font,
        TextSize = Styles.Text.Header.Size,
        Parent = notification
    })
    
    -- Create message
    local message = Utils.Create("TextLabel", {
        Size = UDim2.new(1, -55, 0, 20),
        Position = UDim2.new(0, 45, 0, 35),
        BackgroundTransparency = 1,
        Text = options.message or "",
        TextColor3 = Styles.Colors.Text.Secondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Styles.Text.Default.Font,
        TextSize = Styles.Text.Default.Size,
        Parent = notification
    })
    
    -- Create progress bar
    local progressBar = Utils.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = NOTIFICATION_COLORS[notifType],
        Parent = notification
    })
    
    -- Close button
    local closeButton = Utils.Create("ImageButton", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -25, 0, 8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://9072944922",
        ImageColor3 = Styles.Colors.Text.Secondary,
        Parent = notification
    })
    
    -- Handle notification positioning
    local function updateNotificationPositions()
        local yOffset = NOTIFICATION_PADDING
        for i = #activeNotifications, 1, -1 do
            local notif = activeNotifications[i]
            if notif and notif.Instance then
                Utils.Tween(notif.Instance, {
                    Position = UDim2.new(1, -NOTIFICATION_WIDTH - NOTIFICATION_PADDING, 1, -NOTIFICATION_HEIGHT - yOffset)
                }, TweenInfo.new(SLIDE_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
                yOffset = yOffset + NOTIFICATION_HEIGHT + NOTIFICATION_PADDING
            end
        end
    end
    
    -- Add to active notifications
    table.insert(activeNotifications, {
        Instance = notification,
        StartTime = tick()
    })
    updateNotificationPositions()
    
    -- Animate progress bar
    Utils.Tween(progressBar, {
        Size = UDim2.new(0, 0, 0, 2)
    }, TweenInfo.new(duration, Enum.EasingStyle.Linear))
    
    -- Close notification function
    local function closeNotification()
        -- Find and remove from active notifications
        for i, notif in ipairs(activeNotifications) do
            if notif.Instance == notification then
                table.remove(activeNotifications, i)
                break
            end
        end
        
        -- Animate out
        Utils.Tween(notification, {
            Position = UDim2.new(1, NOTIFICATION_WIDTH, notification.Position.Y.Scale, notification.Position.Y.Offset),
            BackgroundTransparency = 1
        }, TweenInfo.new(FADE_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)).Completed:Connect(function()
            notification:Destroy()
            updateNotificationPositions()
        end)
    end
    
    -- Setup close button
    closeButton.MouseButton1Click:Connect(closeNotification)
    
    -- Auto close after duration
    task.delay(duration, closeNotification)
    
    return notification
end

-- Helper functions for common notification types
function Notification.Success(message, title)
    return Notification.new({
        type = "success",
        title = title or "Success",
        message = message,
        duration = 3
    })
end

function Notification.Error(message, title)
    return Notification.new({
        type = "error",
        title = title or "Error",
        message = message,
        duration = 5
    })
end

function Notification.Warning(message, title)
    return Notification.new({
        type = "warning",
        title = title or "Warning",
        message = message,
        duration = 4
    })
end

function Notification.Info(message, title)
    return Notification.new({
        type = "info",
        title = title or "Information",
        message = message,
        duration = 3
    })
end

return Notification
