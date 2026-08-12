--[[
    Aikolia UI Library - Modern Roblox Luau UI Framework
    Repository: https://github.com/yenkgg/AikoliaLib
    Author: Aikolia Maintainers
    License: MIT
--]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------------------------
-- UTILITY & CONNECTION TRACKING
--------------------------------------------------------------------------------
local Utility = {}
Utility.Connections = {}

function Utility:Connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(Utility.Connections, connection)
    return connection
end

function Utility:DisconnectAll()
    for _, conn in ipairs(Utility.Connections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    table.clear(Utility.Connections)
end

function Utility:Create(className, properties, children)
    local instance = Instance.new(className)
    for prop, val in pairs(properties or {}) do
        if prop ~= "Parent" then
            instance[prop] = val
        end
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = instance
        end
    end
    if properties and properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Utility:GetParentGui()
    if gethui then
        return gethui()
    elseif syn and syn.protect_gui then
        local sg = Instance.new("ScreenGui")
        syn.protect_gui(sg)
        sg.Parent = CoreGui
        return sg
    elseif CoreGui:FindFirstChild("RobloxGui") then
        return CoreGui
    else
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end

function Utility:IsTouch()
    return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

function Utility:GetViewportSize()
    local camera = workspace.CurrentCamera
    return camera and camera.ViewportSize or Vector2.new(1280, 720)
end

--------------------------------------------------------------------------------
-- ANIMATION SYSTEM
--------------------------------------------------------------------------------
local Animation = {
    Enabled = true,
    ReducedMotion = false,
}

function Animation:Tween(instance, duration, easingStyle, easingDirection, properties)
    if not Animation.Enabled or Animation.ReducedMotion then
        duration = 0.05
    end
    local info = TweenInfo.new(duration or 0.25, easingStyle or Enum.EasingStyle.Quart, easingDirection or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

function Animation:Spring(instance, targetProperties, speed, damping)
    return Animation:Tween(instance, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out, targetProperties)
end

--------------------------------------------------------------------------------
-- THEME SYSTEM
--------------------------------------------------------------------------------
local Theme = {
    CurrentName = "Aikolia Dark",
    BuiltIn = {
        ["Aikolia Dark"] = {
            Background = Color3.fromRGB(18, 19, 24),
            Surface = Color3.fromRGB(26, 27, 35),
            SurfaceVariant = Color3.fromRGB(34, 36, 46),
            Border = Color3.fromRGB(46, 48, 62),
            Accent = Color3.fromRGB(139, 92, 246), -- Violet
            AccentGlow = Color3.fromRGB(139, 92, 246),
            Text = Color3.fromRGB(243, 244, 246),
            SubText = Color3.fromRGB(156, 163, 175),
            Success = Color3.fromRGB(34, 197, 94),
            Warning = Color3.fromRGB(245, 158, 11),
            Error = Color3.fromRGB(239, 68, 68),
            CornerRadius = UDim.new(0, 8),
            Font = Enum.Font.GothamMedium,
            FontBold = Enum.Font.GothamBold,
        },
        ["Aikolia Light"] = {
            Background = Color3.fromRGB(248, 250, 252),
            Surface = Color3.fromRGB(255, 255, 255),
            SurfaceVariant = Color3.fromRGB(241, 245, 249),
            Border = Color3.fromRGB(226, 232, 240),
            Accent = Color3.fromRGB(99, 102, 241),
            AccentGlow = Color3.fromRGB(99, 102, 241),
            Text = Color3.fromRGB(15, 23, 42),
            SubText = Color3.fromRGB(100, 116, 139),
            Success = Color3.fromRGB(16, 185, 129),
            Warning = Color3.fromRGB(245, 158, 11),
            Error = Color3.fromRGB(239, 68, 68),
            CornerRadius = UDim.new(0, 8),
            Font = Enum.Font.GothamMedium,
            FontBold = Enum.Font.GothamBold,
        },
        ["Midnight"] = {
            Background = Color3.fromRGB(9, 10, 15),
            Surface = Color3.fromRGB(17, 19, 31),
            SurfaceVariant = Color3.fromRGB(25, 28, 45),
            Border = Color3.fromRGB(30, 34, 56),
            Accent = Color3.fromRGB(59, 130, 246), -- Sapphire Blue
            AccentGlow = Color3.fromRGB(59, 130, 246),
            Text = Color3.fromRGB(226, 232, 240),
            SubText = Color3.fromRGB(148, 163, 184),
            Success = Color3.fromRGB(16, 185, 129),
            Warning = Color3.fromRGB(245, 158, 11),
            Error = Color3.fromRGB(239, 68, 68),
            CornerRadius = UDim.new(0, 8),
            Font = Enum.Font.GothamMedium,
            FontBold = Enum.Font.GothamBold,
        },
        ["Crimson"] = {
            Background = Color3.fromRGB(18, 10, 14),
            Surface = Color3.fromRGB(28, 16, 23),
            SurfaceVariant = Color3.fromRGB(42, 24, 35),
            Border = Color3.fromRGB(51, 28, 41),
            Accent = Color3.fromRGB(239, 68, 68), -- Crimson
            AccentGlow = Color3.fromRGB(239, 68, 68),
            Text = Color3.fromRGB(250, 250, 250),
            SubText = Color3.fromRGB(161, 161, 170),
            Success = Color3.fromRGB(34, 197, 94),
            Warning = Color3.fromRGB(245, 158, 11),
            Error = Color3.fromRGB(225, 29, 72),
            CornerRadius = UDim.new(0, 8),
            Font = Enum.Font.GothamMedium,
            FontBold = Enum.Font.GothamBold,
        },
        ["Ocean"] = {
            Background = Color3.fromRGB(11, 19, 30),
            Surface = Color3.fromRGB(17, 28, 43),
            SurfaceVariant = Color3.fromRGB(26, 42, 64),
            Border = Color3.fromRGB(30, 46, 69),
            Accent = Color3.fromRGB(6, 182, 212), -- Cyan
            AccentGlow = Color3.fromRGB(6, 182, 212),
            Text = Color3.fromRGB(236, 254, 255),
            SubText = Color3.fromRGB(148, 163, 184),
            Success = Color3.fromRGB(20, 184, 166),
            Warning = Color3.fromRGB(245, 158, 11),
            Error = Color3.fromRGB(239, 68, 68),
            CornerRadius = UDim.new(0, 8),
            Font = Enum.Font.GothamMedium,
            FontBold = Enum.Font.GothamBold,
        },
        ["Emerald"] = {
            Background = Color3.fromRGB(8, 20, 16),
            Surface = Color3.fromRGB(15, 32, 27),
            SurfaceVariant = Color3.fromRGB(22, 48, 40),
            Border = Color3.fromRGB(26, 54, 45),
            Accent = Color3.fromRGB(16, 185, 129), -- Emerald
            AccentGlow = Color3.fromRGB(16, 185, 129),
            Text = Color3.fromRGB(236, 253, 245),
            SubText = Color3.fromRGB(110, 231, 183),
            Success = Color3.fromRGB(16, 185, 129),
            Warning = Color3.fromRGB(245, 158, 11),
            Error = Color3.fromRGB(239, 68, 68),
            CornerRadius = UDim.new(0, 8),
            Font = Enum.Font.GothamMedium,
            FontBold = Enum.Font.GothamBold,
        }
    },
    Active = {},
    Listeners = {}
}

function Theme:Get()
    return Theme.Active
end

function Theme:Set(themeNameOrTable)
    if type(themeNameOrTable) == "string" and Theme.BuiltIn[themeNameOrTable] then
        Theme.CurrentName = themeNameOrTable
        Theme.Active = Theme.BuiltIn[themeNameOrTable]
    elseif type(themeNameOrTable) == "table" then
        Theme.CurrentName = "Custom"
        for k, v in pairs(themeNameOrTable) do
            Theme.Active[k] = v
        end
    end
    for _, callback in ipairs(Theme.Listeners) do
        task.spawn(callback, Theme.Active)
    end
end

function Theme:OnChange(callback)
    table.insert(Theme.Listeners, callback)
end

-- Initialize default theme
Theme:Set("Aikolia Dark")

--------------------------------------------------------------------------------
-- NOTIFICATION SYSTEM
--------------------------------------------------------------------------------
local NotificationSystem = {
    Container = nil,
    Stack = {}
}

function NotificationSystem:Initialize(parentGui)
    if self.Container then return end
    self.Container = Utility:Create("Frame", {
        Name = "AikoliaNotifications",
        Size = UDim2.new(0, 320, 1, -40),
        Position = UDim2.new(1, -340, 0, 20),
        BackgroundTransparency = 1,
        ZIndex = 1000,
        Parent = parentGui
    }, {
        Utility:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            VerticalAlignment = Enum.VerticalAlignment.Bottom
        })
    })
end

function NotificationSystem:Notify(options)
    options = options or {}
    local title = options.Title or "Notification"
    local desc = options.Description or ""
    local duration = options.Duration or 4
    local notifyType = options.Type or "Info" -- Success, Info, Warning, Error
    local callback = options.Callback

    local activeTheme = Theme:Get()
    local typeColor = activeTheme.Accent
    if notifyType == "Success" then typeColor = activeTheme.Success
    elseif notifyType == "Warning" then typeColor = activeTheme.Warning
    elseif notifyType == "Error" then typeColor = activeTheme.Error end

    local notifFrame = Utility:Create("Frame", {
        Name = "Notif",
        Size = UDim2.new(1, 0, 0, 0), -- Animated height
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = activeTheme.Surface,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.Container
    }, {
        Utility:Create("UICorner", { CornerRadius = activeTheme.CornerRadius }),
        Utility:Create("UIStroke", { Color = activeTheme.Border, Thickness = 1 }),
        Utility:Create("Frame", {
            Name = "AccentBar",
            Size = UDim2.new(0, 4, 1, 0),
            BackgroundColor3 = typeColor,
            BorderSizePixel = 0
        }),
        Utility:Create("Frame", {
            Name = "Content",
            Size = UDim2.new(1, -14, 1, 0),
            Position = UDim2.new(0, 14, 0, 0),
            BackgroundTransparency = 1
        }, {
            Utility:Create("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 14)
            }),
            Utility:Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4)
            }),
            Utility:Create("TextLabel", {
                Name = "Title",
                Text = title,
                Font = activeTheme.FontBold,
                TextSize = 14,
                TextColor3 = activeTheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18)
            }),
            Utility:Create("TextLabel", {
                Name = "Desc",
                Text = desc,
                Font = activeTheme.Font,
                TextSize = 12,
                TextColor3 = activeTheme.SubText,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
        }),
        Utility:Create("Frame", {
            Name = "ProgressBar",
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = typeColor,
            BorderSizePixel = 0
        })
    })

    -- Entry animation
    Animation:Tween(notifFrame, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
        BackgroundTransparency = 0.05
    })
    
    local progressBar = notifFrame:FindFirstChild("ProgressBar")
    if progressBar then
        Animation:Tween(progressBar, duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, {
            Size = UDim2.new(0, 0, 0, 2)
        })
    end

    if callback then
        local btn = Utility:Create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            Parent = notifFrame
        })
        btn.MouseButton1Click:Connect(function()
            callback()
        end)
    end

    task.delay(duration, function()
        if notifFrame and notifFrame.Parent then
            local tw = Animation:Tween(notifFrame, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In, {
                BackgroundTransparency = 1
            })
            tw.Completed:Connect(function()
                notifFrame:Destroy()
            end)
        end
    end)
