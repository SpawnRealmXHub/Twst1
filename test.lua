-- SpawnRealm / Moondiety UI Library Module
local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Helper: Make UI Draggy
local function makeDraggable(topbar, object)
	local dragging, dragInput, dragStart, startPos

	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = object.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	topbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- Create Main Window
function Library.CreateWindow(titleText, subText)
	local window = {}
	
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "SpawnRealmHub_" .. math.random(1000, 9999)
	ScreenGui.Parent = (gethui and gethui()) or CoreGui
	ScreenGui.ResetOnSpawn = false

	-- Responsive Main Frame (Compact, fixed design scale suitable for mobile & PC)
	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.new(0, 620, 0, 370)
	Main.Position = UDim2.new(0.5, -310, 0.5, -185)
	Main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
	Main.BorderSizePixel = 0
	Main.Parent = ScreenGui

	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 10)
	MainCorner.Parent = Main

	-- Topbar / Header
	local Topbar = Instance.new("Frame")
	Topbar.Name = "Topbar"
	Topbar.Size = UDim2.new(1, 0, 0, 50)
	Topbar.BackgroundTransparency = 1
	Topbar.Parent = Main

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size = UDim2.new(0, 200, 0, 20)
	TitleLabel.Position = UDim2.new(0, 16, 0, 8)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = titleText or "SpawnRealm"
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextSize = 16
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = Topbar

	local SubTitleLabel = Instance.new("TextLabel")
	SubTitleLabel.Size = UDim2.new(0, 200, 0, 14)
	SubTitleLabel.Position = UDim2.new(0, 16, 0, 26)
	SubTitleLabel.BackgroundTransparency = 1
	SubTitleLabel.Text = subText or "Universal"
	SubTitleLabel.TextColor3 = Color3.fromRGB(130, 130, 140)
	SubTitleLabel.TextSize = 11
	SubTitleLabel.Font = Enum.Font.GothamMedium
	SubTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	SubTitleLabel.Parent = Topbar

	-- Mini Stats Widget (Top Right of Main Frame)
	local StatsFrame = Instance.new("Frame")
	StatsFrame.Size = UDim2.new(0, 210, 0, 26)
	StatsFrame.Position = UDim2.new(1, -230, 0, 12)
	StatsFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
	StatsFrame.BorderSizePixel = 0
	StatsFrame.Parent = Topbar

	local StatsCorner = Instance.new("UICorner")
	StatsCorner.CornerRadius = UDim.new(0, 6)
	StatsCorner.Parent = StatsFrame

	local StatsLayout = Instance.new("UIListLayout")
	StatsLayout.FillDirection = Enum.FillDirection.Horizontal
	StatsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	StatsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	StatsLayout.Padding = UDim.new(0, 10)
	StatsLayout.Parent = StatsFrame

	local function createStatLabel(text)
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0, 55, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
		lbl.TextSize = 10
		lbl.Font = Enum.Font.GothamMedium
		lbl.Parent = StatsFrame
		return lbl
	end

	local PingLabel = createStatLabel("32 ms")
	local FpsLabel = createStatLabel("60 fps")
	local PlayersLabel = createStatLabel("12 players")

	-- Live update stats loop
	task.spawn(function()
		local lastUpdate = 0
		RunService.RenderStepped:Connect(function(dt)
			lastUpdate += dt
			if lastUpdate >= 1 then
				lastUpdate = 0
				local ping = 0
				pcall(function()
					ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
				end)
				PingLabel.Text = ping .. " ms"
				FpsLabel.Text = math.floor(1 / dt) .. " fps"
				PlayersLabel.Text = #Players:GetPlayers() .. " players"
			end
		end)
	end)

	-- Window Control (Close)
	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(0, 22, 0, 22)
	CloseBtn.Position = UDim2.new(1, -32, 0, 14)
	CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
	CloseBtn.Text = "×"
	CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	CloseBtn.TextSize = 15
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.Parent = Topbar

	local CloseCorner = Instance.new("UICorner")
	CloseCorner.CornerRadius = UDim.new(0, 6)
	CloseCorner.Parent = CloseBtn

	CloseBtn.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
	end)

	makeDraggable(Topbar, Main)

	-- Sidebar Tab Container (Left)
	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Name = "TabContainer"
	TabContainer.Size = UDim2.new(0, 140, 1, -60)
	TabContainer.Position = UDim2.new(0, 12, 0, 52)
	TabContainer.BackgroundTransparency = 1
	TabContainer.ScrollBarThickness = 0
	TabContainer.Parent = Main

	local TabList = Instance.new("UIListLayout")
	TabList.Padding = UDim.new(0, 5)
	TabList.Parent = TabContainer

	-- Pages Holder Area (Right)
	local PagesHolder = Instance.new("Frame")
	PagesHolder.Name = "PagesHolder"
	PagesHolder.Size = UDim2.new(1, -170, 1, -60)
	PagesHolder.Position = UDim2.new(0, 160, 0, 52)
	PagesHolder.BackgroundTransparency = 1
	PagesHolder.Parent = Main

	local tabs = {}
	local firstTab = true

	function window:CreateTab(tabName)
		local tab = {}
		
		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(1, 0, 0, 34)
		TabBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
		TabBtn.Text = "   " .. tabName
		TabBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
		TabBtn.Font = Enum.Font.GothamMedium
		TabBtn.TextSize = 12
		TabBtn.TextXAlignment = Enum.TextXAlignment.Left
		TabBtn.Parent = TabContainer

		local TabCorner = Instance.new("UICorner")
		TabCorner.CornerRadius = UDim.new(0, 7)
		TabCorner.Parent = TabBtn

		-- Page Frame containing two columns
		local Page = Instance.new("ScrollingFrame")
		Page.Name = tabName .. "Page"
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 3
		Page.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60)
		Page.Visible = false
		Page.Parent = PagesHolder

		local LeftCol = Instance.new("ScrollingFrame")
		LeftCol.Name = "LeftColumn"
		LeftCol.Size = UDim2.new(0.5, -5, 1, 0)
		LeftCol.BackgroundTransparency = 1
		LeftCol.ScrollBarThickness = 0
		LeftCol.Parent = Page

		local LeftLayout = Instance.new("UIListLayout")
		LeftLayout.Padding = UDim.new(0, 8)
		LeftLayout.Parent = LeftCol

		local RightCol = Instance.new("ScrollingFrame")
		RightCol.Name = "RightColumn"
		RightCol.Size = UDim2.new(0.5, -5, 1, 0)
		RightCol.Position = UDim2.new(0.5, 5, 0, 0)
		RightCol.BackgroundTransparency = 1
		RightCol.ScrollBarThickness = 0
		RightCol.Parent = Page

		local RightLayout = Instance.new("UIListLayout")
		RightLayout.Padding = UDim.new(0, 8)
		RightLayout.Parent = RightCol

		if firstTab then
			Page.Visible = true
			TabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
			TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			firstTab = false
		end

		TabBtn.MouseButton1Click:Connect(function()
			for _, t in pairs(tabs) do
				t.Page.Visible = false
				TweenService:Create(t.Button, TWEEN_INFO, {BackgroundColor3 = Color3.fromRGB(22, 22, 26), TextColor3 = Color3.fromRGB(150, 150, 160)}):Play()
			end
			Page.Visible = true
			TweenService:Create(TabBtn, TWEEN_INFO, {BackgroundColor3 = Color3.fromRGB(28, 28, 34), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
		end)

		table.insert(tabs, {Button = TabBtn, Page = Page})

		function tab:CreateSection(columnSide, sectionTitle)
			local targetCol = (columnSide:lower() == "right") and RightCol or LeftCol

			local SectionFrame = Instance.new("Frame")
			SectionFrame.Size = UDim2.new(1, 0, 0, 100)
			SectionFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
			SectionFrame.BorderSizePixel = 0
			SectionFrame.Parent = targetCol

			local SecCorner = Instance.new("UICorner")
			SecCorner.CornerRadius = UDim.new(0, 7)
			SecCorner.Parent = SectionFrame

			local SecTitle = Instance.new("TextLabel")
			SecTitle.Size = UDim2.new(1, -16, 0, 26)
			SecTitle.Position = UDim2.new(0, 10, 0, 0)
			SecTitle.BackgroundTransparency = 1
			SecTitle.Text = sectionTitle
			SecTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
			SecTitle.TextSize = 12
			SecTitle.Font = Enum.Font.GothamBold
			SecTitle.TextXAlignment = Enum.TextXAlignment.Left
			SecTitle.Parent = SectionFrame

			local InnerList = Instance.new("UIListLayout")
			InnerList.Padding = UDim.new(0, 5)
			InnerList.SortOrder = Enum.SortOrder.LayoutOrder
			InnerList.Parent = SectionFrame

			InnerList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				SectionFrame.Size = UDim2.new(1, 0, 0, InnerList.AbsoluteContentSize.Y + 12)
			end)

			local section = {}

			function section:CreateToggle(name, desc, default, callback)
				local state = default or false

				local ToggleItem = Instance.new("Frame")
				ToggleItem.Size = UDim2.new(1, -14, 0, desc and 38 or 28)
				ToggleItem.BackgroundTransparency = 1
				ToggleItem.Parent = SectionFrame

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, -50, 0, 16)
				Label.Position = UDim2.new(0, 6, 0, desc and 2 or 6)
				Label.BackgroundTransparency = 1
				Label.Text = name
				Label.TextColor3 = Color3.fromRGB(210, 210, 220)
				Label.TextSize = 11
				Label.Font = Enum.Font.GothamMedium
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = ToggleItem

				if desc then
					local DescLabel = Instance.new("TextLabel")
					DescLabel.Size = UDim2.new(1, -50, 0, 12)
					DescLabel.Position = UDim2.new(0, 6, 0, 18)
					DescLabel.BackgroundTransparency = 1
					DescLabel.Text = desc
					DescLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
					DescLabel.TextSize = 9
					DescLabel.Font = Enum.Font.Gotham
					DescLabel.TextXAlignment = Enum.TextXAlignment.Left
					DescLabel.Parent = ToggleItem
				end

				local ToggleBtn = Instance.new("TextButton")
				ToggleBtn.Size = UDim2.new(0, 32, 0, 18)
				ToggleBtn.Position = UDim2.new(1, -36, 0.5, -9)
				ToggleBtn.BackgroundColor3 = state and Color3.fromRGB(220, 30, 60) or Color3.fromRGB(45, 45, 52)
				ToggleBtn.Text = ""
				ToggleBtn.Parent = ToggleItem

				local BtnCorner = Instance.new("UICorner")
				BtnCorner.CornerRadius = UDim.new(1, 0)
				BtnCorner.Parent = ToggleBtn

				local Circle = Instance.new("Frame")
				Circle.Size = UDim2.new(0, 12, 0, 12)
				Circle.Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
				Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Circle.Parent = ToggleBtn

				local CircleCorner = Instance.new("UICorner")
				CircleCorner.CornerRadius = UDim.new(1, 0)
				CircleCorner.Parent = Circle

				ToggleBtn.MouseButton1Click:Connect(function()
					state = not state
					local targetPos = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
					local targetColor = state and Color3.fromRGB(220, 30, 60) or Color3.fromRGB(45, 45, 52)

					TweenService:Create(Circle, TWEEN_INFO, {Position = targetPos}):Play()
					TweenService:Create(ToggleBtn, TWEEN_INFO, {BackgroundColor3 = targetColor}):Play()
					pcall(callback, state)
				end)
			end

			function section:CreateButton(name, callback)
				local Btn = Instance.new("TextButton")
				Btn.Size = UDim2.new(1, -14, 0, 28)
				Btn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
				Btn.Text = "  " .. name
				Btn.TextColor3 = Color3.fromRGB(210, 210, 220)
				Btn.Font = Enum.Font.GothamMedium
				Btn.TextSize = 11
				Btn.TextXAlignment = Enum.TextXAlignment.Left
				Btn.Parent = SectionFrame

				local BtnCorner = Instance.new("UICorner")
				BtnCorner.CornerRadius = UDim.new(0, 5)
				BtnCorner.Parent = Btn

				Btn.MouseButton1Click:Connect(function()
					TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 48)}):Play()
					task.delay(0.1, function()
						TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(28, 28, 34)}):Play()
					end)
					pcall(callback)
				end)
			end

			return section
		end

		return tab
	end

	return window
end

return Library