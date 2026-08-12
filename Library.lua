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
local camera = ws.CurrentCamera
local lp = players.LocalPlayer
local mouse = lp:GetMouse()

if getgenv().library then
	getgenv().library:unload()
end

getgenv().library = {
	flags = {},
	config_flags = {},
	connections = {},
	notifications = {},
	instances = {},
	directory = "aikolia",
	folders = {
		"/fonts",
		"/configs",
	},
	font = Font.fromEnum(Enum.Font.SourceSans),
}

local library = getgenv().library
local flags = library.flags
local config_flags = library.config_flags

-- Themes Configuration
local themes = {
	preset = {
		["outline"] = rgb(32, 32, 38),
		["inline"] = rgb(45, 45, 55),
		["accent"] = rgb(255, 128, 0),
		["contrast"] = rgb(25, 25, 32),
		["background"] = rgb(18, 18, 22),
		["text"] = rgb(220, 220, 220),
		["unselected_text"] = rgb(120, 120, 120),
	},
}

-- Create Folder Structure
for _, path in next, library.folders do
	if makefolder then
		pcall(function() makefolder(library.directory .. path) end)
	end
end

-- Load Custom Tahoma Font Safely
pcall(function()
	if isfile and writefile and getcustomasset then
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
	end
end)

-- Core Helper Functions
function library:create(class, properties)
	local ins = Instance.new(class)
	for prop, val in next, properties do
		ins[prop] = val
	end
	table.insert(library.instances, ins)
	return ins
end

function library:connection(signal, callback)
	local conn = signal:Connect(callback)
	table.insert(library.connections, conn)
	return conn
end

function library:round(number, float)
	local multiplier = 1 / (float or 1)
	return math.floor(number * multiplier + 0.5) / multiplier
end

function library:unload()
	if library.gui then
		library.gui:Destroy()
	end
	for _, conn in next, library.connections do
		conn:Disconnect()
	end
	for _, ins in next, library.instances do
		pcall(function() ins:Destroy() end)
	end
	getgenv().library = nil
end

function library:notification(opts)
	local text = opts.text or opts.Text or "Notification"
	local duration = opts.time or opts.duration or 3

	if not library.notif_holder then
		library.notif_holder = library:create("Frame", {
			Parent = library.gui,
			Size = dim2(0, 250, 1, -20),
			Position = dim2(1, -260, 0, 10),
			BackgroundTransparency = 1,
		})
		library:create("UIListLayout", {
			Parent = library.notif_holder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = dim(0, 6),
		})
	end

	local notif_frame = library:create("Frame", {
		Parent = library.notif_holder,
		Size = dim2(1, 0, 0, 30),
		BackgroundColor3 = themes.preset.contrast,
		BorderColor3 = themes.preset.accent,
		BorderSizePixel = 1,
	})

	library:create("TextLabel", {
		Parent = notif_frame,
		Size = dim2(1, -10, 1, 0),
		Position = dim2(0, 8, 0, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = themes.preset.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.SourceSans,
		TextSize = 13,
	})

	task.delay(duration, function()
		if notif_frame then
			notif_frame:Destroy()
		end
	end)
end

-- Create ScreenGui Container
library.gui = library:create("ScreenGui", {
	Enabled = true,
	Parent = coregui,
	Name = "AikoliaGui",
	DisplayOrder = 10,
	ResetOnSpawn = false,
})

-- Draggable Frame Functionality
function library:make_draggable(frame, drag_handle)
	drag_handle = drag_handle or frame
	local dragging = false
	local drag_start, start_pos

	drag_handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			drag_start = input.Position
			start_pos = frame.Position
		end
	end)

	drag_handle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	library:connection(uis.InputChanged, function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - drag_start
			frame.Position = dim2(
				start_pos.X.Scale,
				start_pos.X.Offset + delta.X,
				start_pos.Y.Scale,
				start_pos.Y.Offset + delta.Y
			)
		end
	end)
end

