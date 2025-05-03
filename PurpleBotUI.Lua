--[[
	PurpleBotUI - A Modern Roblox UI Library
	Refactored and Enhanced from BeanzUI
	Version: 1.0
]]

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui") -- Preferred parent for robust UIs

local player = Players.LocalPlayer
local mouse = player:GetMouse() -- Keep for potential mouse-specific interactions if needed later

--==============================================================================
-- Configuration & Theme
--==============================================================================

local PurpleBotUI = {}
PurpleBotUI.Version = "1.0"

local Theme = {
	-- Primary Colors (Dark Purple Scheme)
	Primary = Color3.fromRGB(88, 30, 135),     -- Deep Purple (e.g., Top Bar Gradient)
	PrimaryVariant = Color3.fromRGB(65, 22, 100), -- Darker Purple (e.g., Top Bar Gradient)
	Secondary = Color3.fromRGB(128, 70, 175),   -- Lighter Purple (e.g., Accents, Slider Bar)
	Background = Color3.fromRGB(35, 35, 40),     -- Dark Background (Main Frame)
	Surface = Color3.fromRGB(45, 45, 50),       -- Slightly Lighter Surface (Sidebar, Component Backgrounds)
	Accent = Color3.fromRGB(180, 120, 220),   -- Bright Purple/Pink Accent (Hover effects, Active states)

	-- Text Colors
	TextPrimary = Color3.fromRGB(240, 240, 245), -- Primary Text (White/Off-white)
	TextSecondary = Color3.fromRGB(180, 180, 190), -- Secondary Text (Grayish)
	TextOnPrimary = Color3.fromRGB(255, 255, 255), -- Text on dark purple backgrounds
	TextOnAccent = Color3.fromRGB(255, 255, 255), -- Text on accent backgrounds

	-- State Colors
	Success = Color3.fromRGB(30, 180, 90),
	Warning = Color3.fromRGB(230, 160, 20),
	Info = Color3.fromRGB(50, 150, 220),
	Error = Color3.fromRGB(220, 40, 60),
	Disabled = Color3.fromRGB(100, 100, 110),

	-- Borders & Strokes
	Border = Color3.fromRGB(70, 70, 80),      -- Default border/stroke color
	BorderActive = Color3.fromRGB(180, 120, 220), -- Stroke for active/highlighted items
	BorderThickness = 1, -- Default thickness

	-- Fonts (Ensure these fonts are available or use Roblox defaults)
	FontRegular = Font.new("rbxassetid://12199695737", Enum.FontWeight.Regular, Enum.FontStyle.Normal), -- Example: Gotham
	FontMedium = Font.new("rbxassetid://12199695737", Enum.FontWeight.Medium, Enum.FontStyle.Normal),  -- Example: Gotham Medium
	FontBold = Font.new("rbxassetid://12199695737", Enum.FontWeight.Bold, Enum.FontStyle.Normal),    -- Example: Gotham Bold

	-- Sizes & Radii
	CornerRadius = UDim.new(0, 6), -- Default corner radius
	SmallCornerRadius = UDim.new(0, 4),
	LargeCornerRadius = UDim.new(0, 8),
	DefaultPadding = UDim.new(0.03, 0), -- Default padding for containers
	ElementPadding = UDim.new(0.05, 0), -- Padding within elements like buttons
}

--==============================================================================
-- Utilities
--==============================================================================

local defaultTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local fastTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local slowTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local function tween(object, tweenInfo, goal, callback)
	local t = TweenService:Create(object, tweenInfo or defaultTweenInfo, goal)
	if callback then
		local connection
		connection = t.Completed:Connect(function(state)
			connection:Disconnect() -- Prevent memory leaks
			callback(state)
		end)
	end
	t:Play()
	return t
end

local function setupHoverEffect(element, hoverGoal, defaultGoal, condition)
	local defaultProps = {}
	for prop, _ in pairs(hoverGoal) do
		defaultProps[prop] = element[prop]
	end
	for prop, val in pairs(defaultGoal or {}) do
		defaultProps[prop] = val -- Allow overriding defaults
	end

	element.MouseEnter:Connect(function()
		if condition and not condition() then return end
		tween(element, fastTweenInfo, hoverGoal)
	end)

	element.MouseLeave:Connect(function()
		if condition and not condition() then return end
		tween(element, fastTweenInfo, defaultProps)
	end)
end

local function dragGUI(guiElement, dragHandle)
	local isDragging = false
	local dragStartMousePos
	local startGuiPos

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
			dragStartMousePos = input.Position
			startGuiPos = guiElement.Position
			-- Prevent text selection while dragging
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		end
	end)

	dragHandle.InputEnded:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isDragging then
			isDragging = false
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStartMousePos
			local newPos = UDim2.new(
				startGuiPos.X.Scale, startGuiPos.X.Offset + delta.X,
				startGuiPos.Y.Scale, startGuiPos.Y.Offset + delta.Y
			)
			-- No tweening during drag for responsiveness
			guiElement.Position = newPos
		end
	end)
end

--==============================================================================
-- Main UI Class
--==============================================================================

