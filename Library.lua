local uis = game:GetService("UserInputService")
local players = game:GetService("Players")
local ws = game:GetService("Workspace")
local http_service = game:GetService("HttpService")
local gui_service = game:GetService("GuiService")
local lighting = game:GetService("Lighting")
local run = game:GetService("RunService")
local stats = game:GetService("Stats")
local coregui = game:GetService("CoreGui")
local debris = game:GetService("Debris")
local tween_service = game:GetService("TweenService")
local rs = game:GetService("ReplicatedStorage")
local vec2 = Vector2.new
local vec3 = Vector3.new
local dim2 = UDim2.new
local dim = UDim.new
local rect = Rect.new
local cfr = CFrame.new
local color = Color3.new
local rgb = Color3.fromRGB
local hex = Color3.fromHex
local hsv = Color3.fromHSV
local rgbseq = ColorSequence.new
local rgbkey = ColorSequenceKeypoint.new
local camera = ws.CurrentCamera
local lp = players.LocalPlayer
local mouse = lp:GetMouse()
local gui_offset = gui_service:GetGuiInset().Y
local max = math.max
local floor = math.floor
local min = math.min
local abs = math.abs

if getgenv().library then
	getgenv().library:unload()
end

getgenv().library = {
	flags = {},
	config_flags = {},
	connections = {},
	notifications = {},
	instances = {},
	main_frame = {},
	config_holder,
	current_tab,
	current_element_open,
	dock_button_holder,
	gui,
	sin = 0,
	keybind_path,
	panel_open = false,
	directory = "aikolia",
	folders = {
		"/fonts",
		"/configs",
	},
	font,
}

local flags = library.flags
local config_flags = library.config_flags
local themes = {
	preset = {
		["outline"] = rgb(32, 32, 38),
		["inline"] = rgb(60, 55, 75),
		["accent"] = rgb(255, 128, 0),
		["contrast"] = rgb(35, 35, 47),
		["text"] = rgb(170, 170, 170),
		["unselected_text"] = rgb(90, 90, 90),
		["text_outline"] = rgb(0, 0, 0),
		["glow"] = rgb(255, 128, 0),
	},
	utility = {
		["outline"] = {
			["BackgroundColor3"] = {},
			["Color"] = {},
		},
		["inline"] = {
			["BackgroundColor3"] = {},
		},
		["accent"] = {
			["BackgroundColor3"] = {},
			["TextColor3"] = {},
			["ImageColor3"] = {},
			["BorderColor3"] = {},
			["ScrollBarImageColor3"] = {},
		},
		["contrast"] = {
			["Color"] = {},
		},
		["text"] = {
			["TextColor3"] = {},
		},
		["text_outline"] = {
			["Color"] = {},
		},
		["glow"] = {
			["ImageColor3"] = {},
		},
	},
}

local keys = {
	[Enum.KeyCode.LeftShift] = "LS",
	[Enum.KeyCode.RightShift] = "RS",
	[Enum.KeyCode.LeftControl] = "LC",
	[Enum.KeyCode.RightControl] = "RC",
	[Enum.KeyCode.Insert] = "INS",
	[Enum.KeyCode.Backspace] = "BS",
	[Enum.KeyCode.Return] = "Ent",
	[Enum.KeyCode.LeftAlt] = "LA",
	[Enum.KeyCode.RightAlt] = "RA",
	[Enum.KeyCode.CapsLock] = "CAPS",
	[Enum.KeyCode.One] = "1",
	[Enum.KeyCode.Two] = "2",
	[Enum.KeyCode.Three] = "3",
	[Enum.KeyCode.Four] = "4",
	[Enum.KeyCode.Five] = "5",
	[Enum.KeyCode.Six] = "6",
	[Enum.KeyCode.Seven] = "7",
	[Enum.KeyCode.Eight] = "8",
	[Enum.KeyCode.Nine] = "9",
	[Enum.KeyCode.Zero] = "0",
	[Enum.KeyCode.KeypadOne] = "Num1",
	[Enum.KeyCode.KeypadTwo] = "Num2",
	[Enum.KeyCode.KeypadThree] = "Num3",
	[Enum.KeyCode.KeypadFour] = "Num4",
	[Enum.KeyCode.KeypadFive] = "Num5",
	[Enum.KeyCode.KeypadSix] = "Num6",
	[Enum.KeyCode.KeypadSeven] = "Num7",
	[Enum.KeyCode.KeypadEight] = "Num8",
	[Enum.KeyCode.KeypadNine] = "Num9",
	[Enum.KeyCode.KeypadZero] = "Num0",
	[Enum.KeyCode.Minus] = "-",
	[Enum.KeyCode.Equals] = "=",
	[Enum.KeyCode.Tilde] = "~",
	[Enum.KeyCode.LeftBracket] = "[",
	[Enum.KeyCode.RightBracket] = "]",
	[Enum.KeyCode.RightParenthesis] = ")",
	[Enum.KeyCode.LeftParenthesis] = "(",
	[Enum.KeyCode.Semicolon] = ",",
	[Enum.KeyCode.Quote] = "'",
	[Enum.KeyCode.BackSlash] = "\\",
	[Enum.KeyCode.Comma] = ",",
	[Enum.KeyCode.Period] = ".",
	[Enum.KeyCode.Slash] = "/",
	[Enum.KeyCode.Asterisk] = "*",
	[Enum.KeyCode.Plus] = "+",
	[Enum.KeyCode.Backquote] = "`",
	[Enum.UserInputType.MouseButton1] = "MB1",
	[Enum.UserInputType.MouseButton2] = "MB2",
	[Enum.UserInputType.MouseButton3] = "MB3",
	[Enum.KeyCode.Escape] = "ESC",
	[Enum.KeyCode.Space] = "SPC",
}