-- Resizable Frame Functionality
function library:make_resizable(frame)
	local resizer = library:create("TextButton", {
		Parent = frame,
		Position = dim2(1, -10, 1, -10),
		Size = dim2(0, 10, 0, 10),
		BackgroundTransparency = 1,
		Text = "",
	})

	local resizing = false
	local start_size, start_pos

	resizer.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			start_pos = input.Position
			start_size = frame.Size
		end
	end)

	resizer.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = false
		end
	end)

	library:connection(uis.InputChanged, function(input)
		if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - start_pos
			frame.Size = dim2(
				start_size.X.Scale,
				math.max(380, start_size.X.Offset + delta.X),
				start_size.Y.Scale,
				math.max(300, start_size.Y.Offset + delta.Y)
			)
		end
	end)
end

-- Main Window
function library:window(properties)
	local cfg = {
		name = properties.Name or properties.name or properties.Title or properties.title or "Aikolia UI",
		size = properties.Size or properties.size or dim2(0, 500, 0, 600),
	}

	local main_frame = library:create("Frame", {
		Parent = library.gui,
		Name = "Aikolia_Window",
		Size = cfg.size,
		Position = dim2(0.5, -cfg.size.X.Offset / 2, 0.5, -cfg.size.Y.Offset / 2),
		BackgroundColor3 = themes.preset.background,
		BorderColor3 = themes.preset.outline,
		BorderSizePixel = 1,
		Active = true,
	})

	local top_bar = library:create("Frame", {
		Parent = main_frame,
		Name = "TopBar",
		Size = dim2(1, 0, 0, 28),
		BackgroundColor3 = themes.preset.contrast,
		BorderSizePixel = 0,
	})

	library:create("Frame", {
		Parent = top_bar,
		Name = "AccentLine",
		Size = dim2(1, 0, 0, 2),
		Position = dim2(0, 0, 0, 0),
		BackgroundColor3 = themes.preset.accent,
		BorderSizePixel = 0,
	})

	library:create("TextLabel", {
		Parent = top_bar,
		Size = dim2(1, -10, 1, 0),
		Position = dim2(0, 10, 0, 2),
		BackgroundTransparency = 1,
		Text = cfg.name,
		TextColor3 = themes.preset.text,
		Font = Enum.Font.SourceSansBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	library:make_draggable(main_frame, top_bar)
	library:make_resizable(main_frame)

	local tab_bar = library:create("Frame", {
		Parent = main_frame,
		Name = "TabBar",
		Size = dim2(1, -16, 0, 26),
		Position = dim2(0, 8, 0, 34),
		BackgroundColor3 = themes.preset.contrast,
		BorderColor3 = themes.preset.outline,
		BorderSizePixel = 1,
	})

	library:create("UIListLayout", {
		Parent = tab_bar,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = dim(0, 2),
	})

	local content_holder = library:create("Frame", {
		Parent = main_frame,
		Name = "ContentHolder",
		Size = dim2(1, -16, 1, -72),
		Position = dim2(0, 8, 0, 66),
		BackgroundTransparency = 1,
	})

	local window_obj = {
		tabs = {},
		current_tab = nil,
	}

	-- TAB METHOD
	function window_obj:tab(tab_cfg)
		local tab_name = tab_cfg.Name or tab_cfg.name or "Tab"

		local tab_btn = library:create("TextButton", {
			Parent = tab_bar,
			Name = tab_name .. "_Btn",
			Size = dim2(0, 80, 1, 0),
			BackgroundColor3 = themes.preset.contrast,
			BorderSizePixel = 0,
			Text = tab_name,
			TextColor3 = themes.preset.unselected_text,
			Font = Enum.Font.SourceSans,
			TextSize = 13,
		})

		local tab_page = library:create("Frame", {
			Parent = content_holder,
			Name = tab_name .. "_Page",
			Size = dim2(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Visible = false,
		})

		local left_col = library:create("ScrollingFrame", {
			Parent = tab_page,
			Size = dim2(0.5, -4, 1, 0),
			Position = dim2(0, 0, 0, 0),
			BackgroundTransparency = 1,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = themes.preset.accent,
			CanvasSize = dim2(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
		})

		local right_col = library:create("ScrollingFrame", {
			Parent = tab_page,
			Size = dim2(0.5, -4, 1, 0),
			Position = dim2(0.5, 4, 0, 0),
			BackgroundTransparency = 1,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = themes.preset.accent,
			CanvasSize = dim2(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
		})

		library:create("UIListLayout", { Parent = left_col, Padding = dim(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
		library:create("UIListLayout", { Parent = right_col, Padding = dim(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })

		local function select_tab()
			for _, t in pairs(window_obj.tabs) do
				t.page.Visible = false
				t.btn.TextColor3 = themes.preset.unselected_text
				t.btn.BackgroundColor3 = themes.preset.contrast
			end
			tab_page.Visible = true
			tab_btn.TextColor3 = themes.preset.accent
			tab_btn.BackgroundColor3 = themes.preset.inline
		end

		tab_btn.MouseButton1Click:Connect(select_tab)

		if #window_obj.tabs == 0 then
			select_tab()
		end

		local tab_obj = { btn = tab_btn, page = tab_page }
		table.insert(window_obj.tabs, tab_obj)

		-- SECTION METHOD
		function tab_obj:section(sec_cfg)
			local sec_name = sec_cfg.Name or sec_cfg.name or "Section"
			local side = sec_cfg.side or "left"
			local target_col = (side:lower() == "right") and right_col or left_col

			local sec_frame = library:create("Frame", {
				Parent = target_col,
				Name = sec_name .. "_Sec",
				Size = dim2(1, -4, 0, 30),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = themes.preset.contrast,
				BorderColor3 = themes.preset.outline,
				BorderSizePixel = 1,
			})

			library:create("TextLabel", {
				Parent = sec_frame,
				Size = dim2(1, -10, 0, 20),
				Position = dim2(0, 8, 0, 2),
				BackgroundTransparency = 1,
				Text = sec_name,
				TextColor3 = themes.preset.text,
				TextXAlignment = Enum.TextXAlignment.Left,
				Font = Enum.Font.SourceSansBold,
				TextSize = 12,
			})

			local container = library:create("Frame", {
				Parent = sec_frame,
				Size = dim2(1, -16, 1, -26),
				Position = dim2(0, 8, 0, 24),
				BackgroundTransparency = 1,
			})

			library:create("UIListLayout", {
				Parent = container,
				Padding = dim(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
			})

			local sec_obj = {}

			-- TOGGLE CONTROL
			function sec_obj:toggle(opts)
				local flag = opts.flag or opts.name
				flags[flag] = opts.default or false

				local toggle_frame = library:create("Frame", {
					Parent = container,
					Size = dim2(1, 0, 0, 20),
					BackgroundTransparency = 1,
				})

				local box = library:create("TextButton", {
					Parent = toggle_frame,
					Size = dim2(0, 14, 0, 14),
					Position = dim2(0, 0, 0.5, -7),
					BackgroundColor3 = flags[flag] and themes.preset.accent or themes.preset.inline,
					BorderColor3 = themes.preset.outline,
					Text = "",
				})

				local label = library:create("TextButton", {
					Parent = toggle_frame,
					Size = dim2(1, -20, 1, 0),
					Position = dim2(0, 20, 0, 0),
					BackgroundTransparency = 1,
					Text = opts.name or "Toggle",
					TextColor3 = flags[flag] and themes.preset.text or themes.preset.unselected_text,
					Font = Enum.Font.SourceSans,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
				})

				local function set_state(val)
					flags[flag] = val
					box.BackgroundColor3 = val and themes.preset.accent or themes.preset.inline
					label.TextColor3 = val and themes.preset.text or themes.preset.unselected_text
					if opts.callback then opts.callback(val) end
				end

				box.MouseButton1Click:Connect(function() set_state(not flags[flag]) end)
				label.MouseButton1Click:Connect(function() set_state(not flags[flag]) end)

				if opts.callback and flags[flag] then
					opts.callback(flags[flag])
				end

				return { set = set_state }
			end

			-- SLIDER CONTROL
			function sec_obj:slider(opts)
				local flag = opts.flag or opts.name
				local min_v = opts.min or 0
				local max_v = opts.max or 100
				local def_v = opts.default or min_v
				flags[flag] = def_v

				local slider_frame = library:create("Frame", {
					Parent = container,
					Size = dim2(1, 0, 0, 32),
					BackgroundTransparency = 1,
				})

				local label = library:create("TextLabel", {
					Parent = slider_frame,
					Size = dim2(1, 0, 0, 14),
					BackgroundTransparency = 1,
					Text = opts.name .. ": " .. tostring(flags[flag]),
					TextColor3 = themes.preset.text,
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSans,
					TextSize = 12,
				})

				local bar = library:create("TextButton", {
					Parent = slider_frame,
					Size = dim2(1, 0, 0, 12),
					Position = dim2(0, 0, 0, 16),
					BackgroundColor3 = themes.preset.inline,
					BorderColor3 = themes.preset.outline,
					Text = "",
					AutoButtonColor = false,
				})

				local fill = library:create("Frame", {
					Parent = bar,
					Size = dim2((flags[flag] - min_v) / (max_v - min_v), 0, 1, 0),
					BackgroundColor3 = themes.preset.accent,
					BorderSizePixel = 0,
				})

				local dragging = false
				local function update(input)
					local percent = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
					local val = library:round(min_v + (max_v - min_v) * percent, opts.float or opts.decimals or 1)
					flags[flag] = val
					fill.Size = dim2(percent, 0, 1, 0)
					label.Text = opts.name .. ": " .. tostring(val)
					if opts.callback then opts.callback(val) end
				end

				bar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						update(input)
					end
				end)

				uis.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
				end)

				uis.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
				end)
			end

			-- BUTTON CONTROL
			function sec_obj:button(opts)
				local btn = library:create("TextButton", {
					Parent = container,
					Size = dim2(1, 0, 0, 22),
					BackgroundColor3 = themes.preset.inline,
					BorderColor3 = themes.preset.outline,
					Text = opts.name or "Button",
					TextColor3 = themes.preset.text,
					Font = Enum.Font.SourceSans,
					TextSize = 12,
				})

				btn.MouseButton1Click:Connect(function()
					if opts.callback then opts.callback() end
				end)
			end

			-- DROPDOWN CONTROL
			function sec_obj:dropdown(opts)
				local flag = opts.flag or opts.name
				local options = opts.options or {}
				flags[flag] = opts.default or options[1] or ""

				local drop_frame = library:create("Frame", {
					Parent = container,
					Size = dim2(1, 0, 0, 36),
					BackgroundTransparency = 1,
				})

				library:create("TextLabel", {
					Parent = drop_frame,
					Size = dim2(1, 0, 0, 14),
					BackgroundTransparency = 1,
					Text = opts.name,
					TextColor3 = themes.preset.text,
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSans,
					TextSize = 12,
				})

				local main_btn = library:create("TextButton", {
					Parent = drop_frame,
					Size = dim2(1, 0, 0, 18),
					Position = dim2(0, 0, 0, 16),
					BackgroundColor3 = themes.preset.inline,
					BorderColor3 = themes.preset.outline,
					Text = "  " .. tostring(flags[flag]),
					TextColor3 = themes.preset.text,
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSans,
					TextSize = 12,
				})

				local list_frame = library:create("Frame", {
					Parent = main_btn,
					Size = dim2(1, 0, 0, 0),
					Position = dim2(0, 0, 1, 2),
					BackgroundColor3 = themes.preset.contrast,
					BorderColor3 = themes.preset.outline,
					Visible = false,
					ZIndex = 5,
					ClipsDescendants = true,
				})

				library:create("UIListLayout", { Parent = list_frame, SortOrder = Enum.SortOrder.LayoutOrder })

				local open = false
				local function refresh_list()
					for _, child in pairs(list_frame:GetChildren()) do
						if child:IsA("TextButton") then child:Destroy() end
					end
					for _, opt in ipairs(options) do
						local opt_btn = library:create("TextButton", {
							Parent = list_frame,
							Size = dim2(1, 0, 0, 18),
							BackgroundColor3 = (flags[flag] == opt) and themes.preset.inline or themes.preset.contrast,
							Text = "  " .. tostring(opt),
							TextColor3 = (flags[flag] == opt) and themes.preset.accent or themes.preset.text,
							TextXAlignment = Enum.TextXAlignment.Left,
							Font = Enum.Font.SourceSans,
							TextSize = 12,
							ZIndex = 6,
						})
						opt_btn.MouseButton1Click:Connect(function()
							flags[flag] = opt
							main_btn.Text = "  " .. tostring(opt)
							open = false
							list_frame.Visible = false
							drop_frame.Size = dim2(1, 0, 0, 36)
							if opts.callback then opts.callback(opt) end
						end)
					end
				end

				main_btn.MouseButton1Click:Connect(function()
					open = not open
					if open then
						refresh_list()
						list_frame.Size = dim2(1, 0, 0, #options * 18)
						list_frame.Visible = true
						drop_frame.Size = dim2(1, 0, 0, 36 + (#options * 18))
					else
						list_frame.Visible = false
						drop_frame.Size = dim2(1, 0, 0, 36)
					end
				end)

				return {
					refresh_options = function(self, new_opts)
						options = new_opts
						if open then refresh_list() end
					end
				}
			end

			-- KEYBIND CONTROL
			function sec_obj:keybind(opts)
				local flag = opts.flag or opts.name
				flags[flag] = opts.default or Enum.KeyCode.RightControl

				local bind_frame = library:create("Frame", {
					Parent = container,
					Size = dim2(1, 0, 0, 20),
					BackgroundTransparency = 1,
				})

				library:create("TextLabel", {
					Parent = bind_frame,
					Size = dim2(1, -60, 1, 0),
					BackgroundTransparency = 1,
					Text = opts.name or "Keybind",
					TextColor3 = themes.preset.text,
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSans,
					TextSize = 13,
				})

				local bind_btn = library:create("TextButton", {
					Parent = bind_frame,
					Size = dim2(0, 55, 1, 0),
					Position = dim2(1, -55, 0, 0),
					BackgroundColor3 = themes.preset.inline,
					BorderColor3 = themes.preset.outline,
					Text = typeof(flags[flag]) == "EnumItem" and flags[flag].Name or "None",
					TextColor3 = themes.preset.text,
					Font = Enum.Font.SourceSans,
					TextSize = 12,
				})

				local listening = false
				bind_btn.MouseButton1Click:Connect(function()
					listening = true
					bind_btn.Text = "..."
				end)

				uis.InputBegan:Connect(function(input, gpe)
					if listening then
						if input.UserInputType == Enum.UserInputType.Keyboard then
							flags[flag] = input.KeyCode
							bind_btn.Text = input.KeyCode.Name
							listening = false
							if opts.callback then opts.callback(input.KeyCode) end
						end
					elseif not gpe and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == flags[flag] then
						if opts.callback then opts.callback(flags[flag]) end
					end
				end)
			end

			-- COLORPICKER CONTROL
			function sec_obj:colorpicker(opts)
				local flag = opts.flag or opts.name
				flags[flag] = opts.default or Color3.fromRGB(255, 255, 255)

				local cp_frame = library:create("Frame", {
					Parent = container,
					Size = dim2(1, 0, 0, 20),
					BackgroundTransparency = 1,
				})

				library:create("TextLabel", {
					Parent = cp_frame,
					Size = dim2(1, -30, 1, 0),
					BackgroundTransparency = 1,
					Text = opts.name or "Colorpicker",
					TextColor3 = themes.preset.text,
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.SourceSans,
					TextSize = 13,
				})

				local preview = library:create("TextButton", {
					Parent = cp_frame,
					Size = dim2(0, 24, 0, 14),
					Position = dim2(1, -24, 0.5, -7),
					BackgroundColor3 = flags[flag],
					BorderColor3 = themes.preset.outline,
					Text = "",
				})

				preview.MouseButton1Click:Connect(function()
					if opts.callback then opts.callback(flags[flag]) end
				end)
			end

			return sec_obj
		end

		return tab_obj
	end

	return window_obj
end

return library