end

--------------------------------------------------------------------------------
-- TOOLTIP SYSTEM
--------------------------------------------------------------------------------
local TooltipSystem = {
    Frame = nil,
    TitleLabel = nil,
    DescLabel = nil,
}

function TooltipSystem:Initialize(parentGui)
    if self.Frame then return end
    local activeTheme = Theme:Get()
    self.Frame = Utility:Create("Frame", {
        Name = "AikoliaTooltip",
        Size = UDim2.new(0, 180, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = activeTheme.Surface,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 2000,
        Parent = parentGui
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
        Utility:Create("UIStroke", { Color = activeTheme.Border, Thickness = 1 }),
        Utility:Create("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 6),
            PaddingBottom = UDim.new(0, 6)
        }),
        Utility:Create("UIListLayout", { Padding = UDim.new(0, 2) }),
        Utility:Create("TextLabel", {
            Name = "Title",
            Text = "",
            Font = activeTheme.FontBold,
            TextSize = 12,
            TextColor3 = activeTheme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14)
        }),
        Utility:Create("TextLabel", {
            Name = "Desc",
            Text = "",
            Font = activeTheme.Font,
            TextSize = 11,
            TextColor3 = activeTheme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y
        })
    })

    self.TitleLabel = self.Frame.Title
    self.DescLabel = self.Frame.Desc

    Utility:Connect(RunService.RenderStepped, function()
        if self.Frame and self.Frame.Visible then
            local mousePos = UserInputService:GetMouseLocation()
            local vp = Utility:GetViewportSize()
            local x = math.min(mousePos.X + 12, vp.X - self.Frame.AbsoluteSize.X - 10)
            local y = math.min(mousePos.Y + 12, vp.Y - self.Frame.AbsoluteSize.Y - 10)
            self.Frame.Position = UDim2.fromOffset(x, y)
        end
    end)
