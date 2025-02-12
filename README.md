# Censura UI Library 🎨

> A sleek, modern UI library for Roblox games featuring smooth animations, consistent styling, and extensive customization options.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## 📋 Table of Contents

- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Features](#-features)
- [Components](#-components)
- [Window](#window)
- [TabSystem](#tabsystem)
- [Section](#section)
- [Controls](#controls)
- [Styling System](#-styling-system)
- [Examples](#-examples)
- [API Reference](#-api-reference)

## 📥 Installation

Load the library into your game:

```lua
local Censura = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/Censura.lua"))()
```

## 🚀 Quick Start

Create your first window with basic controls:

```lua
-- Initialize a window
local window = Censura.Elements.Window.new({
    title = "My First Window",
    size = UDim2.new(0, 400, 0, 500)
})

-- Create a tab system
local tabs = Censura.Elements.TabSystem.new()
tabs.Parent = window.content

-- Add some tabs
local mainTab = tabs:AddTab("Main")
local settingsTab = tabs:AddTab("Settings")

-- Create a section
local section = Censura.Elements.Section.new({
    title = "Quick Actions"
})
section.Parent = mainTab

-- Add interactive elements
Censura.Elements.Button.new({
    text = "Click Me!",
    onClick = function()
        Censura.Elements.Notification.Success("Hello, World!")
    end
}).Parent = section
```

## ✨ Features

- 🎨 Modern, customizable UI elements
- 📱 Responsive design
- 🔄 Smooth animations
- 🎯 Easy-to-use API
- 🛠️ Extensive component library
- 📦 Modular architecture
- 🎮 Gaming-focused design

## 📦 Components

### Window

The foundation of your UI:

```lua
local window = Censura.Elements.Window.new({
    title = "Game Settings",
    size = UDim2.new(0, 400, 0, 500),
    position = UDim2.new(0.5, -200, 0.5, -250)
})
```

### TabSystem

Organize your content:

```lua
local tabs = Censura.Elements.TabSystem.new()
local mainTab = tabs:AddTab("Main")
local settingsTab = tabs:AddTab("Settings")

-- Switch tabs programmatically
tabs:SelectTab("Settings")
```

### Section

Group related controls:

```lua
local section = Censura.Elements.Section.new({
    title = "Player Settings"
})
```

### Controls

#### Button

```lua
Censura.Elements.Button.new({
    text = "Save Settings",
    onClick = function()
        Censura.Elements.Notification.Success("Settings saved!")
    end
})
```

#### Toggle

```lua
Censura.Elements.Toggle.new({
    text = "Enable Flight",
    default = false,
    onToggle = function(enabled)
        local player = game.Players.LocalPlayer
        player.Character.Humanoid:ChangeState(enabled and "Flying" or "Landing")
    end
})
```

#### Slider

```lua
Censura.Elements.Slider.new({
    text = "Walk Speed",
    min = 16,
    max = 100,
    default = 16,
    onValueChanged = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})
```

#### Input

```lua
Censura.Elements.Input.new({
    text = "Display Name",
    placeholder = "Enter your name...",
    onTextChanged = function(text, enterPressed)
        if enterPressed then
            game.Players.LocalPlayer.DisplayName = text
        end
    end
})
```

#### Keybind

```lua
Censura.Elements.Keybind.new({
    text = "Toggle UI",
    default = Enum.KeyCode.RightControl,
    onBind = function(key)
        print("UI will now toggle with", key.Name)
    end
})
```

#### ColorPicker

```lua
Censura.Elements.ColorPicker.new({
    text = "Character Color",
    default = Color3.fromRGB(255, 0, 0),
    onColorChanged = function(color)
        local player = game.Players.LocalPlayer
        player.Character.Humanoid.DisplayName = "Changed color!"
    end
})
```

#### List

```lua
Censura.Elements.List.new({
    title = "Players",
    items = {"Player1", "Player2", "Player3"},
    onSelect = function(player)
        print("Selected player:", player)
    end
})
```

#### Notification System

```lua
-- Quick notifications
Censura.Elements.Notification.Success("Operation completed!")
Censura.Elements.Notification.Error("Something went wrong!")
Censura.Elements.Notification.Warning("Low health!")
Censura.Elements.Notification.Info("New quest available!")

-- Custom notification
Censura.Elements.Notification.new({
    type = "success",
    title = "Achievement Unlocked",
    message = "You've reached level 10!",
    duration = 3
})
```

## 🎨 Styling System

Customize the appearance using the built-in styling system:

```lua
local Styles = Censura.Modules.Styles

-- Modify theme colors
Styles.Colors.Primary.Main = Color3.fromRGB(0, 255, 0)
Styles.Colors.Window.Background = Color3.fromRGB(20, 20, 20)

-- Adjust spacing
Styles.Layout.Spacing.Medium = 10
```

## 📚 Examples

### Complete Settings Menu

```lua
local window = Censura.Elements.Window.new({
    title = "Game Settings"
})

local tabs = Censura.Elements.TabSystem.new()
tabs.Parent = window.content

-- Graphics Settings
local graphicsTab = tabs:AddTab("Graphics")
local graphicsSection = Censura.Elements.Section.new({
    title = "Quality Settings"
})
graphicsSection.Parent = graphicsTab

Censura.Elements.Toggle.new({
    text = "Shadows",
    default = true,
    onToggle = function(enabled)
        game.Lighting.GlobalShadows = enabled
    end
}).Parent = graphicsSection

Censura.Elements.Slider.new({
    text = "Brightness",
    min = 0,
    max = 100,
    default = 50,
    onValueChanged = function(value)
        game.Lighting.Brightness = value/100
    end
}).Parent = graphicsSection

-- Audio Settings
local audioTab = tabs:AddTab("Audio")
local audioSection = Censura.Elements.Section.new({
    title = "Sound Settings"
})
audioSection.Parent = audioTab

Censura.Elements.Toggle.new({
    text = "Music",
    default = true,
    onToggle = function(enabled)
        -- Toggle background music
    end
}).Parent = audioSection
```

## 📖 API Reference

### Window Options

```lua
{
    title = string,
    size = UDim2,
    position = UDim2,
}
```

### Section Options

```lua
{
    title = string,
    layoutOrder = number,
}
```

### Button Options

```lua
{
    text = string,
    onClick = function,
    layoutOrder = number,
}
```

### Toggle Options

```lua
{
    text = string,
    default = boolean,
    onToggle = function(enabled),
    layoutOrder = number,
}
```

### Slider Options

```lua
{
    text = string,
    min = number,
    max = number,
    default = number,
    onValueChanged = function(value),
    layoutOrder = number,
}
```

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Contact

Created by [@LxckStxp](https://github.com/LxckStxp)




<div align="center">
  Made with ❤️ by LxckStxp
</div>
