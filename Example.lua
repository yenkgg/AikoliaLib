-- Load Aikolia Library
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/yenkgg/AikoliaLib/refs/heads/main/Library.lua"))()

-- Create Main Window
local window = library:window({
    name = "Aikolia Test Script",
    size = UDim2.new(0, 500, 0, 650)
})

-- Create Tabs
local main_tab = window:tab({ name = "Main" })
local visual_tab = window:tab({ name = "Visuals" })
local config_tab = window:tab({ name = "Settings" })

---------------------------------------------------------------------
-- MAIN TAB
---------------------------------------------------------------------
local player_section = main_tab:section({ name = "Player Modifications", side = "left" })
local misc_section = main_tab:section({ name = "Utilities", side = "right" })

-- Toggle
player_section:toggle({
    name = "Enable Speed Hack",
    flag = "speed_enabled",
    default = false,
    callback = function(state)
        print("Speed toggle state:", state)
    end
})

-- Slider
player_section:slider({
    name = "WalkSpeed Value",
    flag = "walkspeed_value",
    min = 16,
    max = 250,
    default = 16,
    decimals = 1,
    callback = function(value)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end
})

-- Dropdown
misc_section:dropdown({
    name = "Select Mode",
    flag = "target_mode",
    options = { "Legit", "Rage", "Semi-Rage" },
    default = "Legit",
    callback = function(selected)
        print("Selected mode:", selected)
    end
})

-- Button
misc_section:button({
    name = "Reset Character",
    callback = function()
        if game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character:BreakJoints()
        end
    end
})

-- Keybind
misc_section:keybind({
    name = "Panic Key",
    flag = "panic_keybind",
    default = Enum.KeyCode.RightControl,
    callback = function(key)
        print("Panic key pressed:", key)
    end
})

---------------------------------------------------------------------
-- VISUALS TAB
---------------------------------------------------------------------
local esp_section = visual_tab:section({ name = "ESP Options", side = "left" })

-- Colorpicker
esp_section:colorpicker({
    name = "Box ESP Color",
    flag = "esp_box_color",
    default = Color3.fromRGB(255, 128, 0),
    callback = function(color)
        print("ESP Color changed to:", color)
    end
})

---------------------------------------------------------------------
-- SETTINGS TAB
---------------------------------------------------------------------
local config_section = config_tab:section({ name = "Config Manager", side = "left" })

config_section:button({
    name = "Unload Script",
    callback = function()
        library:unload()
    end
})

print("Aikolia UI script loaded successfully!")
