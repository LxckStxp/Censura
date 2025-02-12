# Censura UI Library
A modern, feature-rich UI library for Roblox games with smooth animations, consistent styling, and extensive customization options.

## Table of Contents
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Components](#components)
  - [Window](#window)
  - [TabSystem](#tabsystem)
  - [Section](#section)
  - [Button](#button)
  - [Toggle](#toggle)
  - [Slider](#slider)
  - [Input](#input)
  - [Keybind](#keybind)
  - [ColorPicker](#colorpicker)
  - [List](#list)
  - [Notification](#notification)
- [Styling](#styling)
- [Examples](#examples)

## Installation
Load the library into your game:
```lua
local Censura = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/Censura.lua"))()

Quick Start
Create a basic window with some controls:
-- Create a window
local window = Censura.Elements.Window.new({
    title = "My Window",
    size = UDim2.new(0, 400, 0, 500)
})

-- Add a tab system
local tabs = Censura.Elements.TabSystem.new()
tabs.Parent = window.content

-- Create tabs
local mainTab = tabs:AddTab("Main")
local settingsTab = tabs:AddTab("Settings")

-- Add a section to the main tab
local section = Censura.Elements.Section.new({
    title = "Controls"
})
section.Parent = mainTab

-- Add some controls
Censura.Elements.Button.new({
    text = "Click Me!",
    onClick = function()
        Censura.Elements.Notification.Success("Button clicked!")
    end
}).Parent = section

Censura.Elements.Toggle.new({
    text = "Enable Feature",
    onToggle = function(enabled)
        print("Feature:", enabled)
    end
}).Parent = section

Components

Window
Create a draggable window with title bar and content area:
local window = Censura.Elements.Window.new({
    title = "Window Title",
    size = UDim2.new(0, 400, 0, 500),
    position = UDim2.new(0.5, -200, 0.5, -250)
})

TabSystem
Organize content into tabs:
local tabs = Censura.Elements.TabSystem.new()
local mainTab = tabs:AddTab("Main")
local settingsTab = tabs:AddTab("Settings")

-- Switch tabs programmatically
tabs:SelectTab("Settings")

Section
Group related controls:
local section = Censura.Elements.Section.new({
    title = "Section Title"
})

-- Add elements to section
section:AddElement(Censura.Elements.Button.new({
    text = "Button"
}))

Button
Create clickable buttons:
Censura.Elements.Button.new({
    text = "Click Me",
    onClick = function()
        print("Button clicked!")
    end
})

Toggle
Create toggleable switches:
Censura.Elements.Toggle.new({
    text = "Enable Feature",
    default = false,
    onToggle = function(enabled)
        print("Toggle:", enabled)
    end
})

Slider
Create value sliders:
Censura.Elements.Slider.new({
    text = "Speed",
    min = 0,
    max = 100,
    default = 50,
    onValueChanged = function(value)
        print("Value:", value)
    end
})

Input
Create text input fields:
Censura.Elements.Input.new({
    text = "Username",
    placeholder = "Enter username...",
    onTextChanged = function(text, enterPressed)
        if enterPressed then
            print("Input submitted:", text)
        end
    end
})

Keybind
Create keyboard shortcuts:
Censura.Elements.Keybind.new({
    text = "Toggle UI",
    default = Enum.KeyCode.RightControl,
    onBind = function(key)
        print("New keybind:", key.Name)
    end
})

ColorPicker
Create color selection controls:
Censura.Elements.ColorPicker.new({
    text = "UI Color",
    default = Color3.fromRGB(255, 0, 0),
    onColorChanged = function(color)
        print("New color:", color)
    end
})

List
Create scrollable lists:
Censura.Elements.List.new({
    title = "Players",
    items = {"Player1", "Player2", "Player3"},
    onSelect = function(item)
        print("Selected:", item)
    end
})

Notification
Show temporary notifications:
-- Quick notifications
Censura.Elements.Notification.Success("Operation completed!")
Censura.Elements.Notification.Error("Something went wrong!")
Censura.Elements.Notification.Warning("Be careful!")
Censura.Elements.Notification.Info("Did you know?")

-- Custom notification
Censura.Elements.Notification.new({
    type = "success",
    title = "Custom Title",
    message = "Custom message",
    duration = 3
})

Styling
The library uses a consistent styling system defined in Styles.lua. You can access and modify styles through:
local Styles = Censura.Modules.Styles

-- Example: Change primary color
Styles.Colors.Primary.Main = Color3.fromRGB(0, 255, 0)

Examples

Complete UI Example
local window = Censura.Elements.Window.new({
    title = "Game Settings"
})

local tabs = Censura.Elements.TabSystem.new()
tabs.Parent = window.content

-- Main Settings Tab
local mainTab = tabs:AddTab("Settings")
local settingsSection = Censura.Elements.Section.new({
    title = "Game Settings"
})
settingsSection.Parent = mainTab

-- Add controls
Censura.Elements.Toggle.new({
    text = "Enable Sounds",
    default = true,
    onToggle = function(enabled)
        -- Handle sound toggle
    end
}).Parent = settingsSection

Censura.Elements.Slider.new({
    text = "Volume",
    min = 0,
    max = 100,
    default = 50,
    onValueChanged = function(value)
        -- Handle volume change
    end
}).Parent = settingsSection

-- Player Tab
local playerTab = tabs:AddTab("Player")
local playerSection = Censura.Elements.Section.new({
    title = "Player Settings"
})
playerSection.Parent = playerTab

-- Add player controls
Censura.Elements.ColorPicker.new({
    text = "Player Color",
    default = Color3.fromRGB(255, 255, 255),
    onColorChanged = function(color)
        -- Handle color change
    end
}).Parent = playerSection

Notification System Example
-- Show a success notification when saving
local saveButton = Censura.Elements.Button.new({
    text = "Save Settings",
    onClick = function()
        -- Save logic here
        Censura.Elements.Notification.Success("Settings saved successfully!")
    end
})

-- Show an error notification
local function handleError()
    Censura.Elements.Notification.Error("Failed to save settings", "Save Error")
end

-- Show a warning notification
local function handleWarning()
    Censura.Elements.Notification.Warning("Low disk space")
end

For more examples and detailed documentation, visit the Wiki.