function PurpleBotUI:new(args)
	args = args or {}
	args.Name = args.Name or "PurpleBotUI"
	args.Size = args.Size or UDim2.fromScale(0.4, 0.5) -- Default size
	args.MinimizedSize = args.MinimizedSize or UDim2.new(args.Size.X.Scale, 0, 0, 40) -- Adjust height for minimized state
	args.MinPosition = args.MinPosition or UDim2.fromScale(0.3, 0.3) -- Default position
	args.Movable = args.Movable == nil and true or args.Movable -- Default to movable

	local UI = {
		CurrentTab = nil,
		Tabs = {},
		onDestroyed = args.onDestroyed, -- Callback when closed
		_internal = {}, -- Store internal instances
		_connections = {}, -- Store connections to disconnect later
		_isMinimized = false,
		_originalSize = args.Size,
		_originalPosition = args.MinPosition,
		_elements = {} -- To store created elements like buttons, sliders etc for potential access
	}
	setmetatable(UI, {__index = PurpleBotUI}) -- Allow calling methods like UI:CreateTab

	-- // ScreenGui \\ --
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PurpleBotUI_Container"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true -- Usually better for draggable UIs
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- Ensure proper layering
	screenGui.DisplayOrder = args.DisplayOrder or 100 -- Control draw order relative to other ScreenGuis
	screenGui.Parent = RunService:IsStudio() and player:WaitForChild("PlayerGui") or CoreGui
	UI._internal.screenGui = screenGui

	-- // Main Frame \\ --
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = args.Size
	mainFrame.Position = args.MinPosition
	mainFrame.BackgroundColor3 = Theme.Background
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = screenGui
	UI._internal.mainFrame = mainFrame

	local mainFrameCorner = Instance.new("UICorner", mainFrame)
	mainFrameCorner.CornerRadius = Theme.LargeCornerRadius

	-- Optional: Add subtle shadow/outline
	local mainFrameStroke = Instance.new("UIStroke", mainFrame)
	mainFrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	mainFrameStroke.Color = Theme.Border
	mainFrameStroke.Thickness = Theme.BorderThickness + 1 -- Slightly thicker outline for main window
	mainFrameStroke.Transparency = 0.5

	-- // Top Bar \\ --
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 40) -- Fixed height top bar
	topBar.BackgroundColor3 = Theme.PrimaryVariant -- Use solid color or gradient below
	topBar.BorderSizePixel = 0
	topBar.Parent = mainFrame
	UI._internal.topBar = topBar

	local topBarGradient = Instance.new("UIGradient", topBar)
	topBarGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.PrimaryVariant),
		ColorSequenceKeypoint.new(1, Theme.Primary)
	})
	topBarGradient.Rotation = 90

	local topBarCorner = Instance.new("UICorner", topBar)
	topBarCorner.CornerRadius = Theme.LargeCornerRadius -- Match parent

	-- Clip top corners only (Hack: Cover bottom corners)
	local bottomCover = Instance.new("Frame", topBar)
	bottomCover.Size = UDim2.new(1, 0, 0.5, 0)
	bottomCover.Position = UDim2.new(0, 0, 0.5, 0)
	bottomCover.BackgroundColor3 = topBar.BackgroundColor3 -- Match solid color part
	bottomCover.BackgroundTransparency = topBarGradient and 1 or 0 -- Hide if gradient is used, show if solid
	bottomCover.BorderSizePixel = 0
	bottomCover.ZIndex = topBar.ZIndex - 1 -- Behind other topbar elements

	-- Layout for Top Bar elements
	local topBarLayout = Instance.new("UIListLayout", topBar)
	topBarLayout.FillDirection = Enum.FillDirection.Horizontal
	topBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	topBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	topBarLayout.Padding = UDim.new(0.02, 0)

	local topBarPadding = Instance.new("UIPadding", topBar)
	topBarPadding.PaddingLeft = UDim.new(0.02, 0)
	topBarPadding.PaddingRight = UDim.new(0.01, 0)

	-- // Icon \\ --
	local iconImage = Instance.new("ImageLabel")
	iconImage.Name = "Icon"
	iconImage.Size = UDim2.new(0, 28, 0, 28) -- Fixed size icon
	iconImage.BackgroundTransparency = 1
	iconImage.Image = args.Icon or "rbxassetid://18187292776" -- Default PurpleBot icon (replace with actual)
	iconImage.ScaleType = Enum.ScaleType.Fit
	iconImage.LayoutOrder = 1
	iconImage.Parent = topBar
	UI._internal.iconImage = iconImage

	-- // Title \\ --
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -100, 0, 30) -- Flexible width, minus space for buttons
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Theme.FontMedium.FontFace
	titleLabel.Text = args.Name
	titleLabel.TextColor3 = Theme.TextOnPrimary
	titleLabel.TextSize = 18
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.LayoutOrder = 2
	titleLabel.Parent = topBar
	UI._internal.titleLabel = titleLabel

	-- Spacer to push buttons to the right
	local spacer = Instance.new("Frame")
	spacer.Name = "Spacer"
	spacer.Size = UDim2.new(1, -100, 0, 1) -- Takes up remaining space dynamically
	spacer.BackgroundTransparency = 1
	spacer.LayoutOrder = 3
	spacer.Parent = topBar

	-- // Minimize Button \\ --
	local minimizeButton = Instance.new("ImageButton")
	minimizeButton.Name = "MinimizeButton"
	minimizeButton.Size = UDim2.new(0, 24, 0, 24)
	minimizeButton.BackgroundTransparency = 1
	minimizeButton.Image = "rbxassetid://3926307971" -- Minus icon (replace if needed)
	minimizeButton.ImageColor3 = Theme.TextOnPrimary
	minimizeButton.ScaleType = Enum.ScaleType.Fit
	minimizeButton.LayoutOrder = 4
	minimizeButton.Parent = topBar
	UI._internal.minimizeButton = minimizeButton
	table.insert(UI._connections, minimizeButton.MouseEnter:Connect(function() tween(minimizeButton, fastTweenInfo, {ImageColor3 = Theme.Accent}) end))
	table.insert(UI._connections, minimizeButton.MouseLeave:Connect(function() tween(minimizeButton, fastTweenInfo, {ImageColor3 = Theme.TextOnPrimary}) end))

	-- // Exit Button \\ --
	local exitButton = Instance.new("ImageButton")
	exitButton.Name = "ExitButton"
	exitButton.Size = UDim2.new(0, 24, 0, 24)
	exitButton.BackgroundTransparency = 1
	exitButton.Image = "rbxassetid://3926307976" -- Close icon (replace if needed)
	exitButton.ImageColor3 = Theme.TextOnPrimary
	exitButton.ScaleType = Enum.ScaleType.Fit
	exitButton.LayoutOrder = 5
	exitButton.Parent = topBar
	UI._internal.exitButton = exitButton
	table.insert(UI._connections, exitButton.MouseEnter:Connect(function() tween(exitButton, fastTweenInfo, {ImageColor3 = Theme.Error}) end))
	table.insert(UI._connections, exitButton.MouseLeave:Connect(function() tween(exitButton, fastTweenInfo, {ImageColor3 = Theme.TextOnPrimary}) end))


	-- // Main Content Area (Below Top Bar) \\ --
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.new(1, 0, 1, -topBar.Size.Y.Offset) -- Fill remaining space
	contentFrame.Position = UDim2.new(0, 0, 0, topBar.Size.Y.Offset)
	contentFrame.BackgroundTransparency = 1
	contentFrame.BorderSizePixel = 0
	contentFrame.Parent = mainFrame
	UI._internal.contentFrame = contentFrame

	-- // Sidebar \\ --
	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0.25, 0, 1, 0) -- 25% width
	sidebar.BackgroundColor3 = Theme.Surface
	sidebar.BorderSizePixel = 0
	sidebar.Parent = contentFrame
	UI._internal.sidebar = sidebar

	local sidebarCorner = Instance.new("UICorner", sidebar)
	sidebarCorner.CornerRadius = Theme.LargeCornerRadius -- Match parent corners visually

	-- Cover top-right corner (Hack)
	local cornerCoverSidebar = Instance.new("Frame", sidebar)
	cornerCoverSidebar.Size = UDim2.new(0.5, 0, 0, Theme.LargeCornerRadius.Offset * 2) -- Adjust size based on radius
	cornerCoverSidebar.Position = UDim2.new(0.5, 0, 0, 0)
	cornerCoverSidebar.BackgroundColor3 = sidebar.BackgroundColor3
	cornerCoverSidebar.BorderSizePixel = 0
	cornerCoverSidebar.ZIndex = sidebar.ZIndex - 1

	local sidebarPadding = Instance.new("UIPadding", sidebar)
	sidebarPadding.PaddingTop = UDim.new(0.03, 0)
	sidebarPadding.PaddingBottom = UDim.new(0.03, 0)
	sidebarPadding.PaddingLeft = UDim.new(0.05, 0)
	sidebarPadding.PaddingRight = UDim.new(0.05, 0)

	local sidebarLayout = Instance.new("UIListLayout", sidebar)
	sidebarLayout.FillDirection = Enum.FillDirection.Vertical
	sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sidebarLayout.Padding = UDim.new(0, 5) -- Space between tab buttons
	UI._internal.sidebarLayout = sidebarLayout

	-- // Tab Holder \\ --
	local tabHolder = Instance.new("Frame")
	tabHolder.Name = "TabHolder"
	tabHolder.Size = UDim2.new(1, -sidebar.Size.X.Scale * mainFrame.AbsoluteSize.X, 1, 0) -- Fill space right of sidebar
	tabHolder.Position = UDim2.new(sidebar.Size.X.Scale, 0, 0, 0)
	tabHolder.BackgroundTransparency = 1 -- Transparent, content shown in ScrollingFrames
	tabHolder.BorderSizePixel = 0
	tabHolder.ClipsDescendants = true
	tabHolder.Parent = contentFrame
	UI._internal.tabHolder = tabHolder

	-- Tooltip Frame (Initially Hidden)
	local tooltipFrame = Instance.new("Frame")
	tooltipFrame.Name = "TooltipFrame"
	tooltipFrame.Size = UDim2.new(0, 100, 0, 25) -- Auto-adjusts later
	tooltipFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	tooltipFrame.BorderSizePixel = 0
	tooltipFrame.Position = UDim2.fromScale(0.5, 0.5) -- Will be updated
	tooltipFrame.AnchorPoint = Vector2.new(0, 1.1) -- Position above and slightly away from mouse
	tooltipFrame.Visible = false
	tooltipFrame.ZIndex = 1000 -- Ensure it's on top
	tooltipFrame.Parent = screenGui -- Parent to ScreenGui to overlay everything
	UI._internal.tooltipFrame = tooltipFrame

	local tooltipCorner = Instance.new("UICorner", tooltipFrame)
	tooltipCorner.CornerRadius = Theme.SmallCornerRadius

	local tooltipStroke = Instance.new("UIStroke", tooltipFrame)
	tooltipStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	tooltipStroke.Color = Theme.Accent
	tooltipStroke.Thickness = 1

	local tooltipPadding = Instance.new("UIPadding", tooltipFrame)
	tooltipPadding.PaddingLeft = UDim.new(0, 8)
	tooltipPadding.PaddingRight = UDim.new(0, 8)
	tooltipPadding.PaddingTop = UDim.new(0, 4)
	tooltipPadding.PaddingBottom = UDim.new(0, 4)

	local tooltipLabel = Instance.new("TextLabel", tooltipFrame)
	tooltipLabel.Name = "TooltipLabel"
	tooltipLabel.Size = UDim2.fromScale(1, 1)
	tooltipLabel.BackgroundTransparency = 1
	tooltipLabel.Font = Theme.FontRegular.FontFace
	tooltipLabel.TextColor3 = Theme.TextPrimary
	tooltipLabel.TextSize = 14
	tooltipLabel.TextWrapped = false
	tooltipLabel.AutomaticSize = Enum.AutomaticSize.X -- Adjust width automatically
	tooltipLabel.Text = "Tooltip"
	UI._internal.tooltipLabel = tooltipLabel

	local tooltipTween = nil
	local tooltipActive = false
	local tooltipElement = nil

	local function showTooltip(text, elementToShowNear)
		if tooltipActive and tooltipElement == elementToShowNear then return end -- Already showing for this element
		if tooltipTween then tooltipTween:Cancel() end

		tooltipActive = true
		tooltipElement = elementToShowNear
		tooltipLabel.Text = text
		tooltipFrame.Size = UDim2.new(0, tooltipLabel.TextBounds.X + tooltipPadding.PaddingLeft.Offset + tooltipPadding.PaddingRight.Offset, 0, 25) -- Adjust width
		tooltipFrame.Visible = true
		tooltipFrame.BackgroundTransparency = 1

		tooltipTween = tween(tooltipFrame, fastTweenInfo, {BackgroundTransparency = 0.1})

		-- Update position continuously
		local function updatePos()
			if tooltipActive and tooltipElement then
				local mousePos = UserInputService:GetMouseLocation()
				tooltipFrame.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
			else
				return false -- Stop updating
			end
			return true -- Continue updating
		end
		-- Use task.spawn for continuous update while hovered
		task.spawn(function()
			while updatePos() do
				RunService.RenderStepped:Wait()
			end
		end)
	end

	local function hideTooltip(elementToHideFor)
		if not tooltipActive or tooltipElement ~= elementToHideFor then return end -- Not showing or showing for a different element
		if tooltipTween then tooltipTween:Cancel() end

		tooltipTween = tween(tooltipFrame, fastTweenInfo, {BackgroundTransparency = 1}, function()
			if tooltipActive and tooltipElement == elementToHideFor then -- Check again in case another show started
				tooltipFrame.Visible = false
				tooltipActive = false
				tooltipElement = nil
				tooltipTween = nil
			end
		end)
	end
	UI._internal.showTooltip = showTooltip
	UI._internal.hideTooltip = hideTooltip

	-- // Notification Frame (Initially Hidden) \\ --
	local notifyFrame = Instance.new("Frame")
	notifyFrame.Name = "NotifyFrame"
	notifyFrame.Size = UDim2.new(0.3, 0, 0, 60) -- Example size, adjust as needed
	notifyFrame.Position = UDim2.new(0.5, 0, 1, 10) -- Start below screen
	notifyFrame.AnchorPoint = Vector2.new(0.5, 0)
	notifyFrame.BackgroundColor3 = Theme.Surface
	notifyFrame.BorderSizePixel = 0
	notifyFrame.ClipsDescendants = true
	notifyFrame.ZIndex = 500 -- Above main UI but below tooltips
	notifyFrame.Visible = false -- Start hidden
	notifyFrame.Parent = screenGui -- Parent to ScreenGui for overlay
	UI._internal.notifyFrame = notifyFrame

	local notifyCorner = Instance.new("UICorner", notifyFrame)
	notifyCorner.CornerRadius = Theme.LargeCornerRadius

	local notifyStroke = Instance.new("UIStroke", notifyFrame)
	notifyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	notifyStroke.Color = Theme.Accent -- Default color, change based on type
	notifyStroke.Thickness = Theme.BorderThickness

	local notifyPadding = Instance.new("UIPadding", notifyFrame)
	notifyPadding.PaddingLeft = UDim.new(0, 15)
	notifyPadding.PaddingRight = UDim.new(0, 15)
	notifyPadding.PaddingTop = UDim.new(0, 10)
	notifyPadding.PaddingBottom = UDim.new(0, 10)

	local notifyLabel = Instance.new("TextLabel", notifyFrame)
	notifyLabel.Name = "NotifyLabel"
	notifyLabel.Size = UDim2.new(1, -30, 1, 0) -- Leave space for potential close button
	notifyLabel.BackgroundTransparency = 1
	notifyLabel.Font = Theme.FontRegular.FontFace
	notifyLabel.TextColor3 = Theme.TextPrimary
	notifyLabel.TextSize = 16
	notifyLabel.TextWrapped = true
	notifyLabel.TextXAlignment = Enum.TextXAlignment.Left
	notifyLabel.TextYAlignment = Enum.VerticalAlignment.Center
	notifyLabel.Text = "Notification Text Here"
	UI._internal.notifyLabel = notifyLabel

	local notifyCloseButton = Instance.new("ImageButton", notifyFrame)
	notifyCloseButton.Name = "NotifyCloseButton"
	notifyCloseButton.Size = UDim2.new(0, 18, 0, 18)
	notifyCloseButton.Position = UDim2.new(1, -25, 0.5, -9) -- Top right corner
	notifyCloseButton.AnchorPoint = Vector2.new(0.5, 0.5)
	notifyCloseButton.BackgroundTransparency = 1
	notifyCloseButton.Image = "rbxassetid://3926307976" -- Close icon
	notifyCloseButton.ImageColor3 = Theme.TextSecondary
	notifyCloseButton.ZIndex = notifyFrame.ZIndex + 1
	UI._internal.notifyCloseButton = notifyCloseButton

	local notifyActive = false
	local notifyTweenIn, notifyTweenOut

	function UI:Notify(text, duration, notificationType)
		if notifyActive then
			-- Option 1: Queue notifications (more complex)
			-- Option 2: Cancel existing and show new one immediately
			if notifyTweenIn and notifyTweenIn.PlaybackState == Enum.PlaybackState.Playing then notifyTweenIn:Cancel() end
			if notifyTweenOut and notifyTweenOut.PlaybackState == Enum.PlaybackState.Playing then notifyTweenOut:Cancel() end
			notifyFrame.Visible = false -- Hide briefly to reset
		end

		duration = duration or 4 -- Default duration
		notificationType = notificationType or "Info" -- Default type

		-- Apply theme based on type
		local bgColor = Theme.Surface
		local strokeColor = Theme.Accent
		if notificationType == "Success" then
			strokeColor = Theme.Success
		elseif notificationType == "Warning" then
			strokeColor = Theme.Warning
		elseif notificationType == "Error" then
			strokeColor = Theme.Error
		elseif notificationType == "Info" then
			strokeColor = Theme.Info
		end

		notifyFrame.BackgroundColor3 = bgColor
		notifyStroke.Color = strokeColor
		notifyLabel.Text = text
		notifyFrame.Visible = true
		notifyActive = true

		local targetPos = UDim2.new(0.5, 0, 1, -notifyFrame.AbsoluteSize.Y - 10) -- Position just above bottom edge
		local startPos = UDim2.new(targetPos.X.Scale, targetPos.X.Offset, 1, 10) -- Start below screen

		notifyFrame.Position = startPos

		notifyTweenIn = tween(notifyFrame, defaultTweenInfo, {Position = targetPos})

		-- Auto-dismiss
		local dismissWait = task.delay(duration, function()
			if notifyActive then -- Check if it hasn't been closed manually
				notifyTweenOut = tween(notifyFrame, defaultTweenInfo, {Position = startPos}, function(state)
					if state == Enum.TweenStatus.Completed then
						notifyFrame.Visible = false
						notifyActive = false
						notifyTweenOut = nil
					end
				end)
				notifyTweenIn = nil -- Allow new notifications
			end
		end)

		-- Handle manual close
		local closeConn
		closeConn = notifyCloseButton.MouseButton1Click:Connect(function()
			closeConn:Disconnect()
			task.cancel(dismissWait) -- Cancel auto-dismiss
			if notifyTweenIn and notifyTweenIn.PlaybackState == Enum.PlaybackState.Playing then notifyTweenIn:Cancel() end
			if notifyTweenOut and notifyTweenOut.PlaybackState ~= Enum.PlaybackState.Playing then -- Avoid double tweening if already closing
				notifyTweenOut = tween(notifyFrame, fastTweenInfo, {Position = startPos}, function(state)
					if state == Enum.TweenStatus.Completed then
						notifyFrame.Visible = false
						notifyActive = false
						notifyTweenOut = nil
					end
				end)
			end
			notifyTweenIn = nil
		end)

		-- Add hover effect for close button
		local closeHoverConnEnter, closeHoverConnLeave
		closeHoverConnEnter = notifyCloseButton.MouseEnter:Connect(function() tween(notifyCloseButton, fastTweenInfo, {ImageColor3 = Theme.Error}) end)
		closeHoverConnLeave = notifyCloseButton.MouseLeave:Connect(function() tween(notifyCloseButton, fastTweenInfo, {ImageColor3 = Theme.TextSecondary}) end)

		-- Cleanup connections when notification is dismissed
		local function cleanupConnections()
			if closeConn and closeConn.Connected then closeConn:Disconnect() end
			if closeHoverConnEnter and closeHoverConnEnter.Connected then closeHoverConnEnter:Disconnect() end
			if closeHoverConnLeave and closeHoverConnLeave.Connected then closeHoverConnLeave:Disconnect() end
		end
		if notifyTweenOut then
			notifyTweenOut.Completed:Connect(cleanupConnections)
		else -- If closed manually before dismiss tween starts
			task.delay(duration + 0.5, cleanupConnections) -- Delay cleanup slightly
		end

	end

	-- Key System Frames (Initially Hidden) - Refactored for cleaner structure
	local function createKeyFrame(name, titleText, confirmCallback, copyLinkCallback)
		local keyFrame = Instance.new("Frame", mainFrame)
		keyFrame.Name = name
		keyFrame.Size = UDim2.fromScale(0.6, 0.4) -- Adjusted size
		keyFrame.Position = UDim2.fromScale(0.5, 0.5)
		keyFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		keyFrame.BackgroundColor3 = Theme.Background
		keyFrame.BackgroundTransparency = 0.05 -- Slight transparency
		keyFrame.BorderSizePixel = 0
		keyFrame.Visible = false
		keyFrame.ZIndex = 100 -- Above other UI elements
		UI._internal[name .. "Frame"] = keyFrame

		local keyCorner = Instance.new("UICorner", keyFrame)
		keyCorner.CornerRadius = Theme.LargeCornerRadius

		local keyStroke = Instance.new("UIStroke", keyFrame)
		keyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		keyStroke.Color = Theme.Accent
		keyStroke.Thickness = Theme.BorderThickness

		local keyLayout = Instance.new("UIListLayout", keyFrame)
		keyLayout.FillDirection = Enum.FillDirection.Vertical
		keyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		keyLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		keyLayout.Padding = UDim.new(0, 15)
		keyLayout.SortOrder = Enum.SortOrder.LayoutOrder

		local keyPadding = Instance.new("UIPadding", keyFrame)
		keyPadding.PaddingTop = UDim.new(0, 20)
		keyPadding.PaddingBottom = UDim.new(0, 20)
		keyPadding.PaddingLeft = UDim.new(0, 20)
		keyPadding.PaddingRight = UDim.new(0, 20)

		local keyTitle = Instance.new("TextLabel", keyFrame)
		keyTitle.Name = "Title"
		keyTitle.Size = UDim2.new(1, -20, 0, 30)
		keyTitle.BackgroundTransparency = 1
		keyTitle.Font = Theme.FontMedium.FontFace
		keyTitle.Text = titleText
		keyTitle.TextColor3 = Theme.TextPrimary
		keyTitle.TextSize = 18
		keyTitle.LayoutOrder = 1

		local keyInput = Instance.new("TextBox", keyFrame)
		keyInput.Name = "KeyInput"
		keyInput.Size = UDim2.new(1, -20, 0, 40)
		keyInput.BackgroundColor3 = Theme.Surface
		keyInput.Font = Theme.FontRegular.FontFace
		keyInput.TextColor3 = Theme.TextPrimary
		keyInput.PlaceholderColor3 = Theme.TextSecondary
		keyInput.PlaceholderText = "Enter key..."
		keyInput.ClearTextOnFocus = false
		keyInput.LayoutOrder = 2
		UI._internal[name .. "Input"] = keyInput

		local inputCorner = Instance.new("UICorner", keyInput)
		inputCorner.CornerRadius = Theme.SmallCornerRadius
		local inputStroke = Instance.new("UIStroke", keyInput)
		inputStroke.Color = Theme.Border
		inputStroke.Thickness = Theme.BorderThickness
		local inputPadding = Instance.new("UIPadding", keyInput)
		inputPadding.PaddingLeft = UDim.new(0, 10)
		inputPadding.PaddingRight = UDim.new(0, 10)

		-- Button Frame
		local buttonFrame = Instance.new("Frame", keyFrame)
		buttonFrame.Name = "ButtonFrame"
		buttonFrame.Size = UDim2.new(1, -20, 0, 40)
		buttonFrame.BackgroundTransparency = 1
		buttonFrame.LayoutOrder = 3

		local buttonLayout = Instance.new("UIListLayout", buttonFrame)
		buttonLayout.FillDirection = Enum.FillDirection.Horizontal
		buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		buttonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		buttonLayout.Padding = UDim.new(0, 10)
		buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder

		local confirmButton = Instance.new("TextButton", buttonFrame)
		confirmButton.Name = "ConfirmButton"
		confirmButton.Size = UDim2.new(0.4, 0, 1, 0)
		confirmButton.BackgroundColor3 = Theme.Success
		confirmButton.Font = Theme.FontMedium.FontFace
		confirmButton.Text = "Confirm"
		confirmButton.TextColor3 = Theme.TextOnAccent
		confirmButton.TextSize = 16
		confirmButton.LayoutOrder = 1
		UI._internal[name .. "ConfirmButton"] = confirmButton
		local confirmCorner = Instance.new("UICorner", confirmButton)
		confirmCorner.CornerRadius = Theme.SmallCornerRadius
		table.insert(UI._connections, confirmButton.MouseButton1Click:Connect(function()
			if confirmCallback then confirmCallback(keyInput.Text) end
			keyFrame.Visible = false
		end))
		setupHoverEffect(confirmButton, {BackgroundColor3 = Theme.Secondary}, {BackgroundColor3 = Theme.Success})


		if copyLinkCallback then
			local copyButton = Instance.new("TextButton", buttonFrame)
			copyButton.Name = "CopyLinkButton"
			copyButton.Size = UDim2.new(0.4, 0, 1, 0)
			copyButton.BackgroundColor3 = Theme.Info
			copyButton.Font = Theme.FontMedium.FontFace
			copyButton.Text = "Copy Link"
			copyButton.TextColor3 = Theme.TextOnAccent
			copyButton.TextSize = 16
			copyButton.LayoutOrder = 2
			UI._internal[name .. "CopyButton"] = copyButton
			local copyCorner = Instance.new("UICorner", copyButton)
			copyCorner.CornerRadius = Theme.SmallCornerRadius
			table.insert(UI._connections, copyButton.MouseButton1Click:Connect(copyLinkCallback))
			setupHoverEffect(copyButton, {BackgroundColor3 = Theme.Secondary}, {BackgroundColor3 = Theme.Info})
		end

		local exitKeyButton = Instance.new("ImageButton", keyFrame)
		exitKeyButton.Name = "ExitKeyButton"
		exitKeyButton.Size = UDim2.new(0, 20, 0, 20)
		exitKeyButton.Position = UDim2.new(1, -15, 0, 15) -- Top right corner
		exitKeyButton.AnchorPoint = Vector2.new(1, 0)
		exitKeyButton.BackgroundTransparency = 1
		exitKeyButton.Image = "rbxassetid://3926307976" -- Close icon
		exitKeyButton.ImageColor3 = Theme.TextSecondary
		exitKeyButton.ZIndex = keyFrame.ZIndex + 1
		table.insert(UI._connections, exitKeyButton.MouseButton1Click:Connect(function() keyFrame.Visible = false end))
		table.insert(UI._connections, exitKeyButton.MouseEnter:Connect(function() tween(exitKeyButton, fastTweenInfo, {ImageColor3 = Theme.Error}) end))
		table.insert(UI._connections, exitKeyButton.MouseLeave:Connect(function() tween(exitKeyButton, fastTweenInfo, {ImageColor3 = Theme.TextSecondary}) end))


		return keyFrame
	end

	-- Example usage for Gold Key (Silver would be similar)
	-- Replace dummy callbacks with actual logic
	local goldKeyFrame = createKeyFrame("GoldKey", "Insert Gold Key",
		function(key) print("Gold Key Confirmed:", key) UI:Notify("Gold Key Accepted!", 3, "Success") end,
		function() print("Copy Gold Key Link") setclipboard("YOUR_GOLD_KEY_LINK_HERE") UI:Notify("Link Copied!", 2, "Info") end
	)

	local silverKeyFrame = createKeyFrame("SilverKey", "Insert Silver Key",
		function(key) print("Silver Key Confirmed:", key) UI:Notify("Silver Key Accepted!", 3, "Success") end,
		function() print("Copy Silver Key Link") setclipboard("YOUR_SILVER_KEY_LINK_HERE") UI:Notify("Link Copied!", 2, "Info") end
	)

	-- Public methods to show key frames
	function UI:ShowGoldKeyPrompt() goldKeyFrame.Visible = true end
	function UI:ShowSilverKeyPrompt() silverKeyFrame.Visible = true end


	-- // Event Connections \\ --

	-- Exit Button
	table.insert(UI._connections, exitButton.MouseButton1Click:Connect(function()
		if UI.onDestroyed then
			UI.onDestroyed()
		end
		UI:Destroy() -- Call the destroy method
	end))

	-- Minimize Button
	table.insert(UI._connections, minimizeButton.MouseButton1Click:Connect(function()
		UI:MinimizeToggle()
	end))

	-- Dragging
	if args.Movable then
		dragGUI(mainFrame, topBar)
	end

	-- Store original state for minimizing
	UI._internal.originalTopBarSize = topBar.Size
	UI._internal.originalMainFrameZIndex = mainFrame.ZIndex
	UI._internal.originalTopBarZIndex = topBar.ZIndex

	-- Resize Handling (Update TabHolder width when sidebar ratio changes)
	table.insert(UI._connections, mainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if not UI._isMinimized then
			local sidebarWidth = sidebar.Size.X.Scale * mainFrame.AbsoluteSize.X
			tabHolder.Size = UDim2.new(0, mainFrame.AbsoluteSize.X - sidebarWidth, 1, 0)
			tabHolder.Position = UDim2.new(0, sidebarWidth, 0, 0)
		end
	end))


	return UI