library.__index = library

for _, path in next, library.folders do
	makefolder(library.directory .. path)
end

if not isfile(library.directory .. "/fonts/main.ttf") then
	writefile(
		library.directory .. "/fonts/main.ttf",
		game:HttpGet("https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/fs-tahoma-8px.ttf")
	)
end

local tahoma = {
	name = "SmallestPixel7",
	faces = {
		{
			name = "Regular",
			weight = 400,
			style = "normal",
			assetId = getcustomasset(library.directory .. "/fonts/main.ttf"),
		},
	},
}

if not isfile(library.directory .. "/fonts/main_encoded.ttf") then
	writefile(library.directory .. "/fonts/main_encoded.ttf", http_service:JSONEncode(tahoma))
end

library.font = Font.new(getcustomasset(library.directory .. "/fonts/main_encoded.ttf"), Enum.FontWeight.Regular)

-- functions
function library.to_screen_point(position)
	return camera:WorldToViewportPoint(position)
end

function library:unload()
	if library.gui then
		library.gui:Destroy()
	end
	for _, connection in next, library.connections do
		connection:Disconnect()
	end
	for _, item in next, library.instances do
		item:Destroy()
	end
	getgenv().library = nil
end

function library:convert_string_rgb(str)
	local values = {}
	for value in string.gmatch(str, "[^,]+") do
		table.insert(values, tonumber(value))
	end
	if #values == 4 then
		return values[1], values[2], values[3], values[4]
	else
		library:notification({ text = "Input a correct RGBA value (in the format 255, 255, 255, 0.5)" })
	end
end

function library:connection(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(library.connections, connection)
	return connection
end

function library:make_resizable(frame)
	local Frame = Instance.new("TextButton")
	Frame.Position = dim2(1, -10, 1, -10)
	Frame.BorderColor3 = rgb(0, 0, 0)
	Frame.Size = dim2(0, 10, 0, 10)
	Frame.BorderSizePixel = 0
	Frame.BackgroundColor3 = rgb(255, 255, 255)
	Frame.Parent = frame
	Frame.BackgroundTransparency = 1
	Frame.Text = ""

	local resizing = false
	local start_size
	local start
	local og_size = frame.Size

	Frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			start = input.Position
			start_size = frame.Size
		end
	end)

	Frame.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = false
		end
	end)

	library:connection(uis.InputChanged, function(input)
		if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local viewport_x = camera.ViewportSize.X
			local viewport_y = camera.ViewportSize.Y

			frame.Size = dim2(
				start_size.X.Scale,
				math.clamp(start_size.X.Offset + (input.Position.X - start.X), og_size.X.Offset, viewport_x),
				start_size.Y.Scale,
				math.clamp(start_size.Y.Offset + (input.Position.Y - start.Y), og_size.Y.Offset, viewport_y)
			)
		end
	end)
end

function library:new_item(class, properties)
	local ins = Instance.new(class)
	for prop, v in next, properties do
		ins[prop] = v
	end
	table.insert(library.instances, ins)
	return ins
