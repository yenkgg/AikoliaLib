# Aikolia UI Library

**Aikolia** is a high-performance, polished Roblox Luau UI library. Designed for desktop, tablet, and mobile, Aikolia provides dark/light themes, spring animations, stackable notifications, an ESP preview panel, and an intuitive API.

---

## Features

- **Responsive Mobile Layouts:** Touch targets and dynamic sizing support low-resolution viewports.
- **Centralized Animation Utility:** Micro-interactions use smooth Lerps and Spring physics with reduced motion toggles.
- **Built-in Theme Manager:** Preset themes (`Aikolia Dark`, `Aikolia Light`, `Midnight`, `Crimson`, `Ocean`, `Emerald`) and custom color table support.
- **3D ESP Preview:** Integrated character ViewportFrame with 2D bounding boxes, health bars, and rotation controls.
- **Stackable Notifications:** Animated toast notifications with countdown progress indicators.
- **Safe Cleanup:** Clean disconnection of connections via `Aikolia:Unload()`.

---

## Quickstart Guide

```lua
local Aikolia = loadstring(game:HttpGet("[https://raw.githubusercontent.com/yenkgg/AikoliaLib/main/Aikolia.lua](https://raw.githubusercontent.com/yenkgg/AikoliaLib/main/Aikolia.lua)"))()

local Window = Aikolia:CreateWindow({
    Title = "My Application",
    Subtitle = "Powered by Aikolia",
    Size = UDim2.fromOffset(720, 500)
})

local Tab = Window:AddTab({ Name = "General", Icon = "rbxassetid://6031763426" })
local Section = Tab:AddSection("Settings")

Section:AddToggle("SpeedToggle", {
    Text = "Enable Super Speed",
    Default = false,
    Callback = function(enabled)
        print("Toggle status:", enabled)
    end
})