end

--==============================================================================
-- UI Methods
--==============================================================================

function PurpleBotUI:Destroy()
	-- Disconnect all stored connections
	for _, conn in pairs(self._connections) do
		if conn and conn.Connected then
			conn:Disconnect()
		end
	end
	self._connections = {} -- Clear the table

	-- Destroy the main ScreenGui
	if self._internal.screenGui then
		self._internal.screenGui:Destroy()
		self._internal.screenGui = nil -- Allow garbage collection
	end

	-- Clean up potentially lingering tooltip
	if self._internal.tooltipFrame then
		self._internal.tooltipFrame:Destroy()
		self._internal.tooltipFrame = nil
	end

	-- Clean up potentially lingering notification
	if self._internal.notifyFrame then
		self._internal.notifyFrame:Destroy()
		self._internal.notifyFrame = nil
	end

	-- Nil out other references if needed
	self._internal = {}
	self.Tabs = {}
	self.CurrentTab = nil
end

function PurpleBotUI:MinimizeToggle()
	local mainFrame = self._internal.mainFrame
	local contentFrame = self._internal.contentFrame

	self._isMinimized = not self._isMinimized

	if self._isMinimized then
		-- Minimizing
		self._originalSize = mainFrame.Size -- Store current size before minimizing
		self._originalPosition = mainFrame.Position -- Store current position

		-- Determine minimized position (e.g., snap to a corner or keep X)
		local minimizedPosition = UDim2.new(
			self._originalPosition.X.Scale, self._originalPosition.X.Offset,
			self._originalPosition.Y.Scale, self._originalPosition.Y.Offset -- Or snap Y to top/bottom
		)
        local minimizedSize = UDim2.new(self._originalSize.X.Scale, self._originalSize.X.Offset, 0, self._internal.topBar.Size.Y.Offset) -- Only top bar height


		tween(contentFrame, fastTweenInfo, {Transparency = 1})
		tween(mainFrame, defaultTweenInfo, {Size = minimizedSize, Position = minimizedPosition}, function()
			contentFrame.Visible = false -- Hide content after animation
		end)
		-- Bring top bar elements slightly forward if needed
		mainFrame.ZIndex = 200
		self._internal.topBar.ZIndex = 201
	else
		-- Restoring
		contentFrame.Visible = true -- Show content immediately
		tween(contentFrame, fastTweenInfo, {Transparency = 0})
		tween(mainFrame, defaultTweenInfo, {Size = self._originalSize, Position = self._originalPosition})
		-- Restore ZIndex
		mainFrame.ZIndex = self._internal.originalMainFrameZIndex
		self._internal.topBar.ZIndex = self._internal.originalTopBarZIndex
	end