end

function TooltipSystem:Show(title, desc)
    if not self.Frame then return end
    self.TitleLabel.Text = title or ""
    self.DescLabel.Text = desc or ""
    self.Frame.Visible = true
end

function TooltipSystem:Hide()
    if not self.Frame then return end
    self.Frame.Visible = false
end

--------------------------------------------------------------------------------
-- MAIN AIKOLIA LIBRARY MODULE
--------------------------------------------------------------------------------
local Aikolia = {
    Version = "1.0.0",
    Gui = nil,
    Windows = {},
    Configs = {},
    Flags = {},
    OnConfigLoaded = nil
}

function Aikolia:Initialize()
    if self.Gui then return end
    self.Gui = Utility:Create("ScreenGui", {
        Name = "AikoliaUIFramework",
        ResetOnSpawn = false,
        DisplayOrder = 100,
        Parent = Utility:GetParentGui()
    })

    NotificationSystem:Initialize(self.Gui)
    TooltipSystem:Initialize(self.Gui)
end

function Aikolia:SetTheme(themeNameOrTable)
    Theme:Set(themeNameOrTable)
end

function Aikolia:SetAnimationsEnabled(enabled)
    Animation.Enabled = enabled
end

function Aikolia:SetReducedMotion(enabled)
    Animation.ReducedMotion = enabled
end

function Aikolia:Notify(options)
    self:Initialize()
    NotificationSystem:Notify(options)
end

