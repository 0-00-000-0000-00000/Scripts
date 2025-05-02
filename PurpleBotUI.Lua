--Made by WARNINGBOT_DEAD

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

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

-- Tween utility function with easing options
function PurpleBotUI:Tween(object, tweenInfo, goal, callback)
	tweenInfo = tweenInfo or defaultTweenInfo
	local tween = TweenService:Create(object, tweenInfo, goal)
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
		Components = {},
		Theme = args.Theme or {
			Primary = Color3.fromRGB(150, 100, 200), -- Vibrant purple
			Secondary = Color3.fromRGB(100, 50, 150),
			Background = Color3.fromRGB(30, 30, 40),
			Accent = Color3.fromRGB(200, 150, 255),
			Text = Color3.fromRGB(255, 255, 255),
			Border = Color3.fromRGB(80, 80, 100),
			Success = Color3.fromRGB(100, 255, 100),
			Warning = Color3.fromRGB(255, 200, 0),
			Error = Color3.fromRGB(255, 80, 80),
		},
		IsMinimized = false,
		IsDragging = false,
		OnDestroyed = args.OnDestroyed,
		AnimationsEnabled = args.AnimationsEnabled ~= false,
	}

	-- ScreenGui
	UI.ScreenGui = Instance.new("ScreenGui")
	UI.ScreenGui.Name = "PurpleBotUI_" .. tostring(math.random(1000, 9999))
	UI.ScreenGui.ResetOnSpawn = false
	UI.ScreenGui.IgnoreGuiInset = true
	UI.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	UI.ScreenGui.Parent = RunService:IsStudio() and player:WaitForChild("PlayerGui") or game:GetService("CoreGui")

	-- Main Frame
	UI.MainFrame = Instance.new("Frame", UI.ScreenGui)
	UI.MainFrame.Name = "Main"
	UI.MainFrame.BackgroundColor3 = UI.Theme.Background
	UI.MainFrame.Size = args.Size or UDim2.new(0.5, 0, 0.6, 0)
	UI.MainFrame.Position = args.Position or UDim2.new(0.25, 0, 0.2, 0)
	UI.MainFrame.ClipsDescendants = true
	UI.MainFrame.BorderSizePixel = 0
	UI.MainFrame.ZIndex = 10

	-- UICorner for Main Frame
	UI.MainCorner = Instance.new("UICorner", UI.MainFrame)
	UI.MainCorner.CornerRadius = UDim.new(0.02, 0)

	-- UIStroke for neumorphic effect
	UI.MainStroke = Instance.new("UIStroke", UI.MainFrame)
	UI.MainStroke.Color = UI.Theme.Border
	UI.MainStroke.Thickness = 1.5
	UI.MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	-- Drop Shadow
	UI.ShadowHolder = Instance.new("Frame", UI.MainFrame)
	UI.ShadowHolder.Name = "ShadowHolder"
	UI.ShadowHolder.BackgroundTransparency = 1
	UI.ShadowHolder.Size = UDim2.new(1, 0, 1, 0)
	UI.ShadowHolder.ZIndex = 9

	UI.Shadow = Instance.new("ImageLabel", UI.ShadowHolder)
	UI.Shadow.Name = "DropShadow"
	UI.Shadow.Image = "rbxassetid://6014261993"
	UI.Shadow.ImageTransparency = 0.5
	UI.Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	UI.Shadow.ScaleType = Enum.ScaleType.Slice
	UI.Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
	UI.Shadow.Size = UDim2.new(1, 47, 1, 47)
	UI.Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	UI.Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	UI.Shadow.BackgroundTransparency = 1

	-- Top Bar
	UI.TopBar = Instance.new("Frame", UI.MainFrame)
	UI.TopBar.Name = "TopBar"
	UI.TopBar.BackgroundColor3 = UI.Theme.Primary
	UI.TopBar.Size = UDim2.new(1, 0, 0.1, 0)
	UI.TopBar.ZIndex = 12
	UI.TopBar.BorderSizePixel = 0

	-- Top Bar Corner
	UI.TopBarCorner = Instance.new("UICorner", UI.TopBar)
	UI.TopBarCorner.CornerRadius = UDim.new(0.15, 0)

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
	UI.Title.ZIndex = 13

	-- Title Padding
	UI.TitlePadding = Instance.new("UIPadding", UI.Title)
	UI.TitlePadding.PaddingLeft = UDim.new(0.05, 0)

	-- Icon (Optional)
	if args.Icon then
		UI.Icon = Instance.new("ImageLabel", UI.TopBar)
		UI.Icon.Name = "Icon"
		UI.Icon.Image = args.Icon
		UI.Icon.BackgroundTransparency = 1
		UI.Icon.Size = UDim2.new(0.08, 0, 0.8, 0)
		UI.Icon.Position = UDim2.new(0.01, 0, 0.1, 0)
		UI.Icon.ZIndex = 13
	end

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
	UI.ExitButton.ZIndex = 14
	UI.ExitButton.MouseButton1Click:Connect(function()
		if UI.OnDestroyed then
			UI.OnDestroyed()
		end
		UI.ScreenGui:Destroy()
	end)

	-- Minimize Button
	UI.MinimizeButton = Instance.new("ImageButton", UI.TopBar)
	UI.MinimizeButton.Name = "Minimize"
	UI.MinimizeButton.Image = "rbxassetid://7072719338" -- Minimize icon
	UI.MinimizeButton.BackgroundTransparency = 1
	UI.MinimizeButton.Size = UDim2.new(0.06, 0, 0.6, 0)
	UI.MinimizeButton.Position = UDim2.new(0.85, 0, 0.2, 0)
	UI.MinimizeButton.ZIndex = 14

	-- Sidebar
	UI.Sidebar = Instance.new("Frame", UI.MainFrame)
	UI.Sidebar.Name = "Sidebar"
	UI.Sidebar.BackgroundColor3 = UI.Theme.Secondary
	UI.Sidebar.Size = UDim2.new(0.25, 0, 0.85, 0)
	UI.Sidebar.Position = UDim2.new(0, 0, 0.15, 0)
	UI.Sidebar.BorderSizePixel = 0
	UI.Sidebar.ZIndex = 11

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
	UI.SidebarList.Padding = UDim.new(0.03, 0)

	-- Sidebar Padding
	UI.SidebarPadding = Instance.new("UIPadding", UI.SidebarHolder)
	UI.SidebarPadding.PaddingTop = UDim.new(0.05, 0)
	UI.SidebarPadding.PaddingLeft = UDim.new(0.05, 0)

	-- Tab Holder
	UI.TabHolder = Instance.new("Frame", UI.MainFrame)
	UI.TabHolder.Name = "TabHolder"
	UI.TabHolder.BackgroundTransparency = 1
	UI.TabHolder.Size = UDim2.new(0.73, 0, 0.85, 0)
	UI.TabHolder.Position = UDim2.new(0.27, 0, 0.15, 0)
	UI.TabHolder.ZIndex = 11

	-- Notification Frame
	UI.NotifyFrame = Instance.new("Frame", UI.MainFrame)
	UI.NotifyFrame.Name = "NotifyFrame"
	UI.NotifyFrame.BackgroundColor3 = UI.Theme.Background
	UI.NotifyFrame.Size = UDim2.new(0.4, 0, 0.15, 0)
	UI.NotifyFrame.Position = UDim2.new(0.3, 0, 1.2, 0)
	UI.NotifyFrame.ZIndex = 15
	UI.NotifyFrame.BorderSizePixel = 0
	UI.NotifyFrame.ClipsDescendants = true

	-- Notification Stroke
	UI.NotifyStroke = Instance.new("UIStroke", UI.NotifyFrame)
	UI.NotifyStroke.Color = UI.Theme.Accent
	UI.NotifyStroke.Thickness = 2
	UI.NotifyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	-- Notification Text
	UI.NotifyText = Instance.new("TextLabel", UI.NotifyFrame)
	UI.NotifyText.Text = "Notification"
	UI.NotifyText.TextColor3 = UI.Theme.Text
	UI.NotifyText.TextScaled = true
	UI.NotifyText.TextTruncate = Enum.TextTruncate.AtEnd
	UI.NotifyText.FontFace = Font.new("rbxasset://fonts/families/Roboto.json")
	UI.NotifyText.BackgroundTransparency = 1
	UI.NotifyText.Size = UDim2.new(0.85, 0, 0.6, 0)
	UI.NotifyText.Position = UDim2.new(0.05, 0, 0.2, 0)
	UI.NotifyText.ZIndex = 16

	-- Notification Close Button
	UI.NotifyClose = Instance.new("TextButton", UI.NotifyFrame)
	UI.NotifyClose.Text = "×"
	UI.NotifyClose.TextColor3 = UI.Theme.Text
	UI.NotifyClose.TextScaled = true
	UI.NotifyClose.FontFace = Font.new("rbxasset://fonts/families/Roboto.json")
	UI.NotifyClose.BackgroundTransparency = 1
	UI.NotifyClose.Size = UDim2.new(0.1, 0, 0.3, 0)
	UI.NotifyClose.Position = UDim2.new(0.9, 0, 0.05, 0)
	UI.NotifyClose.ZIndex = 16

	-- Notification Animation
	local notifyEnterPos = UDim2.new(0.3, 0, 0.85, 0)
	local notifyExitPos = UI.NotifyFrame.Position
	local notifyTweenIn = TweenService:Create(UI.NotifyFrame, defaultTweenInfo, {Position = notifyEnterPos})
	local notifyTweenOut = TweenService:Create(UI.NotifyFrame, defaultTweenInfo, {Position = notifyExitPos})

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
				math.clamp(newPos.X.Offset, -frame.AbsoluteSize.X + 50, screenSize.X - 50),
				math.clamp(newPos.Y.Scale, 0, 1 - frame.Size.Y.Scale),
				math.clamp(newPos.Y.Offset, -50, screenSize.Y - 50)
			)
			if UI.AnimationsEnabled then
				PurpleBotUI:Tween(frame, TweenInfo.new(0.1), {Position = newPos})
			else
				frame.Position = newPos
			end
		end

		UI.TopBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				UI.IsDragging = true
				dragStart = input.Position
				startPos = frame.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
						UI.IsDragging = false
					end
				end)
			end
		end)

		UI.TopBar.InputChanged:Connect(function(input)
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
	local minimizedSize = args.MinimizedSize or UDim2.new(0.25, 0, 0.12, 0)

	UI.MinimizeButton.MouseButton1Click:Connect(function()
		UI.IsMinimized = not UI.IsMinimized
		if UI.IsMinimized then
			if UI.AnimationsEnabled then
				PurpleBotUI:Tween(UI.MainFrame, nil, {Size = minimizedSize})
				PurpleBotUI:Tween(UI.TopBar, nil, {BackgroundColor3 = UI.Theme.Secondary})
			else
				UI.MainFrame.Size = minimizedSize
				UI.TopBar.BackgroundColor3 = UI.Theme.Secondary
			end
			UI.Sidebar.Visible = false
			UI.TabHolder.Visible = false
			UI.MainStroke.Thickness = 2
		else
			if UI.AnimationsEnabled then
				PurpleBotUI:Tween(UI.MainFrame, nil, {Size = originalSize})
				PurpleBotUI:Tween(UI.TopBar, nil, {BackgroundColor3 = UI.Theme.Primary})
			else
				UI.MainFrame.Size = originalSize
				UI.TopBar.BackgroundColor3 = UI.Theme.Primary
			end
			UI.Sidebar.Visible = true
			UI.TabHolder.Visible = true
			UI.MainStroke.Thickness = 1.5
		end
	end)

	-- Notification System
	function UI:Notify(options)
		options = options or {}
		local text = options.Text or "Notification"
		local duration = options.Duration or 3
		local type = options.Type or "Info" -- "Info", "Success", "Warning", "Error"

		UI.NotifyText.Text = tostring(text)
		UI.NotifyFrame.BackgroundColor3 = ({
			Info = UI.Theme.Background,
			Success = UI.Theme.Success,
			Warning = UI.Theme.Warning,
			Error = UI.Theme.Error,
		})[type] or UI.Theme.Background
		UI.NotifyStroke.Color = ({
			Info = UI.Theme.Accent,
			Success = UI.Theme.Success,
			Warning = UI.Theme.Warning,
			Error = UI.Theme.Error,
		})[type] or UI.Theme.Accent

		if notifyTweenIn.PlaybackState == Enum.PlaybackState.Playing then
			notifyTweenIn:Cancel()
			UI.NotifyFrame.Position = notifyExitPos
		end
		notifyTweenIn:Play()
		local dismissTask
		dismissTask = task.delay(duration, function()
			if dismissTask then
				notifyTweenOut:Play()
			end
		end)

		local connection
		connection = UI.NotifyClose.MouseButton1Click:Connect(function()
			notifyTweenOut:Play()
			if dismissTask then
				task.cancel(dismissTask)
				dismissTask = nil
			end
			connection:Disconnect()
		end)
	end

	-- Tab Creation
	function UI:CreateTab(options)
		options = options or {}
		local Tab = {
			Name = options.Name or "Tab",
			IsActive = false,
			Hover = false,
			Components = {},
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
		Tab.Button.ZIndex = 12
		Tab.Button.BorderSizePixel = 0

		-- Tab Button Corner
		Tab.ButtonCorner = Instance.new("UICorner", Tab.Button)
		Tab.ButtonCorner.CornerRadius = UDim.new(0.2, 0)

		-- Tab Button Padding
		Tab.ButtonPadding = Instance.new("UIPadding", Tab.Button)
		Tab.ButtonPadding.PaddingLeft = UDim.new(0.1, 0)

		-- Tab Button Stroke
		Tab.ButtonStroke = Instance.new("UIStroke", Tab.Button)
		Tab.ButtonStroke.Color = UI.Theme.Border
		Tab.ButtonStroke.Thickness = 1
		Tab.ButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

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
		Tab.ScrollingFrame.ZIndex = 11

		-- Scrolling Frame Layout
		Tab.ListLayout = Instance.new("UIListLayout", Tab.ScrollingFrame)
		Tab.ListLayout.SortOrder = options.Alphabetical and Enum.SortOrder.Name or Enum.SortOrder.LayoutOrder
		Tab.ListLayout.Padding = UDim.new(0.02, 0)

		-- Scrolling Frame Padding
		Tab.Padding = Instance.new("UIPadding", Tab.ScrollingFrame)
		Tab.Padding.PaddingTop = UDim.new(0.02, 0)
		Tab.Padding.PaddingLeft = UDim2.new(0.02, 0)
		Tab.Padding.PaddingRight = UDim2.new(0.02, 0)

		-- Hover Effects
		Tab.Button.MouseEnter:Connect(function()
			Tab.Hover = true
			if not Tab.IsActive then
				if UI.AnimationsEnabled then
					PurpleBotUI:Tween(Tab.Button, nil, {BackgroundTransparency = 0.5, TextColor3 = UI.Theme.Accent})
					PurpleBotUI:Tween(Tab.ButtonStroke, nil, {Color = UI.Theme.Accent})
				else
					Tab.Button.BackgroundTransparency = 0.5
					Tab.Button.TextColor3 = UI.Theme.Accent
					Tab.ButtonStroke.Color = UI.Theme.Accent
				end
			end
		end)

		Tab.Button.MouseLeave:Connect(function()
			Tab.Hover = false
			if not Tab.IsActive then
				if UI.AnimationsEnabled then
					PurpleBotUI:Tween(Tab.Button, nil, {BackgroundTransparency = 0.8, TextColor3 = UI.Theme.Text})
					PurpleBotUI:Tween(Tab.ButtonStroke, nil, {Color = UI.Theme.Border})
				else
					Tab.Button.BackgroundTransparency = 0.8
					Tab.Button.TextColor3 = UI.Theme.Text
					Tab.ButtonStroke.Color = UI.Theme.Border
				end
			end
		end)

		-- Tab Activation
		function Tab:Activate()
			if not Tab.IsActive then
				Tab.IsActive = true
				UI.CurrentTab = Tab
				if UI.AnimationsEnabled then
					PurpleBotUI:Tween(Tab.Button, nil, {BackgroundTransparency = 0, BackgroundColor3 = UI.Theme.Primary})
					PurpleBotUI:Tween(Tab.ButtonStroke, nil, {Color = UI.Theme.Primary})
				else
					Tab.Button.BackgroundTransparency = 0
					Tab.Button.BackgroundColor3 = UI.Theme.Primary
					Tab.ButtonStroke.Color = UI.Theme.Primary
				end
				Tab.ScrollingFrame.Visible = true
			end
		end

		function Tab:Deactivate()
			if Tab.IsActive then
				Tab.IsActive = false
				if UI.AnimationsEnabled then
					PurpleBotUI:Tween(Tab.Button, nil, {BackgroundTransparency = 0.8, BackgroundColor3 = UI.Theme.Secondary})
					PurpleBotUI:Tween(Tab.ButtonStroke, nil, {Color = UI.Theme.Border})
				else
					Tab.Button.BackgroundTransparency = 0.8
					Tab.Button.BackgroundColor3 = UI.Theme.Secondary
					Tab.ButtonStroke.Color = UI.Theme.Border
				end
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

		-- Component: Button
		function Tab:Button(options)
			options = options or {}
			local Button = {
				Callback = options.Callback,
				IsToggled = options.Default or false,
			}

			Button.Frame = Instance.new("TextButton", Tab.ScrollingFrame)
			Button.Frame.Name = options.Name or "Button"
			Button.Frame.Text = ""
			Button.Frame.BackgroundColor3 = options.Color or UI.Theme.Background
			Button.Frame.Size = options.Size or UDim2.new(0.95, 0, 0.06, 0)
			Button.Frame.AutoButtonColor = false
			Button.Frame.BorderSizePixel = 0
			Button.Frame.ZIndex = 12

			-- Button Corner
			Button.Corner = Instance.new("UICorner", Button.Frame)
			Button.Corner.CornerRadius = UDim.new(0.1, 0)

			-- Button Stroke
			Button.Stroke = Instance.new("UIStroke", Button.Frame)
			Button.Stroke.Color = Button.IsToggled and UI.Theme.Accent or UI.Theme.Border
			Button.Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			Button.Stroke.Thickness = 1.5

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
			Button.Text.ZIndex = 13

			-- Button Icon
			if options.Icon then
				Button.Icon = Instance.new("ImageLabel", Button.Frame)
				Button.Icon.Name = "Icon"
				Button.Icon.Image = options.Icon
				Button.Icon.BackgroundTransparency = 1
				Button.Icon.Size = UDim2.new(0.1, 0, 0.7, 0)
				Button.Icon.Position = UDim2.new(0.85, 0, 0.15, 0)
				Button.Icon.ZIndex = 13
			end

			-- Button Interactions
			Button.Frame.MouseButton1Click:Connect(function()
				if options.Toggleable then
					Button.IsToggled = not Button.IsToggled
					if UI.AnimationsEnabled then
						PurpleBotUI:Tween(Button.Stroke, nil, {Color = Button.IsToggled and UI.Theme.Accent or UI.Theme.Border})
					else
						Button.Stroke.Color = Button.IsToggled and UI.Theme.Accent or UI.Theme.Border
					end
				end
				if Button.Callback then
					Button.Callback(Button.IsToggled)
				end
			end)

			-- Hover Effect
			Button.Frame.MouseEnter:Connect(function()
				if UI.AnimationsEnabled then
					PurpleBotUI:Tween(Button.Frame, nil, {BackgroundColor3 = UI.Theme.Secondary})
				else
					Button.Frame.BackgroundColor3 = UI.Theme.Secondary
				end
			end)

			Button.Frame.MouseLeave:Connect(function()
				if UI.AnimationsEnabled then
					PurpleBotUI:Tween(Button.Frame, nil, {BackgroundColor3 = options.Color or UI.Theme.Background})
				else
					Button.Frame.BackgroundColor3 = options.Color or UI.Theme.Background
				end
			end)

			function Button:SetText(text)
				Button.Text.Text = text
			end

			function Button:Toggle(state)
				if state ~= nil then
					Button.IsToggled = state
				else
					Button.IsToggled = not Button.IsToggled
				end
				if UI.AnimationsEnabled then
					PurpleBotUI:Tween(Button.Stroke, nil, {Color = Button.IsToggled and UI.Theme.Accent or UI.Theme.Border})
				else
					Button.Stroke.Color = Button.IsToggled and UI.Theme.Accent or UI.Theme.Border
				end
				if Button.Callback then
					Button.Callback(Button.IsToggled)
				end
			end

			function Button:IsToggled()
				return Button.IsToggled
			end

			table.insert(Tab.Components, Button)
			return Button
		end

		-- Component: Slider
		function Tab:Slider(options)
			options = options or {}
			local Slider = {
				Value = options.Default or options.Min or 0,
				Min = options.Min or 0,
				Max = options.Max or 100,
				Decimals = options.Decimals or 1,
				Callback = options.Callback,
			}

			Slider.Frame = Instance.new("Frame", Tab.ScrollingFrame)
			Slider.Frame.Name = options.Name or "Slider"
			Slider.Frame.BackgroundColor3 = UI.Theme.Background
			Slider.Frame.Size = UDim2.new(0.95, 0, 0.12, 0)
			Slider.Frame.BorderSizePixel = 0
			Slider.Frame.ZIndex = 12

			-- Slider Corner
			Slider.Corner = Instance.new("UICorner", Slider.Frame)
			Slider.Corner.CornerRadius = UDim.new(0.1, 0)

			-- Slider Stroke
			Slider.Stroke = Instance.new("UIStroke", Slider.Frame)
			Slider.Stroke.Color = UI.Theme.Border
			Slider.Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			Slider.Stroke.Thickness = 1.5

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
			Slider.Title.ZIndex = 13

			-- Slider Value
			Slider.ValueText = Instance.new("TextBox", Slider.Frame)
			Slider.ValueText.Text = tostring(Slider.Value)
			Slider.ValueText.TextColor3 = UI.Theme.Text
			Slider.ValueText.TextScaled = true
			Slider.ValueText.FontFace = Font.new("rbxasset://fonts/families/Roboto.json")
			Slider.ValueText.BackgroundColor3 = UI.Theme.Secondary
			Slider.ValueText.Size = UDim2.new(0.2, 0, 0.4, 0)
			Slider.ValueText.Position = UDim2.new(0.75, 0, 0.1, 0)
			Slider.ValueText.ZIndex = 13
			Slider.ValueText.BorderSizePixel = 0

			-- Value Text Corner
			Slider.ValueCorner = Instance.new("UICorner", Slider.ValueText)
			Slider.ValueCorner.CornerRadius = UDim.new(0.2, 0)

			-- Slider Bar
			Slider.Bar = Instance.new("TextButton", Slider.Frame)
			Slider.Bar.Name = "Bar"
			Slider.Bar.Text = ""
			Slider.Bar.BackgroundColor3 = UI.Theme.Border
			Slider.Bar.Size = UDim2.new(0.9, 0, 0.25, 0)
			Slider.Bar.Position = UDim2.new(0.05, 0, 0.65, 0)
			Slider.Bar.AutoButtonColor = false
			Slider.Bar.ZIndex = 13
			Slider.Bar.BorderSizePixel = 0

			-- Bar Corner
			Slider.BarCorner = Instance.new("UICorner", Slider.Bar)
			Slider.BarCorner.CornerRadius = UDim.new(1, 0)

			-- Fill Bar
			Slider.Fill = Instance.new("Frame", Slider.Bar)
			Slider.Fill.Name = "Fill"
			Slider.Fill.BackgroundColor3 = UI.Theme.Accent
			Slider.Fill.Size = UDim2.new(0, 0, 1, 0)
			Slider.Fill.BorderSizePixel = 0
			Slider.Fill.ZIndex = 14

			-- Fill Corner
			Slider.FillCorner = Instance.new("UICorner", Slider.Fill)
			Slider.FillCorner.CornerRadius = UDim.new(1, 0)

			local function updateValue(v)
				local percentage = math.clamp((v - Slider.Min) / (Slider.Max - Slider.Min), 0, 1)
				Slider.Value = math.floor((v * (10 ^ Slider.Decimals)) + 0.5) / (10 ^ Slider.Decimals)
				Slider.Value = math.clamp(Slider.Value, Slider.Min, Slider.Max)
				Slider.ValueText.Text = tostring(Slider.Value)
				if UI.AnimationsEnabled then
					PurpleBotUI:Tween(Slider.Fill, nil, {Size = UDim2.new(percentage, 0, 1, 0)})
				else
					Slider.Fill.Size = UDim2.new(percentage, 0, 1, 0)
				end
				if Slider.Callback then
					Slider.Callback(Slider.Value)
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

			function Slider:SetCallback(callback)
				Slider.Callback = callback
			end

			table.insert(Tab.Components, Slider)
			return Slider
		end

		-- Component: Dropdown
		function Tab:Dropdown(options)
			options = options or {}
			local Dropdown = {
				Selected = nil,
				IsOpen = false,
				Options = {},
				Callback = options.Callback,
			}

			Dropdown.Frame = Instance.new("TextButton", Tab.ScrollingFrame)
			Dropdown.Frame.Name = options.Name or "Dropdown"
			Dropdown.Frame.Text = ""
			Dropdown.Frame.BackgroundColor3 = UI.Theme.Background
			Dropdown.Frame.Size = UDim2.new(0.95, 0, 0.08, 0)
			Dropdown.Frame.AutoButtonColor = false
			Dropdown.Frame.ClipsDescendants = true
			Dropdown.Frame.BorderSizePixel = 0
			Dropdown.Frame.ZIndex = 12

			-- Dropdown Corner
			Dropdown.Corner = Instance.new("UICorner", Dropdown.Frame)
			Dropdown.Corner.CornerRadius = UDim.new(0.1, 0)

			-- Dropdown Stroke
			Dropdown.Stroke = Instance.new("UIStroke", Dropdown.Frame)
			Dropdown.Stroke.Color = UI.Theme.Border
			Dropdown.Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			Dropdown.Stroke.Thickness = 1.5

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
			Dropdown.Title.ZIndex = 13

			-- Dropdown Icon
			Dropdown.Icon = Instance.new("ImageLabel", Dropdown.Frame)
			Dropdown.Icon.Image = "rbxassetid://7072719338" -- Chevron down
			Dropdown.Icon.BackgroundTransparency = 1
			Dropdown.Icon.Size = UDim2.new(0.1, 0, 0.5, 0)
			Dropdown.Icon.Position = UDim2.new(0.85, 0, 0.25, 0)
			Dropdown.Icon.ZIndex = 13

			-- Options Frame
			Dropdown.OptionsFrame = Instance.new("ScrollingFrame", Dropdown.Frame)
			Dropdown.OptionsFrame.Name = "Options"
			Dropdown.OptionsFrame.BackgroundTransparency = 1
			Dropdown.OptionsFrame.Size = UDim2.new(0.95, 0, 0, 0)
			Dropdown.OptionsFrame.Position = UDim2.new(0.05, 0, 0.8, 0)
			Dropdown.OptionsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
			Dropdown.OptionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			Dropdown.OptionsFrame.ScrollingDirection = Enum.ScrollingDirection.Y
			Dropdown.OptionsFrame.ScrollBarThickness = 4
			Dropdown.OptionsFrame.ScrollBarImageColor3 = UI.Theme.Accent
			Dropdown.OptionsFrame.Visible = false
			Dropdown.OptionsFrame.ZIndex = 14

			-- Options Layout
			Dropdown.OptionsLayout = Instance.new("UIListLayout", Dropdown.OptionsFrame)
			Dropdown.OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
			Dropdown.OptionsLayout.Padding = UDim.new(0.02, 0)

			-- Options Padding
			Dropdown.OptionsPadding = Instance.new("UIPadding", Dropdown.OptionsFrame)
			Dropdown.OptionsPadding.PaddingTop = UDim.new(0.05, 0)

			local closedSize = Dropdown.Frame.Size
			local openSize = UDim2.new(0.95, 0, 0.3, 0)

			local function toggleDropdown()
				Dropdown.IsOpen = not Dropdown.IsOpen
				local targetSize = Dropdown.IsOpen and openSize or closedSize
				if UI.AnimationsEnabled then
					PurpleBotUI:Tween(Dropdown.Frame, nil, {Size = targetSize}, function()
						Dropdown.OptionsFrame.Visible = Dropdown.IsOpen
					end)
					PurpleBotUI:Tween(Dropdown.Icon, nil, {Rotation = Dropdown.IsOpen and -180 or 0})
				else
					Dropdown.Frame.Size = targetSize
					Dropdown.OptionsFrame.Visible = Dropdown.IsOpen
					Dropdown.Icon.Rotation = Dropdown.IsOpen and -180 or 0
				end
			end

			Dropdown.Frame.MouseButton1Click:Connect(toggleDropdown)

			function Dropdown:AddOption(option)
				local opt = {}
				opt.Name = option.Name or "Option"
				opt.Callback = option.Callback

				opt.Button = Instance.new("TextButton", Dropdown.OptionsFrame)
				opt.Button.Name = opt.Name
				opt.Button.Text = opt.Name
				opt.Button.TextColor3 = UI.Theme.Text
				opt.Button.TextScaled = true
				opt.Button.TextXAlignment = Enum.TextXAlignment.Left
				opt.Button.FontFace = Font.new("rbxasset://fonts/families/Roboto.json")
				opt.Button.BackgroundColor3 = UI.Theme.Secondary
				opt.Button.Size = UDim2.new(0.9, 0, 0.2, 0)
				opt.Button.AutoButtonColor = false
				opt.Button.ZIndex = 15
				opt.Button.BorderSizePixel = 0

				-- Option Corner
				opt.Corner = Instance.new("UICorner", opt.Button)
				opt.Corner.CornerRadius = UDim.new(0.2, 0)

				-- Option Stroke
				opt.Stroke = Instance.new("UIStroke", opt.Button)
				opt.Stroke.Color = UI.Theme.Border
				opt.Stroke.Thickness = 1
				opt.Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

				opt.Button.MouseButton1Click:Connect(function()
					Dropdown.Selected = opt.Name
					Dropdown.Title.Text = opt.Name
					toggleDropdown()
					if opt.Callback then
						opt.Callback(opt.Name)
					end
					if Dropdown.Callback then
						Dropdown.Callback(opt.Name)
					end
				end)

				-- Hover Effect
				opt.Button.MouseEnter:Connect(function()
					if UI.AnimationsEnabled then
						PurpleBotUI:Tween(opt.Button, nil, {BackgroundColor3 = UI.Theme.Primary})
					else
						opt.Button.BackgroundColor3 = UI.Theme.Primary
					end
				end)

				opt.Button.MouseLeave:Connect(function()
					if UI.AnimationsEnabled then
						PurpleBotUI:Tween(opt.Button, nil, {BackgroundColor3 = UI.Theme.Secondary})
					else
						opt.Button.BackgroundColor3 = UI.Theme.Secondary
					end
				end)

				if option.Default then
					Dropdown.Selected = opt.Name
					Dropdown.Title.Text = opt.Name
					opt.Stroke.Color = UI.Theme.Accent
				end

				table.insert(Dropdown.Options, opt)
				return opt
			end

			-- Initialize options
			if options.Options then
				for _, opt in ipairs(options.Options) do
					Dropdown:AddOption(opt)
				end
			end

			function Dropdown:GetSelected()
				return Dropdown.Selected
			end

			function Dropdown:SetCallback(callback)
				Dropdown.Callback = callback
			end

			table.insert(Tab.Components, Dropdown)
			return Dropdown
		end

		-- Component: Toggle
		function Tab:Toggle(options)
			options = options or {}
			local Toggle = {
				IsToggled = options.Default or false,
				Callback = options.Callback,
				IsLocked = options.Locked or false,
			}

			Toggle.Frame = Instance.new("TextButton", Tab.ScrollingFrame)
			Toggle.Frame.Name = options.Name or "Toggle"
			Toggle.Frame.Text = ""
			Toggle.Frame.BackgroundColor3 = UI.Theme.Background
			Toggle.Frame.Size = UDim2.new(0.95, 0, 0.06, 0)
			Toggle.Frame.AutoButtonColor = false
			Toggle.Frame.BorderSizePixel = 0
			Toggle.Frame.ZIndex = 12

			-- Toggle Corner
			Toggle.Corner = Instance.new("UICorner", Toggle.Frame)
			Toggle.Corner.CornerRadius = UDim.new(0.1, 0)

			-- Toggle Stroke
			Toggle.Stroke = Instance.new("UIStroke", Toggle.Frame)
			Toggle.Stroke.Color = UI.Theme.Border
			Toggle.Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			Toggle.Stroke.Thickness = 1.5

			-- Toggle Text
			Toggle.Text = Instance.new("TextLabel", Toggle.Frame)
			Toggle.Text.Text = options.Text or "Toggle"
			Toggle.Text.TextColor3 = UI.Theme.Text
			Toggle.Text.TextScaled = true
			Toggle.Text.TextXAlignment = Enum.TextXAlignment.Left
			Toggle.Text.FontFace = Font.new("rbxasset://fonts/families/Roboto.json")
			Toggle.Text.BackgroundTransparency = 1
			Toggle.Text.Size = UDim2.new(0.8, 0, 0.7, 0)
			Toggle.Text.Position = UDim2.new(0.05, 0, 0.15, 0)
			Toggle.Text.ZIndex = 13

			-- Toggle Indicator
			Toggle.Indicator = Instance.new("Frame", Toggle.Frame)
			Toggle.Indicator.Name = "Indicator"
			Toggle.Indicator.BackgroundColor3 = Toggle.IsToggled and UI.Theme.Accent or UI.Theme.Border
			Toggle.Indicator.Size = UDim2.new(0.06, 0, 0.6, 0)
			Toggle.Indicator.Position = UDim2.new(0.88, 0, 0.2, 0)
			Toggle.Indicator.ZIndex = 13
			Toggle.Indicator.BorderSizePixel = 0

			-- Indicator Corner
			Toggle.IndicatorCorner = Instance.new("UICorner", Toggle.Indicator)
			Toggle.IndicatorCorner.CornerRadius = UDim.new(0.5, 0)

			-- Indicator Stroke
			Toggle.IndicatorStroke = Instance.new("UIStroke", Toggle.Indicator)
			Toggle.IndicatorStroke.Color = UI.Theme.Text
			Toggle.IndicatorStroke.Thickness = 1

			Toggle.Frame.MouseButton1Click:Connect(function()
				if not Toggle.IsLocked then
					Toggle.IsToggled = not Toggle.IsToggled
					if UI.AnimationsEnabled then
						PurpleBotUI:Tween(Toggle.Indicator, nil, {BackgroundColor3 = Toggle.IsToggled and UI.Theme.Accent or UI.Theme.Border})
					else
						Toggle.Indicator.BackgroundColor3 = Toggle.IsToggled and UI.Theme.Accent or UI.Theme.Border
					end
					if Toggle.Callback then
						Toggle.Callback(Toggle.IsToggled)
					end
				end
			end)

			function Toggle:SetText(text)
				Toggle.Text.Text = text
			end

			function Toggle:Toggle(state)
				if state ~= nil then
					Toggle.IsToggled = state
				else
					Toggle.IsToggled = not Toggle.IsToggled
				end
				if UI.AnimationsEnabled then
					PurpleBotUI:Tween(Toggle.Indicator, nil, {BackgroundColor3 = Toggle.IsToggled and UI.Theme.Accent or UI.Theme.Border})
				else
					Toggle.Indicator.BackgroundColor3 = Toggle.IsToggled and UI.Theme.Accent or UI.Theme.Border
				end
				if Toggle.Callback then
					Toggle.Callback(Toggle.IsToggled)
				end
			end

			function Toggle:IsToggled()
				return Toggle.IsToggled
			end

			function Toggle:Lock()
				Toggle.IsLocked = true
				Toggle.Frame.BackgroundTransparency = 0.5
			end

			function Toggle:Unlock()
				Toggle.IsLocked = false
				Toggle.Frame.BackgroundTransparency = 0
			end

			table.insert(Tab.Components, Toggle)
			return Toggle
		end

		-- Component: TextBox
		function Tab:TextBox(options)
			options = options or {}
			local TextBox = {
				Callback = options.Callback,
				Text = options.Default or "",
			}

			TextBox.Frame = Instance.new("Frame", Tab.ScrollingFrame)
			TextBox.Frame.Name = options.Name or "TextBox"
			TextBox.Frame.BackgroundColor3 = UI.Theme.Background
			TextBox.Frame.Size = UDim2.new(0.95, 0, 0.08, 0)
			TextBox.Frame.BorderSizePixel = 0
			TextBox.Frame.ZIndex = 12

			-- TextBox Corner
			TextBox.Corner = Instance.new("UICorner", TextBox.Frame)
			TextBox.Corner.CornerRadius = UDim.new(0.1, 0)

			-- TextBox Stroke
			TextBox.Stroke = Instance.new("UIStroke", TextBox.Frame)
			TextBox.Stroke.Color = UI.Theme.Border
			TextBox.Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			TextBox.Stroke.Thickness = 1.5

			-- TextBox Label
			TextBox.Label = Instance.new("TextLabel", TextBox.Frame)
			TextBox.Label.Text = options.Text or "TextBox"
			TextBox.Label.TextColor3 = UI.Theme.Text
			TextBox.Label.TextScaled = true
			TextBox.Label.TextXAlignment = Enum.TextXAlignment.Left
			TextBox.Label.FontFace = Font.new("rbxasset://fonts/families/Roboto.json")
			TextBox.Label.BackgroundTransparency = 1
			TextBox.Label.Size = UDim2.new(0.4, 0, 0.5, 0)
			TextBox.Label.Position = UDim2.new(0.05, 0, 0.25, 0)
			TextBox.Label.ZIndex = 13

			-- TextBox Input
			TextBox.Input = Instance.new("TextBox", TextBox.Frame)
			TextBox.Input.Text = TextBox.Text
			TextBox.Input.TextColor3 = UI.Theme.Text
			TextBox.Input.TextScaled = true
			TextBox.Input.TextXAlignment = Enum.TextXAlignment.Left
			TextBox.Input.FontFace = Font.new("rbxasset://fonts/families/Roboto.json")
			TextBox.Input.BackgroundColor3 = UI.Theme.Secondary
			TextBox.Input.Size = UDim2.new(0.5, 0, 0.6, 0)
			TextBox.Input.Position = UDim2.new(0.45, 0, 0.2, 0)
			TextBox.Input.ZIndex = 13
			TextBox.Input.BorderSizePixel = 0
			TextBox.Input.PlaceholderText = options.Placeholder or "Enter text..."
			TextBox.Input.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)

			-- Input Corner
			TextBox.InputCorner = Instance.new("UICorner", TextBox.Input)
			TextBox.InputCorner.CornerRadius = UDim.new(0.2, 0)

			-- Input Padding
			TextBox.InputPadding = Instance.new("UIPadding", TextBox.Input)
			TextBox.InputPadding.PaddingLeft = UDim.new(0.05, 0)

			TextBox.Input.FocusLost:Connect(function(enterPressed)
				TextBox.Text = TextBox.Input.Text
				if TextBox.Callback then
					TextBox.Callback(TextBox.Text, enterPressed)
				end
			end)

			function TextBox:SetText(text)
				TextBox.Text = text
				TextBox.Input.Text = text
			end

			function TextBox:GetText()
				return TextBox.Text
			end

			function TextBox:SetCallback(callback)
				TextBox.Callback = callback
			end

			table.insert(Tab.Components, TextBox)
			return TextBox
		end

		-- Component: Label
		function Tab:Label(options)
			options = options or {}
			local Label = {}

			Label.Frame = Instance.new("Frame", Tab.ScrollingFrame)
			Label.Frame.Name = options.Name or "Label"
			Label.Frame.BackgroundColor3 = options.Color or UI.Theme.Background
			Label.Frame.Size = UDim2.new(0.95, 0, 0, 0)
			Label.Frame.AutomaticSize = Enum.AutomaticSize.Y
			Label.Frame.BorderSizePixel = 0
			Label.Frame.ZIndex = 12

			-- Label Corner
			Label.Corner = Instance.new("UICorner", Label.Frame)
			Label.Corner.CornerRadius = UDim.new(0.1, 0)

			-- Label Stroke
			Label.Stroke = Instance.new("UIStroke", Label.Frame)
			Label.Stroke.Color = UI.Theme.Border
			Label.Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			Label.Stroke.Thickness = 1.5

			-- Label Text
			Label.Text = Instance.new("TextLabel", Label.Frame)
			Label.Text.Text = options.Text or "Label"
			Label.Text.TextColor3 = options.TextColor or UI.Theme.Text
			Label.Text.TextScaled = true
			Label.Text.TextXAlignment = options.Alignment or Enum.TextXAlignment.Left
			Label.Text.FontFace = Font.new("rbxasset://fonts/families/Roboto.json")
			Label.Text.BackgroundTransparency = 1
			Label.Text.Size = UDim2.new(0.9, 0, 0, 0)
			Label.Text.Position = UDim2.new(0.05, 0, 0, 0)
			Label.Text.ZIndex = 13
			Label.Text.AutomaticSize = Enum.AutomaticSize.Y

			-- Text Padding
			Label.Padding = Instance.new("UIPadding", Label.Text)
			Label.Padding.PaddingTop = UDim.new(0.1, 0)
			Label.Padding.PaddingBottom = UDim.new(0.1, 0)
			Label.Padding.PaddingLeft = UDim.new(0.05, 0)
			Label.Padding.PaddingRight = UDim.new(0.05, 0)

			function Label:SetText(text)
				Label.Text.Text = text
			end

			function Label:SetColor(color)
				Label.Frame.BackgroundColor3 = color
			end

			function Label:SetTextColor(color)
				Label.Text.TextColor3 = color
			end

			table.insert(Tab.Components, Label)
			return Label
		end

		-- Component: Keybind
		function Tab:Keybind(options)
			options = options or {}
			local Keybind = {
				Key = options.Key or Enum.KeyCode.E,
				Callback = options.Callback,
				IsActive = false,
			}

			Keybind.Frame = Instance.new("Frame", Tab.ScrollingFrame)
			Keybind.Frame.Name = options.Name or "Keybind"
			Keybind.Frame.BackgroundColor3 = UI.Theme.Background
			Keybind.Frame.Size = UDim2.new(0.95, 0, 0.08, 0)
			Keybind.Frame.BorderSizePixel = 0
			Keybind.Frame.ZIndex = 12

			-- Keybind Corner
			Keybind.Corner = Instance.new("UICorner", Keybind.Frame)
			Keybind.Corner.CornerRadius = UDim.new(0.1, 0)

			-- Keybind Stroke
			Keybind.Stroke = Instance.new("UIStroke", Keybind.Frame)
			Keybind.Stroke.Color = UI.Theme.Border
			Keybind.Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			Keybind.Stroke.Thickness = 1.5

			-- Keybind Label
			Keybind.Label = Instance.new("TextLabel", Keybind.Frame)
			Keybind.Label.Text = options.Text or "Keybind"
			Keybind.Label.TextColor3 = UI.Theme.Text
			Keybind.Label.TextScaled = true
			Keybind.Label.TextXAlignment = Enum.TextXAlignment.Left
			Keybind.Label.FontFace = Font.new("rbxasset://fonts/families/Roboto.json")
			Keybind.Label.BackgroundTransparency = 1
			Keybind.Label.Size = UDim2.new(0.6, 0, 0.5, 0)
			Keybind.Label.Position = UDim2.new(0.05, 0, 0.25, 0)
			Keybind.Label.ZIndex = 13

			-- Keybind Button
			Keybind.Button = Instance.new("TextButton", Keybind.Frame)
			Keybind.Button.Text = Keybind.Key.Name
			Keybind.Button.TextColor3 = UI.Theme.Text
			Keybind.Button.TextScaled = true
			Keybind.Button.FontFace = Font.new("rbxasset://fonts/families/Roboto.json")
			Keybind.Button.BackgroundColor3 = UI.Theme.Secondary
			Keybind.Button.Size = UDim2.new(0.2, 0, 0.6, 0)
			Keybind.Button.Position = UDim2.new(0.75, 0, 0.2, 0)
			Keybind.Button.ZIndex = 13
			Keybind.Button.BorderSizePixel = 0

			-- Button Corner
			Keybind.ButtonCorner = Instance.new("UICorner", Keybind.Button)
			Keybind.ButtonCorner.CornerRadius = UDim.new(0.2, 0)

			local function setKey(input)
				if input.UserInputType == Enum.UserInputType.Keyboard then
					Keybind.Key = input.KeyCode
					Keybind.Button.Text = Keybind.Key.Name
				end
			end

			Keybind.Button.MouseButton1Click:Connect(function()
				Keybind.Button.Text = "Press a key..."
				Keybind.IsActive = true
				local connection
				connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
					if Keybind.IsActive and not gameProcessed then
						setKey(input)
						Keybind.IsActive = false
						connection:Disconnect()
					end
				end)
			end)

			UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if not gameProcessed and not Keybind.IsActive and input.KeyCode == Keybind.Key then
					if Keybind.Callback then
						Keybind.Callback()
					end
				end
			end)

			function Keybind:SetKey(key)
				Keybind.Key = key
				Keybind.Button.Text = key.Name
			end

			function Keybind:GetKey()
				return Keybind.Key
			end

			function Keybind:SetCallback(callback)
				Keybind.Callback = callback
			end

			table.insert(Tab.Components, Keybind)
			return Keybind
		end

		-- Component: ColorPicker
		function Tab:ColorPicker(options)
			options = options or {}
			local ColorPicker = {
				Color = options.Default or Color3.fromRGB(255, 255, 255),
				Callback = options.Callback,
				IsOpen = false,
			}

			ColorPicker.Frame = Instance.new("TextButton", Tab.ScrollingFrame)
			ColorPicker.Frame.Name = options.Name or "ColorPicker"
			ColorPicker.Frame.Text = ""
			ColorPicker.Frame.BackgroundColor3 = UI.Theme.Background
			ColorPicker.Frame.Size = UDim2.new(0.95, 0, 0.08, 0)
			ColorPicker.Frame.AutoButtonColor = false
			ColorPicker.Frame.ClipsDescendants = true
			ColorPicker.Frame.BorderSizePixel = 0
			ColorPicker.Frame.ZIndex = 12

			-- ColorPicker Corner
			ColorPicker.Corner = Instance.new("UICorner", ColorPicker.Frame)
			ColorPicker.Corner.CornerRadius = UDim.new(0.1, 0)

			-- ColorPicker Stroke
			ColorPicker.Stroke = Instance.new("UIStroke", ColorPicker.Frame)
			ColorPicker.Stroke.Color = UI.Theme.Border
			ColorPicker.Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			ColorPicker.Stroke.Thickness = 1.5

			-- ColorPicker Label
			ColorPicker.Label = Instance.new("TextLabel", ColorPicker.Frame)
			ColorPicker.Label.Text = options.Text or "ColorPicker"
			ColorPicker.Label.TextColor3 = UI.Theme.Text
			ColorPicker.Label.TextScaled = true
			ColorPicker.Label.TextXAlignment = Enum.TextXAlignment.Left
			ColorPicker.Label.FontFace = Font.new("rbxasset://fonts/families/Roboto.json")
			ColorPicker.Label.BackgroundTransparency = 1
			ColorPicker.Label.Size = UDim2.new(0.6, 0, 0.5, 0)
			ColorPicker.Label.Position = UDim2.new(0.05, 0, 0.25, 0)
			ColorPicker.Label.ZIndex = 13

			-- Color Preview
			ColorPicker.Preview = Instance.new("Frame", ColorPicker.Frame)
			ColorPicker.Preview.BackgroundColor3 = ColorPicker.Color
			ColorPicker.Preview.Size = UDim2.new(0.1, 0, 0.6, 0)
			ColorPicker.Preview.Position = UDim2.new(0.85, 0, 0.2, 0)
			ColorPicker.Preview.ZIndex = 13
			ColorPicker.Preview.BorderSizePixel = 0

			-- Preview Corner
			ColorPicker.PreviewCorner = Instance.new("UICorner", ColorPicker.Preview)
			ColorPicker.PreviewCorner.CornerRadius = UDim.new(0.2, 0)

			-- Picker Panel
			ColorPicker.Panel = Instance.new("Frame", ColorPicker.Frame)
			ColorPicker.Panel.Name = "PickerPanel"
			ColorPicker.Panel.BackgroundColor3 = UI.Theme.Secondary
			ColorPicker.Panel.Size = UDim2.new(0, 0, 0, 0)
			ColorPicker.Panel.Position = UDim2.new(0.05, 0, 0.8, 0)
			ColorPicker.Panel.ZIndex = 14
			ColorPicker.Panel.Visible = false
			ColorPicker.Panel.ClipsDescendants = true

			-- Panel Corner
			ColorPicker.PanelCorner = Instance.new("UICorner", ColorPicker.Panel)
			ColorPicker.PanelCorner.CornerRadius = UDim.new(0.1, 0)

			-- Saturation/Value Gradient
			ColorPicker.SVGradient = Instance.new("ImageLabel", ColorPicker.Panel)
			ColorPicker.SVGradient.Image = "rbxassetid://4155801252" -- Saturation/Value gradient
			ColorPicker.SVGradient.Size = UDim2.new(0.7, 0, 0.7, 0)
			ColorPicker.SVGradient.Position = UDim2.new(0.05, 0, 0.1, 0)
			ColorPicker.SVGradient.ZIndex = 15
			ColorPicker.SVGradient.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Hue base

			-- SV Cursor
			ColorPicker.SVCursor = Instance.new("Frame", ColorPicker.SVGradient)
			ColorPicker.SVCursor.Size = UDim2.new(0.05, 0, 0.05, 0)
			ColorPicker.SVCursor.BackgroundColor3 = ColorPicker.Color
			ColorPicker.SVCursor.ZIndex = 16
			ColorPicker.SVCursor.BorderSizePixel = 1
			ColorPicker.SVCursor.BorderColor3 = Color3.fromRGB(255, 255, 255)

			-- Hue Slider
			ColorPicker.HueSlider = Instance.new("Frame", ColorPicker.Panel)
			ColorPicker.HueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ColorPicker.HueSlider.Size = UDim2.new(0.2, 0, 0.7, 0)
			ColorPicker.HueSlider.Position = UDim2.new(0.75, 0, 0.1, 0)
			ColorPicker.HueSlider.ZIndex = 15

			-- Hue Gradient
			ColorPicker.HueGradient = Instance.new("UIGradient", ColorPicker.HueSlider)
			ColorPicker.HueGradient.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
				ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
			}

			-- Hue Cursor
			ColorPicker.HueCursor = Instance.new("Frame", ColorPicker.HueSlider)
			ColorPicker.HueCursor.Size = UDim2.new(1, 0, 0.05, 0)
			ColorPicker.HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ColorPicker.HueCursor.ZIndex = 16
			ColorPicker.HueCursor.BorderSizePixel = 1
			ColorPicker.HueCursor.BorderColor3 = Color3.fromRGB(0, 0, 0)

			local function updateColor()
				local huePos = ColorPicker.HueCursor.Position.Y.Scale
				local svPos = ColorPicker.SVCursor.Position
				local h = 1 - huePos
				local s = svPos.X.Scale
				local v = 1 - svPos.Y.Scale
				ColorPicker.Color = Color3.fromHSV(h, s, v)
				ColorPicker.Preview.BackgroundColor3 = ColorPicker.Color
				ColorPicker.SVGradient.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
				if ColorPicker.Callback then
					ColorPicker.Callback(ColorPicker.Color)
				end
			end

			local function setColor(color)
				local h, s, v = color:ToHSV()
				ColorPicker.HueCursor.Position = UDim2.new(0, 0, 1 - h, 0)
				ColorPicker.SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
				updateColor()
			end

			ColorPicker.Frame.MouseButton1Click:Connect(function()
				ColorPicker.IsOpen = not ColorPicker.IsOpen
				if ColorPicker.IsOpen then
					if UI.AnimationsEnabled then
						PurpleBotUI:Tween(ColorPicker.Frame, nil, {Size = UDim2.new(0.95, 0, 0.4, 0)})
						PurpleBotUI:Tween(ColorPicker.Panel, nil, {Size = UDim2.new(0.9, 0, 0.85, 0)})
					else
						ColorPicker.Frame.Size = UDim2.new(0.95, 0, 0.4, 0)
						ColorPicker.Panel.Size = UDim2.new(0.9, 0, 0.85, 0)
					end
					ColorPicker.Panel.Visible = true
				else
					if UI.AnimationsEnabled then
						PurpleBotUI:Tween(ColorPicker.Frame, nil, {Size = UDim2.new(0.95, 0, 0.08, 0)})
						PurpleBotUI:Tween(ColorPicker.Panel, nil, {Size = UDim2.new(0, 0, 0, 0)}, function()
							ColorPicker.Panel.Visible = false
						end)
					else
						ColorPicker.Frame.Size = UDim2.new(0.95, 0, 0.08, 0)
						ColorPicker.Panel.Size = UDim2.new(0, 0, 0, 0)
						ColorPicker.Panel.Visible = false
					end
				end
			end)

			ColorPicker.SVGradient.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					local function updateSV()
						local mousePos = UserInputService:GetMouseLocation()
						local svPos = ColorPicker.SVGradient.AbsolutePosition
						local svSize = ColorPicker.SVGradient.AbsoluteSize
						local x = math.clamp((mousePos.X - svPos.X) / svSize.X, 0, 1)
						local y = math.clamp((mousePos.Y - svPos.Y) / svSize.Y, 0, 1)
						ColorPicker.SVCursor.Position = UDim2.new(x, 0, y, 0)
						updateColor()
					end

					updateSV()
					local conn
					conn = RunService.RenderStepped:Connect(function()
						if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
							conn:Disconnect()
						else
							updateSV()
						end
					end)
				end
			end)

			ColorPicker.HueSlider.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					local function updateHue()
						local mousePos = UserInputService:GetMouseLocation()
						local huePos = ColorPicker.HueSlider.AbsolutePosition
						local hueSize = ColorPicker.HueSlider.AbsoluteSize
						local y = math.clamp((mousePos.Y - huePos.Y) / hueSize.Y, 0, 1)
						ColorPicker.HueCursor.Position = UDim2.new(0, 0, y, 0)
						updateColor()
					end

					updateHue()
					local conn
					conn = RunService.RenderStepped:Connect(function()
						if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
							conn:Disconnect()
						else
							updateHue()
						end
					end)
				end
			end)

			setColor(ColorPicker.Color)

			function ColorPicker:SetColor(color)
				setColor(color)
			end

			function ColorPicker:GetColor()
				return ColorPicker.Color
			end

			function ColorPicker:SetCallback(callback)
				ColorPicker.Callback = callback
			end

			table.insert(Tab.Components, ColorPicker)
			return ColorPicker
		end

		-- Component: ProgressBar
		function Tab:ProgressBar(options)
			options = options or {}
			local ProgressBar = {
				Value = options.Value or 0,
				Max = options.Max or 100,
			}

			ProgressBar.Frame = Instance.new("Frame", Tab.ScrollingFrame)
			ProgressBar.Frame.Name = options.Name or "ProgressBar"
			ProgressBar.Frame.BackgroundColor3 = UI.Theme.Background
			ProgressBar.Frame.Size = UDim2.new(0.95, 0, 0.06, 0)
			ProgressBar.Frame.BorderSizePixel = 0
			ProgressBar.Frame.ZIndex = 12

			-- ProgressBar Corner
			ProgressBar.Corner = Instance.new("UICorner", ProgressBar.Frame)
			ProgressBar.Corner.CornerRadius = UDim.new(0.1, 0)

			-- ProgressBar Stroke
			ProgressBar.Stroke = Instance.new("UIStroke", ProgressBar.Frame)
			ProgressBar.Stroke.Color = UI.Theme.Border
			ProgressBar.Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			ProgressBar.Stroke.Thickness = 1.5

			-- ProgressBar Bar
			ProgressBar.Bar = Instance.new("Frame", ProgressBar.Frame)
			ProgressBar.Bar.BackgroundColor3 = UI.Theme.Border
			ProgressBar.Bar.Size = UDim2.new(0.9, 0, 0.5, 0)
			ProgressBar.Bar.Position = UDim2.new(0.05, 0, 0.25, 0)
			ProgressBar.Bar.ZIndex = 13
			ProgressBar.Bar.BorderSizePixel = 0

			-- Bar Corner
			ProgressBar.BarCorner = Instance.new("UICorner", ProgressBar.Bar)
			ProgressBar.BarCorner.CornerRadius = UDim.new(0.5, 0)

			-- Progress Fill
			ProgressBar.Fill = Instance.new("Frame", ProgressBar.Bar)
			ProgressBar.Fill.BackgroundColor3 = UI.Theme.Accent
			ProgressBar.Fill.Size = UDim2.new(ProgressBar.Value / ProgressBar.Max, 0, 1, 0)
			ProgressBar.Fill.ZIndex = 14
			ProgressBar.Fill.BorderSizePixel = 0

			-- Fill Corner
			ProgressBar.FillCorner = Instance.new("UICorner", ProgressBar.Fill)
			ProgressBar.FillCorner.CornerRadius = UDim.new(0.5, 0)

			-- Progress Text
			ProgressBar.Text = Instance.new("TextLabel", ProgressBar.Frame)
			ProgressBar.Text.Text = string.format("%d%%", math.floor((ProgressBar.Value / ProgressBar.Max) * 100))
			ProgressBar.Text.TextColor3 = UI.Theme.Text
			ProgressBar.Text.TextScaled = true
			ProgressBar.Text.FontFace = Font.new("rbxasset://fonts/families/Roboto.json")
			ProgressBar.Text.BackgroundTransparency = 1
			ProgressBar.Text.Size = UDim2.new(0.2, 0, 0.5, 0)
			ProgressBar.Text.Position = UDim2.new(0.4, 0, 0.25, 0)
			ProgressBar.Text.ZIndex = 15

			local function updateProgress(value)
				ProgressBar.Value = math.clamp(value, 0, ProgressBar.Max)
				local percentage = ProgressBar.Value / ProgressBar.Max
				if UI.AnimationsEnabled then
					PurpleBotUI:Tween(ProgressBar.Fill, nil, {Size = UDim2.new(percentage, 0, 1, 0)})
				else
					ProgressBar.Fill.Size = UDim2.new(percentage, 0, 1, 0)
				end
				ProgressBar.Text.Text = string.format("%d%%", math.floor(percentage * 100))
			end

			function ProgressBar:SetValue(value)
				updateProgress(value)
			end

			function ProgressBar:GetValue()
				return ProgressBar.Value
			end

			function ProgressBar:SetMax(max)
				ProgressBar.Max = max
				updateProgress(ProgressBar.Value)
			end

			updateProgress(ProgressBar.Value)

			table.insert(Tab.Components, ProgressBar)
			return ProgressBar
		end

		table.insert(UI.Tabs, Tab)
		if not UI.CurrentTab then
			Tab:Activate()
		end

		return Tab
	end

	-- Drawing Utility
	function UI:Drawing(options)
		options = options or {}
		local Drawing = {
			Type = options.Type or "Circle",
		}

		if Drawing.Type == "Circle" then
			Drawing.Frame = Instance.new("Frame", UI.ScreenGui)
			Drawing.Frame.Name = "DrawingCircle"
			Drawing.Frame.BackgroundTransparency = 1
			Drawing.Frame.Size = UDim2.new(options.Size or 0.05, 0, options.Size or 0.05, 0)
			Drawing.Frame.Position = options.Position or UDim2.new(0.5, 0, 0.5, 0)
			Drawing.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
			Drawing.Frame.ZIndex = options.ZIndex or 20

			-- Circle Corner
			Drawing.Corner = Instance.new("UICorner", Drawing.Frame)
			Drawing.Corner.CornerRadius = UDim.new(1, 0)

			-- Circle Stroke
			Drawing.Stroke = Instance.new("UIStroke", Drawing.Frame)
			Drawing.Stroke.Color = options.Color or UI.Theme.Accent
			Drawing.Stroke.Thickness = options.Thickness or 2

			function Drawing:SetRadius(radius)
				Drawing.Frame.Size = UDim2.new(radius, 0, radius, 0)
			end

			function Drawing:SetColor(color)
				Drawing.Stroke.Color = color
			end
		elseif Drawing.Type == "Line" then
			Drawing.Frame = Instance.new("Frame", UI.ScreenGui)
			Drawing.Frame.Name = "DrawingLine"
			Drawing.Frame.BackgroundColor3 = options.Color or UI.Theme.Accent
			Drawing.Frame.Size = UDim2.new(options.Length or 0.1, 0, 0, options.Thickness or 2)
			Drawing.Frame.Position = options.Position or UDim2.new(0.5, 0, 0.5, 0)
			Drawing.Frame.ZIndex = options.ZIndex or 20

			function Drawing:SetLength(length)
				Drawing.Frame.Size = UDim2.new(length, 0, 0, Drawing.Frame.Size.Y.Offset)
			end

			function Drawing:SetThickness(thickness)
				Drawing.Frame.Size = UDim2.new(Drawing.Frame.Size.X.Scale, 0, 0, thickness)
			end
		end

		function Drawing:SetPosition(pos)
			Drawing.Frame.Position = pos
		end

		function Drawing:GetPosition()
			return Drawing.Frame.Position
		end

		function Drawing:ToggleVisible(visible)
			Drawing.Frame.Visible = visible
		end

		return Drawing
	end

	-- Theme Management
	function UI:SetTheme(theme)
		UI.Theme = theme
		UI.MainFrame.BackgroundColor3 = theme.Background
		UI.TopBar.BackgroundColor3 = theme.Primary
		UI.Sidebar.BackgroundColor3 = theme.Secondary
		UI.MainStroke.Color = theme.Border
		UI.Title.TextColor3 = theme.Text
		UI.ExitButton.TextColor3 = theme.Text
		UI.MinimizeButton.ImageColor3 = theme.Text
		UI.NotifyFrame.BackgroundColor3 = theme.Background
		UI.NotifyText.TextColor3 = theme.Text
		UI.NotifyStroke.Color = theme.Accent
		for _, tab in ipairs(UI.Tabs) do
			for _, comp in ipairs(tab.Components) do
				if comp.Frame then
					comp.Frame.BackgroundColor3 = theme.Background
					if comp.Stroke then
						comp.Stroke.Color = theme.Border
					end
					if comp.Text then
						comp.Text.TextColor3 = theme.Text
					end
				end
			end
		end
	end

	-- Animation Toggle
	function UI:ToggleAnimations(enabled)
		UI.AnimationsEnabled = enabled
	end

	-- Utility Functions
	function UI:GetTabs()
		return UI.Tabs
	end

	function UI:GetCurrentTab()
		return UI.CurrentTab
	end

	return UI
end

return PurpleBotUI