end

function PurpleBotUI:SetPosition(position: UDim2)
	if self._internal.mainFrame and not self._isMinimized then
		self._internal.mainFrame.Position = position
		self._originalPosition = position -- Update stored original position
	end
end

function PurpleBotUI:GetPosition()
	return self._internal.mainFrame and self._internal.mainFrame.Position or UDim2.new()
end

function PurpleBotUI:GetSize()
	return self._internal.mainFrame and self._internal.mainFrame.Size or UDim2.new()
end

function PurpleBotUI:SetTitle(title: string)
	if self._internal.titleLabel then
		self._internal.titleLabel.Text = title
	end
end

--==============================================================================
-- Tab Creation
--==============================================================================

function PurpleBotUI:CreateTab(tabOptions)
	tabOptions = tabOptions or {}
	local tabName = tabOptions.Name or "Tab " .. (#self.Tabs + 1)
	local tabTooltip = tabOptions.Tooltip or tabName

	local Tab = {
		_isActive = false,
		_internal = {},
		_elements = {}, -- Store elements created within this tab
		_uiRef = self, -- Reference back to the main UI object
		Name = tabName,
		_connections = {} -- Connections specific to this tab/its elements
	}
	setmetatable(Tab, {__index = PurpleBotUI}) -- Inherit PurpleBotUI methods if needed later

	-- // Tab Button in Sidebar \\ --
	local tabButton = Instance.new("TextButton")
	tabButton.Name = tabName
	tabButton.Size = UDim2.new(1, 0, 0, 35) -- Fixed height for tab buttons
	tabButton.BackgroundColor3 = Theme.Surface -- Match sidebar background
	tabButton.BackgroundTransparency = 1 -- Start transparent
	tabButton.Font = Theme.FontMedium.FontFace
	tabButton.Text = tabName
	tabButton.TextColor3 = Theme.TextSecondary
	tabButton.TextSize = 16
	tabButton.TextXAlignment = Enum.TextXAlignment.Left
	tabButton.AutoButtonColor = false -- Disable default button color changes
	tabButton.LayoutOrder = #self.Tabs + 1
	tabButton.Parent = self._internal.sidebar
	Tab._internal.button = tabButton

	local tabButtonCorner = Instance.new("UICorner", tabButton)
	tabButtonCorner.CornerRadius = Theme.SmallCornerRadius

	local tabButtonPadding = Instance.new("UIPadding", tabButton)
	tabButtonPadding.PaddingLeft = UDim.new(0, 10)

	-- Indicator for active tab (small bar on the left)
	local activeIndicator = Instance.new("Frame", tabButton)
	activeIndicator.Name = "ActiveIndicator"
	activeIndicator.Size = UDim2.new(0, 4, 0.7, 0) -- Thin bar
	activeIndicator.Position = UDim2.new(0, -tabButtonPadding.PaddingLeft.Offset, 0.5, 0) -- Position left, centered vertically
	activeIndicator.AnchorPoint = Vector2.new(1, 0.5)
	activeIndicator.BackgroundColor3 = Theme.Accent
	activeIndicator.BorderSizePixel = 0
	activeIndicator.Visible = false -- Hidden by default
	activeIndicator.ClipsDescendants = true
	Tab._internal.activeIndicator = activeIndicator

	local indicatorCorner = Instance.new("UICorner", activeIndicator)
	indicatorCorner.CornerRadius = UDim.new(1, 0) -- Pill shape

	-- // Tab Content Scrolling Frame \\ --
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = tabName .. "_Content"
	scrollingFrame.Size = UDim2.fromScale(1, 1)
	scrollingFrame.Position = UDim2.fromScale(0, 0)
	scrollingFrame.BackgroundTransparency = 1 -- Make parent TabHolder visible
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.CanvasSize = UDim2.fromScale(0, 0) -- Start with 0, will be updated by layout
	scrollingFrame.ScrollBarThickness = 6
	scrollingFrame.ScrollBarImageColor3 = Theme.Secondary
	scrollingFrame.Visible = false -- Hidden initially
	scrollingFrame.ClipsDescendants = true
	scrollingFrame.Parent = self._internal.tabHolder
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y -- Auto-adjust canvas height
	scrollingFrame.CanvasPosition = Vector2.new() -- Ensure it starts at the top
	Tab._internal.scrollingFrame = scrollingFrame

	local contentPadding = Instance.new("UIPadding", scrollingFrame)
	contentPadding.PaddingTop = Theme.DefaultPadding
	contentPadding.PaddingBottom = Theme.DefaultPadding
	contentPadding.PaddingLeft = Theme.DefaultPadding
	contentPadding.PaddingRight = Theme.DefaultPadding

	local listLayout = Instance.new("UIListLayout", scrollingFrame)
	listLayout.Padding = UDim.new(0, 8) -- Space between elements in the tab
	listLayout.FillDirection = Enum.FillDirection.Vertical
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center -- Center elements horizontally
	listLayout.SortOrder = (tabOptions.Alphabetical == true and Enum.SortOrder.Name) or Enum.SortOrder.LayoutOrder
	Tab._internal.listLayout = listLayout

	-- Tab Button Hover & Click Logic
	local function updateVisuals(isHovering)
		if Tab._isActive then
			tabButton.TextColor3 = Theme.TextPrimary
			tabButton.BackgroundTransparency = 0.85 -- Slightly visible background when active
			activeIndicator.Visible = true
		else
			tabButton.TextColor3 = isHovering and Theme.TextPrimary or Theme.TextSecondary
			tabButton.BackgroundTransparency = isHovering and 0.9 or 1
			activeIndicator.Visible = false
		end
	end

	table.insert(Tab._connections, tabButton.MouseEnter:Connect(function()
		updateVisuals(true)
		self._internal.showTooltip(tabTooltip, tabButton)
	end))
	table.insert(Tab._connections, tabButton.MouseLeave:Connect(function()
		updateVisuals(false)
		self._internal.hideTooltip(tabButton)
	end))

	table.insert(Tab._connections, tabButton.MouseButton1Click:Connect(function()
		self:SetActiveTab(Tab)
	end))

	-- Public Tab Methods
	function Tab:Activate()
		if self._isActive then return end
		self._isActive = true
		self._internal.scrollingFrame.Visible = true
		self._internal.scrollingFrame.CanvasPosition = Vector2.new() -- Reset scroll on activate
		updateVisuals(false) -- Update visuals based on new active state
		-- Optional: Tween indicator visibility/position
	end

	function Tab:Deactivate()
		if not self._isActive then return end
		self._isActive = false
		self._internal.scrollingFrame.Visible = false
		updateVisuals(false) -- Update visuals based on new active state
		-- Optional: Tween indicator visibility/position
	end

	function Tab:IsActive()
		return self._isActive
	end

	function Tab:SetText(text)
		self.Name = text
		self._internal.button.Text = text
		self._internal.button.Name = text -- Keep name consistent if used for sorting
		self._internal.scrollingFrame.Name = text .. "_Content"
	end

	function Tab:Destroy()
		-- Disconnect tab-specific connections
		for _, conn in ipairs(Tab._connections) do
			if conn.Connected then conn:Disconnect() end
		end
		Tab._connections = {}

		-- Destroy elements within the tab
		for name, elementData in pairs(Tab._elements) do
			if elementData and elementData.Destroy then
				elementData:Destroy() -- Assuming elements have a Destroy method
			elseif elementData.Instance and typeof(elementData.Instance) == "Instance" then
				elementData.Instance:Destroy() -- Fallback for simple instance references
			end
		end
		Tab._elements = {}

		-- Destroy tab UI elements
		if Tab._internal.button then Tab._internal.button:Destroy() end
		if Tab._internal.scrollingFrame then Tab._internal.scrollingFrame:Destroy() end
		Tab._internal = {}

		-- Remove from main UI's list
		for i, t in ipairs(self.Tabs) do
			if t == Tab then
				table.remove(self.Tabs, i)
				break
			end
		end

		-- If the destroyed tab was active, select the first available tab
		if self.CurrentTab == Tab then
			self.CurrentTab = nil
			if #self.Tabs > 0 then
				self:SetActiveTab(self.Tabs[1])
			end
		end
	end

	-- Add Tab to the UI list
	table.insert(self.Tabs, Tab)

	-- Activate the first tab automatically
	if not self.CurrentTab then
		self:SetActiveTab(Tab)
	end

	-- Add Component Creation Methods to the Tab object
	self:_AddElementCreationMethods(Tab)

	return Tab
end

function PurpleBotUI:SetActiveTab(tabToActivate)
	if not tabToActivate or self.CurrentTab == tabToActivate then return end

	if self.CurrentTab then
		self.CurrentTab:Deactivate()
	end

	self.CurrentTab = tabToActivate
	self.CurrentTab:Activate()
end

-- Helper to add component methods to Tab objects
function PurpleBotUI:_AddElementCreationMethods(tabInstance)
	local componentFuncs = {
		"Button", "Toggle", "Slider", "Dropdown", "TextBox",
		"BindKey", "BindButton", "Label", "Divider", "Info", "Warning", "Message", "Drawing" -- Added more
	}
	for _, funcName in ipairs(componentFuncs) do
		if self["Create" .. funcName] then -- Check if the creation function exists on PurpleBotUI
			tabInstance[funcName] = function(tabSelf, options)
				-- Call the main creation function, passing the tab's internal scrolling frame as parent
				local element = self["Create" .. funcName](tabSelf._uiRef, tabSelf._internal.scrollingFrame, options or {})
				if element then
					-- Store element reference in the tab
					local elementName = options and options.Name or (funcName .. "_" .. (#tabSelf._elements + 1))
					tabSelf._elements[elementName] = element
					-- Set LayoutOrder if the element has an instance
					if element.Instance and element.Instance:IsA("GuiObject") then
						element.Instance.LayoutOrder = #tabSelf._internal.scrollingFrame:GetChildren()
					end
				end
				return element
			end
		end
	end
end


--==============================================================================
-- Element/Component Creation Methods (Attached to PurpleBotUI)
-- These functions now take the parent GuiObject (usually a scrolling frame)
--==============================================================================

-- // Label \\ --
function PurpleBotUI:CreateLabel(uiRef, parent, options)
	local label = Instance.new("TextLabel", parent)
	label.Name = options.Name or "Label"
	label.Size = UDim2.new(0.9, 0, 0, 20) -- Default size, AutomaticSize Y preferred
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.BackgroundTransparency = 1
	label.Font = options.Font or Theme.FontRegular.FontFace
	label.TextColor3 = options.Color or Theme.TextPrimary
	label.TextSize = options.TextSize or 16
	label.TextWrapped = true
	label.TextXAlignment = options.Alignment or Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.VerticalAlignment.Top
	label.Text = options.Text or "Label Text"

	local LabelAPI = { Instance = label }
	function LabelAPI:SetText(text) label.Text = text end
	function LabelAPI:SetColor(color) label.TextColor3 = color end
	function LabelAPI:SetVisible(visible) label.Visible = visible end
	function LabelAPI:Destroy() label:Destroy() end

	return LabelAPI
end

-- // Divider \\ --
function PurpleBotUI:CreateDivider(uiRef, parent, options)
	local divider = Instance.new("Frame", parent)
	divider.Name = options.Name or "Divider"
	divider.Size = UDim2.new(0.9, 0, 0, 2) -- Thin line
	divider.BackgroundColor3 = options.Color or Theme.Border
	divider.BorderSizePixel = 0

	local DividerAPI = { Instance = divider }
	function DividerAPI:SetColor(color) divider.BackgroundColor3 = color end
	function DividerAPI:SetVisible(visible) divider.Visible = visible end
	function DividerAPI:Destroy() divider:Destroy() end

	return DividerAPI
end

-- // Message Boxes (Info, Warning, Message/Default) \\ --
local function CreateMessageBoxBase(uiRef, parent, options, boxType)
	local bgColor, strokeColor, defaultText
	if boxType == "Info" then
		bgColor = Theme.Info
		strokeColor = Color3.fromRGB(80, 180, 250) -- Lighter info for stroke
		defaultText = "Information"
	elseif boxType == "Warning" then
		bgColor = Theme.Warning
		strokeColor = Color3.fromRGB(255, 200, 50) -- Lighter warning for stroke
		defaultText = "Warning"
	else -- Message (Default)
		boxType = "Message"
		bgColor = Theme.Surface
		strokeColor = Theme.Border
		defaultText = "Message"
	end

	local frame = Instance.new("Frame", parent)
	frame.Name = options.Name or boxType
	frame.Size = UDim2.new(0.9, 0, 0, 30) -- Automatic Y below
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.BackgroundColor3 = bgColor
	frame.BackgroundTransparency = 0.85 -- Make them slightly transparent
	frame.BorderSizePixel = 0

	local corner = Instance.new("UICorner", frame)
	corner.CornerRadius = Theme.SmallCornerRadius

	local stroke = Instance.new("UIStroke", frame)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = strokeColor
	stroke.Thickness = Theme.BorderThickness

	local padding = Instance.new("UIPadding", frame)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 8)

	local textLabel = Instance.new("TextLabel", frame)
	textLabel.Name = "Title"
	textLabel.Size = UDim2.fromScale(1, 1) -- Fill padded area
	textLabel.AutomaticSize = Enum.AutomaticSize.Y
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Theme.FontRegular.FontFace
	textLabel.TextColor3 = Theme.TextOnPrimary -- Assuming dark backgrounds for these boxes
	textLabel.TextSize = 14
	textLabel.TextWrapped = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.VerticalAlignment.Top
	textLabel.Text = options.Text or defaultText

	local MessageAPI = { Instance = frame }
	function MessageAPI:SetText(text) textLabel.Text = text end
	function MessageAPI:SetVisible(visible) frame.Visible = visible end
	function MessageAPI:Destroy() frame:Destroy() end

	return MessageAPI
end

function PurpleBotUI:CreateInfo(uiRef, parent, options)
	return CreateMessageBoxBase(uiRef, parent, options, "Info")
end

function PurpleBotUI:CreateWarning(uiRef, parent, options)
	return CreateMessageBoxBase(uiRef, parent, options, "Warning")
end

function PurpleBotUI:CreateMessage(uiRef, parent, options)
	return CreateMessageBoxBase(uiRef, parent, options, "Message")
end


-- // Button \\ --
function PurpleBotUI:CreateButton(uiRef, parent, options)
	options.Size = options.Size or UDim2.new(0.9, 0, 0, 35)

	local buttonFrame = Instance.new("TextButton", parent)
	buttonFrame.Name = options.Name or "Button"
	buttonFrame.Size = options.Size
	buttonFrame.BackgroundColor3 = options.Color or Theme.Surface
	buttonFrame.BorderSizePixel = 0
	buttonFrame.AutoButtonColor = false
	buttonFrame.Text = "" -- Clear TextButton text

	local corner = Instance.new("UICorner", buttonFrame)
	corner.CornerRadius = Theme.SmallCornerRadius

	local stroke = Instance.new("UIStroke", buttonFrame)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Theme.Border
	stroke.Thickness = Theme.BorderThickness
	stroke.Enabled = true -- Default stroke visibility

	local padding = Instance.new("UIPadding", buttonFrame)
	padding.PaddingLeft = Theme.ElementPadding
	padding.PaddingRight = Theme.ElementPadding

	local titleLabel = Instance.new("TextLabel", buttonFrame)
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -(options.Icon and 30 or 0), 1, 0) -- Adjust for icon
	titleLabel.Position = UDim2.fromScale(0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Theme.FontMedium.FontFace
	titleLabel.TextColor3 = Theme.TextPrimary
	titleLabel.TextSize = 16
	titleLabel.TextWrapped = true
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextYAlignment = Enum.VerticalAlignment.Center
	titleLabel.Text = options.ButtonText or "Button"

	local iconImage = nil
	if options.Icon then
		iconImage = Instance.new("ImageLabel", buttonFrame)
		iconImage.Name = "Icon"
		iconImage.Size = UDim2.new(0, 20, 0, 20)
		iconImage.Position = UDim2.new(1, -Theme.ElementPadding.Offset - 10, 0.5, -10) -- Position right, centered Y
		iconImage.AnchorPoint = Vector2.new(1, 0.5)
		iconImage.BackgroundTransparency = 1
		iconImage.Image = options.Icon
		iconImage.ImageColor3 = Theme.TextSecondary -- Default icon color
		iconImage.ScaleType = Enum.ScaleType.Fit
	end

	local ButtonAPI = {
		Instance = buttonFrame,
		_isOn = false, -- For toggle-like behavior if needed
		_callback = options.Pressed
	}

	local defaultColor = buttonFrame.BackgroundColor3
	local hoverColor = Theme.Accent
	setupHoverEffect(buttonFrame, {BackgroundColor3 = hoverColor}, {BackgroundColor3 = defaultColor}, function() return not ButtonAPI._isOn end)
	if iconImage then
		setupHoverEffect(buttonFrame, {ImageColor3 = Theme.TextOnAccent}, {ImageColor3 = Theme.TextSecondary}, function() return not ButtonAPI._isOn end)
	end

	table.insert(uiRef._connections, buttonFrame.MouseButton1Click:Connect(function()
		if ButtonAPI._callback then
			ButtonAPI._callback() -- Execute the callback
		end
		-- Optional: Add click feedback (e.g., brief color change)
		local originalColor = buttonFrame.BackgroundColor3
		buttonFrame.BackgroundColor3 = Theme.Primary
		tween(buttonFrame, fastTweenInfo, {BackgroundColor3 = originalColor})
	end))

	function ButtonAPI:SetText(text) titleLabel.Text = text end
	function ButtonAPI:SetCallback(callback) ButtonAPI._callback = callback end
	function ButtonAPI:SetVisible(visible) buttonFrame.Visible = visible end
	function ButtonAPI:Destroy() buttonFrame:Destroy() end
	-- Add Toggle-like functionality if desired (like the original)
	function ButtonAPI:IsOn() return ButtonAPI._isOn end
	function ButtonAPI:Toggle(forceState)
		ButtonAPI._isOn = (forceState == nil) and not ButtonAPI._isOn or forceState
		if ButtonAPI._isOn then
			stroke.Color = Theme.Success -- Use success color for "on" state
			stroke.Thickness = Theme.BorderThickness + 1
			buttonFrame.BackgroundColor3 = Color3.Lerp(defaultColor, Theme.Success, 0.1) -- Tint background
			if iconImage then iconImage.ImageColor3 = Theme.Success end
		else
			stroke.Color = Theme.Border
			stroke.Thickness = Theme.BorderThickness
			buttonFrame.BackgroundColor3 = defaultColor
			if iconImage then iconImage.ImageColor3 = Theme.TextSecondary end
		end
	end

	return ButtonAPI
end


-- // Toggle \\ --
function PurpleBotUI:CreateToggle(uiRef, parent, options)
	options.Size = options.Size or UDim2.new(0.9, 0, 0, 35)
	options.Toggled = options.Toggled == true -- Default to false

	local toggleFrame = Instance.new("TextButton", parent) -- Use TextButton for easy click detection
	toggleFrame.Name = options.Name or "Toggle"
	toggleFrame.Size = options.Size
	toggleFrame.BackgroundColor3 = options.Color or Theme.Surface
	toggleFrame.BorderSizePixel = 0
	toggleFrame.AutoButtonColor = false
	toggleFrame.Text = ""

	local corner = Instance.new("UICorner", toggleFrame)
	corner.CornerRadius = Theme.SmallCornerRadius

	local stroke = Instance.new("UIStroke", toggleFrame)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Theme.Border
	stroke.Thickness = Theme.BorderThickness

	local padding = Instance.new("UIPadding", toggleFrame)
	padding.PaddingLeft = Theme.ElementPadding
	padding.PaddingRight = Theme.ElementPadding

	local titleLabel = Instance.new("TextLabel", toggleFrame)
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -45, 1, 0) -- Leave space for the switch
	titleLabel.Position = UDim2.fromScale(0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Theme.FontRegular.FontFace
	titleLabel.TextColor3 = Theme.TextPrimary
	titleLabel.TextSize = 16
	titleLabel.TextWrapped = true
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextYAlignment = Enum.VerticalAlignment.Center
	titleLabel.Text = options.Text or "Toggle"

	-- Switch Element
	local switchTrack = Instance.new("Frame", toggleFrame)
	switchTrack.Name = "SwitchTrack"
	switchTrack.Size = UDim2.new(0, 36, 0, 20) -- Size of the switch track
	switchTrack.Position = UDim2.new(1, -Theme.ElementPadding.Offset - 18, 0.5, -10) -- Position right, centered Y
	switchTrack.AnchorPoint = Vector2.new(1, 0.5)
	switchTrack.BackgroundColor3 = Theme.Border -- Off color
	switchTrack.BorderSizePixel = 0

	local trackCorner = Instance.new("UICorner", switchTrack)
	trackCorner.CornerRadius = UDim.new(1, 0) -- Pill shape

	local switchThumb = Instance.new("Frame", switchTrack)
	switchThumb.Name = "SwitchThumb"
	switchThumb.Size = UDim2.new(0, 16, 0, 16) -- Slightly smaller than track height
	switchThumb.Position = UDim2.new(0, 2, 0.5, -8) -- Initial position (left)
	switchThumb.AnchorPoint = Vector2.new(0, 0.5)
	switchThumb.BackgroundColor3 = Theme.TextPrimary -- Thumb color
	switchThumb.BorderSizePixel = 0

	local thumbCorner = Instance.new("UICorner", switchThumb)
	thumbCorner.CornerRadius = UDim.new(1, 0) -- Circle shape

	local ToggleAPI = {
		Instance = toggleFrame,
		_isToggled = options.Toggled,
		_callback = options.ChangedCallback,
		_isLocked = false
	}

	local function updateToggleVisuals(animate)
		local targetTrackColor = ToggleAPI._isToggled and Theme.Success or Theme.Border
		local targetThumbPos = ToggleAPI._isToggled and UDim2.new(1, -2, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
		local targetThumbAnchor = ToggleAPI._isToggled and Vector2.new(1, 0.5) or Vector2.new(0, 0.5)

		if animate then
			tween(switchTrack, fastTweenInfo, {BackgroundColor3 = targetTrackColor})
			tween(switchThumb, fastTweenInfo, {Position = targetThumbPos, AnchorPoint = targetThumbAnchor})
		else
			switchTrack.BackgroundColor3 = targetTrackColor
			switchThumb.Position = targetThumbPos
			switchThumb.AnchorPoint = targetThumbAnchor
		end
	end

	-- Initialize visual state
	updateToggleVisuals(false)

	-- Click Logic
	table.insert(uiRef._connections, toggleFrame.MouseButton1Click:Connect(function()
		if ToggleAPI._isLocked then return end
		ToggleAPI._isToggled = not ToggleAPI._isToggled
		updateToggleVisuals(true)
		if ToggleAPI._callback then
			ToggleAPI._callback(ToggleAPI._isToggled) -- Pass the new state to the callback
		end
	end))

	function ToggleAPI:IsToggled() return ToggleAPI._isToggled end
	function ToggleAPI:SetCallback(callback) ToggleAPI._callback = callback end
	function ToggleAPI:Toggle(forceState, suppressCallback)
		if ToggleAPI._isLocked then return end
		local newState = (forceState == nil) and not ToggleAPI._isToggled or forceState
		if newState ~= ToggleAPI._isToggled then
			ToggleAPI._isToggled = newState
			updateToggleVisuals(true)
			if ToggleAPI._callback and not suppressCallback then
				ToggleAPI._callback(ToggleAPI._isToggled)
			end
		end
	end
	function ToggleAPI:Lock() ToggleAPI._isLocked = true end
	function ToggleAPI:Unlock() ToggleAPI._isLocked = false end
	function ToggleAPI:IsLocked() return ToggleAPI._isLocked end
	function ToggleAPI:SetVisible(visible) toggleFrame.Visible = visible end
	function ToggleAPI:Destroy() toggleFrame:Destroy() end

	return ToggleAPI
end

-- // Slider \\ --
function PurpleBotUI:CreateSlider(uiRef, parent, options)
	options.Min = options.Min or 0
	options.Max = options.Max or 100
	options.Default = options.Default or options.Min
	options.Decimals = options.Decimals or 0
	options.Text = options.Text or "Slider"

	local sliderFrame = Instance.new("Frame", parent)
	sliderFrame.Name = options.Name or options.Text
	sliderFrame.Size = UDim2.new(0.9, 0, 0, 60) -- Taller for better interaction
	sliderFrame.BackgroundColor3 = options.Color or Theme.Surface
	sliderFrame.BorderSizePixel = 0

	local corner = Instance.new("UICorner", sliderFrame)
	corner.CornerRadius = Theme.SmallCornerRadius

	local stroke = Instance.new("UIStroke", sliderFrame)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Theme.Border
	stroke.Thickness = Theme.BorderThickness

	local padding = Instance.new("UIPadding", sliderFrame)
	padding.PaddingLeft = Theme.ElementPadding
	padding.PaddingRight = Theme.ElementPadding
	padding.PaddingTop = UDim.new(0, 5)
	padding.PaddingBottom = UDim.new(0, 5)

	local topRow = Instance.new("Frame", sliderFrame) -- Frame for Title and Value
	topRow.Name = "TopRow"
	topRow.Size = UDim2.new(1, 0, 0.4, 0)
	topRow.BackgroundTransparency = 1

	local topRowLayout = Instance.new("UIListLayout", topRow)
	topRowLayout.FillDirection = Enum.FillDirection.Horizontal
	topRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	local titleLabel = Instance.new("TextLabel", topRow)
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(0.7, 0, 1, 0) -- Adjust width as needed
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Theme.FontRegular.FontFace
	titleLabel.TextColor3 = Theme.TextPrimary
	titleLabel.TextSize = 16
	titleLabel.TextWrapped = true
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = options.Text

	local valueBox = Instance.new("TextBox", topRow)
	valueBox.Name = "ValueBox"
	valueBox.Size = UDim2.new(0.3, -10, 1, -4) -- Adjust width, slightly smaller height
	valueBox.BackgroundColor3 = Theme.Background -- Darker background for input
	valueBox.Font = Theme.FontRegular.FontFace
	valueBox.TextColor3 = Theme.TextPrimary
	valueBox.TextSize = 14
	valueBox.TextXAlignment = Enum.TextXAlignment.Right
	valueBox.ClearTextOnFocus = false
	valueBox.NumbersOnly = true -- Allow only numbers

	local valueCorner = Instance.new("UICorner", valueBox)
	valueCorner.CornerRadius = Theme.SmallCornerRadius
	local valuePadding = Instance.new("UIPadding", valueBox)
	valuePadding.PaddingRight = UDim.new(0, 5)

	-- Slider Track Area
	local trackFrame = Instance.new("Frame", sliderFrame)
	trackFrame.Name = "TrackFrame"
	trackFrame.Size = UDim2.new(1, 0, 0.6, -10) -- Fill remaining space, slight bottom padding
	trackFrame.Position = UDim2.new(0, 0, 0.4, 5)
	trackFrame.BackgroundTransparency = 1

	local trackBackground = Instance.new("Frame", trackFrame)
	trackBackground.Name = "TrackBackground"
	trackBackground.Size = UDim2.new(1, 0, 0, 6) -- Thin track
	trackBackground.Position = UDim2.fromScale(0.5, 0.5)
	trackBackground.AnchorPoint = Vector2.new(0.5, 0.5)
	trackBackground.BackgroundColor3 = Theme.Border
	trackBackground.BorderSizePixel = 0

	local trackBgCorner = Instance.new("UICorner", trackBackground)
	trackBgCorner.CornerRadius = UDim.new(1, 0)

	local trackFill = Instance.new("Frame", trackBackground)
	trackFill.Name = "TrackFill"
	trackFill.Size = UDim2.fromScale(0.5, 1) -- Starts at default value %
	trackFill.BackgroundColor3 = Theme.Secondary -- Use accent color for fill
	trackFill.BorderSizePixel = 0

	local trackFillCorner = Instance.new("UICorner", trackFill)
	trackFillCorner.CornerRadius = UDim.new(1, 0)

	-- Invisible Button for dragging
	local dragButton = Instance.new("TextButton", trackFrame)
	dragButton.Name = "DragButton"
	dragButton.Size = UDim2.new(1, 0, 1, 10) -- Make it slightly larger than track for easier clicking
	dragButton.Position = UDim2.fromScale(0.5, 0.5)
	dragButton.AnchorPoint = Vector2.new(0.5, 0.5)
	dragButton.BackgroundTransparency = 1
	dragButton.Text = ""
	dragButton.ZIndex = 2 -- Above track visuals

	local SliderAPI = {
		Instance = sliderFrame,
		_value = options.Default,
		_callback = options.Callback,
		_decimals = 10 ^ options.Decimals,
		_isDragging = false,
		Min = options.Min,
		Max = options.Max
	}

	local function calculateValueFromPosition(xPos)
		local relativeX = xPos - trackBackground.AbsolutePosition.X
		local percentage = math.clamp(relativeX / trackBackground.AbsoluteSize.X, 0, 1)
		local rawValue = ((SliderAPI.Max - SliderAPI.Min) * percentage) + SliderAPI.Min
		local roundedValue = math.floor(rawValue * SliderAPI._decimals + 0.5) / SliderAPI._decimals
		return math.clamp(roundedValue, SliderAPI.Min, SliderAPI.Max)
	end

	local function updateSliderVisuals(value, animate)
		SliderAPI._value = value
		local percentage = (value - SliderAPI.Min) / (SliderAPI.Max - SliderAPI.Min)
		percentage = math.clamp(percentage, 0, 1) -- Ensure percentage is valid

		local fillSize = UDim2.fromScale(percentage, 1)
		local formatString = "%." .. options.Decimals .. "f"
		local formattedValue = string.format(formatString, value)

		if valueBox.Text ~= formattedValue then -- Avoid recursive updates from text input
			valueBox.Text = formattedValue
		end

		if animate then
			tween(trackFill, fastTweenInfo, {Size = fillSize})
		else
			trackFill.Size = fillSize
		end
	end

	-- Initialize
	updateSliderVisuals(SliderAPI._value, false)

	-- Drag Logic
	table.insert(uiRef._connections, dragButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			SliderAPI._isDragging = true
			local newValue = calculateValueFromPosition(input.Position.X)
			updateSliderVisuals(newValue, true) -- Animate initial click position
			if SliderAPI._callback then SliderAPI._callback(newValue) end
			-- Optional: Capture mouse focus
		end
	end))

	table.insert(uiRef._connections, UserInputService.InputChanged:Connect(function(input)
		if SliderAPI._isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local newValue = calculateValueFromPosition(input.Position.X)
			updateSliderVisuals(newValue, false) -- No animation during drag
			if SliderAPI._callback then SliderAPI._callback(newValue) end
		end
	end))

	table.insert(uiRef._connections, UserInputService.InputEnded:Connect(function(input)
		if SliderAPI._isDragging and input.UserInputType == Enum.UserInputType.MouseButton1 then
			SliderAPI._isDragging = false
			-- Optional: Release mouse focus
			-- Final callback trigger might be redundant if done during InputChanged
		end
	end))

	-- Text Input Logic
	table.insert(uiRef._connections, valueBox.FocusLost:Connect(function(enterPressed)
		local num = tonumber(valueBox.Text)
		if num ~= nil then
			local clampedValue = math.clamp(num, SliderAPI.Min, SliderAPI.Max)
			if clampedValue ~= SliderAPI._value then
				updateSliderVisuals(clampedValue, true) -- Animate change from text input
				if SliderAPI._callback then SliderAPI._callback(clampedValue) end
			else
				-- If the value didn't change but text format might have, update text
				updateSliderVisuals(clampedValue, false)
			end
		else
			-- Invalid input, revert to current value
			updateSliderVisuals(SliderAPI._value, false)
		end
	end))


	function SliderAPI:GetValue() return SliderAPI._value end
	function SliderAPI:SetValue(value, suppressCallback)
		local clampedValue = math.clamp(value, SliderAPI.Min, SliderAPI.Max)
		if clampedValue ~= SliderAPI._value then
			updateSliderVisuals(clampedValue, true)
			if SliderAPI._callback and not suppressCallback then
				SliderAPI._callback(clampedValue)
			end
		end
	end
	function SliderAPI:SetCallback(callback) SliderAPI._callback = callback end
	function SliderAPI:SetVisible(visible) sliderFrame.Visible = visible end
	function SliderAPI:Destroy() sliderFrame:Destroy() end

	return SliderAPI
end

-- // Dropdown \\ --
function PurpleBotUI:CreateDropdown(uiRef, parent, options)
	options.Options = options.Options or {}
	options.Default = options.Default or (options.Options[1] or nil) -- Select first option if available
	options.Name = options.Name or "Dropdown"

	local dropdownHeight = 35
	local dropdownOpenHeight = 150 -- Max open height

	local dropdownFrame = Instance.new("Frame", parent)
	dropdownFrame.Name = options.Name
	dropdownFrame.Size = UDim2.new(0.9, 0, 0, dropdownHeight) -- Closed height
	dropdownFrame.BackgroundColor3 = Theme.Surface
	dropdownFrame.BorderSizePixel = 0
	dropdownFrame.ClipsDescendants = true -- Crucial for hiding options
	dropdownFrame.ZIndex = 5 -- Default, increase when open

	local corner = Instance.new("UICorner", dropdownFrame)
	corner.CornerRadius = Theme.SmallCornerRadius

	local stroke = Instance.new("UIStroke", dropdownFrame)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Theme.Border
	stroke.Thickness = Theme.BorderThickness

	local mainButton = Instance.new("TextButton", dropdownFrame) -- Button to show current selection & toggle
	mainButton.Name = "MainButton"
	mainButton.Size = UDim2.new(1, 0, 0, dropdownHeight)
	mainButton.BackgroundColor3 = Theme.Surface
	mainButton.BorderSizePixel = 0
	mainButton.AutoButtonColor = false
	mainButton.Text = "" -- Handled by selectedLabel

	local mainPadding = Instance.new("UIPadding", mainButton)
	mainPadding.PaddingLeft = Theme.ElementPadding
	mainPadding.PaddingRight = Theme.ElementPadding

	local selectedLabel = Instance.new("TextLabel", mainButton)
	selectedLabel.Name = "SelectedLabel"
	selectedLabel.Size = UDim2.new(1, -30, 1, 0) -- Leave space for arrow
	selectedLabel.BackgroundTransparency = 1
	selectedLabel.Font = Theme.FontRegular.FontFace
	selectedLabel.TextColor3 = Theme.TextPrimary
	selectedLabel.TextSize = 16
	selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
	selectedLabel.Text = options.Default or "Select..." -- Show default or placeholder

	local arrowIcon = Instance.new("ImageLabel", mainButton)
	arrowIcon.Name = "ArrowIcon"
	arrowIcon.Size = UDim2.new(0, 16, 0, 16)
	arrowIcon.Position = UDim2.new(1, -Theme.ElementPadding.Offset, 0.5, 0)
	arrowIcon.AnchorPoint = Vector2.new(1, 0.5)
	arrowIcon.BackgroundTransparency = 1
	arrowIcon.Image = "rbxassetid://3926306388" -- Chevron Down Icon
	arrowIcon.ImageColor3 = Theme.TextSecondary
	arrowIcon.ScaleType = Enum.ScaleType.Fit
	arrowIcon.Rotation = 0 -- Start pointing down

	-- Options Scrolling Frame (Initially below and hidden)
	local optionsScroll = Instance.new("ScrollingFrame", dropdownFrame)
	optionsScroll.Name = "OptionsScroll"
	optionsScroll.Size = UDim2.new(1, 0, 0, dropdownOpenHeight - dropdownHeight) -- Height available when open
	optionsScroll.Position = UDim2.new(0, 0, 0, dropdownHeight) -- Positioned below the main button
	optionsScroll.BackgroundColor3 = Theme.Surface
	optionsScroll.BorderSizePixel = 0
	optionsScroll.BorderMode = Enum.BorderMode.Inset -- Helps with clean edges
	optionsScroll.TopImage = "" -- Clean up scrollbar visuals if needed
	optionsScroll.BottomImage = ""
	optionsScroll.CanvasSize = UDim2.new()
	optionsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	optionsScroll.ScrollBarThickness = 4
	optionsScroll.ScrollBarImageColor3 = Theme.Secondary
	optionsScroll.Visible = false -- Start hidden
	optionsScroll.ZIndex = dropdownFrame.ZIndex - 1 -- Behind main button but inside frame

	local optionsPadding = Instance.new("UIPadding", optionsScroll)
	optionsPadding.PaddingTop = UDim.new(0, 4)
	optionsPadding.PaddingBottom = UDim.new(0, 4)

	local optionsLayout = Instance.new("UIListLayout", optionsScroll)
	optionsLayout.Padding = UDim.new(0, 2)
	optionsLayout.FillDirection = Enum.FillDirection.Vertical
	optionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local DropdownAPI = {
		Instance = dropdownFrame,
		_selected = options.Default,
		_isOpen = false,
		_callback = options.Callback,
		_optionButtons = {} -- Store references to the option buttons
	}

	local function openDropdown()
		if DropdownAPI._isOpen then return end
		DropdownAPI._isOpen = true
		dropdownFrame.ZIndex = 10 -- Bring to front
		optionsScroll.Visible = true
		optionsScroll.CanvasPosition = Vector2.new() -- Reset scroll
		tween(dropdownFrame, fastTweenInfo, {Size = UDim2.new(dropdownFrame.Size.X.Scale, dropdownFrame.Size.X.Offset, 0, dropdownOpenHeight)})
		tween(arrowIcon, fastTweenInfo, {Rotation = -180}) -- Point up
	end

	local function closeDropdown()
		if not DropdownAPI._isOpen then return end
		DropdownAPI._isOpen = false
		tween(dropdownFrame, fastTweenInfo, {Size = UDim2.new(dropdownFrame.Size.X.Scale, dropdownFrame.Size.X.Offset, 0, dropdownHeight)}, function()
			if not DropdownAPI._isOpen then -- Check again in case it reopened quickly
				optionsScroll.Visible = false
				dropdownFrame.ZIndex = 5 -- Restore default ZIndex
			end
		end)
		tween(arrowIcon, fastTweenInfo, {Rotation = 0}) -- Point down
	end

	-- Toggle on main button click
	table.insert(uiRef._connections, mainButton.MouseButton1Click:Connect(function()
		if DropdownAPI._isOpen then
			closeDropdown()
		else
			openDropdown()
		end
	end))

	-- Close when clicking outside (handle focus loss)
	-- This requires careful implementation, potentially checking mouse clicks elsewhere.
	-- A simpler approach: close when the mouse leaves the extended dropdown area.
	table.insert(uiRef._connections, dropdownFrame.MouseLeave:Connect(function()
		-- Add a small delay to allow moving mouse onto options
		task.delay(0.1, function()
			local mousePos = UserInputService:GetMouseLocation()
			local framePos = dropdownFrame.AbsolutePosition
			local frameSize = dropdownFrame.AbsoluteSize
			-- Check if mouse is outside the potentially open dropdown bounds
			if not (mousePos.X >= framePos.X and mousePos.X <= framePos.X + frameSize.X and
			        mousePos.Y >= framePos.Y and mousePos.Y <= framePos.Y + frameSize.Y) then
				closeDropdown()
			end
		end)
	end))

	-- Function to add options
	function DropdownAPI:AddOption(optionText)
		local optionButton = Instance.new("TextButton", optionsScroll)
		optionButton.Name = optionText
		optionButton.Size = UDim2.new(1, -8, 0, 28) -- Slightly inset, fixed height
		optionButton.BackgroundColor3 = Theme.Surface
		optionButton.BackgroundTransparency = 1
		optionButton.Font = Theme.FontRegular.FontFace
		optionButton.TextColor3 = Theme.TextSecondary
		optionButton.TextSize = 14
		optionButton.TextXAlignment = Enum.TextXAlignment.Left
		optionButton.Text = optionText
		optionButton.AutoButtonColor = false
		optionButton.LayoutOrder = #optionsScroll:GetChildren()

		local optPadding = Instance.new("UIPadding", optionButton)
		optPadding.PaddingLeft = UDim.new(0, 8)

		DropdownAPI._optionButtons[optionText] = optionButton

		-- Highlight selected option
		local function updateHighlight()
			if DropdownAPI._selected == optionText then
				optionButton.TextColor3 = Theme.TextPrimary
				optionButton.BackgroundTransparency = 0.9
			else
				optionButton.TextColor3 = Theme.TextSecondary
				optionButton.BackgroundTransparency = 1
			end
		end
		updateHighlight() -- Initial highlight

		setupHoverEffect(optionButton, {BackgroundTransparency = 0.85}, {BackgroundTransparency = (DropdownAPI._selected == optionText) and 0.9 or 1})

		table.insert(uiRef._connections, optionButton.MouseButton1Click:Connect(function()
			DropdownAPI:Select(optionText) -- Select this option
			closeDropdown()
		end))

		-- Update highlights when selection changes externally
		-- (Requires a signal/event system or manual calls)
	end

	-- Populate initial options
	for _, opt in ipairs(options.Options) do
		DropdownAPI:AddOption(opt)
	end

	function DropdownAPI:Select(optionText, suppressCallback)
		if DropdownAPI._optionButtons[optionText] and DropdownAPI._selected ~= optionText then
			local previousSelection = DropdownAPI._selected
			DropdownAPI._selected = optionText
			selectedLabel.Text = optionText

			-- Update highlights for previous and new selection
			if previousSelection and DropdownAPI._optionButtons[previousSelection] then
				DropdownAPI._optionButtons[previousSelection].TextColor3 = Theme.TextSecondary
				DropdownAPI._optionButtons[previousSelection].BackgroundTransparency = 1
			end
			DropdownAPI._optionButtons[optionText].TextColor3 = Theme.TextPrimary
			DropdownAPI._optionButtons[optionText].BackgroundTransparency = 0.9


			if DropdownAPI._callback and not suppressCallback then
				DropdownAPI._callback(DropdownAPI._selected)
			end
		end
	end

	function DropdownAPI:ClearOptions()
		for _, btn in pairs(DropdownAPI._optionButtons) do
			btn:Destroy()
		end
		DropdownAPI._optionButtons = {}
		DropdownAPI._selected = nil
		selectedLabel.Text = "Select..." -- Reset label
	end

	function DropdownAPI:GetOption() return DropdownAPI._selected end
	function DropdownAPI:SetCallback(callback) DropdownAPI._callback = callback end
	function DropdownAPI:SetVisible(visible) dropdownFrame.Visible = visible end
	function DropdownAPI:Destroy() dropdownFrame:Destroy() end

	-- Select default if provided
	if options.Default and options.Default ~= "" then
		DropdownAPI:Select(options.Default, true) -- Suppress callback on initial setup
	end

	return DropdownAPI
end

-- // TextBox \\ --
function PurpleBotUI:CreateTextBox(uiRef, parent, options)
	options.PlaceholderText = options.PlaceholderText or "Enter text..."
	options.Text = options.Text or ""
	options.ClearOnFocus = options.ClearOnFocus == true

	local textBoxFrame = Instance.new("Frame", parent)
	textBoxFrame.Name = options.Name or "TextBoxFrame"
	textBoxFrame.Size = UDim2.new(0.9, 0, 0, 50) -- Taller for title + input
	textBoxFrame.BackgroundColor3 = options.Color or Theme.Surface
	textBoxFrame.BorderSizePixel = 0

	local corner = Instance.new("UICorner", textBoxFrame)
	corner.CornerRadius = Theme.SmallCornerRadius

	local stroke = Instance.new("UIStroke", textBoxFrame)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Theme.Border
	stroke.Thickness = Theme.BorderThickness

	local padding = Instance.new("UIPadding", textBoxFrame)
	padding.PaddingLeft = Theme.ElementPadding
	padding.PaddingRight = Theme.ElementPadding
	padding.PaddingTop = UDim.new(0, 5)
	padding.PaddingBottom = UDim.new(0, 5)

	local titleLabel = Instance.new("TextLabel", textBoxFrame)
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, 0, 0.4, -2) -- Top portion for title
	titleLabel.Position = UDim2.fromScale(0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Theme.FontRegular.FontFace
	titleLabel.TextColor3 = Theme.TextSecondary -- Secondary color for label usually
	titleLabel.TextSize = 13
	titleLabel.TextWrapped = true
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = options.Text or "Label"

	local textBox = Instance.new("TextBox", textBoxFrame)
	textBox.Name = "InputBox"
	textBox.Size = UDim2.new(1, 0, 0.6, -2) -- Bottom portion for input
	textBox.Position = UDim2.new(0, 0, 0.4, 2)
	textBox.BackgroundColor3 = Theme.Background -- Darker background for input field
	textBox.Font = Theme.FontRegular.FontFace
	textBox.TextColor3 = Theme.TextPrimary
	textBox.PlaceholderColor3 = Theme.TextSecondary
	textBox.PlaceholderText = options.PlaceholderText
	textBox.Text = options.InitialText or ""
	textBox.ClearTextOnFocus = options.ClearOnFocus
	textBox.TextSize = 15
	textBox.TextXAlignment = Enum.TextXAlignment.Left

	local inputCorner = Instance.new("UICorner", textBox)
	inputCorner.CornerRadius = Theme.SmallCornerRadius
	local inputPadding = Instance.new("UIPadding", textBox)
	inputPadding.PaddingLeft = UDim.new(0, 8)
	inputPadding.PaddingRight = UDim.new(0, 8)
	local inputStroke = Instance.new("UIStroke", textBox) -- Inner stroke for the box itself
	inputStroke.Color = Theme.Border
	inputStroke.Thickness = Theme.BorderThickness

	local TextBoxAPI = {
		Instance = textBoxFrame,
		_callback = options.Callback -- Called on FocusLost
	}

	-- Highlight on focus
	table.insert(uiRef._connections, textBox.Focused:Connect(function()
		inputStroke.Color = Theme.Accent
		inputStroke.Thickness = Theme.BorderThickness + 1
	end))
	table.insert(uiRef._connections, textBox.FocusLost:Connect(function(enterPressed)
		inputStroke.Color = Theme.Border
		inputStroke.Thickness = Theme.BorderThickness
		if TextBoxAPI._callback then
			TextBoxAPI._callback(textBox.Text, enterPressed) -- Pass text and if enter was pressed
		end
	end))

	function TextBoxAPI:GetText() return textBox.Text end
	function TextBoxAPI:SetText(text, suppressCallback)
		textBox.Text = text or ""
		if TextBoxAPI._callback and not suppressCallback then
			TextBoxAPI._callback(textBox.Text, false) -- Indicate enter wasn't pressed
		end
	end
	function TextBoxAPI:SetPlaceholder(text) textBox.PlaceholderText = text or "" end
	function TextBoxAPI:SetCallback(callback) TextBoxAPI._callback = callback end
	function TextBoxAPI:SetVisible(visible) textBoxFrame.Visible = visible end
	function TextBoxAPI:Destroy() textBoxFrame:Destroy() end

	return TextBoxAPI
end


-- // BindKey \\ --
function PurpleBotUI:CreateBindKey(uiRef, parent, options)
	options.Bind = options.Bind or "None"
	options.Name = options.Name or "Keybind"

	local bindFrame = Instance.new("Frame", parent)
	bindFrame.Name = options.Name
	bindFrame.Size = UDim2.new(0.9, 0, 0, 35)
	bindFrame.BackgroundColor3 = Theme.Surface
	bindFrame.BorderSizePixel = 0

	local corner = Instance.new("UICorner", bindFrame)
	corner.CornerRadius = Theme.SmallCornerRadius

	local stroke = Instance.new("UIStroke", bindFrame)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Theme.Border
	stroke.Thickness = Theme.BorderThickness

	local padding = Instance.new("UIPadding", bindFrame)
	padding.PaddingLeft = Theme.ElementPadding
	padding.PaddingRight = Theme.ElementPadding

	local titleLabel = Instance.new("TextLabel", bindFrame)
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(0.6, 0, 1, 0) -- Adjust width split
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Theme.FontRegular.FontFace
	titleLabel.TextColor3 = Theme.TextPrimary
	titleLabel.TextSize = 16
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextYAlignment = Enum.VerticalAlignment.Center
	titleLabel.Text = options.Name

	local bindButton = Instance.new("TextButton", bindFrame)
	bindButton.Name = "BindButton"
	bindButton.Size = UDim2.new(0.4, -Theme.ElementPadding.Offset, 1, -8) -- Adjust width, slightly smaller height
	bindButton.Position = UDim2.new(0.6, 0, 0.5, 0)
	bindButton.AnchorPoint = Vector2.new(0, 0.5)
	bindButton.BackgroundColor3 = Theme.Background
	bindButton.Font = Theme.FontMedium.FontFace
	bindButton.TextColor3 = Theme.TextSecondary
	bindButton.TextSize = 14
	bindButton.Text = options.Bind
	bindButton.AutoButtonColor = false

	local btnCorner = Instance.new("UICorner", bindButton)
	btnCorner.CornerRadius = Theme.SmallCornerRadius
	local btnStroke = Instance.new("UIStroke", bindButton)
	btnStroke.Color = Theme.Border
	btnStroke.Thickness = Theme.BorderThickness

	local BindAPI = {
		Instance = bindFrame,
		_bind = options.Bind,
		_bindType = nil, -- 'KeyCode' or 'UserInputType'
		_callback = options.Callback,
		_isBinding = false,
		_connection = nil, -- To store the InputBegan connection
		_useProcess = options.UseProcess == true -- Whether to ignore processed events
	}

	-- Determine initial bind type
	if Enum.KeyCode[BindAPI._bind] then
		BindAPI._bindType = 'KeyCode'
	elseif Enum.UserInputType[BindAPI._bind] then
		BindAPI._bindType = 'UserInputType'
	end

	local function startBinding()
		BindAPI._isBinding = true
		bindButton.Text = "..."
		bindButton.TextColor3 = Theme.Accent
		btnStroke.Color = Theme.Accent
		btnStroke.Thickness = Theme.BorderThickness + 1

		-- Disconnect previous listener if any
		if BindAPI._connection then BindAPI._connection:Disconnect() BindAPI._connection = nil end

		-- Listen for the next input
		BindAPI._connection = UserInputService.InputBegan:Connect(function(input, processed)
			if BindAPI._isBinding then -- Check again in case of race conditions
				if processed and not BindAPI._useProcess then return end -- Ignore processed event if not allowed

				local newBind = "None"
				local newBindType = nil

				if input.UserInputType == Enum.UserInputType.Keyboard then
					newBind = input.KeyCode.Name
					newBindType = 'KeyCode'
				elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
					newBind = "MouseButton1"
					newBindType = 'UserInputType'
				elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
					newBind = "MouseButton2"
					newBindType = 'UserInputType'
				elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
					newBind = "MouseButton3"
					newBindType = 'UserInputType'
				-- Add MouseWheel or other types if needed
				end

				if newBind ~= "None" and newBind ~= "Escape" then -- Don't bind Escape, allow it to cancel
					BindAPI._bind = newBind
					BindAPI._bindType = newBindType
					bindButton.Text = newBind
					if BindAPI._callback then BindAPI._callback(newBind) end -- Callback with the new bind
				else
					bindButton.Text = BindAPI._bind -- Revert text if Escape or invalid bind pressed
				end

				-- Stop binding
				BindAPI._isBinding = false
				bindButton.TextColor3 = Theme.TextSecondary
				btnStroke.Color = Theme.Border
				btnStroke.Thickness = Theme.BorderThickness
				if BindAPI._connection then BindAPI._connection:Disconnect() BindAPI._connection = nil end
			end
		end)
	end

	-- Stop binding if focus is lost from the button (e.g., clicking elsewhere)
	-- Note: TextButton doesn't have a reliable FocusLost for this purpose.
	-- Consider stopping binding on any other MouseButton1 click outside the button.

	table.insert(uiRef._connections, bindButton.MouseButton1Click:Connect(startBinding))

	-- Global listener for triggering the bind
	table.insert(uiRef._connections, UserInputService.InputBegan:Connect(function(input, processed)
		if BindAPI._isBinding then return end -- Don't trigger while binding
		if processed and BindAPI._useProcess then return end -- Ignore processed based on setting

		local triggered = false
		if BindAPI._bindType == 'KeyCode' and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == BindAPI._bind then
			triggered = true
		elseif BindAPI._bindType == 'UserInputType' and input.UserInputType.Name == BindAPI._bind then
			triggered = true
		end

		if triggered and BindAPI._callback then
			-- IMPORTANT: The callback here should be the ACTION to perform,
			-- not the callback for when the bind is SET. Needs clarification in usage.
			-- Assuming the options.Callback is the action to perform.
			BindAPI._callback(BindAPI._bind) -- Pass the bind that triggered it
		end
	end))

	function BindAPI:GetBind() return BindAPI._bind end
	function BindAPI:SetBind(bindValue, suppressCallback)
		local newBindType = nil
		if Enum.KeyCode[bindValue] then
			newBindType = 'KeyCode'
		elseif Enum.UserInputType[bindValue] then
			newBindType = 'UserInputType'
		else
			bindValue = "None" -- Invalid bind
		end

		if BindAPI._bind ~= bindValue then
			BindAPI._bind = bindValue
			BindAPI._bindType = newBindType
			bindButton.Text = BindAPI._bind
			if BindAPI._callback and not suppressCallback then
				BindAPI._callback(BindAPI._bind) -- Callback for setting the bind
			end
		end
	end
	-- Distinguish between SetCallback (for setting the bind) and ActionCallback (for triggering)
	function BindAPI:SetBindSetCallback(callback) BindAPI._callback = callback end -- Called when bind is changed
	function BindAPI:SetActionCallback(callback) BindAPI._actionCallback = callback end -- TODO: Modify InputBegan listener to use this
	function BindAPI:SetVisible(visible) bindFrame.Visible = visible end
	function BindAPI:Destroy() bindFrame:Destroy() end

	return BindAPI
end


-- // BindButton (Mobile Button) \\ --
-- This seems overly complex and tied to specific UI. Simplifying.
-- Recommendation: Use ContextActionService for better cross-platform input handling.
-- Providing a simplified version based on the original structure:
function PurpleBotUI:CreateBindButton(uiRef, parent, options)
	options.Text = options.Text or "BTN"
	options.Visible = options.Visible == true
	options.Position = options.Position or UDim2.fromScale(0.8, 0.8)
	options.Size = options.Size or UDim2.fromScale(0.1, 0.1)

	local mobileButton = Instance.new("TextButton", uiRef._internal.screenGui) -- Parent to screenGui
	mobileButton.Name = options.Name or "MobileButton"
	mobileButton.Size = options.Size
	mobileButton.Position = options.Position
	mobileButton.BackgroundColor3 = Theme.Secondary
	mobileButton.BorderSizePixel = 0
	mobileButton.Font = Theme.FontBold.FontFace
	mobileButton.TextColor3 = Theme.TextOnAccent
	mobileButton.TextSize = 18
	mobileButton.Text = options.Text
	mobileButton.Visible = options.Visible
	mobileButton.ZIndex = 150 -- Above main UI but below notifications/tooltips
	mobileButton.AutoButtonColor = false

	local corner = Instance.new("UICorner", mobileButton)
	corner.CornerRadius = UDim.new(1, 0) -- Make it circular/pill

	local aspect = Instance.new("UIAspectRatioConstraint", mobileButton)
	aspect.AspectRatio = 1.0 -- Make it square/circular

	local stroke = Instance.new("UIStroke", mobileButton)
	stroke.Color = Color3.new(1,1,1)
	stroke.Transparency = 0.5
	stroke.Thickness = 2

	local ButtonAPI = {
		Instance = mobileButton,
		_callback_Pressed = options.Pressed,
		_callback_Released = options.Released,
		_isDraggable = false,
		_dragDetector = nil
	}

	setupHoverEffect(mobileButton, {BackgroundTransparency = 0.2}, {BackgroundTransparency = 0})

	table.insert(uiRef._connections, mobileButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if ButtonAPI._callback_Pressed then ButtonAPI._callback_Pressed() end
			-- Scale/color feedback
			tween(mobileButton, fastTweenInfo, {Size = options.Size * 0.9, BackgroundTransparency = 0.3})
		end
	end))

	table.insert(uiRef._connections, mobileButton.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if ButtonAPI._callback_Released then ButtonAPI._callback_Released() end
			-- Restore visual state
			tween(mobileButton, fastTweenInfo, {Size = options.Size, BackgroundTransparency = 0})
		end
	end))

	function ButtonAPI:SetDraggable(draggable)
		if draggable and not ButtonAPI._isDraggable then
			ButtonAPI._dragDetector = Instance.new("UIDragDetector")
			ButtonAPI._dragDetector.Parent = mobileButton
			ButtonAPI._isDraggable = true
		elseif not draggable and ButtonAPI._isDraggable then
			if ButtonAPI._dragDetector then ButtonAPI._dragDetector:Destroy() end
			ButtonAPI._dragDetector = nil
			ButtonAPI._isDraggable = false
		end
	end

	-- Connect drag start/end if needed for visual changes
	if ButtonAPI._isDraggable and ButtonAPI._dragDetector then
		table.insert(uiRef._connections, ButtonAPI._dragDetector.DragStart:Connect(function() mobileButton.BackgroundTransparency = 0.5 end))
		table.insert(uiRef._connections, ButtonAPI._dragDetector.DragEnd:Connect(function() mobileButton.BackgroundTransparency = 0 end))
	end

	function ButtonAPI:SetPosition(pos) mobileButton.Position = pos end
	function ButtonAPI:GetPosition() return mobileButton.Position end
	function ButtonAPI:SetVisible(visible) mobileButton.Visible = visible end
	function ButtonAPI:SetPressedCallback(cb) ButtonAPI._callback_Pressed = cb end
	function ButtonAPI:SetReleasedCallback(cb) ButtonAPI._callback_Released = cb end
	function ButtonAPI:Destroy() mobileButton:Destroy() end

	return ButtonAPI
