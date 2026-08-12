--[[
    Aikolia UI Library — Master Showcase Script
--]]

local Aikolia = loadstring(game:HttpGet("https://raw.githubusercontent.com/yenkgg/AikoliaLib/main/Aikolia.lua"))()

-- Create Main Window
local Window = Aikolia:CreateWindow({
    Title = "Aikolia Showcase",
    Subtitle = "Next-Gen Roblox Framework",
    Size = UDim2.fromOffset(740, 540)
})

-- 1. Main Controls Tab
local MainTab = Window:AddTab({ Name = "Main Controls", Icon = "rbxassetid://6031763426" })

local GeneralSection = MainTab:AddSection("General Settings")

GeneralSection:AddButton("Trigger Notification", function()
    Aikolia:Notify({
        Title = "Action Executed",
        Description = "Primary system routine completed without errors.",
        Duration = 3.5,
        Type = "Success"
    })
end)

GeneralSection:AddToggle("AutoFarm", {
    Text = "Enable Automated Farming",
    Default = true,
    Callback = function(val)
        print("AutoFarm Toggled:", val)
    end
})

GeneralSection:AddSlider("WalkSpeed", {
    Text = "Movement Speed Multiplier",
    Min = 16,
    Max = 250,
    Default = 50,
    Rounding = 0,
    Callback = function(val)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
        end
    end
})

local CombatSection = MainTab:AddSection("Combat Configuration")

CombatSection:AddDropdown("TargetPriority", {
    Text = "Targeting Mode",
    Options = { "Closest Distance", "Lowest Health", "Highest Threat", "Random" },
    Default = "Closest Distance",
    Callback = function(mode)
        print("Selected Target Mode:", mode)
    end
})

CombatSection:AddInput("CustomTag", {
    Text = "Custom Clan Tag",
    Placeholder = "Enter tag...",
    Callback = function(text)
        print("Set Tag:", text)
    end
})

CombatSection:AddKeybind("ToggleKey", {
    Text = "Quick Action Keybind",
    Default = Enum.KeyCode.F,
    Callback = function(key)
        Aikolia:Notify({ Title = "Key Pressed", Description = "Keybind triggered: " .. key.Name, Type = "Info" })
    end
})

CombatSection:AddColorPicker("AccentColor", {
    Text = "Custom Highlight Color",
    Default = Color3.fromRGB(139, 92, 246),
    Callback = function(color)
        print("Color Picked:", color)
    end
})

-- 2. ESP Preview Tab
Window:AddESPPreviewTab({ Name = "Visuals & ESP" })

-- 3. Theme & Config Management Tab
local SettingsTab = Window:AddTab({ Name = "Settings", Icon = "rbxassetid://6031280882" })
local ThemeSection = SettingsTab:AddSection("Theme Switcher")

ThemeSection:AddButton("Aikolia Dark", function() Aikolia:SetTheme("Aikolia Dark") end)
ThemeSection:AddButton("Aikolia Light", function() Aikolia:SetTheme("Aikolia Light") end)
ThemeSection:AddButton("Midnight", function() Aikolia:SetTheme("Midnight") end)
ThemeSection:AddButton("Crimson", function() Aikolia:SetTheme("Crimson") end)
ThemeSection:AddButton("Ocean", function() Aikolia:SetTheme("Ocean") end)
ThemeSection:AddButton("Emerald", function() Aikolia:SetTheme("Emerald") end)

local ConfigSection = SettingsTab:AddSection("Configuration System")

ConfigSection:AddButton("Save Default Config", function()
    Aikolia:SaveConfig("Default")
end)

ConfigSection:AddButton("Load Default Config", function()
    Aikolia:LoadConfig("Default")
end)

ConfigSection:AddButton("Unload Library", function()
    Aikolia:Unload()
end)

-- Initial Welcome Toast
Aikolia:Notify({
    Title = "Welcome to Aikolia",
    Description = "Loaded successfully on " .. (game:GetService("UserInputService").TouchEnabled and "Mobile" or "Desktop"),
    Duration = 5,
    Type = "Info"
})