end

function library:animation(text)
	local pattern = {}
	for i = 1, tonumber(text:len()) do
		table.insert(pattern, string.sub(text, 1, i))
	end
	for i = tonumber(text:len()) - 1, 0, -1 do
		table.insert(pattern, string.sub(text, 1, i))
	end
	return pattern
end

function library:convert_enum(enum)
	local enum_parts = {}
	for part in string.gmatch(enum, "[%w_]+") do
		table.insert(enum_parts, part)
	end

	local enum_table = Enum
	for i = 2, #enum_parts do
		enum_table = enum_table[enum_parts[i]]
	end

	return enum_table
end

function library:config_list_update()
	if not library.config_holder then
		return
	end

	local list = {}
	local config_path = library.directory .. "/configs"

	if not isfolder(config_path) then
		makefolder(config_path)
	end

	for _, file in next, listfiles(config_path) do
		local normalized = file:gsub("\\", "/")
		local parts = normalized:split("/")
		local filename = parts[#parts]

		if filename:sub(-4) == ".cfg" then
			local name = filename:sub(1, -5)
			table.insert(list, name)
		end
	end

	library.config_holder:refresh_options(list)
end

function library:get_config()
	local Config = {}

	for i, v in next, flags do
		if type(v) == "table" and v.key then
			Config[i] = { active = v.active, mode = v.mode, key = tostring(v.key) }
		elseif type(v) == "table" and v.Transparency and v.Color then
			local color_hex = "ffffff"
			if typeof(v.Color) == "Color3" then
				color_hex = v.Color:ToHex()
			end
			Config[i] = { Transparency = v.Transparency, Color = color_hex }
		else
			Config[i] = v
		end
	end

	return http_service:JSONEncode(Config)
end

function library:load_config(config_json)
	local success, config = pcall(function()
		return http_service:JSONDecode(config_json)
	end)

	if not success then return end

	for i, v in next, config do
		local function_set = library.config_flags[i]

		if function_set then
			if type(v) == "table" and v.Transparency and v.Color then
				function_set(Color3.fromHex(v.Color), v.Transparency)
			elseif type(v) == "table" and v.active ~= nil then
				function_set(v)
			else
				function_set(v)
			end
		end
	end
end

function library:round(number, float)
	local multiplier = 1 / (float or 1)
	return math.floor(number * multiplier + 0.5) / multiplier
end

function library:apply_theme(instance, theme, property)
	table.insert(themes.utility[theme][property], instance)
end

function library:update_theme(theme, color)
	for property_name, objects in next, themes.utility[theme] do
		for _, object in next, objects do
			if object[property_name] == themes.preset[theme] or object.ClassName == "UIGradient" then
				object[property_name] = color
			end
		end
	end

	themes.preset[theme] = color
end

function library:create(instance, options)
	local ins = Instance.new(instance)

	for prop, value in next, options do
		ins[prop] = value
	end

	return ins
end

library.gui = library:create("ScreenGui", {
	Enabled = true,
	Parent = coregui,
	Name = "",
	DisplayOrder = 2,
	ZIndexBehavior = 1,
})

function library:window(properties)
	local cfg = {
		name = properties.Name or properties.name or properties.Title or properties.title or "sp4m.wtf",
		size = properties.Size or properties.size or dim2(0, 500, 0, 650),
	}
	local animated_text = library:animation(cfg.name)
	local __holder = library:create("Frame", {
		Parent = library.gui,
		Name = "",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 20),
		BorderColor3 = Color3.fromRGB(19, 19, 19),
		ZIndex = 2,
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	})

	local inline1 = library:create("Frame", {
		Parent = __holder,
		Name = "",
		Active = true,
		Draggable = true,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(0, ((#animated_text / 2) * 5) + 13, 0, 40),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
	})

	local accent_line = library:create("Frame", {
		Parent = inline1,
		Name = "",
		BorderColor3 = Color3.fromRGB(34, 34, 34),
		Size = UDim2.new(1, 0, 0, 2),
		BorderSizePixel = 0,
		BackgroundColor3 = themes.preset.accent,
	})

	library:apply_theme(accent_line, "accent", "BackgroundColor3")

	local depth = library:create("Frame", {
		Parent = inline1,
		Name = "",
		BackgroundTransparency = 0.5,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
	})

	return __holder
end

return library
