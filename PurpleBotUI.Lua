--Made by WARNINGBOT_DEAD

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Utility function to convert scale to offset
local function ScaleToOffset(scale)
	local viewportSize = workspace.Camera.ViewportSize
	return {viewportSize.X * scale[1], viewportSize.Y * scale[2]}
end

-- Default tween info for smooth animations
local defaultTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

-- PurpleBotUI Library
local PurpleBotUI = {}

-- Tween utility function
function PurpleBotUI:Tween(object, tweenInfo, goal, callback)
	local tween = TweenService:Create(object, tweenInfo or defaultTweenInfo, goal)
	if callback then
		tween.Completed:Once(callback)
	end
	tween:Play()
	return tween
end

-- Main UI creation function
function PurpleBotUI:Create(args)
	args = args or {}
	local UI = {
		CurrentTab = nil,
		Tabs = {},
		Theme = {
			Primary = Color3.fromRGB(150, 100, 200), -- Vibrant purple
			Secondary = Color3.fromRGB(100, 50, 150),
			Background = Color3.fromRGB(30, 30, 40),
			Accent = Color3.fromRGB(200, 150, 255),
			Text = Color3.fromRGB(255, 255, 255),
			Border = Color3.fromRGB(80, 80, 100),
		},
		IsMinimized = false,
		OnDestroyed = args.OnDestroyed,
	}

	-- ScreenGui
	UI.ScreenGui = Instance.new("ScreenGui")
	UI.ScreenGui.Name = "PurpleBotUI"
	UI.ScreenGui.ResetOnSpawn = false
	UI.ScreenGui.IgnoreGuiInset = true
	UI.ScreenGui.Parent = RunService:IsStudio() and player:WaitForChild("PlayerGui") or game:GetService("CoreGui")

	-- Main Frame
	UI.MainFrame = Instance.new("Frame", UI.ScreenGui)
	UI.MainFrame.Name = "Main"
	UI.MainFrame.BackgroundColor3 = UI.Theme.Background
	UI.MainFrame.Size = args.Size or UDim2.new(0.4, 0, 0.5, 0)
	UI.MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
	UI.MainFrame.ClipsDescendants = true
	UI.MainFrame.BorderSizePixel = 0

	-- UICorner for Main Frame
	UI.MainCorner = Instance.new("UICorner", UI.MainFrame)
	UI.MainCorner.CornerRadius = UDim.new(0.02, 0)

	-- UIStroke for neumorphic effect
	UI.MainStroke = Instance.new("UIStroke", UI.MainFrame)
	UI.MainStroke.Color = UI.Theme.Border
	UI.MainStroke.Thickness = 1
	UI.MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	-- Top Bar
	UI.TopBar = Instance.new("Frame", UI.MainFrame)
	UI.TopBar.Name = "TopBar"
	UI.TopBar.BackgroundColor3 = UI.Theme.Primary
	UI.TopBar.Size = UDim2.new(1, 0, 0.1, 0)
	UI.TopBar.ZIndex = 2
	UI.TopBar.BorderSizePixel = 0

	-- Top Bar Corner
	UI.TopBarCorner = Instance.new("UICorner", UI.TopBar)
	UI.TopBarCorner.CornerRadius = UDim.new(0.1, 0)

	-- Title
	UI.Title = Instance.new("TextLabel", UI.TopBar)
	UI.Title.Name = "Title"
	UI.Title.Text = args.Name or "PurpleBotUI"
	UI.Title.TextColor3 = UI.Theme.Text
	UI.Title.TextScaled = true
	UI.Title.TextXAlignment = Enum.TextXAlignment.Left
	UI.Title.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
	UI.Title.BackgroundTransparency = 1
	UI.Title.Size = UDim2.new(0.6, 0, 0.8, 0)
	UI.Title.Position = UDim2.new(0.05, 0, 0.1, 0)

	-- Exit Button
	UI.ExitButton = Instance.new("TextButton", UI.TopBar)
	UI.ExitButton.Name = "Exit"
	UI.ExitButton.Text = "×"
	UI.ExitButton.TextColor3 = UI.Theme.Text
	UI.ExitButton.TextScaled = true
	UI.ExitButton.FontFace = Font.new("rbxasset://fonts/families/Roboto.json")
	UI.ExitButton.BackgroundTransparency = 1
	UI.ExitButton.Size = UDim2.new(0.08, 0, 0.8, 0)
	UI.ExitButton.Position = UDim2.new(0.92, 0, 0.1, 0)
	UI.ExitButton.ZIndex = 3

	-- Minimize Button
	UI.MinimizeButton = Instance.new("ImageButton", UI.TopBar)
	UI.MinimizeButton.Name = "Minimize"
	UI.MinimizeButton.Image = "rbxassetid://7072719338" -- Minimize icon
	UI.MinimizeButton.BackgroundTransparency = 1
	UI.MinimizeButton.Size = UDim2.new(0.06, 0, 0.6, 0)
	UI.MinimizeButton.Position = UDim2.new(0.85, 0, 0.2, 0)
	UI.MinimizeButton.ZIndex = 3

	-- Sidebar
	UI.Sidebar = Instance.new("Frame", UI.MainFrame)
	UI.Sidebar.Name = "Sidebar"
	UI.Sidebar.BackgroundColor3 = UI.Theme.Secondary
	UI.Sidebar.Size = UDim2.new(0.25, 0, 0.85, 0)
	UI.Sidebar.Position = UDim2.new(0, 0, 0.15, 0)
	UI.Sidebar.BorderSizePixel = 0

	-- Sidebar Corner
	UI.SidebarCorner = Instance.new("UICorner", UI.Sidebar)
	UI.SidebarCorner.CornerRadius = UDim.new(0.05, 0)

	-- Sidebar Holder
	UI.SidebarHolder = Instance.new("Frame", UI.Sidebar)
	UI.SidebarHolder.Name = "Holder"
	UI.SidebarHolder.BackgroundTransparency = 1
	UI.SidebarHolder.Size = UDim2.new(1, 0, 1, 0)

	-- Sidebar List Layout
	UI.SidebarList = Instance.new("UIListLayout", UI.SidebarHolder)
	UI.SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
	UI.SidebarList.Padding = UDim.new(0.02, 0)

	-- Sidebar Padding
	UI.SidebarPadding = Instance.new("UIPadding", UI.SidebarHolder)
	UI.SidebarPadding.PaddingTop = UDim.new(0.05, 0)
	UI.SidebarPadding.PaddingLeft = UDim.new(0.05, 0)

	-- Tab Holder
	UI.TabHolder = Instance.new("Frame", UI.MainFrame)
	UI.TabHolder.Name = "TabHolder"
	UI.TabHolder.BackgroundTransparency = 1
	UI.TabHolder.Size = UDim2.new(0.7, 0, 0.85, 0)
	UI.TabHolder.Position = UDim2.new(0.3, 0, 0.15, 0)

	-- Notification Frame
	UI.NotifyFrame = Instance.new("Frame", UI.MainFrame)
	UI.NotifyFrame.Name = "NotifyFrame"
	UI.NotifyFrame.BackgroundColor3 = UI.Theme.Background
	UI.NotifyFrame.Size = UDim2.new(0.4, 0, 0.15, 0)
	UI.NotifyFrame.Position = UDim2.new(0.3, 0, 1.1, 0)
	UI.NotifyFrame.ZIndex = 5
	UI.NotifyFrame.BorderSizePixel = 0

	-- Notification Text
	UI.NotifyText = Instance.new("TextLabel", UI.NotifyFrame)
	UI.NotifyText.Text = "Notification"
	UI.NotifyText.TextColor3 = UI.Theme.Text
	UI.NotifyText.TextScaled = true
	UI.NotifyText.FontFace = Font.new("rbxasset://fonts/families/Roboto.json")
	UI.NotifyText.BackgroundTransparency = 1
	UI.NotifyText.Size = UDim2.new(0.9, 0, 0.6, 0)
	UI.NotifyText.Position = UDim2.new(0.05, 0, 0.2, 0)
	UI.NotifyText.ZIndex = 5

	-- Notification Close Button
	UI.NotifyClose = Instance.new("TextButton", UI.NotifyFrame)
	UI.NotifyClose.Text = "×"
	UI.NotifyClose.TextColor3 = UI.Theme.Text
	UI.NotifyClose.TextScaled = true
	UI.NotifyClose.FontFace = Font.new("rbxasset://fonts/families/Roboto.json")
	UI.NotifyClose.BackgroundTransparency = 1
	UI.NotifyClose.Size = UDim2.new(0.1, 0, 0.3, 0)
	UI.NotifyClose.Position = UDim2.new(0.9, 0, 0, 0)
	UI.NotifyClose.ZIndex = 5

	-- Notification Stroke
	UI.NotifyStroke = Instance.new("UIStroke", UI.NotifyFrame)
	UI.NotifyStroke.Color = UI.Theme.Accent
	UI.NotifyStroke.Thickness = 2
	UI.NotifyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	-- Notification Animation
	local notifyEnterPos = UDim2.new(0.3, 0, 0.8, 0)
	local notifyExitPos = UI.NotifyFrame.Position
	local notifyTweenIn = TweenService:Create(UI.NotifyFrame, defaultTweenInfo, {Position = notifyEnterPos})
	local notifyTweenOut = TweenService:Create(UI.NotifyFrame, defaultTweenInfo, {Position = notifyExitPos})

	function UI:Notify(text, duration)
		UI.NotifyText.Text = tostring(text)
		duration = duration or 3
		if notifyTweenIn.PlaybackState == Enum.PlaybackState.Playing then
			notifyTweenIn:Cancel()
			UI.NotifyFrame.Position = notifyExitPos
		end
		notifyTweenIn:Play()
		task.delay(duration, function()
			notifyTweenOut:Play()
		end)
	end

	UI.NotifyClose.MouseButton1Click:Connect(function()
		notifyTweenOut:Play()
	end)

	-- Dragging Functionality
	local function makeDraggable(frame)
		local dragging, dragInput, dragStart, startPos
		local function update(input)
			local delta = input.Position - dragStart
			local newPos = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
			-- Boundary checking
			local screenSize = workspace.Camera.ViewportSize
			newPos = UDim2.new(
				math.clamp(newPos.X.Scale, 0, 1 - frame.Size.X.Scale),
				newPos.X.Offset,
				math.clamp(newPos.Y.Scale, 0, 1 - frame.Size.Y.Scale),
				newPos.Y.Offset
			)
			PurpleBotUI:Tween(frame, TweenInfo.new(0.1), {Position = newPos})
		end

		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = frame.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)

		frame.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end)
	end
	makeDraggable(UI.MainFrame)

	-- Minimize Functionality
	local originalSize = UI.MainFrame.Size
	local minimizedSize = args.MinimizedSize or UDim2.new(0.2, 0, 0.1, 0)

	UI.MinimizeButton.MouseButton1Click:Connect(function()
		UI.IsMinimized = not UI.IsMinimized
		if UI.IsMinimized then
			PurpleBotUI:Tween(UI.MainFrame, nil, {Size = minimizedSize})
			UI.Sidebar.Visible = false
			UI.TabHolder.Visible = false
			PurpleBotUI:Tween(UI.TopBar, nil, {BackgroundColor3 = UI.Theme.Secondary})
		else
			PurpleBotUI:Tween(UI.MainFrame, nil, {Size = originalSize})
			UI.Sidebar.Visible = true
			UI.TabHolder.Visible = true
			PurpleBotUI:Tween(UI.TopBar, nil, {BackgroundColor3 = UI.Theme.Primary})
		end
	end)

	-- Exit Functionality
	UI.ExitButton.MouseButton1Click:Connect(function()
		if UI.OnDestroyed then
			UI.OnDestroyed()
		end
		UI.ScreenGui:Destroy()
	end)

	-- Tab Creation
	function UI:CreateTab(options)
		options = options or {}
		local Tab = {
			Name = options.Name or "Tab",
			IsActive = false,
			Hover = false,
		}

		-- Tab Button
		Tab.Button = Instance.new("TextButton", UI.SidebarHolder)
		Tab.Button.Name = options.Name or "TabButton"
		Tab.Button.Text = options.Name or "Tab"
		Tab.Button.TextColor3 = UI.Theme.Text
		Tab.Button.TextScaled = true
		Tab.Button.TextXAlignment = Enum.TextXAlignment.Left
		Tab.Button.FontFace = Font.new("rbxasset://fonts/families/Roboto.json")
		Tab.Button.BackgroundColor3 = UI.Theme.Secondary
		Tab.Button.BackgroundTransparency = 0.8
		Tab.Button.Size = UDim2.new(0.9, 0, 0.08, 0)
		Tab.Button.AutoButtonColor = false
		Tab.Button.ZIndex = 3

		-- Tab Button Corner
		Tab.ButtonCorner = Instance.new("UICorner", Tab.Button)
		Tab.ButtonCorner.CornerRadius = UDim.new(0.2, 0)

		-- Tab Button Padding
		Tab.ButtonPadding = Instance.new("UIPadding", Tab.Button)
		Tab.ButtonPadding.PaddingLeft = UDim.new(0.1, 0)

		-- Tab Content
		Tab.ScrollingFrame = Instance.new("ScrollingFrame", UI.TabHolder)
		Tab.ScrollingFrame.Name = options.Name or "TabContent"
		Tab.ScrollingFrame.BackgroundTransparency = 1
		Tab.ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
		Tab.ScrollingFrame.ScrollBarThickness = 4
		Tab.ScrollingFrame.ScrollBarImageColor3 = UI.Theme.Accent
		Tab.ScrollingFrame.Visible = false
		Tab.ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
		Tab.ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

		-- Scrolling Frame Layout
		Tab.ListLayout = Instance.new("UIListLayout", Tab.ScrollingFrame)
		Tab.ListLayout.SortOrder = options.Alphabetical and Enum.SortOrder.Name or Enum.SortOrder.LayoutOrder
		Tab.ListLayout.Padding = UDim.new(0.02, 0)

		-- Scrolling Frame Padding
		Tab.Padding = Instance.new("UIPadding", Tab.ScrollingFrame)
		Tab.Padding.PaddingTop = UDim.new(0.02, 0)
		Tab.Padding.PaddingLeft = UDim.new(0.02, 0)

		-- Hover Effects
		Tab.Button.MouseEnter:Connect(function()
			Tab.Hover = true
			if not Tab.IsActive then
				PurpleBotUI:Tween(Tab.Button, nil, {BackgroundTransparency = 0.5, TextColor3 = UI.Theme.Accent})
			end
		end)

		Tab.Button.MouseLeave:Connect(function()
			Tab.Hover = false
			if not Tab.IsActive then
				PurpleBotUI:Tween(Tab.Button, nil, {BackgroundTransparency = 0.8, TextColor3 = UI.Theme.Text})
			end
		end)

		-- Tab Activation
		function Tab:Activate()
			if not Tab.IsActive then
				Tab.IsActive = true
				UI.CurrentTab = Tab
				PurpleBotUI:Tween(Tab.Button, nil, {BackgroundTransparency = 0, BackgroundColor3 = UI.Theme.Primary})
				Tab.ScrollingFrame.Visible = true
			end
		end

		function Tab:Deactivate()
			if Tab.IsActive then
				Tab.IsActive = false
				PurpleBotUI:Tween(Tab.Button, nil, {BackgroundTransparency = 0.8, BackgroundColor3 = UI.Theme.Secondary})
				Tab.ScrollingFrame.Visible = false
			end
		end

		Tab.Button.MouseButton1Click:Connect(function()
			for _, tab in ipairs(UI.Tabs) do
				if tab ~= Tab then
					tab:Deactivate()
				end
			end
			Tab:Activate()
		end)

		-- Button Component
		function Tab:Button(options)
			options = options or {}
			local Button = {}

			Button.Frame = Instance.new("TextButton", Tab.ScrollingFrame)
			Button.Frame.Name = options.Name or "Button"
			Button.Frame.Text = ""
			Button.Frame.BackgroundColor3 = options.Color or UI.Theme.Background
			Button.Frame.Size = options.Size or UDim2.new(0.95, 0, 0.06, 0)
			Button.Frame.AutoButtonColor = false
			Button.Frame.BorderSizePixel = 0

			-- Button Corner
			Button.Corner = Instance.new("UICorner", Button.Frame)
			Button.Corner.CornerRadius = UDim.new(0.1, 0)

			-- Button Stroke
			Button.Stroke = Instance.new("UIStroke", Button.Frame)
			Button.Stroke.Color = UI.Theme.Border
			Button.Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			-- Button Text
			Button.Text = Instance.new("TextLabel", Button.Frame)
			Button.Text.Text = options.Text or "Button"
			Button.Text.TextColor3 = UI.Theme.Text
			Button.Text.TextScaled = true
			Button.Text.TextXAlignment = Enum.TextXAlignment.Left
			Button.Text.FontFace = Font.new("rbxasset://fonts/families/Roboto.json")
			Button.Text.BackgroundTransparency = 1
			Button.Text.Size = UDim2.new(0.8, 0, 0.7, 0)
			Button.Text.Position = UDim2.new(0.05, 0, 0.15, 0)

			-- Button Icon
			Button.Icon = Instance.new("ImageLabel", Button.Frame)
			Button.Icon.Name = "Icon"
			Button.Icon.Image = options.Icon or "rbxassetid://7072719338"
			Button.Icon.BackgroundTransparency = 1
			Button.Icon.Size = UDim2.new(0.1, 0, 0.7, 0)
			Button.Icon.Position = UDim2.new(0.85, 0, 0.15, 0)
			Button.Icon.Visible = options.Icon ~= nil

			-- Button Click
			Button.Frame.MouseButton1Click:Connect(function()
				if options.Callback then
					options.Callback()
				end
			end)

			function Button:SetText(text)
				Button.Text.Text = text
			end

			function Button:Toggle(state)
				Button.Stroke.Color = state and UI.Theme.Accent or UI.Theme.Border
			end

			return Button
		end

		-- Slider Component
		function Tab:Slider(options)
			options = options or {}
			local Slider = {
				Value = options.Default or 0,
				Min = options.Min or 0,
				Max = options.Max or 100,
				Decimals = options.Decimals or 1,
			}

			Slider.Frame = Instance.new("Frame", Tab.ScrollingFrame)
			Slider.Frame.Name = options.Name or "Slider"
			Slider.Frame.BackgroundColor3 = UI.Theme.Background
			/slider.Frame.Size = UDim2.new(0.95, 0, 0.1, 0)
			Slider.Frame.BorderSizePixel = 0

			-- Slider Corner
			Slider.Corner = Instance.new("UICorner", Slider.Frame)
			Slider.Corner.CornerRadius = UDim.new(0.1, 0)

			-- Slider Stroke
			Slider.Stroke = Instance.new("UIStroke", Slider.Frame)
			Slider.Stroke.Color = UI.Theme.Border
			Slider.Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			-- Slider Title
			Slider.Title = Instance.new("TextLabel", Slider.Frame)
			Slider.Title.Text = options.Text or "Slider"
			Slider.Title.TextColor3 = UI.Theme.Text
			Slider.Title.TextScaled = true
			Slider.Title.TextXAlignment = Enum.TextXAlignment.Left
			Slider.Title.FontFace = Font.new("rbxasset://fonts/families/Roboto.json")
			Slider.Title.BackgroundTransparency = 1
			Slider.Title.Size = UDim2.new(0.7, 0, 0.4, 0)
			Slider.Title.Position = UDim2.new(0.05, 0, 0.1, 0)

			-- Slider Value
			Slider.ValueText = Instance.new("TextBox", Slider.Frame)
			Slider.ValueText.Text = tostring(Slider.Value)
			Slider.ValueText.TextColor3 = UI.Theme.Text
			Slider.ValueText.TextScaled = true
			Slider.ValueText.FontFace = Font.new("rbxasset://fonts/families/Roboto.json")
			Slider.ValueText.BackgroundTransparency = 1
			Slider.ValueText.Size = UDim2.new(0.2, 0, 0.4, 0)
			Slider.ValueText.Position = UDim2.new(0.75, 0, 0.1, 0)

			-- Slider Bar
			Slider.Bar = Instance.new("TextButton", Slider.Frame)
			Slider.Bar.Name = "Bar"
			Slider.Bar.Text = ""
			Slider.Bar.BackgroundColor3 = UI.Theme.Border
			Slider.Bar.Size = UDim2.new(0.9, 0, 0.2, 0)
			Slider.Bar.Position = UDim2.new(0.05, 0, 0.6, 0)
			Slider.Bar.AutoButtonColor = false

			-- Bar Corner
			Slider.BarCorner = Instance.new("UICorner", Slider.Bar)
			Slider.BarCorner.CornerRadius = UDim.new(1, 0)

			-- Fill Bar
			Slider.Fill = Instance.new("Frame", Slider.Bar)
			Slider.Fill.Name = "Fill"
			Slider.Fill.BackgroundColor3 = UI.Theme.Accent
			Slider.Fill.Size = UDim2.new(0, 0, 1, 0)
			Slider.Fill.BorderSizePixel = 0

			-- Fill Corner
			Slider.FillCorner = Instance.new("UICorner", Slider.Fill)
			Slider.FillCorner.CornerRadius = UDim.new(1, 0)

			local function updateValue(v)
				local percentage = math.clamp((v - Slider.Min) / (Slider.Max - Slider.Min), 0, 1)
				Slider.Value = math.floor((v * Slider.Decimals) + 0.5) / Slider.Decimals
				Slider.ValueText.Text = tostring(Slider.Value)
				PurpleBotUI:Tween(Slider.Fill, nil, {Size = UDim2.new(percentage, 0, 1, 0)})
				if options.Callback then
					options.Callback(Slider.Value)
				end
			end

			Slider.Bar.MouseButton1Down:Connect(function()
				local function update()
					local mouseX = mouse.X
					local barPos = Slider.Bar.AbsolutePosition.X
					local barWidth = Slider.Bar.AbsoluteSize.X
					local percentage = math.clamp((mouseX - barPos) / barWidth, 0, 1)
					local value = Slider.Min + (Slider.Max - Slider.Min) * percentage
					updateValue(value)
				end

				local conn
				conn = RunService.RenderStepped:Connect(function()
					if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
						conn:Disconnect()
					else
						update()
					end
				end)
			end)

			Slider.ValueText.FocusLost:Connect(function()
				local value = tonumber(Slider.ValueText.Text) or Slider.Value
				updateValue(math.clamp(value, Slider.Min, Slider.Max))
			end)

			updateValue(Slider.Value)

			function Slider:SetValue(v)
				updateValue(math.clamp(v, Slider.Min, Slider.Max))
			end

			function Slider:GetValue()
				return Slider.Value
			end

			return Slider
		end

		-- Dropdown Component
		function Tab:Dropdown(options)
			options = options or {}
			local Dropdown = {
				Selected = nil,
				IsOpen = false,
			}

			Dropdown.Frame = Instance.new("TextButton", Tab.ScrollingFrame)
			Dropdown.Frame.Name = options.Name or "Dropdown"
			Dropdown.Frame.Text = ""
			Dropdown.Frame.BackgroundColor3 = UI.Theme.Background
			Dropdown.Frame.Size = UDim2.new(0.95, 0, 0.08, 0)
			Dropdown.Frame.AutoButtonColor = false
			Dropdown.Frame.ClipsDescendants = true
			Dropdown.Frame.BorderSizePixel = 0

			-- Dropdown Corner
			Dropdown.Corner = Instance.new("UICorner", Dropdown.Frame)
			Dropdown.Corner.CornerRadius = UDim.new(0.1, 0)

			-- Dropdown Stroke
			Dropdown.Stroke = Instance.new("UIStroke", Dropdown.Frame)
			Dropdown.Stroke.Color = UI.Theme.Border
			Dropdown.Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			-- Dropdown Title
			Dropdown.Title = Instance.new("TextLabel", Dropdown.Frame)
			Dropdown.Title.Text = options.Text or "Dropdown"
			Dropdown.Title.TextColor3 = UI.Theme.Text
			Dropdown.Title.TextScaled = true
			Dropdown.Title.TextXAlignment = Enum.TextXAlignment.Left
			Dropdown.Title.FontFace = Font.new("rbxasset://fonts/families/Roboto.json")
			Dropdown.Title.BackgroundTransparency = 1
			Dropdown.Title.Size = UDim2.new(0.8, 0, 0.5, 0)
			Dropdown.Title.Position = UDim2.new(0.05, 0, 0.25, 0)

			-- Dropdown Icon
			Dropdown.Icon = Instance.new("ImageLabel", Dropdown.Frame)
			Dropdown.Icon.Image = "rbxassetid://7072719338"
			Dropdown.Icon.BackgroundTransparency = 1
			Dropdown.Icon.Size = UDim2.new(0.1, 0, 0.5, 0)
			Dropdown.Icon.Position = UDim2.new(0.85, 0, 0.25, 0)

			-- Options Frame
			Dropdown.Options = Instance.new("ScrollingFrame", Dropdown.Frame)
			Dropdown.Options.Name = "Options"
			Dropdown.Options.BackgroundTransparency = 1
			Dropdown.Options.Size = UDim2.new(0.95, 0, 0, 0)
			Dropdown.Options.Position = UDim2.new(0.05, 0, 0.8, 0)
			Dropdown.Options.CanvasSize = UDim2.new(0, 0, 0, 0)
			Dropdown.Options.AutomaticCanvasSize = Enum.AutomaticSize.Y
			Dropdown.Options.ScrollingDirection = Enum.ScrollingDirection.Y
			Dropdown.Options.ScrollBarThickness = 4
			Dropdown.Options.Visible = false

			-- Options Layout
			Dropdown.OptionsLayout = Instance.new("UIListLayout", Dropdown.Options)
			Dropdown.OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
			Dropdown.OptionsLayout.Padding = UDim.new(0.02, 0)

			local function toggleDropdown()
				Dropdown.IsOpen = not Dropdown.IsOpen
				local targetSize = Dropdown.IsOpen and UDim2.new(0.95, 0, 0.3, 0) or UDim2.new(0.95, 0, 0.08, 0)
				PurpleBotUI:Tween(Dropdown.Frame, nil, {Size = targetSize}, function()
					Dropdown.Options.Visible = Dropdown.IsOpen
				end)
				PurpleBotUI:Tween(Dropdown.Icon, nil, {Rotation = Dropdown.IsOpen and -180 or 0})
			end

			Dropdown.Frame.MouseButton1Click:Connect(toggleDropdown)

			function Dropdown:Option(option)
				local Option = {}

				Option.Button = Instance.new("TextButton", Dropdown.Options)
				Option.Button.Name = option.Name or "Option"
				Option.Button.Text = option.Name or "Option"
				Option.Button.TextColor3 = UI.Theme.Text
				Option.Button.TextScaled = true
				Option.Button.TextXAlignment = Enum.TextXAlignment.Left
				Option.Button.FontFace = Font.new("rbxasset://fonts/families/Roboto.json")
				Option.Button.BackgroundColor3 = UI.Theme.Secondary
				Option.Button.Size = UDim2.new(0.9, 0, 0.2, 0)
				Option.Button.AutoButtonColor = false

				-- Option Corner
				Option.Corner = Instance.new("UICorner", Option.Button)
				Option.Corner.CornerRadius = UDim.new(0.2, 0)

				Option.Button.MouseButton1Click:Connect(function()
					Dropdown.Selected = Option.Button
					Dropdown.Title.Text = Option.Button.Text
					toggleDropdown()
					if option.Callback then
						option.Callback(Option.Button.Text)
					end
				end)

				return Option
			end

			function Dropdown:GetSelected()
				return Dropdown.Selected and Dropdown.Selected.Text or nil
			end

			return Dropdown
		end

		table.insert(UI.Tabs, Tab)
		if not UI.CurrentTab then
			Tab:Activate()
		end

		return Tab
	end

	-- Theme Switching
	function UI:SetTheme(theme)
		UI.Theme = theme
		UI.MainFrame.BackgroundColor3 = theme.Background
		UI.TopBar.BackgroundColor3 = theme.Primary
		UI.Sidebar.BackgroundColor3 = theme.Secondary
		UI.MainStroke.Color = theme.Border
		UI.Title.TextColor3 = theme.Text
		UI.ExitButton.TextColor3 = theme.Text
		UI.NotifyFrame.BackgroundColor3 = theme.Background
		UI.NotifyText.TextColor3 = theme.Text
		UI.NotifyStroke.Color = theme.Accent
	end

	return UI
end

return PurpleBotUI