end

-- // Drawing (Simplified Circle Example) \\ --
-- Note: Screen drawing usually involves more complex logic (world to screen conversion etc.)
-- This is a basic UI circle implementation.
function PurpleBotUI:CreateDrawing(uiRef, parent, options)
	options.Type = options.Type or "Circle"
	options.Visible = options.Visible == true
	options.Color = options.Color or Theme.Accent
	options.Thickness = options.Thickness or 2
	options.Radius = options.Radius or 50 -- Pixel radius
	options.Position = options.Position or UDim2.fromScale(0.5, 0.5) -- Center screen default

	if options.Type ~= "Circle" then
		warn("PurpleBotUI: Drawing type '"..options.Type.."' not implemented.")
		return nil
	end

	local circleFrame = Instance.new("Frame", uiRef._internal.screenGui) -- Parent to screenGui for overlay
	circleFrame.Name = options.Name or "DrawingCircle"
	circleFrame.Size = UDim2.new(0, options.Radius * 2, 0, options.Radius * 2)
	circleFrame.Position = options.Position
	circleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	circleFrame.BackgroundTransparency = 1 -- Transparent background
	circleFrame.BorderSizePixel = 0
	circleFrame.Visible = options.Visible
	circleFrame.ZIndex = 1 -- Lowest ZIndex for drawings usually

	local corner = Instance.new("UICorner", circleFrame)
	corner.CornerRadius = UDim.new(1, 0) -- Perfect circle

	local stroke = Instance.new("UIStroke", circleFrame)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = options.Color
	stroke.Thickness = options.Thickness

	local aspect = Instance.new("UIAspectRatioConstraint", circleFrame) -- Keep it circular

	local DrawingAPI = { Instance = circleFrame }

	function DrawingAPI:SetVisible(visible) circleFrame.Visible = visible end
	function DrawingAPI:SetPosition(pos: UDim2) circleFrame.Position = pos end
	function DrawingAPI:SetRadius(radius: number)
		options.Radius = radius
		circleFrame.Size = UDim2.new(0, radius * 2, 0, radius * 2)
	end
	function DrawingAPI:SetColor(color: Color3)
		options.Color = color
		stroke.Color = color
	end
	function DrawingAPI:SetThickness(thickness: number)
		options.Thickness = thickness
		stroke.Thickness = thickness
	end
	function DrawingAPI:GetRadius() return options.Radius end
	function DrawingAPI:GetPosition() return circleFrame.Position end
	function DrawingAPI:Destroy() circleFrame:Destroy() end

	return DrawingAPI
end


return PurpleBotUI