--------------------------------------------------------------------------------
-- WINDOW BUILDER
--------------------------------------------------------------------------------
function Aikolia:CreateWindow(options)
    self:Initialize()
    options = options or {}
    local titleText = options.Title or "Aikolia"
    local subtitleText = options.Subtitle or "UI Framework"
    local size = options.Size or UDim2.fromOffset(740, 520)
    local activeTheme = Theme:Get()

    local isMobile = Utility:IsTouch() or (Utility:GetViewportSize().X < 650)
    if isMobile then
        size = UDim2.new(0.94, 0, 0.88, 0)
    end

    local windowFrame = Utility:Create("Frame", {
        Name = "AikoliaWindow",
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = activeTheme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.Gui
    }, {
        Utility:Create("UICorner", { CornerRadius = activeTheme.CornerRadius }),
        Utility:Create("UIStroke", { Color = activeTheme.Border, Thickness = 1 }),
        -- Subtle Accent Glow
        Utility:Create("ImageLabel", {
            Name = "Glow",
            Size = UDim2.new(1, 40, 1, 40),
            Position = UDim2.new(0, -20, 0, -20),
            BackgroundTransparency = 1,
            Image = "rbxassetid://5028857472",
            ImageColor3 = activeTheme.Accent,
            ImageTransparency = 0.85,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(24, 24, 276, 276),
            ZIndex = 0
        })
    })

    -- Dragging Logic
    local topBar = Utility:Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = activeTheme.Surface,
        BorderSizePixel = 0,
        Parent = windowFrame
    }, {
        Utility:Create("UICorner", { CornerRadius = activeTheme.CornerRadius }),
        Utility:Create("Frame", {
            Name = "BottomMask",
            Size = UDim2.new(1, 0, 0, 10),
            Position = UDim2.new(0, 0, 1, -10),
            BackgroundColor3 = activeTheme.Surface,
            BorderSizePixel = 0
        }),
        Utility:Create("TextLabel", {
            Name = "Title",
            Text = titleText,
            Font = activeTheme.FontBold,
            TextSize = 16,
            TextColor3 = activeTheme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 16, 0, 10),
            Size = UDim2.new(0, 200, 0, 16),
            BackgroundTransparency = 1
        }),
        Utility:Create("TextLabel", {
            Name = "Subtitle",
            Text = subtitleText,
            Font = activeTheme.Font,
            TextSize = 12,
            TextColor3 = activeTheme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 16, 0, 26),
            Size = UDim2.new(0, 200, 0, 14),
            BackgroundTransparency = 1
        })
    })

    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        windowFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = windowFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    -- Window Controls (Minimize / Close)
    local controlsHolder = Utility:Create("Frame", {
        Name = "Controls",
        Size = UDim2.new(0, 70, 1, 0),
        Position = UDim2.new(1, -70, 0, 0),
        BackgroundTransparency = 1,
        Parent = topBar
    }, {
        Utility:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8)
        }),
        Utility:Create("UIPadding", { PaddingRight = UDim.new(0, 16) })
    })

    local isMinimized = false
    local originalSize = size

    local minBtn = Utility:Create("TextButton", {
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = Color3.fromRGB(245, 158, 11),
        Text = "",
        Parent = controlsHolder
    }, { Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

    local closeBtn = Utility:Create("TextButton", {
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = Color3.fromRGB(239, 68, 68),
        Text = "",
        Parent = controlsHolder
    }, { Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

    minBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        Animation:Tween(windowFrame, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {
            Size = isMinimized and UDim2.new(size.X.Scale, size.X.Offset, 0, 48) or originalSize
        })
    end)

    closeBtn.MouseButton1Click:Connect(function()
        Animation:Tween(windowFrame, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In, {
            Size = UDim2.new(0, size.X.Offset, 0, 0),
            BackgroundTransparency = 1
        }).Completed:Connect(function()
            windowFrame.Visible = false
        end)
    end)

    -- Content Area with Sidebar Navigation
    local bodyFrame = Utility:Create("Frame", {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -48),
        Position = UDim2.new(0, 0, 0, 48),
        BackgroundTransparency = 1,
        Parent = windowFrame
    })

    local navSidebar = Utility:Create("Frame", {
        Name = "Sidebar",
        Size = isMobile and UDim2.new(0, 50, 1, 0) or UDim2.new(0, 180, 1, 0),
        BackgroundColor3 = activeTheme.Surface,
        BorderSizePixel = 0,
        Parent = bodyFrame
    }, {
        Utility:Create("UIStroke", { Color = activeTheme.Border, Thickness = 1 }),
        Utility:Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8)
        }),
        Utility:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6)
        })
    })

    local tabContainer = Utility:Create("Frame", {
        Name = "TabContainer",
        Size = isMobile and UDim2.new(1, -50, 1, 0) or UDim2.new(1, -180, 1, 0),
        Position = isMobile and UDim2.new(0, 50, 0, 0) or UDim2.new(0, 180, 0, 0),
        BackgroundTransparency = 1,
        Parent = bodyFrame
    })

    local WindowObj = {
        Frame = windowFrame,
        Tabs = {},
        ActiveTab = nil
    }

    ----------------------------------------------------------------------------
    -- TAB SYSTEM
    ----------------------------------------------------------------------------
    function WindowObj:AddTab(tabOptions)
        tabOptions = tabOptions or {}
        local tabName = tabOptions.Name or "Tab"
        local tabIcon = tabOptions.Icon or "rbxassetid://6031763426"

        local tabButton = Utility:Create("TextButton", {
            Name = "TabButton_" .. tabName,
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = activeTheme.SurfaceVariant,
            BackgroundTransparency = 1,
            Text = "",
            Parent = navSidebar
        }, {
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
            Utility:Create("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 10)
            }),
            Utility:Create("UIPadding", { PaddingLeft = UDim.new(0, 10) }),
            Utility:Create("ImageLabel", {
                Name = "Icon",
                Size = UDim2.fromOffset(18, 18),
                Image = tabIcon,
                ImageColor3 = activeTheme.SubText,
                BackgroundTransparency = 1
            }),
            Utility:Create("TextLabel", {
                Name = "Label",
                Text = tabName,
                Font = activeTheme.Font,
                TextSize = 13,
                TextColor3 = activeTheme.SubText,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(1, -30, 1, 0),
                Visible = not isMobile,
                BackgroundTransparency = 1
            })
        })

        local tabContent = Utility:Create("ScrollingFrame", {
            Name = "TabContent_" .. tabName,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = activeTheme.Border,
            Visible = false,
            Parent = tabContainer
        }, {
            Utility:Create("UIPadding", {
                PaddingLeft = UDim.new(0, 14),
                PaddingRight = UDim.new(0, 14),
                PaddingTop = UDim.new(0, 14),
                PaddingBottom = UDim.new(0, 14)
            }),
            Utility:Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 12)
            })
        })

        local TabObj = {
            Name = tabName,
            Button = tabButton,
            Content = tabContent,
            Sections = {}
        }

        local function activateTab()
            for _, t in ipairs(WindowObj.Tabs) do
                t.Content.Visible = false
                Animation:Tween(t.Button, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {
                    BackgroundTransparency = 1
                })
                t.Button.Icon.ImageColor3 = activeTheme.SubText
                if t.Button:FindFirstChild("Label") then
                    t.Button.Label.TextColor3 = activeTheme.SubText
                end
            end

            tabContent.Visible = true
            Animation:Tween(tabButton, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {
                BackgroundTransparency = 0.8
            })
            tabButton.Icon.ImageColor3 = activeTheme.Accent
            if tabButton:FindFirstChild("Label") then
                tabButton.Label.TextColor3 = activeTheme.Text
            end
            WindowObj.ActiveTab = TabObj
        end

        tabButton.MouseButton1Click:Connect(activateTab)

        if #WindowObj.Tabs == 0 then
            activateTab()
        end

        table.insert(WindowObj.Tabs, TabObj)

        ------------------------------------------------------------------------
        -- SECTION / GROUPBOX SYSTEM
        ------------------------------------------------------------------------
        function TabObj:AddSection(sectionTitle)
            local groupbox = Utility:Create("Frame", {
                Name = "Section_" .. sectionTitle,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = activeTheme.Surface,
                BorderSizePixel = 0,
                Parent = tabContent
            }, {
                Utility:Create("UICorner", { CornerRadius = activeTheme.CornerRadius }),
                Utility:Create("UIStroke", { Color = activeTheme.Border, Thickness = 1 }),
                Utility:Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 12),
                    PaddingRight = UDim.new(0, 12),
                    PaddingTop = UDim.new(0, 10),
                    PaddingBottom = UDim.new(0, 12)
                }),
                Utility:Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 8)
                }),
                Utility:Create("TextLabel", {
                    Name = "SectionHeader",
                    Text = sectionTitle,
                    Font = activeTheme.FontBold,
                    TextSize = 13,
                    TextColor3 = activeTheme.Accent,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1
                })
            })

            local SectionObj = { Frame = groupbox }

            --------------------------------------------------------------------
            -- CONTROLS
            --------------------------------------------------------------------
            
            -- BUTTON
            function SectionObj:AddButton(text, callback, icon)
                local btn = Utility:Create("TextButton", {
                    Name = "Button_" .. text,
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundColor3 = activeTheme.SurfaceVariant,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = groupbox
                }, {
                    Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                    Utility:Create("UIStroke", { Color = activeTheme.Border, Thickness = 1 }),
                    Utility:Create("TextLabel", {
                        Name = "BtnText",
                        Text = text,
                        Font = activeTheme.Font,
                        TextSize = 13,
                        TextColor3 = activeTheme.Text,
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1
                    })
                })

                btn.MouseEnter:Connect(function()
                    Animation:Tween(btn, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, { BackgroundColor3 = activeTheme.Border })
                end)
                btn.MouseLeave:Connect(function()
                    Animation:Tween(btn, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, { BackgroundColor3 = activeTheme.SurfaceVariant })
                end)
                btn.MouseButton1Click:Connect(function()
                    Animation:Spring(btn, { Size = UDim2.new(1, -4, 0, 32) }, 10, 0.5)
                    task.delay(0.1, function()
                        Animation:Spring(btn, { Size = UDim2.new(1, 0, 0, 34) }, 10, 0.5)
                    end)
                    if callback then callback() end
                end)
                return btn
            end

            -- TOGGLE
            function SectionObj:AddToggle(flag, options)
                options = options or {}
                local text = options.Text or flag
                local default = options.Default or false
                local callback = options.Callback

                local toggled = default
                Aikolia.Flags[flag] = toggled

                local toggleFrame = Utility:Create("Frame", {
                    Name = "Toggle_" .. text,
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    Parent = groupbox
                }, {
                    Utility:Create("TextLabel", {
                        Text = text,
                        Font = activeTheme.Font,
                        TextSize = 13,
                        TextColor3 = activeTheme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Size = UDim2.new(1, -50, 1, 0),
                        BackgroundTransparency = 1
                    })
                })

                local switchTrack = Utility:Create("TextButton", {
                    Name = "Track",
                    Size = UDim2.fromOffset(40, 20),
                    Position = UDim2.new(1, -40, 0.5, -10),
                    BackgroundColor3 = toggled and activeTheme.Accent or activeTheme.SurfaceVariant,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = toggleFrame
                }, {
                    Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                    Utility:Create("UIStroke", { Color = activeTheme.Border, Thickness = 1 })
                })

                local switchThumb = Utility:Create("Frame", {
                    Name = "Thumb",
                    Size = UDim2.fromOffset(16, 16),
                    Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                    BackgroundColor3 = activeTheme.Text,
                    BorderSizePixel = 0,
                    Parent = switchTrack
                }, { Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

                local function updateState(state)
                    toggled = state
                    Aikolia.Flags[flag] = toggled
                    Animation:Tween(switchTrack, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {
                        BackgroundColor3 = toggled and activeTheme.Accent or activeTheme.SurfaceVariant
                    })
                    Animation:Tween(switchThumb, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {
                        Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                    })
                    if callback then callback(toggled) end
                end

                switchTrack.MouseButton1Click:Connect(function()
                    updateState(not toggled)
                end)

                return {
                    Set = updateState
                }
            end

            -- SLIDER
            function SectionObj:AddSlider(flag, options)
                options = options or {}
                local text = options.Text or flag
                local min = options.Min or 0
                local max = options.Max or 100
                local default = options.Default or min
                local rounding = options.Rounding or 0
                local callback = options.Callback

                local value = default
                Aikolia.Flags[flag] = value

                local sliderFrame = Utility:Create("Frame", {
                    Name = "Slider_" .. text,
                    Size = UDim2.new(1, 0, 0, 44),
                    BackgroundTransparency = 1,
                    Parent = groupbox
                }, {
                    Utility:Create("TextLabel", {
                        Text = text,
                        Font = activeTheme.Font,
                        TextSize = 13,
                        TextColor3 = activeTheme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Size = UDim2.new(0.7, 0, 0, 18),
                        BackgroundTransparency = 1
                    }),
                    Utility:Create("TextLabel", {
                        Name = "ValueLabel",
                        Text = tostring(value),
                        Font = activeTheme.Font,
                        TextSize = 12,
                        TextColor3 = activeTheme.SubText,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Size = UDim2.new(0.3, 0, 0, 18),
                        Position = UDim2.new(0.7, 0, 0, 0),
                        BackgroundTransparency = 1
                    })
                })

                local track = Utility:Create("TextButton", {
                    Name = "Track",
                    Size = UDim2.new(1, 0, 0, 8),
                    Position = UDim2.new(0, 0, 0, 26),
                    BackgroundColor3 = activeTheme.SurfaceVariant,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = sliderFrame
                }, {
                    Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
                })

                local fill = Utility:Create("Frame", {
                    Name = "Fill",
                    Size = UDim2.new((value - min)/(max - min), 0, 1, 0),
                    BackgroundColor3 = activeTheme.Accent,
                    BorderSizePixel = 0,
                    Parent = track
                }, { Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })

                local draggingSlider = false
                local function updateSlider(input)
                    local pct = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    local val = min + (max - min) * pct
                    if rounding == 0 then
                        val = math.floor(val)
                    else
                        val = tonumber(string.format("%." .. rounding .. "f", val))
                    end
                    value = val
                    Aikolia.Flags[flag] = value
                    fill.Size = UDim2.new(pct, 0, 1, 0)
                    sliderFrame.ValueLabel.Text = tostring(value)
                    if callback then callback(value) end
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSlider = true
                        updateSlider(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSlider = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateSlider(input)
                    end
                end)

                return {
                    Set = function(val)
                        val = math.clamp(val, min, max)
                        value = val
                        Aikolia.Flags[flag] = value
                        fill.Size = UDim2.new((value - min)/(max - min), 0, 1, 0)
                        sliderFrame.ValueLabel.Text = tostring(value)
                        if callback then callback(value) end
                    end
                }
            end

            -- DROPDOWN
            function SectionObj:AddDropdown(flag, options)
                options = options or {}
                local text = options.Text or flag
                local items = options.Options or {}
                local default = options.Default or items[1]
                local callback = options.Callback

                local selected = default
                Aikolia.Flags[flag] = selected

                local dropdownFrame = Utility:Create("Frame", {
                    Name = "Dropdown_" .. text,
                    Size = UDim2.new(1, 0, 0, 56),
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    Parent = groupbox
                }, {
                    Utility:Create("TextLabel", {
                        Text = text,
                        Font = activeTheme.Font,
                        TextSize = 13,
                        TextColor3 = activeTheme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Size = UDim2.new(1, 0, 0, 18),
                        BackgroundTransparency = 1
                    })
                })

                local mainBtn = Utility:Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 32),
                    Position = UDim2.new(0, 0, 0, 22),
                    BackgroundColor3 = activeTheme.SurfaceVariant,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = dropdownFrame
                }, {
                    Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                    Utility:Create("UIStroke", { Color = activeTheme.Border, Thickness = 1 }),
                    Utility:Create("TextLabel", {
                        Name = "SelectedText",
                        Text = tostring(selected or "Select..."),
                        Font = activeTheme.Font,
                        TextSize = 12,
                        TextColor3 = activeTheme.SubText,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Size = UDim2.new(1, -30, 1, 0),
                        Position = UDim2.new(0, 10, 0, 0),
                        BackgroundTransparency = 1
                    })
                })

                local isOpen = false
                mainBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    Animation:Tween(dropdownFrame, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {
                        Size = isOpen and UDim2.new(1, 0, 0, 56 + (#items * 28)) or UDim2.new(1, 0, 0, 56)
                    })
                end)

                for i, item in ipairs(items) do
                    local optBtn = Utility:Create("TextButton", {
                        Size = UDim2.new(1, -12, 0, 26),
                        Position = UDim2.new(0, 6, 0, 58 + ((i-1) * 28)),
                        BackgroundColor3 = activeTheme.Surface,
                        Text = tostring(item),
                        Font = activeTheme.Font,
                        TextSize = 12,
                        TextColor3 = activeTheme.Text,
                        Parent = dropdownFrame
                    }, { Utility:Create("UICorner", { CornerRadius = UDim.new(0, 4) }) })

                    optBtn.MouseButton1Click:Connect(function()
                        selected = item
                        Aikolia.Flags[flag] = selected
                        mainBtn.SelectedText.Text = tostring(selected)
                        isOpen = false
                        Animation:Tween(dropdownFrame, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, {
                            Size = UDim2.new(1, 0, 0, 56)
                        })
                        if callback then callback(selected) end
                    end)
                end
            end

            -- INPUT
            function SectionObj:AddInput(flag, options)
                options = options or {}
                local text = options.Text or flag
                local placeholder = options.Placeholder or "Type here..."
                local callback = options.Callback

                local inputFrame = Utility:Create("Frame", {
                    Name = "Input_" .. text,
                    Size = UDim2.new(1, 0, 0, 56),
                    BackgroundTransparency = 1,
                    Parent = groupbox
                }, {
                    Utility:Create("TextLabel", {
                        Text = text,
                        Font = activeTheme.Font,
                        TextSize = 13,
                        TextColor3 = activeTheme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Size = UDim2.new(1, 0, 0, 18),
                        BackgroundTransparency = 1
                    })
                })

                local textBox = Utility:Create("TextBox", {
                    Size = UDim2.new(1, 0, 0, 32),
                    Position = UDim2.new(0, 0, 0, 22),
                    BackgroundColor3 = activeTheme.SurfaceVariant,
                    PlaceholderText = placeholder,
                    Text = "",
                    Font = activeTheme.Font,
                    TextSize = 12,
                    TextColor3 = activeTheme.Text,
                    PlaceholderColor3 = activeTheme.SubText,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    Parent = inputFrame
                }, {
                    Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                    Utility:Create("UIStroke", { Color = activeTheme.Border, Thickness = 1 }),
                    Utility:Create("UIPadding", { PaddingLeft = UDim.new(0, 10) })
                })

                textBox.FocusLost:Connect(function(enterPressed)
                    Aikolia.Flags[flag] = textBox.Text
                    if callback then callback(textBox.Text, enterPressed) end
                end)
            end

            -- KEYBIND
            function SectionObj:AddKeybind(flag, options)
                options = options or {}
                local text = options.Text or flag
                local defaultKey = options.Default or Enum.KeyCode.E
                local callback = options.Callback

                local currentKey = defaultKey
                Aikolia.Flags[flag] = currentKey

                local keybindFrame = Utility:Create("Frame", {
                    Name = "Keybind_" .. text,
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    Parent = groupbox
                }, {
                    Utility:Create("TextLabel", {
                        Text = text,
                        Font = activeTheme.Font,
                        TextSize = 13,
                        TextColor3 = activeTheme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Size = UDim2.new(1, -70, 1, 0),
                        BackgroundTransparency = 1
                    })
                })

                local bindBtn = Utility:Create("TextButton", {
                    Size = UDim2.fromOffset(60, 22),
                    Position = UDim2.new(1, -60, 0.5, -11),
                    BackgroundColor3 = activeTheme.SurfaceVariant,
                    Text = currentKey.Name,
                    Font = activeTheme.FontBold,
                    TextSize = 11,
                    TextColor3 = activeTheme.Accent,
                    Parent = keybindFrame
                }, {
                    Utility:Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    Utility:Create("UIStroke", { Color = activeTheme.Border, Thickness = 1 })
                })

                local binding = false
                bindBtn.MouseButton1Click:Connect(function()
                    binding = true
                    bindBtn.Text = "..."
                end)

                UserInputService.InputBegan:Connect(function(input, gpe)
                    if gpe then return end
                    if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        Aikolia.Flags[flag] = currentKey
                        bindBtn.Text = currentKey.Name
                        binding = false
                    elseif not binding and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
                        if callback then callback(currentKey) end
                    end
                end)
            end

            -- COLOR PICKER
            function SectionObj:AddColorPicker(flag, options)
                options = options or {}
                local text = options.Text or flag
                local defaultColor = options.Default or Color3.fromRGB(139, 92, 246)
                local callback = options.Callback

                local colorVal = defaultColor
                Aikolia.Flags[flag] = colorVal

                local cpFrame = Utility:Create("Frame", {
                    Name = "ColorPicker_" .. text,
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    Parent = groupbox
                }, {
                    Utility:Create("TextLabel", {
                        Text = text,
                        Font = activeTheme.Font,
                        TextSize = 13,
                        TextColor3 = activeTheme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Size = UDim2.new(1, -40, 1, 0),
                        BackgroundTransparency = 1
                    })
                })

                local previewBtn = Utility:Create("TextButton", {
                    Size = UDim2.fromOffset(30, 18),
                    Position = UDim2.new(1, -30, 0.5, -9),
                    BackgroundColor3 = colorVal,
                    Text = "",
                    Parent = cpFrame
                }, {
                    Utility:Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    Utility:Create("UIStroke", { Color = activeTheme.Border, Thickness = 1 })
                })

                previewBtn.MouseButton1Click:Connect(function()
                    -- Cycle basic colors as demonstrative interactive color picker
                    local colors = {
                        Color3.fromRGB(139, 92, 246),
                        Color3.fromRGB(59, 130, 246),
                        Color3.fromRGB(34, 197, 94),
                        Color3.fromRGB(245, 158, 11),
                        Color3.fromRGB(239, 68, 68)
                    }
                    local idx = 1
                    for i, c in ipairs(colors) do
                        if c == colorVal then idx = (i % #colors) + 1 break end
                    end
                    colorVal = colors[idx]
                    Aikolia.Flags[flag] = colorVal
                    previewBtn.BackgroundColor3 = colorVal
                    if callback then callback(colorVal) end
                end)
            end

            return SectionObj
        end

        return TabObj
    end

    ----------------------------------------------------------------------------
    -- ESP PREVIEW PANEL BUILDER
    ----------------------------------------------------------------------------
    function WindowObj:AddESPPreviewTab(tabOptions)
        tabOptions = tabOptions or {}
        local tab = self:AddTab({ Name = tabOptions.Name or "ESP Preview", Icon = "rbxassetid://6031075931" })
        local section = tab:AddSection("3D Character ESP Preview")

        local activeTheme = Theme:Get()
        local vpContainer = Utility:Create("Frame", {
            Name = "ViewportContainer",
            Size = UDim2.new(1, 0, 0, 220),
            BackgroundColor3 = activeTheme.SurfaceVariant,
            Parent = section.Frame
        }, {
            Utility:Create("UICorner", { CornerRadius = activeTheme.CornerRadius }),
            Utility:Create("UIStroke", { Color = activeTheme.Border, Thickness = 1 })
        })

        local viewportFrame = Utility:Create("ViewportFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Parent = vpContainer
        })

        local camera = Instance.new("Camera")
        camera.CFrame = CFrame.new(Vector3.new(0, 2, 7), Vector3.new(0, 1, 0))
        viewportFrame.CurrentCamera = camera

        -- Create Dummy Character inside Viewport
        local dummy = Instance.new("Model")
        dummy.Name = "ESPDummy"
        
        local hrp = Utility:Create("Part", { Name = "HumanoidRootPart", Size = Vector3.new(2, 2, 1), Position = Vector3.new(0, 1, 0), Anchored = true, Transparency = 1, Parent = dummy })
        local head = Utility:Create("Part", { Name = "Head", Size = Vector3.new(1.2, 1.2, 1.2), Position = Vector3.new(0, 2.6, 0), Anchored = true, Color = Color3.fromRGB(220, 220, 220), Parent = dummy })
        local torso = Utility:Create("Part", { Name = "Torso", Size = Vector3.new(2, 2, 1), Position = Vector3.new(0, 1, 0), Anchored = true, Color = activeTheme.Accent, Parent = dummy })
        dummy.PrimaryPart = hrp
        dummy.Parent = viewportFrame

        -- ESP Overlay Drawing Simulation
        local boxOverlay = Utility:Create("Frame", {
            Name = "ESPBox",
            Size = UDim2.fromOffset(90, 140),
            Position = UDim2.new(0.5, -45, 0.5, -70),
            BackgroundTransparency = 1,
            Parent = vpContainer
        }, {
            Utility:Create("UIStroke", { Color = activeTheme.Accent, Thickness = 1.5 }),
            Utility:Create("TextLabel", {
                Text = "Target Dummy [15m]",
                Font = activeTheme.FontBold,
                TextSize = 10,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(1, 0, 0, 14),
                Position = UDim2.new(0, 0, 0, -16),
                BackgroundTransparency = 1
            }),
            Utility:Create("Frame", {
                Name = "HealthBar",
                Size = UDim2.new(0, 3, 1, 0),
                Position = UDim2.new(0, -6, 0, 0),
                BackgroundColor3 = activeTheme.Success,
                BorderSizePixel = 0
            })
        })

        section:AddToggle("ESP_Box", { Text = "Show 2D Bounding Box", Default = true, Callback = function(v) boxOverlay.Visible = v end })
        section:AddToggle("ESP_Health", { Text = "Show Health Bar", Default = true, Callback = function(v) boxOverlay.HealthBar.Visible = v end })
        
        -- Rotation loop for preview dummy
        local angle = 0
        Utility:Connect(RunService.RenderStepped, function(dt)
            if vpContainer and vpContainer.Visible then
                angle = angle + (dt * 45)
                hrp.CFrame = CFrame.new(Vector3.new(0, 1, 0)) * CFrame.Angles(0, math.rad(angle), 0)
                torso.CFrame = hrp.CFrame
                head.CFrame = hrp.CFrame * CFrame.new(0, 1.6, 0)
            end
        end)
    end

    return WindowObj
end

--------------------------------------------------------------------------------
-- CONFIGURATION MANAGEMENT
--------------------------------------------------------------------------------
function Aikolia:SaveConfig(name)
    local json = HttpService:JSONEncode(self.Flags)
    if writefile then
        pcall(function() writefile("Aikolia_" .. name .. ".json", json) end)
    end
    self.Configs[name] = json
    self:Notify({ Title = "Config Saved", Description = "Configuration '" .. name .. "' saved successfully.", Type = "Success" })
end

function Aikolia:LoadConfig(name)
    local json = self.Configs[name]
    if writefile and readfile and isfile and isfile("Aikolia_" .. name .. ".json") then
        pcall(function() json = readfile("Aikolia_" .. name .. ".json") end)
    end
    if json then
        local data = HttpService:JSONDecode(json)
        for k, v in pairs(data) do
            self.Flags[k] = v
        end
        self:Notify({ Title = "Config Loaded", Description = "Loaded '" .. name .. "'.", Type = "Info" })
    end
end

--------------------------------------------------------------------------------
-- CLEANUP / UNLOAD
--------------------------------------------------------------------------------
function Aikolia:Unload()
    Utility:DisconnectAll()
    if self.Gui then
        self.Gui:Destroy()
        self.Gui = nil
    end
    table.clear(self.Windows)
    table.clear(self.Flags)
end

return Aikolia
